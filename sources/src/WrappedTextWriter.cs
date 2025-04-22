// Marcelo Melo
// 10/11/2023

using Microsoft.CodeAnalysis;
using System.CodeDom.Compiler;
using System.IO;
using System.Text;
using System.Xml.Linq;

namespace CSharpToObjectPascal
{
	public class WrappedTextWriter : TextWriter
	{
		private int column;

		private int WrapColumn;

		public char WrapChar;

		private TextWriter publicWriter;

		private int Writing;

		private bool indented;

		private bool wrapPending;

		private bool indentNextLines;

		public IndentedTextWriter IndentedWriter;

		public int Column => column;

		public override Encoding Encoding => publicWriter.Encoding;

		public WrappedTextWriter(TextWriter w, char wrapChar, int wrapColumn, bool indentNextLines)
		{
			publicWriter = w;
			WrapChar = wrapChar;
			WrapColumn = wrapColumn;
			this.indentNextLines = indentNextLines;
		}

		public override void Write(char c)
		{
			if (c == '\n')
			{
				column = 0;
				if (indented)
				{
					IndentedWriter.Indent--;
					indented = false;
				}
				wrapPending = false;
			}
			else if (c == WrapChar)
			{
				wrapPending = Writing + column > WrapColumn;
				return;
			}
			if (wrapPending && c != ' ' && c != '\t' && c != '\r')
			{
				wrapPending = false;
				if (IndentedWriter != null)
				{
					IndentedWriter.WriteLine();
					if (indentNextLines && !indented)
					{
						IndentedWriter.Indent++;
						indented = true;
					}
					IndentedWriter.Write(c);
					return;
				}
				publicWriter.WriteLine();
				column = 0;
			}


			
			 if (c.Equals('\uD800'))
                publicWriter.Write("#$D800");
         //   throw new NotSupportedException("não suportado");
            else
                publicWriter.Write(c);

			Writing--;
			column++;
		}

		public override void Write(char[] cs, int index, int count)
		{
			int writing = Writing;
			Writing = count;
			base.Write(cs, index, count);
			Writing = writing;
		}

		public void WriteNoWrap(string str)
		{
			char wrapChar = WrapChar;
			try
			{
				WrapChar = '\0';
				Write(str);
			}
			finally
			{
				WrapChar = wrapChar;
			}
		}
	}
}
