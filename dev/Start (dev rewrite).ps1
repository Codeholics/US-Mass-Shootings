Import-Module ImportExcel

$ImportedMJEdition = Import-csv -Path "D:\Code\Repos\US-Mass-Shootings\Export\Mother Jones - Mass Shootings Database 1982-2024.csv"

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

    #############################################
    # General formatting changes to the data
    #############################################

    #Splitting city out of location
    $CityRaw = $location
    $CityOnly = $CityRaw -replace ',.*',''
    $City = $CityOnly.trim('')
    
    #Splitting out state from location
    $StateRaw = $location
    $StateOnly = $StateRaw -replace '.*,',''
    $state  = $StateOnly.trim('')

    #force first character of race caps
    $RaceCaps = $race
    $race = $RaceCaps.toCharArray()[0].tostring().toUpper() + $RaceCaps.remove(0,1)
    $race = $race -replace '^[-]+$', ''

    #force first character of location_2 caps
    $LocationCaps = $location_2
    $location_2 = $LocationCaps.toCharArray()[0].tostring().toUpper() + $LocationCaps.remove(0, 1)
    $location_2 = $location_2.trim('')
    
    #force first character of prior_signs_mental_health_issues caps
    $prior_signs_mental_health_issuesCaps = $prior_signs_mental_health_issues
    $prior_signs_mental_health_issues = $prior_signs_mental_health_issuesCaps.toCharArray()[0].tostring().toUpper() + $prior_signs_mental_health_issuesCaps.remove(0, 1)
    $prior_signs_mental_health_issues = $prior_signs_mental_health_issues -replace '^[-]+$', ''

    #force first character of weapon_type
    $WeaponTypeCaps = $weapon_type
    $WeaponType = $WeaponTypeCaps.toCharArray()[0].tostring().toUpper() + $WeaponTypeCaps.remove(0, 1)

    #force first character of gender caps 
    $GenderCaps = $gender
    $gender = $GenderCaps.toCharArray()[0].tostring().toUpper() + $GenderCaps.remove(0,1)
    
    #force first character of weapons_obtained_legally caps
    $weapons_obtained_legallyCaps = $weapons_obtained_legally
    $weapons_obtained_legally = $weapons_obtained_legallyCaps.toCharArray()[0].tostring().toUpper() + $weapons_obtained_legallyCaps.remove(0,1)
    $weapons_obtained_legally = $weapons_obtained_legally -replace '^[-]+$', ''

    #force first character of gender caps
    $where_obtainedCaps = $where_obtained
    $where_obtained = $where_obtainedCaps.toCharArray()[0].tostring().toUpper() + $where_obtainedCaps.remove(0,1)
    $where_obtained = $where_obtained -replace '^[-]+$', ''

    #force first character of mental_health_details caps
    $mental_health_detailsCaps = $mental_health_details
    $mental_health_details = $mental_health_detailsCaps.toCharArray()[0].tostring().toUpper() + $mental_health_detailsCaps.remove(0,1)
    $mental_health_details = $mental_health_details -replace '^[-]+$', ''

    # Removing - from age_of_shooter
    $age_of_shooter = $age_of_shooter -replace '^[-]+$', ''

    # Removing - from weapon_details
    $weapon_details = $weapon_details -replace '^[-]+$', ''

    # Removing - from mental_health_sources
    $mental_health_sources = $mental_health_sources -replace '^[-]+$', ''

    # Removing - from latitude
    $latitude = $latitude -replace '^[-]+$', ''

    # Removing - from longitude
    $longitude = $longitude -replace '^[-]+$', ''

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

    #############################################
    # Changes to incidents
    #############################################

    # Tulsa medical center shooting
    if ($case -eq "Tulsa medical center shooting" -and $date -eq "2022-06-01") {
        $injured = "0"
        $total_victims = "4"
        $age_of_shooter = "45"
        $weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
        $changes = "Updated injured, total_victims, age_of_shooter, weapon_type"
        #Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Updated: $case" -ToScreen
        write-host "[$(Get-Date)] Updated: $case" -foregroundcolor "green"
    }

    # Thousand Oaks nightclub shooting
    if ($case -eq "Thousand Oaks nightclub shooting" -and $date -eq "2018-11-07") {
        $weapon_type = "One semiautomatic handgun"
        $changes = "Updated weapon type to be more consistent"
        #Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Updated: $case" -ToScreen
        write-host "[$(Get-Date)] Updated: $case" -foregroundcolor "green"
    }

    # Nashville Christian school shooting
    if ($case -eq "Nashville Christian school shooting" -and $date -eq "2023-03-27") {
        $gender = "TM"
        $weapon_type = "One semiautomatic rifle, one pistol caliber carbine, one semiautomatic handgun"
        $mental_health_sources = "https://www.nytimes.com/live/2023/03/28/us/nashville-school-shooting-tennessee"
        $prior_signs_mental_health_issues = "Yes"
        $mental_health_details = "Police Say Shooter Was Under Doctor's Care for 'Emotional Disorder'"
        $weapon_details = "was in possession of an AR-15 military-style rifle, a 9 mm Kel-Tec SUB2000 pistol caliber carbine, and a 9mm Smith and Wesson M&P Shield EZ 2.0 handgun. The AR-15 and 9 mm pistol caliber carbine appear to have 30-round magazines"
        $sources = "https://www.tennessean.com/story/news/crime/2023/03/27/nashville-mourns-mass-shooting-covenant-school/70052585007/; https://www.wsmv.com/2023/03/27/vumc-3-students-2-adults-dead-police-say-shooter-also-dead-covenant-school/; https://www.washingtonpost.com/nation/2023/03/27/nashville-shooting-covenant-school/; https://www.nytimes.com/live/2023/03/27/us/nashville-shooting-covenant-school; https://www.nytimes.com/article/nashville-school-shooting-tennessee.html; https://www.washingtonpost.com/nation/2023/03/27/nashville-school-shooting/; https://www.kq2.com/news/national/heres-what-we-know-about-the-guns-used-in-the-nashville-school-shooting/"
        $changes = "Updated gender to be consistent (TM Trans Male). Old value was F (identifies as transgender and Audrey Hale is a biological woman who, on a social media profile, used male pronouns,? according to Nashville Metro PD officials). weapon_type, mental health, and weapon details updated. Added sources."
        #Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Updated: $case" -ToScreen
        write-host "[$(Get-Date)] Updated: $case" -foregroundcolor "green"
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

$Data | where-object {$_.case -like "Nashville Christian school shooting"}
