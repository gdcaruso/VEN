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
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\Documents\GitHub\ENCOVI-2019"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Desktop\worldbank\analisis\ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\1. Data Harmonization\output"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\1. Data Harmonization\dofiles\aux_do"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
		
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}

global dataofficial "$rootpath\data_management\input\02_12_20"
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

// Load and append data of the 3 questionaires
	use  "$pathold\interview__actions.dta", clear
	gen quest="Tradicional - Viejo"                 // To identy Old questionnaires

	append using "$pathnew\interview__actions.dta"
	replace quest="Tradicional - Nuevo" if quest=="" // To identy New questionnaires

	append using "$pathpixel\interview__actions.dta"
	replace quest="Remoto" if quest==""              // To identy Remote questionnaires

// Create a temporary db with surveys approved by HQ 
	preserve
	tempfile approved_surveys
	bys quest interview__key interview__id (date): keep if action==6 // 6=approved by HQ
	bys quest interview__key interview__id (date time): gen duplicates=1 if _n!=_N // check &  delete duplicates
	tab duplicates
	keep interview* origina responsible__name quest date

	// formatting
	rename ori interviewer
	rename respo coordinator
	replace date = subinstr(date, "-", "/",.)
	gen edate=date(date,"YMD")
	format edate %td
	drop date
	// save temporary db with surveys approved
	save `approved_surveys'
    restore

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Append with household data   --------------------------------------------------
This section appends the three questionnaries before keeping the approved observations 
*************************************************************************************************************************************************)*/ 
	
	*-------- Append households
    tempfile household
	use "$pathold\ENCOVI_MainSurvey_Final.dta", clear
	gen quest="Tradicional - Viejo"
	
	append using "$pathnew\ENCOVI.dta"
	replace quest="Tradicional - Nuevo" if quest==""
	
	append using "$pathpixel\ENCOVI_pixel_Qx.dta"
	replace quest="Remoto" if quest==""
	save `household'


	*-------- Append shocks to households
	tempfile shocks
	use "$pathold\HH_Sec15a.dta", clear
	gen quest="Tradicioinal - Viejo"
	
	append using "$pathnew\HH_Sec15a.dta"
	replace quest="Tradicional - Nuevo" if quest==""
	
	append using "$pathpixel\HH_Sec15a.dta"
	replace quest="Remoto" if quest==""
    save `shocks'
	
	
	*-------- Append mortality for each household
	tempfile fallecido
	use "$pathold\.dta", clear
	gen quest="Tradicioinal - Viejo"
	
	append using "$pathnew\.dta"
	replace quest="Tradicional - Nuevo" if quest==""
	
	append using "$pathpixel\.dta"
	replace quest="Remoto" if quest==""
    save `fallecido'


	// quizas hacer esto una vez que tengo todos apendiados
*	merge 1:1 interview__key interview__id quest using `approved_surveys', keep( using matched)	
*	save `household_a'
	