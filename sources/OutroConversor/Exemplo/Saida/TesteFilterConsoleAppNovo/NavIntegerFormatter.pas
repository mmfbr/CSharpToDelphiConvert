unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldIntegerFormatter = class(TGoldValueFormatter)
  private
    m_IntegerFieldNames: TReadOnlyCollection<string>;
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function GetFieldNames(): TReadOnlyCollection<string>;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
    function FormatThousandField(AIntegerStr: String; AOptions: TFormatOptions; ASettings: TFormatSettings): String;
  end;


implementation

function TGoldIntegerFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
  if (uint)AFormatNumber <= 2u or AFormatNumber = 9 then
  begin
    Result := AValue.ToInt32().ToString("d", TGoldCurrentThread.Session.WindowsCulture);
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.Integer);
end;

function TGoldIntegerFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)AFormatNumber <= 2u or AFormatNumber = 9 then
  begin
    Result := TFormatSettings.IntegerStdFormatStrings;
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.Integer);
end;

function TGoldIntegerFormatter.GetFieldNames(): TReadOnlyCollection<string>;
begin
  Result := m_IntegerFieldNames;
end;

function TGoldIntegerFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  Result := true;
end;

function TGoldIntegerFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  _result: String := null;
  navInteger: TGoldInteger := (TGoldInteger)AValue;
  AOptions.Initialize(TFormatSettings.IntegerTypeFmt[AOptions.Field - 3]);
  TGoldFormatEvaluateHelper.GetFieldFormatFromString(AOptions, AFormat, ref APos);
  // TODO: Converter SwitchStatementSyntax
  Result := _result;
end;

function TGoldIntegerFormatter.FormatThousandField(AIntegerStr: String; AOptions: TFormatOptions; ASettings: TFormatSettings): String;
begin
  num: Integer := AIntegerStr.Length;
  startIndex: Integer := 0;
  if AIntegerStr[0] = '-' then
  begin
    startIndex := 1;
    num--;
  end
  ;
  text: String := AIntegerStr.Substring(startIndex, num);
  num := text.Length;
  c: Char := (if AOptions.Character1000 = '\u0002' then ASettings.FieldFormatThousand else AOptions.Character1000);
  if c <> 0 and num > 3 then
  begin
    stringBuilder: TStringBuilder := TStringBuilder.Create(25);
    // TODO: Converter ForStatementSyntax
    text := stringBuilder.ToString();
  end
  ;
  Result := text;
end;


end.
