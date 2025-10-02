unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TRangeListExpressionBuilder = class(TObject)
  public
    function BuildExpression(ARangeList: TRangeList; AOptimizeForEvaluation: Boolean): TFilterExpression;
    function BuildSimpleExpression(ARangeList: TRangeList): TFilterExpression;
    function GroupByNotEqualChain(ARanges: IEnumerable<TRange>): IEnumerable<IList<TRange>>;
    function NotEqualChainToExpression(ANotEqualChain: IList<TRange>): TFilterExpression;
    function BuildSearchExpression(ARangeList: TRangeList; AExpressionContext: TFilterExpressionContext): TFilterExpression;
    function ComputeBalancedSearchExpression(ARanges: TList<TRange>; AMinValue: TGoldValue; AMaxValue: TGoldValue; ABoundaryAlreadyChecked: TBoundaryAlreadyChecked): TFilterExpression;
    function CallComputeBalancedSearchOnPartition(ARanges: TList<TRange>; ALeftPartition: Boolean; AIsPartinioningOnNotEqual: Boolean; AMinValue: TGoldValue; AMaxValue: TGoldValue; ABoundaryAlreadyChecked: TBoundaryAlreadyChecked): TFilterExpression;
    function IsNotEqualPattern(AHighSource: TRange; ALowSource: TRange): Boolean;
    function RelativeSizeOfRangeList(ARanges: IEnumerable<TRange>): Double;
    function ValueIsInOrGreaterThanRange(ARange: TRange; AValue: TGoldValue): Boolean;
    function Partition(ASource: IEnumerable<T>; ANotMatched: TList<T>; APredicate: TFunc<T, bool>): TList<T>;
    function ToHighFilter(ARange: TRange): TFilterExpression;
    function ToLowFilter(ARange: TRange): TFilterExpression;
    function IsSingleValue(ARange: TRange): Boolean;
  end;


implementation

function TRangeListExpressionBuilder.BuildExpression(ARangeList: TRangeList; AOptimizeForEvaluation: Boolean): TFilterExpression;
begin
  ranges: TReadOnlyCollection<TRange> := rangeList.Ranges;
  if ranges.Count = 0 then
  begin
    Result := TFilterExpression.BooleanConstant(AValue: false);
  end
  ;
  if ranges[0].IsFullRange then
  begin
    Result := TFilterExpression.BooleanConstant(AValue: true);
  end
  ;
  expressionContext: TFilterExpressionContext := ranges[0].ExpressionContext;
  if not optimizeForEvaluation or not expressionContext.CanCalculateMinMaxAndMid then
  begin
    Result := BuildSimpleExpression(rangeList);
  end
  ;
  Result := BuildSearchExpression(rangeList, expressionContext);
end;

function TRangeListExpressionBuilder.BuildSimpleExpression(ARangeList: TRangeList): TFilterExpression;
begin
  source: IEnumerable<IList<TRange>> := GroupByNotEqualChain(rangeList.Ranges);
  Result := TFilterExpression.BalancedOr(source.Select(NotEqualChainToExpression));
end;

function TRangeListExpressionBuilder.GroupByNotEqualChain(ARanges: IEnumerable<TRange>): IEnumerable<IList<TRange>>;
begin
  list: TList<TRange> := TList<TRange>.Create;
  for range in ranges do
  begin
    if list.Count = 0 then
    begin
      list.Add(range);
      // TODO: Converter ContinueStatementSyntax
    end
    ;
    highSource: TRange := list[list.Count - 1];
    if IsNotEqualPattern(highSource, range) then
    begin
      list.Add(range);
      // TODO: Converter ContinueStatementSyntax
    end
    ;
    // TODO: Converter YieldStatementSyntax
    list := new List<TRange> { range };
  end;
  if list.Count <> 0 then
  begin
    // TODO: Converter YieldStatementSyntax
  end
  ;
end;

function TRangeListExpressionBuilder.NotEqualChainToExpression(ANotEqualChain: IList<TRange>): TFilterExpression;
begin
  if notEqualChain.Count = 1 then
  begin
    Result := notEqualChain[0].ToFilterExpression();
  end
  ;
  range: TRange := TRange.Create(notEqualChain[0], notEqualChain[notEqualChain.Count - 1]);
  filterExpression: TFilterExpression := TFilterExpression.BalancedAnd(from r in notEqualChain.Take(notEqualChain.Count - 1)
                                                                             select TFilterExpression.NotEqual(r.HighValue, r.ExpressionContext));
  if not range.IsFullRange then
  begin
    Result := TFilterExpression.And(range.ToFilterExpression(), filterExpression);
  end
  ;
  Result := filterExpression;
end;

function TRangeListExpressionBuilder.BuildSearchExpression(ARangeList: TRangeList; AExpressionContext: TFilterExpressionContext): TFilterExpression;
begin
  filterExpression: TFilterExpression := ComputeBalancedSearchExpression(rangeList.Ranges.ToList(), expressionContext.MinValue, expressionContext.MaxValue, TBoundaryAlreadyChecked.None);
  Result := filterExpression.Visit(TBasicSimplifyingVisitor.m_Instance);
end;

function TRangeListExpressionBuilder.ComputeBalancedSearchExpression(ARanges: TList<TRange>; AMinValue: TGoldValue; AMaxValue: TGoldValue; ABoundaryAlreadyChecked: TBoundaryAlreadyChecked): TFilterExpression;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TRangeListExpressionBuilder.CallComputeBalancedSearchOnPartition(ARanges: TList<TRange>; ALeftPartition: Boolean; AIsPartinioningOnNotEqual: Boolean; AMinValue: TGoldValue; AMaxValue: TGoldValue; ABoundaryAlreadyChecked: TBoundaryAlreadyChecked): TFilterExpression;
begin
  flag: Boolean;
  boundaryAlreadyChecked2: TBoundaryAlreadyChecked;
  left: TFilterExpression;
  minValue2: TGoldValue;
  maxValue2: TGoldValue;
  if leftPartition then
  begin
    range: TRange := ranges.Last();
    flag := isPartinioningOnNotEqual or range.IsSingleValue();
    boundaryAlreadyChecked2 := (if flag then boundaryAlreadyChecked & ~TBoundaryAlreadyChecked.High else boundaryAlreadyChecked | TBoundaryAlreadyChecked.High);
    left := range.ToHighFilter();
    minValue2 := minValue;
    maxValue2 := range.HighValue;
  end
  else
  begin
    range: TRange := ranges[0];
    flag := isPartinioningOnNotEqual or range.IsSingleValue();
    boundaryAlreadyChecked2 := (if flag then boundaryAlreadyChecked & ~TBoundaryAlreadyChecked.Low else boundaryAlreadyChecked | TBoundaryAlreadyChecked.Low);
    left := range.ToLowFilter();
    minValue2 := range.LowValue;
    maxValue2 := maxValue;
  end;
  filterExpression: TFilterExpression := ComputeBalancedSearchExpression(ranges, minValue2, maxValue2, boundaryAlreadyChecked2);
  if flag then
  begin
    Result := filterExpression;
  end
  ;
  Result := TFilterExpression.And(left, filterExpression);
end;

function TRangeListExpressionBuilder.IsNotEqualPattern(AHighSource: TRange; ALowSource: TRange): Boolean;
begin
  if not highSource.IsHighMaximum and not lowSource.IsLowIsMinimum and highSource.IsHighExcluded and lowSource.IsLowExcluded then
  begin
    Result := highSource.ExpressionContext.Compare(highSource.HighValue, lowSource.LowValue) = 0;
  end
  ;
  Result := false;
end;

function TRangeListExpressionBuilder.RelativeSizeOfRangeList(ARanges: IEnumerable<TRange>): Double;
begin
  Result := ranges.Sum((r) => TFilterExpressionContext.RelativeDistanceBetwenValues(r.IsLowIsMinimum ? r.ExpressionContext.MinValue : r.LowValue, r.IsHighMaximum ? r.ExpressionContext.MaxValue : r.HighValue));
end;

function TRangeListExpressionBuilder.ValueIsInOrGreaterThanRange(ARange: TRange; AValue: TGoldValue): Boolean;
begin
  if range.IsLowIsMinimum then
  begin
    Result := true;
  end
  ;
  num: Integer := range.ExpressionContext.Compare(range.LowValue, value);
  if num >= 0 then
  begin
    if num = 0 then
    begin
      Result := range.IsLowIncluded;
    end
    ;
    Result := false;
  end
  ;
  Result := true;
end;

function TRangeListExpressionBuilder.Partition(ASource: IEnumerable<T>; ANotMatched: TList<T>; APredicate: TFunc<T, bool>): TList<T>;
begin
  list: TList<T> := TList<T>.Create;
  list2: TList<T> := TList<T>.Create;
  for item in source do
  begin
    if predicate(item) then
    begin
      list.Add(item);
    end
    else
    begin
      list2.Add(item);
    end;
  end;
  notMatched := list2;
  Result := list;
end;

function TRangeListExpressionBuilder.ToHighFilter(ARange: TRange): TFilterExpression;
begin
  if not range.IsHighMaximum then
  begin
    if not range.IsHighIncluded then
    begin
      Result := TFilterExpression.LessThan(range.HighValue, range.ExpressionContext);
    end
    ;
    Result := TFilterExpression.LessThanOrEqual(range.HighValue, range.ExpressionContext);
  end
  ;
  Result := null;
end;

function TRangeListExpressionBuilder.ToLowFilter(ARange: TRange): TFilterExpression;
begin
  if not range.IsLowIsMinimum then
  begin
    if not range.IsLowIncluded then
    begin
      Result := TFilterExpression.GreaterThan(range.LowValue, range.ExpressionContext);
    end
    ;
    Result := TFilterExpression.GreaterThanOrEqual(range.LowValue, range.ExpressionContext);
  end
  ;
  Result := null;
end;

function TRangeListExpressionBuilder.IsSingleValue(ARange: TRange): Boolean;
begin
  if not range.IsLowIsMinimum and not range.IsHighMaximum and range.IsLowIncluded and range.IsHighIncluded then
  begin
    Result := range.ExpressionContext.Compare(range.LowValue, range.HighValue) = 0;
  end
  ;
  Result := false;
end;


end.
