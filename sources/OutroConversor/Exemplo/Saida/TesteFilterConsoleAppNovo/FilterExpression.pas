unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterExpression = class(ISizableObject)
  private
    m_expressionType: TFilterExpressionType;
  public
    const m_UndefinedValueToken: Integer = -1;
    const m_DefaultValueTokens: Integer = 25;
    const m_TimestampValueToken: Integer = 26;
    const m_VariantValueToken: Integer = 27;
    const m_ReservedValueTokens: Integer = 28;
    constructor Create(AExpressionType: TFilterExpressionType);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    procedure ValidateNotNull(AArgument: TObject; AParameterName: String);
    procedure ValidateNull(AArgument: TObject; AParameterName: String);
    procedure ValidateTypesMatch(AValue: INavValueMetadata; AExpressionContext: TFilterExpressionContext);
    function Equals(AOther: TFilterExpression): Boolean;
    function Equals(AObj: TObject): Boolean;
    function GetHashCode(): Integer;
    function ToString(): String;
    function ToString(AStringOptions: TFilterExpressionStringOptions): String;
    function And(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
    function And(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
    function And(AExpressions: TFilterExpression[]): TFilterExpression;
    function Or(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
    function Or(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
    function Or(AExpressions: TFilterExpression[]): TFilterExpression;
    function BalancedOr(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
    function BalancedAnd(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
    function Balanced(AExpressions: IEnumerable<TFilterExpression>; ACombiningFunc: TFunc<TFilterExpression, TFilterExpression, TFilterExpression>): TFilterExpression;
    function ConsumeHeight(AExpressions: IEnumerator<TFilterExpression>; ATargetHeight: Integer; ACombiningFunc: TFunc<TFilterExpression, TFilterExpression, TFilterExpression>; AExpression: TFilterExpression): Boolean;
    function Equal(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
    function NotEqual(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
    function GreaterThan(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
    function GreaterThanOrEqual(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
    function LessThan(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
    function LessThanOrEqual(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
    function Wildcard(AIsNegated: Boolean; APattern: String; ACaseAndAccentInsensitive: Boolean; AExpressionContext: TFilterExpressionContext): TWildcardFilterExpression;
    function BooleanConstant(AValue: Boolean): TBooleanConstantFilterExpression;
    function RangeBetweenInclusive(ALowValue: TGoldValue; AHighValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeFilterExpression;
    function RangeFromInclusive(ALowValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeFilterExpression;
    function RangeToInclusive(AHighValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeFilterExpression;
    function FieldEqualsField(AFieldToCompareTo: INavFieldMetadata; AExpressionContext: TFilterExpressionContext): TFieldEqualsFieldFilterExpression;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property ExpressionType: TFilterExpressionType read GetExpressionType write SetExpressionType;
  end;


implementation

constructor TFilterExpression.Create(AExpressionType: TFilterExpressionType);
begin
  inherited Create;
  Self.m_expressionType := AExpressionType;
end;

function TFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
end;

function TFilterExpression.ToRangeList(): TRangeList;
begin
end;

procedure TFilterExpression.ValidateNotNull(AArgument: TObject; AParameterName: String);
begin
  if AArgument = null then
  begin
    raise TArgumentNullException.Create(AParameterName);
  end
  ;
end;

procedure TFilterExpression.ValidateNull(AArgument: TObject; AParameterName: String);
begin
  if AArgument <> null then
  begin
    raise TArgumentOutOfRangeException.Create(AParameterName);
  end
  ;
end;

procedure TFilterExpression.ValidateTypesMatch(AValue: INavValueMetadata; AExpressionContext: TFilterExpressionContext);
begin
  if AValue.NclType <> AExpressionContext.Metadata.NclType then
  begin
    raise TArgumentException.Create("Type mismatch between m_value and AExpression context.");
  end
  ;
end;

function TFilterExpression.Equals(AOther: TFilterExpression): Boolean;
begin
  if this = AOther then
  begin
    Result := true;
  end
  ;
  if AOther = null or m_expressionType <> AOther.m_expressionType or GetHashCode() <> AOther.GetHashCode() then
  begin
    Result := false;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TFilterExpression.Equals(AObj: TObject): Boolean;
begin
  Result := Equals(AObj as TFilterExpression);
end;

function TFilterExpression.GetHashCode(): Integer;
begin
end;

function TFilterExpression.ToString(): String;
begin
  Result := ToString(TFilterExpressionStringOptions.None);
end;

function TFilterExpression.ToString(AStringOptions: TFilterExpressionStringOptions): String;
begin
  stringBuilder: TStringBuilder := Self.Visit(TFilterStringVisitor.m_Instance, Tuple.Create(AStringOptions, TStringBuilder.Create()));
  if (AStringOptions & TFilterExpressionStringOptions.TwoQuotesAsEmpty) = TFilterExpressionStringOptions.TwoQuotesAsEmpty and stringBuilder.Length = 2 and stringBuilder[0] = '\'' and stringBuilder[1] = '\'' then
  begin
    Result := string.Empty;
  end
  ;
  Result := stringBuilder.ToString();
end;

function TFilterExpression.And(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
begin
  if ALeft <> null then
  begin
    if ARight <> null then
    begin
      Result := TBinaryFilterExpression.Create(TFilterExpressionType.And, ALeft, ARight);
    end
    ;
    Result := ALeft;
  end
  ;
  Result := ARight;
end;

function TFilterExpression.And(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
begin
  Result := AExpressions.Aggregate<TFilterExpression, TFilterExpression>(null, And);
end;

function TFilterExpression.And(AExpressions: TFilterExpression[]): TFilterExpression;
begin
  Result := AExpressions.Aggregate<TFilterExpression, TFilterExpression>(null, And);
end;

function TFilterExpression.Or(ALeft: TFilterExpression; ARight: TFilterExpression): TFilterExpression;
begin
  if ALeft <> null and ARight <> null then
  begin
    Result := TBinaryFilterExpression.Create(TFilterExpressionType.Or, ALeft, ARight);
  end
  ;
  Result := null;
end;

function TFilterExpression.Or(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
begin
  filterExpression: TFilterExpression := null;
  flag: Boolean := true;
  for expression in AExpressions do
  begin
    if expression = null then
    begin
      Result := null;
    end
    ;
    if flag then
    begin
      flag := false;
      filterExpression := expression;
    end
    else
    begin
      filterExpression := Or(filterExpression, expression);
    end;
  end;
  Result := filterExpression;
end;

function TFilterExpression.Or(AExpressions: TFilterExpression[]): TFilterExpression;
begin
  Result := Or((IEnumerable<TFilterExpression>)(AExpressions ?? new TFilterExpression[0]));
end;

function TFilterExpression.BalancedOr(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
begin
  Result := Balanced(AExpressions, Or);
end;

function TFilterExpression.BalancedAnd(AExpressions: IEnumerable<TFilterExpression>): TFilterExpression;
begin
  Result := Balanced(AExpressions, And);
end;

function TFilterExpression.Balanced(AExpressions: IEnumerable<TFilterExpression>; ACombiningFunc: TFunc<TFilterExpression, TFilterExpression, TFilterExpression>): TFilterExpression;
begin
  enumerator: IEnumerator<TFilterExpression> := AExpressions.GetEnumerator();
  if not enumerator.MoveNext() then
  begin
    Result := null;
  end
  ;
  filterExpression: TFilterExpression := null;
  flag: Boolean := true;
  num: Integer := 0;
  // TODO: Converter WhileStatementSyntax
  Result := filterExpression;
end;

function TFilterExpression.ConsumeHeight(AExpressions: IEnumerator<TFilterExpression>; ATargetHeight: Integer; ACombiningFunc: TFunc<TFilterExpression, TFilterExpression, TFilterExpression>; AExpression: TFilterExpression): Boolean;
begin
  if ATargetHeight = 0 then
  begin
    AExpression := AExpressions.Current;
    Result := AExpressions.MoveNext();
  end
  ;
  if not ConsumeHeight(AExpressions, ATargetHeight - 1, ACombiningFunc, out var expression2) then
  begin
    AExpression := expression2;
    Result := false;
  end
  ;
  expression3: TFilterExpression;
  _result: Boolean := ConsumeHeight(AExpressions, ATargetHeight - 1, ACombiningFunc, out expression3);
  AExpression := ACombiningFunc(expression2, expression3);
  Result := _result;
end;

function TFilterExpression.Equal(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(TFilterExpressionType.Equal, AValue, AExpressionContext);
end;

function TFilterExpression.NotEqual(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(TFilterExpressionType.NotEqual, AValue, AExpressionContext);
end;

function TFilterExpression.GreaterThan(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(TFilterExpressionType.GreaterThan, AValue, AExpressionContext);
end;

function TFilterExpression.GreaterThanOrEqual(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(TFilterExpressionType.GreaterThanOrEqual, AValue, AExpressionContext);
end;

function TFilterExpression.LessThan(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(TFilterExpressionType.LessThan, AValue, AExpressionContext);
end;

function TFilterExpression.LessThanOrEqual(AValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TUnaryFilterExpression;
begin
  Result := TUnaryFilterExpression.Create(TFilterExpressionType.LessThanOrEqual, AValue, AExpressionContext);
end;

function TFilterExpression.Wildcard(AIsNegated: Boolean; APattern: String; ACaseAndAccentInsensitive: Boolean; AExpressionContext: TFilterExpressionContext): TWildcardFilterExpression;
begin
  Result := TWildcardFilterExpression.Create(AIsNegated, APattern, ACaseAndAccentInsensitive, AExpressionContext);
end;

function TFilterExpression.BooleanConstant(AValue: Boolean): TBooleanConstantFilterExpression;
begin
  Result := TBooleanConstantFilterExpression.Get(AValue);
end;

function TFilterExpression.RangeBetweenInclusive(ALowValue: TGoldValue; AHighValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeFilterExpression;
begin
  Result := TRangeFilterExpression.Create(TFilterExpressionType.RangeBetweenInclusive, ALowValue, AHighValue, AExpressionContext);
end;

function TFilterExpression.RangeFromInclusive(ALowValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeFilterExpression;
begin
  Result := TRangeFilterExpression.Create(TFilterExpressionType.RangeFromInclusive, ALowValue, null, AExpressionContext);
end;

function TFilterExpression.RangeToInclusive(AHighValue: TGoldValue; AExpressionContext: TFilterExpressionContext): TRangeFilterExpression;
begin
  Result := TRangeFilterExpression.Create(TFilterExpressionType.RangeToInclusive, null, AHighValue, AExpressionContext);
end;

function TFilterExpression.FieldEqualsField(AFieldToCompareTo: INavFieldMetadata; AExpressionContext: TFilterExpressionContext): TFieldEqualsFieldFilterExpression;
begin
  Result := TFieldEqualsFieldFilterExpression.Create(AFieldToCompareTo, AExpressionContext);
end;


end.
