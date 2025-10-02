unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  THybridMemoryCompressStream = class(THybridStream)
  private
    m_isCompressed: Boolean;
    m_configCompressionThreshold: Integer;
  public
    const m_DefaultStreamCapacity: Integer = 4096;
    constructor Create();
    constructor Create(AConfigCompressionThreshold: Integer);
    constructor Create(AData: byte[]; AConfigCompressionThreshold: Integer);
    constructor Create(AStream: TStream; AConfigCompressionThreshold: Integer);
    function Read(ABuffer: byte[]; AOffset: Integer; ACount: Integer): Integer;
    procedure Write(ABuffer: byte[]; AOffset: Integer; ACount: Integer);
    function GetDataStore(): THybridDataStore;
    procedure WriteInternal(ABuffer: byte[]; AOffset: Integer; ACount: Integer);
    procedure UseCompressionStream();
    property IsCompressed: Boolean read GetIsCompressed write SetIsCompressed;
  end;


implementation

constructor THybridMemoryCompressStream.Create();
begin
  inherited Create;
  OperationStream := UnderlyingMemoryStream = TMemoryStream.Create(4096);
end;

constructor THybridMemoryCompressStream.Create(AConfigCompressionThreshold: Integer);
begin
  inherited Create;
  OperationStream := UnderlyingMemoryStream = TMemoryStream.Create(4096);
  Self.m_configCompressionThreshold := AConfigCompressionThreshold;
end;

constructor THybridMemoryCompressStream.Create(AData: byte[]; AConfigCompressionThreshold: Integer);
begin
  inherited Create;
  if AData = null then
  begin
    raise TArgumentNullException.Create("m_data");
  end
  ;
  capacity: Integer := (if AData.Length > AConfigCompressionThreshold then AConfigCompressionThreshold else AData.Length);
  Self.m_configCompressionThreshold := AConfigCompressionThreshold;
  OperationStream := UnderlyingMemoryStream = TMemoryStream.Create(capacity);
  Write(AData, 0, AData.Length);
end;

constructor THybridMemoryCompressStream.Create(AStream: TStream; AConfigCompressionThreshold: Integer);
begin
  inherited Create;
  if AStream = null then
  begin
    raise TArgumentNullException.Create("AStream");
  end
  ;
  capacity: Int64 := (if AStream.Length > AConfigCompressionThreshold then AConfigCompressionThreshold else AStream.Length);
  Self.m_configCompressionThreshold := AConfigCompressionThreshold;
  OperationStream := UnderlyingMemoryStream = TMemoryStream.Create((int)capacity);
  buffer: byte[] := new byte[4096];
  readBytes: Integer;
  // TODO: Converter DoStatementSyntax
end;

function THybridMemoryCompressStream.Read(ABuffer: byte[]; AOffset: Integer; ACount: Integer): Integer;
begin
  raise TNotSupportedException.Create();
end;

procedure THybridMemoryCompressStream.Write(ABuffer: byte[]; AOffset: Integer; ACount: Integer);
begin
  WriteInternal(ABuffer, AOffset, ACount);
end;

function THybridMemoryCompressStream.GetDataStore(): THybridDataStore;
begin
  // TODO: Converter TryStatementSyntax
end;

procedure THybridMemoryCompressStream.WriteInternal(ABuffer: byte[]; AOffset: Integer; ACount: Integer);
begin
  if not IsCompressed and Length + ACount > m_configCompressionThreshold then
  begin
    UseCompressionStream();
  end
  ;
  OperationStream.Write(ABuffer, AOffset, ACount);
end;

procedure THybridMemoryCompressStream.UseCompressionStream();
begin
  IsCompressed := true;
  newStream: TMemoryStream := TMemoryStream.Create((int)UnderlyingMemoryStream.Length / 8);
  deflateStream: TDeflateStream := TDeflateStream.Create(newStream, CompressionMode.Compress, leaveOpen: true);
  buffer: byte[] := UnderlyingMemoryStream.ToArray();
  deflateStream.Write(buffer, 0, buffer.Length);
  OperationStream := deflateStream;
  UnderlyingMemoryStream.Dispose();
  UnderlyingMemoryStream := newStream;
end;


end.
