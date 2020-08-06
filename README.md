# Simplify in memory compilation for .NET Core

[Roslyn](https://github.com/dotnet/roslyn) and the [CodeDom](https://docs.microsoft.com/en-us/dotnet/framework/reflection-and-codedom/using-the-codedom), 
are two powerful APIs for compiling code inside your .NET application. Provide them code,
a few options and a set of references and they will do the heavy lifting of creating the IL 
or semantic model.

These technologies are very straight forward to use when running on .NET Framework
because implementation assemblies can substitute for reference assemblies. That means if
a user wants to add a reference to `System.Core.dll` to the compiler all they need to do
is use the runtime assembly:

```cs
var systemCoreAssembly = typeof(System.Linq.Enumerable).Assembly;
var systemCorePath = systemCoreAssembly.Location;
```

This does not work on .NET Core though because there is a strong split between reference
and implementation assemblies. The above code will give you access to the implementation 
assembly on .NET Core and is not a supported input for compilation. Instead you need to 
get the actual reference assembly.

Unfortunately the .NET Core runtime does not ship reference assemblies, they are only 
included in the .NET SDK. Hence any library or application that wants to compile code 
at runtime must package up the reference assemblies themselves and provide them to 
Roslyn. This can be quite tedious.

The `Roslyn.CodeDom` library takes care of this heavy lifting and provides the reference
assemblies for `netstandard2.0` and `netcoreapp3.1`. It also provides extension methods
to integrate them into Roslyn's APIs.

```cs
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
        new[] { CSharpSyntaxTree.ParseText(code) });

// Add in the netcoreapp3.1 reference assemblies 
compilation = compilation.WithFrameworkReferences(TargetFramework.NetCoreApp31);

using var fileStream = new FileStream(@"p:\temp\helloworld.exe", FileMode.Create, FileAccess.ReadWrite);
var emitResults = compilation.Emit(fileStream);
```

The library also provides a sample `CodeDomProvider` that can serve as a replacement
for the .NET Framework version.

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

var provider = new RoslynCodeDomProvider(targetFramework);
var results = provider.CompileAssemblyFromSource(cp, new[] { code });
```

Together these make it much simpler to approach compilation inside your libraries
or application.

**Note** .NET Framework also has a split between reference and implementation 
assemblies but it is not as strong as on .NET Core.