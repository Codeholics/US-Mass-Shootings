SELECT 
location_2, 
count(1) FROM codeholics_mother_jones_us_mass_shootings_1982_2024
GROUP BY location_2
ORDER BY COUNT DESC