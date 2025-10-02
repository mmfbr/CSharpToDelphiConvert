unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateFormatter = class(TGoldValueFormatter)
  private
    m_DateFieldNames: TReadOnlyCollection<string>;
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function GetFieldNames(): TReadOnlyCollection<string>;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
    function GetYear(ADateValue: TGoldDate): Integer;
    function GetDay(ADateValue: TGoldDate): Integer;
    function IsInRange(AValue: Integer; ALow: Integer; AHigh: Integer): Boolean;
    function PadYear(AYear: Integer): String;
  end;


implementation

function TGoldDateFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
  navDate: TGoldDate := (TGoldDate)AValue;
  if navDate.IsZeroOrEmpty then
  begin
    Result := string.Empty;
  end
  ;
  if (uint)AFormatNumber <= 7u or AFormatNumber = 9 then
  begin
    Result := TGoldFormatEvaluateHelper.FormatWithFormatNumber(navDate, ALength, AFormatNumber, AFormatsetting);
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.Date);
end;

function TGoldDateFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)AFormatNumber <= 7u or AFormatNumber = 9 then
  begin
    Result := TGoldCurrentThread.Session.FormatSettings.DateStdFormatStrings[AFormatNumber];
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.Date);
end;

function TGoldDateFormatter.GetFieldNames(): TReadOnlyCollection<string>;
begin
  Result := m_DateFieldNames;
end;

function TGoldDateFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  Result := true;
end;

function TGoldDateFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  _result: String := null;
  navDate: TGoldDate := (TGoldDate)AValue;
  AOptions.Initialize(TFormatSettings.DateTypeFmt[AOptions.Field - 3]);
  TGoldFormatEvaluateHelper.GetFieldFormatFromString(AOptions, AFormat, ref APos);
  weekNo: Integer;
  year: Integer;
  // TODO: Converter SwitchStatementSyntax
  Result := _result;
end;

function TGoldDateFormatter.GetYear(ADateValue: TGoldDate): Integer;
begin
  if ADateValue = TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    Result := 0;
  end
  ;
  Result := ADateValue.Value.Year;
end;

function TGoldDateFormatter.GetDay(ADateValue: TGoldDate): Integer;
begin
  if ADateValue = TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    Result := 1;
  end
  ;
  Result := ADateValue.Value.Day;
end;

function TGoldDateFormatter.IsInRange(AValue: Integer; ALow: Integer; AHigh: Integer): Boolean;
begin
  if ALow <= AValue then
  begin
    Result := AValue <= AHigh;
  end
  ;
  Result := false;
end;

function TGoldDateFormatter.PadYear(AYear: Integer): String;
begin
  Result := AYear.ToString("D4", CultureInfo.InvariantCulture);
end;


end.
