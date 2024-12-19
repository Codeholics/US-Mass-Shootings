SELECT 
  location, 
  count(1) as Shootings, 
  sum(TOTAL_VICTIMS) as Victims, 
  sum(TOTAL_VICTIMS)/count(1) as VictimsPerShooting,
  ROUND(count(1) * 100.0 / (SELECT COUNT(*) FROM CHData), 2) as ShootingPercentage
FROM CHData
GROUP BY location
ORDER BY Shootings DESC;