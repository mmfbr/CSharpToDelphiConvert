unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TBinaryFilterExpression = class(TFilterExpression)
  private
    m_left: TFilterExpression;
    m_right: TFilterExpression;
    m_hashCode: Integer;
  public
    constructor Create(AFilterExpressionType: TFilterExpressionType; ALeft: TFilterExpression; ARight: TFilterExpression);
    function Evaluate(AInput: TGoldValue): Boolean;
    function ToRangeList(): TRangeList;
    function Equals(AOther: TBinaryFilterExpression): Boolean;
    function GetHashCode(): Integer;
    function Update(ANewExpressionType: TFilterExpressionType; ANewLeft: TFilterExpression; ANewRight: TFilterExpression): TBinaryFilterExpression;
    function ComputeHashCode(): Integer;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property Left: TFilterExpression read GetLeft write SetLeft;
    property Right: TFilterExpression read GetRight write SetRight;
  end;


implementation

constructor TBinaryFilterExpression.Create(AFilterExpressionType: TFilterExpressionType; ALeft: TFilterExpression; ARight: TFilterExpression);
begin
  inherited Create;
  ValidateNotNull(ALeft, "m_left");
  ValidateNotNull(ARight, "m_right");
  if (uint)(AFilterExpressionType - 6) > 1u then
  begin
    raise TArgumentOutOfRangeException.Create("AFilterExpressionType");
  end
  ;
  Self.m_left := ALeft;
  Self.m_right := ARight;
  m_hashCode := ComputeHashCode();
end;

function TBinaryFilterExpression.Evaluate(AInput: TGoldValue): Boolean;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TBinaryFilterExpression.ToRangeList(): TRangeList;
begin
  rangeList: TRangeList := Left.ToRangeList();
  rangeList2: TRangeList := Right.ToRangeList();
  Result := ExpressionType switch
            {
                TFilterExpressionType.And => TRangeList.Intersect(rangeList, rangeList2),
                TFilterExpressionType.Or => TRangeList.Union(rangeList, rangeList2),
                _ => throw TNotSupportedException.Create(),
            };
end;

function TBinaryFilterExpression.Equals(AOther: TBinaryFilterExpression): Boolean;
begin
  if AOther <> null then
  begin
    if this <> AOther then
    begin
      if m_hashCode = AOther.m_hashCode and AOther.ExpressionType = ExpressionType and m_left.Equals(AOther.m_left) then
      begin
        Result := m_right.Equals(AOther.m_right);
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

function TBinaryFilterExpression.GetHashCode(): Integer;
begin
  Result := m_hashCode;
end;

function TBinaryFilterExpression.Update(ANewExpressionType: TFilterExpressionType; ANewLeft: TFilterExpression; ANewRight: TFilterExpression): TBinaryFilterExpression;
begin
  if ANewLeft = Left and ANewRight = Right and ANewExpressionType = ExpressionType then
  begin
    Result := this;
  end
  ;
  Result := TBinaryFilterExpression.Create(ANewExpressionType, ANewLeft, ANewRight);
end;

function TBinaryFilterExpression.ComputeHashCode(): Integer;
begin
  Result := THashCodeHelper.CombineHashCodes((int)ExpressionType, m_left.GetHashCode(), m_right.GetHashCode());
end;


end.
