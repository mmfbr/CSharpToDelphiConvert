unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateTimeFormatter = class(TGoldValueFormatter)
  private
    m_DatetimeFieldNames: TReadOnlyCollection<string>;
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatSetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function GetFieldNames(): TReadOnlyCollection<string>;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
    function GetYear(ADatetimeValue: TGoldDateTime): Integer;
    function GetDay(ADatetimeValue: TGoldDateTime): Integer;
  end;


implementation

function TGoldDateTimeFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatSetting: TFormatSettings): String;
begin
  navDateTime: TGoldDateTime := (TGoldDateTime)AValue;
  if navDateTime.IsZeroOrEmpty then
  begin
    Result := string.Empty;
  end
  ;
  if (uint)AFormatNumber <= 3u or AFormatNumber = 9 then
  begin
    Result := TGoldFormatEvaluateHelper.FormatWithFormatNumber(navDateTime, ALength, AFormatNumber, AFormatSetting);
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.DateTime);
end;

function TGoldDateTimeFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)AFormatNumber <= 3u or AFormatNumber = 9 then
  begin
    Result := TGoldCurrentThread.Session.FormatSettings.DatetimeStdFormatStrings[AFormatNumber];
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.DateTime);
end;

function TGoldDateTimeFormatter.GetFieldNames(): TReadOnlyCollection<string>;
begin
  Result := m_DatetimeFieldNames;
end;

function TGoldDateTimeFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  Result := true;
end;

function TGoldDateTimeFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  text: String := null;
  navDateTime: TGoldDateTime := (TGoldDateTime)AValue;
  AOptions.Initialize(TFormatSettings.DatetimeTypeFmt[AOptions.Field - 3]);
  TGoldFormatEvaluateHelper.GetFieldFormatFromString(AOptions, AFormat, ref APos);
  weekNo: Integer;
  year: Integer;
  // TODO: Converter SwitchStatementSyntax
  Result := text;
end;

function TGoldDateTimeFormatter.GetYear(ADatetimeValue: TGoldDateTime): Integer;
begin
  if ADatetimeValue = TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    Result := 0;
  end
  ;
  Result := ADatetimeValue.Value.Year;
end;

function TGoldDateTimeFormatter.GetDay(ADatetimeValue: TGoldDateTime): Integer;
begin
  if ADatetimeValue = TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    Result := 1;
  end
  ;
  Result := ADatetimeValue.Value.Day;
end;


end.
