<#

    .Synopsis
    Internal functon that retrives the role hierarchy for a single role file. 

    .Description
    Parses the YAML file, and created the hierarchy.

#>
function GetRole {
    param(
        [Parameter(DontShow=$true)]
        [string] $etc = "$PSScriptRoot/etc",
        [string] $name
    )

    $yaml_raw = Get-Content "$etc/$name.yml" -raw

    $yaml = ConvertFrom-Yaml -Yaml $yaml_raw -AllDocuments


    $root = $yaml | Where-Object {$_.Root}

    RecurseRole $root $yaml


}
