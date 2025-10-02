unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterExpressionContext = class(ISizableObject)
  private
    m_defaultStringCompareOptions: TCompareOptions;
    m_navFieldMetadata: INavFieldMetadata;
    m_sortCulture: TCultureInfo;
    m_canBeOptimized: Boolean;
    m_nclType: TGoldNclType;
    m_hashCode: Integer;
    m_ContainsWildcardCharactersSubRegex: String;
    m_TextLiteralNeedsQuotingRegex: TRegex;
    m_TextWildcardNeedsQuotingRegex: TRegex;
    m_NonTextLiteralNeedsQuotingRegex: TRegex;
    m_OnlyQuoteCloseParenthesisRegex: TRegex;
    m_BlobNeedsQuotingRegex: TRegex;
  public
    const m_StartsWithSingleQuoteSubRegex: String = "^\\'";
    const m_IsEmptySubRegex: String = "^\\s*";
    const m_StartsWithWhiteSpaceSubRegex: String = "^\\s";
    const m_StartsWithCaseInsensitivityOperatorRegex: String = "^@";
    const m_EndsWithWhiteSpaceSubRegex: String = "\\s";
    const m_ContainsFilterExpressionTokensSubRegex: String = "[=<>()&|]|\\.\\.";
    const m_ContainsCloseParenthesisSubRegex: String = "\\)";
    constructor Create(ANavFieldMetadata: INavFieldMetadata; ASortCulture: TCultureInfo; ADefaultStringCompareOptions: TCompareOptions; ACanBeOptimized: Boolean);
    function Midpoint(ALow: TGoldValue; AHigh: TGoldValue): TGoldValue;
    function RelativeDistanceBetwenValues(ALowValue: TGoldValue; AHighValue: TGoldValue): Double;
    function Parse(AInput: String): TGoldValue;
    function Parse(AInput: String; ACultureInvariant: Boolean; ADataError: TDataError): TGoldValue;
    function ByteLengthFromLogicalLength(ALogicalLength: Integer): Integer;
    function LogicalLengthFromByteLength(AByteLength: Integer): Integer;
    function Compare(AX: TGoldValue; AY: TGoldValue): Integer;
    function CreateForTextField(ANavFieldMetadata: INavFieldMetadata; ASortCulture: TCultureInfo; ADefaultStringCompareOptions: TCompareOptions; ACanBeOptimized: Boolean): TFilterExpressionContext;
    function CreateForNonTextField(ANavFieldMetadata: INavFieldMetadata): TFilterExpressionContext;
    function AreDiscreteValuesContiguous(ALowValue: TGoldValue; AHighValue: TGoldValue): Boolean;
    function Equals(AOther: TFilterExpressionContext): Boolean;
    function GetHashCode(): Integer;
    function ComputeHashCode(): Integer;
    function ValueToString(AValue: TGoldValue; AStringOptions: TFilterExpressionStringOptions): String;
    function QuoteLiteralIfNecessary(ALiteralValue: String; AStringOptions: TFilterExpressionStringOptions): String;
    function QuoteIfNecessary(ALiteralValue: String; ANeedsQuotingRegex: TRegex; AUseDoubleQuotesForQuoting: Boolean): String;
    function BuildRegexFromSubexpressions(AOptions: string[]): TRegex;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property SortCulture: TCultureInfo read GetSortCulture write SetSortCulture;
    property DefaultStringStringCompareOptions: TCompareOptions read GetDefaultStringStringCompareOptions write SetDefaultStringStringCompareOptions;
    property CanBeOptimized: Boolean read GetCanBeOptimized write SetCanBeOptimized;
    property Metadata: INavFieldMetadata read GetMetadata write SetMetadata;
    property CanCalculateMinMaxAndMid: Boolean read GetCanCalculateMinMaxAndMid write SetCanCalculateMinMaxAndMid;
    property IsDiscrete: Boolean read GetIsDiscrete write SetIsDiscrete;
    property MaxValue: TGoldValue read GetMaxValue write SetMaxValue;
    property MinValue: TGoldValue read GetMinValue write SetMinValue;
    property IsStringBased: Boolean read GetIsStringBased write SetIsStringBased;
    property SupportsWildcards: Boolean read GetSupportsWildcards write SetSupportsWildcards;
  end;


implementation

constructor TFilterExpressionContext.Create(ANavFieldMetadata: INavFieldMetadata; ASortCulture: TCultureInfo; ADefaultStringCompareOptions: TCompareOptions; ACanBeOptimized: Boolean);
begin
  inherited Create;
  if ANavFieldMetadata = null then
  begin
    raise TArgumentNullException.Create("ANavFieldMetadata");
  end
  ;
  Self.m_navFieldMetadata := ANavFieldMetadata;
  Self.m_sortCulture := ASortCulture;
  Self.m_defaultStringCompareOptions := ADefaultStringCompareOptions;
  Self.m_canBeOptimized := ACanBeOptimized;
  m_nclType := Self.m_navFieldMetadata.NclType;
  m_hashCode := ComputeHashCode();
end;

function TFilterExpressionContext.Midpoint(ALow: TGoldValue; AHigh: TGoldValue): TGoldValue;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpressionContext.RelativeDistanceBetwenValues(ALowValue: TGoldValue; AHighValue: TGoldValue): Double;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpressionContext.Parse(AInput: String): TGoldValue;
begin
  Result := TALSystemVariable.EvaluateIntoNavValue(TDataError.ThrowError, m_navFieldMetadata, AInput, 0);
end;

function TFilterExpressionContext.Parse(AInput: String; ACultureInvariant: Boolean; ADataError: TDataError): TGoldValue;
begin
  if ACultureInvariant and m_navFieldMetadata.NclType = TGoldNclType.GoldDate and AInput.StartsWith(TGoldSession.InvariantFormatSettings.ClosingDateCharacter, StringComparison.Ordinal) then
  begin
    date: TGoldDate := (TGoldDate)TALSystemVariable.EvaluateIntoNavValue(ADataError, m_navFieldMetadata, AInput.Substring(TGoldSession.InvariantFormatSettings.ClosingDateCharacter.Length), 9);
    Result := TALSystemDate.ALClosingDate(date);
  end
  ;
  Result := TALSystemVariable.EvaluateIntoNavValue(ADataError, m_navFieldMetadata, AInput, ACultureInvariant ? 9 : 0);
end;

function TFilterExpressionContext.ByteLengthFromLogicalLength(ALogicalLength: Integer): Integer;
begin
  if m_nclType <> TGoldNclType.GoldText and m_nclType <> TGoldNclType.GoldCode then
  begin
    Result := ALogicalLength;
  end
  ;
  Result := ALogicalLength * 2 + (m_nclType = TGoldNclType.GoldCode ? 1 : 0);
end;

function TFilterExpressionContext.LogicalLengthFromByteLength(AByteLength: Integer): Integer;
begin
  if m_nclType <> TGoldNclType.GoldText and m_nclType <> TGoldNclType.GoldCode then
  begin
    Result := AByteLength;
  end
  ;
  Result := AByteLength / 2;
end;

function TFilterExpressionContext.Compare(AX: TGoldValue; AY: TGoldValue): Integer;
begin
  if AX = null then
  begin
    raise TArgumentNullException.Create("AX");
  end
  ;
  if AY = null then
  begin
    raise TArgumentNullException.Create("AY");
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpressionContext.CreateForTextField(ANavFieldMetadata: INavFieldMetadata; ASortCulture: TCultureInfo; ADefaultStringCompareOptions: TCompareOptions; ACanBeOptimized: Boolean): TFilterExpressionContext;
begin
  if ASortCulture = null then
  begin
    raise TArgumentNullException.Create("ASortCulture");
  end
  ;
  Result := TFilterExpressionContext.Create(ANavFieldMetadata, ASortCulture, ADefaultStringCompareOptions, ACanBeOptimized);
end;

function TFilterExpressionContext.CreateForNonTextField(ANavFieldMetadata: INavFieldMetadata): TFilterExpressionContext;
begin
  Result := TFilterExpressionContext.Create(ANavFieldMetadata, CultureInfo.InvariantCulture, CompareOptions.None, ACanBeOptimized: true);
end;

function TFilterExpressionContext.AreDiscreteValuesContiguous(ALowValue: TGoldValue; AHighValue: TGoldValue): Boolean;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpressionContext.Equals(AOther: TFilterExpressionContext): Boolean;
begin
  if AOther <> null then
  begin
    if this <> AOther then
    begin
      if m_hashCode = AOther.m_hashCode and m_nclType = AOther.m_nclType and m_navFieldMetadata.Equals(AOther.m_navFieldMetadata) and Equals(m_sortCulture, AOther.m_sortCulture) then
      begin
        Result := m_defaultStringCompareOptions = AOther.m_defaultStringCompareOptions;
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

function TFilterExpressionContext.GetHashCode(): Integer;
begin
  Result := m_hashCode;
end;

function TFilterExpressionContext.ComputeHashCode(): Integer;
begin
  if m_sortCulture = null then
  begin
    Result := m_navFieldMetadata.GetHashCode();
  end
  ;
  Result := THashCodeHelper.CombineHashCodes(m_navFieldMetadata.GetHashCode(), m_sortCulture.GetHashCode(), m_defaultStringCompareOptions.GetHashCode());
end;

function TFilterExpressionContext.ValueToString(AValue: TGoldValue; AStringOptions: TFilterExpressionStringOptions): String;
begin
  flag: Boolean := (AStringOptions & TFilterExpressionStringOptions.FormatCultureInvariant) <> 0;
  if m_nclType = TGoldNclType.GoldDateTime or m_nclType = TGoldNclType.GoldTime then
  begin
    dateTime: TDateTime := AValue.ToDateTime();
    if dateTime.Second <> 0 or dateTime.Millisecond <> 0 then
    begin
      Result := TGoldFormatEvaluateHelper.Format(AValue, 0, not flag ? 1 : 9);
    end
    ;
  end
  else
  begin
    if m_nclType = TGoldNclType.GoldDate and flag then
    begin
      dateTime2: TDateTime := AValue.ToDateTime();
      if dateTime2 <> TGoldDateTimeHelper.m_DateTimeUndefined and TGoldDate.IsClosingDate(dateTime2) then
      begin
        Result := TGoldSession.InvariantFormatSettings.ClosingDateCharacter + AValue.ToString(invariant: true);
      end
      ;
    end
    else
    begin
      if m_nclType = TGoldNclType.GoldBoolean and (AStringOptions & TFilterExpressionStringOptions.OptionsAsIntegers) <> 0 then
      begin
        Result := AValue.ToInt32().ToString(CultureInfo.InvariantCulture);
      end
      ;
    end;
  end;
  Result := AValue.ToString(flag);
end;

function TFilterExpressionContext.QuoteLiteralIfNecessary(ALiteralValue: String; AStringOptions: TFilterExpressionStringOptions): String;
begin
  useDoubleQuotesForQuoting: Boolean := false;
  needsQuotingRegex: TRegex;
  if Metadata.NclType = TGoldNclType.GoldBlob then
  begin
    needsQuotingRegex := m_BlobNeedsQuotingRegex;
  end
  else
  begin
    if (AStringOptions & TFilterExpressionStringOptions.ConstExpressionImplied) <> TFilterExpressionStringOptions.ConstExpressionImplied then
    begin
      needsQuotingRegex := (if not IsStringBased then m_NonTextLiteralNeedsQuotingRegex else (if (AStringOptions & TFilterExpressionStringOptions.DoNotQuoteWildcards) <> TFilterExpressionStringOptions.DoNotQuoteWildcards then m_TextLiteralNeedsQuotingRegex else m_TextWildcardNeedsQuotingRegex));
    end
    else
    begin
      needsQuotingRegex := m_OnlyQuoteCloseParenthesisRegex;
      useDoubleQuotesForQuoting := true;
    end;
  end;
  Result := QuoteIfNecessary(ALiteralValue, needsQuotingRegex, useDoubleQuotesForQuoting);
end;

function TFilterExpressionContext.QuoteIfNecessary(ALiteralValue: String; ANeedsQuotingRegex: TRegex; AUseDoubleQuotesForQuoting: Boolean): String;
begin
  if not ANeedsQuotingRegex.IsMatch(ALiteralValue) then
  begin
    Result := ALiteralValue;
  end
  ;
  if AUseDoubleQuotesForQuoting then
  begin
    Result := TStringBuilder.Create().Append('"').Append(ALiteralValue).Replace("\"", "\"\"", 1, ALiteralValue.Length)
                    .Append('"')
                    .ToString();
  end
  ;
  Result := TStringBuilder.Create().Append('\'').Append(ALiteralValue).Replace("'", "''", 1, ALiteralValue.Length)
                .Append('\'')
                .ToString();
end;

function TFilterExpressionContext.BuildRegexFromSubexpressions(AOptions: string[]): TRegex;
begin
  Result := TRegex.Create(string.Join("|", AOptions), RegexOptions.Compiled | RegexOptions.CultureInvariant);
end;


end.
