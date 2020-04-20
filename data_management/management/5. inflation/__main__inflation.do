/*===========================================================================
Puropose: Main .do that generates inflation
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Malena Acuña

Dependencies:		The World Bank
Creation Date:		20th April, 2020
Modification Date:  
Output:			

Note: 
=============================================================================*/
********************************************************************************
clear all

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  1
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global dopath "C:\Users\wb563583\GitHub\VEN"
				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\DataEncovi"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global dopath "C:\Users\wb550905\Github\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
}		
********************************************************************************

/*
*/
/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off


global harmonization "$dopath\data_management\management\2. harmonization"

//set universal paths
global merged "$datapath\data_management\output\merged"
global cleaned "$datapath\data_management\output\cleaned"

global povinput "$datapath\poverty_measurement\input\"

//inflation, exchange rate inputs and auxiliaries
global inflationout "$datapath\data_management\input"
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
*global pathaux "$harmonization\aux_do"

/*==============================================================================
harmonization without inflation
 ==============================================================================*/

*Specific inputs: imputation do's and auxiliary SEDLAC do's 
global pathaux "$harmonization\aux_do"
global inflado "$dopath\data_management\management\5. inflation"
run "$pathaux\cuantiles.do"
global forinflation "$datapath\data_management\output\for inflation"
run "$pathaux\cuantiles.do"

//run ENCOVI harmonization
// do "$inflado\armonization_for_inflation.do"

// set population and basket
do "$inflado\genera_poblacion_y_canasta_para_inflacion.do"


// define prices
do "$inflado\precios_implicitos_nov_to_march.do"

// generate inflation
run "$inflado\genera_inflacion_canastas.do"


