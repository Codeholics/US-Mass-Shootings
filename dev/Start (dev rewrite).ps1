Import-Module ImportExcel

# Path to the root directory of the script
$CPSScriptRoot = "D:\Code\Repos\US-Mass-Shootings\dev"

# Importing Functions
    # Function to edit cases
$EditCases = Join-Path -Path $CPSScriptRoot -ChildPath "Functions" | Join-Path -ChildPath "Edit-Cases.ps1"
. $EditCases
    # Function to get the Mother Jones Database 
$GetMotherJonesDB = Join-Path -Path $CPSScriptRoot -ChildPath 'Functions' | Join-Path -ChildPath 'Get-MotherJonesDB.ps1'
. $GetMotherJonesDB

# Import the Mother Jones Edition
#$ImportedMJEdition = Import-csv -Path "D:\Code\Repos\US-Mass-Shootings\Export\Mother Jones - Mass Shootings Database 1982-2024.csv"

# Variables
$Date = Get-Date -Format "yyyyMMdd"
$Random = Get-Random
$ExportPath = Join-Path -Path $CPSScriptRoot -ChildPath 'Export'

# Import and Export FileName Variables
$ExportWebView = Join-Path -Path $ExportPath -ChildPath 'WebView.html'
$ExportCHEdition = Join-Path -Path $ExportPath -ChildPAth 'Codeholics - Mass Shootings Database 1982-2024.csv'
$ImportCSVPath = Join-Path -Path $ExportPath -ChildPath 'Mother Jones - Mass Shootings Database 1982-2024.csv'

# Log Variables
$LogPath = Join-Path -Path $CPSScriptRoot -ChildPath 'Logs'
$LogName = "$Date-$Random.log"
$LogFilePath = Join-Path -Path $LogPath -ChildPath $LogName
$Version = "2.0"

# Path to the replacements file for the Edit-Cases function
$replacements = Join-Path -Path $CPSScriptRoot -ChildPath "replacements.json"

# Start Logging
Start-Log -LogPath $LogPath -LogName $LogName -ScriptVersion $Version

# create Export folder if not exist
if (!(Test-Path $ExportPath)) {
    New-Item -Path $ExportPath -ItemType Directory
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Created Export Folder: [$ExportPath]" -ToScreen
}elseif (Test-Path $ExportPath) {
    Remove-Item -Path $ExportPath -Recurse -Force
    New-Item -Path $ExportPath -ItemType Directory
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Export Folder: [$ExportPath] already exists" -ToScreen
}

# Get Mother Jones CSV and create a new copy without duplicate headers.
try {
    Get-MotherJonesDB -Output $ExportPath
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV copied to: [$ExportPath]" -ToScreen
}
Catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV copy failed" -ToScreen
}

# Check and confrim the new CSV is avaiable before continuing
try {
    $Spreadsheet = (Import-csv -Path $ImportCSVPath)
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV imported from: [$ImportCSVPath]" -ToScreen
}catch {
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV import failed" -ToScreen
}

# Main loop that will correct the data from MJ to build CH edition
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Starting column data correction loop" -ToScreen

# Formatting MJ Data for CH Edition
$Data = @()
foreach ($item in $Spreadsheet) {

    # Initializations
    $gender = $null
    $type = $null
    $mental_health_sources = $null
    $age_of_shooter = $null
    $weapon_details = $null
    $latitude = $null
    $longitude = $null
    $year = $null
    $changes = $null
    $sources = $null
    $sources_additional_age = $null
    $total_victims = $null
    $injured = $null
    $fatalities = $null
    $summary = $null
    $date = $null
    $location = $null
    $case = $null
    $mental_health_details = $null
    $where_obtained = $null
    $weapons_obtained_legally = $null
    $weapon_type = $null
    $race = $null
    $location_2 = $null
    $prior_signs_mental_health_issues = $null
    $gender = $null
    
    # Variable Assignments
    $gender = $item.gender.length
    $type = $item.type
    $mental_health_sources = $item.mental_health_sources
    $age_of_shooter = $item.age_of_shooter
    $weapon_details = $item.weapon_details
    $latitude = $item.latitude
    $longitude = $item.longitude
    $year = $item.year
    $changes = $item.changes
    $sources = $item.sources
    $sources_additional_age = $item.sources_additional_age
    $total_victims = $item.total_victims
    $injured = $item.injured
    $fatalities = $item.fatalities
    $summary = $item.summary
    $date = $item.date
    $location = $item.location
    $case = $item.case
    $mental_health_details = $item.mental_health_details
    $where_obtained = $item.where_obtained
    $weapons_obtained_legally = $item.weapons_obtained_legally
    $weapon_type = $item.weapon_type
    $race = $item.race
    $location_2 = $item.location_2
    $prior_signs_mental_health_issues = $item.prior_signs_mental_health_issues
    $gender = $item.gender
    $changes = $item.changes

    #############################################
    # General formatting changes to the data
    #############################################

    # Splitting city out of location
    $CityRaw = $location
    $CityOnly = $CityRaw -replace ',.*',''
    $City = $CityOnly.trim('')
    
    # Splitting out state from location
    $StateRaw = $location
    $StateOnly = $StateRaw -replace '.*,',''
    $state  = $StateOnly.trim('')

    # force first character of race caps
    $RaceCaps = $race
    $race = $RaceCaps.toCharArray()[0].tostring().toUpper() + $RaceCaps.remove(0,1)
    $race = $race -replace '^[-]+$', $null

    # force first character of location_2 caps
    $LocationCaps = $location_2
    $location_2 = $LocationCaps.toCharArray()[0].tostring().toUpper() + $LocationCaps.remove(0, 1)
    $location_2 = $location_2.trim('')
    
    # force first character of prior_signs_mental_health_issues caps
    $prior_signs_mental_health_issuesCaps = $prior_signs_mental_health_issues
    $prior_signs_mental_health_issues = $prior_signs_mental_health_issuesCaps.toCharArray()[0].tostring().toUpper() + $prior_signs_mental_health_issuesCaps.remove(0, 1)
    $prior_signs_mental_health_issues = $prior_signs_mental_health_issues -replace '^[-]+$', $null

    # force first character of weapon_type
    $WeaponTypeCaps = $weapon_type
    $Weapon_type = $WeaponTypeCaps.toCharArray()[0].tostring().toUpper() + $WeaponTypeCaps.remove(0, 1)

    # force first character of gender caps 
    $GenderCaps = $gender
    $gender = $GenderCaps.toCharArray()[0].tostring().toUpper() + $GenderCaps.remove(0,1)
    
    # force first character of weapons_obtained_legally caps
    $weapons_obtained_legallyCaps = $weapons_obtained_legally
    $weapons_obtained_legally = $weapons_obtained_legallyCaps.toCharArray()[0].tostring().toUpper() + $weapons_obtained_legallyCaps.remove(0,1)
    $weapons_obtained_legally = $weapons_obtained_legally -replace '^[-]+$', $null

    # force first character of gender caps
    $where_obtainedCaps = $where_obtained
    $where_obtained = $where_obtainedCaps.toCharArray()[0].tostring().toUpper() + $where_obtainedCaps.remove(0,1)
    $where_obtained = $where_obtained -replace '^[-]+$', $null

    # force first character of mental_health_details caps
    $mental_health_detailsCaps = $mental_health_details
    $mental_health_details = $mental_health_detailsCaps.toCharArray()[0].tostring().toUpper() + $mental_health_detailsCaps.remove(0,1)
    $mental_health_details = $mental_health_details -replace '^[-]+$', $null

    # Removing - from age_of_shooter
    $age_of_shooter = $age_of_shooter -replace '^[-]+$', $null

    # Removing - from weapon_details
    $weapon_details = $weapon_details -replace '^[-]+$', $null

    # Removing - from mental_health_sources
    $mental_health_sources = $mental_health_sources -replace '^[-]+$', $null

    # Removing - from latitude
    $latitude = $latitude -replace '^[-]+$', $null

    # Removing - from longitude
    $longitude = $longitude -replace '^[-]+$', $null

    #the gender values are not consistnt, abbreviating the gender value for more consistent data
    $GenderValueLength = $gender
    if($GenderValueLength -eq 4){
        $gender = 'M'
    }elseif ($GenderValueLength -eq 6) {
        $gender = 'F'
    }elseif($GenderValueLength -eq 13){
        $gender = 'M/F'
    }else{
        #Do nothing if the value length is 1. (result already "M", "F" or "M/F")
        $gender = $gender
    }

    # weapon_type values
    if ($weapon_type -eq '2 handguns') {
        $weapon_type = 'Two handguns'
    }

    # State corrections
    if ($state -eq 'Kentucky') {
        $state = 'KY'
    }

    if ($state -eq 'Tennessee') {
        $state = 'TN'
    }

    if ($case -eq 'Philidelphia neighborhood shooting') {
        $case = "Philadelphia neighborhood shooting"
    }

    # Final CleanData Array for CH Edition
    $Data += [PSCustomObject]@{
        case = $case
        location = $location
        city = $City
        state = $State
        date = $date
        summary = $summary
        fatalities = $fatalities
        injured = $injured
        total_victims = $total_victims
        location_2 = $Location_2
        age_of_Shooter = $age_of_shooter
        prior_signs_mental_health_issues = $prior_signs_mental_health_issues
        mental_health_details = $mental_health_details
        weapons_obtained_legally = $weapons_obtained_legally
        where_obtained = $where_obtained
        weapon_type = $weapon_type
        weapon_details = $weapon_details
        race = $race
        gender = $gender
        sources = $sources
        mental_health_sources = $mental_health_sources
        sources_additional_age = $sources_additional_age
        latitude = $latitude
        longitude = $longitude
        type = $type
        year = $year
        changes = $changes
    }
}


## Case changes only
$ModifiedCases = @()
foreach ($item in $Data) {
    $item = Edit-Cases -item $item -replacementsPath $replacements
    $ModifiedCases += $item
}

# Correct order of columns
$DataFinal = $ModifiedCases | Select-Object -Property case, location, city, state, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year, changes

# check single record (testing)
#$DataFinal | where-object {$_.case -eq "Nashville Christian school shooting"}

#Export clean dataset for data.world
try {
    $DataFinal | Export-CSV -path $ExportCHEdition -NoTypeInformation
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Exported clean CH Edition dataset for data.world [$ExportCHEdition]" -ToScreen
} catch {
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Exporting clean CH Edition dataset for data.world [$ExportCHEdition]" -ToScreen
}

# Push data to SQLite DB
& "$CPSScriptRoot\SQLPort.ps1"

# Generate Statistics.md
& "$CPSScriptRoot\Statistics.ps1"

# HTML Export of the data. Will popup once script is completed.
try {
    New-HTML {
        New-HTMLTable -DataTable $Data -Title 'Table of records' -HideFooter -PagingLength 200 -Buttons excelHtml5, searchPanes
    } -FilePath $ExportWebView -Online
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Exported WebView [$ExportWebView]" -ToScreen
    }catch{
        Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Exporting WebView [$ExportWebView]" -ToScreen
    }
    
    Stop-Log -LogPath $LogFilePath -NoExit