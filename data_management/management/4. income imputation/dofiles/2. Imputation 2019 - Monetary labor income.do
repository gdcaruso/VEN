****************************************************************
*** ENCOVI 2019 - IMPUTATION MONETARY LABOR INCOME 
****************************************************************
 
///*** OPEN DATABASE & PATHS ***///

global pathout "C:\Users\wb550905\Github\VEN\data_management\management\4. income imputation\output"

use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation\ENCOVI_forimputation_2019.dta", clear

///*** VARIABLES FOR MINCER EQUATION ***///

	local xvar	edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh /*anio_auto_hh*/ heladera_hh lavarropas_hh	computadora_hh internet_hh televisor_hh calentador_hh aire_hh tv_cable_hh microondas_hh  ///
				/*seguro_salud*/ afiliado_segsalud_comp ///
				nivel_educ ///
				tarea sector_encuesta categ_ocu total_hrtr ///
				c_sso c_rpv c_spf c_aca c_sps c_otro ///
				cuenta_corr cuenta_aho tcredito tdebito no_banco ///
				aporte_pension clap ingsuf_comida comida_trueque

* Identifying missing values in potential independent variables for Mincer equation
	*Note: "mdesc" displays the number and proportion of missing values for each variable in varlist.
	mdesc `xvar' if (inlist(recibe_ingresolab_mon,1,2,3) | ocupado==1 ) // Universo: los que reportaron recibir (caso 1.a) o ocupados (caso 2)
		// few % of missinf values except nivel_educ
		// c_* will only be useful if we see divided by categ_ocup as they are only defined for workers who are not independent workers or employers
		
	/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
	values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
	the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

	local xvar1 edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil_sinmis region_est1 entidad municipio 	///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh_sinmis /*anio_auto_hh_sinmis*/ heladera_hh_sinmis lavarropas_hh_sinmis computadora_hh_sinmis internet_hh_sinmis televisor_hh_sinmis calentador_hh_sinmis aire_hh_sinmis tv_cable_hh_sinmis microondas_hh_sinmis ///
				/*seguro_salud*/ afiliado_segsalud_comp ///
				nivel_educ_sinmis asiste_o_dejoypq_sinmis ///
				tarea_sinmis sector_encuesta_sinmis categ_ocu_sinmis total_hrtr_sinmis ///
				/* c_sso_sinmis c_rpv_sinmis c_spf_sinmis c_aca_sinmis c_sps_sinmis c_otro_sinmis */ ///
				cuenta_corr_sinmis cuenta_aho_sinmis tcredito_sinmis tdebito_sinmis no_banco_sinmis ///
				aporte_pension_sinmis clap_sinmis ingsuf_comida_sinmis comida_trueque_sinmis
	
	* Dependent variable
	gen log_ila_m = log(ila_m) if ila_m!=.
	

///*** CHECKING WHICH VARIABLES MAXIMIZE R2 ***///
	
	* LASSO
	/* 	LASSO is one of the first and still most widely used techniques employed in machine learning. 
	For this specification, you may want to use the command lassoregress. 
	You will first need to install the package elasticregress, using the command line ssc install elasticregress. 
	For the purposes of this exercise, please use as argument for the Lasso command set seed 1 and the default number of folds to be 10. */
	
		*set seed 1
		*lassoregress log_ila_m `xvar1' if log_ila_m>0 & ocup_o_rtarecibenilamon==1, numfolds(5)
		
	* Stepwise (pr usa chris; trini usa backward)
		
		* ??
	
	* Vselect
		
		*Problema: no se puede poner variable como factor variables 
		* R2 como criterio
		* me guarda las variables como una lista
		* return - rpret list
		vselect log_ila_m `xvar1' if log_ila_m>0 & ocup_o_rtarecibenilamon==1, backward r2adj
		display r(predlist)
		local vselectvars = r(predlist)
	
	* Nuestra idea
		*local nuestrasvars edad edad2 hombre relacion_comp npers_viv estado_civil entidad tipo_vivienda_hh propieta_hh microondas_hh nivel_educ afiliado_segsalud_comp no_banco_sinmis
	
///*** EQUATION ***///
	
	*Obs: should not be done with "pondera"
	
	reg log_ila_m `xvar1' if log_ila_m>0
	reg log_ila_m `vselectvars' if log_ila_m>0
	*reg log_ila_m `nuestrasvars' if log_ila_m>0 // Da peor
	
stop
	set more off
	mi set flong
	set seed 66778899
	mi register imputed log_ila_m
	mi impute regress log_ila_m `xvar1' if log_ila_m>0 & ocup_o_rtarecibenilamon==1, add(1) rseed(66778899) force noi 
	mi unregister log_ila_m

	clonevar dila_m_zero = dlinc_zero 
	clonevar dila_m_miss1 = dlinc_miss1
	clonevar dila_m_miss2 = dlinc_miss2
	clonevar dila_m_miss3 = dlinc_miss3
	
* Retrieving original variables
	foreach x of varlist ila_m {
	gen `x'2=.
	local j=1
	sum `x' if `x'>0 & ocup_o_rtarecibenilamon==1 &  _mi_m==0
	scalar min_`x'`j'=r(min)
	*replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if ocup_o_rtarecibenilamon==1 & d`x'_miss3==1
	replace `x'2= exp(log_`x') if ocup_o_rtarecibenilamon==1 & d`x'_miss3==1  
	replace `x'2=min_`x'`j' if (ocup_o_rtarecibenilamon==1 & `x'2<min_`x'`j' & d`x'_miss3==1)
	replace `x'=`x'2 if (ocup_o_rtarecibenilamon==1 & d`x'_miss3==1 & _mi_m!=0)
	local j=`j'+1
	drop `x'2
	}	
	mdesc ila_m if _mi_m==0
	mdesc ila_m if _mi_m==1 //cheking we do not have incompleted values in labor income after the imputation

	gen imp_id=_mi_m
	*mi unset
	char _dta[_mi_style] 
	char _dta[_mi_marker] 
	char _dta[_mi_M] 
	char _dta[_mi_N] 
	char _dta[_mi_update] 
	char _dta[_mi_rvars] 
	char _dta[_mi_ivars] 
	drop _mi_id _mi_miss _mi_m	

	drop if imp_id==0
	collapse (mean) ila_m, by(id com)
	rename ila_m ila_m_imp1
	save "$pathdata\VEN_ila_m_imp1.dta" //, replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$pathdata\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
merge 1:1 interview__key interview__id quest using "$pathdata\VEN_ila_m_imp1.dta"

d "$pathout\income_imp"
foreach x of varlist ila_m {
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

*** Comparing not imputed versus imputed labor income distribution
foreach x in ila_m {
twoway (kdensity log_`x' if `x'>0 & ocup_o_rtarecibenilamon==1 , lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & ocup_o_rtarecibenilamon==1, lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1_`y', replace) saving(kd_`x'1_`y', replace)
graph export kd_`x'1.png, replace
}

foreach x in ila_m {
	forv y=`ti'/`tf'{
	tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux1=r(StatTotal)'
	tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux2=r(StatTotal)'
	matrix imp=nullmat(imp)\(aux1,aux2)
}
}
matrix rownames imp="2019"
matrix list imp

putexcel set "$pathout\VEN_income_imputation_2019_MA.xlsx", sheet("labor_incmon_imp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp


