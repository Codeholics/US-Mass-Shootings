SELECT 
location_2, 
count(1) FROM CHData
GROUP BY location_2
ORDER BY COUNT DESC