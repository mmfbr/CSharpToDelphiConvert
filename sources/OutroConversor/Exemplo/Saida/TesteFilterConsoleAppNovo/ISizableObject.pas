unit GoldERP.Runtime;

interface

type
  ISizableObject = interface
    ['{00000000-0000-0000-0000-000000000000}']
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
  end;


implementation


end.
