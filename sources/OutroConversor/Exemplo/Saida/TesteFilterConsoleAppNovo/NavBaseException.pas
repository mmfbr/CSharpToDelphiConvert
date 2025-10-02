unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldBaseException = class(TException)
  private
    m_navTenantId: String;
    m_fatalityScope: TGoldExceptionFatalityScope;
  public
    const m_UnsafeConstructorUsedTelemetryMessage: String = "Message not shown because the TGoldBaseException(string, m_Exception, bool) constructor was used.";
    const m_FatalityScopeName: String = "FatalityScope";
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create();
    constructor Create(ASuppressExceptionCreatedEvent: Boolean);
    constructor Create(AMessage: String; ASuppressExceptionCreatedEvent: Boolean);
    constructor Create(AExceptionMessages: TGoldBaseExceptionMessages);
    constructor Create(AExceptionMessages: TGoldBaseExceptionMessages; AInner: TException);
    constructor Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AInner: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AMessage: String; AInner: TException; ASuppressExceptionCreatedEvent: Boolean);
    constructor Create(AMessage: String; ADiagnosticsMessage: String; AInner: TException; ASuppressExceptionCreatedEvent: Boolean);
    function CanChangeFatalityScope(ANewFatalityScope: TGoldExceptionFatalityScope): Boolean;
    function MarkFatalityScope(AExceptionFatalityScope: TGoldExceptionFatalityScope): TGoldBaseException;
    function CreateExceptionMessages(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]): TGoldBaseExceptionMessages;
    procedure OnExceptionCreated(AException: TException; ASuppress: Boolean);
    procedure GetObjectData(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function Clone(AInnerException: TException): TGoldBaseException;
    function ExtractExceptionMessage(AOriginalException: TException): String;
    function ExtractDiagnosticsMessage(AOriginalException: TException): String;
    function CreateCloneCore(AInnerException: TException): TGoldBaseException;
    procedure UpdateCloneCore(AExceptionClone: TGoldBaseException);
    property SuppressMessage: Boolean read GetSuppressMessage write SetSuppressMessage;
    property ContainsPersonalOrRestrictedInformation: Boolean read GetContainsPersonalOrRestrictedInformation write SetContainsPersonalOrRestrictedInformation;
    property DiagnosticsSuppress: Boolean read GetDiagnosticsSuppress write SetDiagnosticsSuppress;
    property DiagnosticsMessage: String read GetDiagnosticsMessage write SetDiagnosticsMessage;
    property GoldTenantId: String read GetGoldTenantId write SetGoldTenantId;
    property MessageWithoutPrivateInformation: String read GetMessageWithoutPrivateInformation write SetMessageWithoutPrivateInformation;
    property SuppressExceptionCreatedEvent: Boolean read GetSuppressExceptionCreatedEvent write SetSuppressExceptionCreatedEvent;
    property FatalityScope: TGoldExceptionFatalityScope read GetFatalityScope write SetFatalityScope;
  end;


implementation

constructor TGoldBaseException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
  if AInfo = null then
  begin
    raise TArgumentNullException.Create("AInfo");
  end
  ;
  SuppressMessage := AInfo.GetBoolean("SuppressMessage");
  m_fatalityScope := (TGoldExceptionFatalityScope)AInfo.GetInt32("FatalityScope");
end;

constructor TGoldBaseException.Create();
begin
  inherited Create;
  OnExceptionCreated(this);
end;

constructor TGoldBaseException.Create(ASuppressExceptionCreatedEvent: Boolean);
begin
  inherited Create;
  SuppressExceptionCreatedEvent := ASuppressExceptionCreatedEvent;
  OnExceptionCreated(this, ASuppressExceptionCreatedEvent);
end;

constructor TGoldBaseException.Create(AMessage: String; ASuppressExceptionCreatedEvent: Boolean);
begin
  inherited Create;
  SuppressExceptionCreatedEvent := ASuppressExceptionCreatedEvent;
  OnExceptionCreated(this, ASuppressExceptionCreatedEvent);
end;

constructor TGoldBaseException.Create(AExceptionMessages: TGoldBaseExceptionMessages);
begin
  inherited Create;
  DiagnosticsMessage := AExceptionMessages.m_Diagnostics;
end;

constructor TGoldBaseException.Create(AExceptionMessages: TGoldBaseExceptionMessages; AInner: TException);
begin
  inherited Create;
  DiagnosticsMessage := AExceptionMessages.m_Diagnostics;
end;

constructor TGoldBaseException.Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldBaseException.Create(AInner: TException; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldBaseException.Create(AMessage: String; AInner: TException; ASuppressExceptionCreatedEvent: Boolean);
begin
  inherited Create;
end;

constructor TGoldBaseException.Create(AMessage: String; ADiagnosticsMessage: String; AInner: TException; ASuppressExceptionCreatedEvent: Boolean);
begin
  inherited Create;
  DiagnosticsMessage := ADiagnosticsMessage;
  SuppressExceptionCreatedEvent := ASuppressExceptionCreatedEvent;
  OnExceptionCreated(this, ASuppressExceptionCreatedEvent);
end;

function TGoldBaseException.CanChangeFatalityScope(ANewFatalityScope: TGoldExceptionFatalityScope): Boolean;
begin
  if ANewFatalityScope = m_fatalityScope then
  begin
    Result := true;
  end
  ;
  Result := m_fatalityScope switch
            {
                TGoldExceptionFatalityScope.None => true,
                TGoldExceptionFatalityScope.Call => true,
                TGoldExceptionFatalityScope.Page => ANewFatalityScope <> TGoldExceptionFatalityScope.Call,
                _ => false,
            };
end;

function TGoldBaseException.MarkFatalityScope(AExceptionFatalityScope: TGoldExceptionFatalityScope): TGoldBaseException;
begin
  FatalityScope := AExceptionFatalityScope;
  Result := this;
end;

function TGoldBaseException.CreateExceptionMessages(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]): TGoldBaseExceptionMessages;
begin
  exceptionMessages: TGoldBaseExceptionMessages := default;
  if AArgs = null then
  begin
    exceptionMessages.m_Exception := AMessage;
  end
  else
  begin
    exceptionParameters: string[] := new string[AArgs.Length];
    diagnosticsParameters: string[] := new string[AArgs.Length];
    hasPersonalOrRestrictedInformation: Boolean := false;
    index: Integer := 0;
    for arg in AArgs do
    begin
      if TPrivacyHelper.IsPersonalOrRestrictedData(arg) then
      begin
        diagnosticsParameters[index] := "<redacted>";
        hasPersonalOrRestrictedInformation := true;
      end
      else
      begin
        diagnosticsParameters[index] := arg.Content.ToString();
      end;
      exceptionParameters[index++] := arg.Content.ToString();
    end;
    args2: object[] := exceptionParameters;
    exceptionMessages.m_Exception := string.Format(ACulture, AMessage, args2);
    diagnostics: TObject;
    if not hasPersonalOrRestrictedInformation then
    begin
      diagnostics := null;
    end
    else
    begin
      args2 := diagnosticsParameters;
      diagnostics := string.Format(ACulture, AMessage, args2);
    end;
    exceptionMessages.m_Diagnostics := (string)diagnostics;
  end;
  Result := exceptionMessages;
end;

procedure TGoldBaseException.OnExceptionCreated(AException: TException; ASuppress: Boolean);
begin
  if ExceptionCreated <> null and not ASuppress then
  begin
    ExceptionCreated(null, TExceptionCreatedEventArgs.Create(AException));
  end
  ;
end;

procedure TGoldBaseException.GetObjectData(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  if AInfo = null then
  begin
    raise TArgumentNullException.Create("AInfo");
  end
  ;
  AInfo.AddValue("SuppressMessage", SuppressMessage);
  AInfo.AddValue("FatalityScope", m_fatalityScope);
  base.GetObjectData(AInfo, AContext);
end;

function TGoldBaseException.Clone(AInnerException: TException): TGoldBaseException;
begin
  exceptionClone: TGoldBaseException := CreateCloneCore(AInnerException);
  UpdateCloneCore(exceptionClone);
  Result := exceptionClone;
end;

function TGoldBaseException.ExtractExceptionMessage(AOriginalException: TException): String;
begin
  if AOriginalException = null then
  begin
    raise TArgumentNullException.Create("AOriginalException");
  end
  ;
  Result := AOriginalException.Message;
end;

function TGoldBaseException.ExtractDiagnosticsMessage(AOriginalException: TException): String;
begin
  Result := (AOriginalException as TGoldBaseException)?.DiagnosticsMessage;
end;

function TGoldBaseException.CreateCloneCore(AInnerException: TException): TGoldBaseException;
begin
  Result := (TGoldBaseException)GetType().GetConstructor(new Type[2]
            {
                typeof(string),
                typeof(Exception)
            }).Invoke(new object[2] { Message, AInnerException });
end;

procedure TGoldBaseException.UpdateCloneCore(AExceptionClone: TGoldBaseException);
begin
  AExceptionClone.SuppressMessage := SuppressMessage;
  AExceptionClone.DiagnosticsMessage := DiagnosticsMessage;
  AExceptionClone.DiagnosticsSuppress := DiagnosticsSuppress;
  AExceptionClone.FatalityScope := FatalityScope;
  for entry in Data do
  begin
    if not AExceptionClone.Data.Contains(entry.Key) then
    begin
      AExceptionClone.Data.Add(entry.Key, entry.Value);
    end
    ;
  end;
end;


end.
