unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLDateInvalidException = class(TGoldNCLEvaluateException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldNCLDateInvalidException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLDateInvalidException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLDateInvalidException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLDateInvalidException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
