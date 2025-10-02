unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldClientIOException = class(TGoldClientBaseException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create(AMessage: String; AInnerException: TException);
  end;


implementation

constructor TGoldClientIOException.Create();
begin
  inherited Create;
end;

constructor TGoldClientIOException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldClientIOException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

constructor TGoldClientIOException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;


end.
