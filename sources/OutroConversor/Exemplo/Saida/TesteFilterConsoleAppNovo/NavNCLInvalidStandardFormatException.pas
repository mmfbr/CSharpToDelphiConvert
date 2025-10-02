unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLInvalidStandardFormatException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function Create(ACulture: TCultureInfo; AFormatType: Integer; AType_: TGoldType): TGoldNCLInvalidStandardFormatException;
  end;


implementation

constructor TGoldNCLInvalidStandardFormatException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLInvalidStandardFormatException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidStandardFormatException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidStandardFormatException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLInvalidStandardFormatException.Create(ACulture: TCultureInfo; AFormatType: Integer; AType_: TGoldType): TGoldNCLInvalidStandardFormatException;
begin
  Result := TGoldNCLInvalidStandardFormatException.Create(string.Format(ACulture, TLang.InvalidStandardFormat, AFormatType, AType_.ToString()));
end;


end.
