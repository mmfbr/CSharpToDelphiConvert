unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldTimeFormatter = class(TGoldValueFormatter)
  private
    m_TimeFieldNames: TReadOnlyCollection<string>;
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatSetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function GetFieldNames(): TReadOnlyCollection<string>;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
  end;


implementation

function TGoldTimeFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatSetting: TFormatSettings): String;
begin
  navTime: TGoldTime := (TGoldTime)value;
  if navTime.IsZeroOrEmpty then
  begin
    Result := string.Empty;
  end
  ;
  if (uint)formatNumber <= 2u or formatNumber = 9 then
  begin
    Result := TGoldFormatEvaluateHelper.FormatWithFormatNumber(navTime, length, formatNumber, formatSetting);
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, formatNumber, TGoldType.Time);
end;

function TGoldTimeFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)formatNumber <= 2u or formatNumber = 9 then
  begin
    Result := TGoldCurrentThread.Session.FormatSettings.TimeStdFormatStrings[formatNumber];
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, formatNumber, TGoldType.Time);
end;

function TGoldTimeFormatter.GetFieldNames(): TReadOnlyCollection<string>;
begin
  Result := m_TimeFieldNames;
end;

function TGoldTimeFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  Result := true;
end;

function TGoldTimeFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  text: String := null;
  navTime: TGoldTime := (TGoldTime)value;
  options.Initialize(TFormatSettings.TimeTypeFmt[options.Field - 3]);
  TGoldFormatEvaluateHelper.GetFieldFormatFromString(options, format, ref pos);
  // TODO: Converter SwitchStatementSyntax
  Result := text;
end;


end.
