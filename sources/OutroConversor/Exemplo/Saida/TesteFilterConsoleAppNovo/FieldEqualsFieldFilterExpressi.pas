unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFieldEqualsFieldFilterExpression = class(TFilterExpression)
  private
    m_fieldToCompareTo: INavFieldMetadata;
    m_expressionContext: TFilterExpressionContext;
    m_hashCode: Integer;
  public
    constructor Create(AFieldToCompareTo: INavFieldMetadata; AExpressionContext: TFilterExpressionContext);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    function Equals(AOther: TFieldEqualsFieldFilterExpression): Boolean;
    function GetHashCode(): Integer;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property FieldToCompareTo: INavFieldMetadata read GetFieldToCompareTo write SetFieldToCompareTo;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
  end;


implementation

constructor TFieldEqualsFieldFilterExpression.Create(AFieldToCompareTo: INavFieldMetadata; AExpressionContext: TFilterExpressionContext);
begin
  inherited Create;
  ValidateNotNull(AFieldToCompareTo, "m_fieldToCompareTo");
  ValidateNotNull(AExpressionContext, "m_expressionContext");
  Self.m_fieldToCompareTo := AFieldToCompareTo;
  Self.m_expressionContext := AExpressionContext;
  m_hashCode := THashCodeHelper.CombineHashCodes(Self.m_fieldToCompareTo.GetHashCode(), Self.m_expressionContext.GetHashCode());
end;

function TFieldEqualsFieldFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
  raise TNotSupportedException.Create();
end;

function TFieldEqualsFieldFilterExpression.ToRangeList(): TRangeList;
begin
  raise TNotSupportedException.Create();
end;

function TFieldEqualsFieldFilterExpression.Equals(AOther: TFieldEqualsFieldFilterExpression): Boolean;
begin
  if AOther <> null then
  begin
    if this <> AOther then
    begin
      if m_hashCode = AOther.m_hashCode and m_expressionContext.Equals(AOther.m_expressionContext) then
      begin
        Result := m_fieldToCompareTo.Equals(AOther.m_fieldToCompareTo);
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

function TFieldEqualsFieldFilterExpression.GetHashCode(): Integer;
begin
  Result := m_hashCode;
end;


end.
