/*===========================================================================
Puropose: Generate a dta at product-measure-size level, collapsing household
dimension
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		26th Feb, 2020
Modification Date:  
Output:	 log file of tabulated frequencies of food consumption
Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   1
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
		if $trini   {
				global rootpath ""
		}
		
		if $male   {
				global rootpath ""
		}

// set raw data path
// temporary, to be replaced for clean data path COMPLETAR
global datapath "$rootpath\data_management\output\merged" 
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

// product-data setting
global productdta "$datapath\product-hh.dta"
use  $productdta, clear
keep if grupo_bien == 1

collapse (sum) cantidad, by (bien unidad_medida tamano otros_alimentos)
drop if cantidad == 0

save "$rootpath\data_management\management\3. cleaning\product-unit.dta", replace
