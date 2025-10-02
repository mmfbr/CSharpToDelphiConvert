unit GoldERP.Runtime;

interface

type
  IReferenceTarget = interface
    ['{00000000-0000-0000-0000-000000000000}']
    function GetReference(): IReference<T>;
  end;


implementation


end.
