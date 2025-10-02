unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TALCompiler = class(TObject)
  public
    function ToInt32(AFromValue: Int64): Integer;
  end;


implementation

function TALCompiler.ToInt32(AFromValue: Int64): Integer;
begin
  // TODO: Converter TryStatementSyntax
end;


end.
