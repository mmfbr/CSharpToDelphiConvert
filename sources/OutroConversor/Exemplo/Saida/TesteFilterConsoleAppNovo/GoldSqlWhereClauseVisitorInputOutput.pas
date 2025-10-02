unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldSqlWhereClauseVisitorInputOutput = class(TObject)
  private
    m_createTextualWhereClause: Boolean;
    m_whereClause: TStringBuilder;
    m_fixedParentName: String;
    m_sqlParameters: TSqlParameterCollection;
    m_treatNullAsDefaultValue: Boolean;
    m_sqlSortingProperties: TSqlSortingProperties;
    m_sqlParameterHandler: TGoldSqlParameterHandler;
  public
    constructor Create(ACreateTextualWhereClause: Boolean; AParameters: TSqlParameterCollection; AWhereClause: TStringBuilder; ASqlParameterHandling: TGoldSqlParameterHandler; ASqlSortingProperties: TSqlSortingProperties);
    function CreateForTextualWhereClauseGeneration(AWhereClause: TStringBuilder; ASqlParameterHandling: TGoldSqlParameterHandler; ASqlSortingProperties: TSqlSortingProperties): TGoldSqlWhereClauseVisitorInputOutput;
    function CreateForParameterAssignment(AParameters: TSqlParameterCollection; ASqlParameterHandling: TGoldSqlParameterHandler; ASqlSortingProperties: TSqlSortingProperties): TGoldSqlWhereClauseVisitorInputOutput;
    function GetSqlParameter(AParameterNo: Integer): TSqlParameter;
    property CreateTextualWhereClause: Boolean read GetCreateTextualWhereClause write SetCreateTextualWhereClause;
    property WhereClause: TStringBuilder read GetWhereClause write SetWhereClause;
    property Parameters: TSqlParameterCollection read GetParameters write SetParameters;
    property TreatNullAsDefaultValue: Boolean read GetTreatNullAsDefaultValue write SetTreatNullAsDefaultValue;
    property FixedParentName: String read GetFixedParentName write SetFixedParentName;
    property SqlParameterHandling: TGoldSqlParameterHandler read GetSqlParameterHandling write SetSqlParameterHandling;
    property SqlSortingProperties: TSqlSortingProperties read GetSqlSortingProperties write SetSqlSortingProperties;
  end;


implementation

constructor TGoldSqlWhereClauseVisitorInputOutput.Create(ACreateTextualWhereClause: Boolean; AParameters: TSqlParameterCollection; AWhereClause: TStringBuilder; ASqlParameterHandling: TGoldSqlParameterHandler; ASqlSortingProperties: TSqlSortingProperties);
begin
  Self.m_createTextualWhereClause := ACreateTextualWhereClause;
  m_sqlParameters := AParameters;
  Self.m_whereClause := AWhereClause;
  m_sqlParameterHandler := ASqlParameterHandling;
  Self.m_sqlSortingProperties := ASqlSortingProperties;
end;

function TGoldSqlWhereClauseVisitorInputOutput.CreateForTextualWhereClauseGeneration(AWhereClause: TStringBuilder; ASqlParameterHandling: TGoldSqlParameterHandler; ASqlSortingProperties: TSqlSortingProperties): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AWhereClause = null then
  begin
    raise TArgumentNullException.Create("m_whereClause");
  end
  ;
  Result := TGoldSqlWhereClauseVisitorInputOutput.Create(ACreateTextualWhereClause: true, null, AWhereClause, ASqlParameterHandling/*, coveringSiftIndexes, m_treatNullAsDefaultValue, m_fixedParentName*/, ASqlSortingProperties/*, shouldAliasQualifyFields*/);
end;

function TGoldSqlWhereClauseVisitorInputOutput.CreateForParameterAssignment(AParameters: TSqlParameterCollection; ASqlParameterHandling: TGoldSqlParameterHandler; ASqlSortingProperties: TSqlSortingProperties): TGoldSqlWhereClauseVisitorInputOutput;
begin
  if AParameters = null then
  begin
    raise TArgumentNullException.Create("AParameters");
  end
  ;
  Result := TGoldSqlWhereClauseVisitorInputOutput.Create(ACreateTextualWhereClause: false, AParameters, null, ASqlParameterHandling/*, coveringSiftIndexes, m_treatNullAsDefaultValue, string.Empty*/, ASqlSortingProperties/*, shouldAliasQualifyFields*/);
end;

function TGoldSqlWhereClauseVisitorInputOutput.GetSqlParameter(AParameterNo: Integer): TSqlParameter;
begin
  Result := TGoldSqlStatementHelper.GetOrCreateSqlParameterNo(m_sqlParameters, AParameterNo);
end;


end.
