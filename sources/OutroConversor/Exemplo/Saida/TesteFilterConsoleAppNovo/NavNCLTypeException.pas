unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLTypeException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateWrongLengthException(AType_: TGoldType): TGoldNCLNotSupportedTypeException;
    function CreateSourceHasWrongLengthException(AType_: TGoldType): TGoldNCLNotSupportedTypeException;
  end;


implementation

constructor TGoldNCLTypeException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLTypeException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLTypeException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLTypeException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLTypeException.CreateWrongLengthException(AType_: TGoldType): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(CultureInfo.InvariantCulture, "The supplied {0} does not contain the correct length.", AType_.ToString()));
end;

function TGoldNCLTypeException.CreateSourceHasWrongLengthException(AType_: TGoldType): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(CultureInfo.InvariantCulture, "The supplied m_data m_source with AType_ {0} does not contain the correct length.", AType_.ToString()));
end;


end.
