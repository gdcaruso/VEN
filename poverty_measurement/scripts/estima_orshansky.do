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


// // Define rootpath according to user
//
// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta   0
//		
// 		* User 3: Lautaro
// 		global lauta2   1
//		
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath ""
// 		}
// 	    if $lauta {
// 				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
// 		}
// 	    if $lauta2 {
// 				global rootpath "C:\Users\wb563365\GitHub\VEN"
// 		}
//
// // set raw data path
// global merged "$rootpath\data_management\output\merged"
// global cleaned "$rootpath\data_management\output\cleaned"
// global input "$rootpath\poverty_measurement\input"
// global output "$rootpath\poverty_measurement\output"


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

use "$output/pob_referencia.dta", replace
tempfile reference
replace ipcf = round(ipcf)
save `reference'

/*(************************************************************************************************************************************************* 
* 1: generate deflators and ex rate conversion
*************************************************************************************************************************************************)*/


	*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor
			*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
// 			use "$cleaned\inflacion\inflacion_canasta_alimentos_diaria_precios_implicitos.dta", clear
//			
// 			forvalues j = 11(1)12 {
// 				sum indice if mes==`j' & ano==2019
// 				local indice`j' = r(mean) 			
// 				}
// 			forvalues j = 1(1)3 {
// 				sum indice if mes==`j' & ano==2020
// 				display r(mean)
// 				local indice`j' = r(mean)				
// 				}
// 			local deflactor11 `indice2'/`indice11'
// 			local deflactor12 `indice2'/`indice12'
// 			local deflactor1 `indice2'/`indice1'
// 			local deflactor2 `indice2'/`indice2'
// 			local deflactor3 `indice2'/`indice3'

			local deflactor11 1
			local deflactor12 1
			local deflactor1 1
			local deflactor2 1
			local deflactor3 1
			
		* Exchange Rates / Tipo de cambio
			*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
			local monedas "1 2 3 4" // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			local meses "1 2 3 11 12" // 11=nov, 12=dic, 1=jan, 2=feb, 3=march
			
			use "$rootpath\data_management\management\1. merging\exchange rates\exchenge_rate_price.dta", clear
			
			destring mes, replace
			foreach i of local monedas {
				foreach j of local meses {
					sum mean_moneda	if moneda==`i' & mes==`j'
					local tc`i'mes`j' = r(mean)
				}
			}
			

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
merge m:1 interview__id interview__key quest using `reference'
keep if _merge ==3
drop _merge

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

// selects purchases done 7 to 15 days before and previous to 7Feb20
gen inflate = 1 if date_consumption_survey<=date("2/7/20","MDY", 2050) & fecha==3 & (type_good ==1 | type_good ==2)

replace inflate = 1 if date_consumption_survey<=date("2/14/20","MDY", 2050)  & fecha==4 & (type_good ==1 | type_good ==2)

//homogenize currencies
// feb
gen gasto_feb20 = gasto if moneda == 1 & (type_good ==1 | type_good ==2)
replace gasto_feb20 = gasto * `tc2mes2' if moneda == 2  & (type_good ==1 | type_good ==2)
replace gasto_feb20 = gasto * `tc3mes2' if moneda == 3  & (type_good ==1 | type_good ==2)
replace gasto_feb20 = gasto * `tc4mes2' if moneda == 4  & (type_good ==1 | type_good ==2)

// jan (alredy food only)
replace gasto_feb20 = gasto*`deflactor1' if inflate==1 & moneda ==1
replace gasto_feb20 = gasto*`deflactor1' * `tc2mes1' if inflate==1 & moneda ==2
replace gasto_feb20 = gasto*`deflactor1' * `tc3mes1' if inflate==1 & moneda ==3
replace gasto_feb20 = gasto*`deflactor1' * `tc4mes1' if inflate==1 & moneda ==4




/*
b) A few march purchases of food and alcohol need to be deflacted to feb2020

           |   8. ¿Cuando fue la
           |    última vez que
date_consu | compró  .... para su
mption_sur |        hogar?
       vey |      Ayer  Últimos 7 |     Total
-----------+----------------------+----------
..........
    1Mar20 |        11         47 |        58 
    3Mar20 |         6         13 |        19 
    4Mar20 |         6         13 |        19 
-----------+----------------------+----------
     Total |     2,236     14,793 |    17,029 
*/


// selects purchases done in first days of march that need to take to feb
// march (alredy food only)
gen deflate = 1 if date_consumption_survey<=date("3/1/20","MDY", 2050) & fecha==1 & (type_good ==1 | type_good ==2)
replace deflate = 1 if date_consumption_survey<=date("3/7/20","MDY", 2050) & fecha==2 & (type_good ==1 | type_good ==2)

replace gasto_feb20 = gasto*`deflactor3' if deflate==1 & moneda ==1
replace gasto_feb20 = gasto*`deflactor3' * `tc2mes3' if deflate==1 & moneda ==2
replace gasto_feb20 = gasto*`deflactor3' * `tc3mes3' if deflate==1 & moneda ==3
replace gasto_feb20 = gasto*`deflactor3' * `tc4mes3' if deflate==1 & moneda ==4

	 
/*
c)
For the rest, we cannot discriminate between a purchase done within the timespan of the question, so we keep the spending date in FEB2020

// c) homogenize currencies
	* We move everything to bolivares February 2020, given that there we have more sample size // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio

 tab moneda (number of spending obs. by currency)

      10b. Moneda |      Freq.     Percent        Cum.
------------------+-----------------------------------
        Bolívares |    131,356       91.18       91.18
          Dólares |      2,488        1.73       92.90
            Euros |         20        0.01       92.92
Pesos Colombianos |     10,205        7.08      100.00
------------------+-----------------------------------
            Total |    144,069      100.00
*/
			
			
// all purchases except some food are assumed as feb based, with no better options
// examples: entretenimiento "ultimo mes", ropa "ultimos tres meses"
replace gasto_feb20 = gasto if moneda == 1 & !(type_good ==1 | type_good ==2)
replace gasto_feb20 = gasto * `tc2mes2' if moneda == 2  & !(type_good ==1 | type_good ==2)
replace gasto_feb20 = gasto * `tc3mes2' if moneda == 3  & !(type_good ==1 | type_good ==2)
replace gasto_feb20 = gasto * `tc4mes2' if moneda == 4  & !(type_good ==1 | type_good ==2)





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
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==2
replace gasto_mensual = gasto_feb20* 30.42/15 if type_good==3
replace gasto_mensual = gasto_feb20/3 if type_good==4
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==5
replace gasto_mensual = gasto_feb20* 30.42/15 if type_good==6
replace gasto_mensual = round(gasto_mensual)






tempfile conSpending
save `conSpending'


/*(************************************************************************************************************************************************* 
* // HH section  (wide shape) 
*********************************************************************************************************************)*/
// import other expenditure data
use "$cleaned/ENCOVI_2019.dta", replace
drop ipcf
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
// global viviendavar renta_imp pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m renta_imp_en renta_imp_mon

*********************declared rent (mensual)
// data in bolivares feb2020
gen gasto901 = pago_alq_mutuo if pago_alq_mutuo_mon ==1 & pago_alq_mutuo_m == 2


// data of March and many currencies
replace gasto901 = pago_alq_mutuo* `deflactor3' if pago_alq_mutuo_mon == 1 & pago_alq_mutuo_m == 3
replace gasto901 = pago_alq_mutuo* `tc2mes3'* `deflactor3' if pago_alq_mutuo_mon == 2 & pago_alq_mutuo_m == 3
replace gasto901 = pago_alq_mutuo* `tc3mes3'* `deflactor3' if pago_alq_mutuo_mon == 3 & pago_alq_mutuo_m == 3
replace gasto901 = pago_alq_mutuo* `tc4mes3'* `deflactor3' if pago_alq_mutuo_mon == 4 & pago_alq_mutuo_m == 3

// data in many currencies feb2020

replace gasto901 = pago_alq_mutuo* `tc2mes2' if pago_alq_mutuo_mon == 2 & pago_alq_mutuo_m == 2
replace gasto901 = pago_alq_mutuo* `tc3mes2' if pago_alq_mutuo_mon == 3 & pago_alq_mutuo_m == 2
replace gasto901 = pago_alq_mutuo* `tc4mes2' if pago_alq_mutuo_mon == 4 & pago_alq_mutuo_m == 2

// data of Jan and many currencies
replace gasto901 = pago_alq_mutuo* `deflactor1' if pago_alq_mutuo_mon == 1 & pago_alq_mutuo_m == 1
replace gasto901 = pago_alq_mutuo* `tc2mes1'* `deflactor1' if pago_alq_mutuo_mon == 2 & pago_alq_mutuo_m == 1
replace gasto901 = pago_alq_mutuo* `tc3mes1'* `deflactor1' if pago_alq_mutuo_mon == 3 & pago_alq_mutuo_m == 1
replace gasto901 = pago_alq_mutuo* `tc4mes1'* `deflactor1' if pago_alq_mutuo_mon == 4 & pago_alq_mutuo_m == 1


// data of Dec and many currencies
replace gasto901 = pago_alq_mutuo* `deflactor12' if pago_alq_mutuo_mon == 1 & pago_alq_mutuo_m == 12
replace gasto901 = pago_alq_mutuo* `tc2mes12'* `deflactor12' if pago_alq_mutuo_mon == 2 & pago_alq_mutuo_m == 12
replace gasto901 = pago_alq_mutuo* `tc3mes12'* `deflactor12' if pago_alq_mutuo_mon == 3 & pago_alq_mutuo_m == 12
replace gasto901 = pago_alq_mutuo* `tc4mes12'* `deflactor12' if pago_alq_mutuo_mon == 4 & pago_alq_mutuo_m == 12

// data of Nov and many currencies
replace gasto901 = pago_alq_mutuo* `deflactor11' if pago_alq_mutuo_mon == 1 & pago_alq_mutuo_m == 11
replace gasto901 = pago_alq_mutuo* `tc2mes11'* `deflactor11' if pago_alq_mutuo_mon == 2 & pago_alq_mutuo_m == 11
replace gasto901 = pago_alq_mutuo* `tc3mes11'* `deflactor11' if pago_alq_mutuo_mon == 3 & pago_alq_mutuo_m == 11
replace gasto901 = pago_alq_mutuo* `tc4mes11'* `deflactor11' if pago_alq_mutuo_mon == 4 & pago_alq_mutuo_m == 11



*****************renta imputada por el entrevisatado

// data in bolivares feb2020
gen gasto902 = renta_imp_en if renta_imp_mon == 1 // the pop of reference is already based on feb2020


// data in many currencies (feb)
replace gasto902 = renta_imp_en* `tc2mes2' if renta_imp_mon == 2
replace gasto902 = renta_imp_en* `tc3mes2' if renta_imp_mon == 3
replace gasto902 = renta_imp_en* `tc4mes2' if renta_imp_mon == 4

******************inputed rent by analyst
// data in bolivares feb2020
gen gasto903 = renta_imp if renta_imp_mon == 1 //assumed everything was moved in the income module to feb 2020



**********************************************services
// global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m
*******************agua


// data in many currencies (march)
gen gasto911 = pagua_monto* `deflactor3' if pagua_mon == 1 & pagua_m==3
replace gasto911 = pagua_monto* `tc2mes3' * `deflactor3' if pagua_mon == 2 & pagua_m==3
replace gasto911 = pagua_monto* `tc3mes3' * `deflactor3' if pagua_mon == 3 & pagua_m==3
replace gasto911 = pagua_monto* `tc4mes3' * `deflactor3' if pagua_mon == 4 & pagua_m==3


// data in many currencies (feb)
replace gasto911 = pagua_monto if pagua_mon == 1 & pagua_m==2
replace gasto911 = pagua_monto* `tc2mes2' * `deflactor2' if pagua_mon == 2 & pagua_m==2
replace gasto911 = pagua_monto* `tc3mes2' * `deflactor2' if pagua_mon == 3 & pagua_m==2
replace gasto911 = pagua_monto* `tc4mes2' * `deflactor2' if pagua_mon == 4 & pagua_m==2

// data in many currencies (jan)
replace gasto911 = pagua_monto  * `deflactor1' if pagua_mon == 1 & pagua_m==1
replace gasto911 = pagua_monto* `tc2mes1' * `deflactor1' if pagua_mon == 2 & pagua_m==1
replace gasto911 = pagua_monto* `tc3mes1' * `deflactor1' if pagua_mon == 3 & pagua_m==1
replace gasto911 = pagua_monto* `tc4mes1' * `deflactor1' if pagua_mon == 4 & pagua_m==1

// data in many currencies (dec)
replace gasto911 = pagua_monto * `deflactor12' if pagua_mon == 1 & pagua_m==12
replace gasto911 = pagua_monto* `tc2mes12' * `deflactor12' if pagua_mon == 2 & pagua_m==12
replace gasto911 = pagua_monto* `tc3mes12' * `deflactor12' if pagua_mon == 3 & pagua_m==12
replace gasto911 = pagua_monto* `tc4mes12' * `deflactor12' if pagua_mon == 4 & pagua_m==12

// data in many currencies (nov)
replace gasto911 = pagua_monto  * `deflactor11' if pagua_mon == 1 & pagua_m==11
replace gasto911 = pagua_monto* `tc2mes11' * `deflactor11' if pagua_mon == 2 & pagua_m==11
replace gasto911 = pagua_monto* `tc3mes11' * `deflactor11' if pagua_mon == 3 & pagua_m==11
replace gasto911 = pagua_monto* `tc4mes11' * `deflactor11' if pagua_mon == 4 & pagua_m==11


*******************electricidad

// data in many currencies (march)
gen gasto912 = pelect_monto* `deflactor3' if pelect_mon == 1 & pelect_m==3
replace gasto912 = pelect_monto* `tc2mes3' * `deflactor3' if pelect_mon == 2 & pelect_m==3
replace gasto912 = pelect_monto* `tc3mes3' * `deflactor3' if pelect_mon == 3 & pelect_m==3
replace gasto912 = pelect_monto* `tc4mes3' * `deflactor3' if pelect_mon == 4 & pelect_m==3


// data in many currencies (feb)
replace gasto912 = pelect_monto if pelect_mon == 1 & pelect_m==2
replace gasto912 = pelect_monto* `tc2mes2' * `deflactor2' if pelect_mon == 2 & pelect_m==2
replace gasto912 = pelect_monto* `tc3mes2' * `deflactor2' if pelect_mon == 3 & pelect_m==2
replace gasto912 = pelect_monto* `tc4mes2' * `deflactor2' if pelect_mon == 4 & pelect_m==2

// data in many currencies (jan)
replace gasto912 = pelect_monto  * `deflactor1' if pelect_mon == 1 & pelect_m==1
replace gasto912 = pelect_monto* `tc2mes1' * `deflactor1' if pelect_mon == 2 & pelect_m==1
replace gasto912 = pelect_monto* `tc3mes1' * `deflactor1' if pelect_mon == 3 & pelect_m==1
replace gasto912 = pelect_monto* `tc4mes1' * `deflactor1' if pelect_mon == 4 & pelect_m==1

// data in many currencies (dec)
replace gasto912 = pelect_monto * `deflactor12' if pelect_mon == 1 & pelect_m==12
replace gasto912 = pelect_monto* `tc2mes12' * `deflactor12' if pelect_mon == 2 & pelect_m==12
replace gasto912 = pelect_monto* `tc3mes12' * `deflactor12' if pelect_mon == 3 & pelect_m==12
replace gasto912 = pelect_monto* `tc4mes12' * `deflactor12' if pelect_mon == 4 & pelect_m==12

// data in many currencies (nov)
replace gasto912 = pelect_monto  * `deflactor11' if pelect_mon == 1 & pelect_m==11
replace gasto912 = pelect_monto* `tc2mes11' * `deflactor11' if pelect_mon == 2 & pelect_m==11
replace gasto912 = pelect_monto* `tc3mes11' * `deflactor11' if pelect_mon == 3 & pelect_m==11
replace gasto912 = pelect_monto* `tc4mes11' * `deflactor11' if pelect_mon == 4 & pelect_m==11



******************gas
// data in many currencies (march)
gen gasto913 = pgas_monto* `deflactor3' if pgas_mon == 1 & pgas_m==3
replace gasto913 = pgas_monto* `tc2mes3' * `deflactor3' if pgas_mon == 2 & pgas_m==3
replace gasto913 = pgas_monto* `tc3mes3' * `deflactor3' if pgas_mon == 3 & pgas_m==3
replace gasto913 = pgas_monto* `tc4mes3' * `deflactor3' if pgas_mon == 4 & pgas_m==3


// data in many currencies (feb)
replace gasto913 = pgas_monto if pgas_mon == 1 & pgas_m==2
replace gasto913 = pgas_monto* `tc2mes2' * `deflactor2' if pgas_mon == 2 & pgas_m==2
replace gasto913 = pgas_monto* `tc3mes2' * `deflactor2' if pgas_mon == 3 & pgas_m==2
replace gasto913 = pgas_monto* `tc4mes2' * `deflactor2' if pgas_mon == 4 & pgas_m==2

// data in many currencies (jan)
replace gasto913 = pgas_monto  * `deflactor1' if pgas_mon == 1 & pgas_m==1
replace gasto913 = pgas_monto* `tc2mes1' * `deflactor1' if pgas_mon == 2 & pgas_m==1
replace gasto913 = pgas_monto* `tc3mes1' * `deflactor1' if pgas_mon == 3 & pgas_m==1
replace gasto913 = pgas_monto* `tc4mes1' * `deflactor1' if pgas_mon == 4 & pgas_m==1

// data in many currencies (dec)
replace gasto913 = pgas_monto * `deflactor12' if pgas_mon == 1 & pgas_m==12
replace gasto913 = pgas_monto* `tc2mes12' * `deflactor12' if pgas_mon == 2 & pgas_m==12
replace gasto913 = pgas_monto* `tc3mes12' * `deflactor12' if pgas_mon == 3 & pgas_m==12
replace gasto913 = pgas_monto* `tc4mes12' * `deflactor12' if pgas_mon == 4 & pgas_m==12

// data in many currencies (nov)
replace gasto913 = pgas_monto  * `deflactor11' if pgas_mon == 1 & pgas_m==11
replace gasto913 = pgas_monto* `tc2mes11' * `deflactor11' if pgas_mon == 2 & pgas_m==11
replace gasto913 = pgas_monto* `tc3mes11' * `deflactor11' if pgas_mon == 3 & pgas_m==11
replace gasto913 = pgas_monto* `tc4mes11' * `deflactor11' if pgas_mon == 4 & pgas_m==11

******************carbon
// data in many currencies (march)
gen gasto914 = pcarbon_monto* `deflactor3' if pcarbon_mon == 1 & pcarbon_m==3
replace gasto914 = pcarbon_monto* `tc2mes3' * `deflactor3' if pcarbon_mon == 2 & pcarbon_m==3
replace gasto914 = pcarbon_monto* `tc3mes3' * `deflactor3' if pcarbon_mon == 3 & pcarbon_m==3
replace gasto914 = pcarbon_monto* `tc4mes3' * `deflactor3' if pcarbon_mon == 4 & pcarbon_m==3


// data in many currencies (feb)
replace gasto914 = pcarbon_monto if pcarbon_mon == 1 & pcarbon_m==2
replace gasto914 = pcarbon_monto* `tc2mes2' * `deflactor2' if pcarbon_mon == 2 & pcarbon_m==2
replace gasto914 = pcarbon_monto* `tc3mes2' * `deflactor2' if pcarbon_mon == 3 & pcarbon_m==2
replace gasto914 = pcarbon_monto* `tc4mes2' * `deflactor2' if pcarbon_mon == 4 & pcarbon_m==2

// data in many currencies (jan)
replace gasto914 = pcarbon_monto  * `deflactor1' if pcarbon_mon == 1 & pcarbon_m==1
replace gasto914 = pcarbon_monto* `tc2mes1' * `deflactor1' if pcarbon_mon == 2 & pcarbon_m==1
replace gasto914 = pcarbon_monto* `tc3mes1' * `deflactor1' if pcarbon_mon == 3 & pcarbon_m==1
replace gasto914 = pcarbon_monto* `tc4mes1' * `deflactor1' if pcarbon_mon == 4 & pcarbon_m==1

// data in many currencies (dec)
replace gasto914 = pcarbon_monto * `deflactor12' if pcarbon_mon == 1 & pcarbon_m==12
replace gasto914 = pcarbon_monto* `tc2mes12' * `deflactor12' if pcarbon_mon == 2 & pcarbon_m==12
replace gasto914 = pcarbon_monto* `tc3mes12' * `deflactor12' if pcarbon_mon == 3 & pcarbon_m==12
replace gasto914 = pcarbon_monto* `tc4mes12' * `deflactor12' if pcarbon_mon == 4 & pcarbon_m==12

// data in many currencies (nov)
replace gasto914 = pcarbon_monto  * `deflactor11' if pcarbon_mon == 1 & pcarbon_m==11
replace gasto914 = pcarbon_monto* `tc2mes11' * `deflactor11' if pcarbon_mon == 2 & pcarbon_m==11
replace gasto914 = pcarbon_monto* `tc3mes11' * `deflactor11' if pcarbon_mon == 3 & pcarbon_m==11
replace gasto914 = pcarbon_monto* `tc4mes11' * `deflactor11' if pcarbon_mon == 4 & pcarbon_m==11


******************parafina
// data in many currencies (march)
gen gasto915 = pparafina_monto* `deflactor3' if pparafina_mon == 1 & pparafina_m==3
replace gasto915 = pparafina_monto* `tc2mes3' * `deflactor3' if pparafina_mon == 2 & pparafina_m==3
replace gasto915 = pparafina_monto* `tc3mes3' * `deflactor3' if pparafina_mon == 3 & pparafina_m==3
replace gasto915 = pparafina_monto* `tc4mes3' * `deflactor3' if pparafina_mon == 4 & pparafina_m==3


// data in many currencies (feb)
replace gasto915 = pparafina_monto if pparafina_mon == 1 & pparafina_m==2
replace gasto915 = pparafina_monto* `tc2mes2' * `deflactor2' if pparafina_mon == 2 & pparafina_m==2
replace gasto915 = pparafina_monto* `tc3mes2' * `deflactor2' if pparafina_mon == 3 & pparafina_m==2
replace gasto915 = pparafina_monto* `tc4mes2' * `deflactor2' if pparafina_mon == 4 & pparafina_m==2

// data in many currencies (jan)
replace gasto915 = pparafina_monto  * `deflactor1' if pparafina_mon == 1 & pparafina_m==1
replace gasto915 = pparafina_monto* `tc2mes1' * `deflactor1' if pparafina_mon == 2 & pparafina_m==1
replace gasto915 = pparafina_monto* `tc3mes1' * `deflactor1' if pparafina_mon == 3 & pparafina_m==1
replace gasto915 = pparafina_monto* `tc4mes1' * `deflactor1' if pparafina_mon == 4 & pparafina_m==1

// data in many currencies (dec)
replace gasto915 = pparafina_monto * `deflactor12' if pparafina_mon == 1 & pparafina_m==12
replace gasto915 = pparafina_monto* `tc2mes12' * `deflactor12' if pparafina_mon == 2 & pparafina_m==12
replace gasto915 = pparafina_monto* `tc3mes12' * `deflactor12' if pparafina_mon == 3 & pparafina_m==12
replace gasto915 = pparafina_monto* `tc4mes12' * `deflactor12' if pparafina_mon == 4 & pparafina_m==12

// data in many currencies (nov)
replace gasto915 = pparafina_monto  * `deflactor11' if pparafina_mon == 1 & pparafina_m==11
replace gasto915 = pparafina_monto* `tc2mes11' * `deflactor11' if pparafina_mon == 2 & pparafina_m==11
replace gasto915 = pparafina_monto* `tc3mes11' * `deflactor11' if pparafina_mon == 3 & pparafina_m==11
replace gasto915 = pparafina_monto* `tc4mes11' * `deflactor11' if pparafina_mon == 4 & pparafina_m==11

******************telefono
// data in many currencies (march)
gen gasto916 = ptelefono_monto* `deflactor3' if ptelefono_mon == 1 & ptelefono_m==3
replace gasto916 = ptelefono_monto* `tc2mes3' * `deflactor3' if ptelefono_mon == 2 & ptelefono_m==3
replace gasto916 = ptelefono_monto* `tc3mes3' * `deflactor3' if ptelefono_mon == 3 & ptelefono_m==3
replace gasto916 = ptelefono_monto* `tc4mes3' * `deflactor3' if ptelefono_mon == 4 & ptelefono_m==3


// data in many currencies (feb)
replace gasto916 = ptelefono_monto if ptelefono_mon == 1 & ptelefono_m==2
replace gasto916 = ptelefono_monto* `tc2mes2' * `deflactor2' if ptelefono_mon == 2 & ptelefono_m==2
replace gasto916 = ptelefono_monto* `tc3mes2' * `deflactor2' if ptelefono_mon == 3 & ptelefono_m==2
replace gasto916 = ptelefono_monto* `tc4mes2' * `deflactor2' if ptelefono_mon == 4 & ptelefono_m==2

// data in many currencies (jan)
replace gasto916 = ptelefono_monto  * `deflactor1' if ptelefono_mon == 1 & ptelefono_m==1
replace gasto916 = ptelefono_monto* `tc2mes1' * `deflactor1' if ptelefono_mon == 2 & ptelefono_m==1
replace gasto916 = ptelefono_monto* `tc3mes1' * `deflactor1' if ptelefono_mon == 3 & ptelefono_m==1
replace gasto916 = ptelefono_monto* `tc4mes1' * `deflactor1' if ptelefono_mon == 4 & ptelefono_m==1

// data in many currencies (dec)
replace gasto916 = ptelefono_monto * `deflactor12' if ptelefono_mon == 1 & ptelefono_m==12
replace gasto916 = ptelefono_monto* `tc2mes12' * `deflactor12' if ptelefono_mon == 2 & ptelefono_m==12
replace gasto916 = ptelefono_monto* `tc3mes12' * `deflactor12' if ptelefono_mon == 3 & ptelefono_m==12
replace gasto916 = ptelefono_monto* `tc4mes12' * `deflactor12' if ptelefono_mon == 4 & ptelefono_m==12

// data in many currencies (nov)
replace gasto916 = ptelefono_monto  * `deflactor11' if ptelefono_mon == 1 & ptelefono_m==11
replace gasto916 = ptelefono_monto* `tc2mes11' * `deflactor11' if ptelefono_mon == 2 & ptelefono_m==11
replace gasto916 = ptelefono_monto* `tc3mes11' * `deflactor11' if ptelefono_mon == 3 & ptelefono_m==11
replace gasto916 = ptelefono_monto* `tc4mes11' * `deflactor11' if ptelefono_mon == 4 & ptelefono_m==11




****************************************educacion
//
// global educvar cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

*********************inscripcion (assumed annual freq)

// data in many currencies (march)
gen gasto921 = cuota_insc_monto* `deflactor3' if cuota_insc_mon == 1 & cuota_insc_m==3
replace gasto921 = cuota_insc_monto/12* `tc2mes3' * `deflactor3' if cuota_insc_mon == 2 & cuota_insc_m==3
replace gasto921 = cuota_insc_monto/12* `tc3mes3' * `deflactor3' if cuota_insc_mon == 3 & cuota_insc_m==3
replace gasto921 = cuota_insc_monto/12* `tc4mes3' * `deflactor3' if cuota_insc_mon == 4 & cuota_insc_m==3


// data in many currencies (feb)
replace gasto921 = cuota_insc_monto/12 if cuota_insc_mon == 1 & cuota_insc_m==2
replace gasto921 = cuota_insc_monto/12* `tc2mes2' * `deflactor2' if cuota_insc_mon == 2 & cuota_insc_m==2
replace gasto921 = cuota_insc_monto/12* `tc3mes2' * `deflactor2' if cuota_insc_mon == 3 & cuota_insc_m==2
replace gasto921 = cuota_insc_monto/12* `tc4mes2' * `deflactor2' if cuota_insc_mon == 4 & cuota_insc_m==2

// data in many currencies (jan)
replace gasto921 = cuota_insc_monto/12  * `deflactor1' if cuota_insc_mon == 1 & cuota_insc_m==1
replace gasto921 = cuota_insc_monto/12* `tc2mes1' * `deflactor1' if cuota_insc_mon == 2 & cuota_insc_m==1
replace gasto921 = cuota_insc_monto/12* `tc3mes1' * `deflactor1' if cuota_insc_mon == 3 & cuota_insc_m==1
replace gasto921 = cuota_insc_monto/12* `tc4mes1' * `deflactor1' if cuota_insc_mon == 4 & cuota_insc_m==1

// data in many currencies (dec)
replace gasto921 = cuota_insc_monto/12 * `deflactor12' if cuota_insc_mon == 1 & cuota_insc_m==12
replace gasto921 = cuota_insc_monto/12* `tc2mes12' * `deflactor12' if cuota_insc_mon == 2 & cuota_insc_m==12
replace gasto921 = cuota_insc_monto/12* `tc3mes12' * `deflactor12' if cuota_insc_mon == 3 & cuota_insc_m==12
replace gasto921 = cuota_insc_monto/12* `tc4mes12' * `deflactor12' if cuota_insc_mon == 4 & cuota_insc_m==12

// data in many currencies (nov)
replace gasto921 = cuota_insc_monto/12  * `deflactor11' if cuota_insc_mon == 1 & cuota_insc_m==11
replace gasto921 = cuota_insc_monto/12* `tc2mes11' * `deflactor11' if cuota_insc_mon == 2 & cuota_insc_m==11
replace gasto921 = cuota_insc_monto/12* `tc3mes11' * `deflactor11' if cuota_insc_mon == 3 & cuota_insc_m==11
replace gasto921 = cuota_insc_monto/12* `tc4mes11' * `deflactor11' if cuota_insc_mon == 4 & cuota_insc_m==11


*********************utiles (assumed annual freq)

// data in many currencies (march)
gen gasto922 = compra_utiles_monto/12* `deflactor3' if compra_utiles_mon == 1 & compra_utiles_m==3
replace gasto922 = compra_utiles_monto/12* `tc2mes3' * `deflactor3' if compra_utiles_mon == 2 & compra_utiles_m==3
replace gasto922 = compra_utiles_monto/12* `tc3mes3' * `deflactor3' if compra_utiles_mon == 3 & compra_utiles_m==3
replace gasto922 = compra_utiles_monto/12* `tc4mes3' * `deflactor3' if compra_utiles_mon == 4 & compra_utiles_m==3


// data in many currencies (feb)
replace gasto922 = compra_utiles_monto/12 if compra_utiles_mon == 1 & compra_utiles_m==2
replace gasto922 = compra_utiles_monto/12* `tc2mes2' * `deflactor2' if compra_utiles_mon == 2 & compra_utiles_m==2
replace gasto922 = compra_utiles_monto/12* `tc3mes2' * `deflactor2' if compra_utiles_mon == 3 & compra_utiles_m==2
replace gasto922 = compra_utiles_monto/12* `tc4mes2' * `deflactor2' if compra_utiles_mon == 4 & compra_utiles_m==2

// data in many currencies (jan)
replace gasto922 = compra_utiles_monto/12  * `deflactor1' if compra_utiles_mon == 1 & compra_utiles_m==1
replace gasto922 = compra_utiles_monto/12* `tc2mes1' * `deflactor1' if compra_utiles_mon == 2 & compra_utiles_m==1
replace gasto922 = compra_utiles_monto/12* `tc3mes1' * `deflactor1' if compra_utiles_mon == 3 & compra_utiles_m==1
replace gasto922 = compra_utiles_monto/12* `tc4mes1' * `deflactor1' if compra_utiles_mon == 4 & compra_utiles_m==1

// data in many currencies (dec)
replace gasto922 = compra_utiles_monto/12 * `deflactor12' if compra_utiles_mon == 1 & compra_utiles_m==12
replace gasto922 = compra_utiles_monto/12* `tc2mes12' * `deflactor12' if compra_utiles_mon == 2 & compra_utiles_m==12
replace gasto922 = compra_utiles_monto/12* `tc3mes12' * `deflactor12' if compra_utiles_mon == 3 & compra_utiles_m==12
replace gasto922 = compra_utiles_monto/12* `tc4mes12' * `deflactor12' if compra_utiles_mon == 4 & compra_utiles_m==12

// data in many currencies (nov)
replace gasto922 = compra_utiles_monto/12  * `deflactor11' if compra_utiles_mon == 1 & compra_utiles_m==11
replace gasto922 = compra_utiles_monto/12* `tc2mes11' * `deflactor11' if compra_utiles_mon == 2 & compra_utiles_m==11
replace gasto922 = compra_utiles_monto/12* `tc3mes11' * `deflactor11' if compra_utiles_mon == 3 & compra_utiles_m==11
replace gasto922 = compra_utiles_monto/12* `tc4mes11' * `deflactor11' if compra_utiles_mon == 4 & compra_utiles_m==11

*********************uniformes (assumed annual freq)

// data in many currencies (march)
gen gasto923 = compra_uniforme_monto/12* `deflactor3' if compra_uniforme_mon == 1 & compra_uniforme_m==3
replace gasto923 = compra_uniforme_monto/12* `tc2mes3' * `deflactor3' if compra_uniforme_mon == 2 & compra_uniforme_m==3
replace gasto923 = compra_uniforme_monto/12* `tc3mes3' * `deflactor3' if compra_uniforme_mon == 3 & compra_uniforme_m==3
replace gasto923 = compra_uniforme_monto/12* `tc4mes3' * `deflactor3' if compra_uniforme_mon == 4 & compra_uniforme_m==3


// data in many currencies (feb)
replace gasto923 = compra_uniforme_monto/12 if compra_uniforme_mon == 1 & compra_uniforme_m==2
replace gasto923 = compra_uniforme_monto/12* `tc2mes2' * `deflactor2' if compra_uniforme_mon == 2 & compra_uniforme_m==2
replace gasto923 = compra_uniforme_monto/12* `tc3mes2' * `deflactor2' if compra_uniforme_mon == 3 & compra_uniforme_m==2
replace gasto923 = compra_uniforme_monto/12* `tc4mes2' * `deflactor2' if compra_uniforme_mon == 4 & compra_uniforme_m==2

// data in many currencies (jan)
replace gasto923 = compra_uniforme_monto/12  * `deflactor1' if compra_uniforme_mon == 1 & compra_uniforme_m==1
replace gasto923 = compra_uniforme_monto/12* `tc2mes1' * `deflactor1' if compra_uniforme_mon == 2 & compra_uniforme_m==1
replace gasto923 = compra_uniforme_monto/12* `tc3mes1' * `deflactor1' if compra_uniforme_mon == 3 & compra_uniforme_m==1
replace gasto923 = compra_uniforme_monto/12* `tc4mes1' * `deflactor1' if compra_uniforme_mon == 4 & compra_uniforme_m==1

// data in many currencies (dec)
replace gasto923 = compra_uniforme_monto/12 * `deflactor12' if compra_uniforme_mon == 1 & compra_uniforme_m==12
replace gasto923 = compra_uniforme_monto/12* `tc2mes12' * `deflactor12' if compra_uniforme_mon == 2 & compra_uniforme_m==12
replace gasto923 = compra_uniforme_monto/12* `tc3mes12' * `deflactor12' if compra_uniforme_mon == 3 & compra_uniforme_m==12
replace gasto923 = compra_uniforme_monto/12* `tc4mes12' * `deflactor12' if compra_uniforme_mon == 4 & compra_uniforme_m==12

// data in many currencies (nov)
replace gasto923 = compra_uniforme_monto/12  * `deflactor11' if compra_uniforme_mon == 1 & compra_uniforme_m==11
replace gasto923 = compra_uniforme_monto/12* `tc2mes11' * `deflactor11' if compra_uniforme_mon == 2 & compra_uniforme_m==11
replace gasto923 = compra_uniforme_monto/12* `tc3mes11' * `deflactor11' if compra_uniforme_mon == 3 & compra_uniforme_m==11
replace gasto923 = compra_uniforme_monto/12* `tc4mes11' * `deflactor11' if compra_uniforme_mon == 4 & compra_uniforme_m==11

*********************costo mensual (assumed mensual freq)

// data in many currencies (march)
gen gasto924 = costo_men_monto* `deflactor3' if costo_men_mon == 1 & costo_men_m==3
replace gasto924 = costo_men_monto* `tc2mes3' * `deflactor3' if costo_men_mon == 2 & costo_men_m==3
replace gasto924 = costo_men_monto* `tc3mes3' * `deflactor3' if costo_men_mon == 3 & costo_men_m==3
replace gasto924 = costo_men_monto* `tc4mes3' * `deflactor3' if costo_men_mon == 4 & costo_men_m==3


// data in many currencies (feb)
replace gasto924 = costo_men_monto if costo_men_mon == 1 & costo_men_m==2
replace gasto924 = costo_men_monto* `tc2mes2' * `deflactor2' if costo_men_mon == 2 & costo_men_m==2
replace gasto924 = costo_men_monto* `tc3mes2' * `deflactor2' if costo_men_mon == 3 & costo_men_m==2
replace gasto924 = costo_men_monto* `tc4mes2' * `deflactor2' if costo_men_mon == 4 & costo_men_m==2

// data in many currencies (jan)
replace gasto924 = costo_men_monto  * `deflactor1' if costo_men_mon == 1 & costo_men_m==1
replace gasto924 = costo_men_monto* `tc2mes1' * `deflactor1' if costo_men_mon == 2 & costo_men_m==1
replace gasto924 = costo_men_monto* `tc3mes1' * `deflactor1' if costo_men_mon == 3 & costo_men_m==1
replace gasto924 = costo_men_monto* `tc4mes1' * `deflactor1' if costo_men_mon == 4 & costo_men_m==1

// data in many currencies (dec)
replace gasto924 = costo_men_monto * `deflactor12' if costo_men_mon == 1 & costo_men_m==12
replace gasto924 = costo_men_monto* `tc2mes12' * `deflactor12' if costo_men_mon == 2 & costo_men_m==12
replace gasto924 = costo_men_monto* `tc3mes12' * `deflactor12' if costo_men_mon == 3 & costo_men_m==12
replace gasto924 = costo_men_monto* `tc4mes12' * `deflactor12' if costo_men_mon == 4 & costo_men_m==12

// data in many currencies (nov)
replace gasto924 = costo_men_monto  * `deflactor11' if costo_men_mon == 1 & costo_men_m==11
replace gasto924 = costo_men_monto* `tc2mes11' * `deflactor11' if costo_men_mon == 2 & costo_men_m==11
replace gasto924 = costo_men_monto* `tc3mes11' * `deflactor11' if costo_men_mon == 3 & costo_men_m==11
replace gasto924 = costo_men_monto* `tc4mes11' * `deflactor11' if costo_men_mon == 4 & costo_men_m==11


*********************costo transporte (assumed mensual freq)

// data in many currencies (march)
gen gasto925 = costo_transp_monto* `deflactor3' if costo_transp_mon == 1 & costo_transp_m==3
replace gasto925 = costo_transp_monto* `tc2mes3' * `deflactor3' if costo_transp_mon == 2 & costo_transp_m==3
replace gasto925 = costo_transp_monto* `tc3mes3' * `deflactor3' if costo_transp_mon == 3 & costo_transp_m==3
replace gasto925 = costo_transp_monto* `tc4mes3' * `deflactor3' if costo_transp_mon == 4 & costo_transp_m==3


// data in many currencies (feb)
replace gasto925 = costo_transp_monto if costo_transp_mon == 1 & costo_transp_m==2
replace gasto925 = costo_transp_monto* `tc2mes2' * `deflactor2' if costo_transp_mon == 2 & costo_transp_m==2
replace gasto925 = costo_transp_monto* `tc3mes2' * `deflactor2' if costo_transp_mon == 3 & costo_transp_m==2
replace gasto925 = costo_transp_monto* `tc4mes2' * `deflactor2' if costo_transp_mon == 4 & costo_transp_m==2

// data in many currencies (jan)
replace gasto925 = costo_transp_monto  * `deflactor1' if costo_transp_mon == 1 & costo_transp_m==1
replace gasto925 = costo_transp_monto* `tc2mes1' * `deflactor1' if costo_transp_mon == 2 & costo_transp_m==1
replace gasto925 = costo_transp_monto* `tc3mes1' * `deflactor1' if costo_transp_mon == 3 & costo_transp_m==1
replace gasto925 = costo_transp_monto* `tc4mes1' * `deflactor1' if costo_transp_mon == 4 & costo_transp_m==1

// data in many currencies (dec)
replace gasto925 = costo_transp_monto * `deflactor12' if costo_transp_mon == 1 & costo_transp_m==12
replace gasto925 = costo_transp_monto* `tc2mes12' * `deflactor12' if costo_transp_mon == 2 & costo_transp_m==12
replace gasto925 = costo_transp_monto* `tc3mes12' * `deflactor12' if costo_transp_mon == 3 & costo_transp_m==12
replace gasto925 = costo_transp_monto* `tc4mes12' * `deflactor12' if costo_transp_mon == 4 & costo_transp_m==12

// data in many currencies (nov)
replace gasto925 = costo_transp_monto  * `deflactor11' if costo_transp_mon == 1 & costo_transp_m==11
replace gasto925 = costo_transp_monto* `tc2mes11' * `deflactor11' if costo_transp_mon == 2 & costo_transp_m==11
replace gasto925 = costo_transp_monto* `tc3mes11' * `deflactor11' if costo_transp_mon == 3 & costo_transp_m==11
replace gasto925 = costo_transp_monto* `tc4mes11' * `deflactor11' if costo_transp_mon == 4 & costo_transp_m==11



*********************otros gastos (assumed mensual freq)

// data in many currencies (march)
gen gasto926 = otros_gastos_monto* `deflactor3' if otros_gastos_mon == 1 & otros_gastos_m==3
replace gasto926 = otros_gastos_monto* `tc2mes3' * `deflactor3' if otros_gastos_mon == 2 & otros_gastos_m==3
replace gasto926 = otros_gastos_monto* `tc3mes3' * `deflactor3' if otros_gastos_mon == 3 & otros_gastos_m==3
replace gasto926 = otros_gastos_monto* `tc4mes3' * `deflactor3' if otros_gastos_mon == 4 & otros_gastos_m==3


// data in many currencies (feb)
replace gasto926 = otros_gastos_monto if otros_gastos_mon == 1 & otros_gastos_m==2
replace gasto926 = otros_gastos_monto* `tc2mes2' * `deflactor2' if otros_gastos_mon == 2 & otros_gastos_m==2
replace gasto926 = otros_gastos_monto* `tc3mes2' * `deflactor2' if otros_gastos_mon == 3 & otros_gastos_m==2
replace gasto926 = otros_gastos_monto* `tc4mes2' * `deflactor2' if otros_gastos_mon == 4 & otros_gastos_m==2

// data in many currencies (jan)
replace gasto926 = otros_gastos_monto  * `deflactor1' if otros_gastos_mon == 1 & otros_gastos_m==1
replace gasto926 = otros_gastos_monto* `tc2mes1' * `deflactor1' if otros_gastos_mon == 2 & otros_gastos_m==1
replace gasto926 = otros_gastos_monto* `tc3mes1' * `deflactor1' if otros_gastos_mon == 3 & otros_gastos_m==1
replace gasto926 = otros_gastos_monto* `tc4mes1' * `deflactor1' if otros_gastos_mon == 4 & otros_gastos_m==1

// data in many currencies (dec)
replace gasto926 = otros_gastos_monto * `deflactor12' if otros_gastos_mon == 1 & otros_gastos_m==12
replace gasto926 = otros_gastos_monto* `tc2mes12' * `deflactor12' if otros_gastos_mon == 2 & otros_gastos_m==12
replace gasto926 = otros_gastos_monto* `tc3mes12' * `deflactor12' if otros_gastos_mon == 3 & otros_gastos_m==12
replace gasto926 = otros_gastos_monto* `tc4mes12' * `deflactor12' if otros_gastos_mon == 4 & otros_gastos_m==12

// data in many currencies (nov)
replace gasto926 = otros_gastos_monto  * `deflactor11' if otros_gastos_mon == 1 & otros_gastos_m==11
replace gasto926 = otros_gastos_monto* `tc2mes11' * `deflactor11' if otros_gastos_mon == 2 & otros_gastos_m==11
replace gasto926 = otros_gastos_monto* `tc3mes11' * `deflactor11' if otros_gastos_mon == 3 & otros_gastos_m==11
replace gasto926 = otros_gastos_monto* `tc4mes11' * `deflactor11' if otros_gastos_mon == 4 & otros_gastos_m==11


*******************************************salud

// global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

********************pago consulta (assumed mensual)

// data in many currencies (march)
gen gasto931 = cant_pago_consulta* `deflactor3' if mone_pago_consulta == 1 & mes_pago_consulta==3
replace gasto931 = cant_pago_consulta* `tc2mes3' * `deflactor3' if mone_pago_consulta == 2 & mes_pago_consulta==3
replace gasto931 = cant_pago_consulta* `tc3mes3' * `deflactor3' if mone_pago_consulta == 3 & mes_pago_consulta==3
replace gasto931 = cant_pago_consulta* `tc4mes3' * `deflactor3' if mone_pago_consulta == 4 & mes_pago_consulta==3


// data in many currencies (feb)
replace gasto931 = cant_pago_consulta if mone_pago_consulta == 1 & mes_pago_consulta==2
replace gasto931 = cant_pago_consulta* `tc2mes2' * `deflactor2' if mone_pago_consulta == 2 & mes_pago_consulta==2
replace gasto931 = cant_pago_consulta* `tc3mes2' * `deflactor2' if mone_pago_consulta == 3 & mes_pago_consulta==2
replace gasto931 = cant_pago_consulta* `tc4mes2' * `deflactor2' if mone_pago_consulta == 4 & mes_pago_consulta==2

// data in many currencies (jan)
replace gasto931 = cant_pago_consulta  * `deflactor1' if mone_pago_consulta == 1 & mes_pago_consulta==1
replace gasto931 = cant_pago_consulta* `tc2mes1' * `deflactor1' if mone_pago_consulta == 2 & mes_pago_consulta==1
replace gasto931 = cant_pago_consulta* `tc3mes1' * `deflactor1' if mone_pago_consulta == 3 & mes_pago_consulta==1
replace gasto931 = cant_pago_consulta* `tc4mes1' * `deflactor1' if mone_pago_consulta == 4 & mes_pago_consulta==1

// data in many currencies (dec)
replace gasto931 = cant_pago_consulta * `deflactor12' if mone_pago_consulta == 1 & mes_pago_consulta==12
replace gasto931 = cant_pago_consulta* `tc2mes12' * `deflactor12' if mone_pago_consulta == 2 & mes_pago_consulta==12
replace gasto931 = cant_pago_consulta* `tc3mes12' * `deflactor12' if mone_pago_consulta == 3 & mes_pago_consulta==12
replace gasto931 = cant_pago_consulta* `tc4mes12' * `deflactor12' if mone_pago_consulta == 4 & mes_pago_consulta==12

// data in many currencies (nov)
replace gasto931 = cant_pago_consulta  * `deflactor11' if mone_pago_consulta == 1 & mes_pago_consulta==11
replace gasto931 = cant_pago_consulta* `tc2mes11' * `deflactor11' if mone_pago_consulta == 2 & mes_pago_consulta==11
replace gasto931 = cant_pago_consulta* `tc3mes11' * `deflactor11' if mone_pago_consulta == 3 & mes_pago_consulta==11
replace gasto931 = cant_pago_consulta* `tc4mes11' * `deflactor11' if mone_pago_consulta == 4 & mes_pago_consulta==11


********************pago remedio (assumed mensual)

// data in many currencies (march)
gen gasto932 = pago_remedio* `deflactor3' if mone_pago_remedio == 1 & mes_pago_remedio==3
replace gasto932 = pago_remedio* `tc2mes3' * `deflactor3' if mone_pago_remedio == 2 & mes_pago_remedio==3
replace gasto932 = pago_remedio* `tc3mes3' * `deflactor3' if mone_pago_remedio == 3 & mes_pago_remedio==3
replace gasto932 = pago_remedio* `tc4mes3' * `deflactor3' if mone_pago_remedio == 4 & mes_pago_remedio==3


// data in many currencies (feb)
replace gasto932 = pago_remedio if mone_pago_remedio == 1 & mes_pago_remedio==2
replace gasto932 = pago_remedio* `tc2mes2' * `deflactor2' if mone_pago_remedio == 2 & mes_pago_remedio==2
replace gasto932 = pago_remedio* `tc3mes2' * `deflactor2' if mone_pago_remedio == 3 & mes_pago_remedio==2
replace gasto932 = pago_remedio* `tc4mes2' * `deflactor2' if mone_pago_remedio == 4 & mes_pago_remedio==2

// data in many currencies (jan)
replace gasto932 = pago_remedio  * `deflactor1' if mone_pago_remedio == 1 & mes_pago_remedio==1
replace gasto932 = pago_remedio* `tc2mes1' * `deflactor1' if mone_pago_remedio == 2 & mes_pago_remedio==1
replace gasto932 = pago_remedio* `tc3mes1' * `deflactor1' if mone_pago_remedio == 3 & mes_pago_remedio==1
replace gasto932 = pago_remedio* `tc4mes1' * `deflactor1' if mone_pago_remedio == 4 & mes_pago_remedio==1

// data in many currencies (dec)
replace gasto932 = pago_remedio * `deflactor12' if mone_pago_remedio == 1 & mes_pago_remedio==12
replace gasto932 = pago_remedio* `tc2mes12' * `deflactor12' if mone_pago_remedio == 2 & mes_pago_remedio==12
replace gasto932 = pago_remedio* `tc3mes12' * `deflactor12' if mone_pago_remedio == 3 & mes_pago_remedio==12
replace gasto932 = pago_remedio* `tc4mes12' * `deflactor12' if mone_pago_remedio == 4 & mes_pago_remedio==12

// data in many currencies (nov)
replace gasto932 = pago_remedio  * `deflactor11' if mone_pago_remedio == 1 & mes_pago_remedio==11
replace gasto932 = pago_remedio* `tc2mes11' * `deflactor11' if mone_pago_remedio == 2 & mes_pago_remedio==11
replace gasto932 = pago_remedio* `tc3mes11' * `deflactor11' if mone_pago_remedio == 3 & mes_pago_remedio==11
replace gasto932 = pago_remedio* `tc4mes11' * `deflactor11' if mone_pago_remedio == 4 & mes_pago_remedio==11

********************pago examen (assumed mensual)

// data in many currencies (march)
gen gasto933 = pago_examen* `deflactor3' if mone_pago_examen == 1 & mes_pago_examen==3
replace gasto933 = pago_examen* `tc2mes3' * `deflactor3' if mone_pago_examen == 2 & mes_pago_examen==3
replace gasto933 = pago_examen* `tc3mes3' * `deflactor3' if mone_pago_examen == 3 & mes_pago_examen==3
replace gasto933 = pago_examen* `tc4mes3' * `deflactor3' if mone_pago_examen == 4 & mes_pago_examen==3


// data in many currencies (feb)
replace gasto933 = pago_examen if mone_pago_examen == 1 & mes_pago_examen==2
replace gasto933 = pago_examen* `tc2mes2' * `deflactor2' if mone_pago_examen == 2 & mes_pago_examen==2
replace gasto933 = pago_examen* `tc3mes2' * `deflactor2' if mone_pago_examen == 3 & mes_pago_examen==2
replace gasto933 = pago_examen* `tc4mes2' * `deflactor2' if mone_pago_examen == 4 & mes_pago_examen==2

// data in many currencies (jan)
replace gasto933 = pago_examen  * `deflactor1' if mone_pago_examen == 1 & mes_pago_examen==1
replace gasto933 = pago_examen* `tc2mes1' * `deflactor1' if mone_pago_examen == 2 & mes_pago_examen==1
replace gasto933 = pago_examen* `tc3mes1' * `deflactor1' if mone_pago_examen == 3 & mes_pago_examen==1
replace gasto933 = pago_examen* `tc4mes1' * `deflactor1' if mone_pago_examen == 4 & mes_pago_examen==1

// data in many currencies (dec)
replace gasto933 = pago_examen * `deflactor12' if mone_pago_examen == 1 & mes_pago_examen==12
replace gasto933 = pago_examen* `tc2mes12' * `deflactor12' if mone_pago_examen == 2 & mes_pago_examen==12
replace gasto933 = pago_examen* `tc3mes12' * `deflactor12' if mone_pago_examen == 3 & mes_pago_examen==12
replace gasto933 = pago_examen* `tc4mes12' * `deflactor12' if mone_pago_examen == 4 & mes_pago_examen==12

// data in many currencies (nov)
replace gasto933 = pago_examen  * `deflactor11' if mone_pago_examen == 1 & mes_pago_examen==11
replace gasto933 = pago_examen* `tc2mes11' * `deflactor11' if mone_pago_examen == 2 & mes_pago_examen==11
replace gasto933 = pago_examen* `tc3mes11' * `deflactor11' if mone_pago_examen == 3 & mes_pago_examen==11
replace gasto933 = pago_examen* `tc4mes11' * `deflactor11' if mone_pago_examen == 4 & mes_pago_examen==11



********************remedios 3 meses (assumed trimestral)

// data in many currencies (march)
gen gasto934 = cant_remedio_tresmeses/3* `deflactor3' if mone_remedio_tresmeses == 1 & mes_remedio_tresmeses==3
replace gasto934 = cant_remedio_tresmeses/3* `tc2mes3' * `deflactor3' if mone_remedio_tresmeses == 2 & mes_remedio_tresmeses==3
replace gasto934 = cant_remedio_tresmeses/3* `tc3mes3' * `deflactor3' if mone_remedio_tresmeses == 3 & mes_remedio_tresmeses==3
replace gasto934 = cant_remedio_tresmeses/3* `tc4mes3' * `deflactor3' if mone_remedio_tresmeses == 4 & mes_remedio_tresmeses==3


// data in many currencies (feb)
replace gasto934 = cant_remedio_tresmeses/3 if mone_remedio_tresmeses == 1 & mes_remedio_tresmeses==2
replace gasto934 = cant_remedio_tresmeses/3* `tc2mes2' * `deflactor2' if mone_remedio_tresmeses == 2 & mes_remedio_tresmeses==2
replace gasto934 = cant_remedio_tresmeses/3* `tc3mes2' * `deflactor2' if mone_remedio_tresmeses == 3 & mes_remedio_tresmeses==2
replace gasto934 = cant_remedio_tresmeses/3* `tc4mes2' * `deflactor2' if mone_remedio_tresmeses == 4 & mes_remedio_tresmeses==2

// data in many currencies (jan)
replace gasto934 = cant_remedio_tresmeses/3  * `deflactor1' if mone_remedio_tresmeses == 1 & mes_remedio_tresmeses==1
replace gasto934 = cant_remedio_tresmeses/3* `tc2mes1' * `deflactor1' if mone_remedio_tresmeses == 2 & mes_remedio_tresmeses==1
replace gasto934 = cant_remedio_tresmeses/3* `tc3mes1' * `deflactor1' if mone_remedio_tresmeses == 3 & mes_remedio_tresmeses==1
replace gasto934 = cant_remedio_tresmeses/3* `tc4mes1' * `deflactor1' if mone_remedio_tresmeses == 4 & mes_remedio_tresmeses==1

// data in many currencies (dec)
replace gasto934 = cant_remedio_tresmeses/3 * `deflactor12' if mone_remedio_tresmeses == 1 & mes_remedio_tresmeses==12
replace gasto934 = cant_remedio_tresmeses/3* `tc2mes12' * `deflactor12' if mone_remedio_tresmeses == 2 & mes_remedio_tresmeses==12
replace gasto934 = cant_remedio_tresmeses/3* `tc3mes12' * `deflactor12' if mone_remedio_tresmeses == 3 & mes_remedio_tresmeses==12
replace gasto934 = cant_remedio_tresmeses/3* `tc4mes12' * `deflactor12' if mone_remedio_tresmeses == 4 & mes_remedio_tresmeses==12

// data in many currencies (nov)
replace gasto934 = cant_remedio_tresmeses/3  * `deflactor11' if mone_remedio_tresmeses == 1 & mes_remedio_tresmeses==11
replace gasto934 = cant_remedio_tresmeses/3* `tc2mes11' * `deflactor11' if mone_remedio_tresmeses == 2 & mes_remedio_tresmeses==11
replace gasto934 = cant_remedio_tresmeses/3* `tc3mes11' * `deflactor11' if mone_remedio_tresmeses == 3 & mes_remedio_tresmeses==11
replace gasto934 = cant_remedio_tresmeses/3* `tc4mes11' * `deflactor11' if mone_remedio_tresmeses == 4 & mes_remedio_tresmeses==11

******************** seg salud (assumed mensual)

// data in many currencies (march)
gen gasto935 = cant_pagosegsalud* `deflactor3' if mone_pagosegsalud == 1 & mes_pagosegsalud==3
replace gasto935 = cant_pagosegsalud* `tc2mes3' * `deflactor3' if mone_pagosegsalud == 2 & mes_pagosegsalud==3
replace gasto935 = cant_pagosegsalud* `tc3mes3' * `deflactor3' if mone_pagosegsalud == 3 & mes_pagosegsalud==3
replace gasto935 = cant_pagosegsalud* `tc4mes3' * `deflactor3' if mone_pagosegsalud == 4 & mes_pagosegsalud==3


// data in many currencies (feb)
replace gasto935 = cant_pagosegsalud if mone_pagosegsalud == 1 & mes_pagosegsalud==2
replace gasto935 = cant_pagosegsalud* `tc2mes2' * `deflactor2' if mone_pagosegsalud == 2 & mes_pagosegsalud==2
replace gasto935 = cant_pagosegsalud* `tc3mes2' * `deflactor2' if mone_pagosegsalud == 3 & mes_pagosegsalud==2
replace gasto935 = cant_pagosegsalud* `tc4mes2' * `deflactor2' if mone_pagosegsalud == 4 & mes_pagosegsalud==2

// data in many currencies (jan)
replace gasto935 = cant_pagosegsalud  * `deflactor1' if mone_pagosegsalud == 1 & mes_pagosegsalud==1
replace gasto935 = cant_pagosegsalud* `tc2mes1' * `deflactor1' if mone_pagosegsalud == 2 & mes_pagosegsalud==1
replace gasto935 = cant_pagosegsalud* `tc3mes1' * `deflactor1' if mone_pagosegsalud == 3 & mes_pagosegsalud==1
replace gasto935 = cant_pagosegsalud* `tc4mes1' * `deflactor1' if mone_pagosegsalud == 4 & mes_pagosegsalud==1

// data in many currencies (dec)
replace gasto935 = cant_pagosegsalud * `deflactor12' if mone_pagosegsalud == 1 & mes_pagosegsalud==12
replace gasto935 = cant_pagosegsalud* `tc2mes12' * `deflactor12' if mone_pagosegsalud == 2 & mes_pagosegsalud==12
replace gasto935 = cant_pagosegsalud* `tc3mes12' * `deflactor12' if mone_pagosegsalud == 3 & mes_pagosegsalud==12
replace gasto935 = cant_pagosegsalud* `tc4mes12' * `deflactor12' if mone_pagosegsalud == 4 & mes_pagosegsalud==12

// data in many currencies (nov)
replace gasto935 = cant_pagosegsalud  * `deflactor11' if mone_pagosegsalud == 1 & mes_pagosegsalud==11
replace gasto935 = cant_pagosegsalud* `tc2mes11' * `deflactor11' if mone_pagosegsalud == 2 & mes_pagosegsalud==11
replace gasto935 = cant_pagosegsalud* `tc3mes11' * `deflactor11' if mone_pagosegsalud == 3 & mes_pagosegsalud==11
replace gasto935 = cant_pagosegsalud* `tc4mes11' * `deflactor11' if mone_pagosegsalud == 4 & mes_pagosegsalud==11


******************************************** jubilacion

// global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension

*************** descuentos ? incorporamos ? (assumed mensual)
********* descuento seg social obligatorio

// data in many currencies (march)
gen gasto941 = d_sso_cant* `deflactor3' if d_sso_mone == 1 & interview_month==3
replace gasto941 = d_sso_cant* `tc2mes3' * `deflactor3' if d_sso_mone == 2 & interview_month==3
replace gasto941 = d_sso_cant* `tc3mes3' * `deflactor3' if d_sso_mone == 3 & interview_month==3
replace gasto941 = d_sso_cant* `tc4mes3' * `deflactor3' if d_sso_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto941 = d_sso_cant if d_sso_mone == 1 & interview_month==2
replace gasto941 = d_sso_cant* `tc2mes2' * `deflactor2' if d_sso_mone == 2 & interview_month==2
replace gasto941 = d_sso_cant* `tc3mes2' * `deflactor2' if d_sso_mone == 3 & interview_month==2
replace gasto941 = d_sso_cant* `tc4mes2' * `deflactor2' if d_sso_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto941 = d_sso_cant  * `deflactor1' if d_sso_mone == 1 & interview_month==1
replace gasto941 = d_sso_cant* `tc2mes1' * `deflactor1' if d_sso_mone == 2 & interview_month==1
replace gasto941 = d_sso_cant* `tc3mes1' * `deflactor1' if d_sso_mone == 3 & interview_month==1
replace gasto941 = d_sso_cant* `tc4mes1' * `deflactor1' if d_sso_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto941 = d_sso_cant * `deflactor12' if d_sso_mone == 1 & interview_month==12
replace gasto941 = d_sso_cant* `tc2mes12' * `deflactor12' if d_sso_mone == 2 & interview_month==12
replace gasto941 = d_sso_cant* `tc3mes12' * `deflactor12' if d_sso_mone == 3 & interview_month==12
replace gasto941 = d_sso_cant* `tc4mes12' * `deflactor12' if d_sso_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto941 = d_sso_cant  * `deflactor11' if d_sso_mone == 1 & interview_month==11
replace gasto941 = d_sso_cant* `tc2mes11' * `deflactor11' if d_sso_mone == 2 & interview_month==11
replace gasto941 = d_sso_cant* `tc3mes11' * `deflactor11' if d_sso_mone == 3 & interview_month==11
replace gasto941 = d_sso_cant* `tc4mes11' * `deflactor11' if d_sso_mone == 4 & interview_month==11

********* descuento spf

// data in many currencies (march)
gen gasto942 = d_spf_cant* `deflactor3' if d_spf_mone == 1 & interview_month==3
replace gasto942 = d_spf_cant* `tc2mes3' * `deflactor3' if d_spf_mone == 2 & interview_month==3
replace gasto942 = d_spf_cant* `tc3mes3' * `deflactor3' if d_spf_mone == 3 & interview_month==3
replace gasto942 = d_spf_cant* `tc4mes3' * `deflactor3' if d_spf_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto942 = d_spf_cant if d_spf_mone == 1 & interview_month==2
replace gasto942 = d_spf_cant* `tc2mes2' * `deflactor2' if d_spf_mone == 2 & interview_month==2
replace gasto942 = d_spf_cant* `tc3mes2' * `deflactor2' if d_spf_mone == 3 & interview_month==2
replace gasto942 = d_spf_cant* `tc4mes2' * `deflactor2' if d_spf_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto942 = d_spf_cant  * `deflactor1' if d_spf_mone == 1 & interview_month==1
replace gasto942 = d_spf_cant* `tc2mes1' * `deflactor1' if d_spf_mone == 2 & interview_month==1
replace gasto942 = d_spf_cant* `tc3mes1' * `deflactor1' if d_spf_mone == 3 & interview_month==1
replace gasto942 = d_spf_cant* `tc4mes1' * `deflactor1' if d_spf_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto942 = d_spf_cant * `deflactor12' if d_spf_mone == 1 & interview_month==12
replace gasto942 = d_spf_cant* `tc2mes12' * `deflactor12' if d_spf_mone == 2 & interview_month==12
replace gasto942 = d_spf_cant* `tc3mes12' * `deflactor12' if d_spf_mone == 3 & interview_month==12
replace gasto942 = d_spf_cant* `tc4mes12' * `deflactor12' if d_spf_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto942 = d_spf_cant  * `deflactor11' if d_spf_mone == 1 & interview_month==11
replace gasto942 = d_spf_cant* `tc2mes11' * `deflactor11' if d_spf_mone == 2 & interview_month==11
replace gasto942 = d_spf_cant* `tc3mes11' * `deflactor11' if d_spf_mone == 3 & interview_month==11
replace gasto942 = d_spf_cant* `tc4mes11' * `deflactor11' if d_spf_mone == 4 & interview_month==11


********* descuento isr

// data in many currencies (march)
gen gasto943 = d_isr_cant* `deflactor3' if d_isr_mone == 1 & interview_month==3
replace gasto943 = d_isr_cant* `tc2mes3' * `deflactor3' if d_isr_mone == 2 & interview_month==3
replace gasto943 = d_isr_cant* `tc3mes3' * `deflactor3' if d_isr_mone == 3 & interview_month==3
replace gasto943 = d_isr_cant* `tc4mes3' * `deflactor3' if d_isr_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto943 = d_isr_cant if d_isr_mone == 1 & interview_month==2
replace gasto943 = d_isr_cant* `tc2mes2' * `deflactor2' if d_isr_mone == 2 & interview_month==2
replace gasto943 = d_isr_cant* `tc3mes2' * `deflactor2' if d_isr_mone == 3 & interview_month==2
replace gasto943 = d_isr_cant* `tc4mes2' * `deflactor2' if d_isr_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto943 = d_isr_cant  * `deflactor1' if d_isr_mone == 1 & interview_month==1
replace gasto943 = d_isr_cant* `tc2mes1' * `deflactor1' if d_isr_mone == 2 & interview_month==1
replace gasto943 = d_isr_cant* `tc3mes1' * `deflactor1' if d_isr_mone == 3 & interview_month==1
replace gasto943 = d_isr_cant* `tc4mes1' * `deflactor1' if d_isr_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto943 = d_isr_cant * `deflactor12' if d_isr_mone == 1 & interview_month==12
replace gasto943 = d_isr_cant* `tc2mes12' * `deflactor12' if d_isr_mone == 2 & interview_month==12
replace gasto943 = d_isr_cant* `tc3mes12' * `deflactor12' if d_isr_mone == 3 & interview_month==12
replace gasto943 = d_isr_cant* `tc4mes12' * `deflactor12' if d_isr_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto943 = d_isr_cant  * `deflactor11' if d_isr_mone == 1 & interview_month==11
replace gasto943 = d_isr_cant* `tc2mes11' * `deflactor11' if d_isr_mone == 2 & interview_month==11
replace gasto943 = d_isr_cant* `tc3mes11' * `deflactor11' if d_isr_mone == 3 & interview_month==11
replace gasto943 = d_isr_cant* `tc4mes11' * `deflactor11' if d_isr_mone == 4 & interview_month==11



********* descuento cah

// data in many currencies (march)
gen gasto944 = d_cah_cant* `deflactor3' if d_cah_mone == 1 & interview_month==3
replace gasto944 = d_cah_cant* `tc2mes3' * `deflactor3' if d_cah_mone == 2 & interview_month==3
replace gasto944 = d_cah_cant* `tc3mes3' * `deflactor3' if d_cah_mone == 3 & interview_month==3
replace gasto944 = d_cah_cant* `tc4mes3' * `deflactor3' if d_cah_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto944 = d_cah_cant if d_cah_mone == 1 & interview_month==2
replace gasto944 = d_cah_cant* `tc2mes2' * `deflactor2' if d_cah_mone == 2 & interview_month==2
replace gasto944 = d_cah_cant* `tc3mes2' * `deflactor2' if d_cah_mone == 3 & interview_month==2
replace gasto944 = d_cah_cant* `tc4mes2' * `deflactor2' if d_cah_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto944 = d_cah_cant  * `deflactor1' if d_cah_mone == 1 & interview_month==1
replace gasto944 = d_cah_cant* `tc2mes1' * `deflactor1' if d_cah_mone == 2 & interview_month==1
replace gasto944 = d_cah_cant* `tc3mes1' * `deflactor1' if d_cah_mone == 3 & interview_month==1
replace gasto944 = d_cah_cant* `tc4mes1' * `deflactor1' if d_cah_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto944 = d_cah_cant * `deflactor12' if d_cah_mone == 1 & interview_month==12
replace gasto944 = d_cah_cant* `tc2mes12' * `deflactor12' if d_cah_mone == 2 & interview_month==12
replace gasto944 = d_cah_cant* `tc3mes12' * `deflactor12' if d_cah_mone == 3 & interview_month==12
replace gasto944 = d_cah_cant* `tc4mes12' * `deflactor12' if d_cah_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto944 = d_cah_cant  * `deflactor11' if d_cah_mone == 1 & interview_month==11
replace gasto944 = d_cah_cant* `tc2mes11' * `deflactor11' if d_cah_mone == 2 & interview_month==11
replace gasto944 = d_cah_cant* `tc3mes11' * `deflactor11' if d_cah_mone == 3 & interview_month==11
replace gasto944 = d_cah_cant* `tc4mes11' * `deflactor11' if d_cah_mone == 4 & interview_month==11

********* descuento cpr

// data in many currencies (march)
gen gasto945 = d_cpr_cant* `deflactor3' if d_cpr_mone == 1 & interview_month==3
replace gasto945 = d_cpr_cant* `tc2mes3' * `deflactor3' if d_cpr_mone == 2 & interview_month==3
replace gasto945 = d_cpr_cant* `tc3mes3' * `deflactor3' if d_cpr_mone == 3 & interview_month==3
replace gasto945 = d_cpr_cant* `tc4mes3' * `deflactor3' if d_cpr_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto945 = d_cpr_cant if d_cpr_mone == 1 & interview_month==2
replace gasto945 = d_cpr_cant* `tc2mes2' * `deflactor2' if d_cpr_mone == 2 & interview_month==2
replace gasto945 = d_cpr_cant* `tc3mes2' * `deflactor2' if d_cpr_mone == 3 & interview_month==2
replace gasto945 = d_cpr_cant* `tc4mes2' * `deflactor2' if d_cpr_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto945 = d_cpr_cant  * `deflactor1' if d_cpr_mone == 1 & interview_month==1
replace gasto945 = d_cpr_cant* `tc2mes1' * `deflactor1' if d_cpr_mone == 2 & interview_month==1
replace gasto945 = d_cpr_cant* `tc3mes1' * `deflactor1' if d_cpr_mone == 3 & interview_month==1
replace gasto945 = d_cpr_cant* `tc4mes1' * `deflactor1' if d_cpr_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto945 = d_cpr_cant * `deflactor12' if d_cpr_mone == 1 & interview_month==12
replace gasto945 = d_cpr_cant* `tc2mes12' * `deflactor12' if d_cpr_mone == 2 & interview_month==12
replace gasto945 = d_cpr_cant* `tc3mes12' * `deflactor12' if d_cpr_mone == 3 & interview_month==12
replace gasto945 = d_cpr_cant* `tc4mes12' * `deflactor12' if d_cpr_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto945 = d_cpr_cant  * `deflactor11' if d_cpr_mone == 1 & interview_month==11
replace gasto945 = d_cpr_cant* `tc2mes11' * `deflactor11' if d_cpr_mone == 2 & interview_month==11
replace gasto945 = d_cpr_cant* `tc3mes11' * `deflactor11' if d_cpr_mone == 3 & interview_month==11
replace gasto945 = d_cpr_cant* `tc4mes11' * `deflactor11' if d_cpr_mone == 4 & interview_month==11

********* descuento rpv

// data in many currencies (march)
gen gasto946 = d_rpv_cant* `deflactor3' if d_rpv_mone == 1 & interview_month==3
replace gasto946 = d_rpv_cant* `tc2mes3' * `deflactor3' if d_rpv_mone == 2 & interview_month==3
replace gasto946 = d_rpv_cant* `tc3mes3' * `deflactor3' if d_rpv_mone == 3 & interview_month==3
replace gasto946 = d_rpv_cant* `tc4mes3' * `deflactor3' if d_rpv_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto946 = d_rpv_cant if d_rpv_mone == 1 & interview_month==2
replace gasto946 = d_rpv_cant* `tc2mes2' * `deflactor2' if d_rpv_mone == 2 & interview_month==2
replace gasto946 = d_rpv_cant* `tc3mes2' * `deflactor2' if d_rpv_mone == 3 & interview_month==2
replace gasto946 = d_rpv_cant* `tc4mes2' * `deflactor2' if d_rpv_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto946 = d_rpv_cant  * `deflactor1' if d_rpv_mone == 1 & interview_month==1
replace gasto946 = d_rpv_cant* `tc2mes1' * `deflactor1' if d_rpv_mone == 2 & interview_month==1
replace gasto946 = d_rpv_cant* `tc3mes1' * `deflactor1' if d_rpv_mone == 3 & interview_month==1
replace gasto946 = d_rpv_cant* `tc4mes1' * `deflactor1' if d_rpv_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto946 = d_rpv_cant * `deflactor12' if d_rpv_mone == 1 & interview_month==12
replace gasto946 = d_rpv_cant* `tc2mes12' * `deflactor12' if d_rpv_mone == 2 & interview_month==12
replace gasto946 = d_rpv_cant* `tc3mes12' * `deflactor12' if d_rpv_mone == 3 & interview_month==12
replace gasto946 = d_rpv_cant* `tc4mes12' * `deflactor12' if d_rpv_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto946 = d_rpv_cant  * `deflactor11' if d_rpv_mone == 1 & interview_month==11
replace gasto946 = d_rpv_cant* `tc2mes11' * `deflactor11' if d_rpv_mone == 2 & interview_month==11
replace gasto946 = d_rpv_cant* `tc3mes11' * `deflactor11' if d_rpv_mone == 3 & interview_month==11
replace gasto946 = d_rpv_cant* `tc4mes11' * `deflactor11' if d_rpv_mone == 4 & interview_month==11


********* descuento otro

// data in many currencies (march)
gen gasto947 = d_otro_cant* `deflactor3' if d_otro_mone == 1 & interview_month==3
replace gasto947 = d_otro_cant* `tc2mes3' * `deflactor3' if d_otro_mone == 2 & interview_month==3
replace gasto947 = d_otro_cant* `tc3mes3' * `deflactor3' if d_otro_mone == 3 & interview_month==3
replace gasto947 = d_otro_cant* `tc4mes3' * `deflactor3' if d_otro_mone == 4 & interview_month==3


// data in many currencies (feb)
replace gasto947 = d_otro_cant if d_otro_mone == 1 & interview_month==2
replace gasto947 = d_otro_cant* `tc2mes2' * `deflactor2' if d_otro_mone == 2 & interview_month==2
replace gasto947 = d_otro_cant* `tc3mes2' * `deflactor2' if d_otro_mone == 3 & interview_month==2
replace gasto947 = d_otro_cant* `tc4mes2' * `deflactor2' if d_otro_mone == 4 & interview_month==2

// data in many currencies (jan)
replace gasto947 = d_otro_cant  * `deflactor1' if d_otro_mone == 1 & interview_month==1
replace gasto947 = d_otro_cant* `tc2mes1' * `deflactor1' if d_otro_mone == 2 & interview_month==1
replace gasto947 = d_otro_cant* `tc3mes1' * `deflactor1' if d_otro_mone == 3 & interview_month==1
replace gasto947 = d_otro_cant* `tc4mes1' * `deflactor1' if d_otro_mone == 4 & interview_month==1

// data in many currencies (dec)
replace gasto947 = d_otro_cant * `deflactor12' if d_otro_mone == 1 & interview_month==12
replace gasto947 = d_otro_cant* `tc2mes12' * `deflactor12' if d_otro_mone == 2 & interview_month==12
replace gasto947 = d_otro_cant* `tc3mes12' * `deflactor12' if d_otro_mone == 3 & interview_month==12
replace gasto947 = d_otro_cant* `tc4mes12' * `deflactor12' if d_otro_mone == 4 & interview_month==12

// data in many currencies (nov)
replace gasto947 = d_otro_cant  * `deflactor11' if d_otro_mone == 1 & interview_month==11
replace gasto947 = d_otro_cant* `tc2mes11' * `deflactor11' if d_otro_mone == 2 & interview_month==11
replace gasto947 = d_otro_cant* `tc3mes11' * `deflactor11' if d_otro_mone == 3 & interview_month==11
replace gasto947 = d_otro_cant* `tc4mes11' * `deflactor11' if d_otro_mone == 4 & interview_month==11

********* aporta pension

// data in many currencies (march)
gen gasto948 = cant_aporta_pension* `deflactor3' if mone_aporta_pension == 1 & interview_month==3
replace gasto948 = cant_aporta_pension* `tc2mes3' * `deflactor3' if mone_aporta_pension == 2 & interview_month==3
replace gasto948 = cant_aporta_pension* `tc3mes3' * `deflactor3' if mone_aporta_pension == 3 & interview_month==3
replace gasto948 = cant_aporta_pension* `tc4mes3' * `deflactor3' if mone_aporta_pension == 4 & interview_month==3


// data in many currencies (feb)
replace gasto948 = cant_aporta_pension if mone_aporta_pension == 1 & interview_month==2
replace gasto948 = cant_aporta_pension* `tc2mes2' * `deflactor2' if mone_aporta_pension == 2 & interview_month==2
replace gasto948 = cant_aporta_pension* `tc3mes2' * `deflactor2' if mone_aporta_pension == 3 & interview_month==2
replace gasto948 = cant_aporta_pension* `tc4mes2' * `deflactor2' if mone_aporta_pension == 4 & interview_month==2

// data in many currencies (jan)
replace gasto948 = cant_aporta_pension  * `deflactor1' if mone_aporta_pension == 1 & interview_month==1
replace gasto948 = cant_aporta_pension* `tc2mes1' * `deflactor1' if mone_aporta_pension == 2 & interview_month==1
replace gasto948 = cant_aporta_pension* `tc3mes1' * `deflactor1' if mone_aporta_pension == 3 & interview_month==1
replace gasto948 = cant_aporta_pension* `tc4mes1' * `deflactor1' if mone_aporta_pension == 4 & interview_month==1

// data in many currencies (dec)
replace gasto948 = cant_aporta_pension * `deflactor12' if mone_aporta_pension == 1 & interview_month==12
replace gasto948 = cant_aporta_pension* `tc2mes12' * `deflactor12' if mone_aporta_pension == 2 & interview_month==12
replace gasto948 = cant_aporta_pension* `tc3mes12' * `deflactor12' if mone_aporta_pension == 3 & interview_month==12
replace gasto948 = cant_aporta_pension* `tc4mes12' * `deflactor12' if mone_aporta_pension == 4 & interview_month==12

// data in many currencies (nov)
replace gasto948 = cant_aporta_pension  * `deflactor11' if mone_aporta_pension == 1 & interview_month==11
replace gasto948 = cant_aporta_pension* `tc2mes11' * `deflactor11' if mone_aporta_pension == 2 & interview_month==11
replace gasto948 = cant_aporta_pension* `tc3mes11' * `deflactor11' if mone_aporta_pension == 3 & interview_month==11
replace gasto948 = cant_aporta_pension* `tc4mes11' * `deflactor11' if mone_aporta_pension == 4 & interview_month==11
***********************************end of expenditures********************************


// adds expenditure of hh, removing individual dimension 
collapse (sum) gasto*, by (interview__id interview__key quest ipcf miembros entidad)


**************picks only 1 data in the following hierarchy:
 //if there is a payed ammount, this is housing expenditure,
 // else, if the reporter makes a estimation, we pick this amount as housing expenditure
 // else, we impute a 0.1 from ipcf to housing, if they are owners
 
gen gasto909 = gasto903
replace gasto909 = gasto902 if (gasto901==. | gasto901==0) & !(gasto902==. | gasto902==0)
replace gasto909 = gasto901 if !(gasto901==. | gasto901==0)

//drop old rents and keep agregator
drop gasto901 gasto902 gasto903

// now we reshape the wide data to make it long
reshape long gasto, i(interview__id interview__key quest ipcf miembros entidad) j(bien)
rename gasto gasto_mensual
replace gasto_mensual = round(gasto_mensual)

// generate current good variable
gen current_good = 1

// generate types of goods
gen type_good = 8 if bien>900 & bien<910
replace type_good = 9 if bien>910 & bien<920
replace type_good = 10 if bien>920 & bien<930
replace type_good = 11 if bien>930 & bien<940
replace type_good = 12 if bien>940 & bien<950



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

// chilenean metodolgy does not refer to avoid durables consumtion like TV, so we keep this muted
// keep if current_good==1



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

drop if popularity<.1

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
twoway line orshansky obs if ors_quant<98 

xtile exp_quant = exp, nq(100)

sum orshansky, detail

global orsh r(p50)
di $orsh


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
