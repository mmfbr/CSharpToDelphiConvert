unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldFormatEvaluateHelper = class(TObject)
  private
    m_AttributeNames: IList<string>;
  public
    function Format(AValue: TGoldValue): String;
    function Format(AValue: TGoldValue; ALength: Integer; ANumber: Integer): String;
    function Format(AValue: TGoldValue; ALength: Integer; ANumber: Integer; AFormatSettings: TFormatSettings): String;
    function GetKeyValue(AFormat: String; APos: Integer; AKey: String; AValue: String; AExpected: IList<string>): Boolean;
    function ParseChar(AValue: String; AFormat: String): Char;
    function ParseAttributeValueChar(AAttrId: TFormatAttributeId; AValue: String; AFormat: String): Char;
    function EvaluateFormatString(ANavValue: TGoldValue; AFormat: String; ANumber: Integer): String;
    function LookupName(AFieldNames: IList<string>; AToken: String): Integer;
    function FormatUsingOptions(AValue: String; AOptions: TFormatOptions): String;
    function GetStandardFormat(AValue: TGoldValue; AFormatType: Integer): String;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
    procedure GetFieldFormatFromString(AOptions: TFormatOptions; AFormat: String; APos: Integer);
    function IsFormatAttribute(ACh: Char): Boolean;
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; ANumber: Integer; ASettings: TFormatSettings): String;
    function FormatWithParsedFormatString(AValue: TGoldValue; ALength: Integer; AFormat: String; ANumber: Integer; ASettings: TFormatSettings): String;
  end;


implementation

function TGoldFormatEvaluateHelper.Format(AValue: TGoldValue): String;
begin
  Result := Format(AValue, 0, 0);
end;

function TGoldFormatEvaluateHelper.Format(AValue: TGoldValue; ALength: Integer; ANumber: Integer): String;
begin
  Result := Format(AValue, ALength, ANumber, TGoldCurrentThread.Session?.FormatSettings ?? TGoldSession.InvariantFormatSettings);
end;

function TGoldFormatEvaluateHelper.Format(AValue: TGoldValue; ALength: Integer; ANumber: Integer; AFormatSettings: TFormatSettings): String;
begin
  if Math.Abs(ALength) > 2048 then
  begin
    raise TGoldNCLStringLengthExceededException.Create(2048);
  end
  ;
  if AValue = null then
  begin
    raise TArgumentNullException.Create("m_value");
  end
  ;
  Result := TGoldValueFormatter.GetFormatter(AValue).Format(AValue, ALength, ANumber, AFormatSettings);
end;

function TGoldFormatEvaluateHelper.GetKeyValue(AFormat: String; APos: Integer; AKey: String; AValue: String; AExpected: IList<string>): Boolean;
begin
  AKey := string.Empty;
  AValue := string.Empty;
  if APos = AFormat.Length or AFormat[APos] <> '<' then
  begin
    Result := false;
  end
  ;
  num: Integer := APos;
  // TODO: Converter WhileStatementSyntax
  AKey := AFormat.Substring(APos + 1, num - APos - 1);
  if AExpected <> null and LookupName(AExpected, AKey) < 0 then
  begin
    Result := false;
  end
  ;
  if AFormat[num] = ',' then
  begin
    num++;
    num2: Integer := num;
    num3: Integer := 0;
    // TODO: Converter WhileStatementSyntax
    if num2 = AFormat.Length then
    begin
      raise TGoldNCLInvalidFormatStringException.Create(CultureInfo.CurrentCulture, AFormat);
    end
    ;
    AValue := AFormat.Substring(num, num2 - num);
    num := num2;
  end
  ;
  num := APos = num + 1;
  Result := true;
end;

function TGoldFormatEvaluateHelper.ParseChar(AValue: String; AFormat: String): Char;
begin
  if string.IsNullOrEmpty(AValue) then
  begin
    raise TGoldNCLInvalidFormatStringException.Create(CultureInfo.CurrentCulture, AFormat);
  end
  ;
  if AValue[0] <> '<' then
  begin
    if AValue.Length <> 1 then
    begin
      raise TGoldNCLInvalidFormatStringException.Create(CultureInfo.CurrentCulture, AFormat);
    end
    ;
    Result := AValue[0];
  end
  ;
  if not uint.TryParse(AValue.Substring(1, AValue.Length - 2), out var result) then
  begin
    raise TGoldNCLInvalidFormatStringException.Create(CultureInfo.CurrentCulture, AFormat);
  end
  ;
  Result := Convert.ToChar(result);
end;

function TGoldFormatEvaluateHelper.ParseAttributeValueChar(AAttrId: TFormatAttributeId; AValue: String; AFormat: String): Char;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldFormatEvaluateHelper.EvaluateFormatString(ANavValue: TGoldValue; AFormat: String; ANumber: Integer): String;
begin
  stringBuilder: TStringBuilder := TStringBuilder.Create();
  fieldNames: IList<string> := TGoldValueFormatter.GetFormatter(ANavValue).GetFieldNames();
  ANumber := -1;
  pos: Integer := 0;
  // TODO: Converter WhileStatementSyntax
  Result := stringBuilder.ToString();
end;

function TGoldFormatEvaluateHelper.LookupName(AFieldNames: IList<string>; AToken: String): Integer;
begin
  _result: Integer := -1;
  if AFieldNames <> null then
  begin
    // TODO: Converter ForStatementSyntax
    // TODO: Converter ForStatementSyntax
  end
  ;
  Result := _result;
end;

function TGoldFormatEvaluateHelper.FormatUsingOptions(AValue: String; AOptions: TFormatOptions): String;
begin
  if AOptions.Length = 0 then
  begin
    Result := AValue;
  end
  ;
  if AOptions.Length < AValue.Length then
  begin
    if AOptions.Overflow = '\0' then
    begin
      Result := AValue.Substring(0, AOptions.Length);
    end
    ;
    Result := Tstring.Create(AOptions.Overflow, AOptions.Length);
  end
  ;
  if AOptions.Length > AValue.Length then
  begin
    if not AOptions.LeftJustify then
    begin
      Result := AValue + Tstring.Create(AOptions.FillerCharacter = '\0' ? ' ' : AOptions.FillerCharacter, AOptions.Length - AValue.Length);
    end
    ;
    Result := Tstring.Create(AOptions.FillerCharacter = '\0' ? ' ' : AOptions.FillerCharacter, AOptions.Length - AValue.Length) + AValue;
  end
  ;
  Result := AValue;
end;

function TGoldFormatEvaluateHelper.GetStandardFormat(AValue: TGoldValue; AFormatType: Integer): String;
begin
  Result := TGoldValueFormatter.GetFormatter(AValue).GetStandardFormat(AFormatType);
end;

function TGoldFormatEvaluateHelper.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  text: String := TGoldValueFormatter.GetFormatter(AValue).FormatField(AValue, AOptions, ASettings, AFormat, ref APos);
  if text = null then
  begin
    raise TGoldNCLInvalidFormatStringException.Create(CultureInfo.CurrentCulture, string.Empty);
  end
  ;
  Result := FormatUsingOptions(text, AOptions);
end;

procedure TGoldFormatEvaluateHelper.GetFieldFormatFromString(AOptions: TFormatOptions; AFormat: String; APos: Integer);
begin
  // TODO: Converter WhileStatementSyntax
end;

function TGoldFormatEvaluateHelper.IsFormatAttribute(ACh: Char): Boolean;
begin
  if ACh <= '\u001e' then
  begin
    Result := ACh >= '\u0018';
  end
  ;
  Result := false;
end;

function TGoldFormatEvaluateHelper.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; ANumber: Integer; ASettings: TFormatSettings): String;
begin
  if AValue = null then
  begin
    raise TArgumentNullException.Create("m_value");
  end
  ;
  standardFormat: String := GetStandardFormat(AValue, ANumber);
  Result := FormatWithParsedFormatString(AValue, ALength, standardFormat, ANumber, ASettings);
end;

function TGoldFormatEvaluateHelper.FormatWithParsedFormatString(AValue: TGoldValue; ALength: Integer; AFormat: String; ANumber: Integer; ASettings: TFormatSettings): String;
begin
  if AValue.NclType = TGoldNclType.GoldDateTime then
  begin
    if ANumber <> 9 then
    begin
      initValue: TDateTime := DateTime.SpecifyKind(((TGoldDateTime)AValue).ClientLocalValue, DateTimeKind.Utc);
      AValue := TGoldDateTime.Create(initValue, TDateTimeReferenceFrame.Client);
    end
    ;
    navDateTime: TGoldDateTime := (TGoldDateTime)AValue;
    if navDateTime.IsZeroOrEmpty then
    begin
      Result := TGoldValueFormatter.AdjustResultLength(string.Empty, ALength, AValue);
    end
    ;
  end
  else
  begin
    if AValue.NclType = TGoldNclType.GoldDate then
    begin
      navDate: TGoldDate := (TGoldDate)AValue;
      if navDate.IsZeroOrEmpty then
      begin
        Result := TGoldValueFormatter.AdjustResultLength(string.Empty, ALength, AValue);
      end
      ;
      if ANumber = 9 and navDate = TGoldDateTimeHelper.m_DateTimeMinimum then
      begin
        Result := "0001-01-02";
      end
      ;
    end
    ;
  end;
  stringBuilder: TStringBuilder := TStringBuilder.Create();
  pos: Integer := 0;
  formatOptions: TFormatOptions := TFormatOptions.Create();
  // TODO: Converter WhileStatementSyntax
  Result := TGoldValueFormatter.AdjustResultLength(stringBuilder.ToString(), ALength, AValue);
end;


end.
