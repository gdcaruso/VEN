/*===========================================================================
Puropose: Generate a log file with freq. distribution of food consumption
per unit of measurement to detect possible misreportings
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		21th Feb, 2020
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
				global rootpath "C:\Users\wb563365\OneDrive - WBG\Documents\GitHub\VEN\"
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
use  "$productdta", clear
drop if grupo_bien != 1

/*==============================================================================
1: Freq distribution of food consumption
==============================================================================*/
log using "$rootpath\data_management\management\3. cleaning\consumed_quantities_frequencies_wsize", text replace

//levels of foods
qui levelsof bien, local(foodlist)
local fname: value label bien


// loop over foods
foreach f of local foodlist {

	display "ooooooooooooooooooooooooooooooooooooooooooooooooo"
	display "ooooooooooooooooooooooooooooooooooooooooooooooooo"
	display "ooooooooooooooooooooooooooooooooooooooooooooooooo"

	//label of each food
	local vf: label `fname' `f'

	//if the food is NOT classified as Other
	if "`vf'" != "Otro (especifique)"{
		
		//levels of units
		qui levelsof unidad_medida if bien ==`f', local(units)
		local uname: value label unidad_medida
		
		
		//loop over units
		foreach u of local units {
			display "-------------"
			display "-------------"
			local vu: label `uname' `u'
			//levels of sizes
			qui levelsof tamano if bien ==`f' & unidad_medida==`u' , local(tamanos)
			local tname: value label tamano
			local tcounts : list sizeof tamanos
			
			
			// if there is no size option
			if `tcounts' == 0{
				display "#######"
				display "food = `vf' (`f')"
				display "unit = `vu' (`u')"	 
				display "size = no size"
				tab cantidad if (bien ==`f'& unidad_medida==`u'), mi
			} //ends condition on no size option
			
			
			//if there IS size option
			else {
				//loops over sizes
				foreach t of local tamanos {
					local vt: label `tname' `t'
					display "#######"
					display "food = `vf' (`f')"
					display "unit = `vu' (`u')"	 
					display "size = `vt' (`t')"	 
					tab cantidad if (bien ==`f' & unidad_medida==`u' & tamano==`t'), mi
				} //ends looping over sives
			} //ends condition on size option
		} //ends looping over units
	} //ends conditioning on food as NO other
		
		
		
		
	// if the food IS classified as Other
	else {
		qui levelsof otros_alimentos if bien ==`f', local(listotrosalimentos)
		
		//loops over other foods
		foreach otro in $listotrosalimentos {
		
			//levels of units
			qui levelsof unidad_medida if bien == `f' & otros_alimentos ==`otro', local(units)
			local uname: value label unidad_medida
			
			
			//loop over units
			foreach u of local units {
				display "-------------"
				display "-------------"
				local vu: label `uname' `u'
				//levels of sizes
				qui levelsof tamano if bien == `f' & otros_alimentos ==`otro' & unidad_medida==`u' , local(tamanos)
				local tname: value label tamano
				local tcounts : list sizeof tamanos
				
				
				// if there is no size option
				if `tcounts' == 0{
					display "#######"
					display "food = `vf' (`f')"
					display "`otro'"
					display "unit = `vu' (`u')"	 
					display "size = no size"
					tab cantidad if (bien == `f' & otros_alimentos ==`otro' & unidad_medida==`u'), mi
				} //ends condition on no size option
				
				
				//if there IS size option
				else {
					//loops over sizes
					foreach t of local tamanos {
						local vt: label `tname' `t'
						display "#######"
						display "food = `vf' (`f')"
						display "unit = `vu' (`u')"	 
						display "size = `vt' (`t')"	 
						tab cantidad if (bien == `f' & otros_alimentos ==`otro' & unidad_medida==`u' & tamano==`t'), mi
					} //ends loop over sizes
				} //ends condition on size option
			} //end loop over units
		} //ends loop over other foods
	} // ends conditioning on food as Other

} //ends the loop over foods


log close
