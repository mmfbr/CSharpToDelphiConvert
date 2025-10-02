unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterExpressionBalancer = class(TObject)
  public
    function Balance(AExpression: TFilterExpression): TFilterExpression;
    function SplitByBinaryType(ACurrent: TFilterExpression; ABinaryType: TFilterExpressionType): IEnumerable<TFilterExpression>;
  end;


implementation

function TFilterExpressionBalancer.Balance(AExpression: TFilterExpression): TFilterExpression;
begin
  combiningFunc: TFunc<TFilterExpression, TFilterExpression, TFilterExpression>;
  // TODO: Converter SwitchStatementSyntax
  Result := TFilterExpression.Balanced(SplitByBinaryType(AExpression, AExpression.ExpressionType).Select(Balance), combiningFunc);
end;

function TFilterExpressionBalancer.SplitByBinaryType(ACurrent: TFilterExpression; ABinaryType: TFilterExpressionType): IEnumerable<TFilterExpression>;
begin
  stack: TStack<TBinaryFilterExpression> := new Stack<TBinaryFilterExpression>();
  // TODO: Converter WhileStatementSyntax
end;


end.
