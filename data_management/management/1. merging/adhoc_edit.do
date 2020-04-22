/*===========================================================================
Detected and corrected missinputed data
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		22th April, 2020
Modification Date:  
Output:			products.dta

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta  1
//		
//
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath ""
// 		}
// 	    if $lauta {
// 				global rootpath "C:\Users\wb563365\GitHub\VEN\"
//
// 		}
// 		if $trini   {
// 				global rootpath ""
// 		}
//		
// 		if $male   {
// 				global rootpath ""
// 		}
//
// // // set raw data path
// global input "$datapath\data_management\input\latest"
// global output "$datapath\data_management\output"

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

/*==============================================================================
1: replace data
==============================================================================*/

use "$merged/individual.dta"

/*==============================================================================
1: Domestic service
==============================================================================*/

// domestic service reported: 5 years, shares last name with hh jefe & esposa, no income. Replaced for son/daughter

replace s6q2=3 if s6q2 == 13 & interview__key == "27-27-71-43" 

// domestic service reported: 50 years with hh jefa of 46 years. He has same income as hh jefa. Sector retail, housing, general services etc. the couple shares last name. Replaced for husband. No other at this home.

replace s6q2=2 if s6q2 == 13 & interview__key == "19-22-71-57"

// Domestic service reported: 15 years, male, same last name as the family. Student. Replaced for nephew.

replace s6q2=5 if s6q2 == 13 & interview__key == "16-09-80-35"

/*==============================================================================
1: replace data
==============================================================================*/


save "$merged/individual.dta", replace




 
