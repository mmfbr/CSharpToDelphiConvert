unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldCurrentThread = class(TObject)
  public
    property Session: TGoldSession read GetSession write SetSession;
  end;


implementation


end.
