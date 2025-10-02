unit GoldERP.Runtime;

interface

type
  INavValueMetadata = interface
    ['{00000000-0000-0000-0000-000000000000}']
    property GoldType: TGoldType read GetGoldType write SetGoldType;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GoldDefinedLengthMetadata: Integer read GetGoldDefinedLengthMetadata write SetGoldDefinedLengthMetadata;
  end;


implementation


end.
