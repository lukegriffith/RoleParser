

class Role { 
    [String]$RoleName
    [bool]$Root
    [ScriptBlock] $Filter
    [String[]]$Profiles
    [Role[]]$Children 
    [Role]$Parent



    Role([PSObject]$raw_role) {

        $this.RoleName = $raw_role.RoleName
        $this.Root = $raw_role.Root
        $this.Filter = [scriptblock]::Create($raw_role.Filter)
        $this.Profiles = $raw_role.Profiles
    }
}