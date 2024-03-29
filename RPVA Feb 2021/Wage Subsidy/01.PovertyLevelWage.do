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
Output:			    Description of population earning below the extreme poverty-level wage 

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
				global tables "$rootpath\Results\Tables\Poverty Level Wage"
		}
	    if $monica {
				global rootpath ""
		}


********************************************************************************		
*Install packages/user-written commands
********************************************************************************		
clear all 
ssc inst _gwtmean
set maxvar 12000
		
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

local incomevar ila inla renta_imp itf ipcf //these are monthly values 
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
gen inla_ppp = inla/ ppp11 /ipc*ipc11
gen renta_imp_ppp = renta_imp/ ppp11 /ipc*ipc11
gen itf_ppp = itf/ ppp11 / ipc*ipc11
gen ipcf_11 = ipcf/ ppp11 / ipc*ipc11

*** Label variables
label var ila_ppp "Labor Income PPP(dollars)"
label var inla_ppp "Non-Labor Income PPP(dollars"
label var renta_imp_ppp "Imputed rent PPP(dollars"
label var itf_ppp "Total Family Income PPP(dollars)"
label var ipcf_11 "IPCF PPP (dollars)"


*=========================================================================================
*Generate additional variables of interest
*=========================================================================================

********************************************************************************
*Dummy for people earning below the poverty-level wage
gen targetgroup = (ila_ppp<165) if !missing(ila_ppp)
tab targetgroup [fw=pondera] if edad>13 & edad<65

label var targetgroup "Below poverty-level earners"

gen targetgroup2 = (ila_ppp<165 & ila_ppp>20.62) if !missing(ila_ppp)
tab targetgroup2 [fw=pondera] if edad>13 & edad<65

label var targetgroup2 "Below poverty-level and above min. wage earners"

gen targetgroup3 = (ila_ppp<20.62) if !missing(ila_ppp)
tab targetgroup3 [fw=pondera]  if edad>13 & edad<65

gen targetgroup4 = (ila_ppp>20.6 & ila_ppp<55) if !missing(ila_ppp)
tab targetgroup4 [fw=pondera] if edad>13 & edad<65

********************************************************************************
*Generate informality indicator


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

tab formal_ss_pension [fw=pondera] if edad>13 & edad<65

label var formal_ss_pension "Formal worker"


********************************************************************************
*Education Level 

***Educational levels (dummies)
g low_educated = (nivel_educ<4) if !missing(nivel_educ)
g middle_educated = (nivel_educ==4 | nivel_educ==5) if !missing(nivel_educ)
g high_educated = (nivel_educ>5) if !missing(nivel_educ)

label var low_educated "Low-educated"
label var middle_educated "Middle-educated"
label var high_educated "High-educated"

g educ_level = .
replace educ_level = 1 if nivel_educ<4
replace educ_level = 2 if nivel_educ>3 & nivel_educ<6
replace educ_level = 3 if nivel_educ>5 
tab educ_level [fw=pondera]

********************************************************************************
*Skill Level 

**Define skilled occupations: 
recode tarea (1 2 3 =3 ) (4/8 10 =2) (9=1) , gen(skill_level)
lab def skill_level 3 "High skilled" 2 "Skilled" 1 "Unskilled", replace
lab val skill_level skill_level
tab skill_level

//Skilled if have skilled occupation and/or post-secondary education
gen high_skilled = (nivel_educ>5 | skill_level==3) if !missing(skill_level, nivel_educ)
tab high_skilled [fw=pondera]
label var high_skilled "High-Skilled"

gen rest_skilled = (high_skilled==0) if !missing(high_skilled)
tab rest_skilled [fw=pondera]
label var rest_skilled "Low/Middle-Skilled"


********************************************************************************
*Salary-workers

gen salaryworker = . 
replace salaryworker = 1 if categ_ocu<4 //public and private employees
replace salaryworker = 1 if categ_ocu==7 //Member of cooperatives
replace salaryworker = 1 if categ_ocu==8 //Paid/unpaid family helper
replace salaryworker = 1 if categ_ocu==9 //Domestic services
replace salaryworker = 0 if categ_ocu==5 //Employer
replace salaryworker = 0 if categ_ocu==6 //Self-employed worker
tab salaryworker [fw=pondera]

label var salaryworker "Salary worker"


********************************************************************************
*Self employed

gen self_employed = (categ_ocu==6 | categ_ocu==5) if !missing(categ_ocu)
label var self_employed "Self-employed/Employer"

********************************************************************************
*Public employees

gen public_employee = (categ_ocu==1) if !missing(categ_ocu)
label var public_employee "Public Employee"


********************************************************************************
*Part-time workers
gen part_time = (hstr_todos<40) if !missing(hstr_todos)
label var part_time "Part-time worker"


********************************************************************************
*Change label of sector_encuesta

label define industry 1 "Agriculture/ livestock/ fishing/ huntin" 2 "Mining and quarrying" 3 "Manufacturing industry" 4 ///
"Installation / supply / distribution of" 5 "Construction" 6 "Wholesale and retail trade/ repair of motor vehicles and motorcycles" ///
7 "Transportation/ storage/ lodging/ food services/communication/computer services" ///
8 "Financial and insurance/ real estate/ professional scientific technical services/admin" ///
9 "Public administration and defense/ education/ health/social assistance/ art entertainment" ///
10 "Other service activities such as repair cleaning hairdressing domestic services funeral"
label val sector_encuesta industry



********************************************************************************
*Identify households with unique breadwinner

egen numemployed = total(ocupado), by(id)
gen breadwinner = (numemployed==1) if ocupado==1
label var breadwinner "Unique Breadwinner"




********************************************************************************
*Groups of interest
********************************************************************************

tab pobre_extremo [fw=pondera]
tab targetgroup [fw=pondera]
tab targetgroup if categ_ocu!=5 & categ_ocu!=6 [fw=pondera]
tab targetgroup if categ_ocu!=5 & categ_ocu!=6 & formal_ss_pension==1 [fw=pondera]

tab desocu [fw=pondera] if pobre_extremo==1
tab ocupado [fw=pondera] if pobre_extremo==1


********************************************************************************
*Restrict to PAP (Potentially active population)
********************************************************************************

*Restrict to potentially active population (PAP)
keep if edad>13 & edad<65		//10,994 observations deleted)
count							//22,092 interviewed people


tab targetgroup if categ_ocu==5 | categ_ocu==6 [fw=pondera]
********************************************************************************
*Count potentially employed people 

gen numm = _n
summ numm [fweight=pondera] //18,929,128 PAP (Check)


/*==============================================================================
Description of potentiall affected workers 
==============================================================================*/

*Who are they?
local varlist edad hombre low_educated middle_educated high_educated high_skilled salaryworker self_employed public_employee part_time pobre ///
pobre_extremo breadwinner formal_ss_pension
*asdoc sum `varlist' [fw=pondera] if targetgroup2==1, replace nocf dec(2) stat(mean sd p50) fhc(\b) label ///
*save($tables\summarystat.doc) title(Descriptive statistic of below poverty-level wage earners)

estpost sum `varlist' [fw=pondera] if targetgroup2==1
esttab using "$tables\summarystat.csv", cells((mean(fmt(%9.4f) label(Mean)))) ///
label nonumber noobs ///
title(Descriptive statistics of the potentially affected population) replace 



*Percentage of affected group in different categories 
local varlist gedad1 hombre low_educated middle_educated high_educated high_skilled rest_skilled salaryworker self_employed public_employee ///
part_time pobre pobre_extremo breadwinner formal_ss_pension
foreach x in `varlist'{
estpost tab `x' targetgroup2 [fw=pondera_hh], label
esttab using "$tables/`x'_targetgroup2.csv", cells("rowpct") collabels("Row-Percent") label unstack ///
varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Above and below poverty-level earner `x' - National (ENCOVI 2019/20)) replace
}



********************************************************************************
*Potential Target Groups

***How many people are targeted
tab targetgroup2 [fw=pondera] if pobre_extremo==1
tab targetgroup2 [fw=pondera] if pobre_extremo==1 & ocupado==1
tab targetgroup2 [fw=pondera] if pobre==1 & ocupado==1

*Wage earners below the extreme poverty-level wage
tab targetgroup [fw=pondera] if edad>13 & edad<65

*Workers below the extreme poverty-level wage
tab targetgroup [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6

*Workers below the extreme poverty-level wage (formal)
tab targetgroup [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6 & formal_ss_pension==1

*Self-employed and employer below the extreme poverty-level wage 
tab targetgroup [fw=pondera] if edad>13 & edad<65 & (categ_ocu==5 | categ_ocu==6)

*Workers between poverty-level wage and current min wage 
tab targetgroup2 [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6

*Wage-earners below current min wage 
tab targetgroup3 [fw=pondera] if edad>35 & edad<65

*Workers below current min wage
tab targetgroup3 [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6

*Extremely poor unemployed
tab desocu [fw=pondera] if pobre_extremo==1

*Extremely poor inactive
tab ocupado [fw=pondera] if pobre_extremo==1

*Public employees
tab targetgroup2 [fw=pondera] if public_employee==1 & edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6

*Public employees below gradual minimum wage
tab public_employee [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6 & ila_ppp<27.56
tab public_employee [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6 & ila_ppp<41.34

*Public employees below scenario 4 
tab public_employee [fw=pondera] if edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6 & ila_ppp<55


********************************************************************************
*Current average/median wage

***All, also part-time
sum ila_ppp [fw=pondera] if edad>13 & edad<65, d

***All worker 
sum ila_ppp [fw=pondera] if edad>13 & edad<65 & part_time==0, d

***Young worker 
sum ila_ppp [fw=pondera] if edad>14 & edad<36 & part_time==0, d

***Older worker 
sum ila_ppp [fw=pondera] if edad>35 & edad<65 & part_time==0, d

***Wage of potentially affected groups
sum ila_ppp [fw=pondera] if targetgroup2==1 & edad>13 & edad<65 & categ_ocu!=5 & categ_ocu!=6, d
bysort hombre: sum ila_ppp if targetgroup2==1 [fw=pondera]
bysort educ_level: sum ila_ppp if targetgroup2==1 [fw=pondera]
bysort breadwinner: sum ila_ppp if targetgroup2==1 [fw=pondera]
bysort sector_encuesta: sum ila_ppp if targetgroup2==1 [fw=pondera]
bysort categ_ocu: sum ila_ppp if targetgroup2==1 [fw=pondera]

***Wage of public employees potentially affected
sum ila_ppp if public_employee==1 & targetgroup2==1 [fw=pondera]
sum ila_ppp if public_employee==1 & targetgroup4==1 [fw=pondera]


***Wage of PAP under 33 percent poverty-level wage
sum ila_ppp [fw=pondera] if edad>35 & edad<65 & ila_ppp>20.6 & ila_ppp<55, d


********************************************************************************
*Poverty

tab pobre targetgroup [fw=pondera], column

tab pobre targetgroup2 [fw=pondera], column

tab pobre_extremo targetgroup [fw=pondera], column

tab pobre_extremo targetgroup2 [fw=pondera], column

tab targetgroup4 pobre_extremo [fw=pondera], column

tab targetgroup4 pobre_extremo [fw=pondera] if categ_ocu!=5 & categ_ocu!=6, column

tab pobre_extremo targetgroup4 [fw=pondera] if categ_ocu!=5 & categ_ocu!=6, column

tab pobre targetgroup4 [fw=pondera] if categ_ocu!=5 & categ_ocu!=6, column

********************************************************************************
*Informality

tab formal_ss_pension [fw=pondera] if edad>13 & edad<65

***Young worker 
tab formal_ss_pension [fw=pondera] if edad>14 & edad<36

***Old worker
tab formal_ss_pension [fw=pondera] if edad>35 & edad<65

***Not highly skilled 
tab formal_ss_pension [fw=pondera] if edad>13 & edad<65 & rest_skilled==1



********************************************************************************
*Potentially affected public sector worker 

tab public_employee [fw=pondera] if targetgroup2==1


********************************************************************************
* Construct active labor force 

gen active_lf = (ocupad==1 | desocu==1)
tab active_lf [fw=pondera]

***Activity by age group
tab gedad1 active_lf [fw=pondera], row

***Activity by education 
tab educ_level active_lf [fw=pondera], row

***Activity by gender
tab hombre active_lf [w=pondera], row

*Extremely poor inactive
tab active_lf [fw=pondera] if pobre_extremo==1




********************************************************************************
*B) Construct unemployment rate

tab desocu if active_lf==1 [fw=pondera]
tab gedad1 desocu if active_lf==1 [fw=pondera], row
tab educ_level desocu if active_lf==1 [fw=pondera], row
tab hombre desocu if active_lf==1 [fw=pondera], row


********************************************************************************
*C) Minimum wage for certain regions 

tab region_est1 pobre_extremo [fw=pondera], row

tab sector pobre_extremo [fw=pondera], row
tab sector [fw=pondera] if pobre_extremo==1
tab sector [fw=pondera] if pobre==1




