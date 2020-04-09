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

// set raw data path
global merged "$rootpath\data_management\output\merged"
global cleaned "$rootpath\data_management\output\cleaned"
global input "$rootpath\poverty_measurement\input"
global output "$rootpath\poverty_measurement\output"


*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off




/*(************************************************************************************************************************************************* 
* 1: extract incomes
*************************************************************************************************************************************************)*/

use "$cleaned/ENCOVI_2019.dta", replace
tempfile incomes
replace ipcf = round(ipcf)
keep interview__key interview__id quest com ipcf
collapse (max) miembros = com (max) ipcf, by (interview__key interview__id quest) 
save `incomes'


/*(************************************************************************************************************************************************* 
* 1: extract 10 most important products according to incidence in basket costs
*************************************************************************************************************************************************)*/

// load basket
use "$output/costo_canasta_diaria.dta", replace

// generate local with 10 most costly goods
gsort -valor
keep if _n<11
levelsof(bien), local(relevant_goods)

/*(************************************************************************************************************************************************* 
* 1: set indexes
*************************************************************************************************************************************************)*/

*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
	
	* Deflactor
		*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
		
		use "$cleaned\InflacionVerdadera_26-3-20.dta", clear
		
		forvalues j = 11(1)12 {
			sum indice if mes==`j' & ano==2019
			local indice`j' = r(mean) 			
			}
		forvalues j = 1(1)3 {
			sum indice if mes==`j' & ano==2020
			display r(mean)
			local indice`j' = r(mean)				
			}
		local deflactor11 `indice2'/`indice11'
		local deflactor12 `indice2'/`indice12'
		local deflactor1 `indice2'/`indice1'
		local deflactor2 `indice2'/`indice2'
		local deflactor3 `indice2'/`indice3'
		
		di `deflactor1'
		di `deflactor2'
		di `deflactor3'
		di `deflactor11'
		di `deflactor12'
		
	* Exchange Rates / Tipo de cambio
		*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
		
		local monedas "1 2 3 4" // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
		local meses "1 2 3 11 12" // 11=nov, 12=dic, 1=jan, 2=feb, 3=march
		
		use "$cleaned\exchenge_rate_price.dta", clear
		
		destring mes, replace
		foreach i of local monedas {
			foreach j of local meses {
				sum mean_moneda	if moneda==`i' & mes==`j'
				local tc`i'mes`j' = r(mean)
				di `i'
				di `j'
				di `tc`i'mes`j''
			}
		}

/*(************************************************************************************************************************************************* 
* 1: analysis of 10 most relevant goods, all households
*************************************************************************************************************************************************)*/

// load expenditure and quantities data
use "$merged/product-hh.dta", replace



//keep only 10 relevant goods
// keep if inlist(bien, 1, 4, 7, 10, 17, 28, 31, 33, 68, 74) //using local relevant_goods is not working, dont know why

//keep only food
keep if bien<100
/*(************************************************************************************************************************************************* 
* 1: correct currencies and inflation
*************************************************************************************************************************************************)*/

		
// corrects currencies and inflation to get all values in feb20 bol
// esto se puede hacer mejor, hay una variable que es hace cuanto compro!!!
// hacer un corrected month con esta variable

gen mes = month(date_consumption_survey)

gen gasto_bolfeb20 = .

foreach m in `monedas'{
	foreach n in `meses'{
		di "////////"
		di `m'
		di `n'
			
		if `m' == 1 { // if the currency is bolivares
			di `deflactor`n''
			replace gasto_bolfeb20 = gasto *`deflactor`m'' if mes == `n' & moneda == `m'
			
		} // end of if bolivar
		else { // if the currency is not bolivares
			di `tc`m'mes`n'' * `deflactor`n''
			replace gasto_bolfeb20 = gasto * `tc`m'mes`n'' * `deflactor`n'' if mes == `n' & moneda == `m'	
		} // end of else if not bolivares 
	} //end of month loop
} // end of currency loop

//end of inflation and currency correction

// /*(************************************************************************************************************************************************* 
// * 1: homogenize quantities (not very fancy, we took corrections of consumtion data to correct units purchased, as if they were the same variable...)
// *************************************************************************************************************************************************)*/
// levelsof bien, local(goodlist)
//
// tab unidad_medida
// tab unidad_medida tamano
// tab bien unidad_medida
// tab bien tamano
//
//
// gen cantidad_h =.
//
// // food = Arroz, harina de arroz (1)
// // unit = Kilogramos (1)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==1 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==1 & unidad_medida==1 & comprado>=50
//
//
// // food = Arroz, harina de arroz (1)
// // unit = Gramos (2)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==1 & unidad_medida==2 & comprado<50
// replace cantidad_h = comprado if bien==1 & unidad_medida==2 & comprado >=50
//
//
// // food = Harina de maiz (4)
// // unit = Kilogramos (1)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==4 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==4 & unidad_medida==1 & comprado >=50
//
//
// // food = Harina de maiz (4)
// // unit = Gramos (2)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==4 & unidad_medida==2 & comprado<50
// replace cantidad_h = comprado if bien==4 & unidad_medida==2 & comprado >=50
//
// // food = Pastas alimenticias (7)
// // unit = Kilogramos (1)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==7 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==7 & unidad_medida==1 & comprado>=50 
//
// // food = Pastas alimenticias (7)
// // unit = Gramos (2)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==7 & unidad_medida==2 & comprado<50
// replace cantidad_h = comprado if bien==7 & unidad_medida==2 & comprado>=50 
//
// // food = Carne de res (bistec, carne molida, carne para esmechar) (10)
// // unit = Kilogramos (1)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==10 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==10 & unidad_medida==1 & comprado>=50 
//
// // food = Carne de res (bistec, carne molida, carne para esmechar) (10)
// // unit = Gramos (2)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==10 & unidad_medida==2 & comprado<50
// replace cantidad_h = comprado if bien==10 & unidad_medida==2 & comprado>=50 
//
// // food = Carne de pollo (17)
// // unit = Kilogramos (1)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==17 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==17 & unidad_medida==1 & comprado>=50
//
//
// // food = Carne de pollo (17)
// // unit = Gramos (2)
// // size = no size
//
// replace cantidad_h = comprado*1000 if bien==17 & unidad_medida==2 & comprado<50
// replace cantidad_h = comprado if bien==17 & unidad_medida==2 & comprado>=50
//
// // food = Queso blanco (28)
// // unit = Kilogramos (1)
// // size = no size
// replace cantidad_h = comprado*1000 if bien==28 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==28 & unidad_medida==1 & comprado>=50
//
//
// // food = Queso blanco (28)
// // unit = Gramos (2)
// // size = no size
// *ALERT: treshold to move kilos to grams changed (14)
// replace cantidad_h = comprado*1000 if bien==28 & unidad_medida==2 & comprado<14
// replace cantidad_h = comprado if bien==28 & unidad_medida==2 & comprado>=14
//
// // food = Huevos (unidades) (31)
// // unit = Cartón (91)
// // size = no size
// * used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
// * weight = 52.5 gr/unit (ME)
// replace cantidad_h = comprado*36*52.5 if bien==31 & unidad_medida==91 & comprado<=5
// replace cantidad_h = comprado*52.5 if bien==31 & unidad_medida==91 & comprado>5
//
// // food = Huevos (unidades) (31)
// // unit = Medio cartón (92)
// // size = no size
// * used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
// * weight = 52.5 gr/unit (ME)
// replace cantidad_h = comprado*18*52.5 if bien==31 & unidad_medida==92 & comprado<=5
// replace cantidad_h = comprado*52.5 if bien==31 & unidad_medida==92 & comprado>5 & comprado<36
// replace cantidad_h = comprado if bien==31 & unidad_medida==92 & comprado>=100
//
// // food = Huevos (unidades) (31)
// // unit = Docena (100)
// // size = no size
// * used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
// * weight = 52.5 gr/unit (ME)
// replace cantidad_h = comprado*12*52.5 if bien==31 & unidad_medida==100 & comprado<10
// replace cantidad_h = comprado*52.5 if bien==31 & unidad_medida==100 & comprado>=10
//
//
// // food = Huevos (unidades) (31)
// // unit = Unidad (110)
// // size = no size
// * used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
// * weight = 52.5 gr/unit (ME)
// replace cantidad_h = comprado*52.5 if bien==31 & unidad_medida==110 & comprado<200
//
// // food = Aceite (33)
// // unit = Litros (3)
// // size = no size
// *density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/ (ME)
// replace cantidad_h = comprado*0.92*1000 if bien==33 & unidad_medida==3 & comprado<50
// replace cantidad_h = comprado*0.92 if bien==33 & unidad_medida==3 & comprado>=50
//
//
// // food = Aceite (33)
// // unit = Mililitros (4)
// // size = no size
// *density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/ (ME)
// *ALERT: treshold changed (10)
// replace cantidad_h = comprado*0.92*1000 if bien==33 & unidad_medida==4 & comprado<10
// replace cantidad_h = comprado*0.92 if bien==33 & unidad_medida==4 & comprado>=10
//
//
// // food = Aceite (33)
// // unit = Cucharada (210)
// // size = Grande (1)
// * "Cucharada" "grande" (10g) based on Hernandez et al (2015)* (ME)
// replace cantidad_h = comprado*10 if bien==33 & unidad_medida==210 & tamano==1
//
//
// // food = Aceite (33)
// // unit = Cucharada (210)
// // size = Pequeña (3)
// * "Cucharada" "pequena" (5g) based on Hernandez et al (2015)* (ME)
// replace cantidad_h = comprado*5 if bien==33 & unidad_medida==210 & tamano==3 & comprado<100
//
// // food = Azucar (68)
// // unit = Kilogramos (1)
// // size = no size
// replace cantidad_h = comprado*1000 if bien==68 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==68 & unidad_medida==1 & comprado>=50
//
// // food = Azucar (68)
// // unit = Gramos (2)
// // size = no size
// replace cantidad_h = comprado*1000 if bien==35 & unidad_medida==2 & comprado<10
// replace cantidad_h = comprado if bien==35 & unidad_medida==2 & comprado>=10
//
// // food = Cafe (74)
// // unit = Kilogramos (1)
// // size = no size
// replace cantidad_h = comprado*1000 if bien==74 & unidad_medida==1 & comprado<50
// replace cantidad_h = comprado if bien==74 & unidad_medida==1 & comprado>=50
//
// // food = Cafe (74)
// // unit = Gramos (2)
// // size = no size
// replace cantidad_h = comprado*1000 if bien==74 & unidad_medida==2 & comprado<10
// replace cantidad_h = comprado if bien==74 & unidad_medida==2 & comprado>=10

/*(************************************************************************************************************************************************* 
* 1: frequency estimation of goods purchase to month
*************************************************************************************************************************************************)*/

// generate monthly expenditure by frequency factor
gen gasto_men_f4 =  gasto_bolfeb20*30.42/7
gen gasto_men_f1 =  gasto_bolfeb20

//idea of factor specific depreciated: if someone answer that he made the purchase +15 before, no expenditure is asked.
//to make a factor of expasion good-specific
tab fecha
tab fecha if gasto_bolfeb20 ==. | gasto_bolfeb20 ==0 //the amount of +15 days is the same in both tabs!!!

collapse (sum) gasto_men_f4 (sum) gasto_men_f1, by(interview__id interview__key quest)

/*(************************************************************************************************************************************************* 
* 1: merge with incomes
*************************************************************************************************************************************************)*/
merge 1:1 interview__id interview__key quest using `incomes' //some incomes do nor merge hh

gen ingfam = ipcf*miembros
gen outliars =1 if gasto_men_f1>50000000 | ingfam>50000000
egen count = count(outliars)


twoway scatter gasto_men_f1 ingfam if gasto_men_f1<50000000 & ingfam<50000000, msize(tiny) mcolor(%10) ///
|| lfit gasto_men_f1 ingfam if gasto_men_f1<50000000 & ingfam<50000000 ///
|| line ingfam ingfam if gasto_men_f1<50000000 & ingfam<50000000


gen def_f1 = ingfam<gasto_men_f1

twoway scatter gasto_men_f4 ingfam if gasto_men_f4<50000000 & ingfam<50000000, msize(tiny) mcolor(%10) ///
|| lfit gasto_men_f4 ingfam if gasto_men_f4<50000000 & ingfam<50000000 ///
|| line ingfam ingfam if gasto_men_f4<50000000 & ingfam<50000000

gen def_f4 = ingfam<gasto_men_f4

/*(************************************************************************************************************************************************* 
* 1: same excercise, only with surveys of feb20 and raw data
*************************************************************************************************************************************************)*/

//microhistory with raw data

// merge with hh to extract date
use "$merged/household.dta", replace
keep interview__id interview__key quest interview_month
tab interview_month
keep if interview_month==2
tempfile hh
save `hh'


// load raw income data
use "$merged/individual.dta", replace
keep interview__id interview__key quest s9q19a_1 s9q19b_1
tab s9q19b_1
keep if s9q19b_1 == 1
collapse (sum) salario = s9q19a_1, by (interview__id interview__key quest)
merge 1:1 interview__id interview__key quest using `hh', keep(matched)
drop _merge
tempfile salaries
save `salaries'

// load expenditure and quantities data
use "$merged/product-hh.dta", replace
//keep food
keep if bien<100
keep if moneda==1
collapse (sum) gasto, by(interview__id interview__key quest)
//merge
merge 1:1 interview__id interview__key quest using `salaries', keep(matched)
drop _merge

gen notoutliar = gasto<10000000 & salario<10000000
tab notoutliar

gen deficit = salario<gasto 

twoway scatter gasto salario if notoutliar , msize(tiny) mcolor(%10) ///
 || lfit gasto salario if notoutliar ///
 || line salario salario if notoutliar
 
 
 /*(************************************************************************************************************************************************* 
* 1: same excercise, only with surveys of feb20 and ipcf
*************************************************************************************************************************************************)*/

//microhistory with raw data

// merge with hh to extract date
use "$cleaned/ENCOVI_2019.dta", replace
replace ipcf = round(ipcf)
keep interview__key interview__id quest interview_month com ipcf
collapse (max) miembros = com (max) ipcf, by (interview__key interview__id quest interview_month) 
gen ingfam = ipcf*miembros
keep if interview_month==2
tempfile hh
save `hh'


// load expenditure and quantities data
use "$merged/product-hh.dta", replace
//keep food
keep if bien<100
keep if moneda==1
collapse (sum) gasto, by(interview__id interview__key quest)
//merge
merge 1:1 interview__id interview__key quest using `hh', keep(matched)
drop _merge

gen notoutliar = gasto<10000000 & ingfam<10000000
tab notoutliar

gen deficit = ingfam<gasto  
tab deficit, mi 

twoway scatter gasto ingfam if notoutliar , msize(tiny) mcolor(%10) ///
 || lfit gasto ingfam if notoutliar ///
 || line ingfam ingfam if notoutliar