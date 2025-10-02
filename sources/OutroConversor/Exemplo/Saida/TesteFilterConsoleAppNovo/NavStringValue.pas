unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldStringValue = class(TGoldValue)
  public
    const m_MaxDefinedLength: Integer = 2048;
    function GetHashCode(): Integer;
    function ToString(): String;
    function GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
    function GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
    function Equals(AObj: TObject): Boolean;
    function Equals(AOther: TGoldValue): Boolean;
    function Equals(AOther: String): Boolean;
    function CompareTo(AOther: TGoldValue): Integer;
    function CompareTo(AOther: String): Integer;
    function CompareTo(AOther: TGoldStringValue): Integer;
    function Compare(ALeft: TGoldStringValue; ARight: TGoldStringValue): Integer;
    function Compare(ALeft: TGoldStringValue; ARight: String): Integer;
    function GetDefaultForMaxLength(ACachedValues: T[]; AMaxLength: Integer; ACreateDefault: TFunc<int, T>): T;
    function Truncate(AValue: String; AMaxLength: Integer): String;
    function GetStringFromBytes(AData: byte[]; AStartIndex: Integer; ALength: Integer): String;
    property Value: String read GetValue write SetValue;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property IsZeroOrEmpty: Boolean read GetIsZeroOrEmpty write SetIsZeroOrEmpty;
  end;


implementation

function TGoldStringValue.GetHashCode(): Integer;
begin
  Result := Value.GetHashCode();
end;

function TGoldStringValue.ToString(): String;
begin
  Result := Value;
end;

function TGoldStringValue.GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
begin
  Result := ValueAsObject;
end;

function TGoldStringValue.GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
begin
  if Value.Length > maxLength then
  begin
    raise TGoldCSideException.Create(22928068);
  end
  ;
  Result := ValueAsObject;
end;

function TGoldStringValue.Equals(AObj: TObject): Boolean;
begin
  if obj = null then
  begin
    Result := false;
  end
  ;
  if obj = this then
  begin
    Result := true;
  end
  ;
  if obj is TGoldValue other then
  begin
    Result := Equals(other);
  end
  ;
  if obj is string text then
  begin
    Result := Value = text;
  end
  ;
  Result := ThrowUnableToCompareException(obj);
end;

function TGoldStringValue.Equals(AOther: TGoldValue): Boolean;
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
  if other is TGoldStringValue then
  begin
    Result := Value = other.ToString();
  end
  ;
  Result := ThrowUnableToCompareException(other);
end;

function TGoldStringValue.Equals(AOther: String): Boolean;
begin
  Result := string.Equals(Value, other);
end;

function TGoldStringValue.CompareTo(AOther: TGoldValue): Integer;
begin
  if other is TGoldStringValue other2 then
  begin
    Result := CompareTo(other2);
  end
  ;
  ThrowUnableToCompareException(other);
  Result := 0;
end;

function TGoldStringValue.CompareTo(AOther: String): Integer;
begin
  if other = null then
  begin
    Result := -1;
  end
  ;
  Result := string.Compare(Value, other, ignoreCase: false, TGoldCurrentThread.Session.Culture);
end;

function TGoldStringValue.CompareTo(AOther: TGoldStringValue): Integer;
begin
  if (object)other = null then
  begin
    Result := 1;
  end
  ;
  if (object)other = this then
  begin
    Result := 0;
  end
  ;
  Result := string.Compare(Value, other.Value, ignoreCase: false, TGoldCurrentThread.Session.Culture);
end;

function TGoldStringValue.Compare(ALeft: TGoldStringValue; ARight: TGoldStringValue): Integer;
begin
  if (object)right = null then
  begin
    if (object)left <> null then
    begin
      Result := 1;
    end
    ;
    Result := 0;
  end
  ;
  if (object)left = null then
  begin
    Result := -1;
  end
  ;
  if (object)left = right then
  begin
    Result := 0;
  end
  ;
  Result := left.CompareTo(right);
end;

function TGoldStringValue.Compare(ALeft: TGoldStringValue; ARight: String): Integer;
begin
  if right = null then
  begin
    if (object)left <> null then
    begin
      Result := 1;
    end
    ;
    Result := 0;
  end
  ;
  Result := left?.CompareTo(right) ?? -1;
end;

function TGoldStringValue.GetDefaultForMaxLength(ACachedValues: T[]; AMaxLength: Integer; ACreateDefault: TFunc<int, T>): T;
begin
  if maxLength >= cachedValues.Length then
  begin
    Result := createDefault(maxLength);
  end
  ;
  val: T := cachedValues[maxLength];
  if val = null then
  begin
    val := cachedValues[maxLength] = createDefault(maxLength);
  end
  ;
  Result := val;
end;

function TGoldStringValue.Truncate(AValue: String; AMaxLength: Integer): String;
begin
  if value <> null and value.Length > maxLength then
  begin
    value := value.Substring(0, maxLength);
  end
  ;
  Result := value;
end;

function TGoldStringValue.GetStringFromBytes(AData: byte[]; AStartIndex: Integer; ALength: Integer): String;
begin
  i: Integer;
  // TODO: Converter ForStatementSyntax
  length := i - startIndex;
  Result := Encoding.Unicode.GetString(data, startIndex, length);
end;


end.
