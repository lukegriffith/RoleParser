


Describe "Private.GetRole" { 


    Context "WellFormattedYAML." {

        $ymlFile = gc $psscriptroot/etc/Software.yml -raw
        
        It "YAMLIsValid." {
            { $obj = ConvertFrom-Yaml -Yaml $ymlFile -AllDocuments } | Should not throw
        }
        

        InModuleScope -ModuleName RoleParser -ScriptBlock {

            $role = GetRole -etc $psscriptroot/etc -name Software

            It "CorrectStructure" {
                $role | should be $true
            }

            it "IsRoot" { 
                $role.RoleName | should be "ServerSoftware"
            }

            it "HasChildren" {
                $role.Children.Count -gt 1 | should be $true
            }
            
        }

    }

    Context "PoorFormattedYAML." {
        
        $ymlFile = gc $psscriptroot/etc/SoftwareBad.yml -raw

        It "YAMLIsValid." {
            {$obj = ConvertFrom-Yaml -Yaml $ymlFile -AllDocuments} | Should not throw
        }

        InModuleScope -ModuleName RoleParser -ScriptBlock { 


            it "TerminatesOnRecurse" {
                { GetRole -etc $psscriptroot/etc -name SoftwareBad } | should throw
            }
        }
    }

}