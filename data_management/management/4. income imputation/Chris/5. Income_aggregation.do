/*====================================================================
project:    Income aggregation - ENCOVI 2014-2017
Author:        Christian C Gomez C 
----------------------------------------------------------------------
Creation Date:    28 Dic 2018 - 8:20:48
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/
drop _all
clear
global input "Z:\wb509172\Venezuela\ENCOVI\Data\FINAL_DATA_BASES\ENCOVI imputation data"

/*====================================================================
                        1: Aggregates
====================================================================*/

foreach year in /*2015 2016 */ 2017 2018 {
qui {

	di in y `year'
	use "${input}\ENCOVI_imputed_`year'.dta", clear
	
	/*Ingreso individual no laboral imputado*/
	egen inla_imputed = rsum(inla_ocu_imputed o_inla_imputed), missing 
	label var inla_imputed "Ingreso total no laboral individual imputado"
	
	/*Ingreso familiar no laboral imputado*/
	egen inla_tot_imputed = sum(inla_imputed), by(id) 
	label var inla_tot_imputed "Ingreso total no laboral familiar imputado"
	
	/*Ingreso total individual imputado*/
	egen itot_i_imputed = rsum(ila_imputed inla_imputed), missing
	label var itot_i_imputed "Ingreso total individual imputado"
	
	/*Ingreso total familiar imputado*/
	egen itot_imputed_sin_ri = rsum(ila_tot_imputed inla_tot_imputed), missing
	label var itot_imputed_sin_ri "Ingreso tot fam. imputado sin renta imputada"

	save "${input}\ENCOVI_imputed_`year'.dta", replace
	}
}

