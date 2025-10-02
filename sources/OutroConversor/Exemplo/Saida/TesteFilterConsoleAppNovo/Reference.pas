unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TReference = class(IReference<T>)
  private
    m_target: T;
  public
    constructor Create();
    constructor Create(ATarget: T);
    procedure ClearTarget();
    property Target: T read GetTarget write SetTarget;
    property TargetSafe: T read GetTargetSafe write SetTargetSafe;
  end;


implementation

constructor TReference.Create();
begin
  inherited Create;
end;

constructor TReference.Create(ATarget: T);
begin
  inherited Create;
  if target = null then
  begin
    raise TArgumentNullException.Create("m_target");
  end
  ;
  Self.m_target := target;
end;

procedure TReference.ClearTarget();
begin
  m_target := null;
end;


end.
