/*===========================================================================
Country name:	Venezuela
Year:			2021
Survey:			ENCOVI 2014 - ENCOVI 2019/20

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the different sections of the RPBA Venezuela 
Output:			    Growth Incidence Curve  


=============================================================================*/
********************************************************************************
*Paths

* User 1: Monica 
global monica 0

*User 2: Britta
global britta 1

if $britta {
				global rootpath "F:\WB\ENCOVI"
				global rawdata "$rootpath\ENCOVI Data\ENCOVI SEDLAC" 
				global exrate "$rootpath\Additional Data\exchenge_rate_price.dta"
				global exchange "F:\Working with Github\WB\VEN\data_management\management\1. merging\exchange rates"
				global figures "F:\Working with Github\WB\VEN\RPVA Feb 2021\Growth Incidence Curve\Output\Graphs"
		}
	    if $monica {
				global rootpath ""
		}
		

ssc install povcalnet //https://worldbank.github.io/povcalnet/vis.html - Only until 2004 for Venezuela, have to do it by hand 

********************************************************************************
*Upload data

use "$rawdata\VEN_2014_ENCOVI_SEDLAC-01_English labels.dta", clear
destring id, replace
append using "$rawdata\VEN_2015_ENCOVI_SEDLAC-01_English labels.dta"
append using "$rawdata\VEN_2016_ENCOVI_SEDLAC-01_English labels.dta"
append using "$rawdata\VEN_2017_ENCOVI_SEDLAC-01_English labels.dta"
append using "$rawdata\VEN_2018_ENCOVI_SEDLAC-01_English labels.dta"
tostring id, replace
tostring psu, replace
append using "$rawdata\VEN_2019_ENCOVI_SEDLAC-01_English labels.dta"


********************************************************************************
*Prepare variables 

*Create year
tab ano
gen year=ano

*Show income per capita by year
bysort year: sum ipcf_ppp11
		
*Create indicator deciles 
*Quintiles
forval year=2014/2019{
xtile decile`year' = ipcf_ppp11 if year==`year' [fw=pondera], nquantiles(10)
}

gen decile = decile2014
forval year=2015/2019{
replace decile = decile`year' if year==`year'
}
label var decile "Income decile per capita household income"
tab decile
tab decile year

label define decile 1 "Poorest decile" 10 "Richest decile"
label values decile decile

*Calculate mean income per decile 
collapse (mean) ipcf_ppp11 [fw=pondera], by(decile year)
label var ipcf_ppp11 "Mean per capita income (in 2011-PPP-US$) per decile"

		
********************************************************************************
*Growth Incidence Curve 

keep year decile ipcf_ppp11 
keep if year==2014 | year==2019 //Only keep the once for growth rate 
drop if missing(decile)

reshape wide ipcf_ppp11, i(decile) j(year)

g growth = ((ipcf_ppp112019 - ipcf_ppp112014)/ipcf_ppp112014)*100

set scheme s1mono
twoway (scatter growth decile, c(l)), yti("Annual growth in decile average p.c. income (%)" " ", size(small)) ///
xlabel(0(1)10,labs(small)) xtitle("Decile group", size(small)) graphregion(c(white)) ///
scheme(s1mono)
graph export "$figures/GrowthIncidenceCurve.png"
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	
		
		

