unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLEnumerationNotSequencedException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldNCLEnumerationNotSequencedException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLEnumerationNotSequencedException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLEnumerationNotSequencedException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLEnumerationNotSequencedException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
