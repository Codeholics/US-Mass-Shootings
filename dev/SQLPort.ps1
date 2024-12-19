Import-Module -Name PSSQLite, ImportExcel, PSLogging

$CPSScriptRoot = "D:\Code\Repos\US-Mass-Shootings\dev"

# Function to escape single quotes in SQL string
. "$CPSScriptRoot\functions\Get-EscapeSQLString.ps1"


##########################
## SQLite Section Below
##########################

# This is just to test what the sql output would look like for formatting issues
$TestSQLFile = "D:\Code\Repos\US-Mass-Shootings\dev\test.sql"
if (Test-Path -Path $TestSQLFile) {
    Remove-Item -Path $TestSQLFile -Force
    Write-Host "File removed: $TestSQLFile"
} else {
    Write-Host "File does not exist: $TestSQLFile"
}


########################
## CH Edition SQLite
########################

# Import the CH Edition and insert records into SQLite DB
$CH_TableName = 'CHData'
try{
    $CH_CSV = $DataFinal
    #$CH_CSV = Import-CSV -Path $ExportCHEdition | Sort-Object -Property {[DateTime]::ParseExact($_.date,'yyyy-MM-dd',$null)}
    #Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Importing CH Edition [$ExportCHEdition]" -ToScreen
}catch{
    #Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Importing CH Edition [$ExportCHEdition]" -ToScreen
}

foreach ($item in $CH_CSV) {
    $case = Get-EscapeSQLString $item.case
    $location = Get-EscapeSQLString $itemlocation
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
    $CH_Query = "INSERT INTO $CH_TableName ([case], location, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year) VALUES 
    ('[$case]','$location','$date','$summary','$fatalities','$injured','$total_victims','$location_2','$age_of_Shooter','$prior_signs_mental_health_issues','$mental_health_details','$weapons_obtained_legally','$where_obtained','$weapon_type','$weapon_details','$race','$gender','$sources','$mental_health_sources','$sources_additional_age','$latitude','$longitude','$type','$year')"
    
    $CH_Query | Out-File -FilePath $TestSQLFile -Append
    #Invoke-SqliteQuery -Connection $Connection -Query $MJ_Query

}

########################
## MJ Edition SQLite
########################

<#
Insert SQL insert like above but for MJ Edition
#>