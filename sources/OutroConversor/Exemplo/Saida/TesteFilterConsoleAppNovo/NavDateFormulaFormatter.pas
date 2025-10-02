unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateFormulaFormatter = class(TGoldValueFormatter)
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
    function Format(ADateFormula: TGoldDateFormula; AFormatSettings: TFormatSettings; AStandardFormatNumber: Integer): String;
    function Format(ADateFormula: String; AFormatSettings: TFormatSettings; AStandardFormatNumber: Integer): String;
  end;


implementation

function TGoldDateFormulaFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
  Result := TGoldFormatEvaluateHelper.FormatWithFormatNumber(AValue, ALength, AFormatNumber, AFormatsetting);
end;

function TGoldDateFormulaFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)AFormatNumber <= 2u or AFormatNumber = 9 then
  begin
    Result := TFormatSettings.DateFormulaStdFormatStrings[AFormatNumber];
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.Duration);
end;

function TGoldDateFormulaFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  Result := true;
end;

function TGoldDateFormulaFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  Result := Format((TGoldDateFormula)AValue, ASettings, AFormat[APos++]);
end;

function TGoldDateFormulaFormatter.Format(ADateFormula: TGoldDateFormula; AFormatSettings: TFormatSettings; AStandardFormatNumber: Integer): String;
begin
  Result := Format(ADateFormula.Value, AFormatSettings, AStandardFormatNumber);
end;

function TGoldDateFormulaFormatter.Format(ADateFormula: String; AFormatSettings: TFormatSettings; AStandardFormatNumber: Integer): String;
begin
  flag: Boolean := AStandardFormatNumber = 2 or AStandardFormatNumber = 9;
  flag2: Boolean := AStandardFormatNumber = 2;
  array_: string[] := (if flag then TFormatSettings.GlobalDateQuantor else AFormatSettings.DateQuantor);
  stringBuilder: TStringBuilder := TStringBuilder.Create(ADateFormula.Length + 10);
  if flag2 then
  begin
    stringBuilder.Append('<');
  end
  ;
  for c in ADateFormula do
  begin
    if c > '\0' and c <= array_.Length then
    begin
      stringBuilder.Append(array_[c - 1]);
    end
    else
    begin
      stringBuilder.Append(c);
    end;
  end;
  if flag2 then
  begin
    stringBuilder.Append('>');
  end
  ;
  Result := stringBuilder.ToString();
end;


end.
