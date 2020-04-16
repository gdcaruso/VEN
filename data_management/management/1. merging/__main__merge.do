/*===========================================================================
Puropose: Main .do that merges all raw datasets
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		7th April, 2020
Modification Date:  
Output:			

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
				global rootpath "C:\Users\wb563583\GitHub\VEN"
		}
	    if $lauta {
		global dopath "C:\Users\wb563365\GitHub\VEN"
		global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global rootpath "C:\Users\wb550905\GitHub\VEN"
		}

********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

// set path for dofiles
global input "$datapath\data_management\input\latest"
global merging "$dopath\data_management\management\1. merging"
global output "$datapath\data_management\output\merged"


/*==============================================================================
Construction of aproved surveys
==============================================================================*/

//merge individual datasets
run "$merging/individual_append_n_merge.do"
//merge hh datasets
run "$merging/Merge_Hogares_JL.do"
//merge products datasets
run "$merging/products_append_n_merge.do"
//merge prices datasets
// run "$merging/Merge_Prices_JL.do"
//homogenize units for consumtions
run "$merging/consumption_units_homogenization.do"

