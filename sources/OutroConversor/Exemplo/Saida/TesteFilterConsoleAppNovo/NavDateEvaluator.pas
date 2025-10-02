unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateEvaluator = class(TGoldValueEvaluator<TGoldDate>)
  private
    m_instance: TGoldDateEvaluator;
  public
    constructor Create();
    function InternalEvaluate(ADataError: TDataError; AValue: TGoldDate; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function GetDefaultValue(AMetadata: INavValueMetadata): TGoldDate;
    function XMLFormatEvaluate(AValue: TGoldDate; ASource: String): Boolean;
    function ClosingDateEvaluate(ASource: String; APosition: Integer): Boolean;
    function WorkDateTodayEvaluate(AValue: TGoldDate; ASource: String; APosition: Integer; AIsClosingDate: Boolean): Boolean;
    function DayWeekYearEvaluate(AValue: TGoldDate; ASource: String; APosition: Integer; AIsClosingDate: Boolean; AOriginalString: String): Boolean;
    function DayMonthYearEvaluate(AValue: TGoldDate; ASource: String; APosition: Integer; AIsClosingDate: Boolean; AOriginalString: String): Boolean;
    function TryReadLetterToken(AInput: String; APosition: Integer; A_result: String): Boolean;
    procedure ConsumeSpecialCharactersAndWhitespace(AInput: String; APosition: Integer);
    function IsWhiteSpaceOrDigit(ASource: String; APosition: Integer): Boolean;
    function CreateDateFromDMY(ADay: Integer; AMonth: Integer; AYear: Integer; AIsClosingDate: Boolean; AOriginalString: String): TGoldDate;
    function MapShortYearNumberToYear(AYearNumber: Integer): Integer;
    function ThrowNavDateEvalError(AOriginalString: String): TGoldNCLEvaluateException;
    property Instance: TGoldDateEvaluator read GetInstance write SetInstance;
  end;


implementation

constructor TGoldDateEvaluator.Create();
begin
  inherited Create;
end;

function TGoldDateEvaluator.InternalEvaluate(ADataError: TDataError; AValue: TGoldDate; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  if string.IsNullOrWhiteSpace(source) then
  begin
    value := TGoldDate.Default;
    Result := true;
  end
  ;
  if number = 9 or Regex.IsMatch(source, "^\\d{4}-\\d{2}-\\d{2}") then
  begin
    Result := XMLFormatEvaluate(out value, source);
  end
  ;
  originalString: String := source;
  source := source.Trim();
  if source[source.Length - 1] = 'D' then
  begin
    source := source.Substring(0, source.Length - 1);
  end
  ;
  if TDateTimeParsingHelper.TryParseExactDate(source, TGoldCurrentSessionWrapper.RegionalSettings, out var result) or TDateTimeParsingHelper.TryParseExactDate(source, out result) then
  begin
    value := TGoldDate.Create(DateTime.SpecifyKind(result, DateTimeKind.Local));
    Result := true;
  end
  ;
  position: Integer := 0;
  isClosingDate: Boolean := ClosingDateEvaluate(source, ref position);
  if WorkDateTodayEvaluate(out value, source, position, isClosingDate) then
  begin
    Result := true;
  end
  ;
  if DayWeekYearEvaluate(out value, source, position, isClosingDate, originalString) then
  begin
    Result := true;
  end
  ;
  Result := DayMonthYearEvaluate(out value, source, position, isClosingDate, originalString);
end;

function TGoldDateEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): TGoldDate;
begin
  Result := TGoldDate.Default;
end;

function TGoldDateEvaluator.XMLFormatEvaluate(AValue: TGoldDate; ASource: String): Boolean;
begin
  value := TGoldDate.Default;
  originalString: String := source;
  source := source.Trim();
  if string.IsNullOrWhiteSpace(source) then
  begin
    Result := true;
  end
  ;
  if source.Length > 2 and source[source.Length - 3] <> '-' then
  begin
    Result := false;
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TGoldDateEvaluator.ClosingDateEvaluate(ASource: String; APosition: Integer): Boolean;
begin
  _result: Boolean := false;
  closingDateCharacter: String := TGoldCurrentSessionWrapper.FormatSettings.ClosingDateCharacter;
  if StartsWith(source, position, closingDateCharacter) then
  begin
    position := closingDateCharacter.Length;
    if source.Length = closingDateCharacter.Length or IsWhiteSpaceOrDigit(source, position) then
    begin
      _result := true;
      ConsumeSpecialCharactersAndWhitespace(source, ref position);
    end
    else
    begin
      position := closingDateCharacter.Length;
    end;
  end
  ;
  Result := _result;
end;

function TGoldDateEvaluator.WorkDateTodayEvaluate(AValue: TGoldDate; ASource: String; APosition: Integer; AIsClosingDate: Boolean): Boolean;
begin
  workDate: String := TGoldCurrentSessionWrapper.FormatSettings.WorkDate;
  if StartsWith(workDate, 0, source, position) then
  begin
    value := TALSystemDate.ALWorkDate();
    if isClosingDate then
    begin
      value := TALSystemDate.ALClosingDate(value);
    end
    ;
    Result := true;
  end
  ;
  toDay: String := TGoldCurrentSessionWrapper.FormatSettings.ToDay;
  if StartsWith(toDay, 0, source, position) then
  begin
    value := TALSystemDate.ALToday;
    if isClosingDate then
    begin
      value := TALSystemDate.ALClosingDate(value);
    end
    ;
    Result := true;
  end
  ;
  value := TGoldDate.Default;
  Result := false;
end;

function TGoldDateEvaluator.DayWeekYearEvaluate(AValue: TGoldDate; ASource: String; APosition: Integer; AIsClosingDate: Boolean; AOriginalString: String): Boolean;
begin
  if TryReadLetterToken(source, ref position, out var result) then
  begin
    dateTextWeekdayNames: string[] := TGoldCurrentSessionWrapper.FormatSettings.DateTextWeekdayNames;
    firstDayOfWeek: Integer := (int)TGoldCurrentSessionWrapper.FormatSettings.ServerCultureInfo.DateTimeFormat.FirstDayOfWeek;
    flag: Boolean := false;
    num: Integer := firstDayOfWeek;
    // TODO: Converter ForStatementSyntax
    if not flag then
    begin
      raise ThrowNavDateEvalError(originalString);
    end
    ;
    num := (if num = 0 then 7 else num);
    ConsumeSpecialCharactersAndWhitespace(source, ref position);
    numberOfDigitsInLongNumber: Integer;
    array_: int[] := EvaluateNumberSequence(source, ref position, 2, 1, 4, out numberOfDigitsInLongNumber);
    if array_ = null or position <> source.Length then
    begin
      raise ThrowNavDateEvalError(originalString);
    end
    ;
    navDate: TGoldDate := null;
    if array_[0] < 0 then
    begin
      navDate := TALSystemDate.ALWorkDate();
      array_[0] := TALSystemDate.ALDate2DWY(navDate, 2);
    end
    ;
    if array_[1] < 0 then
    begin
      if navDate = null then
      begin
        navDate := TALSystemDate.ALWorkDate();
      end
      ;
      array_[1] := TALSystemDate.ALDate2DWY(navDate, 3);
    end
    else
    begin
      if numberOfDigitsInLongNumber <= 2 then
      begin
        array_[1] := MapShortYearNumberToYear(array_[1]);
      end
      ;
    end;
    // TODO: Converter TryStatementSyntax
    if isClosingDate then
    begin
      value := TALSystemDate.ALClosingDate(value);
    end
    ;
    Result := true;
  end
  ;
  value := TGoldDate.Default;
  Result := false;
end;

function TGoldDateEvaluator.DayMonthYearEvaluate(AValue: TGoldDate; ASource: String; APosition: Integer; AIsClosingDate: Boolean; AOriginalString: String): Boolean;
begin
  value := TGoldDate.Default;
  if position >= source.Length then
  begin
    Result := false;
  end
  ;
  dayMonthYearIndex: int[] := TDateTimeHelper.GetDayMonthYearIndex(TGoldCurrentSessionWrapper.FormatSettings.DateTextEvalOrder);
  num: Integer := dayMonthYearIndex[0];
  num2: Integer := dayMonthYearIndex[1];
  num3: Integer := dayMonthYearIndex[2];
  array_: int[];
  numberOfDigitsInLongNumber: Integer;
  if num3 = 0 then
  begin
    num4: Integer := position;
    array_ := EvaluateNumberSequence(source, ref position, 3, num3, 2, out numberOfDigitsInLongNumber);
    if array_ = null or position <> source.Length then
    begin
      position := num4;
      array_ := EvaluateNumberSequence(source, ref position, 3, num3, 4, out numberOfDigitsInLongNumber);
    end
    ;
    if array_ = null or array_[0] < 0 then
    begin
      Result := false;
    end
    ;
    if array_[0] >= 0 and array_[1] >= 0 and array_[2] < 0 then
    begin
      array_[2] := array_[1];
      array_[1] := array_[0];
      array_[0] := -1;
    end
    ;
  end
  else
  begin
    array_ := EvaluateNumberSequence(source, ref position, 3, num3, 4, out numberOfDigitsInLongNumber);
    if array_ = null or array_[0] < 0 then
    begin
      Result := false;
    end
    ;
  end;
  if array_[0] >= 0 and array_[1] < 0 and array_[2] < 0 then
  begin
    array_[num] := array_[0];
    array_[num2] := -1;
    array_[num3] := -1;
  end
  ;
  navDate: TGoldDate := null;
  if array_[num] < 0 then
  begin
    navDate := TALSystemDate.ALWorkDate();
    array_[num] := TALSystemDate.ALDate2DMY(navDate, 1);
  end
  ;
  if array_[num2] < 0 then
  begin
    if navDate = null then
    begin
      navDate := TALSystemDate.ALWorkDate();
    end
    ;
    array_[num2] := TALSystemDate.ALDate2DMY(navDate, 2);
  end
  ;
  if array_[num3] < 0 then
  begin
    if navDate = null then
    begin
      navDate := TALSystemDate.ALWorkDate();
    end
    ;
    array_[num3] := TALSystemDate.ALDate2DMY(navDate, 3);
  end
  else
  begin
    if numberOfDigitsInLongNumber <= 2 then
    begin
      array_[num3] := MapShortYearNumberToYear(array_[num3]);
    end
    ;
  end;
  value := CreateDateFromDMY(array_[num], array_[num2], array_[num3], isClosingDate, originalString);
  Result := true;
end;

function TGoldDateEvaluator.TryReadLetterToken(AInput: String; APosition: Integer; A_result: String): Boolean;
begin
  _result := null;
  num: Integer := position;
  // TODO: Converter WhileStatementSyntax
  if num = position then
  begin
    Result := false;
  end
  ;
  _result := input.Substring(num, position - num);
  Result := true;
end;

procedure TGoldDateEvaluator.ConsumeSpecialCharactersAndWhitespace(AInput: String; APosition: Integer);
begin
  array_: char[] := new char[4] { '.', ':', '/', '-' };
  // TODO: Converter WhileStatementSyntax
end;

function TGoldDateEvaluator.IsWhiteSpaceOrDigit(ASource: String; APosition: Integer): Boolean;
begin
  if not char.IsWhiteSpace(source, position) then
  begin
    Result := char.IsDigit(source, position);
  end
  ;
  Result := true;
end;

function TGoldDateEvaluator.CreateDateFromDMY(ADay: Integer; AMonth: Integer; AYear: Integer; AIsClosingDate: Boolean; AOriginalString: String): TGoldDate;
begin
  // TODO: Converter TryStatementSyntax
end;

function TGoldDateEvaluator.MapShortYearNumberToYear(AYearNumber: Integer): Integer;
begin
  if yearNumber < 100 then
  begin
    dateRangeCentury: Integer := TGoldCurrentSessionWrapper.FormatSettings.DateRangeCentury;
    num: Integer := dateRangeCentury mod 100;
    dateRangeCentury := num;
    yearNumber := dateRangeCentury + (yearNumber < num ? 100 : 0);
  end
  ;
  Result := yearNumber;
end;

function TGoldDateEvaluator.ThrowNavDateEvalError(AOriginalString: String): TGoldNCLEvaluateException;
begin
  raise TGoldNCLEvaluateException.Create(CultureInfo.CurrentCulture, TGoldType.Date, originalString);
end;


end.
