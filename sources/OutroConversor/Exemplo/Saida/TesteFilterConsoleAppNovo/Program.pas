unit TesteFilterConsoleApp;

interface

uses
  System.Classes, System.SysUtils;

type
  TProgram = class(TObject)
  public
    procedure Main(args: string[]);
  end;


implementation

procedure TProgram.Main(args: string[]);
begin
  navDate: var := Seven.Runtime.TBusinessDateFormulaEvaluator.CalcDate("2T", TALSystemDate.ALToday);
  WriteLn("calculo");
  WriteLn(navDate);
  sqlConnection: var := TSqlConnection.Create();
  command: var := sqlConnection.CreateCommand();
  sqlSortingProperties: var := TSqlSortingProperties.Create(CultureInfo.CurrentUICulture, CompareOptions.IgnoreCase, null);
  hasVariables: Boolean := false;
  metaTable: TNCLMetaTable := TNCLMetaTable.Create();
  metaTable.TableId := 18;
  metaTable.TableName := "Cliente";
  metaTable.ExternalName := "Cliente";
  metaTable.ExternalSchema := "dbo";
  metaField: TNCLMetaField := TNCLMetaField.Create(1, TGoldNclType.GoldDate, TSqlDataType.Default, 30, TFieldClass.Normal, "DataCadastro"/*, true, false, false, false, null, null, false, false, null, null*/, metaTable/*, 0, 0, "DataCadastro"*/);
  context: TFilterExpressionContext := TFilterExpressionContext.CreateForNonTextField(metaField);
  filterTextExpression: var := "MAR|CELO&>GOLD";
  filterTextExpression := "-31D..CT";
  filterExpression: TFilterExpression := TFilterExpressionParser.Parse(filterTextExpression, context,
                    (string texto, TGoldType tipo) =>
                    {
                        if (tipo = TGoldType.Date)
                            return TGoldDateFormulaEvaluator.CalcDate(texto, TALSystemDate.ALToday).Value.ToString(CultureInfo.InvariantCulture);
                        else
                            return texto;
                    }
                );
  if hasVariables then
  begin
    WriteLn("tem expressão para ver");
  end
  ;
  navSqlParameterHandler: TGoldSqlParameterHandler := TGoldSqlParameterHandler.Create();
  stringBuilder: TStringBuilder := TStringBuilder.Create();
  stringBuilder2: TStringBuilder := TStringBuilder.Create(" WHERE ");
  if filterExpression <> null then
  begin
    stringBuilder2.Append('(');
    input: TGoldSqlWhereClauseVisitorInputOutput := TGoldSqlWhereClauseVisitorInputOutput.CreateForTextualWhereClauseGeneration(stringBuilder2, navSqlParameterHandler, sqlSortingProperties/*, shouldAliasQualifyFields: true*/);
    filterExpression.Visit(TGoldSqlWhereClauseVisitor.DefaultVisitor, input);
    stringBuilder2.Append(") ");
  end
  ;
  if stringBuilder2.Length > 7 then
  begin
    stringBuilder.Append(stringBuilder2);
  end
  ;
  WriteLn();
  WriteLn("SetCommandText: " + stringBuilder.ToString());
  navSqlParameterHandler := TGoldSqlParameterHandler.Create();
  if filterExpression <> null then
  begin
    input2: TGoldSqlWhereClauseVisitorInputOutput := TGoldSqlWhereClauseVisitorInputOutput.CreateForParameterAssignment(command.Parameters, navSqlParameterHandler/*, null, false*/, sqlSortingProperties/*, true*/);
    filterExpression.Visit(TGoldSqlWhereClauseVisitor.DefaultVisitor, input2);
  end
  ;
  for parameter in command.Parameters do
  begin
    WriteLn("ParameterName: " + parameter.ParameterName);
    WriteLn("ParameterValue: " + parameter.Value);
    WriteLn("ParameterSqlValue: " + parameter.SqlValue);
    WriteLn("ParameterTypeName: " + parameter.TypeName);
    WriteLn("ParameterDbType: " + parameter.DbType);
    WriteLn("ParameterSqlDbType: " + parameter.SqlDbType);
    WriteLn("ParameterSourceColumn: " + parameter.SourceColumn);
    WriteLn("ParameterUdtTypeName: " + parameter.UdtTypeName);
  end;
  WriteLn();
  WriteLn();
  WriteLn("Pressione qualquer TECLA para sair...");
  Console.ReadLine();
end;


end.
