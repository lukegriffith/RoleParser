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

            [boolean]$InRole = $m | Where-Object $Role.Where

            if ($InRole) {
                Write-Output $Role.Profiles
            }

            if ($Recurse.IsPresent -and $InRole) {
                $childCount = $role.Children.count

                for ($i = 0; $i -lt $childCount; $i++) {

                    $child = $role.Children[$i]
                    $Machine | GetProfile -Role $child -Recurse
                }
            }

        }
    }

}
