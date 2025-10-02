unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldTextFormatter = class(TGoldValueFormatter)
  private
    m_TextFieldNames: TReadOnlyCollection<string>;
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function GetFieldNames(): TReadOnlyCollection<string>;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
  end;


implementation

function TGoldTextFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
  if (uint)formatNumber <= 2u or formatNumber = 9 then
  begin
    Result := ((TGoldStringValue)value).Value;
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, formatNumber, TGoldNclTypeHelper.GetNavTypeFromNclType(value.NclType));
end;

function TGoldTextFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)formatNumber <= 2u or formatNumber = 9 then
  begin
    Result := TFormatSettings.TextStdFormatStrings;
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, formatNumber, TGoldType.Text);
end;

function TGoldTextFormatter.GetFieldNames(): TReadOnlyCollection<string>;
begin
  Result := m_TextFieldNames;
end;

function TGoldTextFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  nclType: TGoldNclType := value.NclType;
  Result := false;
end;

function TGoldTextFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  TGoldFormatEvaluateHelper.GetFieldFormatFromString(options, format, ref pos);
  if value.NclType = TGoldNclType.GoldCode or value.NclType = TGoldNclType.GoldOemCode then
  begin
    options.LeftJustify := true;
  end
  ;
  Result := ((TGoldStringValue)value).Value;
end;


end.
