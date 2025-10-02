unit GoldERP.Runtime;

interface

type
  ISessionProvider = interface
    ['{00000000-0000-0000-0000-000000000000}']
    property Session: TGoldSession read GetSession write SetSession;
  end;


implementation


end.
