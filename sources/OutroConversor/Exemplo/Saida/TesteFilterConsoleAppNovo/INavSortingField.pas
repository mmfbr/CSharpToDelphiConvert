unit GoldERP.Runtime;

interface

type
  INavSortingField = interface
    ['{00000000-0000-0000-0000-000000000000}']
    property Order: TSortOrder read GetOrder write SetOrder;
    property Field: INavFieldMetadata read GetField write SetField;
  end;


implementation


end.
