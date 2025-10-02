unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TBooleanConstantFilterExpression = class(TFilterExpression)
  private
    m_trueHashCode: Integer;
    m_falseHashCode: Integer;
    m_trueExpression: TBooleanConstantFilterExpression;
    m_falseExpression: TBooleanConstantFilterExpression;
    m_value: Boolean;
  public
    constructor Create(AValue: Boolean);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    function Equals(AOther: TBooleanConstantFilterExpression): Boolean;
    function GetHashCode(): Integer;
    function Get(AValue: Boolean): TBooleanConstantFilterExpression;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property Value: Boolean read GetValue write SetValue;
  end;


implementation

constructor TBooleanConstantFilterExpression.Create(AValue: Boolean);
begin
  inherited Create;
  Self.m_value := AValue;
end;

function TBooleanConstantFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
  Result := Value;
end;

function TBooleanConstantFilterExpression.ToRangeList(): TRangeList;
begin
  if not Value then
  begin
    Result := TRangeList.CreateEmpty();
  end
  ;
  Result := TRangeList.CreateFull();
end;

function TBooleanConstantFilterExpression.Equals(AOther: TBooleanConstantFilterExpression): Boolean;
begin
  if AOther <> null then
  begin
    Result := m_value = AOther.m_value;
  end
  ;
  Result := false;
end;

function TBooleanConstantFilterExpression.GetHashCode(): Integer;
begin
  if not m_value then
  begin
    Result := m_falseHashCode;
  end
  ;
  Result := m_trueHashCode;
end;

function TBooleanConstantFilterExpression.Get(AValue: Boolean): TBooleanConstantFilterExpression;
begin
  if not AValue then
  begin
    Result := m_falseExpression;
  end
  ;
  Result := m_trueExpression;
end;


end.
