unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldEnvironment = class(TObject)
  private
    m_lockObject: TObject;
    m_instance: TGoldEnvironment;
    m_standaloneInstance: Boolean;
  public
    const m_CompressionThresholdDefault: Integer = 64 * 1024;
    constructor Create(AFlags: TGoldEnvironmentFlags);
    property DefaultLanguage: Integer read GetDefaultLanguage write SetDefaultLanguage;
    property EnableCompactSerialization: Boolean read GetEnableCompactSerialization write SetEnableCompactSerialization;
    property Instance: TGoldEnvironment read GetInstance write SetInstance;
  end;


implementation

constructor TGoldEnvironment.Create(AFlags: TGoldEnvironmentFlags);
begin
  ConfigurationManager.AppSettings.Set("wcf:disableOperationContextAsyncFlow", false.ToString(CultureInfo.InvariantCulture));
  m_standaloneInstance := AFlags.HasFlag(TGoldEnvironmentFlags.Standalone);
end;


end.
