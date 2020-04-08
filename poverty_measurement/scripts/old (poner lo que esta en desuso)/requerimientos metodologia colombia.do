/*===========================================================================
Puropose: This script generates caloric requirements per capita
using FAO 04 and ENCOVI poblation. This is the methodology of colombia
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
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}
		
		
// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned" // COMPLETAR temporary, replace for clean data 
global mergeddatapath "$rootpath\data_management\output\merged" // COMPLETAR temporary, replace for clean data 
global inputpath "$rootpath\poverty_measurement\input" // 

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

// set paths to dta
global productdta "$cleaneddatapath\product-hh.dta"



/*==============================================================================
1: merge of individual data and requirements
==============================================================================*/

// transforms xlsx with nutritional requirements to dta
import excel "$inputpath/requerimientos_caloricos_2012.xlsx", first
save "$inputpath/requirements_col.dta", replace

// merge individual data with requirements
use "$cleaneddatapath/ENCOVI_2019.dta", replace


merge m:1 hombre edad using "$inputpath/requirements_col.dta"
keep if _merge==3
drop _merge
gen miembro=1

// collapses requirements by household
collapse (sum) req_cal_col miembro
global req = req_cal_col/miembro

display $req








