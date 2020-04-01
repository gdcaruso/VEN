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
global mergeddata "$rootpath\data_management\output\merged" //REPLACE ALL WITH CLEANED DATA
global cleaneddata "$rootpath\data_management\output\cleaned"

global output "$rootpath\poverty_measurement\input"
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

use "$output/reference_metocol.dta", replace
tempfile reference
save `reference'


/*(************************************************************************************************************************************************* 
* 1: generate deflators and ex rate conversion
*************************************************************************************************************************************************)*/


	*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor
			*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
			use "$cleaneddata\InflacionVerdadera_26-3-20.dta", clear
			
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
			
		* Exchange Rates / Tipo de cambio
			*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
			local monedas "1 2 3 4" // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			local meses "1 2 3 11 12" // 11=nov, 12=dic, 1=jan, 2=feb, 3=march
			
			use "$cleaneddata\exchenge_rate_price.dta", clear
			
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
use "$mergeddata/product-hh.dta", replace
merge m:1 interview__id interview__key quest using `reference'
keep if _merge ==3
drop _merge

// problems and solutions: a) define good types b) define current goods c) homogenize currencies d) correct date of purchase  e) define frequency of purchase for each type 

// a) define good type
gen type_good = .
label define type_good 1 "food" 2 "alcohol&smoke" 3 "bath&cleaning" 4 "clothes" 5 "durables" 6 "eatingout" 7 "entertainment"
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
replace current_good = 0 if type_good==3 //bienes durables (TV, plancha)

// c) homogenize currencies
	* We move everything to bolivares February 2020, given that there we have more sample size // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio

/* tab moneda (number of spending obs. by currency)

      10b. Moneda |      Freq.     Percent        Cum.
------------------+-----------------------------------
        Bolívares |    131,356       91.18       91.18
          Dólares |      2,488        1.73       92.90
            Euros |         20        0.01       92.92
Pesos Colombianos |     10,205        7.08      100.00
------------------+-----------------------------------
            Total |    144,069      100.00
*/
		
gen gasto_bol = gasto if moneda == 1
replace gasto_bol = gasto * `tc2mes2' if moneda == 2
replace gasto_bol = gasto * `tc3mes2' if moneda == 3
replace gasto_bol = gasto * `tc4mes2' if moneda == 4


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

Solution:
For food and alcohol&smoke, a) we reimputate month of purchase to january if he or she answered last 15 days or more that 15 days and the date of the survey is earlier that Feb 15th.


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

replace inflate = 1 if date_consumption_survey<=date("2/15/20","MDY", 2050)  & fecha==4 & (type_good ==1 | type_good ==2)
*/
gen gasto_feb20 = gasto_bol
replace gasto_feb20 = gasto_bol*`deflactor1' if inflate==1





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
gen deflate = 1 if date_consumption_survey<=date("3/1/20","MDY", 2050) & fecha==1 & (type_good ==1 | type_good ==2)
replace deflate = 1 if date_consumption_survey<=date("3/7/20","MDY", 2050) & fecha==2 & (type_good ==1 | type_good ==2)

replace gasto_feb20 = gasto_bol*`deflactor3' if deflate==1

	 
/*
c)
For the rest, we cannot discriminate between a purchase done within the timespan of the question, so we keep the spending date in FEB2020



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

tempfile conSpending
save `conSpending'




/*(************************************************************************************************************************************************* 
* // HH section  (wide shape) TODO!
*********************************************************************************************************************)*/
use "$cleaneddata/ENCOVI_2019.dta", replace
merge m:1 interview__id interview__key quest using `reference'
keep if _merge == 3
drop _merge



//select relevant variables
global viviendavar renta_imp pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m renta_imp_en renta_imp_mon

global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m

global educvar cuota_insc_monto compra_utiles_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension

stop
keep interview__id interview__key quest  ///
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
gen gasto901 = pago_alq_mutuo if pago_alq_mutuo_mon ==1 & pago_alq_m == 2


// data of March and many currencies
replace gasto901 = pago_alq_mutuo* `tc2mes3'* `deflactor3' if moneda == 2 & pago_alq_m == 3
replace gasto901 = pago_alq_mutuo* `tc3mes3'* `deflactor3' if moneda == 3 & pago_alq_m == 3
replace gasto901 = pago_alq_mutuo* `tc4mes3'* `deflactor3' if moneda == 4 & pago_alq_m == 3

// data in many currencies feb2020
replace gasto901 = pago_alq_mutuo* `tc2mes2' if moneda == 2 & pago_alq_m == 2
replace gasto901 = pago_alq_mutuo* `tc3mes2' if moneda == 3 & pago_alq_m == 2
replace gasto901 = pago_alq_mutuo* `tc4mes2' if moneda == 4 & pago_alq_m == 2

// data of Jan and many currencies
replace gasto901 = pago_alq_mutuo* `tc2mes1'* `deflactor1' if moneda == 2 & pago_alq_m == 1
replace gasto901 = pago_alq_mutuo* `tc3mes1'* `deflactor1' if moneda == 3 & pago_alq_m == 1
replace gasto901 = pago_alq_mutuo* `tc4mes1'* `deflactor1' if moneda == 4 & pago_alq_m == 1


// data of Dec and many currencies
replace gasto901 = pago_alq_mutuo* `tc2mes12'* `deflactor12' if moneda == 2 & pago_alq_m == 12
replace gasto901 = pago_alq_mutuo* `tc3mes12'* `deflactor12' if moneda == 3 & pago_alq_m == 12
replace gasto901 = pago_alq_mutuo* `tc4mes12'* `deflactor12' if moneda == 4 & pago_alq_m == 12

// data of Nov and many currencies
replace gasto901 = pago_alq_mutuo* `tc2mes11'* `deflactor11' if moneda == 2 & pago_alq_m == 11
replace gasto901 = pago_alq_mutuo* `tc3mes11'* `deflactor11' if moneda == 3 & pago_alq_m == 11
replace gasto901 = pago_alq_mutuo* `tc4mes11'* `deflactor11' if moneda == 4 & pago_alq_m == 11

*****************renta imputada por el entrevisatado

// data in bolivares feb2020
gen gasto902 = renta_imp_en if renta_imp_mon == 1


// data in many currencies (march)
replace gasto902 = renta_imp_en* `tc2mes3' * `deflactor3' if renta_imp_mon == 2 & interview_month==3
replace gasto902 = renta_imp_en* `tc3mes3' * `deflactor3'  if renta_imp_mon == 3 & interview_month==3
replace gasto902 = renta_imp_en* `tc4mes3' * `deflactor3' if renta_imp_mon == 4 & interview_month==3

// data in many currencies (feb)
replace gasto902 = renta_imp_en* `tc2mes2' if renta_imp_mon == 2 & interview_month==2
replace gasto902 = renta_imp_en* `tc3mes2' if renta_imp_mon == 3 & interview_month==2
replace gasto902 = renta_imp_en* `tc4mes2' if renta_imp_mon == 4 & interview_month==2

// data in many currencies (jan)
replace gasto902 = renta_imp_en* `tc2mes1' * `deflactor1' if renta_imp_mon == 2 & interview_month==1
replace gasto902 = renta_imp_en* `tc3mes1' * `deflactor1'  if renta_imp_mon == 3 & interview_month==1
replace gasto902 = renta_imp_en* `tc4mes1' * `deflactor1' if renta_imp_mon == 4 & interview_month==1

// data in many currencies (dec)
replace gasto902 = renta_imp_en* `tc2mes12' * `deflactor12' if renta_imp_mon == 2 & interview_month==12
replace gasto902 = renta_imp_en* `tc3mes12' * `deflactor12'  if renta_imp_mon == 3 & interview_month==12
replace gasto902 = renta_imp_en* `tc4mes12' * `deflactor12' if renta_imp_mon == 4 & interview_month==12

// data in many currencies (nov)
replace gasto902 = renta_imp_en* `tc2mes11' * `deflactor11' if renta_imp_mon == 2 & interview_month==11
replace gasto902 = renta_imp_en* `tc3mes11' * `deflactor11'  if renta_imp_mon == 3 & interview_month==11
replace gasto902 = renta_imp_en* `tc4mes11' * `deflactor11' if renta_imp_mon == 4 & interview_month==11


******************inputed rent by analyst
// data in bolivares feb2020
gen gasto903 = renta_imp if renta_imp_mon == 1 //assumed everything was moved in the income module to feb 2020


**********************************************services











gen gasto = pago_alq_mutuo if bien == 902
replace gasto = renta_imp if bien == 903
replace gasto = renta_imp_en if bien == 902 //the order is relevant, we prefer the reported rent than our inputation

gen moneda = pago_alq_mutuo_mon if bien == 902
replace moneda = renta_imp_mon if bien == 902
replace moneda = 1 if bien == 903

gen mes = pago_alq_mutuo_m if bien == 901



// servicios
// global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m

replace bien = 911 if pagua_monto !=. //servicios
replace bien = 912 if pelect_monto !=.
replace bien = 913 if pgas_monto !=.
replace bien = 914 if pcarbon_monto !=.
replace bien = 915 if pparafina_monto !=.
replace bien = 916 if ptelefono_monto !=.

replace gasto = pagua_monto if bien == 911
replace gasto = pelect_monto if bien == 912
replace gasto = pgas_monto if bien == 913
replace gasto = pcarbon_monto if bien == 914
replace gasto = pparafina_monto if bien == 915
replace gasto = ptelefono_monto if bien == 916


// global educvar cuota_insc_monto compra_utiles_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

replace bien = 921 if couta_insc_monto !=.
replace bien = 922 if compra_utiles_monto !=.
replace bien = 923 if costo_men_monto !=.
replace bien = 924 if costo_transp_monto !=.
replace bien = 925 if otros_gastos_monto !=.

// global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

replace bien = 931 if cant_pago_consulta != .
replace bien = 932 if pago_remedio != .
replace bien = 933 if pago_examen != .
replace bien = 934 if cant_remedio_tresmeses != .
replace bien = 935 if cant_pagosegsalud != .


// global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension

replace bien = 941 if d_sso_cant != .
replace bien = 942 if d_spf_cant != .
replace bien = 943 if d_isr_cant != .
replace bien = 944 if d_cah_cant != .
replace bien = 945 if d_cpr_cant != .
replace bien = 946 if d_rpv_cant != .
replace bien = 947 if d_otro_cant != .
replace bien = 947 if cant_aporta_pension != .

////////////////////////////
// GASTO, MONEDA, FECHA  //
//////////////////////////

// global viviendavar renta_imp pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m renta_imp_en renta_imp_mon
stop








/*(************************************************************************************************************************************************* 
* // Individual section  (wide shape) TODO!
*********************************************************************************************************************)*/

use "$mergeddata/individual.dta", replace
merge m:1 interview__id interview__key quest using `reference'
keep if _merge ==3
drop _merge

//select relevant variables
keep interview__id interview__key quest s7q10* //educacion ///
 s8q8* s8q12* s8q14* s8q16* s8q12* //salud ///
 s9q38* //pension
 
// excluimos bienes del negocio que se lleva a su casa ya que no es identificable el tipo de bien ///
 
// educacion
gen  = gasto if moneda == 1
replace gasto_bol = gasto * `tc2mes2' if moneda == 2
replace gasto_bol = gasto * `tc3mes2' if moneda == 3
replace gasto_bol = gasto * `tc4mes2' if moneda == 4