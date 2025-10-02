unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLException = class(TGoldException)
  public
    constructor Create();
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AMessage: String);
    constructor Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AInnerException: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
  end;


implementation

constructor TGoldNCLException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLException.Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldNCLException.Create(AInnerException: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldNCLException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;


end.
