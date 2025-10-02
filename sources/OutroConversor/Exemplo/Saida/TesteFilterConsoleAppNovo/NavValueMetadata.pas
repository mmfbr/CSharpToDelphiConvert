unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldValueMetadata = class(INavValueMetadata)
  private
    m_nclType: TGoldNclType;
  public
    constructor Create(ANclType: TGoldNclType);
    function DefaultMetadata(ANclType: TGoldNclType): TGoldValueMetadata;
    function DefaultMetadata(ANavType: TGoldType): TGoldValueMetadata;
    function CalcMetadataFromObject(AValue: TObject): INavValueMetadata;
    function CalcMetadataFromDotNetObject(AValue: TObject): INavValueMetadata;
    function CompareTypeAndMetadata(ALeft: INavValueMetadata; ARight: INavValueMetadata): Boolean;
    function GetHashCode(): Integer;
    property GoldType: TGoldType read GetGoldType write SetGoldType;
    property NclType: TGoldNclType read GetNclType write SetNclType;
    property HasMetadata: Boolean read GetHasMetadata write SetHasMetadata;
    property GoldDefinedLengthMetadata: Integer read GetGoldDefinedLengthMetadata write SetGoldDefinedLengthMetadata;
  end;


implementation

constructor TGoldValueMetadata.Create(ANclType: TGoldNclType);
begin
  inherited Create;
  Self.m_nclType := nclType;
end;

function TGoldValueMetadata.DefaultMetadata(ANclType: TGoldNclType): TGoldValueMetadata;
begin
  Result := nclType switch
            {
                TGoldNclType.GoldOemCode => TGoldValueDefinedLengthMetadata.Create(TGoldNclType.GoldOemCode, 2048),
                TGoldNclType.GoldOemText => TGoldValueDefinedLengthMetadata.Create(TGoldNclType.GoldOemText, 2048),
                TGoldNclType.GoldText => TGoldValueDefinedLengthMetadata.Create(TGoldNclType.GoldText, int.MaxValue),
                TGoldNclType.GoldCode => TGoldValueDefinedLengthMetadata.Create(TGoldNclType.GoldCode, 2048),
                _ => TGoldValueMetadata.Create(nclType),
            };
end;

function TGoldValueMetadata.DefaultMetadata(ANavType: TGoldType): TGoldValueMetadata;
begin
  Result := DefaultMetadata(TGoldNclTypeHelper.GetNclTypeFromNavType(navType));
end;

function TGoldValueMetadata.CalcMetadataFromObject(AValue: TObject): INavValueMetadata;
begin
  if value = null then
  begin
    Result := DefaultMetadata(TGoldNclType.None);
  end
  ;
  navValue: TGoldValue := value as TGoldValue;
  // TODO: Converter WhileStatementSyntax
  nclTypeFromObject: TGoldNclType := TGoldNclTypeHelper.GetNclTypeFromObject(value);
  Result := DefaultMetadata(nclTypeFromObject);
end;

function TGoldValueMetadata.CalcMetadataFromDotNetObject(AValue: TObject): INavValueMetadata;
begin
  if value = null then
  begin
    Result := DefaultMetadata(TGoldNclType.None);
  end
  ;
  navValue: TGoldValue := value as TGoldValue;
  // TODO: Converter WhileStatementSyntax
  nclTypeFromObject: TGoldNclType := TGoldNclTypeHelper.GetNclTypeFromObject(value, AForDotNet: true);
  Result := DefaultMetadata(nclTypeFromObject);
end;

function TGoldValueMetadata.CompareTypeAndMetadata(ALeft: INavValueMetadata; ARight: INavValueMetadata): Boolean;
begin
  if left = null then
  begin
    raise TArgumentNullException.Create("m_left");
  end
  ;
  if right = null then
  begin
    raise TArgumentNullException.Create("m_right");
  end
  ;
  if left.NclType <> right.NclType then
  begin
    Result := false;
  end
  ;
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldValueMetadata.GetHashCode(): Integer;
begin
  Result := (int)NclType;
end;


end.
