<#
    .Synopsis
    Given a role object, will recursively link the profiles children in a queue.

    .Description
    Obtains children for object, using a queue to store the 

#>
function RecurseRole {
    param(
        $role,
        $yaml,
        [role]$parent
    )

    $role_obj = [Role]::new($role)

    if ($PSBoundParameters.ContainsKey("parent")) {
        $role_obj.Parent = $parent
    }


    $childCount = $role.Children.count

    for ($i = 0; $i -lt $childCount; $i++) {

        $child = $role.Children[$i]

        if ($child -is [string]) {
            $child = $yaml | Where-Object {$_.RoleName -eq $child} 
        }

        $role_obj.Children += RecurseRole $child $yaml $role_obj
    }

    Write-Output $role_obj
}