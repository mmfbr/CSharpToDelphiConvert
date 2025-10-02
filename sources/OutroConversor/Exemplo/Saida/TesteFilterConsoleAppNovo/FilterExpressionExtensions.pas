unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterExpressionExtensions = class(TObject)
  public
    function OperatorString(AFilterExpressionType: TFilterExpressionType): String;
    function OperatorPrecedence(AToken: TFilterToken): Integer;
    function ToFilterExpressionType(ATokenType: TFilterTokenType): TFilterExpressionType;
    function Visit(AFilterExpression: TFilterExpression; AVisitors: TModifyingExpressionVisitor<object>[]): TFilterExpression;
    function Visit(AFilterExpression: TFilterExpression; AVisitor: TFilterExpressionVisitor<TInput, TReturn>; AInput: TInput): TReturn;
    procedure WriteToBinary(AFilterExpression: TFilterExpression; AWriter: TBinaryWriter);
    function OptimizeForEvaluation(AFilterExpression: TFilterExpression): TFilterExpression;
    function Simplify(AFilterExpression: TFilterExpression): TFilterExpression;
    function Optimize(AFilterExpression: TFilterExpression; ATryBalanced: Boolean): TFilterExpression;
    function ToFilterExpression(ARangeList: TRangeList; AOptimizeForEvaluation: Boolean): TFilterExpression;
    function ToFilterExpression(ARange: TRange): TFilterExpression;
    function TransferToDifferentContext(AInputExpression: TFilterExpression; ANewExpressionContext: TFilterExpressionContext): TFilterExpression;
    function Negate(AInputExpression: TFilterExpression): TFilterExpression;
    function IsNullOrConstantTrue(AExpression: TFilterExpression): Boolean;
    function IsConstantFalse(AExpression: TFilterExpression): Boolean;
    function IsNotNullAndConstantTrue(AExpression: TFilterExpression): Boolean;
  end;


implementation

function TFilterExpressionExtensions.OperatorString(AFilterExpressionType: TFilterExpressionType): String;
begin
  Result := AFilterExpressionType switch
            {
                TFilterExpressionType.Equal => "=",
                TFilterExpressionType.NotEqual => "<>",
                TFilterExpressionType.GreaterThan => ">",
                TFilterExpressionType.LessThan => "<",
                TFilterExpressionType.GreaterThanOrEqual => ">=",
                TFilterExpressionType.LessThanOrEqual => "<=",
                TFilterExpressionType.And => "&",
                TFilterExpressionType.Or => "|",
                _ => throw TNotSupportedException.Create(),
            };
end;

function TFilterExpressionExtensions.OperatorPrecedence(AToken: TFilterToken): Integer;
begin
  Result := AToken.TokenType switch
            {
                TFilterTokenType.DotDot => 3,
                TFilterTokenType.And => 2,
                TFilterTokenType.Or => 1,
                _ => -1,
            };
end;

function TFilterExpressionExtensions.ToFilterExpressionType(ATokenType: TFilterTokenType): TFilterExpressionType;
begin
  Result := ATokenType switch
            {
                TFilterTokenType.Equal => TFilterExpressionType.Equal,
                TFilterTokenType.NotEqual => TFilterExpressionType.NotEqual,
                TFilterTokenType.GreaterThan => TFilterExpressionType.GreaterThan,
                TFilterTokenType.LessThan => TFilterExpressionType.LessThan,
                TFilterTokenType.GreaterThanOrEqual => TFilterExpressionType.GreaterThanOrEqual,
                TFilterTokenType.LessThanOrEqual => TFilterExpressionType.LessThanOrEqual,
                TFilterTokenType.And => TFilterExpressionType.And,
                TFilterTokenType.Or => TFilterExpressionType.Or,
                _ => throw TNotSupportedException.Create(),
            };
end;

function TFilterExpressionExtensions.Visit(AFilterExpression: TFilterExpression; AVisitors: TModifyingExpressionVisitor<object>[]): TFilterExpression;
begin
  Result := AVisitors.Aggregate(AFilterExpression, (AExpression, AVisitor) => AVisitor.Visit(AExpression, null));
end;

function TFilterExpressionExtensions.Visit(AFilterExpression: TFilterExpression; AVisitor: TFilterExpressionVisitor<TInput, TReturn>; AInput: TInput): TReturn;
begin
  Result := AVisitor.Visit(AFilterExpression, AInput);
end;

procedure TFilterExpressionExtensions.WriteToBinary(AFilterExpression: TFilterExpression; AWriter: TBinaryWriter);
begin
  TFilterBinaryWriterVisitor.WriteToBinaryWriter(AFilterExpression, AWriter);
end;

function TFilterExpressionExtensions.OptimizeForEvaluation(AFilterExpression: TFilterExpression): TFilterExpression;
begin
  Result := Optimize(AFilterExpression, ATryBalanced: true);
end;

function TFilterExpressionExtensions.Simplify(AFilterExpression: TFilterExpression): TFilterExpression;
begin
  Result := Optimize(AFilterExpression, ATryBalanced: false);
end;

function TFilterExpressionExtensions.Optimize(AFilterExpression: TFilterExpression; ATryBalanced: Boolean): TFilterExpression;
begin
  if AFilterExpression = null then
  begin
    Result := null;
  end
  ;
  expressionType: TFilterExpressionType := AFilterExpression.ExpressionType;
  if (uint)(expressionType - 6) <= 1u then
  begin
    // TODO: Converter TryStatementSyntax
  end
  ;
  Result := AFilterExpression;
end;

function TFilterExpressionExtensions.ToFilterExpression(ARangeList: TRangeList; AOptimizeForEvaluation: Boolean): TFilterExpression;
begin
  Result := TRangeListExpressionBuilder.BuildExpression(ARangeList, AOptimizeForEvaluation);
end;

function TFilterExpressionExtensions.ToFilterExpression(ARange: TRange): TFilterExpression;
begin
  if ARange.IsFullRange then
  begin
    Result := TFilterExpression.BooleanConstant(AValue: true);
  end
  ;
  if ARange.IsEmptyRange then
  begin
    Result := TFilterExpression.BooleanConstant(AValue: false);
  end
  ;
  if not ARange.IsLowIsMinimum and not ARange.IsHighMaximum and ARange.IsLowIncluded and ARange.IsHighIncluded then
  begin
    if ARange.ExpressionContext.Compare(ARange.LowValue, ARange.HighValue) = 0 then
    begin
      Result := TFilterExpression.Equal(ARange.LowValue, ARange.ExpressionContext);
    end
    ;
    Result := TFilterExpression.RangeBetweenInclusive(ARange.LowValue, ARange.HighValue, ARange.ExpressionContext);
  end
  ;
  filterExpression: TFilterExpression := (if ARange.IsLowIsMinimum then null else (if ARange.IsLowIncluded then TFilterExpression.GreaterThanOrEqual(ARange.LowValue, ARange.ExpressionContext) else TFilterExpression.GreaterThan(ARange.LowValue, ARange.ExpressionContext)));
  filterExpression2: TFilterExpression := (if ARange.IsHighMaximum then null else (if ARange.IsHighIncluded then TFilterExpression.LessThanOrEqual(ARange.HighValue, ARange.ExpressionContext) else TFilterExpression.LessThan(ARange.HighValue, ARange.ExpressionContext)));
  if filterExpression2 = null then
  begin
    Result := filterExpression;
  end
  ;
  if filterExpression = null then
  begin
    Result := filterExpression2;
  end
  ;
  Result := TFilterExpression.And(filterExpression, filterExpression2);
end;

function TFilterExpressionExtensions.TransferToDifferentContext(AInputExpression: TFilterExpression; ANewExpressionContext: TFilterExpressionContext): TFilterExpression;
begin
  Result := AInputExpression.Visit(TTransferExpressionContextVisitor.m_Instance, ANewExpressionContext);
end;

function TFilterExpressionExtensions.Negate(AInputExpression: TFilterExpression): TFilterExpression;
begin
  Result := TNegatingExpressionVisitor.m_Instance.Visit(AInputExpression, null);
end;

function TFilterExpressionExtensions.IsNullOrConstantTrue(AExpression: TFilterExpression): Boolean;
begin
  if AExpression <> null then
  begin
    if AExpression.ExpressionType = TFilterExpressionType.BooleanConstant then
    begin
      Result := ((TBooleanConstantFilterExpression)AExpression).Value;
    end
    ;
    Result := false;
  end
  ;
  Result := true;
end;

function TFilterExpressionExtensions.IsConstantFalse(AExpression: TFilterExpression): Boolean;
begin
  if AExpression.ExpressionType = TFilterExpressionType.BooleanConstant then
  begin
    Result := !((TBooleanConstantFilterExpression)AExpression).Value;
  end
  ;
  Result := false;
end;

function TFilterExpressionExtensions.IsNotNullAndConstantTrue(AExpression: TFilterExpression): Boolean;
begin
  if AExpression <> null and AExpression.ExpressionType = TFilterExpressionType.BooleanConstant then
  begin
    Result := ((TBooleanConstantFilterExpression)AExpression).Value;
  end
  ;
  Result := false;
end;


end.
