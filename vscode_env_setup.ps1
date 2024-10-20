#this script will create launch.json and tasks.json files in .vscode folder

param (
    [string]$vcxprojFilePath
)

# task.json file

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

# Create Task.json at .vscode folder also checks if .vscode folder exists if not then create one
if (-Not (Test-Path "../.vscode")) {
    New-Item -Path "../.vscode" -ItemType Directory
}

$vscodePath = "../.vscode"

$tasksJson = @"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "msbuild x64 Debug",
            "type": "shell",
            "command": "$msbuild",
            "args": [
                "`$`{workspaceFolderBasename}.sln",
                "/p:Configuration=Debug",
                "/p:Platform=x64"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": [
                "`$msCompile`"
            ],
            "detail": "Build the solution using msbuild in debug mode"
        },
        {
            "label": "msbuild x64 Release",
            "type": "shell",
            "command": "$msbuild",
            "args": [
                "`$`{workspaceFolderBaseName}.sln",
                "/property:Configuration=Release",
                "/p:Platform=x64"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": [
                "`$msCompile`"
            ],
            "detail": "Build the solution using msbuild in release mode"
        }
    ]
}
"@

# Create the tasks.json file with the defined content
New-Item -Path "$vscodePath/tasks.json" -ItemType File -Value $tasksJson

# Create Launch.json at .vscode folder also checks if .vscode folder exists if not then create one

# We need to get out dir for each configuration first

$outDirs = & .\get_outdir.ps1 $vcxprojFilePath

$debugX64OutDir = $outDirs.DebugX64OutDir
$releaseX64OutDir = $outDirs.ReleaseX64OutDir


$launchJson = @"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(Windows) Launch x64 Debug",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${debugX64OutDir}`$`{workspaceFolderBasename}.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "`${fileDirname}`",
            "environment": [],
            "console": "externalTerminal",
            "preLaunchTask": "msbuild x64 Debug"
        },
        {
            "name": "(Windows) Launch x64",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${releaseX64OutDir}`${workspaceFolderBaseName}`.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "`${fileDirname}`",
            "environment": [],
            "console": "externalTerminal",
            "preLaunchTask": "msbuild x64 Release"
        }
    ]
}
"@

New-Item -Path "$vscodePath/launch.json" -ItemType File -Value $launchJson

# also run cpp_props_update.ps1
./cpp_props_update.ps1 $vcxprojFilePath
