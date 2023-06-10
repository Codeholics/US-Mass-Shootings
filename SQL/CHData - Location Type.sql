SELECT 
  location_2, 
  count(1) as Count,
  ROUND(count(1) * 100.0 / SUM(count(1)) OVER (), 2) as Percentage
FROM CHData
GROUP BY location_2
ORDER BY COUNT DESC;