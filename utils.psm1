function Get-VcxprojProperty {
    param (
        [xml]$vcxprojXML,
        [stirng]$groupName,
        [string]$propertyName,
        [string]$condition = "Release|x64"
    )
    
    $nodes = $vcxprojXML.Project.$groupName | Where-Object { $_.'Condition' -eq $condition } | Select-Object -ExpandProperty $propertyName

    return $nodes
}

# Function to get OutDir or use default
function Get-OutDirOrDefault {
    param (
        [xml]$vcxproj,
        [string]$condition
    )

    $outDir = $null
    foreach ($propertyGroup in $vcxproj.Project.PropertyGroup) {
        $outDir = $propertyGroup |
        Where-Object { $_.Condition -eq $condition } |
        Select-Object -ExpandProperty OutDir -ErrorAction SilentlyContinue

        if ($null -eq $outDir) {
            # generate default outDir for x64
            $outDir = "$'(SolutionDir)$'(Platform)\'$'(Configuration)\"
        }
    }

    return $outDir
}

function Get-PropOrDefault {
    param (
        [xml]$vcxproj,
        [string]$groupName,
        [string]$propertyName,
        [string]$defaultValue,
        [string]$condition = "Release|x64"
    )

    $outDir = $null
    foreach ($propertyGroup in $vcxproj.Project.$groupName) {
        $outDir = $propertyGroup |
        Where-Object { $_.Condition -eq $condition } |
        Select-Object -ExpandProperty $propertyName -ErrorAction SilentlyContinue

        if ($null -eq $outDir) {
            $outDir = $defaultValue
        }
    }

    return $outDir
}

function ConvertTo-BackwardSlash {
    param (
        [string]$path
    )

    return $path -replace '/', '\\'
}

function ConvertTo-ForwardSlash {
    param (
        [string]$path
    )

    return $path -replace '\\', '/'
}

function AddTab {
    param (
        [string]$path
    )   

    $path += "\t"
    return $path
}

function AddLine {
    param (
        [string]$string
    )
    
    $string += "`n"
    return $string
}

# Convert-VsToPremake.psm1

function Convert-VsToPremake {
    param (
        [string]$Tokens
    )
  
    # Define a dictionary to map Visual Studio tokens to Premake tokens
    $tokenMap = @{
        '\$\((Configuration)\)' = '%{cfg.buildcfg}'
        '\$\((Platform)\)'      = '%{cfg.platform}'
        '\$\((Architecture)\)'  = '%{cfg.architecture}'
        '\$\((OutputPath)\)'    = '%{cfg.buildtarget}'
        '\$\((SolutionDir)\)'   = '%{wks.location}'
        '\$\((ProjectDir)\)'    = '%{prj.location}'
    }
  
    # Use regular expressions to replace Visual Studio tokens with Premake tokens
    foreach ($vsToken in $tokenMap.Keys) {
        $Tokens = $Tokens -replace $vsToken, $tokenMap[$vsToken]
    }
  
    return $Tokens
}
  

Export-ModuleMember -Function *