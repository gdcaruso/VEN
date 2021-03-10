/*===========================================================================
Country name:	Venezuela
Year:			2021
Survey:			ENCOVI 2019/20

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the different sections of the RPBA Venezuela 
Output:			    Multidimensional Poverty Index


=============================================================================*/
********************************************************************************


/*==============================================================================
1. Health 
===============================================================================*/


***Nutrition
*If one of the below is 1, then deprived 
gen foodsec = salteacomida_norecursos + salteacomida_me18_norecursos + comepoco_norecursos + comepoco_me18_norecursos + ///
hambre_norecursos + nocomedia_norecursos + nocomedia_me18_norecursos + preocucomida_norecursos + faltacomida_norecursos + ///
nosaludable_norecursos + pocovariado_norecursos + pocovariado_me18_norecursos

bysort id: egen foodsec_hh = sum(foodsec)
tab foodsec_hh

*If at least one of the above is 1, then deprived in nutrition 
recode foodsec_hh (1/192 = 1) if !missing(foodsec_hh) 
tab foodsec_hh [fw=pondera]



***Child mortality 
tab hijos_nacidos_vivos
replace hijos_nacidos_vivos = . if hijos_nacidos_vivos>13 //possible outliers 

gen child_death = hijos_vivos - hijos_nacidos_vivos
tab child_death

bysort id: egen child_death_hh = sum(child_death)
tab child_death_hh

recode child_death_hh (-13/-1 = 1)
tab child_death_hh [fw=pondera]



/*==============================================================================
2. Education
===============================================================================*/

***No household member with the right age has more than 6 years of schooling 
g 				educyears = 0 if nivel_educ_en < 3
replace 		educyears = g_educ if nivel_educ_en == 3 
replace 		educyears = 9 + g_educ if nivel_educ_en == 4
replace 		educyears = g_educ if nivel_educ_en == 5
replace 		educyears = 6 + g_educ if nivel_educ_en == 6
replace 		educyears = 12 + a_educ if nivel_educ_en == 7
replace 		educyears = floor(12 + s_educ*0.5) if nivel_educ_en == 8
replace 		educyears = 19 if nivel_educ_en == 9

replace			educyears = 0 if educyears == . & nivel_educ_en == .
replace			educyears = 6 if educyears == . & nivel_educ_en ==3
replace			educyears = 12 if educyears == . & nivel_educ_en == 5
replace			educyears = 12 if educyears == . & nivel_educ_en == 6
replace			educyears = 15 if educyears == . & nivel_educ_en == 7
replace			educyears = 17 if educyears == . & nivel_educ_en == 8

*identify the ones with more than 6 years of education and eligible age group 
g educyears_higher6 = (educyears>6 & edad>10) 
replace educyears_higher6 = . if edad<=10
tab educyears_higher6, m

*identify households with no members with more than 6 years of education 
by id: egen schooling_deprived_hh = sum(educyears_higher6)
gen schooling_deprived = (schooling_deprived_hh==0) if !missing(schooling_deprived_hh)
tab schooling_deprived [fw=pondera]

***Children not attending school 
g noschool = (asiste == 0 & edad>=6 & edad <15) if !missing(asiste, edad) //rest is 0 - if hh has no kid in this age: not deprived 
tab noschool [fw=pondera]

*Is there any child in the household not attending school? 
by id: egen anychild_noschool = sum(noschool)
tab anychild_noschool [fw=pondera]

recode anychild_noschool (1/8 = 1) //If at least one child does not attend school = deprived 
tab anychild_noschool [fw=pondera] 



/*==============================================================================
3. Living Standards
===============================================================================*/


***A household is deprived if it uses solid fuel 
tab comb_cocina if relacion_en==1, m //all household heads answer (no missing values at hh-head level)

tab comb_cocina
gen solid_fuel = (comb_cocina>3 & comb_cocina<6)
tab solid_fuel [fw=pondera]

bysort id: egen solid_fuel_hh = max(solid_fuel) //no gas and no electricity for cooking
tab solid_fuel_hh

***Flush toilet
tab tipo_sanitario if relacion_en==1, m //2 household heads have missing information, are treated as nonmissing here 
tab tipo_sanitario [fw=pondera]
gen no_flush_toilet = (tipo_sanitario>2 | banio_con_ducha==0) if !missing(tipo_sanitario, banio_con_ducha)
replace no_flush_toilet = 1 if comparte_gasto_viv==0
tab no_flush_toilet [fw=pondera]
 
bysort id: egen no_flush_toilet_hh = max(no_flush_toilet) //no connected flush toilet 
tab no_flush_toilet_hh [fw=pondera]


***Save access to drinking water 
gen nosave_drinkingwater = (fagua_cisterna==1 | fagua_estanq==1 | fagua_manantial==1 | tratamiento_agua==1) ///
if !missing(fagua_cisterna, fagua_estanq, fagua_manantial, tratamiento_agua)
tab nosave_drinkingwater [fw=pondera]

bysort id: egen nosave_drinkingwater_hh = max(nosave_drinkingwater)
tab nosave_drinkingwater_hh [fw=pondera]


***No electricity
tab electricidad if relacion_en==1, m //all household heads answer (no missing values at hh-head level)
tab interrumpe_elect if relacion_en==1, m //90 report missing, but not important as only consider answer 1
gen no_electricity = (electricidad==0 | interrumpe_elect==1) if !missing(electricidad, interrumpe_elect)
tab no_electricity [fw=pondera] 
 
bysort id: egen no_electricity_hh = max(no_electricity) 
tab no_electricity_hh [fw=pondera]


***Housing material 
tab material_piso if relacion_en==1, m //no missing 
gen inadequate_housing = (material_piso>2 | material_pared_exterior>6 | material_techo>3) ///
if !missing(material_piso, material_pared_exterior, material_techo)
tab inadequate_housing [fw=pondera]

bysort id: egen inadequate_housing_hh = max(inadequate_housing)
tab inadequate_housing_hh [fw=pondera]


***Assets 
gen ownership = heladera + lavarropas + secadora + computadora + internet + televisor + radio + calentador ///
+ aire + tv_cable + microondas + telefono_fijo + auto
tab ownership 

gen assets_poverty = (ownership<=1) if !missing(ownership)
tab assets_poverty [fw=pondera]

bysort id: egen assets_poverty_hh = max(assets_poverty)
tab assets_poverty_hh [fw=pondera]















