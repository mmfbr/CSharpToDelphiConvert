unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TTypesThreadLocalStorage = class(TObject)
  private
    m_operationContext: TOperationContext;
  public
    property OperationContext: TOperationContext read GetOperationContext write SetOperationContext;
    property ClientSessionId: TGuid read GetClientSessionId write SetClientSessionId;
    property ClientActivityId: TGuid read GetClientActivityId write SetClientActivityId;
    property ClientTimeZone: TimeZoneInfo read GetClientTimeZone write SetClientTimeZone;
    property Current: TTypesThreadLocalStorage read GetCurrent write SetCurrent;
  end;


implementation


end.
