
- [Codeholics Edition | Mother Jones Mass Shooter Database 1982-2023](#codeholics-edition--mother-jones-mass-shooter-database-1982-2023)
- [Changes To Original Data](#changes-to-original-data)
- [Dependencies](#dependencies)
- [Executing The Script](#executing-the-script)
- [Output](#output)
- [Links](#links)

<br>

![PowerShell v5.1](https://img.shields.io/badge/PowerShell-v5.1-blue)

<br>

# Codeholics Edition | Mother Jones Mass Shooter Database 1982-2023

I started this project after multiple mass shootings were covered in the news. The media companies and government agencies are not on the same page when it comes to reporting statistical information about mass shooting. One reason why this topic is difficult to share stats for is because defining what a mass shooting is appears to be controversial, but it really shouldn't be. The other reason is no one shares their record sources used to provide statistics about. 

After conducting an extensive research to align on the definition of a mass shooting is for this project. I was able to locate 1 definition of a mass shooting which was posted by the [National Center for Victims of Crime](https://ovc.ojp.gov/sites/g/files/xyckuh226/files/ncvrw2018/info_flyers/fact_sheets/2018NCVRW_MassCasualty_508_QC.pdf) ("VOC"). According to the VOC, the definition for a mass shooting is 3+ victims (excluding other crimes that include gun violence). Before 2013 a mass shooting definition was 4 victims, but the agency lowered it to 3. 

This is what VOC had to say about the Mother Jones dataset "***USA Today recorded more than 350 mass shootings between 
2006 and 2017, while Mother Jones has recorded 95 since 1982. This fact 
sheet presents data published by Mother Jones, as it is kept current and 
most closely follows the federal agency definitions.***"

Still not sure why 1 government agency would define it and no other government agency or media adheres to it and instead creating their own definition.

I chose the [Mother Jones](https://www.motherjones.com/) data for this

- Follows the same definition provided by the VOC
- VOC utilizes the Mother Jones dataset for gun violence statistics. 
- Media reports are reviewed and only those that meet the definition are added.
- Data is updated regularly and publically Available to download as a CSV.

The original dataset Mother Jones created has a few issues that is addressed before being uploaded to [Data.World](https://data.world/).
These changes used to be done manually but requires time and attention to detail to make sure it is being done properly. The goal is to help make it more useful for other data scientist to use and the last thing we want to do is damage the integrity of this valuable dataset

<br>

# Changes To Original Data

First, we only corrected the headers and capitals in words. While going through this process, we also found the data was not very consistent within each column and some data was even missing but was available in the sources. Some columns like weapon_type required multiple changes to structure the data consistently. 

Today, we're no longer manually updating the spreadsheet, so we're able to execute this script to correct the outstanding issues and republish it to data.world. All data modifications will be clearly seen within the PowerShell script, SQLite Database, and added to a new column on the final CSV output for transparency. 

The manual process was automated using PowerShell, so we can ensure the same changes are made while being transparent of what was changed. 

1. Launch Script
   1. Download Mother Jones latest public copy
   2. Rename duplicate header "location"
   3. Column fixing as a whole (trim, split, force case)
   4. Update data to include records updates
   5. Add Mother Jones Dataset and Codeholics version to SQLite database (record ID's are created starting with the oldest record).
   6. Export CSVs
2. Upload to Data.World


<br>

# Dependencies

- [PSWriteHTML](https://www.powershellgallery.com/packages/PSWriteHTML/0.0.189)
- [PSSQLite](https://www.powershellgallery.com/packages/PSSQLite/1.1.0)

It is not required, but I found it best to review the data in the SQLite file by using [DB Browser (SQLite)](https://sqlitebrowser.org/).


<br>

# Executing The Script

1. Download the source code from the project `https://github.com/Codeholics/US-Mass-Shootings.git`
2. Update the variable `$CPSScriptRoot` to be the path to the Repo project folder you created with step 1.
3. Execute `dataworld.ps1`

<br>

# Output

All artifacts after running the script can be found in the `/Export` folder.

|Path|Purpose|
|---|---|
|Mother Jones Raw.csv|This is the original data from Mother Jones without any changes. The CSV has duplicate headers, so we're not able to work directly with this copy.|
|Mother Jones - Mass Shootings Database 1982-2023.csv|Corrected duplicated header from `Mother Jones Raw.csv`|
|thebleak13s1.csv|Final report after data changes made by `dataworld.ps1`.
|MassShooterDatabase.sqlite|Final results stored in a SQLite database that includes the original dataset from Mother Jones and the Codeholics Edition. You can use the queries in the `/SQL` folder for sample statistics.|

<br>

# Links

- [Codeholics.com](https://codeholics.com)
- [Codeholics: Mother Jones US Mass Shootings 1982-2023](https://data.world/thebleak/thebleak13s1)
- [US Mass Shootings, 1982–2023: Data From Mother Jones’ Investigation](https://www.motherjones.com/politics/2012/12/mass-shootings-mother-jones-full-data/)
- [National Center for Victims of Crime - Mass shooter PDF](https://ovc.ojp.gov/sites/g/files/xyckuh226/files/ncvrw2018/info_flyers/fact_sheets/2018NCVRW_MassCasualty_508_QC.pdf)
