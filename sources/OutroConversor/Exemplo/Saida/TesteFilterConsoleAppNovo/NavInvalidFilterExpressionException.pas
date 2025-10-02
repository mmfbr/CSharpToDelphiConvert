unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldInvalidFilterExpressionException = class(TGoldBaseException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInner: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldInvalidFilterExpressionException.Create();
begin
  inherited Create;
end;

constructor TGoldInvalidFilterExpressionException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldInvalidFilterExpressionException.Create(AMessage: String; AInner: TException);
begin
  inherited Create;
end;

constructor TGoldInvalidFilterExpressionException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
