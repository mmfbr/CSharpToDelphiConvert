unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataTableReader = class(TObject)
  private
    m_lastGoodValueRow: TGoldDataRow;
    m_updateRow: Boolean;
  public
    constructor Create(ATable: TGoldDataTable; AUpdateRow: Boolean);
    function GetValue(ARow: TGoldDataRow; AFieldName: String): TObject;
    function GetValue(ARow: TGoldDataRow; AIndex: Integer): TObject;
  end;


implementation

constructor TGoldDataTableReader.Create(ATable: TGoldDataTable; AUpdateRow: Boolean);
begin
  m_lastGoodValueRow := ATable.NewRow();
  Self.m_updateRow := AUpdateRow;
end;

function TGoldDataTableReader.GetValue(ARow: TGoldDataRow; AFieldName: String): TObject;
begin
  Result := GetValue(ARow, ARow.Columns[AFieldName].ColumnIndex);
end;

function TGoldDataTableReader.GetValue(ARow: TGoldDataRow; AIndex: Integer): TObject;
begin
  lastValue: TObject := m_lastGoodValueRow[AIndex];
  value: TObject := ARow[AIndex];
  if value = TDBNotChanged.m_Value then
  begin
    if m_updateRow then
    begin
      ARow[AIndex] := lastValue;
    end
    ;
    value := lastValue;
  end
  else
  begin
    if value <> DBNull.Value then
    begin
      m_lastGoodValueRow[AIndex] := value;
    end
    ;
  end;
  Result := value;
end;


end.
