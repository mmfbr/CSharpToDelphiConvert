unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TTransferExpressionContextVisitor = class(TModifyingExpressionVisitor<TFilterExpressionContext>)
  public
    constructor Create();
    function CoerceValue(ASourceValue: TGoldValue; ADestMetadata: INavFieldMetadata): TGoldValue;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
    function VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
  end;


implementation

constructor TTransferExpressionContextVisitor.Create();
begin
  inherited Create;
end;

function TTransferExpressionContextVisitor.CoerceValue(ASourceValue: TGoldValue; ADestMetadata: INavFieldMetadata): TGoldValue;
begin
  if sourceValue = null then
  begin
    Result := null;
  end
  ;
  Result := TGoldValue.CreateNavValueFromObject(destMetadata, sourceValue);
end;

function TTransferExpressionContextVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
begin
  Result := TFilterExpression.FieldEqualsField(fieldEqualsFieldExpression.FieldToCompareTo, input);
end;

function TTransferExpressionContextVisitor.VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
begin
  Result := TRangeFilterExpression.Create(rangeFilterExpression.ExpressionType, CoerceValue(rangeFilterExpression.LowValue, input.Metadata), CoerceValue(rangeFilterExpression.HighValue, input.Metadata), input);
end;

function TTransferExpressionContextVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(unaryExpression.ExpressionType, CoerceValue(unaryExpression.Value, input.Metadata), input);
end;

function TTransferExpressionContextVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TFilterExpressionContext): TFilterExpression;
begin
  Result := TWildcardFilterExpression.Create(wildcardExpression.IsNegated, wildcardExpression.Pattern, wildcardExpression.IsCaseAndAccentInsensitive, input);
end;


end.
