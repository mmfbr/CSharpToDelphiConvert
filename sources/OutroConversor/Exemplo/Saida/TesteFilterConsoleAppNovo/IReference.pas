unit GoldERP.Runtime;

interface

type
  IReference = interface
    ['{00000000-0000-0000-0000-000000000000}']
    property Target: T read GetTarget write SetTarget;
    property TargetSafe: T read GetTargetSafe write SetTargetSafe;
    procedure ClearTarget();
  end;


implementation


end.
