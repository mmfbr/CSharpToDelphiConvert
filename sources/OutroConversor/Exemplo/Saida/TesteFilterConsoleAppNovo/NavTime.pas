unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldTime = class(TGoldDateTimeValue)
  private
    m_defaultValue: TGoldTime;
    m_minValue: TGoldTime;
    m_maxValue: TGoldTime;
    m_sqlValue: TObject;
  public
    const m_SqlTimeYear: Integer = 1754;
    const m_SqlTimeMonth: Integer = 1;
    const m_SqlTimeDay: Integer = 1;
    constructor Create();
    constructor Create(AInitValue: TDateTime);
    function Create(AInitValue: TDateTime): TGoldTime;
    function Create(AHours: Integer; AMinutes: Integer; ASeconds: Integer; AMilliseconds: Integer): TGoldTime;
    function Create(ACsideTime: Integer): TGoldTime;
    function Create(ACsideTime: uint): TGoldTime;
    function Create(AInitValue: byte[]): TGoldTime;
    function Create(AData: byte[]; AStartIndex: Integer): TGoldTime;
    function CreateFromBytes(AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldTime;
    function CreateFromObject(AValue: TObject): TGoldTime;
    function CreateTime(AValue: TDateTime): TGoldTime;
    function GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
    function GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
    function GetBytes(): byte[];
    function ToInt32(): Integer;
    function Add(AValue1: TGoldTime; AMilliseconds: Integer): TGoldTime;
    function Subtract(AValue1: TGoldTime; AValue2: TGoldTime): Integer;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property Default: TGoldTime read GetDefault write SetDefault;
    property MinValue: TGoldTime read GetMinValue write SetMinValue;
    property MaxValue: TGoldTime read GetMaxValue write SetMaxValue;
    property Undefined: TGoldTime read GetUndefined write SetUndefined;
  end;


implementation

constructor TGoldTime.Create();
begin
  inherited Create;
end;

constructor TGoldTime.Create(AInitValue: TDateTime);
begin
  inherited Create;
  if initValue.Kind <> DateTimeKind.Local or initValue.Date <> TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    raise TGoldNCLInvalidTimeException.Create();
  end
  ;
  m_value := TGoldDateTimeHelper.RoundDateTimeToMilliseconds(initValue);
end;

function TGoldTime.Create(AInitValue: TDateTime): TGoldTime;
begin
  if initValue = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := m_defaultValue;
  end
  ;
  Result := TGoldTime.Create(initValue);
end;

function TGoldTime.Create(AHours: Integer; AMinutes: Integer; ASeconds: Integer; AMilliseconds: Integer): TGoldTime;
begin
  // TODO: Converter TryStatementSyntax
end;

function TGoldTime.Create(ACsideTime: Integer): TGoldTime;
begin
  Result := Create(TGoldDateTimeHelper.CSideTimeToDateTime(csideTime));
end;

function TGoldTime.Create(ACsideTime: uint): TGoldTime;
begin
  Result := Create((int)csideTime);
end;

function TGoldTime.Create(AInitValue: byte[]): TGoldTime;
begin
  Result := Create(BitConverter.ToInt32(initValue, 0));
end;

function TGoldTime.Create(AData: byte[]; AStartIndex: Integer): TGoldTime;
begin
  Result := Create(BitConverter.ToInt32(data, startIndex));
end;

function TGoldTime.CreateFromBytes(AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldTime;
begin
  if data = null then
  begin
    raise TArgumentNullException.Create("m_data");
  end
  ;
  if length <> 4 then
  begin
    raise TGoldNCLTypeException.CreateWrongLengthException(TGoldType.Time);
  end
  ;
  if data.Length < startIndex + length or startIndex < 0 then
  begin
    raise TGoldNCLTypeException.CreateSourceHasWrongLengthException(TGoldType.Time);
  end
  ;
  Result := Create(data, startIndex);
end;

function TGoldTime.CreateFromObject(AValue: TObject): TGoldTime;
begin
  if value = null then
  begin
    Result := Default;
  end
  ;
  if value is TGoldValue navValue then
  begin
    Result := Create(navValue.ToDateTime());
  end
  ;
  if value is DateTime then
  begin
    Result := Create((DateTime)value);
  end
  ;
  if value is IConvertible convertible then
  begin
    Result := Create(convertible.ToInt32(CultureInfo.CurrentCulture));
  end
  ;
  if value is byte[] initValue then
  begin
    Result := Create(initValue);
  end
  ;
  raise CreateUnableToCreateFromObjectException(typeof(TGoldTime), value);
end;

function TGoldTime.CreateTime(AValue: TDateTime): TGoldTime;
begin
  if value = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := Undefined;
  end
  ;
  navTime: TGoldTime := TGoldTime.Create();
  dateTime: TDateTime := TGoldDateTimeHelper.RoundDateTimeToMilliseconds(value);
  navTime.m_value := TGoldDateTimeHelper.m_DateTimeMinimum.AddTicks(dateTime.TimeOfDay.Ticks);
  Result := navTime;
end;

function TGoldTime.GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
begin
  Result := GetSqlWritableValue(sqlDataType, 0);
end;

function TGoldTime.GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
begin
  if m_sqlValue = null then
  begin
    if (object)this = Undefined then
    begin
      m_sqlValue := m_SqlTimeUndefined;
    end
    else
    begin
      m_sqlValue := TDateTime.Create(m_SqlTimeYear, m_SqlTimeMonth, m_SqlTimeDay, m_value.Hour, m_value.Minute, m_value.Second, m_value.Millisecond, DateTimeKind.Local);
    end;
  end
  ;
  Result := m_sqlValue;
end;

function TGoldTime.GetBytes(): byte[];
begin
  num: uint := Convert.ToUInt32(ToInt32());
  Result := BitConverter.GetBytes(num);
end;

function TGoldTime.ToInt32(): Integer;
begin
  Result := TGoldDateTimeHelper.DateTimeToCSideTime(Value);
end;

function TGoldTime.Add(AValue1: TGoldTime; AMilliseconds: Integer): TGoldTime;
begin
  if value1 = null then
  begin
    raise TArgumentNullException.Create("value1");
  end
  ;
  dateTime: TDateTime := value1.Value;
  if value1 = Undefined then
  begin
    raise TGoldNCLInvalidTimeException.Create();
  end
  ;
  num: Integer := (int)(dateTime.Ticks mod 864000000000L / 10000) + milliseconds mod 86400000;
  num := (num + 86400000) % 86400000;
  navTime: TGoldTime := TGoldTime.Create();
  navTime.m_value := TGoldDateTimeHelper.m_DateTimeMinimum.AddMilliseconds(num);
  Result := navTime;
end;

function TGoldTime.Subtract(AValue1: TGoldTime; AValue2: TGoldTime): Integer;
begin
  if value1 = null then
  begin
    raise TArgumentNullException.Create("value1");
  end
  ;
  if value2 = null then
  begin
    raise TArgumentNullException.Create("value2");
  end
  ;
  dateTime: TDateTime := value1.Value;
  dateTime2: TDateTime := value2.Value;
  if dateTime = dateTime2 then
  begin
    Result := 0;
  end
  ;
  if dateTime = TGoldDateTimeHelper.m_DateTimeUndefined or dateTime2 = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  Result := (int)(dateTime - dateTime2).TotalMilliseconds;
end;


end.
