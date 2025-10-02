unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TCannotConvertWildcardIntoRangeException = class(TGoldBaseException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInner: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TCannotConvertWildcardIntoRangeException.Create();
begin
  inherited Create;
end;

constructor TCannotConvertWildcardIntoRangeException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TCannotConvertWildcardIntoRangeException.Create(AMessage: String; AInner: TException);
begin
  inherited Create;
end;

constructor TCannotConvertWildcardIntoRangeException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
