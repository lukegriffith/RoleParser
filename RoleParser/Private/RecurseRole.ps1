<#
    .Synopsis
    Given a role object, will recursively link the profiles children in a queue.

    .Description
    Obtains children for object, using a queue to store the 

#>
function RecurseRole {
    [cmdletBinding()]
    param(
        $role,
        $yaml,
        [role]$parent,
        [System.Collections.Stack]$recursionStack
    )

    $role_obj = [Role]::new($role)

    if ($recursionStack.Contains($role_obj.RoleName)) {
        # Role is used twie in the hierarchy, will result in an endless recursion.
        $PSCmdlet.ThrowTerminatingError((New-Object System.Management.Automation.ErrorRecord(
            (New-Object Exception "Role $($role_obj.RoleName) used twice."),
            'CallDepthError',
            [System.Management.Automation.ErrorCategory]::ResourceExists,
            $role_obj
        )))
    }

    $recursionStack.push($role_obj.RoleName)

    if ($PSBoundParameters.ContainsKey("parent")) {
        $role_obj.Parent = $parent
    }

    $childCount = $role.Children.count

    for ($i = 0; $i -lt $childCount; $i++) {

        $child = $role.Children[$i]

        if ($child -is [string]) {
            $child = $yaml | Where-Object {$_.RoleName -eq $child} 
        }

        # You only want this hierarchy, not all.
        $newRecursionStack = $recursionStack.Clone()

        $role_obj.Children += RecurseRole $child $yaml $role_obj $newRecursionStack
    }

    Write-Output $role_obj
}