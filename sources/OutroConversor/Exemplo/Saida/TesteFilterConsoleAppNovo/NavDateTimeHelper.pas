unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateTimeHelper = class(TObject)
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
    function ToClosingValueIfTimeIsDateTimeMinimum(AFromNavDateTime: TGoldDateTime): TGoldDateTime;
  end;


implementation

function TGoldDateTimeHelper.CSideDateToDateTime(ACsideDate: Integer; ACsideDateKind: TDateTimeKind): TDateTime;
begin
  if ACsideDate <= 7304850 then
  begin
    if ACsideDate >= 737 then
    begin
      _result: TDateTime := TDateTimeHelper.DaysToDateTime((ACsideDate - 737) / 2 + 2, ACsideDateKind);
      if (ACsideDate & 1) = 0 then
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

function TGoldDateTimeHelper.CSideDateToDateTime(ACsideDate: Integer): TDateTime;
begin
  Result := CSideDateToDateTime(ACsideDate, DateTimeKind.Local);
end;

function TGoldDateTimeHelper.DateTimeToCSideDate(AValue: TDateTime): Integer;
begin
  if AValue = m_DateTimeUndefined then
  begin
    Result := 0;
  end
  ;
  num: Integer := TDateTimeHelper.DateTimeToDays(AValue);
  num2: Integer := (if AValue.Ticks mod 864000000000L = m_DateTimeClosingTicks then 1 else 0);
  Result := num switch
            {
                0 => throw TGoldNCLDateInvalidException.Create(),
                1 => 1 + num2,
                _ => 737 + (num - 2) * 2 + num2,
            };
end;

function TGoldDateTimeHelper.CSideDateTimeToDateTime(ACsideDateTime: Int64): TDateTime;
begin
  if ACsideDateTime = 0L then
  begin
    Result := m_DateTimeUndefined;
  end
  ;
  ACsideDateTime--;
  csideDate: Integer := 1 + 2 * (int)(ACsideDateTime / 86400000);
  num: Int64 := ACsideDateTime mod 86400000 * 10000;
  Result := TDateTime.Create(CSideDateToDateTime(csideDate, DateTimeKind.Utc).Ticks + num, DateTimeKind.Utc);
end;

function TGoldDateTimeHelper.DateTimeToCSideDateTime(AValue: TDateTime): Int64;
begin
  if AValue = m_DateTimeUndefined then
  begin
    Result := 0L;
  end
  ;
  num: Integer := DateTimeToCSideDate(AValue.Date);
  if num = 0 then
  begin
    raise TGoldNCLDateInvalidException.Create();
  end
  ;
  num2: Int64 := AValue.Ticks mod 864000000000L;
  Result := 1 + num / 2 * 86400000L + num2 / 10000;
end;

function TGoldDateTimeHelper.CSideTimeToDateTime(AValue: Integer): TDateTime;
begin
  if AValue = 0 then
  begin
    Result := m_DateTimeUndefined;
  end
  ;
  if AValue < 0 or AValue > 86400000 then
  begin
    raise TGoldNCLInvalidTimeException.Create();
  end
  ;
  Result := m_DateTimeMinimum.AddTicks(10000L * (AValue - 1));
end;

function TGoldDateTimeHelper.DateTimeToCSideTime(AValue: TDateTime): Integer;
begin
  if AValue = m_DateTimeUndefined then
  begin
    Result := 0;
  end
  ;
  Result := 1 + (int)(AValue.Ticks mod 864000000000L / 10000);
end;

function TGoldDateTimeHelper.RoundDateTimeToMilliseconds(ADt: TDateTime): TDateTime;
begin
  Result := TDateTime.Create(ADt.Year, ADt.Month, ADt.Day, ADt.Hour, ADt.Minute, ADt.Second, ADt.Millisecond, ADt.Kind);
end;

function TGoldDateTimeHelper.ToClosingValueIfTimeIsDateTimeMinimum(AFromNavDateTime: TGoldDateTime): TGoldDateTime;
begin
  if !(AFromNavDateTime.TimePart = m_DateTimeMinimum) then
  begin
    Result := AFromNavDateTime;
  end
  ;
  Result := TGoldDateTime.Create(AFromNavDateTime.DatePart.m_value.AddTicks(m_DateTimeClosingTicks), TDateTimeReferenceFrame.Client);
end;


end.
