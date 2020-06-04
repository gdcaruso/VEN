*******************************************************************************
*** ENCOVI 2019 - Analyzing imputed vs. non-imputed data
********************************************************************************
/*===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña
Dependencies:		The World Bank
Creation Date:		April, 2020
Modification Date:  
Output:			

Note: Income imputation - Identification missing values
=============================================================================*/
********************************************************************************
clear all

// Define rootpath according to user (silenced as this is done by main now)

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
	global pathoutexcel "$datapath\data_management\output\post imputation"


********************************************************************************


use "$forimp\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$forimp\VEN_ila_m_imp1_2019.dta" // da lo mismo usando id com
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$forimp\VEN_jubpen_imp1_2019.dta"
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$forimp\VEN_inlanojub_imp1_2019.dta"
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$forimp\VEN_bene_imp1_2019.dta"


**************
*** ILA_M  ***
**************

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
		tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90 p99) save
		matrix aux1=r(StatTotal)'
		tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90 p99) save
		matrix aux2=r(StatTotal)'
		matrix imp=nullmat(imp)\(aux1,aux2)
	}

	matrix rownames imp="2019"
	matrix list imp

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("labor_incmon_imp_stochastic_reg") modify
	putexcel A3=matrix(imp) //names
	matrix drop imp

	lorenz ila_m if ila_m!=.
	graph export "lorenz_ila_m_sinimp.png", replace

	lorenz ila_m_imp1 if ila_m_imp1!=.
	graph export "lorenz_ila_m_imp.png", replace

****************
*** PENSIONS ***
****************

	foreach x of varlist jubpen {
	gen log_`x'=ln(`x')
	gen log_`x'_imp1=ln(`x'_imp1)
	}

	cd "$pathoutexcel\income_imp"
	
	*** Comparing not imputed versus imputed labor income distribution
	foreach x in jubpen {
	twoway (kdensity log_`x' if `x'>0 & jubi_o_rtarecibejubi==1 , lcolor(blue) bw(0.45)) ///
		   (kdensity log_`x'_imp1 if `x'_imp1>0 & jubi_o_rtarecibejubi==1, lcolor(red) lp(dash) bw(0.45)), ///
			legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
	graph export "kd_`x'1.png", replace
	}

	foreach x in jubpen {
		tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90 p99) save
		matrix aux1=r(StatTotal)'
		tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90 p99) save
		matrix aux2=r(StatTotal)'
		matrix imp=nullmat(imp)\(aux1,aux2)
	}

	matrix rownames imp="2019"
	matrix list imp

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("labor_jubpenimp_stochastic_reg") modify
	putexcel A3=matrix(imp)
	matrix drop imp

	lorenz jubpen if jubpen!=. // obs: ijubi_m is the same as jubpen
	graph export "lorenz_jubpen_sinimp.png", replace

	lorenz jubpen_imp1 if jubpen_imp1!=. // obs: ijubi_m is the same as jubpen
	graph export "lorenz_jubpen_imp.png", replace

***************************
*** INLA (NOT PENSIONS) ***
***************************

	foreach x in inlanojub {
	gen log_`x'=ln(`x')
	gen log_`x'_imp1=ln(`x'_imp1)
	}

	cd "$pathoutexcel\income_imp"
	
	*** Comparing not imputed vs. imputed non-labor income distribution
	foreach x in inlanojub {
	twoway (kdensity log_`x' if `x'>0 & inlist(recibe_ingresonolab,1,2,3), lcolor(blue) bw(0.45)) ///
		   (kdensity log_`x'_imp1 if `x'_imp1>0 & inlist(recibe_ingresonolab,1,2,3), lcolor(red) lp(dash) bw(0.45)), ///
			legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
	graph export "kd_`x'1.png", replace
	}

	foreach x in inlanojub {
		tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90 p99) save
		matrix aux1=r(StatTotal)'
		tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90 p99) save
		matrix aux2=r(StatTotal)'
		matrix imp=nullmat(imp)\(aux1,aux2)
	}

	matrix rownames imp="2019"
	matrix list imp

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("nonlabor_imp_stochastic_reg") modify
	putexcel A3=matrix(imp)
	matrix drop imp
 
	lorenz inlanojub if inlanojub!=.
	graph export "lorenz_inlanojub_sinimp.png", replace

	lorenz inlanojub_imp1 if inlanojub_imp1!=.
	graph export "lorenz_inlanojub_imp.png", replace

**************
*** ILA_NM ***
**************

	foreach x of varlist bene {
	gen log_`x'=ln(`x')
	gen log_`x'_imp1=ln(`x'_imp1)
	}

	cd "$pathoutexcel\income_imp"
	
	*** Comparing not imputed vs. imputed non monetary labor income
	foreach x in bene {
	twoway (kdensity log_`x' if `x'>0 & recibe_ingresolab_nomon==1 , lcolor(blue) bw(0.45)) ///
		   (kdensity log_`x'_imp1 if `x'_imp1>0 & recibe_ingresolab_nomon==1, lcolor(red) lp(dash) bw(0.45)), ///
			legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
	graph export "kd_`x'1.png", replace
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

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("labor_beneimp_stochastic_reg") modify
	putexcel A3=matrix(imp)
	matrix drop imp
	
	lorenz bene if bene!=.
	graph export "lorenz_bene_sinimp.png", replace

	lorenz bene_imp1 if bene_imp1!=.
	graph export "lorenz_bene_imp.png", replace

***************************************
*** IPCF (CON Y SIN RENTA IMPUTADA) ***
***************************************

use "$cleaned\ENCOVI_2019_pre pobreza.dta", clear
keep itf_sin_ri miembros ipcf renta_imp interview__key interview__id quest com 
rename itf_sin_ri itf_sin_ri_imp1
rename ipcf ipcf_imp1

merge 1:1 interview__key interview__id quest com using "$forimp\ENCOVI_forimputation_2019.dta" // da lo mismo usando id com

	*******
	* SIN *
	*******

	gen ipcf_sin_ri = itf_sin_ri / miembros
	gen ipcf_sin_ri_imp1 = itf_sin_ri_imp1 / miembros

	foreach x in ipcf_sin_ri {
	gen log_`x'=ln(`x')
	gen log_`x'_imp1=ln(`x'_imp1)
	}

	cd "$pathoutexcel\income_imp"
	
	*** Comparing not imputed vs. imputed ipcf_sin_ri
	foreach x in ipcf_sin_ri {
	twoway (kdensity log_`x' if `x'>0, lcolor(blue) bw(0.45)) ///
		   (kdensity log_`x'_imp1 if `x'_imp1>0, lcolor(red) lp(dash) bw(0.45)), ///
			legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
	graph export "kd_`x'1.png", replace
	}
			
	foreach x in ipcf_sin_ri {
		tabstat `x' if `x'>0 & `x'!=., stat(mean p10 p25 p50 p75 p90 p99) save // poner !=. solo deja afuera 2 empleadas domésticas que viven en el hogar que trabajan
		matrix aux1=r(StatTotal)'
		tabstat `x'_imp1 if `x'_imp1>0 & `x'_imp1!=., stat(mean p10 p25 p50 p75 p90 p99) save // poner !=. solo deja afuera 2 empleadas domésticas que viven en el hogar que trabajan
		matrix aux2=r(StatTotal)'
		matrix imp=nullmat(imp)\(aux1,aux2)
	}

	matrix rownames imp="2019"
	matrix list imp

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("ipcf_sinri_imp_stochastic_reg") modify
	putexcel A3=matrix(imp) //names
	matrix drop imp

	lorenz ipcf_sin_ri if ipcf_sin_ri!=.
	graph export "lorenz_ipcf_sin_ri_sinimp.png", replace

	lorenz ipcf_sin_ri_imp1 if ipcf_sin_ri_imp1!=.
	graph export "lorenz_ipcf_sin_ri_imp.png", replace

	
	*******
	* CON *
	*******

	foreach x in ipcf {
	gen log_`x'=ln(`x')
	gen log_`x'_imp1=ln(`x'_imp1)
	}

	cd "$pathoutexcel\income_imp"
	
	*** Comparing not imputed vs. imputed ipcf
	foreach x in ipcf {
	twoway (kdensity log_`x' if `x'>0, lcolor(blue) bw(0.45)) ///
		   (kdensity log_`x'_imp1 if `x'_imp1>0, lcolor(red) lp(dash) bw(0.45)), ///
			legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
	graph export "kd_`x'1.png", replace
	}
			
	foreach x in ipcf {
		tabstat `x' if `x'>0 & `x'!=., stat(mean p10 p25 p50 p75 p90 p99) save // poner !=. solo deja afuera 2 empleadas domésticas que viven en el hogar que trabajan
		matrix aux1=r(StatTotal)'
		tabstat `x'_imp1 if `x'_imp1>0 & `x'_imp1!=., stat(mean p10 p25 p50 p75 p90 p99) save // poner !=. solo deja afuera 2 empleadas domésticas que viven en el hogar que trabajan
		matrix aux2=r(StatTotal)'
		matrix imp=nullmat(imp)\(aux1,aux2)
	}

	matrix rownames imp="2019"
	matrix list imp

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("ipcf_imp_stochastic_reg") modify
	putexcel A3=matrix(imp) //names
	matrix drop imp

	lorenz ipcf if ipcf!=.
	graph export "lorenz_ipcf_sinimp.png", replace

	lorenz ipcf_imp1 if ipcf_imp1!=.
	graph export "lorenz_ipcf_imp.png", replace

	
***********************
*** RENTA IMPLICITA ***
***********************

	use "$cleaned\ENCOVI_2019_pre pobreza.dta", clear

	foreach x in renta_imp {
		tabstat `x' if como_imputa_renta==0, stat(mean p10 p25 p50 p75 p90 p99) save 
		matrix aux1=r(StatTotal)'
		tabstat `x' if como_imputa_renta==1, stat(mean p10 p25 p50 p75 p90 p99) save 
		matrix aux2=r(StatTotal)'
		tabstat `x' if como_imputa_renta==2, stat(mean p10 p25 p50 p75 p90 p99) save 
		matrix aux3=r(StatTotal)'
		tabstat `x' if como_imputa_renta==3, stat(mean p10 p25 p50 p75 p90 p99) save 
		matrix aux4=r(StatTotal)'
		matrix imp=nullmat(imp)\(aux1,aux2,aux3,aux4)
	}

	matrix rownames imp="2019"
	matrix list imp

	putexcel set "$pathoutexcel\VEN_income_imputation_2019.xlsx", sheet("imputed_rent") modify
	putexcel A3=matrix(imp) //names
	matrix drop imp

	cd "$pathoutexcel\income_imp"
	
	lorenz renta_imp if renta_imp!=. & como_imputa_renta==1 	
	graph export "lorenz_renta_imp_RTA Y NO OUT.png", replace

	lorenz renta_imp if renta_imp!=. & como_imputa_renta==2 	
	graph export "lorenz_renta_imp_NO RTA, IMPUTAR.png", replace

	lorenz renta_imp if renta_imp!=. & como_imputa_renta==3 	
	graph export "lorenz_renta_imp_RTA PERO OUT, IMPUTAR.png", replace

	lorenz renta_imp if renta_imp!=.	
	graph export "lorenz_renta_imp.png", replace

	tab como_imputa_renta, mi // For missing_values imputed_rent
