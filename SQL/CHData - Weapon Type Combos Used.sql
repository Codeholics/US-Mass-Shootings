SELECT COUNT(weapon_type) AS Count, Weapon_type
  FROM CHData
  GROUP BY weapon_type
  ORDER BY Count DESC