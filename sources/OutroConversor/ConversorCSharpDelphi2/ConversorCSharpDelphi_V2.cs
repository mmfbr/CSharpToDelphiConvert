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
    /// Conversor principal que processa uma solução C# e gera código Delphi
    /// VERSÃO CORRIGIDA com todos os ajustes
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
            Console.WriteLine("║    Conversor C# → Delphi (VERSÃO CORRIGIDA)             ║");
            Console.WriteLine("╚═══════════════════════════════════════════════════════════╝");
            Console.WriteLine();

            // Registra MSBuild
            if (!MSBuildLocator.IsRegistered)
            {
                var instancia = MSBuildLocator.QueryVisualStudioInstances()
                    .OrderByDescending(i => i.Version)
                    .FirstOrDefault();

                if (instancia == null)
                {
                    throw new Exception("MSBuild não encontrado! Instale Visual Studio Build Tools");
                }

                MSBuildLocator.RegisterInstance(instancia);
                Console.WriteLine($"✓ MSBuild {instancia.Version} registrado");
            }

            Console.WriteLine($"Solução: {_caminhoSolucao}");
            Console.WriteLine($"Saída: {_diretorioSaida}");
            Console.WriteLine();

            // Abre solução
            var workspace = MSBuildWorkspace.Create();
            var solucao = await workspace.OpenSolutionAsync(_caminhoSolucao);

            Console.WriteLine($"Projetos: {solucao.Projects.Count()}");
            Console.WriteLine();

            // Processa cada projeto
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

            // Processa cada documento
            foreach (var documento in projeto.Documents)
            {
                // Ignora arquivos gerados
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

            // Cria o conversor
            var conversor = new ConversorCSharpDelphi(modelo, _opcoes);
            conversor.Visit(raiz);

            // Obtém código Delphi gerado
            var codigoDelphi = conversor.ObterCodigoDelphi();

            if (string.IsNullOrWhiteSpace(codigoDelphi))
            {
                Console.WriteLine("│     (sem classes para converter)");
                return;
            }

            // Salva arquivo .pas
            var nomeArquivo = Path.GetFileNameWithoutExtension(documento.Name);
            var caminhoSaida = Path.Combine(_diretorioSaida, nomeProjeto, $"{nomeArquivo}.pas");
            
            Directory.CreateDirectory(Path.GetDirectoryName(caminhoSaida));
            File.WriteAllText(caminhoSaida, codigoDelphi);

            Console.WriteLine($"│     ✓ Salvo: {nomeArquivo}.pas");
        }
    }

    /// <summary>
    /// Conversor que caminha pela árvore C# e gera código Delphi
    /// VERSÃO CORRIGIDA
    /// </summary>
    public class ConversorCSharpDelphi : CSharpSyntaxWalker
    {
        private readonly SemanticModel _modelo;
        private readonly OpcoesConversao _opcoes;
        
        // Construtores de código
        private StringBuilder _interface = new StringBuilder();
        private StringBuilder _implementation = new StringBuilder();
        private HashSet<string> _usings = new HashSet<string>();
        
        // Contexto atual
        private string _classeAtual = null;
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
            
            // Unit header com nome do namespace
            sb.AppendLine($"unit {_namespaceAtual};");
            sb.AppendLine();
            sb.AppendLine("interface");
            sb.AppendLine();
            
            // Uses
            if (_usings.Any())
            {
                sb.AppendLine("uses");
                sb.AppendLine("  " + string.Join(", ", _usings.OrderBy(u => u)) + ";");
                sb.AppendLine();
            }
            
            // Interface section
            sb.Append(_interface);
            
            // Implementation section
            sb.AppendLine();
            sb.AppendLine("implementation");
            sb.AppendLine();
            sb.Append(_implementation);
            
            // End
            sb.AppendLine();
            sb.AppendLine("end.");
            
            return sb.ToString();
        }

        // ═══════════════════════════════════════════════════════════════
        // NAMESPACE
        // ═══════════════════════════════════════════════════════════════

        public override void VisitNamespaceDeclaration(NamespaceDeclarationSyntax node)
        {
            // Captura o nome do namespace para usar como nome da unit
            _namespaceAtual = node.Name.ToString();
            base.VisitNamespaceDeclaration(node);
        }

        public override void VisitFileScopedNamespaceDeclaration(FileScopedNamespaceDeclarationSyntax node)
        {
            // C# 10+ file-scoped namespace
            _namespaceAtual = node.Name.ToString();
            base.VisitFileScopedNamespaceDeclaration(node);
        }

        // ═══════════════════════════════════════════════════════════════
        // CLASSES
        // ═══════════════════════════════════════════════════════════════

        public override void VisitClassDeclaration(ClassDeclarationSyntax node)
        {
            var nomeClasse = node.Identifier.Text;
            
            // Adiciona prefixo T se não tiver
            if (!nomeClasse.StartsWith("T"))
                nomeClasse = "T" + nomeClasse;

            _classeAtual = nomeClasse;

            // Adiciona uses comuns
            _usings.Add("System.SysUtils");
            _usings.Add("System.Classes");

            // XMLDOC: Converte comentários de documentação
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }

            // Começa declaração da classe
            _interface.AppendLine($"type");
            _interface.Append($"  {nomeClasse} = class");

            // Herança
            if (node.BaseList != null && node.BaseList.Types.Any())
            {
                var tipoBase = node.BaseList.Types.First();
                var nomeBase = tipoBase.Type.ToString();
                
                if (!nomeBase.StartsWith("T"))
                    nomeBase = "T" + nomeBase;
                    
                _interface.Append($"({nomeBase})");
            }
            else if (_opcoes.UsarTObjectPorPadrao)
            {
                _interface.Append("(TObject)");
            }

            _interface.AppendLine();

            // Processa membros da classe
            _indentacao = 2;

            // Separa membros por tipo
            var campos = node.Members.OfType<FieldDeclarationSyntax>().ToList();
            var propriedades = node.Members.OfType<PropertyDeclarationSyntax>().ToList();
            var construtores = node.Members.OfType<ConstructorDeclarationSyntax>().ToList();
            var metodos = node.Members.OfType<MethodDeclarationSyntax>().ToList();

            // Seção private (campos)
            if (campos.Any(c => EhPrivado(c.Modifiers)))
            {
                _interface.AppendLine("  private");
                foreach (var campo in campos.Where(c => EhPrivado(c.Modifiers)))
                {
                    VisitFieldDeclaration(campo);
                }
            }

            // Seção public
            _interface.AppendLine("  public");

            // Construtores
            foreach (var construtor in construtores)
            {
                VisitConstructorDeclaration(construtor);
            }

            // Destrutor se necessário
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
                    
                    // Converte /// <summary> para { }
                    var linhas = textoCompleto.Split('\n');
                    foreach (var linha in linhas)
                    {
                        var limpa = linha.Trim();
                        if (limpa.StartsWith("///"))
                        {
                            limpa = limpa.Substring(3).Trim();
                            
                            // Remove tags XML
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
        // CAMPOS (FIELDS)
        // ═══════════════════════════════════════════════════════════════

        public override void VisitFieldDeclaration(FieldDeclarationSyntax node)
        {
            var tipoDelphi = ConverterTipo(node.Declaration.Type);

            foreach (var variavel in node.Declaration.Variables)
            {
                var nome = variavel.Identifier.Text;
                
                // Adiciona prefixo m_ se não tiver
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
            
            // XMLDOC
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }
            
            // Property simples (get/set automático)
            _interface.AppendLine($"    property {nome}: {tipoDelphi} read Get{nome} write Set{nome};");
        }

        // ═══════════════════════════════════════════════════════════════
        // CONSTRUTORES
        // ═══════════════════════════════════════════════════════════════

        public override void VisitConstructorDeclaration(ConstructorDeclarationSyntax node)
        {
            var parametros = ConverterParametros(node.ParameterList);
            
            // XMLDOC
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }
            
            // Declaração na interface
            _interface.AppendLine($"    constructor Create({parametros});");

            // Implementação
            _implementation.AppendLine($"constructor {_classeAtual}.Create({parametros});");
            _implementation.AppendLine("begin");
            
            // Se tem herança, chama inherited
            var classe = node.Parent as ClassDeclarationSyntax;
            if (classe?.BaseList != null && classe.BaseList.Types.Any())
            {
                _implementation.AppendLine("  inherited Create;");
            }

            // Corpo do construtor
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
            
            // Determina se é function ou procedure
            var ehFunction = tipoRetorno != "void";
            var tipoMetodo = ehFunction ? "function" : "procedure";

            // XMLDOC
            var trivia = node.GetLeadingTrivia();
            var comentarios = ExtrairComentariosXmlDoc(trivia);
            if (!string.IsNullOrEmpty(comentarios))
            {
                _interface.AppendLine(comentarios);
            }

            // Declaração na interface
            if (ehFunction)
            {
                _interface.AppendLine($"    {tipoMetodo} {nome}({parametros}): {tipoRetorno};");
            }
            else
            {
                _interface.AppendLine($"    {tipoMetodo} {nome}({parametros});");
            }

            // Implementação
            if (ehFunction)
            {
                _implementation.AppendLine($"{tipoMetodo} {_classeAtual}.{nome}({parametros}): {tipoRetorno};");
            }
            else
            {
                _implementation.AppendLine($"{tipoMetodo} {_classeAtual}.{nome}({parametros});");
            }

            _implementation.AppendLine("begin");

            // Corpo do método
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
        // CONVERSÃO DE TIPOS
        // ═══════════════════════════════════════════════════════════════

        private string ConverterTipo(TypeSyntax tipo)
        {
            var tipoString = tipo.ToString();

            // Tipos primitivos
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

            // Trata tipo anulável (int?, string?, etc)
            if (tipo is NullableTypeSyntax nullable)
            {
                return ConverterTipo(nullable.ElementType);
            }

            // Tenta mapear tipo primitivo
            if (mapeamento.TryGetValue(tipoString, out var tipoDelphi))
            {
                return tipoDelphi;
            }

            // Tipos genéricos (List<T>, etc)
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

            // Adiciona T se for classe personalizada
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
                
                // Adiciona prefixo A se não tiver
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
        // CONVERSÃO DE EXPRESSÕES PARA STRING (CRÍTICO!)
        // ═══════════════════════════════════════════════════════════════

        private string ConverterExpressaoParaString(ExpressionSyntax expr)
        {
            var texto = expr.ToString();

            // 1. Converte "this." para "Self."
            texto = Regex.Replace(texto, @"\bthis\.", "Self.", RegexOptions.IgnoreCase);

            // 2. Converte "new List<Type>()" para "TList<TType>.Create"
            texto = Regex.Replace(texto, @"new\s+List<(\w+)>\(\)", m =>
            {
                var tipo = m.Groups[1].Value;
                if (!tipo.StartsWith("T"))
                    tipo = "T" + tipo;
                return $"TList<{tipo}>.Create";
            });

            // 3. Converte "new Dictionary<K,V>()" para "TDictionary<TK,TV>.Create"
            texto = Regex.Replace(texto, @"new\s+Dictionary<(\w+),\s*(\w+)>\(\)", m =>
            {
                var tipo1 = m.Groups[1].Value;
                var tipo2 = m.Groups[2].Value;
                if (!tipo1.StartsWith("T") && char.IsUpper(tipo1[0]))
                    tipo1 = "T" + tipo1;
                if (!tipo2.StartsWith("T") && char.IsUpper(tipo2[0]))
                    tipo2 = "T" + tipo2;
                return $"TDictionary<{tipo1},{tipo2}>.Create";
            });

            // 4. Converte "new ClassName()" para "TClassName.Create()"
            texto = Regex.Replace(texto, @"new\s+(\w+)\s*\(", m =>
            {
                var tipo = m.Groups[1].Value;
                if (!tipo.StartsWith("T"))
                    tipo = "T" + tipo;
                return $"{tipo}.Create(";
            });

            // 5. Converte operador "%" para "mod"
            texto = Regex.Replace(texto, @"(\w+)\s*%\s*(\w+)", "$1 mod $2");

            // 6. Converte operador "==" para "="
            texto = texto.Replace("==", "=");

            // 7. Converte operador "!=" para "<>"
            texto = texto.Replace("!=", "<>");

            // 8. Converte "&&" para "and"
            texto = texto.Replace("&&", "and");

            // 9. Converte "||" para "or"
            texto = texto.Replace("||", "or");

            // 10. Converte "!" para "not"
            texto = Regex.Replace(texto, @"!(\w+)", "not $1");

            // 11. Converte DateTime.Now para Now
            texto = texto.Replace("DateTime.Now", "Now");

            // 12. Converte Console.WriteLine para WriteLn
            texto = Regex.Replace(texto, @"Console\.WriteLine", "WriteLn");

            // 13. Converte interpolação de strings $"..." para Format
            if (texto.Contains("$\""))
            {
                // Simplificação: remove $ e mantém aspas
                texto = texto.Replace("$\"", "\"");
            }

            return texto;
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

            _implementation.AppendLine($"{indent}end;");

            // Else
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

    /// <summary>
    /// Opções de conversão
    /// </summary>
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
            Console.WriteLine("Conversor C# → Delphi (VERSÃO CORRIGIDA)");
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
