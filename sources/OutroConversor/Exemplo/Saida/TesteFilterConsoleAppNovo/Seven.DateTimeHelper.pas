unit Seven.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TBusinessDateTimeHelper = class(TObject)
  private
    m_datePeriodStartMinimumDate: TDateTime[];
    m_datePeriodStartMaximumDate: TDateTime[];
    m_datePeriodEndMaximumDate: TDateTime[];
  public
    const m_DefaultShortDateEvalOrder: String = "DMY";
    const m_DaysInWeek: Integer = 7;
    const m_MinWeekNo: Integer = 1;
    const m_MaxWeekNo: Integer = 53;
    procedure DateTimeToIsoYearWeek(ADt: TDateTime; AYear: Integer; AWeekNo: Integer);
    function DateTimeToIsoWeekNo(ADt: TDateTime): Integer;
    function IsoYearWeekToDateTime(AYear: Integer; AWeekNo: Integer): TDateTime;
    function IsoWeekNoToDateTime(AIsoWeekNo: Integer): TDateTime;
    function MaxWeekNoOfYear(AYear: Integer): Integer;
    function GetDayMonthYearOrder(AShortDateSpecifier: String): String;
    function GetDayMonthYearIndex(ADateTextEvaluationOrder: String): int[];
    function TruncateMilliseconds(ADateTime: TDateTime): TDateTime;
    function DateTimeToDays(ADate: TDateTime): Integer;
    function DayOfWeekToNavDayNo(ADow: TDayOfWeek): Integer;
    function DaysToDateTime(AValue: Integer; AValueKind: TDateTimeKind): TDateTime;
    function DaysToDateTime(AValue: Integer): TDateTime;
    function IsDateAtStartOfPeriod(ADate: TDateTime; APeriodType: TBusinessDatePeriodType): Boolean;
    function DatePeriodRoundDown(ADate: TDateTime; APeriodType: TBusinessDatePeriodType; A_result: TDateTime): Boolean;
    function DatePeriodRoundUp(ADate: TDateTime; APeriodType: TBusinessDatePeriodType; A_result: TDateTime): Boolean;
    function DatePeriodStartMinimumDate(APeriodType: TBusinessDatePeriodType): TDateTime;
    function DatePeriodStartMaximumDate(APeriodType: TBusinessDatePeriodType): TDateTime;
    function IntDateNextThursday(AIntDate: Integer): Integer;
    function IntDateDec28(AYear: Integer; AIntDateJan1: Integer): Integer;
  end;


implementation

procedure TBusinessDateTimeHelper.DateTimeToIsoYearWeek(ADt: TDateTime; AYear: Integer; AWeekNo: Integer);
begin
  num: Integer := DateTimeToDays(dt);
  num2: Integer := num mod 7 - 3;
  num3: Integer := num - num2;
  year := DaysToDateTime(num3).Year;
  num4: Integer := DateTimeToDays(TDateTime.Create(year, 1, 1));
  weekNo := (num3 - num4) / 7 + 1;
end;

function TBusinessDateTimeHelper.DateTimeToIsoWeekNo(ADt: TDateTime): Integer;
begin
  DateTimeToIsoYearWeek(dt, out var year, out var weekNo);
  Result := year * 100 + weekNo;
end;

function TBusinessDateTimeHelper.IsoYearWeekToDateTime(AYear: Integer; AWeekNo: Integer): TDateTime;
begin
  if year < 1 or year > 9999 then
  begin
    raise TArgumentOutOfRangeException.Create("year");
  end
  ;
  if weekNo < 1 or weekNo > 53 then
  begin
    raise TArgumentOutOfRangeException.Create("weekNo");
  end
  ;
  num: Integer := DateTimeToDays(TDateTime.Create(year, 1, 1));
  num2: Integer := IntDateNextThursday(num);
  num3: Integer := num2 - 3;
  num4: Integer := num3 + (weekNo - 1) * 7;
  if weekNo = 53 then
  begin
    num5: Integer := IntDateDec28(year, num);
    if num4 > num5 then
    begin
      raise TArgumentOutOfRangeException.Create("weekNo");
    end
    ;
  end
  ;
  Result := DaysToDateTime(num4);
end;

function TBusinessDateTimeHelper.IsoWeekNoToDateTime(AIsoWeekNo: Integer): TDateTime;
begin
  Result := IsoYearWeekToDateTime(isoWeekNo / 100, isoWeekNo mod 100);
end;

function TBusinessDateTimeHelper.MaxWeekNoOfYear(AYear: Integer): Integer;
begin
  if year < 1 or year > 9999 then
  begin
    raise TArgumentOutOfRangeException.Create("year");
  end
  ;
  num: Integer := DateTimeToDays(TDateTime.Create(year, 1, 1));
  num2: Integer := IntDateNextThursday(num);
  num3: Integer := num2 - 3;
  num4: Integer := IntDateDec28(year, num);
  Result := (num4 - num3) / 7 + 1;
end;

function TBusinessDateTimeHelper.GetDayMonthYearOrder(AShortDateSpecifier: String): String;
begin
  if string.IsNullOrEmpty(shortDateSpecifier) then
  begin
    Result := "DMY";
  end
  ;
  stringBuilder: TStringBuilder := TStringBuilder.Create(3);
  length: Integer := shortDateSpecifier.Length;
  num: Integer := 0;
  flag: Boolean := false;
  flag2: Boolean := false;
  flag3: Boolean := false;
  // TODO: Converter WhileStatementSyntax
  if not flag or not flag2 or not flag3 then
  begin
    Result := "DMY";
  end
  ;
  Result := stringBuilder.ToString();
end;

function TBusinessDateTimeHelper.GetDayMonthYearIndex(ADateTextEvaluationOrder: String): int[];
begin
  array_: int[] := new int[3] { -1, -1, -1 };
  // TODO: Converter ForStatementSyntax
  Result := array_;
end;

function TBusinessDateTimeHelper.TruncateMilliseconds(ADateTime: TDateTime): TDateTime;
begin
  Result := TDateTime.Create(dateTime.Year, dateTime.Month, dateTime.Day, dateTime.Hour, dateTime.Minute, dateTime.Second, dateTime.Kind);
end;

function TBusinessDateTimeHelper.DateTimeToDays(ADate: TDateTime): Integer;
begin
  Result := (int)(date.Ticks / 864000000000L);
end;

function TBusinessDateTimeHelper.DayOfWeekToNavDayNo(ADow: TDayOfWeek): Integer;
begin
  if dow <> 0 then
  begin
    Result := (int)dow;
  end
  ;
  Result := 7;
end;

function TBusinessDateTimeHelper.DaysToDateTime(AValue: Integer; AValueKind: TDateTimeKind): TDateTime;
begin
  Result := TDateTime.Create(value * 864000000000L, valueKind);
end;

function TBusinessDateTimeHelper.DaysToDateTime(AValue: Integer): TDateTime;
begin
  Result := DaysToDateTime(value, DateTimeKind.Local);
end;

function TBusinessDateTimeHelper.IsDateAtStartOfPeriod(ADate: TDateTime; APeriodType: TBusinessDatePeriodType): Boolean;
begin
  if date < m_datePeriodStartMinimumDate[(int)periodType] or date > m_datePeriodStartMaximumDate[(int)periodType] then
  begin
    Result := false;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TBusinessDateTimeHelper.DatePeriodRoundDown(ADate: TDateTime; APeriodType: TBusinessDatePeriodType; A_result: TDateTime): Boolean;
begin
  if date < m_datePeriodStartMinimumDate[(int)periodType] or date > m_datePeriodEndMaximumDate[(int)periodType] then
  begin
    _result := date;
    Result := false;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TBusinessDateTimeHelper.DatePeriodRoundUp(ADate: TDateTime; APeriodType: TBusinessDatePeriodType; A_result: TDateTime): Boolean;
begin
  if date < m_datePeriodStartMinimumDate[(int)periodType] or date > m_datePeriodEndMaximumDate[(int)periodType] then
  begin
    _result := date;
    Result := false;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TBusinessDateTimeHelper.DatePeriodStartMinimumDate(APeriodType: TBusinessDatePeriodType): TDateTime;
begin
  Result := m_datePeriodStartMinimumDate[(int)periodType];
end;

function TBusinessDateTimeHelper.DatePeriodStartMaximumDate(APeriodType: TBusinessDatePeriodType): TDateTime;
begin
  Result := m_datePeriodStartMaximumDate[(int)periodType];
end;

function TBusinessDateTimeHelper.IntDateNextThursday(AIntDate: Integer): Integer;
begin
  num: Integer := 6 - (intDate + 3) % 7;
  Result := intDate + num;
end;

function TBusinessDateTimeHelper.IntDateDec28(AYear: Integer; AIntDateJan1: Integer): Integer;
begin
  num: Integer := intDateJan1 + 361;
  if DateTime.IsLeapYear(year) then
  begin
    num++;
  end
  ;
  Result := num;
end;


end.
