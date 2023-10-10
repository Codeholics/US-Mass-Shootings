DROP TABLE IF EXISTS temp_table;
CREATE TEMPORARY TABLE temp_table AS
SELECT * FROM CHData 
WHERE summary LIKE '%military%' 
OR summary LIKE '%retired sergeant%' 
OR summary LIKE '%ex-US Air Force%' 
OR summary LIKE '%former Marine%' 
OR summary LIKE '%Army veteran%' 
OR summary LIKE '%Army Specialist' 
OR summary LIKE '%veteran of the Virginia Army%'
OR summary LIKE '%Off-duty sheriff''s deputy%'
OR summary LIKE '%Army psychiatrist%'
OR summary LIKE '%three-year stint in the US Army%';

SELECT CH.*, 
  CASE WHEN T.summary IS NOT NULL THEN 'Y' ELSE 'N' END AS trained
FROM CHData AS CH
LEFT JOIN temp_table AS T
ON CH.summary = T.summary;

--DROP TABLE temp_table;
--SELECT * FROM temp_table;