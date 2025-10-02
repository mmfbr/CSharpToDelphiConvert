unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldErrorCodeException = class(TGoldException)
  private
    m_errorCode: Integer;
  public
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create(AMessage: String);
    constructor Create(AErrorCode: Integer; AMessage: String);
    constructor Create(AErrorCode: Integer; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AErrorCode: Integer; AInner: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AErrorCode: Integer; AMessage: String; AInnerException: TException);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AMessage: String; ADiagnosticsMessage: String; AInnerException: TException);
    constructor Create();
    procedure GetObjectData(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CalcErrorCode(AErrorNumber: Integer; AModuleNumber: Integer): Integer;
    function GetErrorNumber(AErrorCode: Integer): Integer;
    function GetModuleNumber(AErrorCode: Integer): Integer;
    procedure UpdateCloneCore(AExceptionClone: TGoldBaseException);
    property ErrorCode: Integer read GetErrorCode write SetErrorCode;
    property ErrorNumber: Integer read GetErrorNumber write SetErrorNumber;
    property ModuleNumber: TModuleId read GetModuleNumber write SetModuleNumber;
  end;


implementation

constructor TGoldErrorCodeException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
  if AInfo = null then
  begin
    raise TArgumentNullException.Create("AInfo");
  end
  ;
  m_errorCode := AInfo.GetInt32("ErrorCode");
end;

constructor TGoldErrorCodeException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldErrorCodeException.Create(AErrorCode: Integer; AMessage: String);
begin
  inherited Create;
  Self.m_errorCode := AErrorCode;
end;

constructor TGoldErrorCodeException.Create(AErrorCode: Integer; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
  Self.m_errorCode := AErrorCode;
end;

constructor TGoldErrorCodeException.Create(AErrorCode: Integer; AInner: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
  Self.m_errorCode := AErrorCode;
end;

constructor TGoldErrorCodeException.Create(AErrorCode: Integer; AMessage: String; AInnerException: TException);
begin
  inherited Create;
  Self.m_errorCode := AErrorCode;
end;

constructor TGoldErrorCodeException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldErrorCodeException.Create(AMessage: String; ADiagnosticsMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldErrorCodeException.Create();
begin
  inherited Create;
end;

procedure TGoldErrorCodeException.GetObjectData(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  if AInfo = null then
  begin
    raise TArgumentNullException.Create("AInfo");
  end
  ;
  AInfo.AddValue("ErrorCode", m_errorCode);
  base.GetObjectData(AInfo, AContext);
end;

function TGoldErrorCodeException.CalcErrorCode(AErrorNumber: Integer; AModuleNumber: Integer): Integer;
begin
  Result := (AModuleNumber << 16) + AErrorNumber;
end;

function TGoldErrorCodeException.GetErrorNumber(AErrorCode: Integer): Integer;
begin
  Result := AErrorCode & 0xFFFF;
end;

function TGoldErrorCodeException.GetModuleNumber(AErrorCode: Integer): Integer;
begin
  Result := (byte)(AErrorCode >> 16);
end;

procedure TGoldErrorCodeException.UpdateCloneCore(AExceptionClone: TGoldBaseException);
begin
  base.UpdateCloneCore(AExceptionClone);
  (AExceptionClone as TGoldErrorCodeException).m_errorCode := ErrorCode;
end;


end.
