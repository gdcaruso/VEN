/*===========================================================================
Puropose: This script tries to replicate Colombian methodolody of pov estimation 
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
Output:			hh that belong to the reference population
				food basket for that population

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
				global rootpath "C:\Users\lauta\Documents\GitHub\VEN"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned"
global mergeddatapath "$rootpath\data_management\output\merged"
global foodcomposition "$rootpath/poverty_measurement/input/Calories.dta"
global hhrequirementsdta  "$rootpath\poverty_measurement\input\hh_requirements.dta"

global intakes "$rootpath\poverty_measurement\input\nutritional_intake_and_req.dta"
global baskets "$rootpath\poverty_measurement\input\baskets_with_nutritional_intakes.dta"
global reprensentativebasket "$rootpath\poverty_measurement\input\representative_basket.dta"
global output "$rootpath\poverty_measurement\input"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off


/*(************************************************************************************************************************************************* 
* 1: sets population of reference
*************************************************************************************************************************************************)*/

// merges with income data
use "$cleaneddatapath/base_out_nesstar_cedlas_2019.dta", replace
keep if interview_month==2
bro