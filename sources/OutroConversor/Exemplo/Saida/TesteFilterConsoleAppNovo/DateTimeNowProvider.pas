unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TDateTimeNowProvider = class(TObject)
  private
    m_current: TDateTimeNowProvider;
  public
    property Current: TDateTimeNowProvider read GetCurrent write SetCurrent;
    property UtcNow: TDateTime read GetUtcNow write SetUtcNow;
    property Now: TDateTime read GetNow write SetNow;
  end;


implementation


end.
