/*===========================================================================
Puropose: This script takes spending in food and compares it with spending
in non food goods to calculate orshansky indexes over population of reference
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		25th Mar, 2020
Modification Date:  

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
		
		* User 3: Lautaro
		global lauta2   1
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set path
global merged "$rootpath\data_management\output\merged"
global cleaned "$rootpath\data_management\output\cleaned"
global output "$rootpath\poverty_measurement\output"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off



/*==============================================================================
1:moves currencies to bolivares
==============================================================================*/
// generate exchange rates

*** 0.0 To take everything to bolívares ***

* Deflactor DEPRECIATED
*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
//use "$cleaned\InflacionVerdadera_26-3-20.dta", clear
//		
// forvalues j = 11(1)12 {
// 	sum indice if mes==`j' & ano==2019
// 	local indice`j' = r(mean) 			
// 	di `indice`j''
// 	}
//
//	
// forvalues j = 1(1)3 {
// 	qui sum indice if mes==`j' & ano==2020
// 	display r(mean)
// 	local indice`j' = r(mean)				
// 	}
// local deflactor11 `indice2'/`indice11'
// local deflactor12 `indice2'/`indice12'
// local deflactor1 `indice2'/`indice1'
// local deflactor2 `indice2'/`indice2'
// local deflactor3 `indice2'/`indice3'


// or use this to mute all inflation effects
local deflactor11 1
local deflactor12 1
local deflactor1 1
local deflactor2 1
local deflactor3 1
	
* Exchange Rates / Tipo de cambio
*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio

local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
local meses 1 2 3 4 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march

use "$rootpath\data_management\management\1. merging\exchange rates\exchenge_rate_price.dta", clear

destring mes, replace
foreach i of local monedas {
	foreach j of local meses {
		qui sum mean_moneda	if moneda==`i' & mes==`j'
		local tc`i'mes`j' = r(mean)
		di `tc`i'mes`j''
	}
}


/*==============================================================================
1: Data loading
==============================================================================*/

*************************************************************************************************************
*** COMPLETAR UNIDADES MAL IMPUTADAS (KG x GR o viceversa)
*** COMPLETAR TAMAñOS
*** COMPLETAR BIENES NO ESTANDARIZADOS
****************************************************************************************************************

// load food data
use  "$merged/product-hh.dta", clear


//drop no consumption
keep if consumio==1 & cantidad>0 & (cantidad!=.|cantidad!=.a)


// drop unrelevant variables
keep interview__key interview__id quest bien unidad_medida tamano comprado fecha_ultima_compra cantidad_comprada_noclap unidada_comprada_noclap  tamano_comprada_noclap gasto moneda date_consumption_survey

// replace 0s at purchased ammounts just to dont avoid 0s at summary statistics
replace comprado =. if comprado==0

// replace 0s at expenditure ammounts just to dont avoid 0s at summary statistics
replace gasto =. if gasto==0


//drop if unidad_medida is missing
drop if unidad_medida==.


// merge with sedlac to get hh size
preserve
use  "$cleaned/ENCOVI_2019.dta", clear
collapse (max) com, by (interview__id interview__key quest)
rename com miembros
tempfile hhsize
save `hhsize'
restore

merge m:1 interview__id interview__key quest using `hhsize', keep(match)
drop _merge
// dates
// gen week of data
gen week = week(date_consumption_survey)
replace week = week+52 if week<40
// gen month of data
gen month = month(date_consumption_survey)



// currency conversion

gen gasto_bol = gasto* 1*`deflactor2' if moneda == 1 & month == 2
replace gasto_bol = gasto*`tc2mes2'*`deflactor2' if moneda == 2 & month == 2
replace gasto_bol = gasto*`tc3mes2'*`deflactor2' if moneda == 3 & month == 2
replace gasto_bol = gasto*`tc4mes2'*`deflactor2' if moneda == 4 & month == 2


replace gasto_bol = gasto*1*`deflactor3' if moneda == 1 & month == 3
replace gasto_bol = gasto*`tc2mes3'*`deflactor3' if moneda == 2 & month == 3
replace gasto_bol = gasto*`tc3mes3'*`deflactor3' if moneda == 3 & month == 3
replace gasto_bol = gasto*`tc4mes3'*`deflactor3' if moneda == 4 & month == 3


replace gasto_bol = gasto*1*`deflactor1' if moneda == 1 & month == 1
replace gasto_bol = gasto*`tc2mes1'*`deflactor1' if moneda == 2 & month == 1
replace gasto_bol = gasto*`tc3mes1'*`deflactor1' if moneda == 3 & month == 1
replace gasto_bol = gasto*`tc4mes1'*`deflactor1' if moneda == 4 & month == 1


replace gasto_bol = gasto*1*`deflactor11' if moneda == 1 & month == 11
replace gasto_bol = gasto*`tc2mes11'*`deflactor11' if moneda == 2 & month == 11
replace gasto_bol = gasto*`tc3mes11'*`deflactor11' if moneda == 3 & month == 11
replace gasto_bol = gasto*`tc4mes11'*`deflactor11' if moneda == 4 & month == 11


replace gasto_bol = gasto*1*`deflactor12' if moneda == 1 & month == 12
replace gasto_bol = gasto*`tc2mes12'*`deflactor12' if moneda == 2 & month == 12
replace gasto_bol = gasto*`tc3mes12'*`deflactor12' if moneda == 3 & month == 12
replace gasto_bol = gasto*`tc4mes12'*`deflactor12' if moneda == 4 & month == 12


/*==============================================================================
1: filters
==============================================================================*/
// keep only goods of the basket
keep if inlist(bien, 1, 4, 5, 6, 7, 10, 14, 17, 22, 26, 28, 31, 33, 34, 37, 39, 43, 45, 46, 51, 53, 54, 55, 62, 63, 68, 74, 78)


// keep obs of feb2020
keep if month==2


// create purchases using clap and noclap

// first we compare clap and no clap purchases
gen compare = cantidad_comprada_noclap/comprado
tab compare

//80% of obs are have the same values in cantidad_comprada_noclap and comprado
//           0 |      1,892        3.63        3.63
//         .84 |          1        0.00       15.68
//    .8571429 |          2        0.00       15.69
//        .875 |          1        0.00       15.69
//    .9333333 |          1        0.00       15.69
//           1 |     40,458       77.54       93.23 // 80% of the products have the same quantity on how much of their consumption was purchased and how much of their last purchase was excluding clap. This is informative to generate market prices.
//       1.016 |          1        0.00       93.24
//        1.04 |          1        0.00       93.24
//    1.041667 |          1        0.00       93.24

// are no clap unit the same as comprado units?
gen same_presentation = 1 if unidad_medida == unidada_comprada_noclap
tab same_presentation

// Units reported are the same between purchases and no clap purchases
// . tab same_presentation
//
// same_presen |
//      tation |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           1 |     45,183      100.00      100.00
// ------------+-----------------------------------
//       Total |     45,183      100.00


replace same_presentation = . if same_presentation ==1 & tamano_comprada_noclap != tamano
tab same_presentation  
// (26 real changes made, 26 to missing)
//
// . tab same_presentation  
//
// same_presen |
//      tation |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           1 |     45,157      100.00      100.00
// ------------+-----------------------------------
//       Total |     45,157      100.00
//
// . 

// so we have 45.000 product obs of full non-CLAP implicit prices and 1.800 obs of full CLAP prices


gen clap = 1 if compare ==0
replace clap = 0 if compare ==1 & same_presentation ==1


//drop 0s or . in quantities and expenditure
drop if comprado ==0 | comprado ==.
drop if gasto_bol ==0 | comprado ==.

// look for popularity among "presentations" (bien unidad_medida tamano cantidad) and filter less popular
preserve
collapse (count) count=gasto_bol, by(bien unidad_medida tamano comprado)
by bien: egen total = total(count)
gen pop = count/total
keep if pop>.1 //parametro clave, permite encontrar observaciones en todos los productos. revisar tab bien _merge luego del proximo merge antes de cambiar
tempfile popular
save `popular'
restore


merge m:1 bien unidad_medida tamano comprado using `popular'
tab bien _merge
keep if _merge == 3


/*==============================================================================
1:quantities to grams
==============================================================================*/
// all kilos to grams
replace comprado = comprado*1000 if unidad_medida==1

// modify aceite to grams
replace comprado = comprado*0.92*1000 if bien==33 & unidad_medida==3
replace comprado = comprado*0.92 if bien==33 & unidad_medida==4

// modify eggs to grams
replace comprado = comprado*15*52.5 if bien==31 & unidad_medida==92

//modify pieza pan to grams
replace comprado = comprado*250 if bien==6 & unidad_medida==40

// generate implicit prices per gram
gen pimp_clap = gasto_bol/comprado if clap == 1
gen pimp_no_clap = gasto_bol/comprado if clap == 0


// we have significant N of observations of non clap prices but too few on clap prices.
tab bien if pimp_clap !=.
tab bien if pimp_no_clap !=.


collapse (p50) pimp_clap (p50) pimp_no_clap (count) n_pimp_clap = pimp_clap (count) n_pimp_no_clap = pimp_no_clap, by(bien)

export excel $output/pimp_clap_no_clap.xlsx, firstrow(variables) replace
save $output/pimp_clap_no_clap.dta, replace


