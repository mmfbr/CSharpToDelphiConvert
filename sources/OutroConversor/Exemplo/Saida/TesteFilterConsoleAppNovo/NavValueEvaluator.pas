unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TGoldValueEvaluator = class(TObject)
  public
    function Evaluate(ADataError: TDataError; AValue: TGoldValue; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function GetEvaluator(AType_: TGoldNclType): TGoldValueEvaluator;
    function GetNumberStyles(ANumber: Integer): TNumberStyles;
    function GetFormatProvider(ANumber: Integer): IFormatProvider;
    procedure ConsumeWhitespace(AInput: String; APosition: Integer);
    function EvaluateNumberSequence(ASource: String; APosition: Integer; ANumberOfNumbers: Integer; ALongNumberIndex: Integer; AMaxNumberOfDigitsInLongNumber: Integer; ANumberOfDigitsInLongNumber: Integer): int[];
    procedure ConsumeUntilDigit(AInput: String; APosition: Integer);
    function TryReadDigitToken(AInput: String; APosition: Integer; A_result: String): Boolean;
    function StartsWith(AInput: String; AInputPosition: Integer; AValue: String; AValuePosition: Integer): Boolean;
  end;

type
  TGoldValueEvaluator = class(TGoldValueEvaluator)
  public
    function Evaluate(ADataError: TDataError; AValue: TGoldValue; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function Evaluate(ADataError: TDataError; AValue: T; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function InternalEvaluate(ADataError: TDataError; AValue: T; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
    function GetDefaultValue(AMetadata: INavValueMetadata): T;
    function CreateEvaluateException(AMetadata: INavValueMetadata; ASource: String): TGoldNCLEvaluateException;
  end;


implementation

function TGoldValueEvaluator.Evaluate(ADataError: TDataError; AValue: TGoldValue; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
end;

function TGoldValueEvaluator.GetEvaluator(AType_: TGoldNclType): TGoldValueEvaluator;
begin
  Result := type_ switch
            {
                TGoldNclType.GoldDate => TGoldDateEvaluator.Instance,
                TGoldNclType.GoldDateTime => TGoldDateTimeEvaluator.Instance,
                TGoldNclType.GoldDateFormula => TGoldDateFormulaEvaluator.Instance,
                TGoldNclType.GoldInteger => TGoldIntegerEvaluator.Instance,
                TGoldNclType.GoldText => TGoldTextEvaluator.Instance,
                TGoldNclType.GoldTime => TGoldTimeEvaluator.Instance,
                _ => null,
            };
end;

function TGoldValueEvaluator.GetNumberStyles(ANumber: Integer): TNumberStyles;
begin
  if number = 9 then
  begin
    Result := NumberStyles.Integer | NumberStyles.AllowDecimalPoint;
  end
  ;
  Result := NumberStyles.Any;
end;

function TGoldValueEvaluator.GetFormatProvider(ANumber: Integer): IFormatProvider;
begin
  if number = 9 then
  begin
    Result := CultureInfo.InvariantCulture;
  end
  ;
  Result := TGoldCurrentSessionWrapper.WindowsCulture;
end;

procedure TGoldValueEvaluator.ConsumeWhitespace(AInput: String; APosition: Integer);
begin
  // TODO: Converter WhileStatementSyntax
end;

function TGoldValueEvaluator.EvaluateNumberSequence(ASource: String; APosition: Integer; ANumberOfNumbers: Integer; ALongNumberIndex: Integer; AMaxNumberOfDigitsInLongNumber: Integer; ANumberOfDigitsInLongNumber: Integer): int[];
begin
  numberOfDigitsInLongNumber := 0;
  array_: string[] := new string[numberOfNumbers];
  // TODO: Converter ForStatementSyntax
  num2: Integer := 0;
  array2: int[] := new int[numberOfNumbers];
  // TODO: Converter ForStatementSyntax
  for text in array_ do
  begin
    if text = null then
    begin
      // TODO: Converter BreakStatementSyntax
    end
    ;
    num3: Integer := 0;
    // TODO: Converter WhileStatementSyntax
  end;
  Result := array2;
end;

procedure TGoldValueEvaluator.ConsumeUntilDigit(AInput: String; APosition: Integer);
begin
  // TODO: Converter WhileStatementSyntax
end;

function TGoldValueEvaluator.TryReadDigitToken(AInput: String; APosition: Integer; A_result: String): Boolean;
begin
  _result := null;
  num: Integer := position;
  // TODO: Converter WhileStatementSyntax
  if num = position then
  begin
    Result := false;
  end
  ;
  _result := input.Substring(num, position - num);
  Result := true;
end;

function TGoldValueEvaluator.StartsWith(AInput: String; AInputPosition: Integer; AValue: String; AValuePosition: Integer): Boolean;
begin
  Result := string.Compare(input, inputPosition, value, valuePosition, value.Length - valuePosition, StringComparison.OrdinalIgnoreCase) = 0;
end;

function TGoldValueEvaluator.Evaluate(ADataError: TDataError; AValue: TGoldValue; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  value2: T;
  _result: Boolean := Evaluate(dataError, out value2, metadata, source, number);
  value := value2;
  Result := _result;
end;

function TGoldValueEvaluator.Evaluate(ADataError: TDataError; AValue: T; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
  // TODO: Converter TryStatementSyntax
end;

function TGoldValueEvaluator.InternalEvaluate(ADataError: TDataError; AValue: T; AMetadata: INavValueMetadata; ASource: String; ANumber: Integer): Boolean;
begin
end;

function TGoldValueEvaluator.GetDefaultValue(AMetadata: INavValueMetadata): T;
begin
  Result := (T)TGoldValue.GetDefaultNavValue(metadata);
end;

function TGoldValueEvaluator.CreateEvaluateException(AMetadata: INavValueMetadata; ASource: String): TGoldNCLEvaluateException;
begin
  Result := TGoldNCLEvaluateException.Create(CultureInfo.CurrentCulture, metadata?.GoldType ?? TGoldNclTypeHelper.GetNavTypeFromType(typeof(T)), source);
end;


end.
