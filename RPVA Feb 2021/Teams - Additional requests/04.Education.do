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
	01. Education
=============================================================================*/

********************************************************************************
*Nacional several indicators
local varlist razon_noasis razon_noasis_o pae pae_frecuencia pae_desayuno pae_almuerzo pae_meriman pae_meritard pae_otra razon_dejo_estudios razon_dejo_est_comp
foreach x in `varlist'{
estpost tab `x' [fw=pondera], label
esttab using "$tables/`x'_national.csv", cells("b pct") collabels("Frequency Percent") label unstack varlabels(`e(labels)') ///
title(Education:`x' - National (ENCOVI 2019/20)) replace
}


********************************************************************************
*Cobertura by region
tab region_est1 asiste [fw=pondera]
estpost tab region_est1 asiste[fw=pondera], label
esttab using "$tables/asiste_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Education:asiste - National (ENCOVI 2019/20)) replace

*Cobertura by age group
tab grupo_edad10 asiste [fw=pondera]
estpost tab grupo_edad10 asiste[fw=pondera], label
esttab using "$tables/asiste_grupo_edad10.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Education:asiste grupo_edad10 - National (ENCOVI 2019/20)) replace


********************************************************************************
*Reason for not assisting by age group
tab grupo_edad10 razon_noasis [fw=pondera]
estpost tab grupo_edad10 razon_noasis[fw=pondera], label
esttab using "$tablesrazon_noasis_grupo_edad10.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Education:asiste razon_noasis - National (ENCOVI 2019/20)) replace

asdoc tab razon_noasis_o grupo_edad10 [fw=pondera], replace nocf save($tables\razon_noasis_o_agroups.doc)

*Reason for not attending by gender
tab hombre razon_noasis [fw=pondera]
estpost tab hombre razon_noasis[fw=pondera], label
esttab using "$tables/razon_noasis_hombre.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Education: razon_noasis hombre - National (ENCOVI 2019/20)) replace

asdoc tab razon_noasis_o hombre [fw=pondera], replace nocf save($tables\razon_noasis_o_hombre.doc)


********************************************************************************
*GROSS ASSISTANCE

*Gross assistance
g gr_attend=.
replace gr_attend=1 if edad>=3 & edad<=5
replace gr_attend=2 if edad>5 & edad<=12
replace gr_attend=3 if edad>12 & edad<=14
replace gr_attend=4 if edad>14 & edad<=17

label define gr_attend 1 "ECD" 2 "Primary" 3 "Secondary (12-14)" 4 "Secondary (14-17)"
label val gr_attend gr_attend

*Gross assistance (national)
estpost tab gr_attend [fw=pondera], label
esttab using "$tables/gr_attend_national.csv", cells("b pct") collabels("Frequency Percent") label unstack varlabels(`e(labels)') ///
title(Education: Gross Attendance - National (ENCOVI 2019/20)) replace

*Gross assistance by gender
tab hombre gr_attend [fw=pondera]
estpost tab hombre gr_attend[fw=pondera], label
esttab using "$tables/gr_attend_hombre.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Education: gr_attend hombre - National (ENCOVI 2019/20)) replace



********************************************************************************
*NET ASSISTANCE 

***Educational levels (dummies)
g comp_edu=1 if (nivel_educ_act==2) &!missing(nivel_educ_act) //ECD
replace comp_edu=2 if (nivel_educ_act==5) &!missing(nivel_educ_act) //Primary
replace comp_edu=3 if (nivel_educ_act==6) &!missing(nivel_educ_act) //Secondary
replace comp_edu=4 if (nivel_educ_act==6) &!missing(nivel_educ_act) //Secondary - I define this as 4 for the loop below
replace comp_edu=5 if (nivel_educ_act>6) &!missing(nivel_educ_act) //Tertiary (Tecnico + Universidad)

label define comp_edu 1 "ECD" 2 "Primary" 3 "Secondary" 4 "Secondary" 5 "Tertiary"
label val comp_edu comp_edu


*Net assistance
estpost tab comp_edu [fw=pondera], label
esttab using "$tables/net_attend_national.csv", cells("b pct") collabels("Frequency Percent") label unstack varlabels(`e(labels)') ///
title(Education: Net Attendance by level - National (ENCOVI 2019/20)) replace

*Net assistance by gender
tab hombre comp_edu [fw=pondera]
estpost tab hombre comp_edu[fw=pondera], label
esttab using "$tables/net_attend_hombre.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Education: Net Attendance by Level and Gender - National (ENCOVI 2019/20)) replace



********************************************************************************
*Cantidad de ninjos en el tiempo

append using "$rawdata\ENCOVI_2018_COMP.dta"
append using "$rawdata\ENCOVI_2017_COMP.dta", force
append using "$rawdata\ENCOVI_2016_COMP.dta"
append using "$rawdata\ENCOVI_2015_COMP.dta"
append using "$rawdata\ENCOVI_2014_COMP.dta"

g child7_12 = (edad >= 7 & edad <=12)
g child0_15 = (edad < 15)
g schoolchild_attending = (asiste == 1 & edad>=3 &  edad <15)

tab ano child7_12 [fw=pondera]
tab ano child0_15 [fw=pondera]
tab ano schoolchild_attending [fw=pondera]

local varlist child7_12 child0_15 schoolchild_attending
foreach x in `varlist'{
tab ano `x' [fw=pondera]
estpost tab ano `x' [fw=pondera], label
esttab using "$tables/`x'_year.csv", b(%12.2g) collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Number of children over time: `x' - Regional (ENCOVI 2019/20)) replace
}



			

