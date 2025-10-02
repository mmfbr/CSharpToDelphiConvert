unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldValueFormatter = class(TObject)
  private
    m_navTextFormatter: TGoldValueFormatter;
    m_navTimeFormatter: TGoldValueFormatter;
    m_navDateFormatter: TGoldValueFormatter;
    m_navDateTimeFormatter: TGoldValueFormatter;
    m_navIntegerFormatter: TGoldValueFormatter;
    m_navDateFormulaFormatter: TGoldValueFormatter;
    m_navGenericFormatter: TGoldValueFormatter;
  public
    function GetFormatter(AValue: TGoldValue): TGoldValueFormatter;
    function Format(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function Format(AValue: TGoldValue; ALength: Integer; AFormat: String; AFormatSetting: TFormatSettings): String;
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function PadLeft(AValue: TGoldValue): Boolean;
    function GetFieldNames(): TReadOnlyCollection<string>;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
    function AdjustResultLength(A_result: String; ALength: Integer; AValue: TGoldValue): String;
    procedure AppendValueQuoteIfNecessary(AStringBuilder: TStringBuilder; AValue: String; AQuoteIfContains: Char; AQuoteEmpty: Boolean);
  end;


implementation

function TGoldValueFormatter.GetFormatter(AValue: TGoldValue): TGoldValueFormatter;
begin
  if value = null then
  begin
    raise TArgumentNullException.Create("m_value");
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldValueFormatter.Format(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
  Result := AdjustResultLength(FormatWithFormatNumber(value, length, formatNumber, formatsetting), length, value);
end;

function TGoldValueFormatter.Format(AValue: TGoldValue; ALength: Integer; AFormat: String; AFormatSetting: TFormatSettings): String;
begin
  if value = null then
  begin
    raise TArgumentNullException.Create("m_value");
  end
  ;
  number: Integer := -1;
  format := TGoldFormatEvaluateHelper.EvaluateFormatString(value, format ?? string.Empty, out number);
  Result := TGoldFormatEvaluateHelper.FormatWithParsedFormatString(value, length, format, number, formatSetting);
end;

function TGoldValueFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
end;

function TGoldValueFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
end;

function TGoldValueFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
end;

function TGoldValueFormatter.GetFieldNames(): TReadOnlyCollection<string>;
begin
  Result := null;
end;

function TGoldValueFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  raise TNotSupportedException.Create(value.NclType.ToString());
end;

function TGoldValueFormatter.AdjustResultLength(A_result: String; ALength: Integer; AValue: TGoldValue): String;
begin
  if _result <> null and length <> 0 then
  begin
    if Math.Abs(length) < _result.Length then
    begin
      Result := _result.Remove(Math.Abs(length));
    end
    ;
    if length > _result.Length then
    begin
      if not GetFormatter(value).PadLeft(value) then
      begin
        Result := _result.PadRight(length, ' ');
      end
      ;
      Result := _result.PadLeft(length, ' ');
    end
    ;
  end
  ;
  Result := _result;
end;

procedure TGoldValueFormatter.AppendValueQuoteIfNecessary(AStringBuilder: TStringBuilder; AValue: String; AQuoteIfContains: Char; AQuoteEmpty: Boolean);
begin
  if value <> null and (quoteEmpty or not string.IsNullOrEmpty(value)) then
  begin
    if string.IsNullOrEmpty(value) or value.IndexOf(quoteIfContains) >= 0 or value[0] = '"' or value[0] = ' ' or value[value.Length - 1] = ' ' then
    begin
      stringBuilder.Append("\"");
      length: Integer := stringBuilder.Length;
      stringBuilder.Append(value);
      stringBuilder.Replace("\"", "\"\"", length, value.Length);
      stringBuilder.Append("\"");
    end
    else
    begin
      stringBuilder.Append(value);
    end;
  end
  ;
end;


end.
