unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TSqlSortingProperties = class(TObject)
  private
    m_collationVersion: Byte;
    m_databaseCollationCultureId: Integer;
    m_collation: String;
    m_comparisonStyleFlags: Integer;
    m_databaseComparisonStyle: TCompareOptions;
    m_isCollationCompatibleWithWindows: Boolean;
    m_accentAndCaseInsensitiveCollation: String;
    m_databaseCollationCulture: TCultureInfo;
  public
    const m_IgnoreCase: uint = 0x1u;
    const m_IgnoreNonSpace: uint = 0x2u;
    const m_IgnoreKanaType: uint = 0x10000u;
    const m_IgnoreWidth: uint = 0x20000u;
    constructor Create(ACollationVersion: Byte; AComparisonStyleFlags: Integer; ADatabaseCollationCultureId: Integer; ACollation: String);
    constructor Create(ACulture: TCultureInfo; ACompareOptions: TCompareOptions; ACollation: String);
    function IsSameSorting(AOtherSortingProperties: TSqlSortingProperties): Boolean;
    property AccentAndCaseInsensitiveCollation: String read GetAccentAndCaseInsensitiveCollation write SetAccentAndCaseInsensitiveCollation;
    property CollationVersion: Integer read GetCollationVersion write SetCollationVersion;
    property IsCollationCompatibleWithWindows: Boolean read GetIsCollationCompatibleWithWindows write SetIsCollationCompatibleWithWindows;
    property DatabaseComparisonStyle: TCompareOptions read GetDatabaseComparisonStyle write SetDatabaseComparisonStyle;
    property DatabaseCollationCulture: TCultureInfo read GetDatabaseCollationCulture write SetDatabaseCollationCulture;
    property Collation: String read GetCollation write SetCollation;
    property IsAccentAndCaseInsensitive: Boolean read GetIsAccentAndCaseInsensitive write SetIsAccentAndCaseInsensitive;
    property IsCaseInsensitive: Boolean read GetIsCaseInsensitive write SetIsCaseInsensitive;
    property IsAccentInsensitive: Boolean read GetIsAccentInsensitive write SetIsAccentInsensitive;
  end;


implementation

constructor TSqlSortingProperties.Create(ACollationVersion: Byte; AComparisonStyleFlags: Integer; ADatabaseCollationCultureId: Integer; ACollation: String);
begin
  Self.m_collationVersion := collationVersion;
  Self.m_comparisonStyleFlags := comparisonStyleFlags;
  Self.m_databaseCollationCultureId := databaseCollationCultureId;
  Self.m_collation := collation;
end;

constructor TSqlSortingProperties.Create(ACulture: TCultureInfo; ACompareOptions: TCompareOptions; ACollation: String);
begin
  m_collationVersion := 0;
  m_databaseCollationCulture := culture;
  m_databaseCollationCultureId := culture.LCID;
  m_databaseComparisonStyle := compareOptions;
end;

function TSqlSortingProperties.IsSameSorting(AOtherSortingProperties: TSqlSortingProperties): Boolean;
begin
  Result := string.Equals(m_collation, otherSortingProperties.m_collation, StringComparison.Ordinal);
end;


end.
