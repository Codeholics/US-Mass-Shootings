# Load the module
Import-Module PSSQLite

<#
    .SYNOPSIS
        This commandlet output a table in markdown syntax

    .DESCRIPTION
        This commandlet output quote in markdown syntax by adding a two rows for the header and then one line per entry in the array.

    .PARAMETER  Object
        Any object

    .PARAMETER NoNewLine
        Controls if a new line is added at the end of the output

    .PARAMETER Columns
        The columns that compose the table. Columns must be an ordered hashtable [ordered]@{} where the keys are the column names and as optional value (left,center,right).

    .PARAMETER Shrink
        Shrinks each row to just actually fill the data

    .EXAMPLE
        Get-Command New-MDTable |Select-Object Name,CommandType | New-MDTable

        | Name        | CommandType |
        | ----------- | ----------- |
        | New-MDTable | Function    |

    .EXAMPLE
        Get-Command New-MDTable |Select-Object Name,CommandType | New-MDTable -Shrink

        | Name | CommandType |
        | ---- | ----------- |
        | New-MDTable | Function |

    .EXAMPLE
        Get-Command New-MDTable | New-MDTable -Columns ([ordered]@{Name=$null;CommandType=$null})

        | Name        | CommandType |
        | ----------- | ----------- |
        | New-MDTable | Function    |

    .EXAMPLE
        Get-Command New-MDTable | New-MDTable -Columns ([ordered]@{CommandType=$null;Name=$null})

        | CommandType | Name        |
        | ----------- | ----------- |
        | Function    | New-MDTable |

    .EXAMPLE
        Get-Command New-MDTable | New-MDTable -Columns (@{CommandType=$null;Name=$null})

        | Name        | CommandType |
        | ----------- | ----------- |
        | New-MDTable | Function    |

    .EXAMPLE
        Get-Command New-MDTable | New-MDTable -Columns ([ordered]@{Name="left";CommandType="center";Version="right"})
        | Name        | CommandType | Version     |
        | ----------- |:-----------:| -----------:|
        | New-MDTable | Function    |             |

    .INPUTS
        Any table

    .OUTPUTS
        A table representation in markdown

    .NOTES
        Use the -NoNewLine parameter when you don't want the next markdown content to be separated.
#>
function New-MDTable {
    [CmdletBinding()]
        [OutputType([string])]
        Param (
            [Parameter(
                Mandatory = $true,
                Position = 0,
                ValueFromPipeline = $true
            )]
            [PSObject[]]$Object,
            [Parameter(
                Mandatory = $false
            )]
            $Columns=$null,
            [Parameter(
                ValueFromPipeline = $false
            )]
            [ValidateNotNullOrEmpty()]
            [switch]$NoNewLine=$false,
            [switch]$Shrink=$false
    
        )
    
        Begin {
            $items = @()
            $maxLengthByColumn = @{}
            $output = ""
        }
    
        Process {
            ForEach($item in $Object) 
            {
                $items += $item
            }
            if(-not $Columns)
            {
                $Columns=[ordered]@{}
                ForEach($item in $Object) 
                {
                    $item.PSObject.Properties | ForEach-Object {
                        if(-not $Columns.Contains($_.Name))
                        {
                            $Columns[$_.Name] = $null
                        }
                    }
                }
            }
            
            if(-not $Shrink)
            {
                ForEach($key in $Columns.Keys) 
                {
                    if(-not $maxLengthByColumn.ContainsKey($key))
                    {
                        $maxLengthByColumn[$key] = $key.Length
                    }
                }
                ForEach($item in $Object) {
                    $item.PSObject.Properties | ForEach-Object {
                        $name = $_.Name
                        $value = $_.Value
                        if($Columns.Contains($name) -and $null -ne $value)
                        {
                            $valueLength = $value.ToString().Length
                            $maxLengthByColumn[$name] = [Math]::Max($maxLengthByColumn[$name], $valueLength)
                        }
                    }
                }
            }
        }
    
        End {
            $lines=@()
            $header = @()
            ForEach($key in $Columns.Keys) 
            {
                if(-not $Shrink)
                {
                    $header += ('{0,-' + $maxLengthByColumn[$key] + '}') -f $key
                }
                else {
                    $header += $key
                }
            }
            $lines += '| '+($header -join ' | ')+' |'
    
            $separator = @()
            ForEach($key in $Columns.Keys) 
            {
                if(-not $Shrink)
                {
                    $dashes = '-' * $maxLengthByColumn[$key]
                }
                else {
                    $dashes = '-' * $key.Length
                }
                switch($Columns[$key]) 
                {
                    "left" {
                        $separator += ' '+ $dashes +' '
                    }
                    "right" {
                        $separator += ' '+ $dashes +':'
                    }  
                    "center" {
                        $separator += ':'+ $dashes +':'
                    }
                    default {
                        $separator += ' '+ $dashes +' '
                    }  
                }
            }
            $lines += '|'+($separator -join '|')+'|'
    
            ForEach($item in $items) {
                $values = @()
                ForEach($key in $Columns.Keys) 
                {
                    if(-not $Shrink)
                    {
                        $values += ('{0,-' + $maxLengthByColumn[$key] + '}') -f $item.($key)
                    }
                    else {
                        $values += $item.($key)
                    }
                }
                $lines += '| '+ ($values -join ' | ') + ' |'
            }
            $output+=$lines -join  [System.Environment]::NewLine
    
            if(-not $NoNewLine)
            {
                $output += [System.Environment]::NewLine
            }
            $output
        }
    }

$CPSScriptRoot = "D:\Code\Repos\US-Mass-Shootings\"

Add-Type -Path "$CPSScriptRoot\Resources\System.Data.SQLite.dll"

# Connect to the database
$connection = New-SqliteConnection -DataSource "$CPSScriptRoot\Export\MassShooterDatabase.sqlite"

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
$STATS_MentalHealthRole_withDepressionCount = (Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Mental Health Depression.sql").summaryCount

# Number of time a weapon type is used in a mass shooting
$STATS_NumTimeWeaponUsed = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Number of time a weapon type is used in a mass shooting.sql"

# Location Type
$STATS_LocationType = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Location Type.sql"

# Location City
$STATS_LocationCity = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (City).sql"

# Location State
$STATS_LocationState = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting Locations (state).sql"

# Weapon Combos
$STATS_WeaponCombos = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Weapon Type Combos Used.sql"

# Shootings Per Year
$STATS_ShootingsPerYear = Get-Statistics -Connection $connection -QueryPath "$CPSScriptRoot\SQL\CHData - Shooting per year.sql"
# $STATS_ShootingsPerYearList = $STATS_ShootingsPerYear | Select-Object Year,YearCount,Victims,VictimsPerShooting,YearCountPercentage | ConvertTo-Markdown




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

$($STATS_ShootingsPerYear | New-MDTable -Shrink | Out-String)

## Location Type

$($STATS_LocationType | New-MDTable -Shrink | Out-String)

## Location City

$($STATS_LocationCity | New-MDTable -Shrink | Out-String)

## Location State

$($STATS_LocationState | New-MDTable -Shrink | Out-String)

## Shooters with Mental Health Issues

$($STATS_MentalHealthRole | New-MDTable -Shrink | Out-String)

## Number of Times a Weapon Type is Used in a Mass Shooting

$($STATS_NumTimeWeaponUsed | New-MDTable -Shrink | Out-String)

## Weapon Combos

$($STATS_WeaponCombos | New-MDTable -Shrink | Out-String)


@"


$OutPut > "$CPSScriptRoot\Statistics.md"
