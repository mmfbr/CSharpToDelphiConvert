unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDate = class(TGoldDateTimeValue)
  private
    m_defaultValue: TGoldDate;
    m_SqlDateTimeFirstValid: TDateTime;
    m_SqlDateTimeLastValid: TDateTime;
    m_sqlWritableValue: TObject;
    m_sqlWhereClauseValue: TObject;
    m_nullValue: TGoldDate;
  public
    constructor Create();
    constructor Create(AInitValue: TDateTime);
    function Create(AInitValue: TDateTime): TGoldDate;
    function Create(AInitValue: byte[]): TGoldDate;
    function CreateNavDate(AData: byte[]; AStartIndex: Integer): TGoldDate;
    function Create(ACsideDate: Integer): TGoldDate;
    function Create(ACsideDate: uint): TGoldDate;
    function CreateFromBytes(AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldDate;
    function CreateFromObject(AValue: TObject): TGoldDate;
    function CreateDate(AValue: TDateTime; AClosing: Boolean): TGoldDate;
    function GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
    function GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
    function GetBytes(): byte[];
    function ToInt32(): Integer;
    function IsNormalDate(AValue: TDateTime): Boolean;
    function IsClosingDate(AValue: TDateTime): Boolean;
    function Add(ASource: TGoldDate; ADays: Integer): TGoldDate;
    function Subtract(AValue1: TGoldDate; AValue2: TGoldDate): Integer;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property Default: TGoldDate read GetDefault write SetDefault;
    property Null: TGoldDate read GetNull write SetNull;
    property Undefined: TGoldDate read GetUndefined write SetUndefined;
  end;


implementation

constructor TGoldDate.Create();
begin
  inherited Create;
end;

constructor TGoldDate.Create(AInitValue: TDateTime);
begin
  inherited Create;
  if initValue.Kind <> DateTimeKind.Local or not IsNormalDate(initValue) and not IsClosingDate(initValue) then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  m_value := initValue;
end;

function TGoldDate.Create(AInitValue: TDateTime): TGoldDate;
begin
  if initValue = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    Result := m_defaultValue;
  end
  ;
  Result := TGoldDate.Create(initValue);
end;

function TGoldDate.Create(AInitValue: byte[]): TGoldDate;
begin
  Result := Create(BitConverter.ToInt32(initValue, 0));
end;

function TGoldDate.CreateNavDate(AData: byte[]; AStartIndex: Integer): TGoldDate;
begin
  Result := Create(BitConverter.ToInt32(data, startIndex));
end;

function TGoldDate.Create(ACsideDate: Integer): TGoldDate;
begin
  Result := Create(TGoldDateTimeHelper.CSideDateToDateTime(csideDate));
end;

function TGoldDate.Create(ACsideDate: uint): TGoldDate;
begin
  Result := Create((int)csideDate);
end;

function TGoldDate.CreateFromBytes(AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldDate;
begin
  if data = null then
  begin
    raise TArgumentNullException.Create("m_data");
  end
  ;
  if length <= 0 then
  begin
    raise TGoldNCLTypeException.CreateWrongLengthException(TGoldType.Date);
  end
  ;
  if data.Length < startIndex + length or startIndex < 0 then
  begin
    raise TGoldNCLTypeException.CreateSourceHasWrongLengthException(TGoldType.Date);
  end
  ;
  Result := CreateNavDate(data, startIndex);
end;

function TGoldDate.CreateFromObject(AValue: TObject): TGoldDate;
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
  if value is int or value is long then
  begin
    Result := Create(((IConvertible)value).ToInt32(CultureInfo.CurrentCulture));
  end
  ;
  if value is byte[] initValue then
  begin
    Result := Create(initValue);
  end
  ;
  raise CreateUnableToCreateFromObjectException(typeof(TGoldDate), value);
end;

function TGoldDate.CreateDate(AValue: TDateTime; AClosing: Boolean): TGoldDate;
begin
  value := value.Date;
  if value = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    if closing then
    begin
      raise TGoldNCLDateInvalidException.Create();
    end
    ;
    Result := Undefined;
  end
  ;
  navDate: TGoldDate := TGoldDate.Create();
  if not closing then
  begin
    navDate.m_value := TDateTime.Create(value.Ticks, DateTimeKind.Local);
  end
  else
  begin
    navDate.m_value := TDateTime.Create(value.Ticks + TGoldDateTimeHelper.m_DateTimeClosingTicks, DateTimeKind.Local);
  end;
  Result := navDate;
end;

function TGoldDate.GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
begin
  if m_sqlWhereClauseValue = null then
  begin
    if IsZeroOrEmpty then
    begin
      m_sqlWhereClauseValue := m_SqlDateTimeUndefined;
    end
    else
    begin
      if m_value.CompareTo(m_SqlDateTimeFirstValid) < 0 then
      begin
        m_sqlWhereClauseValue := m_SqlDateTimeFirstValid;
      end
      else
      begin
        if m_value.CompareTo(m_SqlDateTimeLastValid) > 0 then
        begin
          m_sqlWhereClauseValue := m_SqlDateTimeLastValid;
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

function TGoldDate.GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
begin
  if m_sqlWritableValue = null then
  begin
    if IsZeroOrEmpty then
    begin
      m_sqlWritableValue := m_SqlDateTimeUndefined;
    end
    else
    begin
      if m_value.CompareTo(m_SqlDateTimeFirstValid) < 0 or m_value.CompareTo(m_SqlDateTimeLastValid) > 0 then
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

function TGoldDate.GetBytes(): byte[];
begin
  Result := BitConverter.GetBytes(ToInt32());
end;

function TGoldDate.ToInt32(): Integer;
begin
  Result := TGoldDateTimeHelper.DateTimeToCSideDate(Value);
end;

function TGoldDate.IsNormalDate(AValue: TDateTime): Boolean;
begin
  if value = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  Result := value.Ticks mod 864000000000L = 0;
end;

function TGoldDate.IsClosingDate(AValue: TDateTime): Boolean;
begin
  if value = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  Result := value.Ticks mod 864000000000L = TGoldDateTimeHelper.m_DateTimeClosingTicks;
end;

function TGoldDate.Add(ASource: TGoldDate; ADays: Integer): TGoldDate;
begin
  if source = null then
  begin
    raise TArgumentNullException.Create("m_source");
  end
  ;
  dateTime: TDateTime := source.Value;
  if dateTime = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  if IsClosingDate(dateTime) then
  begin
    raise TGoldNCLClosingDateOperationException.Create();
  end
  ;
  num: Integer := TGoldDateTimeHelper.DateTimeToCSideDate(dateTime) + days * 2;
  if num = 0 then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  navDate: TGoldDate := TGoldDate.Create();
  navDate.m_value := TGoldDateTimeHelper.CSideDateToDateTime(num);
  Result := navDate;
end;

function TGoldDate.Subtract(AValue1: TGoldDate; AValue2: TGoldDate): Integer;
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
  if IsClosingDate(dateTime) or IsClosingDate(dateTime2) then
  begin
    raise TGoldNCLClosingDateOperationException.Create();
  end
  ;
  Result := (TGoldDateTimeHelper.DateTimeToCSideDate(dateTime) - TGoldDateTimeHelper.DateTimeToCSideDate(dateTime2)) / 2;
end;


end.
