unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TSizableObject = class(TObject)
  public
    const m_ObjectInstanceByteOverhead: Integer = 24;
    function GetApproximateByteSize(ASizableObjects: ISizableObject[]): Integer;
    function GetApproximateByteSize(ANavValues: TGoldValue[]): Integer;
    function GetApproximateByteSize(ANumberOfObjectFields: Integer): Integer;
    function ApproximateByteSizeForNclType(ANclType: TGoldNclType; ADefinedLength: Integer): Integer;
    function ApproximateByteSizeForNavValue(ANavValue: TGoldValue): Integer;
  end;


implementation

function TSizableObject.GetApproximateByteSize(ASizableObjects: ISizableObject[]): Integer;
begin
  if sizableObjects = null then
  begin
    Result := 0;
  end
  ;
  num: Integer := 0;
  for sizableObject in sizableObjects do
  begin
    if sizableObject <> null then
    begin
      num := sizableObject.ApproximateByteSize;
    end
    ;
  end;
  Result := num;
end;

function TSizableObject.GetApproximateByteSize(ANavValues: TGoldValue[]): Integer;
begin
  if navValues = null then
  begin
    Result := 0;
  end
  ;
  num: Integer := 0;
  for navValue in navValues do
  begin
    if navValue <> null then
    begin
      num := ApproximateByteSizeForNavValue(navValue) + 24;
    end
    ;
  end;
  Result := num;
end;

function TSizableObject.GetApproximateByteSize(ANumberOfObjectFields: Integer): Integer;
begin
  Result := numberOfObjectFields * 8;
end;

function TSizableObject.ApproximateByteSizeForNclType(ANclType: TGoldNclType; ADefinedLength: Integer): Integer;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TSizableObject.ApproximateByteSizeForNavValue(ANavValue: TGoldValue): Integer;
begin
  // TODO: Converter SwitchStatementSyntax
end;


end.
