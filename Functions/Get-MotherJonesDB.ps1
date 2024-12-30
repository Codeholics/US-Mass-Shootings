
<#
    .SYNOPSIS
        Downloads and processes data from the Mother Jones Mass Shooting Database.
    .DESCRIPTION
        This function downloads the Mother Jones Mass Shooting Database from a Google Sheets link and processes it into a new CSV file with a standardized date format (M/d/yyyy) and properly escaped single quotes. The resulting CSV file can be used to create a new SQLite database for storing data on mass shootings.
    .PARAMETER Output
        Specifies the directory where the new CSV file will be saved.
    .PARAMETER ExportOG
        Specifies the file path for the original, unprocessed CSV file.
    .PARAMETER ExportFixed
        Specifies the file path for the processed CSV file.
    .EXAMPLE
        $CPSScriptRoot = "D:\code\MJ Mass Shooter Database"
        Get-MotherJonesDB -Output "$CPSScriptRoot\Export"
#>
function Get-MotherJonesDB {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Output,

        [Parameter(Mandatory=$false)]
        [string]$ExportOG = (Join-Path $Output -ChildPath "Mother Jones Raw.csv"),

        [Parameter(Mandatory=$false)]
        [string]$ExportFixed = (Join-Path -Path $Output -ChildPath "Mother Jones - Mass Shootings Database 1982-2024.csv")
    )

    # Mother Jones Mass Shooting Database
    # Mother Jones - Mass Shootings Database, 1982 - 2024
    $Mothers = 'https://docs.google.com/spreadsheets/d/1b9o6uDO18sLxBqPwl_Gh9bnhW-ev_dABH83M5Vb5L8o/export?format=csv'

    # Remove existing files
    if (test-path $ExportOG) {Remove-Item $ExportOG}
    if (test-path $ExportFixed) {Remove-Item $ExportFixed}

    # Download the Mother Jones DB CSV
    Invoke-WebRequest -outFile $ExportOG $Mothers

    # Import CSV and skip the first row (header) - Header is manually defined (fix for duplicate "location" column)
    $csv = Import-CSV -Path $ExportOG -Header "case","location","date","summary","fatalities","injured","total_victims","location_2","age_of_shooter","prior_signs_mental_health_issues","mental_health_details","weapons_obtained_legally","where_obtained","weapon_type","weapon_details","race","gender","sources","mental_health_sources","sources_additional_age","latitude","longitude","type","year" | Select-Object -Skip 1

    # Fix Date format to always be M/d/yyyy. Also escape single quotes.
    $DataFix = @()
    foreach ($item in $csv) {

        # Initialize variables
        $case = $null
        $location = $null
        $date = $null
        $summary = $null
        $fatalities = $null
        $injured = $null
        $total_victims = $null
        $location_2 = $null
        $age_of_Shooter = $null
        $prior_signs_mental_health_issues = $null
        $mental_health_details = $null
        $weapons_obtained_legally = $null
        $where_obtained = $null
        $weapon_type = $null
        $weapon_details = $null
        $race = $null
        $gender = $null
        $sources = $null
        $mental_health_sources = $null
        $latitude = $null
        $longitude = $null
        $type = $null
        $year = $null

        # Variable assignments
        $summary = $item.summary -replace '(\r\n|\r|\n)', ' '
        $mental_health_details = $item.mental_health_details
        $case = $item.case
        $where_obtained = $item.where_obtained
        $weapon_details = $item.weapon_details
        $weapon_type = $item.weapon_type
        $sources = $item.sources -replace '(\r\n|\r|\n)', ' '
        $date = (Get-Date $item.date).ToString("yyyy-MM-dd")
        $race = $item.race
        $location = $item.location
        $fatalities = $item.fatalities
        $injured = $item.injured
        $total_victims = $item.total_victims
        $location_2 = $item.location_2
        $age_of_Shooter = $item.age_of_Shooter
        $prior_signs_mental_health_issues = $item.prior_signs_mental_health_issues
        $weapons_obtained_legally = $item.weapons_obtained_legally
        $gender = $item.gender
        $sources = $item.sources
        $mental_health_sources = $item.mental_health_sources
        $latitude = $item.latitude
        $longitude = $item.longitude
        $type = $item.type
        $year = $item.year

        # Fixing bad characters that -replace doesn't work because of anti-virus
        if ($case -eq "Marjory Stoneman Douglas High School shooting" -and $date -eq "2018-02-14") {
            $summary = "Nikolas J. Cruz, 19, heavily armed with an AR-15, tactical gear, and 'countless magazines' of ammo, according to the Broward County Sheriff, attacked the high school as classes were ending for the day, killing at least 17 people and injuring many others. He was apprehended by authorities shortly after fleeing the campus."
        }

        if ($case -eq "Yountville veterans home shooting" -and $date -eq "2018-03-09") {
            $summary = "Army veteran Albert Cheung Wong, 36, stormed a veterans home where he was previously under care, exchanging gunfire with a sheriff's deputy and taking three women hostage, one of whom he'd previously threatened. After a standoff with law enforcement, he killed the three women and himself."
        }

        if ($case -eq "Capital Gazette shooting" -and $date -eq "2018-06-28") {
            $summary = "Jarrod W. Ramos, 38, shot through the glass doors of the paper's newsroom around 3pm to carry out his attack; police quickly responding to the scene found him hiding under a desk and apprehended him. Ramos had harbored a longstanding grudge against the paper over a 2011 column that had detailed his guilty plea for the harassment of a former female classmate. Ramos had sued the paper for defamation and lost."
        }

        if ($case -eq "Thousand Oaks nightclub shooting" -and $date -eq "2018-11-07") {
            $summary = "Ian David Long, 28, dressed in black and armed with a handgun and a smoke device, approached the Borderline Bar & Grill a country music venue popular with college students close to midnight and opened fire, killing a security guard and then others in the club, including a sheriff's deputy responding to the attack. Long was found dead at the scene from apparent suicide. He was a former Marine and had a history of interactions with local law enforcement, including a mental health evaluation in which he'd been cleared."
        }

        if ($case -eq "Mercy Hospital shooting" -and $date -eq "2018-11-19") {
            $summary = "Juan Lopez, 32, confronted his former fiance, ER doctor Tamara O'Neal, before shooting her and opening fire on others at the hospital, including a responding police officer, Samuel Jimenez, and a pharmacy employee, Dayna Less. Lopez was fatally shot by a responding SWAT officer. Lopez had a history of domestic abuse against an ex-wife, and was kicked out of a fire department training academy for misconduct against female cadets."
        }

        if ($case -eq "Pensacola Naval base shooting" -and $date -eq "2019-12-06") {
            $summary = "Ahmed Mohammed al-Shamrani, 21, a Saudi Arabian military pilot training in the United States, opened fire just before 7 a.m. in an air station classroom. He was soon shot and killed by responding Florida sheriff's deputies."
        }

        if ($case -eq "Jersey City kosher market shooting" -and $date -eq "2019-12-10") {
            $summary = "David N. Anderson, 47, and Francine Graham, 50, were heavily armed and traveling in a white van when they first killed a police officer in a cemetery, and then opened fire at a kosher market, fueled both by anti-Semitism and anti-law enforcement beliefs, according to New Jersey authorities. The pair, linked to the antisemitic ideology of the Black Hebrew Israelites extremist group, were killed after a lengthy gun battle with police at the market."
        }

        # Add to $DataFix array
        $DataFix += [PSCustomObject]@{
            case = $case
            location = $location
            date = $date
            summary = $summary
            fatalities = $fatalities
            injured = $injured
            total_victims = $total_victims
            location_2 = $location_2
            age_of_Shooter = $age_of_Shooter
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
            latitude = $latitude
            longitude = $longitude
            type = $type
            year = $year
        }
    }

    #Export-CSV -Path $ExportFixed -NoTypeInformation
    $DataFix | Export-CSV -Path $ExportFixed -NoTypeInformation
}

#$CPSScriptRoot = "D:\Code\MJ Mass Shooter Database"
#Get-MotherJonesDB -Output "$CPSScriptRoot\Export"
