

function Get-Role {
    Param(
        $RoleName
    )

    GetRole -etc "$PSScriptRoot/etc" -name $roleName
}