unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TModifyingExpressionVisitor = class(TFilterExpressionVisitor<TInput, TFilterExpression>)
  public
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TInput): TFilterExpression;
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TInput): TFilterExpression;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TInput): TFilterExpression;
    function VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TInput): TFilterExpression;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TInput): TFilterExpression;
  end;


implementation

function TModifyingExpressionVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TInput): TFilterExpression;
begin
  Result := ABinaryExpression.Update(ABinaryExpression.ExpressionType, Visit(ABinaryExpression.Left, AInput), Visit(ABinaryExpression.Right, AInput));
end;

function TModifyingExpressionVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TInput): TFilterExpression;
begin
  Result := AUnaryExpression;
end;

function TModifyingExpressionVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TInput): TFilterExpression;
begin
  Result := AWildcardExpression;
end;

function TModifyingExpressionVisitor.VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TInput): TFilterExpression;
begin
  Result := ABooleanConstantExpression;
end;

function TModifyingExpressionVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TInput): TFilterExpression;
begin
  Result := AFieldEqualsFieldExpression;
end;


end.
