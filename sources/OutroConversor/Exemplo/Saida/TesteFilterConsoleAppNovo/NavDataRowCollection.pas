unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldDataRowCollection = class(ICollection<TGoldDataRow>)
  private
    m_table: TGoldDataTable;
    m_list: TList<TGoldDataRow>;
  public
    constructor Create(ATable: TGoldDataTable);
    procedure Add(ARow: TGoldDataRow);
    procedure AddClone(ARow: TGoldDataRow);
    procedure Add(ARowValues: object[]);
    procedure Clear();
    function Contains(AItem: TGoldDataRow): Boolean;
    procedure CopyTo(AArray_: TGoldDataRow[]; AArrayIndex: Integer);
    function Remove(AItem: TGoldDataRow): Boolean;
    function GetEnumerator(): IEnumerator<TGoldDataRow>;
    function GetEnumerator(): IEnumerator;
    property Count: Integer read GetCount write SetCount;
    property IsReadOnly: Boolean read GetIsReadOnly write SetIsReadOnly;
  end;


implementation

constructor TGoldDataRowCollection.Create(ATable: TGoldDataTable);
begin
  inherited Create;
  Self.m_table := ATable;
  m_list := TList<TGoldDataRow>.Create;
end;

procedure TGoldDataRowCollection.Add(ARow: TGoldDataRow);
begin
  if ARow = null then
  begin
    raise TArgumentNullException.Create("ARow");
  end
  ;
  if ARow.Table <> m_table then
  begin
    raise TArgumentException.Create("Row already belongs to another DataTable.", "ARow");
  end
  ;
  m_list.Add(ARow);
end;

procedure TGoldDataRowCollection.AddClone(ARow: TGoldDataRow);
begin
  if ARow = null then
  begin
    raise TArgumentNullException.Create("ARow");
  end
  ;
  if ARow.Table = m_table then
  begin
    Add(ARow.Clone());
  end
  else
  begin
    Add(ARow.CloneTo(m_table));
  end;
end;

procedure TGoldDataRowCollection.Add(ARowValues: object[]);
begin
  row: TGoldDataRow := m_table.NewRow();
  row.ItemArray := ARowValues;
  m_list.Add(row);
end;

procedure TGoldDataRowCollection.Clear();
begin
  m_list.Clear();
end;

function TGoldDataRowCollection.Contains(AItem: TGoldDataRow): Boolean;
begin
  Result := m_list.Contains(AItem);
end;

procedure TGoldDataRowCollection.CopyTo(AArray_: TGoldDataRow[]; AArrayIndex: Integer);
begin
  m_list.CopyTo(AArray_, AArrayIndex);
end;

function TGoldDataRowCollection.Remove(AItem: TGoldDataRow): Boolean;
begin
  Result := m_list.Remove(AItem);
end;

function TGoldDataRowCollection.GetEnumerator(): IEnumerator<TGoldDataRow>;
begin
  Result := m_list.GetEnumerator();
end;

function TGoldDataRowCollection.GetEnumerator(): IEnumerator;
begin
  Result := m_list.GetEnumerator();
end;


end.
