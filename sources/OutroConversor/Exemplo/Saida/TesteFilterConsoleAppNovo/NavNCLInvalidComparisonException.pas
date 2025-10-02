unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLInvalidComparisonException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function Create(ACulture: TCultureInfo; ANavTypeName: String; AUnsupportedTypeName: String): TGoldNCLInvalidComparisonException;
  end;


implementation

constructor TGoldNCLInvalidComparisonException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLInvalidComparisonException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidComparisonException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLInvalidComparisonException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLInvalidComparisonException.Create(ACulture: TCultureInfo; ANavTypeName: String; AUnsupportedTypeName: String): TGoldNCLInvalidComparisonException;
begin
  Result := TGoldNCLInvalidComparisonException.Create(string.Format(ACulture, TLang.InvalidComparison, ANavTypeName, AUnsupportedTypeName));
end;


end.
