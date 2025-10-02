unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldDataTableCollection = class(ICollection<TGoldDataTable>)
  private
    m_dataSet: TGoldDataSet;
    m_list: TList<TGoldDataTable>;
  public
    constructor Create(ADataSet: TGoldDataSet);
    function Add(AName: String): TGoldDataTable;
    procedure Clear();
    procedure Add(ATable: TGoldDataTable);
    function Contains(AItem: TGoldDataTable): Boolean;
    function Contains(ATableName: String): Boolean;
    procedure CopyTo(AArray_: TGoldDataTable[]; AArrayIndex: Integer);
    function Remove(AItem: TGoldDataTable): Boolean;
    function Remove(ATableName: String): Boolean;
    function FindTable(ATableName: String): TGoldDataTable;
    function GetEnumerator(): IEnumerator<TGoldDataTable>;
    function GetEnumerator(): IEnumerator;
    property Count: Integer read GetCount write SetCount;
    property IsReadOnly: Boolean read GetIsReadOnly write SetIsReadOnly;
  end;


implementation

constructor TGoldDataTableCollection.Create(ADataSet: TGoldDataSet);
begin
  inherited Create;
  if ADataSet = null then
  begin
    raise TArgumentNullException.Create("m_dataSet");
  end
  ;
  Self.m_dataSet := ADataSet;
  m_list := TList<TGoldDataTable>.Create;
end;

function TGoldDataTableCollection.Add(AName: String): TGoldDataTable;
begin
  newTable: TGoldDataTable := TGoldDataTable.Create(AName);
  Add(newTable);
  Result := newTable;
end;

procedure TGoldDataTableCollection.Clear();
begin
  // TODO: Converter ForStatementSyntax
  m_list.Clear();
end;

procedure TGoldDataTableCollection.Add(ATable: TGoldDataTable);
begin
  if ATable = null then
  begin
    raise TArgumentNullException.Create("m_table");
  end
  ;
  if ATable.DataSet = m_dataSet then
  begin
    raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "DataTable '{0}' already belongs to this dataset.", ATable.TableName), "m_table");
  end
  ;
  if ATable.DataSet <> null then
  begin
    raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "DataTable '{0}' already belongs to another dataset.", ATable.TableName), "m_table");
  end
  ;
  locale: TCultureInfo := m_dataSet.Locale;
  // TODO: Converter ForStatementSyntax
  ATable.DataSet := m_dataSet;
  m_list.Add(ATable);
end;

function TGoldDataTableCollection.Contains(AItem: TGoldDataTable): Boolean;
begin
  Result := m_list.Contains(AItem);
end;

function TGoldDataTableCollection.Contains(ATableName: String): Boolean;
begin
  Result := FindTable(ATableName) <> null;
end;

procedure TGoldDataTableCollection.CopyTo(AArray_: TGoldDataTable[]; AArrayIndex: Integer);
begin
  m_list.CopyTo(AArray_, AArrayIndex);
end;

function TGoldDataTableCollection.Remove(AItem: TGoldDataTable): Boolean;
begin
  if AItem <> null then
  begin
    AItem.DataSet := null;
  end
  ;
  Result := m_list.Remove(AItem);
end;

function TGoldDataTableCollection.Remove(ATableName: String): Boolean;
begin
  Result := Remove(FindTable(ATableName));
end;

function TGoldDataTableCollection.FindTable(ATableName: String): TGoldDataTable;
begin
  // TODO: Converter ForStatementSyntax
  Result := null;
end;

function TGoldDataTableCollection.GetEnumerator(): IEnumerator<TGoldDataTable>;
begin
  Result := m_list.GetEnumerator();
end;

function TGoldDataTableCollection.GetEnumerator(): IEnumerator;
begin
  Result := m_list.GetEnumerator();
end;


end.
