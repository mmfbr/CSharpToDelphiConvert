unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TDateTimeParsingHelper = class(TObject)
  public
    function TryParseExactDateTime(ASource: String; ASettings: TClientSettings; A_result: TDateTime): Boolean;
    function TryParseExactDateTime(ASource: String; A_result: TDateTime): Boolean;
    function TryParseExactTime(ASource: String; ASettings: TClientSettings; A_result: TDateTime): Boolean;
    function TryParseExactTime(ASource: String; A_result: TDateTime): Boolean;
    function TryParseExactDate(ASource: String; ASettings: TClientSettings; A_result: TDateTime): Boolean;
    function TryParseExactDate(ASource: String; A_result: TDateTime): Boolean;
    function TryParseExactDateTimeLiteral(ASource: String; A_result: TDateTime): Boolean;
    function CreateExactDateTimePatterns(AShortDatePattern: String; ALongTimePattern: String; ATimeSeparator: String; ADecimalSeparator: String): string[];
    function CreateExactTimePatterns(ALongTimePattern: String; ADecimalSeparator: String): string[];
  end;


implementation

function TDateTimeParsingHelper.TryParseExactDateTime(ASource: String; ASettings: TClientSettings; A_result: TDateTime): Boolean;
begin
  exactDateTimePatterns: string[] := CreateExactDateTimePatterns(ASettings.ShortDatePattern, ASettings.LongTimePattern, ASettings.TimeSeparator, ASettings.DecimalSeparator);
  Result := DateTime.TryParseExact(ASource, exactDateTimePatterns, null, DateTimeStyles.None, out A_result);
end;

function TDateTimeParsingHelper.TryParseExactDateTime(ASource: String; A_result: TDateTime): Boolean;
begin
  Result := TryParseExactDateTimeLiteral(ASource, out A_result);
end;

function TDateTimeParsingHelper.TryParseExactTime(ASource: String; ASettings: TClientSettings; A_result: TDateTime): Boolean;
begin
  exactDateTimePatterns: string[] := CreateExactTimePatterns(ASettings.LongTimePattern, ASettings.DecimalSeparator);
  Result := DateTime.TryParseExact(ASource, exactDateTimePatterns, null, DateTimeStyles.None, out A_result);
end;

function TDateTimeParsingHelper.TryParseExactTime(ASource: String; A_result: TDateTime): Boolean;
begin
  Result := TryParseExactDateTimeLiteral(ASource, out A_result);
end;

function TDateTimeParsingHelper.TryParseExactDate(ASource: String; ASettings: TClientSettings; A_result: TDateTime): Boolean;
begin
  Result := DateTime.TryParseExact(ASource, ASettings.ShortDatePattern, null, DateTimeStyles.None, out A_result);
end;

function TDateTimeParsingHelper.TryParseExactDate(ASource: String; A_result: TDateTime): Boolean;
begin
  Result := TryParseExactDateTimeLiteral(ASource, out A_result);
end;

function TDateTimeParsingHelper.TryParseExactDateTimeLiteral(ASource: String; A_result: TDateTime): Boolean;
begin
  if not DateTime.TryParseExact(ASource, "O", CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out A_result) then
  begin
    Result := false;
  end
  ;
  if A_result.Kind <> 0 then
  begin
    Result := false;
  end
  ;
  A_result := TDateTime.Create(A_result.Year, A_result.Month, A_result.Day, A_result.Hour, A_result.Minute, A_result.Second, A_result.Millisecond, DateTimeKind.Local);
  Result := true;
end;

function TDateTimeParsingHelper.CreateExactDateTimePatterns(AShortDatePattern: String; ALongTimePattern: String; ATimeSeparator: String; ADecimalSeparator: String): string[];
begin
  Result := new string[3]
            {
                string.Format(CultureInfo.InvariantCulture, "{0} {1}", AShortDatePattern, ALongTimePattern),
                string.Format(CultureInfo.InvariantCulture, "{0} {1}", AShortDatePattern, ALongTimePattern.Replace(string.Format(CultureInfo.InvariantCulture, "{0}ss", ATimeSeparator), "")),
                string.Format(CultureInfo.InvariantCulture, "{0} {1}", AShortDatePattern, ALongTimePattern.Replace("ss", string.Format(CultureInfo.InvariantCulture, "ss{0}fff", ADecimalSeparator)))
            };
end;

function TDateTimeParsingHelper.CreateExactTimePatterns(ALongTimePattern: String; ADecimalSeparator: String): string[];
begin
  Result := new string[2]
            {
                ALongTimePattern,
                string.Format(CultureInfo.InvariantCulture, "{0}", ALongTimePattern.Replace("ss", string.Format(CultureInfo.InvariantCulture, "ss{0}fff", ADecimalSeparator)))
            };
end;


end.
