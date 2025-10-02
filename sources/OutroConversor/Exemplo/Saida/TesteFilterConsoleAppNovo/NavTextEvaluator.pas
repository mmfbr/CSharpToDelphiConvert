unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldTextEvaluator = class(TGoldValueEvaluator<TGoldText>)
  private
    m_instance: TGoldTextEvaluator;
  public
    constructor Create();
    function InternalEvaluate(ADataError: TDataError; AValue: TGoldText; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function GetDefaultValue(AMetadata: INavValueMetadata): TGoldText;
    property Instance: TGoldTextEvaluator read GetInstance write SetInstance;
  end;


implementation

constructor TGoldTextEvaluator.Create();
begin
  inherited Create;
end;

function TGoldTextEvaluator.InternalEvaluate(ADataError: TDataError; AValue: TGoldText; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  if metadata = null then
  begin
    raise TArgumentNullException.Create("metadata");
  end
  ;
  value := TGoldText.Create(metadata.GoldDefinedLengthMetadata, source);
  Result := true;
end;

function TGoldTextEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): TGoldText;
begin
  Result := TGoldText.Default(metadata.GoldDefinedLengthMetadata);
end;


end.
