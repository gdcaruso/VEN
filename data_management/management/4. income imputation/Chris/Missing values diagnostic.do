/*====================================================================
project:      Missing values in ENCOVI diagnostic
Author:        Christian C Gomez C 
----------------------------------------------------------------------
Creation Date:    20 Nov 2018 - 8:20:48
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/

clear
global input "Z:\wb509172\Venezuela\ENCOVI\Data\FINAL_DATA_BASES\ENCOVI harmonized data"
global output "Z:\wb509172\Venezuela\ENCOVI\Projects\Income Imputation and WB poverty estimates\excel"

/*====================================================================
                     1: Translate datasets
====================================================================*/

tempfile pfile
tempname pname
postfile `pname' str30(year indicator value) using `pfile', replace

forvalues y = 2014/2016 {
	di in y "Imputation for year `y'"
	qui {
	use "${input}\ENCOVI_harmonized_`y'.dta", clear 
	describe
	noi di "Nuber of observations `r(N)'"
	gen pt=1
	noi tab recibe_ila ocu
	
	sum ocu [w=pondera] 
	local ocupados = `r(sum)'
	post `pname' ("`y'") ("Total Ocupados") ("`ocupados'")
	
	sum pt [w=pondera_hog] if parentesco==1
	local hogares = `r(sum)'
	post `pname' ("`y'") ("Total Hogares") ("`hogares'")
	
	sum ocu [w=pondera] if recibe_ila==2
	local ocu_tsr = (`r(sum)' / `ocupados') * 100
	post `pname' ("`y'") ("Sh ocupados sin remunera") ("`ocu_tsr'")
	
	sum ocu [w=pondera] if (recibe_ila==1 | recibe_ila==99) & ila==.
	local ocu_sin_ila = (`r(sum)' / `ocupados') * 100  
	post `pname' ("`y'") ("Sh ocupados remunera sin ila") ("`ocu_sin_ila'")
	
	sum ocu [w=pondera] if (inla_ocu>=1 & inla_ocu!=.) 
	local ocu_con_ocu_ila = (`r(sum)' / `ocupados') * 100  
	post `pname' ("`y'") ("Sh ocupados con inla") ("`ocu_con_ocu_ila'")
	
	sum pt [w=pondera_hog] if (inla_tot>=1 & inla_tot!=.) & parentesco==1
	local hog_con_inla = (`r(sum)' / `hogares') * 100  
	post `pname' ("`y'") ("Sh hogares con inla") ("`hog_con_inla'")

	sum pt [w=pondera_hog] if (inla_ocu_tot>=1 & inla_ocu_tot!=.) & parentesco==1
	local hog_con_ocu_inla = (`r(sum)' / `hogares') * 100  
	post `pname' ("`y'") ("Sh hogares con ocu inla") ("`hog_con_ocu_inla'")
	
	
	sum pt [w=pondera_hog] if (ipcf==0) & parentesco==1
	local hog_sin_inc = (`r(sum)' / `hogares') * 100  
	post `pname' ("`y'") ("Sh hogares sin ingresos") ("`hog_sin_inc'")
	
	
	local incomes ila_tot inla_ocu_tot in_IVSS_tot in_emp_publ_tot in_emp_priv_tot in_otros_tot o_inla_tot
		sum i_tot [w=pondera_hog] if parentesco==1
		local tot = `r(sum)'
		foreach i of local incomes {
		sum `i' [w=pondera_hog] if parentesco==1
		local inc = (`r(sum)' / `tot') * 100
		post `pname' ("`y'") ("Sh in: `i' en el total") ("`inc'")
		}
		
	}
}

postclose `pname'
use `pfile', clear
destring year indicator value , replace
	
export excel using "${output}/Missing_values_diagnosticv2.xlsx", firstrow(variables) sheet(Raw) sheetreplace



