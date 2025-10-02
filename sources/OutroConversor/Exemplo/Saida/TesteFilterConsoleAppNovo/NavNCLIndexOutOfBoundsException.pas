unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLIndexOutOfBoundsException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldNCLIndexOutOfBoundsException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLIndexOutOfBoundsException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLIndexOutOfBoundsException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLIndexOutOfBoundsException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
