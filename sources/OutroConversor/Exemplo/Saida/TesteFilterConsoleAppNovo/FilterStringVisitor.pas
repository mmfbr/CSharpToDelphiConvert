unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterStringVisitor = class(TFilterExpressionVisitor<Tuple<TFilterExpressionStringOptions, StringBuilder>, StringBuilder>)
  public
    constructor Create();
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitOr(ABinaryExpression: TBinaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitAnd(ABinaryExpression: TBinaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    procedure AppendAndQuoteTableOrColumnNameIfNecessary(AStringBuilder: TStringBuilder; ATableOrColumnName: String);
    function Parenthesize(AFilterExpression: TFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
    function UnaryExpressionRequiresOperator(AValueString: String; AUnaryExpression: TUnaryFilterExpression; AStringOptions: TFilterExpressionStringOptions): Boolean;
  end;


implementation

constructor TFilterStringVisitor.Create();
begin
  inherited Create;
end;

function TFilterStringVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  Result := ABinaryExpression.ExpressionType switch
            {
                TFilterExpressionType.And => VisitAnd(ABinaryExpression, AInput),
                TFilterExpressionType.Or => VisitOr(ABinaryExpression, AInput),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TFilterStringVisitor.VisitOr(ABinaryExpression: TBinaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  flag: Boolean := (AInput.Item1 & TFilterExpressionStringOptions.AlwaysParenthesize) <> 0;
  if flag and (ABinaryExpression.Left.ExpressionType = TFilterExpressionType.Or or ABinaryExpression.Left.ExpressionType = TFilterExpressionType.And) then
  begin
    Parenthesize(ABinaryExpression.Left, AInput);
  end
  else
  begin
    Visit(ABinaryExpression.Left, AInput);
  end;
  AInput.Item2.Append('|');
  if ABinaryExpression.Right.ExpressionType = TFilterExpressionType.Or or flag and ABinaryExpression.Right.ExpressionType = TFilterExpressionType.And then
  begin
    Result := Parenthesize(ABinaryExpression.Right, AInput);
  end
  ;
  Result := Visit(ABinaryExpression.Right, AInput);
end;

function TFilterStringVisitor.VisitAnd(ABinaryExpression: TBinaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  flag: Boolean := (AInput.Item1 & TFilterExpressionStringOptions.AlwaysParenthesize) <> 0;
  if ABinaryExpression.Left.ExpressionType = TFilterExpressionType.Or or flag and ABinaryExpression.Left.ExpressionType = TFilterExpressionType.And then
  begin
    Parenthesize(ABinaryExpression.Left, AInput);
  end
  else
  begin
    Visit(ABinaryExpression.Left, AInput);
  end;
  item: TStringBuilder := AInput.Item2;
  item.Append('&');
  if ABinaryExpression.Right.ExpressionType = TFilterExpressionType.Or or ABinaryExpression.Right.ExpressionType = TFilterExpressionType.And then
  begin
    Parenthesize(ABinaryExpression.Right, AInput);
  end
  else
  begin
    Visit(ABinaryExpression.Right, AInput);
  end;
  Result := item;
end;

function TFilterStringVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  text: String := AUnaryExpression.ExpressionContext.QuoteLiteralIfNecessary(AUnaryExpression.ExpressionContext.ValueToString(AUnaryExpression.Value, AInput.Item1), AInput.Item1);
  if UnaryExpressionRequiresOperator(text, AUnaryExpression, AInput.Item1) then
  begin
    AInput.Item2.Append(AUnaryExpression.ExpressionType.OperatorString());
  end
  ;
  Result := AInput.Item2.Append(text);
end;

function TFilterStringVisitor.VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  Result := ARangeFilterExpression.ExpressionType switch
            {
                TFilterExpressionType.RangeBetweenInclusive => AInput.Item2.Append(ARangeFilterExpression.ExpressionContext.QuoteLiteralIfNecessary(ARangeFilterExpression.ExpressionContext.ValueToString(ARangeFilterExpression.LowValue, AInput.Item1))).Append("..").Append(ARangeFilterExpression.ExpressionContext.QuoteLiteralIfNecessary(ARangeFilterExpression.ExpressionContext.ValueToString(ARangeFilterExpression.HighValue, AInput.Item1))),
                TFilterExpressionType.RangeFromInclusive => AInput.Item2.Append(ARangeFilterExpression.ExpressionContext.QuoteLiteralIfNecessary(ARangeFilterExpression.ExpressionContext.ValueToString(ARangeFilterExpression.LowValue, AInput.Item1))).Append(".."),
                TFilterExpressionType.RangeToInclusive => AInput.Item2.Append("..").Append(ARangeFilterExpression.ExpressionContext.QuoteLiteralIfNecessary(ARangeFilterExpression.ExpressionContext.ValueToString(ARangeFilterExpression.HighValue, AInput.Item1))),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TFilterStringVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  item: TStringBuilder := AInput.Item2;
  if AWildcardExpression.IsNegated then
  begin
    item.Append(TFilterExpressionType.NotEqual.OperatorString());
  end
  ;
  text: String := AWildcardExpression.Pattern;
  if AWildcardExpression.IsCaseAndAccentInsensitive then
  begin
    text := "@" + text;
  end
  ;
  Result := item.Append(AWildcardExpression.ExpressionContext.QuoteLiteralIfNecessary(text, TFilterExpressionStringOptions.DoNotQuoteWildcards));
end;

function TFilterStringVisitor.VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  if (AInput.Item1 & TFilterExpressionStringOptions.BooleanConstantTrueAsEmpty) <> TFilterExpressionStringOptions.BooleanConstantTrueAsEmpty or not ABooleanConstantExpression.Value then
  begin
    AInput.Item2.Append(ABooleanConstantExpression.Value ? "=" : "<><>");
  end
  ;
  Result := AInput.Item2;
end;

function TFilterStringVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  tableOrColumnName: String;
  tableOrColumnName2: String;
  if AFieldEqualsFieldExpression.FieldToCompareTo is TNCLMetaField nCLMetaField then
  begin
    tableOrColumnName := nCLMetaField.Parent.TableName;
    tableOrColumnName2 := nCLMetaField.FieldName;
  end
  else
  begin
    // TODO: Converter BlockSyntax
  end;
  item: TStringBuilder := AInput.Item2;
  item.Append("=Field[");
  AppendAndQuoteTableOrColumnNameIfNecessary(item, tableOrColumnName);
  item.Append('.');
  AppendAndQuoteTableOrColumnNameIfNecessary(item, tableOrColumnName2);
  item.Append(']');
  Result := item;
end;

procedure TFilterStringVisitor.AppendAndQuoteTableOrColumnNameIfNecessary(AStringBuilder: TStringBuilder; ATableOrColumnName: String);
begin
  if Regex.IsMatch(ATableOrColumnName, "[ \\]]") then
  begin
    AStringBuilder.Append('"').Append(ATableOrColumnName.Replace("\"", "\"\"")).Append('"');
  end
  else
  begin
    AStringBuilder.Append(ATableOrColumnName);
  end;
end;

function TFilterStringVisitor.Parenthesize(AFilterExpression: TFilterExpression; AInput: Tuple<TFilterExpressionStringOptions, StringBuilder>): TStringBuilder;
begin
  item: TStringBuilder := AInput.Item2;
  item.Append('(');
  Visit(AFilterExpression, AInput);
  Result := item.Append(')');
end;

function TFilterStringVisitor.UnaryExpressionRequiresOperator(AValueString: String; AUnaryExpression: TUnaryFilterExpression; AStringOptions: TFilterExpressionStringOptions): Boolean;
begin
  if AUnaryExpression.ExpressionType <> 0 then
  begin
    Result := true;
  end
  ;
  if (AStringOptions & TFilterExpressionStringOptions.ConstExpressionImplied) = TFilterExpressionStringOptions.ConstExpressionImplied then
  begin
    Result := false;
  end
  ;
  if AUnaryExpression.ExpressionContext.SupportsWildcards and TFilterExpressionParser.IsWildcard(AValueString) then
  begin
    Result := true;
  end
  ;
  Result := false;
end;


end.
