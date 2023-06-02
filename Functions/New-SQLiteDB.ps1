function New-SQLiteDB {
<#
    .SYNOPSIS
        Creates a new SQLite database and two tables for storing data on mass shootings.
    .DESCRIPTION
        This function creates a new SQLite database at the specified path, along with two tables for storing data on mass shootings. The `MJData` table contains data on mass shootings in the US from 1982 to August 2019, while the `CHData` table contains data on school shootings in the US from 1990 to August 2019.
    .PARAMETER DirRoot
        Specifies the root directory of the CPS script.
    .PARAMETER SQLitePath
        Specifies the path to the SQLite DLL used for the SQLite connection.
    .PARAMETER DBPath
        Specifies the path to the new SQLite database file.
    .EXAMPLE
        $root = "D:\Github\PowerShell\R AND D\Data World\MJ Mass Shooter Database"
        $sqlite = "C:\PSResources\SQLite\System.Data.SQLite.dll"
        $db = "functionTest.sqlite"
        New-SQLiteDB -DirRoot $root -SQLitePath $sqlite -DBName $db
#>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$DirRoot,
        [Parameter(Mandatory=$true)]
        [string]$SQLitePath,
        [Parameter(Mandatory=$true)]
        [string]$DBPath
    )

    Add-Type -Path $SQLitePath

    # Connect to the database
    $Connection = New-SqliteConnection -DataSource $DBPath

    # Create a table with two columns
    $QueryMJ = @"
    CREATE TABLE MJData (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        [case] TEXT,
        location TEXT,
        date DATE,
        summary TEXT,
        fatalities TEXT,
        injured TEXT,
        total_victims TEXT,
        location_2 TEXT,
        age_of_Shooter TEXT,
        prior_signs_mental_health_issues TEXT,
        mental_health_details TEXT,
        weapons_obtained_legally TEXT,
        where_obtained TEXT,
        weapon_type TEXT,
        weapon_details TEXT,
        race TEXT,
        gender TEXT,
        sources TEXT,
        mental_health_sources TEXT,
        sources_additional_age TEXT,
        latitude TEXT,
        longitude TEXT,
        type TEXT,
        year INTEGER
    );
"@

    Invoke-SqliteQuery -Connection $Connection -Query $QueryMJ

    $QueryCH = @"
    CREATE TABLE CHData (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        [case] TEXT,
        location TEXT,
        city TEXT,
        state TEXT,
        date DATE,
        summary TEXT,
        fatalities TEXT,
        injured TEXT,
        total_victims TEXT,
        location_2 TEXT,
        age_of_Shooter TEXT,
        prior_signs_mental_health_issues TEXT,
        mental_health_details TEXT,
        weapons_obtained_legally TEXT,
        where_obtained TEXT,
        weapon_type TEXT,
        weapon_details TEXT,
        race TEXT,
        gender TEXT,
        sources TEXT,
        mental_health_sources TEXT,
        sources_additional_age TEXT,
        latitude TEXT,
        longitude TEXT,
        type TEXT,
        year INTEGER,
        changes TEXT
    );
"@

    Invoke-SqliteQuery -Connection $Connection -Query $QueryCH

    # Close the connection
    $connection.Close()
    } 
    
<#
    $root = "D:\Github\PowerShell\R AND D\Data World\MJ Mass Shooter Database"
    $sqlite = "C:\PSResources\SQLite\System.Data.SQLite.dll"
    $db = "functionTest.sqlite"
    New-SQLiteDB -DirRoot $root -SQLitePath $sqlite -DBName $db
#>