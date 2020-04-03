/*===========================================================================
Country name:	Venezuela
Year:			2014-2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Trinidad Saavedra

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
		}
	    if $lauta {

		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
                global rootpath2 "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela"
		}
		
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global rootpath2 ""
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global pathdata "$rootpath2\Income Imputation\data"
global pathout "$rootpath2\Income Imputation\output"
global pathdo "$rootpath2\Income Imputation\dofiles"

qui: do "$pathdo\outliers.do"

********************************************************************************
********************************************************************************
*** Imputation model for pensions: using stochastic regression (or the Gaussian normal regression imputation method)
********************************************************************************
********************************************************************************

use "$pathdata\encovi_2014_2018.dta", clear
bysort year id: gen hhsize=_N
drop if year==2014 | year==2015  //2014 not available and 2015 not enough obs to run a regression model
local demo    jefe /*miembros*/ hhsize edad edad2 /*sexo*/ hombre entidad 
local xvar_en estado_civil_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en seguro_salud_en misiones_en ///
              tipo_vivienda_en propieta_en ///
              /*auto_en*/ heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en tv_cable_en microondas_en ///
              pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en 
local xvar    estado_civil nivel_educ /*categ_ocu categ_nhorast nhorast firm_size contrato*/ seguro_salud misiones ///
              tipo_vivienda propieta /*auto*/ heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas ///
			  /*pension_vejez pension_inva pension_otra pension_sobrev contribu_pen*/ 

sum year 
local ti=r(min)
local tf=r(max)

foreach x in nlinc_otro {
gen log_`x'=ln(`x')
}

local xvar1 jefe hhsize edad edad2 hombre i.entidad i.estado_civil_en i.tipo_vivienda i.propieta_en ///
            i.nivel_educ_en ocupado i.seguro_salud_en i.misiones_en ///
		    i.heladera_en i.lavarropas_en i.secadora_en i.computadora_en i.internet_en i.televisor_en i.radio_en i.calentador_en i.aire_en i.tv_cable_en i.microondas_en ///
 
		   
*reg log_nlinc_otro `xvar1' if nlinc_otro>0 /*& hogarsec==0*/ & year==2014
*scalar sig2_nlinc_otro1=(e(rmse))^2
*reg log_nlinc_otro `xvar1' if nlinc_otro>0 & year==2015
*scalar sig2_nlinc_otro2=(e(rmse))^2
reg log_nlinc_otro `xvar1' if nlinc_otro>0 & year==2016
scalar sig2_nlinc_otro3=(e(rmse))^2
reg log_nlinc_otro `xvar1' if nlinc_otro>0 & year==2017
scalar sig2_nlinc_otro4=(e(rmse))^2
reg log_nlinc_otro `xvar1' if nlinc_otro>0 & year==2018
scalar sig2_nlinc_otro5=(e(rmse))^2

set more off
mi set flong
set seed 66778899
mi register imputed log_nlinc_otro
mi impute regress log_nlinc_otro `xvar1' if dnlinc_otro==1, by(year) add(30) rseed(66778899) force noi 
mi unregister log_nlinc_otro

*** Retrieving original variables
foreach x of varlist nlinc_otro {
gen `x'2=.
local j=1
forv i=`ti'/`tf'{
sum `x' if `x'>0 & d`x'==1 & year==`i' &  _mi_m==0
scalar min_`x'`j'=r(min)
*replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if d`x'==1 & year==`i' & d`x'_miss3==1
replace `x'2= exp(log_`x') if d`x'==1 & year==`i' & d`x'_miss3==1  
replace `x'2=min_`x'`j' if (d`x'==1 & year==`i' & `x'2<min_`x'`j' & d`x'_miss3==1) // if imputed value is smaller than non-imputed variable minimun value, I keep non-imputed variable minimun value 
replace `x'=`x'2 if (d`x'==1 & year==`i' & d`x'_miss3==1 & _mi_m!=0)
local j=`j'+1
}
drop `x'2
}	
mdesc nlinc_otro if dnlinc_otro==1 & _mi_m==0
mdesc nlinc_otro if dnlinc_otro==1 & _mi_m==1

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
collapse (mean) nlinc_otro, by(year id com)
rename nlinc_otro nlinc_otro_imp1
save "$pathdata\VEN_nlinc_otro_imp1.dta", replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
merge 1:1 year id com using "$pathdata\VEN_nlinc_otro_imp1.dta"
drop if year==2014 | year==2015
cd "$pathout\income_imp"
foreach x of varlist nlinc_otro{
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

sum year 
local ti=r(min)
local tf=r(max)

foreach x in nlinc_otro{
forv y=`ti'/`tf'{
twoway (kdensity log_`x' if `x'>0 & d`x'==1 & year==`y' [aw=pondera], lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & d`x'==1 & year==`y' [aw=pondera], lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1_`y', replace) saving(kd_`x'1_`y', replace)
graph export kd_`x'1_`y'.png, replace
}
}

foreach x in nlinc_otro{
forv y=`ti'/`tf'{
tabstat `x' if `x'>0 & year==`y', stat(mean p10 p25 p50 p75 p90) save
matrix aux1=r(StatTotal)'
tabstat `x'_imp1 if `x'_imp1>0 & year==`y', stat(mean p10 p25 p50 p75 p90) save
matrix aux2=r(StatTotal)'
matrix imp=nullmat(imp)\(aux1,aux2)
}
}
levelsof year, local(year)
matrix rownames imp=`year'
matrix list imp

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("othernonlinc_imp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp
;
********************************************************************************
********************************************************************************
*** Labor income imputation model: using chained equations
********************************************************************************
********************************************************************************
*mi unset
char _dta[_mi_style] 
char _dta[_mi_marker] 
char _dta[_mi_M] 
char _dta[_mi_N] 
char _dta[_mi_update] 
char _dta[_mi_rvars] 
char _dta[_mi_ivars] 

use "$pathdata\encovi_2014_2018.dta", clear
drop if year==2014 | year==2015
bysort year id: gen hhsize=_N

local demo    jefe /*miembros*/ hhsize edad edad2 /*sexo*/ hombre entidad 
local xvar    estado_civil nivel_educ /*categ_ocu categ_nhorast nhorast firm_size contrato*/ seguro_salud misiones ///
              tipo_vivienda propieta /*auto*/ heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas
			  /*pension_vejez pension_inva pension_otra pension_sobrev contribu_pen */ 

mdesc `xvar' if dnlinc_otro==1

foreach x in nlinc_otro {
gen log_`x'=ln(`x')
}

mi set flong
*mi set M=2
local var_com hombre edad edad2 jefe hhsize i.entidad i.tipo_vivienda_en i.estado_civil i.propieta_en i.misiones ///
              i.heladera i.lavarropas i.secadora i.computadora i.internet i.televisor i.radio i.calentador i.aire i.tv_cable i.microondas
local var_imp /*estado_civil*/ nivel_educ seguro_salud /* misiones propieta ///
              heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas*/
			  
mi register imputed log_nlinc_otro `var_imp' 
mi register regular hombre edad edad2 jefe hhsize tipo_vivienda_en estado_civil propieta misiones heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas
set seed 12345678
  
mi impute chained (regress) log_nlinc_otro  ///
                  (mlogit)  nivel_educ      /// 
 				  (logit)   seguro_salud   /* /// 					  
				  (logit)   misiones       /// 
                  (mlogit)  estado_civil   ///				  
				  (logit)   propieta       ///
				  (logit)   heladera       ///
				  (logit)   lavarropas     /// 
				  (logit)   secadora       /// 
				  (logit)   computadora    /// 
				  (logit)   internet       /// 
				  (logit)   televisor      /// 
				  (logit)   radio          ///  
				  (logit)   calentador     /// 
				  (logit)   aire           /// 
				  (logit)   tv_cable       ///
				  (logit)   microondas*/ = `var_com' if ocupado==1,    ///				  
                  add(30) by(year) burnin(50) augment /*savetrace(impstats_linc, replace)*/ force
/*
use `imp`ti'', clear
forv y=`ti'/`tf'{
append using `imp`y''
}
*/
save "$pathdata\VEN_nlinc_otro_imp2.dta", replace

*** Retrieving original variables
foreach x of varlist nlinc_otro {
gen `x'2=.
local j=1
forv i=`ti'/`tf'{
sum `x' if `x'>0 & d`x'==1 & year==`i' &  _mi_m==0
scalar min_`x'`j'=r(min)
*replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if d`x'==1 & year==`i' & d`x'_miss3==1 
replace `x'2= exp(log_`x') if d`x'==1 & year==`i' & d`x'_miss3==1 
replace `x'2=min_`x'`j' if (d`x'==1 & year==`i' & `x'2<min_`x'`j' & d`x'_miss3==1)
replace `x'=`x'2 if (d`x'==1 & year==`i' & d`x'_miss3==1 & _mi_m!=0)
local j=`j'+1
}
drop `x'2
}	
mdesc nlinc_otro if dnlinc_otro==1 & _mi_m==0
mdesc nlinc_otro if dnlinc_otro==1 & _mi_m==1

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
collapse (mean) nlinc_otro, by(year id com)
rename nlinc_otro nlinc_otro_imp2
save "$pathdata\VEN_nlinc_otro_imp2.dta", replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
capture drop _merge
merge 1:1 year id com using "$pathdata\VEN_nlinc_otro_imp2.dta"

cd "$pathout\income_imp"
foreach x of varlist nlinc_otro{
gen log_`x'=ln(`x')
gen log_`x'_imp2=ln(`x'_imp2)
}

sum year 
local ti=r(min)
local tf=r(max)

foreach x in nlinc_otro{
forv y=`ti'/`tf'{
twoway (kdensity log_`x' if `x'>0 & d`x'==1 & year==`y' [aw=pondera], lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp2 if `x'_imp2>0 & d`x'==1 & year==`y' [aw=pondera], lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'2_`y', replace) saving(kd_`x'2_`y', replace)
graph export kd_`x'2_`y'.png, replace
}
}

foreach x in nlinc_otro{
forv y=`ti'/`tf'{
tabstat `x' if `x'>0 & year==`y', stat(mean p10 p25 p50 p75 p90) save
matrix aux1=r(StatTotal)'
tabstat `x'_imp2 if `x'_imp2>0 & year==`y', stat(mean p10 p25 p50 p75 p90) save
matrix aux2=r(StatTotal)'
matrix imp=nullmat(imp)\(aux1,aux2)
}
}
levelsof year, local(year)
matrix rownames imp=`year'
matrix list imp

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("othernlinc_imp_chained_eq") modify
putexcel A3=matrix(imp), names
matrix drop imp
