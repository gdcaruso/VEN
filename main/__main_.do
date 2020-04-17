/*===========================================================================
Puropose: Main .do that construct encovi database
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Malena Acuña

Dependencies:		The World Bank
Creation Date:		17th April, 2020
Modification Date:  
Output:			

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
		
		* User 4: Malena
		global male   1
			
		if $juli {
				global dopath "C:\Users\wb563583\GitHub\VEN"
				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global dopath "C:\Users\wb550905\Github\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
}		
********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

//set universal paths
global merged "$datapath\data_management\output\merged"
global cleaned "$datapath\data_management\output\cleaned"

//inflation and exchange rate inputs
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"

/*==============================================================================
 merging data
 ==============================================================================*/
/*
set path of data
global merging "$dopath\data_management\management\1. merging"
global input "$datapath\data_management\input\latest"
global output "$datapath\data_management\output\merged"

run merge
do "$merging/__main__merge.do"
*/

/*==============================================================================
hh-individual database and imputation
==============================================================================*/

set path of data

global harmonization "$dopath\data_management\management\2. harmonization"

*Specific inputs: imputation do's and auxiliary SEDLAC do's 
global pathaux "$harmonization\ENCOVI harmonization\aux_do"
global impdos "$dopath\data_management\management\4. income imputation\dofiles"

*Specific for imputation
global forimp 	"$datapath\data_management\output\for imputation"
global pathoutexcel "$dopath\data_management\management\4. income imputation\output"

set path of data  (CORREGIR)
global input "$datapath\data_management\output\harmonized"
global output "$datapath\data_management\output\harmonized"

imputate incomes (CORREGIR)
global "$harmonization\ENCOVI harmonization\????????"


/*==============================================================================
poverty estimation
==============================================================================*/

// set path of data
*global encovifilename "ENCOVI_2019_pre pobreza.dta" // LAUTI, FALTARÍA CAMBIA ESTO EN TUS DO'S YA CON EL NOMBRE EN VEZ DE UNA GLOBAL
global povmeasure "$dopath\poverty_measurement\scripts"
global input "$datapath\poverty_measurement\input"
global output "$datapath\poverty_measurement\output"

//run poverty estimation
do "$povmeasure/__main__.do"

/*==============================================================================
attach pov to harmonized data
==============================================================================*/

// use x, replace
// merge m:1 inter, keep(match)
