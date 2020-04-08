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
		global juli   1
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN"
		}
	    if $lauta {
		global rootpath "C:\Users\wb563365\GitHub\VEN"
		}
		if $trini   {
				global rootpath CAMBIAR A ONE DRIVE (VER MALE ABAJO) "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global rootpath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}

********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

// set path for dofiles
global input "$rootpath\data_management\input\04_07_20"
global merging "$rootpath\data_management\management\1. merging"
global output "$rootpath\data_management\output\merged"

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
run "$merging/Merge_Prices_JL.do"

