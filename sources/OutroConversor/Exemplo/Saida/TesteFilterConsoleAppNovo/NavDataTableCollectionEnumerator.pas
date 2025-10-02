unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldDataTableCollectionEnumerator = class(IEnumerable<TGoldDataRow>)
  private
    m_cacheData: Boolean;
    m_endSignal: Boolean;
    m_enumerationFinished: Boolean;
    m_rowsAdded: Integer;
    m_dataTables: TList<TGoldDataTable>;
    m_cachedDataTable: TList<TGoldDataTable>;
    m_tableLock: TSemaphore;
  public
    constructor Create(AWaitForEndSignal: Boolean; ACacheData: Boolean);
    procedure FinalDataTableAdded();
    function DecompressRows(): IList<TGoldDataRow>;
    function CreateDataTable(AMediaColumnsAsByteArray: Boolean): TDataTable;
    procedure ReleaseTableLock();
    procedure AddDataTable(ATable: TGoldDataTable);
    function GetNextNavDataTable(): TGoldDataTable;
    function GetEnumerator(): IEnumerator<TGoldDataRow>;
    function GetEnumerator(): IEnumerator;
    procedure Dispose();
    property HasDeliveredRows: Boolean read GetHasDeliveredRows write SetHasDeliveredRows;
    property RowsRead: Integer read GetRowsRead write SetRowsRead;
    property RowsAdded: Integer read GetRowsAdded write SetRowsAdded;
    property IsCachingData: Boolean read GetIsCachingData write SetIsCachingData;
    property CachedDataTables: TReadOnlyCollection<TGoldDataTable> read GetCachedDataTables write SetCachedDataTables;
    property EnumerationFinished: Boolean read GetEnumerationFinished write SetEnumerationFinished;
  end;


implementation

constructor TGoldDataTableCollectionEnumerator.Create(AWaitForEndSignal: Boolean; ACacheData: Boolean);
begin
  inherited Create;
  m_endSignal := not AWaitForEndSignal;
  Self.m_cacheData := ACacheData;
end;

procedure TGoldDataTableCollectionEnumerator.FinalDataTableAdded();
begin
  m_endSignal := true;
  ReleaseTableLock();
end;

function TGoldDataTableCollectionEnumerator.DecompressRows(): IList<TGoldDataRow>;
begin
  dataRows: TList<TGoldDataRow> := TList<TGoldDataRow>.Create;
  if m_endSignal and m_dataTables.Count > 0 then
  begin
    reader: TGoldDataTableReader := TGoldDataTableReader.Create(m_dataTables[0], AUpdateRow: false);
    // TODO: Converter BlockSyntax
  end
  ;
  Result := dataRows;
end;

function TGoldDataTableCollectionEnumerator.CreateDataTable(AMediaColumnsAsByteArray: Boolean): TDataTable;
begin
  dt: TDataTable := TDataTable.Create();
  if not m_endSignal or m_dataTables.Count <= 0 then
  begin
    Result := dt;
  end
  ;
  dt.Locale := m_dataTables[0].Locale;
  Result := m_dataTables[0].GetDataTable(AMediaColumnsAsByteArray);
end;

procedure TGoldDataTableCollectionEnumerator.ReleaseTableLock();
begin
  if m_tableLock <> null then
  begin
    m_tableLock.Release();
    m_tableLock := null;
  end
  ;
end;

procedure TGoldDataTableCollectionEnumerator.AddDataTable(ATable: TGoldDataTable);
begin
  // TODO: Converter LockStatementSyntax
end;

function TGoldDataTableCollectionEnumerator.GetNextNavDataTable(): TGoldDataTable;
begin
  // TODO: Converter WhileStatementSyntax
end;

function TGoldDataTableCollectionEnumerator.GetEnumerator(): IEnumerator<TGoldDataRow>;
begin
  m_enumerationFinished := false;
  // TODO: Converter ForStatementSyntax
  m_enumerationFinished := true;
end;

function TGoldDataTableCollectionEnumerator.GetEnumerator(): IEnumerator;
begin
  Result := GetEnumerator();
end;

procedure TGoldDataTableCollectionEnumerator.Dispose();
begin
  if m_tableLock <> null then
  begin
    ((IDisposable)m_tableLock).Dispose();
    m_tableLock := null;
  end
  ;
end;


end.
