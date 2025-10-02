unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLInvalidStringFormatException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateNoValueForIndex(ACulture: TCultureInfo; ASource: String; AIndex: Integer): TGoldNCLInvalidStringFormatException;
    function CreateNotEqualLengthForConvert(ACulture: TCultureInfo; AFromCharacters: String; AToCharacters: String): TGoldNCLInvalidStringFormatException;
  end;


implementation

constructor TGoldNCLInvalidStringFormatException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLInvalidStringFormatException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidStringFormatException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidStringFormatException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLInvalidStringFormatException.CreateNoValueForIndex(ACulture: TCultureInfo; ASource: String; AIndex: Integer): TGoldNCLInvalidStringFormatException;
begin
  Result := TGoldNCLInvalidStringFormatException.Create(string.Format(ACulture, TLang.ALSelectStringCommaStringIndexNotValue, ASource, AIndex));
end;

function TGoldNCLInvalidStringFormatException.CreateNotEqualLengthForConvert(ACulture: TCultureInfo; AFromCharacters: String; AToCharacters: String): TGoldNCLInvalidStringFormatException;
begin
  Result := TGoldNCLInvalidStringFormatException.Create(string.Format(ACulture, TLang.ALConvertStringExpectsEqualLength, AFromCharacters, AToCharacters));
end;


end.
