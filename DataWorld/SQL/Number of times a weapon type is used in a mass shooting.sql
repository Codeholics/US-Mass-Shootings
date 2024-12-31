SELECT 
sum(case when weapon_type like '%Semiautomatic handgun%' then 1 else 0 end) as semiautomatic_handgun,
sum(case when weapon_type like '%semiautomatic rifle%' then 1 else 0 end) as semiautomatic_rifle,
sum(case when weapon_type like '%shotgun%' then 1 else 0 end) as shotgun,
sum(case when weapon_type like '%revolver%' then 1 else 0 end) as revolver,
sum(case when weapon_type like '%derringer%' then 1 else 0 end) as derringer,
sum(case when weapon_type like '%knife%' then 1 else 0 end) as knife
from codeholics_mother_jones_us_mass_shootings_1982_2024