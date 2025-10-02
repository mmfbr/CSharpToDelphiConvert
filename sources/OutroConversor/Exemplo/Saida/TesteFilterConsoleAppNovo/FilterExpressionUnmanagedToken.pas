unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterExpressionUnmanagedTokenHelper = class(TObject)
  public
    const m_SpecialFlag: Byte = 128;
    function MakeNormal(AToken: TFilterExpressionUnmanagedToken): TFilterExpressionUnmanagedToken;
    function MakeSpecial(AToken: TFilterExpressionUnmanagedToken): TFilterExpressionUnmanagedToken;
    function IsSpecial(AToken: TFilterExpressionUnmanagedToken): Boolean;
  end;


implementation

function TFilterExpressionUnmanagedTokenHelper.MakeNormal(AToken: TFilterExpressionUnmanagedToken): TFilterExpressionUnmanagedToken;
begin
  Result := (TFilterExpressionUnmanagedToken)((uint)AToken & 0xFFFFFF7Fu);
end;

function TFilterExpressionUnmanagedTokenHelper.MakeSpecial(AToken: TFilterExpressionUnmanagedToken): TFilterExpressionUnmanagedToken;
begin
  Result := AToken | (TFilterExpressionUnmanagedToken)128;
end;

function TFilterExpressionUnmanagedTokenHelper.IsSpecial(AToken: TFilterExpressionUnmanagedToken): Boolean;
begin
  Result := (AToken & (TFilterExpressionUnmanagedToken)128) = (TFilterExpressionUnmanagedToken)128;
end;


end.
