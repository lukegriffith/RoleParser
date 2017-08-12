

class Role { 
    [String]$RoleName
    [bool]$Root
    [ScriptBlock] $Where
    [String[]]$Profiles
    [Role[]]$Children 
    [Role]$Parent

    Role([PSObject]$raw_role) {

        $this.RoleName = $raw_role.RoleName
        $this.Root = $raw_role.Root
        $this.Where = [scriptblock]::Create($raw_role.Where)
        $this.Profiles = $raw_role.Profiles
    }
}