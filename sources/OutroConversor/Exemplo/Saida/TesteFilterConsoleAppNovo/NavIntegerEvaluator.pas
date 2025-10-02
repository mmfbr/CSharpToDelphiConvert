unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldIntegerEvaluator = class(TGoldValueEvaluator<TGoldInteger>)
  private
    m_instance: TGoldIntegerEvaluator;
  public
    constructor Create();
    function InternalEvaluate(ADataError: TDataError; AValue: TGoldInteger; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function Evaluate(ADataError: TDataError; AValue: Integer; ASource: String; ANumber: Integer): Boolean;
    function GetDefaultValue(AMetadata: INavValueMetadata): TGoldInteger;
    property Instance: TGoldIntegerEvaluator read GetInstance write SetInstance;
  end;


implementation

constructor TGoldIntegerEvaluator.Create();
begin
  inherited Create;
end;

function TGoldIntegerEvaluator.InternalEvaluate(ADataError: TDataError; AValue: TGoldInteger; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  value2: Integer;
  _result: Boolean := Evaluate(dataError, out value2, source, number);
  value := TGoldInteger.Create(value2);
  Result := _result;
end;

function TGoldIntegerEvaluator.Evaluate(ADataError: TDataError; AValue: Integer; ASource: String; ANumber: Integer): Boolean;
begin
  if int.TryParse(source, GetNumberStyles(number), GetFormatProvider(number), out value) then
  begin
    if value = int.MinValue then
    begin
      if dataError = TDataError.TrapError then
      begin
        value := 0;
        Result := false;
      end
      ;
      raise TGoldNCLEvaluateException.CreateIntegerValueOutOfRange(CultureInfo.CurrentCulture, source, -2147483647, int.MaxValue);
    end
    ;
    Result := true;
  end
  ;
  if dataError = TDataError.TrapError then
  begin
    value := 0;
    Result := false;
  end
  ;
  raise TGoldNCLEvaluateException.Create(CultureInfo.CurrentCulture, TGoldType.Integer, source);
end;

function TGoldIntegerEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): TGoldInteger;
begin
  Result := TGoldInteger.Default;
end;


end.
