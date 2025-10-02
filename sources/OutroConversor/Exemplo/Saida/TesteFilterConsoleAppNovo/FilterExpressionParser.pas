unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TFilterExpressionParser = class(TObject)
  private
    m_expressionContext: TFilterExpressionContext;
    m_customVariableResolver: TFunc<string, TGoldType, string>;
    m_unknownVariableResolverDepth: Integer;
    m_tokenStream: TTokenStream;
    m_values: TGoldValue[];
    m_currentRecursionCount: Integer;
    m_leafCount: Integer;
    m_hasVariables: Boolean;
  public
    const m_RecursionLimit: Integer = 50;
    const m_MaxLeafCountBeforeBalancing: Integer = 200;
    const m_CaseAndAccentInsensitiveMarker: Char = '@';
    constructor Create(ATokenStream: TTokenStream; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AValues: TGoldValue[]);
    function MockResolveVariables(AStringToResolve: String; AType_: TGoldType): String;
    function Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; AAllowExpressionEvaluation: Boolean; AHasVariables: Boolean; AValues: TGoldValue[]): TFilterExpression;
    function Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; AValues: TGoldValue[]): TFilterExpression;
    function TryParse(AExpression: String; AExpressionContext: TFilterExpressionContext; AFilterExpression: TFilterExpression; AValues: TGoldValue[]): Boolean;
    function ParseInvariant(AExpression: String; AExpressionContext: TFilterExpressionContext; AValues: TGoldValue[]): TFilterExpression;
    function Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AValues: TGoldValue[]): TFilterExpression;
    function Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AHasVariables: Boolean; AValues: TGoldValue[]; ACultureInvariant: Boolean; ADataError: TDataError): TFilterExpression;
    function TryParse(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AHasVariables: Boolean; AFilterExpression: TFilterExpression; AValues: TGoldValue[]; ACultureInvariant: Boolean): Boolean;
    function ParseWithoutBalancing(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AValues: TGoldValue[]; AExpressionLeafCount: Integer; AHasVariables: Boolean; ACultureInvariant: Boolean; ADataError: TDataError): TFilterExpression;
    function ParseFilterTokensWithoutBalancing(AFilterTokens: TList<TFilterToken>; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AValues: TGoldValue[]; AExpressionLeafCount: Integer; AHasVariables: Boolean; AUseOnlyVariableResolver: Boolean; ACultureInvariant: Boolean; ADataError: TDataError): TFilterExpression;
    function Parse(AUseOnlyVariableResolver: Boolean; ADataError: TDataError): TFilterExpression;
    function ParseSubexpression(): TFilterExpression;
    function ParseSubexpression(ALhs: TFilterExpression; AMinPrecedence: Integer): TFilterExpression;
    function ParsePrimary(): TFilterExpression;
    function CombineExpressionsWithOperator(AOp: TFilterToken; ALhs: TFilterExpression; ARhs: TFilterExpression): TFilterExpression;
    function CreateDateTimeRangeExpressionFromValueFilter(ADatetimeValueExpression: TValueFilterExpression): TFilterExpression;
    function ToInnerValue(AExpression: TFilterExpression; AAutoExpandToClosingValue: Boolean): TGoldValue;
    function ToEqualOrWildcardIfValue(AExpression: TFilterExpression; AIsNegated: Boolean; AUseOnlyVariableResolver: Boolean; ADataError: TDataError): TFilterExpression;
    function TryGetWildcard(APattern: String; ANegated: Boolean; AWildcardFilterExpression: TWildcardFilterExpression): Boolean;
    function IsWildcard(APattern: String): Boolean;
    property CultureInvariant: Boolean read GetCultureInvariant write SetCultureInvariant;
  end;


implementation

constructor TFilterExpressionParser.Create(ATokenStream: TTokenStream; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AValues: TGoldValue[]);
begin
  Self.m_tokenStream := ATokenStream;
  Self.m_expressionContext := AExpressionContext;
  Self.m_customVariableResolver := ACustomVariableResolver;
  Self.m_unknownVariableResolverDepth := AUnknownVariableResolverDepth;
  Self.m_values := AValues;
end;

function TFilterExpressionParser.MockResolveVariables(AStringToResolve: String; AType_: TGoldType): String;
begin
  Result := string.Empty;
end;

function TFilterExpressionParser.Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; AAllowExpressionEvaluation: Boolean; AHasVariables: Boolean; AValues: TGoldValue[]): TFilterExpression;
begin
  if AAllowExpressionEvaluation then
  begin
    Result := Parse(AExpression, AExpressionContext, null, 0, out AHasVariables, AValues);
  end
  ;
  Result := Parse(AExpression, AExpressionContext, MockResolveVariables, 0, out AHasVariables, AValues);
end;

function TFilterExpressionParser.Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; AValues: TGoldValue[]): TFilterExpression;
begin
  flag: Boolean;
  Result := Parse(AExpression, AExpressionContext, null, 0, out flag, AValues);
end;

function TFilterExpressionParser.TryParse(AExpression: String; AExpressionContext: TFilterExpressionContext; AFilterExpression: TFilterExpression; AValues: TGoldValue[]): Boolean;
begin
  flag: Boolean;
  Result := TryParse(AExpression, AExpressionContext, null, 0, out flag, out AFilterExpression, AValues);
end;

function TFilterExpressionParser.ParseInvariant(AExpression: String; AExpressionContext: TFilterExpressionContext; AValues: TGoldValue[]): TFilterExpression;
begin
  flag: Boolean;
  Result := Parse(AExpression, AExpressionContext, null, 0, out flag, AValues, ACultureInvariant: true);
end;

function TFilterExpressionParser.Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AValues: TGoldValue[]): TFilterExpression;
begin
  flag: Boolean;
  Result := Parse(AExpression, AExpressionContext, ACustomVariableResolver, 0, out flag, AValues);
end;

function TFilterExpressionParser.Parse(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AHasVariables: Boolean; AValues: TGoldValue[]; ACultureInvariant: Boolean; ADataError: TDataError): TFilterExpression;
begin
  expressionLeafCount: Integer;
  filterExpression: TFilterExpression := ParseWithoutBalancing(AExpression, AExpressionContext, ACustomVariableResolver, AUnknownVariableResolverDepth, AValues, out expressionLeafCount, out AHasVariables, ACultureInvariant, ADataError);
  if filterExpression <> null and expressionLeafCount > m_MaxLeafCountBeforeBalancing then
  begin
    filterExpression := filterExpression.Balance().Simplify();
  end
  ;
  Result := filterExpression;
end;

function TFilterExpressionParser.TryParse(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AHasVariables: Boolean; AFilterExpression: TFilterExpression; AValues: TGoldValue[]; ACultureInvariant: Boolean): Boolean;
begin
  AFilterExpression := Parse(AExpression, AExpressionContext, ACustomVariableResolver, AUnknownVariableResolverDepth, out AHasVariables, AValues, ACultureInvariant, TDataError.TrapError);
  Result := AFilterExpression <> null;
end;

function TFilterExpressionParser.ParseWithoutBalancing(AExpression: String; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AValues: TGoldValue[]; AExpressionLeafCount: Integer; AHasVariables: Boolean; ACultureInvariant: Boolean; ADataError: TDataError): TFilterExpression;
begin
  tokens: TList<TFilterToken> := TFilterExpressionTokenizer.GetTokens(AExpression);
  // TODO: Converter TryStatementSyntax
end;

function TFilterExpressionParser.ParseFilterTokensWithoutBalancing(AFilterTokens: TList<TFilterToken>; AExpressionContext: TFilterExpressionContext; ACustomVariableResolver: TFunc<string, TGoldType, string>; AUnknownVariableResolverDepth: Integer; AValues: TGoldValue[]; AExpressionLeafCount: Integer; AHasVariables: Boolean; AUseOnlyVariableResolver: Boolean; ACultureInvariant: Boolean; ADataError: TDataError): TFilterExpression;
begin
  filterExpressionParser: TFilterExpressionParser := TFilterExpressionParser.Create(TTokenStream.Create(AFilterTokens), AExpressionContext, ACustomVariableResolver, AUnknownVariableResolverDepth, AValues)
            {
                CultureInvariant = ACultureInvariant
            };
  _result: TFilterExpression := filterExpressionParser.Parse(AUseOnlyVariableResolver, ADataError);
  AExpressionLeafCount := filterExpressionParser.m_leafCount;
  AHasVariables := filterExpressionParser.m_hasVariables;
  Result := _result;
end;

function TFilterExpressionParser.Parse(AUseOnlyVariableResolver: Boolean; ADataError: TDataError): TFilterExpression;
begin
  // TODO: Converter TryStatementSyntax
end;

function TFilterExpressionParser.ParseSubexpression(): TFilterExpression;
begin
  lhs: TFilterExpression := ParsePrimary();
  Result := ParseSubexpression(lhs, 0);
end;

function TFilterExpressionParser.ParseSubexpression(ALhs: TFilterExpression; AMinPrecedence: Integer): TFilterExpression;
begin
  // TODO: Converter WhileStatementSyntax
  if m_expressionContext.NclType = TGoldNclType.GoldDateTime then
  begin
    ALhs := CreateDateTimeRangeExpressionFromValueFilter(ALhs as TValueFilterExpression) ?? ALhs;
  end
  ;
  Result := ALhs;
end;

function TFilterExpressionParser.ParsePrimary(): TFilterExpression;
begin
  next: TFilterToken := m_tokenStream.Next;
  if next = null then
  begin
    Result := null;
  end
  ;
  if m_currentRecursionCount++ > m_RecursionLimit then
  begin
    raise TGoldInvalidFilterExpressionException.Create(TLang.FilterExpressionTooLarge);
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TFilterExpressionParser.CombineExpressionsWithOperator(AOp: TFilterToken; ALhs: TFilterExpression; ARhs: TFilterExpression): TFilterExpression;
begin
  if AOp.TokenType = TFilterTokenType.DotDot then
  begin
    m_leafCount++;
    if ALhs <> null then
    begin
      if ALhs.ExpressionType <> (TFilterExpressionType)2147483647 then
      begin
        raise TGoldInvalidFilterExpressionException.Create(TLang.FilterExpressionRangeLhsMustBeAValue);
      end
      ;
      if ARhs <> null then
      begin
        if ARhs.ExpressionType <> (TFilterExpressionType)2147483647 then
        begin
          raise TGoldInvalidFilterExpressionException.Create(TLang.FilterExpressionRangeRhsMustBeAValue);
        end
        ;
        Result := TFilterExpression.RangeBetweenInclusive(ToInnerValue(ALhs), ToInnerValue(ARhs, AAutoExpandToClosingValue: true), m_expressionContext);
      end
      ;
      Result := TFilterExpression.RangeFromInclusive(ToInnerValue(ALhs), m_expressionContext);
    end
    ;
    if ARhs <> null then
    begin
      if ARhs.ExpressionType <> (TFilterExpressionType)2147483647 then
      begin
        raise TGoldInvalidFilterExpressionException.Create(TLang.FilterExpressionRangeRhsMustBeAValue);
      end
      ;
      Result := TFilterExpression.RangeToInclusive(ToInnerValue(ARhs, AAutoExpandToClosingValue: true), m_expressionContext);
    end
    ;
    raise TGoldInvalidFilterExpressionException.Create(TLang.FilterExpressionRangeBothSidesOfRangeCannotBeEmpty);
  end
  ;
  if m_expressionContext.NclType = TGoldNclType.GoldDateTime then
  begin
    ALhs := CreateDateTimeRangeExpressionFromValueFilter(ALhs as TValueFilterExpression) ?? ALhs;
    ARhs := CreateDateTimeRangeExpressionFromValueFilter(ARhs as TValueFilterExpression) ?? ARhs;
  end
  ;
  if ALhs = null then
  begin
    raise TGoldInvalidFilterExpressionException.Create(string.Format(CultureInfo.CurrentCulture, TLang.FilterExpressionLhsCannotBeEmpty, AOp.Value));
  end
  ;
  if ARhs = null then
  begin
    raise TGoldInvalidFilterExpressionException.Create(string.Format(CultureInfo.CurrentCulture, TLang.FilterExpressionRhsCannotBeEmpty, AOp.Value));
  end
  ;
  Result := TBinaryFilterExpression.Create(AOp.TokenType.ToFilterExpressionType(), ToEqualOrWildcardIfValue(ALhs, AIsNegated: false), ToEqualOrWildcardIfValue(ARhs, AIsNegated: false));
end;

function TFilterExpressionParser.CreateDateTimeRangeExpressionFromValueFilter(ADatetimeValueExpression: TValueFilterExpression): TFilterExpression;
begin
  if m_expressionContext.NclType <> TGoldNclType.GoldDateTime or ADatetimeValueExpression = null then
  begin
    Result := null;
  end
  ;
  if ADatetimeValueExpression.FilterToken.Value.Contains("%") then
  begin
    Result := null;
  end
  ;
  if TGoldDateTimeEvaluator.HasTimePart(ADatetimeValueExpression.FilterToken.Value) then
  begin
    Result := null;
  end
  ;
  tokens: TList<TFilterToken> := new List<TFilterToken>(new TFilterToken[3]
            {
                ADatetimeValueExpression.FilterToken,
                TFilterToken.NonLiteral(TFilterTokenType.DotDot),
                ADatetimeValueExpression.FilterToken
            });
  Result := TFilterExpressionParser.Create(TTokenStream.Create(tokens), m_expressionContext, m_customVariableResolver, m_unknownVariableResolverDepth, m_values).Parse();
end;

function TFilterExpressionParser.ToInnerValue(AExpression: TFilterExpression; AAutoExpandToClosingValue: Boolean): TGoldValue;
begin
  Result := ((TValueFilterExpression)AExpression).ToNavValue(AAutoExpandToClosingValue);
end;

function TFilterExpressionParser.ToEqualOrWildcardIfValue(AExpression: TFilterExpression; AIsNegated: Boolean; AUseOnlyVariableResolver: Boolean; ADataError: TDataError): TFilterExpression;
begin
  if AExpression <> null and AExpression.ExpressionType = (TFilterExpressionType)2147483647 then
  begin
    Result := ((TValueFilterExpression)AExpression).ToExpression(AIsNegated, AUseOnlyVariableResolver, ADataError);
  end
  ;
  Result := AExpression;
end;

function TFilterExpressionParser.TryGetWildcard(APattern: String; ANegated: Boolean; AWildcardFilterExpression: TWildcardFilterExpression): Boolean;
begin
  if not IsWildcard(APattern) then
  begin
    AWildcardFilterExpression := null;
    Result := false;
  end
  ;
  m_leafCount++;
  if APattern[0] = m_CaseAndAccentInsensitiveMarker then
  begin
    AWildcardFilterExpression := TFilterExpression.Wildcard(ANegated, APattern.Substring(1), ACaseAndAccentInsensitive: true, m_expressionContext);
  end
  else
  begin
    AWildcardFilterExpression := TFilterExpression.Wildcard(ANegated, APattern, ACaseAndAccentInsensitive: false, m_expressionContext);
  end;
  Result := true;
end;

function TFilterExpressionParser.IsWildcard(APattern: String): Boolean;
begin
  if APattern.Length > 0 then
  begin
    if APattern[0] <> m_CaseAndAccentInsensitiveMarker then
    begin
      Result := APattern.IndexOfAny(m_WildcardChars) >= 0;
    end
    ;
    Result := true;
  end
  ;
  Result := false;
end;


end.
