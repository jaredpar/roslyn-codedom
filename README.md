# Simplify in memory compilation for .NET Core

[Roslyn](https://github.com/dotnet/roslyn) and the [CodeDom](https://docs.microsoft.com/en-us/dotnet/framework/reflection-and-codedom/using-the-codedom), 
are two powerful APIs for compiling code inside your .NET application. Provide them code,
a few options and a set of references and they will do the heavy lifting of creating the IL 
or semantic model.

The library also provides a sample `CodeDomProvider` that uses Roslyn in memory compilations
instead of the .NET Framework version which shells out to csc.exe. This library targets 
.NET Standard 2.0 hence it will run on .NET Core or Framework.

This `CodeDom` implementation also allows the author to choose the target framework that the
code is compiled against: `netstandard2.0`, `netcoreapp3.1` or `net5.0`. 

```cs
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
cp.OutputAssembly = Path.Combine(@"p:\temp", "helloworld.exe");
cp.GenerateInMemory = false;

var provider = new RoslynCodeDomProvider(TargetFramework.Net50);
var results = provider.CompileAssemblyFromSource(cp, new[] { code });
```

This is a prototype implementation, more proof of concept. It doesn't yet support the full
set of options available to the .NET Framework implementation.
