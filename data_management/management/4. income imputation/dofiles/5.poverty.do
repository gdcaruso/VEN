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
*** Poverty rates
********************************************************************************
*** Merging the data with the imputed incomes
use "$pathdata\encovi_2014_2018.dta", clear
capture drop _merge
forv j=1/1{
merge 1:1 year id com using "$pathdata\VEN_linc_imp`j'.dta" //labor income
drop _merge
merge 1:1 year id com using "$pathdata\VEN_pension_imp`j'.dta" //pension
drop _merge
merge 1:1 year id com using "$pathdata\VEN_nlinc_otro_imp`j'.dta" //other non-labor income
drop _merge
}

*** Differents CPIs
** Old IMF
gen cpi_imf = . 
replace cpi_imf = 273.354 if year == 2014		
replace cpi_imf = 578.963 if year == 2015
replace cpi_imf = 2051.844 if year == 2016
replace cpi_imf = 24365.653 if year == 2017
replace cpi_imf = 333833811 if year == 2018
** Updated IMF
gen cpi_imf2 = . 
replace cpi_imf2 = 62.2 if year == 2014		
replace cpi_imf2 = 121.7 if year == 2015
replace cpi_imf2 = 254.9 if year == 2016
replace cpi_imf2 = 438.1 if year == 2017
replace cpi_imf2 = 65374.1 if year == 2018
** CENDAS 
gen cpi_cendas_basket = .  	
replace cpi_cendas_basket = 331.410 if year == 2014	
replace cpi_cendas_basket = 1061.572 if year == 2015
replace cpi_cendas_basket = 6791.048 if year == 2016
replace cpi_cendas_basket = 39678.513 if year == 2017
replace cpi_cendas_basket = 28111464.305 if year == 2018
** CENDAS
gen cpi_cendas_food = .
replace cpi_cendas_food = 410.609 if year == 2014
replace cpi_cendas_food = 1541.792 if year == 2015
replace cpi_cendas_food = 11692.382 if year == 2016
replace cpi_cendas_food = 61292.094 if year == 2017
replace cpi_cendas_food = 35597743.330 if year == 2018

** Bringing the CPI's to 2011 base
foreach y in imf cendas_basket cendas_food{
gen cpi2011_`y'=cpi_`y'/100	
}
*** 
foreach y in imf2{
gen cpi2011_`y'=cpi_`y'/26.1
}
*** PPP extracted from datalibweb			
gen icp2011=2.915005297

*** International poverty lines in USS$ 2011 PPP
gen pl19=1.9*(365/12)
gen pl32=3.2*(365/12)
gen pl55=5.5*(365/12)

*** Value basic basket in Encovi codes (to replicate ENCOVI poverty estimates)
gen canasta=.
replace canasta= 5741.06 if year==2014
replace canasta= 15556 if year==2015
replace canasta= 69540 if year==2016
replace canasta= 686000 if year==2017
replace canasta= 4800 if year==2018

gen lp_extrema=.
gen lp_moderada=.
replace lp_extrema = (canasta / 5.2)  
replace lp_moderada = (2 * canasta) / 5.2  

*** Moderate and extreme poverty lines in US$ 2011 PPP
foreach y in imf imf2 cendas_basket cendas_food{
gen lp_moderada_`y'=lp_moderada/(cpi2011_`y'*icp2011)
gen lp_extrema_`y'=lp_extrema/(cpi2011_`y'*icp2011)
}

*Scenario 0: Official poverty estimates 
*Scenario 1: Official (no imputation, excluding poor househols that have at least one member reporting missing value in labor income, methodology consistent across years, it does not inclued imputed rent 
*Scenario 2: Imputation for labor income using stochastic regression (30 ), no imputation for non-labor income, it does not include imputed rent
*Scenario 3: Imputing labor income, pensions, and other  income (all of them through stochastic regression), it does not include imputed rent 
*Scenario 4: Imputing labor income, pensions, and other  income (all of them through stochastic regression), it also includes imputed rent
*Scenario 5: Imputation for labor income using chained equations (30 ), no imputation for non-labor income, it does not include imputed rent
*Scenario 6: Imputing labor income, pensions, and other  income (all of them through chained equations), it does not include imputed rent 
*Scenario 7: Imputing labor income, pensions, and other  income (all of them through chained equations), it also includes imputed rent
gen dpension2_miss3=(pension2==.) if djubpen==1
gen nodecla1=(dlinc_miss3==1 | dpension2_miss3==1 | dnlinc_otro_miss3==1)
egen nodecla_hh1 = sum(nodecla1==1), by(id) 

clonevar income0=income_off0 //this income replicate the income in Encovi codes (no imputation, double counting of pensions in year 2016, 2017, and 2018)
egen income1= rowtotal (linc pension2 nlinc_otro) //income consistent across years, without imputation (imputing missing values as zeros)
egen income2=rowtotal(linc_imp1 pension2 nlinc_otro) // income when imputing only labor income (through stochastic regression)  
egen income3=rowtotal(linc_imp1 pension_imp1 nlinc_otro_imp1)  // income when imputing labor income, pensions,and other non labor income
egen income4=rowtotal(linc_imp1 pension_imp1 nlinc_otro_imp1)  //+ imputed rent
/*
egen income5=rowtotal(linc_imp2 pension2 nlinc_otro) 
egen income6=rowtotal(linc_imp2 pension_imp2 nlinc_otro_imp2) 
egen income7=rowtotal(linc_imp2 pension_imp2 nlinc_otro_imp2) // + imputed rent
*/
forv i=0/4{
replace income`i'=income`i'*(1000/100000) if year==2018 // ?????? decide what to do with 2018
}

*** Total household income for different scenarios
foreach x in income0 income1 income2 income3 /*income5 income6*/{
bysort year id: egen `x'_hh=sum(`x')
}

foreach i in 3 /*6*/{
gen renta=.
replace renta=0.10*income`i'_hh if propieta==1  
local j=`i'+1
egen income`j'_hh=rowtotal(income`i'_hh renta)
drop renta
}

*** Total per-capita household income in US$ 2011 PPP
foreach x in income0 income1 income2 income3 income4 /*income5 income6 income7*/{
gen `x'_pc=`x'_hh/n_break
foreach y in imf imf2 cendas_basket cendas_food{
gen `x'_ppp_pc_`y'=`x'_pc/(cpi2011_`y'*icp2011)
}
}

*** Poverty estimates for different scenarios and CPIs
tab year
local s=r(r)
foreach y in imf imf2 cendas_basket cendas_food{
forv i=0/4{
gen pov_mod_`i'_`y'=income`i'_ppp_pc_`y'<lp_moderada_`y'
gen pov_ext_`i'_`y'=income`i'_ppp_pc_`y'<lp_extrema_`y'
gen pov55_`i'_`y'=income`i'_ppp_pc_`y'<pl55
gen pov32_`i'_`y'=income`i'_ppp_pc_`y'<pl32
gen pov19_`i'_`y'=income`i'_ppp_pc_`y'<pl19
}

forv i=0/1{
replace pov_mod_`i'_`y'=. if nodecla_hh`i'>0 & pov_mod_`i'_`y'==1
replace pov_ext_`i'_`y'=. if nodecla_hh`i'>0 & pov_ext_`i'_`y'==1
replace pov55_`i'_`y'=. if nodecla_hh`i'>0 & pov55_`i'_`y'==1
replace pov32_`i'_`y'=. if nodecla_hh`i'>0 & pov32_`i'_`y'==1
replace pov19_`i'_`y'=. if nodecla_hh`i'>0 & pov19_`i'_`y'==1
}

*** Exporting result to an excel file
forv i=0/4{
tabstat pov_mod_`i'_`y' pov_ext_`i'_`y' pov55_`i'_`y' pov32_`i'_`y' pov19_`i'_`y' [aw=pondera], by(year) save
forv j=1/`s'{
matrix pov_`i'=nullmat(pov_`i'),r(Stat`j')'*100
}
}

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("poverty_cpi_`y'") modify
putexcel B3=matrix(pov_0)
putexcel B11=matrix(pov_1)
putexcel B19=matrix(pov_2)
putexcel B27=matrix(pov_3)
putexcel B35=matrix(pov_4)
matrix drop _all

}



/*
*** Official
forv i=0/0{
tabstat pov_mod_`i' pov_ext_`i' [aw=pondera], by(year) save
forv j=1/`s'{
matrix pov_`i'=nullmat(pov_`i'),r(Stat`j')'*100
}
}
