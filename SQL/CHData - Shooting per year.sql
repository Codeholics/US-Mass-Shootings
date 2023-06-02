SELECT DISTINCT year,Count(year) ,
sum(TOTAL_VICTIMS) AS Victims,
sum(TOTAL_VICTIMS)/count(1) AS VictimsPerShooting

FROM CHData
GROUP BY year
ORDER BY count desc