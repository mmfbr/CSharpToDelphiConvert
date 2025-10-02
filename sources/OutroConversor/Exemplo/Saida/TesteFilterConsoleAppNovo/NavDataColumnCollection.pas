unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldDataColumnCollection = class(ICollection<TGoldDataColumn>)
  private
    m_table: TGoldDataTable;
    m_list: TList<TGoldDataColumn>;
    m_columnFromName: TDictionary<String, TGoldDataColumn>;
  public
    constructor Create(ATable: TGoldDataTable);
    function IndexOf(AColumn: TGoldDataColumn): Integer;
    function IndexOf(AColumnName: String): Integer;
    function Add(AColumnName: String; AType_: Type): TGoldDataColumn;
    function Add(AColumnName: String; ATypeCode: TGoldTypeCode): TGoldDataColumn;
    procedure Add(AColumn: TGoldDataColumn);
    procedure Clear();
    procedure RegisterColumnName(AColName: String; AColumn: TGoldDataColumn);
    procedure UnRegisterColumnName(AColName: String);
    function Contains(AItem: TGoldDataColumn): Boolean;
    function Contains(AColumnName: String): Boolean;
    function TryGetColumn(AColumnName: String; AColumn: TGoldDataColumn): Boolean;
    procedure CopyTo(AArray_: TGoldDataColumn[]; AArrayIndex: Integer);
    function Remove(AItem: TGoldDataColumn): Boolean;
    function GetEnumerator(): IEnumerator<TGoldDataColumn>;
    function GetEnumerator(): IEnumerator;
    property Count: Integer read GetCount write SetCount;
    property IsReadOnly: Boolean read GetIsReadOnly write SetIsReadOnly;
  end;


implementation

constructor TGoldDataColumnCollection.Create(ATable: TGoldDataTable);
begin
  inherited Create;
  if ATable = null then
  begin
    raise TArgumentNullException.Create("m_table");
  end
  ;
  Self.m_table := ATable;
  m_list := TList<TGoldDataColumn>.Create;
  m_columnFromName := TDictionary<string,TGoldDataColumn>.Create;
end;

function TGoldDataColumnCollection.IndexOf(AColumn: TGoldDataColumn): Integer;
begin
  Result := m_list.IndexOf(AColumn);
end;

function TGoldDataColumnCollection.IndexOf(AColumnName: String): Integer;
begin
  // TODO: Converter ForStatementSyntax
  Result := -1;
end;

function TGoldDataColumnCollection.Add(AColumnName: String; AType_: Type): TGoldDataColumn;
begin
  column: TGoldDataColumn := TGoldDataColumn.Create(AColumnName, AType_);
  Add(column);
  Result := column;
end;

function TGoldDataColumnCollection.Add(AColumnName: String; ATypeCode: TGoldTypeCode): TGoldDataColumn;
begin
  column: TGoldDataColumn := TGoldDataColumn.Create(AColumnName, ATypeCode);
  Add(column);
  Result := column;
end;

procedure TGoldDataColumnCollection.Add(AColumn: TGoldDataColumn);
begin
  if AColumn = null then
  begin
    raise TArgumentNullException.Create("AColumn");
  end
  ;
  if AColumn.Table = m_table then
  begin
    raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "Column '{0}' already belongs to this DataTable.", AColumn.ColumnName), "AColumn");
  end
  ;
  if AColumn.Table <> null then
  begin
    raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "Column '{0}' already belongs to another DataTable.", AColumn.ColumnName), "AColumn");
  end
  ;
  if m_table.Rows.Count > 0 then
  begin
    raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "Column '{0}' cannot be added. There are already m_rows in the DataTable.", AColumn.ColumnName), "AColumn");
  end
  ;
  if string.IsNullOrEmpty(AColumn.ColumnName) then
  begin
    AColumn.ColumnName := "Column" + m_list.Count.ToString(CultureInfo.InvariantCulture);
  end
  ;
  if m_columnFromName.ContainsKey(AColumn.ColumnName) then
  begin
    renameId: Integer := 0;
    dictionary: TDictionary<String, TGoldDataColumn>;
    columnName: String;
    num: Integer;
    // TODO: Converter DoStatementSyntax
    AColumn.ColumnName := AColumn.ColumnName + "_" + renameId;
  end
  ;
  m_list.Add(AColumn);
  RegisterColumnName(AColumn.ColumnName, AColumn);
  AColumn.Table := m_table;
end;

procedure TGoldDataColumnCollection.Clear();
begin
  m_list.Clear();
  m_columnFromName.Clear();
end;

procedure TGoldDataColumnCollection.RegisterColumnName(AColName: String; AColumn: TGoldDataColumn);
begin
  m_columnFromName.Add(AColName, AColumn);
end;

procedure TGoldDataColumnCollection.UnRegisterColumnName(AColName: String);
begin
  m_columnFromName.Remove(AColName);
end;

function TGoldDataColumnCollection.Contains(AItem: TGoldDataColumn): Boolean;
begin
  Result := m_list.Contains(AItem);
end;

function TGoldDataColumnCollection.Contains(AColumnName: String): Boolean;
begin
  if string.IsNullOrEmpty(AColumnName) then
  begin
    Result := false;
  end
  ;
  dataColumn: TGoldDataColumn := null;
  Result := m_columnFromName.TryGetValue(AColumnName, out dataColumn);
end;

function TGoldDataColumnCollection.TryGetColumn(AColumnName: String; AColumn: TGoldDataColumn): Boolean;
begin
  Result := m_columnFromName.TryGetValue(AColumnName, out AColumn);
end;

procedure TGoldDataColumnCollection.CopyTo(AArray_: TGoldDataColumn[]; AArrayIndex: Integer);
begin
  m_list.CopyTo(AArray_, AArrayIndex);
end;

function TGoldDataColumnCollection.Remove(AItem: TGoldDataColumn): Boolean;
begin
  if m_list.Remove(AItem) then
  begin
    UnRegisterColumnName(AItem.ColumnName);
    AItem.Table := null;
    Result := true;
  end
  ;
  Result := false;
end;

function TGoldDataColumnCollection.GetEnumerator(): IEnumerator<TGoldDataColumn>;
begin
  Result := m_list.GetEnumerator();
end;

function TGoldDataColumnCollection.GetEnumerator(): IEnumerator;
begin
  Result := m_list.GetEnumerator();
end;


end.
