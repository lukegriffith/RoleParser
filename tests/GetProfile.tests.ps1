
Describe "Private Function - GetProfile" { 


    InModuleScope -ModuleName RoleParser -ScriptBlock {

        Context "Machine returns correct" {

            $m = [Machine]::new(@{
                Name = "host1"
                Type = "Server"
                Category = "App"
                Environment = "Dev"
                User = "user1"
                Owner = "systems_team"
            })

            $expectedProfiles = @("Choco_Package_Server","Choco_Package_Monitoring_Agent", "Choco_App_Package", "Choco_Dev_Lib")

            $role = GetRole -etc $psscriptroot/etc -name Software

            $sb = { $m | GetProfile  -Role $role -Recurse}

            it "GetProfile - does not throw" {
                $sb | should not throw
            }

            $profiles = $sb.Invoke()

            it "Contains expected profiles" {
                $expectedProfiles | should be $profiles
            }

        }






    }
}