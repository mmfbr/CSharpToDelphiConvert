unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TALSystemDate = class(TObject)
  public
    function ALNormalDate(ADate: TGoldDate): TGoldDate;
    function ALClosingDate(ADate: TGoldDate): TGoldDate;
    function ALDT2Date(ADateTime: TGoldDateTime): TGoldDate;
    function ALWorkDate(): TGoldDate;
    function ALWorkDate(AWorkDate: TGoldDate): TGoldDate;
    function ALDate2DMY(ADate: TGoldDate; AComponent: Integer): Integer;
    function ALDMY2Date(ADay: Integer; AMonth: Integer; AYear: Integer; AClosing: Boolean): TGoldDate;
    function ALDate2DWY(ADate: TGoldDate; AComponent: Integer): Integer;
    function ALDWY2Date(AWeekday: Integer): TGoldDate;
    function ALDWY2Date(AWeekday: Integer; AWeek: Integer): TGoldDate;
    function ALDWY2Date(AWeekday: Integer; AWeek: Integer; AYear: Integer): TGoldDate;
    function ALCalcDate(ADateExpression: TGoldDateFormula): TGoldDate;
    function ALCalcDate(ADateExpression: TGoldDateFormula; ADateValue: TGoldDate): TGoldDate;
    function ALCalcDate(ADateExpression: String; ADateValue: TGoldDate): TGoldDate;
    function ALCalcDate(ADateExpression: TObject; ADateValue: TGoldDate): TGoldDate;
    function ALCalcDate(ADateExpression: String): TGoldDate;
    function ALCalcDate(ADateExpression: TObject): TGoldDate;
    function ALDT2Time(ADateTime: TGoldDateTime): TGoldTime;
    function ALRoundDateTime(ADateTime: TGoldDateTime): TGoldDateTime;
    function ALRoundDateTime(ADateTime: TGoldDateTime; APrecision: Int64): TGoldDateTime;
    function ALRoundDateTime(ADateTime: TGoldDateTime; ADirection: String): TGoldDateTime;
    function ALRoundDateTime(ADateTime: TGoldDateTime; APrecision: Int64; ADirection: String): TGoldDateTime;
    function ALCreateDateTime(ADate: TGoldDate; ATime: TGoldTime): TGoldDateTime;
    property ALToday: TGoldDate read GetALToday write SetALToday;
    property ALTime: TGoldTime read GetALTime write SetALTime;
    property ALCurrentDateTime: TGoldDateTime read GetALCurrentDateTime write SetALCurrentDateTime;
  end;


implementation

function TALSystemDate.ALNormalDate(ADate: TGoldDate): TGoldDate;
begin
  if ADate = null then
  begin
    raise TArgumentNullException.Create("ADate");
  end
  ;
  if TGoldDate.IsNormalDate(ADate) then
  begin
    Result := ADate;
  end
  ;
  Result := TGoldDate.CreateDate(ADate.Value, closing: false);
end;

function TALSystemDate.ALClosingDate(ADate: TGoldDate): TGoldDate;
begin
  if ADate = null then
  begin
    raise TArgumentNullException.Create("ADate");
  end
  ;
  if TGoldDate.IsClosingDate(ADate) then
  begin
    Result := ADate;
  end
  ;
  Result := TGoldDate.CreateDate(ADate.Value, closing: true);
end;

function TALSystemDate.ALDT2Date(ADateTime: TGoldDateTime): TGoldDate;
begin
  if ADateTime = null then
  begin
    raise TArgumentNullException.Create("ADateTime");
  end
  ;
  Result := ADateTime.DatePart;
end;

function TALSystemDate.ALWorkDate(): TGoldDate;
begin
  if TGoldCurrentThread.Session = null then
  begin
    Result := TGoldDate.CreateDate(DateTime.Today, false);
  end
  else
  begin
    Result := TGoldCurrentThread.Session.WorkDate;
  end;
end;

function TALSystemDate.ALWorkDate(AWorkDate: TGoldDate): TGoldDate;
begin
  TGoldCurrentThread.Session.WorkDate := AWorkDate;
  Result := TGoldCurrentThread.Session.WorkDate;
end;

function TALSystemDate.ALDate2DMY(ADate: TGoldDate; AComponent: Integer): Integer;
begin
  if ADate = null then
  begin
    raise TArgumentNullException.Create("ADate");
  end
  ;
  value: TDateTime := ADate.Value;
  if value = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  if value.Date = TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    // TODO: Converter SwitchStatementSyntax
  end
  else
  begin
    // TODO: Converter SwitchStatementSyntax
  end;
  raise TGoldNCLOutsidePermittedRangeException.Create("DATE2DMY", 2, AComponent, 1, 3);
end;

function TALSystemDate.ALDMY2Date(ADay: Integer; AMonth: Integer; AYear: Integer; AClosing: Boolean): TGoldDate;
begin
  if AYear = 0 and AMonth = 1 and ADay = 1 then
  begin
    Result := TGoldDate.Create(TGoldDateTimeHelper.m_DateTimeMinimum);
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TALSystemDate.ALDate2DWY(ADate: TGoldDate; AComponent: Integer): Integer;
begin
  if ADate = null then
  begin
    raise TArgumentNullException.Create("ADate");
  end
  ;
  value: TDateTime := ADate.Value;
  if value = TGoldDateTimeHelper.m_DateTimeUndefined then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  if value.Date = TGoldDateTimeHelper.m_DateTimeMinimum then
  begin
    // TODO: Converter SwitchStatementSyntax
  end
  else
  begin
    // TODO: Converter SwitchStatementSyntax
  end;
  raise TGoldNCLOutsidePermittedRangeException.Create("DATE2DWY", 2, AComponent, 1, 3);
end;

function TALSystemDate.ALDWY2Date(AWeekday: Integer): TGoldDate;
begin
  aLToday: TGoldDate := ALToday;
  Result := ALDWY2Date(AWeekday, ALDate2DWY(aLToday, 2), ALDate2DWY(aLToday, 3));
end;

function TALSystemDate.ALDWY2Date(AWeekday: Integer; AWeek: Integer): TGoldDate;
begin
  aLToday: TGoldDate := ALToday;
  Result := ALDWY2Date(AWeekday, AWeek, ALDate2DWY(aLToday, 3));
end;

function TALSystemDate.ALDWY2Date(AWeekday: Integer; AWeek: Integer; AYear: Integer): TGoldDate;
begin
  if AWeekday = 6 and AWeek = 53 and AYear = -1 then
  begin
    Result := TGoldDate.Create(TGoldDateTimeHelper.m_DateTimeMinimum);
  end
  ;
  if AWeekday < 1 or AWeekday > 7 then
  begin
    raise TGoldNCLOutsidePermittedRangeException.Create("DWY2Date", 1, AWeekday, 1, 7);
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TALSystemDate.ALCalcDate(ADateExpression: TGoldDateFormula): TGoldDate;
begin
  if ADateExpression = null then
  begin
    raise TArgumentNullException.Create("ADateExpression");
  end
  ;
  Result := ALCalcDate(ADateExpression, ALToday);
end;

function TALSystemDate.ALCalcDate(ADateExpression: TGoldDateFormula; ADateValue: TGoldDate): TGoldDate;
begin
  if ADateExpression = null then
  begin
    raise TArgumentNullException.Create("ADateExpression");
  end
  ;
  if ADateValue = null then
  begin
    raise TArgumentNullException.Create("ADateValue");
  end
  ;
  Result := ADateExpression.CalcDate(ADateValue);
end;

function TALSystemDate.ALCalcDate(ADateExpression: String; ADateValue: TGoldDate): TGoldDate;
begin
  if ADateExpression = null then
  begin
    raise TArgumentNullException.Create("ADateExpression");
  end
  ;
  if ADateValue = null then
  begin
    raise TArgumentNullException.Create("ADateValue");
  end
  ;
  Result := TGoldDateFormula.Create(ADateExpression).CalcDate(ADateValue);
end;

function TALSystemDate.ALCalcDate(ADateExpression: TObject; ADateValue: TGoldDate): TGoldDate;
begin
  raise TGoldNCLArgumentException.Create(TLang.IllegalCalcDateArgument);
end;

function TALSystemDate.ALCalcDate(ADateExpression: String): TGoldDate;
begin
  if ADateExpression = null then
  begin
    raise TArgumentNullException.Create("ADateExpression");
  end
  ;
  Result := ALCalcDate(ADateExpression, ALToday);
end;

function TALSystemDate.ALCalcDate(ADateExpression: TObject): TGoldDate;
begin
  raise TGoldNCLArgumentException.Create(TLang.IllegalCalcDateArgument);
end;

function TALSystemDate.ALDT2Time(ADateTime: TGoldDateTime): TGoldTime;
begin
  if ADateTime = null then
  begin
    raise TArgumentNullException.Create("ADateTime");
  end
  ;
  Result := ADateTime.TimePart;
end;

function TALSystemDate.ALRoundDateTime(ADateTime: TGoldDateTime): TGoldDateTime;
begin
  Result := ALRoundDateTime(ADateTime, 1000L, "=");
end;

function TALSystemDate.ALRoundDateTime(ADateTime: TGoldDateTime; APrecision: Int64): TGoldDateTime;
begin
  Result := ALRoundDateTime(ADateTime, APrecision, "=");
end;

function TALSystemDate.ALRoundDateTime(ADateTime: TGoldDateTime; ADirection: String): TGoldDateTime;
begin
  Result := ALRoundDateTime(ADateTime, 1000L, ADirection);
end;

function TALSystemDate.ALRoundDateTime(ADateTime: TGoldDateTime; APrecision: Int64; ADirection: String): TGoldDateTime;
begin
  if ADateTime.IsZeroOrEmpty then
  begin
    Result := ADateTime;
  end
  ;
  if APrecision <= 0 then
  begin
    raise TGoldNCLArgumentException.Create(APrecision, "ROUNDDATETIME", 2);
  end
  ;
  if ADirection = null or ADirection.Length <> 1 or "<=>".IndexOf(ADirection[0]) < 0 then
  begin
    raise TGoldNCLArgumentException.Create(ADirection, "ROUNDDATETIME", 3);
  end
  ;
  num: Int64 := TGoldDateTime.ConvertCSideDateTimeToClientLocal(TGoldDateTimeHelper.DateTimeToCSideDateTime(ADateTime.Value));
  num--;
  num2: Int64 := num mod APrecision;
  // TODO: Converter SwitchStatementSyntax
  num++;
  Result := TGoldDateTime.Create(TGoldDateTimeHelper.CSideDateTimeToDateTime(TGoldDateTime.ConvertCSideDateTimeToUtc(num, AAdjustNonexistentDateTime: true)));
end;

function TALSystemDate.ALCreateDateTime(ADate: TGoldDate; ATime: TGoldTime): TGoldDateTime;
begin
  if ADate = null then
  begin
    raise TArgumentNullException.Create("ADate");
  end
  ;
  if ATime = null then
  begin
    raise TArgumentNullException.Create("ATime");
  end
  ;
  if ADate.IsZeroOrEmpty then
  begin
    if ATime.IsZeroOrEmpty then
    begin
      Result := TGoldDateTime.Undefined;
    end
    ;
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  dateTime: TDateTime := ADate.ToDateTime();
  if not ATime.IsZeroOrEmpty then
  begin
    dateTime := dateTime.AddTicks(ATime.Value.TimeOfDay.Ticks);
  end
  ;
  if dateTime < TGoldDateTimeHelper.m_DateTimeJan1st1601 then
  begin
    Result := TGoldDateTime.Create(TDateTime.Create(dateTime.Ticks, DateTimeKind.Utc));
  end
  ;
  Result := TGoldDateTime.CreateFromClientTimeAllowingForNonexistentTime(dateTime);
end;


end.
