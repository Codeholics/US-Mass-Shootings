-- VSCode will show TEMPORARY as an error, but it's not. It's a valid SQL statement.

-- Drop table at the top, not after query is ran or it will wipe the results.
DROP TABLE IF EXISTS temp_table1;

CREATE TEMPORARY TABLE temp_table1 AS

SELECT DISTINCT year, Count(year) AS YearCount,
SUM(TOTAL_VICTIMS) AS Victims,
SUM(TOTAL_VICTIMS) / COUNT(1) AS VictimsPerShooting,
100.0 * Count(year) / (SELECT Count(DISTINCT year) FROM CHData) AS YearCountPercentage
FROM CHData
GROUP BY year
ORDER BY YearCount DESC;

SELECT * FROM temp_table1 LIMIT 1;
