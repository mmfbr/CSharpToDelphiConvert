unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TNativeMethods = class(TObject)
  public
    const m_NO_ERROR: uint = 0u;
    const m_ERROR_INVALID_DOMAINNAME: uint = 1212u;
    const m_ERROR_NO_SUCH_DOMAIN: uint = 1355u;
    const m_ERROR_INVALID_PARAMETER: uint = 87u;
    const m_ERROR_DS_NAME_ERROR_NO_SYNTACTICAL_MAPPING: uint = 8474u;
    const m_ERROR_DS_INSUFF_ACCESS_RIGHTS: uint = 8344u;
    const m_ERROR_MORE_DATA: uint = 234u;
    function FreeLibrary(ALib: TIntPtr): Boolean;
    function GetModuleHandle(AModuleName: String): TIntPtr;
    function GetTickCount64(): ulong;
    function OemToCharBuff(ASource: byte[]; ADest: byte[]; ABytesize: Integer): Integer;
    function CharToOemBuff(ASource: byte[]; ADest: byte[]; ABytesize: Integer): Integer;
    function WinVerifyTrust(AHWnd: TIntPtr; APgActionID: TIntPtr; APWinTrustData: TIntPtr): uint;
    function SpnRegister(APzServiceAccount: String; APzFqcnSpn: String; APzNetbSpn: String; ANregister: Boolean): uint;
    function DhcpCApiInitialize(AVersion: uint): uint;
    procedure DhcpCApiCleanup();
    function DhcpRequestParams(AFlags: TDHCPCAPI_REQUEST; AReserved: TIntPtr; AdapterName: String; AClassId: TIntPtr; ASendParams: TDHCPCAPI_PARAMS_ARRAY; ARecdParams: TDHCPCAPI_PARAMS_ARRAY; ABuffer: TIntPtr; APSize: uint; ARequestIdStr: String): uint;
  end;


implementation

function TNativeMethods.FreeLibrary(ALib: TIntPtr): Boolean;
begin
end;

function TNativeMethods.GetModuleHandle(AModuleName: String): TIntPtr;
begin
end;

function TNativeMethods.GetTickCount64(): ulong;
begin
end;

function TNativeMethods.OemToCharBuff(ASource: byte[]; ADest: byte[]; ABytesize: Integer): Integer;
begin
end;

function TNativeMethods.CharToOemBuff(ASource: byte[]; ADest: byte[]; ABytesize: Integer): Integer;
begin
end;

function TNativeMethods.WinVerifyTrust(AHWnd: TIntPtr; APgActionID: TIntPtr; APWinTrustData: TIntPtr): uint;
begin
end;

function TNativeMethods.SpnRegister(APzServiceAccount: String; APzFqcnSpn: String; APzNetbSpn: String; ANregister: Boolean): uint;
begin
end;

function TNativeMethods.DhcpCApiInitialize(AVersion: uint): uint;
begin
end;

procedure TNativeMethods.DhcpCApiCleanup();
begin
end;

function TNativeMethods.DhcpRequestParams(AFlags: TDHCPCAPI_REQUEST; AReserved: TIntPtr; AdapterName: String; AClassId: TIntPtr; ASendParams: TDHCPCAPI_PARAMS_ARRAY; ARecdParams: TDHCPCAPI_PARAMS_ARRAY; ABuffer: TIntPtr; APSize: uint; ARequestIdStr: String): uint;
begin
end;


end.
