unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateTimeValue = class(TGoldValue)
  public
    function GetHashCode(): Integer;
    function ToDateTime(): TDateTime;
    function Equals(AObj: TObject): Boolean;
    function Equals(AOther: TGoldValue): Boolean;
    function CompareTo(AOther: TGoldValue): Integer;
    function CompareTo(AOther: TGoldDateTimeValue): Integer;
    function Compare(ALeft: TGoldDateTimeValue; ARight: TGoldDateTimeValue): Integer;
    property Value: TDateTime read GetValue write SetValue;
    property ValueAsObject: TObject read GetValueAsObject write SetValueAsObject;
    property ClientObject: TObject read GetClientObject write SetClientObject;
    property IsZeroOrEmpty: Boolean read GetIsZeroOrEmpty write SetIsZeroOrEmpty;
  end;


implementation

function TGoldDateTimeValue.GetHashCode(): Integer;
begin
  Result := Value.GetHashCode();
end;

function TGoldDateTimeValue.ToDateTime(): TDateTime;
begin
  Result := m_value;
end;

function TGoldDateTimeValue.Equals(AObj: TObject): Boolean;
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
  if obj is DateTime then
  begin
    Result := Value = (DateTime)obj;
  end
  ;
  Result := ThrowUnableToCompareException(obj);
end;

function TGoldDateTimeValue.Equals(AOther: TGoldValue): Boolean;
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
  if other.GoldType = TGoldType.Date then
  begin
    Result := Value = other.ToDateTime();
  end
  ;
  if other is TGoldDateTimeValue then
  begin
    Result := Value = other.ToDateTime();
  end
  ;
  Result := ThrowUnableToCompareException(other);
end;

function TGoldDateTimeValue.CompareTo(AOther: TGoldValue): Integer;
begin
  if other is TGoldDateTimeValue other2 then
  begin
    Result := CompareTo(other2);
  end
  ;
  ThrowUnableToCompareException(other);
  Result := 0;
end;

function TGoldDateTimeValue.CompareTo(AOther: TGoldDateTimeValue): Integer;
begin
  if other = null then
  begin
    Result := 1;
  end
  ;
  if (object)other = this then
  begin
    Result := 0;
  end
  ;
  Result := DateTime.Compare(Value, other.Value);
end;

function TGoldDateTimeValue.Compare(ALeft: TGoldDateTimeValue; ARight: TGoldDateTimeValue): Integer;
begin
  if right = null then
  begin
    if left <> null then
    begin
      Result := 1;
    end
    ;
    Result := 0;
  end
  ;
  if left = null then
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


end.
