using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.WinDraw;
using System.WinDraw.Design;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Permissions;

namespace System.WinForms;

/// <summary>Represents a small rectangular pop-up window that displays a brief description of a control's purpose when the user rests the pointer on the control.</summary>
/// <filterpriority>1</filterpriority>
[ProvideProperty("ToolTip", typeof(Control))]
[DefaultEvent("Popup")]
[ToolboxItemFilter("WinForms")]
[SRDescription("DescriptionToolTip")]
public class ToolTip : Component, IExtenderProvider
{
	private class ToolTipNativeWindow : NativeWindow
	{
		private ToolTip control;

		internal ToolTipNativeWindow(ToolTip control)
		{
			this.control = control;
		}

		protected override void WndProc(ref Message m)
		{
			if (control != null)
			{
				control.WndProc(ref m);
			}
		}
	}

	private class ToolTipTimer : Timer
	{
		private IWin32Window host;

		public IWin32Window Host => host;

		public ToolTipTimer(IWin32Window owner)
		{
			host = owner;
		}
	}

	private class TipInfo
	{
		[Flags]
		public enum Type
		{
			None = 0,
			Auto = 1,
			Absolute = 2,
			SemiAbsolute = 4
		}

		public Type TipType = Type.Auto;

		private string caption;

		private string designerText;

		public Point Position = Point.Empty;

		public string Caption
		{
			get
			{
				if ((TipType & (Type.Absolute | Type.SemiAbsolute)) == 0)
				{
					return designerText;
				}
				return caption;
			}
			set
			{
				caption = value;
			}
		}

		public TipInfo(string caption, Type type)
		{
			this.caption = caption;
			TipType = type;
			if (type == Type.Auto)
			{
				designerText = caption;
			}
		}
	}

	private const int DEFAULT_DELAY = 500;

	private const int RESHOW_RATIO = 5;

	private const int AUTOPOP_RATIO = 10;

	private const int XBALLOONOFFSET = 10;

	private const int YBALLOONOFFSET = 8;

	private const int TOP_LOCATION_INDEX = 0;

	private const int RIGHT_LOCATION_INDEX = 1;

	private const int BOTTOM_LOCATION_INDEX = 2;

	private const int LEFT_LOCATION_INDEX = 3;

	private const int LOCATION_TOTAL = 4;

	private Hashtable tools = new Hashtable();

	private int[] delayTimes = new int[4];

	private bool auto = true;

	private bool showAlways;

	private ToolTipNativeWindow window;

	private Control topLevelControl;

	private bool active = true;

	private bool ownerDraw;

	private object userData;

	private Color backColor = SystemColors.Info;

	private Color foreColor = SystemColors.InfoText;

	private bool isBalloon;

	private bool isDisposing;

	private string toolTipTitle = string.Empty;

	private ToolTipIcon toolTipIcon;

	private ToolTipTimer timer;

	private Hashtable owners = new Hashtable();

	private bool stripAmpersands;

	private bool useAnimation = true;

	private bool useFading = true;

	private int originalPopupDelay;

	private bool trackPosition;

	private PopupEventHandler onPopup;

	private DrawToolTipEventHandler onDraw;

	private Hashtable created = new Hashtable();

	private bool cancelled;

	/// <summary>Gets or sets a value indicating whether the ToolTip is currently active.</summary>
	/// <returns>true if the ToolTip is currently active; otherwise, false. The default is true.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipActiveDescr")]
	[DefaultValue(true)]
	public bool Active
	{
		get
		{
			return active;
		}
		set
		{
			if (active != value)
			{
				active = value;
				if (!base.DesignMode && GetHandleCreated())
				{
					UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1025, value ? 1 : 0, 0);
				}
			}
		}
	}

	/// <summary>Gets or sets the automatic delay for the ToolTip.</summary>
	/// <returns>The automatic delay, in milliseconds. The default is 500.</returns>
	/// <filterpriority>1</filterpriority>
	[RefreshProperties(RefreshProperties.All)]
	[SRDescription("ToolTipAutomaticDelayDescr")]
	[DefaultValue(500)]
	public int AutomaticDelay
	{
		get
		{
			return delayTimes[0];
		}
		set
		{
			if (value < 0)
			{
				throw new ArgumentOutOfRangeException("AutomaticDelay", SR.GetString("InvalidLowBoundArgumentEx", "AutomaticDelay", value.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
			}
			SetDelayTime(0, value);
		}
	}

	/// <summary>Gets or sets the period of time the ToolTip remains visible if the pointer is stationary on a control with specified ToolTip text.</summary>
	/// <returns>The period of time, in milliseconds, that the <see cref="T:WinForms.ToolTip" /> remains visible when the pointer is stationary on a control. The default value is 5000.</returns>
	/// <filterpriority>1</filterpriority>
	[RefreshProperties(RefreshProperties.All)]
	[SRDescription("ToolTipAutoPopDelayDescr")]
	public int AutoPopDelay
	{
		get
		{
			return delayTimes[2];
		}
		set
		{
			if (value < 0)
			{
				throw new ArgumentOutOfRangeException("AutoPopDelay", SR.GetString("InvalidLowBoundArgumentEx", "AutoPopDelay", value.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
			}
			SetDelayTime(2, value);
		}
	}

	/// <summary>Gets or sets the background color for the ToolTip.</summary>
	/// <returns>The background <see cref="T:System.WinDraw.Color" />.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipBackColorDescr")]
	[DefaultValue(typeof(Color), "Info")]
	public Color BackColor
	{
		get
		{
			return backColor;
		}
		set
		{
			backColor = value;
			if (GetHandleCreated())
			{
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1043, ColorTranslator.ToWin32(backColor), 0);
			}
		}
	}

	/// <summary>Gets the creation parameters for the ToolTip window.</summary>
	/// <returns>A <see cref="T:WinForms.CreateParams" /> containing the information needed to create the ToolTip.</returns>
	protected virtual CreateParams CreateParams
	{
		[SecurityPermission(SecurityAction.InheritanceDemand, Flags = SecurityPermissionFlag.UnmanagedCode)]
		[SecurityPermission(SecurityAction.LinkDemand, Flags = SecurityPermissionFlag.UnmanagedCode)]
		get
		{
			CreateParams createParams = new CreateParams();
			if (TopLevelControl != null && !TopLevelControl.IsDisposed)
			{
				createParams.Parent = TopLevelControl.Handle;
			}
			createParams.ClassName = "tooltips_class32";
			if (showAlways)
			{
				createParams.Style = 1;
			}
			if (isBalloon)
			{
				createParams.Style |= 64;
			}
			if (!stripAmpersands)
			{
				createParams.Style |= 2;
			}
			if (!useAnimation)
			{
				createParams.Style |= 16;
			}
			if (!useFading)
			{
				createParams.Style |= 32;
			}
			createParams.ExStyle = 0;
			createParams.Caption = null;
			return createParams;
		}
	}

	/// <summary>Gets or sets the foreground color for the ToolTip.</summary>
	/// <returns>The foreground <see cref="T:System.WinDraw.Color" />.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipForeColorDescr")]
	[DefaultValue(typeof(Color), "InfoText")]
	public Color ForeColor
	{
		get
		{
			return foreColor;
		}
		set
		{
			if (value.IsEmpty)
			{
				throw new ArgumentException(SR.GetString("ToolTipEmptyColor", "ForeColor"));
			}
			foreColor = value;
			if (GetHandleCreated())
			{
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1044, ColorTranslator.ToWin32(foreColor), 0);
			}
		}
	}

	internal IntPtr Handle
	{
		get
		{
			if (!GetHandleCreated())
			{
				CreateHandle();
			}
			return window.Handle;
		}
	}

	private bool HasAllWindowsPermission
	{
		get
		{
			try
			{
				IntSecurity.AllWindows.Demand();
				return true;
			}
			catch (SecurityException)
			{
			}
			return false;
		}
	}

	/// <summary>Gets or sets a value indicating whether the ToolTip should use a balloon window.</summary>
	/// <returns>true if a balloon window should be used; otherwise, false if a standard rectangular window should be used. The default is false.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipIsBalloonDescr")]
	[DefaultValue(false)]
	public bool IsBalloon
	{
		get
		{
			return isBalloon;
		}
		set
		{
			if (isBalloon != value)
			{
				isBalloon = value;
				if (GetHandleCreated())
				{
					RecreateHandle();
				}
			}
		}
	}

	/// <summary>Gets or sets the time that passes before the ToolTip appears.</summary>
	/// <returns>The period of time, in milliseconds, that the pointer must remain stationary on a control before the ToolTip window is displayed.</returns>
	/// <filterpriority>1</filterpriority>
	[RefreshProperties(RefreshProperties.All)]
	[SRDescription("ToolTipInitialDelayDescr")]
	public int InitialDelay
	{
		get
		{
			return delayTimes[3];
		}
		set
		{
			if (value < 0)
			{
				throw new ArgumentOutOfRangeException("InitialDelay", SR.GetString("InvalidLowBoundArgumentEx", "InitialDelay", value.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
			}
			SetDelayTime(3, value);
		}
	}

	/// <summary>Gets or sets a value indicating whether the ToolTip is drawn by the operating system or by code that you provide.</summary>
	/// <returns>true if the <see cref="T:WinForms.ToolTip" /> is drawn by code that you provide; false if the <see cref="T:WinForms.ToolTip" /> is drawn by the operating system. The default is false.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.UIPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Window="AllWindows" />
	/// </PermissionSet>
	[SRCategory("CatBehavior")]
	[DefaultValue(false)]
	[SRDescription("ToolTipOwnerDrawDescr")]
	public bool OwnerDraw
	{
		get
		{
			return ownerDraw;
		}
		[UIPermission(SecurityAction.Demand, Window = UIPermissionWindow.AllWindows)]
		set
		{
			ownerDraw = value;
		}
	}

	/// <summary>Gets or sets the length of time that must transpire before subsequent ToolTip windows appear as the pointer moves from one control to another.</summary>
	/// <returns>The length of time, in milliseconds, that it takes subsequent ToolTip windows to appear.</returns>
	/// <filterpriority>2</filterpriority>
	[RefreshProperties(RefreshProperties.All)]
	[SRDescription("ToolTipReshowDelayDescr")]
	public int ReshowDelay
	{
		get
		{
			return delayTimes[1];
		}
		set
		{
			if (value < 0)
			{
				throw new ArgumentOutOfRangeException("ReshowDelay", SR.GetString("InvalidLowBoundArgumentEx", "ReshowDelay", value.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
			}
			SetDelayTime(1, value);
		}
	}

	/// <summary>Gets or sets a value indicating whether a ToolTip window is displayed, even when its parent control is not active.</summary>
	/// <returns>true if the ToolTip is always displayed; otherwise, false. The default is false.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[DefaultValue(false)]
	[SRDescription("ToolTipShowAlwaysDescr")]
	public bool ShowAlways
	{
		get
		{
			return showAlways;
		}
		set
		{
			if (showAlways != value)
			{
				showAlways = value;
				if (GetHandleCreated())
				{
					RecreateHandle();
				}
			}
		}
	}

	/// <summary>Gets or sets a value that determines how ampersand (&amp;) characters are treated.</summary>
	/// <returns>true if ampersand characters are stripped from the ToolTip text; otherwise, false. The default is false.</returns>
	/// <filterpriority>2</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipStripAmpersandsDescr")]
	[Browsable(true)]
	[DefaultValue(false)]
	public bool StripAmpersands
	{
		get
		{
			return stripAmpersands;
		}
		set
		{
			if (stripAmpersands != value)
			{
				stripAmpersands = value;
				if (GetHandleCreated())
				{
					RecreateHandle();
				}
			}
		}
	}

	/// <summary>Gets or sets the object that contains programmer-supplied data associated with the <see cref="T:WinForms.ToolTip" />.</summary>
	/// <returns>An <see cref="T:System.Object" /> that contains data about the <see cref="T:WinForms.ToolTip" />. The default is null.</returns>
	/// <filterpriority>1</filterpriority>
	[SRCategory("CatData")]
	[Localizable(false)]
	[Bindable(true)]
	[SRDescription("ControlTagDescr")]
	[DefaultValue(null)]
	[TypeConverter(typeof(StringConverter))]
	public object Tag
	{
		get
		{
			return userData;
		}
		set
		{
			userData = value;
		}
	}

	/// <summary>Gets or sets a value that defines the type of icon to be displayed alongside the ToolTip text.</summary>
	/// <returns>One of the <see cref="T:WinForms.ToolTipIcon" /> enumerated values.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[DefaultValue(ToolTipIcon.None)]
	[SRDescription("ToolTipToolTipIconDescr")]
	public ToolTipIcon ToolTipIcon
	{
		get
		{
			return toolTipIcon;
		}
		set
		{
			if (toolTipIcon != value)
			{
				if (!ClientUtils.IsEnumValid(value, (int)value, 0, 3))
				{
					throw new InvalidEnumArgumentException("value", (int)value, typeof(ToolTipIcon));
				}
				toolTipIcon = value;
				if (toolTipIcon > ToolTipIcon.None && GetHandleCreated())
				{
					string lParam = ((!string.IsNullOrEmpty(toolTipTitle)) ? toolTipTitle : " ");
					UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_SETTITLE, (int)toolTipIcon, lParam);
					UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1053, 0, 0);
				}
			}
		}
	}

	/// <summary>Gets or sets a title for the ToolTip window.</summary>
	/// <returns>A <see cref="T:System.String" /> containing the window title.</returns>
	[DefaultValue("")]
	[SRDescription("ToolTipTitleDescr")]
	public string ToolTipTitle
	{
		get
		{
			return toolTipTitle;
		}
		set
		{
			if (value == null)
			{
				value = string.Empty;
			}
			if (toolTipTitle != value)
			{
				toolTipTitle = value;
				if (GetHandleCreated())
				{
					UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_SETTITLE, (int)toolTipIcon, toolTipTitle);
					UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1053, 0, 0);
				}
			}
		}
	}

	private Control TopLevelControl
	{
		get
		{
			Control control = null;
			if (topLevelControl == null)
			{
				Control[] array = new Control[tools.Keys.Count];
				tools.Keys.CopyTo(array, 0);
				if (array != null && array.Length != 0)
				{
					for (int i = 0; i < array.Length; i++)
					{
						Control control2 = array[i];
						control = control2.TopLevelControlInternal;
						if (control != null)
						{
							break;
						}
						if (control2.IsActiveX)
						{
							control = control2;
							break;
						}
						if (control == null && control2 != null && control2.ParentInternal != null)
						{
							while (control2.ParentInternal != null)
							{
								control2 = control2.ParentInternal;
							}
							control = control2;
							if (control != null)
							{
								break;
							}
						}
					}
				}
				topLevelControl = control;
				if (control != null)
				{
					control.HandleCreated += TopLevelCreated;
					control.HandleDestroyed += TopLevelDestroyed;
					if (control.IsHandleCreated)
					{
						TopLevelCreated(control, EventArgs.Empty);
					}
					control.ParentChanged += OnTopLevelPropertyChanged;
				}
			}
			else
			{
				control = topLevelControl;
			}
			return control;
		}
	}

	/// <summary>Gets or sets a value determining whether an animation effect should be used when displaying the ToolTip.</summary>
	/// <returns>true if window animation should be used; otherwise, false. The default is true.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipUseAnimationDescr")]
	[Browsable(true)]
	[DefaultValue(true)]
	public bool UseAnimation
	{
		get
		{
			return useAnimation;
		}
		set
		{
			if (useAnimation != value)
			{
				useAnimation = value;
				if (GetHandleCreated())
				{
					RecreateHandle();
				}
			}
		}
	}

	/// <summary>Gets or sets a value determining whether a fade effect should be used when displaying the ToolTip.</summary>
	/// <returns>true if window fading should be used; otherwise, false. The default is true.</returns>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	[SRDescription("ToolTipUseFadingDescr")]
	[Browsable(true)]
	[DefaultValue(true)]
	public bool UseFading
	{
		get
		{
			return useFading;
		}
		set
		{
			if (useFading != value)
			{
				useFading = value;
				if (GetHandleCreated())
				{
					RecreateHandle();
				}
			}
		}
	}

	/// <summary>Occurs when the ToolTip is drawn and the <see cref="P:WinForms.ToolTip.OwnerDraw" /> property is set to true and the <see cref="P:WinForms.ToolTip.IsBalloon" /> property is false.</summary>
	/// <filterpriority>1</filterpriority>
	[SRCategory("CatBehavior")]
	[SRDescription("ToolTipDrawEventDescr")]
	public event DrawToolTipEventHandler Draw
	{
		add
		{
			onDraw = (DrawToolTipEventHandler)Delegate.Combine(onDraw, value);
		}
		remove
		{
			onDraw = (DrawToolTipEventHandler)Delegate.Remove(onDraw, value);
		}
	}

	/// <summary>Occurs before a ToolTip is initially displayed. This is the default event for the <see cref="T:WinForms.ToolTip" /> class.</summary>
	/// <filterpriority>1</filterpriority>
	[SRCategory("CatBehavior")]
	[SRDescription("ToolTipPopupEventDescr")]
	public event PopupEventHandler Popup
	{
		add
		{
			onPopup = (PopupEventHandler)Delegate.Combine(onPopup, value);
		}
		remove
		{
			onPopup = (PopupEventHandler)Delegate.Remove(onPopup, value);
		}
	}

	/// <summary>Initializes a new instance of the <see cref="T:WinForms.ToolTip" /> class with a specified container.</summary>
	/// <param name="cont">An <see cref="T:System.ComponentModel.IContainer" /> that represents the container of the <see cref="T:WinForms.ToolTip" />. </param>
	public ToolTip(IContainer cont)
		: this()
	{
		if (cont == null)
		{
			throw new ArgumentNullException("cont");
		}
		cont.Add(this);
	}

	/// <summary>Initializes a new instance of the <see cref="T:WinForms.ToolTip" /> without a specified container.</summary>
	public ToolTip()
	{
		window = new ToolTipNativeWindow(this);
		auto = true;
		delayTimes[0] = 500;
		AdjustBaseFromAuto();
	}

	internal void HideToolTip(IKeyboardToolTip currentTool)
	{
		Hide(currentTool.GetOwnerWindow());
	}

	internal string GetCaptionForTool(Control tool)
	{
		return ((TipInfo)tools[tool])?.Caption;
	}

	private bool IsWindowActive(IWin32Window window)
	{
		if (window is Control control && (control.ShowParams & 0xF) != 4)
		{
			IntPtr activeWindow = UnsafeNativeMethods.GetActiveWindow();
			IntPtr ancestor = UnsafeNativeMethods.GetAncestor(new HandleRef(window, window.Handle), 2);
			if (activeWindow != ancestor)
			{
				TipInfo tipInfo = (TipInfo)tools[control];
				if (tipInfo != null && (tipInfo.TipType & TipInfo.Type.SemiAbsolute) != 0)
				{
					tools.Remove(control);
					DestroyRegion(control);
				}
				return false;
			}
		}
		return true;
	}

	private void AdjustBaseFromAuto()
	{
		delayTimes[1] = delayTimes[0] / 5;
		delayTimes[2] = delayTimes[0] * 10;
		delayTimes[3] = delayTimes[0];
	}

	private void HandleCreated(object sender, EventArgs eventargs)
	{
		ClearTopLevelControlEvents();
		topLevelControl = null;
		Control control = (Control)sender;
		CreateRegion(control);
		CheckNativeToolTip(control);
		CheckCompositeControls(control);
		if (!AccessibilityImprovements.UseLegacyToolTipDisplay)
		{
			KeyboardToolTipStateMachine.Instance.Hook(control, this);
		}
	}

	private void CheckNativeToolTip(Control associatedControl)
	{
		if (GetHandleCreated())
		{
			if (associatedControl is TreeView treeView && treeView.ShowNodeToolTips)
			{
				treeView.SetToolTip(this, GetToolTip(associatedControl));
			}
			if (associatedControl is ToolBar)
			{
				((ToolBar)associatedControl).SetToolTip(this);
			}
			if (associatedControl is TabControl tabControl && tabControl.ShowToolTips)
			{
				tabControl.SetToolTip(this, GetToolTip(associatedControl));
			}
			if (associatedControl is ListView)
			{
				((ListView)associatedControl).SetToolTip(this, GetToolTip(associatedControl));
			}
			if (associatedControl is StatusBar)
			{
				((StatusBar)associatedControl).SetToolTip(this);
			}
			if (associatedControl is Label)
			{
				((Label)associatedControl).SetToolTip(this);
			}
		}
	}

	private void CheckCompositeControls(Control associatedControl)
	{
		if (associatedControl is UpDownBase)
		{
			((UpDownBase)associatedControl).SetToolTip(this, GetToolTip(associatedControl));
		}
	}

	private void HandleDestroyed(object sender, EventArgs eventargs)
	{
		Control control = (Control)sender;
		DestroyRegion(control);
		if (!AccessibilityImprovements.UseLegacyToolTipDisplay)
		{
			KeyboardToolTipStateMachine.Instance.Unhook(control, this);
		}
	}

	private void OnDraw(DrawToolTipEventArgs e)
	{
		if (onDraw != null)
		{
			onDraw(this, e);
		}
	}

	private void OnPopup(PopupEventArgs e)
	{
		if (onPopup != null)
		{
			onPopup(this, e);
		}
	}

	private void TopLevelCreated(object sender, EventArgs eventargs)
	{
		CreateHandle();
		CreateAllRegions();
	}

	private void TopLevelDestroyed(object sender, EventArgs eventargs)
	{
		DestoyAllRegions();
		DestroyHandle();
	}

	/// <summary>Returns true if the ToolTip can offer an extender property to the specified target component.</summary>
	/// <returns>true if the <see cref="T:WinForms.ToolTip" /> class can offer one or more extender properties; otherwise, false.</returns>
	/// <param name="target">The target object to add an extender property to. </param>
	/// <filterpriority>1</filterpriority>
	public bool CanExtend(object target)
	{
		if (target is Control && !(target is ToolTip))
		{
			return true;
		}
		return false;
	}

	private void ClearTopLevelControlEvents()
	{
		if (topLevelControl != null)
		{
			topLevelControl.ParentChanged -= OnTopLevelPropertyChanged;
			topLevelControl.HandleCreated -= TopLevelCreated;
			topLevelControl.HandleDestroyed -= TopLevelDestroyed;
		}
	}

	private void CreateHandle()
	{
		if (GetHandleCreated())
		{
			return;
		}
		IntPtr userCookie = UnsafeNativeMethods.ThemingScope.Activate();
		try
		{
			NativeMethods.INITCOMMONCONTROLSEX iNITCOMMONCONTROLSEX = new NativeMethods.INITCOMMONCONTROLSEX();
			iNITCOMMONCONTROLSEX.dwICC = 8;
			SafeNativeMethods.InitCommonControlsEx(iNITCOMMONCONTROLSEX);
			CreateParams createParams = CreateParams;
			if (GetHandleCreated())
			{
				return;
			}
			window.CreateHandle(createParams);
		}
		finally
		{
			UnsafeNativeMethods.ThemingScope.Deactivate(userCookie);
		}
		if (ownerDraw)
		{
			int num = (int)(long)UnsafeNativeMethods.GetWindowLong(new HandleRef(this, Handle), -16);
			num &= -8388609;
			UnsafeNativeMethods.SetWindowLong(new HandleRef(this, Handle), -16, new HandleRef(null, (IntPtr)num));
		}
		UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1048, 0, SystemInformation.MaxWindowTrackSize.Width);
		if (auto)
		{
			SetDelayTime(0, delayTimes[0]);
			delayTimes[2] = GetDelayTime(2);
			delayTimes[3] = GetDelayTime(3);
			delayTimes[1] = GetDelayTime(1);
		}
		else
		{
			for (int i = 1; i < delayTimes.Length; i++)
			{
				if (delayTimes[i] >= 1)
				{
					SetDelayTime(i, delayTimes[i]);
				}
			}
		}
		UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1025, active ? 1 : 0, 0);
		if (BackColor != SystemColors.Info)
		{
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1043, ColorTranslator.ToWin32(BackColor), 0);
		}
		if (ForeColor != SystemColors.InfoText)
		{
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1044, ColorTranslator.ToWin32(ForeColor), 0);
		}
		if (toolTipIcon > ToolTipIcon.None || !string.IsNullOrEmpty(toolTipTitle))
		{
			string lParam = ((!string.IsNullOrEmpty(toolTipTitle)) ? toolTipTitle : " ");
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_SETTITLE, (int)toolTipIcon, lParam);
		}
	}

	private void CreateAllRegions()
	{
		Control[] array = new Control[tools.Keys.Count];
		tools.Keys.CopyTo(array, 0);
		for (int i = 0; i < array.Length && !(array[i] is DataGridView); i++)
		{
			CreateRegion(array[i]);
		}
	}

	private void DestoyAllRegions()
	{
		Control[] array = new Control[tools.Keys.Count];
		tools.Keys.CopyTo(array, 0);
		for (int i = 0; i < array.Length && !(array[i] is DataGridView); i++)
		{
			DestroyRegion(array[i]);
		}
	}

	private void SetToolInfo(Control ctl, string caption)
	{
		bool allocatedString;
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO = GetTOOLINFO(ctl, caption, out allocatedString);
		try
		{
			int num = (int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_ADDTOOL, 0, tOOLINFO);
			if (((!(ctl is TreeView) && !(ctl is ListView)) || ((!(ctl is TreeView treeView) || !treeView.ShowNodeToolTips) && (!(ctl is ListView listView) || !listView.ShowItemToolTips))) && num == 0)
			{
				throw new InvalidOperationException(SR.GetString("ToolTipAddFailed"));
			}
		}
		finally
		{
			if (allocatedString && IntPtr.Zero != tOOLINFO.lpszText)
			{
				Marshal.FreeHGlobal(tOOLINFO.lpszText);
			}
		}
	}

	private void CreateRegion(Control ctl)
	{
		string toolTip = GetToolTip(ctl);
		bool flag = toolTip != null && toolTip.Length > 0;
		bool flag2 = ctl.IsHandleCreated && TopLevelControl != null && TopLevelControl.IsHandleCreated;
		if (!created.ContainsKey(ctl) && flag && flag2 && !base.DesignMode)
		{
			SetToolInfo(ctl, toolTip);
			created[ctl] = ctl;
		}
		if (ctl.IsHandleCreated && topLevelControl == null)
		{
			ctl.MouseMove -= MouseMove;
			ctl.MouseMove += MouseMove;
		}
	}

	private void MouseMove(object sender, MouseEventArgs me)
	{
		Control control = (Control)sender;
		if (!created.ContainsKey(control) && control.IsHandleCreated && TopLevelControl != null)
		{
			CreateRegion(control);
		}
		if (created.ContainsKey(control))
		{
			control.MouseMove -= MouseMove;
		}
	}

	internal void DestroyHandle()
	{
		if (GetHandleCreated())
		{
			window.DestroyHandle();
		}
	}

	private void DestroyRegion(Control ctl)
	{
		bool flag = ctl.IsHandleCreated && topLevelControl != null && topLevelControl.IsHandleCreated && !isDisposing;
		if (!(topLevelControl is Form form) || (form != null && !form.Modal))
		{
			flag = flag && GetHandleCreated();
		}
		if (created.ContainsKey(ctl) && flag && !base.DesignMode)
		{
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_DELTOOL, 0, GetMinTOOLINFO(ctl));
			created.Remove(ctl);
		}
	}

	/// <summary>Disposes of the <see cref="T:WinForms.ToolTip" /> component.</summary>
	/// <param name="disposing">true to release both managed and unmanaged resources; false to release only unmanaged resources. </param>
	protected override void Dispose(bool disposing)
	{
		if (disposing)
		{
			isDisposing = true;
			try
			{
				ClearTopLevelControlEvents();
				StopTimer();
				DestroyHandle();
				RemoveAll();
				window = null;
				if (TopLevelControl is Form form)
				{
					form.Deactivate -= BaseFormDeactivate;
				}
			}
			finally
			{
				isDisposing = false;
			}
		}
		base.Dispose(disposing);
	}

	internal int GetDelayTime(int type)
	{
		if (GetHandleCreated())
		{
			return (int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1045, type, 0);
		}
		return delayTimes[type];
	}

	internal bool GetHandleCreated()
	{
		if (window == null)
		{
			return false;
		}
		return window.Handle != IntPtr.Zero;
	}

	private NativeMethods.TOOLINFO_TOOLTIP GetMinTOOLINFO(Control ctl)
	{
		return GetMinToolInfoForHandle(ctl.Handle);
	}

	private NativeMethods.TOOLINFO_TOOLTIP GetMinToolInfoForTool(IWin32Window tool)
	{
		return GetMinToolInfoForHandle(tool.Handle);
	}

	private NativeMethods.TOOLINFO_TOOLTIP GetMinToolInfoForHandle(IntPtr handle)
	{
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		tOOLINFO_TOOLTIP.hwnd = handle;
		tOOLINFO_TOOLTIP.uFlags |= 1;
		tOOLINFO_TOOLTIP.uId = handle;
		return tOOLINFO_TOOLTIP;
	}

	private NativeMethods.TOOLINFO_TOOLTIP GetTOOLINFO(Control ctl, string caption, out bool allocatedString)
	{
		allocatedString = false;
		NativeMethods.TOOLINFO_TOOLTIP minTOOLINFO = GetMinTOOLINFO(ctl);
		minTOOLINFO.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		minTOOLINFO.uFlags |= 272;
		Control control = TopLevelControl;
		if (control != null && control.RightToLeft == RightToLeft.Yes && !ctl.IsMirrored)
		{
			minTOOLINFO.uFlags |= 4;
		}
		if (ctl is TreeView || ctl is ListView)
		{
			if (ctl is TreeView treeView && treeView.ShowNodeToolTips)
			{
				minTOOLINFO.lpszText = NativeMethods.InvalidIntPtr;
			}
			else if (ctl is ListView listView && listView.ShowItemToolTips)
			{
				minTOOLINFO.lpszText = NativeMethods.InvalidIntPtr;
			}
			else
			{
				minTOOLINFO.lpszText = Marshal.StringToHGlobalAuto(caption);
				allocatedString = true;
			}
		}
		else
		{
			minTOOLINFO.lpszText = Marshal.StringToHGlobalAuto(caption);
			allocatedString = true;
		}
		return minTOOLINFO;
	}

	private NativeMethods.TOOLINFO_TOOLTIP GetWinTOOLINFO(IntPtr hWnd)
	{
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		tOOLINFO_TOOLTIP.hwnd = hWnd;
		tOOLINFO_TOOLTIP.uFlags |= 273;
		Control control = TopLevelControl;
		if (control != null && control.RightToLeft == RightToLeft.Yes && ((int)(long)UnsafeNativeMethods.GetWindowLong(new HandleRef(this, hWnd), -16) & 0x400000) != 4194304)
		{
			tOOLINFO_TOOLTIP.uFlags |= 4;
		}
		tOOLINFO_TOOLTIP.uId = tOOLINFO_TOOLTIP.hwnd;
		return tOOLINFO_TOOLTIP;
	}

	/// <summary>Retrieves the ToolTip text associated with the specified control.</summary>
	/// <returns>A <see cref="T:System.String" /> containing the ToolTip text for the specified control.</returns>
	/// <param name="control">The <see cref="T:WinForms.Control" /> for which to retrieve the <see cref="T:WinForms.ToolTip" /> text. </param>
	/// <filterpriority>1</filterpriority>
	[DefaultValue("")]
	[Localizable(true)]
	[SRDescription("ToolTipToolTipDescr")]
	[Editor("System.ComponentModel.Design.MultilineStringEditor, System.Design, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a", typeof(UITypeEditor))]
	public string GetToolTip(Control control)
	{
		if (control == null)
		{
			return string.Empty;
		}
		TipInfo tipInfo = (TipInfo)tools[control];
		if (tipInfo == null || tipInfo.Caption == null)
		{
			return "";
		}
		return tipInfo.Caption;
	}

	private IntPtr GetWindowFromPoint(Point screenCoords, ref bool success)
	{
		Control control = TopLevelControl;
		if (control != null && control.IsActiveX)
		{
			IntPtr intPtr = UnsafeNativeMethods.WindowFromPoint(screenCoords.X, screenCoords.Y);
			if (intPtr != IntPtr.Zero)
			{
				Control control2 = Control.FromHandleInternal(intPtr);
				if (control2 != null && tools != null && tools.ContainsKey(control2))
				{
					return intPtr;
				}
			}
			return IntPtr.Zero;
		}
		IntPtr intPtr2 = IntPtr.Zero;
		if (control != null)
		{
			intPtr2 = control.Handle;
		}
		IntPtr intPtr3 = IntPtr.Zero;
		bool flag = false;
		while (!flag)
		{
			Point point = screenCoords;
			if (control != null)
			{
				point = control.PointToClientInternal(screenCoords);
			}
			IntPtr intPtr4 = UnsafeNativeMethods.ChildWindowFromPointEx(new HandleRef(null, intPtr2), point.X, point.Y, 1);
			if (intPtr4 == intPtr2)
			{
				intPtr3 = intPtr4;
				flag = true;
				continue;
			}
			if (intPtr4 == IntPtr.Zero)
			{
				flag = true;
				continue;
			}
			control = Control.FromHandleInternal(intPtr4);
			if (control == null)
			{
				control = Control.FromChildHandleInternal(intPtr4);
				if (control != null)
				{
					intPtr3 = control.Handle;
				}
				flag = true;
			}
			else
			{
				intPtr2 = control.Handle;
			}
		}
		if (intPtr3 != IntPtr.Zero)
		{
			Control control3 = Control.FromHandleInternal(intPtr3);
			if (control3 != null)
			{
				Control control4 = control3;
				while (control4 != null && control4.Visible)
				{
					control4 = control4.ParentInternal;
				}
				if (control4 != null)
				{
					intPtr3 = IntPtr.Zero;
				}
				success = true;
			}
		}
		return intPtr3;
	}

	private void OnTopLevelPropertyChanged(object s, EventArgs e)
	{
		ClearTopLevelControlEvents();
		topLevelControl = null;
		topLevelControl = TopLevelControl;
	}

	private void RecreateHandle()
	{
		if (!base.DesignMode)
		{
			if (GetHandleCreated())
			{
				DestroyHandle();
			}
			created.Clear();
			CreateHandle();
			CreateAllRegions();
		}
	}

	/// <summary>Removes all ToolTip text currently associated with the ToolTip component.</summary>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void RemoveAll()
	{
		Control[] array = new Control[tools.Keys.Count];
		tools.Keys.CopyTo(array, 0);
		for (int i = 0; i < array.Length; i++)
		{
			if (array[i].IsHandleCreated)
			{
				DestroyRegion(array[i]);
			}
			array[i].HandleCreated -= HandleCreated;
			array[i].HandleDestroyed -= HandleDestroyed;
			if (!AccessibilityImprovements.UseLegacyToolTipDisplay)
			{
				KeyboardToolTipStateMachine.Instance.Unhook(array[i], this);
			}
		}
		created.Clear();
		tools.Clear();
		ClearTopLevelControlEvents();
		topLevelControl = null;
		if (!AccessibilityImprovements.UseLegacyToolTipDisplay)
		{
			KeyboardToolTipStateMachine.Instance.ResetStateMachine(this);
		}
	}

	private void SetDelayTime(int type, int time)
	{
		if (type == 0)
		{
			auto = true;
		}
		else
		{
			auto = false;
		}
		delayTimes[type] = time;
		if (GetHandleCreated() && time >= 0)
		{
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1027, type, time);
			if (auto)
			{
				delayTimes[2] = GetDelayTime(2);
				delayTimes[3] = GetDelayTime(3);
				delayTimes[1] = GetDelayTime(1);
			}
		}
		else if (auto)
		{
			AdjustBaseFromAuto();
		}
	}

	/// <summary>Associates ToolTip text with the specified control.</summary>
	/// <param name="control">The <see cref="T:WinForms.Control" /> to associate the ToolTip text with. </param>
	/// <param name="caption">The ToolTip text to display when the pointer is on the control. </param>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void SetToolTip(Control control, string caption)
	{
		TipInfo info = new TipInfo(caption, TipInfo.Type.Auto);
		SetToolTipInternal(control, info);
	}

	private void SetToolTipInternal(Control control, TipInfo info)
	{
		if (control == null)
		{
			throw new ArgumentNullException("control");
		}
		bool flag = false;
		bool flag2 = false;
		if (tools.ContainsKey(control))
		{
			flag = true;
		}
		if (info == null || string.IsNullOrEmpty(info.Caption))
		{
			flag2 = true;
		}
		if (flag && flag2)
		{
			tools.Remove(control);
		}
		else if (!flag2)
		{
			tools[control] = info;
		}
		if (!flag2 && !flag)
		{
			control.HandleCreated += HandleCreated;
			control.HandleDestroyed += HandleDestroyed;
			if (control.IsHandleCreated)
			{
				HandleCreated(control, EventArgs.Empty);
			}
			return;
		}
		bool flag3 = control.IsHandleCreated && TopLevelControl != null && TopLevelControl.IsHandleCreated;
		if (flag && !flag2 && flag3 && !base.DesignMode)
		{
			bool allocatedString;
			NativeMethods.TOOLINFO_TOOLTIP tOOLINFO = GetTOOLINFO(control, info.Caption, out allocatedString);
			try
			{
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_SETTOOLINFO, 0, tOOLINFO);
			}
			finally
			{
				if (allocatedString && IntPtr.Zero != tOOLINFO.lpszText)
				{
					Marshal.FreeHGlobal(tOOLINFO.lpszText);
				}
			}
			CheckNativeToolTip(control);
			CheckCompositeControls(control);
		}
		else if (flag2 && flag && !base.DesignMode)
		{
			control.HandleCreated -= HandleCreated;
			control.HandleDestroyed -= HandleDestroyed;
			if (control.IsHandleCreated)
			{
				HandleDestroyed(control, EventArgs.Empty);
			}
			created.Remove(control);
		}
	}

	private bool ShouldSerializeAutomaticDelay()
	{
		if (auto && AutomaticDelay != 500)
		{
			return true;
		}
		return false;
	}

	private bool ShouldSerializeAutoPopDelay()
	{
		return !auto;
	}

	private bool ShouldSerializeInitialDelay()
	{
		return !auto;
	}

	private bool ShouldSerializeReshowDelay()
	{
		return !auto;
	}

	private void ShowTooltip(string text, IWin32Window win, int duration)
	{
		if (win == null)
		{
			throw new ArgumentNullException("win");
		}
		if (!(win is Control control))
		{
			return;
		}
		NativeMethods.RECT rect = default(NativeMethods.RECT);
		UnsafeNativeMethods.GetWindowRect(new HandleRef(control, control.Handle), ref rect);
		Cursor currentInternal = Cursor.CurrentInternal;
		Point position = Cursor.Position;
		Point point = position;
		Screen screen = Screen.FromPoint(position);
		if (position.X < rect.left || position.X > rect.right || position.Y < rect.top || position.Y > rect.bottom)
		{
			NativeMethods.RECT rECT = default(NativeMethods.RECT);
			rECT.left = ((rect.left < screen.WorkingArea.Left) ? screen.WorkingArea.Left : rect.left);
			rECT.top = ((rect.top < screen.WorkingArea.Top) ? screen.WorkingArea.Top : rect.top);
			rECT.right = ((rect.right > screen.WorkingArea.Right) ? screen.WorkingArea.Right : rect.right);
			rECT.bottom = ((rect.bottom > screen.WorkingArea.Bottom) ? screen.WorkingArea.Bottom : rect.bottom);
			point.X = rECT.left + (rECT.right - rECT.left) / 2;
			point.Y = rECT.top + (rECT.bottom - rECT.top) / 2;
			control.PointToClientInternal(point);
			SetTrackPosition(point.X, point.Y);
			SetTool(win, text, TipInfo.Type.SemiAbsolute, point);
			if (duration > 0)
			{
				StartTimer(window, duration);
			}
			return;
		}
		TipInfo tipInfo = (TipInfo)tools[control];
		if (tipInfo == null)
		{
			tipInfo = new TipInfo(text, TipInfo.Type.SemiAbsolute);
		}
		else
		{
			tipInfo.TipType |= TipInfo.Type.SemiAbsolute;
			tipInfo.Caption = text;
		}
		tipInfo.Position = point;
		if (duration > 0)
		{
			if (originalPopupDelay == 0)
			{
				originalPopupDelay = AutoPopDelay;
			}
			AutoPopDelay = duration;
		}
		SetToolTipInternal(control, tipInfo);
	}

	/// <summary>Sets the ToolTip text associated with the specified control, and displays the ToolTip modally.</summary>
	/// <param name="text">A <see cref="T:System.String" /> containing the new ToolTip text. </param>
	/// <param name="window">The <see cref="T:WinForms.Control" /> to display the ToolTip for.</param>
	/// <exception cref="T:System.ArgumentNullException">The <paramref name="window" /> parameter is null.</exception>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Show(string text, IWin32Window window)
	{
		if (HasAllWindowsPermission && IsWindowActive(window))
		{
			ShowTooltip(text, window, 0);
		}
	}

	/// <summary>Sets the ToolTip text associated with the specified control, and then displays the ToolTip for the specified duration.</summary>
	/// <param name="text">A <see cref="T:System.String" /> containing the new ToolTip text. </param>
	/// <param name="window">The <see cref="T:WinForms.Control" /> to display the ToolTip for.</param>
	/// <param name="duration">An <see cref="T:System.Int32" /> containing the duration, in milliseconds, to display the ToolTip.</param>
	/// <exception cref="T:System.ArgumentNullException">The <paramref name="window" /> parameter is null.</exception>
	/// <exception cref="T:System.ArgumentOutOfRangeException">
	///   <paramref name="duration" /> is less than or equal to 0.</exception>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Show(string text, IWin32Window window, int duration)
	{
		if (duration < 0)
		{
			throw new ArgumentOutOfRangeException("duration", SR.GetString("InvalidLowBoundArgumentEx", "duration", duration.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
		}
		if (HasAllWindowsPermission && IsWindowActive(window))
		{
			ShowTooltip(text, window, duration);
		}
	}

	/// <summary>Sets the ToolTip text associated with the specified control, and then displays the ToolTip modally at the specified relative position.</summary>
	/// <param name="text">A <see cref="T:System.String" /> containing the new ToolTip text. </param>
	/// <param name="window">The <see cref="T:WinForms.Control" /> to display the ToolTip for.</param>
	/// <param name="point">A <see cref="T:System.WinDraw.Point" /> containing the offset, in pixels, relative to the upper-left corner of the associated control window, to display the ToolTip.</param>
	/// <exception cref="T:System.ArgumentNullException">The <paramref name="window" /> parameter is null.</exception>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Show(string text, IWin32Window window, Point point)
	{
		if (window == null)
		{
			throw new ArgumentNullException("window");
		}
		if (HasAllWindowsPermission && IsWindowActive(window))
		{
			NativeMethods.RECT rect = default(NativeMethods.RECT);
			UnsafeNativeMethods.GetWindowRect(new HandleRef(window, Control.GetSafeHandle(window)), ref rect);
			int num = rect.left + point.X;
			int num2 = rect.top + point.Y;
			SetTrackPosition(num, num2);
			SetTool(window, text, TipInfo.Type.Absolute, new Point(num, num2));
		}
	}

	/// <summary>Sets the ToolTip text associated with the specified control, and then displays the ToolTip for the specified duration at the specified relative position.</summary>
	/// <param name="text">A <see cref="T:System.String" /> containing the new ToolTip text. </param>
	/// <param name="window">The <see cref="T:WinForms.Control" /> to display the ToolTip for.</param>
	/// <param name="point">A <see cref="T:System.WinDraw.Point" /> containing the offset, in pixels, relative to the upper-left corner of the associated control window, to display the ToolTip.</param>
	/// <param name="duration">An <see cref="T:System.Int32" /> containing the duration, in milliseconds, to display the ToolTip.</param>
	/// <exception cref="T:System.ArgumentNullException">The <paramref name="window" /> parameter is null.</exception>
	/// <exception cref="T:System.ArgumentOutOfRangeException">
	///   <paramref name="duration" /> is less than or equal to 0.</exception>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Show(string text, IWin32Window window, Point point, int duration)
	{
		if (window == null)
		{
			throw new ArgumentNullException("window");
		}
		if (duration < 0)
		{
			throw new ArgumentOutOfRangeException("duration", SR.GetString("InvalidLowBoundArgumentEx", "duration", duration.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
		}
		if (HasAllWindowsPermission && IsWindowActive(window))
		{
			NativeMethods.RECT rect = default(NativeMethods.RECT);
			UnsafeNativeMethods.GetWindowRect(new HandleRef(window, Control.GetSafeHandle(window)), ref rect);
			int num = rect.left + point.X;
			int num2 = rect.top + point.Y;
			SetTrackPosition(num, num2);
			SetTool(window, text, TipInfo.Type.Absolute, new Point(num, num2));
			StartTimer(window, duration);
		}
	}

	/// <summary>Sets the ToolTip text associated with the specified control, and then displays the ToolTip modally at the specified relative position.</summary>
	/// <param name="text">A <see cref="T:System.String" /> containing the new ToolTip text. </param>
	/// <param name="window">The <see cref="T:WinForms.Control" /> to display the ToolTip for.</param>
	/// <param name="x">The horizontal offset, in pixels, relative to the upper-left corner of the associated control window, to display the ToolTip.</param>
	/// <param name="y">The vertical offset, in pixels, relative to the upper-left corner of the associated control window, to display the ToolTip.</param>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Show(string text, IWin32Window window, int x, int y)
	{
		if (window == null)
		{
			throw new ArgumentNullException("window");
		}
		if (HasAllWindowsPermission && IsWindowActive(window))
		{
			NativeMethods.RECT rect = default(NativeMethods.RECT);
			UnsafeNativeMethods.GetWindowRect(new HandleRef(window, Control.GetSafeHandle(window)), ref rect);
			int num = rect.left + x;
			int num2 = rect.top + y;
			SetTrackPosition(num, num2);
			SetTool(window, text, TipInfo.Type.Absolute, new Point(num, num2));
		}
	}

	/// <summary>Sets the ToolTip text associated with the specified control, and then displays the ToolTip for the specified duration at the specified relative position.</summary>
	/// <param name="text">A <see cref="T:System.String" /> containing the new ToolTip text. </param>
	/// <param name="window">The <see cref="T:WinForms.Control" /> to display the ToolTip for.</param>
	/// <param name="x">The horizontal offset, in pixels, relative to the upper-left corner of the associated control window, to display the ToolTip.</param>
	/// <param name="y">The vertical offset, in pixels, relative to the upper-left corner of the associated control window, to display the ToolTip.</param>
	/// <param name="duration">An <see cref="T:System.Int32" /> containing the duration, in milliseconds, to display the ToolTip.</param>
	/// <exception cref="T:System.ArgumentNullException">The <paramref name="window" /> parameter is null.</exception>
	/// <exception cref="T:System.ArgumentOutOfRangeException">
	///   <paramref name="duration" /> is less than or equal to 0.</exception>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Show(string text, IWin32Window window, int x, int y, int duration)
	{
		if (window == null)
		{
			throw new ArgumentNullException("window");
		}
		if (duration < 0)
		{
			throw new ArgumentOutOfRangeException("duration", SR.GetString("InvalidLowBoundArgumentEx", "duration", duration.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
		}
		if (HasAllWindowsPermission && IsWindowActive(window))
		{
			NativeMethods.RECT rect = default(NativeMethods.RECT);
			UnsafeNativeMethods.GetWindowRect(new HandleRef(window, Control.GetSafeHandle(window)), ref rect);
			int num = rect.left + x;
			int num2 = rect.top + y;
			SetTrackPosition(num, num2);
			SetTool(window, text, TipInfo.Type.Absolute, new Point(num, num2));
			StartTimer(window, duration);
		}
	}

	internal void ShowKeyboardToolTip(string text, IKeyboardToolTip tool, int duration)
	{
		if (tool == null)
		{
			throw new ArgumentNullException("tool");
		}
		if (duration < 0)
		{
			throw new ArgumentOutOfRangeException("duration", SR.GetString("InvalidLowBoundArgumentEx", "duration", duration.ToString(CultureInfo.CurrentCulture), 0.ToString(CultureInfo.CurrentCulture)));
		}
		Rectangle nativeScreenRectangle = tool.GetNativeScreenRectangle();
		int num = (nativeScreenRectangle.Left + nativeScreenRectangle.Right) / 2;
		int num2 = (nativeScreenRectangle.Top + nativeScreenRectangle.Bottom) / 2;
		SetTool(tool.GetOwnerWindow(), text, TipInfo.Type.Absolute, new Point(num, num2));
		if (TryGetBubbleSize(tool, nativeScreenRectangle, out var bubbleSize))
		{
			Point optimalToolTipPosition = GetOptimalToolTipPosition(tool, nativeScreenRectangle, bubbleSize.Width, bubbleSize.Height);
			num = optimalToolTipPosition.X;
			num2 = optimalToolTipPosition.Y;
			TipInfo tipInfo = (TipInfo)(tools[tool] ?? tools[tool.GetOwnerWindow()]);
			tipInfo.Position = new Point(num, num2);
			Reposition(optimalToolTipPosition, bubbleSize);
		}
		SetTrackPosition(num, num2);
		StartTimer(tool.GetOwnerWindow(), duration);
	}

	private bool TryGetBubbleSize(IKeyboardToolTip tool, Rectangle toolRectangle, out Size bubbleSize)
	{
		IntPtr n = UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1054, 0, GetMinToolInfoForTool(tool.GetOwnerWindow()));
		if (n.ToInt32() != 1)
		{
			int width = NativeMethods.Util.LOWORD(n);
			int height = NativeMethods.Util.HIWORD(n);
			bubbleSize = new Size(width, height);
			return true;
		}
		bubbleSize = Size.Empty;
		return false;
	}

	private Point GetOptimalToolTipPosition(IKeyboardToolTip tool, Rectangle toolRectangle, int width, int height)
	{
		int x = toolRectangle.Left + toolRectangle.Width / 2 - width / 2;
		int y = toolRectangle.Top + toolRectangle.Height / 2 - height / 2;
		Rectangle[] array = new Rectangle[4]
		{
			new Rectangle(x, toolRectangle.Top - height, width, height),
			new Rectangle(toolRectangle.Right, y, width, height),
			new Rectangle(x, toolRectangle.Bottom, width, height),
			new Rectangle(toolRectangle.Left - width, y, width, height)
		};
		IList<Rectangle> neighboringToolsRectangles = tool.GetNeighboringToolsRectangles();
		long[] array2 = new long[4];
		for (int i = 0; i < array.Length; i++)
		{
			checked
			{
				foreach (Rectangle item in neighboringToolsRectangles)
				{
					Rectangle rectangle = Rectangle.Intersect(array[i], item);
					array2[i] += Math.Abs(unchecked((long)rectangle.Width) * unchecked((long)rectangle.Height));
				}
			}
		}
		Rectangle virtualScreen = SystemInformation.VirtualScreen;
		long[] array3 = new long[4];
		for (int j = 0; j < array.Length; j++)
		{
			Rectangle rectangle2 = Rectangle.Intersect(virtualScreen, array[j]);
			checked
			{
				array3[j] = (Math.Abs(unchecked((long)array[j].Width)) - Math.Abs(unchecked((long)rectangle2.Width))) * (Math.Abs(unchecked((long)array[j].Height)) - Math.Abs(unchecked((long)rectangle2.Height)));
			}
		}
		long[] array4 = new long[4];
		Rectangle a = ((IKeyboardToolTip)TopLevelControl)?.GetNativeScreenRectangle() ?? Rectangle.Empty;
		if (!a.IsEmpty)
		{
			for (int k = 0; k < array.Length; k++)
			{
				Rectangle rectangle3 = Rectangle.Intersect(a, array[k]);
				checked
				{
					array4[k] = Math.Abs(unchecked((long)rectangle3.Height) * unchecked((long)rectangle3.Width));
				}
			}
		}
		long originalLocationWeight = array2[0];
		long originalLocationClippedArea = array3[0];
		long originalLocationAreaWithinTopControl = array4[0];
		int originalIndex = 0;
		Rectangle rectangle4 = array[0];
		bool rtlEnabled = tool.HasRtlModeEnabled();
		for (int l = 1; l < array.Length; l++)
		{
			if (IsCompetingLocationBetter(originalLocationClippedArea, originalLocationWeight, originalLocationAreaWithinTopControl, originalIndex, array3[l], array2[l], array4[l], l, rtlEnabled))
			{
				originalLocationWeight = array2[l];
				originalLocationClippedArea = array3[l];
				originalLocationAreaWithinTopControl = array4[l];
				originalIndex = l;
				rectangle4 = array[l];
			}
		}
		return new Point(rectangle4.Left, rectangle4.Top);
	}

	private bool IsCompetingLocationBetter(long originalLocationClippedArea, long originalLocationWeight, long originalLocationAreaWithinTopControl, int originalIndex, long competingLocationClippedArea, long competingLocationWeight, long competingLocationAreaWithinTopControl, int competingIndex, bool rtlEnabled)
	{
		if (competingLocationClippedArea < originalLocationClippedArea)
		{
			return true;
		}
		if (competingLocationWeight < originalLocationWeight)
		{
			return true;
		}
		if (competingLocationWeight == originalLocationWeight && competingLocationClippedArea == originalLocationClippedArea)
		{
			if (competingLocationAreaWithinTopControl > originalLocationAreaWithinTopControl)
			{
				return true;
			}
			if (competingLocationAreaWithinTopControl == originalLocationAreaWithinTopControl)
			{
				switch (originalIndex)
				{
				case 0:
					return true;
				case 2:
					if (competingIndex == 3 || competingIndex == 1)
					{
						return true;
					}
					break;
				case 1:
					if (rtlEnabled && competingIndex == 3)
					{
						return true;
					}
					break;
				case 3:
					if (!rtlEnabled && competingIndex == 1)
					{
						return true;
					}
					break;
				default:
					throw new NotSupportedException("Unsupported location index value");
				}
			}
		}
		return false;
	}

	private void SetTrackPosition(int pointX, int pointY)
	{
		try
		{
			trackPosition = true;
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1042, 0, NativeMethods.Util.MAKELONG(pointX, pointY));
		}
		finally
		{
			trackPosition = false;
		}
	}

	/// <summary>Hides the specified ToolTip window.</summary>
	/// <param name="win">The <see cref="T:WinForms.IWin32Window" /> of the associated window or control that the ToolTip is associated with.</param>
	/// <exception cref="T:System.ArgumentNullException">
	///   <paramref name="win" /> is null.</exception>
	/// <filterpriority>1</filterpriority>
	/// <PermissionSet>
	///   <IPermission class="System.Security.Permissions.EnvironmentPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.FileIOPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	///   <IPermission class="System.Security.Permissions.SecurityPermission, mscorlib, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Flags="UnmanagedCode, ControlEvidence" />
	///   <IPermission class="System.Diagnostics.PerformanceCounterPermission, System, Version=2.0.3600.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" version="1" Unrestricted="true" />
	/// </PermissionSet>
	public void Hide(IWin32Window win)
	{
		if (win == null)
		{
			throw new ArgumentNullException("win");
		}
		if (!HasAllWindowsPermission || window == null)
		{
			return;
		}
		if (GetHandleCreated())
		{
			IntPtr safeHandle = Control.GetSafeHandle(win);
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1041, 0, GetWinTOOLINFO(safeHandle));
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_DELTOOL, 0, GetWinTOOLINFO(safeHandle));
		}
		StopTimer();
		if (!(win is Control control))
		{
			owners.Remove(win.Handle);
		}
		else
		{
			if (tools.ContainsKey(control))
			{
				SetToolInfo(control, GetToolTip(control));
			}
			else
			{
				owners.Remove(win.Handle);
			}
			Form form = control.FindFormInternal();
			if (form != null)
			{
				form.Deactivate -= BaseFormDeactivate;
			}
		}
		ClearTopLevelControlEvents();
		topLevelControl = null;
	}

	private void BaseFormDeactivate(object sender, EventArgs e)
	{
		HideAllToolTips();
		if (!AccessibilityImprovements.UseLegacyToolTipDisplay)
		{
			KeyboardToolTipStateMachine.Instance.NotifyAboutFormDeactivation(this);
		}
	}

	private void HideAllToolTips()
	{
		Control[] array = new Control[owners.Values.Count];
		owners.Values.CopyTo(array, 0);
		for (int i = 0; i < array.Length; i++)
		{
			Hide(array[i]);
		}
	}

	private void SetTool(IWin32Window win, string text, TipInfo.Type type, Point position)
	{
		Control control = win as Control;
		if (control != null && tools.ContainsKey(control))
		{
			bool flag = false;
			NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
			try
			{
				tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
				tOOLINFO_TOOLTIP.hwnd = control.Handle;
				tOOLINFO_TOOLTIP.uId = control.Handle;
				if ((int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETTOOLINFO, 0, tOOLINFO_TOOLTIP) != 0)
				{
					tOOLINFO_TOOLTIP.uFlags |= 32;
					if (type == TipInfo.Type.Absolute || type == TipInfo.Type.SemiAbsolute)
					{
						tOOLINFO_TOOLTIP.uFlags |= 128;
					}
					tOOLINFO_TOOLTIP.lpszText = Marshal.StringToHGlobalAuto(text);
					flag = true;
				}
				TipInfo tipInfo = (TipInfo)tools[control];
				if (tipInfo == null)
				{
					tipInfo = new TipInfo(text, type);
				}
				else
				{
					tipInfo.TipType |= type;
					tipInfo.Caption = text;
				}
				tipInfo.Position = position;
				tools[control] = tipInfo;
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_SETTOOLINFO, 0, tOOLINFO_TOOLTIP);
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1041, 1, tOOLINFO_TOOLTIP);
			}
			finally
			{
				if (flag && IntPtr.Zero != tOOLINFO_TOOLTIP.lpszText)
				{
					Marshal.FreeHGlobal(tOOLINFO_TOOLTIP.lpszText);
				}
			}
		}
		else
		{
			Hide(win);
			TipInfo tipInfo2 = (TipInfo)tools[control];
			if (tipInfo2 == null)
			{
				tipInfo2 = new TipInfo(text, type);
			}
			else
			{
				tipInfo2.TipType |= type;
				tipInfo2.Caption = text;
			}
			tipInfo2.Position = position;
			tools[control] = tipInfo2;
			IntPtr safeHandle = Control.GetSafeHandle(win);
			owners[safeHandle] = win;
			NativeMethods.TOOLINFO_TOOLTIP winTOOLINFO = GetWinTOOLINFO(safeHandle);
			winTOOLINFO.uFlags |= 32;
			if (type == TipInfo.Type.Absolute || type == TipInfo.Type.SemiAbsolute)
			{
				winTOOLINFO.uFlags |= 128;
			}
			try
			{
				winTOOLINFO.lpszText = Marshal.StringToHGlobalAuto(text);
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_ADDTOOL, 0, winTOOLINFO);
				UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1041, 1, winTOOLINFO);
			}
			finally
			{
				if (IntPtr.Zero != winTOOLINFO.lpszText)
				{
					Marshal.FreeHGlobal(winTOOLINFO.lpszText);
				}
			}
		}
		if (control != null)
		{
			Form form = control.FindFormInternal();
			if (form != null)
			{
				form.Deactivate += BaseFormDeactivate;
			}
		}
	}

	private void StartTimer(IWin32Window owner, int interval)
	{
		if (timer == null)
		{
			timer = new ToolTipTimer(owner);
			timer.Tick += TimerHandler;
		}
		timer.Interval = interval;
		timer.Start();
	}

	/// <summary>Stops the timer that hides displayed ToolTips.</summary>
	protected void StopTimer()
	{
		ToolTipTimer toolTipTimer = timer;
		if (toolTipTimer != null)
		{
			toolTipTimer.Stop();
			toolTipTimer.Dispose();
			timer = null;
		}
	}

	private void TimerHandler(object source, EventArgs args)
	{
		Hide(((ToolTipTimer)source).Host);
	}

	/// <summary>Releases the unmanaged resources and performs other cleanup operations before the <see cref="T:WinForms.Cursor" /> is reclaimed by the garbage collector.</summary>
	~ToolTip()
	{
		DestroyHandle();
	}

	/// <summary>Returns a string representation for this control.</summary>
	/// <returns>A <see cref="T:System.String" /> containing a description of the <see cref="T:WinForms.ToolTip" />.</returns>
	/// <filterpriority>2</filterpriority>
	public override string ToString()
	{
		string text = base.ToString();
		return text + " InitialDelay: " + InitialDelay.ToString(CultureInfo.CurrentCulture) + ", ShowAlways: " + ShowAlways.ToString(CultureInfo.CurrentCulture);
	}

	private void Reposition(Point tipPosition, Size tipSize)
	{
		Point point = tipPosition;
		Screen screen = Screen.FromPoint(point);
		if (point.X + tipSize.Width > screen.WorkingArea.Right)
		{
			point.X = screen.WorkingArea.Right - tipSize.Width;
		}
		if (point.Y + tipSize.Height > screen.WorkingArea.Bottom)
		{
			point.Y = screen.WorkingArea.Bottom - tipSize.Height;
		}
		SafeNativeMethods.SetWindowPos(new HandleRef(this, Handle), NativeMethods.HWND_TOPMOST, point.X, point.Y, tipSize.Width, tipSize.Height, 529);
	}

	private void WmMove()
	{
		NativeMethods.RECT rect = default(NativeMethods.RECT);
		UnsafeNativeMethods.GetWindowRect(new HandleRef(this, Handle), ref rect);
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		if ((int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETCURRENTTOOL, 0, tOOLINFO_TOOLTIP) == 0)
		{
			return;
		}
		IWin32Window win32Window = (IWin32Window)owners[tOOLINFO_TOOLTIP.hwnd];
		if (win32Window == null)
		{
			win32Window = Control.FromHandleInternal(tOOLINFO_TOOLTIP.hwnd);
		}
		if (win32Window != null)
		{
			TipInfo tipInfo = (TipInfo)tools[win32Window];
			if (win32Window != null && tipInfo != null && (!(win32Window is TreeView treeView) || !treeView.ShowNodeToolTips) && tipInfo.Position != Point.Empty)
			{
				Reposition(tipInfo.Position, rect.Size);
			}
		}
	}

	private void WmMouseActivate(ref Message msg)
	{
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		if ((int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETCURRENTTOOL, 0, tOOLINFO_TOOLTIP) == 0)
		{
			return;
		}
		IWin32Window win32Window = (IWin32Window)owners[tOOLINFO_TOOLTIP.hwnd];
		if (win32Window == null)
		{
			win32Window = Control.FromHandleInternal(tOOLINFO_TOOLTIP.hwnd);
		}
		if (win32Window != null)
		{
			NativeMethods.RECT rect = default(NativeMethods.RECT);
			UnsafeNativeMethods.GetWindowRect(new HandleRef(win32Window, Control.GetSafeHandle(win32Window)), ref rect);
			Point position = Cursor.Position;
			if (position.X >= rect.left && position.X <= rect.right && position.Y >= rect.top && position.Y <= rect.bottom)
			{
				msg.Result = (IntPtr)3;
			}
		}
	}

	private void WmWindowFromPoint(ref Message msg)
	{
		NativeMethods.POINT pOINT = (NativeMethods.POINT)msg.GetLParam(typeof(NativeMethods.POINT));
		Point screenCoords = new Point(pOINT.x, pOINT.y);
		bool success = false;
		msg.Result = GetWindowFromPoint(screenCoords, ref success);
	}

	private void WmShow()
	{
		NativeMethods.RECT rect = default(NativeMethods.RECT);
		UnsafeNativeMethods.GetWindowRect(new HandleRef(this, Handle), ref rect);
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		if ((int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETCURRENTTOOL, 0, tOOLINFO_TOOLTIP) == 0)
		{
			return;
		}
		IWin32Window win32Window = (IWin32Window)owners[tOOLINFO_TOOLTIP.hwnd];
		if (win32Window == null)
		{
			win32Window = Control.FromHandleInternal(tOOLINFO_TOOLTIP.hwnd);
		}
		if (win32Window == null)
		{
			return;
		}
		Control control = win32Window as Control;
		Size size = rect.Size;
		PopupEventArgs popupEventArgs = new PopupEventArgs(win32Window, control, IsBalloon, size);
		OnPopup(popupEventArgs);
		if (control is DataGridView dataGridView && dataGridView.CancelToolTipPopup(this))
		{
			popupEventArgs.Cancel = true;
		}
		UnsafeNativeMethods.GetWindowRect(new HandleRef(this, Handle), ref rect);
		size = ((popupEventArgs.ToolTipSize == size) ? rect.Size : popupEventArgs.ToolTipSize);
		if (IsBalloon)
		{
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1055, 1, ref rect);
			if (rect.Size.Height > size.Height)
			{
				size.Height = rect.Size.Height;
			}
		}
		if (size != rect.Size)
		{
			Screen screen = Screen.FromPoint(Cursor.Position);
			int lParam = (IsBalloon ? Math.Min(size.Width - 20, screen.WorkingArea.Width) : Math.Min(size.Width, screen.WorkingArea.Width));
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1048, 0, lParam);
		}
		if (popupEventArgs.Cancel)
		{
			cancelled = true;
			SafeNativeMethods.SetWindowPos(new HandleRef(this, Handle), NativeMethods.HWND_TOPMOST, 0, 0, 0, 0, 528);
		}
		else
		{
			cancelled = false;
			SafeNativeMethods.SetWindowPos(new HandleRef(this, Handle), NativeMethods.HWND_TOPMOST, rect.left, rect.top, size.Width, size.Height, 528);
		}
	}

	private bool WmWindowPosChanged()
	{
		if (cancelled)
		{
			SafeNativeMethods.ShowWindow(new HandleRef(this, Handle), 0);
			return true;
		}
		return false;
	}

	private unsafe void WmWindowPosChanging(ref Message m)
	{
		if (cancelled || isDisposing)
		{
			return;
		}
		NativeMethods.WINDOWPOS* ptr = (NativeMethods.WINDOWPOS*)(void*)m.LParam;
		Cursor currentInternal = Cursor.CurrentInternal;
		Point position = Cursor.Position;
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		if ((int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETCURRENTTOOL, 0, tOOLINFO_TOOLTIP) != 0)
		{
			IWin32Window win32Window = (IWin32Window)owners[tOOLINFO_TOOLTIP.hwnd];
			if (win32Window == null)
			{
				win32Window = Control.FromHandleInternal(tOOLINFO_TOOLTIP.hwnd);
			}
			if (win32Window == null || !IsWindowActive(win32Window))
			{
				return;
			}
			TipInfo tipInfo = null;
			if (win32Window != null)
			{
				tipInfo = (TipInfo)tools[win32Window];
				if (tipInfo == null || (win32Window is TreeView treeView && treeView.ShowNodeToolTips))
				{
					return;
				}
			}
			if (IsBalloon)
			{
				ptr->cx += 20;
				return;
			}
			if ((tipInfo.TipType & TipInfo.Type.Auto) != 0 && window != null)
			{
				window.DefWndProc(ref m);
				return;
			}
			if ((tipInfo.TipType & TipInfo.Type.SemiAbsolute) != 0 && tipInfo.Position == Point.Empty)
			{
				Screen screen = Screen.FromPoint(position);
				if (currentInternal != null)
				{
					ptr->x = position.X;
					try
					{
						IntSecurity.ObjectFromWin32Handle.Assert();
						ptr->y = position.Y;
						if (ptr->y + ptr->cy + currentInternal.Size.Height - currentInternal.HotSpot.Y > screen.WorkingArea.Bottom)
						{
							ptr->y = position.Y - ptr->cy;
						}
						else
						{
							ptr->y = position.Y + currentInternal.Size.Height - currentInternal.HotSpot.Y;
						}
					}
					finally
					{
						CodeAccessPermission.RevertAssert();
					}
				}
				if (ptr->x + ptr->cx > screen.WorkingArea.Right)
				{
					ptr->x = screen.WorkingArea.Right - ptr->cx;
				}
			}
			else if ((tipInfo.TipType & TipInfo.Type.SemiAbsolute) != 0 && tipInfo.Position != Point.Empty)
			{
				Screen screen2 = Screen.FromPoint(tipInfo.Position);
				ptr->x = tipInfo.Position.X;
				if (ptr->x + ptr->cx > screen2.WorkingArea.Right)
				{
					ptr->x = screen2.WorkingArea.Right - ptr->cx;
				}
				ptr->y = tipInfo.Position.Y;
				if (ptr->y + ptr->cy > screen2.WorkingArea.Bottom)
				{
					ptr->y = screen2.WorkingArea.Bottom - ptr->cy;
				}
			}
		}
		m.Result = IntPtr.Zero;
	}

	private void WmPop()
	{
		NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
		tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
		if ((int)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETCURRENTTOOL, 0, tOOLINFO_TOOLTIP) == 0)
		{
			return;
		}
		IWin32Window win32Window = (IWin32Window)owners[tOOLINFO_TOOLTIP.hwnd];
		if (win32Window == null)
		{
			win32Window = Control.FromHandleInternal(tOOLINFO_TOOLTIP.hwnd);
		}
		if (win32Window == null)
		{
			return;
		}
		Control control = win32Window as Control;
		TipInfo tipInfo = (TipInfo)tools[win32Window];
		if (tipInfo == null)
		{
			return;
		}
		if ((tipInfo.TipType & TipInfo.Type.Auto) != 0 || (tipInfo.TipType & TipInfo.Type.SemiAbsolute) != 0)
		{
			Screen screen = Screen.FromPoint(Cursor.Position);
			UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 1048, 0, screen.WorkingArea.Width);
		}
		if ((tipInfo.TipType & TipInfo.Type.Auto) == 0)
		{
			tools.Remove(control);
			owners.Remove(win32Window.Handle);
			control.HandleCreated -= HandleCreated;
			control.HandleDestroyed -= HandleDestroyed;
			created.Remove(control);
			if (originalPopupDelay != 0)
			{
				AutoPopDelay = originalPopupDelay;
				originalPopupDelay = 0;
			}
		}
		else
		{
			tipInfo.TipType = TipInfo.Type.Auto;
			tipInfo.Position = Point.Empty;
			tools[control] = tipInfo;
		}
	}

	private void WndProc(ref Message msg)
	{
		switch (msg.Msg)
		{
		case 8270:
		{
			NativeMethods.NMHDR nMHDR = (NativeMethods.NMHDR)msg.GetLParam(typeof(NativeMethods.NMHDR));
			if (nMHDR.code == -521 && !trackPosition)
			{
				WmShow();
			}
			else if (nMHDR.code == -522)
			{
				WmPop();
				if (window != null)
				{
					window.DefWndProc(ref msg);
				}
			}
			return;
		}
		case 70:
			WmWindowPosChanging(ref msg);
			return;
		case 71:
			if (!WmWindowPosChanged() && window != null)
			{
				window.DefWndProc(ref msg);
			}
			return;
		case 33:
			WmMouseActivate(ref msg);
			return;
		case 3:
			WmMove();
			return;
		case 1040:
			WmWindowFromPoint(ref msg);
			return;
		case 15:
		case 792:
		{
			if (!ownerDraw || isBalloon || trackPosition)
			{
				break;
			}
			NativeMethods.PAINTSTRUCT lpPaint = default(NativeMethods.PAINTSTRUCT);
			IntPtr hdc = UnsafeNativeMethods.BeginPaint(new HandleRef(this, Handle), ref lpPaint);
			Graphics graphics = Graphics.FromHdcInternal(hdc);
			try
			{
				Rectangle rectangle = new Rectangle(lpPaint.rcPaint_left, lpPaint.rcPaint_top, lpPaint.rcPaint_right - lpPaint.rcPaint_left, lpPaint.rcPaint_bottom - lpPaint.rcPaint_top);
				if (rectangle == Rectangle.Empty)
				{
					return;
				}
				NativeMethods.TOOLINFO_TOOLTIP tOOLINFO_TOOLTIP = new NativeMethods.TOOLINFO_TOOLTIP();
				tOOLINFO_TOOLTIP.cbSize = Marshal.SizeOf(typeof(NativeMethods.TOOLINFO_TOOLTIP));
				if ((int)(long)UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), NativeMethods.TTM_GETCURRENTTOOL, 0, tOOLINFO_TOOLTIP) == 0)
				{
					break;
				}
				IWin32Window win32Window = (IWin32Window)owners[tOOLINFO_TOOLTIP.hwnd];
				Control control = Control.FromHandleInternal(tOOLINFO_TOOLTIP.hwnd);
				if (win32Window == null)
				{
					win32Window = control;
				}
				IntSecurity.ObjectFromWin32Handle.Assert();
				Font font;
				try
				{
					font = Font.FromHfont(UnsafeNativeMethods.SendMessage(new HandleRef(this, Handle), 49, 0, 0));
				}
				catch (ArgumentException)
				{
					font = Control.DefaultFont;
				}
				finally
				{
					CodeAccessPermission.RevertAssert();
				}
				OnDraw(new DrawToolTipEventArgs(graphics, win32Window, control, rectangle, GetToolTip(control), BackColor, ForeColor, font));
				return;
			}
			finally
			{
				graphics.Dispose();
				UnsafeNativeMethods.EndPaint(new HandleRef(this, Handle), ref lpPaint);
			}
		}
		}
		if (window != null)
		{
			window.DefWndProc(ref msg);
		}
	}
}
