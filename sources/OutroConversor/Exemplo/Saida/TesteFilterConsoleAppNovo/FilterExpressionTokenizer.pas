unit GoldERP.Runtime;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  TFilterExpressionTokenizer = class(TObject)
  public
    function GetTokens(AInput: String): TList<TFilterToken>;
    procedure AddAnyUnquotedLiteral(AUnquotedLiteralStartPosition: Integer; ATokens: TList<TFilterToken>; AInput: String; ACurrentPosition: Integer; ALastWhitespaceStartPosition: Integer);
    function CharAtOrDefault(AIndex: Integer; AInput: String): Char;
  end;


implementation

function TFilterExpressionTokenizer.GetTokens(AInput: String): TList<TFilterToken>;
begin
  if AInput = null then
  begin
    raise TArgumentNullException.Create("AInput");
  end
  ;
  list: TList<TFilterToken> := new List<TFilterToken>(16);
  unquotedLiteralStartPosition: Integer := -1;
  num: Integer := -1;
  // TODO: Converter ForStatementSyntax
  AddAnyUnquotedLiteral(ref unquotedLiteralStartPosition, list, AInput, AInput.Length, num);
  Result := list;
end;

procedure TFilterExpressionTokenizer.AddAnyUnquotedLiteral(AUnquotedLiteralStartPosition: Integer; ATokens: TList<TFilterToken>; AInput: String; ACurrentPosition: Integer; ALastWhitespaceStartPosition: Integer);
begin
  if AUnquotedLiteralStartPosition >= 0 then
  begin
    num: Integer := (ALastWhitespaceStartPosition < 0 ? ACurrentPosition : ALastWhitespaceStartPosition) - 1;
    ATokens.Add(TFilterToken.Literal(AInput.Substring(AUnquotedLiteralStartPosition, num - AUnquotedLiteralStartPosition + 1), AQuoted: false));
    AUnquotedLiteralStartPosition := -1;
  end
  ;
end;

function TFilterExpressionTokenizer.CharAtOrDefault(AIndex: Integer; AInput: String): Char;
begin
  if AIndex >= AInput.Length then
  begin
    Result := '\0';
  end
  ;
  Result := AInput[AIndex];
end;


end.
