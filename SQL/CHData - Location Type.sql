SELECT 
  location_2, 
  count(1) as Count,
  ROUND(count(1) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) as Percentage
FROM CHData
GROUP BY location_2
ORDER BY COUNT DESC;