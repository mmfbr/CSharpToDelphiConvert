unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldDateFormulaEvaluator = class(TGoldValueEvaluator<TGoldDateFormula>)
  private
    m_instance: TGoldDateFormulaEvaluator;
  public
    constructor Create();
    function InternalEvaluate(ADataError: TDataError; AValue: TGoldDateFormula; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function GetDefaultValue(AMetadata: INavValueMetadata): TGoldDateFormula;
    function Parse(AValue: String; AFormatNumber: Integer): String;
    function CalcDate(AValue: String; ADateValue: TGoldDate): TGoldDate;
    property Instance: TGoldDateFormulaEvaluator read GetInstance write SetInstance;
  end;


implementation

constructor TGoldDateFormulaEvaluator.Create();
begin
  inherited Create;
end;

function TGoldDateFormulaEvaluator.InternalEvaluate(ADataError: TDataError; AValue: TGoldDateFormula; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  value := TGoldDateFormula.Create(Parse(source, number), isTokenString: true);
  Result := true;
end;

function TGoldDateFormulaEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): TGoldDateFormula;
begin
  Result := TGoldDateFormula.Default;
end;

function TGoldDateFormulaEvaluator.Parse(AValue: String; AFormatNumber: Integer): String;
begin
  Result := TInternalEvaluator.Create(value).Parse(formatNumber);
end;

function TGoldDateFormulaEvaluator.CalcDate(AValue: String; ADateValue: TGoldDate): TGoldDate;
begin
  Result := TInternalEvaluator.Create(value).CalcDate(dateValue);
end;


end.
