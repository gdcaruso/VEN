/*===============================================================================
*Author: Britta Rude
*Creation Date: Feb, 2021
*Topic: Fay-Herriot model for poverty map at the municipality level 
*===============================================================================
*Estimate Fay-Harriot model: 
Version 1: Only uses household data (ENCOVI 2019/20)
Version 2: Only uses census data (Census 2011)
Version 3: Uses census data at municipality level and household data at the regional level

*===============================================================================*/
/*===============================================================================
Version 2: Only use Census 2011
===============================================================================*/

*******************************************************************************
*Define variables for estimation

global directestimators ipcf_munid ipcf_var_munid pobre_extremo_munid pobre_extremo_var_munid
global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
*global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global headvars h_age h_fem h_single h_primaria h_secundaria
global hhvars miembros shchild shoccadult notsch
global munvars occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9


/*===============================================================================
Version 2.1.: Use entire census 2011
===============================================================================*/

********************************************************************************
*Upload fh census data and merge to fh encovi data

use "${dataout}/census_hhlevel_munid_fhmodel.dta", clear

merge 1:1 munid using "${dataout}/survey_hhlevel_fhmodel.dta", keepusing(munid munid_str ${directestimators})
*Note: Several are not matched (3 from encovi are not in census, 125 from census are not in encovi)


********************************************************************************
*Check survey data

tab pobre_extremo_var_munid, m //125 are missing from encovi
tab entid if _merge==2 //The missing are in all regions and entidades
replace pobre_extremo_var_munid=. if pobre_extremo_var_munid==0 //replace 38 which are missing

*QNORM of poverty rates
qnorm pobre_extremo_munid, grid ytitle(Extreme Poverty Rate (Municipality Level)) xlabel(,format(%12.2f)) ylabel(,format(%12.2f))
graph export "$figures/qnormplot.png", replace

********************************************************************************
*Run FH Model on extreme poverty rate

fhsae pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, method(FH) ///
revar(pobre_extremo_var_munid) fhpredict(EBLUP) fhcvpredict(EBLUP_cv) dcvpredict(Direct_cv) outsample nonegative
 

********************************************************************************
*Extract summary statistics

label var pobre_extremo_munid "Direct estimator"
label var EBLUP "EBLUP estimator"
label var EBLUP_cv "CV (EBPLU)"
label var Direct_cv "CV(Direct)"

local varlist pobre_extremo_munid EBLUP EBLUP_cv Direct_cv
asdoc sum `varlist', stat(N mean min p10 p25 p50 max) replace nocf save($tables\poverty_rate_eblup.doc) ///
title(Fay-Herriot-Model Results) fhc(\b) fs(11) dec(1) ///
cnames(Number Mean Min 10-perc 25-perc Median Max) label


********************************************************************************
*Save household data ready for FH model at munid level
drop _merge
save "${dataout}/povertymap.dta", replace




/*===============================================================================
Version 2.2.: Use entire census 2011 but entidades not sampled in encovi (2, 25 and 10)
===============================================================================*/

********************************************************************************
*Upload fh census data and merge to fh encovi data

use "${dataout}/census_hhlevel_munid_fhmodel.dta", clear

merge 1:1 munid using "${dataout}/survey_hhlevel_fhmodel.dta", keepusing(munid munid_str ${directestimators})
*Note: Several are not matched (3 from encovi are not in census, 125 from census are not in encovi)

tab pobre_extremo_var_munid, m //125 are missing from encovi
tab entid if _merge==2 //The missing are in all regions and entidades
replace pobre_extremo_var_munid=. if pobre_extremo_var_munid==0 //replace 38 which are missing

*drop entidades not sampled in encovi
drop if entid=="02" | entid=="25" | entid=="10"

********************************************************************************
*Run FH Model on extreme poverty rate

fhsae pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, method(FH) ///
revar(pobre_extremo_var_munid) fhpredict(EBLUP) fhcvpredict(EBLUP_cv) dcvpredict(Direct_cv) outsample nonegative
 

********************************************************************************
*Extract summary statistics

label var pobre_extremo_munid "Direct estimator"
label var EBLUP "EBLUP estimator"
label var EBLUP_cv "CV (EBPLU)"
label var Direct_cv "CV(Direct)"

local varlist pobre_extremo_munid EBLUP EBLUP_cv Direct_cv
asdoc sum `varlist', stat(N mean min p10 p25 p50 max) replace nocf save($tables\poverty_rate_eblup.doc) ///
title(Fay-Herriot-Model Results) fhc(\b) fs(11) dec(1) ///
cnames(Number Mean Min 10-perc 25-perc Median Max) label


********************************************************************************
*Save household data ready for FH model at munid level
drop _merge
save "${dataout}/povertymap.dta", replace


















