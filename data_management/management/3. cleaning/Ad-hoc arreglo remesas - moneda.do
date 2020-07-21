// Define rootpath according to user (silenced as this is done by main now)

 	 
 		* User 2: Julieta
 		global juli   1
		
 	
 		* User 4: Malena
 		global male   0
			
 		if $juli {
 				global dopath "C:\Users\wb563583\GitHub\VEN"
 				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
				global outENCOVI "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018\"

 		}
 	    
 		if $male   {
 				global dopath "C:\Users\wb550905\Github\VEN"
 				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
				global outENCOVI "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018\"

				}
	
*Inputs
		global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
		global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
		global merged "$datapath\data_management\output\merged"
		global pathaux "$dopath\data_management\management\2. harmonization\aux_do"
*Outputs
		global cleaned "$datapath\data_management\output\cleaned"
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Final database  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
***** Final database
use "$outENCOVI\ENCOVI_2019.dta", clear

***** Errores Final Database
global ingreso2 rem 
foreach i of global ingreso2  {
replace `i'=. if `i'==0
replace `i'=. if `i'==.a
gen `i'_bajito = 1 if `i'<1000
display `i'
tab `i' if `i'_bajito==1
}

***** Keep relevant variables 
keep rem rem_bajito interview__key interview__id miembro__id com ///
iext_remesa_cant iext_remesa_mone 

save "$cleaned\ENCOVI_2019_errores_valores_bajitos.dta", replace

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	2.0: Raw databases  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
***** From raw database
*****Generate unique household identifier by strata
use "$merged\household.dta", clear
tempfile household_hhid
sort combined_id, stable // Instead of "bysort", to make sure we keep order
by combined_id: gen hh_by_combined_id = _n
save `household_hhid'

***** Open "output" database
use "$merged\individual.dta", clear
merge m:1 interview__key interview__id quest using `household_hhid'
drop _merge
***** Dropping those who do not collaborate in the survey
drop if colabora_entrevista==2


***** Select relevant variables 
*****Change names to lower cases
rename _all, lower
keep interview__key interview__id miembro__id interview_month com s9q29*
* obs: s9q20 y s9q22 no se usaron para armar los agregados de ingreso 

***** Change zeros to missing
foreach i in  s9q29b_4  {
replace `i'=. if `i'==0
replace `i'=. if `i'==.a
}

***** Identify errors (remittances)
	gen tag_s9q29c_4=0
	replace tag_s9q29c_4=1 if s9q29b_4>0 & s9q29b_4<=100 & s9q29c_4==1
	replace tag_s9q29c_4=1 if s9q29b_4>100 & s9q29b_4<=1000 & s9q29c_4==1
	replace tag_s9q29c_4=1 if s9q29b_4>0 & s9q29b_4<=1000 & s9q29c_4==4
	replace tag_s9q29c_4=1 if s9q29c_4==.a

*** Save database with tagged errors
save "$cleaned\base_tags_raw.dta", replace
use "$cleaned\base_tags_raw.dta", clear
merge 1:1 interview__key interview__id miembro__id using "$cleaned\ENCOVI_2019_errores_valores_bajitos.dta"
save "$cleaned\base_tags_raw.dta", replace

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	3.0: Correction  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 

/*==================================================================================================================================================
								1: Data preparation: First-Order Variables
==================================================================================================================================================*/

*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor
			*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
			use "$inflation", clear

			
			forvalues j = 10(1)12 {
				sum indice if mes==`j' & ano==2019
				local indice`j' = r(mean) 			
				}
			forvalues j = 1(1)4 {
				sum indice if mes==`j' & ano==2020
				display r(mean)
				local indice`j' = r(mean)				
				}
				
			// if we consider that incomes are earned in the previous month than the month of the interview use this
						local deflactor11 `indice2'/`indice10'
						local deflactor12 `indice2'/`indice11'
						local deflactor1 `indice2'/`indice12'
						local deflactor2 `indice2'/`indice1'
						local deflactor3 `indice2'/`indice2'
						local deflactor4 `indice2'/`indice3'
						

		* Exchange Rates / Tipo de cambio
			*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
			local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			local meses 1 2 3 4 10 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march, 4=april
			
			use "$exrate", clear
			
		// if we consider that incomes are earned one month previous to data collection use this			
					destring mes, replace
					foreach i of local monedas {
						foreach j of local meses {
							if `j' !=12 {
							  local k=`j'+1
							 }
							else {
							  local k=1 // if the month is 12 we send it to month 1
							}
							sum mean_moneda	if moneda==`i' & mes==`j' // if we pick ex rate of month=2
							local tc`i'mes`k' = r(mean)
							display `tc`i'mes`k''
							}
						}

use "$cleaned\base_tags_raw.dta", clear

**** Remittances
** Create a new variable to include changes in remittances

** Errors to address
tab tag_s9q29c_4 rem_bajito
tab interview__id if tag_s9q29c_4==1 & rem_bajito==1
br interview__id interview__key miembro__id tag_s9q29c_4  iext_remesa_mone rem s9q29b_4 iext_remesa_cant rem_bajito if tag_s9q29c_4==1 | rem_bajito==1

/* Reported as Bolivares but should be USD
interview__id	interview__key	miembro__id

9b74085863f247cba69aa7491f7ce981	12-21-41-35	2
6dee56912c884499901c45a2f559e443	17-11-38-72	1
e1565430eb4d4ad194a2064ad320cf79	27-23-09-12	3
5f3d4d175ead4568a30a2cb445c90d4c	32-11-02-35	2
4e903dcf3e3a4a0ba4d3b4d268940bb6	55-12-33-56	3
88b313d025e140bfb342eab0df2ddce8	71-09-62-21	2
c6b27ca33bf0407c8aeefe620f16f7ae	77-02-66-41	1
cfc32e11aea04154997b6e1af823c211	79-72-92-20	3
ef9d2a4bc13f4329bc8c5b1ed462af3e	83-04-95-44	1
d77861595c774796b852eff812071491	97-45-12-06	3
47cdf35210b84a58b667599f7c477a1d	97-86-21-95	6
*/

** Generate new currency and replace bolivars to dollars for the cases above
gen s9q29c_4_2=s9q29c_4
replace s9q29c_4_2=	2 	if 	interview__id=="9b74085863f247cba69aa7491f7ce981" &  interview__key=="12-21-41-35" & miembro__id==2 
replace s9q29c_4_2=	2	if 	interview__id=="6dee56912c884499901c45a2f559e443" &  interview__key=="17-11-38-72" & miembro__id==1
replace s9q29c_4_2=	2 	if 	interview__id=="e1565430eb4d4ad194a2064ad320cf79" &  interview__key=="27-23-09-12" & miembro__id==3
replace s9q29c_4_2=	2 	if 	interview__id=="5f3d4d175ead4568a30a2cb445c90d4c" &  interview__key=="32-11-02-35" & miembro__id==2
replace s9q29c_4_2=	2 	if 	interview__id=="4e903dcf3e3a4a0ba4d3b4d268940bb6" &  interview__key=="55-12-33-56" & miembro__id==3
replace s9q29c_4_2=	2 	if 	interview__id=="88b313d025e140bfb342eab0df2ddce8" &  interview__key=="71-09-62-21" & miembro__id==2
replace s9q29c_4_2=	2 	if 	interview__id=="c6b27ca33bf0407c8aeefe620f16f7ae" &  interview__key=="77-02-66-41" & miembro__id==1
replace s9q29c_4_2=	2 	if 	interview__id=="cfc32e11aea04154997b6e1af823c211" &  interview__key=="79-72-92-20" & miembro__id==3
replace s9q29c_4_2=	2 	if 	interview__id=="ef9d2a4bc13f4329bc8c5b1ed462af3e" &  interview__key=="83-04-95-44" & miembro__id==1
replace s9q29c_4_2=	2 	if 	interview__id=="d77861595c774796b852eff812071491" &  interview__key=="97-45-12-06" & miembro__id==3
replace s9q29c_4_2=	2 	if 	interview__id=="47cdf35210b84a58b667599f7c477a1d" &  interview__key=="97-86-21-95" & miembro__id==6
tab s9q29c_4_2

	local incomevar29  _4 
	foreach i of local incomevar29 {
		* Bolívares
			gen s9q29b`i'_bolfeb_2 = s9q29b`i'					* `deflactor11'	if interview_month==11 & s9q29c`i'_2==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'				* `deflactor12'	if interview_month==12 & s9q29c`i'_2==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'				* `deflactor1'	if interview_month==1 & s9q29c`i'_2==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'				* `deflactor2'  if interview_month==2 & s9q29c`i'_2==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'				* `deflactor3'	if interview_month==3 & s9q29c`i'_2==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			cap replace s9q29b`i'_bolfeb_2 = s9q29b`i'	     	* `deflactor4'	if interview_month==4 & s9q29c`i'_2==1 & s9q29b`i'!=. & s9q29b`i'!=.a 
		* Dólares
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc2mes11'	* `deflactor11'	if interview_month==11 & s9q29c`i'_2==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc2mes12' * `deflactor12'	if interview_month==12 & s9q29c`i'_2==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc2mes1' 	* `deflactor1'	if interview_month==1 & s9q29c`i'_2==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc2mes2' 	* `deflactor2' 	if interview_month==2 & s9q29c`i'_2==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc2mes3'	* `deflactor3'	if interview_month==3 & s9q29c`i'_2==2 & s9q29b`i'!=. & s9q29b`i'!=.a 
			cap replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc2mes4'* `deflactor4'	if interview_month==4 & s9q29c`i'_2==2 & s9q29b`i'!=. & s9q29b`i'!=.a 
		* Euros
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc3mes11' * `deflactor11'	if interview_month==11 & s9q29c`i'_2==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc3mes12' * `deflactor12'	if interview_month==12 & s9q29c`i'_2==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc3mes1' 	* `deflactor1' 	if interview_month==1 & s9q29c`i'_2==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc3mes2'	* `deflactor2' 	if interview_month==2 & s9q29c`i'_2==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc3mes3'	* `deflactor3'	if interview_month==3 & s9q29c`i'_2==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			cap replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc3mes4'* `deflactor4' if interview_month==4 & s9q29c`i'_2==3 & s9q29b`i'!=. & s9q29b`i'!=.a 
		* Colombianos
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc4mes11'	* `deflactor11'	if interview_month==11 & s9q29c`i'_2==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc4mes12' * `deflactor12'	if interview_month==12 & s9q29c`i'_2==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc4mes1'	* `deflactor1'	if interview_month==1 & s9q29c`i'_2==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc4mes2'	* `deflactor2' 	if interview_month==2 & s9q29c`i'_2==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc4mes3'	* `deflactor3'	if interview_month==3 & s9q29c`i'_2==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			cap replace s9q29b`i'_bolfeb_2 = s9q29b`i'	*`tc4mes4'* `deflactor4' if interview_month==4 & s9q29c`i'_2==4 & s9q29b`i'!=. & s9q29b`i'!=.a 
		}

****** 9.3.3.REMESAS ******	

/*rem: Ingreso monetario de remesas */
	
	gen rem2 = .
		
	foreach i of numlist 4 {
	*Assumption only the option "Remesas o ayudas periódicas de otros hogares del exterior" counts as remesas
		replace rem2 = rem + s9q29b_`i'_bolfeb_2 / 12	if rem!=. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		replace rem2 = s9q29b_`i'_bolfeb_2 / 12		if rem==. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}		
		sum rem2
	
	br interview__key interview__id miembro__id interview_month iext_remesa_mone rem s9q29c_4_2 s9q29b_4 iext_remesa_cant rem rem2 if tag_s9q29c_4==1 | rem_bajito==1
	label var s9q29c_4_2 "Moneda (editada para remesas 2)"
	rename s9q29c_4_2 iext_remesa_mone2
	
keep interview__key interview__id miembro__id rem2 iext_remesa_mone2
merge 1:1 interview__key interview__id miembro__id using "$outENCOVI\ENCOVI_2019.dta"
drop _merge
save "$outENCOVI\ENCOVI_2019_2.dta", replace
