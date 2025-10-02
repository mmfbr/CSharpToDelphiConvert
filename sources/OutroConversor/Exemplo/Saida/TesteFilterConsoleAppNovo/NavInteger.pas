unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldInteger = class(TGoldValue)
  private
    m_defaultValue: TGoldInteger;
    m_minValue: TGoldInteger;
    m_maxValue: TGoldInteger;
    m_cachedNavIntegers: TGoldInteger[];
    m_value: Integer;
    m_nullValue: TGoldInteger;
  public
    constructor Create(AInitValue: Integer);
    function Create(AValue: Integer): TGoldInteger;
    function Create(AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldInteger;
    function CreateFromObject(AValue: TObject): TGoldInteger;
    procedure StoreToBytes(AWriter: TBinaryWriter);
    function GetHashCode(): Integer;
    function GetBytes(): byte[];
    function ToInt32(): Integer;
    function Equals(AOther: TGoldValue): Boolean;
    function Equals(AOther: Byte): Boolean;
    function Equals(AOther: Integer): Boolean;
    function Equals(AOther: Int64): Boolean;
    function CompareTo(AOther: TGoldValue): Integer;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property ValueAsObject: TObject read GetValueAsObject write SetValueAsObject;
    property IsZeroOrEmpty: Boolean read GetIsZeroOrEmpty write SetIsZeroOrEmpty;
    property Default: TGoldInteger read GetDefault write SetDefault;
    property Null: TGoldInteger read GetNull write SetNull;
    property Value: Integer read GetValue write SetValue;
    property MinValue: TGoldInteger read GetMinValue write SetMinValue;
    property MaxValue: TGoldInteger read GetMaxValue write SetMaxValue;
  end;


implementation

constructor TGoldInteger.Create(AInitValue: Integer);
begin
  inherited Create;
  m_value := initValue;
end;

function TGoldInteger.Create(AValue: Integer): TGoldInteger;
begin
  if value >= -5 and value <= 10 then
  begin
    Result := m_cachedNavIntegers[value - -5];
  end
  ;
  Result := TGoldInteger.Create(value);
end;

function TGoldInteger.Create(AData: byte[]; AStartIndex: Integer; ALength: Integer): TGoldInteger;
begin
  if data = null then
  begin
    raise TArgumentNullException.Create("m_data");
  end
  ;
  if length <> 4 then
  begin
    raise TGoldNCLTypeException.CreateWrongLengthException(TGoldType.Integer);
  end
  ;
  if data.Length < startIndex + length or startIndex < 0 then
  begin
    raise TGoldNCLTypeException.CreateSourceHasWrongLengthException(TGoldType.Integer);
  end
  ;
  Result := Create(BitConverter.ToInt32(data, startIndex));
end;

function TGoldInteger.CreateFromObject(AValue: TObject): TGoldInteger;
begin
  if value = null then
  begin
    Result := Default;
  end
  ;
  if value is TGoldValue navValue then
  begin
    Result := Create(navValue.ToInt32());
  end
  ;
  if value is string s then
  begin
    if int.TryParse(s, out var result) then
    begin
      Result := Create(result);
    end
    ;
  end
  else
  begin
    if value is IConvertible convertible then
    begin
      Result := Create(convertible.ToInt32(CultureInfo.CurrentCulture));
    end
    ;
    if value is byte[] data then
    begin
      Result := Create(data, 0, 4);
    end
    ;
  end;
  raise CreateUnableToCreateFromObjectException(typeof(TGoldInteger), value);
end;

procedure TGoldInteger.StoreToBytes(AWriter: TBinaryWriter);
begin
  if writer <> null then
  begin
    writer.Write((int)GoldType);
    writer.Write(4);
    writer.Write(m_value);
  end
  ;
end;

function TGoldInteger.GetHashCode(): Integer;
begin
  Result := Value;
end;

function TGoldInteger.GetBytes(): byte[];
begin
  Result := new byte[4]
            {
                (byte)((uint)m_value & 0xFFu),
                (byte)((uint)(m_value >> 8) & 0xFFu),
                (byte)((uint)(m_value >> 16) & 0xFFu),
                (byte)((uint)(m_value >> 24) & 0xFFu)
            };
end;

function TGoldInteger.ToInt32(): Integer;
begin
  Result := Value;
end;

function TGoldInteger.Equals(AOther: TGoldValue): Boolean;
begin
  if other = null then
  begin
    Result := false;
  end
  ;
  if other = this then
  begin
    Result := true;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldInteger.Equals(AOther: Byte): Boolean;
begin
  Result := Value = other;
end;

function TGoldInteger.Equals(AOther: Integer): Boolean;
begin
  Result := Value = other;
end;

function TGoldInteger.Equals(AOther: Int64): Boolean;
begin
  Result := Value = other;
end;

function TGoldInteger.CompareTo(AOther: TGoldValue): Integer;
begin
  if other <> null then
  begin
    // TODO: Converter SwitchStatementSyntax
  end
  ;
  ThrowUnableToCompareException(other);
  Result := 0;
end;


end.
