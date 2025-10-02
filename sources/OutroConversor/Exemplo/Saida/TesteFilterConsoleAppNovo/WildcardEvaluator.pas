unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TWildcardEvaluator = class(TObject)
  private
    m_compareOptions: TCompareOptions;
    m_isNegated: Boolean;
    m_originalPattern: String;
    m_locale: Integer;
    m_wildcardPatternType: TWildcardPatternType;
    m_analyzedPattern: String;
    m_patternTokens: string[];
  public
    const m_AccentAndCaseInsensitiveOptions: TCompareOptions = CompareOptions.IgnoreCase | CompareOptions.IgnoreNonSpace;
    const m_RemoveOrdinalOptionsMask: TCompareOptions = ~(CompareOptions.OrdinalIgnoreCase | CompareOptions.Ordinal);
    constructor Create(AWildcardFilterExpression: TWildcardFilterExpression);
    function Evaluate(AInput: String; AExpressionContext: TFilterExpressionContext): Boolean;
    function EvaluateImpl(AInput: String; AExpressionContext: TFilterExpressionContext): Boolean;
    function DeterminePatternType(): TWildcardPatternType;
    function EvaluateComplexPattern(AInput: String; AInputIndex: Integer; AMustStartHere: Boolean; ATokenIndex: Integer; ACompareInfo: TCompareInfo): Boolean;
    property PatternType: TWildcardPatternType read GetPatternType write SetPatternType;
  end;


implementation

constructor TWildcardEvaluator.Create(AWildcardFilterExpression: TWildcardFilterExpression);
begin
  m_originalPattern := wildcardFilterExpression.Pattern;
  m_isNegated := wildcardFilterExpression.IsNegated;
  m_compareOptions := wildcardFilterExpression.ExpressionContext.DefaultStringStringCompareOptions;
  if wildcardFilterExpression.IsCaseAndAccentInsensitive then
  begin
    m_compareOptions := (m_compareOptions | CompareOptions.IgnoreCase | CompareOptions.IgnoreNonSpace) & ~(CompareOptions.OrdinalIgnoreCase | CompareOptions.Ordinal);
  end
  ;
  m_locale := wildcardFilterExpression.ExpressionContext.SortCulture.LCID;
end;

function TWildcardEvaluator.Evaluate(AInput: String; AExpressionContext: TFilterExpressionContext): Boolean;
begin
  Result := m_isNegated ^ EvaluateImpl(input, expressionContext);
end;

function TWildcardEvaluator.EvaluateImpl(AInput: String; AExpressionContext: TFilterExpressionContext): Boolean;
begin
  compareInfo: TCompareInfo := expressionContext.SortCulture.CompareInfo;
  matchLength: Integer;
  matchLength2: Integer;
  // TODO: Converter SwitchStatementSyntax
end;

function TWildcardEvaluator.DeterminePatternType(): TWildcardPatternType;
begin
  if m_originalPattern.Length = 0 then
  begin
    Result := TWildcardPatternType.Any;
  end
  ;
  c: Char := m_originalPattern[0];
  if m_originalPattern.Length = 1 then
  begin
    Result := c switch
                {
                    '*' => TWildcardPatternType.Any,
                    '?' => TWildcardPatternType.Question,
                    _ => TWildcardPatternType.Const,
                };
  end
  ;
  if m_originalPattern.IndexOfAny(TFilterExpressionParser.m_WildcardChars, 1, m_originalPattern.Length - 2) >= 0 then
  begin
    list: TList<String> := TList<Tstring>.Create;
    num: Integer := 0;
    // TODO: Converter ForStatementSyntax
    if m_originalPattern.Length - num > 0 then
    begin
      list.Add(m_originalPattern.Substring(num, m_originalPattern.Length - num));
    end
    ;
    m_patternTokens := list.ToArray();
    Result := TWildcardPatternType.SomethingMoreComplicated;
  end
  ;
  c3: Char := m_originalPattern[m_originalPattern.Length - 1];
  // TODO: Converter SwitchStatementSyntax
end;

function TWildcardEvaluator.EvaluateComplexPattern(AInput: String; AInputIndex: Integer; AMustStartHere: Boolean; ATokenIndex: Integer; ACompareInfo: TCompareInfo): Boolean;
begin
  if tokenIndex = m_patternTokens.Length then
  begin
    if not mustStartHere then
    begin
      Result := true;
    end
    ;
    Result := inputIndex = input.Length;
  end
  ;
  text: String := m_patternTokens[tokenIndex];
  if text.Length = 1 then
  begin
    // TODO: Converter SwitchStatementSyntax
  end
  ;
  if mustStartHere then
  begin
    if inputIndex + 1 > input.Length then
    begin
      Result := false;
    end
    ;
    if TWildcardEvaluatorHelper.IsPrefix(m_locale, input, text, inputIndex, m_compareOptions, out var matchLength) then
    begin
      Result := EvaluateComplexPattern(input, inputIndex + matchLength, mustStartHere: true, tokenIndex + 1, compareInfo);
    end
    ;
    Result := false;
  end
  ;
  num: Integer := inputIndex;
  count: Integer;
  // TODO: Converter WhileStatementSyntax
  Result := false;
end;


end.
