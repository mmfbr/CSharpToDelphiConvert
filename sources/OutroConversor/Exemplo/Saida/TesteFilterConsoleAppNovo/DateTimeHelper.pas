unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TDateTimeHelper = class(TObject)
  public
    const m_MinWeekNo: Integer = 1;
    procedure DateTimeToIsoYearWeek(ADt: TDateTime; AYear: Integer; AWeekNo: Integer);
    function DateTimeToIsoWeekNo(ADt: TDateTime): Integer;
    function IsoYearWeekToDateTime(AYear: Integer; AWeekNo: Integer): TDateTime;
    function MaxWeekNoOfYear(AYear: Integer): Integer;
    function GetDayMonthYearOrder(AShortDateSpecifier: String): String;
    function GetDayMonthYearIndex(ADateTextEvaluationOrder: String): int[];
    function DateTimeToDays(ADate: TDateTime): Integer;
    function DayOfWeekToNavDayNo(ADow: TDayOfWeek): Integer;
    function DaysToDateTime(AValue: Integer; AValueKind: TDateTimeKind): TDateTime;
    function DaysToDateTime(AValue: Integer): TDateTime;
    function IntDateNextThursday(AIntDate: Integer): Integer;
    function IntDateDec28(AYear: Integer; AIntDateJan1: Integer): Integer;
  end;


implementation

procedure TDateTimeHelper.DateTimeToIsoYearWeek(ADt: TDateTime; AYear: Integer; AWeekNo: Integer);
begin
  num: Integer := DateTimeToDays(ADt);
  num2: Integer := num mod 7 - 3;
  num3: Integer := num - num2;
  AYear := DaysToDateTime(num3).Year;
  num4: Integer := DateTimeToDays(TDateTime.Create(AYear, 1, 1));
  AWeekNo := (num3 - num4) / 7 + 1;
end;

function TDateTimeHelper.DateTimeToIsoWeekNo(ADt: TDateTime): Integer;
begin
  DateTimeToIsoYearWeek(ADt, out var year, out var weekNo);
  Result := year * 100 + weekNo;
end;

function TDateTimeHelper.IsoYearWeekToDateTime(AYear: Integer; AWeekNo: Integer): TDateTime;
begin
  if AYear < 1 or AYear > 9999 then
  begin
    raise TArgumentOutOfRangeException.Create("AYear");
  end
  ;
  if AWeekNo < 1 or AWeekNo > 53 then
  begin
    raise TArgumentOutOfRangeException.Create("AWeekNo");
  end
  ;
  num: Integer := DateTimeToDays(TDateTime.Create(AYear, 1, 1));
  num2: Integer := IntDateNextThursday(num);
  num3: Integer := num2 - 3;
  num4: Integer := num3 + (AWeekNo - 1) * 7;
  if AWeekNo = 53 then
  begin
    num5: Integer := IntDateDec28(AYear, num);
    if num4 > num5 then
    begin
      raise TArgumentOutOfRangeException.Create("AWeekNo");
    end
    ;
  end
  ;
  Result := DaysToDateTime(num4);
end;

function TDateTimeHelper.MaxWeekNoOfYear(AYear: Integer): Integer;
begin
  if AYear < 1 or AYear > 9999 then
  begin
    raise TArgumentOutOfRangeException.Create("AYear");
  end
  ;
  num: Integer := DateTimeToDays(TDateTime.Create(AYear, 1, 1));
  num2: Integer := IntDateNextThursday(num);
  num3: Integer := num2 - 3;
  num4: Integer := IntDateDec28(AYear, num);
  Result := (num4 - num3) / 7 + 1;
end;

function TDateTimeHelper.GetDayMonthYearOrder(AShortDateSpecifier: String): String;
begin
  if string.IsNullOrEmpty(AShortDateSpecifier) then
  begin
    Result := "DMY";
  end
  ;
  stringBuilder: TStringBuilder := TStringBuilder.Create(3);
  length: Integer := AShortDateSpecifier.Length;
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

function TDateTimeHelper.GetDayMonthYearIndex(ADateTextEvaluationOrder: String): int[];
begin
  array_: int[] := new int[3] { -1, -1, -1 };
  // TODO: Converter ForStatementSyntax
  Result := array_;
end;

function TDateTimeHelper.DateTimeToDays(ADate: TDateTime): Integer;
begin
  Result := (int)(ADate.Ticks / 864000000000L);
end;

function TDateTimeHelper.DayOfWeekToNavDayNo(ADow: TDayOfWeek): Integer;
begin
  if ADow <> 0 then
  begin
    Result := (int)ADow;
  end
  ;
  Result := 7;
end;

function TDateTimeHelper.DaysToDateTime(AValue: Integer; AValueKind: TDateTimeKind): TDateTime;
begin
  Result := TDateTime.Create(AValue * 864000000000L, AValueKind);
end;

function TDateTimeHelper.DaysToDateTime(AValue: Integer): TDateTime;
begin
  Result := DaysToDateTime(AValue, DateTimeKind.Local);
end;

function TDateTimeHelper.IntDateNextThursday(AIntDate: Integer): Integer;
begin
  num: Integer := 6 - (AIntDate + 3) % 7;
  Result := AIntDate + num;
end;

function TDateTimeHelper.IntDateDec28(AYear: Integer; AIntDateJan1: Integer): Integer;
begin
  num: Integer := AIntDateJan1 + 361;
  if DateTime.IsLeapYear(AYear) then
  begin
    num++;
  end
  ;
  Result := num;
end;


end.
