/*===========================================================================
Puropose: This script takes prices and baskets and calculates basket's value

===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		31th march, 2020
Modification Date:  
Output:			dta with baskets values and indexes

Note: 
=============================================================================*/
********************************************************************************


// // Define rootpath according to user
//
// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
//		
// 		* User 3: Lautaro
// 		global lauta   1
//		
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath ""
// 		}
//
// 	    if $lauta {
// 				global rootpath "C:\Users\wb563365\GitHub\VEN"
// 		}
//
// // set raw data path
// global cleaned "$rootpath\data_management\output\cleaned"
// global merged "$rootpath\data_management\output\merged"
// global input  "$rootpath\poverty_measurement\input"
// global output "$rootpath\poverty_measurement\output"


*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

/*(************************************************************************************************************************************************* 
* 1: basket value by month (at national level)
*************************************************************************************************************************************************)*/

// import prices (REPLACE WITH IMPLICIT PRICES!!!!!!!)
use "$output/precios_implicitos.dta", replace


// impor quantities
merge m:1 bien using "$output/canasta_diaria.dta"
drop _merge



// generate value of each products
gen valor = pimp * cantidad_ajustada


export excel "$output/costo_canasta_diaria.xlsx", firstrow(variables) replace
save "$output/costo_canasta_diaria.dta", replace

