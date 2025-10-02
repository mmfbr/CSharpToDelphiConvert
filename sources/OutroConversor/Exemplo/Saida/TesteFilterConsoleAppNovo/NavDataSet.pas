unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataSet = class(IExtensibleDataObject)
  private
    m_culture: TCultureInfo;
    m_dataSetName: String;
    m_tables: TGoldDataTableCollection;
    m_unknownDataBag: TExtensionDataObject;
    m_CompressionThreshold: Integer;
    m_useCompactSerialization: Boolean;
  public
    const m_DefaultDataSetName: String = "NewDataSet";
    constructor Create();
    constructor Create(AData: THybridDataStore);
    procedure InitializeCompressionThreshold();
    procedure Clear();
    function Serialize(): THybridDataStore;
    procedure Deserialize(AData: THybridDataStore);
    procedure ClearAll();
    function ConstructReadItemErrorMessage(AEx: TException; ABinReader: TBinaryReader; ATableName: String; AColumnNumber: Integer; ARowNumber: Integer): String;
    function Clone(): TGoldDataSet;
    function CloneStructure(): TGoldDataSet;
    property ExtensionData: TExtensionDataObject read GetExtensionData write SetExtensionData;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property Locale: TCultureInfo read GetLocale write SetLocale;
    property Tables: TGoldDataTableCollection read GetTables write SetTables;
    property HasData: Boolean read GetHasData write SetHasData;
    property DataSet: THybridDataStore read GetDataSet write SetDataSet;
  end;


implementation

constructor TGoldDataSet.Create();
begin
  inherited Create;
  m_tables := TGoldDataTableCollection.Create(this);
  m_dataSetName := "NewDataSet";
  m_culture := CultureInfo.CurrentCulture;
end;

constructor TGoldDataSet.Create(AData: THybridDataStore);
begin
  inherited Create;
  Deserialize(AData);
end;

procedure TGoldDataSet.InitializeCompressionThreshold();
begin
  if m_CompressionThreshold = 0 then
  begin
    m_CompressionThreshold := TGoldEnvironment.m_CompressionThresholdDefault;
  end
  ;
end;

procedure TGoldDataSet.Clear();
begin
  if m_tables <> null then
  begin
    // TODO: Converter ForStatementSyntax
  end
  ;
end;

function TGoldDataSet.Serialize(): THybridDataStore;
begin
  InitializeCompressionThreshold();
  memStream: THybridMemoryCompressStream := THybridMemoryCompressStream.Create(m_CompressionThreshold);
  binWriter: TBinaryWriter := TBinaryWriter.Create(memStream);
  binWriter.Write(DataSetName);
  binWriter.Write(Locale.LCID);
  binWriter.Write(Tables.Count);
  for table2 in Tables do
  begin
    binWriter.Write(table2.TableName);
    binWriter.Write(table2.Locale.LCID);
    binWriter.Write(table2.Columns.Count);
    for col in table2.Columns do
    begin
      binWriter.Write(col.ColumnName);
      binWriter.Write((byte)col.GoldTypeCode);
      if col.HasExtendedProperties then
      begin
        binWriter.Write(col.ExtendedProperties.Count);
        for key in col.ExtendedProperties.Keys do
        begin
          TGoldSerializer.WriteTypeAndItem(binWriter, key.GetType().TypeHandle, key, m_useCompactSerialization);
          value: TObject := col.ExtendedProperties[key];
          TGoldSerializer.WriteTypeAndItem(binWriter, value.GetType().TypeHandle, value, m_useCompactSerialization);
        end;
      end
      else
      begin
        binWriter.Write(0);
      end;
    end;
  end;
  for table in Tables do
  begin
    binWriter.Write(table.Rows.Count);
    for row in table.Rows do
    begin
      // TODO: Converter ForStatementSyntax
    end;
  end;
  Result := memStream.GetDataStore();
end;

procedure TGoldDataSet.Deserialize(AData: THybridDataStore);
begin
  if AData = null then
  begin
    Exit;
  end
  ;
  memStream: THybridMemoryDecompressStream := THybridMemoryDecompressStream.Create(AData);
  binReader: TBinaryReader := TBinaryReader.Create(memStream);
  ClearAll();
  DataSetName := binReader.ReadString();
  Locale := TCultureInfo.Create(binReader.ReadInt32());
  numberOfTables: Integer := binReader.ReadInt32();
  if numberOfTables > 0 then
  begin
    Tables.Clear();
  end
  ;
  // TODO: Converter ForStatementSyntax
  for table in Tables do
  begin
    columnCount: Integer := table.Columns.Count;
    numberOfRows: Integer := binReader.ReadInt32();
    // TODO: Converter ForStatementSyntax
  end;
end;

procedure TGoldDataSet.ClearAll();
begin
  Clear();
  m_dataSetName := "NewDataSet";
  m_culture := CultureInfo.CurrentCulture;
  m_tables := TGoldDataTableCollection.Create(this);
end;

function TGoldDataSet.ConstructReadItemErrorMessage(AEx: TException; ABinReader: TBinaryReader; ATableName: String; AColumnNumber: Integer; ARowNumber: Integer): String;
begin
  sb: TStringBuilder := TStringBuilder.Create(AEx.ToString());
  sb.AppendFormat(CultureInfo.InvariantCulture, "Failed to read {0} column {1} in row {2} from the stream.", ATableName, AColumnNumber.ToString(CultureInfo.InvariantCulture), ARowNumber.ToString(CultureInfo.InvariantCulture));
  if ABinReader.BaseStream <> null then
  begin
    sb.AppendLine("Stream length: " + ABinReader.BaseStream.Length.ToString(CultureInfo.InvariantCulture));
    sb.AppendLine("Stream position: " + ABinReader.BaseStream.Position.ToString(CultureInfo.InvariantCulture));
  end
  ;
  Result := sb.ToString();
end;

function TGoldDataSet.Clone(): TGoldDataSet;
begin
  Result := TGoldDataSet.Create(Serialize());
end;

function TGoldDataSet.CloneStructure(): TGoldDataSet;
begin
  dataSet: TGoldDataSet := TGoldDataSet.Create();
  for table in Tables do
  begin
    dataSet.Tables.Add(table.Clone());
  end;
  Result := dataSet;
end;


end.
