unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldNCLOutsidePermittedRangeException = class(TGoldNCLException)
  public
    const m_DecimalFormatString: String = "#,0.##################";
    const m_IntegerFormatStringWithGrouping: String = "N0";
    const m_IntegerFormatStringWithoutGrouping: String = null;
    const m_NoFormattingCutoffMin: Integer = 0;
    const m_NoFormattingCutoffMax: Integer = 9999;
    constructor Create(AParameterName: String; AParameterNumber: Integer; ACurrentValue: Integer; ALowerBound: Integer; AUpperBound: Integer);
    constructor Create(AParameterName: String; AParameterNumber: Integer; ACurrentValue: Currency; ALowerBound: Currency; AUpperBound: Currency);
    constructor Create();
    constructor Create(AMessage: String);
    constructor Create(AMessage: String; AInnerException: TException);
    constructor Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
    function CreateMessage(AParameterName: String; AParameterNumber: Integer; ACurrentValue: Integer; ALowerBound: Integer; AUpperBound: Integer): String;
    function IsWithinYearRange(AValue: Integer): Boolean;
    function CreateMessage(AParameterName: String; AParameterNumber: Integer; ACurrentValue: IFormattable; ALowerBound: IFormattable; AUpperBound: IFormattable; AFormatString: String): String;
  end;


implementation

constructor TGoldNCLOutsidePermittedRangeException.Create(AParameterName: String; AParameterNumber: Integer; ACurrentValue: Integer; ALowerBound: Integer; AUpperBound: Integer);
begin
  inherited Create;
end;

constructor TGoldNCLOutsidePermittedRangeException.Create(AParameterName: String; AParameterNumber: Integer; ACurrentValue: Currency; ALowerBound: Currency; AUpperBound: Currency);
begin
  inherited Create;
end;

constructor TGoldNCLOutsidePermittedRangeException.Create();
begin
  inherited Create;
end;

constructor TGoldNCLOutsidePermittedRangeException.Create(AMessage: String);
begin
  inherited Create;
end;

constructor TGoldNCLOutsidePermittedRangeException.Create(AMessage: String; AInnerException: TException);
begin
  inherited Create;
end;

constructor TGoldNCLOutsidePermittedRangeException.Create(AInfo: TSerializationInfo; AContext: TStreamingContext);
begin
  inherited Create;
end;

function TGoldNCLOutsidePermittedRangeException.CreateMessage(AParameterName: String; AParameterNumber: Integer; ACurrentValue: Integer; ALowerBound: Integer; AUpperBound: Integer): String;
begin
  formatString: String := (if IsWithinYearRange(ALowerBound) and IsWithinYearRange(AUpperBound) then null else "N0");
  Result := CreateMessage(AParameterName, AParameterNumber, ACurrentValue, ALowerBound, AUpperBound, formatString);
end;

function TGoldNCLOutsidePermittedRangeException.IsWithinYearRange(AValue: Integer): Boolean;
begin
  if AValue <= 9999 then
  begin
    Result := AValue >= 0;
  end
  ;
  Result := false;
end;

function TGoldNCLOutsidePermittedRangeException.CreateMessage(AParameterName: String; AParameterNumber: Integer; ACurrentValue: IFormattable; ALowerBound: IFormattable; AUpperBound: IFormattable; AFormatString: String): String;
begin
  parameterNumberString: String := (if AParameterNumber = 0 then string.Empty else AParameterNumber.ToString(CultureInfo.CurrentCulture));
  currentValueString: String := ACurrentValue.ToString(AFormatString, CultureInfo.CurrentCulture);
  lowerBoundString: String := ALowerBound.ToString(AFormatString, CultureInfo.CurrentCulture);
  upperBoundString: String := AUpperBound.ToString(AFormatString, CultureInfo.CurrentCulture);
  Result := string.Format(CultureInfo.CurrentCulture, TLang._00095_50010, AParameterName, parameterNumberString, currentValueString, lowerBoundString, upperBoundString);
end;


end.
