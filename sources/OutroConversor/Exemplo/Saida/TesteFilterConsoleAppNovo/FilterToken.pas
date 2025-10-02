unit GoldERP.Runtime;

interface

uses
  System.Classes, System.SysUtils;

type
  TFilterToken = class(ISizableObject)
  private
    m_nonLiteralTokens: TFilterToken[];
    m_tokenType: TFilterTokenType;
    m_value: String;
    m_quoted: Boolean;
  public
    constructor Create(ATokenType: TFilterTokenType; AValue: String);
    constructor Create(ATokenType: TFilterTokenType; AValue: String; AQuoted: Boolean);
    constructor Create(ATokenType: TFilterTokenType);
    function NonLiteral(ATokenType: TFilterTokenType): TFilterToken;
    function Literal(AValue: String; AQuoted: Boolean): TFilterToken;
    function BuildNonLiteralTokens(): TFilterToken[];
    function ToString(): String;
    property ApproximateByteSize: Integer read GetApproximateByteSize write SetApproximateByteSize;
    property TokenType: TFilterTokenType read GetTokenType write SetTokenType;
    property Value: String read GetValue write SetValue;
    property Quoted: Boolean read GetQuoted write SetQuoted;
  end;


implementation

constructor TFilterToken.Create(ATokenType: TFilterTokenType; AValue: String);
begin
  inherited Create;
end;

constructor TFilterToken.Create(ATokenType: TFilterTokenType; AValue: String; AQuoted: Boolean);
begin
  inherited Create;
  Self.m_tokenType := ATokenType;
  Self.m_value := AValue;
  Self.m_quoted := AQuoted;
end;

constructor TFilterToken.Create(ATokenType: TFilterTokenType);
begin
  inherited Create;
  Self.m_tokenType := ATokenType;
end;

function TFilterToken.NonLiteral(ATokenType: TFilterTokenType): TFilterToken;
begin
  if ATokenType = TFilterTokenType.Literal then
  begin
    raise TNotSupportedException.Create();
  end
  ;
  Result := m_nonLiteralTokens[(int)ATokenType];
end;

function TFilterToken.Literal(AValue: String; AQuoted: Boolean): TFilterToken;
begin
  Result := TFilterToken.Create(TFilterTokenType.Literal, AValue, AQuoted);
end;

function TFilterToken.BuildNonLiteralTokens(): TFilterToken[];
begin
  num: Integer := Enum.GetValues(typeof(TFilterTokenType)).Cast<int>().Max();
  array_: TFilterToken[] := new TFilterToken[num + 1];
  // TODO: Converter ForStatementSyntax
  Result := array_;
end;

function TFilterToken.ToString(): String;
begin
  Result := TokenType.ToString() + " (" + Value + ")";
end;


end.
