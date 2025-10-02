unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFormatOptions = class(TObject)
  public
    constructor Create();
    constructor Create(AOverflow: Char; AFillerCharacter: Char; AComma: Char; ACharacter1000: Char; ALeftJustify: Boolean; APrecisionMin: Byte; APrecisionMax: Byte);
    procedure Initialize(AOther: TFormatOptions);
    procedure Clear();
    property Field: Integer read GetField write SetField;
    property Length: Integer read GetLength write SetLength;
    property Overflow: Char read GetOverflow write SetOverflow;
    property FillerCharacter: Char read GetFillerCharacter write SetFillerCharacter;
    property Comma: Char read GetComma write SetComma;
    property Character1000: Char read GetCharacter1000 write SetCharacter1000;
    property LeftJustify: Boolean read GetLeftJustify write SetLeftJustify;
    property PrecisionMin: Byte read GetPrecisionMin write SetPrecisionMin;
    property PrecisionMax: Byte read GetPrecisionMax write SetPrecisionMax;
  end;


implementation

constructor TFormatOptions.Create();
begin
  PrecisionMax := byte.MaxValue;
end;

constructor TFormatOptions.Create(AOverflow: Char; AFillerCharacter: Char; AComma: Char; ACharacter1000: Char; ALeftJustify: Boolean; APrecisionMin: Byte; APrecisionMax: Byte);
begin
  Field := 0;
  Length := 0;
  Overflow := AOverflow;
  FillerCharacter := AFillerCharacter;
  Comma := AComma;
  Character1000 := ACharacter1000;
  LeftJustify := ALeftJustify;
  PrecisionMin := APrecisionMin;
  PrecisionMax := APrecisionMax;
end;

procedure TFormatOptions.Initialize(AOther: TFormatOptions);
begin
  Overflow := AOther.Overflow;
  FillerCharacter := AOther.FillerCharacter;
  Comma := AOther.Comma;
  Character1000 := AOther.Character1000;
  LeftJustify := AOther.LeftJustify;
end;

procedure TFormatOptions.Clear();
begin
  Field := 0;
  Length := 0;
  Overflow := '\0';
  FillerCharacter := '\0';
  Comma := '\0';
  Character1000 := '\0';
  LeftJustify := false;
end;


end.
