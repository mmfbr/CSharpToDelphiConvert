unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TBasicSimplifyingVisitor = class(TModifyingExpressionVisitor<object>)
  public
    constructor Create();
    function VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TObject): TFilterExpression;
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TObject): TFilterExpression;
    function TryTurnAndIntoRangeOrSingleValue(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
    function TryTurnOrIntoNotEqual(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
  end;


implementation

constructor TBasicSimplifyingVisitor.Create();
begin
  inherited Create;
end;

function TBasicSimplifyingVisitor.VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TObject): TFilterExpression;
begin
  if ARangeFilterExpression.ExpressionType = TFilterExpressionType.RangeBetweenInclusive and ARangeFilterExpression.ExpressionContext.Compare(ARangeFilterExpression.LowValue, ARangeFilterExpression.HighValue) = 0 then
  begin
    Result := TFilterExpression.Equal(ARangeFilterExpression.HighValue, ARangeFilterExpression.ExpressionContext);
  end
  ;
  Result := ARangeFilterExpression;
end;

function TBasicSimplifyingVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TObject): TFilterExpression;
begin
  filterExpression: TFilterExpression := base.VisitBinary(ABinaryExpression, AInput);
  // TODO: Converter SwitchStatementSyntax
end;

function TBasicSimplifyingVisitor.TryTurnAndIntoRangeOrSingleValue(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
begin
  if ALeft.ExpressionType = TFilterExpressionType.GreaterThanOrEqual and ARight.ExpressionType = TFilterExpressionType.LessThanOrEqual then
  begin
    unaryFilterExpression: TUnaryFilterExpression := (TUnaryFilterExpression)ALeft;
    unaryFilterExpression2: TUnaryFilterExpression := (TUnaryFilterExpression)ARight;
    if not unaryFilterExpression.ExpressionContext.Equals(unaryFilterExpression2.ExpressionContext) then
    begin
      Result := null;
    end
    ;
    value: TGoldValue := unaryFilterExpression.Value;
    value2: TGoldValue := unaryFilterExpression2.Value;
    num: Integer := unaryFilterExpression.ExpressionContext.Compare(value, value2);
    if num < 0 then
    begin
      Result := TFilterExpression.RangeBetweenInclusive(value, value2, unaryFilterExpression.ExpressionContext);
    end
    ;
    if num = 0 then
    begin
      Result := TFilterExpression.Equal(value, unaryFilterExpression.ExpressionContext);
    end
    ;
  end
  ;
  Result := null;
end;

function TBasicSimplifyingVisitor.TryTurnOrIntoNotEqual(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
begin
  if ALeft.ExpressionType = TFilterExpressionType.LessThan and ARight.ExpressionType = TFilterExpressionType.GreaterThan then
  begin
    unaryFilterExpression: TUnaryFilterExpression := (TUnaryFilterExpression)ALeft;
    unaryFilterExpression2: TUnaryFilterExpression := (TUnaryFilterExpression)ARight;
    if not unaryFilterExpression.ExpressionContext.Equals(unaryFilterExpression2.ExpressionContext) then
    begin
      Result := null;
    end
    ;
    value: TGoldValue := unaryFilterExpression.Value;
    value2: TGoldValue := unaryFilterExpression2.Value;
    if unaryFilterExpression.ExpressionContext.Compare(value, value2) = 0 then
    begin
      Result := TFilterExpression.NotEqual(value, unaryFilterExpression.ExpressionContext);
    end
    ;
  end
  ;
  Result := null;
end;


end.
