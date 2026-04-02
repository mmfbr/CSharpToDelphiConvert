using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;

namespace CSharpAStToXml
{
    internal class Converter
    {
        static HashSet<string> GNodeBlackList = new HashSet<string>();
        static HashSet<string> GTokenBlackList = new HashSet<string>();
        static HashSet<string> GTriviaBlackList = new HashSet<string>();
        static Converter() 
        {
            GNodeBlackList.Add("Language");
            GNodeBlackList.Add("FullSpan");
            GNodeBlackList.Add("Span");
            GNodeBlackList.Add("SpanStart");
            GNodeBlackList.Add("IsMissing");
            GNodeBlackList.Add("IsStructuredTrivia");
            GNodeBlackList.Add("HasStructuredTrivia");
            GNodeBlackList.Add("ContainsSkippedText");
            GNodeBlackList.Add("ContainsDiagnostics");
            GNodeBlackList.Add("ContainsDirectives");
            GNodeBlackList.Add("HasLeadingTrivia");
            GNodeBlackList.Add("HasTrailingTrivia");
            GNodeBlackList.Add("ContainsAnnotations");
            GNodeBlackList.Add("IsNint");
            GNodeBlackList.Add("IsNuint");
            GNodeBlackList.Add("IsNotNull");
            GNodeBlackList.Add("IsUnmanaged");
            GNodeBlackList.Add("ParentTrivia");

            GTokenBlackList.Add("Language");
            GTokenBlackList.Add("FullSpan");
            GTokenBlackList.Add("Span");
            GTokenBlackList.Add("SpanStart");
            GTokenBlackList.Add("IsMissing");
            GTokenBlackList.Add("HasStructuredTrivia");
            GTokenBlackList.Add("ContainsDiagnostics");
            GTokenBlackList.Add("ContainsDirectives");
            GTokenBlackList.Add("HasLeadingTrivia");
            GTokenBlackList.Add("HasTrailingTrivia");
            GTokenBlackList.Add("ContainsAnnotations");
            GTokenBlackList.Add("Value");
            //GTokenBlackList.Add("Text");

            GTriviaBlackList.Add("Language");
            GTriviaBlackList.Add("FullSpan");
            GTriviaBlackList.Add("Span");
            GTriviaBlackList.Add("SpanStart");
            GTriviaBlackList.Add("ContainsDiagnostics");
            GTriviaBlackList.Add("HasStructure");
            GTriviaBlackList.Add("IsDirective");
        }
        public void Run(string ASourceDirectory)
        {
            ConvertDirectory(ASourceDirectory);
            Console.WriteLine("Finished. Press Enter...");
            Console.ReadLine();
        }
        private void ConvertDirectory(string ADirectory)
        {
            var Directories = Directory.GetDirectories(ADirectory);
            foreach (var Directory in Directories)
                ConvertDirectory(Directory);

            var Filenames = Directory.GetFiles(ADirectory, "*.cs");
            foreach (var Filename in Filenames)
                Convert(Filename);
        }

        private void Convert(string AFilename)
        {
            Console.WriteLine($"Converting {AFilename}...");
            var Source = File.ReadAllText(AFilename);
            var Tree = CSharpSyntaxTree.ParseText(Source);
            var CompilationUnit = Tree.GetCompilationUnitRoot();

            AFilename = Path.ChangeExtension(AFilename, ".astml");
            var Writer = new XmlTextWriter(AFilename, Encoding.UTF8);
            Writer.Formatting = Formatting.Indented;
            WriteNode(CompilationUnit, Writer);
            Writer.Flush();
        }

        private void WriteNode(SyntaxNode ANode, XmlTextWriter AWriter)
        {
            var Type = ANode.GetType();
            AWriter.WriteStartElement(Type.Name);

            var Props = Type.GetProperties(BindingFlags.Instance | BindingFlags.Public);
            WriteProperties(ANode, Props, GNodeBlackList, AWriter);

            foreach (var ChildNodeOrToken in ANode.ChildNodesAndTokens())
            {
                if (ChildNodeOrToken.IsNode)
                    WriteNode(ChildNodeOrToken.AsNode()!, AWriter);
                else if (ChildNodeOrToken.IsToken)
                    WriteToken(ChildNodeOrToken.AsToken(), AWriter);

            }

            AWriter.WriteEndElement();
        }
        private void WriteToken(SyntaxToken AToken, XmlTextWriter AWriter)
        {
            AWriter.WriteStartElement("token");

            var Type = AToken.GetType();
            var Props = Type.GetProperties(BindingFlags.Instance | BindingFlags.Public);
            WriteProperties(AToken, Props, GTokenBlackList, AWriter);

            WriteTrivia("lead", AToken.LeadingTrivia, AWriter);
            WriteTrivia("trail", AToken.TrailingTrivia, AWriter);
            AWriter.WriteEndElement();
        }
        private void WriteTrivia(string AType, SyntaxTriviaList ATrivia, XmlTextWriter AWriter)
        {
            if (ATrivia.Count == 0)
                return;

            foreach (var Trivia in ATrivia)
            {
                AWriter.WriteStartElement("trivia");
                AWriter.WriteAttributeString("type", AType);

                var Type = Trivia.GetType();
                var Props = Type.GetProperties(BindingFlags.Instance | BindingFlags.Public);
                WriteProperties(Trivia, Props, GTriviaBlackList, AWriter);

                var Structure = Trivia.GetStructure();
                if (Structure != null) 
                    WriteNode(Structure, AWriter);
                else
                    AWriter.WriteAttributeString("Text", Trivia.ToString());
                AWriter.WriteEndElement();
            }
        }
        private void WriteProperties(object AInstance, PropertyInfo[] AProps, HashSet<string> ABlackList, XmlTextWriter AWriter)
        {
            foreach (var Prop in AProps)
            {
                var PropName = Prop.Name;
                if (!ABlackList.Contains(PropName) || (true))
                {
                    var Value = Prop.GetValue(AInstance);
                    if ((Value != null) && ((Value is String) || ((Value is ValueType) && (Value is not IEnumerable) && (Value is not SyntaxToken))))
                    {
                        var Text = Value.ToString();
                        if (!string.IsNullOrEmpty(Text))
                            AWriter.WriteAttributeString(PropName, Text);
                    }
                }
                else
                {
                    Console.WriteLine($"Skipping {PropName}");
                }
            }
        }
    }
}
