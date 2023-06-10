SELECT 
location_2, 
count(1) as Count FROM CHData
GROUP BY location_2
ORDER BY COUNT DESC