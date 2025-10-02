unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TCollationAwareStringComparer = class(IEqualityComparer<string>)
  private
    m_sortingProperties: TSqlSortingProperties;
    m_compareInfo: TCompareInfo;
    m_SpaceArray: char[];
  public
    const m_Space: Char = ' ';
    constructor Create(AProperties: TSqlSortingProperties);
    function Equals(AX: String; AY: String): Boolean;
    function Compare(AX: String; AY: String): Integer;
    function GetHashCode(ASource: String): Integer;
    function Compare(ACompareInfo: TCompareInfo; AOptions: TCompareOptions; ALeft: String; ARight: String): Integer;
    function Compare(ACompareInfo: TCompareInfo; AOptions: TCompareOptions; ALeft: String; ARight: String; AEmptyValue: String): Integer;
    function IsEmpty(AStringValue: String; AEmptyValue: String): Boolean;
    function TrimSpacesFromEnd(AValue: String): String;
  end;


implementation

constructor TCollationAwareStringComparer.Create(AProperties: TSqlSortingProperties);
begin
  inherited Create;
  m_sortingProperties := AProperties ?? TGoldGlobal.SqlSortingProperties;
  m_compareInfo := m_sortingProperties.DatabaseCollationCulture.CompareInfo;
end;

function TCollationAwareStringComparer.Equals(AX: String; AY: String): Boolean;
begin
  if (object)AX = AY then
  begin
    Result := true;
  end
  ;
  if AX = null then
  begin
    Result := AY = null;
  end
  ;
  if AY = null then
  begin
    Result := false;
  end
  ;
  Result := Compare(m_compareInfo, m_sortingProperties.DatabaseComparisonStyle, AX, AY) = 0;
end;

function TCollationAwareStringComparer.Compare(AX: String; AY: String): Integer;
begin
  if AY = null then
  begin
    if AX <> null then
    begin
      Result := 1;
    end
    ;
    Result := 0;
  end
  ;
  if AX = null then
  begin
    Result := -1;
  end
  ;
  if (object)AX = AY then
  begin
    Result := 0;
  end
  ;
  Result := Compare(m_compareInfo, m_sortingProperties.DatabaseComparisonStyle, AX, AY);
end;

function TCollationAwareStringComparer.GetHashCode(ASource: String): Integer;
begin
  if ASource = null then
  begin
    Result := 0;
  end
  ;
  sortKey: TSortKey := m_compareInfo.GetSortKey(ASource, m_sortingProperties.DatabaseComparisonStyle);
  Result := sortKey.GetHashCode();
end;

function TCollationAwareStringComparer.Compare(ACompareInfo: TCompareInfo; AOptions: TCompareOptions; ALeft: String; ARight: String): Integer;
begin
  string_: String := TrimSpacesFromEnd(ALeft);
  string2: String := TrimSpacesFromEnd(ARight);
  Result := ACompareInfo.Compare(string_, string2, AOptions);
end;

function TCollationAwareStringComparer.Compare(ACompareInfo: TCompareInfo; AOptions: TCompareOptions; ALeft: String; ARight: String; AEmptyValue: String): Integer;
begin
  text: String := TrimSpacesFromEnd(ALeft);
  text2: String := TrimSpacesFromEnd(ARight);
  if AEmptyValue <> null and IsEmpty(text, AEmptyValue) and IsEmpty(text2, AEmptyValue) then
  begin
    Result := 0;
  end
  ;
  Result := Compare(ACompareInfo, AOptions, text, text2);
end;

function TCollationAwareStringComparer.IsEmpty(AStringValue: String; AEmptyValue: String): Boolean;
begin
  if not string.IsNullOrEmpty(AStringValue) then
  begin
    Result := AStringValue.Equals(AEmptyValue);
  end
  ;
  Result := true;
end;

function TCollationAwareStringComparer.TrimSpacesFromEnd(AValue: String): String;
begin
  if string.IsNullOrEmpty(AValue) or AValue[AValue.Length - 1] <> m_Space then
  begin
    Result := AValue;
  end
  ;
  Result := AValue.TrimEnd(m_SpaceArray);
end;


end.
