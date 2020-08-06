using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using System;
using System.CodeDom.Compiler;
using System.IO;
using System.Runtime.Versioning;
using Xunit;

namespace Roslyn.CodeDom.UnitTests
{
    public class CodeDomUnitTests : IDisposable
    {
        public string ScratchDirectory { get; }

        public CodeDomUnitTests()
        {
            ScratchDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
            Directory.CreateDirectory(ScratchDirectory);
        }

        public void Dispose()
        {
            Directory.Delete(ScratchDirectory, recursive: true);
        }

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

            var cp = new CompilerParameters();
            cp.GenerateExecutable = true;
            cp.OutputAssembly = Path.Combine(ScratchDirectory, "helloworld.exe");
            cp.GenerateInMemory = false;

            var provider = new RoslynCodeDomProvider(targetFramework);
            var results = provider.CompileAssemblyFromSource(cp, new[] { code });
            Assert.Equal(0, results.NativeCompilerReturnValue);
            Assert.Empty(results.Errors);
            Assert.Empty(results.Output);
            Assert.Null(results.CompiledAssembly);
        }
    }
}
