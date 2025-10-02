unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldSqlStatementHelper = class(TObject)
  public
    procedure AppendSqlColumnName(AStatement: TStringBuilder; AField: TNCLMetaField; AMainAlias: String);
    function AppendCollate(AInput: TStringBuilder; ACollation: String): TStringBuilder;
    procedure AppendSqlColumnName(AStatement: TStringBuilder; ASqlColumnName: String; alias: String);
    function ParameterName(AParameterNo: Integer): String;
    function WildcardText(AText: String): String;
    function ConvertToSqlIdentifier(AIdentifier: String): String;
    function GetOrCreateSqlParameterNo(ASqlParameters: TSqlParameterCollection; AParameterNo: Integer): TSqlParameter;
    procedure SetSqlParameterWithEmptyValue(ASqlParameter: TSqlParameter; AField: INavFieldMetadata; AGetEmptySqlValue: TFunc<INavFieldMetadata, object>);
    procedure AppendSelectStatementOptions(AStatement: TStringBuilder; addFastOption: Boolean);
    procedure SetSqlParameter(ASqlParameter: TSqlParameter; AField: INavFieldMetadata; AValue: TObject; AIsWildcardValue: Boolean; AIsFilterValue: Boolean);
    procedure SetSqlParameter(ASqlParameter: TSqlParameter; ACompanyId: TCompanyId);
    procedure SetSqlParameter(ASqlParameter: TSqlParameter; AValue: TObject; AValueSqlDbType: TSqlDbType);
    procedure AppendSelectStatementOptions(AStatement: TStringBuilder; addFastOption: Boolean; addForceOrderHint: Boolean; addLoopJoinHint: Boolean);
    procedure SetSqlParameter(ASqlParameter: TSqlParameter; ANclType: TGoldNclType; ASqlDataType: TSqlDataType; ALength: Integer; AValue: TObject; AIsWildcardValue: Boolean; AIsFilterValue: Boolean);
    function AppendQuotedIdentifier(ACommandText: TStringBuilder; AIdentifier: String): TStringBuilder;
  end;


implementation

procedure TGoldSqlStatementHelper.AppendSqlColumnName(AStatement: TStringBuilder; AField: TNCLMetaField; AMainAlias: String);
begin
  alias: String := null;
  if mainAlias <> null then
  begin
    alias := mainAlias;
  end
  ;
  AppendSqlColumnName(statement, field.SqlColumnName, alias);
end;

function TGoldSqlStatementHelper.AppendCollate(AInput: TStringBuilder; ACollation: String): TStringBuilder;
begin
  if collation = null then
  begin
    Result := input;
  end
  ;
  input.Append(" COLLATE ");
  input.Append(collation);
  Result := input;
end;

procedure TGoldSqlStatementHelper.AppendSqlColumnName(AStatement: TStringBuilder; ASqlColumnName: String; alias: String);
begin
  if alias <> null then
  begin
    AppendQuotedIdentifier(statement, alias);
    statement.Append('.');
  end
  ;
  AppendQuotedIdentifier(statement, sqlColumnName);
end;

function TGoldSqlStatementHelper.ParameterName(AParameterNo: Integer): String;
begin
  Result := string.Intern("@" + parameterNo);
end;

function TGoldSqlStatementHelper.WildcardText(AText: String): String;
begin
  stringBuilder: TStringBuilder := TStringBuilder.Create();
  // TODO: Converter ForStatementSyntax
  Result := stringBuilder.ToString();
end;

function TGoldSqlStatementHelper.ConvertToSqlIdentifier(AIdentifier: String): String;
begin
  invalidIdentifierChars: String := "";
  for oldChar in invalidIdentifierChars do
  begin
    identifier := identifier.Replace(oldChar, '_');
  end;
  Result := identifier;
end;

function TGoldSqlStatementHelper.GetOrCreateSqlParameterNo(ASqlParameters: TSqlParameterCollection; AParameterNo: Integer): TSqlParameter;
begin
  sqlParameter: TSqlParameter;
  if parameterNo < sqlParameters.Count then
  begin
    sqlParameter := sqlParameters[parameterNo];
  end
  else
  begin
    sqlParameter := TSqlParameter.Create();
    sqlParameter.ParameterName := ParameterName(parameterNo);
    sqlParameters.Add(sqlParameter);
  end;
  Result := sqlParameter;
end;

procedure TGoldSqlStatementHelper.SetSqlParameterWithEmptyValue(ASqlParameter: TSqlParameter; AField: INavFieldMetadata; AGetEmptySqlValue: TFunc<INavFieldMetadata, object>);
begin
  // TODO: Converter BlockSyntax
end;

procedure TGoldSqlStatementHelper.AppendSelectStatementOptions(AStatement: TStringBuilder; addFastOption: Boolean);
begin
  AppendSelectStatementOptions(statement, addFastOption, addForceOrderHint: false, addLoopJoinHint: false);
end;

procedure TGoldSqlStatementHelper.SetSqlParameter(ASqlParameter: TSqlParameter; AField: INavFieldMetadata; AValue: TObject; AIsWildcardValue: Boolean; AIsFilterValue: Boolean);
begin
  SetSqlParameter(sqlParameter, field.NclType, field.SqlDataType, field.GoldDefinedLengthMetadata, value, isWildcardValue, isFilterValue);
end;

procedure TGoldSqlStatementHelper.SetSqlParameter(ASqlParameter: TSqlParameter; ACompanyId: TCompanyId);
begin
  sqlParameter.Value := companyId.Value;
  sqlParameter.SqlDbType := SqlDbType.Int;
end;

procedure TGoldSqlStatementHelper.SetSqlParameter(ASqlParameter: TSqlParameter; AValue: TObject; AValueSqlDbType: TSqlDbType);
begin
  sqlParameter.Value := value;
  sqlParameter.SqlDbType := valueSqlDbType;
end;

procedure TGoldSqlStatementHelper.AppendSelectStatementOptions(AStatement: TStringBuilder; addFastOption: Boolean; addForceOrderHint: Boolean; addLoopJoinHint: Boolean);
begin
  statement.Append(" OPTION(");
  length: Integer := statement.Length;
  if addFastOption then
  begin
    statement.Append("FAST 50, ");
  end
  ;
  if statement.Length > length then
  begin
    statement.Length := 2;
    statement.Append(')');
  end
  else
  begin
    statement.Length := " OPTION(".Length;
  end;
end;

procedure TGoldSqlStatementHelper.SetSqlParameter(ASqlParameter: TSqlParameter; ANclType: TGoldNclType; ASqlDataType: TSqlDataType; ALength: Integer; AValue: TObject; AIsWildcardValue: Boolean; AIsFilterValue: Boolean);
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldSqlStatementHelper.AppendQuotedIdentifier(ACommandText: TStringBuilder; AIdentifier: String): TStringBuilder;
begin
  commandText.Append("\"");
  commandText.Append(identifier);
  commandText.Append("\"");
  Result := commandText;
end;


end.
