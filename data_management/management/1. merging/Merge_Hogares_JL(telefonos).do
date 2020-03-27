/*===========================================================================
Country name:		Venezuela
Year:			2014
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			Merged Dataset ENCOVI

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   1
		
		* User 3: Lautaro
		global lauta   0
		
		* User 3: Lautaro
		global lautaa	0   
		
		* User 4: Malena
		global male   0

			
		if $juli {
				global rootpath "C:\Users\wb563583\Documents\GitHub\VEN"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lautaa {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}
		if $trini {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
		}
		
		if $male {
				global rootpath "C:\Users\wb550905\Github\VEN\"
		}

global dataofficial "$rootpath\data_management\input\03_26_20"
 // Set the path for the three questionnaires
	global pathnew "$dataofficial\ENCOVI_3_STATA_All"
	global pathold "$dataofficial\ENCOVI_MainSurvey_Final_3_STATA_All"
	global pathpixel "$dataofficial\ENCOVI_pixel_Qx_9_STATA_All"


********************************************************************************
/*===============================================================================
                          0: Program set up
===============================================================================*/
version 14
drop _all
set more off

local country  "VEN"    // Country ISO code
local year     "2014"   // Year of the survey
local survey   "ENCOVI"  // Survey acronym
local vm       "01"     // Master version
local va       "01"     // Alternative version
local project  "03"     // Project version
local period   ""       // Periodo, ejemplo -S1 -S2
local alterna  ""       // 
local vr       "01"     // version renta
local vsp      "01"	// version ASPIRE
*include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

/*==================================================================================================================================================
								1: Preparacion de los datos: Variables de Primer Orden
==================================================================================================================================================*/


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Data preparation  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 

	
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Append with household data   --------------------------------------------------

*************************************************************************************************************************************************)*/ 

**** Preliminary information: approved surveys

	*-------- Append actions 
	// To Old questionnaire
	use "$pathold\interview__actions.dta", clear
	gen quest=1
	
	// Add New questionnaire
	append using "$pathnew\interview__actions.dta"
	replace quest=2 if quest==. & quest!=1
	
	// Add Remote questionnaire
	append using "$pathpixel\interview__actions.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2

	// Create a tempfile for approved surveys
    tempfile approved_surveys
	
	// Create identification for completed surveys
	bys interview__key interview__id (date): keep if action==3 // 3=Completed 

	// To identify unique interviews according the last date and time entered
    bys interview__key interview__id (date time) : keep if _n==_N
	
	// Check duplicates 
	duplicates report interview__key interview__id 
	duplicates report interview__key interview__id date time
	
	
	//preserve
	//keep if dupli >= 1
	//save "$rootpath\data_management\output\merged\duplicates-hh.dta", replace
	//restore	
	//drop if dupli >= 1
	
	//keep interview* origina responsible__name quest date

	// Change format
	rename ori interviewer
	//rename respo coordinator
	replace date = subinstr(date, "-", "/",.)
	gen approved_date=date(date,"YMD")
	format approved_date %td
	drop date
	// save temporary db with surveys approved (means unique id and time for each interview)
	save `approved_surveys'	
	
**** Main household data	
	*-------- Append households 
	// Compile the three questionnaires as temporary file 
    tempfile household
	
	// To Old questionnaire
	use "$pathold\ENCOVI_MainSurvey_Final.dta", clear
	gen quest=1
	
	// Add New questionnaire
	append using "$pathnew\ENCOVI.dta"
	replace quest=2 if quest==. & quest!=1
	
	// Add Remote questionnaire
	append using "$pathpixel\ENCOVI_pixel_Qx.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2
	
	// Selecting only the approved by HQ
	merge 1:1 interview__key interview__id quest using `approved_surveys', keep(using matched)
	drop _merge
    // Save the temporary file
    save `household'

	// This file has a wide format while the other carctheristics have a long format
	// The following files: shocks, mortalidad, services and emigration are transformed 
	// in the following section before merging with the household data

**** Complementary household data	
	*-------- Append shocks to households
	// Compile the three questionnaires as temporary file 
	tempfile shocks
	
	// To Old questionnaire
	use "$pathold\HH_Sec15a.dta", clear
	gen quest=1
	
	// Add New questionnaire
	append using "$pathnew\HH_Sec15a.dta"
	replace quest=2 if quest==. & quest!=1
	
	// Add Remote questionnaire
	append using "$pathpixel\HH_Sec15a.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2
	
	// Transform the file from long to wide
    rename s15q2* s15q2*_
	reshape wide s15q2* , i(interview__id)  j(HH_Sec15a__id)
	
	// Selecting only the approved by HQ
	merge 1:1 interview__key interview__id quest using `approved_surveys', keep(using matched)
    drop _merge
	// Save the temporary file
    save `shocks'

	
	*-------- Append mortality for each household
	// Compile the three questionnaires as temporary file 
	tempfile mortality
	
	// To Old questionnaire
	use "$pathold\Fallecido.dta", clear
	gen quest=1
	
	// Add New questionnaire
	append using "$pathnew\Fallecido.dta"
	replace quest=2 if quest==. & quest!=1
	
	// Add Remote questionnaire
	append using "$pathpixel\Fallecido.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2
	
	// Transform the file from long to wide
	rename Fallecido__id fallecido_id
	reshape wide s11q* , i(interview__id)  j(fallecido_id)
	
	// Selecting only the approved by HQ
	merge 1:1 interview__key interview__id quest using `approved_surveys', keep(using matched)
    drop _merge
	// Save the temporary file
    save `mortality'

	
	*-------- Append services for each household
	// Compile the three questionnaires as temporary file 	
	tempfile services
	
	// To Old questionnaire
	use "$pathold\s5q17_roster.dta", clear
	gen quest=1
	
	// Add New questionnaire
	append using "$pathnew\s5q17_roster.dta"
	replace quest=2 if quest==. & quest!=1
	
	// Add Remote questionnaire
	append using "$pathpixel\s5q17_roster.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2
   
    // Rename the services identificator
	rename s5q17_roster__id servicio_id
	
	// Transform the file from long to wide
	reshape wide s5q17* , i(interview__id)  j(servicio_id)
	
	// Selecting only the approved by HQ
	merge 1:1 interview__key interview__id quest using `approved_surveys', keep(using matched)
    drop _merge	
	// Save the temporary file
	save `services' 
	 
	*-------- Append emigration for each household
	// Compile the three questionnaires as temporary file 	
	tempfile emigration
	
	// To Old questionnaire
	use "$pathold\Migrante.dta", clear
	gen quest=1
	
	// Add New questionnaire
	append using "$pathnew\Migrante.dta"
	replace quest=2 if quest==. & quest!=1
	
	// Add Remote questionnaire
	append using "$pathpixel\Migrante.dta"
	replace quest=3 if quest==. & quest!=1 & quest!=2
 
	// Transform the file from long to wide
	reshape wide s10q* , i(interview__id) j(Migrante__id)
	
	// Selecting only the approved by HQ
	merge 1:1 interview__key interview__id quest using `approved_surveys', keep(using matched)
    drop _merge
	// Save the temporary file
    save `emigration'

****Combine the main and complementary household data	
	*-------- Merge at the household level 

    local com_data `shocks' `mortality' `services' `emigration'
	use `household', clear
foreach file in `com_data' {
    merge 1:1 interview__key interview__id quest using `file'
    drop _merge
}

*-------- Define labels for each type of questionnaire 
	label define quest_label 1 "Tradicional - Viejo" ///
	2 "Tradicional - Nuevo" ///
	3 "Remoto"
	
	*Incorporate the values labels to the variable 		  
	label values quest quest_label

	compress
*-------- Save 

save "$rootpath\data_management\output\merged\household(telefonos).dta", replace

