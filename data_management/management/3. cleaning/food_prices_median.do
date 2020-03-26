/*===========================================================================
Puropose: Take the clean price dataset and generate a median price for each month
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		27th Feb, 2020
Modification Date:  
Output:			household dataset with caloric (and protein) requirements

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 3: Lautaro
		global lauta2   1
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}
		
		
// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned" // COMPLETAR temporary, replace for clean data 
global mergeddatapath "$rootpath\data_management\output\merged" // COMPLETAR temporary, replace for clean data 
global inputpath "$rootpath\poverty_measurement\input" // 

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

// set paths to dta
global productdta "$cleaneddatapath\product-hh.dta"
global householddta  "$mergeddatapath\household.dta"
global individualdta  "$mergeddatapath\individual.dta"



/*==============================================================================
Take cleaned price data and generate time series
==============================================================================*/

use "$cleaneddatapath/Price_database_complete.dta", replace
drop precio
rename precio_u precio

preserve
collapse (median) precio, by(bien mes)
save "$cleaneddatapath/food_prices_per_month.dta", replace
restore


collapse (median) precio, by(bien mes ENTIDAD)
save "$cleaneddatapath/food_prices_per_month_entidad.dta", replace