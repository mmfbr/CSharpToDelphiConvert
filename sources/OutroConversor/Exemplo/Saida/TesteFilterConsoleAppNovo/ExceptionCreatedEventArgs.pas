unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TExceptionCreatedEventArgs = class(TEventArgs)
  private
    m_createdException: TException;
  public
    constructor Create(ACreatedException: TException);
    property CreatedException: TException read GetCreatedException write SetCreatedException;
  end;


implementation

constructor TExceptionCreatedEventArgs.Create(ACreatedException: TException);
begin
  inherited Create;
  Self.m_createdException := ACreatedException;
end;


end.
