SELECT location
, count(1) as Shootings
, sum(TOTAL_VICTIMS) as Victims
, sum(TOTAL_VICTIMS)/count(1) as VictimsPerShooting 

FROM codeholics_mother_jones_us_mass_shootings_1982_2024
GROUP BY location
ORDER BY Shootings DESC