-- Drop table at the top, not after query is ran or it will wipe the results.
DROP TABLE IF EXISTS temp_table;

-- Create temp table (as the script)
-- VSCode will show TEMPORARY as an error, but it's not. It's a valid SQL statement.
CREATE TEMPORARY TABLE temp_table AS

SELECT 'semiautomatic_handgun' AS weapon_type, sum(case when weapon_type like '%Semiautomatic handgun%' then 1 else 0 end) AS count, ROUND(sum(case when weapon_type like '%Semiautomatic handgun%' then 1 else 0 end) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) AS percentage
FROM CHData
UNION
SELECT 'semiautomatic_rifle' AS weapon_type, sum(case when weapon_type like '%semiautomatic rifle%' then 1 else 0 end) AS count, ROUND(sum(case when weapon_type like '%semiautomatic rifle%' then 1 else 0 end) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) AS percentage
FROM CHData
UNION
SELECT 'shotgun' AS weapon_type, sum(case when weapon_type like '%shotgun%' then 1 else 0 end) AS count, ROUND(sum(case when weapon_type like '%shotgun%' then 1 else 0 end) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) AS percentage
FROM CHData
UNION
SELECT 'revolver' AS weapon_type, sum(case when weapon_type like '%revolver%' then 1 else 0 end) AS count, ROUND(sum(case when weapon_type like '%revolver%' then 1 else 0 end) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) AS percentage
FROM CHData
UNION
SELECT 'derringer' AS weapon_type, sum(case when weapon_type like '%derringer%' then 1 else 0 end) AS count, ROUND(sum(case when weapon_type like '%derringer%' then 1 else 0 end) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) AS percentage
FROM CHData
UNION
SELECT 'knife' AS weapon_type, sum(case when weapon_type like '%knife%' then 1 else 0 end) AS count, ROUND(sum(case when weapon_type like '%knife%' then 1 else 0 end) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) AS percentage
FROM CHData;

-- Select values from the table table to be returned
SELECT * FROM temp_table ORDER BY count DESC;