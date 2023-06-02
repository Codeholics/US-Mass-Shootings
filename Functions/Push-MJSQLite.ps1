Function Push-CHSQLite {
<#
    .SYNOPSIS
        Imports data from a CSV file into a SQLite database table.
    .DESCRIPTION
        This function imports data from a CSV file into a specified SQLite database table. The function sorts the data by date before importing it into the table.
    .PARAMETER CPSScriptRoot
        Specifies the root directory of the CPS script.
    .PARAMETER DBPath
        Specifies the path to the SQLite database file.
    .PARAMETER CSVPath
        Specifies the path to the CSV file containing the data to be imported.
    .PARAMETER SQLitePath
        Specifies the path to the SQLite DLL used for the SQLite connection.
    .PARAMETER TableName
        Specifies the name of the table to import data into.
    .EXAMPLE
        Push-CHSQLite -CPSScriptRoot "C:\CPS\" -DBPath "C:\data\test.db" -CSVPath "C:\data\test.csv" -SQLitePath "C:\SQLite\SQLite.Interop.dll" -TableName "test_table"
#>
    param (
        [Parameter(Mandatory=$true)]
        [string]$CPSScriptRoot,
        [Parameter(Mandatory=$true)]
        [string]$DBPath,
        [Parameter(Mandatory=$true)]
        [string]$CSVPath,
        [Parameter(Mandatory=$true)]
        [string]$SQLitePath,
        [Parameter(Mandatory=$true)]
        [string]$TableName
    )

    Add-Type -Path $SQLitePath

    # Connect to the database
    $Connection = New-SqliteConnection -DataSource $DBPath

    # Import the CSV file into the table
    $CSV = Import-Csv -Path $CSVPath | Sort-Object -Property {[DateTime]::ParseExact($_.date,'yyyy-MM-dd',$null)}
    $CSV | ForEach-Object {
        $Query = "INSERT INTO $TableName ([case], location, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year) VALUES 
        ('$($_.case)','$($_.location)','$($_.date)','$($_.summary)','$($_.fatalities)','$($_.injured)','$($_.total_victims)','$($_.location_2)','$($_.age_of_Shooter)','$($_.prior_signs_mental_health_issues)','$($_.mental_health_details)','$($_.weapons_obtained_legally)','$($_.where_obtained)','$($_.weapon_type)','$($_.weapon_details)','$($_.race)','$($_.gender)','$($_.sources)','$($_.mental_health_sources)','$($_.sources_additional_age)','$($_.latitude)','$($_.longitude)','$($_.type)','$($_.year)')"
        $Query
        Invoke-SqliteQuery -Connection $Connection -Query $Query
    }

    # Close the connection
    $Connection.Close()
} 

# Push-MJSQLite -DBPath "$CPSScriptRoot\Export\CHData.sqlite" -CSVPath "$CPSScriptRoot\Export\CHData.csv" -SQLitePath "$CPSScriptRoot\Functions\SQLite\SQLite.Interop.dll" -CPSScriptRoot $CPSScriptRoot -TableName 'CHData'
