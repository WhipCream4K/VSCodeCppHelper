# Path to the .vcxproj file
param(
    [string]$vcxprojFilePath
)

Import-Module .\utils.psm1


# Path to generate the premake5.lua
$premakeFilePath = "./premake5.lua"

$ProjectName = "MyProject"
$SourceFiles = @()
$AdditionalIncludeDirs = @()
$OutDir = "bin/%{cfg.buildcfg}/%{cfg.platform}"


if (-Not $vcxprojFilePath) {
    Write-Host "Usage: .\premake_generator.ps1 -vcxprojFilePath <path_to_your_vcxproj_file>"
    Write-Host "OR generate default premake5.lua file"
} else {
    . .\premake_props.ps1 -vcxprojFilePath $vcxprojFilePath
}

$premakeScript = @"
workspace "MyWorkspace"
    configurations { "Debug", "Release" }
    platforms { "Win32", "x64" }

project "$ProjectName"
    location "./$ProjectName"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++20"
    targetdir "$OutDir"
    objdir "Intermediate/%{cfg.buildcfg}"

    files {
        $( $SourceFiles | ForEach-Object { if ($_.Equals($SourceFiles[0])) { '"' + $_ + '"' + "," + "`n" } else { "`t`t" + '"' + $_ + '"' + "," + "`n" } } )
    }

    includedirs {
        $( $AdditionalIncludeDirs | ForEach-Object { $convertedPath = Convert-VsToPremake -Tokens $_; if ($_.Equals($AdditionalIncludeDirs[0])) { '"' + $convertedPath + '"' + "," + "`n" } else { "`t`t" + '"' + $convertedPath + '"' + "," + "`n" } } )
    }

    filter { "configurations:Debug" }
        defines { "DEBUG" }
        symbols "On"

    filter { "configurations:Release" }
        defines { "NDEBUG" }
        optimize "On"
"@

# Create new premake5.lua file
if (-Not (Test-Path $premakeFilePath)) {
    New-Item -Path $premakeFilePath -ItemType File -Value $premakeScript
} else {
    Set-Content -Path $premakeFilePath -Value $premakeScript
}
