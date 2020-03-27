/*===========================================================================
Puropose: this scripts takes raw data of the 2019 ENCOVY survey at individual
level and integrates into a unique dataset at individual level
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		12th Feb, 2020
Modification Date:  
Output:			sedlac do-file template

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
		
		* User 3: Lautaro
		global lautaa   0
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\Documents\GitHub\VEN"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lautaa {
				global rootpath "C:\Users\wb563365\GitHub\VEN\"
		}
	
		if $trini   {
				global rootpath ""
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN\"
		}

// set raw data path
global dataofficial "$rootpath\data_management\input\03_26_20"

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off



/*==============================================================================
1: Construction of aproved surveys
==============================================================================*/
// There are different "actions" during the data collection of a survey such as
// first data input, completed, approved by supervisor, approved by HQ, rejected
// We will keep only the approved by HQ


/*==============================================================================
1: Construction of aproved surveys
==============================================================================*/
// There are different "actions" during the data collection of a survey such as
// first data input, completed, approved by supervisor, approved by HQ, rejected
// We will keep only the approved by HQ

// set the path for our 3 types of questionaires
global pathnew "$dataofficial\ENCOVI_3_STATA_All"
global pathold "$dataofficial\ENCOVI_MainSurvey_Final_3_STATA_All"
global pathpixel "$dataofficial\ENCOVI_pixel_Qx_9_STATA_All"

// load and append data of the 3 questionaires
use  "$pathold\interview__actions.dta", clear
gen quest=1

append using "$pathnew\interview__actions.dta"
replace quest=2 if quest==. & quest!=1

append using "$pathpixel\interview__actions.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

	// To identify unique interviews according the last date and time entered
    bys interview__key interview__id (date time) : keep if _n==_N
	
	// Check duplicates 
	duplicates report interview__key interview__id 
	duplicates report interview__key interview__id date time

//preserve
//keep if dupli >= 1
//save "$rootpath\data_management\output\merged\duplicates-ind.dta", replace
//restore	
//drop if dupli >= 1

keep interview* origina responsible__name quest date


// formatting
keep interview__key interview__id quest date
replace date = subinstr(date, "-", "/",.)
gen approved_date=date(date,"YMD")
format approved_date %td
drop date


// test if is id
isid interview__key interview__id quest


	// save temporary db with surveys approved (means unique id and time for each interview)
	tempfile approved_surveys
	save `approved_surveys'


/*(************************************************************************************************************************************************* 
* 2: Append & Merge of individual questionaries
*************************************************************************************************************************************************)*/
// Main individual level dataset (Miembro.dta)

// Append main indiviudal dataset across questionnaires

use  "$pathold\Miembro.dta", clear
gen quest=1

append using "$pathnew\Miembro.dta"
replace quest=2 if quest==.

append using "$pathpixel\Miembro.dta"
replace quest=3 if quest==.


// Keep only approved surveys
merge m:1 interview__id interview__key quest using `approved_surveys'
keep if _merge==3
drop _merge

// Merge other individual level datasets to the main (Miembro.dta)
// But previously, we have to change sub-indiviudal level datasets to individual level
// by reshaping datasets to a wide shape.
// example:
// pre-reshape subindividual level dataset
// individual | concept | amount
// 1          | toast   | 10
// 1          | butter  | 12

// after-reshape individual level dataset
// individual | amount_toast | amount_butter |
// 1          | 10           | 20
// now we can merge with other individual level datasets

// list subindividual level datasets
global dtalist s7q10 s9q19_monto s9q20_monto s9q21_monto s9q22_monto s9q28_monto s9q29_monto

//sets the loop
foreach dtafile in $dtalist{

	preserve // the main individual level dataset

	// append the 3 types of questionnaires of this sub-individual level dataset
	use  "$pathold/`dtafile'.dta", clear
	gen quest=1

	append using "$pathnew/`dtafile'.dta"
	replace quest=2 if quest==.

	append using "$pathpixel/`dtafile'.dta"
	replace quest=3 if quest==.


	// merge to keep only approved surveys
	merge m:1 interview__id interview__key quest using `approved_surveys'
	keep if _merge==3
	drop _merge

	//eliminate useless data
	cap drop edate

	// pre formatting to reshape
	rename s?q??? s?q???_

	// to-wide transformation in move from sub-individual to individual level
	// 2 key facts of the data for the loop
	// All identifiers end with id.
	// All subindividual varibles are of the form s?q??_

	reshape wide s?q???_, i(interview__id Miembro__id) j(`dtafile'~id)
	tempfile tempdta
	save `tempdta'

	restore // the main individual dataset

	// merges the main individual dataset to the reshaped individual data
	merge 1:1 interview__id interview__key quest Miembro__id using `tempdta'
	drop _merge
}

// Define labels for each type of questionnaire 
	label define quest_label 1 "Tradicional - Viejo" ///
	2 "Tradicional - Nuevo" ///
	3 "Remoto"
	
	*Incorporate the values labels to the variable 		  
	label values quest quest_label

compress
	
save "$rootpath\data_management\output\merged\individual(telefonos).dta", replace
