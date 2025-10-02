unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TRangeList = class(IEquatable<TRangeList>)
  private
    m_empty: TRangeList;
    m_full: TRangeList;
    m_ranges: TList<TRange>;
  public
    constructor Create(AFirstRange: TRange);
    constructor Create(AFirstRange: TRange; ASecondRange: TRange);
    constructor Create();
    constructor Create(ARanges: TList<TRange>);
    function Create(ASingleRange: TRange): TRangeList;
    function CreateForEverythingExceptASingleValue(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeList;
    function CreateFull(): TRangeList;
    function CreateEmpty(): TRangeList;
    function Union(ARangeList1: TRangeList; ARangeList2: TRangeList): TRangeList;
    function Union(ARangeList1: TRangeList; ARangeList2: TRangeList; AOther: TRangeList[]): TRangeList;
    function Intersect(ARangeList1: TRangeList; ARangeList2: TRangeList): TRangeList;
    function Equals(AOther: TRangeList): Boolean;
    function ToString(): String;
    property Ranges: TReadOnlyCollection<TRange> read GetRanges write SetRanges;
    property IsEmpty: Boolean read GetIsEmpty write SetIsEmpty;
    property IsFull: Boolean read GetIsFull write SetIsFull;
  end;


implementation

constructor TRangeList.Create(AFirstRange: TRange);
begin
  inherited Create;
  m_ranges.Add(firstRange);
end;

constructor TRangeList.Create(AFirstRange: TRange; ASecondRange: TRange);
begin
  inherited Create;
  m_ranges.Add(firstRange);
  m_ranges.Add(secondRange);
end;

constructor TRangeList.Create();
begin
  inherited Create;
end;

constructor TRangeList.Create(ARanges: TList<TRange>);
begin
  inherited Create;
  Self.m_ranges := ranges;
end;

function TRangeList.Create(ASingleRange: TRange): TRangeList;
begin
  Result := TRangeList.Create(singleRange);
end;

function TRangeList.CreateForEverythingExceptASingleValue(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeList;
begin
  Result := TRangeList.Create(TRange.CreateFromMinimum(value, highIsInclusive: false, expressionContext), TRange.CreateToMaximum(value, lowIsInclusive: false, expressionContext));
end;

function TRangeList.CreateFull(): TRangeList;
begin
  Result := m_full;
end;

function TRangeList.CreateEmpty(): TRangeList;
begin
  Result := m_empty;
end;

function TRangeList.Union(ARangeList1: TRangeList; ARangeList2: TRangeList): TRangeList;
begin
  if rangeList1.m_ranges.Count = 0 then
  begin
    Result := rangeList2;
  end
  ;
  if rangeList2.m_ranges.Count = 0 then
  begin
    Result := rangeList1;
  end
  ;
  list: TList<TRange> := rangeList1.m_ranges;
  list2: TList<TRange> := rangeList2.m_ranges;
  list3: TList<TRange> := new List<TRange>(list.Count + list2.Count);
  if list.Count > 2 and list2.Count > 2 and list[list.Count - 1].CompareForUnion(list2[0]) = TRangeComparison.DisjointHigher then
  begin
    list3.AddRange(list);
    list3.AddRange(list2);
    Result := TRangeList.Create(list3);
  end
  ;
  range: TRange := list[0];
  range2: TRange := list2[0];
  num: Integer := 0;
  num2: Integer := 0;
  // TODO: Converter WhileStatementSyntax
  // TODO: Converter WhileStatementSyntax
  // TODO: Converter WhileStatementSyntax
  Result := TRangeList.Create(list3);
end;

function TRangeList.Union(ARangeList1: TRangeList; ARangeList2: TRangeList; AOther: TRangeList[]): TRangeList;
begin
  rangeList3: TRangeList := Union(rangeList1, rangeList2);
  if other <> null then
  begin
    for rangeList4 in other do
    begin
      rangeList3 := Union(rangeList3, rangeList4);
    end;
  end
  ;
  Result := rangeList3;
end;

function TRangeList.Intersect(ARangeList1: TRangeList; ARangeList2: TRangeList): TRangeList;
begin
  list: TList<TRange> := new List<TRange>(Math.Max(rangeList1.m_ranges.Count, rangeList2.m_ranges.Count));
  num: Integer := 0;
  num2: Integer := 0;
  // TODO: Converter WhileStatementSyntax
  if list.Count <> 0 then
  begin
    Result := TRangeList.Create(list);
  end
  ;
  Result := m_empty;
end;

function TRangeList.Equals(AOther: TRangeList): Boolean;
begin
  if other = null or m_ranges.Count <> other.m_ranges.Count then
  begin
    Result := false;
  end
  ;
  if this = other then
  begin
    Result := true;
  end
  ;
  // TODO: Converter ForStatementSyntax
  Result := true;
end;

function TRangeList.ToString(): String;
begin
  Result := string.Join(" | ", m_ranges.Select((r) => r.ToString()));
end;


end.
