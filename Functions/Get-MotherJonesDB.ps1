
function Get-MotherJonesDB {
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
        $CPSScriptRoot = "D:\Github\PowerShell\R AND D\Data World\MJ Mass Shooter Database"
        Get-MotherJonesDB -Output "$CPSScriptRoot\Export"
#>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Output,

        [Parameter(Mandatory=$false)]
        [string]$ExportOG = "$Output\Mother Jones Raw.csv",

        [Parameter(Mandatory=$false)]
        [string]$ExportFixed = "$Output\Mother Jones - Mass Shootings Database 1982-2023.csv"
    )
    #Mother Jones Mass Shooting Database
    #Mother Jones - Mass Shootings Database, 1982 - 2022
    $Mothers = 'https://docs.google.com/spreadsheets/d/1b9o6uDO18sLxBqPwl_Gh9bnhW-ev_dABH83M5Vb5L8o/export?format=csv'

    if (test-path $ExportOG) {Remove-Item $ExportOG}
    if (test-path $ExportFixed) {Remove-Item $ExportFixed}

    Invoke-WebRequest -outFile $ExportOG $Mothers

    $csv = Import-CSV -Path $ExportOG -Header "case","location","date","summary","fatalities","injured","total_victims","location_2","age_of_shooter","prior_signs_mental_health_issues","mental_health_details","weapons_obtained_legally","where_obtained","weapon_type","weapon_details","race","gender","sources","mental_health_sources","sources_additional_age","latitude","longitude","type","year" | Select-Object -Skip 1

    #testing code here
    # Fix Date format to always be M/d/yyyy. Also escape single quotes.
    $DataFix = @()
    foreach ($item in $csv) {
        $Summary = $item.summary -replace "'", "''"
        $MentalHealthDetails = $item.mental_health_details -replace "'", "''"
        $Case = $item.case -replace "'", "''"
        $WhereObtained = $item.where_obtained -replace "'", "''"
        $WeaponDetails = $item.weapon_details -replace "'", "''"
        $WeaponType = $item.weapon_type -replace "'", "''"
        $Date = (Get-Date $item.date).ToString("yyyy-MM-dd")
        
        $row = new-object psobject
        $row | add-member -MemberType NoteProperty -Name case -Value $Case
        $row | add-member -MemberType NoteProperty -Name location -Value $item.location
        #$row | add-member -MemberType NoteProperty -Name city -Value $item.city
        #$row | add-member -MemberType NoteProperty -Name state -Value $item.state
        $row | add-member -MemberType NoteProperty -Name date -Value $Date
        $row | add-member -MemberType NoteProperty -Name summary -Value $Summary
        $row | add-member -MemberType NoteProperty -Name fatalities -Value $item.fatalities
        $row | add-member -MemberType NoteProperty -Name injured -Value $item.injured
        $row | add-member -MemberType NoteProperty -Name total_victims -Value $item.total_victims
        $row | add-member -MemberType NoteProperty -Name location_2 -Value $item.location_2
        $row | add-member -MemberType NoteProperty -Name age_of_Shooter -Value $item.age_of_Shooter
        $row | add-member -MemberType NoteProperty -Name prior_signs_mental_health_issues -Value $item.prior_signs_mental_health_issues
        $row | add-member -MemberType NoteProperty -Name mental_health_details -Value $MentalHealthDetails
        $row | add-member -MemberType NoteProperty -Name weapons_obtained_legally -Value $item.weapons_obtained_legally
        $row | add-member -MemberType NoteProperty -Name where_obtained -Value $WhereObtained
        $row | add-member -MemberType NoteProperty -Name weapon_type -Value $WeaponType
        $row | add-member -MemberType NoteProperty -Name weapon_details -Value $WeaponDetails
        $row | add-member -MemberType NoteProperty -Name race -Value $item.race
        $row | Add-member -MemberType NoteProperty -Name gender -Value $item.gender
        $row | add-member -MemberType NoteProperty -Name sources -Value $item.sources
        $row | add-member -MemberType NoteProperty -Name mental_health_sources -Value $item.mental_health_sources
        $row | add-member -MemberType NoteProperty -Name latitude -Value $item.latitude
        $row | add-member -MemberType NoteProperty -Name longitude -Value $item.longitude
        $row | add-member -MemberType NoteProperty -Name type -Value $item.type
        $row | add-member -MemberType NoteProperty -Name year -Value $item.year
        $DataFix += $row

    }


    #Export-CSV -Path $ExportFixed -NoTypeInformation
    $DataFix | Export-CSV -Path $ExportFixed -NoTypeInformation
}

#$CPSScriptRoot = "D:\Github\PowerShell\R AND D\Data World\MJ Mass Shooter Database"
#Get-MotherJonesDB -Output "$CPSScriptRoot\Export"
