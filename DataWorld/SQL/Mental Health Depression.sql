SELECT count(summary) AS SummaryCount FROM codeholics_mother_jones_us_mass_shootings_1982_2024
WHERE prior_signs_mental_health_issues = "Yes"
    AND mental_health_details LIKE '%depression%'