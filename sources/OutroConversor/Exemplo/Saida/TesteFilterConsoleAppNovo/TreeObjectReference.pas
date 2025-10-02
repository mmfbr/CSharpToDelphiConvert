unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TTreeObjectReference = class(TTreeObject)
  public
    constructor Create(AParent: ITreeObject);
    constructor Create(AParent: ITreeObject; AInitialTarget: ITreeObject);
    function CreateTarget(): ITreeSharedObject;
    property Target: ITreeObject read GetTarget write SetTarget;
  end;


implementation

constructor TTreeObjectReference.Create(AParent: ITreeObject);
begin
  inherited Create;
end;

constructor TTreeObjectReference.Create(AParent: ITreeObject; AInitialTarget: ITreeObject);
begin
  inherited Create;
  if initialTarget = null then
  begin
    raise TArgumentNullException.Create("initialTarget");
  end
  ;
  Target := initialTarget;
end;

function TTreeObjectReference.CreateTarget(): ITreeSharedObject;
begin
  Result := null;
end;


end.
