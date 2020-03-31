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
                        1: Rent imputation
====================================================================*/

foreach year in /*2015 2016 */ 2017 2018 {
qui {

	di in y `year'
	use "${input}\ENCOVI_imputed_`year'.dta", clear
		
		
	* Identifica a miembros propietarios
	gen aux_prop=(propieta==1 | propieta==2)
	
	* Renta implícita de la vivienda propia 
	gen renta_imp=.
	replace renta_imp=0.10*itot_imputed_sin_ri if aux_prop==1  
	label var renta_imp "renta implicita vivienda"
	cap drop aux_prop
	
	* Ingreso familiar total - total
	egen itot_imputed = rsum(itot_imputed_sin_ri renta_imp), missing
	label var itot_imputed "ingreso total familiar imputado"
	
	* Ingreso percapita familiar total imputado
	gen ipcf_imputed = itot_imputed / nper
	

	save "${input}\ENCOVI_imputed_`year'.dta", replace
	}
}
