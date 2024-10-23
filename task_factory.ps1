class TaskJsonGenerator {
    [string]$Version
    [string]$ProjectDir
    [string]$MSBuildTarget
    [System.Collections.Specialized.OrderedDictionary]$Content

    TaskJsonGenerator([string]$version,[string]$projectDir,[string]$msbuildTarget) {
        $this.Version = $version
        $this.ProjectDir = $projectDir
        $this.MSBuildTarget = $msbuildTarget
    }

    [void]Generate(){
        $this.Content = [ordered]@{
            "version" = $this.Version
            "task" = @{
                "label" = "msbuild `${command:cpptools.activeConfigName}"
                "type" = "shell"
                "command" = "$($this.MSBuildTarget)"
                "args" = @(
                    "$($this.ProjectDir)/*.sln"
                    '/property:Configuration=${input:configuration}'
                    '/p:Platform=${input:platform}'
                )
                "group" = @{
                    "kind" = "build"
                    "isDefault" = $true
                }
                "problemMatcher" = @(
                    "`$msCompile"
                )
                "detail" = "Build sln in current configuration"
            }
            "inputs" = @(
                @{
                    "id" = "configuration"
                    "type" = "command"
                    "command" = "cpptools.activeConfigCustomVariable"
                    "args" = "configuration"
                },
                @{
                    "id" = "platform"
                    "type" = "command"
                    "command" = "cpptools.activeConfigCustomVariable"
                    "args" = "platform"
                }
            )
        }


    }

    [void]SaveToFile([string]$location) {
        # turns content into json file
        $filePath = "$($location)/tasks.json"
        $this.Content | ConvertTo-Json | Set-Content $filePath -Encoding UTF8
        Write-Host "tasks.json file has been generated at $filePath"
    }
}
