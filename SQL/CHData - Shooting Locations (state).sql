SELECT state, count(1) as Shootings, sum(TOTAL_VICTIMS) as Victims, sum(TOTAL_VICTIMS)/count(1) as VictimsPerShooting,
100.0 * count(1) / (SELECT count(1) FROM CHData) as ShootingsPercentage
FROM CHData
GROUP BY state
ORDER BY Shootings DESC