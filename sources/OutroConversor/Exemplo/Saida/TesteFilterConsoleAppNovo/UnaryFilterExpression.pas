unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TUnaryFilterExpression = class(TFilterExpression)
  private
    m_value: TGoldValue;
    m_valueToken: Integer;
    m_expressionContext: TFilterExpressionContext;
    m_hashCode: Integer;
  public
    constructor Create(AFilterExpressionType: TFilterExpressionType; AValue: TGoldValue; AExpressionContext: TFilterExpressionContext; AValueToken: Integer);
    constructor Create(AUnaryFilterExpression: TUnaryFilterExpression; AValueToken: Integer);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    function Equals(AOther: TUnaryFilterExpression): Boolean;
    function GetHashCode(): Integer;
    function ComputeHashCode(): Integer;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property Value: TGoldValue read GetValue write SetValue;
    property ValueToken: Integer read GetValueToken write SetValueToken;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
  end;


implementation

constructor TUnaryFilterExpression.Create(AFilterExpressionType: TFilterExpressionType; AValue: TGoldValue; AExpressionContext: TFilterExpressionContext; AValueToken: Integer);
begin
  inherited Create;
  ValidateNotNull(value, "m_value");
  ValidateNotNull(expressionContext, "m_expressionContext");
  if (uint)filterExpressionType > 5u then
  begin
    raise TArgumentOutOfRangeException.Create("filterExpressionType");
  end
  ;
  Self.m_value := value;
  Self.m_expressionContext := expressionContext;
  m_hashCode := ComputeHashCode();
  Self.m_valueToken := valueToken;
end;

constructor TUnaryFilterExpression.Create(AUnaryFilterExpression: TUnaryFilterExpression; AValueToken: Integer);
begin
  inherited Create;
  m_value := unaryFilterExpression.m_value;
  m_expressionContext := unaryFilterExpression.m_expressionContext;
  m_hashCode := unaryFilterExpression.m_hashCode;
  Self.m_valueToken := valueToken;
end;

function TUnaryFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
  num: Integer := m_expressionContext.Compare(input, Value);
  Result := ExpressionType switch
            {
                TFilterExpressionType.Equal => num = 0,
                TFilterExpressionType.NotEqual => num <> 0,
                TFilterExpressionType.GreaterThan => num > 0,
                TFilterExpressionType.LessThan => num < 0,
                TFilterExpressionType.GreaterThanOrEqual => num >= 0,
                TFilterExpressionType.LessThanOrEqual => num <= 0,
                _ => throw TNotSupportedException.Create(),
            };
end;

function TUnaryFilterExpression.ToRangeList(): TRangeList;
begin
  Result := ExpressionType switch
            {
                TFilterExpressionType.Equal => TRangeList.Create(TRange.CreateForSingleValue(Value, m_expressionContext)),
                TFilterExpressionType.NotEqual => TRangeList.CreateForEverythingExceptASingleValue(Value, m_expressionContext),
                TFilterExpressionType.GreaterThan => TRangeList.Create(TRange.CreateToMaximum(Value, lowIsInclusive: false, m_expressionContext)),
                TFilterExpressionType.LessThan => TRangeList.Create(TRange.CreateFromMinimum(Value, highIsInclusive: false, m_expressionContext)),
                TFilterExpressionType.GreaterThanOrEqual => TRangeList.Create(TRange.CreateToMaximum(Value, lowIsInclusive: true, m_expressionContext)),
                TFilterExpressionType.LessThanOrEqual => TRangeList.Create(TRange.CreateFromMinimum(Value, highIsInclusive: true, m_expressionContext)),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TUnaryFilterExpression.Equals(AOther: TUnaryFilterExpression): Boolean;
begin
  if other <> null then
  begin
    if this <> other then
    begin
      if m_hashCode = other.m_hashCode and ExpressionType = other.ExpressionType and m_expressionContext.Equals(other.m_expressionContext) then
      begin
        Result := m_value.Equals(other.m_value);
      end
      ;
      Result := false;
    end
    ;
    Result := true;
  end
  ;
  Result := false;
end;

function TUnaryFilterExpression.GetHashCode(): Integer;
begin
  Result := m_hashCode;
end;

function TUnaryFilterExpression.ComputeHashCode(): Integer;
begin
  Result := THashCodeHelper.CombineHashCodes((int)ExpressionType, m_expressionContext.GetHashCode(), m_value.GetHashCode());
end;


end.
