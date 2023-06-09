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

This project was initiated in response to the lack of consensus among media companies and government agencies regarding statistical reporting on mass shootings. The difficulty in sharing statistics arises from the controversial nature of defining what constitutes a mass shooting, compounded by the fact that record sources are not being shared.

To address this issue, extensive research was conducted to align on a definition of a mass shooting, resulting in the identification of the [National Center for Victims of Crime's definition](https://ovc.ojp.gov/sites/g/files/xyckuh226/files/ncvrw2018/info_flyers/fact_sheets/2018NCVRW_MassCasualty_508_QC.pdf) of three or more victims (excluding other crimes that include gun violence) as the most appropriate. This definition was adopted after previously being set at four victims prior to 2013.

Despite this authoritative definition, it remains unclear why other government agencies or media outlets have not adhered to it, opting instead to create their own definitions.

To address this issue, the [Mother Jones dataset](https://www.motherjones.com/politics/2012/12/mass-shootings-mother-jones-full-data/), which adheres to the VOC's definition, was selected as the primary data source. Only media reports that meet this definition are included in the dataset, which is updated regularly and publicly available to download as a CSV.

However, the original Mother Jones dataset had a few issues that were addressed before being uploaded to [Data.World](https://data.world/thebleak/thebleak13s1). These changes were previously done manually, requiring significant time and attention to detail to ensure their accuracy. Our goal is to make this valuable dataset more useful for other data scientists and preserve its integrity.

<br>

# Changes To Original Data

The original dataset used in this project had some inconsistencies, including headers and capitalization errors. Upon closer inspection, it was also found that some of the columns lacked data consistency, and some data was missing but available in the sources. One such column, "weapon_type," required multiple changes to ensure consistent data structure.

To address these issues, we have automated the process using PowerShell. This allows us to ensure consistency in the changes made to the dataset while being transparent about what was modified. The PowerShell script includes the following steps:

1. Downloading the latest public copy of the Mother Jones dataset.
2. Renaming duplicate headers.
3. Fixing columns as a whole (trimming, splitting, and forcing case).
4. Updating data to include any record updates.
5. Adding the Mother Jones Dataset and Codeholics version to a SQLite database (with record IDs created starting with the oldest record).
6. Exporting CSVs.

We no longer manually update the spreadsheet, as the modifications are now automatically executed by the script. The changes made to the data are clearly documented in the PowerShell script, SQLite database, and a new column on the final CSV output, ensuring full transparency. Once the changes have been made, the updated dataset is uploaded to Data.World, where it is available for use by other data scientists.

<br>

# Dependencies

- [PSWriteHTML](https://www.powershellgallery.com/packages/PSWriteHTML/0.0.189)
- [PSSQLite](https://www.powershellgallery.com/packages/PSSQLite/1.1.0)
- [PSLogging](https://www.powershellgallery.com/packages/PSLogging/2.5.2)

It is not required, but I found it best to review the data in the SQLite file by using [DB Browser (SQLite)](https://sqlitebrowser.org/).


<br>

# Executing The Script

1. Download the source code from the project `https://github.com/Codeholics/US-Mass-Shootings.git`
2. Update the variable `$CPSScriptRoot` in `dataworld.ps1` to be the path to the Repo project folder you created with step 1.
3. Execute `dataworld.ps1`

<br>

# Output

All artifacts after running the script can be found in the `/Export` folder.

|Path|Purpose|
|---|---|
|Mother Jones Raw.csv|The Mother Jones dataset, in its original form, is provided without any modifications. However, it should be noted that the CSV file contains duplicate headers, which renders it unsuitable for direct use in this project.|
|Mother Jones - Mass Shootings Database 1982-2023.csv|The duplicated header in the `Mother Jones Raw.csv` file has been corrected to ensure that the dataset can be used accurately and efficiently in this project.|
|thebleak13s1.csv|Final report after data changes made by `dataworld.ps1`.
|MassShooterDatabase.sqlite|The final results of this project have been stored in a SQLite database, which includes both the original dataset from Mother Jones and the Codeholics Edition. This database serves as a reliable and efficient resource for data scientists seeking to analyze and report on mass shootings. To facilitate the use of the database, sample statistics queries have been provided in the `/SQL` folder. These queries offer a useful starting point for data scientists seeking to conduct statistical analyses on mass shootings data.|

<br>

# Links

- [Codeholics.com](https://codeholics.com)
- [Codeholics: Mother Jones US Mass Shootings 1982-2023](https://data.world/thebleak/thebleak13s1)
- [US Mass Shootings, 1982–2023: Data From Mother Jones’ Investigation](https://www.motherjones.com/politics/2012/12/mass-shootings-mother-jones-full-data/)
- [National Center for Victims of Crime - Mass shooter PDF](https://ovc.ojp.gov/sites/g/files/xyckuh226/files/ncvrw2018/info_flyers/fact_sheets/2018NCVRW_MassCasualty_508_QC.pdf)

