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

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta   1
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath CAMBIAR A ONE DRIVE (VER MALE ABAJO) "C:\Users\wb563583\GitHub\VEN"
// 		}
// 	    if $lauta {
// 		global rootpath "C:\Users\wb563365\GitHub\VEN"
// 		}
// 		if $trini   {
// 				global rootpath CAMBIAR A ONE DRIVE (VER MALE ABAJO) "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
// 		}
// 		if $male   {
// 				global rootpath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// 		}

********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

// set path for files
// global input "$datapath\poverty_measurement\input"
// global merged "$datapath\data_management\output\merged"
// global cleaned "$datapath\data_management\output\cleaned"
// global output "$datapath\poverty_measurement\output"
// global scripts "$datapath\poverty_measurement\scripts"
// global encovifilename "ENCOVI_2019_PRECIOS IMPLICITOS_lag_ingresos_IMPUTADA.dta"


/*==============================================================================
run dos to estimate poverty
==============================================================================*/

//defines poblation of references and normative basket
do "$povmeasure/genera_poblacion_y_canasta.do"
//calculate prices (implicit)
do "$povmeasure/precios_implicitos.do"
// do "$povmeasure/precios_implicitos_nov_to_march.do"
// do "$povmeasure/genera_inflacion_canastas.do"

// //generate cost of basket
do "$povmeasure/genera_costo_canasta.do"
// //estimates orshansky
do "$povmeasure/estima_orshansky.do"
// //estimates poverty headcount
do "$povmeasure/estima_pobreza.do"