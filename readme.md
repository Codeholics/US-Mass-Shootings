
- [Codeholics Edition | Mother Jones Mass Shooter Database 1982-2023](#codeholics-edition--mother-jones-mass-shooter-database-1982-2023)
- [How are changes made to the Codeholics Edition](#how-are-changes-made-to-the-codeholics-edition)
- [Links](#links)

<br>

# Codeholics Edition | Mother Jones Mass Shooter Database 1982-2023

The original dataset [Mother Jones](https://www.motherjones.com/) created has a few issues that is addressed before being uploaded to [Data.World](https://data.world/).
These changes used to be done manually but requires time and attention to detail to make sure it is being done properly. The goal is to help make it more useful for other data scientist to use and the last thing we want to do is damage the integrity of this valuable dataset

First, we only corrected the headers and capitals in words. While going through this process, we also found the data was not very consistent within each column and some data was even missing but was available in the sources. Some columns like weapon_type required multiple changes to structure the data consistently. 

Today, we're no longer manually updating the spreadsheet, so we're able to correct these outstanding issues and republish it to data.world. All data modifications will be clearly seen within the PowerShell script used to clean the dataset for transparency. 

<br>

# How are changes made to the Codeholics Edition

The manual process was automated using PowerShell, so we can ensure the same changes are made while being transparent of what was changed. 

1. Launch Script
   1. Download Mother Jones latest public copy
   2. Rename duplicate header "location"
   3. Column fixing as a whole (trim, split, force case)
   4. Update data to include records updates
   5. Export CSVs
2. Upload to Data.World

I have a second process that takes the CSVs and imports the data into a SQLite file.

<br>



# Links

- [Codeholics.com](https://codeholics.com)
- [Codeholics: Mother Jones US Mass Shootings 1982-2023](https://data.world/thebleak/thebleak13s1)
- [US Mass Shootings, 1982–2023: Data From Mother Jones’ Investigation](https://www.motherjones.com/politics/2012/12/mass-shootings-mother-jones-full-data/)