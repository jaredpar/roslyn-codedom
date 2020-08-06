using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using System;
using System.Runtime.Versioning;
using Xunit;

namespace Roslyn.CodeDom.UnitTests
{
    public class ExampleUnitTests
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

        [Theory]
        [InlineData(TargetFramework.NetCoreApp31)]
        [InlineData(TargetFramework.NetStandard20)]
        public void Tuples(TargetFramework targetFramework)
        {
            var code = @"
using System;
static class Program
{
    static void Main()
    {
        var tuple = (Part1: ""hello"", Part2: ""world"");
        Console.WriteLine($""{tuple.Part1} {tuple.Part2}"");
    }
}
";

            var compilation = CSharpCompilation
                .Create(
                    "HelloWorld.dll",
                    new[] { CSharpSyntaxTree.ParseText(code) })
                .WithFrameworkReferences(targetFramework);
            Assert.Empty(compilation.GetDiagnostics());
            var tuple = compilation.Emit();
            Assert.Empty(tuple.EmitResults.Diagnostics);
            Assert.True(tuple.EmitResults.Success);
        }
    }
}
