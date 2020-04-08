/*===========================================================================
Puropose: This script takes prices and baskets and calculates basket's value
over time and region and creates indexes
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

// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned"
global mergeddatapath "$rootpath\data_management\output\merged"
global input  "$rootpath\poverty_measurement\input"
global output "$rootpath\poverty_measurement\input"

///////////////////////////////////////////////////////////////////////////////
// USER SHOULD CHOOSE BETWEEN METHODOLOGIES (CHILENIAN OR COLOMBIAN)
///////////////////////////////////////////////////////////////////////////////

*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off
// for label handling, we use labutil module 
// ssc install labutil


/*(************************************************************************************************************************************************* 
* 1: merging baskets and prices at month-state level
*************************************************************************************************************************************************)*/


// import prices
use "$cleaneddatapath/food_prices_per_month_entidad.dta", replace

// keep relevant variables
keep bien ENTIDAD mes precio

// goods in price dataset are classified differently than products in consumption dataset
// so we use a function to map goods from one dataset to the other

//generate mapping
preserve
use "$input/Labels_Prices_Consumption_Goods.dta", replace
drop if COD_PRECIO==.
isid COD_PRECIO
rename COD_PRECIO bien
tempfile mapping
save `mapping'
restore

// map goods of price dataset to goods of consumption dataset
merge m:1 bien using `mapping'



// cleaning
// correct mapping in some specific products

// drop product with no (relevant) price
drop if _merge==2

// consumption data mixes arroz and harina de arroz, but arroz is way more popular that harina de arroz. So we prefer a price for arroz only.
drop if bien==2




/*(************************************************************************************************************************************************* 
* 1: basket value by month (NO STATE)
*************************************************************************************************************************************************)*/

// import prices
use "$cleaneddatapath/food_prices_per_month.dta", replace


// map goods of price dataset to goods of consumption dataset
merge m:1 bien using `mapping'


// cleaning
// correct mapping in some specific products

// drop product with no (relevant) price
drop if _merge==2

// consumption data mixes arroz and harina de arroz, but arroz is way more popular that harina de arroz. So we prefer a price for arroz only.
drop if bien==2

// Many products of the price data set are agregated in the consumption dataset. Example carne de res bistec, molida and desmechada. With no prior on within-group relevance, we just input a mean.
collapse (mean) precio=precio, by (mes COD_GASTO LABEL_GASTO)


// merge prices with representative baskets
rename COD_GASTO bien
merge m:1 bien using "$input/canastapercapita_metochi_sin_outliars.dta"

// cleaning
keep if _merge==3
keep mes bien LABEL_GASTO precio cantidad_ajustada
rename LABEL_GASTO label_bien
rename cantidad_ajustada cantidad


//generate labels
labmask bien, values(label_bien)
drop label_bien


// generate value of each products
bysort mes: gen valor = precio * cantidad
rename bien bien_desc
gen bien = bien_desc

keep if mes=="02"
export excel "$output/valor_canasta_nacional_metochi.xlsx", firstrow(variables) replace


//generate baskets by month and state
collapse (sum) valor, by (mes)

// set basis for indexes
gen temp = valor if mes=="02"
egen valorbase = max (temp)
drop temp

gen index=100*valor/valorbase

// set time 
replace mes = "nov2019" if mes=="11"
replace mes = "dec2019" if mes=="12"
replace mes = "jan2020" if mes=="01"
replace mes = "feb2020" if mes=="02"
replace mes = "mar2020" if mes=="03"
replace mes = "apr2020" if mes=="04"
replace mes = "may2020" if mes=="05"
replace mes = "jun2020" if mes=="06"

gen t = monthly(mes, "MY")
format t %tm

sort t

export excel "$output/indice_precios_nacional_metochi.xlsx", firstrow(variables) replace
save "$output/indice_precio_nacional_metochi.dta", replace




/*(************************************************************************************************************************************************* 
* 1: DEPRECIATED: BASKETS AND INDEXES AT SUBNATIONAL LEVEL
*************************************************************************************************************************************************)*/

// // Many products of the price data set are agregated in the consumption dataset. Example carne de res bistec, molida and desmechada. With no prior on within-group relevance, we just input a mean.
// collapse (mean) precio=precio, by (ENTIDAD mes COD_GASTO LABEL_GASTO)
//	
//
// // merge prices with representative baskets
// rename COD_GASTO bien
// merge m:1 bien using "$input/canastapercapita_metochi_sin_outliars.dta"
// stop
// // cleaning
// keep if _merge==3
// keep ENTIDAD mes bien LABEL_GASTO precio cantidad
// rename LABEL_GASTO label_bien
// rename ENTIDAD entidad
// rename cantidad_ajustada cantidad
//
//
// //generate labels
// labmask bien, values(label_bien)
// drop label_bien
//
//
//
// /*(************************************************************************************************************************************************* 
// * 1: basket value by month-state
// *************************************************************************************************************************************************)*/
//
// // generate value of each products
// bysort entidad mes: gen valor = precio * cantidad
//
// // save basket value result
// preserve
// keep if entidad==1
// export excel "$output/valor_canasta_df.xlsx", firstrow(variables) replace
// restore
//
// //generate baskets by month and state
// collapse (sum) valor, by (entidad mes)
//
// // set basis for indexes
// gen temp = valor if mes=="02" & entidad == 1
// egen valorbase = max (temp)
// drop temp
//
// gen index=100*valor/valorbase
//
// // set time 
// replace mes = "nov2019" if mes=="11"
// replace mes = "dec2019" if mes=="12"
// replace mes = "jan2020" if mes=="01"
// replace mes = "feb2020" if mes=="02"
// replace mes = "mar2020" if mes=="03"
// replace mes = "apr2020" if mes=="04"
// replace mes = "may2020" if mes=="05"
// replace mes = "jun2020" if mes=="06"
//
// gen t = monthly(mes, "MY")
// format t %tm
//
// sort entidad t
//
// export excel "$output/indice_precios_por_estado.xlsx", firstrow(variables) replace
// save "$output/indice_precio_por_estado.dta", replace