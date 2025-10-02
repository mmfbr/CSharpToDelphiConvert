unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLTypeConversionException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AFromType: TGoldType; AToType: TGoldType);
    constructor Create(AFromType: TGoldType; AToType: TGoldType; AInnerException: TException);
    constructor Create(AFromType: Type; AToType: Type);
    constructor Create(AFromType: Type; AToType: Type; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateMessage(AFromType: TObject; AToType: TObject): String;
  end;


implementation

constructor TGoldNCLTypeConversionException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AFromType: TGoldType; AToType: TGoldType);
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AFromType: TGoldType; AToType: TGoldType; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AFromType: Type; AToType: Type);
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AFromType: Type; AToType: Type; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLTypeConversionException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLTypeConversionException.CreateMessage(AFromType: TObject; AToType: TObject): String;
begin
  Result := string.Format(CultureInfo.CurrentCulture, TLang._00095_50168, AFromType, AToType);
end;


end.
