unit GoldERP.Types.Data;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldSerializer = class(TObject)
  public
    function ReadTypeAndItem(ABinReader: TBinaryReader): TObject;
    procedure WriteTypeAndItem(ABinWriter: TBinaryWriter; ATypeHandle: TRuntimeTypeHandle; AValue: TObject; AUseCompactSerialization: Boolean);
    function GetTypeCode(ATypeHandle: TRuntimeTypeHandle): TGoldTypeCode;
    function GetType(ATypeCode: TGoldTypeCode): Type;
    function PrepareValueForOutput(AItemValue: TObject; ACode: TGoldTypeCode): String;
    function PrepareValueForXmlOutput(AItemValue: TObject; ACode: TGoldTypeCode): String;
    procedure WriteItem(ABinWriter: TBinaryWriter; ANavTypeCode: TGoldTypeCode; AValue: TObject; AUseCompactSerialization: Boolean);
    function ReadItem(ABinReader: TBinaryReader; ANavTypeCode: TGoldTypeCode): TObject;
  end;


implementation

function TGoldSerializer.ReadTypeAndItem(ABinReader: TBinaryReader): TObject;
begin
  navTypeCode: TGoldTypeCode := (TGoldTypeCode)ReadItem(ABinReader, TGoldTypeCode.Byte);
  Result := ReadItem(ABinReader, navTypeCode);
end;

procedure TGoldSerializer.WriteTypeAndItem(ABinWriter: TBinaryWriter; ATypeHandle: TRuntimeTypeHandle; AValue: TObject; AUseCompactSerialization: Boolean);
begin
  navTypeCode: TGoldTypeCode := GetTypeCode(ATypeHandle);
  WriteItem(ABinWriter, TGoldTypeCode.Byte, navTypeCode, AUseCompactSerialization);
  WriteItem(ABinWriter, navTypeCode, AValue, AUseCompactSerialization);
end;

function TGoldSerializer.GetTypeCode(ATypeHandle: TRuntimeTypeHandle): TGoldTypeCode;
begin
  if typeof(DBNull).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.DBNull;
  end
  ;
  if typeof(bool).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Boolean;
  end
  ;
  if typeof(char).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Char;
  end
  ;
  if typeof(sbyte).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.SByte;
  end
  ;
  if typeof(byte).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Byte;
  end
  ;
  if typeof(short).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Int16;
  end
  ;
  if typeof(ushort).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.UInt16;
  end
  ;
  if typeof(int).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Int32;
  end
  ;
  if typeof(uint).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.UInt32;
  end
  ;
  if typeof(long).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Int64;
  end
  ;
  if typeof(ulong).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.UInt64;
  end
  ;
  if typeof(float).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Single;
  end
  ;
  if typeof(double).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Double;
  end
  ;
  if typeof(decimal).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Decimal;
  end
  ;
  if typeof(DateTime).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.DateTime;
  end
  ;
  if typeof(TimeSpan).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.TimeSpan;
  end
  ;
  if typeof(string).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.String;
  end
  ;
  if typeof(Guid).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.Guid;
  end
  ;
  if typeof(byte[]).TypeHandle.Equals(ATypeHandle) then
  begin
    Result := TGoldTypeCode.ByteArray;
  end
  ;
  raise TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "O tipo '{0}' não é conhecido pelo TGoldSerializer.", Type.GetTypeFromHandle(ATypeHandle).ToString()), "ATypeHandle");
end;

function TGoldSerializer.GetType(ATypeCode: TGoldTypeCode): Type;
begin
  Result := ATypeCode switch
            {
                TGoldTypeCode.DBNull => typeof(DBNull),
                TGoldTypeCode.Boolean => typeof(bool),
                TGoldTypeCode.Char => typeof(char),
                TGoldTypeCode.SByte => typeof(sbyte),
                TGoldTypeCode.Byte => typeof(byte),
                TGoldTypeCode.Int16 => typeof(short),
                TGoldTypeCode.UInt16 => typeof(ushort),
                TGoldTypeCode.Int32 => typeof(int),
                TGoldTypeCode.UInt32 => typeof(uint),
                TGoldTypeCode.Int64 => typeof(long),
                TGoldTypeCode.UInt64 => typeof(ulong),
                TGoldTypeCode.Single => typeof(float),
                TGoldTypeCode.Double => typeof(double),
                TGoldTypeCode.Decimal => typeof(decimal),
                TGoldTypeCode.DateTime => typeof(DateTime),
                TGoldTypeCode.TimeSpan => typeof(TimeSpan),
                TGoldTypeCode.String => typeof(string),
                TGoldTypeCode.Guid => typeof(Guid),
                TGoldTypeCode.ByteArray => typeof(byte[]),
                TGoldTypeCode.Media => typeof(Guid),
                TGoldTypeCode.MediaSet => typeof(Guid),
                _ => throw TArgumentException.Create(string.Format(CultureInfo.InvariantCulture, "O tipo '{0}' não é conhecido pelo TGoldSerializer.", ATypeCode), "ATypeCode"),
            };
end;

function TGoldSerializer.PrepareValueForOutput(AItemValue: TObject; ACode: TGoldTypeCode): String;
begin
  Result := ACode switch
            {
                TGoldTypeCode.Boolean => ((bool)AItemValue).ToString(CultureInfo.CurrentCulture),
                TGoldTypeCode.DateTime => ((DateTime)AItemValue).ToString(CultureInfo.CurrentCulture),
                TGoldTypeCode.Decimal => ((decimal)AItemValue).ToString(CultureInfo.CurrentCulture),
                //TGoldTypeCode.Media => (AItemValue as NSMediaWrapper ?? TNSMediaWrapper.Create((GoldMediaDescriptionCollection)AItemValue)).ToString(),
                //TGoldTypeCode.MediaSet => (AItemValue as NSMediaSetWrapper ?? TNSMediaSetWrapper.Create((GoldMediaDescriptionCollection)AItemValue)).ToString(),
                _ => AItemValue.ToString(),
            };
end;

function TGoldSerializer.PrepareValueForXmlOutput(AItemValue: TObject; ACode: TGoldTypeCode): String;
begin
  // TODO: Converter SwitchStatementSyntax
end;

procedure TGoldSerializer.WriteItem(ABinWriter: TBinaryWriter; ANavTypeCode: TGoldTypeCode; AValue: TObject; AUseCompactSerialization: Boolean);
begin
  if AValue = DBNull.Value then
  begin
    ABinWriter.Write((byte)0);
    Exit;
  end
  ;
  if AValue = TDBNotChanged.m_Value then
  begin
    ABinWriter.Write((byte)1);
    Exit;
  end
  ;
  if AUseCompactSerialization and ANavTypeCode <> TGoldTypeCode.Media and ANavTypeCode <> TGoldTypeCode.MediaSet and (AValue.Equals(0) or AValue.Equals(0m)) then
  begin
    ABinWriter.Write((byte)3);
    Exit;
  end
  ;
  ABinWriter.Write((byte)2);
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldSerializer.ReadItem(ABinReader: TBinaryReader; ANavTypeCode: TGoldTypeCode): TObject;
begin
  // TODO: Converter SwitchStatementSyntax
end;


end.
