unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataTable = class(TObject)
  private
    m_columns: TGoldDataColumnCollection;
    m_rows: TGoldDataRowCollection;
    m_culture: TCultureInfo;
    m_formatProvider: IFormatProvider;
    m_dataSet: TGoldDataSet;
  public
    constructor Create();
    constructor Create(ATableName: String);
    function GetDataTable(AMediaColumnsAsByteArray: Boolean): TDataTable;
    function BuildDataTable(): TDataTable;
    function BuildDataTable(AMediaColumnsAsByteArray: Boolean): TDataTable;
    procedure Clear();
    function NewRow(): TGoldDataRow;
    function NewRow(ARowData: object[]): TGoldDataRow;
    procedure Decompress(ARowToInit: TGoldDataRow);
    function Clone(): TGoldDataTable;
    function Copy(): TGoldDataTable;
    property FormatProvider: IFormatProvider read GetFormatProvider write SetFormatProvider;
    property DataSet: TGoldDataSet read GetDataSet write SetDataSet;
    property Locale: TCultureInfo read GetLocale write SetLocale;
    property TableName: String read GetTableName write SetTableName;
    property Columns: TGoldDataColumnCollection read GetColumns write SetColumns;
    property Rows: TGoldDataRowCollection read GetRows write SetRows;
  end;


implementation

constructor TGoldDataTable.Create();
begin
end;

constructor TGoldDataTable.Create(ATableName: String);
begin
  m_culture := CultureInfo.CurrentCulture;
  m_columns := TGoldDataColumnCollection.Create(this);
  m_rows := TGoldDataRowCollection.Create(this);
  TableName := ATableName ?? string.Empty;
end;

function TGoldDataTable.GetDataTable(AMediaColumnsAsByteArray: Boolean): TDataTable;
begin
  dt: TDataTable := BuildDataTable(AMediaColumnsAsByteArray);
  reader: TGoldDataTableReader := TGoldDataTableReader.Create(this, AUpdateRow: false);
  for row in Rows do
  begin
    dr: TDataRow := dt.NewRow();
    columnLength: Integer := Columns.Count;
    // TODO: Converter ForStatementSyntax
    dt.Rows.Add(dr);
  end;
  Result := dt;
end;

function TGoldDataTable.BuildDataTable(): TDataTable;
begin
  Result := BuildDataTable(AMediaColumnsAsByteArray: false);
end;

function TGoldDataTable.BuildDataTable(AMediaColumnsAsByteArray: Boolean): TDataTable;
begin
  dataTable: TDataTable := TDataTable.Create(TableName)
            {
                Locale = Locale
            };
  for col in Columns do
  begin
    dataType: Type := (if col.GoldTypeCode <> TGoldTypeCode.Media and col.GoldTypeCode <> TGoldTypeCode.MediaSet then col.DataType else (if AMediaColumnsAsByteArray then typeof(byte[]) else typeof(Guid)));
    dc: TDataColumn := TDataColumn.Create(col.ColumnName, dataType);
    if col.DataType = typeof(DateTime) then
    begin
      dc.DateTimeMode := DataSetDateTime.Local;
    end
    ;
    if col.HasExtendedProperties then
    begin
      for key in col.ExtendedProperties.Keys do
      begin
        dc.ExtendedProperties.Add(key, col.ExtendedProperties[key]);
      end;
    end
    ;
    dataTable.Columns.Add(dc);
  end;
  Result := dataTable;
end;

procedure TGoldDataTable.Clear();
begin
  Rows.Clear();
end;

function TGoldDataTable.NewRow(): TGoldDataRow;
begin
  Result := TGoldDataRow.Create(this);
end;

function TGoldDataTable.NewRow(ARowData: object[]): TGoldDataRow;
begin
  Result := TGoldDataRow.Create(this, ARowData);
end;

procedure TGoldDataTable.Decompress(ARowToInit: TGoldDataRow);
begin
  previousRow: TGoldDataRow := ARowToInit;
  for row in Rows do
  begin
    if previousRow = null then
    begin
      previousRow := row;
      // TODO: Converter ContinueStatementSyntax
    end
    ;
    // TODO: Converter ForStatementSyntax
    previousRow := row;
  end;
end;

function TGoldDataTable.Clone(): TGoldDataTable;
begin
  clone: TGoldDataTable := TGoldDataTable.Create(TableName);
  clone.Locale := Locale;
  clone.m_formatProvider := FormatProvider;
  columnCount: Integer := Columns.Count;
  // TODO: Converter ForStatementSyntax
  Result := clone;
end;

function TGoldDataTable.Copy(): TGoldDataTable;
begin
  table: TGoldDataTable := Clone();
  i: Integer := 0;
  // TODO: Converter ForStatementSyntax
  Result := table;
end;


end.
