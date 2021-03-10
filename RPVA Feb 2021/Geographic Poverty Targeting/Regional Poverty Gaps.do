/*===========================================================================
Country name:	Venezuela
Year:			2021
Survey:			ENCOVI 2019/20

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the Poverty Section of the RPBA Venezuela 
Output:			    Mean income of the extreme poor at the regional level 
					Mean income of the extreme poor at the national level 

=============================================================================*/
********************************************************************************
*Paths

* User 1: Monica 
global monica 0

*User 2: Britta
global britta 1

if $britta {
				global rootpath "F:\WB\ENCOVI"
				global rawdata "$rootpath\ENCOVI Data" 
				global datout "$rootpath\Output\PovertySection"	
				global exrate "$rootpath\Additional Data\exchenge_rate_price.dta"
		}
	    if $monica {
				global rootpath ""
		}


********************************************************************************		
*Install packages/user-written commands
********************************************************************************		

ssc inst _gwtmean
		
********************************************************************************
*Upload data and prepare data 
********************************************************************************
*Remember to run this section all together, if not does not work due to locals 

*a) Exchange Rate
*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
local meses 1 2 3 4 10 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march, 4=april (these are the months the data was collected)
			
use "$exrate", clear
			
// if we consider that incomes are earned one month previous to data collection use this			
					destring mes, replace
					foreach i of local monedas {
						foreach j of local meses {
							if `j' !=12 {
							  local k=`j'+1
							 }
							else {
							  local k=1 // if the month is 12 we send it to month 1
							}
							sum mean_moneda	if moneda==`i' & mes==`j' // if we pick ex rate of month=2
							local tc`i'mes`k' = r(mean)
							display `tc`i'mes`k''
							}
						}

						
*b) ENCOVI Household data 2019/20
**** ENCOVI Database	
use "$rawdata\ENCOVI_2019_English labels.dta", clear


*Convert Bolivares to Dollars: Labor Income, Total Family Income and per capita income

local incomevar ila itf ipcf //these are monthly values 
foreach i of local incomevar {
*Dólares
 	gen `i'_usd = `i' /`tc2mes11' if interview_month==11 
	replace `i'_usd = `i' /`tc2mes12' if interview_month==12 
	replace `i'_usd = `i' /`tc2mes1' if interview_month==1 
	replace `i'_usd = `i' /`tc2mes2' if interview_month==2 
	replace `i'_usd = `i' /`tc2mes3' if interview_month==3 
	replace `i'_usd = `i' /`tc2mes4' if interview_month==4 	
}


*** Label variables
label var ila_usd "Labor Income(dollars)" //monthly
label var itf_usd "Total Family Income(dollars)" //monthly
label var ipcf_usd "IPCF (dollars)" //monthly

***Calculate 2011-PPP-$

*** Labor income, family income and IPCF in Dollar PPP 2011
gen ila_ppp = ila/ ppp11 / ipc*ipc11
gen itf_ppp = itf/ ppp11 / ipc*ipc11
gen ipcf_11 = ipcf/ ppp11 / ipc*ipc11

*** Label variables
label var ila_ppp "Labor Income PPP(dollars)"
label var itf_ppp "Total Family Income PPP(dollars)"
label var ipcf_11 "IPCF PPP (dollars)"


********************************************************************************		
*Create Poverty Indicators
********************************************************************************		

*REMARK: I stay at the monthly level 

********************************************************************************
*Create indicators for extreme and moderate poor 
tab lp_moderada [fw=pondera] //5680446 (this is in Feb-2020-Bolivares) - extreme poverty line
tab lp_extrema [fw=pondera] //2240355 (this is in Feb-2020-Bolivares) - moderate poverty line 

*** Convert poverty lines to 2011-PPP-$	
gen lp_extrema_ppp = lp_extrema / ppp11 / ipc*ipc11 
gen lp_moderada_ppp = lp_moderada / ppp11 / ipc*ipc11
tab lp_extrema_ppp //102 (this is in 2011-PPP-$)
tab lp_moderada_ppp // 260. (this is in 2011-PPP-$)

** Create indicator for extreme poor
gen extreme_poor = .
replace extreme_poor = 0 if ipcf_11 > lp_extrema_ppp
replace extreme_poor = 1 if ipcf_11 < lp_extrema_ppp 
tab extreme_poor [fw=pondera] //79.25 % of all are extremely poor (check); 76.40 % of PAP is extremely poor 

tab extreme_poor [fw=pondera] //79.25 % of all are extremely poor (check); 76.40 % of PAP is extremely poor 


**Create indicator for extreme poor and poor and non-poor
gen poorlevel = .
replace poorlevel = 0 if ipcf_11 > lp_extrema_ppp
replace poorlevel = 1 if ipcf_11 < lp_extrema_ppp 
replace poorlevel = 2 if ipcf_11 > lp_extrema_ppp & ipcf_11 < lp_moderada_ppp
replace poorlevel = 3 if ipcf_11 > lp_moderada_ppp
label define poorlevel 1 "Extreme poor" 2 "Moderate poor" 3 "Non-Poor"
tab poorlevel [fw=pondera]


********************************************************************************		
*Create mean income of extreme poor by region
********************************************************************************		

*Regional mean income of the extreme poor
tab region_est1
bysort region_est1: egen mean_ipcf_region= wtmean(ila_ppp) if extreme_poor==1, weight(pondera) 
tab region_est1 mean_ipcf_region [fw=pondera]
 
*National mean income of extreme poor
egen mean_ipcf_national = wtmean(ila_ppp) if extreme_poor==1, weight(pondera) 
tab mean_ipcf_national [fw=pondera]

















		
