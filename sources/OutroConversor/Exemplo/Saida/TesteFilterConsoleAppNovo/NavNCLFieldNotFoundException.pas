unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLFieldNotFoundException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function Create(ACulture: TCultureInfo; AField: String; ATable: String): TGoldNCLFieldNotFoundException;
    function Create(ACulture: TCultureInfo; AField: Integer; ATable: String): TGoldNCLFieldNotFoundException;
  end;


implementation

constructor TGoldNCLFieldNotFoundException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLFieldNotFoundException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLFieldNotFoundException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLFieldNotFoundException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLFieldNotFoundException.Create(ACulture: TCultureInfo; AField: String; ATable: String): TGoldNCLFieldNotFoundException;
begin
  Result := TGoldNCLFieldNotFoundException.Create(string.Format(ACulture, TLang._00095_50022, AField, ATable));
end;

function TGoldNCLFieldNotFoundException.Create(ACulture: TCultureInfo; AField: Integer; ATable: String): TGoldNCLFieldNotFoundException;
begin
  Result := TGoldNCLFieldNotFoundException.Create(string.Format(ACulture, TLang._00095_50023, AField, ATable));
end;


end.
