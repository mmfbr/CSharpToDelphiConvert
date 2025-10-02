unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateTime = class(TGoldDateTimeValue)
  private
    m_defaultValue: TGoldDateTime;
    m_maxValue: TGoldDateTime;
    m_minValue: TGoldDateTime;
    m_SqlDateTimeUtcFirstValid: TDateTime;
    m_SqlDateTimeUtcLastValid: TDateTime;
    m_sqlWhereClauseValue: TObject;
    m_sqlWritableValue: TObject;
    m_nullValue: TGoldDateTime;
  public
    constructor Create();
    constructor Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AUnspecifiedAsLocal: Boolean);
    constructor Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AUnspecifiedAsLocal: Boolean; AAdjustNonexistentDateTime: Boolean);
    function Create(AInitValue: TDateTime): TGoldDateTime;
    function Create(AInitValue: TDateTime; AUnspecifiedAsLocal: Boolean): TGoldDateTime;
    function Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame): TGoldDateTime;
    function Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AUnspecifiedAsLocal: Boolean): TGoldDateTime;
    function CreateFromClientTimeAllowingForNonexistentTime(AValue: TDateTime): TGoldDateTime;
    function Create(AInitValue: Int64): TGoldDateTime;
    function Create(AInitValue: byte[]): TGoldDateTime;
    function CreateFromObject(AValue: TObject): TGoldDateTime;
    function GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
    function GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
    function GetBytes(): byte[];
    function ToInt64(): Int64;
    function ConvertCSideDateTimeToClientLocal(ACsideDateTime: Int64): Int64;
    function ConvertCSideDateTimeToUtc(ACsideDateTime: Int64; AAdjustNonexistentDateTime: Boolean): Int64;
    function Add(AValue1: TGoldDateTime; AMilliseconds: Int64): TGoldDateTime;
    function ConvertToLocalTime(ADateTime: TDateTime; AReferenceFrame: TDateTimeReferenceFrame): TDateTime;
    function ConvertToUTc(ADateTime: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AAdjustInvalidDateTime: Boolean): TDateTime;
    function AdjustForInvalidClientTime(AClientDateTime: TDateTime; AClientTimeZone: TimeZoneInfo): TDateTime;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property Default: TGoldDateTime read GetDefault write SetDefault;
    property MinValue: TGoldDateTime read GetMinValue write SetMinValue;
    property MaxValue: TGoldDateTime read GetMaxValue write SetMaxValue;
    property Now: TGoldDateTime read GetNow write SetNow;
    property ClientToday: TDateTime read GetClientToday write SetClientToday;
    property Undefined: TGoldDateTime read GetUndefined write SetUndefined;
    property Null: TGoldDateTime read GetNull write SetNull;
    property ClientLocalValue: TDateTime read GetClientLocalValue write SetClientLocalValue;
    property DatePart: TGoldDate read GetDatePart write SetDatePart;
    property TimePart: TGoldTime read GetTimePart write SetTimePart;
  end;


implementation

constructor TGoldDateTime.Create();
begin
  inherited Create;
end;

constructor TGoldDateTime.Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AUnspecifiedAsLocal: Boolean);
begin
  inherited Create;
end;

constructor TGoldDateTime.Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AUnspecifiedAsLocal: Boolean; AAdjustNonexistentDateTime: Boolean);
begin
  inherited Create;
  if AInitValue.Kind = DateTimeKind.Unspecified and not AUnspecifiedAsLocal and AInitValue >= TGoldDateTimeHelper.m_DateTimeJan1st1601 then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldDateTime.Create(AInitValue: TDateTime): TGoldDateTime;
begin
  Result := Create(AInitValue, AUnspecifiedAsLocal: false);
end;

function TGoldDateTime.Create(AInitValue: TDateTime; AUnspecifiedAsLocal: Boolean): TGoldDateTime;
begin
  Result := Create(AInitValue, TDateTimeReferenceFrame.Client, AUnspecifiedAsLocal);
end;

function TGoldDateTime.Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame): TGoldDateTime;
begin
  Result := Create(AInitValue, AReferenceFrame, AUnspecifiedAsLocal: false);
end;

function TGoldDateTime.Create(AInitValue: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AUnspecifiedAsLocal: Boolean): TGoldDateTime;
begin
  if AInitValue = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := m_defaultValue;
  end
  ;
  Result := TGoldDateTime.Create(AInitValue, AReferenceFrame, AUnspecifiedAsLocal);
end;

function TGoldDateTime.CreateFromClientTimeAllowingForNonexistentTime(AValue: TDateTime): TGoldDateTime;
begin
  if AValue = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := m_defaultValue;
  end
  ;
  Result := TGoldDateTime.Create(AValue, TDateTimeReferenceFrame.Client, AUnspecifiedAsLocal: false, AAdjustNonexistentDateTime: true);
end;

function TGoldDateTime.Create(AInitValue: Int64): TGoldDateTime;
begin
  Result := Create(TGoldDateTimeHelper.CSideDateTimeToDateTime(AInitValue));
end;

function TGoldDateTime.Create(AInitValue: byte[]): TGoldDateTime;
begin
  Result := Create(TGoldDateTimeHelper.CSideDateTimeToDateTime(BitConverter.ToInt64(AInitValue, 0)));
end;

function TGoldDateTime.CreateFromObject(AValue: TObject): TGoldDateTime;
begin
  if AValue = null then
  begin
    Result := Default;
  end
  ;
  if AValue is TGoldValue navValue then
  begin
    Result := Create(navValue.ToDateTime());
  end
  ;
  if AValue is DateTime then
  begin
    Result := Create((DateTime)AValue, TDateTimeReferenceFrame.Client, AUnspecifiedAsLocal: true);
  end
  ;
  if AValue is int or AValue is long then
  begin
    Result := Create(((IConvertible)AValue).ToInt32(CultureInfo.CurrentCulture));
  end
  ;
  if AValue is byte[] initValue then
  begin
    Result := Create(initValue);
  end
  ;
  raise CreateUnableToCreateFromObjectException(typeof(TGoldDateTime), AValue);
end;

function TGoldDateTime.GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
begin
  if m_sqlWhereClauseValue = null then
  begin
    if IsZeroOrEmpty then
    begin
      m_sqlWhereClauseValue := m_SqlDateTimeUtcUndefined;
    end
    else
    begin
      if m_value.CompareTo(m_SqlDateTimeUtcFirstValid) < 0 then
      begin
        m_sqlWhereClauseValue := m_SqlDateTimeUtcFirstValid;
      end
      else
      begin
        if m_value.CompareTo(m_SqlDateTimeUtcLastValid) > 0 then
        begin
          m_sqlWhereClauseValue := m_SqlDateTimeUtcLastValid;
        end
        else
        begin
          m_sqlWhereClauseValue := m_value;
        end;
      end;
    end;
  end
  ;
  Result := m_sqlWhereClauseValue;
end;

function TGoldDateTime.GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
begin
  if m_sqlWritableValue = null then
  begin
    if IsZeroOrEmpty then
    begin
      m_sqlWritableValue := m_SqlDateTimeUtcUndefined;
    end
    else
    begin
      if m_value.CompareTo(m_SqlDateTimeUtcFirstValid) < 0 or m_value.CompareTo(m_SqlDateTimeUtcLastValid) > 0 then
      begin
        raise TGoldCSideException.Create(22928068);
      end
      ;
      m_sqlWritableValue := m_value;
    end;
  end
  ;
  Result := m_sqlWritableValue;
end;

function TGoldDateTime.GetBytes(): byte[];
begin
  Result := BitConverter.GetBytes(ToInt64());
end;

function TGoldDateTime.ToInt64(): Int64;
begin
  Result := TGoldDateTimeHelper.DateTimeToCSideDateTime(Value);
end;

function TGoldDateTime.ConvertCSideDateTimeToClientLocal(ACsideDateTime: Int64): Int64;
begin
  dateTime: TDateTime := TGoldDateTimeHelper.CSideDateTimeToDateTime(ACsideDateTime);
  if dateTime >= TGoldDateTimeHelper.m_DateTimeJan1st1601 then
  begin
    dateTime2: TDateTime := ConvertToLocalTime(dateTime, TDateTimeReferenceFrame.Client);
    ACsideDateTime := TGoldDateTimeHelper.DateTimeToCSideDateTime(dateTime2);
  end
  ;
  Result := ACsideDateTime;
end;

function TGoldDateTime.ConvertCSideDateTimeToUtc(ACsideDateTime: Int64; AAdjustNonexistentDateTime: Boolean): Int64;
begin
  dateTime: TDateTime := TGoldDateTimeHelper.CSideDateTimeToDateTime(ACsideDateTime);
  if dateTime >= TGoldDateTimeHelper.m_DateTimeJan1st1601 then
  begin
    dateTime2: TDateTime := ConvertToUTc(dateTime, TDateTimeReferenceFrame.Client, AAdjustNonexistentDateTime);
    ACsideDateTime := TGoldDateTimeHelper.DateTimeToCSideDateTime(dateTime2);
  end
  ;
  Result := ACsideDateTime;
end;

function TGoldDateTime.Add(AValue1: TGoldDateTime; AMilliseconds: Int64): TGoldDateTime;
begin
  if AValue1 = null then
  begin
    raise TArgumentNullException.Create("AValue1");
  end
  ;
  dateTime: TDateTime := AValue1.Value;
  if dateTime = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  num: Int64 := TGoldDateTimeHelper.DateTimeToCSideDateTime(dateTime) + AMilliseconds;
  if num = 0L then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  navDateTime: TGoldDateTime := TGoldDateTime.Create();
  navDateTime.m_value := TGoldDateTimeHelper.CSideDateTimeToDateTime(num);
  Result := navDateTime;
end;

function TGoldDateTime.ConvertToLocalTime(ADateTime: TDateTime; AReferenceFrame: TDateTimeReferenceFrame): TDateTime;
begin
  if ADateTime = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := Undefined;
  end
  ;
  if ADateTime >= TGoldDateTimeHelper.m_DateTimeJan1st1601 then
  begin
    Result := DateTime.SpecifyKind(TimeZoneInfo.ConvertTimeFromUtc(ADateTime, TimeZoneInfo.Local), DateTimeKind.Local);
  end
  ;
  Result := DateTime.SpecifyKind(ADateTime, DateTimeKind.Local);
end;

function TGoldDateTime.ConvertToUTc(ADateTime: TDateTime; AReferenceFrame: TDateTimeReferenceFrame; AAdjustInvalidDateTime: Boolean): TDateTime;
begin
  if ADateTime = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := Undefined;
  end
  ;
  if ADateTime >= TGoldDateTimeHelper.m_DateTimeJan1st1601 then
  begin
    ADateTime := DateTime.SpecifyKind(ADateTime, DateTimeKind.Unspecified);
    clientTimeZone: TimeZoneInfo := TGoldCurrentSessionWrapper.ClientTimeZone;
    if clientTimeZone.IsInvalidTime(ADateTime) then
    begin
      if not AAdjustInvalidDateTime then
      begin
        raise TGoldNCLDateInvalidException.Create(string.Format(CultureInfo.CurrentCulture, TLang.InvalidDateTimeForTimeZone, ADateTime.ToString(CultureInfo.CurrentCulture)));
      end
      ;
      ADateTime := AdjustForInvalidClientTime(ADateTime, clientTimeZone);
    end
    ;
    Result := TimeZoneInfo.ConvertTimeToUtc(ADateTime, AReferenceFrame = TDateTimeReferenceFrame.Server ? TimeZoneInfo.Local : clientTimeZone);
  end
  ;
  Result := DateTime.SpecifyKind(ADateTime, DateTimeKind.Utc);
end;

function TGoldDateTime.AdjustForInvalidClientTime(AClientDateTime: TDateTime; AClientTimeZone: TimeZoneInfo): TDateTime;
begin
  adjustmentRule: TimeZoneInfo.AdjustmentRule := AClientTimeZone.GetAdjustmentRules().First((AR) => AR.DateStart <= AClientDateTime and AR.DateEnd >= AClientDateTime);
  Result := AClientDateTime + adjustmentRule.DaylightDelta;
end;


end.
