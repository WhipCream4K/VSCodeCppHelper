#this script will create launch.json and tasks.json files in .vscode folder


param (
    [string]$ProjectName = "",
    [string]$Kind = "",
    [string]$OutPath = ""
)


# Just error reminder to input params
if ($ProjectName -eq "" -or $Kind -eq "" -or $OutPath -eq "") {
    Write-Host "Please input ProjectName, Kind and OutPath"
    exit 1
}

# before we create we need to locate msbuild.exe to be used by vscode at command
function Get-MsBuildPath {
    $msbuildPaths = @(
        "$env:ProgramFiles\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "$env:ProgramFiles\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "$env:ProgramFiles\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "$env:ProgramFiles\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "$env:ProgramFiles\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "$env:ProgramFiles(x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe",
        "$env:ProgramFiles(x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe",
        "$env:ProgramFiles(x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
    )

    foreach ($path in $msbuildPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    # If MSBuild.exe is not found in the default locations
    return $null
}

$msbuild = Get-MsBuildPath

if ($msbuild) {
    Write-Host "Found msbuild.exe at: $msbuild"
} else {
    Write-Host "msbuild.exe not found in the default locations. Please install Visual Studio 2017 or later."
    exit 1
}

$msbuild = $msbuild -replace '\\', '/'

$vscodePath = "$OutPath/.vscode"

# Create Task.json at .vscode folder also checks if .vscode folder exists if not then create one
if (-Not (Test-Path $vscodePath)) {
    New-Item -Path $vscodePath -ItemType Directory
}

. ./premake_factory.ps1
. ./task_factory.ps1
. ./launch_factory.ps1
. ./cpp_props_factory.ps1


# Edit this properties to your needs (premake)
$workspaceDir = "." # workspace dir is relative to output path
$projectOutDir = "$workspaceDir/bin"
$projectLocation = "$workspaceDir/$ProjectName"
$waringLevel = "Extra"

$premakeScript = [PremakeGenerator]::new($workspaceDir,$ProjectName, $projectLocation, $Kind, $projectOutDir, $waringLevel)
$taskJson = [TaskJsonGenerator]::new("2.0.0", $ProjectName,$workspaceDir, $msbuild)
$launchJson = [LaunchJsonGenerator]::new("0.2.0", $ProjectName, $workspaceDir)
$cppPropsJson = [CppPropsFactory]::new("4")

$premakeScript.Generate()
$taskJson.Generate()
$launchJson.Generate()
$cppPropsJson.Generate()

$premakeScript.SaveToFile($OutPath)
$taskJson.SaveToFile($vscodePath)
$launchJson.SaveToFile($vscodePath)
$cppPropsJson.SaveToFile($vscodePath)