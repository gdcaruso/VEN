*******************************************************************************
*** ENCOVI 2019 - Income imputation : PENSIONS
********************************************************************************
/*===========================================================================
Country name:	Venezuela
Year:			2014-2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Julieta Ladronis, Trinidad Saavedra
Dependencies:		The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			

Note: Income imputation - Identification missing values
=============================================================================*/
********************************************************************************
clear all

// Define rootpath according to user (silenced as this is done by main now)
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
		if $trini   {
		}
		
		if $male   {
		        global dopath "C:\Users\wb550905\GitHub\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}

	global forimp "$datapath\data_management\output\for imputation"
	global pathoutexcel "$dopath\data_management\management\4. income imputation\output"
*/
********************************************************************************

///*** OPEN DATABASE ***///

use "$forimp\ENCOVI_forimputation_2019.dta", clear

///*** Check missing values to fix
	mdesc jubpen if jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0

///*** VARIABLES FOR MINCER EQUATION ***///

	 global xvar edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
					tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh anio_auto_hh heladera_hh lavarropas_hh	computadora_hh internet_hh televisor_hh calentador_hh aire_hh	tv_cable_hh	microondas_hh  ///
					afiliado_segsalud_comp ///
					nivel_educ asiste_o_dejoypq ///
					tarea sector_encuesta categ_ocu total_hrtr ///
					c_sso c_rpv c_spf c_aca c_sps c_otro ///
					cuenta_corr cuenta_aho tcredito tdebito no_banco ///
					aporte_pension clap ingsuf_comida comida_trueque 
					
///*** Check missing values predictors for these individuals		
	mdesc jubpen $xvar if jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
			
	/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
	values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
	the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

	global xvar1 edad edad2 agegroup hombre npers_viv miembros total_hrtr_sinmis ///
		p_agegroup_sinmis1 p_agegroup_sinmis2 p_agegroup_sinmis3 p_agegroup_sinmis4 p_agegroup_sinmis5 p_agegroup_sinmis6 p_agegroup_sinmis7 p_agegroup_sinmis8 ///
		p_relacion_comp_sinmis1 p_relacion_comp_sinmis2 p_relacion_comp_sinmis3 p_relacion_comp_sinmis4 p_relacion_comp_sinmis5 p_relacion_comp_sinmis6 p_relacion_comp_sinmis7 p_relacion_comp_sinmis8 p_relacion_comp_sinmis9 p_relacion_comp_sinmis10 p_relacion_comp_sinmis11 p_relacion_comp_sinmis12 p_relacion_comp_sinmis13 ///
		p_estado_civil_sinmis1 p_estado_civil_sinmis2 p_estado_civil_sinmis3 p_estado_civil_sinmis4 p_estado_civil_sinmis5 p_estado_civil_sinmis6 p_region_est1_sinmis1 p_region_est1_sinmis2 p_region_est1_sinmis3 p_region_est1_sinmis4 p_region_est1_sinmis5 p_region_est1_sinmis6 p_region_est1_sinmis7 p_region_est1_sinmis8 p_region_est1_sinmis9 ///
		p_municipio_sinmis1 p_municipio_sinmis2 p_municipio_sinmis3 p_municipio_sinmis4 p_municipio_sinmis5 p_municipio_sinmis6 p_municipio_sinmis7 p_municipio_sinmis8 p_municipio_sinmis9 p_municipio_sinmis10 p_municipio_sinmis11 p_municipio_sinmis12 p_municipio_sinmis13 p_municipio_sinmis14 p_municipio_sinmis15 p_municipio_sinmis16 p_municipio_sinmis17 p_municipio_sinmis18 p_municipio_sinmis19 p_municipio_sinmis20 p_municipio_sinmis21 p_municipio_sinmis22 p_municipio_sinmis23 p_municipio_sinmis24 p_municipio_sinmis25 ///
		p_tipo_vivienda_hh_sinmis1 p_tipo_vivienda_hh_sinmis2 p_tipo_vivienda_hh_sinmis3 p_tipo_vivienda_hh_sinmis4 p_tipo_vivienda_hh_sinmis5 p_tipo_vivienda_hh_sinmis6 p_tipo_vivienda_hh_sinmis7 p_tipo_vivienda_hh_sinmis8 ///
		p_propieta_hh_sinmis1 p_propieta_hh_sinmis2 p_propieta_hh_sinmis3 ///
		p_auto_hh_sinmis1 p_auto_hh_sinmis2 p_auto_hh_sinmis3 p_heladera_hh_sinmis1 p_heladera_hh_sinmis2 p_heladera_hh_sinmis3 p_lavarropas_hh_sinmis1 p_lavarropas_hh_sinmis2 p_lavarropas_hh_sinmis3 p_computadora_hh_sinmis1 p_computadora_hh_sinmis2 p_computadora_hh_sinmis3 p_internet_hh_sinmis1 p_internet_hh_sinmis2 p_internet_hh_sinmis3 p_televisor_hh_sinmis1 p_televisor_hh_sinmis2 p_televisor_hh_sinmis3 p_calentador_hh_sinmis1 p_calentador_hh_sinmis2 p_calentador_hh_sinmis3 p_aire_hh_sinmis1 p_aire_hh_sinmis2 p_aire_hh_sinmis3 p_tv_cable_hh_sinmis1 p_tv_cable_hh_sinmis2 p_tv_cable_hh_sinmis3 p_microondas_hh_sinmis1 p_microondas_hh_sinmis2 p_microondas_hh_sinmis3 ///
		p_afiliado_segsalud_comp_sinmis1 p_afiliado_segsalud_comp_sinmis2 p_afiliado_segsalud_comp_sinmis3 p_afiliado_segsalud_comp_sinmis4 p_afiliado_segsalud_comp_sinmis5 p_afiliado_segsalud_comp_sinmis6 p_afiliado_segsalud_comp_sinmis7 ///
		p_nivel_educ_sinmis1 p_nivel_educ_sinmis2 p_nivel_educ_sinmis3 p_nivel_educ_sinmis4 p_nivel_educ_sinmis5 p_nivel_educ_sinmis6 p_nivel_educ_sinmis7 p_nivel_educ_sinmis8 /*p_asiste_o_dejoypq_sinmis1 p_asiste_o_dejoypq_sinmis2 p_asiste_o_dejoypq_sinmis3 p_asiste_o_dejoypq_sinmis4 p_asiste_o_dejoypq_sinmis5 p_asiste_o_dejoypq_sinmis6 p_asiste_o_dejoypq_sinmis7 p_asiste_o_dejoypq_sinmis8 p_asiste_o_dejoypq_sinmis9 p_asiste_o_dejoypq_sinmis10 p_asiste_o_dejoypq_sinmis11 p_asiste_o_dejoypq_sinmis12 p_asiste_o_dejoypq_sinmis13 p_asiste_o_dejoypq_sinmis14 p_asiste_o_dejoypq_sinmis15 p_asiste_o_dejoypq_sinmis16 p_asiste_o_dejoypq_sinmis17*/ ///
		/*p_tarea_sinmis1 p_tarea_sinmis2 p_tarea_sinmis3 p_tarea_sinmis4 p_tarea_sinmis5 p_tarea_sinmis6 p_tarea_sinmis7 p_tarea_sinmis8 p_tarea_sinmis9 p_tarea_sinmis10 p_tarea_sinmis11 p_sector_encuesta_sinmis1 p_sector_encuesta_sinmis2 p_sector_encuesta_sinmis3 p_sector_encuesta_sinmis4 p_sector_encuesta_sinmis5 p_sector_encuesta_sinmis6 p_sector_encuesta_sinmis7 p_sector_encuesta_sinmis8 p_sector_encuesta_sinmis9 p_sector_encuesta_sinmis10 p_sector_encuesta_sinmis11 p_categ_ocu_sinmis1 p_categ_ocu_sinmis2 p_categ_ocu_sinmis3 p_categ_ocu_sinmis4 p_categ_ocu_sinmis5 p_categ_ocu_sinmis6 p_categ_ocu_sinmis7 p_categ_ocu_sinmis8*/ /*p_c_sso_sinmis1 p_c_sso_sinmis2 p_c_sso_sinmis3*/ ///
		/*p_c_rpv_sinmis1 p_c_rpv_sinmis2 p_c_rpv_sinmis3 p_c_spf_sinmis1 p_c_spf_sinmis2 p_c_spf_sinmis3 p_c_aca_sinmis1 p_c_aca_sinmis2 p_c_aca_sinmis3 p_c_sps_sinmis1 p_c_sps_sinmis2 p_c_sps_sinmis3 p_c_otro_sinmis1 p_c_otro_sinmis2 p_c_otro_sinmis3*/ ///
		p_cuenta_corr_sinmis1 p_cuenta_corr_sinmis2 p_cuenta_corr_sinmis3 p_cuenta_aho_sinmis1 p_cuenta_aho_sinmis2 p_cuenta_aho_sinmis3 p_tcredito_sinmis1 p_tcredito_sinmis2 p_tcredito_sinmis3 p_tdebito_sinmis1 p_tdebito_sinmis2 p_tdebito_sinmis3 p_no_banco_sinmis1 p_no_banco_sinmis2 p_no_banco_sinmis3 ///
		/*p_aporte_pension_sinmis1 p_aporte_pension_sinmis2 p_aporte_pension_sinmis3 p_aporte_pension_sinmis4 p_aporte_pension_sinmis5 p_aporte_pension_sinmis6*/ ///
		p_clap_sinmis1 p_clap_sinmis2 p_clap_sinmis3 p_ingsuf_comida_sinmis1 p_ingsuf_comida_sinmis2 p_ingsuf_comida_sinmis3 p_comida_trueque_sinmis1 p_comida_trueque_sinmis2 p_comida_trueque_sinmis3
		 
	* Identifying missing values in potential independent variables for Mincer equation
	*Note: "mdesc" displays the number and proportion of missing values for each variable in varlist.	
	mdesc $xvar1 if jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 

	* Generate dependent variable
	gen log_jubpen = ln(jubpen) if jubpen!=.
	

///*** CHECKING WHICH VARIABLES MAXIMIZE R2 ***///
	
	** LASSO
		/* 	LASSO is one of the first and still most widely used techniques employed in machine learning. 
		For this specification, you may want to use the command lassoregress. 
		You will first need to install the package elasticregress, using the command line ssc install elasticregress. 
		For the purposes of this exercise, please use as argument for the Lasso command set seed 1 and the default number of folds to be 10. */
		
		set seed 1
		lassoregress log_jubpen $xvar1 if log_jubpen>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0, numfolds(5)
		display e(varlist_nonzero)
		global lassovars = e(varlist_nonzero)
		
	** Stepwise (pr usa Chris; Trini usa backward)
		* ??
	
	** Vselect
		*Problema: no se puede poner variable como factor variables (incluir dummys una a una) 
		* Use option: best 
		* Select model with highest R2 como criterio
		* return - rpret list
		//vselect log_jubpen $xvar1 if log_jubpen>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0, best
	
	* Best: model with 21 vars. Copy and paste them here:
		//global vselectvars  
	
///*** EQUATION ***///
	
	*Obs: Regress without using weights because we try to predict indivudual income
	*(should not be done with "pondera")
	
	*reg log_jubpen $xvar1 if log_jubpen>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	reg log_jubpen $lassovars if log_jubpen>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 
	//reg log_jubpen $vselectvars if log_jubpen>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	
	* The variables which leads to the maximun R2 are selected for the imputation
	set more off
	mi set flong
	set seed 66778899
	mi register imputed log_jubpen
	mi impute regress log_jubpen $lassovars if log_jubpen>0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0, add(1) rseed(66778899) force noi 
	mi unregister log_jubpen

	//clonevar dila_m_zero = dlinc_zero 
	//clonevar dila_m_miss1 = dlinc_miss1
	//clonevar dila_m_miss2 = dlinc_miss2
	//clonevar dila_m_miss3 = dlinc_miss3
	
* Retrieving original variables
	foreach x of varlist jubpen {
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
	mdesc jubpen if _mi_m==0 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0
	mdesc jubpen if _mi_m==1 & jubi_o_rtarecibejubi==1 & recibe_ingresopenjub!=0 //cheking we do not have incompleted values in labor income after the imputation

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
	collapse (mean) jubpen, by(interview__key interview__id quest com) // La imputacion va a ser el promedio de las bases imputadas
	rename jubpen jubpen_imp1
	save "$forimp\VEN_jubpen_imp1.dta", replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$forimp\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$forimp\VEN_jubpen_imp1.dta"


foreach x of varlist jubpen {
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

*** Comparing not imputed versus imputed labor income distribution
cd "$pathoutexcel\income_imp"
foreach x in jubpen {
twoway (kdensity log_`x' if `x'>0 & jubi_o_rtarecibejubi==1 , lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & jubi_o_rtarecibejubi==1, lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
graph export "kd_`x'1.png", replace
}

foreach x in jubpen {
	tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux1=r(StatTotal)'
	tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux2=r(StatTotal)'
	matrix imp=nullmat(imp)\(aux1,aux2)
}

matrix rownames imp="2019"
matrix list imp

putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("labor_jubpenimp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp

********************************************************************************
********************************************************************************
*** Imputation model for labor income: using chained equations
********************************************************************************
********************************************************************************

* Hacer?

