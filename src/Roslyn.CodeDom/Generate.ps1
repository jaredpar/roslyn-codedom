function Add-TargetFramework($name, $packagePath)
{
  [string]$nugetPackageRoot = $env:NUGET_PACKAGES
  if ($nugetPackageRoot -eq "")
  {
    $nugetPackageRoot = Join-Path $env:USERPROFILE ".nuget\packages"
  }

  $realPackagePath = Join-Path $nugetPackageRoot $packagePath 
  $resourceTypeName = $name + "Resources"
  $script:codeContent += @"
    internal static class $resourceTypeName
    {

"@;

  $refContent = @"
    public static class $name
    {

"@

  $name = $name.ToLower()
  $list = Get-ChildItem -filter *.dll $realPackagePath | %{ $_.FullName }
  $allPropNames = @()
  foreach ($dllPath in $list)
  {
    $dllName= Split-Path -Leaf $dllPath
    $dll = $dllName.Substring(0, $dllName.Length - 4)
    $logicalName = "$($name).$($dll)";
    $dllPath = $dllPath.Substring($nugetPackageRoot.Length)
    $dllPath = '$(NuGetPackageRoot)' + $dllPath

    $script:targetsContent += @"
        <EmbeddedResource Include="$dllPath">
          <LogicalName>$logicalName</LogicalName>
          <Link>Resources\$name\$dllName</Link>
        </EmbeddedResource>

"@

    $propName = $dll.Replace(".", "");
    $allPropNames += $propName
    $fieldName = "_" + $propName
    $script:codeContent += @"
        private static byte[] $fieldName;
        internal static byte[] $propName => ResourceLoader.GetOrCreateResource(ref $fieldName, "$logicalName");

"@

    $refContent += @"
        public static PortableExecutableReference $propName { get; } = AssemblyMetadata.CreateFromImage($($resourceTypeName).$($propName)).GetReference(display: "$dll ($name)");

"@

  }

  $refContent += @"
        public static IEnumerable<PortableExecutableReference> All { get; }= new PortableExecutableReference[]
        {

"@;
    foreach ($propName in $allPropNames)
    {
      $refContent += @"
            $propName,

"@
    }

    $refContent += @"
        };
    }

"@

    $script:codeContent += @"
    }

"@
    $script:codeContent += $refContent;
}

$targetsContent = @"
<Project>
    <ItemGroup>

"@;

$codeContent = @"
// This is a generated file, please edit Generate.ps1 to change the contents

using System.Collections.Generic;
using Microsoft.CodeAnalysis;

namespace Roslyn.CodeDom.References
{

"@

Add-TargetFramework "NetCoreApp31" 'Microsoft.NETCore.App.Ref\3.1.0\ref\netcoreapp3.1' 

Add-TargetFramework "NetStandard20" 'netstandard.library\2.0.3\build\netstandard2.0\ref'

$targetsContent += @"
  </ItemGroup>
</Project>
"@;

$codeContent += @"
}
"@

$targetsContent | Out-File "Generated.targets" -Encoding Utf8
$codeContent | Out-File "Generated.cs" -Encoding Utf8
