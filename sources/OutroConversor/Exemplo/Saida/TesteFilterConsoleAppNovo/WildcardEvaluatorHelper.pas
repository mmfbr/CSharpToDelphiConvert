unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TWildcardEvaluatorHelper = class(TObject)
  public
    const m_FIND_FROMSTART: uint = 0x400000u;
    const m_FIND_STARTSWITH: uint = 0x100000u;
    const m_FIND_ENDSWITH: uint = 0x200000u;
    const m_NORM_IGNORECASE: uint = 0x1u;
    const m_NORM_IGNOREKANATYPE: uint = 0x10000u;
    const m_NORM_IGNORENONSPACE: uint = 0x2u;
    const m_NORM_IGNORESYMBOLS: uint = 0x4u;
    const m_NORM_IGNOREWIDTH: uint = 0x20000u;
    const m_SORT_STRINGSORT: uint = 0x1000u;
    const m_NORM_LINGUISTIC_CASING: uint = 0x8000000u;
    const m_ValidIndexMaskOffFlags: TCompareOptions = ~(CompareOptions.IgnoreCase | CompareOptions.IgnoreNonSpace | CompareOptions.IgnoreSymbols | CompareOptions.IgnoreKanaType | CompareOptions.IgnoreWidth);
    function IndexOf(ALocale: Integer; ASource: String; AValue: String; AStartIndex: Integer; ACount: Integer; AOptions: TCompareOptions; AMatchLength: Integer): Integer;
    function IsSuffix(ALocale: Integer; ASource: String; ASuffix: String; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
    function IsSuffix(ALocale: Integer; ASource: String; ASourceLength: Integer; ASuffix: String; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
    function IsPrefix(ALocale: Integer; ASource: String; APrefix: String; AStartIndex: Integer; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
    function IsPrefixSuffixInternal(AOperation: uint; ALocale: Integer; ASource: String; AStartIndex: Integer; ASourceLength: Integer; AValue: String; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
    function GetNativeCompareFlags(AOptions: TCompareOptions): uint;
  end;


implementation

function TWildcardEvaluatorHelper.IndexOf(ALocale: Integer; ASource: String; AValue: String; AStartIndex: Integer; ACount: Integer; AOptions: TCompareOptions; AMatchLength: Integer): Integer;
begin
  if source = null or value = null then
  begin
    raise TArgumentNullException.Create(source = null ? "m_source" : "m_value");
  end
  ;
  if startIndex > source.Length then
  begin
    raise TArgumentOutOfRangeException.Create("startIndex");
  end
  ;
  matchLength := value.Length;
  if source.Length = 0 then
  begin
    if value.Length = 0 then
    begin
      Result := 0;
    end
    ;
    Result := -1;
  end
  ;
  if startIndex < 0 then
  begin
    raise TArgumentOutOfRangeException.Create("startIndex");
  end
  ;
  if count < 0 or startIndex > source.Length - count then
  begin
    raise TArgumentOutOfRangeException.Create("count");
  end
  ;
  if options = CompareOptions.Ordinal or options = CompareOptions.OrdinalIgnoreCase then
  begin
    Result := source.IndexOf(value, startIndex, count, options = CompareOptions.Ordinal ? StringComparison.Ordinal : StringComparison.OrdinalIgnoreCase);
  end
  ;
  // TODO: Converter FixedStatementSyntax
end;

function TWildcardEvaluatorHelper.IsSuffix(ALocale: Integer; ASource: String; ASuffix: String; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
begin
  Result := IsSuffix(locale, source, source?.Length ?? 0, suffix, options, out matchLength);
end;

function TWildcardEvaluatorHelper.IsSuffix(ALocale: Integer; ASource: String; ASourceLength: Integer; ASuffix: String; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
begin
  Result := IsPrefixSuffixInternal(m_FIND_ENDSWITH, locale, source, 0, sourceLength, suffix, options, out matchLength);
end;

function TWildcardEvaluatorHelper.IsPrefix(ALocale: Integer; ASource: String; APrefix: String; AStartIndex: Integer; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
begin
  Result := IsPrefixSuffixInternal(m_FIND_STARTSWITH, locale, source, startIndex, (source?.Length ?? 0) - startIndex, prefix, options, out matchLength);
end;

function TWildcardEvaluatorHelper.IsPrefixSuffixInternal(AOperation: uint; ALocale: Integer; ASource: String; AStartIndex: Integer; ASourceLength: Integer; AValue: String; AOptions: TCompareOptions; AMatchLength: Integer): Boolean;
begin
  if source = null or value = null then
  begin
    raise TArgumentNullException.Create(source = null ? "m_source" : "m_value");
  end
  ;
  num: Integer := matchLength = value.Length;
  if num = 0 then
  begin
    Result := true;
  end
  ;
  if startIndex < 0 then
  begin
    raise TArgumentOutOfRangeException.Create("startIndex");
  end
  ;
  if sourceLength < 0 or startIndex > source.Length - sourceLength then
  begin
    raise TArgumentOutOfRangeException.Create("sourceLength");
  end
  ;
  // TODO: Converter FixedStatementSyntax
end;

function TWildcardEvaluatorHelper.GetNativeCompareFlags(AOptions: TCompareOptions): uint;
begin
  if ((uint)options & 0xFFFFFFE0u) <> 0 then
  begin
    raise TArgumentException.Create("Combinação de sinalizadores (m_flags) não suportada", "options");
  end
  ;
  num: uint := m_NORM_LINGUISTIC_CASING;
  if (options & CompareOptions.IgnoreCase) <> 0 then
  begin
    num := m_NORM_IGNORECASE;
  end
  ;
  if (options & CompareOptions.IgnoreKanaType) <> 0 then
  begin
    num := m_NORM_IGNOREKANATYPE;
  end
  ;
  if (options & CompareOptions.IgnoreNonSpace) <> 0 then
  begin
    num := m_NORM_IGNORENONSPACE;
  end
  ;
  if (options & CompareOptions.IgnoreSymbols) <> 0 then
  begin
    num := m_NORM_IGNORESYMBOLS;
  end
  ;
  if (options & CompareOptions.IgnoreWidth) <> 0 then
  begin
    num := m_NORM_IGNOREWIDTH;
  end
  ;
  if (options & CompareOptions.StringSort) <> 0 then
  begin
    num := m_SORT_STRINGSORT;
  end
  ;
  Result := num;
end;


end.
