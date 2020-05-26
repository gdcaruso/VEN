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
/*
 	    * User 1: Trini
 		global trini 0
		
 		* User 2: Julieta
 		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
 		* User 4: Malena
 		global male   1
			
 		if $juli {
 				global dopath "C:\Users\wb563583\GitHub\VEN"
 				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
 		}
	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019"
		}
 		if $trini   {
 				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
 		}
 		if $male   {
 				global dopath "C:\Users\wb550905\Github\VEN"
 				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
				global outENCOVI "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018\"
	
	}		


 //set universal datapaths

 global forinflation "$datapath\data_management\output\for inflation"

 //set universal dopath
 global harmonization "$dopath\data_management\management\2. harmonization"
 global inflado "$dopath\data_management\management\5. inflation"

 //Exchange rate inputs and auxiliaries

 global pathaux "$harmonization\aux_do"

 // set path of data
 global povmeasure "$dopath\poverty_measurement\scripts"
 global input "$datapath\poverty_measurement\input"
 global output "$datapath\poverty_measurement\output"
*/
/*
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
global merged "$datapath\data_management\output\merged"
global cleaned "$datapath\data_management\output\cleaned"
global output "$datapath\expenditure\output"
*/

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off


/*(************************************************************************************************************************************************* 
* 1: generate deflators and ex rate conversion
*************************************************************************************************************************************************)*/

qui{
	*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor


use "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta", clear
			
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
			local deflactor4 `indice2'/`indice3' // this are surveys started on march, in most cases
// 			local deflactor11 1
// 			local deflactor12 1
// 			local deflactor1 1
// 			local deflactor2 1
// 			local deflactor3 1
		
		* Exchange Rates / Tipo de cambio
			*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
			local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			local meses 1 2 3 4 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march
			
			use "$datapath\data_management\input\exchenge_rate_price.dta", clear //
			
			destring mes, replace
			foreach i of local monedas {
				foreach j of local meses {
					sum mean_moneda	if moneda==`i' & mes==`j'
					local tc`i'mes`j' = r(mean)
					di `tc`i'mes`j''
				}
			}
//aprils exchange rates temporary equal as march
local tc1mes4 = `tc1mes3'
local tc2mes4 = `tc2mes3'
local tc3mes4 = `tc3mes3'
local tc4mes4 = `tc4mes3'


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
di `deflactor4' //temporary same as march



/*(************************************************************************************************************************************************* 
* // Consumption section  (long shape)
*********************************************************************************************************************)*/

// import main encovi for basic hh data
// import other expenditure data
use "$outENCOVI/ENCOVI_2019_Spanish labels.dta", replace 
cap drop if hogarsec == 1
cap drop _merge
cap egen miembros = count(com), by (interview__key interview__id)

drop if pondera_hh ==.
keep interview__id interview__key ipcf miembros pondera_hh
isid interview__id interview__key
tempfile hh
save `hh'


// import feb2020 product data
use "$merged/product-hh.dta", replace //use merged because we need expenditure, not homogenized units of cleaned dataset
merge m:1 interview__id interview__key using `hh', keep(matched) 

// // generate month of the survey
gen month = month(date_consumption_survey) // its another variable in harmonization

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
	cap replace gasto_feb20 = gasto * `tc`currency'mes`mes'' * `deflactor`mes'' if month==`mes' & moneda == `currency'
	
	}
	}
replace gasto_feb20 = round(gasto_feb20)

/*
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
gen gasto_mensual = gasto_feb20* 30.42/7 if type_good==1 // weekly
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==2 // weekly
replace gasto_mensual = gasto_feb20* 30.42/15 if type_good==3 //bath&cleaning twice a week
replace gasto_mensual = gasto_feb20/3 if type_good==4 //clothes in three months
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==5 //durables not current
replace gasto_mensual = gasto_feb20* 30.42/7 if type_good==6 //eatingout weekly
replace gasto_mensual = gasto_feb20* 30.42/30.42 if type_good==7 // monthly for enterainment
replace gasto_mensual = round(gasto_mensual)

keep interview__id interview__key bien gasto_mensual type_good current_good month miembros ipcf pondera_hh

tempfile conSpending
save `conSpending'

/*(************************************************************************************************************************************************* 
* // HH section  (wide shape) 
*********************************************************************************************************************)*/
// import other expenditure data
use "$outENCOVI/ENCOVI_2019_Spanish labels.dta", replace
cap drop _merge
merge m:1 interview__id interview__key using `hh', keep(matched) 


//select relevant variables
global viviendavar renta_imp pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m renta_imp_en renta_imp_mon

global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m

global educvar cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension





keep interview__id interview__key interview_month ipcf miembros pondera_hh  ///
$viviendavar ///
$serviciosvar ///
$educvar ///
$saludvar ///
$jubivar

sort interview__id interview__key pondera_hh, stable
by interview__id interview__key: replace pondera_hh= pondera_hh[1] 


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
	if `m'>10 | `m'<=4 {
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
gen gasto902 = renta_imp //assumed everything was moved in the income module to feb 2020


**********************************************services
// global serviciosvar pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m
*******************agua


gen gasto911 =. //pagua_monto 
gen gasto912 =. //pelect_monto 
gen gasto913 =. //pgas_monto 
gen gasto914 =. //pcarbon_monto 
gen gasto915 =. //pparafina_monto 
gen gasto916 =. //ptelefono_monto 


// gasto en agua
local servicios pagua pelect pgas pcarbon pparafina ptelefono
local n=910

foreach v in `servicios'{
local n=`n'+1
levelsof `v'_m, local(month)
	foreach m in `month'{
	levelsof `v'_mon, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<=4 {
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



****************************************educacion
//
// global educvar cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m

*********************inscripcion (assumed annual freq)



gen gasto921 =. //cuota_insc_monto 
gen gasto922 =. //compra_utiles_monto 
gen gasto923 =. //compra_uniforme_monto 
gen gasto924 =. //costo_men_monto 
gen gasto925 =. //costo_transp_monto 
gen gasto926 =. //otros_gastos_monto


// gasto en educ
local educ cuota_insc compra_utiles compra_uniforme costo_men costo_transp otros_gastos
local n=920

foreach v in `servicios'{
local n=`n'+1
levelsof `v'_m, local(month)
	foreach m in `month'{
	levelsof `v'_mon, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<=4 {
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



*******************************************salud

// global saludvar cant_pago_consulta mone_pago_consulta mes_pago_consulta pago_remedio mone_pago_remedio mes_pago_remedio pago_examen mone_pago_examen mes_pago_examen cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

********************pago consulta (assumed mensual)

gen gasto931 =. //pago_consulta
gen gasto932 =. //pago_remedio
gen gasto933 =. //pago_examen
gen gasto934 =. // remedio_tresmeses
gen gasto935 =. //pagosegsalud


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
		if `m'>10 | `m'<=4 {
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



******************************************** jubilacion

// global jubivar d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone cant_aporta_pension mone_aporta_pension

*************** descuentos ? incorporamos ? (assumed mensual)
********* descuento seg social obligatorio

gen gasto941 =. //d_sso
gen gasto942 =. //d_spf
gen gasto943 =. //d_isr
gen gasto944 =. //d_cah
gen gasto945 =. //d_cpr
gen gasto946 =. //d_rpv
gen gasto947 =. //d_otro



// gasto en jubi
local jubi d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro
local n=940

foreach v in `jubi'{
local n=`n'+1
levelsof interview_month, local(month)
	foreach m in `month'{
	levelsof `v'_mone, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<=4 {
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

gen gasto948=. //aporta_pension
levelsof interview_month, local(month)
	foreach m in `month'{
	levelsof mone_aporta_pension, local(currency)
		foreach c in `currency'{
		if `m'>10 | `m'<=4 {
			di `m'
			di `c'
			di `tc`c'mes`m''
			di `deflactor`m''
			replace gasto948 = cant_aporta_pension*`tc`c'mes`m''*`deflactor`m'' if interview_month == `m' & mone_aporta_pension == `c'
		}
		}
		}


		
} //end of quietly
***********************************end of expenditures********************************


// adds expenditure of hh, removing individual dimension 
collapse (sum) gasto*, by (interview__id interview__key ipcf miembros pondera_hh)


// now we reshape the wide data to make it long
reshape long gasto, i(interview__id interview__key ipcf miembros pondera_hh) j(bien)


rename gasto gasto_mensual
replace gasto_mensual = round(gasto_mensual)

// generate current good variable
gen current_good = 1

// generate types of goods
gen type_good = 8 if bien>=900 & bien<=909  //housing
replace type_good = 9 if bien>=910 & bien<=919  //services
replace type_good = 10 if bien>=920 & bien<=929  //educ
replace type_good = 11 if bien>=930 & bien<=939  //health
replace type_good = 12 if bien>=940 & bien<=949  //ss

replace current_good = 0 if type_good == 12




tempfile hhSpending
save `hhSpending'

// apends hh spending dataset with consumption dataset
append using `conSpending'

keep interview__id interview__key ipcf miembros  ///
bien type_good current_good gasto_mensual pondera_hh


order interview__id interview__key ipcf miembros pondera_hh  ///
bien type_good current_good gasto_mensual


/*(************************************************************************************************************************************************* 
* 1:complete panel values with 0s
*************************************************************************************************************************************************)*/

// first we need to complete the panel, replacing with 0 in any good undeclared
// create observations

fillin bien interview__id

replace gasto_mensual = 0 if gasto_mensual ==.

//complete obs
sort interview__id interview__key, stable
by interview__id: replace interview__key= interview__key[_N]


sort interview__id interview__key miembros, stable
by interview__id interview__key: replace miembros= miembros[1]

sort interview__id interview__key ipcf, stable
by interview__id interview__key: replace ipcf= ipcf[1]

sort interview__id interview__key pondera_hh, stable
by interview__id interview__key: replace pondera_hh= pondera_hh[1]

sort bien type_good, stable
by bien: replace type_good= type_good[1]

sort bien type_good current_good, stable
by bien: replace current_good = current_good[1]

gen gasto_men_pc = gasto_mensual/miembros


save "$datapath\poverty_measurement\output\unwinsored_expenditure.dta", replace


/*(************************************************************************************************************************************************* 
* 1:detect outliars
*************************************************************************************************************************************************)*/
use "$datapath\poverty_measurement\output\unwinsored_expenditure.dta", replace

// need to correct by outliers!
egen total = total(gasto_men_pc), by(interview__id)
gen share = gasto_men_pc/total


levelsof bien, local (good_list)
gen gasto_men_pc_winsored = .
gen winsored = 0
sort bien, stable
gen uno=1
by bien: egen popular=count(uno) if gasto_men_pc>0
gsort bien -popular
by bien: replace popular = popular[1]
distinct interview__key interview__id 
replace popular = popular /r(ndistinct)
keep if popular > 0.01 // dropping 41 goods
drop uno

foreach b in `good_list' {
 
di "----------------"
di `b'
qui summarize gasto_men_pc if bien == `b' & gasto_men_pc>0, detail
		replace gasto_men_pc_winsored = gasto_men_pc if bien == `b'
		replace gasto_men_pc_winsored =r(p98) if gasto_men_pc>r(p98) & bien == `b' & gasto_men_pc>0 //replace values over p99
		replace gasto_men_pc_winsored =r(p1) if gasto_men_pc<r(p1) & bien == `b' & gasto_men_pc>0 //replace values under p1 (no answer excluded)
		replace winsored = 1 if (gasto_men_pc<r(p1) | gasto_men_pc>r(p98)) & bien == `b' & gasto_men_pc>0 //flag
}

egen total_winsored = total(gasto_men_pc_winsored), by(interview__id)
gen share_winsored = gasto_men_pc_winsored/total_winsored


//generate expenditure aggregates per hh
sort interview__id interview__key, stable
egen gpcf = total(gasto_men_pc_winsored), by (interview__id interview__key)
egen gpcf_food = total(gasto_men_pc_winsored) if inrange(bien,1,87) & current_good==1, by (interview__id interview__key)
egen gpcf_nonfood = total(gasto_men_pc_winsored) if !inrange(bien,1,87) & current_good==1, by (interview__id interview__key)
egen gpcf_housing = total(gasto_men_pc_winsored) if inrange(bien,901,902), by (interview__id interview__key)
egen gpcf_other = total(gasto_men_pc_winsored) if !inrange(bien,901,902) & !inrange(bien,1,87) & current_good==1, by (interview__id interview__key)


// // agregate winsor
// summarize gpcf, detail
// replace gpcf = r(p99) if gpcf>r(p99)
// replace gpcf =r(p1) if gpcf<r(p1)


//complete observations
sort interview__id interview__key gpcf_food, stable
by interview__id interview__key: replace gpcf_food = gpcf_food[1] 
sort interview__id interview__key gpcf_nonfood, stable
by interview__id interview__key: replace gpcf_nonfood = gpcf_nonfood[1]
sort interview__id interview__key gpcf_housing, stable
by interview__id interview__key: replace gpcf_housing = gpcf_housing[1]
sort interview__id interview__key gpcf_other, stable
by interview__id interview__key: replace gpcf_other = gpcf_other[1]



// check orshanskys
gen orsh = gpcf/gpcf_food 
gen share_food = gpcf_food/gpcf
gen share_housing = gpcf_housing/gpcf
gen share_other = gpcf_other/gpcf

save "$datapath\poverty_measurement\output\winsored_expenditure_product_level.dta", replace


// 17 hh do not answer consumption
preserve
collapse (max) orsh (max) pondera_hh, by(interview__key interview__id)
summ orsh [w=pondera_hh], detail
restore

preserve
keep gpcf share* interview__id interview__key
duplicates drop
tempfile expenditure
save `expenditure'
restore

collapse (max) gpcf gpcf_* share*, by(interview__key interview__id)


**************ARREGLO AD HOC DE GERMÁN ÚLTIMO MOMENTO**************************
		*Replace outliers after P95
			*Food
			summ gpcf_food , detail
			gen gpcf_food_p95=gpcf_food
			replace gpcf_food_p95=r(p95) if gpcf_food>r(p95) 

			*Non-Food
			summ gpcf_housing , detail
			gen gpcf_housing_p95=gpcf_housing
			replace gpcf_housing_p95=r(p95) if gpcf_housing>r(p95) 

			summ gpcf_other , detail
			gen gpcf_other_p95=gpcf_other
			replace gpcf_other_p95=r(p95) if gpcf_other>r(p95) 

			gen gpcf_nonfood_p95 = gpcf_housing_p95 + gpcf_other_p95

			*Total Exp
			gen gpcf_p95= gpcf_nonfood_p95 + gpcf_food_p95

		*Drop old variables and rename
			drop gpcf- share_other

			foreach v in gpcf_food gpcf_housing gpcf_other gpcf_nonfood gpcf{ 
			rename `v'_p95 `v'
			}
*******************************************************************************


save "$datapath\poverty_measurement\output\winsored_expenditure_hh_level.dta", replace


/*(************************************************************************************************************************************************* 
* 1:compare against lines
*************************************************************************************************************************************************)*/


*use "$outENCOVI/ENCOVI_2019_Spanish labels.dta", replace

*merge m:1 interview__id interview__key using "$output/winsored_expenditure_hh_level.dta"
*drop _merge

*save "$outENCOVI/ENCOVI_2019_with_expenditures_Spanish labels.dta", replace // NOW DONE IN THE MAIN



// drop lp_* pobre pobre_extremo
//
// cap drop if hogarsec == 1
//
// //generates lines
// gen lp_moderada = 5450207
// gen lp_extrema = 2217069
// gen le_ofi = 2502450
// gen lp_ofi = 5004901
// gen lp_19_ready = 1259070
// gen lp_32_ready = 2120539
// gen lp_55_ready = 3644676
//
// // lines and sorted gpcf plot
// sort gpcf, stable
// gen personas = sum(pondera) //running sum
// egen max_obs = max(personas)
// local maxobs = max_obs[1]*0.95
//
//
// graph twoway line gpcf personas [fw=pondera]   if personas<`maxobs', lcolor("black") lw(thick) ///
// || line lp_19_ready personas  [fw=pondera], lcolor("blue") ///
// || line lp_32_ready personas [fw=pondera], lcolor("blue") ///
// || line lp_55_ready personas [fw=pondera], lcolor("blue") ///
// || line lp_moderada personas [fw=pondera], lcolor("red") lw(thick) ///
// || line lp_extrema personas [fw=pondera], lcolor("red") lw(thick) ///
// || line le_ofi personas [fw=pondera], lcolor("green") ///
// || line lp_ofi personas [fw=pondera], lcolor("green")  ///
//  legend(off) ytitle("")  ytitle("") graphregion(color(gs15)) ylabel(, nogrid format(%12.0f)) xlabel(,format(%12.0f))
//  
//  // clasificates population using diff lines
// gen pobre = gpcf<lp_moderada
// gen pobre_extremo = gpcf<lp_extrema
// gen pobre_extremo_ofi = gpcf<le_ofi
// gen pobre_ofi = gpcf<lp_ofi
// gen pobre_19 = gpcf<lp_19_ready
// gen pobre_32 = gpcf<lp_32_ready
// gen pobre_55 = gpcf<lp_55_ready
//
// // generate matrix of results
//
// sum pobre [fw=pondera]
// mat A1 = r(mean)
//
// sum pobre_extremo [fw=pondera]
// mat A2 = r(mean)
//
// sum pobre_ofi [fw=pondera]
// mat A3 = r(mean)
//
// sum pobre_extremo_ofi [fw=pondera]
// mat A4 = r(mean)
//
// sum pobre_19 [fw=pondera]
// mat A5 = r(mean)
//
// sum pobre_32 [fw=pondera]
// mat A6 = r(mean)
//
// sum pobre_55 [fw=pondera]
// mat A7 = r(mean)
//
// local names "Pobreza" "Pobreza extrema" "Pobreza oficial" "Pobreza extrema oficial" "Pobreza 1.9" "Pobreza 3.2" "Pobreza 5.5"
//
// mat R1 = A1\A2\A3\A4\A5\A6\A7
// matrix rownames R1 = `names'
//
//
// // generate matrix of results
//
// sum lp_moderada
// mat B1 = r(mean)
//
// sum lp_extrema
// mat B2 = r(mean)
//
// sum lp_ofi
// mat B3 = r(mean)
//
// sum le_ofi
// mat B4 = r(mean)
//
// sum lp_19_ready
// mat B5 = r(mean)
//
// sum lp_32_ready
// mat B6 = r(mean)
//
// sum lp_55_ready
// mat B7 = r(mean)
//
//
// mat R2 = B1\B2\B3\B4\B5\B6\B7
// matrix rownames R2 = `names'
// mat R3 = (B1\B2\B3\B4\B5\B6\B7) / ppp11[1] / ipc[1]*ipc11[1] /30.42
// matrix rownames R3 = `names'
//
// matlist R1
// matlist R2
// matlist R3
//
// /*(************************************************************************************************************************************************* 
// * 1:compare expenditure against income
// *************************************************************************************************************************************************)*/
//
// gen g_to_y = gpcf/ipcf
//
//
// summ g_to_y [w=pondera], detail
