unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TTreeHandler = class(TObject)
  private
    m_defaultHandler: TTreeHandler;
    m_hostObject: ITreeObject;
    m_parentHandler: TTreeHandler;
    m_fistChildHandler: TTreeHandler;
    m_previousSiblingHandler: TTreeHandler;
    m_nextSiblingHandler: TTreeHandler;
  public
    constructor Create();
    constructor Create(AParent: ITreeObject; AHostObject: ITreeObject);
    function CreateTreeHandler(AParent: ITreeObject; AHostObject: ITreeObject): TTreeHandler;
    procedure Dispose();
    procedure DisposeAllChildren();
    procedure DisposeAllChildrenExcept(AObjectNotToDispose: ITreeObject);
    function GetReferenceTarget(): ITreeObject;
    procedure SetReferenceTarget(ANewTarget: ITreeObject);
    procedure Dispose(ADisposing: Boolean);
    procedure InternalClearAll();
    procedure InternalAddReference(AReference: ITreeObjectReference);
    procedure InternalRemoveReferenceDisposeIfLast(AReference: ITreeObjectReference);
    procedure InternalAddChild(AChildToAdd: TTreeHandler);
    procedure InternalRemoveChild(AChildToRemove: TTreeHandler);
    procedure InternalHostDispose();
    property DefaultHandler: TTreeHandler read GetDefaultHandler write SetDefaultHandler;
    property IsDisposed: Boolean read GetIsDisposed write SetIsDisposed;
    property Parent: ITreeObject read GetParent write SetParent;
    property ReferenceCount: Integer read GetReferenceCount write SetReferenceCount;
  end;


implementation

constructor TTreeHandler.Create();
begin
end;

constructor TTreeHandler.Create(AParent: ITreeObject; AHostObject: ITreeObject);
begin
  if hostObject = null then
  begin
    raise TArgumentNullException.Create("m_hostObject");
  end
  ;
  Self.m_hostObject := hostObject;
  if Self.m_hostObject.Tree <> null then
  begin
    raise InvalidOperationException.Create();
  end
  ;
  if parent <> null then
  begin
    if parent.Tree = null then
    begin
      raise TArgumentException.Create("m_parent.Tree");
    end
    ;
    m_parentHandler := parent.Tree;
    m_parentHandler.InternalAddChild(this);
  end
  ;
end;

function TTreeHandler.CreateTreeHandler(AParent: ITreeObject; AHostObject: ITreeObject): TTreeHandler;
begin
  if parent = null then
  begin
    parent := hostObject;
  end
  ;
  if hostObject = null then
  begin
    raise TArgumentNullException.Create("m_hostObject");
  end
  ;
  if hostObject is ITreeSharedObject then
  begin
    Result := TTreeSharedObjectHandler.Create(parent, hostObject);
  end
  ;
  if hostObject is ITreeObjectReference then
  begin
    Result := TTreeObjectReferenceHandler.Create(parent, hostObject);
  end
  ;
  Result := TTreeHandler.Create(parent, hostObject);
end;

procedure TTreeHandler.Dispose();
begin
  Dispose(disposing: true);
end;

procedure TTreeHandler.DisposeAllChildren();
begin
  treeHandler: TTreeHandler := Interlocked.Exchange(ref m_fistChildHandler, null);
  // TODO: Converter WhileStatementSyntax
end;

procedure TTreeHandler.DisposeAllChildrenExcept(AObjectNotToDispose: ITreeObject);
begin
  // TODO: Converter LockStatementSyntax
end;

function TTreeHandler.GetReferenceTarget(): ITreeObject;
begin
  raise InvalidOperationException.Create();
end;

procedure TTreeHandler.SetReferenceTarget(ANewTarget: ITreeObject);
begin
  raise InvalidOperationException.Create();
end;

procedure TTreeHandler.Dispose(ADisposing: Boolean);
begin
  if not disposing or IsDisposed then
  begin
    Exit;
  end
  ;
  // TODO: Converter TryStatementSyntax
end;

procedure TTreeHandler.InternalClearAll();
begin
  m_parentHandler := null;
  m_fistChildHandler := null;
  m_nextSiblingHandler := null;
  m_previousSiblingHandler := null;
  m_hostObject := null;
end;

procedure TTreeHandler.InternalAddReference(AReference: ITreeObjectReference);
begin
end;

procedure TTreeHandler.InternalRemoveReferenceDisposeIfLast(AReference: ITreeObjectReference);
begin
  if not IsDisposed then
  begin
    parent: ITreeObject := Parent;
    if parent <> null and parent = reference then
    begin
      InternalHostDispose();
    end
    ;
  end
  ;
end;

procedure TTreeHandler.InternalAddChild(AChildToAdd: TTreeHandler);
begin
  // TODO: Converter LockStatementSyntax
end;

procedure TTreeHandler.InternalRemoveChild(AChildToRemove: TTreeHandler);
begin
  // TODO: Converter LockStatementSyntax
end;

procedure TTreeHandler.InternalHostDispose();
begin
  if not IsDisposed then
  begin
    if m_hostObject is IDisposable disposable then
    begin
      disposable.Dispose();
    end
    else
    begin
      Dispose();
    end;
  end
  ;
end;


end.
