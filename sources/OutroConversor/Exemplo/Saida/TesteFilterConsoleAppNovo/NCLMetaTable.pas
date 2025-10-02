unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TNCLMetaTable = class(TObject)
  private
    m_fieldIndexByName: TDictionary<String, Integer>;
    m_timestampField: TNCLMetaField;
    m_sourceAppId: TGuid;
  public
    function TryGetFieldIndexByName(AFieldName: String; AFieldIndex: Integer): Boolean;
    property TableId: Integer read GetTableId write SetTableId;
    property TableName: String read GetTableName write SetTableName;
    property TableCaptionSafe: String read GetTableCaptionSafe write SetTableCaptionSafe;
    property ExternalName: String read GetExternalName write SetExternalName;
    property ExternalSchema: String read GetExternalSchema write SetExternalSchema;
    property FieldCount: Integer read GetFieldCount write SetFieldCount;
    property TimestampField: TNCLMetaField read GetTimestampField write SetTimestampField;
    property AllFields: TNCLMetaField[] read GetAllFields write SetAllFields;
  end;


implementation

function TNCLMetaTable.TryGetFieldIndexByName(AFieldName: String; AFieldIndex: Integer): Boolean;
begin
  if m_fieldIndexByName = null then
  begin
    dictionary: TDictionary<String, Integer> := new Dictionary<string, int>(FieldCount, StringComparer.OrdinalIgnoreCase);
    num: Integer := 0;
    // TODO: Converter TryStatementSyntax
    m_fieldIndexByName := dictionary;
  end
  ;
  if m_fieldIndexByName.TryGetValue(fieldName, out fieldIndex) then
  begin
    Result := true;
  end
  ;
  fieldIndex := -1;
  Result := false;
end;


end.
