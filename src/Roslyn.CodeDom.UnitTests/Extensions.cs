
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using System;
using System.IO;
using System.Runtime.Versioning;
using Xunit;

namespace Roslyn.CodeDom.UnitTests
{
    internal static class Extensions
    {
        internal static MemoryStream Emit(this Compilation compilation)
        {
            var memoryStream = new MemoryStream();
            compilation.Emit(memoryStream);
            memoryStream.Position = 0;
            return memoryStream;
        }
    }
}
