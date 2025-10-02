unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TALSystemString = class(TObject)
  public
    function GetChar(AValue: String; AIndex: Integer): Char;
    function GetCharAsByte(AValue: String; AIndex: Integer): Byte;
    function ALPadStr(ASource: String; ALength: Integer; APadCharacter: String): String;
    function ALInsStr(ASource: String; AInsert: String; AIndex1Based: Integer): String;
  end;


implementation

function TALSystemString.GetChar(AValue: String; AIndex: Integer): Char;
begin
  if AValue = null then
  begin
    AValue := string.Empty;
  end
  ;
  if AIndex < 0 then
  begin
    raise TGoldNCLOutsidePermittedRangeException.Create("INDEXING", 1, AIndex, 0, int.MaxValue);
  end
  ;
  if AIndex >= AValue.Length then
  begin
    Result := '\0';
  end
  ;
  Result := AValue[AIndex];
end;

function TALSystemString.GetCharAsByte(AValue: String; AIndex: Integer): Byte;
begin
  Result := TNCLManagedAdapter.TextCharToByte(GetChar(AValue, AIndex));
end;

function TALSystemString.ALPadStr(ASource: String; ALength: Integer; APadCharacter: String): String;
begin
  if ASource = null then
  begin
    raise TArgumentNullException.Create("m_source");
  end
  ;
  if APadCharacter = null then
  begin
    raise TArgumentNullException.Create("APadCharacter");
  end
  ;
  if ALength < 0 then
  begin
    raise TGoldNCLOutsidePermittedRangeException.Create("PADSTR", 2, ALength, 0, int.MaxValue);
  end
  ;
  if APadCharacter.Length <> 1 then
  begin
    raise TGoldNCLOutsidePermittedRangeException.Create("PADSTR", 3, APadCharacter.Length, 1, 1);
  end
  ;
  if ASource.Length = 0 then
  begin
    Result := Tstring.Create(APadCharacter[0], ALength);
  end
  ;
  if ALength > ASource.Length then
  begin
    Result := ASource.PadRight(ALength, APadCharacter[0]);
  end
  ;
  if ALength < ASource.Length then
  begin
    Result := ASource.Substring(0, ALength);
  end
  ;
  Result := ASource;
end;

function TALSystemString.ALInsStr(ASource: String; AInsert: String; AIndex1Based: Integer): String;
begin
  if ASource = null then
  begin
    raise TArgumentNullException.Create("m_source");
  end
  ;
  if AInsert = null then
  begin
    raise TArgumentNullException.Create("AInsert");
  end
  ;
  if AIndex1Based < 1 then
  begin
    raise TGoldNCLOutsidePermittedRangeException.Create("INSSTR", 3, AIndex1Based, 1, int.MaxValue);
  end
  ;
  if AInsert.Length = 0 then
  begin
    Result := ASource;
  end
  ;
  if AIndex1Based > ASource.Length then
  begin
    Result := ASource + AInsert;
  end
  ;
  Result := ASource.Insert(AIndex1Based - 1, AInsert);
end;


end.
