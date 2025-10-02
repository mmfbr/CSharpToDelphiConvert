unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TByteArrayHelper = class(TObject)
  public
    function Compare(ABinary1: byte[]; ABinary2: byte[]): Boolean;
  end;


implementation

function TByteArrayHelper.Compare(ABinary1: byte[]; ABinary2: byte[]): Boolean;
begin
  if ABinary1 = null and ABinary2 = null then
  begin
    Result := true;
  end
  ;
  if ABinary1 = null or ABinary2 = null then
  begin
    Result := false;
  end
  ;
  if ABinary1.Length <> ABinary2.Length then
  begin
    Result := false;
  end
  ;
  ints: Integer := ABinary1.Length / 8;
  bytes: Integer := ABinary1.Length mod 8;
  byteStart: Integer := ints * 8;
  // TODO: Converter FixedStatementSyntax
  // TODO: Converter ForStatementSyntax
  Result := true;
end;


end.
