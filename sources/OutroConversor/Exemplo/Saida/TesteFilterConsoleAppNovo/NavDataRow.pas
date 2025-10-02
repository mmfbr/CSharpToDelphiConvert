unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataRow = class(ICustomTypeDescriptor)
  private
    m_table: TGoldDataTable;
    m_items: object[];
  public
    constructor Create();
    constructor Create(ATable: TGoldDataTable);
    constructor Create(ATable: TGoldDataTable; ARowData: object[]);
    function IsNull(AColumn: TGoldDataColumn): Boolean;
    procedure SetValue(AColumn: TGoldDataColumn; AColumnIndex: Integer; AValue: TObject);
    procedure SetDeserializedValue(AColumnIndex: Integer; AValue: TObject);
    function Clone(): TGoldDataRow;
    function CloneTo(ADestinationTable: TGoldDataTable): TGoldDataRow;
    procedure Check(AColumn: TGoldDataColumn);
    function GetProperties(): TPropertyDescriptorCollection;
    procedure WriteXml(AXmlWriter: TXmlWriter; ARowReader: TGoldDataTableReader);
    procedure WriteXml(AXmlWriter: TXmlWriter);
    procedure WriteCsv(AStreamWriter: TextWriter; ADelimiter: String; AWriteColumnNames: Boolean; APositionFixed: Boolean; APositions: int[]);
    function GetAttributes(): TAttributeCollection;
    function GetClassName(): String;
    function GetComponentName(): String;
    function GetConverter(): TypeConverter;
    function GetDefaultEvent(): TEventDescriptor;
    function GetDefaultProperty(): TPropertyDescriptor;
    function GetEditor(AEditorBaseType: Type): TObject;
    function GetEvents(AAttributes: TAttribute[]): TEventDescriptorCollection;
    function GetEvents(): TEventDescriptorCollection;
    function GetProperties(AAttributes: TAttribute[]): TPropertyDescriptorCollection;
    function GetPropertyOwner(APd: TPropertyDescriptor): TObject;
    property Table: TGoldDataTable read GetTable write SetTable;
    property Columns: TGoldDataColumnCollection read GetColumns write SetColumns;
    property ItemArray: object[] read GetItemArray write SetItemArray;
  end;


implementation

constructor TGoldDataRow.Create();
begin
  inherited Create;
end;

constructor TGoldDataRow.Create(ATable: TGoldDataTable);
begin
  inherited Create;
  Self.m_table := ATable;
  m_items := new object[ATable.Columns.Count];
  // TODO: Converter ForStatementSyntax
end;

constructor TGoldDataRow.Create(ATable: TGoldDataTable; ARowData: object[]);
begin
  inherited Create;
  if ATable.Columns.Count <> ARowData.Length then
  begin
    raise TArgumentException.Create("The array is larger than the number of m_columns in the m_table.", "ARowData");
  end
  ;
  Self.m_table := ATable;
  m_items := (object[])ARowData.Clone();
end;

function TGoldDataRow.IsNull(AColumn: TGoldDataColumn): Boolean;
begin
  Check(AColumn);
  Result := m_items[AColumn.ColumnIndex] = DBNull.Value;
end;

procedure TGoldDataRow.SetValue(AColumn: TGoldDataColumn; AColumnIndex: Integer; AValue: TObject);
begin
  if AValue = null or AValue = DBNull.Value then
  begin
    m_items[AColumnIndex] := DBNull.Value;
    Exit;
  end
  ;
  if AValue = TDBNotChanged.m_Value then
  begin
    m_items[AColumnIndex] := AValue;
    Exit;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
  m_items[AColumnIndex] := AValue;
end;

procedure TGoldDataRow.SetDeserializedValue(AColumnIndex: Integer; AValue: TObject);
begin
  m_items[AColumnIndex] := AValue;
end;

function TGoldDataRow.Clone(): TGoldDataRow;
begin
  Result := new TGoldDataRow
            {
                m_table = m_table,
                m_items = (object[])m_items.Clone()
            };
end;

function TGoldDataRow.CloneTo(ADestinationTable: TGoldDataTable): TGoldDataRow;
begin
  Result := new TGoldDataRow
            {
                m_table = ADestinationTable,
                m_items = (object[])m_items.Clone()
            };
end;

procedure TGoldDataRow.Check(AColumn: TGoldDataColumn);
begin
  if AColumn = null then
  begin
    raise TArgumentNullException.Create("AColumn");
  end
  ;
  if AColumn.Table <> m_table then
  begin
    raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "Column '{0}' does not belong to m_table {1}.", AColumn.ColumnName, m_table.TableName), "AColumn");
  end
  ;
end;

function TGoldDataRow.GetProperties(): TPropertyDescriptorCollection;
begin
  reader: TGoldDataTableReader := TGoldDataTableReader.Create(Table, TZoomToolState.UseZoomToolForReports);
  col: TPropertyDescriptorCollection := TPropertyDescriptorCollection.Create(null);
  for column in Table.Columns do
  begin
    col.Add(TGoldDataColumnPropertyDescriptor.Create(reader, column));
  end;
  Result := col;
end;

procedure TGoldDataRow.WriteXml(AXmlWriter: TXmlWriter; ARowReader: TGoldDataTableReader);
begin
  AXmlWriter.WriteStartElement(Table.TableName);
  // TODO: Converter ForStatementSyntax
  AXmlWriter.WriteEndElement();
end;

procedure TGoldDataRow.WriteXml(AXmlWriter: TXmlWriter);
begin
  WriteXml(AXmlWriter, null);
end;

procedure TGoldDataRow.WriteCsv(AStreamWriter: TextWriter; ADelimiter: String; AWriteColumnNames: Boolean; APositionFixed: Boolean; APositions: int[]);
begin
  currentPosition: Integer := 1;
  if APositionFixed and (APositions = null or APositions.Length < m_items.Length) then
  begin
    raise TGoldNCLQuerySaveAsException.Create(string.Format(CultureInfo.CurrentCulture, TLang.QueryOutputCouldNotBeSaved, "Invalid argument: Positions"));
  end
  ;
  // TODO: Converter ForStatementSyntax
  AStreamWriter.WriteLine();
end;

function TGoldDataRow.GetAttributes(): TAttributeCollection;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetClassName(): String;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetComponentName(): String;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetConverter(): TypeConverter;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetDefaultEvent(): TEventDescriptor;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetDefaultProperty(): TPropertyDescriptor;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetEditor(AEditorBaseType: Type): TObject;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetEvents(AAttributes: TAttribute[]): TEventDescriptorCollection;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetEvents(): TEventDescriptorCollection;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetProperties(AAttributes: TAttribute[]): TPropertyDescriptorCollection;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataRow.GetPropertyOwner(APd: TPropertyDescriptor): TObject;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;


end.
