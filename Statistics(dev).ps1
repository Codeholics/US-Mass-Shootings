# Load the module
Import-Module PSSQLite

<#
.Synopsis
   Converts a PowerShell object to a Markdown table.
.Description
   The ConvertTo-Markdown function converts a Powershell Object to a Markdown formatted table
.EXAMPLE
   Get-Process | Where-Object {$_.mainWindowTitle} | Select-Object ID, Name, Path, Company | ConvertTo-Markdown

   This command gets all the processes that have a main window title, and it displays them in a Markdown table format with the process ID, Name, Path and Company.
.EXAMPLE
   ConvertTo-Markdown (Get-Date)

   This command converts a date object to Markdown table format
.EXAMPLE
   Get-Alias | Select Name, DisplayName | ConvertTo-Markdown

   This command displays the name and displayname of all the aliases for the current session in Markdown table format
#>
Function ConvertTo-Markdown {
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [PSObject[]]$InputObject
    )

    Begin {
        $items = @()
        $columns = [Ordered] @{}
    }

    Process {
        ForEach($item in $InputObject) {
            $items += $item

            $item.PSObject.Properties | %{
                if($_.Value -ne $null){
                    if(-not $columns.Contains($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                        $columns[$_.Name] = $_.Value.ToString().Length
                    }
                }
            }
        }
    }

    End {
        ForEach($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length)
        }

        $header = @()
        ForEach($key in $columns.Keys) {
            $header += ('{0,-' + $columns[$key] + '}') -f $key
        }
        $header -join ' | '

        $separator = @()
        ForEach($key in $columns.Keys) {
            $separator += '-' * $columns[$key]
        }
        $separator -join ' | '

        ForEach($item in $items) {
            $values = @()
            ForEach($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key)
            }
            $values -join ' | '
        }
    }
}

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
    $results = Invoke-SqliteQuery -Connection $connection -Query $query -verbose

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
$STATS_MentalHealthRoleList = $STATS_MentalHealthRole | Select-Object prior_signs_mental_health_issues2,Shootings,percentage | ConvertTo-Markdown
$STATS_MentalHealthRole_withDepressionCount = (Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Mental Health Depression.sql").summaryCount

# Number of time a weapon type is used in a mass shooting
$STATS_NumTimeWeaponUsed = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Number of time a weapon type is used in a mass shooting.sql"
$STATS_NumTimeWeaponUsedList = $STATS_NumTimeWeaponUsed | Select-Object weapon_type,count,percentage | ConvertTo-Markdown

# Location Type
$STATS_LocationType = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Location Type.sql"
$STATS_LocationTypeList = $STATS_LocationType | Select-Object location_2,count,percentage | ConvertTo-Markdown

# Location City
$STATS_LocationCity = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (City).sql"
$STATS_LocationCityList = $STATS_LocationCity | Select-Object Location,Shootings,Victims,VictimsPerShooting,ShootingPercentage | ConvertTo-Markdown

# Location State
$STATS_LocationState = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (state).sql"
$STATS_LocationStateList = $STATS_LocationState | Select-Object State,Shootings,Victims,VictimsPerShooting | ConvertTo-Markdown

# Weapon Combos
$STATS_WeaponCombos = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Weapon Type Combos Used.sql"
$STATS_WeaponCombosList = $STATS_WeaponCombos | Select-Object count,weapon_type | ConvertTo-Markdown

# Shootings Per Year
$STATS_ShootingsPerYear = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting per year.sql"
$STATS_ShootingsPerYearList = $STATS_ShootingsPerYear | Select-Object Year,YearCount,Victims,VictimsPerShooting | ConvertTo-Markdown




$OutPut = "@
- [Statistics](#statistics)
  - [General Statistics](#general-statistics)
  - [Shooters with Mental Health Issues](#shooters-with-mental-health-issues)
  - [Number of Times a Weapon Type is Used in a Mass Shooting](#number-of-times-a-weapon-type-is-used-in-a-mass-shooting)
  - [Location Type](#location-type)
  - [Location City](#location-city)
  - [Location State](#location-state)
  - [Weapon Combos](#weapon-combos)
  - [Shootings Per Year](#shootings-per-year)

# Statistics

## General Statistics

- Total Number of Shootings: ``$($STATS_TotalRecords.recordcount)``
- Average Age of Shooters: ``$($STATS_AverageAge.Average)``
- Shooters with Depression ``$($STATS_MentalHealthRole_withDepressionCount)``


## Shootings Per Year

$($STATS_ShootingsPerYearList | format-table -AutoSize | Out-String)

## Location Type

$($STATS_LocationTypeList | format-table -AutoSize | Out-String)

## Location City

$($STATS_LocationCityList | format-table -AutoSize | Out-String)

## Location State

$($STATS_LocationStateList | format-table -AutoSize | Out-String)

## Shooters with Mental Health Issues

$($STATS_MentalHealthRoleList | format-table -AutoSize | Out-String)

## Number of Times a Weapon Type is Used in a Mass Shooting

$($STATS_NumTimeWeaponUsedList | format-table -AutoSize | Out-String)

## Weapon Combos

$($STATS_WeaponCombosList.trim('') | format-table -AutoSize | Out-String)


@"


$OutPut > "$CPSScriptRoot\Statistics.md"

