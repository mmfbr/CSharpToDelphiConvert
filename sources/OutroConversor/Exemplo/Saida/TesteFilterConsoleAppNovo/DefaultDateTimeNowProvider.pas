unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TDefaultDateTimeNowProvider = class(TDateTimeNowProvider)
  private
    m_instance: TLazy<TDateTimeNowProvider>;
  public
    property Instance: TDateTimeNowProvider read GetInstance write SetInstance;
    property UtcNow: TDateTime read GetUtcNow write SetUtcNow;
    property Now: TDateTime read GetNow write SetNow;
  end;


implementation


end.
