unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldClientBaseException = class(TGoldBaseException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create(AMessage: String; AInnerException: TException);
  end;


implementation

constructor TGoldClientBaseException.Create();
begin
  inherited Create;
end;

constructor TGoldClientBaseException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldClientBaseException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

constructor TGoldClientBaseException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;


end.
