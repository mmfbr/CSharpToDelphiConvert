unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TTreeObject = class(ITreeObject)
  private
    m_tree: TTreeHandler;
  public
    constructor Create(AParent: ITreeObject);
    procedure Dispose(ADisposing: Boolean);
    procedure Dispose();
    property Tree: TTreeHandler read GetTree write SetTree;
    property IsDisposed: Boolean read GetIsDisposed write SetIsDisposed;
  end;


implementation

constructor TTreeObject.Create(AParent: ITreeObject);
begin
  inherited Create;
  m_tree := TTreeHandler.CreateTreeHandler(parent, this);
end;

procedure TTreeObject.Dispose(ADisposing: Boolean);
begin
  if disposing and not IsDisposed then
  begin
    Tree.Dispose();
  end
  ;
end;

procedure TTreeObject.Dispose();
begin
  Dispose(disposing: true);
end;


end.
