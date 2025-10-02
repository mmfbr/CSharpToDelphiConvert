unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldCSideException = class(TGoldErrorCodeException)
  private
    m_remappable: Boolean;
  public
    const m_RemappableFieldName: String = "m_remappable";
    constructor Create();
    constructor Create(AErrorCode: Integer);
    constructor Create(AMessage: String);
    constructor Create(AErrorCode: Integer; AMessage: String);
    constructor Create(AErrorCode: Integer; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AErrorCode: Integer; AMessage: String; AInnerException: TException);
    constructor Create(AErrorCode: Integer; AMessage: String; AInnerException: TException; ARemappable: Boolean);
    constructor Create(AErrorCode: Integer; AInnerException: TException; ARemappable: Boolean; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AMessage: String; ADiagnosticsMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    procedure GetObjectData(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateAutoIncrementFieldError(AOriginalException: TGoldErrorCodeException; AFieldCaption: String; ATableCaptions: String; APrimaryKeyFieldsAndValues: String; ARemappable: Boolean): TGoldCSideException;
    function CreateForInvalidValueInField(AOriginalException: TGoldErrorCodeException; ATableCaptions: String; APrimaryKeyFieldsAndValues: String; ARemappable: Boolean): TGoldCSideException;
    property Remappable: Boolean read GetRemappable write SetRemappable;
  end;


implementation

constructor TGoldCSideException.Create();
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AErrorCode: Integer);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AErrorCode: Integer; AMessage: String);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AErrorCode: Integer; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AErrorCode: Integer; AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AErrorCode: Integer; AMessage: String; AInnerException: TException; ARemappable: Boolean);
begin
  inherited Create;
  Self.m_remappable := ARemappable;
end;

constructor TGoldCSideException.Create(AErrorCode: Integer; AInnerException: TException; ARemappable: Boolean; ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
  Self.m_remappable := ARemappable;
end;

constructor TGoldCSideException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AMessage: String; ADiagnosticsMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldCSideException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
  if AInfo = null then
  begin
    raise TArgumentNullException.Create("AInfo");
  end
  ;
  m_remappable := AInfo.GetBoolean("m_remappable");
end;

procedure TGoldCSideException.GetObjectData(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  if AInfo = null then
  begin
    raise TArgumentNullException.Create("AInfo");
  end
  ;
  AInfo.AddValue("m_remappable", m_remappable);
  base.GetObjectData(AInfo, AContext);
end;

function TGoldCSideException.CreateAutoIncrementFieldError(AOriginalException: TGoldErrorCodeException; AFieldCaption: String; ATableCaptions: String; APrimaryKeyFieldsAndValues: String; ARemappable: Boolean): TGoldCSideException;
begin
  Result := TGoldCSideException.Create(AOriginalException.ErrorCode, AOriginalException, ARemappable, CultureInfo.CurrentCulture, TLang.CannotModifyAutoIncrementFieldError, TDiagnosticParameter.SystemMetadata(AFieldCaption), TDiagnosticParameter.SystemMetadata(ATableCaptions), TDiagnosticParameter.CustomerContent(APrimaryKeyFieldsAndValues));
end;

function TGoldCSideException.CreateForInvalidValueInField(AOriginalException: TGoldErrorCodeException; ATableCaptions: String; APrimaryKeyFieldsAndValues: String; ARemappable: Boolean): TGoldCSideException;
begin
  Result := TGoldCSideException.Create(AOriginalException.ErrorCode, AOriginalException, ARemappable, CultureInfo.CurrentCulture, TLang.BadCodeDataError, TDiagnosticParameter.SystemMetadata(ATableCaptions), TDiagnosticParameter.CustomerContent(APrimaryKeyFieldsAndValues), TDiagnosticParameter.CustomerContent(AOriginalException.Message));
end;


end.
