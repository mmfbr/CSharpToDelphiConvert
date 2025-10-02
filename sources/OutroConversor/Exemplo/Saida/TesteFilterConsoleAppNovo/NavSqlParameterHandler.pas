unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldSqlParameterHandler = class(TObject)
  private
    m_valueTokenMap: int?[];
    m_nextParameterNo: Integer;
    m_companyIdParameters: TDictionary<TCompanyId, Integer>;
  public
    constructor Create(ANextParameterNo: Integer);
    constructor Create();
    function GetParameterNoFromValueToken(AValueToken: Integer): Integer;
    function GetParameterNoForEmptyValue(AFieldMetadata: INavFieldMetadata): Integer;
    function GetCompanyParameterNo(ACompanyId: TCompanyId): Integer;
    property GetNextParameterNo: Integer read GetGetNextParameterNo write SetGetNextParameterNo;
    property GetNextParameterName: String read GetGetNextParameterName write SetGetNextParameterName;
  end;


implementation

constructor TGoldSqlParameterHandler.Create(ANextParameterNo: Integer);
begin
  Self.m_nextParameterNo := nextParameterNo;
end;

constructor TGoldSqlParameterHandler.Create();
begin
end;

function TGoldSqlParameterHandler.GetParameterNoFromValueToken(AValueToken: Integer): Integer;
begin
  if valueToken = -1 then
  begin
    Result := GetNextParameterNo;
  end
  ;
  num: Integer := (if m_valueTokenMap <> null then m_valueTokenMap.Length else 0);
  if num <= valueToken then
  begin
    destinationArray: int?[] := new int?[valueToken + 28];
    if num > 0 then
    begin
      Array.Copy(m_valueTokenMap, destinationArray, num);
    end
    ;
    m_valueTokenMap := destinationArray;
  end
  ;
  if not m_valueTokenMap[valueToken].HasValue then
  begin
    getNextParameterNo: Integer := GetNextParameterNo;
    m_valueTokenMap[valueToken] := getNextParameterNo;
    Result := getNextParameterNo;
  end
  ;
  Result := m_valueTokenMap[valueToken].Value;
end;

function TGoldSqlParameterHandler.GetParameterNoForEmptyValue(AFieldMetadata: INavFieldMetadata): Integer;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldSqlParameterHandler.GetCompanyParameterNo(ACompanyId: TCompanyId): Integer;
begin
  if not m_companyIdParameters.TryGetValue(companyId, out var value) then
  begin
    value := GetNextParameterNo;
    m_companyIdParameters.Add(companyId, value);
  end
  ;
  Result := value;
end;


end.
