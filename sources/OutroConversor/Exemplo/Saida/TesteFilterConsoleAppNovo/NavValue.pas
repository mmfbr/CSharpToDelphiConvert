unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldValue = class(TGoldObject)
  public
    function GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
    function GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
    function GetHashCode(): Integer;
    function GetBytes(): byte[];
    function ToInt32(): Integer;
    function ToInt64(): Int64;
    function ToDateTime(): TDateTime;
    function ToString(): String;
    function ToString(AInvariant: Boolean): String;
    function Equals(AOther: TGoldValue): Boolean;
    function CompareTo(AOther: TGoldValue): Integer;
    function ThrowUnableToCompareException(AUnsupportedInstance: TObject): Boolean;
    function CreateUnableToCompareException(ATarget: Type; AUnsupportedInstance: TObject): TGoldNCLInvalidComparisonException;
    function CreateUnableToCreateFromObjectException(ATarget: Type; AUnsupportedObject: TObject): TGoldNCLArgumentException;
    function CompareTypeAndMetadata(AOtherMetadata: INavValueMetadata): Boolean;
    function CreateNavValueFromObject(AMetadata: INavValueMetadata; AValue: TObject): TGoldValue;
    procedure StoreToBytes(AWriter: TBinaryWriter);
    function GetDefaultNavValue(AMetadata: INavValueMetadata; ANullSupport: Boolean): TGoldValue;
    property GoldDefinedLengthMetadata: Integer read GetGoldDefinedLengthMetadata write SetGoldDefinedLengthMetadata;
    property GetBytesSize: Integer read GetGetBytesSize write SetGetBytesSize;
    property IsWrapper: Boolean read GetIsWrapper write SetIsWrapper;
    property IsInitialized: Boolean read GetIsInitialized write SetIsInitialized;
    property IsNull: Boolean read GetIsNull write SetIsNull;
    property InnerValue: TGoldValue read GetInnerValue write SetInnerValue;
    property IsZeroOrEmpty: Boolean read GetIsZeroOrEmpty write SetIsZeroOrEmpty;
    property ValueAsObject: TObject read GetValueAsObject write SetValueAsObject;
    property ClientObject: TObject read GetClientObject write SetClientObject;
  end;


implementation

function TGoldValue.GetSqlWhereClauseValue(ASqlDataType: TSqlDataType): TObject;
begin
  Result := ValueAsObject;
end;

function TGoldValue.GetSqlWritableValue(ASqlDataType: TSqlDataType; AMaxLength: Integer; ACompressed: Boolean): TObject;
begin
  Result := ValueAsObject;
end;

function TGoldValue.GetHashCode(): Integer;
begin
end;

function TGoldValue.GetBytes(): byte[];
begin
  raise TNotSupportedException.Create();
end;

function TGoldValue.ToInt32(): Integer;
begin
  raise TGoldNCLConversionException.Create(GetType(), typeof(int));
end;

function TGoldValue.ToInt64(): Int64;
begin
  Result := ToInt32();
end;

function TGoldValue.ToDateTime(): TDateTime;
begin
  raise TGoldNCLConversionException.Create(GetType(), typeof(DateTime));
end;

function TGoldValue.ToString(): String;
begin
  Result := TGoldFormatEvaluateHelper.Format(this);
end;

function TGoldValue.ToString(AInvariant: Boolean): String;
begin
  if not invariant then
  begin
    Result := TGoldFormatEvaluateHelper.Format(this);
  end
  ;
  Result := TGoldFormatEvaluateHelper.Format(this, 0, 9, TGoldSession.InvariantFormatSettings);
end;

function TGoldValue.Equals(AOther: TGoldValue): Boolean;
begin
  if other = null then
  begin
    Result := false;
  end
  ;
  if other = this then
  begin
    Result := true;
  end
  ;
  if GoldType <> other.GoldType then
  begin
    Result := false;
  end
  ;
  Result := ThrowUnableToCompareException(other);
end;

function TGoldValue.CompareTo(AOther: TGoldValue): Integer;
begin
  ThrowUnableToCompareException(other);
  Result := 0;
end;

function TGoldValue.ThrowUnableToCompareException(AUnsupportedInstance: TObject): Boolean;
begin
  raise CreateUnableToCompareException(GetType(), unsupportedInstance);
end;

function TGoldValue.CreateUnableToCompareException(ATarget: Type; AUnsupportedInstance: TObject): TGoldNCLInvalidComparisonException;
begin
  unsupportedTypeName: String := (if unsupportedInstance = null then "<NULL>" else unsupportedInstance.GetType().Name);
  Result := TGoldNCLInvalidComparisonException.Create(CultureInfo.InvariantCulture, target.Name, unsupportedTypeName);
end;

function TGoldValue.CreateUnableToCreateFromObjectException(ATarget: Type; AUnsupportedObject: TObject): TGoldNCLArgumentException;
begin
  arg: String := (if unsupportedObject = null then "<NULL>" else unsupportedObject.GetType().Name);
  Result := TGoldNCLArgumentException.Create(string.Format(CultureInfo.CurrentCulture, TLang.UnableToCreateFromObject, arg, target.Name));
end;

function TGoldValue.CompareTypeAndMetadata(AOtherMetadata: INavValueMetadata): Boolean;
begin
  if otherMetadata = null then
  begin
    raise TArgumentNullException.Create("otherMetadata");
  end
  ;
  Result := TGoldValueMetadata.CompareTypeAndMetadata(this, otherMetadata);
end;

function TGoldValue.CreateNavValueFromObject(AMetadata: INavValueMetadata; AValue: TObject): TGoldValue;
begin
  if metadata = null then
  begin
    raise TArgumentNullException.Create("metadata");
  end
  ;
  nclType: TGoldNclType := metadata.NclType;
  // TODO: Converter ForStatementSyntax
  if value = DBNull.Value then
  begin
    value := null;
  end
  ;
  // TODO: Converter TryStatementSyntax
  raise TGoldNCLNotSupportedTypeException.CreateUnknownType(CultureInfo.CurrentCulture, nclType.ToString());
end;

procedure TGoldValue.StoreToBytes(AWriter: TBinaryWriter);
begin
  writer.Write((int)GoldType);
  bytes: byte[] := GetBytes();
  writer.Write(bytes.Length);
  writer.Write(bytes);
end;

function TGoldValue.GetDefaultNavValue(AMetadata: INavValueMetadata; ANullSupport: Boolean): TGoldValue;
begin
  fixedDefaultNavValue: TGoldValue;
  if not nullSupport then
  begin
    fixedDefaultNavValue := TGoldNclTypeHelper.GetFixedDefaultNavValue(metadata);
    if fixedDefaultNavValue <> null then
    begin
      Result := fixedDefaultNavValue;
    end
    ;
  end
  ;
  fixedDefaultNavValue := metadata.NclType switch
            {
                TGoldNclType.GoldDate => nullSupport ? TGoldDate.Null : TGoldDate.Default,
                TGoldNclType.GoldDateTime => nullSupport ? TGoldDateTime.Null : TGoldDateTime.Default,
                TGoldNclType.GoldInteger => nullSupport ? TGoldInteger.Null : TGoldInteger.Default,
                TGoldNclType.GoldText => nullSupport ? TGoldText.NullWithMaxLength(metadata.GoldDefinedLengthMetadata) : TGoldText.Default(metadata.GoldDefinedLengthMetadata),
                TGoldNclType.GoldDateFormula => TGoldDateFormula.Default,
                TGoldNclType.GoldTime => TGoldTime.Default,
                _ => throw TGoldNCLNotSupportedTypeException.CreateUnknownType(CultureInfo.CurrentCulture, metadata.NclType.ToString()),
            };
  if nullSupport and not fixedDefaultNavValue.IsNull and fixedDefaultNavValue.NclType <> TGoldNclType.GoldBlob then
  begin
    raise TGoldNCLNotSupportedTypeException.CreateUnknownType(CultureInfo.CurrentCulture, metadata.NclType.ToString());
  end
  ;
  Result := fixedDefaultNavValue;
end;


end.
