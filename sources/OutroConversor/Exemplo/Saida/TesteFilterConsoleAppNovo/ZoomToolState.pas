unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  TZoomToolState = class(TObject)
  private
    m_useZoomToolForReports: Boolean;
  public
    property UseZoomToolForReports: Boolean read GetUseZoomToolForReports write SetUseZoomToolForReports;
  end;


implementation


end.
