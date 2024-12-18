Import-Module -Name PSWriteHTML, PSSQLite, PSLogging

# Root folder of the script
$CPSScriptRoot = 'D:\Code\Repos\US-Mass-Shootings'

# Importing functions
$GetMotherJonesDB = Join-Path -Path $CPSScriptRoot -ChildPath 'Functions' | Join-Path -ChildPath 'Get-MotherJonesDB.ps1'
$NewSQLiteDB = Join-Path -Path $CPSScriptRoot -ChildPath 'Functions' | Join-Path -ChildPath 'New-SQLiteDB.ps1'
. $GetMotherJonesDB
. $NewSQLiteDB

# Variables
$Date = Get-Date -Format "yyyyMMdd"
$Random = Get-Random
$ExportPath = Join-Path -Path $CPSScriptRoot -ChildPath 'Export'

# SQLite Variables
$SQLitePath = Join-Path -Path $CPSScriptRoot -ChildPath 'Resources' | Join-Path -ChildPath 'System.Data.SQLite.dll'
$DBPath = Join-Path -Path $ExportPath -ChildPath 'MassShooterDatabase.sqlite'

# Import and Export FileName Variables
$ExportWebView = Join-Path -Path $ExportPath -ChildPath 'WebView.html'
$ExportCHEdition = Join-Path -Path $ExportPath -ChildPAth 'Codeholics - Mass Shootings Database 1982-2024.csv'
$ImportCSVPath = Join-Path -Path $ExportPath -ChildPath 'Mother Jones - Mass Shootings Database 1982-2024.csv'

# Log Variables
$LogPath = Join-Path -Path $CPSScriptRoot -ChildPath 'Logs'
$LogName = "$Date-$Random.log"
$LogFilePath = Join-Path -Path $LogPath -ChildPath $LogName
$Version = "1.1"

# Start Logging
Start-Log -LogPath $LogPath -LogName $LogName -ScriptVersion $Version

# Logging submitted parameters
#Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Import Type: [$Import_Type] | AD Fields: [$AD_Fields] | File: [$UserSubmittedList]" -ToScreen

# create Export folder if not exist
if (!(Test-Path $ExportPath)) {
    New-Item -Path $ExportPath -ItemType Directory
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Created Export Folder: [$ExportPath]" -ToScreen
}elseif (Test-Path $ExportPath) {
    Remove-Item -Path $ExportPath -Recurse -Force
    New-Item -Path $ExportPath -ItemType Directory
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Export Folder: [$ExportPath] already exists" -ToScreen
}

# Get Mother Jones CSV and create a new copy without duplicate headers.
try {
    Get-MotherJonesDB -Output $ExportPath
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV copied to: [$ExportPath]" -ToScreen
}
Catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV copy failed" -ToScreen
}

# Check and confrim the new CSV is avaiable before continuing
try {
    $Spreadsheet = (Import-csv -Path $ImportCSVPath)
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV imported from: [$ImportCSVPath]" -ToScreen
}catch {
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Mother Jones CSV import failed" -ToScreen
}

# Main loop that will correct the data from MJ to build CH edition
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Starting column data correction loop" -ToScreen
$Data = @()
foreach($item in $Spreadsheet) {

    # Variable Assignments
    $gender = $item.gender
    $type = $item.type
    $mental_health_sources = $item.mental_health_sources
    $age_of_shooter = $item.age_of_shooter
    $weapon_details = $item.weapon_details
    $latitude = $item.latitude
    $longitude = $item.longitude
    $year = $item.year
    $changes = $item.changes
    $sources = $item.sources
    $sources_additional_age = $item.sources_additional_age
    $total_victims = $item.total_victims
    $injured = $item.injured
    $fatalities = $item.fatalities
    $summary = $item.summary
    $date = $item.date
    $location = $item.location
    $case = $item.case
    $mental_health_details = $item.mental_health_details
    $where_obtained = $item.where_obtained
    $weapons_obtained_legally = $item.weapons_obtained_legally
    $weapon_type = $item.weapon_type
    $race = $item.race
    $location_2 = $item.location_2
    $prior_signs_mental_health_issues = $item.prior_signs_mental_health_issues
    
    
    #Splitting city out of location
    $CityRaw = $location
    $CityOnly = $CityRaw -replace ',.*',''
    $City = $CityOnly.trim('')
    
    #Splitting out state from location
    $StateRaw = $location
    $StateOnly = $StateRaw -replace '.*,',''
    $state  = $StateOnly.trim('')

    #force first character of race caps
    $RaceCaps = $race
    $race = $RaceCaps.toCharArray()[0].tostring().toUpper() + $RaceCaps.remove(0,1)
    $race = $race -replace '^[-]+$', ''

    #force first character of location_2 caps
    $LocationCaps = $location_2
    $location_2 = $LocationCaps.toCharArray()[0].tostring().toUpper() + $LocationCaps.remove(0, 1)
    $location_2 = $location_2.trim('')
    
    #force first character of prior_signs_mental_health_issues caps
    $PriorSignsMentalHealthIssuesCaps = $prior_signs_mental_health_issues
    $PriorSignsMentalHealthIssues = $PriorSignsMentalHealthIssuesCaps.toCharArray()[0].tostring().toUpper() + $PriorSignsMentalHealthIssuesCaps.remove(0, 1)
    $PriorSignsMentalHealthIssues = $PriorSignsMentalHealthIssues -replace '^[-]+$', ''

    #force first character of weapon_type
    $WeaponTypeCaps = $weapon_type
    $WeaponType = $WeaponTypeCaps.toCharArray()[0].tostring().toUpper() + $WeaponTypeCaps.remove(0, 1)

    #force first character of gender caps 
    $GenderCaps = $gender
    $gender = $GenderCaps.toCharArray()[0].tostring().toUpper() + $GenderCaps.remove(0,1)
    
    #force first character of weapons_obtained_legally caps
    $weapons_obtained_legallyCaps = $weapons_obtained_legally
    $weapons_obtained_legally = $weapons_obtained_legallyCaps.toCharArray()[0].tostring().toUpper() + $weapons_obtained_legallyCaps.remove(0,1)
    $weapons_obtained_legally = $weapons_obtained_legally -replace '^[-]+$', ''

    #force first character of gender caps
    $where_obtainedCaps = $where_obtained
    $where_obtained = $where_obtainedCaps.toCharArray()[0].tostring().toUpper() + $where_obtainedCaps.remove(0,1)
    $where_obtained = $where_obtained -replace '^[-]+$', ''

    #force first character of mental_health_details caps
    $mental_health_detailsCaps = $mental_health_details
    $mental_health_details = $mental_health_detailsCaps.toCharArray()[0].tostring().toUpper() + $mental_health_detailsCaps.remove(0,1)
    $mental_health_details = $mental_health_details -replace '^[-]+$', ''

    # Removing - from age_of_shooter
    $age_of_shooter = $age_of_shooter -replace '^[-]+$', ''

    # Removing - from weapon_details
    $weapon_details = $weapon_details -replace '^[-]+$', ''

    # Removing - from mental_health_sources
    $mental_health_sources = $mental_health_sources -replace '^[-]+$', ''

    # Removing - from latitude
    $latitude = $latitude -replace '^[-]+$', ''

    # Removing - from longitude
    $longitude = $longitude -replace '^[-]+$', ''

    #the gender values are not consistnt, abbreviating the gender value for more consistent data
    $GenderValueLength = $gender
    if($GenderValueLength -eq 4){
        $gender = 'M'
    }elseif ($GenderValueLength -eq 6) {
        $gender = 'F'
    }elseif($GenderValueLength -eq 13){
        $gender = 'M/F'
    }else{
        #Do nothing if the value length is 1. (result already "M", "F" or "M/F")
        $gender = $gender
    }

    if ($souce -like '*;*') {
        $sources = $sources -replace ';', ','
    }

    # Final Data Array for CH Edition
    $Data += [PSCustomObject]@{
        case = $case
        location = $location
        city = $City
        state = $State
        date = $date
        summary = $summary
        fatalities = $fatalities
        injured = $injured
        total_victims = $total_victims
        location_2 = $Location_2
        age_of_Shooter = $age_of_shooter
        prior_signs_mental_health_issues = $PriorSignsMentalHealthIssues
        mental_health_details = $mental_health_details
        weapons_obtained_legally = $weapons_obtained_legally
        where_obtained = $where_obtained
        weapon_type = $WeaponType
        weapon_details = $weapon_details
        race = $race
        gender = $gender
        sources = $sources
        mental_health_sources = $mental_health_sources
        sources_additional_age = $sources_additional_age
        latitude = $latitude
        longitude = $longitude
        type = $type
        year = $year
        changes = $changes
    }
} 


# RowIndex1
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 1" -ToScreen
$rowIndex1 = [array]::IndexOf($data.summary,'Michael Louis, 45, killed four, including two doctors, and took his own life, according to authorities. "The gunman, who the chief said fatally shot himself, had been carrying a letter saying he blamed his surgeon for continuing back pain and intended to kill him and anyone who got in the way," according to the New York Times. Louis purchased the AR-15-style rifle he used the day of the attack, according to city Police Chief Wendell Franklin.')
$data[$rowIndex1].injured = "0"
$data[$rowIndex1].total_victims = "4"
$data[$rowIndex1].age_of_Shooter = "45"
$data[$rowIndex1].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex1].changes = "Updated injured, total_victims, age_of_shooter, weapon_type"
#$data[$rowIndex1]

# RowIndex2
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 2" -ToScreen
$rowIndex2 = [array]::IndexOf($data.case,'Thousand Oaks nightclub shooting')
$data[$rowIndex2].weapon_type = "One semiautomatic handgun"
$data[$rowIndex2].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex2]

# RowIndex3
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 3" -ToScreen
$rowIndex3 = [array]::IndexOf($data.summary,'Audrey Hale, 28, who was a former student at the private Covenant School (pre-school; K-6), killed three adults and three 9-year-old children, before being shot dead by responding police.')
$data[$rowIndex3].gender = "TM"
$data[$RowIndex3].weapon_type = "One semiautomatic rifle, one pistol caliber carbine, one semiautomatic handgun"
$data[$rowIndex3].mental_health_sources = "https://www.nytimes.com/live/2023/03/28/us/nashville-school-shooting-tennessee"
$data[$rowIndex3].prior_signs_mental_health_issues = "Yes"
$data[$rowIndex3].mental_health_details = "Police Say Shooter Was Under Doctors Care for Emotional Disorder"
$data[$rowIndex3].weapon_details = "was in possession of an AR-15 military-style rifle, a 9 mm Kel-Tec SUB2000 pistol caliber carbine, and a 9mm Smith and Wesson M&P Shield EZ 2.0 handgun. The AR-15 and 9 mm pistol caliber carbine appear to have 30-round magazines"
$data[$rowIndex3].sources = "https://www.tennessean.com/story/news/crime/2023/03/27/nashville-mourns-mass-shooting-covenant-school/70052585007/; https://www.wsmv.com/2023/03/27/vumc-3-students-2-adults-dead-police-say-shooter-also-dead-covenant-school/; https://www.washingtonpost.com/nation/2023/03/27/nashville-shooting-covenant-school/; https://www.nytimes.com/live/2023/03/27/us/nashville-shooting-covenant-school; https://www.nytimes.com/article/nashville-school-shooting-tennessee.html; https://www.washingtonpost.com/nation/2023/03/27/nashville-school-shooting/; https://www.kq2.com/news/national/heres-what-we-know-about-the-guns-used-in-the-nashville-school-shooting/"
$data[$rowIndex3].changes = "Updated gender to be consistent (TM Trans Male). Old value was F (identifies as transgender and Audrey Hale is a biological woman who, on a social media profile, used male pronouns,? according to Nashville Metro PD officials). weapon_type, mental health, and weapon details updated. Added sources."
#$data[$rowIndex3]

# RowIndex4
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 4" -ToScreen
$rowIndex4 = [array]::IndexOf($data.case,'Capital Gazette shooting')
$data[$rowIndex4].weapon_type = "One shotgun"
$data[$rowIndex4].changes = "Updated weapon type to match the weapon desc and to keep values consistent"
#$data[$rowIndex4]

# RowIndex5
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 5" -ToScreen
$rowIndex5 = [array]::IndexOf($data.summary,'Kurt Myers, 64, shot six people in neighboring towns, killing two in a barbershop and two at a car care business, before being killed by officers in a shootout after a nearly 19-hour standoff.')
$data[$rowIndex5].weapon_type = "One shotgun"
$data[$rowIndex5].changes = "Updated weapon type to match the weapon desc and to keep values consistent"
#$data[$rowIndex5]

# RowIndex6
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 6" -ToScreen
$rowIndex6 = [array]::IndexOf($data.weapon_type,'2 handguns')
$data[$rowIndex6].weapon_type = "Two handguns"
$data[$rowIndex6].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex6]

# RowIndex7
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 7" -ToScreen
$rowIndex7 = [array]::IndexOf($data.summary,'Suspected gunman Robert "Bobby" Crimo, 21, allegedly opened fire with a rifle from a rooftop during an Independence Day parade, unleashing several bursts of rapid fire, and then escaped from the scene as police responded. He was taken into custody about eight hours later, a few miles from the scene of the attack, following a large-scale manhunt by law enforcement. (*Further details pending.)')
$data[$rowIndex7].weapon_type = "One semiautomatic rifle"
$data[$rowIndex7].changes = "Updated weapon type to match the weapon desc and to keep values consistent"
#$data[$rowIndex7]

# RowIndex8
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 8" -ToScreen
$rowIndex8 = [array]::IndexOf($data.summary,'Samuel Cassidy, 57, a Valley Transportation Authorty employee, opened fire at a union meeting at the light rail facility, soon also fatally shooting himself at the scene. Before the attack, Cassidy had set fire to his own house, where he also had firearms and a stockpile of ammunition. His legal history included his ex-wife filing a restraining order against him in 2009.')
$data[$rowIndex8].weapon_type = "One Semiautomatic handgun"
$data[$rowIndex8].changes = "Updated weapon type to match the weapon desc and to keep values consistent"
#$data[$rowIndex8]

# RowIndex9
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 9" -ToScreen
$rowIndex9 = [array]::IndexOf($data.summary,'Robert Lewis Dear, 57, shot and killed a police officer and two citizens when he opened fire at a Planned Parenthood health clinic in Colorado Springs, Colorado. Nine others were wounded. Dear was arrested after an hours-long standoff with police.')
$data[$rowIndex9].weapon_type = "Seven semiautomatic rifles, one shotgun, five handguns"
$data[$rowIndex9].weapon_details = "Dear had with him four SKS rifles, five handguns, two additional rifles, a shotgun, more than 500 rounds of ammunition, as well as propane tanks"
$data[$rowIndex9].sources = "http://www.nytimes.com/2015/11/28/us/colorado-planned-parenthood-shooting.html and http://www.cnn.com/2015/12/09/us/colorado-planned-parenthood-shooting/ and http://www.npr.org/sections/thetwo-way/2015/11/28/457674369/planned-parenthood-shooting-police-name-suspect-procession-for-fallen-officer and http://www.cbsnews.com/news/robert-lewis-dear-planned-parenthood-first-court-appearance/ and http://www.denverpost.com/news/ci_29729326/judge-wont-release-all-records-accused-planned-parenthood and http://www.csindy.com/IndyBlog/archives/2016/02/17/judge-resists-unsealing-dear-affidavits; http://www.nbcnews.com/news/us-news/who-robert-dear-planned-parenthood-shooting-suspect-seemed-strange-not-n470896; https://www.justice.gov/opa/pr/robert-dear-indicted-federal-grand-jury-2015-planned-parenthood-clinic-shooting"
$data[$rowIndex9].changes = "Updated weapon type to be more consistent, updated weapon details according to new source link from justice.gov"
#$data[$rowIndex9]

# RowIndex10
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 10" -ToScreen
$rowIndex10 = [array]::IndexOf($data.case,'Pennsylvania hotel bar shooting')
$data[$rowIndex10].weapon_type = "One handgun"
$data[$rowIndex10].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex10]

# RowIndex11
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 11" -ToScreen
$rowIndex11 = [array]::IndexOf($data.case,'SunTrust bank shooting')
$data[$rowIndex11].weapon_type = "One semiautomatic handgun"
$data[$rowIndex11].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex11]

# RowIndex12
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 12" -ToScreen
$rowIndex12 = [array]::IndexOf($data.summary,'Javier Casarez, 54, who was going through a bitter divorce, went on a shooting spree targeting his ex-wife and former coworkers at the trucking company. His attack included fatally shooting one victim who he pursued to a nearby sporting goods retailer, and two others at a private residence. After then carjacking a woman who was driving with a child (and letting the two go), Casarez fatally shot himself as law enforcement officials closed in on him.')
$data[$rowIndex12].weapon_type = "One revolver"
$data[$rowIndex12].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex12]

# RowIndex13
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 13" -ToScreen
$rowIndex13 = [array]::IndexOf($data.summary,'Radee Labeeb Prince, 37, fatally shot three people and wounded two others around 9am at Advance Granite Solutions, a home remodeling business where he worked near Baltimore. Hours later he shot and wounded a sixth person at a car dealership in Wilmington, Delaware. He was apprehended that evening following a manhunt by authorities.')
$data[$rowIndex13].weapon_type = "One semiautomatic handgun"
$data[$rowIndex13].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex13]

# RowIndex14
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Update 14" -ToScreen
$rowIndex14 = [array]::IndexOf($data.summary,'Kori Ali Muhammad, 39, opened fire along a street in downtown Fresno, killing three people randomly in an alleged hate crime prior to being apprehended by police. Muhammad, who is black, killed three white victims and later described his attack as being racially motivated; he also reportedly yelled ''Allahu Akbar'' at the time he was arrested, but authorities indicated they found no links to Islamist terrorism.')
$data[$rowIndex14].weapon_type = "One revolver"
$data[$rowIndex14].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex14]

# RowIndex15
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 15" -ToScreen
$rowIndex15 = [array]::IndexOf($data.summary,'Dylann Storm Roof, 21, shot and killed 9 people after opening fire at the Emanuel AME Church in Charleston, South Carolina. According to a roommate, he had allegedly been “planning something like that for six months."')
$data[$rowIndex15].weapon_type = "One semiautomatic handgun"
$data[$rowIndex15].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex15]

# RowIndex16
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 16" -ToScreen
$rowIndex16 = [array]::IndexOf($data.case,'Marysville-Pilchuck High School shooting')
$data[$rowIndex16].weapon_type = "One semiautomatic handgun"
$data[$rowIndex16].changes = "Updated weapon type to be more consistent"
#$data[$rowIndex16]

# RowIndex17
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 17" -ToScreen
$rowIndex17 = [array]::IndexOf($data.summary,'Army Specialist Ivan Lopez, 34, opened fire at the Fort Hood Army Post in Texas, killing three and wounding at least 12 others before shooting himself in the head after engaging with military police. Lt. Gen. Mark A. Milley told reporters that Lopez "had behavioral health and mental health" issues.')
$data[$rowIndex17].weapon_type = "One semiautomatic handgun"
$data[$rowIndex17].weapons_obtained_legally = "Yes"
$data[$rowIndex17].changes = "Updated weapon type to be more consistent, removed a new line from weapons_obtained_legally"
#$data[$rowIndex17]

# RowIndex18
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 18" -ToScreen
$rowIndex18 = [array]::IndexOf($data.summary,'Anthony Ferrill, 51, an employee armed with two handguns, including one with a silencer, opened fire on the Milwaukee campus of the beer company, killing five people and then committing suicide. According to the Milwaukee Journal Sentinel, Ferrill "had been involved in a long-running dispute with a co-worker that boiled over" in the run-up to the attack.')
$data[$rowIndex18].weapon_type = "Two handguns"
$data[$rowIndex18].changes = "Updated weapon type to be more consistent. Reviewed all source links, no mention of semiautomatic or gun details."
#$data[$rowIndex18]

# RowIndex19
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 19" -ToScreen
$rowIndex19 = [array]::IndexOf($data.summary,'"A man believed to be meeting his three children for a supervised visit at a church just outside Sacramento on Monday afternoon fatally shot the children and an adult accompanying them before killing himself, police officials said. Sheriff Scott Jones of Sacramento County told reporters at the scene that the gunman had a restraining order against him, and that he had to have supervised visits with his children, who were younger than 15." (NYTimes)')
$data[$rowIndex19].age_of_Shooter = "39"
$data[$rowIndex19].weapon_type = "One semiautomatic rifle"
$data[$rowIndex19].changes = "Age of shooter found in source link. Weapon type updated to be more consistent with other records."
#$data[$rowIndex19]

# RowIndex20
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 20" -ToScreen
$rowIndex20 = [array]::IndexOf($data.summary,'Aminadab Gaxiola Gonzalez, 44, allegedly opened fire inside a small business at an office complex, killing at least four victims, including a nine-year-old boy, before being wounded in a confrontation with police and taken into custody. According to law enforcement officials, Gonzalez had chained the front and rear gates to the complex with bicycle cable locks to hinder police response.')
$data[$rowIndex20].age_of_Shooter = "44"
$data[$rowIndex20].weapon_type = "One semiautomatic handgun"
$data[$rowIndex20].changes = "Age of shooter found in summary, updated weapon type to be consistent"
#$data[$rowIndex20]

# RowIndex21
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 21" -ToScreen
$rowIndex21 = [array]::IndexOf($data.summary,'Gary Martin, 45, went on a rampage inside the warehouse in response to being fired from his job and died soon thereafter in a shootout with police. Among his victims were five dead coworkers and five injured police officers. Martin had a felony record and lengthy history of domestic violence; he was able to obtain a gun despite having had his Illinois firearms ownership identification card revoked. According to a report from prosecutors, Martin told a co-worker the morning of the shooting that if he was fired he was going to kill employees and police.')
$data[$rowIndex21].weapon_type = "One semiautomatic handgun"
$data[$rowIndex21].weapon_details = "Smith & Wesson .40 cal handgun, with a green sighting laser"
$data[$rowIndex21].changes = "Updated weapon type based on the information in weapon details so data is consistent."
#$data[$rowIndex21]

# RowIndex22
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 22" -ToScreen
$rowIndex22 = [array]::IndexOf($data.summary,'David N. Anderson, 47, and Francine Graham, 50, were heavily armed and traveling in a white van when they first killed a police officer in a cemetery, and then opened fire at a kosher market, “fueled both by anti-Semitism and anti-law enforcement beliefs,” according to New Jersey authorities. The pair, linked to the antisemitic ideology of the Black Hebrew Israelites extremist group, were killed after a lenghty gun battle with police at the market.')
$data[$rowIndex22].weapon_type = "One assault rifle, two semiautomatic pistols, one shotgun"
$data[$rowIndex22].weapon_details = "AR-15-style rifle, 12-gauge shotgun, two 9-millimeter semiautomatic pistols"
$data[$rowIndex22].age_of_Shooter = "48"
$data[$rowIndex22].changes = "Updated weapon type and weapon details based on the information in source links. Updated age to be the average of both shooters."
#$data[$rowIndex22]

# RowIndex23
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 23" -ToScreen
$rowIndex23 = [array]::IndexOf($data.summary,'Aaron Alexis, 34, a military veteran and contractor from Texas, opened fire in the Navy installation, killing 12 people and wounding 8 before being shot dead by police.')
$data[$rowIndex23].weapon_type = "One shotgun, one handgun"
$data[$rowIndex23].weapon_details = "Remington 870 Express, 12-gauge Sawed-off shotgun, .45-caliber Beretta handgun"
$data[$rowIndex23].changes = "Updated weapon type and weapon details to be more consistent."
#$data[$rowIndex23]

# RowIndex24
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 24" -ToScreen
$rowIndex24 = [array]::IndexOf($data.summary,'Juan Lopez, 32, confronted his former fiancé, ER doctor Tamara O''Neal, before shooting her and opening fire on others at the hospital, including a responding police officer, Samuel Jimenez, and a pharmacy employee, Dayna Less. Lopez was fatally shot by a responding SWAT officer. Lopez had a history of domestic abuse against an ex-wife, and was kicked out of a fire department training academy for misconduct against female cadets.')
$data[$rowIndex24].weapon_type = "One semiautomatic handgun"
$data[$rowIndex24].changes = "Updated weapon type to be more consistent."
#$data[$rowIndex24]

# RowIndex25
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 25" -ToScreen
$rowIndex25 = [array]::IndexOf($data.summary,'Robert Findlay Smith, 70, opened fire with a handgun at a potluck dinner and was subdued by a church member until police arrived to apprehend him.')
$data[$rowIndex25].weapon_type = "One handgun"
$data[$rowIndex25].changes = "Updated weapon type to be more consistent."
#$data[$rowIndex25]

# RowIndex26
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 26" -ToScreen
$rowIndex26 = [array]::IndexOf($data.summary,'Ethan Crumbley, a 15-year-old student at Oxford High School, opened fire with a Sig Sauer 9mm pistol purchased four days earlier by his father, and was apprehended by police shortly thereafter. Prosecutors filed charges against Crumbley for terrorism and first-degree murder.')
$data[$rowIndex26].weapon_type = "One semiautomatic handgun"
$data[$rowIndex26].changes = "Updated weapon type to be more consistent."
#$data[$rowIndex26]

# RowIndex27
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 27" -ToScreen
$rowIndex27 = [array]::IndexOf($data.summary,'Michael McDermott, 42, opened fire on co-workers at Edgewater Technology and was later arrested.')
$data[$rowIndex27].weapon_type = "One semiautomatic rifle, one shotgun, one semiautomatic handgun"
$data[$rowIndex27].changes = "Updated weapon type to be more consistent."
#$data[$rowIndex27]

# RowIndex28
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 28" -ToScreen
$rowIndex28 = [array]::IndexOf($data.case,'Rural Ohio nursing home shooting')
$data[$rowIndex28].weapon_type = "One shotgun, one handgun"
$data[$rowIndex28].changes = "Updated weapon type to be more consistent."
#$data[$rowIndex28]

# RowIndex29
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 29" -ToScreen
$rowIndex29 = [array]::IndexOf($data.summary,'Salvador Ramos, 18, was identified by authorities as the suicidal gunman who attacked at Robb Elementary school.')
$data[$rowIndex29].weapon_type = "Two semiautomatic rifles"
$data[$rowIndex29].weapon_details = "Smith & Wesson MP 15, Daniel Defense rifle"
$data[$rowIndex29].changes = "Updated weapon type to be more consistent. Updated weapon details from information in source"
#$data[$rowIndex29]

# RowIndex30
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 30" -ToScreen
$rowIndex30 = [array]::IndexOf($data.summary,'Kuwaiti-born Mohammod Youssuf Abdulazeez, 24, a naturalized US citizen, opened fire at a Naval reserve center, and then drove to a military recruitment office where he shot and killed four Marines and a Navy service member, and wounded a police officer and another military service member. He was then fatally shot in an exchange of gunfire with law enforcement officers responding to the attack.')
$data[$rowIndex30].weapon_type = "Two semiautomatic rifles, one semiautomatic handgun"
$data[$rowIndex30].changes = "Updated weapon type based on the information in weapon_details so data is consistent"
#$data[$rowIndex30]

# RowIndex31
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 31" -ToScreen
$rowIndex31 = [array]::IndexOf($data.summary,'Dennis Clark III, 27, shot and killed his girlfriend in their shared apartment, and then shot two witnesses in the building''s parking lot and a third victim in another apartment, before being killed by police.')
$data[$rowIndex31].weapon_type = "One semiautomatic handgun, one shotgun"
$data[$rowIndex31].location_2 = "Other"
$data[$rowIndex31].changes = "Updated weapon type based on the information in weapon_details so data is consistent. Updated location_2 to be more consistent."
#$data[$rowIndex31]

# RowIndex32
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 32" -ToScreen
$rowIndex32 = [array]::IndexOf($data.summary,'Pedro Vargas, 42, set fire to his apartment, killed six people in the complex, and held another two hostages at gunpoint before a SWAT team stormed the building and fatally shot him.')
$data[$rowIndex32].weapon_type = "One semiautomatic handgun"
$data[$rowIndex32].weapon_details = "Glock 17 9mm"
$data[$rowIndex32].location_2 = "Other"
$data[$rowIndex32].changes = "Updated weapon type based on the information in weapon_details so data is consistent. Added 9mm to the weapon_details per sources. Updated location_2 to be more consistent."
#$data[$rowIndex32]

# RowIndex33
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 33" -ToScreen
$rowIndex33 = [array]::IndexOf($data.summary,'Dimitrios Pagourtzis, a 17-year-old student, opened fire at Santa Fe High School with a shotgun and .38 revolver owned by his father; Pagourtzis killed 10 and injured at least 13 others before surrendering to authorities after a standoff and additional gunfire inside the school. (Pagourtzis reportedly had intended to commit suicide.) Investigators also found undetonated explosive devices in the vicinity. (FURTHER DETAILS PENDING.)')
$data[$rowIndex33].weapon_type = "One shotgun, one revolver"
$data[$rowIndex33].weapon_details = ".38 revolver"
$data[$rowIndex33].changes = "Updated weapon type based on the information in weapon_details so data is consistent. Updated weapon details to be more consistent"
#$data[$rowIndex33]

# RowIndex34
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 34" -ToScreen
$rowIndex34 = [array]::IndexOf($data.summary,'Randy Stair, a 24-year-old worker at Weis grocery fatally shot three of his fellow employees. He reportedly fired 59 rounds with a pair of shotguns before turning the gun on himself as another co-worker fled the scene for help and law enforcement responded.')
$data[$rowIndex34].weapon_type = "Two shotguns"
$data[$rowIndex34].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex34]

# RowIndex35
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 35" -ToScreen
$rowIndex35 = [array]::IndexOf($data.summary,'Kevin Janson Neal, 44, went on an approximately 45-minute shooting spree in the rural community of Rancho Tehama Reserve in Northern California, including shooting up an elementary school, before being killed by law enforcement officers. Neal had also killed his wife at home.')
$data[$rowIndex35].weapon_type = "Two semiautomatic rifles"
$data[$rowIndex35].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex35]

# RowIndex36
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 36" -ToScreen
$rowIndex36 = [array]::IndexOf($data.summary,'John Zawahri, 23, armed with a homemade assault rifle and high-capacity magazines, killed his brother and father at home and then headed to Santa Monica College, where he was eventually killed by police.')
$data[$rowIndex36].weapon_type = "One semiautomatic rifle, one handgun"
$data[$rowIndex36].location_2 = "Other"
$data[$rowIndex36].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. Updated location_2 to be more consistent."
#$data[$rowIndex36]

# RowIndex37
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 37" -ToScreen
$rowIndex37 = [array]::IndexOf($data.summary,'Timothy O''Brien Smith, 28, wearing body armor and well-stocked with ammo, opened fire at a carwash early in the morning in this rural community, killing four people. A fifth victim, though not shot, suffered minor injuries. One of the deceased victims, 25-year-old Chelsie Cline, had been romantically involved with Smith and had broken off the relationship recently, according to her sister. Smith shot himself in the head and died later that night at the hospital.')
$data[$rowIndex37].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex37].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex37]

# RowIndex38
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 38" -ToScreen
$rowIndex38 = [array]::IndexOf($data.summary,'Snochia Moseley, 26, reportedly a disgruntled employee, shot her victims outside the building and on the warehouse floor; she later died from a self-inflicted gunshot at a nearby hospital. (No law enforcement officers responding to her attack fired shots.)')
$data[$rowIndex38].weapon_type = "One semiautomatic handgun"
$data[$rowIndex38].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex38]

# RowIndex39
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 39" -ToScreen
$rowIndex39 = [array]::IndexOf($data.summary,'Omar Enrique Santa Perez, 29, walked into the ground-floor lobby of a building in downtown Cincinnati shortly after 9 a.m. and opened fire. Within minutes, Perez was fatally wounded in a shootout with law enforcement officers responding to the scene.')
$data[$rowIndex39].weapon_type = "One semiautomatic handgun"
$data[$rowIndex39].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex39]

# RowIndex40
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 40" -ToScreen
$rowIndex40 = [array]::IndexOf($data.case,'San Ysidro McDonald''s massacre')
$data[$rowIndex40].weapon_type = "One semiautomatic handgun, one semiautomatic rifle, one shotgun"
$data[$rowIndex40].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex40]

# RowIndex41
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 41" -ToScreen
$rowIndex41 = [array]::IndexOf($data.summary,'Esteban Santiago, 26, flew from Alaska to Fort Lauderdale, where he opened fire in the baggage claim area of the airport, killing five and wounding six before police aprehended him. (Numerous other people were reportedly injured while fleeing during the panic.)')
$data[$rowIndex41].weapon_type = "One semiautomatic handgun"
$data[$rowIndex41].changes = "Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex41]

# RowIndex42
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 42" -ToScreen
$rowIndex42 = [array]::IndexOf($data.summary,'Ahmad Al Aliwi Alissa, 21, carried out a mass shooting at a King Soopers that left 10 victims dead, including veteran police officer Eric Talley, who was the first officer to respond on the scene. Alissa was wounded by police and taken into custody.')
$data[$rowIndex42].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex42].weapon_details = "Ruger AR-556; weapon was purchased six days before the attack. One tactical vest"
$data[$rowIndex42].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. Moved tactical vest from weapon type to weapon_details"
#$data[$rowIndex42]

# RowIndex43
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 43" -ToScreen
$rowIndex43 = [array]::IndexOf($data.summary,'Brandon Scott Hole, 19, opened fire around 11 p.m. in the parking lot and inside the warehouse, and then shot himself fatally as police responded to the scene.')
$data[$rowIndex43].weapon_type = "One semiautomatic rifle"
$data[$rowIndex43].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. Updated Summary"
#$data[$rowIndex43]

# RowIndex44
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 44" -ToScreen
$rowIndex44 = [array]::IndexOf($data.summary,'Maurice Clemmons, 37, a felon who was out on bail for child-rape charges, entered a coffee shop on a Sunday morning and shot four police officers who had gone there to use their laptops before their shifts. Clemmons, who was wounded fleeing the scene, was later shot dead by a police officer in Seattle after a two-day manhunt.')
$data[$rowIndex44].weapon_type = "One semiautomatic handgun, one revolver"
$data[$rowIndex44].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex44]

# RowIndex45
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 45" -ToScreen
$rowIndex45 = [array]::IndexOf($data.summary,'Payton S. Gendron, 18, committed a racially motivated mass murder, according to authorities. He livestreamed the attack and was apprehended by police.')
$data[$rowIndex45].weapon_type = "One semiautomatic rifle"
$data[$rowIndex45].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex45]

# RowIndex46
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 46" -ToScreen
$rowIndex46 = [array]::IndexOf($data.summary,'Connor Betts, 24, died during the attack, following a swift police response. He wore tactical gear including body armor and hearing protection, and had an ammunition device capable of holding 100 rounds. Betts had a history of threatening behavior dating back to high school, including reportedly having hit lists targeting classmates for rape and murder.')
$data[$rowIndex46].weapon_type = "One semiautomatic rifle"
$data[$rowIndex46].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex46]

# RowIndex47
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 47" -ToScreen
$rowIndex47 = [array]::IndexOf($data.summary,'Patrick Crusius, 21, who was apprehended by police, posted a so-called manifesto online shortly before the attack espousing ideas of violent white nationalism and hatred of immigrants. "This attack is a response to the Hispanic invasion of Texas," he allegedly wrote in the document.')
$data[$rowIndex47].weapon_type = "One semiautomatic rifle"
$data[$rowIndex47].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex47]

# RowIndex48
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 48" -ToScreen
$rowIndex48 = [array]::IndexOf($data.summary,'Santino William LeGan, 19, fired indiscriminately into the crowd near a concert stage at the festival. He used an AK-47-style rifle, purchased legally in Nevada three weeks earlier. After apparently pausing to reload, he fired additional multiple rounds before police shot him and then he killed himself. A witness described overhearing someone shout at LeGan, "Why are you doing this?" LeGan, who wore camouflage and tactical gear, replied: “Because I''m really angry." The murdered victims included a 13-year-old girl, a man in his 20s, and six-year-old Stephen Romero.')
$data[$rowIndex48].weapon_type = "One semiautomatic rifle"
$data[$rowIndex48].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex48]

# RowIndex49
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 49" -ToScreen
$rowIndex49 = [array]::IndexOf($data.case,'Waffle House shooting')
$data[$rowIndex49].weapon_type = "One semiautomatic rifle"
$data[$rowIndex49].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex49]

# RowIndex50
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 50" -ToScreen
$rowIndex50 = [array]::IndexOf($data.summary,'Nikolas J. Cruz, 19, heavily armed with an AR-15, tactical gear, and “countless magazines” of ammo, according to the Broward County Sheriff, attacked the high school as classes were ending for the day, killing at least 17 people and injuring many others. He was apprehended by authorities shortly after fleeing the campus.')
$data[$rowIndex50].weapon_type = "One semiautomatic rifle"
$data[$rowIndex50].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex50]

# RowIndex51
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 51" -ToScreen
$rowIndex51 = [array]::IndexOf($data.summary,'Robert A. Hawkins, 19, opened fire inside Westroads Mall before committing suicide.')
$data[$rowIndex51].weapon_type = "One semiautomatic rifle"
$data[$rowIndex51].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex51]

# RowIndex52
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 52" -ToScreen
$rowIndex52 = [array]::IndexOf($data.summary,'Off-duty sheriff''s deputy Tyler Peterson, 20, opened fire inside an apartment after an argument at a homecoming party. He fled the scene and later committed suicide.')
$data[$rowIndex52].weapon_type = "One semiautomatic rifle"
$data[$rowIndex52].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex52]

# RowIndex53
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 53" -ToScreen
$rowIndex53 = [array]::IndexOf($data.summary,'Former Caltrans employee Arturo Reyes Torres, 41, opened fire at a maintenance yard after he was fired for allegedly selling government materials he''d stolen from work. He was shot dead by police.')
$data[$rowIndex53].weapon_type = "One semiautomatic rifle"
$data[$rowIndex53].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex53]

# RowIndex54
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 54" -ToScreen
$rowIndex54 = [array]::IndexOf($data.summary,'Former airman Dean Allen Mellberg, 20, opened fire inside a hospital at the Fairchild Air Force Base before he was shot dead by a military police officer outside.')
$data[$rowIndex54].weapon_type = "One semiautomatic rifle"
$data[$rowIndex54].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex54]

# RowIndex55
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 55" -ToScreen
$rowIndex55 = [array]::IndexOf($data.summary,'James Holmes, 24, opened fire in a movie theater during the opening night of "The Dark Night Rises" and was later arrested outside.')
$data[$rowIndex55].weapon_type = "One semiautomatic rifle, one shotgun, two semiautomatic handguns"
$data[$rowIndex55].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex55]

# RowIndex56
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 56" -ToScreen
$rowIndex56 = [array]::IndexOf($data.summary,'Kyle Aaron Huff, 28, opened fire at a rave afterparty in the Capitol Hill neighborhood of Seattle before committing suicide.')
$data[$rowIndex56].weapon_type = "One semiautomatic rifle, one shotgun, two semiautomatic handguns"
$data[$rowIndex56].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex56]

# RowIndex57
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 57" -ToScreen
$rowIndex57 = [array]::IndexOf($data.summary,'Noah Harpham, 33, shot three people before dead in Colorado Springs before police killed him in a shootout.')
$data[$rowIndex57].weapon_type = "One semiautomatic rifle, two semiautomatic handguns"
$data[$rowIndex57].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex57]

# RowIndex58
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 58" -ToScreen
$rowIndex58 = [array]::IndexOf($data.summary,'Retired librarian William Cruse, 59, was paranoid neighbors gossiped that he was gay. He drove to a Publix supermarket, killing two Florida Tech students en route before opening fire outside and killing a woman. He then drove to a Winn-Dixie supermarket and killed three more, including two police officers. Cruse was arrested after taking a hostage and died on death row in 2009.')
$data[$rowIndex58].weapon_type = "One semiautomatic rifle, one shotgun, one revolver"
$data[$rowIndex58].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex58]

# RowIndex59
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 59" -ToScreen
$rowIndex59 = [array]::IndexOf($data.summary,'Army Sgt. Kenneth Junior French, 22, opened fire inside Luigi''s Italian restaurant while ranting about gays in the military before he was shot and arrested by police.')
$data[$rowIndex59].weapon_type = "One semiautomatic rifle, two shotguns"
$data[$rowIndex59].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex59]

# RowIndex60
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 60" -ToScreen
$rowIndex60 = [array]::IndexOf($data.summary,'Former Lindhurst High School student Eric Houston, 20, angry about various personal failings, killed three students and a teacher at the school before surrendering to police after an eight-hour standoff. He was later sentenced to death.')
$data[$rowIndex60].weapon_type = "One semiautomatic rifle, one shotgun"
$data[$rowIndex60].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex60]

# RowIndex61
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 61" -ToScreen
$rowIndex61 = [array]::IndexOf($data.case,'Cascade Mall shooting')
$data[$rowIndex61].weapon_type = "One semiautomatic rifle"
$data[$rowIndex61].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex61]

# RowIndex62
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 62" -ToScreen
$rowIndex62 = [array]::IndexOf($data.case,'Royal Oak postal shootings')
$data[$rowIndex62].weapon_type = "One semiautomatic rifle"
$data[$rowIndex62].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex62]

# RowIndex63
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 63" -ToScreen
$rowIndex63 = [array]::IndexOf($data.case,'IHOP shooting')
$data[$rowIndex63].weapon_type = "Two semiautomatic rifle, one revolver"
$data[$rowIndex63].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex63]

# RowIndex64
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 64" -ToScreen
$rowIndex64 = [array]::IndexOf($data.summary,'Robert D. Bowers, 46, shouted anti-Semitic slurs as he opened fire inside the Tree of Life synagogue during Saturday morning worship. He was armed with an assault rifle and multiple handguns and was apprehended after a standoff with police. His social media accounts contained virulent anti-Semitic content, and references to migrant caravan "invaders" hyped by President Trump and the Republican party ahead of the 2018 midterms elections.')
$data[$rowIndex64].weapon_type = "One semiautomatic rifle, three semiautomatic handguns"
$data[$rowIndex64].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex64]

# RowIndex65 
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 65" -ToScreen
$rowIndex65 = [array]::IndexOf($data.summary, 'Syed Rizwan Farook left a Christmas party held at Inland Regional Center, later returning with Tashfeen Malik and the two opened fire, killing 14 and wounding 21, ten critically. The two were later killed by police as they fled in an SUV.')
$data[$rowIndex65].weapon_type = "Two semiautomatic rifles, two semiautomatic handguns"
$data[$rowIndex65].weapon_details = "Two semiautomatic AR-15-style rifles-one a DPMS A-15, the other a Smith & Wesson M&P15, both with .223 calibre ammunition. Two 9mm semiautomatic handguns. High capacity magazines.Police found a remote controlled explosive device at the scene of the crime.At the home were 12 pipe bombs, 2,500 rounds for the AR-15 variants, 2,000 rounds for the pistols, and several hundred for a .22 calibre rifle. In the suspects car were an additional 1,400 rounds for the rifles and 200 for the handguns."
$data[$rowIndex65].location_2 = "Workplace"
$data[$rowIndex65].weapons_obtained_legally = "Yes"
$data[$rowIndex65].changes = "Updated weapon type, weapon details, location_2, and weapons obtained legally to include more details from sources and to be more consistent."
#$data[$rowIndex65]

# RowIndex66
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 66" -ToScreen
$rowIndex66 = [array]::IndexOf($data.case,'Standard Gravure shooting')
$data[$rowIndex66].weapon_type = "One semiautomatic rifle, two semiautomatic handguns, one revolver"
$data[$rowIndex66].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex66]

# RowIndex67
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 67" -ToScreen
$rowIndex67 = [array]::IndexOf($data.summary,'Patrick Purdy, 26, an alcoholic with a police record, launched an assault at Cleveland Elementary School, where many young Southeast Asian immigrants were enrolled. Purdy killed himself with a shot to the head.')
$data[$rowIndex67].weapon_type = "One semiautomatic rifle, one handgun"
$data[$rowIndex67].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex67]

# RowIndex68
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 68" -ToScreen
$rowIndex68 = [array]::IndexOf($data.summary,'Failed businessman Gian Luigi Ferri, 55, opened fire throughout an office building before he committed suicide inside as police pursued him.')
$data[$rowIndex68].weapon_type = "Three semiautomatic handguns"
$data[$rowIndex68].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex68]

# RowIndex69
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 69" -ToScreen
$rowIndex69 = [array]::IndexOf($data.case,'Pensacola Naval base shooting')
$data[$rowIndex69].weapon_type = "One semiautomatic handgun"
$data[$rowIndex69].weapon_details = "Glock Model 45 9mm"
$data[$rowIndex69].sources = "https://www.washingtonpost.com/national-security/2019/12/06/naval-station-pensacola-active-shooter/; https://www.cnn.com/us/live-news/pensacola-naval-base-shooter/index.html; https://www.navytimes.com/news/your-navy/2019/12/09/how-did-the-pensacola-gunman-get-the-pistol-he-used-to-kill-3-sailors"
$data[$rowIndex69].changes = "Added navytimes.com as a source, updated weapon details and weapon type based on new information and to be consistent."
#$data[$rowIndex69]

# RowIndex70
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 70" -ToScreen
$rowIndex70 = [array]::IndexOf($data.summary,'Scott Allen Ostrem, 47, walked into a Walmart in a suburb north of Denver and fatally shot two men and a woman, then left the store and drove away. After an all-night manhunt, Ostrem, who had financial problems but no serious criminal history, was captured by police after being spotted near his apartment in Denver.')
$data[$rowIndex70].weapon_type = "One semiautomatic handgun"
$data[$rowIndex70].weapon_details = "Ruger AR-556 semiautomatic pistol"
$data[$rowIndex70].sources = "https://www.nytimes.com/2017/11/01/us/thornton-colorado-walmart-shooting.html; http://www.cnn.com/2017/11/01/us/colorado-walmart-shooting/index.html; http://www.thedenverchannel.com/news/crime/colorado-walmart-shooting-suspect-scott-ostrem-had-run-ins-with-police-financial-troubles; http://www.ibtimes.com/who-scott-ostrem-manhunt-underway-colorado-walmart-shooting-suspect-2609562; https://www.nytimes.com/live/2021/03/23/us/boulder-colorado-shooting"
$data[$rowIndex70].changes = "Added www.nytimes.com as a source, updated weapon details and weapon type based on new information and to be consistent."
#$data[$rowIndex70]

# RowIndex71
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 71" -ToScreen
$rowIndex71 = [array]::IndexOf($data.case,'Kalamazoo shooting spree')
$data[$rowIndex71].weapon_type = "One semiautomatic handgun"
$data[$rowIndex71].changes = "Updated weapon_type based on the information in weapon_details so data is consistent"
#$data[$rowIndex71]

# RowIndex72
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 72" -ToScreen
$rowIndex72 = [array]::IndexOf($data.summary,'26-year-old Chris Harper Mercer opened fire at Umpqua Community College in southwest Oregon. The gunman shot himself to death after being wounded in a shootout with police.')
$data[$rowIndex72].weapon_type = "One semiautomatic rifle, five semiautomatic handguns"
$data[$rowIndex72].weapon_details = "9 mm Glock pistol, .40 caliber Smith & Wesson, .40 caliber Taurus pistol, .556 caliber Del-Ton; (ammo details unclear).five magazines of ammunition"
$data[$rowIndex72].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. Updated weapon_details to be more consistent."
#$data[$rowIndex72]

# RowIndex73
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 73" -ToScreen
$rowIndex73 = [array]::IndexOf($data.summary,'Devin Patrick Kelley, a 26-year-old ex-US Air Force airman, opened fire at the First Baptist Church in Sutherland Springs during Sunday morning services, killing at least 26 people and wounding and injuring 20 others. He left the church and fled in his vehicle after engaging in a gunfight with a local citizen; he soon crashed his vehicle and died from a self-inflicted gunshot wound.')
$data[$rowIndex73].weapon_type = "One semiautomatic rifle"
$data[$rowIndex73].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. No mention in source links about any handguns"
#$data[$rowIndex73]

# RowIndex74
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 74" -ToScreen
$rowIndex74 = [array]::IndexOf($data.summary,'Seth A. Ator, 36, fired at police officers who stopped him for a traffic violation, and then went on a driving rampage in the Odessa-Midland region, where he also shot a postal worker and stole her vehicle. He was shot dead by law enforcement responding to the rampage. Ator had been fired from a job just prior to the attack (though per the FBI he had shown up to that job "already enraged"). He had a criminal record and "a long history of mental problems and making racist comments," according to a family friend who spoke to the media.')
$data[$rowIndex74].weapon_type = "One semiautomatic rifle"
$data[$rowIndex74].weapon_details = "AR-15 Style rifle"
$data[$rowIndex74].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. No mention in source links about any handguns"
#$data[$rowIndex74]

# RowIndex75
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 75" -ToScreen
$rowIndex75 = [array]::IndexOf($data.case,'Yountville veterans home shooting')
$data[$rowIndex75].weapon_type = "One semiautomatic rifle, one shotgun"
$data[$rowIndex75].weapon_details = ".308 JR Enterprises LRP-07 semi-automatic rifle 12-gauge Stoeger Coach Gun"
$data[$rowIndex75].sources = "https://www.cnn.com/2018/03/10/us/california-veterans-home-shooting/index.html; http://www.ktvu.com/news/gunman-in-yountville-veterans-home-killings-was-ex-patient; https://www.washingtonpost.com/news/post-nation/wp/2018/03/09/police-respond-to-reports-of-gunfire-and-hostages-taken-at-california-veterans-home/?utm_term=.b9dde7ac5f0f; http://dig.abclocal.go.com/kgo/PDF/112918_Pathway_Home_Homicide_Redacted.pdf"
$data[$rowIndex75].changes = "Added 4 new sources to confirm weapon_details and type. No data in original sources, Added police report showing weapon details. Updated weapon_type based on the information in weapon_details so data is consistent."
#$data[$rowIndex75]

# RowIndex76
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 76" -ToScreen
$rowIndex76 = [array]::IndexOf($data.case,'Florida awning manufacturer shooting')
$data[$rowIndex76].weapon_type = "One semiautomatic handgun"
$data[$rowIndex76].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. No mention in source links about any handguns"
#$data[$rowIndex76]

# RowIndex77
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 77" -ToScreen
$rowIndex77 = [array]::IndexOf($data.summary,'Omar Mateen, 29, attacked the Pulse nighclub in Orlando in the early morning hours of June 12. He was killed by law enforcement who raided the club after a prolonged standoff.')
$data[$rowIndex77].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex77].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. No mention in source links about any handguns"
#$data[$rowIndex77]

# RowIndex78
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 78" -ToScreen
$rowIndex78 = [array]::IndexOf($data.summary,'Cedric L. Ford, who worked as a painter at a manufacturing company, shot victims from his car and at his workplace before being killed by police at the scene. Shortly before the rampage he had been served with a restraining order.')
$data[$rowIndex78].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex78].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. No mention in source links about any handguns"
#$data[$rowIndex78]

# RowIndex79
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 79" -ToScreen
$rowIndex79 = [array]::IndexOf($data.summary,'Jonathan Sapirman, 20, opened fire in a mall food court and was soon shot dead by a 22-year-old armed civilian, whose response local authorities called "nothing short of heroic."')
$data[$rowIndex79].weapon_type = "Two semiautomatic rifles, one semiautomatic handgun"
$data[$rowIndex79].weapon_details = "Sig Sauer M400 rifle, MP15 rifle, Glock 33"
$data[$rowIndex79].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. Updated weapon details from source links. No mention in source links about any handguns"
#$data[$rowIndex79]

# RowIndex80
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 80" -ToScreen
$rowIndex80 = [array]::IndexOf($data.summary,'Micah Xavier Johnson, a 25-year-old Army veteran, targeted police at a peaceful Black Lives Matter protest, killing five officers and injuring nine others as well as two civilians. After a prolonged standoff in a downtown building, law enforcement killed Johnson using a robot-delivered bomb.')
$data[$rowIndex80].weapon_type = "One semiautomatic rifle, two semiautomatic handguns"
$data[$rowIndex80].changes = "Updated weapon_type based on the information in weapon_details so data is consistent. No mention in source links about any handguns"
#$data[$rowIndex80]

# RowIndex81
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 81" -ToScreen
$rowIndex81 = [array]::IndexOf($data.state,'KY')
$data[$rowIndex81].State = "Kentucky"
$data[$rowIndex81].changes = "Updated state to be consistent with other states"
#$data[$rowIndex81]

# RowIndex82
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 82" -ToScreen
$rowIndex82 = [array]::IndexOf($data.state,'TN')
$data[$rowIndex82].State = "Tennessee"
$data[$rowIndex82].changes = "Updated state to be consistent with other states"
#$data[$rowIndex82]

# RowIndex83
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 83" -ToScreen
$rowIndex83 = [array]::IndexOf($data.case,'Michigan State University shooting')
$data[$rowIndex83].prior_signs_mental_health_issues = "Yes"
$data[$rowIndex83].weapon_type = "Two semiautomatic handguns"
$data[$rowIndex83].weapon_details = "Two 9mm handguns with additional magazines and ammunition"
$data[$rowIndex83].sources = "https://www.cnn.com/us/live-news/michigan-state-university-shooting-updates-2-13-23/index.html; https://www.freep.com/story/news/local/michigan/2023/02/13/michigan-state-shooting-what-we-know-about-shots-fired-on-campus/69901251007/; https://abcnews.go.com/US/anthony-mcrae-suspected-michigan-state-shooter/story?id=97195504; https://www.nytimes.com/2023/02/16/us/michigan-state-shooting-professor-berkey-hall.html?referringSource=articleShare; https://www.nbcnews.com/news/us-news/msu-shooter-was-found-2-legally-purchased-guns-ammo-threatening-note-o-rcna70973"
$data[$rowIndex83].mental_health_sources = "https://abcnews.go.com/US/anthony-mcrae-suspected-michigan-state-shooter/story?id=97195504"
$data[$rowIndex83].changes = "Added new sources cnn, abcnews, nytimes, etc to help confirm and update data on mental health isssues, weapon details, weapon type. "
#$data[$rowIndex83]

# RowIndex84
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 84" -ToScreen
$rowIndex84 = [array]::IndexOf($data.summary,'Sergio Valencia del Toro, 27, in what officials say was a random act, shot and killed three people including an 11-year-old girl before turning the gun on himself.')
$Data[$rowIndex84].weapon_type = "Two handguns"
$Data[$rowIndex84].changes = "Updated weapon_type because original value contained a newline which broke statistics.md output."
#$Data[$rowIndex84]

# RowIndex85
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 85" -ToScreen
$rowIndex85 = [array]::IndexOf($data.case,'Caltrans maintenance yard shooting')
$Data[$rowIndex85].weapon_type = "One semiautomatic handgun"
$Data[$rowIndex85].changes = "Updated weapon_type because original value contained a newline which broke statistics.md output."
#$Data[$rowIndex85]

# RowIndex86
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 86" -ToScreen
$rowIndex86 = [array]::IndexOf($data.case,'Pennsylvania carwash shooting')
$Data[$rowIndex86].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex86].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex86]

# RowIndex87
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 87" -ToScreen
$rowIndex87 = [array]::IndexOf($data.case,'Gilroy garlic festival shooting')
$Data[$rowIndex87].weapon_type = "One semiautomatic handgun"
$Data[$rowIndex87].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex87]

# RowIndex88
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 88" -ToScreen
$rowIndex88 = [array]::IndexOf($data.case,'Marjory Stoneman Douglas High School shooting')
$Data[$rowIndex88].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex88].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex88]

# RowIndex89
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 89" -ToScreen
$rowIndex89 = [array]::IndexOf($data.case,'Mercy Hospital shooting')
$Data[$rowIndex89].weapon_type = "One semiautomatic handgun"
$Data[$rowIndex89].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex89]

# RowIndex90
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 90" -ToScreen
$rowIndex90 = [array]::IndexOf($data.case,'Jersey City kosher market shooting')
$Data[$rowIndex90].weapon_type = "One semiautomatic rifle, one shotgun, three semiautomatic handguns"
$Data[$rowIndex90].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex90]

# RowIndex91
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 91" -ToScreen
$rowIndex91 = [array]::IndexOf($data.case,'Springfield convenience store shooting')
$Data[$rowIndex91].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex91].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex91]

# RowIndex92
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 92" -ToScreen
$rowIndex92 = [array]::IndexOf($data.case,'University of Virginia shooting')
$Data[$rowIndex92].weapon_type = "One semiautomatic handgun"
$Data[$rowIndex92].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex92]

# RowIndex93
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 93" -ToScreen
$rowIndex93 = [array]::IndexOf($data.case,'LGBTQ club shooting')
$Data[$rowIndex93].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex93].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex93]

# RowIndex94
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 94" -ToScreen
$rowIndex94 = [array]::IndexOf($data.case,'Raleigh spree shooting')
$Data[$rowIndex94].weapon_type = "One shotgun, one semiautomatic handgun"
$Data[$rowIndex94].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex94]

# RowIndex95
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 95" -ToScreen
$rowIndex95 = [array]::IndexOf($data.case,'LA dance studio mass shooting')
$Data[$rowIndex95].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex95].weapon_details = "Details pending"
$Data[$rowIndex95].changes = 'Updated weapon_type to be consistent with other records, Moved "Details pending" to weapon_details.'
#$Data[$rowIndex95]

# RowIndex96
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 96" -ToScreen
$rowIndex96 = [array]::IndexOf($data.case,'Louisville bank shooting')
$Data[$rowIndex96].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex96].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex96]

# RowIndex97
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 97" -ToScreen
$rowIndex97 = [array]::IndexOf($data.case,'Texas outlet mall shooting')
$Data[$rowIndex97].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex97].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex97]

# RowIndex98
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 98" -ToScreen
$rowIndex98 = [array]::IndexOf($data.case,'New Mexico neighborhood shooting')
$Data[$rowIndex98].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex98].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex98]

# RowIndex99
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 99" -ToScreen
$rowIndex99 = [array]::IndexOf($data.case,'Pinewood Village Apartment shooting')
$Data[$rowIndex99].weapon_type = "One shotgun, one semiautomatic handgun"
$Data[$rowIndex99].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex99]

# RowIndex100
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 100" -ToScreen
$rowIndex100 = [array]::IndexOf($data.case,'Baton Rouge police shooting')
$Data[$rowIndex100].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex100].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex100]

# RowIndex101
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 101" -ToScreen
$rowIndex101 = [array]::IndexOf($data.case,'Sandy Hook Elementary massacre')
$Data[$rowIndex101].weapon_type = "One semiautomatic rifle, one semiautomatic shotgun, two semiautomatic handguns"
$Data[$rowIndex101].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex101]

# RowIndex102
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 102" -ToScreen
$rowIndex102 = [array]::IndexOf($data.case,'Alturas tribal shooting')
$Data[$rowIndex102].weapon_type = "One semiautomatic handgun, one butcher knife"
$Data[$rowIndex102].changes = "Updated weapon_type to be consistent with other records. (Matches with weapon_details.)"
#$Data[$rowIndex102]

# RowIndex103
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 103" -ToScreen
$rowIndex103 = [array]::IndexOf($data.case,'Columbine High School massacre')
$Data[$rowIndex103].weapon_type = "One semiautomatic rifle, two shotguns, one semiautomatic handgun"
$Data[$rowIndex103].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex103]

# RowIndex104
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 104" -ToScreen
$rowIndex104 = [array]::IndexOf($data.case,'Crandon shooting')
$Data[$rowIndex104].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex104].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex104]

# RowIndex105
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 105" -ToScreen
$rowIndex105 = [array]::IndexOf($data.case,'Isla Vista mass murder')
$Data[$rowIndex105].weapon_type = "Three semiautomatic handguns, two hunting knives"
$Data[$rowIndex105].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex105]

# RowIndex106
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 106" -ToScreen
$rowIndex106 = [array]::IndexOf($data.case,"San Ysidro McDonald''s massacre")
$Data[$rowIndex106].weapon_type = "One semiautomatic rifle, one shotgun, one semiautomatic handgun"
$Data[$rowIndex106].changes = "Updated weapon_type to be consistent with other records."
#$Data[$rowIndex106]

# RowIndex107
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 107"
$RowIndex107 = [array]::IndexOf($data.case,"Northern Illinois University shooting")
$Data[$RowIndex107].weapon_type = "One shotgun, three semiautomatic handguns"
$Data[$RowIndex107].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex107]

# RowIndex108
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 108"
$RowIndex108 = [array]::IndexOf($data.case,"Red Lake massacre")
$Data[$RowIndex108].weapon_type = "One shotgun, two semiautomatic handguns"
$Data[$RowIndex108].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex108]

# RowIndex109
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 109" -ToScreen
$RowIndex109 = [array]::IndexOf($data.case,'Navistar shooting')
$Data[$RowIndex109].weapon_type = "Two rifles, one shotgun, one revolver"
$Data[$RowIndex109].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex109]

# RowIndex110
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 110" -ToScreen
$RowIndex110 = [array]::IndexOf($data.case,'Trolley Square shooting')
$Data[$RowIndex110].weapon_type = "One shotgun, one revolver"
$Data[$RowIndex110].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex110]

# RowIndex111
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 111" -ToScreen
$RowIndex111 = [array]::IndexOf($data.case,'Carthage nursing home shooting')
$Data[$RowIndex111].weapon_type = "One shotgun, one revolver"
$Data[$RowIndex111].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex111]

# RowIndex112
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 112" -ToScreen
$RowIndex112 = [array]::IndexOf($data.case,'ESL shooting')
$Data[$RowIndex112].weapon_type = "One rifle, one shotgun, two semiautomatic handguns, two revolvers"
$Data[$RowIndex112].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex112]

# RowIndex113
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 113" -ToScreen
$RowIndex113 = [array]::IndexOf($data.case,'Thurston High School shooting')
$Data[$RowIndex113].weapon_type = "One rifle, two semiautomatic handguns"
$Data[$RowIndex113].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex113]

# RowIndex114
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 114" -ToScreen
$RowIndex114 = [array]::IndexOf($data.case,'San Francisco UPS shooting')
$Data[$RowIndex114].weapon_type = "Two semiautomatic handguns"
$Data[$RowIndex114].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex114]

# RowIndex115
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 115" -ToScreen
$RowIndex115 = [array]::IndexOf($data.case,'Virginia Beach municipal building shooting')
$Data[$RowIndex115].weapon_type = "Two semiautomatic handguns"
$Data[$RowIndex115].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex115]

# RowIndex116
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 116" -ToScreen
$RowIndex116 = [array]::IndexOf($data.case,'Charleston Church Shooting')
$Data[$RowIndex116].weapon_type = "One semiautomatic handgun"
$Data[$RowIndex116].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex116]

# RowIndex117
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 117" -ToScreen
$RowIndex117 = [array]::IndexOf($data.case,'Fresno downtown shooting')
$Data[$RowIndex117].weapon_type = "One handgun"
$Data[$RowIndex117].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex117]

# RowIndex118
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 118" -ToScreen
$RowIndex118 = [array]::IndexOf($data.case,'Atlanta massage parlor shootings')
$Data[$RowIndex118].weapon_type = "One semiautomatic handgun"
$Data[$RowIndex118].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex118]

# RowIndex119
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 119" -ToScreen
$RowIndex119 = [array]::IndexOf($data.case,'Concrete company shooting')
$Data[$RowIndex119].weapon_type = "One semiautomatic handgun"
$Data[$RowIndex119].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex119]

# RowIndex120
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 120" -ToScreen
$RowIndex120 = [array]::IndexOf($data.case,'Virginia Walmart shooting')
$Data[$RowIndex120].weapon_type = "One semiautomatic handgun"
$Data[$RowIndex120].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex120]

# RowIndex121
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 121" -ToScreen
$RowIndex121 = [array]::IndexOf($data.case,'Half Moon Bay spree shooting')
$Data[$RowIndex121].weapon_type = "One semiautomatic handgun"
$Data[$RowIndex121].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex121]

# RowIndex122
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 122" -ToScreen
$RowIndex122 = [array]::IndexOf($data.case,'Amish school shooting')
$Data[$RowIndex122].weapon_type = "One rifle, one shotgun, one semiautomatic handgun"
$Data[$RowIndex122].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex122]

# RowIndex123
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 123" -ToScreen
$RowIndex123 = [array]::IndexOf($data.case,'Lockheed Martin shooting')
$Data[$RowIndex123].weapon_type = "Two rifles, one shotgun, one semiautomatic handgun, one derringer"
$Data[$RowIndex123].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex123]

# RowIndex124
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 124" -ToScreen
$RowIndex124 = [array]::IndexOf($data.case,'Westside Middle School killings')
$Data[$RowIndex124].weapon_type = "Two rifles, two semiautomatic handguns, three revolvers, two derringers"
$Data[$RowIndex124].changes = "Updated weapon_type to be consistent with other records."
#$Data[$RowIndex124]

# RowIndex125
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 125" -ToScreen
$RowIndex125 = [array]::IndexOf($data.case,'United States Postal Service shooting')
$Data[$RowIndex125].prior_signs_mental_health_issues = 'Unclear'
$Data[$RowIndex125].changes = "Updated prior_signs_mental_health_issues, removing a space after the word Unclear"
#$Data[$RowIndex125]

# RowIndex126
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 126" -ToScreen
$rowIndex126 = [array]::IndexOf($data.summary,'Anthony Polito, 67, a former university professor, died in a shootout with police after opening fire on the UNLV campus.')
$Data[$RowIndex126].weapon_type = "Two semiautomatic handguns"
$Data[$RowIndex126].weapon_details = "Two 9mm handguns with nine loaded magazines."
$Data[$RowIndex126].sources = "https://www.nbcnews.com/news/us-news/anthony-polito-s-know-unlv-shooting-suspect-accused-killing-3-wounding-rcna128499; https://www.reviewjournal.com/crime/shootings/police-engaged-suspect-in-shootout-unlv-police-chief-says-2960370/; https://www.cnn.com/2023/12/06/us/university-of-nevada-las-vegas-campus-shooting/index.html; https://news.yahoo.com/authorities-responding-reports-multiple-victims-201320923.html;https://www.cnn.com/2023/12/08/us/university-of-nevada-las-vegas-shooting-friday/index.html;"
$Data[$RowIndex126].changes = "Added weapon_type which was provided on updated source link from CNN."
# $Data[$RowIndex126]

# RowIndex127
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 127" -ToScreen
$rowIndex127 = [array]::IndexOf($data.summary,'Colt Gray, 14, was apprehended by responding police. He and his father had been interviewed in 2023 by local authorities after the FBI received anonymous tips about school shooting threats allegedly coming from Gray.')
$Data[$rowIndex127].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex127].changes = "Updated weapon_type to be consistent with other records."
# $Data[$rowIndex127]

# RowIndex128
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 128" -ToScreen
$rowIndex128 = [array]::IndexOf($data.summary,'Travis Posey, 44, opened fire in the parking lot and inside the store; he was injuired in a gun battle with responding police before being taken into custody.')
$Data[$rowIndex128].weapon_type = "One shotgun, one semiautomatic handgun"
$Data[$rowIndex128].changes = "Updated weapon_type to be consistent with other records."
# $Data[$rowIndex128]

# RowIndex129
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 129" -ToScreen
$rowIndex129 = [array]::IndexOf($data.case,'Maine bowling alley and bar shootings')
$Data[$rowIndex129].weapon_type = "One semiautomatic rifle"
$Data[$rowIndex129].changes = "Updated weapon_type to be consistent with other records."
# $Data[$rowIndex129]

# RowIndex130
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 130" -ToScreen
$rowIndex130 = [array]::IndexOf($data.summary,'Ryan Palmeter, 21, outfitted in body armor, fatally shot three Black victims in what authorities said was a racist hate crime. He then shot himself to death on the scene as police responded. Palmeter had first gone to Edward Waters University, a historically Black college, but was refused entry.')
$Data[$rowIndex130].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex130].changes = "Updated weapon_type to be consistent with other records."
# $Data[$rowIndex130]

# RowIndex131
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 131" -ToScreen
$rowIndex131 = [array]::IndexOf($data.summary,'John Snowling, 59, a retired sergeant from the Ventura Police Department, was targeting his estranged wife, and was killed by police responding to the scene.')
$Data[$rowIndex131].weapon_type = "One shotgun, two semiautomatic handguns"
$Data[$rowIndex131].changes = "Updated weapon_type to be consistent with other records."
# $Data[$rowIndex131]

# RowIndex132
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Record Updated 132" -ToScreen
$rowIndex132 = [array]::IndexOf($data.case,'Philidelphia neighborhood shooting')
$Data[$rowIndex132].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$Data[$rowIndex132].changes = "Updated weapon_type to be consistent with other records."
# $Data[$rowIndex132]


#Export clean dataset for data.world
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Exporting clean CH Edition dataset for data.world [$ExportCHEdition]" -ToScreen
$Data | Export-CSV -path $ExportCHEdition -NoTypeInformation

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
## CH Edition SQLite ##
########################

# Import the CH Edition and insert records into SQLite DB
$CH_TableName = 'CHData'
try{
    $CH_CSV = Import-CSV -Path $ExportCHEdition | Sort-Object -Property {[DateTime]::ParseExact($_.date,'yyyy-MM-dd',$null)}
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Importing CH Edition [$ExportCHEdition]" -ToScreen
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Importing CH Edition [$ExportCHEdition]" -ToScreen
}

try {
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Inserting CH Edition [$ExportCHEdition] into SQLite DB [$DBPath]" -ToScreen
    $CH_CSV | ForEach-Object {
        # SQL Query to insert records into SQLite DB
        $CH_Query = "INSERT INTO $CH_TableName ([case], location, city, state, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year, changes) VALUES 
        ('$($_.case)','$($_.location)','$($_.city)','$($_.state)','$($_.date)','$($_.summary)','$($_.fatalities)','$($_.injured)','$($_.total_victims)','$($_.location_2)','$($_.age_of_Shooter)','$($_.prior_signs_mental_health_issues)','$($_.mental_health_details)','$($_.weapons_obtained_legally)','$($_.where_obtained)','$($_.weapon_type)','$($_.weapon_details)','$($_.race)','$($_.gender)','$($_.sources)','$($_.mental_health_sources)','$($_.sources_additional_age)','$($_.latitude)','$($_.longitude)','$($_.type)','$($_.year)', '$($_.changes)')"
        $CH_Query
        # Send SQL query to SQLite DB
        Invoke-SqliteQuery -Connection $Connection -Query $CH_Query
    }
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Inserting CH Edition [$ExportCHEdition] into SQLite DB [$DBPath]" -ToScreen
}

########################
## MJ Edition SQLite ##
########################

# Import the MJ Edition and insert records into SQLite DB
$MJ_TableName = 'MJData'
try {
    $MJ_CSV = Import-Csv -Path $ImportCSVPath | Sort-Object -Property {[DateTime]::ParseExact($_.date,'yyyy-MM-dd',$null)}
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Importing MJ Edition [$ImportCSVPath]" -ToScreen
} catch {
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Importing MJ Edition [$ImportCSVPath]" -ToScreen
}

try {
    Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Inserting MJ Edition [$ImportCSVPath] into SQLite DB [$DBPath]" -ToScreen
    $MJ_CSV | ForEach-Object {
        # SQL Query to insert records into SQLite DB
        $MJ_Query = "INSERT INTO $MJ_TableName ([case], location, date, summary, fatalities, injured, total_victims, location_2, age_of_Shooter, prior_signs_mental_health_issues, mental_health_details, weapons_obtained_legally, where_obtained, weapon_type, weapon_details, race, gender, sources, mental_health_sources, sources_additional_age, latitude, longitude, type, year) VALUES 
        ('$($_.case)','$($_.location)','$($_.date)','$($_.summary)','$($_.fatalities)','$($_.injured)','$($_.total_victims)','$($_.location_2)','$($_.age_of_Shooter)','$($_.prior_signs_mental_health_issues)','$($_.mental_health_details)','$($_.weapons_obtained_legally)','$($_.where_obtained)','$($_.weapon_type)','$($_.weapon_details)','$($_.race)','$($_.gender)','$($_.sources)','$($_.mental_health_sources)','$($_.sources_additional_age)','$($_.latitude)','$($_.longitude)','$($_.type)','$($_.year)')"
        $MJ_Query
        # Send SQL query to SQLite DB
        Invoke-SqliteQuery -Connection $Connection -Query $MJ_Query
    }
} catch {
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Inserting MJ Edition [$ImportCSVPath] into SQLite DB [$DBPath]" -ToScreen
}
# Close the connection
$Connection.Close()



# HTML Export of the data. Will popup once script is completed.
try {
New-HTML {
    New-HTMLTable -DataTable $Data -Title 'Table of records' -HideFooter -PagingLength 200 -Buttons excelHtml5, searchPanes
} -ShowHTML -FilePath $ExportWebView -Online
Write-LogInfo -LogPath $LogFilePath -Message "[$(Get-Date)] Exported WebView [$ExportWebView]" -ToScreen
}catch{
    Write-LogError -LogPath $LogFilePath -Message "[$(Get-Date)] Exporting WebView [$ExportWebView]" -ToScreen
}

Stop-Log -LogPath $LogFilePath -NoExit
