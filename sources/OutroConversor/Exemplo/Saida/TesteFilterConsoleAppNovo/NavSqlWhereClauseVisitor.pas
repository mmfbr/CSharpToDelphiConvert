unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldSqlWhereClauseVisitor = class(TFilterExpressionVisitor<TGoldSqlWhereClauseVisitorInputOutput, TGoldSqlWhereClauseVisitorInputOutput>)
  private
    m_defaultVisitor: TGoldSqlWhereClauseVisitor;
  public
    function GetSqlparameterValue(AField: INavFieldMetadata; AValue: TGoldValue): TObject;
    procedure AppendOperator(AExpressionType: TFilterExpressionType; ANegate: Boolean; AInput: TGoldSqlWhereClauseVisitorInputOutput);
    function Parenthesize(AFilterExpression: TFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    procedure AppendParameterName(AInput: TGoldSqlWhereClauseVisitorInputOutput; AParameterNo: Integer);
    procedure AddNullCheckParameterIfApplicable(AField: INavFieldMetadata; AInput: TGoldSqlWhereClauseVisitorInputOutput);
    function VisitOr(ABinaryExpression: TBinaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    function VisitAnd(ABinaryExpression: TBinaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    function VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    procedure AppendColumnName(AInput: TGoldSqlWhereClauseVisitorInputOutput; AWhereClause: TStringBuilder; AMetaData: INavFieldMetadata; ATreatNullAsDefaultValue: Boolean; AFixedParentName: String);
    function VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    function VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    function VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    function VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
    property DefaultVisitor: TGoldSqlWhereClauseVisitor read GetDefaultVisitor write SetDefaultVisitor;
  end;


implementation

function TGoldSqlWhereClauseVisitor.GetSqlparameterValue(AField: INavFieldMetadata; AValue: TGoldValue): TObject;
begin
  if AValue = null then
  begin
    Result := DBNull.Value;
  end
  ;
  Result := AValue.GetSqlWhereClauseValue(AField.SqlDataType);
end;

procedure TGoldSqlWhereClauseVisitor.AppendOperator(AExpressionType: TFilterExpressionType; ANegate: Boolean; AInput: TGoldSqlWhereClauseVisitorInputOutput);
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldSqlWhereClauseVisitor.Parenthesize(AFilterExpression: TFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  AInput.WhereClause.Append('(');
  Visit(AFilterExpression, AInput);
  AInput.WhereClause.Append(')');
  Result := AInput;
end;

procedure TGoldSqlWhereClauseVisitor.AppendParameterName(AInput: TGoldSqlWhereClauseVisitorInputOutput; AParameterNo: Integer);
begin
  AInput.WhereClause.Append(TGoldSqlStatementHelper.ParameterName(AParameterNo));
end;

procedure TGoldSqlWhereClauseVisitor.AddNullCheckParameterIfApplicable(AField: INavFieldMetadata; AInput: TGoldSqlWhereClauseVisitorInputOutput);
begin
  if AInput.TreatNullAsDefaultValue and AField.NclType <> TGoldNclType.GoldBlob then
  begin
    parameterNoForEmptyValue: Integer := AInput.SqlParameterHandling.GetParameterNoForEmptyValue(AField);
    sqlParameter: TSqlParameter := AInput.GetSqlParameter(parameterNoForEmptyValue);
    getEmptySqlValue: TFunc<INavFieldMetadata, object> := (AF) => AF.EmptyValue.GetSqlWhereClauseValue(AF.SqlDataType);
    TGoldSqlStatementHelper.SetSqlParameterWithEmptyValue(sqlParameter, AField, getEmptySqlValue);
  end
  ;
end;

function TGoldSqlWhereClauseVisitor.VisitOr(ABinaryExpression: TBinaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  Visit(ABinaryExpression.Left, AInput);
  AppendOperator(TFilterExpressionType.Or, ANegate: false, AInput);
  if ABinaryExpression.Right.ExpressionType = TFilterExpressionType.Or then
  begin
    Result := Parenthesize(ABinaryExpression.Right, AInput);
  end
  ;
  Result := Visit(ABinaryExpression.Right, AInput);
end;

function TGoldSqlWhereClauseVisitor.VisitAnd(ABinaryExpression: TBinaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if ABinaryExpression.Left.ExpressionType = TFilterExpressionType.Or then
  begin
    Parenthesize(ABinaryExpression.Left, AInput);
  end
  else
  begin
    Visit(ABinaryExpression.Left, AInput);
  end;
  AppendOperator(TFilterExpressionType.And, ANegate: false, AInput);
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

function TGoldSqlWhereClauseVisitor.VisitBinary(ABinaryExpression: TBinaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AInput.CreateTextualWhereClause then
  begin
    // TODO: Converter SwitchStatementSyntax
    Result := AInput;
  end
  ;
  Visit(ABinaryExpression.Left, AInput);
  Visit(ABinaryExpression.Right, AInput);
  Result := AInput;
end;

procedure TGoldSqlWhereClauseVisitor.AppendColumnName(AInput: TGoldSqlWhereClauseVisitorInputOutput; AWhereClause: TStringBuilder; AMetaData: INavFieldMetadata; ATreatNullAsDefaultValue: Boolean; AFixedParentName: String);
begin
  nCLMetaField: TNCLMetaField := (TNCLMetaField)AMetaData;
  if not string.IsNullOrEmpty(AFixedParentName) then
  begin
    TGoldSqlStatementHelper.AppendQuotedIdentifier(AWhereClause, TGoldSqlStatementHelper.ConvertToSqlIdentifier(AFixedParentName));
    AWhereClause.Append('.');
    TGoldSqlStatementHelper.AppendQuotedIdentifier(AWhereClause, nCLMetaField.SqlColumnName);
  end
  else
  begin
    TGoldSqlStatementHelper.AppendQuotedIdentifier(AWhereClause, nCLMetaField.SqlColumnName);
  end;
end;

function TGoldSqlWhereClauseVisitor.VisitUnary(AUnaryExpression: TUnaryFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AInput.CreateTextualWhereClause then
  begin
    flag: Boolean := AUnaryExpression.ExpressionContext.Metadata.NclType = TGoldNclType.GoldBlob;
    if flag then
    begin
      AInput.WhereClause.Append("CASE ISNULL(DATALENGTH(");
    end
    ;
    AppendColumnName(AInput, AInput.WhereClause, AUnaryExpression.ExpressionContext.Metadata, AInput.TreatNullAsDefaultValue, AInput.FixedParentName);
    if flag then
    begin
      AInput.WhereClause.Append("), 0) WHEN 0 THEN 0 ELSE 1 END");
    end
    ;
    AppendOperator(AUnaryExpression.ExpressionType, ANegate: false, AInput);
    AppendParameterName(AInput, AInput.SqlParameterHandling.GetParameterNoFromValueToken(AUnaryExpression.ValueToken));
    Result := AInput;
  end
  ;
  AddNullCheckParameterIfApplicable(AUnaryExpression.ExpressionContext.Metadata, AInput);
  sqlparameterValue: TObject := GetSqlparameterValue(AUnaryExpression.ExpressionContext.Metadata, AUnaryExpression.Value);
  TGoldSqlStatementHelper.SetSqlParameter(AInput.GetSqlParameter(AInput.SqlParameterHandling.GetParameterNoFromValueToken(AUnaryExpression.ValueToken)), AUnaryExpression.ExpressionContext.Metadata, sqlparameterValue, isWildcardValue: false, isFilterValue: true);
  Result := AInput;
end;

function TGoldSqlWhereClauseVisitor.VisitWildcard(AWildcardExpression: TWildcardFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AInput.CreateTextualWhereClause then
  begin
    flag: Boolean := AWildcardExpression.ExpressionContext.Metadata.NclType = TGoldNclType.GoldOemCode or AWildcardExpression.ExpressionContext.Metadata.NclType = TGoldNclType.GoldCode;
    flag2: Boolean := flag and AWildcardExpression.ExpressionContext.Metadata.SqlDataType = TSqlDataType.Variant;
    if flag2 then
    begin
      AInput.WhereClause.Append("CAST(");
    end
    ;
    AppendColumnName(AInput, AInput.WhereClause, AWildcardExpression.ExpressionContext.Metadata, AInput.TreatNullAsDefaultValue, AInput.FixedParentName);
    if flag2 then
    begin
      AInput.WhereClause.Append(AWildcardExpression.ExpressionContext.Metadata.NclType = TGoldNclType.GoldOemCode ? " AS VARCHAR)" : " AS NVARCHAR)");
    end
    ;
    if AWildcardExpression.IsCaseAndAccentInsensitive then
    begin
      metadata: INavFieldMetadata := AWildcardExpression.ExpressionContext.Metadata;
      if not flag or metadata.SqlDataType <> TSqlDataType.Integer and metadata.SqlDataType <> TSqlDataType.BigInt then
      begin
        TGoldSqlStatementHelper.AppendCollate(AInput.WhereClause, AInput.SqlSortingProperties.AccentAndCaseInsensitiveCollation);
      end
      ;
    end
    ;
    AppendOperator(AWildcardExpression.ExpressionType, AWildcardExpression.IsNegated, AInput);
    AppendParameterName(AInput, AInput.SqlParameterHandling.GetNextParameterNo);
    Result := AInput;
  end
  ;
  AddNullCheckParameterIfApplicable(AWildcardExpression.ExpressionContext.Metadata, AInput);
  value: TObject := TGoldSqlStatementHelper.WildcardText(AWildcardExpression.Pattern);
  TGoldSqlStatementHelper.SetSqlParameter(AInput.GetSqlParameter(AInput.SqlParameterHandling.GetNextParameterNo), AWildcardExpression.ExpressionContext.Metadata, value, isWildcardValue: true, isFilterValue: true);
  Result := AInput;
end;

function TGoldSqlWhereClauseVisitor.VisitBooleanConstant(ABooleanConstantExpression: TBooleanConstantFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AInput.CreateTextualWhereClause then
  begin
    AInput.WhereClause.Append("1=");
    AppendParameterName(AInput, AInput.SqlParameterHandling.GetNextParameterNo);
    Result := AInput;
  end
  ;
  sqlParameter: TSqlParameter := AInput.GetSqlParameter(AInput.SqlParameterHandling.GetNextParameterNo);
  sqlParameter.SqlDbType := SqlDbType.TinyInt;
  sqlParameter.Value := ABooleanConstantExpression.Value;
  Result := AInput;
end;

function TGoldSqlWhereClauseVisitor.VisitFieldEqualsField(AFieldEqualsFieldExpression: TFieldEqualsFieldFilterExpression; AInput: TGoldSqlWhereClauseVisitorInputOutput): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AInput.CreateTextualWhereClause then
  begin
    AppendColumnName(AInput, AInput.WhereClause, AFieldEqualsFieldExpression.ExpressionContext.Metadata, ATreatNullAsDefaultValue: false, AInput.FixedParentName);
    AppendOperator(AFieldEqualsFieldExpression.ExpressionType, ANegate: false, AInput);
    AppendColumnName(AInput, AInput.WhereClause, AFieldEqualsFieldExpression.FieldToCompareTo, ATreatNullAsDefaultValue: false, AInput.FixedParentName);
  end
  ;
  Result := AInput;
end;


end.
