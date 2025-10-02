unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLEvaluateException = class(TGoldNCLException)
  public
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    constructor Create(ACulture: TCultureInfo; AMessage: String; args: TDiagnosticParameter[]);
    constructor Create(AInnerException: TException; ACulture: TCultureInfo; AMessage: String; args: TDiagnosticParameter[]);
    function Create(ACulture: TCultureInfo; AType_: TGoldType; ASource: String): TGoldNCLEvaluateException;
    function Create(ACulture: TCultureInfo; AType_: TGoldType; ASource: String; AInnerException: TException): TGoldNCLEvaluateException;
    function CreateDateFormulaSignMissing(ACulture: TCultureInfo; ASource: String): TGoldNCLEvaluateException;
    function CreateDateFormulaShouldIncludeANumber(ACulture: TCultureInfo; ASource: String): TGoldNCLEvaluateException;
    function CreateDateFormulaShouldIncludeQuantor(ACulture: TCultureInfo; ASource: String): TGoldNCLEvaluateException;
    function CreateDateFormulaExceedMaxLength(ACulture: TCultureInfo; ASource: String; AMaxLength: Integer): TGoldNCLEvaluateException;
    function CreateDateFormulaNumberOutOfRange(ACulture: TCultureInfo; ASource: String; ALowerBound: Integer; AUpperBound: Integer): TGoldNCLEvaluateException;
    function CreateIntegerValueOutOfRange(ACulture: TCultureInfo; ASource: String; ALowerBound: Integer; AUpperBound: Integer): TGoldNCLEvaluateException;
  end;


implementation

constructor TGoldNCLEvaluateException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLEvaluateException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLEvaluateException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLEvaluateException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

constructor TGoldNCLEvaluateException.Create(ACulture: TCultureInfo; AMessage: String; args: TDiagnosticParameter[]);
begin
  inherited Create;
end;

constructor TGoldNCLEvaluateException.Create(AInnerException: TException; ACulture: TCultureInfo; AMessage: String; args: TDiagnosticParameter[]);
begin
  inherited Create;
end;

function TGoldNCLEvaluateException.Create(ACulture: TCultureInfo; AType_: TGoldType; ASource: String): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateError, TDiagnosticParameter.SystemMetadata(type_.ToString()), TDiagnosticParameter.CustomerContent(source));
end;

function TGoldNCLEvaluateException.Create(ACulture: TCultureInfo; AType_: TGoldType; ASource: String; AInnerException: TException): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(innerException, culture, TLang.m_EvaluateErrorWithMessage, TDiagnosticParameter.SystemMetadata(type_.ToString()), TDiagnosticParameter.CustomerContent(source), TDiagnosticParameter.CustomerContent(innerException.Message));
end;

function TGoldNCLEvaluateException.CreateDateFormulaSignMissing(ACulture: TCultureInfo; ASource: String): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateDateFormulaSignMissingError, TDiagnosticParameter.CustomerContent(source));
end;

function TGoldNCLEvaluateException.CreateDateFormulaShouldIncludeANumber(ACulture: TCultureInfo; ASource: String): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateDateFormulaShouldIncludeANumberError, TDiagnosticParameter.CustomerContent(source));
end;

function TGoldNCLEvaluateException.CreateDateFormulaShouldIncludeQuantor(ACulture: TCultureInfo; ASource: String): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateDateFormulaShouldIncludeAQuantorError, TDiagnosticParameter.CustomerContent(source));
end;

function TGoldNCLEvaluateException.CreateDateFormulaExceedMaxLength(ACulture: TCultureInfo; ASource: String; AMaxLength: Integer): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateDateFormulaExceedsMaxLengthError, TDiagnosticParameter.CustomerContent(source), TDiagnosticParameter.SystemMetadata(maxLength));
end;

function TGoldNCLEvaluateException.CreateDateFormulaNumberOutOfRange(ACulture: TCultureInfo; ASource: String; ALowerBound: Integer; AUpperBound: Integer): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateDateFormulaNumberOutOfRangeError, TDiagnosticParameter.CustomerContent(source), TDiagnosticParameter.SystemMetadata(lowerBound), TDiagnosticParameter.SystemMetadata(upperBound));
end;

function TGoldNCLEvaluateException.CreateIntegerValueOutOfRange(ACulture: TCultureInfo; ASource: String; ALowerBound: Integer; AUpperBound: Integer): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(culture, TLang.EvaluateIntegerValueOutOfRangeError, TDiagnosticParameter.CustomerContent(source), TDiagnosticParameter.SystemMetadata(lowerBound), TDiagnosticParameter.SystemMetadata(upperBound));
end;


end.
