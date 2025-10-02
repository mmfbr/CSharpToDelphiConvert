unit GoldERP.Types.Exceptions;

interface

uses
  System.Classes, System.SysUtils;

type
  TLang = class(TObject)
  public
    property _00095_50082: String read Get_00095_50082 write Set_00095_50082;
    property _00095_50167: String read Get_00095_50167 write Set_00095_50167;
    property _00095_50165: String read Get_00095_50165 write Set_00095_50165;
    property _00095_50005: String read Get_00095_50005 write Set_00095_50005;
    property _00095_50019: String read Get_00095_50019 write Set_00095_50019;
    property _00095_50023: String read Get_00095_50023 write Set_00095_50023;
    property _00095_50035: String read Get_00095_50035 write Set_00095_50035;
    property _00095_50020: String read Get_00095_50020 write Set_00095_50020;
    property _00095_50001: String read Get_00095_50001 write Set_00095_50001;
    property _00095_50017: String read Get_00095_50017 write Set_00095_50017;
    property _00095_50105: String read Get_00095_50105 write Set_00095_50105;
    property _00095_50010: String read Get_00095_50010 write Set_00095_50010;
    property _00095_50007: String read Get_00095_50007 write Set_00095_50007;
    property _00095_50168: String read Get_00095_50168 write Set_00095_50168;
    property _00095_50027: String read Get_00095_50027 write Set_00095_50027;
    property _00095_50022: String read Get_00095_50022 write Set_00095_50022;
    property _00095_50024: String read Get_00095_50024 write Set_00095_50024;
    property EvaluateDateFormulaShouldIncludeAQuantorError: String read GetEvaluateDateFormulaShouldIncludeAQuantorError write SetEvaluateDateFormulaShouldIncludeAQuantorError;
    property EvaluateDateFormulaShouldIncludeANumberError: String read GetEvaluateDateFormulaShouldIncludeANumberError write SetEvaluateDateFormulaShouldIncludeANumberError;
    property EvaluateError: String read GetEvaluateError write SetEvaluateError;
    property WilcardCannotBeUsedWithOperator: String read GetWilcardCannotBeUsedWithOperator write SetWilcardCannotBeUsedWithOperator;
    property FilterExpressionVariableMustResolveToAValue: String read GetFilterExpressionVariableMustResolveToAValue write SetFilterExpressionVariableMustResolveToAValue;
    property FilterExpressionVariableNotResolved: String read GetFilterExpressionVariableNotResolved write SetFilterExpressionVariableNotResolved;
    property FilterExpressionTooLarge: String read GetFilterExpressionTooLarge write SetFilterExpressionTooLarge;
    property FilterExpressionMissingClosingParenthesis: String read GetFilterExpressionMissingClosingParenthesis write SetFilterExpressionMissingClosingParenthesis;
    property FilterExpressionExpectedValueAfter: String read GetFilterExpressionExpectedValueAfter write SetFilterExpressionExpectedValueAfter;
    property FilterExpressionLhsCannotBeEmpty: String read GetFilterExpressionLhsCannotBeEmpty write SetFilterExpressionLhsCannotBeEmpty;
    property FilterExpressionRangeBothSidesOfRangeCannotBeEmpty: String read GetFilterExpressionRangeBothSidesOfRangeCannotBeEmpty write SetFilterExpressionRangeBothSidesOfRangeCannotBeEmpty;
    property FilterExpressionRangeRhsMustBeAValue: String read GetFilterExpressionRangeRhsMustBeAValue write SetFilterExpressionRangeRhsMustBeAValue;
    property FilterExpressionRangeLhsMustBeAValue: String read GetFilterExpressionRangeLhsMustBeAValue write SetFilterExpressionRangeLhsMustBeAValue;
    property FilterExpressionUnexpectedValue: String read GetFilterExpressionUnexpectedValue write SetFilterExpressionUnexpectedValue;
    property FilterExpressionUnexpectedToken: String read GetFilterExpressionUnexpectedToken write SetFilterExpressionUnexpectedToken;
    property FilterExpressionRhsCannotBeEmpty: String read GetFilterExpressionRhsCannotBeEmpty write SetFilterExpressionRhsCannotBeEmpty;
    property CalcDateResultOverflow: String read GetCalcDateResultOverflow write SetCalcDateResultOverflow;
    property CalcDateOnUndefinedDate: String read GetCalcDateOnUndefinedDate write SetCalcDateOnUndefinedDate;
    property IllegalCalcDateArgument: String read GetIllegalCalcDateArgument write SetIllegalCalcDateArgument;
    property InvalidDateTimeForTimeZone: String read GetInvalidDateTimeForTimeZone write SetInvalidDateTimeForTimeZone;
    property UnableToCreateFromObject: String read GetUnableToCreateFromObject write SetUnableToCreateFromObject;
    property InvalidLanguage: String read GetInvalidLanguage write SetInvalidLanguage;
    property InvalidFormatLanguage: String read GetInvalidFormatLanguage write SetInvalidFormatLanguage;
    property InvalidLanguageCode: String read GetInvalidLanguageCode write SetInvalidLanguageCode;
    property FilterExpressionQuoteMissing: String read GetFilterExpressionQuoteMissing write SetFilterExpressionQuoteMissing;
    property QueryOutputCouldNotBeSaved: String read GetQueryOutputCouldNotBeSaved write SetQueryOutputCouldNotBeSaved;
    property CannotModifyAutoIncrementFieldError: String read GetCannotModifyAutoIncrementFieldError write SetCannotModifyAutoIncrementFieldError;
    property BadCodeDataError: String read GetBadCodeDataError write SetBadCodeDataError;
    property ConversionCastException: String read GetConversionCastException write SetConversionCastException;
    property EvaluateDateFormulaSignMissingError: String read GetEvaluateDateFormulaSignMissingError write SetEvaluateDateFormulaSignMissingError;
    property EvaluateDateFormulaExceedsMaxLengthError: String read GetEvaluateDateFormulaExceedsMaxLengthError write SetEvaluateDateFormulaExceedsMaxLengthError;
    property EvaluateDateFormulaNumberOutOfRangeError: String read GetEvaluateDateFormulaNumberOutOfRangeError write SetEvaluateDateFormulaNumberOutOfRangeError;
    property EvaluateIntegerValueOutOfRangeError: String read GetEvaluateIntegerValueOutOfRangeError write SetEvaluateIntegerValueOutOfRangeError;
    property InvalidComparison: String read GetInvalidComparison write SetInvalidComparison;
    property InvalidFormatString: String read GetInvalidFormatString write SetInvalidFormatString;
    property InvalidStandardFormat: String read GetInvalidStandardFormat write SetInvalidStandardFormat;
    property ALSelectStringCommaStringIndexNotValue: String read GetALSelectStringCommaStringIndexNotValue write SetALSelectStringCommaStringIndexNotValue;
    property ALConvertStringExpectsEqualLength: String read GetALConvertStringExpectsEqualLength write SetALConvertStringExpectsEqualLength;
    property ArrayCloneIllegalType: String read GetArrayCloneIllegalType write SetArrayCloneIllegalType;
    property FormUnsupportedSplitKeyType: String read GetFormUnsupportedSplitKeyType write SetFormUnsupportedSplitKeyType;
    property GetDotNetType: String read GetGetDotNetType write SetGetDotNetType;
    property GoldTypeIsNotSupported: String read GetGoldTypeIsNotSupported write SetGoldTypeIsNotSupported;
  end;


implementation


end.
