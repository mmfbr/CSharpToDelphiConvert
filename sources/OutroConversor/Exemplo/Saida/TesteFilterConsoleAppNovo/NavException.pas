unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldException = class(TGoldBaseException)
  public
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AInner: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AMessage: String; AInner: TException);
    constructor Create(AMessage: String; ADiagnosticsMessage: String; AInner: TException);
    function CreateFaultException(AFaultCode: String; AReason: String): TFaultException;
  end;


implementation

constructor TGoldException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

constructor TGoldException.Create();
begin
  inherited Create;
end;

constructor TGoldException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldException.Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldException.Create(AInner: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldException.Create(AMessage: String; AInner: TException);
begin
  inherited Create;
end;

constructor TGoldException.Create(AMessage: String; ADiagnosticsMessage: String; AInner: TException);
begin
  inherited Create;
end;

function TGoldException.CreateFaultException(AFaultCode: String; AReason: String): TFaultException;
begin
  senderFaultCode: TFaultCode := FaultCode.CreateSenderFaultCode(TFaultCode.Create(AFaultCode));
  Result := TFaultException.Create(AReason, senderFaultCode);
end;


end.
