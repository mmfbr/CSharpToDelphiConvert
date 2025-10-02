unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterExpressionVisitor = class(TObject)
  public
    function Visit(AExpression: TFilterExpression; AInput: TInput): TReturn;
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TInput): TReturn;
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TInput): TReturn;
    function VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TInput): TReturn;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TInput): TReturn;
    function VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TInput): TReturn;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TInput): TReturn;
  end;


implementation

function TFilterExpressionVisitor.Visit(AExpression: TFilterExpression; AInput: TInput): TReturn;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpressionVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TInput): TReturn;
begin
end;

function TFilterExpressionVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TInput): TReturn;
begin
end;

function TFilterExpressionVisitor.VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TInput): TReturn;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpressionVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TInput): TReturn;
begin
end;

function TFilterExpressionVisitor.VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TInput): TReturn;
begin
end;

function TFilterExpressionVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TInput): TReturn;
begin
end;


end.
