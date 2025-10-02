unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldCurrentSessionWrapper = class(TObject)
  private
    m_appInitFallbackValues: TLazy<TAppInitFallbackValues>;
  public
    property FormatSettings: TFormatSettings read GetFormatSettings write SetFormatSettings;
    property RegionalSettings: TClientSettings read GetRegionalSettings write SetRegionalSettings;
    property WindowsCulture: TCultureInfo read GetWindowsCulture write SetWindowsCulture;
    property ClientTimeZone: TimeZoneInfo read GetClientTimeZone write SetClientTimeZone;
  end;


implementation


end.
