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
Output:			    Additional analysis for the RPBA 

=============================================================================
	05. Return Migration
=============================================================================*/

********************************************************************************
*Shortage in medicine
tab recibio_remedio [fw=pondera]

gen med_shortage = recibio_remedio
replace med_shortage= (recibio_remedio>3) if !missing(recibio_remedio)
tab med_shortage [fw=pondera], m

label define med_shortage 0 "No shortage" 1 "Shortage"
label val med_shortage med_shortage

estpost tab med_shortage [fw=pondera], label
esttab using "$tables/med_shortage_national.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Shortage in Medicine among those with medical prescription (ENCOVI 2019/20)) replace


********************************************************************************
*Educational level of emigrants

preserve

local varlist numero_emig edad_emig_* sexo_emig_* anoemig_* leveledu_emig_* 
keep  if hogar_emig==1
collapse (mean) `varlist' pondera_hh miembros, by(id)
list id numero_emig pondera_hh in 1/10 

reshape long edad_emig_ sexo_emig_ anoemig_ leveledu_emig_, i(id) j(emigid)
list emigid leveledu_emig pondera_hh in 1/10
drop if edad_emig==.
by id: gen emig_id = _n
drop emigid
tab leveledu_emig_ [fw=pondera_hh]

g comp_edu=0 if (leveledu_emig_==1) &!missing(leveledu_emig_) //No degree
replace comp_edu=1 if (leveledu_emig_==2) &!missing(leveledu_emig_) //Pre-school
replace comp_edu=2 if (leveledu_emig_==3 | leveledu_emig==5) &!missing(leveledu_emig) //Básica
replace comp_edu=3 if (leveledu_emig_==4 | leveledu_emig==6) &!missing(leveledu_emig) //Media
replace comp_edu=4 if (leveledu_emig_>6) &!missing(leveledu_emig_) //Tertiary
tab comp_edu leveledu_emig, m //Check

label define comp_edu 0 "No degree" 1 "ECD" 2 "Basic Schooling" 3 "Secondary" 4 "Tertiary"
label val comp_edu comp_edu

tab comp_edu [fw=pondera_hh]
tab comp_edu [fw=pondera_hh] if anoemig_>2015
estpost tab comp_edu [fw=pondera_hh] if anoemig_>2015, label
esttab using "$tables/leveledu_emig_.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Educ. level of emigrants (emigration after 2015) (ENCOVI 2019/20)) replace

tab comp_edu [fw=pondera_hh]
tab comp_edu [fw=pondera_hh] if anoemig_>2018
estpost tab comp_edu [fw=pondera_hh] if anoemig_>2018, label
esttab using "$tables/leveledu_emig_2018.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Educ. level of emigrants (emigration after 2018) (ENCOVI 2019/20)) replace

*Education level of emigrants by emigration year 
tab comp_edu anoemig [fw=pondera_hh]
estpost tab comp_edu anoemig [fw=pondera_hh], label
esttab using "$tables/leveledu_emig_year.csv", cells("b colpct(fmt(%5.2f))") collabels("Frequency" "Columnpercent") label unstack varlabels(`e(labels)') ///
title(Educ. level of emigrants (emigration after 2018) (ENCOVI 2019/20)) replace

tab miembros [fw=pondera_hh] if anoemig_>2015
estpost tab miembros [fw=pondera_hh] if anoemig_>2015, label
esttab using "$tables/miembros_emig.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Household members  (emigration after 2015) (ENCOVI 2019/20)) replace

sum miembros [fw=pondera_hh] if anoemig_>2015, d
estpost tabstat miembros [fw=pondera_hh] if anoemig_>2015, listwise statistics(count mean sd min max) columns(statistics)
esttab using "$tables/miembros_emig_sum.csv", cells("count mean sd min max") collabels("N" "Mean" "SD" "Min" "Max") ///
title(Household members  (emigration after 2015) (ENCOVI 2019/20)) replace

restore



********************************************************************************
*Female-led household heads

tab hombre if relacion_en == 1 [fw=pondera_hh]
estpost tab hombre [fw=pondera_hh] if relacion_en==1, label
esttab using "$tables/female_hhead.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Female household heads (ENCOVI 2019/20)) replace

********************************************************************************
*Household size in Venezuela

sum miembros [fw=pondera], d
estpost tabstat miembros [fw=pondera], listwise statistics(count mean sd min max) columns(statistics)
esttab using "$tables/household_size_sum.csv", cells("count mean sd min max") collabels("N" "Mean" "SD" "Min" "Max") ///
title(Household size in Venezuela (ENCOVI 2019/20)) replace

********************************************************************************
*Number of households in Venezuela

egen hhid = tag(id)
tab hhid

tab relacion_en if hhid==1 //There are some households without a household head, but they receive zero weight in pondera_hh
tab relacion_en if hhid==1 [fw=pondera_hh] //Receive no weight
tab relacion_en if hhid==1 [fw=pondera] //Receive weight

tab hhid [fw=pondera_hh] //8,524,989 
estpost tab hhid [fw=pondera_hh] if hhid==1, label
esttab using "$tables/number_households.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Number of households (ENCOVI 2019/20)) replace


********************************************************************************
*Number of single-headed households in Venezuela

tab estado_civil_en if relacion_en == 1 [fw=pondera_hh]

gen single = (estado_civil_en==8) if !missing(estado_civil_en)
tab single hombre [fw=pondera_hh] if relacion_en==1
label define singlelab 1 "Single" 0 "Non-Single"
label val single singlelab

estpost tab hombre single[fw=pondera_hh] if relacion_en==1, label
esttab using "$tables/gender_singlehh.csv", cells("b") collabels("Frequency") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Gender of single-headed households in Venezuela (ENCOVI 2019/20)) replace


********************************************************************************
*Mean salary by gender

estpost tabstat ila [fw=pondera] if ocupado==1, by(hombre) listwise statistics(count mean sd min max) columns(statistics)
esttab using "$tables/mean_laborincome_gender.csv", cells("count mean(fmt(%12.2f)) sd min max(fmt(%12.2f))") collabels("N" "Mean" "SD" "Min" "Max") ///
title(Mean income of working population by gender in Venezuela (ENCOVI 2019/20)) replace


********************************************************************************
*Beneficiaries by CLAP 
label define clap 1 "Clap recipient" 0 "Clap Non-recipient"
label val clap clap

tab clap hombre [fw=pondera]
estpost tab hombre clap[fw=pondera_hh] if relacion_en==1, label
esttab using "$tables/gender_beneficiaries_clap.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Clap beneficiaries by gender (ENCOVI 2019/20)) replace



********************************************************************************
*Number of males between 25 and 34 years that report childcare as an impediment to search for job. 

tab razon_no_busca hombre [fw=pondera] if edad>24 & edad<35
estpost tab razon_no_busca hombre [fw=pondera] if edad>24 & edad<35, label
esttab using "$tables/razon_no_busca_genero.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Main reason for not looking for a job by gender (ENCOVI 2019/20)) replace

********************************************************************************
*Mean salary by industry

label define industry 1 "Agriculture/ livestock/ fishing/ huntin" 2 "Mining and quarrying" 3 "Manufacturing industry" 4 ///
"Installation / supply / distribution of" 5 "Construction" 6 "Wholesale and retail trade; repair of motor vehicles and motorcycles" ///
7 "Transportation/ storage/ lodging/ food services/communication/computer services" ///
8 "Financial and insurance/ real estate/ professional scientific technical services/admin" ///
9 "Public administration and defense/ education/ health/social assistance/ art entertainment" ///
10 "Other service activities such as repair cleaning hairdressing domestic services funeral"
label val sector_encuesta industry

estpost tabstat ila [fw=pondera] if ocupado==1, by(sector_encuesta) listwise statistics(count mean sd min max) columns(statistics)
esttab using "$tables/mean_laborincome_industry.csv", cells("count mean sd min max(fmt(%12.2f))") collabels("N" "Mean" "SD" "Min" "Max") ///
title(Mean income of working population by industry in Venezuela (ENCOVI 2019/20)) replace varlabels(`e(labels)') varwidth(20)

 


********************************************************************************
*Gas Shortage

*Need to use follow-up surveys

use "$rawdata\VEN_ENCOVI_2019_&_FOLLOW_UP_2020_2_English labels.dta", clear

*Necesidad de comprar gasolina

tab gas_necesita_FU2 [fw=pondera]

*Logró comprar gasolina? Only asked to those that have necessity 
tab gas_compro_FU2 [fw=pondera]
estpost tab gas_compro_FU2 [fw=pondera], label
esttab using "$tables/gas_compro_FU2.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Households with necessity to buy gas - could they get gas? (ENCOVI 2019/20)) replace

*People that could not pay for gas? Only aksed to those that could not get gas
tab gas_causa_precio_FU2 [fw=pondera]
estpost tab gas_causa_precio_FU2 [fw=pondera], label
esttab using "$tables/gas_causa_precio_FU2.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Households that could not get gas - reason:Price? (ENCOVI 2019/20)) replace

tab gas_causa_precio_FU2 [fw=pondera]
estpost tab gas_causa_precio_FU2 [fw=pondera], label
esttab using "$tables/gas_causa_precio_FU2.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Households that could not get gas - reason:Price? (ENCOVI 2019/20)) replace

tab gas_causa_dinero_FU2 [fw=pondera], label
estpost tab gas_causa_dinero_FU2 [fw=pondera], label
esttab using "$tables/gas_causa_dinero_FU2.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Households that could not get gas - reason:No money? (ENCOVI 2019/20)) replace






********************************************************************************
*Hourly wage over time 

append using "$rawdata\ENCOVI_2018_COMP.dta"
append using "$rawdata\ENCOVI_2017_COMP.dta", force
append using "$rawdata\ENCOVI_2016_COMP.dta"
append using "$rawdata\ENCOVI_2015_COMP.dta"
append using "$rawdata\ENCOVI_2014_COMP.dta"

************************************************************
** Hourly wages over time 

* need to put all in comparable time period due to hyperinflation

*Genreate wage in US-2011-PPP values
gen double wage_ppp11 = wage * (ipc11/ipc) * (1/ppp11)

*Tab mean wage by year 
bysort ano: sum wage_ppp11 if inrange(edad,14,64) [fw=pondera]

*Drop 2018 as problems with currency
drop if ano==2018

*Put in excel 
estpost tabstat wage_ppp11 if inrange(edad,14,64) [fw=pondera], by(ano) statistics(p10 p90) columns(statistics)
esttab using "$tables/hourlywage_year.csv", cells("p10 p90") label collabels("P10" "P90") obs unstack ///
title(Hourly wage by 10th and 90th percentile - National (ENCOVI 2019/20)) replace ///
varlabels(`e(labels)') eqlabels(`e(eqlabels)')







