unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TNCLManagedAdapter = class(TObject)
  private
    m_oem2AnsiTable: byte[];
    m_ansi2OemTable: byte[];
    m_maxBytesPerChar: Integer;
    m_defaultEncoding: TEncoding;
  public
    constructor Create();
    procedure Initialize();
    procedure ChangeDefaultEncoding(ANewEncoding: TEncoding);
    procedure RestoreDefaultEncoding();
    function ByteToText(AOemBytes: byte[]): String;
    function ByteToText(AOemBytes: byte[]; AEncoding: TTextEncoding): String;
    function ByteToTextChar(AOemByte: Byte): Char;
    function ByteToTextChar(AOemByte: Byte; AEncoding: TTextEncoding): Char;
    function ByteToText(AOemBytes: byte[]; AStartIndex: Integer; ALength: Integer): String;
    function ByteToText(AOemBytes: byte[]; AStartIndex: Integer; ALength: Integer; AEncoding: TTextEncoding): String;
    function ByteToText(ALpzOemStr: TIntPtr): String;
    function TextToByte(ansiString: String): byte[];
    function TextToByte(ansiString: String; AEncoding: TTextEncoding): byte[];
    function TextCharToByte(ansiChar: Char): Byte;
    function TextCharToByte(ansiChar: Char; AEncoding: TTextEncoding): Byte;
    procedure TextToByte(ansiString: String; ADest: TIntPtr; ADestMaxSize: Integer);
    procedure CopyFromBytesToIntPtr(ASource: byte[]; ADestination: TIntPtr);
  end;


implementation

constructor TNCLManagedAdapter.Create();
begin
  m_defaultEncoding := Encoding.Default;
  Initialize();
end;

procedure TNCLManagedAdapter.Initialize();
begin
  m_oem2AnsiTable := new byte[256];
  m_ansi2OemTable := new byte[256];
  // TODO: Converter ForStatementSyntax
  TNativeMethods.OemToCharBuff(m_oem2AnsiTable, m_oem2AnsiTable, m_oem2AnsiTable.Length);
  TNativeMethods.CharToOemBuff(m_ansi2OemTable, m_ansi2OemTable, m_ansi2OemTable.Length);
  num: Integer := 255;
  num2: Integer := 255;
  // TODO: Converter WhileStatementSyntax
  if m_defaultEncoding.IsSingleByte then
  begin
    m_maxBytesPerChar := 1;
  end
  else
  begin
    m_maxBytesPerChar := 2;
  end;
end;

procedure TNCLManagedAdapter.ChangeDefaultEncoding(ANewEncoding: TEncoding);
begin
  m_defaultEncoding := newEncoding;
  Initialize();
end;

procedure TNCLManagedAdapter.RestoreDefaultEncoding();
begin
  m_defaultEncoding := Encoding.Default;
  Initialize();
end;

function TNCLManagedAdapter.ByteToText(AOemBytes: byte[]): String;
begin
  Result := ByteToText(oemBytes, TTextEncoding.MSDos);
end;

function TNCLManagedAdapter.ByteToText(AOemBytes: byte[]; AEncoding: TTextEncoding): String;
begin
  Result := ByteToText(oemBytes, 0, oemBytes.Length, encoding);
end;

function TNCLManagedAdapter.ByteToTextChar(AOemByte: Byte): Char;
begin
  Result := ByteToTextChar(oemByte, TTextEncoding.MSDos);
end;

function TNCLManagedAdapter.ByteToTextChar(AOemByte: Byte; AEncoding: TTextEncoding): Char;
begin
  if Encoding.Default.IsSingleByte and encoding = TTextEncoding.MSDos then
  begin
    Result := m_defaultEncoding.GetChars(new byte[1] { m_oem2AnsiTable[oemByte] })[0];
  end
  ;
  Result := m_defaultEncoding.GetChars(new byte[1] { oemByte })[0];
end;

function TNCLManagedAdapter.ByteToText(AOemBytes: byte[]; AStartIndex: Integer; ALength: Integer): String;
begin
  Result := ByteToText(oemBytes, startIndex, length, TTextEncoding.MSDos);
end;

function TNCLManagedAdapter.ByteToText(AOemBytes: byte[]; AStartIndex: Integer; ALength: Integer; AEncoding: TTextEncoding): String;
begin
  if oemBytes = null then
  begin
    raise TGoldNCLArgumentException.Create(TLang._00095_50082);
  end
  ;
  if startIndex < 0 or startIndex > oemBytes.Length then
  begin
    raise TGoldNCLIndexOutOfBoundsException.Create();
  end
  ;
  if length < 0 or startIndex + length > oemBytes.Length then
  begin
    raise TGoldNCLIndexOutOfBoundsException.Create();
  end
  ;
  // TODO: Converter ForStatementSyntax
  if length = 0 then
  begin
    Result := string.Empty;
  end
  ;
  if m_defaultEncoding.IsSingleByte and encoding = TTextEncoding.MSDos then
  begin
    array_: byte[] := new byte[length];
    // TODO: Converter ForStatementSyntax
    Result := m_defaultEncoding.GetString(array_);
  end
  ;
  Result := m_defaultEncoding.GetString(oemBytes, startIndex, length);
end;

function TNCLManagedAdapter.ByteToText(ALpzOemStr: TIntPtr): String;
begin
  ptr: byte* := (byte*)lpzOemStr.ToPointer();
  if *ptr = 0 then
  begin
    Result := string.Empty;
  end
  ;
  array_: byte[] := new byte[1050];
  num: Integer := 0;
  // TODO: Converter ForStatementSyntax
  Result := m_defaultEncoding.GetString(array_, 0, num);
end;

function TNCLManagedAdapter.TextToByte(ansiString: String): byte[];
begin
  Result := TextToByte(ansiString, TTextEncoding.MSDos);
end;

function TNCLManagedAdapter.TextToByte(ansiString: String; AEncoding: TTextEncoding): byte[];
begin
  array_: byte[] := new byte[(ansiString.Length + 1) * m_maxBytesPerChar];
  bytes: Integer := m_defaultEncoding.GetBytes(ansiString, 0, ansiString.Length, array_, 0);
  if not m_defaultEncoding.IsSingleByte then
  begin
    Array.Resize(ref array_, bytes + 1);
  end
  else
  begin
    if encoding <> TTextEncoding.Windows then
    begin
      // TODO: Converter ForStatementSyntax
    end
    ;
  end;
  Result := array_;
end;

function TNCLManagedAdapter.TextCharToByte(ansiChar: Char): Byte;
begin
  Result := TextCharToByte(ansiChar, TTextEncoding.MSDos);
end;

function TNCLManagedAdapter.TextCharToByte(ansiChar: Char; AEncoding: TTextEncoding): Byte;
begin
  b: Byte := m_defaultEncoding.GetBytes(new char[1] { ansiChar })[0];
  if m_defaultEncoding.IsSingleByte and encoding = TTextEncoding.MSDos then
  begin
    Result := m_ansi2OemTable[b];
  end
  ;
  Result := b;
end;

procedure TNCLManagedAdapter.TextToByte(ansiString: String; ADest: TIntPtr; ADestMaxSize: Integer);
begin
  array_: byte[] := new byte[ansiString.Length * m_maxBytesPerChar];
  bytes: Integer := m_defaultEncoding.GetBytes(ansiString, 0, ansiString.Length, array_, 0);
  if bytes > destMaxSize then
  begin
    raise TGoldNCLStringLengthExceededException.Create(destMaxSize - 1, bytes, ansiString);
  end
  ;
  ptr: byte* := (byte*)dest.ToPointer();
  if m_defaultEncoding.IsSingleByte then
  begin
    // TODO: Converter ForStatementSyntax
  end
  else
  begin
    // TODO: Converter ForStatementSyntax
  end;
  *ptr := 0;
end;

procedure TNCLManagedAdapter.CopyFromBytesToIntPtr(ASource: byte[]; ADestination: TIntPtr);
begin
  if source = null then
  begin
    raise TArgumentNullException.Create("m_source");
  end
  ;
  if destination = IntPtr.Zero then
  begin
    raise TArgumentNullException.Create("destination");
  end
  ;
  if source.Length < 3400 then
  begin
    ptr: byte* := (byte*)destination.ToPointer();
    // TODO: Converter ForStatementSyntax
  end
  else
  begin
    Marshal.Copy(source, 0, destination, source.Length);
  end;
end;


end.
