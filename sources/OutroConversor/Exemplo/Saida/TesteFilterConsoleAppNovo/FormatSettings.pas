unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFormatSettings = class(TObject)
  private
    m_dateTypeFmt: TFormatOptions[];
    m_timeTypeFmt: TFormatOptions[];
    m_datetimeTypeFmt: TFormatOptions[];
    m_decimalTypeFmt: TFormatOptions[];
    m_integerTypeFmt: TFormatOptions[];
    m_dateQuantor: string[];
  public
    constructor Create();
    function Create(ALcid: Integer; AClientSettings: TClientSettings): TFormatSettings;
    procedure DateUpdateFmt(AClientSettings: TClientSettings);
    procedure TimeUpdateFmt(AClientSettings: TClientSettings);
    procedure DatetimeUpdateFmt(AClientSettings: TClientSettings);
    function BuildFormat(AFormatArgs: char[]): String;
    function BuildGenericStdFormatStrings(): string[];
    procedure SetDMYFormat(ADmy: Char; AFmt1: Char; AFmt2: Char; AMonth0: Char; AMonth1: Char; AYear0: Char; ADay1: Char);
    function FirstCharOrZero(AClientProperty: String): Char;
    function GetShortDatePattern(AClientSettings: TClientSettings): String;
    property DateTypeFmt: TFormatOptions[] read GetDateTypeFmt write SetDateTypeFmt;
    property TimeTypeFmt: TFormatOptions[] read GetTimeTypeFmt write SetTimeTypeFmt;
    property DatetimeTypeFmt: TFormatOptions[] read GetDatetimeTypeFmt write SetDatetimeTypeFmt;
    property DecimalTypeFmt: TFormatOptions[] read GetDecimalTypeFmt write SetDecimalTypeFmt;
    property IntegerTypeFmt: TFormatOptions[] read GetIntegerTypeFmt write SetIntegerTypeFmt;
    property DateStdFormatStrings: string[] read GetDateStdFormatStrings write SetDateStdFormatStrings;
    property TimeStdFormatStrings: string[] read GetTimeStdFormatStrings write SetTimeStdFormatStrings;
    property DatetimeStdFormatStrings: string[] read GetDatetimeStdFormatStrings write SetDatetimeStdFormatStrings;
    property TextStdFormatStrings: String read GetTextStdFormatStrings write SetTextStdFormatStrings;
    property IntegerStdFormatStrings: String read GetIntegerStdFormatStrings write SetIntegerStdFormatStrings;
    property DateTextEvalOrder: String read GetDateTextEvalOrder write SetDateTextEvalOrder;
    property ClosingDateCharacter: String read GetClosingDateCharacter write SetClosingDateCharacter;
    property WorkDate: String read GetWorkDate write SetWorkDate;
    property ToDay: String read GetToDay write SetToDay;
    property Time: String read GetTime write SetTime;
    property DateRangeCentury: Integer read GetDateRangeCentury write SetDateRangeCentury;
    property ServerCultureInfo: TCultureInfo read GetServerCultureInfo write SetServerCultureInfo;
    property DateTextMonthNames: string[] read GetDateTextMonthNames write SetDateTextMonthNames;
    property DateTextWeekdayNames: string[] read GetDateTextWeekdayNames write SetDateTextWeekdayNames;
    property DateSeparator: String read GetDateSeparator write SetDateSeparator;
    property TimeSeparator: String read GetTimeSeparator write SetTimeSeparator;
    property DecimalSeparator: String read GetDecimalSeparator write SetDecimalSeparator;
    property ShortDatePattern: String read GetShortDatePattern write SetShortDatePattern;
    property LongTimePattern: String read GetLongTimePattern write SetLongTimePattern;
    property ShortTimePattern: String read GetShortTimePattern write SetShortTimePattern;
    property FieldFormatComma: Char read GetFieldFormatComma write SetFieldFormatComma;
    property FieldFormatThousand: Char read GetFieldFormatThousand write SetFieldFormatThousand;
    property TimeAMDesignator: String read GetTimeAMDesignator write SetTimeAMDesignator;
    property TimePMDesignator: String read GetTimePMDesignator write SetTimePMDesignator;
    property BooleanOptions: string[] read GetBooleanOptions write SetBooleanOptions;
    property DateFormulaStdFormatStrings: string[] read GetDateFormulaStdFormatStrings write SetDateFormulaStdFormatStrings;
    property GenericStdFormatStrings: string[] read GetGenericStdFormatStrings write SetGenericStdFormatStrings;
    property GlobalDateQuantor: string[] read GetGlobalDateQuantor write SetGlobalDateQuantor;
    property DateQuantor: string[] read GetDateQuantor write SetDateQuantor;
  end;


implementation

constructor TFormatSettings.Create();
begin
  DateStdFormatStrings := new string[10];
  TimeStdFormatStrings := new string[10];
  DatetimeStdFormatStrings := new string[10];
end;

function TFormatSettings.Create(ALcid: Integer; AClientSettings: TClientSettings): TFormatSettings;
begin
  AClientSettings.LCID := ALcid;
  formatSettings: TFormatSettings := TFormatSettings.Create();
  formatSettings.ServerCultureInfo := CultureInfo.GetCultureInfo(ALcid);
  formatSettings.ClosingDateCharacter := "C";
  formatSettings.WorkDate := "DATADOTRABALHO";
  formatSettings.ToDay := "HOJE";
  formatSettings.Time := "HORA";
  formatSettings.DateRangeCentury := 1950;
  formatSettings.FieldFormatComma := FirstCharOrZero(AClientSettings.DecimalSeparator);
  formatSettings.FieldFormatThousand := FirstCharOrZero(AClientSettings.GroupSeparator);
  formatSettings.DateTextEvalOrder := TDateTimeHelper.GetDayMonthYearOrder(AClientSettings.ShortDatePattern);
  formatSettings.DateSeparator := AClientSettings.DateSeparator;
  formatSettings.TimeSeparator := AClientSettings.TimeSeparator;
  formatSettings.DecimalSeparator := AClientSettings.DecimalSeparator;
  formatSettings.ShortDatePattern := GetShortDatePattern(AClientSettings);
  formatSettings.ShortTimePattern := AClientSettings.ShortTimeFormat;
  formatSettings.LongTimePattern := AClientSettings.LongTimePattern;
  formatSettings.DateUpdateFmt(AClientSettings);
  formatSettings.TimeUpdateFmt(AClientSettings);
  formatSettings.DatetimeUpdateFmt(AClientSettings);
  formatSettings.m_dateQuantor := null;
  formatSettings.BooleanOptions := ["Não", "Sim"];
  Result := formatSettings;
end;

procedure TFormatSettings.DateUpdateFmt(AClientSettings: TClientSettings);
begin
  c: Char := (if string.IsNullOrEmpty(AClientSettings.DateSeparator) then ' ' else AClientSettings.DateSeparator[0]);
  SetDMYFormat(DateTextEvalOrder[0], out var fmt, out var fmt2, '\u0004', '\u0002', '\a', '\u0002');
  SetDMYFormat(DateTextEvalOrder[1], out var fmt3, out var fmt4, '\u0004', '\u0002', '\a', '\u0002');
  SetDMYFormat(DateTextEvalOrder[2], out var fmt5, out var fmt6, '\u0004', '\u0002', '\a', '\u0002');
  DateStdFormatStrings[0] := BuildFormat('\u000e', '\0', fmt, fmt2, c, fmt3, fmt4, c, fmt5, fmt6);
  DateStdFormatStrings[1] := BuildFormat('\u000e', '\0', fmt, fmt2, c, fmt3, fmt4, c, fmt5, fmt6);
  DateStdFormatStrings[2] := BuildFormat(fmt, fmt2, fmt3, fmt4, fmt5, fmt6, '\u000e', '\0', 'D');
  dateStdFormatStrings: string[] := DateStdFormatStrings;
  obj: char[] := new char[10] { '\u000e', '\0', '\a', '\0', '\0', '\u0004', '\u0002', '\0', '\u0003', '\u0002' };
  obj[4] := c;
  obj[7] := c;
  dateStdFormatStrings[3] := BuildFormat(obj);
  DateStdFormatStrings[5] := BuildFormat('\u000e', '\0', fmt, fmt2, fmt3, fmt4, fmt5, fmt6);
  DateStdFormatStrings[6] := BuildFormat('\u000e', '\0', '\a', '\0', '\u0004', '\u0002', '\u0003', '\u0002');
  SetDMYFormat(DateTextEvalOrder[0], out fmt, out fmt2, '\u0005', '\0', '\b', '\0');
  SetDMYFormat(DateTextEvalOrder[1], out fmt3, out fmt4, '\u0005', '\0', '\b', '\0');
  SetDMYFormat(DateTextEvalOrder[2], out fmt5, out fmt6, '\u0005', '\0', '\b', '\0');
  if DateTextEvalOrder[2] = 'D' then
  begin
    dateStdFormatStrings2: string[] := DateStdFormatStrings;
    obj2: char[] := new char[11]
                {
                    '\u000e', '\0', '\0', '\0', ' ', '\0', '\0', ' ', '\0', '\0',
                    '.'
                };
    obj2[2] := fmt;
    obj2[3] := fmt2;
    obj2[5] := fmt3;
    obj2[6] := fmt4;
    obj2[8] := fmt5;
    obj2[9] := fmt6;
    dateStdFormatStrings2[4] := BuildFormat(obj2);
  end
  else
  begin
    if DateTextEvalOrder[1] = 'D' then
    begin
      dateStdFormatStrings3: string[] := DateStdFormatStrings;
      obj3: char[] := new char[11]
                {
                    '\0', '\0', ' ', '\u000e', '\0', '\0', '\0', ',', ' ', '\0',
                    '\0'
                };
      obj3[0] := fmt;
      obj3[1] := fmt2;
      obj3[5] := fmt3;
      obj3[6] := fmt4;
      obj3[9] := fmt5;
      obj3[10] := fmt6;
      dateStdFormatStrings3[4] := BuildFormat(obj3);
    end
    else
    begin
      dateStdFormatStrings4: string[] := DateStdFormatStrings;
      obj4: char[] := new char[11]
                {
                    '\u000e', '\0', '\0', '\0', '.', ' ', '\0', '\0', ' ', '\0',
                    '\0'
                };
      obj4[2] := fmt;
      obj4[3] := fmt2;
      obj4[6] := fmt3;
      obj4[7] := fmt4;
      obj4[9] := fmt5;
      obj4[10] := fmt6;
      dateStdFormatStrings4[4] := BuildFormat(obj4);
    end;
  end;
  DateStdFormatStrings[7] := BuildFormat('\u0003', '\u0002', '\u001c', ' ', '.', ' ', '\u0005', '\u0003', ' ', '\b', '\0');
  DateStdFormatStrings[9] := BuildFormat('\b', '\0', '-', '\u0004', '\u0002', '-', '\u0003', '\u0002');
end;

procedure TFormatSettings.TimeUpdateFmt(AClientSettings: TClientSettings);
begin
  flag: Boolean := not string.IsNullOrEmpty(AClientSettings.ShortTimeFormat) and AClientSettings.ShortTimeFormat.IndexOf('H') <> -1;
  flag2: Boolean := not string.IsNullOrEmpty(AClientSettings.ShortTimeZero) and AClientSettings.ShortTimeZero.IndexOf("HH", StringComparison.OrdinalIgnoreCase) <> -1;
  c: Char := (if string.IsNullOrEmpty(AClientSettings.TimeSeparator) then ' ' else AClientSettings.TimeSeparator[0]);
  c2: Char := '\u0004';
  c2 := (if not flag2 then (if flag then '\u0003' else '\u0004') else (if flag then '\n' else '\v'));
  TimeAMDesignator := AClientSettings.TimeAMDesignator;
  TimePMDesignator := AClientSettings.TimePMDesignator;
  if flag then
  begin
    timeStdFormatStrings: string[] := TimeStdFormatStrings;
    obj: char[] := new char[8] { '\0', '\u0002', '\0', '\u0005', '\u0002', '\0', '\u0006', '\u0002' };
    obj[0] := c2;
    obj[2] := c;
    obj[5] := c;
    timeStdFormatStrings[0] := BuildFormat(obj);
    timeStdFormatStrings2: string[] := TimeStdFormatStrings;
    obj2: char[] := new char[10] { '\0', '\u0002', '\0', '\u0005', '\u0002', '\0', '\u0006', '\u0002', '\t', '\0' };
    obj2[0] := c2;
    obj2[2] := c;
    obj2[5] := c;
    timeStdFormatStrings2[1] := BuildFormat(obj2);
  end
  else
  begin
    timeStdFormatStrings3: string[] := TimeStdFormatStrings;
    obj3: char[] := new char[11]
                {
                    '\0', '\u0002', '\0', '\u0005', '\u0002', '\0', '\u0006', '\u0002', ' ', '\b',
                    '\0'
                };
    obj3[0] := c2;
    obj3[2] := c;
    obj3[5] := c;
    timeStdFormatStrings3[0] := BuildFormat(obj3);
    timeStdFormatStrings4: string[] := TimeStdFormatStrings;
    obj4: char[] := new char[13]
                {
                    '\0', '\u0002', '\0', '\u0005', '\u0002', '\0', '\u0006', '\u0002', '\t', '\0',
                    ' ', '\b', '\0'
                };
    obj4[0] := c2;
    obj4[2] := c;
    obj4[5] := c;
    timeStdFormatStrings4[1] := BuildFormat(obj4);
  end;
  TimeStdFormatStrings[2] := BuildFormat('\u0003', '\u0002', '\u001c', '0', '\u0005', '\u0002', '\u0006', '\u0002', '\t', '\0', '\u001a', '.', 'T');
  TimeStdFormatStrings[9] := BuildFormat('\u0003', '\u0002', '\u001c', '0', ':', '\u0005', '\u0002', ':', '\u0006', '\u0002', '\t', '\0', '\u001a', '.');
end;

procedure TFormatSettings.DatetimeUpdateFmt(AClientSettings: TClientSettings);
begin
  c: Char := (if string.IsNullOrEmpty(AClientSettings.DateSeparator) then ' ' else AClientSettings.DateSeparator[0]);
  SetDMYFormat(DateTextEvalOrder[0], out var fmt, out var fmt2, '\u0004', '\u0002', '\a', '\u0002');
  SetDMYFormat(DateTextEvalOrder[1], out var fmt3, out var fmt4, '\u0004', '\u0002', '\a', '\u0002');
  SetDMYFormat(DateTextEvalOrder[2], out var fmt5, out var fmt6, '\u0004', '\u0002', '\a', '\u0002');
  flag: Boolean := not string.IsNullOrEmpty(AClientSettings.ShortTimeFormat) and AClientSettings.ShortTimeFormat.IndexOf('H') <> -1;
  c2: Char := (if string.IsNullOrEmpty(AClientSettings.TimeSeparator) then ' ' else AClientSettings.TimeSeparator[0]);
  c3: Char := (if flag then '\u000e' else '\u000f');
  TimeAMDesignator := AClientSettings.TimeAMDesignator;
  TimePMDesignator := AClientSettings.TimePMDesignator;
  if flag then
  begin
    datetimeStdFormatStrings: string[] := DatetimeStdFormatStrings;
    obj: char[] := new char[14]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002'
                };
    obj[0] := fmt;
    obj[1] := fmt2;
    obj[2] := c;
    obj[3] := fmt3;
    obj[4] := fmt4;
    obj[5] := c;
    obj[6] := fmt5;
    obj[7] := fmt6;
    obj[9] := c3;
    obj[11] := c2;
    datetimeStdFormatStrings[0] := BuildFormat(obj);
    datetimeStdFormatStrings2: string[] := DatetimeStdFormatStrings;
    obj2: char[] := new char[19]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002', '\0', '\u0011', '\u0002', '\u0014', '\0'
                };
    obj2[0] := fmt;
    obj2[1] := fmt2;
    obj2[2] := c;
    obj2[3] := fmt3;
    obj2[4] := fmt4;
    obj2[5] := c;
    obj2[6] := fmt5;
    obj2[7] := fmt6;
    obj2[9] := c3;
    obj2[11] := c2;
    obj2[14] := c2;
    datetimeStdFormatStrings2[1] := BuildFormat(obj2);
    datetimeStdFormatStrings3: string[] := DatetimeStdFormatStrings;
    obj3: char[] := new char[14]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002'
                };
    obj3[0] := fmt;
    obj3[1] := fmt2;
    obj3[2] := c;
    obj3[3] := fmt3;
    obj3[4] := fmt4;
    obj3[5] := c;
    obj3[6] := fmt5;
    obj3[7] := fmt6;
    obj3[9] := c3;
    obj3[11] := c2;
    datetimeStdFormatStrings3[2] := BuildFormat(obj3);
    datetimeStdFormatStrings4: string[] := DatetimeStdFormatStrings;
    obj4: char[] := new char[17]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002', '\0', '\u0011', '\u0002'
                };
    obj4[0] := fmt;
    obj4[1] := fmt2;
    obj4[2] := c;
    obj4[3] := fmt3;
    obj4[4] := fmt4;
    obj4[5] := c;
    obj4[6] := fmt5;
    obj4[7] := fmt6;
    obj4[9] := c3;
    obj4[11] := c2;
    obj4[14] := c2;
    datetimeStdFormatStrings4[3] := BuildFormat(obj4);
  end
  else
  begin
    datetimeStdFormatStrings5: string[] := DatetimeStdFormatStrings;
    obj5: char[] := new char[17]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002', ' ', '\u0013', '\0'
                };
    obj5[0] := fmt;
    obj5[1] := fmt2;
    obj5[2] := c;
    obj5[3] := fmt3;
    obj5[4] := fmt4;
    obj5[5] := c;
    obj5[6] := fmt5;
    obj5[7] := fmt6;
    obj5[9] := c3;
    obj5[11] := c2;
    datetimeStdFormatStrings5[0] := BuildFormat(obj5);
    datetimeStdFormatStrings6: string[] := DatetimeStdFormatStrings;
    obj6: char[] := new char[22]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002', '\0', '\u0011', '\u0002', '\u0014', '\0', ' ',
                    '\u0013', '\0'
                };
    obj6[0] := fmt;
    obj6[1] := fmt2;
    obj6[2] := c;
    obj6[3] := fmt3;
    obj6[4] := fmt4;
    obj6[5] := c;
    obj6[6] := fmt5;
    obj6[7] := fmt6;
    obj6[9] := c3;
    obj6[11] := c2;
    obj6[14] := c2;
    datetimeStdFormatStrings6[1] := BuildFormat(obj6);
    datetimeStdFormatStrings7: string[] := DatetimeStdFormatStrings;
    obj7: char[] := new char[17]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002', ' ', '\u0013', '\0'
                };
    obj7[0] := fmt;
    obj7[1] := fmt2;
    obj7[2] := c;
    obj7[3] := fmt3;
    obj7[4] := fmt4;
    obj7[5] := c;
    obj7[6] := fmt5;
    obj7[7] := fmt6;
    obj7[9] := c3;
    obj7[11] := c2;
    datetimeStdFormatStrings7[2] := BuildFormat(obj7);
    datetimeStdFormatStrings8: string[] := DatetimeStdFormatStrings;
    obj8: char[] := new char[20]
                {
                    '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', ' ', '\0',
                    '\u0002', '\0', '\u0010', '\u0002', '\0', '\u0011', '\u0002', ' ', '\u0013', '\0'
                };
    obj8[0] := fmt;
    obj8[1] := fmt2;
    obj8[2] := c;
    obj8[3] := fmt3;
    obj8[4] := fmt4;
    obj8[5] := c;
    obj8[6] := fmt5;
    obj8[7] := fmt6;
    obj8[9] := c3;
    obj8[11] := c2;
    obj8[14] := c2;
    datetimeStdFormatStrings8[3] := BuildFormat(obj8);
  end;
  DatetimeStdFormatStrings[9] := BuildFormat('\b', '\0', '-', '\u0004', '\u0002', '-', '\u0003', '\u0002', 'T', '\u000e', '\u0002', ':', '\u0010', '\u0002', ':', '\u0011', '\u0002', '\u0014', '\0', '\u001a', '.', 'Z');
end;

function TFormatSettings.BuildFormat(AFormatArgs: char[]): String;
begin
  Result := Tstring.Create(AFormatArgs);
end;

function TFormatSettings.BuildGenericStdFormatStrings(): string[];
begin
  array_: string[] := new string[10];
  // TODO: Converter ForStatementSyntax
  Result := array_;
end;

procedure TFormatSettings.SetDMYFormat(ADmy: Char; AFmt1: Char; AFmt2: Char; AMonth0: Char; AMonth1: Char; AYear0: Char; ADay1: Char);
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TFormatSettings.FirstCharOrZero(AClientProperty: String): Char;
begin
  if not string.IsNullOrEmpty(AClientProperty) then
  begin
    Result := AClientProperty[0];
  end
  ;
  Result := '\0';
end;

function TFormatSettings.GetShortDatePattern(AClientSettings: TClientSettings): String;
begin
  if not string.IsNullOrEmpty(AClientSettings.ShortDatePattern) then
  begin
    Result := AClientSettings.ShortDatePattern;
  end
  ;
  culture: Integer := (if AClientSettings.WindowsLCID > 0 then AClientSettings.WindowsLCID else AClientSettings.LCID);
  cultureInfo: TCultureInfo := CultureInfo.GetCultureInfo(culture);
  Result := cultureInfo.DateTimeFormat.ShortDatePattern;
end;


end.
