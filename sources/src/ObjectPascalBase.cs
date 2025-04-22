// Marcelo Melo
// 10/11/2023

using System;
using System.IO;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace CSharpToObjectPascal
{
    internal abstract class ObjectPascalBaseOldDesativado
    {


        public static String CSharpToObjectPascalType(TypeSyntax pType)
        {          
            return CSharpToObjectPascalType(pType.ToString());
        }

        public static String CSharpToObjectPascalType(String pTypeName)
        {
            if (pTypeName.Contains("["))
            {
                String[] p1 = pTypeName.Split('[');
                return $"TArray<{CSharpToObjectPascalType(p1[0])}>";
            }
            if (pTypeName.Contains("<"))
            {
                String[] p1 = pTypeName.Split('<');
                String[] p2 = p1[1].Split(new[] { ">" }, StringSplitOptions.RemoveEmptyEntries);
                p2 = p2[0].Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries);

                return $"{CSharpToObjectPascalType(p1[0])}<{String.Join(", ", p2.Select(v => CSharpToObjectPascalType(v)).ToArray())}>";
            }
            switch (pTypeName)
            {
                case "int":
                case "Int":
                    return "Integer";

                case "Boolean":
                case "bool":
                    return "Boolean";

                case "Array":
                    return "TArray";

                case "StringBuilder":
                    return "TStringBuilder";

                case "DateTime":
                    return "TDatetime";

                case "long":
                case "Long":
                    return "Int64";

                case "Guid":
                    return "TGuid";

                case "object":
                    return "TObject";

                case "decimal":
                case "Decimal":
                    return "Double";

                case "string":
                case "String":
                    return "string";

                case "char":
                    return "Char";

                case "List":
                    return "TList";

                case "Dictionary":
                    return "TDictionary";

                case "ReadOnlyCollection":
                    return "TReadOnlyCollection";


                default:
                    if (pTypeName.StartsWith("T") || (pTypeName.StartsWith("I"))) 
                        return pTypeName;
                    else
                        return "T" + pTypeName;
            }
        }

    }
}