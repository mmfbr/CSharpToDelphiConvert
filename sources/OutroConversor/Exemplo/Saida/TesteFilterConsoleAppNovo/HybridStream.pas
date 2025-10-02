unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  THybridStream = class(TStream)
  private
    m_compressionMode: TCompressionMode;
    m_operationStream: TStream;
    m_underlyingMemoryStream: TMemoryStream;
  public
    constructor Create(ACompressionMode: TCompressionMode);
    procedure Flush();
    function Seek(AOffset: Int64; AOrigin: TSeekOrigin): Int64;
    procedure SetLength(AValue: Int64);
    procedure Dispose(ADisposing: Boolean);
    property CanRead: Boolean read GetCanRead write SetCanRead;
    property CanSeek: Boolean read GetCanSeek write SetCanSeek;
    property CanWrite: Boolean read GetCanWrite write SetCanWrite;
    property Length: Int64 read GetLength write SetLength;
    property Position: Int64 read GetPosition write SetPosition;
    property OperationStream: TStream read GetOperationStream write SetOperationStream;
    property UnderlyingMemoryStream: TMemoryStream read GetUnderlyingMemoryStream write SetUnderlyingMemoryStream;
  end;


implementation

constructor THybridStream.Create(ACompressionMode: TCompressionMode);
begin
  inherited Create;
  Self.m_compressionMode := ACompressionMode;
end;

procedure THybridStream.Flush();
begin
  OperationStream.Flush();
end;

function THybridStream.Seek(AOffset: Int64; AOrigin: TSeekOrigin): Int64;
begin
  raise TNotSupportedException.Create();
end;

procedure THybridStream.SetLength(AValue: Int64);
begin
  raise TNotSupportedException.Create();
end;

procedure THybridStream.Dispose(ADisposing: Boolean);
begin
  // TODO: Converter TryStatementSyntax
end;


end.
