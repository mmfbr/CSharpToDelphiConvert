unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLNotSupportedTypeException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateSplitKeyType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
    function CreateArrayCloneNotSupportedType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
    function CreateUnknownType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
    function CreateUnsupportedGetType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
    function CreateReadFromBytesNotSupportedType(ACulture: TCultureInfo; AType_: TGoldType): TGoldNCLNotSupportedTypeException;
    function CreateUnsupportedType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
  end;


implementation

constructor TGoldNCLNotSupportedTypeException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLNotSupportedTypeException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLNotSupportedTypeException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLNotSupportedTypeException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLNotSupportedTypeException.CreateSplitKeyType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(ACulture, TLang.FormUnsupportedSplitKeyType, ATypeName));
end;

function TGoldNCLNotSupportedTypeException.CreateArrayCloneNotSupportedType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(ACulture, TLang.ArrayCloneIllegalType, ATypeName));
end;

function TGoldNCLNotSupportedTypeException.CreateUnknownType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(ACulture, TLang._00095_50017, ATypeName));
end;

function TGoldNCLNotSupportedTypeException.CreateUnsupportedGetType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(ACulture, TLang.GetDotNetType, ATypeName));
end;

function TGoldNCLNotSupportedTypeException.CreateReadFromBytesNotSupportedType(ACulture: TCultureInfo; AType_: TGoldType): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(ACulture, "The supplied {0} is not supported when reading from a byte[].", AType_));
end;

function TGoldNCLNotSupportedTypeException.CreateUnsupportedType(ACulture: TCultureInfo; ATypeName: String): TGoldNCLNotSupportedTypeException;
begin
  Result := TGoldNCLNotSupportedTypeException.Create(string.Format(ACulture, TLang.GoldTypeIsNotSupported, ATypeName));
end;


end.
