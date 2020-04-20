********************************************************************************
*** ENCOVI 2019 - Income imputation: MONETARY LABOR INCOME 
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
		global lauta   0
		
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
	
///*** CHECKING MISSING VALUES TO BE IMPUTED ***///
	* How many we are going to impute
	mdesc ila_m if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.) 

		// if me decís que recibiste pero ila monteario missing Ó estás ocupado, no decís que no recibís ila_m (eso sería un verdadero missing) y no contestás un monto de ila no mon.
		* Check: da ok! Igual que la cantidad de miss3

///*** VARIABLES FOR MINCER EQUATION ***///

	 global xvar edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
					tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh anio_auto_hh heladera_hh lavarropas_hh	computadora_hh internet_hh televisor_hh calentador_hh aire_hh	tv_cable_hh	microondas_hh  ///
					afiliado_segsalud_comp ///
					nivel_educ ///
					tarea sector_encuesta categ_ocu total_hrtr ///
					/*c_sso c_rpv c_spf c_aca c_sps c_otro*/ ///
					cuenta_corr cuenta_aho tcredito tdebito no_banco ///
					aporte_pension clap ingsuf_comida comida_trueque 

///*** Check missing values predictors for these individuals		
	mdesc $xvar if ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0

* Identifying missing values in potential independent variables for Mincer equation
	*Note: "mdesc" displays the number and proportion of missing values for each variable in varlist.
	mdesc $xvar if ocup_o_rtarecibenilamon==1 // Universo: los que reportaron recibir (caso 1.a) o ocupados (caso 2)
		// few % of missinf values except nivel_educ
		// c_* will only be useful if we see divided by categ_ocup as they are only defined for workers who are not independent workers or employers
		
	/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
	values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
	the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

	  	global xvar1 edad edad2 hombre npers_viv miembros total_hrtr_sinmis ///
		p_agegroup_sinmis1 p_agegroup_sinmis2 p_agegroup_sinmis3 p_agegroup_sinmis4 p_agegroup_sinmis5 p_agegroup_sinmis6 p_agegroup_sinmis7 p_agegroup_sinmis8 ///
		p_relacion_comp_sinmis1 p_relacion_comp_sinmis2 p_relacion_comp_sinmis3 p_relacion_comp_sinmis4 p_relacion_comp_sinmis5 p_relacion_comp_sinmis6 p_relacion_comp_sinmis7 p_relacion_comp_sinmis8 p_relacion_comp_sinmis9 p_relacion_comp_sinmis10 p_relacion_comp_sinmis11 p_relacion_comp_sinmis12 p_relacion_comp_sinmis13 ///
		p_estado_civil_sinmis1 p_estado_civil_sinmis2 p_estado_civil_sinmis3 p_estado_civil_sinmis4 p_estado_civil_sinmis5 p_estado_civil_sinmis6 p_region_est1_sinmis1 p_region_est1_sinmis2 p_region_est1_sinmis3 p_region_est1_sinmis4 p_region_est1_sinmis5 p_region_est1_sinmis6 p_region_est1_sinmis7 p_region_est1_sinmis8 p_region_est1_sinmis9 ///
		p_municipio_sinmis1 p_municipio_sinmis2 p_municipio_sinmis3 p_municipio_sinmis4 p_municipio_sinmis5 p_municipio_sinmis6 p_municipio_sinmis7 p_municipio_sinmis8 p_municipio_sinmis9 p_municipio_sinmis10 p_municipio_sinmis11 p_municipio_sinmis12 p_municipio_sinmis13 p_municipio_sinmis14 p_municipio_sinmis15 p_municipio_sinmis16 p_municipio_sinmis17 p_municipio_sinmis18 p_municipio_sinmis19 p_municipio_sinmis20 p_municipio_sinmis21 p_municipio_sinmis22 p_municipio_sinmis23 p_municipio_sinmis24 p_municipio_sinmis25 ///
		p_tipo_vivienda_hh_sinmis1 p_tipo_vivienda_hh_sinmis2 p_tipo_vivienda_hh_sinmis3 p_tipo_vivienda_hh_sinmis4 p_tipo_vivienda_hh_sinmis5 p_tipo_vivienda_hh_sinmis6 p_tipo_vivienda_hh_sinmis7 p_tipo_vivienda_hh_sinmis8 ///
		p_propieta_hh_sinmis1 p_propieta_hh_sinmis2 p_propieta_hh_sinmis3 ///
		p_auto_hh_sinmis1 p_auto_hh_sinmis2 p_auto_hh_sinmis3 p_heladera_hh_sinmis1 p_heladera_hh_sinmis2 p_heladera_hh_sinmis3 p_lavarropas_hh_sinmis1 p_lavarropas_hh_sinmis2 p_lavarropas_hh_sinmis3 p_computadora_hh_sinmis1 p_computadora_hh_sinmis2 p_computadora_hh_sinmis3 p_internet_hh_sinmis1 p_internet_hh_sinmis2 p_internet_hh_sinmis3 p_televisor_hh_sinmis1 p_televisor_hh_sinmis2 p_televisor_hh_sinmis3 p_calentador_hh_sinmis1 p_calentador_hh_sinmis2 p_calentador_hh_sinmis3 p_aire_hh_sinmis1 p_aire_hh_sinmis2 p_aire_hh_sinmis3 p_tv_cable_hh_sinmis1 p_tv_cable_hh_sinmis2 p_tv_cable_hh_sinmis3 p_microondas_hh_sinmis1 p_microondas_hh_sinmis2 p_microondas_hh_sinmis3 ///
		p_afiliado_segsalud_comp_sinmis1 p_afiliado_segsalud_comp_sinmis2 p_afiliado_segsalud_comp_sinmis3 p_afiliado_segsalud_comp_sinmis4 p_afiliado_segsalud_comp_sinmis5 p_afiliado_segsalud_comp_sinmis6 p_afiliado_segsalud_comp_sinmis7 ///
		p_nivel_educ_sinmis1 p_nivel_educ_sinmis2 p_nivel_educ_sinmis3 p_nivel_educ_sinmis4 p_nivel_educ_sinmis5 p_nivel_educ_sinmis6 p_nivel_educ_sinmis7 p_nivel_educ_sinmis8 /*p_asiste_o_dejoypq_sinmis1 p_asiste_o_dejoypq_sinmis2 p_asiste_o_dejoypq_sinmis3 p_asiste_o_dejoypq_sinmis4 p_asiste_o_dejoypq_sinmis5 p_asiste_o_dejoypq_sinmis6 p_asiste_o_dejoypq_sinmis7 p_asiste_o_dejoypq_sinmis8 p_asiste_o_dejoypq_sinmis9 p_asiste_o_dejoypq_sinmis10 p_asiste_o_dejoypq_sinmis11 p_asiste_o_dejoypq_sinmis12 p_asiste_o_dejoypq_sinmis13 p_asiste_o_dejoypq_sinmis14 p_asiste_o_dejoypq_sinmis15 p_asiste_o_dejoypq_sinmis16 p_asiste_o_dejoypq_sinmis17*/ ///
		p_tarea_sinmis1 p_tarea_sinmis2 p_tarea_sinmis3 p_tarea_sinmis4 p_tarea_sinmis5 p_tarea_sinmis6 p_tarea_sinmis7 p_tarea_sinmis8 p_tarea_sinmis9 p_tarea_sinmis10 p_tarea_sinmis11 p_sector_encuesta_sinmis1 p_sector_encuesta_sinmis2 p_sector_encuesta_sinmis3 p_sector_encuesta_sinmis4 p_sector_encuesta_sinmis5 p_sector_encuesta_sinmis6 p_sector_encuesta_sinmis7 p_sector_encuesta_sinmis8 p_sector_encuesta_sinmis9 p_sector_encuesta_sinmis10 p_sector_encuesta_sinmis11 p_categ_ocu_sinmis1 p_categ_ocu_sinmis2 p_categ_ocu_sinmis3 p_categ_ocu_sinmis4 p_categ_ocu_sinmis5 p_categ_ocu_sinmis6 p_categ_ocu_sinmis7 p_categ_ocu_sinmis8 /*p_c_sso_sinmis1 p_c_sso_sinmis2 p_c_sso_sinmis3*/ ///
		/*p_c_rpv_sinmis1 p_c_rpv_sinmis2 p_c_rpv_sinmis3 p_c_spf_sinmis1 p_c_spf_sinmis2 p_c_spf_sinmis3 p_c_aca_sinmis1 p_c_aca_sinmis2 p_c_aca_sinmis3 p_c_sps_sinmis1 p_c_sps_sinmis2 p_c_sps_sinmis3 p_c_otro_sinmis1 p_c_otro_sinmis2 p_c_otro_sinmis3*/ ///
		p_cuenta_corr_sinmis1 p_cuenta_corr_sinmis2 p_cuenta_corr_sinmis3 p_cuenta_aho_sinmis1 p_cuenta_aho_sinmis2 p_cuenta_aho_sinmis3 p_tcredito_sinmis1 p_tcredito_sinmis2 p_tcredito_sinmis3 p_tdebito_sinmis1 p_tdebito_sinmis2 p_tdebito_sinmis3 p_no_banco_sinmis1 p_no_banco_sinmis2 p_no_banco_sinmis3 ///
		p_aporte_pension_sinmis1 p_aporte_pension_sinmis2 p_aporte_pension_sinmis3 p_aporte_pension_sinmis4 p_aporte_pension_sinmis5 p_aporte_pension_sinmis6 ///
		p_clap_sinmis1 p_clap_sinmis2 p_clap_sinmis3 p_ingsuf_comida_sinmis1 p_ingsuf_comida_sinmis2 p_ingsuf_comida_sinmis3 p_comida_trueque_sinmis1 p_comida_trueque_sinmis2 p_comida_trueque_sinmis3

	
	* Nuestra idea para laboral monetario
		*local nuestrasvars edad edad2 hombre relacion_comp npers_viv estado_civil entidad tipo_vivienda_hh propieta_hh microondas_hh nivel_educ afiliado_segsalud_comp no_banco_sinmis
	
	* Generate dependent variable
	gen log_ila_m = ln(ila_m) if ila_m!=.

///*** CHECKING WHICH VARIABLES MAXIMIZE R2 ***///
	
	** LASSO
		/* 	LASSO is one of the first and still most widely used techniques employed in machine learning. 
		For this specification, you may want to use the command lassoregress. 
		You will first need to install the package elasticregress, using the command line ssc install elasticregress. 
		For the purposes of this exercise, please use as argument for the Lasso command set seed 1 and the default number of folds to be 10. */
		
		sort interview__id interview__key quest com
		set seed 66778899 
		lassoregress log_ila_m $xvar1 if log_ila_m>0 & log_ila_m!=. & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, numfolds(10)
		display e(varlist_nonzero)
		global lassovars = e(varlist_nonzero)
		
		*Selected on april 20:
		/*
		global lassovars edad edad2 hombre miembros total_hrtr_sinmis p_agegroup_sinmis1 p_agegroup_sinmis2 p_agegroup_sinmis4 p_agegroup_sinmis5 p_agegroup_sinmis6 p_relacion_comp_sinmis1 ///
		p_relacion_comp_sinmis2 p_relacion_comp_sinmis4 p_relacion_comp_sinmis5 p_relacion_comp_sinmis6 p_relacion_comp_sinmis7 p_relacion_comp_sinmis8 ///
		p_relacion_comp_sinmis9 p_relacion_comp_sinmis10 p_relacion_comp_sinmis11 p_estado_civil_sinmis2 p_estado_civil_sinmis3 p_estado_civil_sinmis4 p_estado_civil_sinmis5 ///
		p_region_est1_sinmis1 p_region_est1_sinmis2 p_region_est1_sinmis3 p_region_est1_sinmis4 p_region_est1_sinmis5 p_region_est1_sinmis6 p_region_est1_sinmis7 p_region_est1_sinmis8 ///
		p_municipio_sinmis1 p_municipio_sinmis2 p_municipio_sinmis3 p_municipio_sinmis4 p_municipio_sinmis5 p_municipio_sinmis6 p_municipio_sinmis7 p_municipio_sinmis8 ///
		p_municipio_sinmis9 p_municipio_sinmis10 p_municipio_sinmis11 p_municipio_sinmis13 p_municipio_sinmis16 p_municipio_sinmis17 p_municipio_sinmis18 p_municipio_sinmis19 ///
		p_municipio_sinmis20 p_municipio_sinmis21 p_municipio_sinmis22 p_municipio_sinmis23 p_municipio_sinmis24 p_tipo_vivienda_hh_sinmis1 p_tipo_vivienda_hh_sinmis2 ///
		p_tipo_vivienda_hh_sinmis3 p_tipo_vivienda_hh_sinmis4 p_tipo_vivienda_hh_sinmis5 p_tipo_vivienda_hh_sinmis6 p_propieta_hh_sinmis1 p_auto_hh_sinmis2 p_heladera_hh_sinmis1 ///
		p_lavarropas_hh_sinmis1 p_lavarropas_hh_sinmis2 p_computadora_hh_sinmis1 p_computadora_hh_sinmis2 p_internet_hh_sinmis1 p_internet_hh_sinmis2 p_televisor_hh_sinmis1 ///
		p_calentador_hh_sinmis1 p_aire_hh_sinmis1 p_aire_hh_sinmis2 p_tv_cable_hh_sinmis2 p_microondas_hh_sinmis2 p_afiliado_segsalud_comp_sinmis1 p_afiliado_segsalud_comp_sinmis2 ///
		p_afiliado_segsalud_comp_sinmis3 p_afiliado_segsalud_comp_sinmis5 p_nivel_educ_sinmis1 p_nivel_educ_sinmis2 p_nivel_educ_sinmis3 p_nivel_educ_sinmis4 p_nivel_educ_sinmis5 ///
		p_nivel_educ_sinmis6 p_nivel_educ_sinmis7 p_tarea_sinmis1 p_tarea_sinmis2 p_tarea_sinmis3 p_tarea_sinmis4 p_tarea_sinmis5 p_tarea_sinmis6 p_tarea_sinmis7 p_tarea_sinmis8 p_tarea_sinmis10 ///
		p_sector_encuesta_sinmis1 p_sector_encuesta_sinmis2 p_sector_encuesta_sinmis3 p_sector_encuesta_sinmis4 p_sector_encuesta_sinmis5 p_sector_encuesta_sinmis6 ///
		p_sector_encuesta_sinmis7 p_sector_encuesta_sinmis8 p_sector_encuesta_sinmis9 p_sector_encuesta_sinmis10 p_categ_ocu_sinmis1 p_categ_ocu_sinmis2 p_categ_ocu_sinmis3 ///
		p_categ_ocu_sinmis4 p_categ_ocu_sinmis5 p_categ_ocu_sinmis6 p_cuenta_corr_sinmis2 p_cuenta_aho_sinmis1 p_tcredito_sinmis1 p_tdebito_sinmis1 p_no_banco_sinmis1 ///
		p_aporte_pension_sinmis1 p_aporte_pension_sinmis2 p_aporte_pension_sinmis3 p_aporte_pension_sinmis4 p_clap_sinmis1 p_clap_sinmis2 p_ingsuf_comida_sinmis2 p_comida_trueque_sinmis2
		*/
		
	** Vselect
		* Se puede usar R2adjustado como criterio. Ojo, no se puede poner variable como factor variables 
		* return - rpret list
	
	//vselect log_ila_m $xvar1 if log_ila_m>0 & log_ila_m!=. & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, best
	
	* Best: model with XX vars. Copy and paste them here:
	* CAMBIAR CUANDO CORRA CON LA NUEVA BASE
	/*local vselectvars categ_ocu_sinmis clap_sinmis comida_trueque_sinmis sector_encuesta_sinmis auto_hh_sinmis ///
					hombre total_hrtr_sinmis ingsuf_comida_sinmis tdebito_sinmis relacion_comp region_est1 ///
					tv_cable_hh_sinmis entidad tarea_sinmis lavarropas_hh_sinmis tcredito_sinmis material_piso_hh ///
					propieta_hh nivel_educ_sinmis cuenta_aho_sinmis municipio heladera_hh_sinmis televisor_hh_sinmis ///
					aporte_pension_sinmis tipo_sanitario_comp_hh computadora_hh_sinmis cuenta_corr_sinmis edad
	*/
	
	/*	NO: vselect log_ila_m `nuestrasvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1, backward r2adj
		display r(predlist)
		local vselectvars2 = r(predlist)	*/
		
	
///*** EQUATION ***///
	
	*Obs.: should not be done with "pondera"

	reg log_ila_m $lassovars if log_ila_m>0 & log_ila_m!=. & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 // R2ajustado .1433
	// reg log_ila_m `vselectvars' if log_ila_m>0 & log_ila_m!=. & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 // R2ajustado .1436, mejor que Lasso

	set more off
	sort interview__id interview__key quest com
	mi set flong
	*set seed 66778899
	mi register imputed log_ila_m
	mi impute regress log_ila_m `lassovars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, add(2) rseed(66778899) force noi 
	mi unregister log_ila_m
	* Obs.: _mi_m es la variable que crea Stata luego de la imputacion e identifica cada base
		*Ej. si haces 20 imputaciones _mi_m tendra valores de 0 a 20, donde 0 corresponde a la variable sin imputar e 1 a 20 a las bases con un posible valor para los missing values
	
	
///*** REPLACING MISSINGS BY IMPUTED VALUES ***///

	foreach x of varlist ila_m {
	gen `x'2=.
	* Genero var. con valores preliminares de los missing a imputar
	replace `x'2= exp(log_`x') if d`x'_miss3==1 // miss3 junta los 3 tipos de missing
	* Si algun valor imputado es menor que el menor ila_m, reemplazar con el menor ila_m
	sum `x' if `x'>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 & _mi_m==0 // _mi_m==0 es la variable sin imputar
	scalar min_`x'=r(min)
	replace `x'2=min_`x' if (`x'2<min_`x' & d`x'_miss3==1)
	* Imputo reemplazando en variable ila_m en las variables imputadas (varias porque hay cuantas replicas como repeticiones tenga el vselect)
	replace `x'=`x'2 if (d`x'_miss3==1 & _mi_m!=0)
	drop `x'2
	}
	
	mdesc ila_m if _mi_m==0 & (inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.)) 
	mdesc ila_m if _mi_m==1 & (inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.))  // Cheking we do not have "incompleted" values in monetary labor income after imputation
	* Check: Da ok! Se imputaron todos los missing a imputar
	
	gen imp_id=_mi_m // Para que se conserve esta variable luego
	*mi unset // Borramos cosas que se generan de la imputación:
	char _dta[_mi_style] 
	char _dta[_mi_marker] 
	char _dta[_mi_M] 
	char _dta[_mi_N] 
	char _dta[_mi_update] 
	char _dta[_mi_rvars] 
	char _dta[_mi_ivars] 
	drop _mi_id _mi_miss _mi_m

	drop if imp_id==0 // Droppea la variable sin imputar
	collapse (mean) ila_m, by(interview__key interview__id quest com) // da lo mismo usando by(id com)
	
	* Chequear que el número de obs. sea el mismo que en la base original
	
	rename ila_m ila_m_imp1
	save "$forimp\VEN_ila_m_imp1_2019.dta", replace

	
********************************************************************************
*** Analyzing imputed data
********************************************************************************

use "$forimp\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$forimp\VEN_ila_m_imp1_2019.dta" // da lo mismo usando id com

foreach x in ila_m {
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

cd "$pathoutexcel\income_imp"
*** Comparing not imputed vs. imputed monetary labor income distribution
foreach x in ila_m {
twoway (kdensity log_`x' if `x'>0 & ocup_o_rtarecibenilamon==1, lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & ocup_o_rtarecibenilamon==1, lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
graph export "kd_`x'1.png", replace
}
		
foreach x in ila_m {
	tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux1=r(StatTotal)'
	tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux2=r(StatTotal)'
	matrix imp=nullmat(imp)\(aux1,aux2)
}

matrix rownames imp="2019"
matrix list imp

putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("labor_incmon_imp_stochastic_reg") modify
putexcel A3=matrix(imp) //names
matrix drop imp


********************************************************************************
********************************************************************************
*** Imputation model for labor income: using chained equations
********************************************************************************
********************************************************************************

* Hacer?
