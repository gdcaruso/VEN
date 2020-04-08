/*===========================================================================
Puropose: This script generates a dataset with caloric
(and protein?) requirements per hh
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
		global lauta   1
		
		* User 3: Lautaro
		global lauta2   0
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\Desktop\ENCOVI-2019"
		}
		
		
// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned" // COMPLETAR temporary, replace for clean data 
global mergeddatapath "$rootpath\data_management\output\merged" // COMPLETAR temporary, replace for clean data 

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
global requirementsxls  "$rootpath\poverty_measurement\input\requerimientos_caloricos_2012.xlsx"
global requirementsdta  "$rootpath\poverty_measurement\input\nutrition_requirements_2012.dta"
global output  "$rootpath\poverty_measurement\input\"


/*==============================================================================
1: merge of individual data and requirements
==============================================================================*/

// transforms xlsx with nutritional requirements to dta
import excel $requirementsxls, first
save $requirementsdta, replace

// merge individual data with requirements
use $individualdta, replace
rename (s6q3 s6q5) (hombre edad) //CAMBIAR CUANDO USE DATA CLEAN
replace hombre=0 if hombre==2 //CAMBIAR CUANDO USE DATA CLEAN

merge m:1 hombre edad using $requirementsdta
keep if _merge==3
drop _merge
gen miembro=1

// collapses requirements by household
collapse (sum) req_cal_col req_prot_ven he_cal_col he_prot_ven miembro, by(interview__key interview__id quest)
sort interview__key interview__id quest


// save dta
compress
save "$output/requerimets_col.dta", replace








