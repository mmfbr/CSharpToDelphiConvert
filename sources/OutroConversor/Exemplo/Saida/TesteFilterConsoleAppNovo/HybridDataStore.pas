unit GoldERP.Types;

interface

uses
  System.Classes, System.SysUtils;

type
  THybridDataStore = class(TObject)
  private
    m_data: byte[];
    m_isCompressed: Boolean;
  public
    constructor Create(AData: byte[]; AIsCompressed: Boolean);
    function DecompressStream(): THybridMemoryDecompressStream;
    property Data: byte[] read GetData write SetData;
    property IsCompressed: Boolean read GetIsCompressed write SetIsCompressed;
  end;


implementation

constructor THybridDataStore.Create(AData: byte[]; AIsCompressed: Boolean);
begin
  Data := AData;
  IsCompressed := AIsCompressed;
end;

function THybridDataStore.DecompressStream(): THybridMemoryDecompressStream;
begin
  Result := THybridMemoryDecompressStream.Create(this);
end;


end.
