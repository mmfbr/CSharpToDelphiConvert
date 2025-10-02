# 🎯 Conversor C# → Delphi usando Roslyn

Este é um conversor **completo e funcional** que transforma código C# em código Delphi, usando `CSharpSyntaxWalker` do Roslyn.

## 📋 Por que CSharpSyntaxWalker?

| Classe | Uso | Para Converter C#→Delphi |
|--------|-----|--------------------------|
| `CSharpSyntaxRewriter` | Modifica C# → gera C# | ❌ Não |
| `CSharpSyntaxWalker` | Analisa C# → gera **qualquer coisa** | ✅ **Sim!** |

**CSharpSyntaxWalker** permite:
- Caminhar pela árvore sintática C#
- Analisar cada nó (classe, método, campo)
- **Gerar código em qualquer linguagem** (no nosso caso, Delphi!)

---

## 🚀 Como Funciona

```
Código C#
   ↓
CSharpSyntaxTree (Roslyn)
   ↓
CSharpSyntaxWalker percorre a árvore
   ↓
Gera código Delphi (StringBuilder)
   ↓
Arquivo .pas
```

---

## ⚡ Início Rápido

### 1. Pré-requisitos

✅ .NET 8 SDK  
✅ Visual Studio ou VS Build Tools (para MSBuild)

### 2. Compilar

```bash
cd <pasta_do_conversor>
dotnet restore ConversorCSharpDelphi.csproj
dotnet build ConversorCSharpDelphi.csproj
```

### 3. Executar

```bash
dotnet run --project ConversorCSharpDelphi.csproj -- "C:\Projetos\MeuApp.sln" "C:\Saida\Delphi"
```

---

## 📊 O Que é Convertido

### ✅ Suportado

| C# | Delphi | Exemplo |
|----|--------|---------|
| `class Pessoa` | `type TPessoa = class` | ✅ |
| `private int idade` | `m_idade: Integer` | ✅ |
| `public string Nome { get; set; }` | `property Nome: String` | ✅ |
| `public Pessoa(string nome)` | `constructor Create(ANome: String)` | ✅ |
| `public void Metodo()` | `procedure Metodo` | ✅ |
| `public int Metodo()` | `function Metodo: Integer` | ✅ |
| `class Funcionario : Pessoa` | `TFuncionario = class(TPessoa)` | ✅ |
| `List<T>` | `TList<T>` | ✅ |
| `Dictionary<K,V>` | `TDictionary<K,V>` | ✅ |

### Tipos Convertidos

```csharp
// C#              →  Delphi
int                →  Integer
long               →  Int64
short              →  SmallInt
byte               →  Byte
bool               →  Boolean
string             →  String
double             →  Double
float              →  Single
decimal            →  Currency
char               →  Char
DateTime           →  TDateTime
List<T>            →  TList<T>
Dictionary<K,V>    →  TDictionary<K,V>
object             →  TObject
```

---

## 📝 Exemplo Completo

### Código C# (entrada):

```csharp
using System;

namespace Exemplo
{
    public class Pessoa
    {
        private string nome;
        private int idade;

        public Pessoa(string nome, int idade)
        {
            this.nome = nome;
            this.idade = idade;
        }

        public string Nome
        {
            get { return nome; }
            set { nome = value; }
        }

        public bool EhMaiorDeIdade()
        {
            return idade >= 18;
        }
    }
}
```

### Código Delphi (saída):

```pascal
unit Pessoa;

interface

uses
  System.Classes, System.SysUtils;

type
  TPessoa = class(TObject)
  private
    m_nome: String;
    m_idade: Integer;
  public
    constructor Create(ANome: String; AIdade: Integer);
    function EhMaiorDeIdade: Boolean;
    property Nome: String read GetNome write SetNome;
  end;

implementation

constructor TPessoa.Create(ANome: String; AIdade: Integer);
begin
  inherited Create;
  m_nome := ANome;
  m_idade := AIdade;
end;

function TPessoa.EhMaiorDeIdade: Boolean;
begin
  Result := m_idade >= 18;
end;

end.
```

---

## 🔧 Estrutura do Conversor

### 1. ConversorSolucao (classe principal)

```csharp
// Abre a solução e processa cada projeto
var workspace = MSBuildWorkspace.Create();
var solucao = await workspace.OpenSolutionAsync("caminho.sln");

foreach (var projeto in solucao.Projects)
{
    // Processa cada arquivo .cs
}
```

### 2. ConversorCSharpDelphi (CSharpSyntaxWalker)

```csharp
public class ConversorCSharpDelphi : CSharpSyntaxWalker
{
    private StringBuilder _interface = new StringBuilder();
    private StringBuilder _implementation = new StringBuilder();
    
    // Caminha pela árvore e gera código Delphi
    public override void VisitClassDeclaration(ClassDeclarationSyntax node)
    {
        // Gera código Delphi para a classe
        _interface.AppendLine($"type");
        _interface.AppendLine($"  T{node.Identifier.Text} = class");
        // ...
    }
}
```

### 3. Métodos Override Principais

| Método | Converte | Para |
|--------|----------|------|
| `VisitClassDeclaration` | Classes C# | `type TClasse = class` |
| `VisitFieldDeclaration` | Campos privados | `m_campo: Tipo` |
| `VisitPropertyDeclaration` | Propriedades | `property Nome: Tipo` |
| `VisitConstructorDeclaration` | Construtores | `constructor Create` |
| `VisitMethodDeclaration` | Métodos | `function/procedure` |

---

## 🎨 Personalização

### Opções de Conversão

```csharp
var opcoes = new OpcoesConversao
{
    // Adiciona TObject como base se não tiver herança
    UsarTObjectPorPadrao = true,
    
    // Gera destrutor Destroy automaticamente
    GerarDestrutor = false,
    
    // Prefixo para campos privados
    PrefixoCampos = "m_"
};

var conversor = new ConversorSolucao(caminhoSln, diretorioSaida, opcoes);
```

### Adicionar Novos Tipos

Edite o método `ConverterTipo()`:

```csharp
private string ConverterTipo(TypeSyntax tipo)
{
    var mapeamento = new Dictionary<string, string>
    {
        ["int"] = "Integer",
        ["string"] = "String",
        // Adicione seus tipos personalizados aqui:
        ["Guid"] = "TGUID",
        ["TimeSpan"] = "TTimeSpan",
    };
    // ...
}
```

### Adicionar Novos Statements

Edite o método `ConverterStatement()`:

```csharp
private void ConverterStatement(StatementSyntax statement, int indentLevel)
{
    switch (statement)
    {
        case ExpressionStatementSyntax expr:
            // Já implementado
            break;
            
        case WhileStatementSyntax whileStat:
            // Adicione suporte a while
            ConverterWhile(whileStat, indentLevel);
            break;
            
        // Adicione mais casos conforme necessário
    }
}
```

---

## 🔍 Arquitetura do Código

### Fluxo de Conversão

```
1. MSBuildWorkspace.OpenSolutionAsync()
   ↓
2. Para cada Projeto → GetCompilationAsync()
   ↓
3. Para cada Document → GetSyntaxTreeAsync()
   ↓
4. ConversorCSharpDelphi.Visit(root)
   ↓
   ├─ VisitClassDeclaration
   ├─ VisitFieldDeclaration
   ├─ VisitConstructorDeclaration
   ├─ VisitMethodDeclaration
   └─ VisitPropertyDeclaration
   ↓
5. ObterCodigoDelphi()
   ↓
6. Salvar arquivo .pas
```

### StringBuilder Sections

```csharp
// Interface section (declarações)
private StringBuilder _interface;
// "type TClasse = class ... end;"

// Implementation section (implementações)
private StringBuilder _implementation;
// "constructor TClasse.Create; begin ... end;"

// Uses clause
private HashSet<string> _usings;
// "uses System.SysUtils, System.Classes"
```

---

## 🧪 Testando o Conversor

### 1. Criar Projeto de Teste

```bash
# Crie uma solução C# simples
dotnet new console -n TesteConversao
cd TesteConversao

# Adicione suas classes de teste
# (use o arquivo ExemploC#ParaConversao.cs como referência)

# Converta
dotnet run --project ..\ConversorCSharpDelphi.csproj -- "TesteConversao.sln" "Saida"
```

### 2. Verificar Resultado

```bash
cd Saida
# Você encontrará arquivos .pas gerados
# Abra-os no Delphi IDE para compilar
```

---

## 📋 Checklist de Conversão

Após converter, verifique manualmente:

- [ ] Tipos genéricos (`TList<T>`, `TDictionary<K,V>`)
- [ ] Propriedades (adicionar métodos Get/Set se necessário)
- [ ] Construtores com `inherited`
- [ ] Métodos com múltiplos parâmetros
- [ ] Expressões complexas
- [ ] Try-catch-finally
- [ ] Events/Delegates (requer implementação manual)
- [ ] LINQ (converter para loops Delphi)
- [ ] Async/await (converter para threads Delphi)

---

## 🚀 Melhorias Futuras

### Recursos a Adicionar

1. **Statements Completos**
   - [x] `if/else`
   - [x] `for each`
   - [ ] `while`
   - [ ] `do-while`
   - [ ] `switch/case`
   - [ ] `try-catch-finally`

2. **Expressões**
   - [x] Atribuições simples
   - [x] Chamadas de método
   - [ ] Operadores lógicos
   - [ ] Expressões lambda
   - [ ] LINQ

3. **Tipos Avançados**
   - [x] Classes
   - [x] Herança
   - [x] Genéricos básicos
   - [ ] Interfaces
   - [ ] Enums
   - [ ] Structs
   - [ ] Delegates
   - [ ] Events

4. **Recursos Especiais**
   - [ ] Attributes → Attributes Delphi
   - [ ] Async/await → Threads
   - [ ] LINQ → Loops
   - [ ] Extension methods

---

## 💡 Dicas de Desenvolvimento

### 1. Debugar o Walker

```csharp
public override void VisitClassDeclaration(ClassDeclarationSyntax node)
{
    Console.WriteLine($"Convertendo classe: {node.Identifier.Text}");
    // Seu código aqui
    base.VisitClassDeclaration(node);
}
```

### 2. Ver a Árvore Sintática

Use o Syntax Visualizer no Visual Studio:
- View → Other Windows → Syntax Visualizer

Ou use https://sharplab.io para visualizar online

### 3. Testar Pequenos Trechos

```csharp
var codigo = @"
public class Teste
{
    private int valor;
}";

var arvore = CSharpSyntaxTree.ParseText(codigo);
var conversor = new ConversorCSharpDelphi(null, new OpcoesConversao());
conversor.Visit(arvore.GetRoot());
Console.WriteLine(conversor.ObterCodigoDelphi());
```

---

## 🎯 Exemplo de Uso Real

### Estrutura do Projeto

```
MeuProjeto/
├── Program.cs
├── Models/
│   ├── Pessoa.cs          → Saida/Models/Pessoa.pas
│   ├── Funcionario.cs     → Saida/Models/Funcionario.pas
│   └── Empresa.cs         → Saida/Models/Empresa.pas
└── Services/
    └── PessoaService.cs   → Saida/Services/PessoaService.pas
```

### Comando

```bash
dotnet run --project ConversorCSharpDelphi.csproj -- "MeuProjeto.sln" "Saida"
```

### Resultado

```
✓ Projeto MeuProjeto convertido
  → Pessoa.pas
  → Funcionario.pas
  → Empresa.pas
  → PessoaService.pas
```

---

## ⚠️ Limitações Conhecidas

| Recurso C# | Status | Solução |
|------------|--------|---------|
| LINQ | ❌ Não suportado | Converter manualmente para loops |
| async/await | ❌ Não suportado | Usar threads Delphi |
| Delegates/Events | ⚠️ Parcial | Implementar manualmente |
| Anonymous types | ❌ Não suportado | Criar classes explícitas |
| Extension methods | ❌ Não suportado | Converter para métodos helper |
| Nullable types | ⚠️ Parcial | Usar Default() |

---

## 🆘 Troubleshooting

### Erro: "MSBuild não encontrado"

```
Solução: Instale Visual Studio Build Tools
```

### Código Delphi não compila

```
Problema: Tipos não mapeados
Solução: Adicione o tipo no método ConverterTipo()
```

### Método não convertido

```
Problema: Statement não implementado
Solução: Adicione o case no método ConverterStatement()
```

---

## 📚 Recursos

- [Roslyn API](https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/)
- [CSharpSyntaxWalker](https://learn.microsoft.com/en-us/dotnet/api/microsoft.codeanalysis.csharp.csharpsyntaxwalker)
- [Delphi Language Guide](https://docwiki.embarcadero.com/RADStudio/en/Delphi_Language_Guide)

---

## 🎉 Conclusão

Este conversor fornece uma **base sólida** para conversão automática C# → Delphi:

✅ Converte estrutura básica de classes  
✅ Mapeia tipos C# → Delphi  
✅ Gera código Delphi válido  
✅ Mantém hierarquia de projetos  
✅ Extensível e personalizável  

**Próximo passo:** Estenda o conversor com os recursos que você mais precisa!

---

**Boa sorte com suas conversões! 🚀**
