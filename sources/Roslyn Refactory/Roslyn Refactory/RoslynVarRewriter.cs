using System;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace RoslynVarRewrite
{
    public class VarRewriter : CSharpSyntaxRewriter
    {
        private readonly SemanticModel model;

        public VarRewriter(SemanticModel model)
        {
            this.model = model;
        }

        public override SyntaxNode VisitLocalDeclarationStatement(LocalDeclarationStatementSyntax node)
        {
            var symbolInfo = model.GetSymbolInfo(node.Declaration.Type);
            var typeSymbol = symbolInfo.Symbol;
            var type = typeSymbol.ToDisplayString(
              SymbolDisplayFormat.MinimallyQualifiedFormat);

            var declaration = SyntaxFactory
                .LocalDeclarationStatement(
                    SyntaxFactory
                        .VariableDeclaration(SyntaxFactory.IdentifierName(
                          SyntaxFactory.Identifier(type)))
                            .WithVariables(node.Declaration.Variables)
                            .NormalizeWhitespace()
                    )
                    .WithTriviaFrom(node);
            return declaration;
        }
    }

    class TestProgram
    {
        public static string Main(string[] args)
        {
            var tree = CSharpSyntaxTree.ParseText(@"
using System;
using System.Collections.Generic;
class Program {
  static void Main(string[] args) {
    var x = 5;
    var s = ""Test string"";
    var l = new List<string>();
    var scores = new byte[8][]; // Test comment
    var names = new string[3] {""Diego"", ""Dani"", ""Seba""};
  }
}");

            // Get the assembly file, the compilation and the semantic model
            var Mscorlib = MetadataReference.CreateFromFile(typeof(object).Assembly.Location);
            var compilation = CSharpCompilation.Create("RoslynVarRewrite",
              syntaxTrees: new[] { tree },
              references: new[] { Mscorlib });
            var model = compilation.GetSemanticModel(tree);

            var varRewriter = new VarRewriter(model);
            var result = varRewriter.Visit(tree.GetRoot());
            Console.WriteLine(result.ToFullString());
            return result.ToFullString();
        }
    }
}