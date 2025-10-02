unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLStringLengthExceededException = class(TGoldNCLEvaluateException)
  public
    const m_MaxValueMessageLength: Integer = 200;
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMaxLength: Integer);
    constructor Create(AMaxLength: Integer; ALength: Integer; AValue: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
    function CreateMessage(AMaxLength: Integer): String;
    function GetTruncatedString(AValue: String): String;
  end;


implementation

constructor TGoldNCLStringLengthExceededException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLStringLengthExceededException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLStringLengthExceededException.Create(AMaxLength: Integer);
begin
  inherited Create;
end;

constructor TGoldNCLStringLengthExceededException.Create(AMaxLength: Integer; ALength: Integer; AValue: String);
begin
  inherited Create;
end;

constructor TGoldNCLStringLengthExceededException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLStringLengthExceededException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

constructor TGoldNCLStringLengthExceededException.Create(ACulture: TCultureInfo; AMessage: String; AArgs: TDiagnosticParameter[]);
begin
  inherited Create;
end;

function TGoldNCLStringLengthExceededException.CreateMessage(AMaxLength: Integer): String;
begin
  Result := string.Format(CultureInfo.CurrentCulture, " TLang._00095_50006", AMaxLength);
end;

function TGoldNCLStringLengthExceededException.GetTruncatedString(AValue: String): String;
begin
  if AValue.Length >= 200 then
  begin
    Result := AValue.Substring(0, 200) + "...";
  end
  ;
  Result := AValue;
end;


end.
