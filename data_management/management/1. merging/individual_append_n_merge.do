/*===========================================================================
Puropose: Merge and append raw data to make a dataset at individual level
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

//  	    * User 1: Trini
//  		global trini 0
//		
//  		* User 2: Julieta
//  		global juli   0
//		
//  		* User 3: Lautaro
//  		global lauta  0
//		
//  		* User 4: Malena
//  		global male   1
//			
//  		if $juli {
//  				global dopath "C:\Users\wb563583\GitHub\VEN"
//  				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
//  		}
//  	    if $lauta {
//  				global dopath "C:\Users\wb563365\GitHub\VEN"
//  				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
//  		}
//  		if $trini   {
//  				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
//  		}
//  		if $male   {
//  				global dopath "C:\Users\wb550905\Github\VEN"
//  				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
//  }		

// set path for dofiles
global input "$datapath\data_management\input\latest"
global merging "$dopath\data_management\management\1. merging"
global output "$datapath\data_management\output\merged"

********************************************************************************

/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off


/*==============================================================================
Construction of approved surveys
==============================================================================*/
// There are different "actions" during the data collection of a survey such as
// first data input, completed, approved by supervisor, approved by HQ, rejected
// We will keep only the approved by HQ.

// set the path for our 3 types of questionaires
global new "$input\ENCOVI_3_STATA_All"
global old "$input\ENCOVI_MainSurvey_Final_3_STATA_All"
global pixel "$input\ENCOVI_pixel_Qx_9_STATA_All"

// load and append data of the 3 questionaires
use  "$old\interview__actions.dta", clear
gen quest=1

append using "$new\interview__actions.dta"
replace quest=2 if quest==. & quest!=1

append using "$pixel\interview__actions.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// Keep aproved interviews by HQ
sort quest interview__key interview__id date time, stable
by quest interview__key interview__id: keep if action[_N]==6 // approved by HQ (as last step)

// To identify unique interviews according the last date and time entered
sort quest interview__key interview__id date time, stable
by quest interview__key interview__id: keep if _n==_N

//check, log and delete duplicates
duplicates tag interview__key interview__id quest, generate(dupli)


//drop duplicates, (but saved in a log)
preserve
keep if dupli >= 1
save "$output\duplicates-ind.dta", replace
restore	
drop if dupli >= 1

// formatting
keep interview__key interview__id quest date
replace date = subinstr(date, "-", "/",.)
gen approved_date=date(date,"YMD")
format approved_date %td
drop date

// test if is id
isid interview__key interview__id quest

// save temporary db with surveys approved
tempfile approved_surveys
save `approved_surveys'


/*(************************************************************************************************************************************************* 
* 2: Append & Merge of individual questionaries
*************************************************************************************************************************************************)*/
// Main individual level dataset (Miembro.dta)

// Append main indiviudal dataset across questionnaires

use  "$old\Miembro.dta", clear
gen quest=1

append using "$new\Miembro.dta"
replace quest=2 if quest==. & quest!=1

append using "$pixel\Miembro.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2


// Keep only approved surveys
merge m:1 interview__id interview__key quest using `approved_surveys'
keep if _merge==3
drop _merge



// list subindividual level datasets
global dtalist s7q10 s9q19_monto s9q20_monto s9q21_monto s9q22_monto s9q28_monto s9q29_monto

//sets the loop
foreach dtafile in $dtalist {

	preserve // the main individual level dataset

	// append the 3 types of questionnaires of this sub-individual level dataset
	use  "$old/`dtafile'.dta", clear
	gen quest=1

	append using "$new/`dtafile'.dta"
	replace quest=2 if quest==. & quest!=1

	append using "$pixel/`dtafile'.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2


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
sort interview__id interview__key quest s6q5 s6q3 s6q1, stable

	
save "$output\individual.dta", replace
