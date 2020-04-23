/*===========================================================================
Puropose: Main .do that merges all raw datasets
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

clear all

// Define rootpath according to user

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta  1
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global dopath "C:\Users\wb563583\GitHub\VEN"
// 				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// 		}
// 	    if $lauta {
// 				global dopath "C:\Users\wb563365\GitHub\VEN"
// 				global datapath "C:\Users\wb563365\DataEncovi\"
// 		}
// 		if $trini   {
// 				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
// 		}
// 		if $male   {
// 				global dopath "C:\Users\wb550905\Github\VEN"
// 				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// }		
// ********************************************************************************
//
//
//
// /*==============================================================================
// Program set up
// ==============================================================================*/
// version 14
// drop _all
// set more off
//
// //set universal datapaths
// global merged "$datapath\data_management\output\merged"
// global cleaned "$datapath\data_management\output\cleaned"
// global forinflation "$datapath\data_management\output\for inflation"
//
// //set universal dopaths
// global harmonization "$dopath\data_management\management\2. harmonization"
// global inflado "$dopath\data_management\management\5. inflation"
// global pathaux "$harmonization\aux_do"
//
// //exchange rate input
// global exrate "$datapath\data_management\input\exchenge_rate_price.dta"


********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

// // set global inflation input
// global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
// // set path of data
// global povmeasure "$dopath\poverty_measurement\scripts"
// global input "$datapath\poverty_measurement\input"
// global output "$datapath\poverty_measurement\output"
//

/*==============================================================================
run dos to estimate poverty
==============================================================================*/

//defines poblation of references and normative basket
do "$povmeasure/genera_poblacion_y_canasta.do"

//calculate prices (implicit)
run "$povmeasure/precios_implicitos.do"

// //generate cost of basket
run "$povmeasure/genera_costo_canasta.do"
// //estimates orshansky
do "$povmeasure/estima_orshansky.do"
// //estimates poverty headcount

do "$povmeasure/estima_pobreza.do"
