Import-Module -Name PSSQLite, ImportExcel, PSLogging

#$CPSScriptRoot = "D:\Code\Repos\US-Mass-Shootings"

# Importing functions
$GetMotherJonesDB = Join-Path -Path $CPSScriptRoot -ChildPath 'Functions' | Join-Path -ChildPath 'Get-MotherJonesDB.ps1'
$NewSQLiteDB = Join-Path -Path $CPSScriptRoot -ChildPath 'Functions' | Join-Path -ChildPath 'New-SQLiteDB.ps1'
$EscapeSQLString = Join-Path -Path $CPSScriptRoot -ChildPath 'Functions' | Join-Path -ChildPath 'Get-EscapeSQLString.ps1'
. $GetMotherJonesDB
. $NewSQLiteDB
    # Function to escape single quotes in SQL string
. $EscapeSQLString

# Variables
$Date = Get-Date -Format "yyyyMMdd"
#$Random = Get-Random
$ExportPath = Join-Path -Path $CPSScriptRoot -ChildPath 'Export'

# SQLite Variables
$SQLitePath = Join-Path -Path $CPSScriptRoot -ChildPath 'Resources' | Join-Path -ChildPath 'System.Data.SQLite.dll'
$DBPath = Join-Path -Path $ExportPath -ChildPath 'MassShooterDatabase.sqlite'

# Import and Export FileName Variables
#ExportWebView = Join-Path -Path $ExportPath -ChildPath 'WebView.html'
$ExportCHEdition = Join-Path -Path $ExportPath -ChildPAth 'Codeholics - Mass Shootings Database 1982-2024.csv'
$ImportCSVPath = Join-Path -Path $ExportPath -ChildPath 'Mother Jones - Mass Shootings Database 1982-2024.csv'

<# Log Variables
$LogPath = Join-Path -Path $CPSScriptRoot -ChildPath 'Logs'
$LogName = "$Date-$Random.log"
$LogFilePath = Join-Path -Path $LogPath -ChildPath $LogName
$Version = "2.0"

# Start Logging
Start-Log -LogPath $LogPath -LogName $LogName -ScriptVersion $Version
#>

########################
## Test SQL File
########################

# This is just to test what the sql output would look like for formatting issues
$CHTestSQLFile = "$CPSScriptRoot\Export\CHtest.sql"
if (Test-Path -Path $CHTestSQLFile) {
    Remove-Item -Path $CHTestSQLFile -Force
    Write-Host "File removed: $CHTestSQLFile"
} else {
    Write-Host "File does not exist: $CHTestSQLFile"
}

$MJTestSQLFile = "$CPSScriptRoot\Export\MJtest.sql"
if (Test-Path -Path $MJTestSQLFile) {
    Remove-Item -Path $MJTestSQLFile -Force
    Write-Host "File removed: $MJTestSQLFile"
} else {
    Write-Host "File does not exist: $MJTestSQLFile"
}

########################
## SQLite Create/Connect
########################

# Create SQLite DB
try {
    New-SQLiteDB -DirRoot $CPSScriptRoot -SQLitePath $SQLitePath -DBPath $DBPath
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] SQLite DB Created [$SQLitePath]" -ToScreen
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Creating SQLite DB [$SQLitePath]" -ToScreen
}

# Connect to the SQLite DB
try {
    $Connection = New-SqliteConnection -DataSource $DBPath
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Connected to SQLite DB [$DBPath]" -ToScreen
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Connecting to SQLite DB [$DBPath]" -ToScreen
}

########################
## CH Edition SQLite
########################

# Import the CH Edition and insert records into SQLite DB
$CH_TableName = 'CHData'
try{
    #$CH_CSV = $DataFinal
    $CH_CSV = Import-CSV -Path $ExportCHEdition | Sort-Object -Property {[DateTime]::ParseExact($_.date,'yyyy-MM-dd',$null)}
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Importing CH Edition [$ExportCHEdition]" -ToScreen
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Importing CH Edition [$ExportCHEdition]" -ToScreen
}

foreach ($item in $CH_CSV) {
    $case = Get-EscapeSQLString $item.case
    $location = Get-EscapeSQLString $item.location
    $city = Get-EscapeSQLString $item.city
    $state = Get-EscapeSQLString $item.state
    $date = Get-EscapeSQLString $item.date
    $summary = Get-EscapeSQLString $item.summary
    $fatalities = Get-EscapeSQLString $item.fatalities
    $injured = Get-EscapeSQLString $item.injured
    $total_victims = Get-EscapeSQLString $item.total_victims
    $location_2 = Get-EscapeSQLString $item.location_2
    $age_of_Shooter = Get-EscapeSQLString $item.age_of_Shooter
    $prior_signs_mental_health_issues = Get-EscapeSQLString $item.prior_signs_mental_health_issues
    $mental_health_details = Get-EscapeSQLString $item.mental_health_details
    $weapons_obtained_legally = Get-EscapeSQLString $item.weapons_obtained_legally
    $where_obtained = Get-EscapeSQLString $item.where_obtained
    $weapon_type = Get-EscapeSQLString $item.weapon_type
    $weapon_details = Get-EscapeSQLString $item.weapon_details
    $race = Get-EscapeSQLString $item.race
    $gender = Get-EscapeSQLString $item.gender
    $sources = Get-EscapeSQLString $item.sources
    $mental_health_sources = Get-EscapeSQLString $item.mental_health_sources
    $sources_additional_age = Get-EscapeSQLString $item.sources_additional_age
    $latitude = Get-EscapeSQLString $item.latitude
    $longitude = Get-EscapeSQLString $item.longitude
    $type = Get-EscapeSQLString $item.type
    $year = Get-EscapeSQLString $item.year
    $changes = Get-EscapeSQLString $item.changes

    # SQL Query to insert records into SQLite DB
    $CH_Query = "INSERT INTO $CH_TableName ([case], location, city, state, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year, changes) VALUES 
    ('$case','$location','$city','$state','$date','$summary','$fatalities','$injured','$total_victims','$location_2','$age_of_Shooter','$prior_signs_mental_health_issues','$mental_health_details','$weapons_obtained_legally','$where_obtained','$weapon_type','$weapon_details','$race','$gender','$sources','$mental_health_sources','$sources_additional_age','$latitude','$longitude','$type','$year','$changes')"
    
    $CH_Query | Out-File -FilePath $CHTestSQLFile -Append

    try {
        Invoke-SqliteQuery -Connection $Connection -Query $CH_Query
        Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Inserted into CH Edition DB: [$case : $date]" -ToScreen
    } catch {
        Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Inserting into CH Edition DB: [$CH_Query]" -ToScreen
    }

    start-sleep -seconds 1

}

########################
## MJ Edition SQLite
########################

# Import the MJ Edition and insert records into SQLite DB
$MJ_TableName = 'MJData'
try{
    #$MJ_CSV = $DataFinal
    $MJ_CSV = Import-CSV -Path $ImportCSVPath | Sort-Object -Property {[DateTime]::ParseExact($_.date,'yyyy-MM-dd',$null)}
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Imported MJ Edition [$ImportCSVPath]" -ToScreen
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Importing MJ Edition [$ImportCSVPath]" -ToScreen
}

foreach ($item in $MJ_CSV) {
    $case = Get-EscapeSQLString $item.case
    $location = Get-EscapeSQLString $item.location
    $date = Get-EscapeSQLString $item.date
    $summary = Get-EscapeSQLString $item.summary
    $fatalities = Get-EscapeSQLString $item.fatalities
    $injured = Get-EscapeSQLString $item.injured
    $total_victims = Get-EscapeSQLString $item.total_victims
    $location_2 = Get-EscapeSQLString $item.location_2
    $age_of_Shooter = Get-EscapeSQLString $item.age_of_Shooter
    $prior_signs_mental_health_issues = Get-EscapeSQLString $item.prior_signs_mental_health_issues
    $mental_health_details = Get-EscapeSQLString $item.mental_health_details
    $weapons_obtained_legally = Get-EscapeSQLString $item.weapons_obtained_legally
    $where_obtained = Get-EscapeSQLString $item.where_obtained
    $weapon_type = Get-EscapeSQLString $item.weapon_type
    $weapon_details = Get-EscapeSQLString $item.weapon_details
    $race = Get-EscapeSQLString $item.race
    $gender = Get-EscapeSQLString $item.gender
    $sources = Get-EscapeSQLString $item.sources
    $mental_health_sources = Get-EscapeSQLString $item.mental_health_sources
    $sources_additional_age = Get-EscapeSQLString $item.sources_additional_age
    $latitude = Get-EscapeSQLString $item.latitude
    $longitude = Get-EscapeSQLString $item.longitude
    $type = Get-EscapeSQLString $item.type
    $year = Get-EscapeSQLString $item.year

    # SQL Query to insert records into SQLite DB
    $MJ_Query = "INSERT INTO $MJ_TableName ([case], location, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year) VALUES 
    ('$case','$location','$date','$summary','$fatalities','$injured','$total_victims','$location_2','$age_of_Shooter','$prior_signs_mental_health_issues','$mental_health_details','$weapons_obtained_legally','$where_obtained','$weapon_type','$weapon_details','$race','$gender','$sources','$mental_health_sources','$sources_additional_age','$latitude','$longitude','$type','$year')"
    
    $MJ_Query | Out-File -FilePath $MJTestSQLFile -Append

    try {
        Invoke-SqliteQuery -Connection $Connection -Query $MJ_Query
        Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Inserted into MJ Edition DB: [$case : $date]" -ToScreen
    } catch {
        Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Inserting into MJ Edition DB: [$MJ_Query]" -ToScreen
    }

    start-sleep -seconds 1

}

# Close the SQLite Connection
$Connection.Close()