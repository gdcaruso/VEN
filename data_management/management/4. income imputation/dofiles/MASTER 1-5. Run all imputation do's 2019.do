* Run 1-5 imputation do's 2019
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   1
			
		if $juli {
				global pathcorto "C:\Users\wb563583\Github\VEN\data_management"
				global pathaux "C:\Users\wb563583\GitHub\VEN\data_management\management\2. harmonization\ENCOVI harmonization\aux_do"
				global pathrun "C:\Users\wb563583\Github\VEN\data_management\management\4. income imputation\dofiles"
				global dataout "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned"
				global path "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"		
		}
	    if $lauta {

		}
		if $trini   {
		}
		
		if $male   {
		        global pathcorto "C:\Users\wb550905\Github\VEN\data_management"
				global pathaux "C:\Users\wb550905\Github\VEN\data_management\management\2. harmonization\ENCOVI harmonization\aux_do"
				global pathrun "C:\Users\wb550905\Github\VEN\data_management\management\4. income imputation\dofiles"
				global dataout "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned"
				global path "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"		
		}


***********************************
//*** Running all imputations ***//
**********************************

run "$pathrun\1. Imputation 2019 - Identification missing values & possible variables for regression.do"
	* Obs: dofile 1 uses "ENCOVI_2019_PRECIOS IMPLICITOS_lag_ingresos.dta"
run "$pathrun\2. Imputation 2019 - Monetary labor income.do"
run "$pathrun\3. Imputation 2019 - Pensions.do"
run "$pathrun\4. Imputation 2019 - Non Labor Income.do"
run "$pathrun\5. Imputation 2019 - Labor benefits (non monetary income).do"


**************************************
/* NUESTRO DOFILE: TC Y DEFLACTORES */
**************************************
	
	*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor
			*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
			use "$pathcorto\output\cleaned\inflacion\inflacion_canasta_alimentos_diaria_precios_implicitos.dta", clear
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
			
			use "$pathcorto\management\1. merging\exchange rates\exchenge_rate_price.dta", clear
			
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

use "$path\ENCOVI_forimputation_2019.dta", clear

	* Mergeamos ila_m_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$path\VEN_ila_m_imp1.dta" // da lo mismo usando id com

	* Mergeamos jubpen_imp1
	capture drop _merge
	merge 1:1 id com using "$path\VEN_jubpen_imp1.dta"

	* Mergeamos inlanojub_imp1
	capture drop _merge
	merge 1:1 id com using "$path\VEN_inlanojub_imp1.dta"

	* Mergeamos bene_imp1
	capture drop _merge
	merge 1:1 id com using "$path\VEN_bene_imp1.dta"

	
****************************************************
//*** Replacing imputed labor income variables ***//
****************************************************

	drop ingresoslab_mon
	rename ila_m_imp1 ingresoslab_mon
	
	drop ingresoslab_bene 
	rename bene_imp1 ingresoslab_bene
	
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

		* Nothing to replace, they were all missing
		
		****** NON-LABOR INCOME ******
		
		* s9q28__4==1 // Pensión por divorcio, separación, alimentación
		* Tal vez sería mejor ponerlo adentro de "transferencias privadas" itranp_o_m
		* If so, cambiar en la otra base y en SEDLAS
		
		* No pudimos recrear ijubi_m, icap_m, rem, itranp_o_m, itranp_ns, cct, itrane_o_m, itrane_ns, inla_otro
		
		drop inla inla_m
		egen inla = rsum(jubpen_imp1 inlanojub_imp1)
		egen inla_m = rsum(jubpen_imp1 inlanojub_imp1)
	
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
		/* ing. individuales totales */ 
		foreach i in ii ii_m perii  {
			cap drop `i'  	
		}
		/* ing. familiares totales */ 
		foreach i in n_perila_h ilf ilf_m inlaf_m itf_m itf_sin_ri n_perii_h inlaf {
			cap drop `i'  	
		}
	
	cap gen hogarsec=0
	cap gen hstrp=hstr_ppal
	cap gen hstrt= hstr_ppal 
		replace hstrt = hstr_todos if hstr_todos!=. // los que tienen dos trabajos

	include "$pathcorto\management\2. harmonization\ENCOVI harmonization\aux_do\do_file_1_variables_MA.do"
	
	************************************
	/* NUESTRO DOFILE: RENTA IMPUTADA */
	************************************
	
	foreach i in aux_propieta_no_paga propieta_no_paga renta_imp renta_imp_b {
			cap drop `i'  	
		}
	
	gen aux_propieta_no_paga = 1 if tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==5 | tenencia_vivienda==6 | tenencia_vivienda==7 | tenencia_vivienda==8
	replace aux_propieta_no_paga = 0 if tenencia_vivienda==3 | tenencia_vivienda==4 | (tenencia_vivienda>=9 & tenencia_vivienda<=10) | tenencia_vivienda==.
	bysort id: egen propieta_no_paga = max(aux_propieta_no_paga)

	// Creates implicit rent from hh guess of its housing costs if they do noy pay rent and 10% of actual income if hh do not make any guess
		gen     renta_imp = .
		
		levelsof interview_month, local(rent_month)
		foreach m in `rent_month' {
			levelsof renta_imp_mon, local(rent_currency)

			foreach c in `rent_currency'{
				di "////"
				di `m'
				di `c'
				di  `tc`c'mes`m''
				di `deflactor`m''
				replace renta_imp = renta_imp_en * `tc`c'mes`m'' * `deflactor`m'' if interview_month == `m' & renta_imp_mon == `c' & propieta_no_paga == 1
			}
		}

		gen renta_imp_b = itf_sin_ri*0.1
		replace renta_imp = renta_imp_b  if  propieta_no_paga == 1 & renta_imp ==. //complete with 10% in cases where no guess is provided by hh.

	*********************
	/* Dofile CEDLAS 2 */
	*********************
	
	foreach i in itf cohi cohh aux_ocu jefe_ocu max_edu edu_max coh_oficial {
			cap drop `i'  	
		}
	/*ING. FAM. AJUSTADOS POR FACTORES DEMO. */ 
	foreach i in ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf aefa iea ilea_m ieb iec ied iee {
			cap drop `i'  	
		}
	
	clonevar relacion = relacion_comp
	clonevar nivel = nivel_educ
	
	include "$pathcorto\management\2. harmonization\ENCOVI harmonization\aux_do\do_file_2_variables.do"
	
	* El do de CEDLAS que está en aux_do parece disinto que el do de CEDLAS adentro de ENCOVI harmonization, chequear


****************************************************
//*** SAVING IMPUTED DATABASE: HURRAY!!!!!!!!!!***//
****************************************************

save "$dataout\ENCOVI_2019_PRECIOS IMPLICITOS_lag_ingresos_IMPUTADA.dta", replace
	
