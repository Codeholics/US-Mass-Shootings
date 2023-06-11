SELECT DISTINCT year, Count(year) AS YearCount,
SUM(TOTAL_VICTIMS) AS Victims,
SUM(TOTAL_VICTIMS) / COUNT(1) AS VictimsPerShooting
FROM CHData
GROUP BY year
ORDER BY YearCount DESC