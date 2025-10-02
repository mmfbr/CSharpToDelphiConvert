unit GoldERP.Runtime;

interface

type
  INavFieldMetadata = interface(INavValueMetadata)
    ['{00000000-0000-0000-0000-000000000000}']
    property ColumnIndex: Integer read GetColumnIndex write SetColumnIndex;
    property ExpressionContext: TFilterExpressionContext read GetExpressionContext write SetExpressionContext;
    property FieldClass: TFieldClass read GetFieldClass write SetFieldClass;
    property SqlDataType: TSqlDataType read GetSqlDataType write SetSqlDataType;
    property InitValue: TGoldValue read GetInitValue write SetInitValue;
    property EmptyValue: TGoldValue read GetEmptyValue write SetEmptyValue;
    property DescriptiveName: String read GetDescriptiveName write SetDescriptiveName;
    property DescriptiveParentName: String read GetDescriptiveParentName write SetDescriptiveParentName;
  end;


implementation


end.
