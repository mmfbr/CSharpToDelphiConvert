using System;
using System.Collections.Generic;

namespace ExemploConversao
{
    /// <summary>
    /// Classe de exemplo para demonstrar a conversão C# → Delphi
    /// </summary>
    public class Pessoa
    {
        // Campos privados
        private string nome;
        private int idade;
        private DateTime dataNascimento;

        // Construtor
        public Pessoa(string nome, int idade)
        {
            this.nome = nome;
            this.idade = idade;
            this.dataNascimento = DateTime.Now.AddYears(-idade);
        }

        // Propriedades
        public string Nome
        {
            get { return nome; }
            set { nome = value; }
        }

        public int Idade
        {
            get { return idade; }
            set { idade = value; }
        }

        // Métodos
        public void ExibirDados()
        {
            Console.WriteLine($"Nome: {nome}, Idade: {idade}");
        }

        public bool EhMaiorDeIdade()
        {
            return idade >= 18;
        }

        public int CalcularAnoNascimento()
        {
            return DateTime.Now.Year - idade;
        }
    }

    /// <summary>
    /// Classe com herança
    /// </summary>
    public class Funcionario : Pessoa
    {
        private string cargo;
        private decimal salario;

        public Funcionario(string nome, int idade, string cargo, decimal salario) 
            : base(nome, idade)
        {
            this.cargo = cargo;
            this.salario = salario;
        }

        public string Cargo
        {
            get { return cargo; }
            set { cargo = value; }
        }

        public decimal Salario
        {
            get { return salario; }
            set { salario = value; }
        }

        public decimal CalcularSalarioAnual()
        {
            return salario * 12;
        }

        public void Promover(string novoCargo, decimal novoSalario)
        {
            cargo = novoCargo;
            salario = novoSalario;
        }
    }

    /// <summary>
    /// Classe com coleções genéricas
    /// </summary>
    public class Empresa
    {
        private string nome;
        private List<Funcionario> funcionarios;

        public Empresa(string nome)
        {
            this.nome = nome;
            this.funcionarios = new List<Funcionario>();
        }

        public void AdicionarFuncionario(Funcionario funcionario)
        {
            funcionarios.Add(funcionario);
        }

        public void RemoverFuncionario(Funcionario funcionario)
        {
            funcionarios.Remove(funcionario);
        }

        public int ObterTotalFuncionarios()
        {
            return funcionarios.Count;
        }

        public List<Funcionario> ObterFuncionarios()
        {
            return funcionarios;
        }
    }

    /// <summary>
    /// Classe com tipos diversos
    /// </summary>
    public class Calculadora
    {
        public int Somar(int a, int b)
        {
            return a + b;
        }

        public double Dividir(double a, double b)
        {
            if (b == 0)
            {
                return 0;
            }
            return a / b;
        }

        public bool EhPar(int numero)
        {
            return numero % 2 == 0;
        }
    }
}
