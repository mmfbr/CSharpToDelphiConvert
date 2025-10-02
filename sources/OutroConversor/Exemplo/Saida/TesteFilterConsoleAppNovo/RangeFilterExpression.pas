unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TRangeFilterExpression = class(TFilterExpression)
  private
    m_highValue: TGoldValue;
    m_highValueToken: Integer;
    m_expressionContext: TFilterExpressionContext;
    m_lowValue: TGoldValue;
    m_lowValueToken: Integer;
    m_hashCode: Integer;
  public
    constructor Create(AFilterExpressionType: TFilterExpressionType; ALowValue: TGoldValue; AHighValue: TGoldValue; AExpressionContext: TFilterExpressionContext);
    constructor Create(ARangeFilterExpression: TRangeFilterExpression; ALowValueToken: Integer; AHighValueToken: Integer);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    function Equals(AOther: TRangeFilterExpression): Boolean;
    function GetHashCode(): Integer;
    function ComputeHashCode(): Integer;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property LowValue: TGoldValue read GetLowValue write SetLowValue;
    property LowValueToken: Integer read GetLowValueToken write SetLowValueToken;
    property HighValue: TGoldValue read GetHighValue write SetHighValue;
    property HighValueToken: Integer read GetHighValueToken write SetHighValueToken;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
  end;


implementation

constructor TRangeFilterExpression.Create(AFilterExpressionType: TFilterExpressionType; ALowValue: TGoldValue; AHighValue: TGoldValue; AExpressionContext: TFilterExpressionContext);
begin
  inherited Create;
  ValidateNotNull(expressionContext, "m_expressionContext");
  // TODO: Converter SwitchStatementSyntax
  Self.m_highValue := highValue;
  Self.m_lowValue := lowValue;
  Self.m_expressionContext := expressionContext;
  m_hashCode := ComputeHashCode();
  m_lowValueToken := -1;
  m_highValueToken := -1;
end;

constructor TRangeFilterExpression.Create(ARangeFilterExpression: TRangeFilterExpression; ALowValueToken: Integer; AHighValueToken: Integer);
begin
  inherited Create;
  m_highValue := rangeFilterExpression.m_highValue;
  m_lowValue := rangeFilterExpression.m_lowValue;
  m_expressionContext := rangeFilterExpression.m_expressionContext;
  m_hashCode := rangeFilterExpression.m_hashCode;
  Self.m_lowValueToken := lowValueToken;
  Self.m_highValueToken := highValueToken;
end;

function TRangeFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TRangeFilterExpression.ToRangeList(): TRangeList;
begin
  Result := ExpressionType switch
            {
                TFilterExpressionType.RangeBetweenInclusive => TRangeList.Create(TRange.Create(LowValue, lowIsInclusive: true, HighValue, highIsInclusive: true, m_expressionContext)),
                TFilterExpressionType.RangeFromInclusive => TRangeList.Create(TRange.CreateToMaximum(LowValue, lowIsInclusive: true, m_expressionContext)),
                TFilterExpressionType.RangeToInclusive => TRangeList.Create(TRange.CreateFromMinimum(HighValue, highIsInclusive: true, m_expressionContext)),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TRangeFilterExpression.Equals(AOther: TRangeFilterExpression): Boolean;
begin
  if this = other then
  begin
    Result := true;
  end
  ;
  if other = null or m_hashCode <> other.m_hashCode or ExpressionType <> other.ExpressionType or not m_expressionContext.Equals(other.ExpressionContext) then
  begin
    Result := false;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TRangeFilterExpression.GetHashCode(): Integer;
begin
  Result := m_hashCode;
end;

function TRangeFilterExpression.ComputeHashCode(): Integer;
begin
  Result := ExpressionType switch
            {
                TFilterExpressionType.RangeBetweenInclusive => THashCodeHelper.CombineHashCodes((int)ExpressionType, m_expressionContext.GetHashCode(), m_lowValue.GetHashCode(), m_highValue.GetHashCode()),
                TFilterExpressionType.RangeFromInclusive => THashCodeHelper.CombineHashCodes((int)ExpressionType, m_expressionContext.GetHashCode(), m_lowValue.GetHashCode()),
                TFilterExpressionType.RangeToInclusive => THashCodeHelper.CombineHashCodes((int)ExpressionType, m_expressionContext.GetHashCode(), m_highValue.GetHashCode()),
                _ => throw TNotSupportedException.Create(),
            };
end;


end.
