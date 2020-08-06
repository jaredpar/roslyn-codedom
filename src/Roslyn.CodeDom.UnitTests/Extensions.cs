
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.Emit;
using System;
using System.IO;
using System.Runtime.Versioning;
using Xunit;

namespace Roslyn.CodeDom.UnitTests
{
    internal static class Extensions
    {
        internal static (EmitResult EmitResults, MemoryStream PeStream) Emit(this Compilation compilation)
        {
            var memoryStream = new MemoryStream();
            var results = compilation.Emit(memoryStream);
            memoryStream.Position = 0;
            return (results, memoryStream);
        }
    }
}
