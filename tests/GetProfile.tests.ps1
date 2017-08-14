Describe "Private Function - GetProfile" { 


    InModuleScope -ModuleName RoleParser -ScriptBlock {

        Context "Machine returns correct" {

            $m = [Machine]@{
                Name = "host1"
                Type = "Server"
                Category = "App"
                Environment = "Dev"
                User = "user1"
                Owner = "systems_team"
            }

            $expectedProfiles = @("Choco_Package_Server","Choco_Package_Monitoring_Agent", "Choco_App_Package", "Choco_Dev_Lib")

            $role = GetRole -etc $psscriptroot/etc -name Software

            $sb = { $m | GetProfile  -Role $role -Recurse}

            it "GetProfile - does not throw" {
                $sb | should not throw
            }

            $profiles = $sb.Invoke()

            it "Contains expected profiles" {
                $profiles | should be $expectedProfiles
            }

            mock Where-Object -MockWith {
                return $InputObject
            }

            $r = [Role]@{
                RoleName = "Apps"
                Root = $true
                Where = {$_.Owner -eq 'systems_team'}
                Profiles = @("app1", "app2")
                Children = @()
                Parent = $null
            }

            it "Returns profiles where role is true" {


                $m | GetProfile -Role $r | Should be @("app1","app2")

            }
        }






    }
}