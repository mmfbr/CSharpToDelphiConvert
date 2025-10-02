unit GoldERP.Runtime;

interface

    property Value: Integer read GetValue write SetValue;
    constructor Create(AValue: Integer);
    function Equals(AOther: TCompanyId): Boolean;
    function ToString(): String;
    function Equals(AObj: TObject): Boolean;
    function GetHashCode(): Integer;
    function GetTypeCode(): TypeCode;
    function ToBoolean(AProvider: IFormatProvider): Boolean;
    function ToChar(AProvider: IFormatProvider): Char;
    function ToSByte(AProvider: IFormatProvider): sbyte;
    function ToByte(AProvider: IFormatProvider): Byte;
    function ToInt16(AProvider: IFormatProvider): SmallInt;
    function ToUInt16(AProvider: IFormatProvider): ushort;
    function ToInt32(AProvider: IFormatProvider): Integer;
    function ToUInt32(AProvider: IFormatProvider): uint;
    function ToInt64(AProvider: IFormatProvider): Int64;
    function ToUInt64(AProvider: IFormatProvider): ulong;
    function ToSingle(AProvider: IFormatProvider): Single;
    function ToDouble(AProvider: IFormatProvider): Double;
    function ToDecimal(AProvider: IFormatProvider): Currency;
    function ToDateTime(AProvider: IFormatProvider): TDateTime;
    function ToType(AConversionType: Type; AProvider: IFormatProvider): TObject;
    function ToString(AProvider: IFormatProvider): String;
    function CompareTo(AOther: TCompanyId): Integer;

implementation

constructor .Create(AValue: Integer);
begin
  Value := AValue;
end;

function .Equals(AOther: TCompanyId): Boolean;
begin
  Result := Value.Equals(AOther.Value);
end;

function .ToString(): String;
begin
  Result := Value.ToString(CultureInfo.InvariantCulture);
end;

function .Equals(AObj: TObject): Boolean;
begin
  if !(AObj is TCompanyId companyId) then
  begin
    Result := false;
  end
  ;
  Result := Value.Equals(companyId.Value);
end;

function .GetHashCode(): Integer;
begin
  Result := Value.GetHashCode();
end;

function .GetTypeCode(): TypeCode;
begin
  Result := TypeCode.Int32;
end;

function .ToBoolean(AProvider: IFormatProvider): Boolean;
begin
  raise InvalidCastException.Create();
end;

function .ToChar(AProvider: IFormatProvider): Char;
begin
  raise InvalidCastException.Create();
end;

function .ToSByte(AProvider: IFormatProvider): sbyte;
begin
  raise InvalidCastException.Create();
end;

function .ToByte(AProvider: IFormatProvider): Byte;
begin
  raise InvalidCastException.Create();
end;

function .ToInt16(AProvider: IFormatProvider): SmallInt;
begin
  raise InvalidCastException.Create();
end;

function .ToUInt16(AProvider: IFormatProvider): ushort;
begin
  raise InvalidCastException.Create();
end;

function .ToInt32(AProvider: IFormatProvider): Integer;
begin
  Result := Value;
end;

function .ToUInt32(AProvider: IFormatProvider): uint;
begin
  raise InvalidCastException.Create();
end;

function .ToInt64(AProvider: IFormatProvider): Int64;
begin
  Result := Value;
end;

function .ToUInt64(AProvider: IFormatProvider): ulong;
begin
  raise InvalidCastException.Create();
end;

function .ToSingle(AProvider: IFormatProvider): Single;
begin
  raise InvalidCastException.Create();
end;

function .ToDouble(AProvider: IFormatProvider): Double;
begin
  raise InvalidCastException.Create();
end;

function .ToDecimal(AProvider: IFormatProvider): Currency;
begin
  raise InvalidCastException.Create();
end;

function .ToDateTime(AProvider: IFormatProvider): TDateTime;
begin
  raise InvalidCastException.Create();
end;

function .ToType(AConversionType: Type; AProvider: IFormatProvider): TObject;
begin
  if AConversionType = typeof(int) then
  begin
    Result := Value;
  end
  ;
  if AConversionType = typeof(long) then
  begin
    Result := (long)Value;
  end
  ;
  raise InvalidCastException.Create();
end;

function .ToString(AProvider: IFormatProvider): String;
begin
  Result := Value.ToString(AProvider);
end;

function .CompareTo(AOther: TCompanyId): Integer;
begin
  Result := Value.CompareTo(AOther.Value);
end;


end.
