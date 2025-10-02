unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataColumnPropertyDescriptor = class(TPropertyDescriptor)
  private
    m_dataTableReader: TGoldDataTableReader;
    m_columnIndex: Integer;
  public
    constructor Create(ADataTableReader: TGoldDataTableReader; AColumn: TGoldDataColumn);
    function GetValue(AComponent: TObject): TObject;
    function CanResetValue(AComponent: TObject): Boolean;
    procedure ResetValue(AComponent: TObject);
    procedure SetValue(AComponent: TObject; AValue: TObject);
    function ShouldSerializeValue(AComponent: TObject): Boolean;
    property ComponentType: Type read GetComponentType write SetComponentType;
    property IsReadOnly: Boolean read GetIsReadOnly write SetIsReadOnly;
    property PropertyType: Type read GetPropertyType write SetPropertyType;
  end;


implementation

constructor TGoldDataColumnPropertyDescriptor.Create(ADataTableReader: TGoldDataTableReader; AColumn: TGoldDataColumn);
begin
  inherited Create;
  m_columnIndex := AColumn.ColumnIndex;
  Self.m_dataTableReader := ADataTableReader;
end;

function TGoldDataColumnPropertyDescriptor.GetValue(AComponent: TObject): TObject;
begin
  dataRow: TGoldDataRow := (TGoldDataRow)AComponent;
  Result := m_dataTableReader.GetValue(dataRow, m_columnIndex);
end;

function TGoldDataColumnPropertyDescriptor.CanResetValue(AComponent: TObject): Boolean;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

procedure TGoldDataColumnPropertyDescriptor.ResetValue(AComponent: TObject);
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

procedure TGoldDataColumnPropertyDescriptor.SetValue(AComponent: TObject; AValue: TObject);
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;

function TGoldDataColumnPropertyDescriptor.ShouldSerializeValue(AComponent: TObject): Boolean;
begin
  raise TNotImplementedException.Create("The method or operation is not implemented.");
end;


end.
