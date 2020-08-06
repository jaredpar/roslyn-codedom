using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using System;
using System.Runtime.Versioning;
using Xunit;

namespace Roslyn.CodeDom.UnitTests
{
    public class Examples
    {
        [Theory]
        [InlineData(TargetFramework.NetCoreApp31)]
        [InlineData(TargetFramework.NetStandard20)]
        public void HelloWorld(TargetFramework targetFramework)
        {
            var code = @"
using System;
static class Program
{
    static void Main()
    {
        Console.WriteLine(""Hello World"");
    }
}
";

            var compilation = CSharpCompilation
                .Create(
                    "HelloWorld.dll",
                    new[] { CSharpSyntaxTree.ParseText(code) })
                .WithFrameworkReferences(targetFramework);
            Assert.Empty(compilation.GetDiagnostics());
            compilation.Emit();
        }
    }
}
