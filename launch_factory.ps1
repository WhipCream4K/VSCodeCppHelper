class LaunchJsonGenerator {
    [string]$Version
    [string]$TargetName
    [string]$WorkspaceDir
    [System.Collections.Specialized.OrderedDictionary]$Content

    LaunchJsonGenerator([string]$version, [string]$targetName, [string]$workspaceDir) {
        $this.Version = $version
        $this.TargetName = $targetName
        $this.WorkspaceDir = $workspaceDir
        $this.Content = [ordered]@{}
    }

    [void]Generate() {
        $this.Content = [ordered]@{
            "version"       = $this.Version
            "configurations" = @(
                [ordered]@{
                    "name"          = '(Windows) Launch ${command:cpptools.activeConfigName}'
                    "type"          = "cppvsdbg"
                    "request"       = "launch"
                    # it only make sense to target the Debug directory
                    "program"       = "$($this.WorkspaceDir)/Debug/`${input:platform}/$($this.TargetName).exe"
                    "args"          = @('')
                    "stopAtEntry"   = $false
                    "cwd"           = '${fileDirname}'
                    "environment"   = @('')
                    "console"       = "externalTerminal"
                    "preLaunchTask" = 'msbuild'
                }
            )
            "inputs" = @(
                [ordered]@{
                    "id"      = "platform"
                    "type"    = "command"
                    "command" = "cpptools.activeConfigCustomVariable"
                    "args"    = "platform"
                }
            )
        }

    }

    [void]SaveToFile([string]$location) {
        $this.Content | ConvertTo-Json | Set-Content "$location/launch.json" -Encoding UTF8
        Write-Host "launch.json file has been generated at $location"
    }
}
