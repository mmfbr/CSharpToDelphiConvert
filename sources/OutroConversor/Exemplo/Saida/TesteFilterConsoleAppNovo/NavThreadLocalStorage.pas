unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldThreadLocalStorage = class(TTypesThreadLocalStorage)
  private
    m_instance: TGoldThreadLocalStorage;
  public
    constructor Create(ATypesTls: TTypesThreadLocalStorage);
    procedure Clear();
    procedure Restore(AOriginalInstance: TGoldThreadLocalStorage);
    property Current: TGoldThreadLocalStorage read GetCurrent write SetCurrent;
    property Session: IReference<TGoldSession> read GetSession write SetSession;
    property FormPersonalizationId: String read GetFormPersonalizationId write SetFormPersonalizationId;
    property DrillDownPersonalizationId: String read GetDrillDownPersonalizationId write SetDrillDownPersonalizationId;
    property InitializingAppGroup: Boolean read GetInitializingAppGroup write SetInitializingAppGroup;
  end;


implementation

constructor TGoldThreadLocalStorage.Create(ATypesTls: TTypesThreadLocalStorage);
begin
  inherited Create;
  if typesTls <> null then
  begin
    OperationContext := typesTls.OperationContext;
    ClientSessionId := typesTls.ClientSessionId;
    ClientActivityId := typesTls.ClientActivityId;
    ClientTimeZone := typesTls.ClientTimeZone;
  end
  ;
end;

procedure TGoldThreadLocalStorage.Clear();
begin
  m_instance := null;
  m_typesInstance := null;
end;

procedure TGoldThreadLocalStorage.Restore(AOriginalInstance: TGoldThreadLocalStorage);
begin
  m_instance := originalInstance;
  m_typesInstance := originalInstance;
  SynchronizationContext.SetSynchronizationContext(TGoldSynchronizationContext.Instance);
end;


end.
