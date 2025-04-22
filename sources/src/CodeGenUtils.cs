// Marcelo Melo
// 10/11/2023

using Microsoft.CodeAnalysis.CSharp.Syntax;
using System;
using System.CodeDom;
using Microsoft.CodeAnalysis.CSharp;
using System.CodeDom.Compiler;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Text;
using Microsoft.CodeAnalysis;

namespace CSharpToObjectPascal
{
    public class CodeGenUtils
    {
        public const string STypeParamStart = "<";

        public const string STypeParamEnd = ">";

        private static Hashtable specialWords;

        private static Dictionary<string, string> primitiveTypeMap;

        private static ResourceManager resourceManager;

        public static string GetString(string name)
        {
            if (resourceManager == null)
            {
                Assembly assembly = typeof(CodeGenUtils).Assembly;
                resourceManager = new ResourceManager(assembly.GetName().Name + ".ResourceStrings", assembly);
            }
            try
            {
                return resourceManager.GetString(name);
            }
            catch
            {
                return name;
            }
        }

        public static int CharCount(string str, char c)
        {
            int num = 0;
            int num2 = 0;
            int num3 = 0;
            while (num3 < str.Length && num > -1)
            {
                num = str.IndexOf(c, num3);
                if (num == -1)
                {
                    break;
                }
                num2++;
                num3 = num + 1;
            }
            return num2;
        }

        public static void CheckForOverloadedMethods(TypeDeclarationSyntax e)
        {
            Hashtable hashtable = new Hashtable(StringComparer.CurrentCultureIgnoreCase);
            foreach (MemberDeclarationSyntax member in e.Members)
            {
                if ((member is MethodDeclarationSyntax || member is ConstructorDeclarationSyntax) && (!(member is MethodDeclarationSyntax) || ((MethodDeclarationSyntax)member).Modifiers.IndexOf(SyntaxKind.PrivateKeyword) == -1))
                {
                    MethodDeclarationSyntax codeTypeMember2 = (MethodDeclarationSyntax)hashtable[member.ToString()];
                    if (codeTypeMember2 == null)
                    {
                        hashtable[member.ToString()] = member;
                        continue;
                    }

//                    member.Attributes |= MemberAttributes.Overloaded;
  //                  codeTypeMember2.Attributes |= MemberAttributes.Overloaded;
                }
            }
        }

        public static string CreateEscapedIdentifier(NameSyntax name)
        {
            if (IsKeyword(name.ToString()))
            {
                if (IsSpecialWord(name.ToString()))
                {
                    return "_" + name.ToString();
                }
                return "&" + name.ToString();
            }
            return name.ToString();
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

        public static string CreateEscapedIdentifier(NameSyntax name, int offset)
        {
            if (offset == 0)
            {
                return CreateEscapedIdentifier(name);
            }
            return name.ToString();
        }

        public static string CreateNonEscapedIdentifier(string name)
        {
            if (IsSpecialWord(name))
            {
                return "_" + name;
            }
            return name;
        }

        public static string CreateValidIdentifier(string name)
        {
            if (IsKeyword(name))
            {
                return "_" + name;
            }
            return name;
        }

        public static void FindNestedTypes(TypeDeclarationSyntax c, string parentName, Hashtable typeList)
        {
            foreach (MemberDeclarationSyntax member in c.Members)
            {
                TypeDeclarationSyntax codeTypeDeclaration = member as TypeDeclarationSyntax;
                if (codeTypeDeclaration != null)
                {
                    string text = parentName + "." + codeTypeDeclaration.Identifier.Text;
                    typeList[text] = codeTypeDeclaration;
                    FindNestedTypes(codeTypeDeclaration, text, typeList);
                }
            }
        }

        public static string FixupDelphiUnitNames(string ident)
        {
            if (ident.IndexOf('.') >= 0)
            {
                Type type = Type.GetType(ident, throwOnError: false, ignoreCase: true);
                if (type != null)
                {
                    object[] customAttributes = type.GetCustomAttributes(inherit: false);
                    if (customAttributes != null)
                    {
                        object[] array = customAttributes;
                        foreach (object obj in array)
                        {
                            Type type2 = obj.GetType();
                            if (!(type2.Name == "TUnitNameAttribute"))
                            {
                                continue;
                            }
                            PropertyInfo property = type2.GetProperty("UnitName");
                            if (property != null)
                            {
                                object value = property.GetValue(obj, null);
                                if (value == null || !(value is string))
                                {
                                    break;
                                }
                                int num = ident.LastIndexOf(".");
                                if (num >= 0)
                                {
                                    ident = ident.Substring(num + 1, ident.Length - (num + 1));
                                }
                                return (string)value + "." + ident;
                            }
                        }
                    }
                }
            }
            return ident;
        }

        public static Hashtable FixupTypes(NamespaceDeclarationSyntax e)
        {
            Hashtable hashtable = new Hashtable(StringComparer.CurrentCultureIgnoreCase);
             for (int i = 0; i < e.Members.Count; i++)
            {


                ClassDeclarationSyntax typeDeclaration = e.Members[i] as ClassDeclarationSyntax;
                string name = typeDeclaration.Identifier.Text;
                hashtable[name] = typeDeclaration;
                FindNestedTypes(typeDeclaration, name, hashtable);
                if (typeDeclaration.BaseList.Types.Count <= 0)
                {
                    continue;
                }
                string baseType = typeDeclaration.BaseList.Types[0].Type.ToString();
                for (int j = i + 1; j < e.Members.Count; j++)
                {
                    TypeDeclarationSyntax typeDeclaration2 = e.Members[j] as TypeDeclarationSyntax;
                    if (typeDeclaration2.Identifier.Text == baseType)
                    {
                        if (typeDeclaration2.Kind() == SyntaxKind.InterfaceDeclaration)
                        {
                            e.Members.Remove(typeDeclaration2);
                            e.Members.Insert(i, typeDeclaration2);
                            name = typeDeclaration2.Identifier.Text;
                            hashtable[name] = typeDeclaration2;
                            FindNestedTypes(typeDeclaration2, name, hashtable);
                            i++;
                        }
                        break;
                    }
                }
            }
            return hashtable;
        }

        protected static void OnFindDelegateReferences(CodeObject e, object data)
        {
            Hashtable hashtable = (Hashtable)data;
            if (e is CodeTypeReference)
            {
                CodeTypeReference codeTypeReference = (CodeTypeReference)e;
                if (!hashtable.Contains(codeTypeReference.BaseType))
                {
                    hashtable[codeTypeReference.BaseType] = codeTypeReference;
                }
            }
        }

        public static void FixupTypesInner(SyntaxList<MemberDeclarationSyntax> types, ref int currentIndex, Hashtable allTypes)
        {
            while (currentIndex < types.Count)
            {
                TypeDeclarationSyntax typeDecl = types[currentIndex] as TypeDeclarationSyntax;
                Hashtable hashtable = new Hashtable(StringComparer.CurrentCultureIgnoreCase);
                //DomWalker.WalkDom(typeDecl, OnFindDelegateReferences, hashtable);
                //if (hashtable.Count > 0)
                //{
                //    for (int i = currentIndex + 1; i < types.Count; i++)
                //    {
                //        CodeTypeDeclaration codeTypeDeclaration = types[i];
                //        if (hashtable[codeTypeDeclaration.Name] != null)
                //        {
                //            object obj = codeTypeDeclaration.UserData["LastMovedIndex"];
                //            if (obj == null || (int)obj != currentIndex)
                //            {
                //                types.Remove(codeTypeDeclaration);
                //                types.Insert(currentIndex, codeTypeDeclaration);
                //                codeTypeDeclaration.UserData["LastMovedIndex"] = currentIndex;
                //                FixupTypesInner(types, ref currentIndex, allTypes);
                //                break;
                //            }
                //        }
                //    }
                //}
                currentIndex++;
            }
        }

        public static Hashtable FixupTypeOrder(NamespaceDeclarationSyntax ns)
        {
            Hashtable hashtable = new Hashtable(StringComparer.CurrentCultureIgnoreCase);
            foreach (TypeDeclarationSyntax type in ns.Members)
            {
                string name = type.Identifier.Text;
                hashtable[name] = type;
                FindNestedTypes(type, name, hashtable);
            }
            int currentIndex = 0;
            FixupTypesInner(ns.Members, ref currentIndex, hashtable);
            return hashtable;
        }

        public static string GetArrayTypeOutput(CodeTypeReference typeRef, bool prependT)
        {
            string text;
            if (typeRef.ArrayElementType != null)
            {
                text = GetArrayTypeOutput(typeRef.ArrayElementType, prependT: false);
            }
            else
            {
                text = GetBaseTypeOutput(typeRef, typeArgsAsIdentifiers: true);
                text = !(text == "string") ? text.Replace('.', '_') : "String";
            }
            for (int i = 0; i < typeRef.ArrayRank; i++)
            {
                text = "ArrayOf" + text.Replace("&", "");
            }
            if (prependT)
            {
                text = "T" + text;
            }
            return text;
        }

        public static string GetTypeArgumentsOutput(CodeTypeReferenceCollection typeArguments)
        {
            StringBuilder stringBuilder = new StringBuilder();
            GetTypeArgumentsOutput(typeArguments, 0, typeArguments.Count, stringBuilder);
            return stringBuilder.ToString();
        }

        public static void GetTypeArgumentsOutput(CodeTypeReferenceCollection typeArguments, int start, int length, StringBuilder sb)
        {
            sb.Append("<");
            bool flag = true;
            for (int i = start; i < start + length; i++)
            {
                if (flag)
                {
                    flag = false;
                }
                else
                {
                    sb.Append(", ");
                }
                if (i < typeArguments.Count)
                {
                    sb.Append(GetTypeOutput(typeArguments[i]));
                }
            }
            sb.Append(">");
        }

        public static void GetTypeArgumentsAsIdentifiers(CodeTypeReferenceCollection typeArguments, int start, int length, StringBuilder sb)
        {
            for (int i = start; i < start + length; i++)
            {
                sb.Append("_");
                if (i < typeArguments.Count)
                {
                    sb.Append(GetTypeOutput(typeArguments[i]));
                }
            }
        }

        public static string FixupBaseTypeOutput(CodeTypeReference typeRef, bool typeArgsAsIdentifiers)
        {
            return null;
        }

        public static string GetBaseTypeOutput(CodeTypeReference baseType, bool typeArgsAsIdentifiers)
        {
            if (IsPrimitiveType(baseType.BaseType, out var mappedValue))
            {
                return mappedValue;
            }
            mappedValue = FixupBaseTypeOutput(baseType, typeArgsAsIdentifiers);
            if (mappedValue.IndexOf('.') > 0)
            {
                mappedValue = FixupDelphiUnitNames(mappedValue);
            }
            return mappedValue;
        }

        public static string GetTypeOutput(CodeTypeReference typeRef)
        {
            if (typeRef.UserData["EmitType"] != null)
            {
                return (string)typeRef.UserData["EmitType"];
            }
            if (typeRef.UserData["FullType"] != null)
            {
                return (string)typeRef.UserData["FullType"];
            }
            string text = typeRef.ArrayElementType == null ? GetBaseTypeOutput(typeRef, typeArgsAsIdentifiers: false) : GetTypeOutput(typeRef.ArrayElementType);
            for (int i = 0; i < typeRef.ArrayRank; i++)
            {
                text = "array of " + text;
            }
            return text;
        }

        public static string GetRuntimeInstallDirectory()
        {
            string fullyQualifiedName = typeof(object).Module.FullyQualifiedName;
            return Directory.GetParent(fullyQualifiedName).ToString() + "\\";
        }

        public static bool IsAbstract(CodeTypeMember member)
        {
            return (member.Attributes & MemberAttributes.Abstract) == MemberAttributes.Abstract;
        }

        public static bool IsArrayType(CodeTypeReference typeRef)
        {
            if (typeRef.ArrayElementType == null)
            {
                return typeRef.ArrayRank > 0;
            }
            return true;
        }

        public static bool IsKeyword(string value)
        {
            if (!ObjectPascalTokenizer.IsKeyword(value))
            {
                return IsSpecialWord(value);
            }
            return true;
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

        public static bool IsPrimitiveType(string value, out string mappedValue)
        {
            if (value.Length == 0)
            {
                value = "system.void";
            }
            if (primitiveTypeMap == null)
            {
                primitiveTypeMap = new Dictionary<string, string>(16);
                primitiveTypeMap.Add("system.int16", "Smallint");
                primitiveTypeMap.Add("system.int32", "Integer");
                primitiveTypeMap.Add("system.int64", "Int64");
                primitiveTypeMap.Add("system.string", "string");
                primitiveTypeMap.Add("system.boolean", "Boolean");
                primitiveTypeMap.Add("system.void", "TObject");
                primitiveTypeMap.Add("system.char", "WideChar");
                primitiveTypeMap.Add("system.byte", "Byte");
                primitiveTypeMap.Add("system.uint16", "UInt16");
                primitiveTypeMap.Add("system.uint32", "UInt32");
                primitiveTypeMap.Add("system.uint64", "UInt64");
                primitiveTypeMap.Add("system.sbyte", "SByte");
                primitiveTypeMap.Add("system.single", "Single");
                primitiveTypeMap.Add("system.double", "Double");
                primitiveTypeMap.Add("system.decimal", "Decimal");
                primitiveTypeMap.Add("string", "String");
            }
            return primitiveTypeMap.TryGetValue(value.ToLower(), out mappedValue);
        }

        public static bool IsStringTypeReference(CodeExpression expression)
        {
            CodeTypeReferenceExpression codeTypeReferenceExpression = expression as CodeTypeReferenceExpression;
            if (codeTypeReferenceExpression != null && codeTypeReferenceExpression.Type != null && codeTypeReferenceExpression.Type.ArrayRank == 0 && codeTypeReferenceExpression.Type.ArrayElementType == null)
            {
                return string.Compare(codeTypeReferenceExpression.Type.BaseType, "String", ignoreCase: true) == 0;
            }
            return false;
        }

        public static bool IsValidIdentifier(string value)
        {
            if (value == null || value.Length == 0)
            {
                return false;
            }
            if (value[0] != '&')
            {
                if (IsKeyword(value))
                {
                    return false;
                }
            }
            else
            {
                value = value.Substring(1);
            }

            // por que gerou essa linha abaixo? (eu que comentei ela)
            // bool flag = false;

            if (value.IndexOf('<') > -1 && value.IndexOf('>') > -1)
            {
                string value2 = value.Substring(0, value.IndexOf('<'));
                return CodeGenerator.IsValidLanguageIndependentIdentifier(value2);
            }
            return CodeGenerator.IsValidLanguageIndependentIdentifier(value);
        }

        public static bool IsValidLanguageIndependentIdentifier(string value)
        {
            char[] array = value.ToCharArray();
            if (array.Length == 0)
            {
                return false;
            }
            if (char.GetUnicodeCategory(array[0]) == UnicodeCategory.DecimalDigitNumber)
            {
                return false;
            }
            char[] array2 = array;
            foreach (char c in array2)
            {
                switch (char.GetUnicodeCategory(c))
                {
                    case UnicodeCategory.UppercaseLetter:
                    case UnicodeCategory.LowercaseLetter:
                    case UnicodeCategory.TitlecaseLetter:
                    case UnicodeCategory.ModifierLetter:
                    case UnicodeCategory.OtherLetter:
                    case UnicodeCategory.NonSpacingMark:
                    case UnicodeCategory.SpacingCombiningMark:
                    case UnicodeCategory.DecimalDigitNumber:
                    case UnicodeCategory.ConnectorPunctuation:
                        continue;
                }
                return false;
            }
            return true;
        }

        public static string JoinStringArray(string[] sa, string separator)
        {
            if (sa == null || sa.Length == 0)
            {
                return string.Empty;
            }
            if (sa.Length == 1)
            {
                return "\"" + sa[0] + "\"";
            }
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0; i < sa.Length - 1; i++)
            {
                stringBuilder.Append("\"");
                stringBuilder.Append(sa[i]);
                stringBuilder.Append("\"");
                stringBuilder.Append(separator);
            }
            stringBuilder.Append("\"");
            stringBuilder.Append(sa[sa.Length - 1]);
            stringBuilder.Append("\"");
            return stringBuilder.ToString();
        }

        public static void QuoteSnippetString(IndentedTextWriter writer, string value, int wrapColumn)
        {
            WrappedTextWriter wrappedTextWriter = (WrappedTextWriter)writer.InnerWriter;
            bool flag = true;
            writer.Write("'");
            for (int i = 0; i < value.Length; i++)
            {
                if (char.IsControl(value, i))
                {
                    if (flag)
                    {
                        flag = false;
                        writer.Write("'");
                    }
                    if (value[i] < ' ')
                    {
                        writer.Write("#");
                        writer.Write((int)value[i]);
                    }
                    else
                    {
                        writer.Write("#$");
                        writer.Write(((int)value[i]).ToString("X4"));
                    }
                }
                else if (value[i] == '\'')
                {
                    if (!flag)
                    {
                        writer.Write("'");
                        flag = true;
                    }
                    writer.Write("''");
                }
                else
                {
                    if (!flag)
                    {
                        writer.Write("'");
                        flag = true;
                    }
                    writer.Write(value[i]);
                }
                if (wrappedTextWriter.Column >= wrapColumn - 1 && i < value.Length - 1)
                {
                    if (flag)
                    {
                        writer.Write("'");
                        flag = false;
                    }
                    writer.WriteLine(" +");
                    flag = false;
                }
            }
            if (flag)
            {
                writer.Write("'");
            }
        }

        public static void ValidateIdentifier(string value)
        {
            if (!IsValidIdentifier(value))
            {
                throw new ArgumentException(string.Format(GetString("strInvalidIdentifier"), value));
            }
        }

        public static void VerifyImports(IDictionary imports, ArrayList typeDeclarations)
        {
            ArrayList arrayList = new ArrayList();
            ArrayList arrayList2 = new ArrayList();
            foreach (DictionaryEntry import in imports)
            {
                if ((bool)import.Value)
                {
                    continue;
                }
                string text = (string)import.Key;
                if (string.Compare(text, "ObjectPascal.System", ignoreCase: true) == 0 || string.Compare(text, "System", ignoreCase: true) == 0)
                {
                    arrayList.Add(text);
                    continue;
                }
                while (true)
                {
                    if (typeDeclarations.Contains(text))
                    {
                        arrayList.Add(text);
                        text = null;
                        break;
                    }
                    if (Type.GetType(text, throwOnError: false) != null)
                    {
                        arrayList.Add(text);
                        int num = text.LastIndexOf('.');
                        if (num > 0)
                        {
                            text = text.Substring(0, num);
                            continue;
                        }
                        text = null;
                        break;
                    }
                    int num2 = text.LastIndexOf('.');
                    if (num2 > 0)
                    {
                        string item = text.Substring(num2 + 1, text.Length - num2 - 1);
                        if (typeDeclarations.Contains(item))
                        {
                            arrayList.Add(text);
                            text = text.Substring(0, num2);
                        }
                        else
                        {
                            text = null;
                        }
                    }
                    else
                    {
                        text = null;
                    }
                    break;
                }
                if (text != null)
                {
                    arrayList2.Add(text);
                }
            }
            foreach (string item2 in arrayList)
            {
                imports.Remove(item2);
            }
            foreach (string item3 in arrayList2)
            {
                imports[item3] = true;
            }
        }
    }

}