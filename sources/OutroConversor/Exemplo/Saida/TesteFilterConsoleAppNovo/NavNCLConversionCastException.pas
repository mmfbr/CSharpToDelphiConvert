unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLConversionCastException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function Create(ACulture: TCultureInfo; AFromType: Type; AToType: Type): TGoldNCLConversionCastException;
    function Create(ACulture: TCultureInfo; AFromType: Type; AFromValue: TObject; AToType: Type): TGoldNCLConversionCastException;
  end;


implementation

constructor TGoldNCLConversionCastException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLConversionCastException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLConversionCastException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLConversionCastException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLConversionCastException.Create(ACulture: TCultureInfo; AFromType: Type; AToType: Type): TGoldNCLConversionCastException;
begin
  Result := Create(ACulture, AFromType, null, AToType);
end;

function TGoldNCLConversionCastException.Create(ACulture: TCultureInfo; AFromType: Type; AFromValue: TObject; AToType: Type): TGoldNCLConversionCastException;
begin
  message: String := (if AFromValue <> null then string.Format(ACulture, TLang.ConversionCastException, AFromType, AFromValue, AToType) else string.Format(ACulture, TLang._00095_50005, AFromType, AToType));
  Result := TGoldNCLConversionCastException.Create(message);
end;


end.
