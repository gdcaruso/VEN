	* Profile Missing Values 

	* Equations:
		* Ingreso laboral montario - hacerlo por categ. ocup?
		* Ingreso laboral no monetario (no jubilación)
		* Ingreso no laboral
		* Jubilación/Pensión
clear
	* Path Output
	global pathout "C:\Users\wb563583\Github\VEN\data_management\management\4. income imputation\output"

	* Path Input (Base a imputar)
	*global main "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
     global main "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation" //Trini
********************************************************************************
*** Profile of employed with missing values in labor income
********************************************************************************
	use "$main\ENCOVI_forimputation_2019.dta", clear
	
*** Individuals


local varlist1 ila_m jubpen
local varlist2 hombre agegroup estado_civil_sinmis nivel_educ_sinmis categ_ocu_sinmis sector_encuesta_sinmis propieta_hh_sinmis

foreach z in `varlist2' {
tab `z', g(`z')
}

matrix a=J(100,2, .)
local j=1
foreach y in `varlist1' {
local i=1
foreach z in `varlist2' {
tab `z'
local s=r(r)
forv k=1/`s'{
sum `z'`k' /*[w=weight]*/ if d`y'_miss3==1
local i=`i'+ 1
matrix a[`i',`j']=r(mean)*100
}
local i=`i'+1
}
local j=`j'+1
}
matrix colnames a="Labor income" "Pensions"
matrix list a
;
putexcel set "$pathout\VEN_income_imputation_JL.xlsx", sheet("profile_missing_values") modify
putexcel B2=matrix(a), colnames



