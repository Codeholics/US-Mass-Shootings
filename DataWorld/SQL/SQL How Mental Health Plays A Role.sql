SELECT 
CASE 
    WHEN prior_signs_mental_health_issues = 'TBD' THEN 'Unknown'
    WHEN prior_signs_mental_health_issues = 'Unclear' THEN 'Unknown'
    WHEN prior_signs_mental_health_issues = 'Unclear ' THEN 'Unknown'
    WHEN prior_signs_mental_health_issues = NULL THEN 'Unknown'
ELSE prior_signs_mental_health_issues 
END
AS prior_signs_mental_health_issues2,
count(1) AS Shootings,
sum(TOTAL_VICTIMS) AS Victims,
sum(TOTAL_VICTIMS)/count(1) AS VictimsPerShooting 
FROM codeholics_mother_jones_us_mass_shootings_1982_2024

GROUP BY prior_signs_mental_health_issues2
ORDER BY Shootings DESC