# This script will define how properties are queried from vcxproj file

param (
    [string]$vcxprojFilePath
)

Import-Module .\utils.psm1

[xml]$vcxproj = Get-Content $vcxprojFilePath

$ProjectName = $vcxproj.Project.PropertyGroup | Where-Object { $_.Label -eq "Globals" } | Select-Object -ExpandProperty RootNamespace

$SourceFiles = $vcxproj.Project.ItemGroup.ClCompile | Select-Object -ExpandProperty Include

# Include Directories will get from debug x64
$AdditionalIncludeDirs = $vcxproj.Project.ItemDefinitionGroup |
    Where-Object { $_.Condition -eq "'`$(Configuration)|`$(Platform)'=='Debug|x64'" } |
    Select-Object -ExpandProperty ClCompile |
    Select-Object -ExpandProperty AdditionalIncludeDirectories

# make then join by semicolon
$AdditionalIncludeDirs = $AdditionalIncludeDirs -replace "%\(AdditionalIncludeDirectories\)", ''
$AdditionalIncludeDirs = $AdditionalIncludeDirs -split ";" | Where-Object { -not [string]::IsNullOrEmpty($_) }

$AdditionalIncludeDirs = $AdditionalIncludeDirs -replace '\\', '/'
