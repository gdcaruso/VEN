/*===========================================================================
Puropose: Run 1-5 imputation do's for ENCOVI 2019
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña

Dependencies:		The World Bank
Creation Date:		17th April, 2020
Modification Date:  
Output:			

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user (silenced as this is done by main now)

// clear all 
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
				global datapath "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	    if $lauta {

		}
		if $trini {
		}
		
		if $male   {
				global dopath "C:\Users\wb550905\GitHub\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
			}

	global numberofimpruns 30

*Inputs
	global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
	global exrate 	"$datapath\data_management\input\exchenge_rate_price.dta"
	global pathaux 	"$dopath\data_management\management\2. harmonization\aux_do"
	global impdos 	"$dopath\data_management\management\4. income imputation\dofiles"
	global forimp 	"$datapath\data_management\output\for imputation"
*Output
	global cleaned "$datapath\data_management\output\cleaned"
	global pathoutexcel "$dopath\data_management\management\4. income imputation\output"

*/
********************************************************************************
	
***********************************
//*** Running all imputations ***//
**********************************

*set seed 1 // The seeds are in the do's in the end

run "$impdos\1. Imputation 2019 - Identification missing values & possible variables for regression.do"
	* Obs: dofile 1 uses "ENCOVI_2019_Sin imputar (con precios implicitos).dta"
run "$impdos\2. Imputation 2019 - Monetary labor income.do"
run "$impdos\3. Imputation 2019 - Pensions.do"
run "$impdos\4. Imputation 2019 - Non Labor Income (except pensions).do"
run "$impdos\5. Imputation 2019 - Labor benefits (non monetary income).do"


**************************************
/* NUESTRO DOFILE: TC Y DEFLACTORES */
**************************************

	*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor
			*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
			use "$inflation", clear
			*use "$rootpath\data_management\output\cleaned\inflacion\Inflacion_Asamblea Nacional.dta", clear

			
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
					
*************************************************************
//*** Merging ENCOVI 2019 database with imputed incomes ***//
************************************************************

use "$forimp\ENCOVI_forimputation_2019.dta", clear

	* Mergeamos ila_m_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$forimp\VEN_ila_m_imp1_2019.dta" // da lo mismo usando id com

	* Mergeamos jubpen_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$forimp\VEN_jubpen_imp1_2019.dta"

	* Mergeamos inlanojub_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$forimp\VEN_inlanojub_imp1_2019.dta"

	* Mergeamos bene_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$forimp\VEN_bene_imp1_2019.dta"

	
****************************************************
//*** Replacing imputed labor income variables ***//
****************************************************
	
	*Labor income
	
		drop ingresoslab_mon
		rename ila_m_imp1 ingresoslab_mon
		
		drop ingresoslab_bene 
		rename bene_imp1 ingresoslab_bene
	
	*Non labor income
		drop ijubi_m 
		rename jubpen_imp1 ijubi_m 
		
		cap drop inla_otro
		replace inlanojub=. if dinlanojub_out==1
			* Polémico, pero no queda otra para que tengan sentido los nuevos agregados monetarios de los outliers:
			* Change to missing all the variables that generate inlanojub (all inla's except ijubi_m) so that they don't add up again
			foreach i of varlist icap_m rem itranp_o_m itranp_ns itrane_o_m itrane_ns inla_extraord {
				replace `i' =. if dinlanojub_out==1
			}
		gen inla_otro = .
		replace inla_otro = cond(missing(inlanojub_imp1), ., inlanojub_imp1) - cond(missing(inlanojub), 0, inlanojub) // La diferencia entre los que ya están y lo imputado
		replace inla_otro =. if inla_otro<=0 // Si lo imputado es igual o más bajo, no poner nada
		
		*replace imputed rent_currency
		cap drop d_renta_imp_b
		
	* Bringing back a small ad-hoc we did before to do the imputation
		replace im_petro=. if quest==1 
		replace inla_petro=. if quest==1 
	
	******************************************
	/* OUR DOFILE: LABOR & NON-LABOR INCOME */
	******************************************
		foreach i of varlist ipatrp_m ipatrp_nm iasalp_m iasalp_nm ictapp_m ictapp_nm iolp_m iolp_nm {
		   cap drop `i'  	
		}
		
		****** PRIMARY LABOR INCOME ******
		
		*i)  	PATRÓN
			gen     ipatrp_m = ingresoslab_mon if relab==1  // Monetario
			gen     ipatrp_nm = ingresoslab_bene if relab==1 // No monetario

		*ii)  	ASALARIADOS
			gen     iasalp_m = ingresoslab_mon if relab==2 // Monetario
			gen     iasalp_nm = ingresoslab_bene if relab==2 // No monetario

		* iii)  CUENTA PROPIA
			gen     ictapp_m = ingresoslab_mon if relab==3 // Monetario
			gen     ictapp_nm = ingresoslab_bene if relab==3 // No monetario
			
		* iv) 	Otros - trabajador sin salario
			gen iolp_m = ingresoslab_mon if relab==4 // Monetario
			gen iolp_nm = ingresoslab_bene if relab==4 // No monetario

		* iv) AGREGADO POR NOSOTROS: relab=. pero ganan dinero
				// (como se les pregunta el dinero que ganan con base anual, 
				//por lo que puede haber gente no ocupada -medido en la última semana- que gana ingreso laboral)

			gen irelabmisspr_m = ingresoslab_mon if inlist(relab,.,5) & ingresoslab_mon!=.  // Monetario
			gen irelabmisspr_nm = ingresoslab_bene if inlist(relab,.,5) & ingresoslab_mon!=.  // No monetario

		****** SECONDARY LABOR INCOME ******

			* Nothing to replace, they were all missing. 
			* I added a "cap" in front of this lines, which got executed to create the first database but won't get executed this time.
		
		****** NON-LABOR INCOME ******
		
			* Nothing to replace besides the imputed variables ijubi_m and inla_otro
	
	********************
	/* Dofile CEDLAS 1*/
	********************
	
		/* ing. act. ppal */
		foreach i in ipatrp iasalp ictapp iolp irelabmiss ip ip_m wage wage_m {
		   cap drop `i'  	
		}
		/* ing. laborales totales */ 
		foreach i in ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila {
			cap drop `i'  	
		}
		/* ing. no laborales */
		foreach i in ijubi icap itranp itranp_m itrane itrane_m itran itran_m inla inla_m  {
			cap drop `i'  	
		}
		/* ing. individuales totales */ 
		foreach i in ii ii_m perii  {
			cap drop `i'  	
		}
		/* ing. familiares totales */ 
		foreach i in n_perila_h n_perii_h ilf ilf_m inlaf inlaf_m itf_m itf_sin_ri {
			cap drop `i'  	
		}
	
	cap gen hogarsec=0
	cap gen hstrp=hstr_ppal
	cap gen hstrt= hstr_ppal 
		replace hstrt = hstr_todos if hstr_todos!=. // los que tienen dos trabajos

	include "$pathaux\do_file_1_variables_MA.do"
	
	*************************************
	/* NUESTRO DOFILE: RENTA IMPLICITA */
	*************************************
	
	foreach i in aux_propieta_no_paga propieta_no_paga renta_imp renta_imp_b como_imputa_renta {
			cap drop `i'  	
		}
	
	gen aux_propieta_no_paga = 1 if tenencia_vivienda==1 | tenencia_vivienda==6 | tenencia_vivienda==7 | tenencia_vivienda==8 | tenencia_vivienda==9 | tenencia_vivienda==10 
	replace aux_propieta_no_paga = 0 if tenencia_vivienda==2 | tenencia_vivienda==3 | tenencia_vivienda==4 | tenencia_vivienda==5 | tenencia_vivienda==. 
	sort id, stable
	by id: egen propieta_no_paga = max(aux_propieta_no_paga) 
	replace propieta_no_paga=. if hogarsec==1
	
	// Creating implicit rent from hh guess of its housing costs if they had to pay rent of their dwelling
		gen     renta_imp = .
		
		levelsof interview_month, local(rent_month)
		foreach m in `rent_month' {
			*local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			foreach c in `monedas'{
				di "////"
				di `m'
				di `c'
				di  `tc`c'mes`m''
				di `deflactor`m''
				replace renta_imp = renta_imp_en * `tc`c'mes`m'' * `deflactor`m'' if interview_month == `m' & renta_imp_mon == `c' & propieta_no_paga == 1
			}
		}
		
				gen como_imputa_renta = . // For analysis: to know how we treated the renta imputada in each case
				replace como_imputa_renta = 0 if propieta_no_paga==0
				replace como_imputa_renta = 1 if propieta_no_paga==1 & renta_imp!=.
				replace como_imputa_renta = 2 if propieta_no_paga==1 & renta_imp==.

	// Taking care of people who need to have rent imputated but didn't answer what would be their housing costs if they had to pay
		* Assumption: Para los pocos que no contestaron, el ing. total familiar (pre-renta imp) por la media de la participación de la renta imp reportada en el ing. total familiar (antes de renta imp), entre los que sí la contestaron.
	
			gen part_rentaimp = renta_imp/itf_sin_ri if renta_imp!=. & renta_imp!=0  
			sum part_rentaimp [w=pondera_hh] if renta_imp!=. & renta_imp!=0 & relacion_en==1, detail // Lo hacemos a nivel de hogar
			* Problem: there are people who answer they would spend too much if they paid rent. The 50% percentile answers 66%. The 99% percentile even 687 times their income before imputed rent!
			* Note: we will take care of outliers.
			tab renta_imp_mon if renta_imp_en!=. & renta_imp_en!=0, mi
			drop part_rentaimp
			
			* Changing outliers to missing	
			program drop _all
			qui: do "$impdos\outliers.do" 			
			clonevar renta_imp_out=renta_imp
			outliers renta_imp 10 90 5 5 // Ya cambia los outliers a missing // Obs: se tuvo un trato más estricto de outliers 3 std. dev. en vez de 5
			sum	renta_imp_out if out_renta_imp==1  // van entre 2.07e+07 y 3.44e+11
				
				replace como_imputa_renta = 3 if out_renta_imp==1
				label define como_imputa_renta 0 "Alquila o crédito hipotecario (no imp)" 1 "Rta preg costo potencial, no outlier (no imp)" 2 "No rta preg costo potencial (imputar)" 3 "Outlier (imputar)"
				label values como_imputa_renta como_imputa_renta
				*Check
				tab como_imputa_renta, mi // Ok

			* Now without outliers
			gen part_rentaimp = renta_imp/itf_sin_ri if renta_imp!=. & renta_imp!=0
			sum part_rentaimp [w=pondera_hh] if renta_imp!=. & renta_imp!=0 & relacion_en==1, detail // Lo hacemos a nivel de hogar
			local partrentaimp2 = r(p50)
			display `partrentaimp2' // 55.25%
			
		sort interview__key interview__id quest relacion_en, stable
		by interview__key interview__id quest: replace renta_imp=renta_imp[1] if relacion_en!=13 // We add to all the other household members (who are not domestic service) the imputed rent of the head
		
			* tab tenencia_vivienda if renta_imp==. // to check cases of reported rent but not imputated 
		
		*sum itf_sin_ri if relacion_en==1 & propieta_no_paga==1 & (renta_imp==. | renta_imp==.a | renta_imp==0)
	
		egen max_renta_imp = max(renta_imp) // Máximo no outlier que contesta la gente
		sum max_renta_imp // 18443144 or 1.8e+7

		replace renta_imp = max_renta_imp 					if  propieta_no_paga == 1 & `partrentaimp2'*itf_sin_ri > max_renta_imp	 // We can't impute something higher than the maximum thing someone answered (and is not outlier)
		replace renta_imp = `partrentaimp2'*itf_sin_ri  	if  propieta_no_paga == 1 & (renta_imp==. | renta_imp==0 | renta_imp==.a) & (`partrentaimp2'*itf_sin_ri)<=max_renta_imp // Complete with r(p50) of ITF_SIN_RI in cases where no guess is provided by hh.
		cap drop part_rentaimp max_renta_imp
		
			/*Check: OK
			gen part = .
			replace part = renta_imp/itf_sin_ri if  propieta_no_paga == 1 & (renta_imp_en==. | renta_imp_en==.a | renta_imp_en==0) & relacion_en==1
			sum part if part!=.
			br renta_imp_en renta_imp itf_sin_ri /*itf*/ part if propieta_no_paga == 1 & (renta_imp_en==. | renta_imp_en==.a | renta_imp_en==0) & relacion_en==1
			*/
			
	*********************
	/* Dofile CEDLAS 2 */
	*********************
	
	/* Cálculos e ingresos inconsistentes */
	foreach i in itf cohi cohh aux_ocu jefe_ocu max_edu edu_max coh_oficial {
			cap drop `i'  	
		}
	/*Ing. fam. ajustados por valores demo. */ 
	foreach i in ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf aefa iea ilea_m ieb iec ied iee {
			cap drop `i'  	
		}
	/* Percentiles */
	foreach i in pipcf dipcf d_ing_ofi p_ing_ofi piea qiea ipc11 ppp11 ipcf_cpi11 ipcf_ppp11 {
			cap drop `i'  	
		}
	
	clonevar relacion = relacion_comp
	clonevar nivel = nivel_educ
	include "$pathaux\cuantiles.do"
	include "$pathaux\do_file_2_variables.do"
	
	
************************************************************
//*** QUICK CHECK TO SEE IF EVERYTHING IS WORKING FINE ***//
************************************************************

egen ila_nuestro = rowtotal(ingresoslab_mon ingresoslab_bene), mi
gen dummy_nocoincideila = 1 if ila != ila_nuestro
tab dummy_nocoincideila
	*Check: fine!

egen inla_nuestro = rowtotal(inlanojub_imp1 ijubi_m), mi
gen dummy_nocoincideinla = 1 if inla != inla_nuestro
tab dummy_nocoincideinla
*br inla inla_nuestro inla_otro dinlanojub_out inlanojub_imp1 inlanojub dummy_nocoincideinla if dummy_nocoincideinla==1
	*Check: fine! 4 differ only in decimals..
drop inlanojub_imp1


****************************************************
//*** SAVING IMPUTED DATABASE: HURRAY!!!!!!!!!!***//
****************************************************

save "$cleaned\ENCOVI_2019_pre pobreza.dta", replace


********************************************************************************
*** Analyzing imputed data
********************************************************************************

run "$impdos\Analysis imputation.do"

