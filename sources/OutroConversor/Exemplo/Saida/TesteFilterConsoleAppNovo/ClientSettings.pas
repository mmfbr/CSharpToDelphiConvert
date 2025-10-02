unit GoldERP.Types;

interface

    property ShortTimeFormat: String read GetShortTimeFormat write SetShortTimeFormat;
    property LongTimePattern: String read GetLongTimePattern write SetLongTimePattern;
    property ShortTimeZero: String read GetShortTimeZero write SetShortTimeZero;
    property ShortDatePattern: String read GetShortDatePattern write SetShortDatePattern;
    property TimeAMDesignator: String read GetTimeAMDesignator write SetTimeAMDesignator;
    property TimePMDesignator: String read GetTimePMDesignator write SetTimePMDesignator;
    property TimeSeparator: String read GetTimeSeparator write SetTimeSeparator;
    property DateSeparator: String read GetDateSeparator write SetDateSeparator;
    property DecimalSeparator: String read GetDecimalSeparator write SetDecimalSeparator;
    property GroupSeparator: String read GetGroupSeparator write SetGroupSeparator;
    property CurrencyDecimalSeparator: String read GetCurrencyDecimalSeparator write SetCurrencyDecimalSeparator;
    property CurrencyGroupSeparator: String read GetCurrencyGroupSeparator write SetCurrencyGroupSeparator;
    property LCID: Integer read GetLCID write SetLCID;
    property WindowsLCID: Integer read GetWindowsLCID write SetWindowsLCID;
    procedure Refresh(AFormatCulture: TCultureInfo; AUserCulture: TCultureInfo);
    function Equals(AObj: TObject): Boolean;
    function Equals(AOther: TClientSettings): Boolean;
    function GetHashCode(): Integer;

implementation

procedure .Refresh(AFormatCulture: TCultureInfo; AUserCulture: TCultureInfo);
begin
  if AFormatCulture = null then
  begin
    raise TArgumentNullException.Create("AFormatCulture");
  end
  ;
  if AUserCulture = null then
  begin
    raise TArgumentNullException.Create("AUserCulture");
  end
  ;
  datetimeFormatInfo: TDateTimeFormatInfo := AFormatCulture.DateTimeFormat;
  numFormatInfo: TNumberFormatInfo := AFormatCulture.NumberFormat;
  ShortTimeFormat := datetimeFormatInfo.ShortTimePattern;
  ShortTimeZero := datetimeFormatInfo.ShortTimePattern;
  LongTimePattern := datetimeFormatInfo.LongTimePattern;
  ShortDatePattern := datetimeFormatInfo.ShortDatePattern;
  TimeAMDesignator := datetimeFormatInfo.AMDesignator;
  TimePMDesignator := datetimeFormatInfo.PMDesignator;
  TimeSeparator := datetimeFormatInfo.TimeSeparator;
  DateSeparator := datetimeFormatInfo.DateSeparator;
  DecimalSeparator := numFormatInfo.NumberDecimalSeparator;
  GroupSeparator := numFormatInfo.NumberGroupSeparator;
  CurrencyDecimalSeparator := numFormatInfo.CurrencyDecimalSeparator;
  CurrencyGroupSeparator := numFormatInfo.CurrencyGroupSeparator;
  LCID := AUserCulture.LCID;
  WindowsLCID := AFormatCulture.LCID;
end;

function .Equals(AObj: TObject): Boolean;
begin
  if !(AObj is TClientSettings) then
  begin
    Result := false;
  end
  ;
  Result := Equals((TClientSettings)AObj);
end;

function .Equals(AOther: TClientSettings): Boolean;
begin
  if ShortTimeFormat.Equals(AOther.ShortTimeFormat) and ShortTimeZero.Equals(AOther.ShortTimeZero) and LongTimePattern.Equals(AOther.LongTimePattern) and ShortDatePattern.Equals(AOther.ShortDatePattern) and TimeAMDesignator.Equals(AOther.TimeAMDesignator) and TimePMDesignator.Equals(AOther.TimePMDesignator) and TimeSeparator.Equals(AOther.TimeSeparator) and DateSeparator.Equals(AOther.DateSeparator) and DecimalSeparator.Equals(AOther.DecimalSeparator) and GroupSeparator.Equals(AOther.GroupSeparator) and CurrencyDecimalSeparator.Equals(AOther.CurrencyDecimalSeparator) and CurrencyGroupSeparator.Equals(AOther.CurrencyGroupSeparator) and LCID.Equals(AOther.LCID) then
  begin
    Result := WindowsLCID.Equals(AOther.WindowsLCID);
  end
  ;
  Result := false;
end;

function .GetHashCode(): Integer;
begin
  Result := ShortTimeFormat.GetHashCode() ^ ShortTimeZero.GetHashCode() ^ LongTimePattern.GetHashCode() ^ ShortDatePattern.GetHashCode() ^ TimeAMDesignator.GetHashCode() ^ TimePMDesignator.GetHashCode() ^ TimeSeparator.GetHashCode() ^ DateSeparator.GetHashCode() ^ DecimalSeparator.GetHashCode() ^ GroupSeparator.GetHashCode() ^ CurrencyDecimalSeparator.GetHashCode() ^ CurrencyGroupSeparator.GetHashCode() ^ LCID.GetHashCode() ^ WindowsLCID.GetHashCode();
end;


end.
