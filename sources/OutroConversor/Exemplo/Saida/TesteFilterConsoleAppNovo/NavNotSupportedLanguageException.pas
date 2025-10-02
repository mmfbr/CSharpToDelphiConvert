unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNotSupportedLanguageException = class(TGoldBaseException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldNotSupportedLanguageException.Create();
begin
  inherited Create;
end;

constructor TGoldNotSupportedLanguageException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNotSupportedLanguageException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNotSupportedLanguageException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
