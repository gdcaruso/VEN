/*===========================================================================
Puropose: Graph of ipcf distrubution & month of survey
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
1: Data loading
==============================================================================*/

*************************************************************************************************************
*** COMPLETAR UNIDADES MAL IMPUTADAS (KG x GR o viceversa)
*** COMPLETAR TAMAñOS
*** COMPLETAR BIENES NO ESTANDARIZADOS
****************************************************************************************************************

// load food data
use  "$cleaned/ENCOVI_2019.dta

collapse (max) ipcf, by(interview__id interview__key quest interview_month)
local t 5

xtile q = ipcf, nq(`t')

tab interview_month,mi

gen share_nov =.
gen share_dic =.
gen share_jan =.
gen share_feb =.
gen share_mar =.

forvalues i = 1(1)`t' {
count if interview_month==12 & q==`i'
replace share_dic = r(N) if q==`i'
count if interview_month==11 & q==`i'
replace share_nov = r(N) if q==`i'
count if interview_month==1 & q==`i'
replace share_jan = r(N) if q==`i'
count if interview_month==2 & q==`i'
replace share_feb = r(N) if q==`i'
count if interview_month==3 & q==`i'
replace share_mar = r(N) if q==`i'
}

bys q: gen q_obs = _N

local vars share_nov share_dic share_jan share_feb share_mar
bro

foreach v in `vars' {
 replace `v' = `v'/q_obs
 }

 
sort ipcf
gen obs = _n
bro

sum ipcf, detail
gen noout = ipcf<r(p99)

twoway line ipcf obs if noout   ///
|| line share_feb obs if noout, yaxis(2) ///
|| line share_mar obs if noout, yaxis(2) ///
|| line share_jan obs if noout, yaxis(2) ///
|| line share_dic obs if noout, yaxis(2) ///
|| line share_nov obs if noout, yaxis(2) 

stop
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
gen week = week(date_consumption_survey)-52

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

//drop 0s or . in quantities and expenditure
drop if comprado ==0 | comprado ==.
drop if gasto_bol ==0 | comprado ==.

// look for popularity among "presentations" (bien unidad_medida tamano cantidad) and filter less popular
preserve
collapse (count) count=gasto_bol, by(bien unidad_medida tamano comprado)
by bien: egen total = total(count)
gen pop = count/total
keep if pop>.15 //parametro clave, permite encontrar observaciones en todos los productos. revisar tab bien _merge luego del proximo merge antes de cambiar
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
gen pimp = gasto_bol/comprado

collapse (p50) pimp, by(bien)

export excel $output/precios_implicitos.xlsx, firstrow(variables) replace
save $output/precios_implicitos.dta, replace