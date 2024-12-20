
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
        $Summary = $item.summary -replace '(\r\n|\r|\n)', ' '
        $MentalHealthDetails = $item.mental_health_details #-replace "'", "''"
        $Case = $item.case #-replace "'", "''"
        $WhereObtained = $item.where_obtained #-replace "'", "''"
        $WeaponDetails = $item.weapon_details #-replace "'", "''"
        $WeaponType = $item.weapon_type #-replace "'", "''"
        $sources = $item.sources -replace '(\r\n|\r|\n)', ' '
        $Date = (Get-Date $item.date).ToString("yyyy-MM-dd")

        # Add to $DataFix array
        $DataFix += [PSCustomObject]@{
            case = $Case
            location = $item.location
            date = $Date
            summary = $Summary
            fatalities = $item.fatalities
            injured = $item.injured
            total_victims = $item.total_victims
            location_2 = $item.location_2
            age_of_Shooter = $item.age_of_Shooter
            prior_signs_mental_health_issues = $item.prior_signs_mental_health_issues
            mental_health_details = $MentalHealthDetails
            weapons_obtained_legally = $item.weapons_obtained_legally
            where_obtained = $WhereObtained
            weapon_type = $WeaponType
            weapon_details = $WeaponDetails
            race = $item.race
            gender = $item.gender
            sources = $item.sources
            mental_health_sources = $item.mental_health_sources
            latitude = $item.latitude
            longitude = $item.longitude
            type = $item.type
            year = $item.year
        }
    }

    #Export-CSV -Path $ExportFixed -NoTypeInformation
    $DataFix | Export-CSV -Path $ExportFixed -NoTypeInformation
}

#$CPSScriptRoot = "D:\Code\MJ Mass Shooter Database"
#Get-MotherJonesDB -Output "$CPSScriptRoot\Export"
