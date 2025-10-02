unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldSession = class(TTreeObject)
  private
    m_invariantFormatSettings: TFormatSettings;
    m_formatSettingsDictionary: TDictionary<Integer, TFormatSettings>;
    m_selfReference: IReference<TGoldSession>;
    m_workDate: TGoldDate;
    m_globalLanguageStack: TStack<int>;
    m_currentCulture: TCultureInfo;
    m_windowsCulture: TCultureInfo;
    m_cultureSettings: TClientSettings;
  public
    constructor Create(AParent: ITreeObject);
    function GetFormattingCulture(AClientFormats: TClientSettings): TCultureInfo;
    function GetReference(): IReference<TGoldSession>;
    property Session: TGoldSession read GetSession write SetSession;
    property InvariantFormatSettings: TFormatSettings read GetInvariantFormatSettings write SetInvariantFormatSettings;
    property WorkDate: TGoldDate read GetWorkDate write SetWorkDate;
    property RegionalSettings: TClientSettings read GetRegionalSettings write SetRegionalSettings;
    property GlobalLanguage: Integer read GetGlobalLanguage write SetGlobalLanguage;
    property LocalLanguage: Integer read GetLocalLanguage write SetLocalLanguage;
    property IsLocalLanguage: Boolean read GetIsLocalLanguage write SetIsLocalLanguage;
    property Culture: TCultureInfo read GetCulture write SetCulture;
    property WindowsCulture: TCultureInfo read GetWindowsCulture write SetWindowsCulture;
    property FormatSettings: TFormatSettings read GetFormatSettings write SetFormatSettings;
    property ClientTimeZone: TimeZoneInfo read GetClientTimeZone write SetClientTimeZone;
  end;


implementation

constructor TGoldSession.Create(AParent: ITreeObject);
begin
  inherited Create;
  m_selfReference := new TReference<TGoldSession>(this);
  ClientTimeZone := TimeZoneInfo.Local;
end;

function TGoldSession.GetFormattingCulture(AClientFormats: TClientSettings): TCultureInfo;
begin
  Result := TCultureInfo.Create(AClientFormats.WindowsLCID)
            {
                DateTimeFormat =
                {
                    ShortDatePattern = AClientFormats.ShortDatePattern,
                    ShortTimePattern = AClientFormats.ShortTimeFormat,
                    AMDesignator = AClientFormats.TimeAMDesignator,
                    PMDesignator = AClientFormats.TimePMDesignator,
                    TimeSeparator = AClientFormats.TimeSeparator,
                    DateSeparator = AClientFormats.DateSeparator
                },
                NumberFormat =
                {
                    NumberDecimalSeparator = AClientFormats.DecimalSeparator,
                    NumberGroupSeparator = AClientFormats.GroupSeparator,
                    CurrencyDecimalSeparator = AClientFormats.CurrencyDecimalSeparator,
                    CurrencyGroupSeparator = AClientFormats.CurrencyGroupSeparator
                }
            };
end;

function TGoldSession.GetReference(): IReference<TGoldSession>;
begin
  Result := m_selfReference;
end;


end.
