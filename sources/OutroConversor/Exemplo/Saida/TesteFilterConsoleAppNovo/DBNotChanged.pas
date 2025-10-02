unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TDBNotChanged = class(TObject)
  public
    constructor Create();
    function Equals(AObj: TObject): Boolean;
    function GetHashCode(): Integer;
  end;


implementation

constructor TDBNotChanged.Create();
begin
end;

function TDBNotChanged.Equals(AObj: TObject): Boolean;
begin
  Result := AObj is TDBNotChanged;
end;

function TDBNotChanged.GetHashCode(): Integer;
begin
  Result := 1;
end;


end.
