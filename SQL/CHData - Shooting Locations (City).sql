SELECT location
, count(1) as Shootings
, sum(TOTAL_VICTIMS) as Victims
, sum(TOTAL_VICTIMS)/count(1) as VictimsPerShooting 

FROM CHData
GROUP BY location
ORDER BY Shootings DESC