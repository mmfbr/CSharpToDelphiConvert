unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldObject = class(TObject)
  public
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property GoldType: TGoldType read GetGoldType write SetGoldType;
  end;


implementation


end.
