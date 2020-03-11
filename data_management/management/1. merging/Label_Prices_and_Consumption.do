/*===========================================================================
Purpose: merge incorporate identification codes of which allow to link
         goods from the price survey and goods from the consumption survey

Country name:	Venezuela
Year:			2019
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Merged Dataset ENCOVI (Prices)

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
	global dataout "$rootpath\data_management\output"
	global dataint "$dataout\intermediate"
    // Set the  path for prices
	global pathprc "$dataofficial\ENCOVI_prices_2_STATA_All"
	

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Merge codes for prices database  ----------------------------------------------
*************************************************************************************************************************************************)*/ 
    // From labels dataset
	use "$dataint\Labels_Prices_Consumption_Goods", clear
	// Rename the key variable to merge
	rename COD_PRECIO bien
	// Eliminate missing values
	keep if bien!=.
	//Save as temporary file
	tempfile label
	save `label'
	//Merge with prices dataset
	use "$dataout\merged\prices.dta", clear //4183 observations
	merge m:1 bien using `label', keep(matched) //4183 observations
    save "$dataout\merged\prices_labeled.dta"
	
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Merge codes for consumption database ------------------------------------------
*************************************************************************************************************************************************)*/


    // From labels dataset
	use "$dataint\Labels_Prices_Consumption_Goods", clear
	// Rename the key variable to merge
	rename COD_GASTO bien
	// Eliminate missing values
	keep if bien!=.
	//Save as temporary file
	tempfile label
	save `label'
	//Merge with consumption dataset
	use "$dataout\merged\XXXX.dta", clear // xxx observations
	merge m:1 bien using `label', keep(matched) // xxx observations
	save "$dataout\merged\XXXX_labeled.dta"
	
