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
Output:			    Additional analysis for the Poverty Section 


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

*Convert poverty lines to 2011-PPP-$	
gen lp_extrema_ppp = lp_extrema / ppp11 / ipc*ipc11 
gen lp_moderada_ppp = lp_moderada / ppp11 / ipc*ipc11
tab lp_extrema_ppp //102 (this is in 2011-PPP-$)
tab lp_moderada_ppp // 260. (this is in 2011-PPP-$)

*Create indicator for extreme poor
gen extreme_poor = .
replace extreme_poor = 0 if ipcf_11 > lp_extrema_ppp
replace extreme_poor = 1 if ipcf_11 < lp_extrema_ppp 
tab extreme_poor [fw=pondera] //79.25 % of all are extremely poor (check); 76.40 % of PAP is extremely poor 

tab extreme_poor [fw=pondera] //79.25 % of all are extremely poor (check); 76.40 % of PAP is extremely poor 


*Create indicator for extreme poor and poor and non-poor
gen poorlevel = .
replace poorlevel = 0 if ipcf_11 > lp_extrema_ppp
replace poorlevel = 1 if ipcf_11 < lp_extrema_ppp 
replace poorlevel = 2 if ipcf_11 > lp_extrema_ppp & ipcf_11 < lp_moderada_ppp
replace poorlevel = 3 if ipcf_11 > lp_moderada_ppp
label define poorlevel 1 "Extreme poor" 2 "Moderate poor" 3 "Non-Poor"
tab poorlevel [fw=pondera]


*Create indicator quantiles 
*Quintiles
xtile ipcf_q = ipcf [fw=pondera], nquantiles(5)
label var ipcf_q "Income quintiles per capita household income"



********************************************************************************		
*Create Labor Market Indicators 
********************************************************************************		

gen active_lf = .
replace active_lf = 0 if trabajo_semana==0 & edad>13 & edad<65
replace active_lf = 0 if trabajo_independiente==0 & edad>13 & edad<65
replace active_lf = 0 if trabajo_independiente==1 & sueldo_semana==0 & edad>13 & edad<65 //self-employed, but no income
replace active_lf = 1 if trabajo_semana==1 & edad>13 & edad<65 //those who state to work at least one hour
replace active_lf = 1 if trabajo_semana_2<3 & edad>13 & edad<65 //those who indirectly state to work
replace active_lf = 1 if trabajo_independiente==1 & sueldo_semana==1 & edad>13 & edad<65 //self-employed
replace active_lf = 1 if busco_trabajo==1 & edad>13 & edad<65
replace active_lf = 1 if empezo_negocio==1 & edad>13 & edad<65
*replace active_lf = 1 if razon_no_trabajo <6 | razon_no_trabajo==8 | razon_no_trabajo==11 | razon_no_trabajo==12 //have a job but are currently not at work due to illness, leave or industrial action 
replace active_lf=1 if razon_no_trabajo <17 & edad>13 & edad<65
tab active_lf [fw=pondera]


********************************************************************************
*D) Generate informality indicator
********************************************************************************


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



*================================================================================
*Analysis
*================================================================================



********************************************************************************		
*Poverty by demographic groups
********************************************************************************		

*Age groups
tab extreme_poor [fw=pondera] if edad<5 //90.36 
tab extreme_poor [fw=pondera] if edad>=65 //72.2

*Female versus male-led households
tab extreme_poor [fw=pondera_hh] if relacion_en==1 & hombre==0 //79.7
tab extreme_poor [fw=pondera_hh] if relacion_en==1 & hombre==1 //72.2

*Active versus inactive population
tab extreme_poor active_lf [fw=pondera], column //

*Emigration
tab extreme_poor hogar_emig [fw=pondera_hh], column

*Formal versus informal
tab extreme_poor formal_ss_pension [fw=pondera], column


********************************************************************************		
*Informality by gender
********************************************************************************		

tab formal_ss_pension hombre [fw=pondera], column


********************************************************************************		
*Housing conditions by income quintile
********************************************************************************		

*Questions are asked to household head so use household weight
tab material_pared_exterior [fw=pondera_hh] if ipcf_q==1 //5.88  - other (precarious)
tab material_pared_exterior [fw=pondera_hh] if ipcf_q==5 //0.93  - other (precarious)


********************************************************************************		
*Industry by income quintile
********************************************************************************		

*First, look at sample sizes (without weights)
tab ipcf_q sector_encuesta

tabout ipcf_q sector_encuesta [fw=pondera] using "$datout/sectors.xls", ///
append cells(freq col row) format(1) clab(Freq Col_% Row_%) percent layout(cb) show(all) font(bold) replace






