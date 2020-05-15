/*===========================================================================
Puropose: TThis scrip takes basket value, orshansky and ENCOVI ipcf and estimates
poverty
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		31th march, 2020
Modification Date:  
Output:			dta with baskets values and indexes

Note: 
=============================================================================*/
********************************************************************************

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
				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global dopath "C:\Users\wb550905\Github\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
}		

//
// //set universal datapaths
global merged "$datapath\data_management\output\merged"
global final_output "$datapath\..\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018"
global povinput "$datapath\poverty_measurement\input"

// global cleaned "$datapath\data_management\output\cleaned"
// global forinflation "$datapath\data_management\output\for inflation"
//
// //set universal dopath
// global harmonization "$dopath\data_management\management\2. harmonization"
// global inflado "$dopath\data_management\management\5. inflation"
//
// //Exchange rate inputs and auxiliaries
//
// global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
// global pathaux "$harmonization\aux_do"
//
//
// // set path of data
// global povmeasure "$dopath\poverty_measurement\scripts"

// global output "$datapath\poverty_measurement\output"
// global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
//
// global orsh = 1.9
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off



/*(***************************************************************************** 
* 1: caloric intake per capita
*******************************************************************************/

//add caloric intake

preserve
use "$merged\product_hh_homogeneous.dta", replace
rename bien COD_GASTO
merge m:1 COD_GASTO using "$povinput/Calories.dta"

keep if _merge==3
drop _merge
rename COD_GASTO bien

gen cal_intake = Energia_kcal_m/100*cantidad_h/7
gen prot_intake = Proteina_m/100*cantidad_h/7

collapse (max) cal_intake (max) prot_intake, by (interview__id interview__key)

compress
tempfile calintake
save `calintake'
restore

// merge encovi with cal intake (spanish labels)
use "$final_output/ENCOVI_2019_Spanish labels.dta", replace
merge m:1 interview__id interview__key using `calintake'
keep if _merge != 2
drop _merge

gen calorias_diarias_per_capita= cal_intake/miembros
drop cal_intake
gen pobre_19usd = ipcf<lp_19usd if hogarsec !=1
gen pobre_32usd = ipcf<lp_32usd if hogarsec !=1
gen pobre_55usd = ipcf<lp_55usd if hogarsec !=1

label variable calorias_diarias_per_capita "Consumo diario de kilocalorias per capita"
label variable pobre_19usd "Identificador situación de pobreza para línea de 1.9usd ppp2011"
label variable pobre_32usd "Identificador situación de pobreza para línea de 3.2usd ppp2011"
label variable pobre_55usd "Identificador situación de pobreza para línea de 5.5usd ppp2011"

//save "$final_output/ENCOVI_2019_Spanish label with calintake.dta"

// merge encovi with cal intake (english labels)
use "$final_output/ENCOVI_2019_English labels.dta", replace
merge m:1 interview__id interview__key using `calintake'
keep if _merge != 2
drop _merge

gen caloric_diarias_per_capita= cal_intake/miembros
drop cal_intake
gen pobre_19usd = ipcf<lp_19usd if hogarsec !=1
gen pobre_32usd = ipcf<lp_32usd if hogarsec !=1
gen pobre_55usd = ipcf<lp_55usd if hogarsec !=1

label variable calorias_diarias_per_capita "Daily caloric intake per capita in kcal."
label variable pobre_19usd "Indicator of poverty: 1 = income less that 1.9usd a day ppp2011"
label variable pobre_32usd "Indicator of poverty: 1 = income less that 3.2usd a day ppp2011"
label variable pobre_32usd "Indicator of poverty: 1 = income less that 5.5usd a day ppp2011"

//save "$final_output/ENCOVI_2019_English label with calintake.dta"

