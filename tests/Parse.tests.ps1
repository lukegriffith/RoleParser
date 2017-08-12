


Describe "Testing Parsing yaml." { 

    $ymlFile = gc $psscriptroot/etc/Software.yml -raw

    It "test Yaml is valid." {
        $obj = ConvertFrom-Yaml -Yaml $ymlFile -AllDocuments
    }

    Context "Private functions." {

        InModuleScope -ModuleName RoleParser -ScriptBlock {

            $role = GetRole -etc $psscriptroot/etc -name Software

            It "GetRole gets the role structure." {
                $role | should be $true
            }

            it "Role is root." { 
                $role.RoleName | should be "ServerSoftware"
            }

            it "Role has children." {
                $role.Children | should be $true
            }
            
        }

    }

}