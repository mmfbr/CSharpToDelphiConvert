unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TRange = class(IEquatable<TRange>)
  private
    m_emptyRange: TRange;
    m_fullRange: TRange;
    m_flags: TRangeFlags;
    m_highValue: TGoldValue;
    m_lowValue: TGoldValue;
    m_expressionContext: TFilterExpressionContext;
  public
    constructor Create(AFlags: TRangeFlags);
    constructor Create(ALowSource: TRange; AHighSource: TRange);
    constructor Create(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext);
    constructor Create(ALowValue: TGoldValue; AHighValue: TGoldValue; AFlags: TRangeFlags; AExpressionContext: TFilterExpressionContext);
    function CreateFromMinimum(AHighValue: TGoldValue; AHighIsInclusive: Boolean; AExpressionContext: TFilterExpressionContext): TRange;
    function CreateToMaximum(ALowValue: TGoldValue; ALowIsInclusive: Boolean; AExpressionContext: TFilterExpressionContext): TRange;
    function Create(ALowValue: TGoldValue; ALowIsInclusive: Boolean; AHighValue: TGoldValue; AHighIsInclusive: Boolean; AExpressionContext: TFilterExpressionContext): TRange;
    function CreateForSingleValue(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRange;
    function CreateFull(): TRange;
    function Create(ALowSource: TRange; AHighSource: TRange): TRange;
    function CompareForIntersection(AOther: TRange): TRangeComparison;
    function CompareForUnion(AOther: TRange): TRangeComparison;
    function Compare(AOther: TRange; attemptToCombineContiguousRanges: Boolean): TRangeComparison;
    function CompareHighEnds(AOther: TRange): Integer;
    function AreHighEndsContiguouslyEquivaluent(AGreater: TRange; ALesser: TRange; AExpressionContext: TFilterExpressionContext): Boolean;
    function CompareLowEnds(AOther: TRange): Integer;
    function CompareHighAndLow(AHighSource: TRange; ALowSource: TRange; attemptToCombine: Boolean): Integer;
    function ValidateAndGetExpressionContext(ARange1: TRange; ARange2: TRange): TFilterExpressionContext;
    function Equals(AOther: TRange): Boolean;
    function ToString(): String;
    property EmptyRange: TRange read GetEmptyRange write SetEmptyRange;
    property FullRange: TRange read GetFullRange write SetFullRange;
    property LowValue: TGoldValue read GetLowValue write SetLowValue;
    property HighValue: TGoldValue read GetHighValue write SetHighValue;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
    property IsEmptyRange: Boolean read GetIsEmptyRange write SetIsEmptyRange;
    property IsFullRange: Boolean read GetIsFullRange write SetIsFullRange;
    property IsLowIsMinimum: Boolean read GetIsLowIsMinimum write SetIsLowIsMinimum;
    property IsLowDefined: Boolean read GetIsLowDefined write SetIsLowDefined;
    property IsLowIncluded: Boolean read GetIsLowIncluded write SetIsLowIncluded;
    property IsLowExcluded: Boolean read GetIsLowExcluded write SetIsLowExcluded;
    property IsHighMaximum: Boolean read GetIsHighMaximum write SetIsHighMaximum;
    property IsHighDefined: Boolean read GetIsHighDefined write SetIsHighDefined;
    property IsHighIncluded: Boolean read GetIsHighIncluded write SetIsHighIncluded;
    property IsHighExcluded: Boolean read GetIsHighExcluded write SetIsHighExcluded;
  end;


implementation

constructor TRange.Create(AFlags: TRangeFlags);
begin
  inherited Create;
  Self.m_flags := flags;
  if IsEmptyRange then
  begin
    Self.m_flags := TRangeFlags.EmptyRange;
  end
  else
  begin
    if IsLowIsMinimum then
    begin
      if IsHighMaximum then
      begin
        Self.m_flags := TRangeFlags.FullRange;
      end
      else
      begin
        Self.m_flags := TRangeFlags.LowIsIncluded;
      end;
    end
    else
    begin
      if IsHighMaximum then
      begin
        Self.m_flags := TRangeFlags.HighIsIncluded;
      end
      ;
    end;
  end;
end;

constructor TRange.Create(ALowSource: TRange; AHighSource: TRange);
begin
  inherited Create;
  if lowSource.IsEmptyRange or highSource.IsEmptyRange then
  begin
    m_flags := EmptyRange.m_flags;
    Exit;
  end
  ;
  if lowSource.IsLowIsMinimum and highSource.IsHighMaximum then
  begin
    m_flags := FullRange.m_flags;
    Exit;
  end
  ;
  m_expressionContext := ValidateAndGetExpressionContext(lowSource, highSource);
  if lowSource.IsLowDefined then
  begin
    m_lowValue := lowSource.LowValue;
  end
  ;
  if highSource.IsHighDefined then
  begin
    m_highValue := highSource.HighValue;
  end
  ;
  m_flags := lowSource.m_flags & (TRangeFlags.LowIsMinimum | TRangeFlags.LowIsIncluded) | highSource.m_flags & (TRangeFlags.HighIsMaximum | TRangeFlags.HighIsIncluded);
end;

constructor TRange.Create(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext);
begin
  inherited Create;
  m_lowValue := value;
  m_highValue := value;
  m_flags := TRangeFlags.LowIsIncluded | TRangeFlags.HighIsIncluded;
  Self.m_expressionContext := expressionContext;
end;

constructor TRange.Create(ALowValue: TGoldValue; AHighValue: TGoldValue; AFlags: TRangeFlags; AExpressionContext: TFilterExpressionContext);
begin
  inherited Create;
  Self.m_lowValue := lowValue;
  Self.m_highValue := highValue;
  Self.m_expressionContext := expressionContext;
end;

function TRange.CreateFromMinimum(AHighValue: TGoldValue; AHighIsInclusive: Boolean; AExpressionContext: TFilterExpressionContext): TRange;
begin
  Result := TRange.Create(null, highValue, TRangeFlags.LowIsMinimum | (highIsInclusive ? TRangeFlags.HighIsIncluded : 0), expressionContext);
end;

function TRange.CreateToMaximum(ALowValue: TGoldValue; ALowIsInclusive: Boolean; AExpressionContext: TFilterExpressionContext): TRange;
begin
  Result := TRange.Create(lowValue, null, TRangeFlags.HighIsMaximum | (lowIsInclusive ? TRangeFlags.LowIsIncluded : 0), expressionContext);
end;

function TRange.Create(ALowValue: TGoldValue; ALowIsInclusive: Boolean; AHighValue: TGoldValue; AHighIsInclusive: Boolean; AExpressionContext: TFilterExpressionContext): TRange;
begin
  Result := TRange.Create(lowValue, highValue, (lowIsInclusive ? TRangeFlags.LowIsIncluded : 0) | (highIsInclusive ? TRangeFlags.HighIsIncluded : 0), expressionContext);
end;

function TRange.CreateForSingleValue(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRange;
begin
  Result := TRange.Create(value, expressionContext);
end;

function TRange.CreateFull(): TRange;
begin
  Result := FullRange;
end;

function TRange.Create(ALowSource: TRange; AHighSource: TRange): TRange;
begin
  Result := TRange.Create(lowSource, highSource);
end;

function TRange.CompareForIntersection(AOther: TRange): TRangeComparison;
begin
  Result := Compare(other, attemptToCombineContiguousRanges: false);
end;

function TRange.CompareForUnion(AOther: TRange): TRangeComparison;
begin
  Result := Compare(other, attemptToCombineContiguousRanges: true);
end;

function TRange.Compare(AOther: TRange; attemptToCombineContiguousRanges: Boolean): TRangeComparison;
begin
  if IsFullRange then
  begin
    if not other.IsFullRange then
    begin
      Result := TRangeComparison.Subset;
    end
    ;
    Result := TRangeComparison.SubsetEndsEqual;
  end
  ;
  if other.IsFullRange then
  begin
    Result := TRangeComparison.Superset;
  end
  ;
  num: Integer := CompareLowEnds(other);
  num2: Integer := CompareHighEnds(other);
  if num > 0 then
  begin
    if num2 > 0 then
    begin
      if CompareHighAndLow(other, this, attemptToCombineContiguousRanges) < 0 then
      begin
        Result := TRangeComparison.DisjointLower;
      end
      ;
      Result := TRangeComparison.BeginsLower;
    end
    ;
    if num2 < 0 then
    begin
      if attemptToCombineContiguousRanges and AreHighEndsContiguouslyEquivaluent(other, this, m_expressionContext) then
      begin
        Result := TRangeComparison.BeginsLowerEndsEqual;
      end
      ;
      Result := TRangeComparison.Superset;
    end
    ;
    if num2 = 0 then
    begin
      Result := TRangeComparison.BeginsLowerEndsEqual;
    end
    ;
  end
  ;
  if num2 > 0 then
  begin
    if attemptToCombineContiguousRanges and AreHighEndsContiguouslyEquivaluent(this, other, m_expressionContext) then
    begin
      Result := TRangeComparison.SubsetEndsEqual;
    end
    ;
    Result := TRangeComparison.Subset;
  end
  ;
  if num2 = 0 then
  begin
    Result := TRangeComparison.SubsetEndsEqual;
  end
  ;
  if CompareHighAndLow(this, other, attemptToCombineContiguousRanges) < 0 then
  begin
    Result := TRangeComparison.DisjointHigher;
  end
  ;
  if AreHighEndsContiguouslyEquivaluent(other, this, m_expressionContext) then
  begin
    Result := TRangeComparison.SubsetEndsEqual;
  end
  ;
  Result := TRangeComparison.EndsHigher;
end;

function TRange.CompareHighEnds(AOther: TRange): Integer;
begin
  if IsHighMaximum then
  begin
    if not other.IsHighMaximum then
    begin
      Result := 1;
    end
    ;
    Result := 0;
  end
  ;
  if other.IsHighMaximum then
  begin
    Result := -1;
  end
  ;
  num: Integer := m_expressionContext.Compare(m_highValue, other.m_highValue);
  if num = 0 then
  begin
    if IsHighIncluded and other.IsHighExcluded then
    begin
      num := 1;
    end
    ;
    if IsHighExcluded and other.IsHighIncluded then
    begin
      num := -1;
    end
    ;
  end
  ;
  Result := num;
end;

function TRange.AreHighEndsContiguouslyEquivaluent(AGreater: TRange; ALesser: TRange; AExpressionContext: TFilterExpressionContext): Boolean;
begin
  if expressionContext.IsDiscrete and not greater.IsHighMaximum and greater.IsHighExcluded and lesser.IsHighIncluded then
  begin
    Result := TFilterExpressionContext.AreDiscreteValuesContiguous(lesser.m_highValue, greater.m_highValue);
  end
  ;
  Result := false;
end;

function TRange.CompareLowEnds(AOther: TRange): Integer;
begin
  if IsLowIsMinimum then
  begin
    if not other.IsLowIsMinimum then
    begin
      Result := -1;
    end
    ;
    Result := 0;
  end
  ;
  if other.IsLowIsMinimum then
  begin
    Result := 1;
  end
  ;
  num: Integer := m_expressionContext.Compare(m_lowValue, other.m_lowValue);
  if num = 0 then
  begin
    if IsLowExcluded and other.IsLowIncluded then
    begin
      Result := 1;
    end
    ;
    if IsLowIncluded and other.IsLowExcluded then
    begin
      Result := -1;
    end
    ;
  end
  ;
  Result := num;
end;

function TRange.CompareHighAndLow(AHighSource: TRange; ALowSource: TRange; attemptToCombine: Boolean): Integer;
begin
  if highSource.IsHighMaximum or lowSource.IsLowIsMinimum then
  begin
    Result := 1;
  end
  ;
  filterExpressionContext: TFilterExpressionContext := highSource.m_expressionContext;
  num: Integer := filterExpressionContext.Compare(highSource.m_highValue, lowSource.m_lowValue);
  if num = 0 then
  begin
    if lowSource.IsLowIncluded and highSource.IsHighIncluded then
    begin
      Result := 0;
    end
    ;
    if not attemptToCombine or lowSource.IsLowExcluded and highSource.IsHighExcluded then
    begin
      Result := -1;
    end
    ;
    Result := 0;
  end
  ;
  if not filterExpressionContext.IsDiscrete then
  begin
    Result := num;
  end
  ;
  if num > 0 then
  begin
    if highSource.IsHighExcluded and lowSource.IsLowExcluded and TFilterExpressionContext.AreDiscreteValuesContiguous(lowSource.m_lowValue, highSource.m_highValue) then
    begin
      Result := -1;
    end
    ;
  end
  else
  begin
    if attemptToCombine and lowSource.IsLowIncluded and highSource.IsHighIncluded and TFilterExpressionContext.AreDiscreteValuesContiguous(highSource.m_highValue, lowSource.m_lowValue) then
    begin
      Result := 0;
    end
    ;
  end;
  Result := num;
end;

function TRange.ValidateAndGetExpressionContext(ARange1: TRange; ARange2: TRange): TFilterExpressionContext;
begin
  if range1.m_expressionContext = null or range2.m_expressionContext = null or not range1.m_expressionContext.Equals(range2.m_expressionContext) then
  begin
    raise TNotSupportedException.Create("Não é possível comparar intervalos de diferentes contextos de expressão.");
  end
  ;
  Result := range1.m_expressionContext;
end;

function TRange.Equals(AOther: TRange): Boolean;
begin
  if this <> other then
  begin
    if other <> null and other.m_flags = m_flags and Equals(m_lowValue, other.m_lowValue) and Equals(m_highValue, other.m_highValue) then
    begin
      Result := Equals(m_expressionContext, other.m_expressionContext);
    end
    ;
    Result := false;
  end
  ;
  Result := true;
end;

function TRange.ToString(): String;
begin
  Result := (IsLowIncluded ? '[' : '(') + (IsLowIsMinimum ? "" : ExpressionContext.QuoteLiteralIfNecessary(m_lowValue.ToString())) + ", " + (IsHighMaximum ? "" : ExpressionContext.QuoteLiteralIfNecessary(m_highValue.ToString())) + (IsHighIncluded ? ']' : ')');
end;


end.
