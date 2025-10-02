unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateFormula = class(TGoldStringValue)
  private
    m_defaultValue: TGoldDateFormula;
    m_value: String;
    m_bytes: byte[];
  public
    const m_ByteSize: Integer = 32;
    const m_MaxCharSize: Integer = 32;
    constructor Create(AInitValue: String);
    constructor Create(AInitValue: String; AIsTokenString: Boolean);
    function Create(AInitValue: String; AIsTokenString: Boolean): TGoldDateFormula;
    function CreateFromObject(AValue: TObject): TGoldDateFormula;
    function GetHashCode(): Integer;
    function CalcDate(ADate: TGoldDate): TGoldDate;
    function ToString(): String;
    function Equals(AOther: TGoldValue): Boolean;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property ValueAsObject: TObject read GetValueAsObject write SetValueAsObject;
    property ClientObject: TObject read GetClientObject write SetClientObject;
    property IsZeroOrEmpty: Boolean read GetIsZeroOrEmpty write SetIsZeroOrEmpty;
    property TokenString: String read GetTokenString write SetTokenString;
    property Default: TGoldDateFormula read GetDefault write SetDefault;
    property Value: String read GetValue write SetValue;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
  end;


implementation

constructor TGoldDateFormula.Create(AInitValue: String);
begin
  inherited Create;
end;

constructor TGoldDateFormula.Create(AInitValue: String; AIsTokenString: Boolean);
begin
  inherited Create;
  if isTokenString then
  begin
    m_value := initValue;
  end
  else
  begin
    m_value := TGoldDateFormulaEvaluator.Parse(initValue, 0);
  end;
end;

function TGoldDateFormula.Create(AInitValue: String; AIsTokenString: Boolean): TGoldDateFormula;
begin
  if string.IsNullOrEmpty(initValue) then
  begin
    Result := Default;
  end
  ;
  Result := TGoldDateFormula.Create(initValue, isTokenString);
end;

function TGoldDateFormula.CreateFromObject(AValue: TObject): TGoldDateFormula;
begin
  if value = null then
  begin
    Result := Default;
  end
  ;
  if value is TGoldValue navValue then
  begin
    raise TNotImplementedException.Create("ainda não fiz isso aqui mais");
  end
  ;
  if value is byte[] initValue then
  begin
    raise TNotImplementedException.Create("ainda não fiz isso aqui mais 2");
  end
  ;
  if value is string initValue2 then
  begin
    Result := TGoldDateFormula.Create(initValue2);
  end
  ;
  raise CreateUnableToCreateFromObjectException(typeof(TGoldDateFormula), value);
end;

function TGoldDateFormula.GetHashCode(): Integer;
begin
  Result := m_value.GetHashCode();
end;

function TGoldDateFormula.CalcDate(ADate: TGoldDate): TGoldDate;
begin
  Result := TGoldDateFormulaEvaluator.CalcDate(m_value, date);
end;

function TGoldDateFormula.ToString(): String;
begin
  Result := TGoldDateFormulaFormatter.Format(this, TGoldCurrentThread.Session.FormatSettings, 0);
end;

function TGoldDateFormula.Equals(AOther: TGoldValue): Boolean;
begin
  if this = other then
  begin
    Result := true;
  end
  ;
  if !(other is TGoldDateFormula navDateFormula) then
  begin
    Result := false;
  end
  ;
  Result := string.Equals(m_value, navDateFormula.m_value, StringComparison.Ordinal);
end;


end.
