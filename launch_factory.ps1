class LaunchJsonGenerator {
    [string]$Version
    [string]$TargetName
    [string]$TargetDir
    [System.Collections.Specialized.OrderedDictionary]$Content

    LaunchJsonGenerator([string]$version, [string]$targetName, [string]$targetDir) {
        $this.Version = $version
        $this.TargetName = $targetName
        $this.TargetDir = $targetDir
        $this.Content = [ordered]@{}
    }

    [void]Generate() {
        $this.Content = [ordered]@{
            "version"       = $this.Version
            "configurations" = @(
                @{
                    "name"          = '(Windows) Launch ${command:cpptools.activeConfigName}'
                    "type"          = "cppvsdbg"
                    "request"       = "launch"
                    "program"       = "$($this.TargetDir)/`${input:configuration}/`${input:platform}/$($this.TargetName).exe"
                    "args"          = @('')
                    "stopAtEntry"   = $false
                    "cwd"           = '${fileDirname}'
                    "environment"   = @('')
                    "console"       = "externalTerminal"
                    "preLaunchTask" = 'msbuild'
                }
            )
            "inputs" = @(
                @{
                    "id"      = "configuration"
                    "type"    = "command"
                    "command" = "cpptools.activeConfigCustomVariable"
                    "args"    = "configuration"
                },
                @{
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
