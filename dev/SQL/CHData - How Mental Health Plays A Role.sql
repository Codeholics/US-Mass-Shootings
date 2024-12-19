SELECT 
CASE 
    WHEN prior_signs_mental_health_issues = 'TBD' THEN 'Unknown'
    WHEN prior_signs_mental_health_issues = 'Unclear' THEN 'Unknown'
    WHEN prior_signs_mental_health_issues = 'Unclear ' THEN 'Unknown'
    WHEN prior_signs_mental_health_issues = '' THEN 'Unknown'
ELSE prior_signs_mental_health_issues 
    END AS prior_signs_mental_health_issues2,
    count(1) AS Shootings,
    count(1) * 100.0 / (SELECT count(*) FROM CHData) AS Percentage
FROM CHData
GROUP BY prior_signs_mental_health_issues2
ORDER BY Shootings DESC;