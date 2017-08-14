Describe "Private.GetProfile" { 


    InModuleScope -ModuleName RoleParser -ScriptBlock {

        Context "ReturnsProfiles" {

            $m = [Machine]@{
                Name = "host1"
                Type = "Server"
                Category = "App"
                Environment = "Dev"
                User = "user1"
                Owner = "systems_team"
            }

            $expectedProfiles = @(("Choco_Package_Server","Choco_Package_Monitoring_Agent", "Choco_App_Package", "Choco_Dev_Lib") | sort ) -join ","

            $role = GetRole -etc $psscriptroot/etc -name Software

            it "DoesNotThrow" {
                {$m | GetProfile -etc $psscriptroot/etc  -Role $role -Recurse} | should not throw
            }

            it "ContainsExpectedProfiles" {
                $pros = ($m | GetProfile -etc $psscriptroot/etc  -Role $role -Recurse | sort ) -join ","
                
                $pros | should be $expectedProfiles
            }

            mock Where-Object -MockWith {
                return $InputObject
            }

            $r = [Role]::new(@{
                RoleName = "Apps"
                Root = $true
                Filter = {$_.Owner -eq 'systems_team'}
                Profiles = @("app1", "app2")
                Children = @()
                Parent = $null
            })

            it "ReturnsProfilesWhenTrue" {

                $exp = "app1,app2"

                $pros = ($m | GetProfile -etc $psscriptroot/etc  -Role $r) -join ","

                $pros | Should be $exp

            }


            mock Where-Object -MockWith {}

            it "ReturnsNoProfilesWhenFalse" {
                $m | GetProfile -etc $psscriptroot/etc -Role $r | Should be $null

            }
        }

    }
}