
$ModuleName = 'RoleParser'
$Seperator = '------------------------------------------'
$RequiredModules = @('Pester', 'PSScriptAnalyzer','powershell-yaml')
$SourcePath = "$PSScriptRoot\$ModuleName"

if ($IsOSX) {
	$OutputPath = "/Users/$env:USER/.local/share/powershell/Modules"
}
else {
	$OutputPath = "C:\Program Files\WindowsPowerShell\Modules"
}

Task . Init, {Clean}, Compile, Test

Task BuildOnly Init, {Clean}, Compile
Task TestOnly Test




Function Clean {
	#Remove any previously loaded module versions from subsequent runs
	Get-Module -Name $ModuleName | Remove-Module

	#Remove any files previously compiled but leave other versions intact
	$Path = Join-Path -Path $OutputPath -ChildPath $ModuleName
	If ($PSVersionTable.PSVersion.Major -ge 5 ) {
		$Path = Join-Path -Path $Path -ChildPath $Script:Version.ToString()
	}
	Write-Output "Cleaning: $Path"
	$Path | Get-Item -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
}

Task Init {
	$Seperator
	
	#Query the module manifest for information
	$ManifestPath = Join-Path -Path $SourcePath -ChildPath "$ModuleName.psd1"
	$Script:ManifestInfo = Test-ModuleManifest -Path $ManifestPath -ErrorAction SilentlyContinue

	#Determine the new version. Major & Minor are set in the source psd1 file, BuildNumer is fed in as a parameter
	If ($BuildNumber) {
		$Script:Version = [Version]::New($ManifestInfo.Version.Major, $ManifestInfo.Version.Minor, $BuildNumber)
	}
	Else {
		$Script:Version = [Version]::New($ManifestInfo.Version.Major, $ManifestInfo.Version.Minor, 0)
	}

	Write-Output "Begining $CIEngine build of $ModuleName ($Version)"
	#Import required modules
	$RequiredModules | ForEach-Object {
		If (-not (Get-Module -Name $_ -ListAvailable)){
			Try {
				Write-Output "Installing Module: $_"
				Install-Module -Name $_ -Force -Scope CurrentUser
			}
			Catch {
				Throw "Unable to install missing module - $($_.Exception.Message)"
			}
		}

		Write-Output "Importing Module: $_"
		Import-Module -Name $_
	}
}


Task Compile {
	$Seperator
	
	Write-Output "Compiling Module..."
	#Depending on powershell version the module folder may or may not already exists after subsequent runs
	If (Test-Path -Path "$OutputPath\$ModuleName") {
		$Script:ModuleFolder = Get-Item -Path "$OutputPath\$ModuleName"
	}
	Else {
		$Script:ModuleFolder = New-Item -Path $OutputPath -Name $ModuleName -ItemType Directory
	}

	#Make a subfolder for the version if module is for powershell 5
	If ($PSVersionTable.PSVersion.Major -ge 5 ) {
		$Script:ModuleFolder = New-Item -Path $Script:ModuleFolder -Name $Version.ToString() -ItemType Directory
	}

	#Create root module psm1 file
	$ModuleContentParts = 'Classes', 'Private', 'Public' | ForEach-Object {
		Join-Path -Path $SourcePath -ChildPath $_ | Get-ChildItem -Recurse -Depth 1 -Include '*.ps1','*.psm1' | Get-Content -Raw
	}
	$ModuleContentParts += Join-Path -Path $SourcePath -ChildPath "$ModuleName.ps1" | Get-Item -ErrorAction SilentlyContinue | Get-Content -Raw
	$ModuleContent = $ModuleContentParts -join "`r`n`r`n`r`n"
	$RootModule = New-Item -Path $ModuleFolder.FullName -Name "$ModuleName.psm1" -ItemType File -Value $ModuleContent

	#Copy module manifest and any other source files
	Write-Output "Copying other source files..."
	Get-ChildItem -Path $SourcePath -File | Where-Object {$_.Name -ne $RootModule.Name} | Copy-Item -Destination $ModuleFolder.FullName

	#Update module copied manifest
	$NewManifestPath = Join-Path -Path $ModuleFolder.FullName -ChildPath "$ModuleName.psd1"
	Write-Host "Updating Manifest ModuleVersion to $Script:Version"
	#Stupidly Update-ModuleManifest fails to correct the version when it doesnt match the folder its in. wtf?
	(Get-Content -Path $NewManifestPath) -replace "ModuleVersion = .+","ModuleVersion = '$Script:Version'" | Set-Content -Path $NewManifestPath

	$FunctionstoExport = Get-ChildItem -Path "$SourcePath\Public" -Filter '*.ps1' | Select-Object -ExpandProperty BaseName
	Write-Output "Updating Manifest FunctionsToExport: $FunctionstoExport"
	Update-ModuleManifest -Path $NewManifestPath -FunctionsToExport $FunctionstoExport

	Copy-Item $sourcePath\etc $moduleFolder -Recurse
	
	#Update nuspec
	$NuspecPath = Join-Path -Path $ModuleFolder.FullName -ChildPath "$ModuleName.nuspec"
	(Get-Content -Path $NuspecPath) -replace "<version>__VERSION__</version>","<version>$Script:Version</version>" | Set-Content -Path $NuspecPath
}







task Test { 
	$Seperator
	Write-Output "Starting tests."

	Import-Module -Name $ModuleName -Force
	Get-Module -Name $ModuleName -ListAvailable

	Invoke-Pester  -OutputFormat NUnitXml -OutputFile  ./nunit.xml
}