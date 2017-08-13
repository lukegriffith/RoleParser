<#
    .Synopsis
    



#>
function GetProfile {

    Param(
        [String]$etc,
        [Parameter(ValueFromPipeline)]
        [Machine[]]$Machine,
        [Role]$Role,
        [switch]$Recurse
    )

    Process {
        foreach($m in $Machine) {

            if ($m | Where-Object $Role.Where) {
                Write-Output $Role.Profiles
            }

            if ($Recurse.IsPresent) {
                $childCount = $role.Children.count

                for ($i = 0; $i -lt $childCount; $i++) {

                    $child = $role.Children[$i]
                    $Machine | GetProfile -Role $child -Recurse
                }
            }

        }
    }

}
