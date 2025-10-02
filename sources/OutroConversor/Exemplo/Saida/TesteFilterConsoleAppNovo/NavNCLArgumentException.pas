unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLArgumentException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AArgument: TObject; AMethodName: String; AArgumentNumber: Integer);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateMessage(AArgument: TObject; AMethodName: String; AArgumentNumber: Integer): String;
  end;


implementation

constructor TGoldNCLArgumentException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLArgumentException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLArgumentException.Create(AArgument: TObject; AMethodName: String; AArgumentNumber: Integer);
begin
  inherited Create;
end;

constructor TGoldNCLArgumentException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLArgumentException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLArgumentException.CreateMessage(AArgument: TObject; AMethodName: String; AArgumentNumber: Integer): String;
begin
  Result := string.Format(CultureInfo.CurrentCulture, TLang._00095_50165, AArgument, AMethodName, AArgumentNumber);
end;


end.
