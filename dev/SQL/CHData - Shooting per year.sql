SELECT DISTINCT year, Count(year) AS YearCount,
SUM(TOTAL_VICTIMS) AS Victims,
SUM(TOTAL_VICTIMS) / COUNT(1) AS VictimsPerShooting,
100.0 * Count(year) / (SELECT Count(DISTINCT year) FROM CHData) AS YearCountPercentage
FROM CHData
GROUP BY year
ORDER BY YearCount DESC