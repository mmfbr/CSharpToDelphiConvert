unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldValueDefinedLengthMetadata = class(TGoldValueMetadata)
  private
    m_definedLength: Integer;
  public
    constructor Create(ANclType: TGoldNclType; ADefinedLength: Integer);
    constructor Create(ANavType: TGoldType; ADefinedLength: Integer);
    property GoldDefinedLengthMetadata: Integer read GetGoldDefinedLengthMetadata write SetGoldDefinedLengthMetadata;
  end;


implementation

constructor TGoldValueDefinedLengthMetadata.Create(ANclType: TGoldNclType; ADefinedLength: Integer);
begin
  inherited Create;
  Self.m_definedLength := definedLength;
end;

constructor TGoldValueDefinedLengthMetadata.Create(ANavType: TGoldType; ADefinedLength: Integer);
begin
  inherited Create;
  Self.m_definedLength := definedLength;
end;


end.
