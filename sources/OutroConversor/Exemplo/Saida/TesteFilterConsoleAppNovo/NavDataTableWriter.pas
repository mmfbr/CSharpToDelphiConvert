unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataTableWriter = class(TObject)
  private
    m_table: TGoldDataTable;
    m_lastGoodValueRow: TGoldDataRow;
    m_currentRow: object[];
  public
    constructor Create(ATable: TGoldDataTable);
    procedure SetValue(AFieldName: String; AValue: TObject);
    procedure InsertRepeatedData(AColumnIndexes: int[]);
    procedure SetValue(AIndex: Integer; AValue: TObject);
    function ObjectEquals(ALastValue: TObject; AValue: TObject): Boolean;
    procedure Clear();
    procedure ResetRow();
    function AddCurrentRowToCollection(ARowCollection: TGoldDataRowCollection): Boolean;
    procedure DecompressRow();
    property CurrentRow: object[] read GetCurrentRow write SetCurrentRow;
  end;


implementation

constructor TGoldDataTableWriter.Create(ATable: TGoldDataTable);
begin
  Self.m_table := ATable;
  m_lastGoodValueRow := ATable.NewRow();
  columnCount: Integer := ATable.Columns.Count;
  m_currentRow := new object[columnCount];
  // TODO: Converter ForStatementSyntax
end;

procedure TGoldDataTableWriter.SetValue(AFieldName: String; AValue: TObject);
begin
  SetValue(m_lastGoodValueRow.Columns[AFieldName].ColumnIndex, AValue);
end;

procedure TGoldDataTableWriter.InsertRepeatedData(AColumnIndexes: int[]);
begin
  // TODO: Converter ForStatementSyntax
end;

procedure TGoldDataTableWriter.SetValue(AIndex: Integer; AValue: TObject);
begin
  lastValue: TObject := m_lastGoodValueRow[AIndex];
  if lastValue <> null and ObjectEquals(lastValue, AValue) then
  begin
    m_currentRow[AIndex] := TDBNotChanged.m_Value;
    Exit;
  end
  ;
  if AValue <> DBNull.Value then
  begin
    m_lastGoodValueRow[AIndex] := AValue;
  end
  ;
  m_currentRow[AIndex] := AValue;
end;

function TGoldDataTableWriter.ObjectEquals(ALastValue: TObject; AValue: TObject): Boolean;
begin
  array_: byte[] := ALastValue as byte[];
  if array_ <> null then
  begin
    Result := TByteArrayHelper.Compare(array_, AValue as byte[]);
  end
  ;
  Result := Equals(ALastValue, AValue);
end;

procedure TGoldDataTableWriter.Clear();
begin
  m_lastGoodValueRow := m_table.NewRow();
end;

procedure TGoldDataTableWriter.ResetRow();
begin
  // TODO: Converter ForStatementSyntax
end;

function TGoldDataTableWriter.AddCurrentRowToCollection(ARowCollection: TGoldDataRowCollection): Boolean;
begin
  rowIsEmpty: Boolean := true;
  // TODO: Converter ForStatementSyntax
  if not rowIsEmpty then
  begin
    ARowCollection.Add(CurrentRow);
    Result := true;
  end
  ;
  Result := false;
end;

procedure TGoldDataTableWriter.DecompressRow();
begin
  // TODO: Converter ForStatementSyntax
end;


end.
