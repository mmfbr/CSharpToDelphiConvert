unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldGlobal = class(TObject)
  private
    m_sqlSortingProperties: TSqlSortingProperties;
  public
    property SqlSortingProperties: TSqlSortingProperties read GetSqlSortingProperties write SetSqlSortingProperties;
  end;


implementation


end.
