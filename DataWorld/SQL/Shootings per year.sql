SELECT DISTINCT year,Count(year) ,
sum(TOTAL_VICTIMS) AS Victims,
sum(TOTAL_VICTIMS)/count(1) AS VictimsPerShooting

FROM codeholics_mother_jones_us_mass_shootings_1982_2024
GROUP BY year
ORDER BY count desc