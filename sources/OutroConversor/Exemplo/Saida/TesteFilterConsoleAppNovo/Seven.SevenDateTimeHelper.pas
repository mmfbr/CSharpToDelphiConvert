unit Seven.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TBusinessDateTimeUtils = class(TObject)
  public
    const m_CSideDateUndefined: Integer = 0;
    const m_CSideTimeUndefined: Integer = 0;
    const m_CSideDateTimeUndefined: Int64 = 0L;
    const m_CSideDateMinimum: Integer = 1;
    const m_DateTimeMinimumDateXmlFormatPrefix: String = "0001-01-02T";
    const m_CSideDateTimeZero: Int64 = 1L;
    const m_CSideDateMinimumClosing: Integer = 2;
    const m_CSideDateFirstSupported: Integer = 737;
    const m_CSideDateMaximumClosing: Integer = 7304850;
    const m_MillisecondsPerDay: Integer = 86400000;
    function CSideDateToDateTime(ACsideDate: Integer; ACsideDateKind: TDateTimeKind): TDateTime;
    function CSideDateToDateTime(ACsideDate: Integer): TDateTime;
    function DateTimeToCSideDate(AValue: TDateTime): Integer;
    function CSideDateTimeToDateTime(ACsideDateTime: Int64): TDateTime;
    function DateTimeToCSideDateTime(AValue: TDateTime): Int64;
    function CSideTimeToDateTime(AValue: Integer): TDateTime;
    function DateTimeToCSideTime(AValue: TDateTime): Integer;
    function RoundDateTimeToMilliseconds(ADt: TDateTime): TDateTime;
  end;


implementation

function TBusinessDateTimeUtils.CSideDateToDateTime(ACsideDate: Integer; ACsideDateKind: TDateTimeKind): TDateTime;
begin
  if csideDate <= 7304850 then
  begin
    if csideDate >= 737 then
    begin
      _result: TDateTime := TBusinessDateTimeHelper.DaysToDateTime((csideDate - 737) / 2 + 2, csideDateKind);
      if (csideDate & 1) = 0 then
      begin
        Result := _result.AddTicks(m_DateTimeClosingTicks);
      end
      ;
      Result := _result;
    end
    ;
    // TODO: Converter SwitchStatementSyntax
  end
  ;
  raise TGoldNCLDateInvalidException.Create();
end;

function TBusinessDateTimeUtils.CSideDateToDateTime(ACsideDate: Integer): TDateTime;
begin
  Result := CSideDateToDateTime(csideDate, DateTimeKind.Local);
end;

function TBusinessDateTimeUtils.DateTimeToCSideDate(AValue: TDateTime): Integer;
begin
  if value = m_DateTimeUndefined then
  begin
    Result := 0;
  end
  ;
  num: Integer := TBusinessDateTimeHelper.DateTimeToDays(value);
  num2: Integer := (if value.Ticks mod 864000000000L = m_DateTimeClosingTicks then 1 else 0);
  Result := num switch
            {
                0 => throw TGoldNCLDateInvalidException.Create(),
                1 => 1 + num2,
                _ => 737 + (num - 2) * 2 + num2,
            };
end;

function TBusinessDateTimeUtils.CSideDateTimeToDateTime(ACsideDateTime: Int64): TDateTime;
begin
  if csideDateTime = 0L then
  begin
    Result := m_DateTimeUndefined;
  end
  ;
  csideDateTime--;
  csideDate: Integer := 1 + 2 * (int)(csideDateTime / 86400000);
  num: Int64 := csideDateTime mod 86400000 * 10000;
  Result := TDateTime.Create(CSideDateToDateTime(csideDate, DateTimeKind.Utc).Ticks + num, DateTimeKind.Utc);
end;

function TBusinessDateTimeUtils.DateTimeToCSideDateTime(AValue: TDateTime): Int64;
begin
  if value = m_DateTimeUndefined then
  begin
    Result := 0L;
  end
  ;
  num: Integer := DateTimeToCSideDate(value.Date);
  if num = 0 then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  num2: Int64 := value.Ticks mod 864000000000L;
  Result := 1 + num / 2 * 86400000L + num2 / 10000;
end;

function TBusinessDateTimeUtils.CSideTimeToDateTime(AValue: Integer): TDateTime;
begin
  if value = 0 then
  begin
    Result := m_DateTimeUndefined;
  end
  ;
  if value < 0 or value > 86400000 then
  begin
    raise TGoldNCLInvalidTimeException.Create();
  end
  ;
  Result := m_DateTimeMinimum.AddTicks(10000L * (value - 1));
end;

function TBusinessDateTimeUtils.DateTimeToCSideTime(AValue: TDateTime): Integer;
begin
  if value = m_DateTimeUndefined then
  begin
    Result := 0;
  end
  ;
  Result := 1 + (int)(value.Ticks mod 864000000000L / 10000);
end;

function TBusinessDateTimeUtils.RoundDateTimeToMilliseconds(ADt: TDateTime): TDateTime;
begin
  Result := TDateTime.Create(dt.Year, dt.Month, dt.Day, dt.Hour, dt.Minute, dt.Second, dt.Millisecond, dt.Kind);
end;


end.
