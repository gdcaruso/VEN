*******************************************************************************
*** ENCOVI 2019 - Income imputation : LABOR NON MONETARY INCOME
********************************************************************************
/*===========================================================================
Country name:	Venezuela
Year:			2014-2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			
Dependencies:		The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			

Note: Income imputation - Identification missing values
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 1
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global path "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
				global pathpathoutexcel "C:\Users\wb563583\Github\VEN\data_management\management\4. income imputation\output"
		}
	    if $lauta {

		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
                global rootpath2 "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela"
				global path "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
				global pathdo "$rootpath2\Income Imputation\dofiles"
		}
		
		if $male   {
		        global path "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"

		}

///*** OPEN DATABASE & PATHS ***///

use "$path\ENCOVI_forimputation_2019.dta", clear

mdesc bene if inlist(recibe_ingresonolab,1,2,3)
///*** VARIABLES FOR MINCER EQUATION ***///

	global xvar	edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh /*anio_auto_hh*/ heladera_hh ///
				lavarropas_hh computadora_hh internet_hh televisor_hh calentador_hh aire_hh tv_cable_hh microondas_hh  ///
				/*seguro_salud*/ afiliado_segsalud_comp ///
				nivel_educ cuenta_corr cuenta_aho tcredito tdebito no_banco ///
				aporte_pension clap ingsuf_comida comida_trueque 

* Identifying missing values in potential independent variables for Mincer equation
	*Note: "mdesc" displays the number and proportion of missing values for each variable in varlist.
	mdesc $xvar if jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	//(inlist(recibe_ingresopenjub,1,2,3) | jubi_pens==1) // Universo: los que reportaron recibir (caso 1.a) o ocupados (caso 2)
		// few % of missinf values except nivel_educ
		// c_* will only be useful if we see divided by categ_ocup as they are only defined for workers who are not independent workers or employers
		
	/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
	values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
	the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

	global xvar1  edad edad2 agegroup hombre npers_viv miembros total_hrtr_sinmis ///
		p_agegroup_sinmis1 p_agegroup_sinmis2 p_agegroup_sinmis3 p_agegroup_sinmis4 p_agegroup_sinmis5 p_agegroup_sinmis6 p_agegroup_sinmis7 p_agegroup_sinmis8 ///
		p_relacion_comp_sinmis1 p_relacion_comp_sinmis2 p_relacion_comp_sinmis3 p_relacion_comp_sinmis4 p_relacion_comp_sinmis5 p_relacion_comp_sinmis6 p_relacion_comp_sinmis7 p_relacion_comp_sinmis8 p_relacion_comp_sinmis9 p_relacion_comp_sinmis10 p_relacion_comp_sinmis11 p_relacion_comp_sinmis12 p_relacion_comp_sinmis13 ///
		p_estado_civil_sinmis1 p_estado_civil_sinmis2 p_estado_civil_sinmis3 p_estado_civil_sinmis4 p_estado_civil_sinmis5 p_estado_civil_sinmis6 p_region_est1_sinmis1 p_region_est1_sinmis2 p_region_est1_sinmis3 p_region_est1_sinmis4 p_region_est1_sinmis5 p_region_est1_sinmis6 p_region_est1_sinmis7 p_region_est1_sinmis8 p_region_est1_sinmis9 ///
		p_municipio_sinmis1 p_municipio_sinmis2 p_municipio_sinmis3 p_municipio_sinmis4 p_municipio_sinmis5 p_municipio_sinmis6 p_municipio_sinmis7 p_municipio_sinmis8 p_municipio_sinmis9 p_municipio_sinmis10 p_municipio_sinmis11 p_municipio_sinmis12 p_municipio_sinmis13 p_municipio_sinmis14 p_municipio_sinmis15 p_municipio_sinmis16 p_municipio_sinmis17 p_municipio_sinmis18 p_municipio_sinmis19 p_municipio_sinmis20 p_municipio_sinmis21 p_municipio_sinmis22 p_municipio_sinmis23 p_municipio_sinmis24 p_municipio_sinmis25 ///
		p_tipo_vivienda_hh_sinmis1 p_tipo_vivienda_hh_sinmis2 p_tipo_vivienda_hh_sinmis3 p_tipo_vivienda_hh_sinmis4 p_tipo_vivienda_hh_sinmis5 p_tipo_vivienda_hh_sinmis6 p_tipo_vivienda_hh_sinmis7 p_tipo_vivienda_hh_sinmis8 ///
		p_propieta_hh_sinmis1 p_propieta_hh_sinmis2 p_propieta_hh_sinmis3 ///
		p_auto_hh_sinmis1 p_auto_hh_sinmis2 p_auto_hh_sinmis3 p_heladera_hh_sinmis1 p_heladera_hh_sinmis2 p_heladera_hh_sinmis3 p_lavarropas_hh_sinmis1 p_lavarropas_hh_sinmis2 p_lavarropas_hh_sinmis3 p_computadora_hh_sinmis1 p_computadora_hh_sinmis2 p_computadora_hh_sinmis3 p_internet_hh_sinmis1 p_internet_hh_sinmis2 p_internet_hh_sinmis3 p_televisor_hh_sinmis1 p_televisor_hh_sinmis2 p_televisor_hh_sinmis3 p_calentador_hh_sinmis1 p_calentador_hh_sinmis2 p_calentador_hh_sinmis3 p_aire_hh_sinmis1 p_aire_hh_sinmis2 p_aire_hh_sinmis3 p_tv_cable_hh_sinmis1 p_tv_cable_hh_sinmis2 p_tv_cable_hh_sinmis3 p_microondas_hh_sinmis1 p_microondas_hh_sinmis2 p_microondas_hh_sinmis3 ///
		p_afiliado_segsalud_comp_sinmis1 p_afiliado_segsalud_comp_sinmis2 p_afiliado_segsalud_comp_sinmis3 p_afiliado_segsalud_comp_sinmis4 p_afiliado_segsalud_comp_sinmis5 p_afiliado_segsalud_comp_sinmis6 p_afiliado_segsalud_comp_sinmis7 ///
		p_nivel_educ_sinmis1 p_nivel_educ_sinmis2 p_nivel_educ_sinmis3 p_nivel_educ_sinmis4p_nivel_educ_sinmis5 p_nivel_educ_sinmis6 p_nivel_educ_sinmis7 p_nivel_educ_sinmis8 p_asiste_o_dejoypq_sinmis1 p_asiste_o_dejoypq_sinmis2 p_asiste_o_dejoypq_sinmis3 p_asiste_o_dejoypq_sinmis4 p_asiste_o_dejoypq_sinmis5 p_asiste_o_dejoypq_sinmis6 p_asiste_o_dejoypq_sinmis7 p_asiste_o_dejoypq_sinmis8 p_asiste_o_dejoypq_sinmis9 p_asiste_o_dejoypq_sinmis10 p_asiste_o_dejoypq_sinmis11 p_asiste_o_dejoypq_sinmis12 p_asiste_o_dejoypq_sinmis13 p_asiste_o_dejoypq_sinmis14 p_asiste_o_dejoypq_sinmis15 p_asiste_o_dejoypq_sinmis16 p_asiste_o_dejoypq_sinmis17 ///
		p_tarea_sinmis1 p_tarea_sinmis2 p_tarea_sinmis3 p_tarea_sinmis4 p_tarea_sinmis5 p_tarea_sinmis6 p_tarea_sinmis7 p_tarea_sinmis8 p_tarea_sinmis9 p_tarea_sinmis10p_tarea_sinmis11 p_sector_encuesta_sinmis1 p_sector_encuesta_sinmis2 p_sector_encuesta_sinmis3 p_sector_encuesta_sinmis4 p_sector_encuesta_sinmis5 p_sector_encuesta_sinmis6 p_sector_encuesta_sinmis7 p_sector_encuesta_sinmis8 p_sector_encuesta_sinmis9 p_sector_encuesta_sinmis10 p_sector_encuesta_sinmis11 p_categ_ocu_sinmis1 p_categ_ocu_sinmis2 p_categ_ocu_sinmis3 p_categ_ocu_sinmis4 p_categ_ocu_sinmis5 p_categ_ocu_sinmis6 p_categ_ocu_sinmis7p_categ_ocu_sinmis8 p_c_sso_sinmis1 p_c_sso_sinmis2 p_c_sso_sinmis3 ///
		p_c_rpv_sinmis1 p_c_rpv_sinmis2 p_c_rpv_sinmis3 p_c_spf_sinmis1 p_c_spf_sinmis2 p_c_spf_sinmis3 p_c_aca_sinmis1 p_c_aca_sinmis2 p_c_aca_sinmis3 p_c_sps_sinmis1 p_c_sps_sinmis2 p_c_sps_sinmis3 p_c_otro_sinmis1 p_c_otro_sinmis2 p_c_otro_sinmis3 ///
		p_cuenta_corr_sinmis1 p_cuenta_corr_sinmis2 p_cuenta_corr_sinmis3 p_cuenta_aho_sinmis1 p_cuenta_aho_sinmis2 p_cuenta_aho_sinmis3 p_tcredito_sinmis1 p_tcredito_sinmis2 p_tcredito_sinmis3 p_tdebito_sinmis1 p_tdebito_sinmis2 p_tdebito_sinmis3 p_no_banco_sinmis1 p_no_banco_sinmis2 p_no_banco_sinmis3 ///
		p_aporte_pension_sinmis1 p_aporte_pension_sinmis2 p_aporte_pension_sinmis3 p_aporte_pension_sinmis4 p_aporte_pension_sinmis5 p_aporte_pension_sinmis6 ///
		p_clap_sinmis1 p_clap_sinmis2 p_clap_sinmis3 p_ingsuf_comida_sinmis1 p_ingsuf_comida_sinmis2 p_ingsuf_comida_sinmis3 p_comida_trueque_sinmis1 p_comida_trueque_sinmis2 p_comida_trueque_sinmis3
		 
    

	
	/* edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil_sinmis region_est1 entidad municipio 	///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh_sinmis propieta_hh auto_hh_sinmis /*anio_auto_hh_sinmis*/ heladera_hh_sinmis lavarropas_hh_sinmis computadora_hh_sinmis internet_hh_sinmis televisor_hh_sinmis calentador_hh_sinmis aire_hh_sinmis tv_cable_hh_sinmis microondas_hh_sinmis ///
				afiliado_segsalud_comp_sinmis ///
				nivel_educ_sinmis asiste_o_dejoypq_sinmis ///
				/* tarea_sinmis sector_encuesta_sinmis categ_ocu_sinmis total_hrtr_sinmis ///
				 c_sso_sinmis c_rpv_sinmis c_spf_sinmis c_aca_sinmis c_sps_sinmis c_otro_sinmis */ ///
				cuenta_corr_sinmis cuenta_aho_sinmis tcredito_sinmis tdebito_sinmis no_banco_sinmis ///
				/* aporte_pension_sinmis*/ clap_sinmis ingsuf_comida_sinmis comida_trueque_sinmis 
	mdesc $xvar1 if jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 */
	
	
	* Dependent variable
	gen log_bene = ln(bene) if bene!=.
	

///*** CHECKING WHICH VARIABLES MAXIMIZE R2 ***///
	
	** LASSO
		/* 	LASSO is one of the first and still most widely used techniques employed in machine learning. 
		For this specification, you may want to use the command lassoregress. 
		You will first need to install the package elasticregress, using the command line ssc install elasticregress. 
		For the purposes of this exercise, please use as argument for the Lasso command set seed 1 and the default number of folds to be 10. */
		
		*set seed 1
		
		lassoregress log_bene $xvar1 if log_bene>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0, numfolds(5)
		display e(varlist_nonzero)
		global lassovars = e(varlist_nonzero)
		

	** Vselect
		*Problema: no se puede poner variable como factor variables (incluir dummys una a una) 
		* Use option: best 
		* Select model with highest R2 como criterio
		* return - rpret list
		vselect log_bene $xvar1 if log_bene>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0, best
		display r(predlist)
		local vselectvars = r(predlist)
	
	* Best: model with xx vars. Copy and paste them here:
		global vselectvars  region_est1 no_banco_sinmis entidad calentador_hh_sinmis tdebito_sinmis ///
		afiliado_segsalud_comp_sinmis computadora_hh_sinmis comida_trueque_sinmis npers_viv ///
		asiste_o_dejoypq_sinmis cuenta_corr_sinmis municipio estado_civil_sinmis tipo_vivienda_hh relacion_comp ///
		cuenta_aho_sinmis heladera_hh_sinmis aire_hh_sinmis auto_hh_sinmis tv_cable_hh_sinmis agegroup


	
///*** EQUATION ***///
	
	*Obs: Regress without using weights because we try to predict indivudual income
	*(should not be done with "pondera")
	
	reg log_bene $xvar1 if log_bene>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	reg log_bene $lassovars if log_bene>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 
	reg log_bene $vselectvars if log_bene>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	
	* The variables which leads to the maximun R2 are selected for the imputation
	set more off
	mi set flong
	set seed 66778899
	mi register imputed log_bene
	mi impute regress log_bene $vselectvars if log_bene>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0, add(1) rseed(66778899) force noi 
	mi unregister log_bene

	//clonevar dila_m_zero = dlinc_zero 
	//clonevar dila_m_miss1 = dlinc_miss1
	//clonevar dila_m_miss2 = dlinc_miss2
	//clonevar dila_m_miss3 = dlinc_miss3
	
* Retrieving original variables
	foreach x of varlist bene {
	gen `x'2=.
	* Genero var. con valores preliminares de los missing a imputar
	local j=1
	* Si algun valor imputado es menor que el menor ingreso, reemplazar con el menor ingreso
	sum `x' if `x'>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 & _mi_m==0
	scalar min_`x'`j'=r(min)
	*replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if ocup_o_rtarecibenilamon==1 & d`x'_miss3==1
	replace `x'2= exp(log_`x') if jubi_o_rtarecibejubi==1 & d`x'_miss3==1  
	replace `x'2=min_`x'`j' if (jubi_o_rtarecibejubi==1 & `x'2<min_`x'`j' & d`x'_miss3==1)
	replace `x'=`x'2 if (jubi_o_rtarecibejubi==1 & d`x'_miss3==1 & _mi_m!=0)
	local j=`j'+1
	drop `x'2
	}	
	mdesc bene if _mi_m==0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	mdesc bene if _mi_m==1 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 //cheking we do not have incompleted values in labor income after the imputation

	gen imp_id=_mi_m
	*mi unset (Para borrar cosas que quedaron de la imputacion en el memoria)
	char _dta[_mi_style] 
	char _dta[_mi_marker] 
	char _dta[_mi_M] 
	char _dta[_mi_N] 
	char _dta[_mi_update] 
	char _dta[_mi_rvars] 
	char _dta[_mi_ivars] 
	drop _mi_id _mi_miss _mi_m	

	drop if imp_id==0 // Saco la base sin imputaciones
	collapse (mean) bene, by(id com) // La imputacion va a ser el promedio de las bases imputadas
	rename bene bene_imp1
	save "$pathpathoutexcel\VEN_bene_imp1.dta", replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$path\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
merge 1:1 id com using "$pathpathoutexcel\VEN_bene_imp1.dta"


foreach x of varlist bene {
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

*** Comparing not imputed versus imputed labor income distribution
foreach x in bene {
twoway (kdensity log_`x' if `x'>0 & jubi_o_rtarecibejubi==1 , lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & jubi_o_rtarecibejubi==1, lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1_`y', replace) saving(kd_`x'1_`y', replace)
graph export kd_`x'1.png, replace
}

foreach x in bene {
	tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90 p99) save
	matrix aux1=r(StatTotal)'
	tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90 p99) save
	matrix aux2=r(StatTotal)'
	matrix imp=nullmat(imp)\(aux1,aux2)
}

matrix rownames imp="2019"
matrix list imp

putexcel set "$pathpathoutexcel\VEN_income_imputation_2019_JL.xlsx", sheet("labor_beneimp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp


