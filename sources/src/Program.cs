// Marcelo Melo
// 19/03/2024

using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;


namespace CSharpToObjectPascal
{
 

    class Program
    {

        static void Main(string[] args)
        {

            ConvertFilesInDirectory("T:\\Data7Dsv\\src\\Usuarios\\Marcelo Melo\\Filtros do usuario\\Filter Framework\\cs", translator: false);

//            ConvertFilesInDirectory("T:\\Data7AdvDsv\\TestesDotNet\\evoluir", translator: false);


            return;

            if (args.Length == 0)
            {
                ConvertFilesInDirectory("T:\\dotnet-src\\src-runtime\\src\\libraries\\System.Data.Common\\src", null);
            }
            else
            {
                string outputDir = null;

                if (args.Length >= 2)
                    outputDir = args[1];

                if (args[0].ToUpper().Equals("/I"))
                {
                    string solutionFileName = null;
                    solutionFileName = @"T:\dotnet-src\src-runtime\src\libraries\System.Data.Common\System.Data.Common.sln";
                    outputDir = @"T:\LaboratorioDsv\src\Marcelo\Delphi\Codebot.Pascal\Referencias";


                    ConvertSolutionNamespace(solutionFileName, outputDir, oneUnitForAll: false).Wait();
                    //ConvertSolution(solutionFileName, outputDir, false).Wait();
                }
                else
                {
                    FileAttributes attr = File.GetAttributes(args[0]);

                    if (attr.HasFlag(FileAttributes.Directory))
                        ConvertFilesInDirectory(args[0], outputDir);
                    else
                        ConvertSolution(args[0], outputDir, true).Wait();
                }

            }

        }

        private static void ConvertFilesInDirectory(string workDir, string outputDir = null, bool translator = false)
        {
          //  Console.Title = workDir;
            var files = Directory.GetFiles(workDir, "*.cs", SearchOption.AllDirectories).ToList();
            var outputDirIsNull = outputDir is null;

            foreach (var file in files)
            {
                String cs = File.ReadAllText(file);

                var preprocessorSymbols = new List<string>
                {
                    "DEBUG",
                    "TARGET_64BIT",
                    "TARGET_32BIT",
                    "HAS_CUSTOM_BLOCKS",
                    "FEATURE_WINDOWS_SYSTEM_COLORS",
                    "OPTIMIZED_MEASUREMENTDC",
                    "NET9_0_OR_GREATER",
                    "NET8_0_OR_GREATER",
                    "NET7_0_OR_GREATER",
                    "NET6_0_OR_GREATER",
                    "NET5_0_OR_GREATER",
                    "FINALIZATION_WATCH",
                };

                var parseOptions = new CSharpParseOptions(languageVersion: LanguageVersion.Latest, 
                                                          documentationMode: DocumentationMode.Parse, 
                                                          kind: SourceCodeKind.Regular, 
                                                          preprocessorSymbols: preprocessorSymbols);

                SyntaxTree tree = CSharpSyntaxTree.ParseText(cs, parseOptions, file);

                var provider = new ObjectPascalCodeGenerator();
                ObjectPascalCodeGeneratorOptions options = new ObjectPascalCodeGeneratorOptions();
                options.unitName = Path.GetFileNameWithoutExtension(file);
                options.UnitNameWithNamespaceName = false;

                BaseNamespaceDeclarationSyntax NamespaceDeclarationSyntax = ((CompilationUnitSyntax)tree.GetRoot()).DescendantNodes().OfType<BaseNamespaceDeclarationSyntax>().FirstOrDefault();

                if (NamespaceDeclarationSyntax is not null)
                    options.unitName = NamespaceDeclarationSyntax.Name.ToString() + "." + options.unitName;
                else
                {
                    options.unitName = Path.GetFileNameWithoutExtension(file); ;
                }




                if (outputDirIsNull)
                    outputDir = Path.GetDirectoryName(file);

                if (translator)
                    TranslatorService.Start();

                using (StreamWriter sourceWriter = new StreamWriter(outputDir + "\\" + options.unitName + ".pas"))
                {
                    provider.GenerateCodeFromCompilationUnit((CompilationUnitSyntax)tree.GetRoot(), sourceWriter, options);
                    sourceWriter.Flush();
                    sourceWriter.Close();
                }

                if (translator)
                    TranslatorService.Stop();

            }
        }

        private static async Task ConvertSolution(string solutionFile, string outputDir, bool unitNameWithNamespaceName)
        {
            //Console.Title = solutionFile;

            ////MSBuildLocator.RegisterDefaults();
            //MSBuildWorkspace workspace = MSBuildWorkspace.Create();
            //Solution solution = workspace.OpenSolutionAsync(solutionFile).Result;


            //foreach (Project project in solution.Projects)
            //{
            //    Compilation compilation = await project.GetCompilationAsync();

            //    foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //    {
            //        // SemanticModel semantic = compilation.GetSemanticModel(syntaxTree);

            //        var unitName = Path.GetFileNameWithoutExtension(syntaxTree.FilePath);
            //        var workDir = Path.GetDirectoryName(syntaxTree.FilePath);
            //        var provider = new ObjectPascalCodeGenerator();

            //        if (unitNameWithNamespaceName)
            //        {
            //            NamespaceDeclarationSyntax firstNamespace = syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>().FirstOrDefault();

            //            if (firstNamespace != null)
            //                unitName = firstNamespace.Name.ToString() + "." + unitName;
            //        }

            //        ObjectPascalCodeGeneratorOptions options = new ObjectPascalCodeGeneratorOptions();
            //        options.UnitNameWithNamespaceName = unitNameWithNamespaceName;
            //        using (StreamWriter sourceWriter = File.CreateText(outputDir ?? workDir + "\\" + unitName + ".pas"))
            //        {
            //            provider.GenerateCodeFromCompilationUnit((CompilationUnitSyntax)syntaxTree.GetRoot(), sourceWriter, options);
            //            sourceWriter.Flush();
            //            sourceWriter.Close();
            //        }

            //    }

            //}
        }


        private static async Task ConvertSolutionNamespace(string solutionFile, string outputDir, bool oneUnitForAll)
        {
            //Console.Title = solutionFile;

            ////MSBuildLocator.RegisterDefaults();
            //MSBuildWorkspace workspace = MSBuildWorkspace.Create();
            //Solution solution = await workspace.OpenSolutionAsync(solutionFile);

            //var namespaceNames = new Dictionary<string, HashSet<string>>();

            //foreach (Project project in solution.Projects)
            //{
            //    Compilation compilation = await project.GetCompilationAsync();

            //    foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //    {
            //        foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //        {
            //            HashSet<string> usingNames;
            //            if (!namespaceNames.TryGetValue(nameSpace.Name.ToString(), out usingNames))
            //            {
            //                usingNames = new HashSet<string>();
            //                namespaceNames[nameSpace.Name.ToString()] = usingNames;
            //            }

            //            var usingDirectiveSyntaxCollection = nameSpace.Parent.DescendantNodes().OfType<UsingDirectiveSyntax>();
            //            if (usingDirectiveSyntaxCollection != null && usingDirectiveSyntaxCollection.Count() > 0)
            //            {

            //                foreach (UsingDirectiveSyntax usingDirectiveSyntax in usingDirectiveSyntaxCollection)
            //                {
            //                    if (usingDirectiveSyntax.Name == null)
            //                        return;

            //                    if (usingDirectiveSyntax.Name.ToString().Equals("System"))
            //                        continue;

            //                    usingNames.Add(usingDirectiveSyntax.Name.ToString());
            //                }


            //            }
            //        }
            //    }
            //}

            //if (oneUnitForAll)
            //{
            //    var unitName = Path.GetFileNameWithoutExtension(solutionFile);
            //    var workDir = Path.GetDirectoryName(solutionFile);
            //    var provider = new ObjectPascalCodeGenerator();
            //    ObjectPascalCodeGeneratorOptions options = new ObjectPascalCodeGeneratorOptions();

            //    using (StreamWriter sourceWriter = File.CreateText(outputDir ?? workDir + "\\" + unitName + ".pas"))
            //    {
            //        bool reset = provider.InitOutput(sourceWriter, options);
            //        provider.GenerateCompilationUnitStart();
            //        sourceWriter.Write("unit ");
            //        sourceWriter.Write(unitName);
            //        sourceWriter.WriteLine(";");
            //        sourceWriter.WriteLine("");
            //        sourceWriter.WriteLine("{$SCOPEDENUMS ON}");
            //        sourceWriter.WriteLine("{$ZEROBASEDSTRINGS ON}");
            //        sourceWriter.WriteLine("");
            //        sourceWriter.WriteLine("interface");
            //        sourceWriter.WriteLine("");
            //        sourceWriter.WriteLine("uses");

            //        HashSet<string> uniqueUsingNames = new HashSet<string>();

            //        foreach (var currentNamespaceName in namespaceNames)
            //        {
            //            HashSet<string> usingNames = currentNamespaceName.Value;
            //            foreach (var usingName in usingNames)
            //            {
            //                uniqueUsingNames.Add(usingName);
            //            }
            //        }

            //        foreach (var usingName in uniqueUsingNames)
            //        {
            //            sourceWriter.Write("  ");
            //            sourceWriter.Write(usingName);

            //            if (usingName.Equals(uniqueUsingNames.Last()))
            //                sourceWriter.WriteLine(";");
            //            else
            //                sourceWriter.WriteLine(",");

            //        }

            //        sourceWriter.WriteLine();
            //        sourceWriter.WriteLine("type");
            //        sourceWriter.WriteLine("");


            //        foreach (var currentNamespaceName in namespaceNames)
            //        {

            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            provider.GenerateForwardTypes(nameSpace);
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }
            //        }


            //        foreach (var currentNamespaceName in namespaceNames)
            //        {
            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            foreach (var type in nameSpace.Members)
            //                            {
            //                                if (type is EnumDeclarationSyntax)
            //                                {
            //                                    provider.output.WriteLine("");
            //                                    provider.GenerateEnumType(type as EnumDeclarationSyntax);
            //                                }
            //                            }
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }
            //        }

            //        foreach (var currentNamespaceName in namespaceNames)
            //        {
            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            foreach (var type in nameSpace.Members)
            //                            {
            //                                if (type is DelegateDeclarationSyntax)
            //                                {
            //                                    provider.output.WriteLine("");
            //                                    provider.GenerateDelegateDeclarationSyntax(type as DelegateDeclarationSyntax);
            //                                }
            //                            }
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }
            //        }


            //        foreach (var currentNamespaceName in namespaceNames)
            //        {
            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            foreach (var type in nameSpace.Members)
            //                            {
            //                                if (type is InterfaceDeclarationSyntax)
            //                                {
            //                                    provider.output.WriteLine("");
            //                                    provider.GenerateInterfaceType(type as InterfaceDeclarationSyntax);
            //                                }
            //                            }
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }
            //        }



            //        foreach (var currentNamespaceName in namespaceNames)
            //        {
            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            foreach (var type in nameSpace.Members)
            //                            {
            //                                if (type is DelegateDeclarationSyntax)
            //                                {
            //                                    // provider.output.WriteLine("");
            //                                    // provider.GenerateDelegateDeclarationSyntax(type as DelegateDeclarationSyntax);
            //                                }
            //                                if (type is EnumDeclarationSyntax)
            //                                {
            //                                    //  provider.output.WriteLine("");
            //                                    //  provider.GenerateEnumType(type as EnumDeclarationSyntax);
            //                                }
            //                                else if (type is InterfaceDeclarationSyntax)
            //                                {
            //                                    //  provider.output.WriteLine("");
            //                                    //  provider.GenerateInterfaceType(type as InterfaceDeclarationSyntax);
            //                                }
            //                                else if (type is StructDeclarationSyntax)
            //                                {
            //                                    provider.output.WriteLine("");
            //                                    provider.GenerateStructType(type as StructDeclarationSyntax, declaration: true);
            //                                }
            //                                else if (type is ClassDeclarationSyntax)
            //                                {
            //                                    provider.output.WriteLine("");
            //                                    provider.GenerateClassType(type as ClassDeclarationSyntax, declaration: true);
            //                                }
            //                            }
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }
            //        }

            //        sourceWriter.WriteLine();
            //        sourceWriter.WriteLine("implementation");

            //        foreach (var currentNamespaceName in namespaceNames)
            //        {

            //            foreach (Project project3 in solution.Projects)
            //            {
            //                Compilation compilation3 = await project3.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree3 in compilation3.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace3 in syntaxTree3.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace3.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.GenerateImplementations(nameSpace3);
            //                        }


            //                    }
            //                }
            //            }
            //        }


            //        sourceWriter.WriteLine();
            //        sourceWriter.WriteLine("end.");

            //        sourceWriter.Flush();
            //        sourceWriter.Close();
            //    }
            //}
            //else
            //{
            //    foreach (var currentNamespaceName in namespaceNames)
            //    {
            //        var unitName = currentNamespaceName.Key;
            //        var workDir = Path.GetDirectoryName(solutionFile);
            //        var provider = new ObjectPascalCodeGenerator();
            //        ObjectPascalCodeGeneratorOptions options = new ObjectPascalCodeGeneratorOptions();

            //        using (StreamWriter sourceWriter = File.CreateText(outputDir ?? workDir + "\\" + unitName + ".pas"))
            //        {
            //            bool reset = provider.InitOutput(sourceWriter, options);
            //            provider.GenerateCompilationUnitStart();
            //            sourceWriter.Write("unit ");
            //            sourceWriter.Write(unitName);
            //            sourceWriter.WriteLine(";");
            //            sourceWriter.WriteLine("");
            //            sourceWriter.WriteLine("{$SCOPEDENUMS ON}");
            //            sourceWriter.WriteLine("{$ZEROBASEDSTRINGS ON}");
            //            sourceWriter.WriteLine("");
            //            sourceWriter.WriteLine("interface");
            //            sourceWriter.WriteLine("");

            //            HashSet<string> usingNames = currentNamespaceName.Value;
            //            if (usingNames.Count() > 0)
            //            {
            //                sourceWriter.WriteLine("uses");
            //                provider.Indent++;

            //                foreach (var usingName in usingNames)
            //                {
            //                    sourceWriter.Write("  ");
            //                    sourceWriter.Write(usingName);

            //                    if (usingName.Equals(usingNames.Last()))
            //                        sourceWriter.WriteLine(";");
            //                    else
            //                        sourceWriter.WriteLine(",");

            //                }
            //                sourceWriter.WriteLine();
            //                provider.Indent--;
            //            }

            //            sourceWriter.WriteLine("type");
            //            sourceWriter.WriteLine("");

            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            provider.GenerateForwardTypes(nameSpace);
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }

            //            foreach (Project project in solution.Projects)
            //            {
            //                Compilation compilation = await project.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree in compilation.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace in syntaxTree.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.Indent++;
            //                            provider.GenerateTypes(nameSpace);
            //                            provider.Indent--;
            //                        }

            //                    }
            //                }
            //            }

            //            sourceWriter.WriteLine();
            //            sourceWriter.WriteLine("implementation");

            //            foreach (Project project3 in solution.Projects)
            //            {
            //                Compilation compilation3 = await project3.GetCompilationAsync();

            //                foreach (SyntaxTree syntaxTree3 in compilation3.SyntaxTrees)
            //                {
            //                    foreach (var nameSpace3 in syntaxTree3.GetRoot().DescendantNodes().OfType<NamespaceDeclarationSyntax>())
            //                    {
            //                        if (nameSpace3.Name.ToString().Equals(currentNamespaceName.Key))
            //                        {
            //                            provider.GenerateImplementations(nameSpace3);
            //                        }


            //                    }
            //                }
            //            }

            //            sourceWriter.WriteLine();
            //            sourceWriter.WriteLine("end.");

            //            sourceWriter.Flush();
            //            sourceWriter.Close();
            //        }

            //    }
            //}
        }

    }

}
