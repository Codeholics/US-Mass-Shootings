# Load the module
Import-Module PSSQLite

$CPSScriptRoot = "D:\Code\Repos\US-Mass-Shootings\"

Add-Type -Path "$CPSScriptRoot\Resources\System.Data.SQLite.dll"

# Connect to the database
$connection = New-SqliteConnection -DataSource "$CPSScriptRoot\Export\20230609-32279454\MassShooterDatabase.sqlite"

function Get-Statistics{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.Data.SQLite.SQLiteConnection]$Connection,
        [Parameter(Mandatory=$true)]
        [string]$QueryPath
    )
    # Create a query to select all rows from the table
    $query = Get-Content $QueryPath -Raw

    # Execute the query and store the results in a variable
    $results = Invoke-SqliteQuery -Connection $connection -Query $query #-verbose

    # Display the results
    $results

    # Close the connection
    $connection.Close()
}

$STATS_TotalRecords = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Average Age.sql"

# Average Age
$STATS_AverageAge = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Average Age.sql"

# how mental health plays a role
$STATS_MentalHealthRole = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - How Mental Health Plays A Role.sql"
$STATS_MentalHealthRole_Yes = $STATS_MentalHealthRole | Where-Object {$_.prior_signs_mental_health_issues2 -eq "Yes"}
$STATS_MentalHealthRole_No = $STATS_MentalHealthRole | Where-Object {$_.prior_signs_mental_health_issues2 -eq "No"}
$STATS_MentalHealthRole_Missing = $STATS_MentalHealthRole | Where-Object {$_.prior_signs_mental_health_issues2 -eq "Unknown"}

# Number of time a weapon type is used in a mass shooting
$STATS_NumTimeWeaponUsed = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Number of time a weapon type is used in a mass shooting.sql"
$STATS_MentalHealthRole_SemiAutomaticHandgun = $STATS_NumTimeWeaponUsed | Where-Object {$_.weapon_type -eq "semiautomatic_handgun"}
$STATS_MentalHealthRole_SemiAutomaticRifle = $STATS_NumTimeWeaponUsed | Where-Object {$_.weapon_type -eq "semiautomatic_rifle"}
$STATS_MentalHealthRole_Shotgun = $STATS_NumTimeWeaponUsed | Where-Object {$_.weapon_type -eq "shotgun"}
$STATS_MentalHealthRole_Revolver = $STATS_NumTimeWeaponUsed | Where-Object {$_.weapon_type -eq "revolver"}
$STATS_MentalHealthRole_Derringer = $STATS_NumTimeWeaponUsed | Where-Object {$_.weapon_type -eq "derringer"}
$STATS_MentalHealthRole_Knife = $STATS_NumTimeWeaponUsed | where-Object {$_.weapon_type -eq "knife"}

$STATS_LocationType = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Location Type.sql"
$STATS_Depression = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Mental Health Depression.sql"
$STATS_LocationsCity = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (City).sql"
$STATS_LocationState = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (state).sql"
# $STATS_ShootingsPerYear = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting per year.sql"
$STATS_WeaponCombos = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Weapon Type Combos Used.sql"



$OutPut = "@
- [Statistics](#statistics)
  - [General Statistics](#general-statistics)
  - [Shooters with mental health issues:](#shooters-with-mental-health-issues)
  - [Number of Times a Weapon Type is Used in a Mass Shooting](#number-of-times-a-weapon-type-is-used-in-a-mass-shooting)

# Statistics

## General Statistics
- Total Number of Shootings: ``$($STATS_TotalRecords.recordcount)``
- Average Age of Shooters: ``$($STATS_AverageAge.Average)``

## Shooters with mental health issues:
- Shooters with Mental Health issues were involved in ``$($STATS_MentalHealthRole_Yes.shootings)`` shootings with a percentage of ``$($STATS_MentalHealthRole_Yes.percentage)%`` of all mass shootings.
- The Mother Jones database does not include data for ``$($STATS_MentalHealthRole_Missing.shootings)`` which is ``$($STATS_MentalHealthRole_Missing.Percentage)%`` of all mass shootings.
- A total of ``$($STATS_MentalHealthRole_No.shootings)`` mass shootings did not involve a shooter with mental health issues which is ``$($STATS_MentalHealthRole_No.Percentage)%`` of all mass shootings.

## Number of Times a Weapon Type is Used in a Mass Shooting
- SemiAutomatic Handgun: ``$($STATS_MentalHealthRole_SemiAutomaticHandgun.count)`` involved, with Percentage of ``$($STATS_MentalHealthRole_SemiAutomaticHandgun.Percentage)%``
- SemiAutomatic Rifle: ``$($STATS_MentalHealthRole_SemiAutomaticRifle.count)`` involved, with Percentage of ``$($STATS_MentalHealthRole_SemiAutomaticRifle.Percentage)%``
- Shotgun: ``$($STATS_MentalHealthRole_Shotgun.count)`` involved, with Percentage of ``$($STATS_MentalHealthRole_Shotgun.Percentage)%``
- Revolver: ``$($STATS_MentalHealthRole_Revolver.count)`` involved, with Percentage of ``$($STATS_MentalHealthRole_Revolver.Percentage)%``
- Derringer: ``$($STATS_MentalHealthRole_Derringer.count)`` involved, with Percentage of ``$($STATS_MentalHealthRole_Derringer.Percentage)%``
- Knife: ``$($STATS_MentalHealthRole_Knife.count)`` involved, with Percentage of ``$($STATS_MentalHealthRole_Knife.Percentage)%``
@"



$OutPut