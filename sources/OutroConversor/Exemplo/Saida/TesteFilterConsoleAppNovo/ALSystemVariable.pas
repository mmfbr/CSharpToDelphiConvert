unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TALSystemVariable = class(TObject)
  public
    const m_XmlFormat: Integer = 9;
    function EvaluateIntoNavValue(ADataError: TDataError; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): TGoldValue;
    function ALEvaluate(ADataError: TDataError; AValue: TGoldDate; ASource: String; ANumber: Integer): Boolean;
    function ALEvaluate(ADataError: TDataError; AValue: TGoldTime; ASource: String; ANumber: Integer): Boolean;
  end;


implementation

function TALSystemVariable.EvaluateIntoNavValue(ADataError: TDataError; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): TGoldValue;
begin
  if AMetadata = null then
  begin
    raise TArgumentNullException.Create("AMetadata");
  end
  ;
  evaluator: TGoldValueEvaluator := TGoldValueEvaluator.GetEvaluator(AMetadata.NclType);
  if evaluator <> null then
  begin
    if not evaluator.Evaluate(ADataError, out var value, AMetadata, ASource, ANumber) then
    begin
      Result := null;
    end
    ;
    Result := value;
  end
  ;
  if ADataError = TDataError.TrapError then
  begin
    Result := null;
  end
  ;
  raise TGoldNCLNotSupportedTypeException.CreateUnknownType(CultureInfo.CurrentCulture, AMetadata.GoldType.ToString());
end;

function TALSystemVariable.ALEvaluate(ADataError: TDataError; AValue: TGoldDate; ASource: String; ANumber: Integer): Boolean;
begin
  Result := TGoldDateEvaluator.Instance.Evaluate(ADataError, out AValue, AValue, ASource, ANumber);
end;

function TALSystemVariable.ALEvaluate(ADataError: TDataError; AValue: TGoldTime; ASource: String; ANumber: Integer): Boolean;
begin
  Result := TGoldTimeEvaluator.Instance.Evaluate(ADataError, out AValue, AValue, ASource, ANumber);
end;


end.
