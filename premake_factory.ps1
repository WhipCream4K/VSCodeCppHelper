
# This class is used to generate premake5.lua file
# Note: This class will leave files and libdirs empty
# Because usually it requires a manual directory navigation
class PremakeGenerator {
    [string]$ProjectName
    [string]$ProjectDir
    [string]$Kind
    [string]$TargetDir
    [string]$WarningsLevel
    [string]$Content
    [string]$IncludeDirs
    [string]$WorkspaceDir

    PremakeGenerator([string]$workspaceDir,[string]$projectName, [string]$projectDir, [string]$kind, [string]$targetDir,[string]$warningLevel) {
        $this.ProjectName = $projectName
        $this.ProjectDir = $projectDir
        $this.Kind = $kind
        $this.TargetDir = $targetDir
        $this.IncludeDirs = @()
        $this.WarningsLevel = $warningLevel
        $this.WorkspaceDir = $workspaceDir
    }

    [void]Generate() {

        $this.Content = @"
workspace "$($this.ProjectName)"
    configurations { "Debug", "Release" }
    platforms {"Win32", "x64"}
    location "$($this.WorkspaceDir)"

project "$($this.ProjectName)"
    kind "$($this.Kind)"
    targetdir "$($this.TargetDir)/%{cfg.buildcfg}/%{cfg.platform}"
    objdir "$($this.WorkspaceDir)/Intermediate/%{cfg.buildcfg}/%{cfg.platform}"
    location "$($this.ProjectDir)"
    warnings "$($this.WarningsLevel)"

    files {  }

    includedirs { $($this.IncludeDirs) }

    libdirs { }

    filter {"action:vs*"}
        cppdialect "C++20"

    filter {"configurations:Debug"}
        defines {"_DEBUG"}
        symbols "On"

    filter {"configurations:Release"}
        defines {"NDEBUG"}
        optimize "On"
    
    filter {"platforms:Win32"}
        defines {"WIN32"}    

    filter {"kind:ConsoleApp"}
        defines {"_CONSOLE"}
    
"@
    }

    [void]SetIncludeDirs([string[]]$files) {
        $this.Files = $files
    }

    [void]SaveToFile([string]$location) {
        $filePath = "$($location)/premake5.lua"
        $this.Content | Out-File -FilePath $filePath -Encoding UTF8
        Write-Output "premake5.lua file has been generated at $filePath"
    }
}
