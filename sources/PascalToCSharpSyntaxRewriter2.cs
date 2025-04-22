using System;
using System.IO;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

public class DelphiCodeGenerator : CSharpSyntaxRewriter
{
    private IndentedTextWriter writer;

    public string GenerateDelphiCode(string csharpCode)
    {
        SyntaxTree syntaxTree = CSharpSyntaxTree.ParseText(csharpCode);
        CompilationUnitSyntax root = syntaxTree.GetCompilationUnitRoot();

        using (StringWriter stringWriter = new StringWriter())
        {
            writer = new IndentedTextWriter(stringWriter);

            foreach (SyntaxNode node in root.ChildNodes())
            {
                Visit(node);
            }

            return stringWriter.ToString();
        }
    }

    public override SyntaxNode VisitClassDeclaration(ClassDeclarationSyntax node)
    {
        writer.WriteLine($"type");
        writer.Indent++;
        writer.WriteLine($"{node.Identifier.Value} = class");
        writer.Indent++;
        
        foreach (MemberDeclarationSyntax member in node.Members)
        {
            Visit(member);
        }

        writer.Indent--;
        writer.WriteLine($"end;");
        writer.Indent--;

        return node;
    }

    public override SyntaxNode VisitMethodDeclaration(MethodDeclarationSyntax node)
    {
        writer.WriteLine($"procedure {node.Identifier.Value};");
        return node;
    }

    public override SyntaxNode VisitPropertyDeclaration(PropertyDeclarationSyntax node)
    {
        writer.WriteLine($"property {node.Identifier.Value}: {node.Type} read F{node.Identifier.Value} write F{node.Identifier.Value};");
        return node;
    }

    // Adicione outros métodos de visitante conforme necessário para outros elementos da linguagem C#

    // Exemplo de uso:
    static void Main()
    {
        string csharpCode = @"
            using System;

            public class MyClass
            {
                public int MyProperty { get; set; }

                public void MyMethod()
                {
                    Console.WriteLine(""Hello, World!"");
                }
            }
        ";

        DelphiCodeGenerator generator = new DelphiCodeGenerator();
        string delphiCode = generator.GenerateDelphiCode(csharpCode);
        Console.WriteLine(delphiCode);
    }
}
