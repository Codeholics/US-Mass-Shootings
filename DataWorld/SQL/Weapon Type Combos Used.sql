SELECT COUNT(weapon_type) AS Count, Weapon_type
  FROM codeholics_mother_jones_us_mass_shootings_1982_2024
  GROUP BY weapon_type
  ORDER BY Count DESC