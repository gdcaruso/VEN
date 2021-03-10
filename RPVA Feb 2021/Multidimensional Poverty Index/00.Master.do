/*===========================================================================
Country name:	Venezuela
Year:			2021
Survey:			ENCOVI 2019/20

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the different sections of the RPBA Venezuela 
Output:			    Multidimensional Poverty Index


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
				global census "F:\WB\Poverty Map\Fay_Herriot_VEN\dataout"
				global exrate "$rootpath\Additional Data\exchenge_rate_price.dta"
				global exchange "F:\Working with Github\WB\VEN\data_management\management\1. merging\exchange rates"
				global tables "$rootpath\Results\Tables"
				global figures "$rootpath\Results\Figures"
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
***For SPENDING IN SERVICES - convert all values to dolares
********************************************************************************

*Prepare exchange to dollars
local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
local meses 1 2 3 4 5 6 7 8 9 10 11 12 //these are the months in the exchange data (May-2019 to April-2020)
// 11=nov, 12=dic, 1=jan, 2=feb, 3=march, 4=april (these are the months the data was collected)
			
use "$exchange\exchenge_rate_price_with2019T2", clear //Data goes from 05-2019 to 04-2020
			
// For payment of services use this one			
					destring mes, replace
					foreach i of local monedas {
						foreach k of local meses {
							sum mean_moneda	if moneda==`i' & mes==`k'
							local tc`i'mes`k' = r(mean)
							display `tc`i'mes`k''
							}
						}


use "$rawdata\ENCOVI_2019_English labels.dta", clear
						
						

*Generate payment month similar to interview month
*From which year are the payments? 2019? 
*I assume that Jan, Feb, March and April is from 2020 and the rest from 2019 (May to Dec) 
tab pagua_m interview_month 

local watersanitationvars pagua pelect pgas pcarbon pparafina ptelefono


********************************************************************************
*Fix potential currency mismatches

foreach i of local watersanitationvars {
	replace `i'_mon = 1 if `i'_monto>1000 & `i'_mon==2
	replace `i'_mon = 1 if `i'_monto>1000 & `i'_mon==3
	replace `i'_monto=`i'_monto*1000 if `i'_monto<1000 & `i'_mon==1
}



********************************************************************************
*Generate spending variables in BOLIVARES

foreach i of local watersanitationvars {
	gen payment_month_`i' = `i'_m
	gen `i'_monto_bol = `i'_monto
}

*Euros to bolivares
foreach i of local watersanitationvars {
		 	replace `i'_monto_bol = `i'_monto *`tc3mes5' if payment_month_`i'==5 & `i'_mon==3
		 	replace `i'_monto_bol = `i'_monto *`tc3mes6' if payment_month_`i'==6 & `i'_mon==3
		 	replace `i'_monto_bol = `i'_monto *`tc3mes7' if payment_month_`i'==7 & `i'_mon==3
			replace `i'_monto_bol = `i'_monto *`tc3mes8' if payment_month_`i'==8 & `i'_mon==3
		 	replace `i'_monto_bol = `i'_monto *`tc3mes9' if payment_month_`i'==9 & `i'_mon==3
		 	replace `i'_monto_bol = `i'_monto *`tc3mes10' if payment_month_`i'==10 & `i'_mon==3
		 	replace `i'_monto_bol = `i'_monto *`tc3mes11' if payment_month_`i'==11 & `i'_mon==3
			replace `i'_monto_bol = `i'_monto *`tc3mes12' if payment_month_`i'==12 & `i'_mon==3 
			replace `i'_monto_bol = `i'_monto *`tc3mes1' if payment_month_`i'==1 & `i'_mon==3 
			replace `i'_monto_bol = `i'_monto *`tc3mes2' if payment_month_`i'==2 & `i'_mon==3 
			replace `i'_monto_bol = `i'_monto *`tc3mes3' if payment_month_`i'==3 & `i'_mon==3 
			replace `i'_monto_bol = `i'_monto *`tc3mes4' if payment_month_`i'==4 & `i'_mon==3	
}

*Colombianos to bolivares
foreach i of local watersanitationvars {
		 	replace `i'_monto_bol = `i'_monto *`tc4mes5' if payment_month_`i'==5 & `i'_mon==4
		 	replace `i'_monto_bol = `i'_monto *`tc4mes6' if payment_month_`i'==6 & `i'_mon==4
		 	replace `i'_monto_bol = `i'_monto *`tc4mes7' if payment_month_`i'==7 & `i'_mon==4
			replace `i'_monto_bol = `i'_monto *`tc4mes8' if payment_month_`i'==8 & `i'_mon==4
		 	replace `i'_monto_bol = `i'_monto *`tc4mes9' if payment_month_`i'==9 & `i'_mon==4
		 	replace `i'_monto_bol = `i'_monto *`tc4mes10' if payment_month_`i'==10 & `i'_mon==4
		 	replace `i'_monto_bol = `i'_monto *`tc4mes11' if payment_month_`i'==11 & `i'_mon==4
			replace `i'_monto_bol = `i'_monto *`tc4mes12' if payment_month_`i'==12 & `i'_mon==4 
			replace `i'_monto_bol = `i'_monto *`tc4mes1' if payment_month_`i'==1 & `i'_mon==4 
			replace `i'_monto_bol = `i'_monto *`tc4mes2' if payment_month_`i'==2 & `i'_mon==4 
			replace `i'_monto_bol = `i'_monto *`tc4mes3' if payment_month_`i'==3 & `i'_mon==4 
			replace `i'_monto_bol = `i'_monto *`tc4mes4' if payment_month_`i'==4 & `i'_mon==4	
}

*Dollars to bolivares
foreach i of local watersanitationvars {
		 	replace `i'_monto_bol = `i'_monto *`tc2mes5' if payment_month_`i'==5 & `i'_mon==2
		 	replace `i'_monto_bol = `i'_monto *`tc2mes6' if payment_month_`i'==6 & `i'_mon==2
		 	replace `i'_monto_bol = `i'_monto *`tc2mes7' if payment_month_`i'==7 & `i'_mon==2
			replace `i'_monto_bol = `i'_monto *`tc2mes8' if payment_month_`i'==8 & `i'_mon==2
		 	replace `i'_monto_bol = `i'_monto *`tc2mes9' if payment_month_`i'==9 & `i'_mon==2
		 	replace `i'_monto_bol = `i'_monto *`tc2mes10' if payment_month_`i'==10 & `i'_mon==2
		 	replace `i'_monto_bol = `i'_monto *`tc2mes11' if payment_month_`i'==11 & `i'_mon==2
			replace `i'_monto_bol = `i'_monto *`tc2mes12' if payment_month_`i'==12 & `i'_mon==2
			replace `i'_monto_bol = `i'_monto *`tc2mes1' if payment_month_`i'==1 & `i'_mon==2 
			replace `i'_monto_bol = `i'_monto *`tc2mes2' if payment_month_`i'==2 & `i'_mon==2
			replace `i'_monto_bol = `i'_monto *`tc2mes3' if payment_month_`i'==3 & `i'_mon==2 
			replace `i'_monto_bol = `i'_monto *`tc2mes4' if payment_month_`i'==4 & `i'_mon==2	
}



********************************************************************************
*Generate spending variables in DOLLARS


*bolivares to dollars
foreach i of local watersanitationvars {
			gen `i'_monto_dollars = `i'_monto_bol
		 	replace `i'_monto_dollars = `i'_monto_bol /`tc2mes5' if payment_month_`i'==5
		 	replace `i'_monto_dollars = `i'_monto_bol /`tc2mes6' if payment_month_`i'==6
		 	replace `i'_monto_dollars = `i'_monto_bol /`tc2mes7' if payment_month_`i'==7
			replace `i'_monto_dollars = `i'_monto_bol /`tc2mes8' if payment_month_`i'==8
		 	replace `i'_monto_dollars = `i'_monto_bol /`tc2mes9' if payment_month_`i'==9
		 	replace `i'_monto_dollars = `i'_monto_bol /`tc2mes10' if payment_month_`i'==10
		 	replace `i'_monto_dollars = `i'_monto_bol /`tc2mes11' if payment_month_`i'==11
			replace `i'_monto_dollars = `i'_monto_bol /`tc2mes12' if payment_month_`i'==12
			replace `i'_monto_dollars = `i'_monto_bol /`tc2mes1' if payment_month_`i'==1
			replace `i'_monto_dollars = `i'_monto_bol /`tc2mes2' if payment_month_`i'==2
			replace `i'_monto_dollars = `i'_monto_bol /`tc2mes3' if payment_month_`i'==3 
			replace `i'_monto_dollars = `i'_monto_bol /`tc2mes4' if payment_month_`i'==4	
}





********************************************************************************
*Variables needed for all
********************************************************************************

*Create indicator quantiles 
*Quintiles
xtile ipcf_q = ipcf [fw=pondera], nquantiles(5)
label var ipcf_q "Income quintiles per capita household income"

label define quintiles 1 "Poorest quintile" 5 "Richest quintile"
label values ipcf_q quintiles


