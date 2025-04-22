using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using RoslynCore;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.MSBuild;
using Microsoft.CodeAnalysis.Rename;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Xml;

namespace RoslynRefactory {
    public partial class Form1 : Form {

        public SyntaxTree syntax;
        public Dictionary<string, SyntaxNode[]> nodes = new Dictionary<string, SyntaxNode[]>();
        private MSBuildWorkspace workspace;
        public Solution solution;
        public Project project;
        public Document document;

        private string operationName;
        private int operationTime;
        string solutionPath = "";
        private TreeNode lastNode;
        
        public Form1() {
            InitializeComponent();
            AnalyzeCode();
            workspace = MSBuildWorkspace.Create();
            MessageBox.Show (RoslynVarRewrite.TestProgram.Main(new string[] { }));
        }

        public void File_CreateNewSolution () {

        }
        public async void File_OpenSolution() {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Solution (*.sln)|*.sln|All Files (*.*)|*.*";
            if (ofd.ShowDialog () == DialogResult.OK) {
                solutionPath = ofd.FileName;
                if (workspace.CurrentSolution != null) {
                    workspace.CloseSolution();
                }
                solution = await workspace.OpenSolutionAsync(solutionPath);
                tvFiles.Nodes.Clear();
                var root = CreateTreeNode(Path.GetFileName(solution.FilePath), solution, tvFiles.Nodes);
                foreach (var proj in solution.Projects) {
                    var node = CreateTreeNode(proj.Name, proj, root.Nodes);
                    var prj = LoadProject(proj);
                    project = prj;
                    foreach (var doc in prj.Documents)
                        CreateTreeNode(doc.Name, doc, node.Nodes);
                }
            }
            tvFiles.ExpandAll();
        }
        private Project LoadProject (Project project) {
            XmlDocument xml = new XmlDocument();
            xml.Load(project.FilePath);
            List<string> filesToLoad = new List<string>();
            for (int i = 0; i < xml.ChildNodes.Count;i ++) {
                var node = xml.ChildNodes[i];
                if (node.Name == "Project")
                    for (int j = 0; j < node.ChildNodes.Count; j ++) {
                        var item = node.ChildNodes[j];
                        if (item.Name == "ItemGroup")
                            for (int k = 0; k < item.ChildNodes.Count; k ++) {
                                var compile = item.ChildNodes[k];
                                if (compile.Name == "Compile") {
                                    for (int q = 0; q < compile.Attributes.Count; q++) {
                                        if (compile.Attributes[q].Name == "Include") {
                                            string filePath = Path.Combine(Path.GetDirectoryName(project.FilePath), compile.Attributes[q].Value);
                                            /*if (File.Exists (filePath)) {
                                                //bool add = true;
                                                //for (int w = 0; add && w < compile.ChildNodes.Count; w++) if (compile.ChildNodes[w].Name == "DependentUpon") add = false;
                                                //if (add) {
                                                //    filesToLoad.Add(filePath);
                                                //}
                                                if (filePath.EndsWith(".cs")) filesToLoad.Add(filePath);
                                            }*/
                                            if (File.Exists(filePath) && filePath.EndsWith(".cs")) filesToLoad.Add(filePath);
                                            break;
                                        }
                                    }
                                }
                            }
                    }
            }
            var docs = project.Documents.ToList();
            for (int i = 0; i < filesToLoad.Count; i ++) {
                bool add = true; for (int j = 0; j < docs.Count && add; j ++) if (filesToLoad[i] == docs[j].Name) add = false;
                if (add) project = project.AddDocument(Path.GetFileName(filesToLoad[i]), File.ReadAllText(filesToLoad[i]), null, filesToLoad[i]).Project;
            }
            solution = project.Solution;
            return project;
        }
        public void File_SaveSolution () {

        }
        public void AnalyzeCode () {
            InitOperation ("AnalyzeCode ()");

            syntax = Parse(textBox1.Text, "Program.cs");
            CreateAst(syntax);

            EndOperation();
        
        }
        public void GenerateCode () {
            InitOperation("GenerateCode ()");

            textBox1.Text = Generate(syntax);

            EndOperation();
        }
        public void AnalyzeAST () {
            InitOperation("AnalyzeAST ()");

            ParseDocument();

            EndOperation();
        }
        public void AstElement () {
            var tag = tvAst.SelectedNode.Tag;
            propertyGrid1.SelectedObject = tag;
            //propertyGrid1.SelectedObjects = new object[] { tag, tag.GetType() };
            if (tag is SyntaxNode) AstElement(tag as SyntaxNode);
        }
        public void AstElement (SyntaxNode node) {
            textBox1.Focus();
            textBox1.Select(node.Span.Start, node.Span.Length);
            propertyGrid1.SelectedObject = node;
            Status(node.GetType ().ToString());
        }
        
        public async void Files () {
            if (tvFiles.SelectedNode == null || tvFiles.SelectedNode.Tag == null) return;
            var tag = tvFiles.SelectedNode.Tag;
            if (tag is Document) {
                document = tag as Document;
                if (tvFiles.SelectedNode == lastNode) { } else { }
                if (MessageBox.Show ("Are you sure you want to load the selected file?", "Load File") == DialogResult.OK) {
                    var tree = await document.GetSyntaxTreeAsync();
                    var root = tree.GetRoot();
                    var text = tree.ToString();
                    textBox1.Text = text;
                    CreateAst(syntax = tree);

                    ParseDocument();

                    lastNode = tvFiles.SelectedNode;
                } else {
                    tvFiles.SelectedNode = lastNode;
                }
            }
        }
        public void ParseDocument () {
            nodes.Clear();
            Collect(syntax.GetRoot());
            CreateNames();
        }
        public void Collect (SyntaxNode root) {
            if (root is NamespaceDeclarationSyntax) {
                var node = root as NamespaceDeclarationSyntax;
                Collect(node.Name.ToString (), node);
            } else if (root is ClassDeclarationSyntax) {
                var node = root as ClassDeclarationSyntax;
                Collect(node.Identifier.ValueText, node);
            } else if (root is EnumDeclarationSyntax) {
                var node = root as EnumDeclarationSyntax;
                Collect(node.Identifier.ValueText, node);
            } else if (root is FieldDeclarationSyntax) {
                var node = root as FieldDeclarationSyntax;
                foreach (var subnode in node.Declaration.Variables)
                    Collect(subnode.Identifier.ValueText, node);
            } else if (root is PropertyDeclarationSyntax) {
                var node = root as PropertyDeclarationSyntax;
                Collect(node.Identifier.ValueText, node);
            } else if (root is MethodDeclarationSyntax) {
                var node = root as MethodDeclarationSyntax;
                Collect(node.Identifier.ValueText, node);
            } else if (root is EventDeclarationSyntax) {
                var node = root as EventDeclarationSyntax;
                Collect(node.Identifier.ValueText, node);
            }
            foreach (var node in root.ChildNodes()) Collect(node);
        }
        public void Collect (string Name, SyntaxNode Node) {
            if (nodes.ContainsKey (Name)) {
                var list = new List<SyntaxNode>();
                list.AddRange(nodes[Name]);
                list.Add(Node);
                nodes[Name] = list.ToArray();
            } else nodes.Add(Name, new SyntaxNode[] { Node });
        }
        public void Rename () {
            tvAst.Nodes.Clear();
            textBox1.Text = "";
            //Rename(document);
            foreach (var row in nodes)
            {
                string newName = Rename(row.Key);
                foreach (var astnode in row.Value)
                {
                    RenameAll(document, astnode, newName);
                }
            }

            tvFiles.Nodes.Clear();
            var root = CreateTreeNode(Path.GetFileName(solution.FilePath), solution, tvFiles.Nodes);
            foreach (var proj in solution.Projects) {
                var node = CreateTreeNode(proj.Name, proj, root.Nodes);
                var prj = LoadProject(proj);
                project = prj;
                foreach (var doc in prj.Documents)
                    CreateTreeNode(doc.Name, doc, node.Nodes);
            }
            tvFiles.ExpandAll();
            /*CreateAst(syntax);
            GenerateCode();*/
        }
        private async void RenameAll (Document document, SyntaxNode node, string newName) {
            if (node == null || document == null) return;
            var semanticModel = await document.GetSemanticModelAsync();
            var ins = GetIdentifierNode(node);
            if (ins == null) return;
            var symbol = semanticModel.GetSymbolInfo(ins);
            /*if (MessageBox.Show(node.ToString() + "\n\n\n" + ins.ToString()) != DialogResult.OK)
                throw new Exception();*/
            var isymbol = symbol.Symbol ?? (symbol.CandidateSymbols.Length > 0 ? symbol.CandidateSymbols.First() : GetSymbol (semanticModel, node));
            if (isymbol == null) return;
            var newSolution = await Renamer.RenameSymbolAsync(solution, isymbol, newName, solution.Workspace.Options).ConfigureAwait(false);
            this.solution = newSolution;
            this.project = this.solution.Projects.First();
        }
        private ISymbol GetSymbol (SemanticModel semanticModel, SyntaxNode root) {
            if (root is ClassDeclarationSyntax) return semanticModel.GetTypeInfo(root).Type;
            return null;
        }
        private SyntaxNode GetIdentifierNode(SyntaxNode root) {
            if (root is ClassDeclarationSyntax ||
                root is FieldDeclarationSyntax ||
                root is MethodDeclarationSyntax ||
                root is EventDeclarationSyntax) return root;
            return null;
        }
        private string Rename (string name) { return name.ToUpper(); }
        private void NamesElement () { }
        private void AnalyzeCode_Click(object sender, EventArgs e) => AnalyzeCode();
        private void GenerateCode_Click(object sender, EventArgs e) => GenerateCode();
        private void AstElement_Select(object sender, TreeViewEventArgs e) => AstElement();
        private void NamesElement_Select(object sender, TreeViewEventArgs e) => NamesElement();
        private void AnalyzeAST_Click(object sender, EventArgs e) => AnalyzeAST();
        private void File_NewSolution_Click(object sender, EventArgs e) => File_CreateNewSolution();
        private void File_OpenSolution_Click(object sender, EventArgs e) => File_OpenSolution();
        private void File_SaveSolution_Click(object sender, EventArgs e) => File_SaveSolution();
        private void Files_Select(object sender, TreeViewEventArgs e) => Files();
        private SyntaxTree Parse (string programCode, string programPath) { return CSharpSyntaxTree.ParseText(programCode).WithFilePath(programPath); }
        public string Generate (SyntaxTree syntax) { return syntax.GetRoot().NormalizeWhitespace().ToString(); }
        private void CreateAst (SyntaxTree syntax) { tvAst.Nodes.Clear(); CreateAst(syntax.GetRoot(), tvAst.Nodes); tvAst.ExpandAll(); }
        private void CreateAst (SyntaxNode node, TreeNodeCollection root = null) { var tn = CreateTreeNode(GetNodeTitle(node), node, root); foreach (var subnode in node.ChildNodes()) CreateAst(subnode, tn.Nodes); }
        private void CreateNames() { tvNames.Nodes.Clear(); foreach (var row in nodes) CreateTreeNode(row.Key, row.Value, tvNames.Nodes); tvNames.ExpandAll(); }
        private TreeNode CreateTreeNode (string name, object tag = null, TreeNodeCollection root = null) { var node = new TreeNode(name); node.Tag = tag; if (root != null) root.Add(node); return node; }
        private TreeNode CreateTreeNode(string name, string tooltip, object tag = null, TreeNodeCollection root = null) { var node = new TreeNode(name); node.Tag = tag; node.ToolTipText = tooltip; if (root != null) root.Add(node); return node; }
        private string GetNodeTitle (SyntaxNode node) { return "<" + node.GetType().Name + ">"; }
        public void InitOperation (string name) { operationTime = Environment.TickCount; operationName = name; tsStatus.Text = name + " { }"; Application.DoEvents(); }
        public void EndOperation(string log = null) { var elap = Environment.TickCount - operationTime; tsStatus.Text = operationName + (string.IsNullOrEmpty(log) ? "" : " { " + log.Trim() + " }") + " : " + elap + "ms"; operationName = ""; operationTime = 0; }
        public void Status (string text) { tsStatus.Text = text; }
        private void Rename_Click(object sender, EventArgs e) => Rename();
    }
}
