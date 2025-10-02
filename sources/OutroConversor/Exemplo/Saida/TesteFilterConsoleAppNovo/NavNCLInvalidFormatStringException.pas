unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLInvalidFormatStringException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function Create(ACulture: TCultureInfo; AFormat: String): TGoldNCLInvalidFormatStringException;
  end;


implementation

constructor TGoldNCLInvalidFormatStringException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLInvalidFormatStringException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidFormatStringException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidFormatStringException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLInvalidFormatStringException.Create(ACulture: TCultureInfo; AFormat: String): TGoldNCLInvalidFormatStringException;
begin
  Result := TGoldNCLInvalidFormatStringException.Create(string.Format(ACulture, TLang.InvalidFormatString, AFormat));
end;


end.
