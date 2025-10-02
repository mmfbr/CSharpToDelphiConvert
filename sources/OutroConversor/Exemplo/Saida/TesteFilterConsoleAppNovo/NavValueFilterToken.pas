unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldValueFilterToken = class(TFilterToken)
  private
    m_navValue: TGoldValue;
  public
    constructor Create(ANavValue: TGoldValue);
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property GoldValue: TGoldValue read GetGoldValue write SetGoldValue;
    property Value: String read GetValue write SetValue;
  end;


implementation

constructor TGoldValueFilterToken.Create(ANavValue: TGoldValue);
begin
  inherited Create;
  if navValue = null then
  begin
    raise TArgumentNullException.Create("m_navValue");
  end
  ;
  Self.m_navValue := navValue;
end;


end.
