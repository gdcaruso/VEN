 ****************************************************************
*** ENCOVI 2019 - IMPUTATION MONETARY LABOR INCOME 
****************************************************************
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
program drop _all
clear all
set mem 300m
clear matrix
clear mata
capture log close
set matsize 11000
set more off
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
				global pathoutexcel "C:\Users\wb563583\Github\VEN\data_management\management\4. income imputation\output"}
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
				global pathoutexcel "C:\Users\wb550905\Github\VEN\data_management\management\4. income imputation\output"

		}

qui: do "$pathdo\outliers.do" 

///*** OPEN DATABASE & PATHS ***///

use "$path\ENCOVI_forimputation_2019.dta", clear

*** agregar esta parte en el do donde se identifican los missing values
clonevar ila_m_out=ila_m
outliers ila_m 10 90 5 5 //44 outliers obs
sum	ila_m_out if	out_ila_m==1 //
gen dila_m_out=out_ila_m==1 if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.) 
*gen dila_m_miss3=(dila_m_miss1==1 | dila_m_miss2==1 | dila_m_out==1) if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.)  //esta linea se debe agregar en el do de identificacion en vez de la siguiente linea
replace dila_m_miss3=1 if dila_m_out==1 & inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.) //adding outliers to variable identifying all the missing values 
mdesc ila_m if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.)  //now there are 3963 missing values instead of 3919
tab dila_m_miss3 if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.) 
note: fine!

* Cuántos queremos imputar
mdesc ila_m if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.) 
	// if me decís que recibiste pero ila monteario missing Ó estás ocupado, no decís que no recibís ila_m (eso sería un verdadero missing) y no contestás un monto de ila no mon.
	* Check: da ok! Igual que la cantidad de miss3
	
///*** VARIABLES FOR MINCER EQUATION ***///

	global xvar	edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh /*anio_auto_hh*/ heladera_hh lavarropas_hh	computadora_hh internet_hh televisor_hh calentador_hh aire_hh tv_cable_hh microondas_hh  ///
				/*seguro_salud*/ afiliado_segsalud_comp ///
				nivel_educ ///
				tarea sector_encuesta categ_ocu total_hrtr ///
				c_sso c_rpv c_spf c_aca c_sps c_otro ///
				cuenta_corr cuenta_aho tcredito tdebito no_banco ///
				aporte_pension clap ingsuf_comida comida_trueque

* Identifying missing values in potential independent variables for Mincer equation
	*Note: "mdesc" displays the number and proportion of missing values for each variable in varlist.
	mdesc $xvar if ocup_o_rtarecibenilamon==1 // Universo: los que reportaron recibir (caso 1.a) o ocupados (caso 2)
		// few % of missinf values except nivel_educ
		// c_* will only be useful if we see divided by categ_ocup as they are only defined for workers who are not independent workers or employers
		
	/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
	values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
	the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

	global xvar1 edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil_sinmis region_est1 entidad municipio 	///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh_sinmis /*anio_auto_hh_sinmis*/ heladera_hh_sinmis lavarropas_hh_sinmis computadora_hh_sinmis internet_hh_sinmis televisor_hh_sinmis calentador_hh_sinmis aire_hh_sinmis tv_cable_hh_sinmis microondas_hh_sinmis ///
				/*seguro_salud*/ afiliado_segsalud_comp ///
				nivel_educ_sinmis ///
				tarea_sinmis sector_encuesta_sinmis categ_ocu_sinmis total_hrtr_sinmis ///
				/* c_sso_sinmis c_rpv_sinmis c_spf_sinmis c_aca_sinmis c_sps_sinmis c_otro_sinmis */ ///
				cuenta_corr_sinmis cuenta_aho_sinmis tcredito_sinmis tdebito_sinmis no_banco_sinmis ///
				aporte_pension_sinmis clap_sinmis ingsuf_comida_sinmis comida_trueque_sinmis
	
	* Nuestra idea para laboral monetario
		*local nuestrasvars edad edad2 hombre relacion_comp npers_viv estado_civil entidad tipo_vivienda_hh propieta_hh microondas_hh nivel_educ afiliado_segsalud_comp no_banco_sinmis
	
	* Dependent variable
	gen log_ila_m = ln(ila_m) if ila_m!=.
	

///*** CHECKING WHICH VARIABLES MAXIMIZE R2 ***///
	
	** LASSO
		/* 	LASSO is one of the first and still most widely used techniques employed in machine learning. 
		For this specification, you may want to use the command lassoregress. 
		You will first need to install the package elasticregress, using the command line ssc install elasticregress. 
		For the purposes of this exercise, please use as argument for the Lasso command set seed 1 and the default number of folds to be 10. */
		
		*set seed 1
		
		lassoregress log_ila_m $xvar1 if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, numfolds(5)
		display e(varlist_nonzero)
		local lassovars = e(varlist_nonzero)
		
	** Stepwise (pr usa Chris; Trini usa backward)
		* ??
	
	** Vselect
		* Se puede usar R2adjustado como criterio. Ojo, no se puede poner variable como factor variables 
		* return - rpret list
	
	vselect log_ila_m $xvar1 if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, best
	
	* Best one appears to be with 28 vars.
	/*
	local vselectvars categ_ocu_sinmis clap_sinmis comida_trueque_sinmis sector_encuesta_sinmis auto_hh_sinmis ///
					hombre total_hrtr_sinmis ingsuf_comida_sinmis tdebito_sinmis relacion_comp region_est1 ///
					tv_cable_hh_sinmis entidad tarea_sinmis lavarropas_hh_sinmis tcredito_sinmis material_piso_hh ///
					propieta_hh nivel_educ_sinmis cuenta_aho_sinmis municipio heladera_hh_sinmis televisor_hh_sinmis ///
					aporte_pension_sinmis tipo_sanitario_comp_hh computadora_hh_sinmis cuenta_corr_sinmis edad
	*/				
		local vselectvars i.categ_ocu_sinmis i.clap_sinmis i.comida_trueque_sinmis i.sector_encuesta_sinmis i.auto_hh_sinmis ///
					i.hombre /*total_hrtr_sinmis*/ i.ingsuf_comida_sinmis i.tdebito_sinmis i.relacion_comp i.region_est1 ///
					i.tv_cable_hh_sinmis i.entidad i.tarea_sinmis i.lavarropas_hh_sinmis i.tcredito_sinmis i.material_piso_hh ///
					i.propieta_hh i.nivel_educ_sinmis i.cuenta_aho_sinmis i.municipio i.heladera_hh_sinmis i.televisor_hh_sinmis ///
					i.aporte_pension_sinmis i.tipo_sanitario_comp_hh i.computadora_hh_sinmis i.cuenta_corr_sinmis edad
	
	/*	vselect log_ila_m `nuestrasvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1, backward r2adj
		display r(predlist)
		local vselectvars2 = r(predlist)	*/
		
	
///*** EQUATION ***///
	
	*Obs.: should not be done with "pondera"
	
	*reg log_ila_m `xvar1' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0  // Da peor
	*reg log_ila_m `nuestrasvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0  // Da peor
	
	*reg log_ila_m `lassovars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 // R2ajustado .1433
	reg log_ila_m `vselectvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 // R2ajustado .1436, mejor que Lasso

	set more off
	mi set flong
	set seed 66778899
	mi register imputed log_ila_m
	mi impute regress log_ila_m `vselectvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, add(1) rseed(66778899) force noi 
	mi unregister log_ila_m
	* Obs.: _mi_m es la variable que crea Stata luego de la imputacion e identifica cada base
		*Ej. si haces 20 imputaciones _mi_m tendra valores de 0 a 20, donde 0 corresponde a la variable sin imputar e 1 a 20 a las bases con un posible valor para los missing values
	
///*** REPLACING MISSINGS BY IMPUTED VALUES ***///

	foreach x of varlist ila_m {
	gen `x'2=.
	* Genero var. con valores preliminares de los missing a imputar
	replace `x'2= exp(log_`x') if d`x'_miss3==1 // miss3 junta los 2 tipos de missing
	* Si algun valor imputado es menor que el menor ila_m, reemplazar con el menor ila_m
	sum `x' if `x'>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 & _mi_m==0 // _mi_m==0 es la variable sin imputar
	scalar min_`x'`j'=r(min)
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
	tempfile VEN_ila_m_imp1
	save `VEN_ila_m_imp1', replace
	*save "$pathout\VEN_ila_m_imp1.dta", replace

	
********************************************************************************
*** Analyzing imputed data
********************************************************************************

use "$path\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
*merge 1:1 interview__key interview__id quest com using "$path\VEN_ila_m_imp1.dta" // da lo mismo usando id com
merge 1:1 interview__key interview__id quest com using `VEN_ila_m_imp1' // da lo mismo usando id com

outliers ila_m 20 80 5 5 //aggregar en do identificaton missing values

foreach x of varlist ila_m {
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

*cd "$pathoutexcel\income_imp"
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
;
putexcel set "$pathoutexcel\VEN_income_imputation_2019_MA.xlsx", sheet("labor_incmon_imp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp


********************************************************************************
********************************************************************************
*** Imputation model for labor income: using chained equations
********************************************************************************
********************************************************************************

* Hacer?
