unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TNCLMetaField = class(INavFieldMetadata)
  private
    m_fieldNo: Integer;
    m_fieldNclType: TGoldNclType;
    m_sqlType: TSqlDataType;
    m_fieldDefinedLength: Integer;
    m_fieldClass: TFieldClass;
    m_fieldName: String;
    m_emptyValue: TGoldValue;
    m_expressionContext: TFilterExpressionContext;
    m_externalMetadata: TExternalMetadata;
    m_parent: TNCLMetaTable;
    m_fieldIndex: Integer;
    m_initialValueText: String;
    m_initValue: TGoldValue;
    m_sqlColumnName: String;
  public
    constructor Create(AFieldNo: Integer; AFieldNclType: TGoldNclType; ASqlType: TSqlDataType; AFieldDefinedLength: Integer; AFieldClass: TFieldClass; AFieldName: String; AParent: TNCLMetaTable);
    property Parent: TNCLMetaTable read GetParent write SetParent;
    property FieldNo: Integer read GetFieldNo write SetFieldNo;
    property FieldNavType: TGoldType read GetFieldNavType write SetFieldNavType;
    property FieldNclType: TGoldNclType read GetFieldNclType write SetFieldNclType;
    property FieldDefinedLength: Integer read GetFieldDefinedLength write SetFieldDefinedLength;
    property FieldClass: TFieldClass read GetFieldClass write SetFieldClass;
    property InitValue: TGoldValue read GetInitValue write SetInitValue;
    property EmptyValue: TGoldValue read GetEmptyValue write SetEmptyValue;
    property FieldName: String read GetFieldName write SetFieldName;
    property FieldIsUserDefinedTimestamp: Boolean read GetFieldIsUserDefinedTimestamp write SetFieldIsUserDefinedTimestamp;
    property ExternalName: String read GetExternalName write SetExternalName;
    property SqlColumnName: String read GetSqlColumnName write SetSqlColumnName;
    property GoldType: TGoldType read GetGoldType write SetGoldType;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GoldDefinedLengthMetadata: Integer read GetGoldDefinedLengthMetadata write SetGoldDefinedLengthMetadata;
    property ColumnIndex: Integer read GetColumnIndex write SetColumnIndex;
    property DescriptiveName: String read GetDescriptiveName write SetDescriptiveName;
    property DescriptiveParentName: String read GetDescriptiveParentName write SetDescriptiveParentName;
    property IsStringType: Boolean read GetIsStringType write SetIsStringType;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
    property SqlDataType: TSqlDataType read GetSqlDataType write SetSqlDataType;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property Order: TSortOrder read GetOrder write SetOrder;
    property Field: INavFieldMetadata read GetField write SetField;
  end;


implementation

constructor TNCLMetaField.Create(AFieldNo: Integer; AFieldNclType: TGoldNclType; ASqlType: TSqlDataType; AFieldDefinedLength: Integer; AFieldClass: TFieldClass; AFieldName: String; AParent: TNCLMetaTable);
begin
  inherited Create;
  referencingField: TNCLMetaField := this;
  Self.m_parent := parent;
  Self.m_fieldNo := fieldNo;
  Self.m_fieldNclType := fieldNclType;
  Self.m_sqlType := sqlType;
  Self.m_fieldDefinedLength := fieldDefinedLength;
  Self.m_fieldClass := fieldClass;
  Self.m_fieldName := fieldName;
  Self.m_fieldIndex := fieldNo - 1;
end;


end.
