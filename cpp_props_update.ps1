# This script updates include directories and preprocessor definitions in c_cpp_properties.json file

param (
    [string]$vcxprojFilePath,
    [string]$cppPropertiesFilePath = "../.vscode/c_cpp_properties.json"
)

# Check if the file path is provided
if (-Not $vcxprojFilePath) {
    Write-Host "Usage: .\props-update.ps1 -vcxprojFilePath <path_to_your_vcxproj_file>"
    exit
}

# Check if the file exists
if (-Not (Test-Path $vcxprojFilePath)) {
    Write-Host "The specified file does not exist. Please check the path and try again."
    exit
}

# Check if cpp_properties.json file exists if not then create one also check if .vscode folder exists
if (-Not (Test-Path $cppPropertiesFilePath)) {

    if (-Not (Test-Path "../.vscode")) {
        New-Item -Path "../.vscode" -ItemType Directory
    }

    New-Item -Path $cppPropertiesFilePath -ItemType File

}

# Load the XML file
[xml]$vcxproj = Get-Content $vcxprojFilePath

# Define the condition for x64 Release
$condition = "'`$(Configuration)|`$(Platform)'=='Debug|x64'"

# Find the specific ItemDefinitionGroup for x64 Release based on the Condition
$itemDefinitionGroup = $vcxproj.Project.ItemDefinitionGroup | Where-Object { $_.Condition -eq $condition }


if ($null -ne $itemDefinitionGroup) 
{
    $includeDirectories = $itemDefinitionGroup.ClCompile.AdditionalIncludeDirectories

    $preprocessorDefinitions = $itemDefinitionGroup.ClCompile.PreprocessorDefinitions
}

# Conform VS macros with VS Code labels
$includeDirectories = $includeDirectories -replace '\$\(SolutionDir\)', '${workspaceFolder}'
$includeDirectories = $includeDirectories -replace '%\(AdditionalIncludeDirectories\)', ''
$preprocessorDefinitions = $preprocessorDefinitions -replace '%\(PreprocessorDefinitions\)', ''

$includeDirsArray = $includeDirectories -split ';' | Where-Object { $_ -ne '' }
$preprocessorDefinitionsArray = $preprocessorDefinitions -split ';' | Where-Object { $_ -ne '' }

# Load the c_cpp_properties.json file
$json = Get-Content $cppPropertiesFilePath -Raw | ConvertFrom-Json

# Append the include directories to the includePath
$json.configurations[0].includePath += $includeDirsArray

# Ensure 'defines' property exists
if (-Not $json.configurations[0].PSObject.Properties['defines']) {
    $json.configurations[0] | Add-Member -MemberType NoteProperty -Name defines -Value @()
}

# Check that defines doesn't contain duplicates
foreach ($define in $preprocessorDefinitionsArray) {
    if ($json.configurations[0].defines -notcontains $define) {
        $json.configurations[0].defines += $define
    }
}


# Save the updated c_cpp_properties.json file
$json | ConvertTo-Json -Depth 4 | Set-Content $cppPropertiesFilePath


Write-Host "AdditionalIncludeDirectories:"
$includeDirectories -split ';' | ForEach-Object { Write-Host "`t$_" }

Write-Host "`nPreprocessorDefinitions (Release|x64):"
$preprocessorDefinitions -split ';' | ForEach-Object { Write-Host "`t$_" }

Write-Host "Additional include directories have been appended to the includePath in $cppPropertiesFilePath"

# Change OutDir for launch.json

$launchJsonPath = "../.vscode/launch.json"
$launchJson = Get-Content $launchJsonPath -Raw | ConvertFrom-Json

$outDirs = & .\get_outdir.ps1 $vcxprojFilePath

$debugX64OutDir = $outDirs.DebugX64OutDir
$releaseX64OutDir = $outDirs.ReleaseX64OutDir

# Find LauchJson for x64 Debug and change its program property to debugX64OutDir
$launchJson.configurations | ForEach-Object {
    if ($_.name -eq "Launch x64 Debug") {
        $_.program = $debugX64OutDir
    }
}

# Find LauchJson for x64 and change its program property to releaseX64OutDir
$launchJson.configurations | ForEach-Object {
    if ($_.name -eq "Launch x64") {
        $_.program = $releaseX64OutDir
    }
}

$launchJson | ConvertTo-Json -Depth 4 | Set-Content $launchJsonPath