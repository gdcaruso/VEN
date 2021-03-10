/*===========================================================================
Country name:		Venezuela
Year:			2021
Survey:			ENCOVI

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the Poverty Section of the RPBA Venezuela 
Output:			    Number of formally employed extremely poor salary worker who earn below poverty-level wage (Program 1)
					Numer of formally employed moderately poor + extremely poor salary worker who earn below poverty-level wage (Program 2)
					Poverty-gap for poverty-level wage for the extreme poor (Program 1)
					Poverty-gap for poverty-level wage for the moderate+extreme poor (Program 2)

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
ssc inst asdoc
		
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
*Restrict to PAP (Potentially active population)
********************************************************************************

*Restrict to potentially active population (PAP)
keep if edad>13 & edad<65		//10,994 observations deleted)
count							//22,092 interviewed people


		
*=========================================================================================
*Construct variables necessary to calculate the number of formally employed salary workers
*=========================================================================================

*Count potentially employed people 
gen numm = _n
summ numm [fweight=pondera] //18,929,128 PAP (Check)

********************************************************************************
*Construct Labor Status Variables
********************************************************************************

*Active Labor Force = Employed + Unemployed
*Employed = Those who work for pay/profit for at least one hour a week, or who have a job but are currently not at work due to illness, leave or industrial action 
*Unemployed = People without work but actively seeking employment, currently available for work


********************************************************************************
*A) Construct active labor force 
*a.1.) Identify working people
tab trabajo_semana [fw=pondera] 
tab trabajo_semana_2 [fw=pondera]	//only those who answered no in trabajo_semana
tab trabajo_independiente [fw=pondera] //only those who answered no in trabajo_semana
		
*a.2.) Identify people not working 
tab razon_no_trabajo [fw=pondera]	//Lack of work, clients or orders

*a.3.) Identify pay/profit
tab sueldo_semana [fw=pondera]

*a.4.) Construct active labor force
gen active_lf = 0
replace active_lf = 1 if trabajo_semana==1 //those who state to work at least one hour
replace active_lf = 1 if trabajo_semana_2<3 //those who indirectly state to work
replace active_lf = 1 if trabajo_independiente==1 & sueldo_semana==1 //self-employed
*replace active_lf = 1 if razon_no_trabajo <6 | razon_no_trabajo==8 | razon_no_trabajo==11 | razon_no_trabajo==12 //have a job but are currently not at work due to illness, leave or industrial action 
replace active_lf=1 if razon_no_trabajo <17
tab active_lf [fw=pondera]



********************************************************************************
*B) Construct unemployed and employed (as percentage of PAP) 
*b.1.) Identify unemployed 
tab busco_trabajo [fw=pondera]
tab empezo_negocio [fw=pondera]	
		
*b.2.) Construct unemployed as percent of PAP
gen unemployed_pap = 0
replace unemployed_pap = 1 if busco_trabajo==1
replace unemployed_pap = 1 if empezo_negocio==1				
tab unemployed_pap [fw=pondera]		//2.3 (check)

*b.3.) Construct employed
gen employed=0
replace employed=1 if active_lf==1 & unemployed_pap==0 
tab employed [fw=pondera]



********************************************************************************
*C) Construct employed salary-worker (public and private sector)
tab categ_ocu [fw=pondera]

gen salaryworker = . 
replace salaryworker = 1 if categ_ocu<4 //public and private employees
replace salaryworker = 1 if categ_ocu==7 //Member of cooperatives
replace salaryworker = 1 if categ_ocu==8 //Paid/unpaid family helper
replace salaryworker = 1 if categ_ocu==9 //Domestic services
replace salaryworker = 0 if categ_ocu==5 //Employer
replace salaryworker = 0 if categ_ocu==6 //Self-employed worker
tab salaryworker [fw=pondera]



********************************************************************************
*D) Construct formal and informal worker

*d.1. Contribution to social security
* Social security: "Seguro social obligatorio, Régimen de prestaciones Vivienda y hábitat, Seguro de paro forzoso, Aporte patronal de la caja de ahorro, Contribuciones al sistema privado de seguros, Otras contribuciones"

*d.1.1. By worker
gen any_worker_disc = .
replace any_worker_disc=0 if (d_sso==0 | d_spf==0 | d_isr==0 | d_cah==0 | d_cpr==0 | d_rpv==0 | d_otro==0) // answered 0 at least once, even if rest missing, and had no 1's
replace any_worker_disc=1 if (d_sso==1 | d_spf==1 | d_isr==1 | d_cah==1 | d_cpr==1 | d_rpv==1 | d_otro==1) // answered 1 at least once
*d.1.2. By employer
gen any_employer_cont = .
replace any_employer_cont=0 if c_sso==0 | c_rpv==0 | c_spf==0 | c_aca==0 | c_sps==0 | c_otro==0 // answered 0 at least once, even if rest missing, and had no 1's
replace any_employer_cont=1 if c_sso==1 | c_rpv==1 | c_spf==1 | c_aca==1 | c_sps==1 | c_otro==1 // answered 1 at least once
*d.1.3. Worker or employer (at least one is 1)
gen formal_ss = .
replace formal_ss = 0 if any_worker_disc==0 | any_employer_cont==0 // contestó a alguna de las dos 0 (incluso si hubo missing) y no tiene 1 en la otra
replace formal_ss = 1 if any_worker_disc==1 | any_employer_cont==1 // al menos un 1

*d.2. Combine with pension fund 

gen formal_ss_pension = .
replace formal_ss_pension = 0 if (formal_ss==0 | aporta_pension==0) & inlist(categ_ocu,1,2,3,4,7,8,9) // contestó a alguna de las dos 0 y no tiene 1 en la otra y es empleado
replace formal_ss_pension = 1 if (formal_ss==1 | aporta_pension==1) & inlist(categ_ocu,1,2,3,4,7,8,9)

tab formal_ss_pension [fw=pondera]



********************************************************************************
*E. Consruct formal salary-worker
gen salaryworker_formal = .
replace salaryworker_formal = 0 if salaryworker==1 & formal_ss_pension==0
replace salaryworker_formal = 1 if salaryworker==1 & formal_ss_pension==1
tab salaryworker_formal [fw=pondera] // 1,850,247 formal salary worker (32.76 percent of all salaryworker)





*========================================================================================
*Calculate number of extreme poor formal salary worker earning below poverty-level wage
*========================================================================================
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
*Show formal salary workers who are extreme poor
gen salaryworker_formal_ep=.
replace salaryworker_formal_ep=1 if extreme_poor==1 & salaryworker_formal==1  
replace salaryworker_formal_ep=0 if extreme_poor==0 & salaryworker_formal==1
tab salaryworker_formal_ep [fw=pondera] //1,214,477 (65.64 percent) of formal salary worker are extremely poor 

*Show formal salary worker who are extreme poor and moderate poor
gen salaryworker_formal_mp=.
replace salaryworker_formal_mp=1 if poorlevel<3 & salaryworker_formal==1  
replace salaryworker_formal_mp=0 if poorlevel==3 & salaryworker_formal==1
tab salaryworker_formal_mp [fw=pondera] //1,744,924 are formal salary worker are extremely or moderately poor 


********************************************************************************
*How many earn below the poverty-level wage? Extreme poverty
*Create indicator
gen povertylevel_wage_ppp = 165
gen lpa_below_plw = .
replace lpa_below_plw = 1 if ila_ppp < povertylevel_wage_ppp
replace lpa_below_plw = 0 if ila_ppp > povertylevel_wage_ppp
tab lpa_below_plw [fweight=pondera]
*Calculate number
tab salaryworker_formal_ep lpa_below_plw [fw=pondera] //1,187,542  are extremely poor formal workers earning less than poverty-level wage

*How many earn below the poverty-level wage? Moderate poverty
*Create indicator
gen povertylevel_wage_ppp2 = 428
gen lpa_below_plw2 = .
replace lpa_below_plw2 = 1 if ila_ppp < povertylevel_wage_ppp2
replace lpa_below_plw2 = 0 if ila_ppp > povertylevel_wage_ppp2
tab lpa_below_plw2 [fweight=pondera]
*Calculate number
tab salaryworker_formal_mp lpa_below_plw2 [fw=pondera] //1,736,909  

*How many earn below the minimum wage? 
gen minimum_wage_ppp = 20.62
gen lpa_below_min = . 
replace lpa_below_min = 1 if ila_ppp < minimum_wage_ppp
replace lpa_below_min = 0 if ila_ppp > minimum_wage_ppp
tab lpa_below_min [fweight=pondera]

tab employed lpa_below_min [fw=pondera],row
tab salaryworker_formal_ep lpa_below_min [fw=pondera],row



********************************************************************************
*Calculate equivalent to poverty gap but for poverty-level wage (extreme poor)
********************************************************************************

*Mean labor income of people below poverty-level wage
egen mean_plwagegap = wtmean(ila_ppp) if salaryworker_formal_ep==1 & lpa_below_plw==1, weight(pondera) 
tab (mean_plwagegap) [fw=pondera] //43.36348  

*Calculate equivalent to poverty gap but for poverty-level wage (moderate poor)
*Mean labor income of people below poverty-level wage
egen mean_plwagegap2 = wtmean(ila_ppp) if salaryworker_formal_mp==1 & lpa_below_plw2==1, weight(pondera) 
tab (mean_plwagegap2) [fw=pondera] //65.68161



********************************************************************************
*Calculate numbers for target group and efficiency analysis
********************************************************************************


tab extreme_poor [fw=pondera] //76.40 % of PAP is extremely poor 
tab active_lf extreme_poor [fw=pondera], row //71.29% in active labor force is extreme poor
tab employed extreme_poor [fw=pondera], row //employed being extremely poor 
tab salaryworker extreme_poor [fw=pondera], row //salary worker (formal and informal) being extremely poor
tab salaryworker_formal extreme_poor [fw=pondera], row //formal worker being extremely poor (1.2 Mio) 
tab salaryworker_formal_ep lpa_below_plw [fw=pondera], row //extreme poor earning below povety-level wage
tab salaryworker_formal lpa_below_plw [fw=pondera], row //formal salary worker earning below poverty-level wage (1.6 Mio) 
tab lpa_below_plw extreme_poor [fw=pondera], row // 		
tab lpa_below_plw poorlevel [fw=pondera] if salaryworker_formal==1 //1.2 Mio are extremely poor, 0.4 are poor, 0.05 are non-poor 		
tab unemployed extreme_poor [fw=pondera], row //0.4 Mio are unemployed, of these are 84.90 % extremely poor. 

		

		
*=========================================================================================
*Show characteristics of people earning below poverty-level wage
*=========================================================================================

*Characterize the ones earning below minimum wage
tab lpa_below_min [fw=pondera]

tabout lpa_below_min [fw=pondera] 


























