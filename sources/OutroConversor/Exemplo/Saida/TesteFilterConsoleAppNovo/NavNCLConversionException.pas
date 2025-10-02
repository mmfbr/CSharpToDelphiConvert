unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLConversionException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AFromTypeName: TGoldType; AToTypeName: TGoldType);
    constructor Create(AFromType: Type; AToType: Type);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateMessage(AFromType: TObject; AToType: TObject): String;
  end;


implementation

constructor TGoldNCLConversionException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLConversionException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLConversionException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLConversionException.Create(AFromTypeName: TGoldType; AToTypeName: TGoldType);
begin
  inherited Create;
end;

constructor TGoldNCLConversionException.Create(AFromType: Type; AToType: Type);
begin
  inherited Create;
end;

constructor TGoldNCLConversionException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLConversionException.CreateMessage(AFromType: TObject; AToType: TObject): String;
begin
  Result := string.Format(CultureInfo.CurrentCulture, TLang._00095_50167, AFromType, AToType);
end;


end.
