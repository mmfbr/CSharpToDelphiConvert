using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis;
using System.Linq;
using Microsoft.CodeAnalysis.CSharp;

namespace RoslynCore {
    public static class ViewModelGeneration {
        public static SyntaxNode GenerateViewModel(SyntaxNode node) {
            var classNode = node.DescendantNodes()
             .OfType<ClassDeclarationSyntax>().FirstOrDefault();
            if (classNode != null) {
                string modelClassName = classNode.Identifier.Text;
                string viewModelClassName = $"{modelClassName}ViewModel";
                string newImplementation =
                  $@"public class {viewModelClassName} : INotifyPropertyChanged
{{
public event PropertyChangedEventHandler PropertyChanged;
// Raise a property change notification
protected virtual void OnPropertyChanged(string propname)
{{
  PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propname));
}}
private ObservableCollection<{modelClassName}> _{modelClassName}s;
public ObservableCollection<{modelClassName}> {modelClassName}s
{{
  get {{ return _{modelClassName}s; }}
  set
  {{
    _{modelClassName}s = value;
    OnPropertyChanged(nameof({modelClassName}s));
  }}
}}
public {viewModelClassName}() {{
// Implement your logic to load a collection of items
}}
}}
";
                var newClassNode = CSharpSyntaxTree.ParseText(newImplementation).GetRoot()
                                    .DescendantNodes().OfType<ClassDeclarationSyntax>().FirstOrDefault();
                if (!(classNode.Parent is NamespaceDeclarationSyntax)) return null;
                var parentNamespace = (NamespaceDeclarationSyntax)classNode.Parent;
                var newParentNamespace = parentNamespace.AddMembers(newClassNode).NormalizeWhitespace();
                return newParentNamespace;
            } else
                return null;
        }
    }
}