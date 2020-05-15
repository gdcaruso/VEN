/*===========================================================================
Country name:	Venezuela
Year:			2014-2018
Survey:			ENCOVI
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		January, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   1
		
			
		if $juli {
				global rootpath "C:\Users\WB563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Desktop\worldbank\analisis\ENCOVI"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
		}
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
               	global pathdo "C:\Users\wb550905\Github\VEN\data_management\management\2. harmonization\ENCOVI harmonization"
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global pathout "$rootpath\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018"

***************************************************************************************************************

*** 2014
do "$pathdo\VEN_ENCOVI_COMP_2014"
*** 2015 
do "$pathdo\VEN_ENCOVI_COMP_2015"
*** 2016
do "$pathdo\VEN_ENCOVI_COMP_2016"
*** 2017
do "$pathdo\VEN_ENCOVI_COMP_2017"
*** 2018
do "$pathdo\VEN_ENCOVI_COMP_2018"

clear all
