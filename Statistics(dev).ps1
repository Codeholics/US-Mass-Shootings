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
$STATS_MentalHealthRole_Yes = $STATS_MentalHealthRole | where {$_.prior_signs_mental_health_issues2 -eq "Yes"}
$STATS_MentalHealthRole_No = $STATS_MentalHealthRole | where {$_.prior_signs_mental_health_issues2 -eq "No"}
$STATS_MentalHealthRole_Missing = $STATS_MentalHealthRole | where {$_.prior_signs_mental_health_issues2 -eq "Unknown"}

$STATS_LocationType = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Location Type.sql"
$STATS_Depression = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Mental Health Depression.sql"
$STATS_NumTimeWeaponUsed = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Number of time a weapon type is used in a mass shooting.sql"
$STATS_LocationsCity = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (City).sql"
$STATS_LocationState = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (state).sql"
# $STATS_ShootingsPerYear = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting per year.sql"
$STATS_WeaponCombos = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Weapon Type Combos Used.sql"



$OutPut = "@
# Statistics

## General Statistics
- Total Number of Shootings: [$($STATS_TotalRecords.recordcount)]
- Average Age of Shooters: [$($STATS_AverageAge.Average)]

## Shooters with mental health issues:
- Shooters with Mental Health issues were involved in [$($STATS_MentalHealthRole_Yes.shootings)] shootings with a percentage of [$($STATS_MentalHealthRole_Yes.percentage)%] of all mass shootings.
- The Mother Jones database does not include data for [$($STATS_MentalHealthRole_Missing.shootings)] which is [$($STATS_MentalHealthRole_Missing.Percentage)%] of all mass shootings.
- A total of [$($STATS_MentalHealthRole_No.shootings)] mass shootings did not involve a shooter with mental health issues which is [$($STATS_MentalHealthRole_No.Percentage)%] of all mass shootings.
@"

$Output

