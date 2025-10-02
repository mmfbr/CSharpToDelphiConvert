unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TTreeSharedObjectContainer = class(TTreeObject)
  public
    constructor Create(AParent: ITreeObject);
  end;


implementation

constructor TTreeSharedObjectContainer.Create(AParent: ITreeObject);
begin
  inherited Create;
end;


end.
