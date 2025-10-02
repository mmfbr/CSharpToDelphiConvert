unit GoldERP.Types;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  THybridMemoryDecompressStream = class(THybridStream)
  public
    constructor Create(AHybridStorage: THybridDataStore);
    function Read(ABuffer: byte[]; AOffset: Integer; ACount: Integer): Integer;
    procedure Write(ABuffer: byte[]; AOffset: Integer; ACount: Integer);
    function ToArray(): byte[];
  end;


implementation

constructor THybridMemoryDecompressStream.Create(AHybridStorage: THybridDataStore);
begin
  inherited Create;
  OperationStream := UnderlyingMemoryStream = TMemoryStream.Create(AHybridStorage.Data, 0, AHybridStorage.Data.Length, writable: false);
  if AHybridStorage.IsCompressed then
  begin
    OperationStream := TDeflateStream.Create(UnderlyingMemoryStream, CompressionMode.Decompress);
  end
  ;
end;

function THybridMemoryDecompressStream.Read(ABuffer: byte[]; AOffset: Integer; ACount: Integer): Integer;
begin
  Result := OperationStream.Read(ABuffer, AOffset, ACount);
end;

procedure THybridMemoryDecompressStream.Write(ABuffer: byte[]; AOffset: Integer; ACount: Integer);
begin
  raise TNotSupportedException.Create();
end;

function THybridMemoryDecompressStream.ToArray(): byte[];
begin
  if OperationStream is MemoryStream then
  begin
    Result := UnderlyingMemoryStream.ToArray();
  end
  ;
  bufferCollection: TList<byte[]> := new List<byte[]>();
  totalCapacity: Integer := 0;
  read: Integer := 0;
  // TODO: Converter WhileStatementSyntax
end;


end.
