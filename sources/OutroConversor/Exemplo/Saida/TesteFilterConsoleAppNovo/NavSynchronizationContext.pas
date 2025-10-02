unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldSynchronizationContext = class(TSynchronizationContext)
  private
    m_instance: TGoldSynchronizationContext;
  public
    function ClearThreadLocalStorageDelegate(AOriginalDelegate: TSendOrPostCallback): TSendOrPostCallback;
    procedure Send(AD: TSendOrPostCallback; AState: TObject);
    procedure Post(AD: TSendOrPostCallback; AState: TObject);
    property Instance: TGoldSynchronizationContext read GetInstance write SetInstance;
  end;


implementation

function TGoldSynchronizationContext.ClearThreadLocalStorageDelegate(AOriginalDelegate: TSendOrPostCallback): TSendOrPostCallback;
begin
  Result := delegate (object state)
            {
                TGoldThreadLocalStorage current = TGoldThreadLocalStorage.Current;
                try
                {
                    TGoldThreadLocalStorage.Clear();
                    originalDelegate(state);
                }
                finally
                {
                    TGoldThreadLocalStorage.Restore(current);
                }
            };
end;

procedure TGoldSynchronizationContext.Send(AD: TSendOrPostCallback; AState: TObject);
begin
  base.Send(ClearThreadLocalStorageDelegate(d), state);
end;

procedure TGoldSynchronizationContext.Post(AD: TSendOrPostCallback; AState: TObject);
begin
  base.Post(ClearThreadLocalStorageDelegate(d), state);
end;


end.
