
using System.CodeDom.Compiler;
using System.IO;
using System.Text;

namespace CSharpToObjectPascal
{
	public class ObjectPascalCodeGeneratorOptions : CodeGeneratorOptions
	{
		private int wrapLocation;
		public bool UnitNameWithNamespaceName = false;
		public string unitName = null;


        public int WrapLocation
		{
			get
			{
				return wrapLocation;
			}
			set
			{
				wrapLocation = value;
				base["WrapLocation"] = value;
			}
		}

		public ObjectPascalCodeGeneratorOptions()
			: this(160)
		{
		}

		public ObjectPascalCodeGeneratorOptions(int wrapLocation)
		{
			WrapLocation = wrapLocation;
			base.BlankLinesBetweenMembers = true;
			base.BracingStyle = "C";
			base.IndentString = "   ";


		}

		public IndentedTextWriter CreateWriter(StringBuilder builder, int indent)
		{
			IndentedTextWriter indentedTextWriter = new IndentedTextWriter(new StringWriter(builder), "    ");

            indentedTextWriter.Indent = indent;
			return indentedTextWriter;
		}
	}
}
