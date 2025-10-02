unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  THashCodeHelper = class(TObject)
  public
    const m_DJB2SEED: Integer = 5381;
    function Djb2HashCode(AValue: byte[]): Integer;
    function CombineHashCodes(AH1: Integer; AH2: Integer): Integer;
    function CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer): Integer;
    function CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer; AH4: Integer): Integer;
    function CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer; AH4: Integer; AH5: Integer): Integer;
    function CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer; AH4: Integer; AH5: Integer; AH6: Integer): Integer;
  end;


implementation

function THashCodeHelper.Djb2HashCode(AValue: byte[]): Integer;
begin
  if AValue = null then
  begin
    Result := 0;
  end
  ;
  num: Integer := 5381;
  // TODO: Converter ForStatementSyntax
  Result := num;
end;

function THashCodeHelper.CombineHashCodes(AH1: Integer; AH2: Integer): Integer;
begin
  Result := ((AH1 << 5) + AH1 + (AH1 >> 27)) ^ h2;
end;

function THashCodeHelper.CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer): Integer;
begin
  Result := CombineHashCodes(CombineHashCodes(h1, h2), h3);
end;

function THashCodeHelper.CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer; AH4: Integer): Integer;
begin
  Result := CombineHashCodes(CombineHashCodes(h1, h2, h3), h4);
end;

function THashCodeHelper.CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer; AH4: Integer; AH5: Integer): Integer;
begin
  Result := CombineHashCodes(CombineHashCodes(h1, h2, h3, h4), h5);
end;

function THashCodeHelper.CombineHashCodes(AH1: Integer; AH2: Integer; AH3: Integer; AH4: Integer; AH5: Integer; AH6: Integer): Integer;
begin
  Result := CombineHashCodes(CombineHashCodes(h1, h2, h3, h4, h5), h6);
end;


end.
