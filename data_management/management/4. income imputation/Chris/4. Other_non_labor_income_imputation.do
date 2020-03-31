/*====================================================================
project:     Labor Income imputation - ENCOVI 2014-2017
Author:        Christian C Gomez C 
----------------------------------------------------------------------
Creation Date:    30 Nov 2018 - 8:20:48
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/
drop _all
clear
cd "Z:\wb509172\Venezuela\ENCOVI\Projects\Income Imputation and WB poverty estimates\excel"
global output "Z:\wb509172\Venezuela\ENCOVI\Data\FINAL_DATA_BASES\ENCOVI imputation data"
global input "Z:\wb509172\Venezuela\ENCOVI\Data\FINAL_DATA_BASES\ENCOVI harmonized data"


di in g " 3 --- > Other non Labor income imputation "
foreach year in /*2015 2016 */ 2017 2018 {
qui {
	clear
	drop _all
	cap erase miest_nl`year'.ster
	di in y `year'
	use "${input}\ENCOVI_harmonized_`year'.dta", clear
	/* Variables temporales */
	*tempvar active inactive edad2 hombre emp_grande emp_mediana

	/* Relacion de dependencia*/
	gen active = inrange(edad,15,54)
	gen inactive = inrange(edad,0,14) | inrange(edad,55,100)
	ereplace active = sum(active), by(id)
	ereplace inactive = sum(inactive), by(id)
	gen rela_depen = inactive/active

	/*edad cuadrado*/
	gen edad2 = edad^2 
	tab edad2
	/*hombre*/
	gen hombre = (sexo==1)
	
	/*jefe*/
	gen jefe = (parentesco==1)

	/*vive en pareja*/
	gen viv_par = inrange(civil,1,4) if edad>=12

	/* Log Ingreso no laboral (pensiones)*/
	gen log_o_inla = log(o_inla)
	
	
	/* Dummies de municipio*/
	local municipio ""
	cap drop mun_*
	levelsof entidad, local (municipio)
	local municipio = ustrregexrf("`municipio'", "1", "")
	di in y "`municipio'"
	foreach m of local municipio {
		gen mun_`m' = (entidad==`m')
		}

	/* Dummies de sector de actividad*/
	destring rama, replace
	recode rama (98 99 = .)
	levelsof rama, local (rama)
	local rama = ustrregexrf("`rama'", "20", "")

	foreach r of local rama {
		gen rama_`r' = (rama==`r')
		}
		
	
	/* Dummies de nivel educativo */
	recode nivel (98 99 = .)
	levelsof nivel, local (nivel)
	local nivel = ustrregexrf("`nivel'", "6", "")
	foreach n of local nivel {
		gen nivel_`n' = (nivel==`n')
		}
	
	/* missing reports */
	* Labor income
	mdesc o_inla if edad>=40 & (recibe_inla==1)
	noi di "There are `r(percent)' of employed pop. with labor income not reporting the value"
	noi di "Number of missing values: `r(miss)'"
	
/*===========================================================================
					2: Variable identification
============================================================================*/

	/* Variable idendification */
		
	local independent "edad edad2 aedu hombre jefe viv_par mun_* nivel_*"
		
	/*Missing data patterns*/
	
	misstable patterns `independent', frequency
	
	/* Explanatory variables with missing data */
	local miss_var ""
	foreach ind of varlist `independent' {
	 qui mdesc `ind' if edad>=40 & (recibe_inla==1)
	 if "`r(miss)'" != "0" {
		noi di "There are `r(percent)' % of missing values in variable `ind'"
		local miss_var "`miss_var' `ind'"
	  }
	 local complete_var ""
	 if "`r(miss)'" == "0" {
		local complete_var "`complete_var' `ind'"
	  }
	 
	}
}

	di "Missing data Variables for target population -- > `miss_var'"
	di "Complete vriables for target population -- >`complete_var'"

	

/*===========================================================================
	2: Multiple iputation (Draw many guesses at the missing values)
	- Max likelihood estimation for labor income
============================================================================*/

*Use the Bayes posterior predictive distribution of the missing values based, Allows accounting for variation due to not being observed,
*Estimate the model on each of the imputed datasets, Pool the estimates using rules which account for variation from each dataset (within)
* and variation from the imputation (between)
* Note on Multivariate Normal Imputation (This is the method which is commonly used if there is no pattern to the missing values) 
* It assumes a multivariate normal distribution for the imputed variables.

/* Set the data set for mi */
mi set mlong

/* Register variables imputed (want to impute) */
mi register imputed `miss_var' 
di in y "`miss_var'"
tempvar pt
gen `pt' = 1
tab `pt' [w=pondera] if recibe_inla==1 & o_inla>0 & o_inla!=. 
tab `pt' if recibe_inla==1 & o_inla>0 & o_inla!=. 

/* Register regular variables. One can regsitrate passive vars (variables derived from imputed variables) */
mi register regular `complete_var'

/* Set the number of imputations */
mi set M=20

/* Imputation of explanatory variables */
mi impute mvn `miss_var' = `complete_var' if edad>=40 & recibe_inla==1 , replace rseed(3593) 
*mi impute monotone (pmm) weight (logit) foreign (ologit) rep78 = lp100km trunk length turn displacement gear_ratio, > add(20) rseed(3443)


// Stata imputed 20 different datasets, It treated the above variables (all of them) as being jointly multivariate normal, It then used the Monte Carlo Markov Chain (MCMC) data augementation methods to pick values from the posterior predictive distribution for the multivariate normal
* https://www.stata.com/meeting/italy10/rising_sug.pdf

*mi convert wide, clear
mi describe
mi estimate, saving(miest_nl`year'): regress log_o_inla `miss_var' `complete_var' [w=pondera] if recibe_inla==1 & o_inla>0 & o_inla!=. 


// Stata estimated the model for all 20 imputed datasets, the results were then combine. The results are weighted according to how much variation there is between imputations vs. how much variation there is according to the linear model,  check:
mi estimate, vartable nocitable

* Predict labor income
mi predict xb_mi using miest_nl`year'


/*===========================================================================
	          3: Clean data set (After MI)
============================================================================*/

keep if _mi_m == 0
cap erase miest_nl`year'.ster

* Transform labor income and generate imputed income after affect data
replace xb_mi = exp(xb_mi)
gen o_inla_imputed = o_inla
replace o_inla_imputed = xb_mi if edad>=40 & (recibe_inla==1) & (o_inla==. | o_inla==0)
egen o_inla_tot_imputed = sum(o_inla_imputed), by(id)
label var o_inla_imputed "Ingreso no laboral imputado - Tot. individual"
label var o_inla_tot_imputed "Ingreso no laboral imputado - Tot. familiar"
drop xb_mi _mi_* rama_* mun_* nivel_* log_o_inla rela_depen


/*==================================================================
						  4: Labels
====================================================================*/

label var viv_par 		"Dummy de vive en pareja"
label var edad  		"Edad"
cap drop edad2 

/*==================================================================
				5: Merge with labor income imputed
====================================================================*/
tempfile non_lab
save `non_lab', replace
*stop
use "${output}\ENCOVI_imputed_`year'.dta", clear
*use "${output}\ENCOVI_imputed_`year'.dta", clear
merge 1:1 ano id miembro using `non_lab', keepusing (o_inla_imputed o_inla_tot_imputed)
sort ano id miembro
order ano id miembro
drop _merge
save "${output}\ENCOVI_imputed_`year'.dta", replace
}






