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
Output:			    Simulation of extreme poverty-level wage 

=============================================================================*/
********************************************************************************
*Prepare 
********************************************************************************

***Current min wage
g minwage=20.62
label var minwage "Current minimum wage (in 2011-PPP-$)"

***Create minimum wages
*g newminwage1 = 27.56 // Minimum wage ratio of 0.4
*label var newminwage1 "Minimum wage ratio of 0.4" 
*g newminwage2 = 41.34 // Minimum wage ratio of 0.6 
*label var newminwage2 "Minimum wage ratio of 0.6 "

g newminwage1 = 164.9 //Two-thirds of extreme poverty-level wage
label var newminwage1 "100 percent of extreme poverty-level wage (164.9 2011-PPP-$)"
g newminwage2 = 123.75 //Two-thirds of extreme poverty-level wage
label var newminwage2 "75 percent of extreme poverty-level wage (123.75 2011-PPP-$)"
g newminwage3 = 82.5 //Two-thirds of extreme poverty-level wage
label var newminwage3 "50 percent of extreme poverty-level wage (82.5 2011-PPP-$)"
g newminwage4 = 55
label var newminwage4 "33 percent of extreme poverty-level wage (55.0 2011-PPP-$)"

***Young worker 
tab gedad1 //2 = age group 15-24

***Define current wage
drop wage
g wage = ila_ppp
label var wage "Wage 2019/20 in 2011-PPP-$"

***Employed
g employed = ocupado 
g unemployed = desocupa // desocupa = empezo_negocio o busco_trabajo
g unemploy_rate = .
replace unemploy_rate = 0 if ocupado==1 | desocup==1
replace unemploy_rate = 1 if desocup==1
tab unemploy_rate [fw=pondera] //check 

***School 
g atschool = (asiste==1) if !missing(asiste)

***NEET
g neet = . 
replace neet = 0 if gedad1==2 
replace neet = 1 if gedad1==2 & ocupado==0 & asiste==0 & actividades_inactivos<3
tab neet 

***Average income of employed earning below the poverty level wage
sum wage if wage<165 & categ_ocu!=5 & categ_ocu!=6 [fw=pondera]


********************************************************************************
*Replace missing wage

**Impute missing wages


***First choice: Impute average wage based on age, gender, skill, occupation, part-time, sector, formality
tempfile temptest 
save `temptest', emptyok

preserve
collapse (mean) wage [fw=pondera] if ocupado==1 & categ_ocu!=5 & categ_ocu!=6, ///
by(gedad1 hombre high_skilled categ_ocu part_time sector_encuesta formal_ss_pension)
rename wage Mwage
save `temptest', replace
restore

merge m:1 gedad1 hombre high_skilled categ_ocu part_time sector_encuesta formal_ss_pension using `temptest'  
drop _merge

replace wage=Mwage if wage==. & ocupado==1 & categ_ocu!=5 & categ_ocu!=6

***Second choice: Impute average wage based on age, occupation, formality and education
tempfile temptest 
save `temptest', emptyok

preserve
collapse (mean) wage [fw=pondera] if ocupado==1 & categ_ocu!=5 & categ_ocu!=6, ///
by(gedad1 categ_ocu formal_ss_pension hombre nivel_educ)
rename wage Mwage2
save `temptest', replace
restore

merge m:1 gedad1 categ_ocu formal_ss_pension hombre nivel_educ using `temptest'  
drop _merge

replace wage=Mwage2 if wage==. & ocupado==1 & categ_ocu!=5 & categ_ocu!=6

***Third choice: Impute average wage based on age, gender and education 
tempfile temptest 
save `temptest', emptyok

preserve
collapse (mean) wage [fw=pondera] if ocupado==1 & categ_ocu!=5 & categ_ocu!=6, ///
by(gedad1 hombre nivel_educ)
rename wage Mwage3
save `temptest', replace
restore

merge m:1 gedad1 hombre nivel_educ using `temptest'  
drop _merge

replace wage=Mwage3 if wage==. & categ_ocu!=5 & categ_ocu!=6

***Fourth choice: Imputed average wage based on age and gender 
tempfile temptest 
save `temptest', emptyok

preserve
collapse (mean) wage [fw=pondera] if ocupado==1 & categ_ocu!=5 & categ_ocu!=6, ///
by(gedad1 hombre)
rename wage Mwage4
save `temptest', replace
restore

merge m:1 gedad1 hombre using `temptest'  
drop _merge

replace wage=Mwage4 if wage==. & categ_ocu!=5 & categ_ocu!=6

***Drop variables 
drop Mwage Mwage2 Mwage3 Mwage4


********************************************************************************
*Define different scenarios

***Wage elasticity 
local sigma=5  // OWE= -0.5 (baseline)

***Wage Scenario
local sc=4

***New minimum wage
g newminwage=newminwage`sc'          //scenario of the Policy





********************************************************************************
*Only consider employees
replace wage=. if categ_ocu==5 | categ_ocu==6 //Do not consider employers and self-employed



********************************************************************************
*Expected wage due to policy 
********************************************************************************

***Wage below the minimum: 
gen wagelowold=wage<minwage 
replace wagelowold=. if wage==. | minwage==.
sum  wagelowold [fw=pondera]  

***Wage below the new minimum and obove the minimum (potentially affected)
gen wagelownew= wage<newminwage & wage>=minwage // -> try-out including below min-wage earners 
replace wagelownew=. if wage==. | minwage==.
sum  wagelownew [fw=pondera]  

***Wage above new min wage 
gen wagehigh=wage>=newminwage 
replace wagehigh=. if wage==. | minwage==.
sum  wagehigh [fw=pondera] 

***Compute expected wage as a result of the policy:
gen expwage=newminwage if wagelownew==1  // if potentally affected then expected wage = new min wage
replace expwage=wage if  wagelownew!=1   // otherwise wage remains unchanged
replace expwage=. if wage==.             

***Expected absolute change of wage:
gen wagechange=expwage-wage

lab var wagelowold "Wage<Minimum Wage"
lab var wagelownew "% new minwage>wage>=minwage" 
lab var expwage "Expected wage, all emp., 2011-PPP-U$"
lab var wagechange "Expected increase in wage, 2011-PPP-U$"
lab var wagechange "Expected increase in wage, 2011-PPP-U$"





********************************************************************************
*Create different types of elasticities
********************************************************************************


***Elasticities for skilled and unskilled 
g sigma=-0.`sigma'        // elasticity for skilled in the short-run
g sigma_us=sigma-0.7      // elasticity for unskilled in the short-run
g sigmalr=sigma-0.8       // elasticity for skilled in the long-run
g sigma_uslr=-1 // elasticity for unskilled in the long-run


***Create a variable for short- and long-run elasticity:
g sigma_sr=sigma*high_skilled+sigma_us*(1-high_skilled)
g sigma_lr=sigmalr*high_skilled+sigma_uslr*(1-high_skilled)



********************************************************************************
*Prepare Microsimulations
********************************************************************************

// Assuming that only whose who have minimum wage will loose
//By age, skills, occupation, type of firm and employment compute expected change in wage
//Compute change in wages (New minimum wage respect to group average wage) 
//Do not include sample weights here yet


**Compute average wage by age, gender, educ level, skill-level, occupation, sector, formal/informal, breadwinner
tempfile temptest 
save `temptest', emptyok

preserve
collapse (mean) wage [fw=pondera] if wagelownew==1, ///
by(gedad1 hombre educ_level high_skilled categ_ocu part_time sector_encuesta formal_ss_pension breadwinner)
rename wage Mwage
save `temptest', replace
restore

merge m:1 gedad1 hombre educ_level high_skilled categ_ocu part_time sector_encuesta formal_ss_pension breadwinner using `temptest'  
drop _merge


**Compute expected wage by age, gender, educ level, skill-level, occupation, sector, formal/informal, breadwinner
tempfile temptest 
save `temptest', emptyok

preserve
collapse (mean) expwage [fw=pondera] if wagelownew==1, ///
by(gedad1 high_skilled categ_ocu part_time sector_encuesta formal_ss_pension)
rename expwage Mexpwage
save `temptest', replace
restore

merge m:1 gedad1 high_skilled categ_ocu part_time sector_encuesta formal_ss_pension using `temptest'  
drop _merge

***Compute percentage change in wage : 
gen deltawage=(Mexpwage-Mwage)/Mexpwage

***Percentage change in wage=0 is non-affected
replace deltawage=0 if wagelownew==0 
replace deltawage=. if high_skilled==. | sector_encuesta==.

***Probability of loosing a job = change of wage * OWE: 
*Short-run
gen deltaemp_sr=deltawage*sigma_sr
*Long-run
gen deltaemp_lr=deltawage*sigma_lr



********************************************************************************
*Start simulation 
********************************************************************************

**Set a number of simulations:
local n=1000

forval i=1/`n' {
qui{

**Generate a random number between 0 and 1 for affected workers
set seed `i'
gen rann=uniform() if deltaemp_sr!=.


**in the long- and short- run
   foreach r in sr lr {
   
   
 **If the random number is below the probability of losing a job, then individual loses a job
 
   gen loosejob_`r'=(rann<-deltaemp_`r') if deltaemp_sr!=.
   
 **Replace wage by expected wage
   gen wage_`r'`i'=expwag 
 **Replace wage by zero if lost a job
   replace wage_`r'`i'=0 if loosejob_`r'==1
   replace wage_`r'`i'=. if wage==.

  
  
   g employed_`r'`i'=employed
   
 **Replace employment status by zero if lost a job:
 
   replace employed_`r'`i'=0 if wage_`r'`i'==0
 
   g unemployed_`r'`i'=unemployed
   
 **Replace unemployed by 1 if lost a job
 
   replace unemployed_`r'`i'=1 if wage_`r'`i'==0 & unemployed_`r'`i'!=.
   g neet_`r'`i'=neet
   
 **Replace neet by 1 if lost a job and not in school
 
   replace neet_`r'`i'=1 if unemployed_`r'`i'==1 
   replace neet_`r'`i'=0 if atschool==1 
   }
   
 **Generate real wage which is defined only for those who did not lose a job
 
 g Realwage_lr`i'=expwage
 replace Realwage_lr`i'=. if loosejob_lr==1
 replace Realwage_lr`i'=. if wage==.
 
   
drop rann loosejob_sr loosejob_lr 
}
}



********************************************************************************
*Compute average across simulations
********************************************************************************

***Now generate average wage, median wage, employment rate and unemployment rate across simulations: 

foreach r in sr lr {
egen Mwage_`r'=rowmean(wage_`r'*)
egen SDwage_`r'=rowsd(wage_`r'*)
egen MEDwage_`r'=rowmedian(wage_`r'*)
egen Munemployed_`r'=rowmean(unemployed_`r'*)
egen Memployed_`r'=rowmean(employed_`r'*)
egen Mneet_`r'=rowmean(neet_`r'*)
}
egen MRealwage_lr=rowmean(Realwage_lr*)


***Labeling

lab var wage "Actual wage."
lab var employed "Employment rate. %"
lab var unemployed "Unemployment rate. %"
lab var neet "Percent of NEETs. %"
lab var expwage  "Expected wage assuming no loose of employment."
lab var Mwage_sr  "Simulated wage. Short-run."
lab var Memployed_sr "Simulated employment rate. Short-run. %"
lab var Munemployed_sr "Simulated unemployment rate. Short-run %"
lab var Mneet_sr "Simulated percent of NEETs. Short-run %"
lab var Mwage_lr  "Simulated wage. Long-run."
lab var Memployed_lr "Simulated employment rate. Long-run. %"
lab var Munemployed_lr "Simulated unemployment rate. Long-run %"
lab var Mneet_lr "Simulated percent of NEETs. Long-run %"



********************************************************************************
*Summary statistic
********************************************************************************

**Create the list of main indicators: 
global outcome  wage wagelownew wagelowold employed unemployed neet expwage Mwage_sr Memployed_sr  Munemployed_sr  Mneet_sr  Mwage_lr  Memployed_lr ///
Munemployed_lr Mneet_lr
global outcome2  wage employed unemployed neet expwage Mwage_sr Memployed_sr  Munemployed_sr  Mneet_sr  Mwage_lr  Memployed_lr ///
Munemployed_lr Mneet_lr


*************************************************
*Define groups of interest for summary statistic

**Define the groups for which we compute the main effect:
g notbreadwinner  =1-breadwinner
lab var notbreadwinner "Non-unique breadwinner"

gen agegr=""
replace agegr = "15-24" if gedad1==2
replace agegr = "25-40" if gedad1==3
replace agegr = "41-64" if gedad1==4

g age1524 = (gedad1==2) if !missing(gedad1)
g age2540 = (gedad1==3) if !missing(gedad1)
g age4164 = (gedad1==4) if !missing(gedad1)

gen informal_string=""
replace informal_string="formal" if formal_ss_pension==1
replace informal_string="informal" if formal_ss_pension==0

g Informal = (formal_ss_pension==0) if !missing(formal_ss_pension)
g Formal = (formal_ss_pension==1) if !missing(formal_ss_pension)

gen educ_string=""
replace educ_string="Primary education or less" if nivel_educ<3
replace educ_string="Secondary education" if nivel_educ>2 & nivel_educ<7
replace educ_string="Post-secondary education" if nivel_educ>6

g Primaryorless = (nivel_educ<4) if !missing(nivel_educ)
g Secondary = (nivel_educ>3 & nivel_educ<6) if !missing(nivel_educ)
g PostSecondary = (nivel_educ>5) if !missing(nivel_educ)

gen sex_string=""
replace sex_string="Female" if hombre==0
replace sex_string="Male" if hombre==1
gen Male=(hombre==1) if !missing(hombre)
gen Female=(hombre==0) if !missing(hombre)

gen sector_string="Private" if categ_ocu==3
replace sector_string="Public" if categ_ocu==1

g Private = (categ_ocu==3) if !missing(categ_ocu)
g Public = (categ_ocu==1) if !missing(categ_ocu)
g DomesticService = (categ_ocu==9) if !missing(categ_ocu) 
g FamilyWorker = (categ_ocu==8) if !missing(categ_ocu) 
g Cooperatives = (categ_ocu==7) if !missing(categ_ocu) 

lab def skill_level 3 "High skilled" 2 "Skilled" 1 "Unskilled", replace
lab val skill_level skill_level
tab skill_level

gen All=1

global group All Male Female age1524 age2540 age4164 ///
Primaryorless Secondary PostSecondary Private Public DomesticService FamilyWorker Cooperatives Informal Formal breadwinner 



********************************************************************************
*Compute summary statistics

***Generate the summary statisctics: 

foreach var in $group {
local lb`var': variable label `var'
}

foreach var in $group {

preserve 
collapse  $outcome [fw=pondera] if `var'==1



lab var wage "Actual wage."
lab var wagelownew "% of potentially affected"
lab var wagelowold "% with wage below minimum"
lab var employed "Employment rate. %"
lab var unemployed "Unemployment rate. %"
lab var neet "Percent of NEETs. %"
lab var expwage  "Expected wage assuming no lose of employment."
lab var Mwage_sr  "Simulated wage. Short-run."
lab var Memployed_sr "Simulated employment rate. Short-run. %"
lab var Munemployed_sr "Simulated unemployment rate. Short-run %"
lab var Mneet_sr "Simulated percent of NEETs. Short-run %"
lab var Mwage_lr  "Simulated wage. Long-run."
lab var Memployed_lr "Simulated employment rate. Long-run. %"
lab var Munemployed_lr "Simulated unemployment rate. Long-run %"
lab var Mneet_lr "Simulated percent of NEETs. Long-run %"


**Compute changes in wage as a results of the policy: 

g wage_change_sr=Mwage_sr/wage-1
g wage_change_lr=Mwage_lr/wage-1

g employed_change_sr=Memployed_sr-employed
g employed_change_lr=Memployed_lr-employed

g unemployed_change_sr=Munemployed_sr-unemployed
g unemployed_change_lr=Munemployed_lr-unemployed

lab var wage_change_sr "Percentage change in wage. Short-run"
lab var wage_change_lr "Percentage change in wage. Long-run"
lab var employed_change_sr "Change in employment. Short-run"
lab var employed_change_lr "Change in employment. Long-run"
lab var unemployed_change_sr "Change in unemployment. Short-run"
lab var unemployed_change_lr "Change in unemployment. Long-run"

g group="`var'"


order group wage wagelownew wagelowold employed  unemployed neet expwage Mwage_sr Memployed_sr Munemployed_sr Mneet_sr ///
wage_change_sr   employed_change_sr unemployed_change_sr Mwage_lr Memployed_lr Munemployed_lr Mneet_lr ///
wage_change_lr employed_change_lr unemployed_change_lr 

foreach xx in wagelownew wagelowold  employed  unemployed neet Memployed_sr Munemployed_sr Mneet_sr wage_change_sr  ///
employed_change_sr unemployed_change_sr Memployed_lr Munemployed_lr Mneet_lr ///
wage_change_lr employed_change_lr unemployed_change_lr {
replace `xx'=`xx'*100
}

//Save to stata
save "$tables/temp_SIM_`var'.dta", replace

restore
}


global group Male Female age1524 age2540 age4164 ///
Primaryorless Secondary PostSecondary Private Public DomesticService FamilyWorker Cooperatives Informal Formal breadwinner 


***Append all excel files in one:
use "$tables\temp_SIM_All.dta", clear

foreach var in $group {
append using "$tables\temp_SIM_`var'.dta"
}


export excel using "$tables\SIMILATION.xlsx", sheet(`sigma'_`sc') firstrow(varlabels) cell(A2) sheetreplace   


**Save the final excel file:

putexcel set "$tables\SIMILATION.xlsx", sheet(`sigma'_`sc') modify
putexcel A1=("Micro-Simulation Results. Venezuela, 2019/20. Policy: `lbwagelownew`sc''. Assumed elasticity -0.`sigma'") 

**Errase intermediate files

foreach var in $group {
erase "$tables\temp_SIM_`var'.dta"
}
































