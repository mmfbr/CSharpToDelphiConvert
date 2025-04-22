using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Build.Locator;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.MSBuild;
using Microsoft.CodeAnalysis.Formatting;
using Microsoft.CodeAnalysis.Rename;
using System.IO;

static class Program
{

    private static Hashtable keywords;
    private static Hashtable specialWords;
    private static Hashtable dotNetKeywords;

    static Program()
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

        dotNetKeywords = new Hashtable(9);
        dotNetKeywords["BOOLEAN"] = '\u0004';
        dotNetKeywords["BYTE"] = '\u0004';
        dotNetKeywords["STRING"] = '\u0004';
        dotNetKeywords["DECIMAL"] = '\u0004';
        dotNetKeywords["CHAR"] = '\u0004';
        dotNetKeywords["DOUBLE"] = '\u0004';
        dotNetKeywords["INT16"] = '\u0004';
        dotNetKeywords["INT32"] = '\u0004';
        dotNetKeywords["INT64"] = '\u0004';
        dotNetKeywords["CLASSOBJECT"] = '\u0005';
        dotNetKeywords["OBJECT"] = '\u0005';
        dotNetKeywords["SBYTE"] = '\u0005';
        dotNetKeywords["SINGLE"] = '\u0005';
    }

    public static bool IsSpecialWord(string value)
    {
        if (specialWords == null)
        {
            specialWords = new Hashtable(StringComparer.CurrentCultureIgnoreCase);
            specialWords["Result"] = true;
            specialWords["Break"] = true;
            specialWords["Continue"] = true;
            specialWords["Exit"] = true;
        }
        return specialWords[value] != null;
    }


    public static bool IsKeyword(string value)
    {
        if (!keywords.ContainsKey(value.ToUpper()))
        {
            return IsSpecialWord(value);
        }
        return true;
    }

    public static bool IsDotNetKeyword(string value)
    {
        return dotNetKeywords.ContainsKey(value.ToUpper());
    }


    public static string CreateEscapedIdentifier(string name)
    {
        if (IsKeyword(name))
        {
            if (IsSpecialWord(name))
            {
                return "_" + name;
            }
            return name + "_";
        }
        return name;
    }


    static async Task Main(string[] args)
    {
        MSBuildLocator.RegisterDefaults();

        MSBuildWorkspace workspace = MSBuildWorkspace.Create();

        //Solution originalSolution = await workspace.OpenSolutionAsync(@"T:\estudando\roslyn-sdk\Se7e.Data-v2\Se7e.Data.sln");
        var solutionFileName = args.FirstOrDefault();
        //solutionFileName = @"T:\DoslynDsv\master\PascalStudio\src\CSharpToObjectPascal\Conversoes\TypeScriptAST\TypeScriptAST.sln";
        //solutionFileName = @"T:\DynamicNav2009Dsv\SourceILSpyRenomeado\Solution.sln";
        //solutionFileName = @"T:\DynamicsNavDsv\SourcesRenomeados2\Microsoft.Dynamics.Nav.sln";
        //solutionFileName = @"T:\DynamicNav2009Dsv\WinForms2\System.Windows.Forms.sln";
        //solutionFileName = @"T:\DoslynDsv\master\PascalStudio\src\CSharpToObjectPascal\Conversoes\PaxScript.NET\PaxScriptNet.sln";
        //solutionFileName = @"T:\dotnet\winforms-6.0.0-rc.2.21480.6\Winforms.sln";
        //solutionFileName = @"T:\DynamicNav2009Dsv\System.Drawing2\System.Drawing.sln";
        //solutionFileName = @"T:\dotnet\.NET 4.8 for Windows January 2020 - Conversao\Source\ndp\fx\src\System.Windows.Forms.sln";
        //solutionFileName = @"T:\DynamicNav2009Dsv\Framework.NET-2.0-src\Framework.NET-2.0.sln";
        //solutionFileName = @"T:\DynamicNav2009Dsv\Framework.NET-2.0-src\Microsoft\Web\Management\Microsoft.Web.Management.sln";

        //solutionFileName = @"X:\GoldERP-Dsv\v1.14\PlataformaDsv\src\v1.14-All.sln";
        solutionFileName = @"X:\WinFormsDsv\renomeados\WinForms - Meu WinDraw - Renomeados.sln";
        Directory.SetCurrentDirectory(Path.GetDirectoryName(solutionFileName));

        int qtdeRenomeados = 0;

        Console.Title = solutionFileName;

        //Solution newSolution = originalSolution;
        Solution newSolution = await workspace.OpenSolutionAsync(solutionFileName);
        bool achouAlgum = true;
        while (achouAlgum)
        {
            achouAlgum = false;

            foreach (Project project in newSolution.Projects)
            {
                Compilation compilation = await project.GetCompilationAsync();

                foreach (SyntaxTree syntaxTree in compilation!.SyntaxTrees)
                {
                    SemanticModel semantic = compilation.GetSemanticModel(syntaxTree);

                    var currentFileName = syntaxTree.FilePath;
                    Console.WriteLine("Renomeando arquivo: " + currentFileName);

                    IEnumerable<ClassDeclarationSyntax> classDeclarationSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<ClassDeclarationSyntax>();
                    foreach (ClassDeclarationSyntax classDeclarationSyntax in classDeclarationSyntaxCollection)
                    {
                        var className = classDeclarationSyntax.Identifier.ValueText;

                        if (IsDotNetKeyword(className))
                        {
                            continue;
                        }


                        if (className.Length > 2 && (!className.StartsWith("T") || Char.IsLower(className[1])))
                        {
                            string newName = "T" + className;
                            Console.WriteLine("Renomeando Class" + className + " em: " + currentFileName);

                            ISymbol originalSymbol = semantic.GetDeclaredSymbol(classDeclarationSyntax);
                            SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                            Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);

                            newSolution = tempSolution;
                            achouAlgum = true;
                            break;
                        }

                    }

                    if (achouAlgum)
                        break;

                    IEnumerable<DelegateDeclarationSyntax> delegateDeclarationSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<DelegateDeclarationSyntax>();
                    foreach (DelegateDeclarationSyntax delegateDeclarationSyntax in delegateDeclarationSyntaxCollection)
                    {
                        var delegateName = delegateDeclarationSyntax.Identifier.ValueText;
                        if (delegateName.Length > 2 && (!delegateName.StartsWith("T") || Char.IsLower(delegateName[1])))
                        {
                            string newName = "T" + delegateName;
                            Console.WriteLine("Renomeando Delegate" + delegateName + " em: " + currentFileName);

                            ISymbol originalSymbol = semantic.GetDeclaredSymbol(delegateDeclarationSyntax);
                            SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                            Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);
                            newSolution = tempSolution;

                            achouAlgum = true;
                            break;
                        }

                    }

                    if (achouAlgum)
                        break;

                    IEnumerable<EnumDeclarationSyntax> enumDeclarationSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<EnumDeclarationSyntax>();
                    foreach (EnumDeclarationSyntax enumDeclarationSyntax in enumDeclarationSyntaxCollection)
                    {
                        var enumName = enumDeclarationSyntax.Identifier.ValueText;
                        if (enumName.Length > 2 && (!enumName.StartsWith("T") || Char.IsLower(enumName[1])))
                        {
                            string newName = "T" + enumName;
                            Console.WriteLine("Renomeando Enum: " + enumName + " em: " + currentFileName);

                            ISymbol originalSymbol = semantic.GetDeclaredSymbol(enumDeclarationSyntax);
                            SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                            Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);
                            newSolution = tempSolution;

                            achouAlgum = true;
                            break;
                        }

                    }

                    if (achouAlgum)
                        break;

                    IEnumerable<StructDeclarationSyntax> structDeclarationSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<StructDeclarationSyntax>();
                    foreach (StructDeclarationSyntax structDeclarationSyntax in structDeclarationSyntaxCollection)
                    {
                        var structName = structDeclarationSyntax.Identifier.ValueText;

                        if (IsDotNetKeyword(structName)) 
                        {
                            continue;
                        }


                        if (structName.Length > 2 && (!structName.StartsWith("T") || Char.IsLower(structName[1])))
                        {
                            string newName = "T" + structName;
                            Console.WriteLine("Renomeando Struct: " + structName + " em: " + currentFileName);

                            ISymbol originalSymbol = semantic.GetDeclaredSymbol(structDeclarationSyntax);
                            SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                            Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);
                            newSolution = tempSolution;

                            achouAlgum = true;
                            break;
                        }

                    }

                    if (achouAlgum)
                        break;

                    IEnumerable<FieldDeclarationSyntax> fieldDeclarationSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<FieldDeclarationSyntax>();
                    foreach (FieldDeclarationSyntax fieldDeclarationSyntax in fieldDeclarationSyntaxCollection)
                    {
                        foreach (VariableDeclaratorSyntax variableDeclaratorSyntax in fieldDeclarationSyntax.Declaration.Variables)
                        {

                            if (!variableDeclaratorSyntax.Identifier.ValueText.StartsWith("m_"))
                            {
                                string newName = "m_" + variableDeclaratorSyntax.Identifier.ValueText;
                                Console.WriteLine("Renomeando Field: " + variableDeclaratorSyntax.Identifier.ValueText + " em: " + currentFileName);

                                ISymbol originalSymbol = semantic.GetDeclaredSymbol(variableDeclaratorSyntax);
                                SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                                Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);
                                newSolution = tempSolution;

                                achouAlgum = true;
                                break;
                            }

                        }

                        if (achouAlgum)
                            break;
                    }

                    if (achouAlgum)
                        break;

                    IEnumerable<ParameterSyntax> parameterSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<ParameterSyntax>();
                    foreach (ParameterSyntax parameterDeclarationSyntax in parameterSyntaxCollection)
                    {
                        
                        if (IsKeyword(parameterDeclarationSyntax.Identifier.ValueText))
                        {
                            string newName = CreateEscapedIdentifier(parameterDeclarationSyntax.Identifier.ValueText);
                            Console.WriteLine("Renomeando Parametro: " + parameterDeclarationSyntax.Identifier.ValueText + " em: " + currentFileName);

                            ISymbol originalSymbol = semantic.GetDeclaredSymbol(parameterDeclarationSyntax);
                            SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                            Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);
                            newSolution = tempSolution;

                            achouAlgum = true;
                            break;
                        }

                    }

                    if (achouAlgum)
                        break;

                    IEnumerable<LocalDeclarationStatementSyntax> localDeclarationStatementSyntaxCollection = syntaxTree.GetRoot().DescendantNodesAndSelf().OfType<LocalDeclarationStatementSyntax>();
                    foreach (LocalDeclarationStatementSyntax localDeclarationStatementSyntax in localDeclarationStatementSyntaxCollection)
                    {


                        SeparatedSyntaxList<VariableDeclaratorSyntax> variableDeclaratorSyntaxCollection = localDeclarationStatementSyntax.Declaration.Variables;
                        foreach (VariableDeclaratorSyntax variableDeclaratorSyntax in variableDeclaratorSyntaxCollection)
                        {

                            if (IsKeyword(variableDeclaratorSyntax.Identifier.ValueText))
                            {
                                string newName = CreateEscapedIdentifier(variableDeclaratorSyntax.Identifier.ValueText);
                                Console.WriteLine("Renomeando Variavel Local: " + variableDeclaratorSyntax.Identifier.ValueText + " em: " + currentFileName);

                                ISymbol originalSymbol = semantic.GetDeclaredSymbol(variableDeclaratorSyntax);
                                SymbolRenameOptions symbolRenameOptions = new SymbolRenameOptions(true, true, true, true);
                                Solution tempSolution = await Renamer.RenameSymbolAsync(project.Solution, originalSymbol, symbolRenameOptions, newName);
                                newSolution = tempSolution;
                                

                                achouAlgum = true;
                                break;
                            }

                        }

                        if (achouAlgum)
                            break;
                    }

                    if (achouAlgum)
                        break;

                }

                if (achouAlgum)
                    break;

            }

            if (achouAlgum)
            {
                qtdeRenomeados++;
                Console.WriteLine("Total de nomes alterados: " + qtdeRenomeados.ToString());
                
                if (qtdeRenomeados % 60 == 0)
                {
                    if (workspace.TryApplyChanges(newSolution))
                    {
                        Console.WriteLine("Solução atualizada com sucesso.");

                        workspace.CloseSolution();

                        workspace = MSBuildWorkspace.Create();

                        newSolution = await workspace.OpenSolutionAsync(solutionFileName);

                        Console.WriteLine("Solução salva e recarregada com sucesso.");
                    }
                    else
                    {
                        Console.WriteLine("Atualização falhou!");
                        throw new Exception("Atualização falhou!");
                    }

                }
            }
        }

        Console.WriteLine("Total de nomes alterados: " + qtdeRenomeados.ToString());


        if (workspace.TryApplyChanges(newSolution))
        {

            Console.WriteLine("Solução atualizada com sucesso.");

        }
        else
        {
            Console.WriteLine("Atualização falhou!");
        }
    }
}
