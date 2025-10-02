unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TGoldNclTypeHelper = class(TObject)
  private
    m_nclToNavType: TGoldType[];
    m_fixedDefaultValues: TGoldValue[];
    m_navToNclType: TDictionary<TGoldType, TGoldNclType>;
    m_typeToNclType: TDictionary<Type, TGoldNclType>;
  public
    function GetNavTypeFromNclType(ANavNclType: TGoldNclType): TGoldType;
    function GetNclTypeFromNavType(ANavType: TGoldType): TGoldNclType;
    function GetNclTypeFromObject(AObj: TObject): TGoldNclType;
    function GetNclTypeFromObject(AValue: TObject; AForDotNet: Boolean): TGoldNclType;
    function GetNclTypeFromType(AType_: Type; AForDotNet: Boolean): TGoldNclType;
    function GetNavTypeFromType(AType_: Type; AForDotNet: Boolean): TGoldType;
    function GetNavTypeFromType(AType_: Type): TGoldType;
    function GetFixedDefaultNavValue(AMetadata: INavValueMetadata): TGoldValue;
    function TryGetNclTypeFromGenericType(AType_: Type; ANclType: TGoldNclType): Boolean;
    procedure InitializeStaticInfo();
    procedure AddInfo(ATempNclToNavType: TGoldType[]; ATempFixedDefaultValues: TGoldValue[]; ATempNavToNclType: TDictionary<TGoldType, TGoldNclType>; ATempTypeToNclType: TDictionary<Type, TGoldNclType>; ANclType: TGoldNclType; ANavType: TGoldType; ACompatibleTypes: Type[]);
    procedure AddInfo(ATempNclToNavType: TGoldType[]; ATempFixedDefaultValues: TGoldValue[]; ATempNavToNclType: TDictionary<TGoldType, TGoldNclType>; ATempTypeToNclType: TDictionary<Type, TGoldNclType>; ANclType: TGoldNclType; ANavType: TGoldType; AFixedDefaultValue: TGoldValue; ACompatibleTypes: Type[]);
  end;


implementation

function TGoldNclTypeHelper.GetNavTypeFromNclType(ANavNclType: TGoldNclType): TGoldType;
begin
  if m_nclToNavType = null then
  begin
    InitializeStaticInfo();
  end
  ;
  Result := m_nclToNavType[(int)ANavNclType];
end;

function TGoldNclTypeHelper.GetNclTypeFromNavType(ANavType: TGoldType): TGoldNclType;
begin
  if ANavType = TGoldType.NotSupported_Binary then
  begin
    raise TGoldNCLNotSupportedTypeException.CreateUnsupportedType(CultureInfo.CurrentUICulture, "Binary");
  end
  ;
  if m_navToNclType = null then
  begin
    InitializeStaticInfo();
  end
  ;
  if m_navToNclType.TryGetValue(ANavType, out var value) then
  begin
    Result := value;
  end
  ;
  raise TGoldNCLTypeMappingException.Create();
end;

function TGoldNclTypeHelper.GetNclTypeFromObject(AObj: TObject): TGoldNclType;
begin
  Result := GetNclTypeFromObject(AObj, AForDotNet: false);
end;

function TGoldNclTypeHelper.GetNclTypeFromObject(AValue: TObject; AForDotNet: Boolean): TGoldNclType;
begin
  if AValue = null then
  begin
    Result := TGoldNclType.None;
  end
  ;
  if AValue is TGoldObject navObject then
  begin
    Result := navObject.NclType;
  end
  ;
  if AValue is CurrencyWrapper then
  begin
    Result := TGoldNclType.GoldDecimal;
  end
  ;
  Result := GetNclTypeFromType(AValue.GetType(), AForDotNet);
end;

function TGoldNclTypeHelper.GetNclTypeFromType(AType_: Type; AForDotNet: Boolean): TGoldNclType;
begin
  if m_typeToNclType = null then
  begin
    InitializeStaticInfo();
  end
  ;
  if m_typeToNclType.TryGetValue(AType_, out var value) then
  begin
    Result := value;
  end
  ;
  if AForDotNet then
  begin
    Result := TGoldNclType.GoldDotNet;
  end
  ;
  if TryGetNclTypeFromGenericType(AType_, out value) then
  begin
    Result := value;
  end
  ;
  raise TGoldNCLNotSupportedTypeException.CreateUnknownType(CultureInfo.CurrentCulture, AType_.ToString());
end;

function TGoldNclTypeHelper.GetNavTypeFromType(AType_: Type; AForDotNet: Boolean): TGoldType;
begin
  Result := GetNavTypeFromNclType(GetNclTypeFromType(AType_, AForDotNet));
end;

function TGoldNclTypeHelper.GetNavTypeFromType(AType_: Type): TGoldType;
begin
  Result := GetNavTypeFromType(AType_, AForDotNet: false);
end;

function TGoldNclTypeHelper.GetFixedDefaultNavValue(AMetadata: INavValueMetadata): TGoldValue;
begin
  // TODO: Converter SwitchStatementSyntax
end;

function TGoldNclTypeHelper.TryGetNclTypeFromGenericType(AType_: Type; ANclType: TGoldNclType): Boolean;
begin
  raise TNotImplementedException.Create("Tambem não foi feito não por que não foi");
end;

procedure TGoldNclTypeHelper.InitializeStaticInfo();
begin
  array_: int[] := (int[])Enum.GetValues(typeof(TGoldNclType));
  // TODO: Converter ForStatementSyntax
  array2: TGoldType[] := new TGoldType[array_.Length];
  tempFixedDefaultValues: TGoldValue[] := new TGoldValue[array_.Length];
  tempNavToNclType: TDictionary<TGoldType, TGoldNclType> := new Dictionary<TGoldType, TGoldNclType>(array2.Length);
  tempTypeToNclType: TDictionary<Type, TGoldNclType> := new Dictionary<Type, TGoldNclType>(array2.Length + 10);
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.None, TGoldType.None);
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.GoldInteger, TGoldType.Integer, TGoldInteger.Default, typeof(TGoldInteger), typeof(short), typeof(int), typeof(ushort), typeof(sbyte));
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.GoldText, TGoldType.Text, typeof(TGoldText), typeof(string));
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.GoldDate, TGoldType.Date, TGoldDate.Default, typeof(TGoldDate));
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.GoldTime, TGoldType.Time, TGoldTime.Default, typeof(TGoldTime));
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.GoldDateTime, TGoldType.DateTime, TGoldDateTime.Default, typeof(TGoldDateTime), typeof(DateTime));
  AddInfo(array2, tempFixedDefaultValues, tempNavToNclType, tempTypeToNclType, TGoldNclType.GoldDateFormula, TGoldType.DateFormula, typeof(TGoldDateFormula));
  m_nclToNavType := array2;
  m_fixedDefaultValues := tempFixedDefaultValues;
  m_navToNclType := tempNavToNclType;
  m_typeToNclType := tempTypeToNclType;
  // TODO: Converter ForStatementSyntax
end;

procedure TGoldNclTypeHelper.AddInfo(ATempNclToNavType: TGoldType[]; ATempFixedDefaultValues: TGoldValue[]; ATempNavToNclType: TDictionary<TGoldType, TGoldNclType>; ATempTypeToNclType: TDictionary<Type, TGoldNclType>; ANclType: TGoldNclType; ANavType: TGoldType; ACompatibleTypes: Type[]);
begin
  AddInfo(ATempNclToNavType, ATempFixedDefaultValues, ATempNavToNclType, ATempTypeToNclType, ANclType, ANavType, null, ACompatibleTypes);
end;

procedure TGoldNclTypeHelper.AddInfo(ATempNclToNavType: TGoldType[]; ATempFixedDefaultValues: TGoldValue[]; ATempNavToNclType: TDictionary<TGoldType, TGoldNclType>; ATempTypeToNclType: TDictionary<Type, TGoldNclType>; ANclType: TGoldNclType; ANavType: TGoldType; AFixedDefaultValue: TGoldValue; ACompatibleTypes: Type[]);
begin
  ATempFixedDefaultValues[(int)ANclType] := AFixedDefaultValue;
  ATempNclToNavType[(int)ANclType] := ANavType;
  ATempNavToNclType.Add(ANavType, ANclType);
  // TODO: Converter ForStatementSyntax
end;


end.
