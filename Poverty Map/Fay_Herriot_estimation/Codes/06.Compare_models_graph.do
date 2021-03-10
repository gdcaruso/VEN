/*=================================================================================
			  Graph Maps
Project:      Poverty Map Venezuela
Author:        Britta Rude 
---------------------------------------------------------------------------
Creation Date:      Feb, 2021
==================================================================================
Graph to compare different estimations
===============================================================================*/

*******************************************************************************
*Define variables for estimation

global directestimators ipcf_munid ipcf_var_munid pobre_extremo_munid pobre_extremo_var_munid poverty_gap_munid poverty_gap_var_munid ///
samplesize simple_mean_ipcf simple_mean_pobre_extremo simple_mean_poverty_gap simple_var_ipcf simple_var_pobre_extremo simple_var_poverty_gap
global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
*global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global headvars h_fem h_primaria
global hhvars miembros shchild shoccadult notsch
global munvars occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9

********************************************************************************
*Upload fh census data and merge to fh encovi data

use "${dataout}/census_hhlevel_munid_fhmodel.dta", clear

merge 1:1 munid using "${dataout}/survey_hhlevel_fhmodel.dta", keepusing(munid munid_str ${directestimators})
drop _merge
*Note: Several are not matched (3 from encovi are not in census, 125 from census are not in encovi)

/*==============================================================================
Activate this if only for entities that were estimated in ENCOVI 2019/20
===============================================================================*/

*drop entidades not sampled in encovi
drop if entid=="02" | entid=="25" | entid=="10" //12 municipalities

/*==============================================================================
Conduct different versions of model for differenet poverty indicators
===============================================================================*/

*Normal model 
sum pobre_extremo_var_munid, d
fayherriot pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(pobre_extremo_var_munid) gamma nolog ///
initialvalue(`=r(p50)')
 
predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"


*Normal model with ampl 
sum pobre_extremo_var_munid, d
fayherriot pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(pobre_extremo_var_munid) gamma nolog ///
initialvalue(`=r(p50)') sigmamethod(ampl)

predict eblupROR2, eblup //obtain the EBLUPs
label var eblupROR2 "EBLUP estimator (ampl)"


*Arcsin-transformed model 
gen pobre_extremo_asin = asin(sqrt(pobre_extremo_munid))
replace pobre_extremo_var_munid=0.0000001 if pobre_extremo_var_munid==0 //Correct for 0 variance due to comment below
gen designeffect = pobre_extremo_var_munid/simple_var_pobre_extremo //Problem: Those with variance 0 will be missing
gen effsample = samplesize/designeffect //157 missing
gen sigma2_e_arcsine = 1/(4*effsample) //157 missing

sum sigma2_e_arcsine, d
fayherriot pobre_extremo_asin ${vivvars} ${headvars} ${hhvars} ${munvars} if sigma2_e_arcsine!=., variance(sigma2_e_arcsine) gamma nolog ///
initialvalue(`=r(p50)') arcsin

predict eblupROR3, eblup //obtain the EBLUPs
label var eblupROR3 "EBLUP estimator (arcsin-transformed)"


*Log-transformed model 
generate log_pobre_extremo = log(pobre_extremo_munid) //126 missing values generated
generate directlogvariance = pobre_extremo_var_munid/(pobre_extremo_munid*pobre_extremo_munid) //126 missing values generated

sum directlogvariance, d
fayherriot log_pobre_extremo ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(directlogvariance) gamma nolog logarithm ///
initialvalue(`=r(p50)') biascorrection(sm)

predict eblupROR4, eblup //obtain the EBLUPs
label var eblupROR4 "EBLUP estimator (Log-transformed)"


/*==============================================================================
Export for graph 
===============================================================================*/

save "$dataout/compare_estimators_fh.dta", replace



/*==============================================================================
POVMAP for comparison 
===============================================================================*/

import excel "$povmap/Map_PreviousWork_June2020.xlsx", firstrow clear

bysort MunicipioUniqueID: egen newvar = wtmean(ExtremePovertyRateParroquia), weight(PopulationParroquia)
sum ExtremePovertyRateParroquia, d

collapse (mean) ExtremePovertyRateParroquia, by(MunicipioUniqueID)
rename MunicipioUniqueID munid


********************************************************************************
*Merge with FH estimates

merge 1:1 munid using "$dataout/compare_estimators_fh.dta" //22 not matched, 13 from master and 9 from using 
drop _merge

export delimited "$dataout/compare_estimators_fh_povmap.csv", replace



























