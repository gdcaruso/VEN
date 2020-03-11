/*===========================================================================
Puropose: Generate a log file with freq. distribution of prices of 
products with different measurement units. It aim to detect misreportings
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Julieta Ladronis based on Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		2nd Mar, 2020
Modification Date:  
Output:	 log file of tabulated frequencies of food consumption
Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   1
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta {
				global rootpath ""
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
drop if grupo_bien != 1

/*==============================================================================
1: Freq distribution of food consumption
==============================================================================*/
log using "$rootpath\data_management\management\3. cleaning\consumed_quantities_frequencies_wsize", text replace


qui levelsof bien, local(foodlist)
local fname: value label bien

foreach f of local foodlist {

	display "ooooooooooooooooooooooooooooooooooooooooooooooooo"
	display "ooooooooooooooooooooooooooooooooooooooooooooooooo"
	display "ooooooooooooooooooooooooooooooooooooooooooooooooo"

	local vf: label `fname' `f'

	qui levelsof unidad_medida if bien ==`f', local(units)
	local uname: value label unidad_medida

	foreach u of local units {
		display "-------------"
		display "-------------"

		local vu: label `uname' `u'

		qui levelsof tamano if bien ==`f' & unidad_medida==`u' , local(tamanos)
		local tname: value label tamano
		local tcounts : list sizeof tamanos
		
		if `tcounts' == 0 {
			display "food = `vf' (`f')"
			display "unit = `vu' (`u')"	 
			display "size = no size"
			
			if "`vf'" == "Otro (especifique)"{
 				tab cantidad otros_alimento if (bien ==`f'& unidad_medida==`u'), mi
			}

			else{
				tab cantidad if (bien ==`f'& unidad_medida==`u'), mi		
			}
			}
		
		else {
		foreach t of local tamanos {

			local vt: label `tname' `t'
	
			display "food = `vf' (`f')"
			display "unit = `vu' (`u')"	 
			display "size = `vt' (`t')"	 
			
			if "`vf'" == "Otro (especifique)"{
 				tab cantidad otros_alimento if (bien ==`f'& unidad_medida==`u' & tamano==`t'), mi
			}

			else{
				tab cantidad if (bien ==`f'& unidad_medida==`u' & tamano==`t'), mi		
			}
		}
		}
	}


	 
}

log close
