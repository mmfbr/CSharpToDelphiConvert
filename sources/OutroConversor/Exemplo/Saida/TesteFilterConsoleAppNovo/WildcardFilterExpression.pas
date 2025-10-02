unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TWildcardFilterExpression = class(TFilterExpression)
  private
    m_evaluator: TWildcardEvaluator;
    m_isCaseAndAccentInsensitive: Boolean;
    m_expressionContext: TFilterExpressionContext;
    m_isNegated: Boolean;
    m_pattern: String;
    m_hashCode: Integer;
  public
    constructor Create(AIsNegated: Boolean; APattern: String; AIsCaseAndAccentInsensitive: Boolean; AExpressionContext: TFilterExpressionContext);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    function Equals(AOther: TWildcardFilterExpression): Boolean;
    function GetHashCode(): Integer;
    function ComputeHashCode(): Integer;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property Pattern: String read GetPattern write SetPattern;
    property IsCaseAndAccentInsensitive: Boolean read GetIsCaseAndAccentInsensitive write SetIsCaseAndAccentInsensitive;
    property IsNegated: Boolean read GetIsNegated write SetIsNegated;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
  end;


implementation

constructor TWildcardFilterExpression.Create(AIsNegated: Boolean; APattern: String; AIsCaseAndAccentInsensitive: Boolean; AExpressionContext: TFilterExpressionContext);
begin
  inherited Create;
  ValidateNotNull(pattern, "m_pattern");
  ValidateNotNull(expressionContext, "m_expressionContext");
  Self.m_isNegated := isNegated;
  Self.m_isCaseAndAccentInsensitive := isCaseAndAccentInsensitive;
  Self.m_expressionContext := expressionContext;
  Self.m_pattern := pattern;
  if Self.m_expressionContext.Metadata.NclType = TGoldNclType.GoldCode then
  begin
    Self.m_pattern := Self.m_pattern.ToUpper(CultureInfo.InvariantCulture);
  end
  ;
  m_evaluator := TWildcardEvaluator.Create(this);
  m_hashCode := ComputeHashCode();
end;

function TWildcardFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
  Result := m_evaluator.Evaluate(input.ToString(), m_expressionContext);
end;

function TWildcardFilterExpression.ToRangeList(): TRangeList;
begin
  raise TCannotConvertWildcardIntoRangeException.Create();
end;

function TWildcardFilterExpression.Equals(AOther: TWildcardFilterExpression): Boolean;
begin
  if other <> null then
  begin
    if this <> other then
    begin
      if m_hashCode = other.m_hashCode and m_expressionContext.Equals(other.m_expressionContext) and m_pattern = other.m_pattern and m_isNegated = other.m_isNegated then
      begin
        Result := m_isCaseAndAccentInsensitive = other.m_isCaseAndAccentInsensitive;
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

function TWildcardFilterExpression.GetHashCode(): Integer;
begin
  Result := m_hashCode;
end;

function TWildcardFilterExpression.ComputeHashCode(): Integer;
begin
  Result := THashCodeHelper.CombineHashCodes((int)ExpressionType, m_expressionContext.GetHashCode(), m_pattern.GetHashCode(), Convert.ToInt32(m_isCaseAndAccentInsensitive) | Convert.ToInt32(m_isNegated) << 1);
end;


end.
