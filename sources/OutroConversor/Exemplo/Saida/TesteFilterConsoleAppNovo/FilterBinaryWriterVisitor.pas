unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterBinaryWriterVisitor = class(TFilterExpressionVisitor<BinaryWriter, BinaryWriter>)
  private
    m_instance: TFilterBinaryWriterVisitor;
  public
    procedure WriteToBinaryWriter(AFilterExpression: TFilterExpression; AWriter: TBinaryWriter);
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function VisitOr(ABinaryExpression: TBinaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function VisitAnd(ABinaryExpression: TBinaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function Parenthesize(AFilterExpression: TFilterExpression; ABinaryWriter: TBinaryWriter): TBinaryWriter;
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
    function WriteValue(ANavValue: TGoldValue; AInput: TBinaryWriter; AExpressionContext: TFilterExpressionContext): TBinaryWriter;
  end;


implementation

procedure TFilterBinaryWriterVisitor.WriteToBinaryWriter(AFilterExpression: TFilterExpression; AWriter: TBinaryWriter);
begin
  AFilterExpression.Visit(m_instance, AWriter);
  AWriter.Write((byte)0);
end;

function TFilterBinaryWriterVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  Result := ABinaryExpression.ExpressionType switch
            {
                TFilterExpressionType.And => VisitAnd(ABinaryExpression, AInput),
                TFilterExpressionType.Or => VisitOr(ABinaryExpression, AInput),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TFilterBinaryWriterVisitor.VisitOr(ABinaryExpression: TBinaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  Visit(ABinaryExpression.Left, AInput);
  AInput.Write((byte)11);
  if ABinaryExpression.Right.ExpressionType = TFilterExpressionType.Or then
  begin
    Result := Parenthesize(ABinaryExpression.Right, AInput);
  end
  ;
  Result := Visit(ABinaryExpression.Right, AInput);
end;

function TFilterBinaryWriterVisitor.VisitAnd(ABinaryExpression: TBinaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  if ABinaryExpression.Left.ExpressionType = TFilterExpressionType.Or then
  begin
    Parenthesize(ABinaryExpression.Left, AInput);
  end
  else
  begin
    Visit(ABinaryExpression.Left, AInput);
  end;
  AInput.Write((byte)10);
  if ABinaryExpression.Right.ExpressionType = TFilterExpressionType.Or or ABinaryExpression.Right.ExpressionType = TFilterExpressionType.And then
  begin
    Parenthesize(ABinaryExpression.Right, AInput);
  end
  else
  begin
    Visit(ABinaryExpression.Right, AInput);
  end;
  Result := AInput;
end;

function TFilterBinaryWriterVisitor.Parenthesize(AFilterExpression: TFilterExpression; ABinaryWriter: TBinaryWriter): TBinaryWriter;
begin
  ABinaryWriter.Write((byte)12);
  Visit(AFilterExpression, ABinaryWriter);
  ABinaryWriter.Write((byte)13);
  Result := ABinaryWriter;
end;

function TFilterBinaryWriterVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  // TODO: Converter SwitchStatementSyntax
  Result := WriteValue(AUnaryExpression.Value, AInput, AUnaryExpression.ExpressionContext);
end;

function TFilterBinaryWriterVisitor.VisitRange(ARangeFilterExpression: TRangeFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  // TODO: Converter SwitchStatementSyntax
  Result := AInput;
end;

function TFilterBinaryWriterVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  AInput.Write((byte)(AWildcardExpression.IsNegated ? 9 : 8));
  input2: String := (if AWildcardExpression.IsCaseAndAccentInsensitive then "@" + AWildcardExpression.Pattern else AWildcardExpression.Pattern);
  navValue: TGoldValue := AWildcardExpression.ExpressionContext.Parse(input2);
  Result := WriteValue(navValue, AInput, AWildcardExpression.ExpressionContext);
end;

function TFilterBinaryWriterVisitor.VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  if not ABooleanConstantExpression.Value then
  begin
    raise TNotSupportedException.Create();
  end
  ;
  Result := AInput;
end;

function TFilterBinaryWriterVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TBinaryWriter): TBinaryWriter;
begin
  raise TNotSupportedException.Create();
end;

function TFilterBinaryWriterVisitor.WriteValue(ANavValue: TGoldValue; AInput: TBinaryWriter; AExpressionContext: TFilterExpressionContext): TBinaryWriter;
begin
  bytes: byte[] := ANavValue.GetBytes();
  num: Integer := AExpressionContext.LogicalLengthFromByteLength(bytes.Length);
  AInput.Write((byte)num);
  AInput.Write(bytes);
  Result := AInput;
end;


end.
