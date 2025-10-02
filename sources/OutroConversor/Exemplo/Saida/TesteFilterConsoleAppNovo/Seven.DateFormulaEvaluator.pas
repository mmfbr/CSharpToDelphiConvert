unit Seven.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TBusinessDateFormulaEvaluator = class(TObject)
  public
    function Parse(AValue: String; AFormatNumber: Integer): String;
    function CalcDate(AValue: String; ADateValue: TDateTime): TDateTime;
    function CalcDate(AValue: String): TDateTime;
  end;


implementation

function TBusinessDateFormulaEvaluator.Parse(AValue: String; AFormatNumber: Integer): String;
begin
  Result := TBusinessInternalEvaluator.Create(value).Parse(formatNumber);
end;

function TBusinessDateFormulaEvaluator.CalcDate(AValue: String; ADateValue: TDateTime): TDateTime;
begin
  Result := TBusinessInternalEvaluator.Create(value).CalcDate(dateValue);
end;

function TBusinessDateFormulaEvaluator.CalcDate(AValue: String): TDateTime;
begin
  Result := CalcDate(value, DateTime.Today);
end;


end.
