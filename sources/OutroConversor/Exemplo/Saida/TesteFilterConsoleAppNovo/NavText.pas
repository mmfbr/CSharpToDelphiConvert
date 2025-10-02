unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldText = class(TGoldStringValue)
  private
    m_defaultValue: TGoldText;
    m_nullValue: TGoldText;
    m_value: String;
    m_maxLength: Integer;
    m_isNull: Boolean;
    m_cachedNavTexts: TGoldText[];
    m_cachedNavTextNulls: TGoldText[];
    m_createDefault: TFunc<int, TGoldText>;
    m_createDefaultNull: TFunc<int, TGoldText>;
  public
    const m_MaxSize: Integer = int.MaxValue;
    const m_MaxDefinedSize: Integer = 2048;
    constructor Create(AMaxLength: Integer; AValue: String);
    constructor Create(AValue: String);
    constructor Create(AMaxLength: Integer; AData: byte[]; AStartIndex: Integer; ALength: Integer);
    constructor Create(AMaxLength: Integer; AValue: byte[]);
    function GetDefaultForMaxLength(AMaxLength: Integer): TGoldText;
    function GetNullForMaxLength(AMaxLength: Integer): TGoldText;
    function CreateFromBytes(AMaxLength: Integer; AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldText;
    function CreateFromObject(AMaxLength: Integer; AValue: TObject): TGoldText;
    procedure SetMaxLength(ANewMaxLength: Integer);
    function Default(AMaxLength: Integer): TGoldText;
    function NullWithMaxLength(AMaxLength: Integer): TGoldText;
    function ToInt32(): Integer;
    function ToInt64(): Int64;
    function GetBytes(): byte[];
    property Value: String read GetValue write SetValue;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property IsNull: Boolean read GetIsNull write SetIsNull;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property ValueAsObject: TObject read GetValueAsObject write SetValueAsObject;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property GoldDefinedLengthMetadata: Integer read GetGoldDefinedLengthMetadata write SetGoldDefinedLengthMetadata;
  end;


implementation

constructor TGoldText.Create(AMaxLength: Integer; AValue: String);
begin
  inherited Create;
  if string.IsNullOrEmpty(value) then
  begin
    m_isNull := value = null;
    value := string.Empty;
  end
  ;
  SetMaxLength(maxLength);
  if Self.m_maxLength > 0 and value.Length > Self.m_maxLength then
  begin
    raise TGoldNCLStringLengthExceededException.Create(Self.m_maxLength, value.Length, value);
  end
  ;
  Self.m_value := value;
end;

constructor TGoldText.Create(AValue: String);
begin
  inherited Create;
  if string.IsNullOrEmpty(value) then
  begin
    m_isNull := value = null;
    value := string.Empty;
  end
  ;
  m_maxLength := int.MaxValue;
  Self.m_value := value;
end;

constructor TGoldText.Create(AMaxLength: Integer; AData: byte[]; AStartIndex: Integer; ALength: Integer);
begin
  inherited Create;
  SetMaxLength(maxLength);
  if data = null then
  begin
    raise TArgumentNullException.Create("m_data");
  end
  ;
  if length < 0 then
  begin
    raise TGoldNCLTypeException.CreateWrongLengthException(TGoldType.Text);
  end
  ;
  if data.Length < startIndex + length or startIndex < 0 then
  begin
    raise TGoldNCLTypeException.CreateSourceHasWrongLengthException(TGoldType.Text);
  end
  ;
  m_value := GetStringFromBytes(data, startIndex, length);
end;

constructor TGoldText.Create(AMaxLength: Integer; AValue: byte[]);
begin
  inherited Create;
  SetMaxLength(maxLength);
  if ((uint)value.Length & (true ? 1u : 0u)) <> 0 then
  begin
    raise TGoldNCLTypeException.CreateSourceHasWrongLengthException(TGoldType.Text);
  end
  ;
  Self.m_value := GetStringFromBytes(value, 0, value.Length);
end;

function TGoldText.GetDefaultForMaxLength(AMaxLength: Integer): TGoldText;
begin
  Result := GetDefaultForMaxLength(m_cachedNavTexts, maxLength, m_createDefault);
end;

function TGoldText.GetNullForMaxLength(AMaxLength: Integer): TGoldText;
begin
  Result := GetDefaultForMaxLength(m_cachedNavTextNulls, maxLength, m_createDefaultNull);
end;

function TGoldText.CreateFromBytes(AMaxLength: Integer; AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldText;
begin
  Result := TGoldText.Create(maxLength, data, startIndex, length);
end;

function TGoldText.CreateFromObject(AMaxLength: Integer; AValue: TObject): TGoldText;
begin
  if value = null then
  begin
    navText: TGoldText := Default(maxLength);
    navText.m_isNull := true;
    Result := navText;
  end
  ;
  if value is TGoldValue navValue then
  begin
    Result := TGoldText.Create(maxLength, navValue.ToString());
  end
  ;
  if value is string text then
  begin
    Result := TGoldText.Create(maxLength, text);
  end
  ;
  if value is byte[] array then
  begin
    Result := TGoldText.Create(maxLength, array);
  end
  ;
  raise CreateUnableToCreateFromObjectException(typeof(TGoldText), value);
end;

procedure TGoldText.SetMaxLength(ANewMaxLength: Integer);
begin
  m_maxLength := (if newMaxLength = 0 then int.MaxValue else newMaxLength);
end;

function TGoldText.Default(AMaxLength: Integer): TGoldText;
begin
  Result := GetDefaultForMaxLength(maxLength);
end;

function TGoldText.NullWithMaxLength(AMaxLength: Integer): TGoldText;
begin
  Result := GetNullForMaxLength(maxLength);
end;

function TGoldText.ToInt32(): Integer;
begin
  Result := int.Parse(Value, TGoldCurrentThread.Session.WindowsCulture);
end;

function TGoldText.ToInt64(): Int64;
begin
  Result := long.Parse(Value, TGoldCurrentThread.Session.WindowsCulture);
end;

function TGoldText.GetBytes(): byte[];
begin
  array_: byte[] := new byte[(m_value.Length + 1) * 2];
  Encoding.Unicode.GetBytes(m_value, 0, m_value.Length, array_, 0);
  Result := array_;
end;


end.
