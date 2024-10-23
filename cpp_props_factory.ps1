class CppPropsFactory {
    [string] $Version
    [System.Collections.Specialized.OrderedDictionary]$Content


    CppPropsFactory([string]$version) {
        $this.Version = $version
    }

    [void]Generate()
    {
        $this.Content = [ordered]@{
            "env" = @{
                "includeDirs" = @(
                )
                "globalDefines" = @(
                    "UNICODE",
                    "_UNICODE"
                )
            }
            "configurations" = @(
                @{
                    "name" = "Debug-Win32"
                    "includePath" = @( 
                        '${includeDirs}'
                    )
                    "defines" = @(
                        "_DEBUG",
                        "WIN32",
                        '${globalDefines}'
                    )
                    "windowsSdkVersion" = "10.0.22621.0"
                    "cppStandard" = "c++20"
                    "intelliSenseMode" = "windows-msvc-x86"
                    "customConfigurationVariables" = @{
                        "platform" = "Win32"
                        "configuration" = "Debug"
                    }
                },
                @{
                    "name" = "Release-Win32"
                    "includePath" = @( 
                        '${includeDirs}'
                    )
                    "defines" = @(
                        "WIN32",
                        "NDEBUG",
                        '${globalDefines}'
                    )
                    "windowsSdkVersion" = "10.0.22621.0"
                    "cppStandard" = "c++20"
                    "intelliSenseMode" = "windows-msvc-x86"
                    "customConfigurationVariables" = @{
                        "platform" = "Win32"
                        "configuration" = "Release"
                    }
                },
                @{
                    "name" = "Debug-x64"
                    "includePath" = @( 
                        '${includeDirs}'
                    )
                    "defines" = @(
                        "_DEBUG",
                        '${globalDefines}'
                    )
                    "windowsSdkVersion" = "10.0.22621.0"
                    "cppStandard" = "c++20"
                    "intelliSenseMode" = "windows-msvc-x64"
                    "customConfigurationVariables" = @{
                        "platform" = "x64"
                        "configuration" = "Debug"
                    }
                },
                @{
                    "name" = "Release-x64"
                    "includePath" = @(
                        '${includeDirs}'
                    )
                    "defines" = @(
                        '${globalDefines}'
                    )
                    "windowsSdkVersion" = "10.0.22621.0"
                    "cppStandard" = "c++20"
                    "intelliSenseMode" = "windows-msvc-x64"
                    "customConfigurationVariables" = @{
                        "platform" = "x64"
                        "configuration" = "Release"
                    }
                }
            )
            "version" = $this.Version
        }
    }

    
    [void]SaveToFile([string]$location) {  
        $this.Content | ConvertTo-Json -Depth 4 | Set-Content "$location/c_cpp_properties.json" -Encoding UTF8
    }
}