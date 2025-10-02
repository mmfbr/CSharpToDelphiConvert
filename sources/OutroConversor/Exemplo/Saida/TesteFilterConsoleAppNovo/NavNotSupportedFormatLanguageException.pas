unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNotSupportedFormatLanguageException = class(TGoldNotSupportedLanguageException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldNotSupportedFormatLanguageException.Create();
begin
  inherited Create;
end;

constructor TGoldNotSupportedFormatLanguageException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNotSupportedFormatLanguageException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNotSupportedFormatLanguageException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
