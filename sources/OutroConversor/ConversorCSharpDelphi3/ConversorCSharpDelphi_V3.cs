using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.Build.Locator;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.MSBuild;

namespace ConversorCSharpParaDelphi
{
    /// <summary>
    /// Conversor C# → Delphi - VERSÃO 3.0
    /// Correções: Interfaces, Operador Ternário, throw→raise, Constantes
    /// </summary>
    public class ConversorSolucao
    {
        private readonly string _caminhoSolucao;
        private readonly string _diretorioSaida;
        private readonly OpcoesConversao _opcoes;

        public ConversorSolucao(string caminhoSolucao, string diretorioSaida, OpcoesConversao opcoes = null)
        {
            _caminhoSolucao = caminhoSolucao;
            _diretorioSaida = diretorioSaida;
            _opcoes = opcoes ?? new OpcoesConversao();
        }

        public async Task ConverterAsync()
        {
            Console.WriteLine("╔═══════════════════════════════════════════════════════════╗");
            Console.WriteLine("║    Conversor C# → Delphi - VERSÃO 3.0 (V3)              ║");
            Console.WriteLine("╚═══════════════════════════════════════════════════════════╝");
            Console.WriteLine();

            if (!MSBuildLocator.IsRegistered)
            {
                var instancia = MSBuildLocator.QueryVisualStudioInstances()
                    .OrderByDescending(i => i.Version)
                    .FirstOrDefault();

                if (instancia == null)
                    throw new Exception("MSBuild não encontrado!");

                MSBuildLocator.RegisterInstance(instancia);
                Console.WriteLine($"✓ MSBuild {instancia.Version}");
            }

            Console.WriteLine($"Solução: {_caminhoSolucao}");
            Console.WriteLine($"Saída: {_diretorioSaida}");
            Console.WriteLine();

            var workspace = MSBuildWorkspace.Create();
            var solucao = await workspace.OpenSolutionAsync(_caminhoSolucao);

            Console.WriteLine($"Projetos: {solucao.Projects.Count()}");
            Console.WriteLine();

            foreach (var projeto in solucao.Projects)
            {
                await ConverterProjetoAsync(projeto);
            }

            Console.WriteLine();
            Console.WriteLine("✓ Conversão concluída!");
        }

        private async Task ConverterProjetoAsync(Project projeto)
        {
            Console.WriteLine($"┌─ Convertendo projeto: {projeto.Name}");

            var compilacao = await projeto.GetCompilationAsync();
            if (compilacao == null)
            {
                Console.WriteLine("│  ⚠ Erro ao compilar projeto");
                Console.WriteLine("└─");
                return;
            }

            foreach (var documento in projeto.Documents)
            {
                if (DeveIgnorarDocumento(documento))
                    continue;

                await ConverterDocumentoAsync(documento, compilacao, projeto.Name);
            }

            Console.WriteLine("└─");
            Console.WriteLine();
        }

        private bool DeveIgnorarDocumento(Document documento)
        {
            return documento.Name.EndsWith(".Designer.cs") ||
                   documento.Name.EndsWith(".g.cs") ||
                   documento.Name.EndsWith(".g.i.cs") ||
                   documento.Name == "AssemblyInfo.cs" ||
                   documento.Folders.Any(f => f == "obj" || f == "bin");
        }

        private async Task ConverterDocumentoAsync(Document documento, Compilation compilacao, string nomeProjeto)
        {
            Console.WriteLine($"│  → {documento.Name}");

            var arvore = await documento.GetSyntaxTreeAsync();
            var raiz = await arvore.GetRootAsync();
            var modelo = compilacao.GetSemanticModel(arvore);

            var conversor = new ConversorCSharpDelphi(modelo, _opcoes);
            conversor.Visit(raiz);

            var codigoDelphi = conversor.ObterCodigoDelphi();

            if (string.IsNullOrWhiteSpace(codigoDelphi))
            {
                Console.WriteLine("│     (sem conteúdo para converter)");
                return;
            }

            var nomeArquivo = Path.GetFileNameWithoutExtension(documento.Name);
            var caminhoSaida = Path.Combine(_diretorioSaida, nomeProjeto, $"{nomeArquivo}.pas");
            
            Directory.CreateDirectory(Path.GetDirectoryName(caminhoSaida));
            File.WriteAllText(caminhoSaida, codigoDelphi);

            Console.WriteLine($"│     ✓ Salvo: {nomeArquivo}.pas");
        }
    }

    /// <summary>
    /// Conversor C# → Delphi - VERSÃO 3.0
    /// </summary>
    public class ConversorCSharpDelphi : CSharpSyntaxWalker
    {
        private readonly SemanticModel _modelo;
        private readonly OpcoesConversao _opcoes;
        
        private StringBuilder _interface = new StringBuilder();
        private StringBuilder _implementation = new StringBuilder();
        private HashSet<string> _usings = new HashSet<string>();
        
        private string _classeAtual = null;
        private string _interfaceAtual = null;
        private string _namespaceAtual = "UnitName";
        private int _indentacao = 0;

        public ConversorCSharpDelphi(SemanticModel modelo, OpcoesConversao opcoes)
        {
            _modelo = modelo;
            _opcoes = opcoes;
        }

        public string ObterCodigoDelphi()
        {
            if (_interface.Length == 0)
                return string.Empty;

            var sb = new StringBuilder();
            
            sb.AppendLine($"unit {_namespaceAtual};");
            sb.AppendLine();
            sb.AppendLine("interface");
            sb.AppendLine();
            
            if (_usings.Any())
            {
                sb.AppendLine("uses");
                sb.AppendLine("  " + string.Join(", ", _usings.OrderBy(u => u)) + ";");
                sb.AppendLine();
            }
            
            sb.Append(_interface);
            sb.AppendLine();
            sb.AppendLine("implementation");
            sb.AppendLine();
            sb.Append(_implementation);
            sb.AppendLine();
            sb.AppendLine("end.");
            
            return sb.ToString();
        }

        // ═══════════════════════════════════════════════════════════════
        // NAMESPACE
        // ═══════════════════════════════════════════════════════════════

        public override void VisitNamespaceDeclaration(NamespaceDeclarationSyntax node)
        {
            _namespaceAtual = node.Name.ToString();
            base.VisitNamespaceDeclaration(node);
        }

        public override void VisitFileScopedNamespaceDeclaration(FileScopedNamespaceDeclarationSyntax node)
        {
            _namespaceAtual = node.Name.ToString();
            base.VisitFileScopedNamespaceDeclaration(node);
        }

        // ═══════════════════════════════════════════════════════════════
        // INTERFACES (CORREÇÃO CRÍTICA!)
        // ═══════════════════════════════════════════════════════════════

        public override void VisitInterfaceDeclaration(InterfaceDeclarationSyntax node)
        {
            var nomeInterface = node.Identifier.Text;
            
            // Interface já começa com I, não adiciona T!
            if (!nomeInterface.StartsWith("I"))
                nomeInterface = "I" + nomeInterface;

            _interfaceAtual = nomeInterface;

            // XMLDOC
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }

            // Declaração da interface
            _interface.AppendLine($"type");
            _interface.Append($"  {nomeInterface} = interface");

            // Herança (interfaces podem herdar de outras)
            if (node.BaseList != null && node.BaseList.Types.Any())
            {
                var basesFormatadas = node.BaseList.Types.Select(t =>
                {
                    var nomeBase = t.Type.ToString();
                    // Interface herda de interface - mantém I
                    if (!nomeBase.StartsWith("I"))
                        nomeBase = "I" + nomeBase;
                    return nomeBase;
                });
                
                _interface.Append($"({string.Join(", ", basesFormatadas)})");
            }

            _interface.AppendLine();

            // GUID (opcional, mas recomendado)
            _interface.AppendLine("    ['{00000000-0000-0000-0000-000000000000}']");

            // Processa membros da interface
            foreach (var membro in node.Members)
            {
                if (membro is PropertyDeclarationSyntax propriedade)
                {
                    VisitInterfaceProperty(propriedade);
                }
                else if (membro is MethodDeclarationSyntax metodo)
                {
                    VisitInterfaceMethod(metodo);
                }
            }

            _interface.AppendLine("  end;");
            _interface.AppendLine();

            _interfaceAtual = null;
        }

        private void VisitInterfaceProperty(PropertyDeclarationSyntax node)
        {
            var nome = node.Identifier.Text;
            var tipoDelphi = ConverterTipo(node.Type);
            
            // XMLDOC
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }
            
            // Propriedade em interface
            _interface.AppendLine($"    property {nome}: {tipoDelphi} read Get{nome} write Set{nome};");
        }

        private void VisitInterfaceMethod(MethodDeclarationSyntax node)
        {
            var nome = node.Identifier.Text;
            var parametros = ConverterParametros(node.ParameterList);
            var tipoRetorno = ConverterTipo(node.ReturnType);
            
            var ehFunction = tipoRetorno != "void";
            var tipoMetodo = ehFunction ? "function" : "procedure";

            // XMLDOC
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }

            if (ehFunction)
            {
                _interface.AppendLine($"    {tipoMetodo} {nome}({parametros}): {tipoRetorno};");
            }
            else
            {
                _interface.AppendLine($"    {tipoMetodo} {nome}({parametros});");
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // CLASSES
        // ═══════════════════════════════════════════════════════════════

        public override void VisitClassDeclaration(ClassDeclarationSyntax node)
        {
            var nomeClasse = node.Identifier.Text;
            
            if (!nomeClasse.StartsWith("T"))
                nomeClasse = "T" + nomeClasse;

            _classeAtual = nomeClasse;

            _usings.Add("System.SysUtils");
            _usings.Add("System.Classes");

            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }

            _interface.AppendLine($"type");
            _interface.Append($"  {nomeClasse} = class");

            if (node.BaseList != null && node.BaseList.Types.Any())
            {
                var tipoBase = node.BaseList.Types.First();
                var nomeBase = tipoBase.Type.ToString();
                
                // Se é interface, mantém I, senão adiciona T
                if (!nomeBase.StartsWith("T") && !nomeBase.StartsWith("I"))
                    nomeBase = "T" + nomeBase;
                    
                _interface.Append($"({nomeBase})");
            }
            else if (_opcoes.UsarTObjectPorPadrao)
            {
                _interface.Append("(TObject)");
            }

            _interface.AppendLine();

            _indentacao = 2;

            var campos = node.Members.OfType<FieldDeclarationSyntax>().ToList();
            var constantes = campos.Where(c => c.Modifiers.Any(m => m.IsKind(SyntaxKind.ConstKeyword))).ToList();
            var camposNormais = campos.Except(constantes).ToList();
            var propriedades = node.Members.OfType<PropertyDeclarationSyntax>().ToList();
            var construtores = node.Members.OfType<ConstructorDeclarationSyntax>().ToList();
            var metodos = node.Members.OfType<MethodDeclarationSyntax>().ToList();

            // Seção private (campos)
            if (camposNormais.Any(c => EhPrivado(c.Modifiers)))
            {
                _interface.AppendLine("  private");
                foreach (var campo in camposNormais.Where(c => EhPrivado(c.Modifiers)))
                {
                    VisitFieldDeclaration(campo);
                }
            }

            // Seção public
            _interface.AppendLine("  public");

            // Constantes
            if (constantes.Any())
            {
                foreach (var constante in constantes)
                {
                    VisitConstantDeclaration(constante);
                }
            }

            // Construtores
            foreach (var construtor in construtores)
            {
                VisitConstructorDeclaration(construtor);
            }

            // Destrutor
            if (_opcoes.GerarDestrutor)
            {
                _interface.AppendLine($"    destructor Destroy; override;");
            }

            // Métodos
            foreach (var metodo in metodos)
            {
                VisitMethodDeclaration(metodo);
            }

            // Propriedades
            foreach (var propriedade in propriedades)
            {
                VisitPropertyDeclaration(propriedade);
            }

            _interface.AppendLine("  end;");
            _interface.AppendLine();

            _indentacao = 0;
            _classeAtual = null;
        }

        // ═══════════════════════════════════════════════════════════════
        // CONSTANTES (CORREÇÃO!)
        // ═══════════════════════════════════════════════════════════════

        private void VisitConstantDeclaration(FieldDeclarationSyntax node)
        {
            foreach (var variavel in node.Declaration.Variables)
            {
                var nome = variavel.Identifier.Text;
                var tipo = ConverterTipo(node.Declaration.Type);
                
                if (variavel.Initializer != null)
                {
                    var valor = ConverterExpressaoParaString(variavel.Initializer.Value);
                    _interface.AppendLine($"    const {nome}: {tipo} = {valor};");
                }
                else
                {
                    _interface.AppendLine($"    const {nome}: {tipo};");
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // COMENTÁRIOS XMLDOC
        // ═══════════════════════════════════════════════════════════════

        private string ExtrairComentariosXmlDoc(SyntaxTriviaList trivia)
        {
            var sb = new StringBuilder();
            
            foreach (var t in trivia)
            {
                if (t.IsKind(SyntaxKind.SingleLineDocumentationCommentTrivia))
                {
                    var textoCompleto = t.ToFullString();
                    var linhas = textoCompleto.Split('\n');
                    
                    foreach (var linha in linhas)
                    {
                        var limpa = linha.Trim();
                        if (limpa.StartsWith("///"))
                        {
                            limpa = limpa.Substring(3).Trim();
                            limpa = Regex.Replace(limpa, @"<summary>|</summary>", "");
                            limpa = Regex.Replace(limpa, @"<param[^>]*>|</param>", "");
                            limpa = Regex.Replace(limpa, @"<returns>|</returns>", "");
                            limpa = limpa.Trim();
                            
                            if (!string.IsNullOrEmpty(limpa))
                            {
                                sb.AppendLine($"  {{ {limpa} }}");
                            }
                        }
                    }
                }
            }
            
            return sb.ToString().TrimEnd();
        }

        // ═══════════════════════════════════════════════════════════════
        // CAMPOS
        // ═══════════════════════════════════════════════════════════════

        public override void VisitFieldDeclaration(FieldDeclarationSyntax node)
        {
            var tipoDelphi = ConverterTipo(node.Declaration.Type);

            foreach (var variavel in node.Declaration.Variables)
            {
                var nome = variavel.Identifier.Text;
                
                if (!nome.StartsWith("m_") && !nome.StartsWith("F"))
                {
                    nome = "m_" + nome;
                }

                _interface.AppendLine($"    {nome}: {tipoDelphi};");
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // PROPRIEDADES
        // ═══════════════════════════════════════════════════════════════

        public override void VisitPropertyDeclaration(PropertyDeclarationSyntax node)
        {
            var nome = node.Identifier.Text;
            var tipoDelphi = ConverterTipo(node.Type);
            
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }
            
            _interface.AppendLine($"    property {nome}: {tipoDelphi} read Get{nome} write Set{nome};");
        }

        // ═══════════════════════════════════════════════════════════════
        // CONSTRUTORES
        // ═══════════════════════════════════════════════════════════════

        public override void VisitConstructorDeclaration(ConstructorDeclarationSyntax node)
        {
            var parametros = ConverterParametros(node.ParameterList);
            
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }
            
            _interface.AppendLine($"    constructor Create({parametros});");

            _implementation.AppendLine($"constructor {_classeAtual}.Create({parametros});");
            _implementation.AppendLine("begin");
            
            var classe = node.Parent as ClassDeclarationSyntax;
            if (classe?.BaseList != null && classe.BaseList.Types.Any())
            {
                _implementation.AppendLine("  inherited Create;");
            }

            if (node.Body != null)
            {
                foreach (var statement in node.Body.Statements)
                {
                    ConverterStatement(statement, 1);
                }
            }

            _implementation.AppendLine("end;");
            _implementation.AppendLine();
        }

        // ═══════════════════════════════════════════════════════════════
        // MÉTODOS
        // ═══════════════════════════════════════════════════════════════

        public override void VisitMethodDeclaration(MethodDeclarationSyntax node)
        {
            var nome = node.Identifier.Text;
            var parametros = ConverterParametros(node.ParameterList);
            var tipoRetorno = ConverterTipo(node.ReturnType);
            
            var ehFunction = tipoRetorno != "void";
            var tipoMetodo = ehFunction ? "function" : "procedure";

            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }

            if (ehFunction)
            {
                _interface.AppendLine($"    {tipoMetodo} {nome}({parametros}): {tipoRetorno};");
            }
            else
            {
                _interface.AppendLine($"    {tipoMetodo} {nome}({parametros});");
            }

            if (ehFunction)
            {
                _implementation.AppendLine($"{tipoMetodo} {_classeAtual}.{nome}({parametros}): {tipoRetorno};");
            }
            else
            {
                _implementation.AppendLine($"{tipoMetodo} {_classeAtual}.{nome}({parametros});");
            }

            _implementation.AppendLine("begin");

            if (node.Body != null)
            {
                foreach (var statement in node.Body.Statements)
                {
                    ConverterStatement(statement, 1);
                }
            }

            _implementation.AppendLine("end;");
            _implementation.AppendLine();
        }

        // ═══════════════════════════════════════════════════════════════
        // CONVERSÃO DE TIPOS (CORREÇÃO: INTERFACES!)
        // ═══════════════════════════════════════════════════════════════

        private string ConverterTipo(TypeSyntax tipo)
        {
            var tipoString = tipo.ToString();

            var mapeamento = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["int"] = "Integer",
                ["long"] = "Int64",
                ["short"] = "SmallInt",
                ["byte"] = "Byte",
                ["bool"] = "Boolean",
                ["string"] = "String",
                ["double"] = "Double",
                ["float"] = "Single",
                ["decimal"] = "Currency",
                ["char"] = "Char",
                ["object"] = "TObject",
                ["void"] = "void",
                ["DateTime"] = "TDateTime",
                ["List"] = "TList",
            };

            if (tipo is NullableTypeSyntax nullable)
            {
                return ConverterTipo(nullable.ElementType);
            }

            if (mapeamento.TryGetValue(tipoString, out var tipoDelphi))
            {
                return tipoDelphi;
            }

            if (tipo is GenericNameSyntax generica)
            {
                var nomeBase = generica.Identifier.Text;
                var tiposGenericos = generica.TypeArgumentList.Arguments
                    .Select(t => ConverterTipo(t))
                    .ToList();

                if (nomeBase == "List")
                {
                    _usings.Add("System.Generics.Collections");
                    return $"TList<{string.Join(", ", tiposGenericos)}>";
                }
                else if (nomeBase == "Dictionary")
                {
                    _usings.Add("System.Generics.Collections");
                    return $"TDictionary<{string.Join(", ", tiposGenericos)}>";
                }
            }

            // CORREÇÃO CRÍTICA: Se começa com I e segunda letra é maiúscula = INTERFACE!
            if (tipoString.StartsWith("I") && tipoString.Length > 1 && char.IsUpper(tipoString[1]))
            {
                // É uma interface, mantém o nome como está!
                return tipoString;
            }

            // Senão, é uma classe, adiciona T
            if (!tipoString.StartsWith("T") && char.IsUpper(tipoString[0]))
            {
                return "T" + tipoString;
            }

            return tipoString;
        }

        // ═══════════════════════════════════════════════════════════════
        // CONVERSÃO DE PARÂMETROS
        // ═══════════════════════════════════════════════════════════════

        private string ConverterParametros(ParameterListSyntax parametros)
        {
            if (parametros == null || !parametros.Parameters.Any())
                return string.Empty;

            var lista = parametros.Parameters.Select(p =>
            {
                var nome = p.Identifier.Text;
                var tipo = ConverterTipo(p.Type);
                
                if (!nome.StartsWith("A") && !nome.StartsWith("a"))
                {
                    nome = "A" + char.ToUpper(nome[0]) + nome.Substring(1);
                }

                return $"{nome}: {tipo}";
            });

            return string.Join("; ", lista);
        }

        // ═══════════════════════════════════════════════════════════════
        // CONVERSÃO DE STATEMENTS
        // ═══════════════════════════════════════════════════════════════

        private void ConverterStatement(StatementSyntax statement, int indentLevel)
        {
            var indent = new string(' ', indentLevel * 2);

            switch (statement)
            {
                case ExpressionStatementSyntax expr:
                    ConverterExpression(expr.Expression, indentLevel);
                    break;

                case ReturnStatementSyntax ret:
                    if (ret.Expression != null)
                    {
                        var expressaoConvertida = ConverterExpressaoParaString(ret.Expression);
                        _implementation.AppendLine($"{indent}Result := {expressaoConvertida};");
                    }
                    else
                    {
                        _implementation.AppendLine($"{indent}Exit;");
                    }
                    break;

                case ThrowStatementSyntax throwStat:
                    ConverterThrow(throwStat, indentLevel);
                    break;

                case LocalDeclarationStatementSyntax local:
                    ConverterDeclaracaoLocal(local, indentLevel);
                    break;

                case IfStatementSyntax ifStat:
                    ConverterIf(ifStat, indentLevel);
                    break;

                case ForEachStatementSyntax forEach:
                    ConverterForEach(forEach, indentLevel);
                    break;

                default:
                    _implementation.AppendLine($"{indent}// TODO: Converter {statement.GetType().Name}");
                    break;
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // THROW → RAISE (CORREÇÃO!)
        // ═══════════════════════════════════════════════════════════════

        private void ConverterThrow(ThrowStatementSyntax throwStat, int indentLevel)
        {
            var indent = new string(' ', indentLevel * 2);
            
            if (throwStat.Expression != null)
            {
                var excecao = ConverterExpressaoParaString(throwStat.Expression);
                _implementation.AppendLine($"{indent}raise {excecao};");
            }
            else
            {
                // throw; sem expressão = re-raise
                _implementation.AppendLine($"{indent}raise;");
            }
        }

        private void ConverterExpression(ExpressionSyntax expr, int indentLevel)
        {
            var indent = new string(' ', indentLevel * 2);

            switch (expr)
            {
                case AssignmentExpressionSyntax assign:
                    var esquerda = ConverterExpressaoParaString(assign.Left);
                    var direita = ConverterExpressaoParaString(assign.Right);
                    _implementation.AppendLine($"{indent}{esquerda} := {direita};");
                    break;

                case InvocationExpressionSyntax invocacao:
                    var chamada = ConverterExpressaoParaString(invocacao);
                    _implementation.AppendLine($"{indent}{chamada};");
                    break;

                default:
                    var texto = ConverterExpressaoParaString(expr);
                    _implementation.AppendLine($"{indent}{texto};");
                    break;
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // CONVERSÃO DE EXPRESSÕES (COM OPERADOR TERNÁRIO!)
        // ═══════════════════════════════════════════════════════════════

        private string ConverterExpressaoParaString(ExpressionSyntax expr)
        {
            // CORREÇÃO: Operador Ternário primeiro!
            if (expr is ConditionalExpressionSyntax ternario)
            {
                return ConverterOperadorTernario(ternario);
            }

            var texto = expr.ToString();

            // 1. this → Self
            texto = Regex.Replace(texto, @"\bthis\.", "Self.", RegexOptions.IgnoreCase);

            // 2. new List<Type>() → TList<TType>.Create
            texto = Regex.Replace(texto, @"new\s+List<(\w+)>\(\)", m =>
            {
                var tipo = m.Groups[1].Value;
                if (!tipo.StartsWith("T") && !tipo.StartsWith("I"))
                    tipo = "T" + tipo;
                return $"TList<{tipo}>.Create";
            });

            // 3. new Dictionary<K,V>() → TDictionary<TK,TV>.Create
            texto = Regex.Replace(texto, @"new\s+Dictionary<(\w+),\s*(\w+)>\(\)", m =>
            {
                var tipo1 = m.Groups[1].Value;
                var tipo2 = m.Groups[2].Value;
                if (!tipo1.StartsWith("T") && !tipo1.StartsWith("I") && char.IsUpper(tipo1[0]))
                    tipo1 = "T" + tipo1;
                if (!tipo2.StartsWith("T") && !tipo2.StartsWith("I") && char.IsUpper(tipo2[0]))
                    tipo2 = "T" + tipo2;
                return $"TDictionary<{tipo1},{tipo2}>.Create";
            });

            // 4. new ClassName() → TClassName.Create()
            texto = Regex.Replace(texto, @"new\s+(\w+)\s*\(", m =>
            {
                var tipo = m.Groups[1].Value;
                if (!tipo.StartsWith("T") && !tipo.StartsWith("I"))
                    tipo = "T" + tipo;
                return $"{tipo}.Create(";
            });

            // 5. throw new → raise
            texto = Regex.Replace(texto, @"throw\s+new\s+", "raise ", RegexOptions.IgnoreCase);

            // 6. Operador %
            texto = Regex.Replace(texto, @"(\w+)\s*%\s*(\w+)", "$1 mod $2");

            // 7. Operador ==
            texto = texto.Replace("==", "=");

            // 8. Operador !=
            texto = texto.Replace("!=", "<>");

            // 9. Operador &&
            texto = texto.Replace("&&", "and");

            // 10. Operador ||
            texto = texto.Replace("||", "or");

            // 11. Operador !
            texto = Regex.Replace(texto, @"!(\w+)", "not $1");

            // 12. DateTime.Now
            texto = texto.Replace("DateTime.Now", "Now");

            // 13. Console.WriteLine
            texto = Regex.Replace(texto, @"Console\.WriteLine", "WriteLn");

            // 14. String interpolation
            if (texto.Contains("$\""))
            {
                texto = texto.Replace("$\"", "\"");
            }

            return texto;
        }

        // ═══════════════════════════════════════════════════════════════
        // OPERADOR TERNÁRIO (CORREÇÃO!)
        // ═══════════════════════════════════════════════════════════════

        private string ConverterOperadorTernario(ConditionalExpressionSyntax ternario)
        {
            var condicao = ConverterExpressaoParaString(ternario.Condition);
            var seVerdadeiro = ConverterExpressaoParaString(ternario.WhenTrue);
            var seFalso = ConverterExpressaoParaString(ternario.WhenFalse);

            // Delphi: if condition then value1 else value2
            // Ou usa função IfThen do SysUtils
            _usings.Add("System.SysUtils");
            
            // Retorna inline usando if/then/else
            return $"(if {condicao} then {seVerdadeiro} else {seFalso})";
        }

        private void ConverterDeclaracaoLocal(LocalDeclarationStatementSyntax local, int indentLevel)
        {
            var indent = new string(' ', indentLevel * 2);
            var tipo = ConverterTipo(local.Declaration.Type);

            foreach (var variavel in local.Declaration.Variables)
            {
                var nome = variavel.Identifier.Text;
                _implementation.Append($"{indent}{nome}: {tipo}");

                if (variavel.Initializer != null)
                {
                    var valorInicial = ConverterExpressaoParaString(variavel.Initializer.Value);
                    _implementation.Append($" := {valorInicial}");
                }

                _implementation.AppendLine(";");
            }
        }

        private void ConverterIf(IfStatementSyntax ifStat, int indentLevel)
        {
            var indent = new string(' ', indentLevel * 2);
            var condicao = ConverterExpressaoParaString(ifStat.Condition);
            
            _implementation.AppendLine($"{indent}if {condicao} then");
            _implementation.AppendLine($"{indent}begin");

            if (ifStat.Statement is BlockSyntax block)
            {
                foreach (var stmt in block.Statements)
                {
                    ConverterStatement(stmt, indentLevel + 1);
                }
            }
            else
            {
                ConverterStatement(ifStat.Statement, indentLevel + 1);
            }

            _implementation.AppendLine($"{indent}end");

            if (ifStat.Else != null)
            {
                _implementation.AppendLine($"{indent}else");
                _implementation.AppendLine($"{indent}begin");

                if (ifStat.Else.Statement is BlockSyntax elseBlock)
                {
                    foreach (var stmt in elseBlock.Statements)
                    {
                        ConverterStatement(stmt, indentLevel + 1);
                    }
                }
                else
                {
                    ConverterStatement(ifStat.Else.Statement, indentLevel + 1);
                }

                _implementation.AppendLine($"{indent}end;");
            }
            else
            {
                _implementation.AppendLine($"{indent};");
            }
        }

        private void ConverterForEach(ForEachStatementSyntax forEach, int indentLevel)
        {
            var indent = new string(' ', indentLevel * 2);
            var variavel = forEach.Identifier.Text;
            var colecao = ConverterExpressaoParaString(forEach.Expression);

            _implementation.AppendLine($"{indent}for {variavel} in {colecao} do");
            _implementation.AppendLine($"{indent}begin");

            if (forEach.Statement is BlockSyntax block)
            {
                foreach (var stmt in block.Statements)
                {
                    ConverterStatement(stmt, indentLevel + 1);
                }
            }

            _implementation.AppendLine($"{indent}end;");
        }

        // ═══════════════════════════════════════════════════════════════
        // UTILITÁRIOS
        // ═══════════════════════════════════════════════════════════════

        private bool EhPrivado(SyntaxTokenList modifiers)
        {
            return modifiers.Any(m => m.IsKind(SyntaxKind.PrivateKeyword)) ||
                   !modifiers.Any(m => 
                       m.IsKind(SyntaxKind.PublicKeyword) ||
                       m.IsKind(SyntaxKind.ProtectedKeyword) ||
                       m.IsKind(SyntaxKind.InternalKeyword));
        }
    }

    public class OpcoesConversao
    {
        public bool UsarTObjectPorPadrao { get; set; } = true;
        public bool GerarDestrutor { get; set; } = false;
        public bool UsarPrefixoACampos { get; set; } = true;
        public string PrefixoCampos { get; set; } = "m_";
    }

    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("Conversor C# → Delphi - VERSÃO 3.0");
            Console.WriteLine();
            string caminhoSolucao = string.Empty;
            string diretorioSaida = string.Empty;

            if (args.Length < 2)
            {
                Console.WriteLine("Uso: programa <solucao.sln> <diretorio_saida>");
                Console.WriteLine();
                Console.WriteLine("Exemplo:");
                Console.WriteLine(@"  programa ""C:\Projetos\MeuApp.sln"" ""C:\Saida\Delphi""");

                caminhoSolucao = "T:\\temp\\MeusProjetos\\ProjetoOriginal\\TesteFilterConsoleAppNovo.sln";
                diretorioSaida = "T:\\CSharpToDelphiConvertDsv\\sources\\OutroConversor\\Exemplo\\Saida";

                //return;
            }
            else
            {
                caminhoSolucao = args[0];
                diretorioSaida = args[1];
            }

            if (!File.Exists(caminhoSolucao))
            {
                Console.WriteLine($"❌ Arquivo não encontrado: {caminhoSolucao}");
                return;
            }

            try
            {
                var opcoes = new OpcoesConversao
                {
                    UsarTObjectPorPadrao = true,
                    GerarDestrutor = false
                };

                var conversor = new ConversorSolucao(caminhoSolucao, diretorioSaida, opcoes);
                await conversor.ConverterAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Erro: {ex.Message}");
                Console.WriteLine(ex.StackTrace);
            }
        }
    }
}
