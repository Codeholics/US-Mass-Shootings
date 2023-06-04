Import-Module -Name PSWriteHTML, PSSQLite

$CPSScriptRoot = 'D:\Github\Repos\US-Mass-Shootings'

. "$CPSScriptRoot\Functions\Get-MotherJonesDB.ps1"
. "$CPSScriptRoot\Functions\New-SQLiteDB.ps1"
. "$CPSScriptRoot\Functions\Push-CHSQLite.ps1"
. "$CPSScriptRoot\Functions\Push-MJSQLite.ps1"

$Date = Get-Date -Format "yyyyMMdd"
$Random = Get-Random
$ExportPath = "$CPSScriptRoot\Export\$Date-$Random"

$SQLitePath = "$CPSScriptRoot\Resources\System.Data.SQLite.dll"
$DBPath = "$ExportPath\MassShooterDatabase.sqlite"

$ExportWebView = "$ExportPath\WebView.html"
$ExportCHEdition = "$ExportPath\thebleak13s1.csv"
$ImportCSVPath = "$ExportPath\Mother Jones - Mass Shootings Database 1982-2023.csv"

# create Export folder if not exist
if (!(Test-Path $ExportPath)) {
    New-Item -Path $ExportPath -ItemType Directory
}

try {
    Get-MotherJonesDB -Output $ExportPath
}
Catch{
    Write-Warning $_
}


try {
    $spreadsheet = (Import-csv -Path $ImportCSVPath)
}catch {
    Write-Warning $_
}

$data = @()
foreach($item in $spreadsheet) {
    
    #Splitting city out of location
    $CityRaw = $item.location
    $CityOnly = $CityRaw -replace ',.*',''
    $City = $CityOnly.trim('')
    
    #Splitting out state from location
    $StateRaw = $item.location
    $StateOnly = $StateRaw -replace '.*,',''
    $State  = $StateOnly.trim('')

    #force first character of race caps
    $RaceCaps = $item.race
    $Race = $RaceCaps.toCharArray()[0].tostring().toUpper() + $RaceCaps.remove(0,1)
    $Race = $Race -replace '^[-]+$', ''

    #force first character of location_2 caps
    $LocationCaps = $item.location_2
    $Location_2 = $LocationCaps.toCharArray()[0].tostring().toUpper() + $LocationCaps.remove(0, 1)
    $Location_2 = $Location_2.trim('')
    
    #force first character of prior_signs_mental_health_issues caps
    $PriorSignsMentalHealthIssuesCaps = $item.prior_signs_mental_health_issues
    $PriorSignsMentalHealthIssues = $PriorSignsMentalHealthIssuesCaps.toCharArray()[0].tostring().toUpper() + $PriorSignsMentalHealthIssuesCaps.remove(0, 1)
    $PriorSignsMentalHealthIssues = $PriorSignsMentalHealthIssues -replace '^[-]+$', ''

    #force first character of weapon_type
    $WeaponTypeCaps = $item.weapon_type
    $WeaponType = $WeaponTypeCaps.toCharArray()[0].tostring().toUpper() + $WeaponTypeCaps.remove(0, 1)

    #force first character of gender caps
    $GenderCaps = $item.gender
    $Gender = $GenderCaps.toCharArray()[0].tostring().toUpper() + $GenderCaps.remove(0,1)
    
    #force first character of weapons_obtained_legally caps
    $weapons_obtained_legallyCaps = $item.weapons_obtained_legally
    $weapons_obtained_legally = $weapons_obtained_legallyCaps.toCharArray()[0].tostring().toUpper() + $weapons_obtained_legallyCaps.remove(0,1)
    $weapons_obtained_legally = $weapons_obtained_legally -replace '^[-]+$', ''

    #force first character of gender caps
    $where_obtainedCaps = $item.where_obtained
    $where_obtained = $where_obtainedCaps.toCharArray()[0].tostring().toUpper() + $where_obtainedCaps.remove(0,1)
    $where_obtained = $where_obtained -replace '^[-]+$', ''

    #force first character of mental_health_details caps
    $mental_health_detailsCaps = $item.mental_health_details
    $mental_health_details = $mental_health_detailsCaps.toCharArray()[0].tostring().toUpper() + $mental_health_detailsCaps.remove(0,1)
    $mental_health_details = $mental_health_details -replace '^[-]+$', ''

    # Removing - from age_of_shooter
    $age_of_shooter = $item.age_of_shooter -replace '^[-]+$', ''

    # Removing - from weapon_details
    $weapon_details = $item.weapon_details -replace '^[-]+$', ''

    # Removing - from mental_health_sources
    $mental_health_sources = $item.mental_health_sources -replace '^[-]+$', ''

    # Removing - from latitude
    $latitude = $item.latitude -replace '^[-]+$', ''

    # Removing - from longitude
    $longitude = $item.longitude -replace '^[-]+$', ''

    #the gender values are not consistnt, abbreviating the gender value for more consistant data
    $GenderValueLength = $item.gender.length
    if($GenderValueLength -eq 4){
        $Gender = 'M'
    }elseif ($GenderValueLength -eq 6) {
        $Gender = 'F'
    }elseif($GenderValueLength -eq 13){
        $Gender = 'M/F'
    }else{
        #Do nothing if the value length is 1. (result already "M", "F" or "M/F")
    }
    
    #custom csv list building so the location column can be split $item
    $row = new-object psobject
    $row | Add-member -membertype NoteProperty -name "case" -value $item.case
    $row | Add-member -membertype NoteProperty -name "location" -value $item.location
    $row | Add-member -membertype NoteProperty -name "city" -value $City
    $row | Add-member -membertype NoteProperty -name "state" -value $State
    $row | Add-member -membertype NoteProperty -name "date" -value $item.date
    $row | Add-member -membertype NoteProperty -name "summary" -value $item.summary
    $row | Add-member -membertype NoteProperty -name "fatalities" -value $item.fatalities
    $row | Add-member -membertype NoteProperty -name "injured" -value $item.injured
    $row | Add-member -membertype NoteProperty -name "total_victims" -value $item.total_victims
    $row | Add-member -membertype NoteProperty -name "location_2" -value $Location_2
    $row | Add-member -membertype NoteProperty -name "age_of_Shooter" -value $age_of_shooter
    $row | Add-member -membertype NoteProperty -name "prior_signs_mental_health_issues" -value $PriorSignsMentalHealthIssues
    $row | Add-member -membertype NoteProperty -name "mental_health_details" -value $mental_health_details
    $row | Add-member -membertype NoteProperty -name "weapons_obtained_legally" -value $weapons_obtained_legally
    $row | Add-member -membertype NoteProperty -name "where_obtained" -value $where_obtained
    $row | Add-member -membertype NoteProperty -name "weapon_type" -value $WeaponType
    $row | Add-member -membertype NoteProperty -name "weapon_details" -value $weapon_details
    $row | Add-member -membertype NoteProperty -name "race" -value $Race
    $row | Add-member -membertype NoteProperty -name "gender" -value $Gender
    $row | Add-member -membertype NoteProperty -name "sources" -value $item.sources
    $row | Add-member -membertype NoteProperty -name "mental_health_sources" -value $mental_health_sources
    $row | Add-member -membertype NoteProperty -name "sources_additional_age" -value $item.sources_additional_age
    $row | Add-member -membertype NoteProperty -name "latitude" -value $latitude
    $row | Add-member -membertype NoteProperty -name "longitude" -value $longitude
    $row | Add-member -membertype NoteProperty -name "type" -value $item.type
    $row | Add-member -membertype NoteProperty -name "year" -value $item.year
    $row | Add-member -membertype NoteProperty -name "changes" -value $item.changes
    $data += $row

} 


# RowIndex1
$rowIndex1 = [array]::IndexOf($data.summary,'Michael Louis, 45, killed four, including two doctors, and took his own life, according to authorities. "The gunman, who the chief said fatally shot himself, had been carrying a letter saying he blamed his surgeon for continuing back pain and intended to kill him and anyone who got in the way," according to the New York Times. Louis purchased the AR-15-style rifle he used the day of the attack, according to city Police Chief Wendell Franklin.')
$data[$rowIndex1].injured = "0"
$data[$rowIndex1].total_victims = "4"
$data[$rowIndex1].age_of_Shooter = "45"
$data[$rowIndex1].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex1].changes = "Updated injured, total_victims, age_of_shooter, weapon_type"
#$data[$rowIndex1]

# RowIndex2
$rowIndex2 = [array]::IndexOf($data.case,'Thousand Oaks nightclub shooting')
$data[$rowIndex2].weapon_type = "One semiautomatic handgun"
$data[$rowIndex2].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex2]

# RowIndex4
$rowIndex4 = [array]::IndexOf($data.case,'Capital Gazette shooting')
$data[$rowIndex4].weapon_type = "One shotgun"
$data[$rowIndex4].changes = "Updated weapon type to match the weapon desc and to keep values consistant"
#$data[$rowIndex4]

# RowIndex5
$rowIndex5 = [array]::IndexOf($data.summary,'Kurt Myers, 64, shot six people in neighboring towns, killing two in a barbershop and two at a car care business, before being killed by officers in a shootout after a nearly 19-hour standoff.')
$data[$rowIndex5].weapon_type = "One shotgun"
$data[$rowIndex5].changes = "Updated weapon type to match the weapon desc and to keep values consistant"
#$data[$rowIndex5]

# RowIndex6
$rowIndex6 = [array]::IndexOf($data.weapon_type,'2 handguns')
$data[$rowIndex6].weapon_type = "Two handguns"
$data[$rowIndex6].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex6]

# RowIndex7
$rowIndex7 = [array]::IndexOf($data.summary,'Suspected gunman Robert "Bobby" Crimo, 21, allegedly opened fire with a rifle from a rooftop during an Independence Day parade, unleashing several bursts of rapid fire, and then escaped from the scene as police responded. He was taken into custody about eight hours later, a few miles from the scene of the attack, following a large-scale manhunt by law enforcement. (*Further details pending.)')
$data[$rowIndex7].weapon_type = "One semiautomatic rifle"
$data[$rowIndex7].changes = "Updated weapon type to match the weapon desc and to keep values consistant"
#$data[$rowIndex7]

# RowIndex8
$rowIndex8 = [array]::IndexOf($data.summary,'Samuel Cassidy, 57, a Valley Transportation Authorty employee, opened fire at a union meeting at the light rail facility, soon also fatally shooting himself at the scene. Before the attack, Cassidy had set fire to his own house, where he also had firearms and a stockpile of ammunition. His legal history included his ex-wife filing a restraining order against him in 2009.')
$data[$rowIndex8].weapon_type = "One Semiautomatic handgun"
$data[$rowIndex8].changes = "Updated weapon type to match the weapon desc and to keep values consistant"
#$data[$rowIndex8]

# RowIndex9
$rowIndex9 = [array]::IndexOf($data.summary,'Robert Lewis Dear, 57, shot and killed a police officer and two citizens when he opened fire at a Planned Parenthood health clinic in Colorado Springs, Colorado. Nine others were wounded. Dear was arrested after an hours-long standoff with police.')
$data[$rowIndex9].weapon_type = "Seven semiautomatic rifles, one shotgun, five handguns"
$data[$rowIndex9].weapon_details = "Dear had with him four SKS rifles, five handguns, two additional rifles, a shotgun, more than 500 rounds of ammunition, as well as propane tanks"
$data[$rowIndex9].sources = "http://www.nytimes.com/2015/11/28/us/colorado-planned-parenthood-shooting.html and http://www.cnn.com/2015/12/09/us/colorado-planned-parenthood-shooting/ and http://www.npr.org/sections/thetwo-way/2015/11/28/457674369/planned-parenthood-shooting-police-name-suspect-procession-for-fallen-officer and http://www.cbsnews.com/news/robert-lewis-dear-planned-parenthood-first-court-appearance/ and http://www.denverpost.com/news/ci_29729326/judge-wont-release-all-records-accused-planned-parenthood and http://www.csindy.com/IndyBlog/archives/2016/02/17/judge-resists-unsealing-dear-affidavits; http://www.nbcnews.com/news/us-news/who-robert-dear-planned-parenthood-shooting-suspect-seemed-strange-not-n470896; https://www.justice.gov/opa/pr/robert-dear-indicted-federal-grand-jury-2015-planned-parenthood-clinic-shooting"
$data[$rowIndex9].changes = "Updated weapon type to be more consistant, updated weapon details according to new source link from justice.gov"
#$data[$rowIndex9]

# RowIndex10
$rowIndex10 = [array]::IndexOf($data.case,'Pennsylvania hotel bar shooting')
$data[$rowIndex10].weapon_type = "One handgun"
$data[$rowIndex10].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex10]

# RowIndex11
$rowIndex11 = [array]::IndexOf($data.case,'SunTrust bank shooting')
$data[$rowIndex11].weapon_type = "One semiautomatic handgun"
$data[$rowIndex11].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex11]

# RowIndex12
$rowIndex12 = [array]::IndexOf($data.summary,'Javier Casarez, 54, who was going through a bitter divorce, went on a shooting spree targeting his ex-wife and former coworkers at the trucking company. His attack included fatally shooting one victim who he pursued to a nearby sporting goods retailer, and two others at a private residence. After then carjacking a woman who was driving with a child (and letting the two go), Casarez fatally shot himself as law enforcement officials closed in on him.')
$data[$rowIndex12].weapon_type = "One revolver"
$data[$rowIndex12].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex12]

# RowIndex13
$rowIndex13 = [array]::IndexOf($data.summary,'Radee Labeeb Prince, 37, fatally shot three people and wounded two others around 9am at Advance Granite Solutions, a home remodeling business where he worked near Baltimore. Hours later he shot and wounded a sixth person at a car dealership in Wilmington, Delaware. He was apprehended that evening following a manhunt by authorities.')
$data[$rowIndex13].weapon_type = "One semiautomatic handgun"
$data[$rowIndex13].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex13]

# RowIndex14
$rowIndex14 = [array]::IndexOf($data.summary,'Kori Ali Muhammad, 39, opened fire along a street in downtown Fresno, killing three people randomly in an alleged hate crime prior to being apprehended by police. Muhammad, who is black, killed three white victims and later described his attack as being racially motivated; he also reportedly yelled ''Allahu Akbar'' at the time he was arrested, but authorities indicated they found no links to Islamist terrorism.')
$data[$rowIndex14].weapon_type = "One revolver"
$data[$rowIndex14].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex14]

# RowIndex15
$rowIndex15 = [array]::IndexOf($data.summary,'Dylann Storm Roof, 21, shot and killed 9 people after opening fire at the Emanuel AME Church in Charleston, South Carolina. According to a roommate, he had allegedly been “planning something like that for six months."')
$data[$rowIndex15].weapon_type = "One semiautomatic handgun"
$data[$rowIndex15].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex15]

# RowIndex16
$rowIndex16 = [array]::IndexOf($data.case,'Marysville-Pilchuck High School shooting')
$data[$rowIndex16].weapon_type = "One semiautomatic handgun"
$data[$rowIndex16].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex16]

# RowIndex17
$rowIndex17 = [array]::IndexOf($data.summary,'Army Specialist Ivan Lopez, 34, opened fire at the Fort Hood Army Post in Texas, killing three and wounding at least 12 others before shooting himself in the head after engaging with military police. Lt. Gen. Mark A. Milley told reporters that Lopez "had behavioral health and mental health" issues.')
$data[$rowIndex17].weapon_type = "One semiautomatic handgun"
$data[$rowIndex17].changes = "Updated weapon type to be more consistant"
#$data[$rowIndex17]

# RowIndex18
$rowIndex18 = [array]::IndexOf($data.summary,'Anthony Ferrill, 51, an employee armed with two handguns, including one with a silencer, opened fire on the Milwaukee campus of the beer company, killing five people and then committing suicide. According to the Milwaukee Journal Sentinel, Ferrill "had been involved in a long-running dispute with a co-worker that boiled over" in the run-up to the attack.')
$data[$rowIndex18].weapon_type = "Two handguns"
$data[$rowIndex18].changes = "Updated weapon type to be more consistant. Reviewed all source links, no mention of semiautomatic or gun details."
#$data[$rowIndex18]

# RowIndex19
$rowIndex19 = [array]::IndexOf($data.summary,'"A man believed to be meeting his three children for a supervised visit at a church just outside Sacramento on Monday afternoon fatally shot the children and an adult accompanying them before killing himself, police officials said. Sheriff Scott Jones of Sacramento County told reporters at the scene that the gunman had a restraining order against him, and that he had to have supervised visits with his children, who were younger than 15." (NYTimes)')
$data[$rowIndex19].age_of_Shooter = "39"
$data[$rowIndex19].changes = "Age of shooter found in source link"
#$data[$rowIndex19]

# RowIndex20
$rowIndex20 = [array]::IndexOf($data.summary,'Aminadab Gaxiola Gonzalez, 44, allegedly opened fire inside a small business at an office complex, killing at least four victims, including a nine-year-old boy, before being wounded in a confrontation with police and taken into custody. According to law enforcement officials, Gonzalez had chained the front and rear gates to the complex with bicycle cable locks to hinder police response.')
$data[$rowIndex20].age_of_Shooter = "44"
$data[$rowIndex20].weapon_type = "One semiautomatic handgun"
$data[$rowIndex20].changes = "Age of shooter found in summary, updated weapon type to be consistant"
#$data[$rowIndex20]

# RowIndex21
$rowIndex21 = [array]::IndexOf($data.summary,'Gary Martin, 45, went on a rampage inside the warehouse in response to being fired from his job and died soon thereafter in a shootout with police. Among his victims were five dead coworkers and five injured police officers. Martin had a felony record and lengthy history of domestic violence; he was able to obtain a gun despite having had his Illinois firearms ownership identification card revoked. According to a report from prosecutors, Martin told a co-worker the morning of the shooting that if he was fired he was going to kill employees and police.')
$data[$rowIndex21].weapon_type = "One semiautomatic handgun"
$data[$rowIndex21].weapon_details = "Smith & Wesson .40 cal handgun, with a green sighting laser"
$data[$rowIndex21].changes = "Updated weapon type based on the information in weapon details so data is consistant."
#$data[$rowIndex21]

# RowIndex22
$rowIndex22 = [array]::IndexOf($data.summary,'David N. Anderson, 47, and Francine Graham, 50, were heavily armed and traveling in a white van when they first killed a police officer in a cemetery, and then opened fire at a kosher market, “fueled both by anti-Semitism and anti-law enforcement beliefs,” according to New Jersey authorities. The pair, linked to the antisemitic ideology of the Black Hebrew Israelites extremist group, were killed after a lenghty gun battle with police at the market.')
$data[$rowIndex22].weapon_type = "One assault rifle, two semiautomatic pistols, one shotgun"
$data[$rowIndex22].weapon_details = "AR-15-style rifle, 12-gauge shotgun, two 9-millimeter semiautomatic pistols"
$data[$rowIndex22].age_of_Shooter = "48"
$data[$rowIndex22].changes = "Updated weapon type and weapon details based on the information in source links. Updated age to be the average of both shooters."
#$data[$rowIndex22]

# RowIndex23
$rowIndex23 = [array]::IndexOf($data.summary,'Aaron Alexis, 34, a military veteran and contractor from Texas, opened fire in the Navy installation, killing 12 people and wounding 8 before being shot dead by police.')
$data[$rowIndex23].weapon_type = "One shotgun, one handgun"
$data[$rowIndex23].weapon_details = "Remington 870 Express, 12-gauge Sawed-off shotgun, .45-caliber Beretta handgun"
$data[$rowIndex23].changes = "Updated weapon type and weapon details to be more consistant."
#$data[$rowIndex23]

# RowIndex24
$rowIndex24 = [array]::IndexOf($data.summary,'Juan Lopez, 32, confronted his former fiancé, ER doctor Tamara O''Neal, before shooting her and opening fire on others at the hospital, including a responding police officer, Samuel Jimenez, and a pharmacy employee, Dayna Less. Lopez was fatally shot by a responding SWAT officer. Lopez had a history of domestic abuse against an ex-wife, and was kicked out of a fire department training academy for misconduct against female cadets.')
$data[$rowIndex24].weapon_type = "One semiautomatic handgun"
$data[$rowIndex24].changes = "Updated weapon type to be more consistant."
#$data[$rowIndex24]

# RowIndex25
$rowIndex25 = [array]::IndexOf($data.summary,'Robert Findlay Smith, 70, opened fire with a handgun at a potluck dinner and was subdued by a church member until police arrived to apprehend him.')
$data[$rowIndex25].weapon_type = "One handgun"
$data[$rowIndex25].changes = "Updated weapon type to be more consistant."
#$data[$rowIndex25]

# RowIndex26
$rowIndex26 = [array]::IndexOf($data.summary,'Ethan Crumbley, a 15-year-old student at Oxford High School, opened fire with a Sig Sauer 9mm pistol purchased four days earlier by his father, and was apprehended by police shortly thereafter. Prosecutors filed charges against Crumbley for terrorism and first-degree murder.')
$data[$rowIndex26].weapon_type = "One semiautomatic handgun"
$data[$rowIndex26].changes = "Updated weapon type to be more consistant."
#$data[$rowIndex26]

# RowIndex27
$rowIndex27 = [array]::IndexOf($data.summary,'Michael McDermott, 42, opened fire on co-workers at Edgewater Technology and was later arrested.')
$data[$rowIndex27].weapon_type = "One semiautomatic handgun, one semiautomatic rifle, one shotgun"
$data[$rowIndex27].changes = "Updated weapon type to be more consistant."
#$data[$rowIndex27]

# RowIndex28
$rowIndex28 = [array]::IndexOf($data.case,'Rural Ohio nursing home shooting')
$data[$rowIndex28].weapon_type = "One handgun, one shotgun"
$data[$rowIndex28].changes = "Updated weapon type to be more consistant."
#$data[$rowIndex28]

# RowIndex29
$rowIndex29 = [array]::IndexOf($data.summary,'Salvador Ramos, 18, was identified by authorities as the suicidal gunman who attacked at Robb Elementary school.')
$data[$rowIndex29].weapon_type = "Two semiautomatic rifles"
$data[$rowIndex29].weapon_details = "Smith & Wesson MP 15, Daniel Defense rifle"
$data[$rowIndex29].changes = "Updated weapon type to be more consistant. Updated weapon details from information in source"
#$data[$rowIndex29]

# RowIndex30
$rowIndex30 = [array]::IndexOf($data.summary,'Kuwaiti-born Mohammod Youssuf Abdulazeez, 24, a naturalized US citizen, opened fire at a Naval reserve center, and then drove to a military recruitment office where he shot and killed four Marines and a Navy service member, and wounded a police officer and another military service member. He was then fatally shot in an exchange of gunfire with law enforcement officers responding to the attack.')
$data[$rowIndex30].weapon_type = "Two semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex30].changes = "Updated weapon type based on the information in weapon_details so data is consistant"
#$data[$rowIndex30]

# RowIndex31
$rowIndex31 = [array]::IndexOf($data.summary,'Dennis Clark III, 27, shot and killed his girlfriend in their shared apartment, and then shot two witnesses in the building''s parking lot and a third victim in another apartment, before being killed by police.')
$data[$rowIndex31].weapon_type = "One semiautomatic handgun, one shotgun"
$data[$rowIndex31].location_2 = "Other"
$data[$rowIndex31].changes = "Updated weapon type based on the information in weapon_details so data is consistant. Updated location_2 to be more consistant."
#$data[$rowIndex31]

# RowIndex32
$rowIndex32 = [array]::IndexOf($data.summary,'Pedro Vargas, 42, set fire to his apartment, killed six people in the complex, and held another two hostages at gunpoint before a SWAT team stormed the building and fatally shot him.')
$data[$rowIndex32].weapon_type = "One semiautomatic handgun"
$data[$rowIndex32].weapon_details = "Glock 17 9mm"
$data[$rowIndex32].location_2 = "Other"
$data[$rowIndex32].changes = "Updated weapon type based on the information in weapon_details so data is consistant. Added 9mm to the weapon_details per sources. Updated location_2 to be more consistant."
#$data[$rowIndex32]

# RowIndex33
$rowIndex33 = [array]::IndexOf($data.summary,'Dimitrios Pagourtzis, a 17-year-old student, opened fire at Santa Fe High School with a shotgun and .38 revolver owned by his father; Pagourtzis killed 10 and injured at least 13 others before surrendering to authorities after a standoff and additional gunfire inside the school. (Pagourtzis reportedly had intended to commit suicide.) Investigators also found undetonated explosive devices in the vicinity. (FURTHER DETAILS PENDING.)')
$data[$rowIndex33].weapon_type = "One shotgun, one revolver"
$data[$rowIndex33].weapon_details = ".38 revolver"
$data[$rowIndex33].changes = "Updated weapon type based on the information in weapon_details so data is consistant. Updated weapon details to be more consistant"
#$data[$rowIndex33]

# RowIndex34
$rowIndex34 = [array]::IndexOf($data.summary,'Randy Stair, a 24-year-old worker at Weis grocery fatally shot three of his fellow employees. He reportedly fired 59 rounds with a pair of shotguns before turning the gun on himself as another co-worker fled the scene for help and law enforcement responded.')
$data[$rowIndex34].weapon_type = "Two shotguns"
$data[$rowIndex34].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex34]

# RowIndex35
$rowIndex35 = [array]::IndexOf($data.summary,'Kevin Janson Neal, 44, went on an approximately 45-minute shooting spree in the rural community of Rancho Tehama Reserve in Northern California, including shooting up an elementary school, before being killed by law enforcement officers. Neal had also killed his wife at home.')
$data[$rowIndex35].weapon_type = "Two semiautomatic rifles"
$data[$rowIndex35].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex35]

# RowIndex36
$rowIndex36 = [array]::IndexOf($data.summary,'John Zawahri, 23, armed with a homemade assault rifle and high-capacity magazines, killed his brother and father at home and then headed to Santa Monica College, where he was eventually killed by police.')
$data[$rowIndex36].weapon_type = "One semiautomatic rifle, one handgun"
$data[$rowIndex36].location_2 = "Other"
$data[$rowIndex36].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. Updated location_2 to be more consistant."
#$data[$rowIndex36]

# RowIndex37
$rowIndex37 = [array]::IndexOf($data.summary,'Timothy O''Brien Smith, 28, wearing body armor and well-stocked with ammo, opened fire at a carwash early in the morning in this rural community, killing four people. A fifth victim, though not shot, suffered minor injuries. One of the deceased victims, 25-year-old Chelsie Cline, had been romantically involved with Smith and had broken off the relationship recently, according to her sister. Smith shot himself in the head and died later that night at the hospital.')
$data[$rowIndex37].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex37].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex37]

# RowIndex38
$rowIndex38 = [array]::IndexOf($data.summary,'Snochia Moseley, 26, reportedly a disgruntled employee, shot her victims outside the building and on the warehouse floor; she later died from a self-inflicted gunshot at a nearby hospital. (No law enforcement officers responding to her attack fired shots.)')
$data[$rowIndex38].weapon_type = "One semiautomatic handgun"
$data[$rowIndex38].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex38]

# RowIndex39
$rowIndex39 = [array]::IndexOf($data.summary,'Omar Enrique Santa Perez, 29, walked into the ground-floor lobby of a building in downtown Cincinnati shortly after 9 a.m. and opened fire. Within minutes, Perez was fatally wounded in a shootout with law enforcement officers responding to the scene.')
$data[$rowIndex39].weapon_type = "One semiautomatic handgun"
$data[$rowIndex39].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex39]

# RowIndex40
$rowIndex40 = [array]::IndexOf($data.case,'San Ysidro McDonald''s massacre')
$data[$rowIndex40].weapon_type = "One semiautomatic handgun, one semiautomatic rifle, one shotgun"
$data[$rowIndex40].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex40]

# RowIndex41
$rowIndex41 = [array]::IndexOf($data.summary,'Esteban Santiago, 26, flew from Alaska to Fort Lauderdale, where he opened fire in the baggage claim area of the airport, killing five and wounding six before police aprehended him. (Numerous other people were reportedly injured while fleeing during the panic.)')
$data[$rowIndex41].weapon_type = "One semiautomatic handgun"
$data[$rowIndex41].changes = "Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex41]

# RowIndex42
$rowIndex42 = [array]::IndexOf($data.summary,'Ahmad Al Aliwi Alissa, 21, carried out a mass shooting at a King Soopers that left 10 victims dead, including veteran police officer Eric Talley, who was the first officer to respond on the scene. Alissa was wounded by police and taken into custody.')
$data[$rowIndex42].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex42].weapon_details = "Ruger AR-556; weapon was purchased six days before the attack. One tactical vest"
$data[$rowIndex42].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. Moved tactical vest from weapon type to weapon_details"
#$data[$rowIndex42]

# RowIndex43
$rowIndex43 = [array]::IndexOf($data.summary,'Brandon Scott Hole, 19, opened fire around 11 p.m. in the parking lot and inside the warehouse, and then shot himself fatally as police responded to the scene.')
$data[$rowIndex43].weapon_type = "One semiautomatic rifle"
$data[$rowIndex43].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. Updated Summary"
#$data[$rowIndex43]

# RowIndex44
$rowIndex44 = [array]::IndexOf($data.summary,'Maurice Clemmons, 37, a felon who was out on bail for child-rape charges, entered a coffee shop on a Sunday morning and shot four police officers who had gone there to use their laptops before their shifts. Clemmons, who was wounded fleeing the scene, was later shot dead by a police officer in Seattle after a two-day manhunt.')
$data[$rowIndex44].weapon_type = "One semiautomatic handgun, one revolver"
$data[$rowIndex44].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex44]

# RowIndex45
$rowIndex45 = [array]::IndexOf($data.summary,'Payton S. Gendron, 18, committed a racially motivated mass murder, according to authorities. He livestreamed the attack and was apprehended by police.')
$data[$rowIndex45].weapon_type = "One semiautomatic rifle"
$data[$rowIndex45].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex45]

# RowIndex46
$rowIndex46 = [array]::IndexOf($data.summary,'Connor Betts, 24, died during the attack, following a swift police response. He wore tactical gear including body armor and hearing protection, and had an ammunition device capable of holding 100 rounds. Betts had a history of threatening behavior dating back to high school, including reportedly having hit lists targeting classmates for rape and murder.')
$data[$rowIndex46].weapon_type = "One semiautomatic rifle"
$data[$rowIndex46].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex46]

# RowIndex47
$rowIndex47 = [array]::IndexOf($data.summary,'Patrick Crusius, 21, who was apprehended by police, posted a so-called manifesto online shortly before the attack espousing ideas of violent white nationalism and hatred of immigrants. "This attack is a response to the Hispanic invasion of Texas," he allegedly wrote in the document.')
$data[$rowIndex47].weapon_type = "One semiautomatic rifle"
$data[$rowIndex47].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex47]

# RowIndex48
$rowIndex48 = [array]::IndexOf($data.summary,'Santino William LeGan, 19, fired indiscriminately into the crowd near a concert stage at the festival. He used an AK-47-style rifle, purchased legally in Nevada three weeks earlier. After apparently pausing to reload, he fired additional multiple rounds before police shot him and then he killed himself. A witness described overhearing someone shout at LeGan, "Why are you doing this?" LeGan, who wore camouflage and tactical gear, replied: “Because I''m really angry." The murdered victims included a 13-year-old girl, a man in his 20s, and six-year-old Stephen Romero.')
$data[$rowIndex48].weapon_type = "One semiautomatic rifle"
$data[$rowIndex48].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex48]

# RowIndex49
$rowIndex49 = [array]::IndexOf($data.case,'Waffle House shooting')
$data[$rowIndex49].weapon_type = "One semiautomatic rifle"
$data[$rowIndex49].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex49]

# RowIndex50
$rowIndex50 = [array]::IndexOf($data.summary,'Nikolas J. Cruz, 19, heavily armed with an AR-15, tactical gear, and “countless magazines” of ammo, according to the Broward County Sheriff, attacked the high school as classes were ending for the day, killing at least 17 people and injuring many others. He was apprehended by authorities shortly after fleeing the campus.')
$data[$rowIndex50].weapon_type = "One semiautomatic rifle"
$data[$rowIndex50].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex50]

# RowIndex51
$rowIndex51 = [array]::IndexOf($data.summary,'Robert A. Hawkins, 19, opened fire inside Westroads Mall before committing suicide.')
$data[$rowIndex51].weapon_type = "One semiautomatic rifle"
$data[$rowIndex51].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex51]

# RowIndex52
$rowIndex52 = [array]::IndexOf($data.summary,'Off-duty sheriff''s deputy Tyler Peterson, 20, opened fire inside an apartment after an argument at a homecoming party. He fled the scene and later committed suicide.')
$data[$rowIndex52].weapon_type = "One semiautomatic rifle"
$data[$rowIndex52].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex52]

# RowIndex53
$rowIndex53 = [array]::IndexOf($data.summary,'Former Caltrans employee Arturo Reyes Torres, 41, opened fire at a maintenance yard after he was fired for allegedly selling government materials he''d stolen from work. He was shot dead by police.')
$data[$rowIndex53].weapon_type = "One semiautomatic rifle"
$data[$rowIndex53].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex53]

# RowIndex54
$rowIndex54 = [array]::IndexOf($data.summary,'Former airman Dean Allen Mellberg, 20, opened fire inside a hospital at the Fairchild Air Force Base before he was shot dead by a military police officer outside.')
$data[$rowIndex54].weapon_type = "One semiautomatic rifle"
$data[$rowIndex54].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex54]

# RowIndex55
$rowIndex55 = [array]::IndexOf($data.summary,'James Holmes, 24, opened fire in a movie theater during the opening night of "The Dark Night Rises" and was later arrested outside.')
$data[$rowIndex55].weapon_type = "One semiautomatic rifle, one shotgun, two semiautomatic handguns"
$data[$rowIndex55].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex55]

# RowIndex56
$rowIndex56 = [array]::IndexOf($data.summary,'Kyle Aaron Huff, 28, opened fire at a rave afterparty in the Capitol Hill neighborhood of Seattle before committing suicide.')
$data[$rowIndex56].weapon_type = "One semiautomatic rifle, one shotgun, two semiautomatic handguns"
$data[$rowIndex56].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex56]

# RowIndex57
$rowIndex57 = [array]::IndexOf($data.summary,'Noah Harpham, 33, shot three people before dead in Colorado Springs before police killed him in a shootout.')
$data[$rowIndex57].weapon_type = "One semiautomatic rifle, two semiautomatic handguns"
$data[$rowIndex57].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex57]

# RowIndex58
$rowIndex58 = [array]::IndexOf($data.summary,'Retired librarian William Cruse, 59, was paranoid neighbors gossiped that he was gay. He drove to a Publix supermarket, killing two Florida Tech students en route before opening fire outside and killing a woman. He then drove to a Winn-Dixie supermarket and killed three more, including two police officers. Cruse was arrested after taking a hostage and died on death row in 2009.')
$data[$rowIndex58].weapon_type = "One semiautomatic rifle, one shotgun, one revolver"
$data[$rowIndex58].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex58]

# RowIndex59
$rowIndex59 = [array]::IndexOf($data.summary,'Army Sgt. Kenneth Junior French, 22, opened fire inside Luigi''s Italian restaurant while ranting about gays in the military before he was shot and arrested by police.')
$data[$rowIndex59].weapon_type = "One semiautomatic rifle, two shotguns"
$data[$rowIndex59].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex59]

# RowIndex60
$rowIndex60 = [array]::IndexOf($data.summary,'Former Lindhurst High School student Eric Houston, 20, angry about various personal failings, killed three students and a teacher at the school before surrendering to police after an eight-hour standoff. He was later sentenced to death.')
$data[$rowIndex60].weapon_type = "One semiautomatic rifle, one shotgun"
$data[$rowIndex60].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex60]

# RowIndex61
$rowIndex61 = [array]::IndexOf($data.case,'Cascade Mall shooting')
$data[$rowIndex61].weapon_type = "One semiautomatic rifle"
$data[$rowIndex61].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex61]

# RowIndex62
$rowIndex62 = [array]::IndexOf($data.sumamry,'Laid-off postal worker Thomas McIlvane, 31, opened fire at his former workplace before committing suicide.')
$data[$rowIndex62].weapon_type = "One semiautomatic rifle"
$data[$rowIndex62].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex62]

# RowIndex63
$rowIndex63 = [array]::IndexOf($data.case,'IHOP shooting')
$data[$rowIndex63].weapon_type = "Two semiautomatic rifle, one revolver"
$data[$rowIndex63].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex63]

# RowIndex64
$rowIndex64 = [array]::IndexOf($data.summary,'Robert D. Bowers, 46, shouted anti-Semitic slurs as he opened fire inside the Tree of Life synagogue during Saturday morning worship. He was armed with an assault rifle and multiple handguns and was apprehended after a standoff with police. His social media accounts contained virulent anti-Semitic content, and references to migrant caravan "invaders" hyped by President Trump and the Republican party ahead of the 2018 midterms elections.')
$data[$rowIndex64].weapon_type = "One semiautomatic rifle, three semiautomatic handguns"
$data[$rowIndex64].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex64]

# RowIndex65 
$rowIndex65 = [array]::IndexOf($data.summary, 'Syed Rizwan Farook left a Christmas party held at Inland Regional Center, later returning with Tashfeen Malik and the two opened fire, killing 14 and wounding 21, ten critically. The two were later killed by police as they fled in an SUV.')
$data[$rowIndex65].weapon_type = "Two semiautomatic rifles, two semiautomatic handguns"
$data[$rowIndex65].weapon_details = "Two semiautomatic AR-15-style rifles-one a DPMS A-15, the other a Smith & Wesson M&P15, both with .223 calibre ammunition. Two 9mm semiautomatic handguns. High capacity magazines.Police found a remote controlled explosive device at the scene of the crime.At the home were 12 pipe bombs, 2,500 rounds for the AR-15 variants, 2,000 rounds for the pistols, and several hundred for a .22 calibre rifle. In the suspects car were an additional 1,400 rounds for the rifles and 200 for the handguns."
$data[$rowIndex65].location_2 = "Workplace"
$data[$rowIndex65].weapons_obtained_legally = "Yes"
$data[$rowIndex65].changes = "Updated weapon type, weapon details, location_2, and weapons obtained legally to include more details from sources and to be more consistant."
#$data[$rowIndex65]

# RowIndex66
$rowIndex66 = [array]::IndexOf($data.case,'Standard Gravure shooting')
$data[$rowIndex66].weapon_type = "One semiautomatic rifle, two semiautomatic handguns, one revolver"
$data[$rowIndex66].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex66]

# RowIndex67
$rowIndex67 = [array]::IndexOf($data.summary,'Patrick Purdy, 26, an alcoholic with a police record, launched an assault at Cleveland Elementary School, where many young Southeast Asian immigrants were enrolled. Purdy killed himself with a shot to the head.')
$data[$rowIndex67].weapon_type = "One semiautomatic rifle, one handgun"
$data[$rowIndex67].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex67]

# RowIndex68
$rowIndex68 = [array]::IndexOf($data.summary,'Failed businessman Gian Luigi Ferri, 55, opened fire throughout an office building before he committed suicide inside as police pursued him.')
$data[$rowIndex68].weapon_type = "Three semiautomatic handguns"
$data[$rowIndex68].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex68]

# RowIndex69
$rowIndex69 = [array]::IndexOf($data.case,'Pensacola Naval base shooting')
$data[$rowIndex69].weapon_type = "One semiautomatic handgun"
$data[$rowIndex69].weapon_details = "Glock Model 45 9mm"
$data[$rowIndex69].sources = "https://www.washingtonpost.com/national-security/2019/12/06/naval-station-pensacola-active-shooter/; https://www.cnn.com/us/live-news/pensacola-naval-base-shooter/index.html; https://www.navytimes.com/news/your-navy/2019/12/09/how-did-the-pensacola-gunman-get-the-pistol-he-used-to-kill-3-sailors"
$data[$rowIndex69].changes = "Added navytimes.com as a source, updated weapon details and weapon type based on new information and to be consistant."
#$data[$rowIndex69]

# RowIndex70
$rowIndex70 = [array]::IndexOf($data.summary,'Scott Allen Ostrem, 47, walked into a Walmart in a suburb north of Denver and fatally shot two men and a woman, then left the store and drove away. After an all-night manhunt, Ostrem, who had financial problems but no serious criminal history, was captured by police after being spotted near his apartment in Denver.')
$data[$rowIndex70].weapon_type = "One semiautomatic handgun"
$data[$rowIndex70].weapon_details = "Ruger AR-556 semiautomatic pistol"
$data[$rowIndex70].sources = "https://www.nytimes.com/2017/11/01/us/thornton-colorado-walmart-shooting.html; http://www.cnn.com/2017/11/01/us/colorado-walmart-shooting/index.html; http://www.thedenverchannel.com/news/crime/colorado-walmart-shooting-suspect-scott-ostrem-had-run-ins-with-police-financial-troubles; http://www.ibtimes.com/who-scott-ostrem-manhunt-underway-colorado-walmart-shooting-suspect-2609562; https://www.nytimes.com/live/2021/03/23/us/boulder-colorado-shooting"
$data[$rowIndex70].changes = "Added www.nytimes.com as a source, updated weapon details and weapon type based on new information and to be consistant."
#$data[$rowIndex70]

# RowIndex71
$rowIndex71 = [array]::IndexOf($data.case,'Kalamazoo shooting spree')
$data[$rowIndex71].weapon_type = "One semiautomatic handgun"
$data[$rowIndex71].changes = "Updated weapon_type based on the information in weapon_details so data is consistant"
#$data[$rowIndex71]

# RowIndex72
$rowIndex72 = [array]::IndexOf($data.summary,'26-year-old Chris Harper Mercer opened fire at Umpqua Community College in southwest Oregon. The gunman shot himself to death after being wounded in a shootout with police.')
$data[$rowIndex72].weapon_type = "One semiautomatic rifle, five semiautomatic handguns"
$data[$rowIndex72].weapon_details = "9 mm Glock pistol, .40 caliber Smith & Wesson, .40 caliber Taurus pistol, .556 caliber Del-Ton; (ammo details unclear).five magazines of ammunition"
$data[$rowIndex72].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. Updated weapon_details to be more consistant."
#$data[$rowIndex72]

# RowIndex73
$rowIndex73 = [array]::IndexOf($data.summary,'Devin Patrick Kelley, a 26-year-old ex-US Air Force airman, opened fire at the First Baptist Church in Sutherland Springs during Sunday morning services, killing at least 26 people and wounding and injuring 20 others. He left the church and fled in his vehicle after engaging in a gunfight with a local citizen; he soon crashed his vehicle and died from a self-inflicted gunshot wound.')
$data[$rowIndex73].weapon_type = "One semiautomatic rifle"
$data[$rowIndex73].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. No mention in source links about any handguns"
#$data[$rowIndex73]

# RowIndex74
$rowIndex74 = [array]::IndexOf($data.summary,'Seth A. Ator, 36, fired at police officers who stopped him for a traffic violation, and then went on a driving rampage in the Odessa-Midland region, where he also shot a postal worker and stole her vehicle. He was shot dead by law enforcement responding to the rampage. Ator had been fired from a job just prior to the attack (though per the FBI he had shown up to that job "already enraged"). He had a criminal record and "a long history of mental problems and making racist comments," according to a family friend who spoke to the media.')
$data[$rowIndex74].weapon_type = "One semiautomatic rifle"
$data[$rowIndex74].weapon_details = "AR-15 Style rifle"
$data[$rowIndex74].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. No mention in source links about any handguns"
#$data[$rowIndex74]

# RowIndex75
$rowIndex75 = [array]::IndexOf($data.case,'Yountville veterans home shooting')
$data[$rowIndex75].weapon_type = "One semiautomatic rifle, one shotgun"
$data[$rowIndex75].weapon_details = ".308 JR Enterprises LRP-07 semi-automatic rifle 12-gauge Stoeger Coach Gun"
$data[$rowIndex75].sources = "https://www.cnn.com/2018/03/10/us/california-veterans-home-shooting/index.html; http://www.ktvu.com/news/gunman-in-yountville-veterans-home-killings-was-ex-patient; https://www.washingtonpost.com/news/post-nation/wp/2018/03/09/police-respond-to-reports-of-gunfire-and-hostages-taken-at-california-veterans-home/?utm_term=.b9dde7ac5f0f; http://dig.abclocal.go.com/kgo/PDF/112918_Pathway_Home_Homicide_Redacted.pdf"
$data[$rowIndex75].changes = "Added 4 new sources to confirm weapon_details and type. No data in original sources, Added police report showing weapon details. Updated weapon_type based on the information in weapon_details so data is consistant."
#$data[$rowIndex75]

# RowIndex76
$rowIndex76 = [array]::IndexOf($data.case,'Florida awning manufacturer shooting')
$data[$rowIndex76].weapon_type = "One semiautomatic handgun"
$data[$rowIndex76].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. No mention in source links about any handguns"
#$data[$rowIndex76]

# RowIndex77
$rowIndex77 = [array]::IndexOf($data.summary,'Omar Mateen, 29, attacked the Pulse nighclub in Orlando in the early morning hours of June 12. He was killed by law enforcement who raided the club after a prolonged standoff.')
$data[$rowIndex77].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex77].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. No mention in source links about any handguns"
#$data[$rowIndex77]

# RowIndex78
$rowIndex78 = [array]::IndexOf($data.summary,'Cedric L. Ford, who worked as a painter at a manufacturing company, shot victims from his car and at his workplace before being killed by police at the scene. Shortly before the rampage he had been served with a restraining order.')
$data[$rowIndex78].weapon_type = "One semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex78].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. No mention in source links about any handguns"
#$data[$rowIndex78]

# RowIndex79
$rowIndex79 = [array]::IndexOf($data.summary,'Jonathan Sapirman, 20, opened fire in a mall food court and was soon shot dead by a 22-year-old armed civilian, whose response local authorities called "nothing short of heroic."')
$data[$rowIndex79].weapon_type = "Two semiautomatic rifle, one semiautomatic handgun"
$data[$rowIndex79].weapon_details = "Sig Sauer M400 rifle, MP15 rifle, Glock 33"
$data[$rowIndex79].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. Updated weapon details from source links. No mention in source links about any handguns"
#$data[$rowIndex79]

# RowIndex80
$rowIndex80 = [array]::IndexOf($data.summary,'Micah Xavier Johnson, a 25-year-old Army veteran, targeted police at a peaceful Black Lives Matter protest, killing five officers and injuring nine others as well as two civilians. After a prolonged standoff in a downtown building, law enforcement killed Johnson using a robot-delivered bomb.')
$data[$rowIndex80].weapon_type = "One semiautomatic rifle, two semiautomatic handguns"
$data[$rowIndex80].changes = "Updated weapon_type based on the information in weapon_details so data is consistant. No mention in source links about any handguns"
#$data[$rowIndex80]

# RowIndex81
$rowIndex81 = [array]::IndexOf($data.state,'KY')
$data[$rowIndex81].State = "Kentucky"
$data[$rowIndex81].changes = "Updated state to be consistant with other states"
#$data[$rowIndex81]

# RowIndex82
$rowIndex82 = [array]::IndexOf($data.state,'TN')
$data[$rowIndex82].State = "Tennessee"
$data[$rowIndex82].changes = "Updated state to be consistant with other states"
#$data[$rowIndex82]

# RowIndex83
$rowIndex83 = [array]::IndexOf($data.case,'Michigan State University shooting')
$data[$rowIndex83].prior_signs_mental_health_issues = "Yes"
$data[$rowIndex83].weapon_type = "Two semiautomatic handguns"
$data[$rowIndex83].weapon_details = "Two 9mm handguns with additional magazines and ammunition"
$data[$rowIndex83].sources = "https://www.cnn.com/us/live-news/michigan-state-university-shooting-updates-2-13-23/index.html; https://www.freep.com/story/news/local/michigan/2023/02/13/michigan-state-shooting-what-we-know-about-shots-fired-on-campus/69901251007/; https://abcnews.go.com/US/anthony-mcrae-suspected-michigan-state-shooter/story?id=97195504; https://www.nytimes.com/2023/02/16/us/michigan-state-shooting-professor-berkey-hall.html?referringSource=articleShare; https://www.nbcnews.com/news/us-news/msu-shooter-was-found-2-legally-purchased-guns-ammo-threatening-note-o-rcna70973"
$data[$rowIndex83].mental_health_sources = "https://abcnews.go.com/US/anthony-mcrae-suspected-michigan-state-shooter/story?id=97195504"
$data[$rowIndex83].changes = "Added new sources cnn, abcnews, nytimes, etc to help confirm and update data on mental health isssues, weapon details, weapon type. "
#$data[$rowIndex83]

if (test-path $ExportCHEdition) {Remove-Item $ExportCHEdition}

#Export clean dataset for data.world
$data | Export-CSV -path $ExportCHEdition -NoTypeInformation

if (test-path $ExportWebView) {Remove-Item $ExportWebView}

New-SQLiteDB -DirRoot $CPSScriptRoot -SQLitePath $SQLitePath -DBPath $DBPath

Push-CHSQLite -DBPath $DBPath -CSVPath $ExportCHEdition -SQLitePath $SQLitePath -CPSScriptRoot $CPSScriptRoot -TableName 'CHData'

Push-CHSQLite -DBPath $DBPath -CSVPath $ImportCSVPath -SQLitePath $SQLitePath -CPSScriptRoot $CPSScriptRoot -TableName 'MJData'

New-HTML {
    New-HTMLTable -DataTable $data -Title 'Table with Users' -HideFooter -PagingLength 200 -Buttons excelHtml5, searchPanes
} -ShowHTML -FilePath $ExportWebView -Online

