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
/*
 	    * User 1: Trini
 		global trini 0
		
 		* User 2: Julieta
 		global juli   0
		
 		* User 3: Lautaro
 		global lauta  0
		
 		* User 4: Malena
 		global male   1
			
		if $juli {
				global dopath "C:\Users\wb563583\GitHub\VEN"
				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\DataEncovi\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global dopath "C:\Users\wb550905\Github\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
				global outSEDLAC "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_SEDLAC_DATA_2014_2019\"
				global outENCOVI "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018\"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}		

// set path for dofiles
global input "$datapath\data_management\input\latest"
global merging "$dopath\data_management\management\1. merging"
global merged "$datapath\data_management\output\merged"

*/

********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

/*==============================================================================
Construction of aproved surveys
==============================================================================*/

//merge individual datasets
run "$merging/individual_append_n_merge.do"

//merge hh datasets
run "$merging/Merge_Hogares_JL.do"

//ad-hoc edits
run "$merging/adhoc_edit.do"

//merge products datasets
run "$merging/products_append_n_merge.do"

//merge prices datasets
// run "$merging/Merge_Prices_JL.do" // We are using implicit prices in the final database

//homogenize units for consumtions
run "$merging/consumption_units_homogenization.do"

