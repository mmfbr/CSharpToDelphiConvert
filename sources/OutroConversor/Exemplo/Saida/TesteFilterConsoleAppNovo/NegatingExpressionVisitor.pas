unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TNegatingExpressionVisitor = class(TFilterExpressionVisitor<object, TFilterExpression>)
  public
    constructor Create();
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TObject): TFilterExpression;
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TObject): TFilterExpression;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TObject): TFilterExpression;
    function VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TObject): TFilterExpression;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TObject): TFilterExpression;
  end;


implementation

constructor TNegatingExpressionVisitor.Create();
begin
  inherited Create;
end;

function TNegatingExpressionVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TObject): TFilterExpression;
begin
  Result := binaryExpression.ExpressionType switch
            {
                TFilterExpressionType.And => TFilterExpression.Or(Visit(binaryExpression.Left, input), Visit(binaryExpression.Right, input)),
                TFilterExpressionType.Or => TFilterExpression.And(Visit(binaryExpression.Left, input), Visit(binaryExpression.Right, input)),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TNegatingExpressionVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TObject): TFilterExpression;
begin
  Result := unaryExpression.ExpressionType switch
            {
                TFilterExpressionType.Equal => TFilterExpression.NotEqual(unaryExpression.Value, unaryExpression.ExpressionContext),
                TFilterExpressionType.NotEqual => TFilterExpression.Equal(unaryExpression.Value, unaryExpression.ExpressionContext),
                TFilterExpressionType.GreaterThan => TFilterExpression.LessThanOrEqual(unaryExpression.Value, unaryExpression.ExpressionContext),
                TFilterExpressionType.LessThan => TFilterExpression.GreaterThanOrEqual(unaryExpression.Value, unaryExpression.ExpressionContext),
                TFilterExpressionType.GreaterThanOrEqual => TFilterExpression.LessThan(unaryExpression.Value, unaryExpression.ExpressionContext),
                TFilterExpressionType.LessThanOrEqual => TFilterExpression.GreaterThan(unaryExpression.Value, unaryExpression.ExpressionContext),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TNegatingExpressionVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TObject): TFilterExpression;
begin
  Result := TFilterExpression.Wildcard(not wildcardExpression.IsNegated, wildcardExpression.Pattern, wildcardExpression.IsCaseAndAccentInsensitive, wildcardExpression.ExpressionContext);
end;

function TNegatingExpressionVisitor.VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TObject): TFilterExpression;
begin
  Result := TFilterExpression.BooleanConstant(not booleanConstantExpression.Value);
end;

function TNegatingExpressionVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TObject): TFilterExpression;
begin
  raise TNotSupportedException.Create();
end;


end.
