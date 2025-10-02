unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldGenericFormatter = class(TGoldValueFormatter)
  public
    function FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
    function GetStandardFormat(AFormatNumber: Integer): String;
    function PadLeft(AValue: TGoldValue): Boolean;
    function FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
  end;


implementation

function TGoldGenericFormatter.FormatWithFormatNumber(AValue: TGoldValue; ALength: Integer; AFormatNumber: Integer; AFormatsetting: TFormatSettings): String;
begin
  if (uint)AFormatNumber <= 2u or AFormatNumber = 9 then
  begin
    // TODO: Converter SwitchStatementSyntax
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldNclTypeHelper.GetNavTypeFromNclType(AValue.NclType));
end;

function TGoldGenericFormatter.GetStandardFormat(AFormatNumber: Integer): String;
begin
  if (uint)AFormatNumber <= 2u or AFormatNumber = 9 then
  begin
    Result := TFormatSettings.GenericStdFormatStrings[AFormatNumber];
  end
  ;
  raise TGoldNCLInvalidStandardFormatException.Create(CultureInfo.CurrentCulture, AFormatNumber, TGoldType.None);
end;

function TGoldGenericFormatter.PadLeft(AValue: TGoldValue): Boolean;
begin
  Result := false;
end;

function TGoldGenericFormatter.FormatField(AValue: TGoldValue; AOptions: TFormatOptions; ASettings: TFormatSettings; AFormat: String; APos: Integer): String;
begin
  Result := Format(AValue, AOptions.Length, AFormat[APos++], ASettings);
end;


end.
