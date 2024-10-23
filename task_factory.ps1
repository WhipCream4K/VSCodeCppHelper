class TaskJsonGenerator {
    [string]$Version
    [string]$ProjectDir
    [string]$ProjectName
    [string]$MSBuildTarget
    [System.Collections.Specialized.OrderedDictionary]$Content

    TaskJsonGenerator([string]$version,[string]$projectName,[string]$projectDir,[string]$msbuildTarget) {
        $this.Version = $version
        $this.ProjectName = $projectName
        $this.ProjectDir = $projectDir
        $this.MSBuildTarget = $msbuildTarget
    }

    [void]Generate(){
        $this.Content = [ordered]@{
            "version" = $this.Version
            "tasks" = @(
                [ordered]@{
                    "label" = "msbuild"
                    "type" = "shell"
                    "command" = "$($this.MSBuildTarget)"
                    "args" = @(
                        "$($this.ProjectDir)/$($this.ProjectName).sln"
                        '/p:Configuration=${input:configuration}'
                        "/p:GenerateFullPaths=true"
                        '/p:Platform=${input:platform}'
                        "/consoleloggerparameters:NoSummary"
                        "/t:build"
                    )
                    "group" = "build"
                    "problemMatcher" = @(
                        "`$msCompile"
                    )
                    "presentation" = @{
                        "reveal" = "silent"
                    }
                    "detail" = "Build sln in current configuration"
                }
            )
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
