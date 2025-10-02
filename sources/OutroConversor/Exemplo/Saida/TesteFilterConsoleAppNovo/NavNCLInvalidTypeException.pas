unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLInvalidTypeException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateExpectedType(ACulture: TCultureInfo; AExpectedType: Type): TGoldNCLInvalidTypeException;
  end;


implementation

constructor TGoldNCLInvalidTypeException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLInvalidTypeException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidTypeException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidTypeException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLInvalidTypeException.CreateExpectedType(ACulture: TCultureInfo; AExpectedType: Type): TGoldNCLInvalidTypeException;
begin
  Result := TGoldNCLInvalidTypeException.Create(string.Format(ACulture, TLang._00095_50001, AExpectedType));
end;


end.
