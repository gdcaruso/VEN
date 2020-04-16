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
* 1: sets population of reference
*************************************************************************************************************************************************)*/

// we dont want to be misleaded by imputed income, so we remove this households
import excel "$input\imputacion_ingreso_lista_hh.xlsx", firstrow clear
keep interview__key interview__id quest
bys interview__key interview__id quest: keep if _n==1
replace quest = "1" if quest == "Tradicional - Viejo"
replace quest = "2" if quest == "Tradicional - Nuevo"
replace quest = "3" if quest == "Remoto"
destring quest, replace


tempfile imputedhh
save `imputedhh'


// import data of pop of reference
use "$output/pob_referencia.dta", replace


// // to test on all pop
// use "$cleaned/ENCOVI_2019.dta", replace
// collapse (max) ipcf (max)miembros, by(interview__id interview__key quest)

// remove hh with imputed income
merge 1:1 interview__id interview__key quest using `imputedhh'


drop if _merge!=1
drop _merge
tempfile reference
replace ipcf = round(ipcf)
save `reference'



/*(************************************************************************************************************************************************* 
* 1: generate deflators and ex rate conversion
*************************************************************************************************************************************************)*/


	*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor

//use "$rootpath\data_management\output\cleaned\inflacion\Inflacion_Asamblea Nacional.dta", clear

use "$rootpath\data_management\output\cleaned\inflacion\inflacion_canasta_alimentos_diaria_precios_implicitos.dta", clear
			
			forvalues j = 10(1)12 {
				sum indice if mes==`j' & ano==2019
				local indice`j' = r(mean) 			
				}
			forvalues j = 1(1)4 {
				sum indice if mes==`j' & ano==2020
				display r(mean)
				local indice`j' = r(mean)				
				}
				
				
				
			local deflactor11 `indice2'/`indice11'
			local deflactor12 `indice2'/`indice12'
			local deflactor1 `indice2'/`indice1'
			local deflactor2 `indice2'/`indice2'
			local deflactor3 `indice2'/`indice3'

// 			local deflactor11 1
// 			local deflactor12 1
// 			local deflactor1 1
// 			local deflactor2 1
// 			local deflactor3 1
		
		* Exchange Rates / Tipo de cambio
			*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
			local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			local meses 1 2 3 4 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march
			
			use "$rootpath\data_management\management\1. merging\exchange rates/TC_cierre_provisorio.dta", clear
			
			destring mes, replace
			foreach i of local monedas {
				foreach j of local meses {
					sum mean_moneda	if moneda==`i' & mes==`j'
					local tc`i'mes`j' = r(mean)
					di `tc`i'mes`j''
				}
			}

di `tc1mes1'
di `tc2mes1'
di `tc2mes12'
di `tc2mes11'
di `tc2mes2'
di `tc3mes2'
di `tc3mes12'
di `tc3mes3'
di `tc4mes1'
di `deflactor11'
di `deflactor12'
di `deflactor1'
di `deflactor2'
di `deflactor3'
di `deflactor4' //falta!


/*(************************************************************************************************************************************************* 
* 1: collect data of spending in feb2020
*************************************************************************************************************************************************)*/

// there are two data sources of spending. 1) Household-individual section of survey and 2) Consumption section. Also, there are two types of spending: a) food b) non-food. So we aggregate each type of consumption in each section of the survey


/*(************************************************************************************************************************************************* 
* // Consumption section  (long shape)
*********************************************************************************************************************)*/
// import feb2020 product data
use "$merged/product-hh.dta", replace //use merged because we need expenditure, not homogenized units of cleaned dataset

// keep only with data of pop of reference
merge m:1 interview__id interview__key quest using `reference' //up to APRIL 13th is ipcf quantiles 55 74 

keep if _merge ==3
drop _merge

// generate month of the survey
gen month = month(date_consumption_survey)
drop if month ==4


// problems and solutions: a) define good types b) define current goods c) homogenize currencies d) correct date of purchase  e) define frequency of purchase for each type 

// a) define good type
gen type_good = .
label define type_good 1 "food" 2 "alcohol&smoke" 3 "bath&cleaning" 4 "clothes" 5 "durables" 6 "eatingout" 7 "entertainment" 8 "housing" 9 "services" 10 "education" 11 "health" 12 "social security" 
label value type_good type_good

replace type_good = 1 if inrange(bien, 1,89) //alimentos
replace type_good = 2 if inrange(bien, 90,92) //alcohol&smoke
replace type_good = 3 if inrange(bien, 101,122) //bienes de consumo no alimenticios (tocador, limpieza)
replace type_good = 4 if inrange(bien, 123,131) //ropa
replace type_good = 5 if inrange(bien, 132,147) //bienes durables (TV, plancha)
replace type_good = 6 if inrange(bien, 200,205) //comida fuera del hogar
replace type_good = 7 if inrange(bien, 301,322) //entretenimiento y turismo

// b) define non current goods
gen current_good = .
replace current_good = 1 if inlist(type_good,1,2,3,4,6,7) 
replace current_good = 0 if type_good==5 //bienes durables (TV, plancha)
drop if current_good !=1

// //only food
// keep if type_good == 1


// d) define date of purchases
// problem: dates of purchase is different among goods

/* FOR FOOD and alcohol&smoke


. tab type_good fecha

              |   8. ¿Cuando fue la última vez que compró  .... para
              |                       su hogar?
    type_good |      Ayer  Últimos 7  Últimos 1  Más de 15      Nunca |     Total
--------------+-------------------------------------------------------+----------
         food |     2,190     14,768      4,086      4,895        552 |    26,491 
alcohol&smoke |        47         68         12          6          1 |       134 
--------------+-------------------------------------------------------+----------
        Total |     2,237     14,836      4,098      4,901        553 |    26,625 

//FOR bath&cleaning 15 days
// FOR clothes 3 months
// FOR eatingout 7 days
// FOR entertainment last month	

// FOOD AND ALCOHOL

Solution:
a) we reimputate month of purchase to january if he or she answered more that 15 days and the date of the survey is earlier that Feb 14th.
b) we reimputate month of purchase to jan if he/she answered that they bought 7 days before and date is earlier than 7th


           |   8. ¿Cuando fue la
           |    última vez que
date_consu | compró  .... para su
mption_sur |        hogar?
       vey | Últimos 1  Más de 15 |     Total
-----------+----------------------+----------
    1Feb20 |        63         45 |       108 
    2Feb20 |        36         70 |       106 
    3Feb20 |       117        193 |       310 
    4Feb20 |       150        204 |       354 
    5Feb20 |       192        174 |       366 
    6Feb20 |       171        162 |       333 
    7Feb20 |       208        204 |       412 
    8Feb20 |       159        179 |       338 
    9Feb20 |        53         75 |       128 
   10Feb20 |       256        272 |       528 
   11Feb20 |       173        250 |       423 
   12Feb20 |       293        259 |       552 
   13Feb20 |       176        278 |       454 
   14Feb20 |       170        213 |       383 
   15Feb20 |       156        176 |       332 
   16Feb20 |        22         34 |        56 
   17Feb20 |       122        183 |       305 
   18Feb20 |       136        158 |       294 
   19Feb20 |       248        311 |       559 
... and keeps going
*/


//homogenize currencies
// we simplify the analysis assuming that any purchase of the consumption interview of Feb is done within Feb, and each purchase of a survey of march is done within march
// for non food this might be questionable, but we have no other reference of when the purchase was done. Ex. prendas de vestir en los ultimos 3 meses...
gen gasto_feb20 = .

levelsof month, local(month_levels)
levelsof moneda, local(moneda_levels)

foreach mes in `month_levels'{
	foreach currency in `moneda_levels'{
	di "////"
	di `mes'
	di `currency'
	di  `tc`currency'mes`mes''
	di `deflactor`mes''
	replace gasto_feb20 = gasto * `tc`currency'mes`mes'' * `deflactor`mes'' if month==`mes' & moneda == `currency'
	
	}
	}
replace gasto_feb20 = round(gasto_feb20)

// just to test the previous loop, 13th april its working well
// gen gasto_feb20_b=.
// replace gasto_feb20_b = gasto if moneda == 1 & month ==2
// replace gasto_feb20_b = gasto * `tc2mes2' if moneda == 2  & month ==2
// replace gasto_feb20_b = gasto * `tc3mes2' if moneda == 3  & month ==2
// replace gasto_feb20_b = gasto * `tc4mes2' if moneda == 4 & month ==2
//
// // march (alredy food only)
// replace gasto_feb20_b = gasto*`deflactor3' if moneda == 1 & month ==3
// replace gasto_feb20_b = gasto*`deflactor3' * `tc2mes3' if moneda == 2 & month ==3
// replace gasto_feb20_b = gasto*`deflactor3' * `tc3mes3'  if moneda == 3 & month ==3
// replace gasto_feb20_b = gasto*`deflactor3' * `tc4mes3' if moneda == 4 & month ==3




/*

// e) define frequency of purchases
// problem:
we dont know how recurrent are the purchased of different goods
FOR FOOD and alcohol&smoke
              |   8. ¿Cuando fue la última vez que compró  .... para
              |                       su hogar?
    type_good |      Ayer  Últimos 7  Últimos 1  Más de 15      Nunca |     Total
--------------+-------------------------------------------------------+----------
         food |    10,751     80,381     22,814     28,394      2,426 |   144,766 
alcohol&smoke |       264        374         36         46          1 |       721 
--------------+-------------------------------------------------------+----------
        Total |    11,015     80,755     22,850     28,440      2,427 |   145,487 

FOR bath&cleaning 15 days
FOR clothes 3 months
FOR eatingout 7 days
FOR entertainment last month	

solution:
we make the following assumptions
food and alcohol = 7 days (mostly cases of food are between 7 days)
bath&cleaning = 15 days
clothes = 3 months
eatingout = 7 days
entertainment = a month
we use a standard month of 30.42 days
we convert all expenditures to montly equivalent multiplying or dividing each type of product by the proper ratio
*/

//genera gasto mensualizado
gen gasto_mensual = gasto_feb20* 30.42/7 if type_good==1
// gen gasto_mensual = gasto_feb20* 30.42/15 if type_good==1

replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==2
replace gasto_mensual = gasto_feb20* 30.42/15 if type_good==3 //bath&cleaning twice a week
replace gasto_mensual = gasto_feb20/3 if type_good==4 //clothes in three months
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==5 //durables not current
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==6 //eatingout weekly
replace gasto_mensual = gasto_feb20* 30.42/30.42 if type_good==7 // monthly for enterainment
replace gasto_mensual = round(gasto_mensual)

// // genera gasto mensual raw, sin multiplicadores de frecuencia de consumos
// gen gasto_mensual = gasto_feb20


// outliars detection
xtile q = gasto_mensual, nq(100)
gen flag = q > 99
gsort -gasto_mensual
tab q [fw=gasto_mensual] //top 1% of current expenditure gets 98% of total expenditure
replace gasto_mensual=. if q >99 // drop top 1%

tab q [fw=gasto_mensual] //now looks more reasonable

// composition of expenditures
tab type_good
tab type_good [fw=gasto_mensual]

tempfile conSpending
save `conSpending'

/*(************************************************************************************************************************************************* 
* // Check spending
*********************************************************************************************************************)*/
collapse (sum) gasto_mensual, by (interview__id interview__key quest)
tempfile `checkingSpending'

merge 1:m (interview__id interview__key quest) using `reference'
gen ingfam = ipcf*miembros

gen superavit = ingfam > gasto_mensual
gen keynes_multiplier = ingfam/gasto_mensual

//graph box keynes, noout
tab superavit
codebook ingfam



/*(************************************************************************************************************************************************* 
* // HH section  (wide shape) 
*********************************************************************************************************************)*/
// import other expenditure data
use "$cleaned/ENCOVI_2019.dta", replace
drop ipcf
drop _merge
merge m:1 interview__id interview__key quest using `reference'
keep if _merge == 3
drop _merge


//select relevant variables
global viviendavar renta_imp pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m renta_imp_en renta_imp_mon

global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m

global educvar cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension


keep interview__id interview__key quest interview_month quest ipcf miembros entidad  ///
$viviendavar ///
$serviciosvar ///
$educvar ///
$saludvar ///
$jubivar

////////////////////
// CLASIFICACION //
//////////////////

// first we move everything to feb 2020 bolivares, mensual freq. Then we reshape to get a long dataset.



******************************************vivienda
// we use the imputed rent or the actually payed rent

// global viviendavar pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m
*********************declared rent (mensual)
// data in bolivares feb2020


gen gasto901 =.
levelsof pago_alq_mutuo_m, local(month)
foreach m in `month'{
	levelsof pago_alq_mutuo_mon, local(currency)
	foreach c in `currency'{
	if `m'>10 | `m'<3 {
		replace gasto901 = pago_alq_mutuo*`tc`c'mes`m''*`deflactor`m'' if pago_alq_mutuo_m == `m' & pago_alq_mutuo_mon == `c'
		di `m'
		di `c'
		di `tc`c'mes`m''
		di `deflactor`m''
	}
	}
	}


******************inputed rent by analyst
// data in bolivares feb2020
gen gasto903 = renta_imp //assumed everything was moved in the income module to feb 2020

gen gasto90 = renta_imp // uses imputed rent or
replace gasto90 = gasto901 if gasto901 !=. // reported rent. If there are both, reported rent prevails

// outliars detection
replace gasto90 = round(gasto90)
xtile q = gasto90, nq(100)
gen flag = q > 99
gsort -gasto90
tab q [fw=gasto90] //top 1% of current expenditure gets 98% of total expenditure
tab q [fw=gasto90] //now looks more reasonable
drop q flag

**********************************************services
// global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m
*******************agua


gen gasto911 =.
gen gasto912 =.
gen gasto913 =.
gen gasto914 =.
gen gasto915 =.
gen gasto916 =.


// gasto en agua
local servicios pagua pelect pgas pcarbon pparafina ptelefono
local n=910

foreach v in `servicios'{
local n=`n'+1
levelsof `v'_m, local(month)
	foreach m in `month'{
	levelsof `v'_mon, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<4 {
			di "`v'" "`n'"
			di `m'
			di `c'
			di `tc`c'mes`m''
			di `deflactor`m''
			replace gasto`n' = `v'_monto*`tc`c'mes`m''*`deflactor`m'' if `v'_m == `m' & `v'_mon == `c'
		}
		}
		}
	}



// outliars detection
replace gasto911 = round(gasto911)
xtile q = gasto911, nq(100)
gen flag = q > 99
gsort -gasto911
tab q [fw=gasto911] //top 1% of current expenditure gets 20% of total expenditure
//drop if q >99 // do not drop 1% looks reasonable
drop q flag


// outliars detection
replace gasto912 = round(gasto912)
xtile q = gasto912, nq(100)
gen flag = q > 99
gsort -gasto912
tab q [fw=gasto912] //top 1% of current expenditure gets 50% of total expenditure
replace gasto912=. if q >99  // drop 1% 
drop q flag

// outliars detection
replace gasto913 = round(gasto913)
xtile q = gasto913, nq(100)
gen flag = q > 99
gsort -gasto913
tab q [fw=gasto913] 
replace gasto913=. if q >99 
drop q flag

// outliars detection
replace gasto914 = round(gasto914)
xtile q = gasto914, nq(100)
gen flag = q > 99
gsort -gasto914
tab q [fw=gasto914] //top 1% of current expenditure gets 20% of total expenditure
//drop if q >99 // do not drop 1% looks reasonable
drop q flag

// outliars detection
replace gasto915 = round(gasto915)
xtile q = gasto915, nq(100)
gen flag = q > 99
gsort -gasto915
tab q [fw=gasto915]
drop q flag

// outliars detection
replace gasto916 = round(gasto916)
xtile q = gasto916, nq(100)
gen flag = q > 99
gsort -gasto916
tab q [fw=gasto916] //
drop q flag

egen gasto91 = rowtotal(gasto91*)



****************************************educacion
//
// global educvar cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

*********************inscripcion (assumed annual freq)



gen gasto921 =.
gen gasto922 =.
gen gasto923 =.
gen gasto924 =.
gen gasto925 =.
gen gasto926 =.


// gasto en agua
local educ cuota_insc compra_utiles compra_uniforme costo_men costo_transp otros_gastos
local n=920

foreach v in `servicios'{
local n=`n'+1
levelsof `v'_m, local(month)
	foreach m in `month'{
	levelsof `v'_mon, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<4 {
			di "`v'" "`n'"
			di `m'
			di `c'
			di `tc`c'mes`m''
			di `deflactor`m''
			replace gasto`n' = `v'_monto*`tc`c'mes`m''*`deflactor`m'' if `v'_m == `m' & `v'_mon == `c'
		}
		}
		}
	}



// outliars detection
replace gasto921 = round(gasto921)
xtile q = gasto921, nq(100)
gen flag = q > 99
gsort -gasto921
tab q [fw=gasto921] //top 1% of current expenditure gets 40% of total expenditure

drop q flag

// outliars detection
replace gasto922 = round(gasto922)
xtile q = gasto922, nq(100)
gen flag = q > 99
gsort -gasto922
tab q [fw=gasto922] 
replace gasto922=. if q >99 
drop q flag


// outliars detection
replace gasto923 = round(gasto923)
xtile q = gasto923, nq(100)
gen flag = q > 99
gsort -gasto923
tab q [fw=gasto923] //
replace gasto923=. if q >99 
drop q flag

// outliars detection
replace gasto924 = round(gasto924)
xtile q = gasto924, nq(100)
gen flag = q > 99
gsort -gasto924
tab q [fw=gasto924] //top 1% of current expenditure gets 20% of total expenditure
//drop if q >99 // do not drop 1% looks reasonable
drop q flag

// outliars detection
replace gasto925 = round(gasto925)
xtile q = gasto925, nq(100)
gen flag = q > 99
gsort -gasto925
tab q [fw=gasto925]
//drop if q >99 // do not drop 1% looks reasonable
drop q flag

// outliars detection
replace gasto926 = round(gasto926)
xtile q = gasto926, nq(100)
gen flag = q > 99
gsort -gasto926
tab q [fw=gasto926] //
//drop if q >99 // do not drop 1% looks reasonable
drop q flag

egen gasto92 = rowtotal(gasto92*)


*******************************************salud

// global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

********************pago consulta (assumed mensual)

gen gasto931 =.
gen gasto932 =.
gen gasto933 =.
gen gasto934 =.
gen gasto935 =.


rename pago_remedio cant_pago_remedio
rename pago_examen cant_pago_examen

// gasto en agua
local salud pago_consulta pago_remedio pago_examen remedio_tresmeses pagosegsalud
local n=930

foreach v in `salud'{
local n=`n'+1
levelsof mes_`v', local(month)
	foreach m in `month'{
	levelsof mone_`v', local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<4 {
			di "`v'" "`n'"
			di `m'
			di `c'
			di `tc`c'mes`m''
			di `deflactor`m''
			replace gasto`n' = cant_`v'*`tc`c'mes`m''*`deflactor`m'' if mes_`v' == `m' & mone_`v' == `c'
		}
		}
		}
		}



// outliars detection
replace gasto931 = round(gasto931)
xtile q = gasto931, nq(100)
gen flag = q > 99
gsort -gasto931
tab q [fw=gasto931] //top 1% of current expenditure gets 40% of total expenditure
drop q flag


// outliars detection
replace gasto932 = round(gasto932)
xtile q = gasto932, nq(100)
gen flag = q > 99
gsort -gasto932
tab q [fw=gasto932] 
drop q flag


// outliars detection
replace gasto933 = round(gasto933)
xtile q = gasto933, nq(100)
gen flag = q > 99
gsort -gasto933
tab q [fw=gasto933] //
drop q flag

// outliars detection
replace gasto934 = round(gasto934)
xtile q = gasto934, nq(100)
gen flag = q > 99
gsort -gasto934
tab q [fw=gasto934] //top 1% of current expenditure gets 20% of total expenditure
drop q flag

// outliars detection
replace gasto935 = round(gasto935)
xtile q = gasto935, nq(100)
gen flag = q > 99
gsort -gasto935
tab q [fw=gasto935]
drop q flag


egen gasto93 = rowtotal(gasto93*)

// outliars detection
replace gasto93 = round(gasto93)
xtile q = gasto93, nq(100)
gen flag = q > 99
gsort -gasto93
tab q [fw=gasto93]
drop q flag




******************************************** jubilacion

// global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension

*************** descuentos ? incorporamos ? (assumed mensual)
********* descuento seg social obligatorio

gen gasto941 =.
gen gasto942 =.
gen gasto943 =.
gen gasto944 =.
gen gasto945 =.
gen gasto946 =.
gen gasto947 =.



// gasto en jubi
local jubi d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro
local n=940

foreach v in `jubi'{
local n=`n'+1
levelsof interview_month, local(month)
	foreach m in `month'{
	levelsof `v'_mone, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<4 {
			di "`v'" "`n'"
			di `m'
			di `c'
			di `tc`c'mes`m''
			di `deflactor`m''
			replace gasto`n' = `v'_cant*`tc`c'mes`m''*`deflactor`m'' if interview_month == `m' & `v'_mone == `c'
		}
		}
		}
		}


// gasto en aportapension

gen gasto948=.
levelsof interview_month, local(month)
	foreach m in `month'{
	levelsof mone_aporta_pension, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<4 {
			di `m'
			di `c'
			di `tc`c'mes`m''
			di `deflactor`m''
			replace gasto948 = cant_aporta_pension*`tc`c'mes`m''*`deflactor`m'' if interview_month == `m' & mone_aporta_pension == `c'
		}
		}
		}
		
egen gasto94 = rowtotal(gasto94*)

// outliars detection
replace gasto94 = round(gasto94)
xtile q = gasto94, nq(100)
gen flag = q > 99
gsort -gasto94
tab q [fw=gasto94]
drop q flag		
		

***********************************end of expenditures********************************


// adds expenditure of hh, removing individual dimension 
collapse (sum) gasto??, by (interview__id interview__key quest ipcf miembros entidad)


// now we reshape the wide data to make it long
reshape long gasto, i(interview__id interview__key quest ipcf miembros entidad) j(bien)
rename gasto gasto_mensual
replace gasto_mensual = round(gasto_mensual)

// generate current good variable
gen current_good = 1

// generate types of goods
gen type_good = 8 if bien==90
replace type_good = 9 if bien==91
replace type_good = 10 if bien==92
replace type_good = 11 if bien==93
replace type_good = 12 if bien==94

replace current_good = 0 if type_good == 12

tempfile hhSpending
save `hhSpending'

// apends hh spending dataset with consumption dataset
append using `conSpending'

keep interview__id interview__key quest ipcf miembros entidad ///
bien type_good current_good gasto_mensual

order interview__id interview__key quest ipcf miembros entidad ///
bien type_good current_good gasto_mensual

// saves expenditure dta in long shape
save "$output/gastos_pob_referencia.dta", replace


/*(************************************************************************************************************************************************* 
* 1:orshanky
*************************************************************************************************************************************************)*/

// colombian meth removes electronics as non current goods.
keep if current_good==1



//drop smoke and alcohol intake
drop if type_good == 2

// filter of popularity
bysort bien: egen pop = count(gasto_mensual) if gasto_mensual>0 & gasto_mensual!=. 
bysort bien: egen popularity_hh = max(pop)
drop pop

qui tab interview__id
gen totalhh = r(r)
gen popularity = popularity_hh/totalhh
sort popularity

drop if popularity<.05

// aggregate expenditures by group and hh
collapse (sum) gasto_mensual, by(interview__id interview__key quest ipcf miembros entidad type_good)


tab type_good [fw=gasto_mensual]

//reshapes to wide 
reshape wide gasto_mensual, i(interview__id interview__key quest ipcf miembros entidad) j(type_good)

//sum food and non food expenditure per hh
egen food_exp = rowtotal(gasto_mensual1)
egen exp = rowtotal (gasto_mensual*)
gen non_food_exp = exp-food_exp

//calculates orshansky per hh 
gen orshansky = exp/food_exp

//remove outliars
xtile ors_quant = orshansky, nq(100)


sort orshansky
gen obs = _n
twoway line orshansky obs if ors_quant<100 

xtile exp_quant = exp, nq(100)

sum orshansky, detail
global orsh = r(p50)

drop if ors_quant>99
sum orsh, detail



// TO ANALYSE COMPOSITION OF EXPENDITURE IN THE THE ENVIROMENT OF ORSHANSNKY
// keep if orshansky <$orsh*1.30
// keep if orshansky >$orsh*0.7
//
// local values 1 3 4 7 8 9 10 11 12 
//
// foreach i in `values'{
// 	egen total`i' = total(gasto_mensual`i')
// 	}
//


// TO COMPARE EXPENDITURE AND INCOME IN THE POB OF REFERENCE
// twoway scatter food ingreso if food< 10000000, msize(tiny) ///
// || lfit food ingreso if food<10000000 ///
// || line food food if food<10000000, sort
//
// gen flag = food > ingreso
// tab flag
//
