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
*** Imputation model for labor income: using stochastic regression (or the Gaussian normal regression imputation method)
********************************************************************************
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
bysort year id: gen hhsize=_N

local demo    jefe /*miembros*/ hhsize edad edad2 /*sexo*/ hombre entidad 
local xvar_en estado_civil_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en seguro_salud_en misiones_en ///
              tipo_vivienda_en propieta_en ///
              /*auto_en*/ heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en tv_cable_en microondas_en ///
              pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en 
local xvar    estado_civil nivel_educ categ_ocu categ_nhorast /*nhorast*/ firm_size contrato seguro_salud misiones ///
              tipo_vivienda propieta /*auto*/ heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas 

*** Identifying missing values in potential independent variables for Mincer equation
mdesc `xvar' if ocupado==1  //few % of missinf values except in nivel_educ, categ_ocu, categ_nhorast, firm size, and contract
/*    Variable    |     Missing          Total     Percent Missing
----------------+-----------------------------------------------
   estado_civil |          27         30,308           0.09
     nivel_educ |       1,443         30,308           4.76
      categ_ocu |         697         30,308           2.30
   categ_nhor~t |       1,238         30,308           4.08
      firm_size |       1,255         30,308           4.14
       contrato |       1,484         30,308           4.90
   seguro_salud |         488         30,308           1.61
       misiones |         181         30,308           0.60
   tipo_vivie~a |           2         30,308           0.01
       propieta |          69         30,308           0.23
       heladera |          63         30,308           0.21
     lavarropas |          79         30,308           0.26
       secadora |         161         30,308           0.53
    computadora |         121         30,308           0.40
       internet |         140         30,308           0.46
      televisor |          89         30,308           0.29
          radio |         120         30,308           0.40
     calentador |         173         30,308           0.57
           aire |         145         30,308           0.48
       tv_cable |         104         30,308           0.34
     microondas |         180         30,308           0.59
----------------+-----------------------------------------------
*/
			  
foreach x in linc {
gen log_`x'=ln(`x')
}

/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

local xvar1 jefe hhsize edad edad2 hombre i.entidad i.estado_civil_en i.tipo_vivienda_en i.propieta_en i.nivel_educ_en ///
           i.seguro_salud_en i.categ_ocu_en i.categ_nhorast_en i.firm_size_en i.contrato_en i.misiones_en ///
		   i.heladera_en i.lavarropas_en i.secadora_en i.computadora_en i.internet_en i.televisor_en i.radio_en i.calentador_en i.aire_en i.tv_cable_en i.microondas_en
		   
reg log_linc `xvar1' if log_linc>0 /*& hogarsec==0*/ & year==2014
scalar sig2_linc1=(e(rmse))^2
reg log_linc `xvar1' nhorast if log_linc>0 & year==2015
scalar sig2_linc2=(e(rmse))^2
reg log_linc `xvar1' nhorast if log_linc>0 & year==2016
scalar sig2_linc3=(e(rmse))^2
reg log_linc `xvar1' if log_linc>0 & year==2017
scalar sig2_linc4=(e(rmse))^2
reg log_linc `xvar1' if log_linc>0 & year==2018
scalar sig2_linc5=(e(rmse))^2

set more off
mi set flong
set seed 66778899
mi register imputed log_linc
mi impute regress log_linc `xvar1' if log_linc>0 & ocupado==1, by(year) add(30) rseed(66778899) force noi 
mi unregister log_linc

*** Retrieving original variables
foreach x of varlist linc {
gen `x'2=.
local j=1
forv i=`ti'/`tf'{
sum `x' if `x'>0 & ocupado==1 & year==`i' &  _mi_m==0
scalar min_`x'`j'=r(min)
*replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if ocupado==1 & year==`i' & d`x'_miss3==1
replace `x'2= exp(log_`x') if ocupado==1 & year==`i' & d`x'_miss3==1  
replace `x'2=min_`x'`j' if (ocupado==1 & year==`i' & `x'2<min_`x'`j' & d`x'_miss3==1)
replace `x'=`x'2 if (ocupado==1 & year==`i' & d`x'_miss3==1 & _mi_m!=0)
local j=`j'+1
}
drop `x'2
}	
mdesc linc if _mi_m==0
mdesc linc if _mi_m==1 //cheking we do not have incompleted values in labor income after the imputation

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
collapse (mean) linc, by(year id com)
rename linc linc_imp1
save "$pathdata\VEN_linc_imp1.dta", replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
capture drop _merge
merge 1:1 year id com using "$pathdata\VEN_linc_imp1.dta"

cd "$pathout\income_imp"
foreach x of varlist linc{
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

sum year 
local ti=r(min)
local tf=r(max)

*** Comparing not imputed versus imputed labor income distribution
foreach x in linc{
forv y=`ti'/`tf'{
twoway (kdensity log_`x' if `x'>0 & ocupado==1 & year==`y' [aw=pondera], lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & ocupado==1 & year==`y' [aw=pondera], lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1_`y', replace) saving(kd_`x'1_`y', replace)
graph export kd_`x'1_`y'.png, replace
}
}
/*
putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("labor_income_imp_stochastic_reg") modify
putexcel A1="Labor income"
putexcel A2=picture("kd_linc_2014.png")
*/

foreach x in linc{
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

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("labor_income_imp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp
;
********************************************************************************
********************************************************************************
*** Imputation model for labor income: using chained equations
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
bysort year id: gen hhsize=_N

local demo    jefe /*miembros*/ hhsize edad edad2 /*sexo*/ hombre entidad 
local xvar    estado_civil nivel_educ categ_ocu categ_nhorast /*nhorast*/ firm_size contrato seguro_salud misiones ///
              tipo_vivienda propieta /*auto*/ heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas 
mdesc `xvar' if ocupado==1

/*  Variable    |     Missing          Total     Percent Missing
----------------+-----------------------------------------------
   estado_civil |          27         30,308           0.09
     nivel_educ |       1,443         30,308           4.76
      categ_ocu |         697         30,308           2.30
   categ_nhor~t |       1,238         30,308           4.08
      firm_size |       1,255         30,308           4.14
       contrato |       1,484         30,308           4.90
   seguro_salud |         488         30,308           1.61
       misiones |         181         30,308           0.60
   tipo_vivie~a |           2         30,308           0.01
       propieta |          69         30,308           0.23
       heladera |          63         30,308           0.21
     lavarropas |          79         30,308           0.26
       secadora |         161         30,308           0.53
    computadora |         121         30,308           0.40
       internet |         140         30,308           0.46
      televisor |          89         30,308           0.29
          radio |         120         30,308           0.40
     calentador |         173         30,308           0.57
           aire |         145         30,308           0.48
       tv_cable |         104         30,308           0.34
     microondas |         180         30,308           0.59
----------------+-----------------------------------------------
*/

			  
sum year 
local ti=r(min)
local tf=r(max)
forv y=`ti'/`tf'{
	local miss_var_`y' ""
	local complete_var_`y' ""
	foreach x in `demo' `xvar' {
	 qui: mdesc `x' if ocupado==1 & year==`y'
	 if "`r(miss)'" != "0" {
		*noi di "There are `r(percent)' % of missing values in variable `ind'"
		local miss_var_`y' "`miss_var_`y'' `x'"
	  }
	 if "`r(miss)'" == "0" {
		local complete_var_`y' "`complete_var_`y'' `x'"
	 }
	}
display "`y'"
display "`complete_var_`y''"
display "`miss_var_`y''"
}
*** 2014
* Completed variables: jefe hhsize edad edad2 hombre entidad tipo_vivienda
* Incompleted variables: estado_civil propieta nivel_educ categ_ocu categ_nhorast firm_size contrato seguro_salud misiones heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas
*** 2015
* Completed variables: jefe hhsize edad hombre entidad 
* Incompleted variables: estado_civil tipo_vivienda propieta nivel_educ categ_ocu categ_nhorast firm_size contrato seguro_salud misiones heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas
*** 2016
* Completed variables: jefe hhsize edad hombre entidad tipo_vivienda 
* Incompleted variables:  estado_civil propieta nivel_educ categ_ocu categ_nhorast firm_size contrato seguro_salud misiones heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas
*** 2017
* Completed variables: jefe hhsize edad hombre entidad tipo_vivienda
* Incompleted variables: estado_civil propieta nivel_educ categ_ocu categ_nhorast firm_size contrato seguro_salud misiones heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas
*** 2018
* Completed variables: jefe hhsize edad hombre entidad tipo_vivienda
* Incompleted variables:  estado_civil propieta nivel_educ categ_ocu categ_nhorast firm_size contrato seguro_salud misiones heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas

foreach x in linc {
gen log_`x'=ln(`x')
}

mi set flong
*mi set M=2
local var_com hombre edad edad2 jefe hhsize i.entidad i.tipo_vivienda_en i.estado_civil_en i.seguro_salud_en i.misiones_en i.propieta_en
local var_imp /*estado_civil*/ nivel_educ categ_ocu categ_nhorast firm_size contrato /* estado_civil seguro_salud misiones propieta*/ ///
               /*heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas*/
mi register imputed log_linc `var_imp' 
mi register regular hombre edad edad2 jefe hhsize entidad tipo_vivienda_en estado_civil_en seguro_salud_en misiones_en propieta_en 
set seed 12345678
  
mi impute chained (regress) log_linc       ///
                  (mlogit)  nivel_educ   /// 
                  (mlogit)  categ_ocu     /// 
				  (mlogit)  categ_nhorast  ///
				  (logit)   contrato       = `var_com' if ocupado==1,    ///				  
                  add(30)  by(year) augment /* burnin(100) savetrace(impstats_linc, replace)*/ force


/*
use `imp`ti'', clear
forv y=`ti'/`tf'{
append using `imp`y''
}
*/
save "$pathdata\VEN_linc_imp2.dta", replace
;
*** Retrieving original variables
foreach x of varlist linc {
gen `x'2=.
local j=1
forv i=`ti'/`tf'{
sum `x' if `x'>0 & ocupado==1 & year==`i' &  _mi_m==0
scalar min_`x'`j'=r(min)
*replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if ocupado==1 & year==`i' & d`x'_miss3==1 
replace `x'2= exp(log_`x') if ocupado==1 & year==`i' & d`x'_miss3==1 
replace `x'2=min_`x'`j' if (ocupado==1 & year==`i' & `x'2<min_`x'`j' & d`x'_miss3==1)
replace `x'=`x'2 if (ocupado==1 & year==`i' & d`x'_miss3==1 & _mi_m!=0)
local j=`j'+1
}
drop `x'2
}	
mdesc linc if _mi_m==0
mdesc linc if _mi_m==1

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
collapse (mean) linc, by(year id com)
rename linc linc_imp2
save "$pathdata\VEN_linc_imp2.dta", replace

********************************************************************************
*** Analyzing imputed data
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
capture drop _merge
merge 1:1 year id com using "$pathdata\VEN_linc_imp2.dta"

cd "$pathout\income_imp"
foreach x of varlist linc{
gen log_`x'=ln(`x')
gen log_`x'_imp2=ln(`x'_imp2)
}

sum year 
local ti=r(min)
local tf=r(max)

foreach x in linc{
forv y=`ti'/`tf'{
twoway (kdensity log_`x' if `x'>0 & ocupado==1 & year==`y' [aw=pondera], lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp2 if `x'_imp2>0 & ocupado==1 & year==`y' [aw=pondera], lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'2_`y', replace) saving(kd_`x'2_`y', replace)
graph export kd_`x'2_`y'.png, replace
}
}
/*
putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("labor_income_imp_stochastic_reg") modify
putexcel A1="Labor income"
putexcel A2=picture("kd_linc_2014.png")
*/

foreach x in linc{
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

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("labor_income_imp_chained_eq") modify
putexcel A3=matrix(imp), names
matrix drop imp


/*
mi impute chained (regress) log_linc       ///
                  (mlogit)  estado_civil   ///
                  (mlogit)  nivel_educ     /// 
				  (mlogit)  categ_ocu      ///
				  (mlogit)  categ_nhorast  /// 
				  (mlogit)  firm_size      /// 
				  (logit)   contrato       /// 
 				  (logit)   seguro_salud   /// 
				  (logit)   misiones       /// 
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
				  (logit) microondas = `var_com' if ocupado==1 & year==2014,    ///				  
                  add(30) by(year) burnin(100) augment /*savetrace(impstats_linc, replace)*/ force


/*			  
forv y=2014/2018{
mi impute chained (regress if log_linc>0 & ocupado==1 & year==`y',                       include (`var_imp' `var_com')            noimputed) log_linc       ///
                  (mlogit  if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) estado_civil   ///
                  (mlogit  if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) nivel_educ     /// 
				  (mlogit  if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) categ_ocu      ///
				  (mlogit  if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) categ_nhorast  /// 
				  (mlogit  if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) firm_size      /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) contrato       /// 
 				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) seguro_salud   /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) misiones       /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) propieta       ///
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) heladera       ///
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) lavarropas     /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) secadora       /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) computadora    /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) internet       /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) televisor      /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) radio          ///  
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) calentador     /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) aire           /// 
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) tv_cable       ///
				  (logit   if log_linc>0 & ocupado==1 & year==`y',                       include (log_linc `var_imp' `var_com')   noimputed) microondas,    ///				  
                  /*add(30)*/ replace burnin(100) /*savetrace(impstats_linc, replace)*/ force
tempfile imp`y'
save `imp`y''
restore
}


