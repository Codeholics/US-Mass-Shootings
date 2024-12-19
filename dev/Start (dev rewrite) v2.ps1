Import-Module ImportExcel

# Path to the root directory of the script
$CPSScriptRoot = "D:\Code\Repos\US-Mass-Shootings\dev"

# Function to edit cases
. "$CPSScriptRoot\functions\Edit-Cases.ps1"

# Import the Mother Jones Edition
$ImportedMJEdition = Import-csv -Path "D:\Code\Repos\US-Mass-Shootings\Export\Mother Jones - Mass Shootings Database 1982-2024.csv"

# Path to the replacements file for the Edit-Cases function
$replacements = "$CPSScriptRoot\replacements.json"

# Formatting MJ Data for CH Edition
$Data = @()
foreach ($item in $ImportedMJEdition) {

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
$DataFinal | where-object {$_.case -eq "Nashville Christian school shooting"}

# Push data to SQLite DB
& "D:\Code\Repos\US-Mass-Shootings\dev\SQLPort.ps1"