SELECT count(summary) AS SummaryCount FROM CHData
WHERE prior_signs_mental_health_issues = "Yes"
    AND mental_health_details LIKE '%depression%'