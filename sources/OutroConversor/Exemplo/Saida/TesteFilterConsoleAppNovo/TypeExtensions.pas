unit GoldERP.Runtime.Utility;

interface

uses
  System.Classes, System.SysUtils;

type
  TTypeExtensions = class(TObject)
  public
    function IsSubClassOfGenericType(AToCheck: Type; AGeneric: Type): Boolean;
  end;


implementation

function TTypeExtensions.IsSubClassOfGenericType(AToCheck: Type; AGeneric: Type): Boolean;
begin
  // TODO: Converter WhileStatementSyntax
  Result := false;
end;


end.
