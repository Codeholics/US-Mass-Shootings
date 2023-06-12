SELECT COUNT(weapon_type) AS Count, Weapon_type,
100.0 * COUNT(weapon_type) / (SELECT COUNT(DISTINCT weapon_type) FROM CHData) AS Percentage
FROM CHData
GROUP BY weapon_type
ORDER BY Count DESC