unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateTimeEvaluator = class(TGoldValueEvaluator<TGoldDateTime>)
  private
    m_instance: TGoldDateTimeEvaluator;
  public
    constructor Create();
    function InternalEvaluate(ADataError: TDataError; AValue: TGoldDateTime; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function NonXMLFormatEvaluate(AValue: TGoldDateTime; ASource: String; ANumber: Integer): Boolean;
    function HasTimePart(ASource: String): Boolean;
    function FindDateEnd(ASource: String; ATestZuluTimeMarker: Boolean): Integer;
    function XMLFormatEvaluate(AValue: TGoldDateTime; ASource: String): Boolean;
    function GetDefaultValue(AMetadata: INavValueMetadata): TGoldDateTime;
    property Instance: TGoldDateTimeEvaluator read GetInstance write SetInstance;
  end;


implementation

constructor TGoldDateTimeEvaluator.Create();
begin
  inherited Create;
end;

function TGoldDateTimeEvaluator.InternalEvaluate(ADataError: TDataError; AValue: TGoldDateTime; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  if ANumber = 9 then
  begin
    Result := XMLFormatEvaluate(out AValue, ASource);
  end
  ;
  Result := NonXMLFormatEvaluate(out AValue, ASource, ANumber);
end;

function TGoldDateTimeEvaluator.NonXMLFormatEvaluate(AValue: TGoldDateTime; ASource: String; ANumber: Integer): Boolean;
begin
  AValue := TGoldDateTime.Default;
  if string.IsNullOrWhiteSpace(ASource) then
  begin
    Result := true;
  end
  ;
  ASource := ASource.Trim();
  if TDateTimeParsingHelper.TryParseExactDateTime(ASource, TGoldCurrentSessionWrapper.RegionalSettings, out var result) or TDateTimeParsingHelper.TryParseExactDateTime(ASource, out result) then
  begin
    result := DateTime.SpecifyKind(result, DateTimeKind.Local);
  end
  else
  begin
    num: Integer := FindDateEnd(ASource);
    value2: TGoldDate := null;
    if not TALSystemVariable.ALEvaluate(TDataError.TrapError, ref value2, ASource.Substring(0, num), ANumber) then
    begin
      Result := false;
    end
    ;
    value3: TGoldTime := null;
    if num = ASource.Length then
    begin
      value3 := TGoldTime.Default;
    end
    else
    begin
      if not TALSystemVariable.ALEvaluate(TDataError.TrapError, ref value3, ASource.Substring(num, ASource.Length - num), ANumber) then
      begin
        Result := false;
      end
      ;
    end;
    result := TDateTime.Create(value2.m_value.Year, value2.m_value.Month, value2.m_value.Day, value3.m_value.Hour, value3.m_value.Minute, value3.m_value.Second, value3.m_value.Millisecond, DateTimeKind.Local);
  end;
  AValue := TGoldDateTime.Create(result, TDateTimeReferenceFrame.Client);
  Result := true;
end;

function TGoldDateTimeEvaluator.HasTimePart(ASource: String): Boolean;
begin
  text: String := ASource.Trim();
  Result := FindDateEnd(text, ATestZuluTimeMarker: true) <> text.Length;
end;

function TGoldDateTimeEvaluator.FindDateEnd(ASource: String; ATestZuluTimeMarker: Boolean): Integer;
begin
  if ATestZuluTimeMarker and ASource.EndsWith("Z", StringComparison.OrdinalIgnoreCase) and ASource.Any(char.IsDigit) then
  begin
    num: Integer := ASource.IndexOf("T", StringComparison.OrdinalIgnoreCase);
    if num > -1 then
    begin
      Result := num;
    end
    ;
  end
  ;
  dateSeparator: String := TGoldCurrentSessionWrapper.FormatSettings.DateSeparator;
  num2: Integer := dateSeparator.IndexOf(' ');
  // TODO: Converter ForStatementSyntax
  Result := ASource.Length;
end;

function TGoldDateTimeEvaluator.XMLFormatEvaluate(AValue: TGoldDateTime; ASource: String): Boolean;
begin
  AValue := TGoldDateTime.Default;
  if string.IsNullOrWhiteSpace(ASource) then
  begin
    Result := true;
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

function TGoldDateTimeEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): TGoldDateTime;
begin
  Result := TGoldDateTime.Default;
end;


end.
