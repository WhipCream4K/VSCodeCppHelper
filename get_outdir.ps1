param(
    [string]$vcxprojFilePath
)

# Load the XML file
[xml]$vcxproj = Get-Content $vcxprojFilePath

# Function to get OutDir or use default
function Get-OutDirOrDefault {
    param (
        [System.Xml.XmlNode[]]$propertyGroups,
        [string]$condition,
        [string]$configuration
    )
    $outDir = $null
    foreach ($propertyGroup in $propertyGroups) {
        $outDir = $propertyGroup |
            Where-Object { $_.Condition -eq $condition } |
            Select-Object -ExpandProperty OutDir -ErrorAction SilentlyContinue

        if ($outDir) {
            $outDir = $outDir -replace '\$\(SolutionDir\)', '${workspaceFolder}'
            $outDir = $outDir -replace '\$\(Configuration\)', $configuration

            # change back slash to forward slash
            $outDir = $outDir -replace '\\', '/'
            break
        }
    }

    if (-Not $outDir) {
        $outDir = "`$`{workspaceFolder}"
        if ($configuration -eq "Debug") {
            $outDir = $outDir + "/x64/Debug/"
        }
        if ($configuration -eq "Release") {
            $outDir = $outDir + "/Release/"
        }
    }
    return $outDir
}


# Get OutDir for each configuration
$debugX64OutDir = Get-OutDirOrDefault -propertyGroup $vcxproj.Project.PropertyGroup -condition "'`$(Configuration)|`$(Platform)'=='Debug|x64'" -configuration "Debug"
$releaseX64OutDir = Get-OutDirOrDefault -propertyGroup $vcxproj.Project.PropertyGroup -condition "'`$(Configuration)|`$(Platform)'=='Release|x64'" -configuration "Release"

# Create and return a custom object
$result = [PSCustomObject]@{
    DebugX64OutDir   = $debugX64OutDir
    ReleaseX64OutDir = $releaseX64OutDir
}

return $result