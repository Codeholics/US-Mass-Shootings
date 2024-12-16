Import-Module ImportExcel

$ImportedMJEdition = Import-csv -Path "D:\Code\Repos\US-Mass-Shootings\Export\Mother Jones - Mass Shootings Database 1982-2024.csv"

$CleanData = @()
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
    $concatenated = $null
    
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

    # Tulsa medical center shooting
    if ($case -eq "Tulsa medical center shooting" -and $date -eq "2022-06-01") {
        $injured = "x"
        $total_victims = "4"
        $age_of_shooter = "45"
        $weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
        $changes = "Updated injured, total_victims, age_of_shooter, weapon_type"
        #Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Updated: $case" -ToScreen
        write-host "[$(Get-Date)] Updated: $case" -foregroundcolor "green"
    }

    # Final CleanData Array for CH Edition
    $CleanData += [PSCustomObject]@{
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
        prior_signs_mental_health_issues = $PriorSignsMentalHealthIssues
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

$CleanData | where-object {$_.case -like "Tulsa medical center shooting"} | select-object Injured
