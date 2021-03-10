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
	A. Oxfort/UNDP
===============================================================================*/



/*==============================================================================
1. Poverty Dimensions
===============================================================================*/

***Health sub-dimension 
g health_dimension = 0.5*foodsec_hh + 0.5*child_death_hh
tab health_dimension [fw=pondera]

***Educational dimension 
g educ_dimension = 0.5*schooling_deprived + 0.5*anychild_noschool
tab educ_dimension [fw=pondera]

***Living standards dimension 
g livingstandards_dimension = 1/6*solid_fuel_hh + 1/6*no_flush_toilet_hh + 1/6*nosave_drinkingwater_hh + 1/6*no_electricity_hh + ///
1/6*inadequate_housing_hh + 1/6*assets_poverty_hh
tab livingstandards_dimension [fw=pondera]


/*==============================================================================
2. Multidimensional Poverty
===============================================================================*/

***Overall index
g multi_dimension = 1/3*health_dimension + 1/3*educ_dimension + 1/3*livingstandards_dimension
tab multi_dimension [fw=pondera]

***Poor if deprived in at least 1/3 of the weighted dimensions 
g multi_poor = (multi_dimension>1/3) if !missing(multi_dimension)
tab multi_poor [fw=pondera]



/*==============================================================================
3. summary Table 
===============================================================================*/

label var foodsec_hh "Food insecurity"
label var child_death_hh "Household with child death"
label var schooling_deprived "No household member more than 6 years of educ."
label var anychild_noschool "Any child not attending school (6-14 years)"
label var solid_fuel_hh "Cooking with solid fuel"
label var no_flush_toilet_hh "No connected private flush toilet"
label var nosave_drinkingwater_hh "No save drinking water access"
label var no_electricity_hh "No electricity or daily electricity breaks"
label var inadequate_housing_hh "Inadequate housing"
label var assets_poverty_hh "Asset poverty" 
label var health_dimension "Health subindicator"
label var educ_dimension "Educational subindicator"
label var livingstandards_dimension "Living Standards subindicator"
label var multi_poor "Multidimensional Poverty Indicator" 

local indicators foodsec_hh child_death_hh schooling_deprived anychild_noschool ///
solid_fuel_hh no_flush_toilet_hh nosave_drinkingwater_hh no_electricity_hh ///
inadequate_housing_hh assets_poverty_hh

local dimensions health_dimension educ_dimension livingstandards_dimension


foreach x in `indicators'{
	replace `x' = `x'*100
}

foreach x in `dimensions'{
	replace `x' = `x'*100
}

replace multi_poor = multi_poor*100

*Summary table 
estpost sum `indicators' `dimensions' multi_poor [fw=pondera],d
esttab using "$tables\multidimensional_poverty.csv", cells((mean(fmt(%9.1f) label(Mean)) sd(par fmt(%9.1f) label(St.Dev.)) p50(par fmt(%9.1f) label(Median)))) ///
label nonumber noobs ///
title(Descriptive statistic of multidimensional poverty) replace 




/*==============================================================================
	B. World Bank 
===============================================================================*/


/*==============================================================================
1. Poverty Dimensions
===============================================================================*/

***Educational dimension 
g educ_dimension = 0.5*schooling_deprived + 0.5*anychild_noschool
tab educ_dimension [fw=pondera]

***Infra access dimension 
g access_infra = 1/3*no_flush_toilet_hh + 1/3*nosave_drinkingwater_hh + 1/3*no_electricity_hh
tab access_infra [fw=pondera]

***Income dimension 
replace pobre_extremo = pobre_extremo*100
tab pobre_extremo [fw=pondera]


/*==============================================================================
2. Multidimensional Poverty
===============================================================================*/

***Overall index
g multi_dimension_wb = 1/3*access_infra + 1/3*educ_dimension + 1/3*pobre_extremo
tab multi_dimension_wb [fw=pondera]

***Poor if deprived in at least 1/3 of the weighted dimensions 
g multi_poor_wb = (multi_dimension_wb>(1/3*100)) if !missing(multi_dimension_wb)
tab multi_poor_wb [fw=pondera] //65.11 percent 

replace multi_poor_wb = multi_poor_wb*100

*Summary table 

label var multi_poor_wb "Multidimensional Poverty Indicator"
label var access_infra "Access to infrastructure"

local dimensions access_infra educ_dimension pobre_extremo

estpost sum `dimensions' multi_poor_wb [fw=pondera],d
esttab using "$tables\multidimensional_poverty_wb.csv", cells((mean(fmt(%9.1f) label(Mean)) sd(par fmt(%9.1f) label(St.Dev.)) p50(par fmt(%9.1f) label(Median)))) ///
label nonumber noobs ///
title(Descriptive statistic of multidimensional poverty) replace 























