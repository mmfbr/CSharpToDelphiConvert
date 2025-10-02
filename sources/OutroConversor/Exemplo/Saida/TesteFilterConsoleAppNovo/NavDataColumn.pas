unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDataColumn = class(TObject)
  private
    m_columnName: String;
    m_dataType: Type;
    m_table: TGoldDataTable;
    m_extendedProperties: THashtable;
    m_tableColumnIndex: Integer;
  public
    constructor Create();
    constructor Create(AColumnName: String; ATypeCode: TGoldTypeCode);
    constructor Create(AColumnName: String; ADataType: Type);
    constructor Create(AColumnName: String; ADataType: Type; ATable: TGoldDataTable);
    constructor Create(AColumnName: String; ADataType: Type; ATypeCode: TGoldTypeCode; ATable: TGoldDataTable);
    function Clone(): TGoldDataColumn;
    property HasExtendedProperties: Boolean read GetHasExtendedProperties write SetHasExtendedProperties;
    property ExtendedProperties: THashtable read GetExtendedProperties write SetExtendedProperties;
    property ColumnName: String read GetColumnName write SetColumnName;
    property DataType: Type read GetDataType write SetDataType;
    property GoldTypeCode: TGoldTypeCode read GetGoldTypeCode write SetGoldTypeCode;
    property Table: TGoldDataTable read GetTable write SetTable;
    property ColumnIndex: Integer read GetColumnIndex write SetColumnIndex;
  end;


implementation

constructor TGoldDataColumn.Create();
begin
end;

constructor TGoldDataColumn.Create(AColumnName: String; ATypeCode: TGoldTypeCode);
begin
end;

constructor TGoldDataColumn.Create(AColumnName: String; ADataType: Type);
begin
end;

constructor TGoldDataColumn.Create(AColumnName: String; ADataType: Type; ATable: TGoldDataTable);
begin
  Self.m_columnName := AColumnName ?? string.Empty;
  DataType := ADataType ?? typeof(string);
  Self.m_table := ATable;
end;

constructor TGoldDataColumn.Create(AColumnName: String; ADataType: Type; ATypeCode: TGoldTypeCode; ATable: TGoldDataTable);
begin
  Self.m_columnName := AColumnName ?? string.Empty;
  if ADataType = null then
  begin
    DataType := typeof(string);
  end
  else
  begin
    Self.m_dataType := ADataType;
    GoldTypeCode := ATypeCode;
  end;
  Self.m_table := ATable;
end;

function TGoldDataColumn.Clone(): TGoldDataColumn;
begin
  clone: TGoldDataColumn := TGoldDataColumn.Create(m_columnName, m_dataType, GoldTypeCode, m_table);
  clone.m_tableColumnIndex := m_tableColumnIndex;
  if HasExtendedProperties then
  begin
    clone.m_extendedProperties := (Hashtable)ExtendedProperties.Clone();
  end
  ;
  Result := clone;
end;


end.
