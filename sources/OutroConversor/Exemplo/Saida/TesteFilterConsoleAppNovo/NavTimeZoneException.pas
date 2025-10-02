unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldTimeZoneException = class(TGoldBaseException)
  public
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
  end;


implementation

constructor TGoldTimeZoneException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

constructor TGoldTimeZoneException.Create();
begin
  inherited Create;
end;

constructor TGoldTimeZoneException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldTimeZoneException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;


end.
