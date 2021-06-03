/*===============================================================================
*Author: Britta Rude
*Creation Date: Feb, 2021
*Topic: Fay-Herriot model for poverty map at the municipality level 
*===============================================================================
*Estimate Fay-Harriot model: 
Only uses census data (Census 2011) as explanatory variables

*===============================================================================*/

*******************************************************************************
*Define variables for estimation

global directestimators simple_mean_ipcf_ppp simple_mean_poor simple_mean_poverty_gap simple_mean_poverty_severity ///
simple_var_ipcf_ppp simple_var_poor simple_var_poverty_gap simple_var_poverty_severity samplesize ///
poor_munid poor_var_munid ipcf_ppp11_munid ipcf_ppp11_var_munid poverty_gap_munid poverty_gap_var_munid ///
poverty_severity_munid poverty_severity_var_munid
*global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global headvars h_fem h_primaria
global hhvars miembros shchild shoccadult notsch
global munvars occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9



********************************************************************************
*Upload fh census data and merge to fh encovi data

use "${dataout_census}/census_hhlevel_munid_fhmodel.dta", clear

merge 1:1 munid using "${dataout}/survey_hhlevel_fhmodel.dta", keepusing(munid munid_str ${directestimators})
drop _merge
*Note: Several are not matched (3 from encovi are not in census, 125 from census are not in encovi)



/*==============================================================================
Activate this if only for entities that were estimated in ENCOVI 2019/20
===============================================================================*/

*drop entidades not sampled in encovi
drop if entid=="02" | entid=="25" | entid=="10" //12 municipalities


/*==============================================================================
Plot histograms of outcome variable of interest
===============================================================================*/

hist pobre_extremo_munid, title("Extreme Poverty Rate at the municipality level") xtitle("Extreme Poverty Rate")
graph export "$figures/histogram_pobreextremo_munid.png", replace 

hist poverty_gap_munid, title("Extreme Poverty Gap at the municipality level") xtitle("Extreme Poverty Gap")
graph export "$figures/histogram_gap_munid.png", replace 

hist ipcf_munid, title("Income of the extreme poor at the municipality level") xtitle("Income of the extreme poor") ylabel(,format(%9.7fc))
graph export "$figures/histogram_income_munid.png", replace



/*==============================================================================
Conduct different versions of model for different poverty indicators
===============================================================================*/


********************************************************************************
*A) Extreme poverty rate
********************************************************************************

*1.) Extreme Poverty Rate
preserve

sum pobre_extremo_var_munid, d
fayherriot pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(pobre_extremo_var_munid) gamma nolog ///
initialvalue(`=r(p50)')
 
predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_pobreextremo.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Model - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label replace

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_pobreextremo.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_pobreextremo.png", replace 

restore


*2.) Extreme Poverty Rate with ampl estimation for variance
preserve

sum pobre_extremo_var_munid, d
fayherriot pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(pobre_extremo_var_munid) gamma nolog ///
initialvalue(`=r(p50)') sigmamethod(ampl)

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

tab eblupROR 

save "$dataout/fh_pobreextremo_ampl.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Model with ampl estimation - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label append

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_pobreextremo_ampl.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_pobreextremo_ampl.png", replace 

restore


*3.) Extreme Poverty Rate with aryl estimation for variance
preserve

sum pobre_extremo_var_munid, d
fayherriot pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(pobre_extremo_var_munid) gamma nolog ///
initialvalue(`=r(p50)') sigmamethod(aryl)

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_pobreextremo_aryl.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Model with aryl estimation - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label append

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_pobreextremo_aryl.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_pobreextremo_aryl.png", replace 

restore




********************************************************************************
*Run acrsin transformed model 

*Note with arcsin no MSE and no CVFH and no CVdirect possible 

*4) Arcsin transformation 
gen pobre_extremo_asin = asin(sqrt(pobre_extremo_munid))
replace pobre_extremo_var_munid=0.0000001 if pobre_extremo_var_munid==0 //Correct for 0 variance due to comment below
gen designeffect = pobre_extremo_var_munid/simple_var_pobre_extremo //Problem: Those with variance 0 will be missing
gen effsample = samplesize/designeffect //157 missing
gen sigma2_e_arcsine = 1/(4*effsample) //157 missing

preserve

sum sigma2_e_arcsine, d
fayherriot pobre_extremo_asin ${vivvars} ${headvars} ${hhvars} ${munvars} if sigma2_e_arcsine!=., variance(sigma2_e_arcsine) gamma nolog ///
initialvalue(`=r(p50)') arcsin

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
label var pobre_extremo_munid "Direct estimator"

tab eblupROR

save "$dataout/fh_pobreextremo_arcsin.dta", replace

asdoc sum pobre_extremo_munid eblupROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Model with acrsin transformation) - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label append

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_pobreextremo_arcsin.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_pobreextremo_arcsin.png", replace 

restore


*Arcsin transformation with ampl 
 
preserve

sum sigma2_e_arcsine, d
fayherriot pobre_extremo_asin ${vivvars} ${headvars} ${hhvars} ${munvars} if sigma2_e_arcsine!=., variance(sigma2_e_arcsine) gamma nolog ///
initialvalue(`=r(p50)') arcsin sigmamethod(ampl)

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
label var pobre_extremo_munid "Direct estimator"

tab eblupROR

save "$dataout/fh_pobreextremo_arcsin_ampl.dta", replace

asdoc sum pobre_extremo_munid eblupROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Model with acrsin transformation and ampl estimation - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label append

restore



********************************************************************************
*Run Log-Transformed version of FH Model (predict for all out-of-sample municipalities


*5) Extreme poverty rate and log-transformation 
generate log_pobre_extremo = log(pobre_extremo_munid) //126 missing values generated
generate directlogvariance = pobre_extremo_var_munid/(pobre_extremo_munid*pobre_extremo_munid) //126 missing values generated

preserve
sum directlogvariance, d
fayherriot log_pobre_extremo ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(directlogvariance) gamma nolog logarithm ///
initialvalue(`=r(p50)') biascorrection(sm)

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for FH estimate
predict cvROR_direct, cvdirect //CV for direct estimate

label var eblupROR "EBLUP estimator"
label var mseROR "MSE EBLUP"
label var cvROR_FH "CV (FH Model)"
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_pobreextremo_log.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Log-Transformed Model - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(1) label append

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_pobreextremo_log.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_pobreextremo_log.png", replace 

restore


*6) Extreme poverty rate with crude back transformation in log-transformed model 

preserve
sum directlogvariance, d
fayherriot log_pobre_extremo ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(directlogvariance) gamma nolog logarithm ///
initialvalue(`=r(p50)') biascorrection(crude)

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for FH estimate
predict cvROR_direct, cvdirect //CV for direct estimate

label var eblupROR "EBLUP estimator"
label var mseROR "MSE EBLUP"
label var cvROR_FH "CV (FH Model)"
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

tab eblupROR 

save "$dataout/fh_pobreextremo_log.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyRate.doc) ///
title(FH Log-Transformed Model with crude back-transformation - Extreme Poverty Rate (2019/20)) fhc(\b) fs(11) dec(1) label append

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_pobreextremo_log2.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_pobreextremo_log2.png", replace 

restore





********************************************************************************
*B) POVERTY GAPS (EXTREME POVERTY)
********************************************************************************

*1.) Extreme Poverty Gap
preserve

sum poverty_gap_var_munid, d
fayherriot poverty_gap_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(poverty_gap_var_munid) gamma nolog ///
initialvalue(`=r(p50)')
 
predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_povertygap.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyGap.doc) ///
title(FH Model - Extreme Poverty Gap (2019/20)) fhc(\b) fs(11) dec(2) label replace

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_povertygap.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_povertygap.png", replace 

restore


*2.) Extreme Poverty Gap with ampl estimation for variance
preserve

sum poverty_gap_var_munid, d
fayherriot poverty_gap_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(poverty_gap_var_munid) gamma nolog ///
initialvalue(`=r(p50)') sigmamethod(ampl)

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

tab eblupROR 

save "$dataout/fh_povrtygap_ampl.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyGap.doc) ///
title(FH Model with ampl estimation - Extreme Poverty Gap (2019/20)) fhc(\b) fs(11) dec(2) label append

restore


*3.) Extreme Poverty Gap with aryl estimation for variance
preserve

sum poverty_gap_var_munid, d
fayherriot poverty_gap_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(poverty_gap_var_munid) gamma nolog ///
initialvalue(`=r(p50)') sigmamethod(aryl)

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_povertygap_aryl.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyGap.doc) ///
title(FH Model with aryl estimation - Extreme Poverty Gap (2019/20)) fhc(\b) fs(11) dec(2) label append

restore




********************************************************************************
*Run acrsin transformed model 

*Note with arcsin no MSE and no CVFH and no CVdirect possible 

*4) Arcsin transformation 
gen poverty_gap_asin = asin(sqrt(poverty_gap_munid))
gen designeffect = poverty_gap_var_munid/simple_var_poverty_gap //Problem: Those with variance 0 will be missing (118)
gen effsample = samplesize/designeffect //131 missing
gen sigma2_e_arcsine = 1/(4*effsample) //131 missing

preserve

sum sigma2_e_arcsine, d
fayherriot poverty_gap_asin ${vivvars} ${headvars} ${hhvars} ${munvars} if sigma2_e_arcsine!=., variance(sigma2_e_arcsine) gamma nolog ///
initialvalue(`=r(p50)') arcsin

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
label var pobre_extremo_munid "Direct estimator"

tab eblupROR

save "$dataout/fh_povertygap_arcsin.dta", replace

asdoc sum pobre_extremo_munid eblupROR, save($tables\EBLUP_ExtremePovertyGap.doc) ///
title(FH Model with acrsin transformation) - Extreme Poverty Gap (2019/20)) fhc(\b) fs(11) dec(2) label append

restore



********************************************************************************
*Run Log-Transformed version of FH Model (predict for all out-of-sample municipalities


*5) Extreme poverty rate and log-transformation 
generate log_poverty_gap = log(poverty_gap_munid) //114 missing values generated
generate directlogvariance = poverty_gap_var_munid/(poverty_gap_munid*poverty_gap_munid) //114 missing values generated

preserve
sum directlogvariance, d
fayherriot log_poverty_gap ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(directlogvariance) gamma nolog logarithm ///
initialvalue(`=r(p50)') biascorrection(sm)

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for FH estimate
predict cvROR_direct, cvdirect //CV for direct estimate

label var eblupROR "EBLUP estimator"
label var mseROR "MSE EBLUP"
label var cvROR_FH "CV (FH Model)"
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_povertygap_log.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyGap.doc) ///
title(FH Log-Transformed Model - Extreme Poverty Gap (2019/20)) fhc(\b) fs(11) dec(1) label append

restore


*6) Extreme poverty rate with crude back transformation in log-transformed model 

preserve
sum directlogvariance, d
fayherriot log_poverty_gap ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(directlogvariance) gamma nolog logarithm ///
initialvalue(`=r(p50)') biascorrection(crude)

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for FH estimate
predict cvROR_direct, cvdirect //CV for direct estimate

label var eblupROR "EBLUP estimator"
label var mseROR "MSE EBLUP"
label var cvROR_FH "CV (FH Model)"
label var cvROR_direct "CV (Direct estimator)"
label var pobre_extremo_munid "Direct estimator"

save "$dataout/fh_povertygap_log.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertyGap.doc) ///
title(FH Log-Transformed Model with crude bias correction - Extreme Poverty Gap (2019/20)) fhc(\b) fs(11) dec(1) label append

restore








********************************************************************************
*C) Income of extreme poor
********************************************************************************

*NOTE: AMPL takes a very long time and ARCSIN does not work as asin square root only generates missing values! 

*Normal with aryl error estimation
preserve

sum ipcf_var_munid, d
fayherriot ipcf_munid ${vivvars} ${headvars} ${hhvars} ${munvars} if ipcf_var_munid!=0, variance(ipcf_var_munid) gamma nolog ///
sigmamethod(aryl) initialvalue(`=r(p50)')

predict eblup_income, eblup //obtain the EBLUPs
label var eblup_income "EBLUP estimator"
predict mse_income, mse //level of precision (MSE)
label var mse_income "MSE EBLUP"
predict cv_income_FH, cvfh //CV for the direct estimate
label var cv_income_FH "CV (FH Model)"
predict cv_income_direct, cvdirect //CV for FH estimate
label var cv_income_direct "CV (Direct estimator)"
label var ipcf_munid "Direct estimator (Income)"

tab eblup_income 

save "$dataout/fh_income_aryl.dta", replace

asdoc sum ipcf_munid cv_income_direct eblup_income cv_income_FH mse_income, save($tables\EBLUP_Income.doc) ///
title(FH Model with aryl estimation - Income of the extreme poor (2019/20)) fhc(\b) fs(11) dec(2) label replace

restore


*Normal with ampl estimation
*Does not work 

preserve

*sum ipcf_var_munid, d
fayherriot ipcf_munid ${vivvars} ${headvars} ${hhvars} ${munvars} if ipcf_var_munid!=0, variance(ipcf_var_munid) gamma nolog ///
sigmamethod(ampl) // initialvalue(`=r(p50)')

predict eblup_income, eblup //obtain the EBLUPs
label var eblup_income "EBLUP estimator"
predict mse_income, mse //level of precision (MSE)
label var mse_income "MSE EBLUP"
predict cv_income_FH, cvfh //CV for the direct estimate
label var cv_income_FH "CV (FH Model)"
predict cv_income_direct, cvdirect //CV for FH estimate
label var cv_income_direct "CV (Direct estimator)"
label var ipcf_munid "Direct estimator (Income)"

tab eblup_income 

save "$dataout/fh_income_ampl.dta", replace

asdoc sum ipcf_munid cv_income_direct eblup_income cv_income_FH mse_income, save($tables\EBLUP_Income.doc) ///
title(FH Model with ampl estimation - Income of the extreme poor (2019/20)) fhc(\b) fs(11) dec(2) label append

restore

*Arcsin transformation
*Does not work 


*Log transformed model
generate log_ipcf_munid = log(ipcf_munid) //126 missing values generated
generate directlogvariance_income = ipcf_var_munid/(ipcf_munid*ipcf_munid) //126 missing values generated

preserve
sum directlogvariance_income, d
fayherriot log_ipcf_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(directlogvariance_income) gamma nolog logarithm ///
initialvalue(`=r(p50)') biascorrection(sm)

predict eblup_income, eblup //obtain the EBLUPs
label var eblup_income "EBLUP estimator"
predict mse_income, mse //level of precision (MSE)
label var mse_income "MSE EBLUP"
predict cv_income_FH, cvfh //CV for the direct estimate
label var cv_income_FH "CV (FH Model)"
predict cv_income_direct, cvdirect //CV for FH estimate
label var cv_income_direct "CV (Direct estimator)"
label var ipcf_munid "Direct estimator (Income)"

tab eblup_income 

save "$dataout/fh_income_log.dta", replace

asdoc sum ipcf_munid cv_income_direct eblup_income cv_income_FH mse_income, save($tables\EBLUP_Income.doc) ///
title(FH Model with log transformation - Income of the extreme poor (2019/20)) fhc(\b) fs(11) dec(2) label append

restore




********************************************************************************
*B) POVERTY SEVERITY (EXTREME POVERTY)
********************************************************************************

preserve

sum poverty_severity_var_munid, d
fayherriot poverty_severity_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(poverty_severity_var_munid) gamma nolog ///
initialvalue(`=r(p50)') sigmamethod(ampl)

predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var poverty_severity_munid "Direct estimator"

tab eblupROR 

save "$dataout/fh_povertyseverity_ampl.dta", replace

asdoc sum poverty_severity_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_ExtremePovertySeverity.doc) ///
title(FH Model with ampl estimation - Extreme Poverty Severity (2019/20)) fhc(\b) fs(11) dec(2) label replace

restore







/*==============================================================================
Create final dataset for maps and geographic targeting program 
===============================================================================*/


********************************************************************************
*D) Merge extreme poverty rate and income of the extreme poor at municipality level 
********************************************************************************
*AMPL specification

import delimited "$population\pop_munid_worldpop_fromqgis.csv", clear
g munid_str = substr(adm2_pcode, 3,6)
g munid = real(munid_str)
save "$population\pop_munid_worldpop_fromqgis.dta", replace

use "$dataout/fh_income_ampl.dta", clear 
keep munid munid_str eblup_income
label var eblup_income "Mean income of the extreme poor (EBLUP)"

*Merge extreme Poverty Rate
merge 1:1 munid using "${dataout}/fh_pobreextremo_ampl.dta", keepusing(munid munid_str eblupROR)
drop _merge

rename eblupROR eblupROR_rate
label var eblupROR_rate "Extreme Poverty Rate (EBLUP)"

*Merge poverty gap 
merge 1:1 munid using "$dataout/fh_povrtygap_ampl.dta", keepusing(munid munid_str eblupROR)
drop _merge

rename eblupROR eblupROR_gap
label var eblupROR_gap "Extreme Poverty Gap (EBLUP)"

*Merge poverty severity
merge 1:1 munid using "$dataout/fh_povertyseverity_ampl", keepusing(munid munid_str eblupROR)
drop _merge

rename eblupROR eblupROR_severity
label var eblupROR_severity "Extreme Poverty Severity (EBLUP)"

*Save
drop munid_str
export delimited "$dataout/fh_povertyestimators_ampl.csv", replace

merge 1:1 munid using "$population\pop_munid_worldpop_fromqgis.dta", keepusing(munid pop_munid_)
drop if _merge==2 //from 3 entities not included in ENCOVI sample
drop _merge

save "$dataout/fh_finaldataset.dta", replace
export delimited "$dataout/fh_finaldataset.csv", replace

*Get municipality names

clear all
	
cd "F:\Working with Github\WB\VEN\Poverty Map\Fay_Herriot_estimation\ven_adm_2021_shp"

shp2dta using "ven_admbnda_adm2.shp", data(ven_mun) coordinates(ven_mun_coord) replace

use "ven_mun.dta", clear
gen munid_str = substr(ADM2_PCODE,3,.)
gen munid = real(munid_str)

keep ADM2_ES ADM2_REF munid

merge 1:1 munid using "$dataout/fh_finaldataset.dta"
drop _merge

*Save
save "$dataout/fh_finaldataset.dta", replace
export delimited "$dataout/fh_finaldataset.csv", replace






