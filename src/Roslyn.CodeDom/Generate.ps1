function Add-TargetFramework($name, $packagePath)
{
  [string]$nugetPackageRoot = $env:NUGET_PACKAGES
  if ($nugetPackageRoot -eq "")
  {
    $nugetPackageRoot = Join-Path $env:USERPROFILE ".nuget\packages"
  }

  $realPackagePath = Join-Path $nugetPackageRoot $packagePath 
  $list = Get-ChildItem -filter *.dll $realPackagePath | %{ $_.FullName }
  $resourceTypeName = "Resources" + $name
  $script:codeContent += @"
        public static class $resourceTypeName
        {

"@;

  $refContent = @"
        public static class $name
        {

"@

  $nugetPackagePath = '$(NugetPackageRoot)\' + $packagePath
  $name = $name.ToLower()
  foreach ($dllPath in $list)
  {
    if ($dllPath.Contains('#'))
    {
      $all = $dllPath.Split('#')
      $dllName = $all[0]
      $dllPath = $all[1]
      $dll = Split-Path -leaf $dllPath
      $logicalName = "$($dllName.ToLower()).$($name).$($dll)";
    }
    else
    {
      $dll = Split-Path -leaf $dllPath
      $dllName = $dll.Substring(0, $dll.Length - 4)
      $logicalName = "$($name).$($dll)";
    }

    $script:targetsContent += @"
        <EmbeddedResource Include="$nugetPackagePath\$dllPath">
          <LogicalName>$logicalName</LogicalName>
        </EmbeddedResource>

"@

    $propName = $dllName.Replace(".", "");
    $fieldName = "_" + $propName
    $script:codeContent += @"
            private static byte[] $fieldName;
            public static byte[] $propName => ResourceLoader.GetOrCreateResource(ref $fieldName, "$logicalName");

"@

    $refContent += @"
            public static PortableExecutableReference $propName { get; } = AssemblyMetadata.CreateFromImage($($resourceTypeName).$($propName)).GetReference(display: "$dll ($name)");

"@

  }

  $script:codeContent += @"
        }

"@

    $script:codeContent += $refContent;
    $script:codeContent += @"
        }

"@
}

$targetsContent = @"
<Project>
    <ItemGroup>

"@;

$codeContent = @"
// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

// This is a generated file, please edit Generate.ps1 to change the contents

using Microsoft.CodeAnalysis;

namespace Roslyn.CodeDom
{
    public static class TestMetadata
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
}
"@

$targetsContent | Out-File "Generated.targets" -Encoding Utf8
$codeContent | Out-File "Generated.cs" -Encoding Utf8
