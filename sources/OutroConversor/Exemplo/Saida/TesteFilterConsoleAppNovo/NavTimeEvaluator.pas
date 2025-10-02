unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldTimeEvaluator = class(TGoldValueEvaluator<TGoldTime>)
  private
    m_instance: TGoldTimeEvaluator;
  public
    constructor Create();
    function InternalEvaluate(ADataError: TDataError; AValue: TGoldTime; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function NonXMLFormatEvaluate(AValue: TGoldTime; ASource: String): Boolean;
    function CurrentTimeEvaluate(AValue: TGoldTime; ASource: String; APosition: Integer): Boolean;
    function XMLFormatEvaluate(AValue: TGoldTime; ASource: String): Boolean;
    function CreateTime(AHours: Integer; AMinutes: Integer; ASeconds: Integer; AMilliseconds: Integer; AOriginalString: String): TGoldTime;
    function ThrowNavTimeEvalError(AOriginalString: String): TGoldNCLEvaluateException;
    function GetDefaultValue(AMetadata: INavValueMetadata): TGoldTime;
    property Instance: TGoldTimeEvaluator read GetInstance write SetInstance;
  end;


implementation

constructor TGoldTimeEvaluator.Create();
begin
  inherited Create;
end;

function TGoldTimeEvaluator.InternalEvaluate(ADataError: TDataError; AValue: TGoldTime; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  // TODO: Converter TryStatementSyntax
end;

function TGoldTimeEvaluator.NonXMLFormatEvaluate(AValue: TGoldTime; ASource: String): Boolean;
begin
  value := TGoldTime.Default;
  if string.IsNullOrWhiteSpace(source) then
  begin
    Result := true;
  end
  ;
  if TDateTimeParsingHelper.TryParseExactTime(source, TGoldCurrentSessionWrapper.RegionalSettings, out var result) or TDateTimeParsingHelper.TryParseExactTime(source, out result) then
  begin
    value := CreateTime(result.Hour, result.Minute, result.Second, result.Millisecond, source);
    Result := true;
  end
  ;
  position: Integer := 0;
  ConsumeWhitespace(source, ref position);
  if CurrentTimeEvaluate(out value, source, position) then
  begin
    Result := true;
  end
  ;
  numberOfDigitsInLongNumber: Integer;
  array_: int[] := EvaluateNumberSequence(source, ref position, 4, 3, 3, out numberOfDigitsInLongNumber);
  if array_ = null or array_[0] < 0 then
  begin
    Result := false;
  end
  ;
  array_[1] := Math.Max(array_[1], 0);
  array_[2] := Math.Max(array_[2], 0);
  array_[3] := Math.Max(array_[3], 0);
  if numberOfDigitsInLongNumber > 0 then
  begin
    array2: int[] := new int[3] { 1, 10, 100 };
    array_[3] := array2[3 - numberOfDigitsInLongNumber];
  end
  ;
  ConsumeWhitespace(source, ref position);
  timeAMDesignator: String := TGoldCurrentSessionWrapper.FormatSettings.TimeAMDesignator;
  timePMDesignator: String := TGoldCurrentSessionWrapper.FormatSettings.TimePMDesignator;
  if position <> source.Length then
  begin
    if string.IsNullOrEmpty(timeAMDesignator) or string.IsNullOrEmpty(timePMDesignator) or array_[0] > 12 then
    begin
      Result := false;
    end
    ;
    value2: String := source.Substring(position).TrimEnd();
    flag: Boolean := StartsWith(timePMDesignator, 0, value2);
    if not flag and not StartsWith(timeAMDesignator, 0, value2) then
    begin
      Result := false;
    end
    ;
    if flag then
    begin
      if array_[0] <> 12 then
      begin
        array_[0] := 12;
      end
      ;
    end
    else
    begin
      if array_[0] = 12 then
      begin
        array_[0] := 0;
      end
      ;
    end;
  end
  ;
  value := CreateTime(array_[0], array_[1], array_[2], array_[3], source);
  Result := true;
end;

function TGoldTimeEvaluator.CurrentTimeEvaluate(AValue: TGoldTime; ASource: String; APosition: Integer): Boolean;
begin
  time: String := TGoldCurrentSessionWrapper.FormatSettings.Time;
  if StartsWith(time, 0, source, position) then
  begin
    value := TGoldTime.CreateTime(TGoldNow.ClientLocalValue);
    Result := true;
  end
  ;
  value := TGoldTime.Default;
  Result := false;
end;

function TGoldTimeEvaluator.XMLFormatEvaluate(AValue: TGoldTime; ASource: String): Boolean;
begin
  value := TGoldTime.Default;
  originalString: String := source;
  source := source.Trim();
  if string.IsNullOrWhiteSpace(source) then
  begin
    Result := true;
  end
  ;
  if source.Length > 2 and source[2] <> ':' then
  begin
    Result := false;
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TGoldTimeEvaluator.CreateTime(AHours: Integer; AMinutes: Integer; ASeconds: Integer; AMilliseconds: Integer; AOriginalString: String): TGoldTime;
begin
  if hours < 0 or hours >= 24 or minutes < 0 or minutes >= 60 or seconds < 0 or seconds >= 60 or milliseconds < 0 then
  begin
    raise ThrowNavTimeEvalError(originalString);
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TGoldTimeEvaluator.ThrowNavTimeEvalError(AOriginalString: String): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(CultureInfo.CurrentCulture, TGoldType.Time, originalString);
end;

function TGoldTimeEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): TGoldTime;
begin
  Result := TGoldTime.Default;
end;


end.
