// Marcelo Melo
// 10/11/2023

using System.Collections;
using System.IO;
using System.Text;

namespace CSharpToObjectPascal
{
	public class ObjectPascalTokenizer
	{
		public enum Directives
		{
			pdOverride,
			pdVirtual,
			pdDynamic,
			pdMessage,
			pdAbstract,
			pdCdecl,
			pdStdcall,
			pdSafecall,
			pdExport,
			pdDispid,
			pdFar,
			pdNear,
			pdPascal,
			pdForward,
			pdAssembler,
			pdExternal,
			pdInline,
			pdRegister,
			pdOverload,
			pdReintroduce,
			pdDeprecated,
			pdPlatform,
			pdLibrary,
			pdNone
		}

		private enum CharClass
		{
			CharEnd,
			CharWhite,
			CharToken,
			CharNumeric,
			CharStr,
			CharLParen,
			CharIdent,
			CharIllegal,
			CharLBrace,
			CharFSlash,
			CharDot
		}

		public const char tkIdent = '\u0001';

		public const char tkIllegal = '\u0002';

		public const char tkLiteral = '\u0003';

		public const char tkSymbol = '\u0004';

		public const char tkArray = '\u0005';

		public const char tkOf = '\u0006';

		public const char tkProcedure = '\a';

		public const char tkFunction = '\b';

		public const char tkPrivate = '\t';

		public const char tkProtected = '\u0010';

		public const char tkPublic = '\u0011';

		public const char tkPublished = '\u0012';

		public const char tkEnd = '\u0013';

		public const char tkVar = '\u0014';

		public const char tkConst = '\u0015';

		public const char tkString = '\u0016';

		public const char tkFile = '\u0017';

		public const char tkComment = '\u0018';

		public const char tkStrConst = '\u0019';

		public const char tkBegin = ' ';

		public const char tkConstructor = 'Ĩ';

		public const char tkDestructor = 'ĩ';

		public const char tkType = 'İ';

		public const char tkInitialization = 'ı';

		public const char tkRecord = 'Ĳ';

		public const char tkRepeat = 'ĳ';

		public const char tkThreadVar = 'Ĵ';

		public const char tkCase = 'ĵ';

		public const char tkTry = 'Ķ';

		public const char tkInherited = 'ķ';

		public const char tkImplementation = 'ĸ';

		public const char tkClass = 'Ĺ';

		public const char tkProperty = 'ŀ';

		public const char tkAutomated = 'Ł';

		public const char tkSet = 'ł';

		public const char tkInterface = 'Ń';

		public const char tkUntil = 'ń';

		public const char tkUses = 'Ņ';

		public const char tkObject = 'ņ';

		public const char tkDispinterface = 'Ň';

		public const char tkPacked = 'ň';

		public const char tkResourceString = 'ŉ';

		public const char tkDotDot = 'Ő';

		public const char tkAsm = 'ő';

		public const char tkLabel = 'Œ';

		public const char tkExports = 'œ';

		public const char tkIn = 'Ŕ';

		public const char tkFinalization = 'ŕ';

		public const char tkStrict = 'Ŗ';

		private const CharClass Z = CharClass.CharEnd;

		private const CharClass W = CharClass.CharWhite;

		private const CharClass T = CharClass.CharToken;

		private const CharClass N = CharClass.CharNumeric;

		private const CharClass S = CharClass.CharStr;

		private const CharClass P = CharClass.CharLParen;

		private const CharClass I = CharClass.CharIdent;

		private const CharClass E = CharClass.CharIllegal;

		private const CharClass B = CharClass.CharLBrace;

		private const CharClass C = CharClass.CharFSlash;

		private const CharClass D = CharClass.CharDot;

		private char[] buffer;

		private int pos;

		private int tokenStart;

		private int tokenEnd;

		private char token = '\u0002';

		private TextWriter output;

		private static Hashtable keywords;

		private static Hashtable directives;

		private CharClass[] CharClasses = new CharClass[256]
		{
			CharClass.CharEnd,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharWhite,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharStr,
			CharClass.CharLParen,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharDot,
			CharClass.CharFSlash,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharNumeric,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharIllegal,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharToken,
			CharClass.CharIllegal,
			CharClass.CharToken,
			CharClass.CharToken,
			CharClass.CharIdent,
			CharClass.CharIllegal,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharIdent,
			CharClass.CharLBrace,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal,
			CharClass.CharIllegal
		};

		public char Token => token;

		public char TokenSymbol
		{
			get
			{
				if (token == '\u0001')
				{
					object obj = keywords[TokenIdent.ToUpper()];
					if (obj != null)
					{
						token = (char)obj;
					}
				}
				return token;
			}
		}

		public string TokenIdent
		{
			get
			{
				StringBuilder stringBuilder = new StringBuilder();
				stringBuilder.Append(buffer, tokenStart, tokenEnd - tokenStart);
				return stringBuilder.ToString();
			}
		}

		public int TokenStart => tokenStart;

		public int TokenEnd => tokenEnd;

		public int TokenLength => tokenEnd - tokenStart;

		public Directives Directive
		{
			get
			{
				if (Token == '\u0001')
				{
					return DirectiveOf(TokenIdent);
				}
				return Directives.pdNone;
			}
		}

		static ObjectPascalTokenizer()
		{
			keywords = new Hashtable(75);
			keywords["AND"] = '\u0004';
			keywords["ARRAY"] = '\u0005';
			keywords["AS"] = '\u0004';
			keywords["ASM"] = 'ő';
			keywords["AUTOMATED"] = 'Ł';
			keywords["BEGIN"] = ' ';
			keywords["CASE"] = 'ĵ';
			keywords["CLASS"] = 'Ĺ';
			keywords["CONST"] = '\u0015';
			keywords["CONSTRUCTOR"] = 'Ĩ';
			keywords["DESTRUCTOR"] = 'ĩ';
			keywords["DISPINTERFACE"] = 'Ň';
			keywords["DIV"] = '\u0004';
			keywords["DO"] = '\u0004';
			keywords["DOWNTO"] = '\u0004';
			keywords["ELSE"] = '\u0004';
			keywords["END"] = '\u0013';
			keywords["EXCEPT"] = '\u0004';
			keywords["EXPORTS"] = 'œ';
			keywords["FILE"] = '\u0017';
			keywords["FINALIZATION"] = 'ŕ';
			keywords["FINALLY"] = '\u0004';
			keywords["FOR"] = '\u0004';
			keywords["FUNCTION"] = '\b';
			keywords["GOTO"] = '\u0004';
			keywords["IF"] = '\u0004';
			keywords["IMPLEMENTATION"] = '\u0004';
			keywords["IN"] = 'Ŕ';
			keywords["INHERITED"] = '\u0004';
			keywords["INITIALIZATION"] = 'ı';
			keywords["INLINE"] = '\u0004';
			keywords["INTERFACE"] = 'Ń';
			keywords["IS"] = '\u0004';
			keywords["LABEL"] = 'Œ';
			keywords["LIBRARY"] = '\u0004';
			keywords["MOD"] = '\u0004';
			keywords["NIL"] = '\u0004';
			keywords["NOT"] = '\u0004';
			keywords["OBJECT"] = 'ņ';
			keywords["OF"] = '\u0006';
			keywords["ON"] = '\u0004';
			keywords["OR"] = '\u0004';
			keywords["PACKED"] = 'ň';
			keywords["PRIVATE"] = '\t';
			keywords["PROTECTED"] = '\u0010';
			keywords["PROCEDURE"] = '\a';
			keywords["PROGRAM"] = '\u0004';
			keywords["PROPERTY"] = 'ŀ';
			keywords["PUBLIC"] = '\u0011';
			keywords["PUBLISHED"] = '\u0012';
			keywords["RAISE"] = '\u0004';
			keywords["RECORD"] = 'Ĳ';
			keywords["RESOURCESTRING"] = 'ŉ';
			keywords["REPEAT"] = 'ĳ';
			keywords["SET"] = 'ł';
			keywords["SHL"] = '\u0004';
			keywords["SHR"] = '\u0004';
			keywords["STRING"] = '\u0016';
			keywords["STRICT"] = 'Ŗ';
			keywords["THEN"] = '\u0004';
			keywords["THREADVAR"] = 'Ĵ';
			keywords["TO"] = '\u0004';
			keywords["TRY"] = 'Ķ';
			keywords["TYPE"] = 'İ';
			keywords["UNIT"] = '\u0004';
			keywords["UNTIL"] = 'ń';
			keywords["USES"] = 'Ņ';
			keywords["VAR"] = '\u0014';
			keywords["WHILE"] = '\u0004';
			keywords["WITH"] = '\u0004';
			keywords["XOR"] = '\u0004';
			directives = new Hashtable(23);
			directives["OVERRIDE"] = Directives.pdOverride;
			directives["VIRTUAL"] = Directives.pdVirtual;
			directives["DYNAMIC"] = Directives.pdDynamic;
			directives["MESSAGE"] = Directives.pdMessage;
			directives["ABSTRACT"] = Directives.pdAbstract;
			directives["CDECL"] = Directives.pdCdecl;
			directives["STDCALL"] = Directives.pdStdcall;
			directives["SAFECALL"] = Directives.pdSafecall;
			directives["EXPORT"] = Directives.pdExport;
			directives["DISPID"] = Directives.pdDispid;
			directives["FAR"] = Directives.pdFar;
			directives["NEAR"] = Directives.pdNear;
			directives["PASCAL"] = Directives.pdPascal;
			directives["FORWARD"] = Directives.pdForward;
			directives["ASSEMBLER"] = Directives.pdAssembler;
			directives["EXTERNAL"] = Directives.pdExternal;
			directives["INLINE"] = Directives.pdInline;
			directives["REGISTER"] = Directives.pdRegister;
			directives["OVERLOAD"] = Directives.pdOverload;
			directives["REINTRODUCE"] = Directives.pdReintroduce;
			directives["DEPRECATED"] = Directives.pdDeprecated;
			directives["PLATFORM"] = Directives.pdPlatform;
			directives["LIBRARY"] = Directives.pdLibrary;
		}

		public ObjectPascalTokenizer(string text)
			: this(text, null)
		{
		}

		public ObjectPascalTokenizer(string text, TextWriter output)
		{
			this.output = output;
			buffer = new char[text.Length + 1];
			for (int i = 0; i < text.Length; i++)
			{
				buffer[i] = text[i];
			}
			buffer[text.Length] = '\0';
		}

		public ObjectPascalTokenizer(char[] Buffer)
		{
			buffer = Buffer;
		}

		private CharClass CharClassOf(char ch)
		{
			if (ch > CharClasses.Length - 1)
			{
				return CharClass.CharIllegal;
			}
			return CharClasses[(uint)ch];
		}

		public string GetText(int start, int end)
		{
			StringBuilder stringBuilder = new StringBuilder();
			if (end >= buffer.Length)
			{
				end = buffer.Length - 1;
			}
			stringBuilder.Append(buffer, start, end - start);
			return stringBuilder.ToString();
		}

		public char NextSymbol()
		{
			NextToken();
			return TokenSymbol;
		}

		public char NextToken()
		{
			int num = pos;
			while (true)
			{
				tokenStart = num;
				switch (CharClassOf(buffer[num]))
				{
				default:
					continue;
				case CharClass.CharWhite:
					num++;
					continue;
				case CharClass.CharToken:
					token = buffer[num++];
					break;
				case CharClass.CharNumeric:
				{
					tokenStart = num;
					CharClass charClass;
					do
					{
						charClass = CharClassOf(buffer[++num]);
					}
					while (charClass == CharClass.CharNumeric);
					if (charClass == CharClass.CharDot)
					{
						do
						{
							charClass = CharClassOf(buffer[++num]);
						}
						while (charClass == CharClass.CharNumeric);
						char c = buffer[num];
						if (c == 'e' || c == 'E')
						{
							do
							{
								charClass = CharClassOf(buffer[++num]);
							}
							while (charClass == CharClass.CharNumeric);
						}
					}
					token = '\u0003';
					break;
				}
				case CharClass.CharStr:
					tokenStart = num;
					while (true)
					{
						char c = buffer[++num];
						if (c == '\'' || c == '\0')
						{
							c = buffer[num + 1];
							if (c != '\'')
							{
								break;
							}
							num++;
						}
					}
					num++;
					token = '\u0019';
					break;
				case CharClass.CharLParen:
				{
					char c = buffer[++num];
					if (c == '*')
					{
						do
						{
							c = buffer[++num];
						}
						while ((c != '*' && c != 0) || c != '*' || buffer[num + 1] != ')');
						num += 2;
						continue;
					}
					token = '(';
					break;
				}
				case CharClass.CharIllegal:
					num++;
					token = '\u0002';
					break;
				case CharClass.CharLBrace:
				{
					if (output != null)
					{
						output.Write("{");
					}
					char c;
					do
					{
						c = buffer[++num];
						if (output != null)
						{
							output.Write(c);
						}
					}
					while (c != '}' && c != 0);
					continue;
				}
				case CharClass.CharIdent:
				{
					tokenStart = num;
					CharClass charClass;
					do
					{
						charClass = CharClassOf(buffer[++num]);
					}
					while (charClass == CharClass.CharIdent || charClass == CharClass.CharNumeric);
					token = '\u0001';
					break;
				}
				case CharClass.CharFSlash:
					if (buffer[++num] == '/')
					{
						char c;
						do
						{
							c = buffer[++num];
						}
						while (c != '\n' && c != 0);
						if (c != 0)
						{
							num++;
						}
						continue;
					}
					token = '/';
					break;
				case CharClass.CharDot:
					if (buffer[++num] == '.')
					{
						num++;
						token = 'Ő';
					}
					else
					{
						token = '.';
					}
					break;
				case CharClass.CharEnd:
					token = '\u0013';
					break;
				}
				break;
			}
			tokenEnd = num;
			pos = num;
			return token;
		}

		public string TokenName(char token)
		{
			if (token <= ' ' || token >= 'Ĩ')
			{
				return token switch
				{
					'\u0001' => "<ident \"" + TokenIdent + "\">", 
					'\u0002' => "<illegal char '" + token + "'>", 
					'\u0005' => "ARRAY", 
					'ő' => "ASM", 
					'Ł' => "AUTOMATED", 
					' ' => "BEGIN", 
					'ĵ' => "CASE", 
					'Ĺ' => "CLASS", 
					'\u0015' => "CONST", 
					'Ĩ' => "CONSTRUCTOR", 
					'ĩ' => "DESTRUCTOR", 
					'Ň' => "DISPINTERFACE", 
					'\u0013' => "END", 
					'œ' => "EXPORTS", 
					'\u0017' => "FILE", 
					'ŕ' => "FINALIZATION", 
					'\b' => "FUNCTION", 
					'Ŕ' => "IN", 
					'ı' => "INITIALIZATION", 
					'Ń' => "INTERFACE", 
					'Œ' => "LABEL", 
					'ņ' => "OBJECT", 
					'\u0006' => "OF", 
					'ň' => "PACKED", 
					'\t' => "PRIVATE", 
					'\u0010' => "PROTECTED", 
					'\a' => "PROCEDURE", 
					'ŀ' => "PROPERTY", 
					'\u0011' => "PUBLIC", 
					'\u0012' => "PUBLISHED", 
					'Ĳ' => "RECORD", 
					'ŉ' => "RESOURCESTRING", 
					'ĳ' => "REPEAT", 
					'ł' => "SET", 
					'\u0016' => "STRING", 
					'Ĵ' => "THREADVAR", 
					'Ķ' => "TRY", 
					'İ' => "TYPE", 
					'ń' => "UNTIL", 
					'Ņ' => "USES", 
					'\u0014' => "VAR", 
					_ => "<symbol (" + (int)token + ") \"" + TokenIdent + "\">", 
				};
			}
			return token.ToString();
		}

		public string TokenName()
		{
			return TokenName(token);
		}

		public static bool IsKeyword(string value)
		{
			return keywords.ContainsKey(value.ToUpper());
		}

		public Directives DirectiveOf(string value)
		{
			object obj = directives[value.ToUpper()];
			if (obj != null)
			{
				return (Directives)obj;
			}
			return Directives.pdNone;
		}

		public void SkipTo(char token)
		{
			while (Token != token)
			{
				NextSymbol();
				if (Token == token)
				{
					break;
				}
				switch (Token)
				{
				case '(':
					SkipTo(')');
					NextSymbol();
					break;
				case ' ':
					SkipTo('\u0013');
					NextSymbol();
					break;
				case 'ĵ':
					SkipTo('\u0013');
					NextSymbol();
					break;
				case 'ĳ':
					SkipTo('ń');
					SkipTo(';');
					break;
				case 'Ķ':
					SkipTo('\u0013');
					NextSymbol();
					break;
				case '\u0013':
					return;
				}
			}
		}
	}
}
