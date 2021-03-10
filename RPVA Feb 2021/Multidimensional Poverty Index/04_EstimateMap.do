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


*******************************************************************************
*Define variables for estimation

*global directestimators multi_poor_munid multi_poor_var_munid
global directestimators multi_poor_wb_munid multi_poor_wb_var_munid

global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
*global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global headvars h_fem h_primaria
global hhvars miembros shchild shoccadult notsch
global munvars occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9


********************************************************************************
*Upload fh census data and merge to fh encovi data

use "${census}\census_hhlevel_munid_fhmodel.dta", clear


********************************************************************************
*Choose respective dataset

*For WB MPI
merge 1:1 munid using "${dataout}/survey_hhlevel_fhmodel_multipoor_wb.dta", keepusing(munid munid_str ${directestimators})
drop _merge

*For Oxfort MPI
merge 1:1 munid using "${dataout}/survey_hhlevel_fhmodel_multipoor.dta", keepusing(munid munid_str ${directestimators})
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

***Simple model 

preserve

fayherriot multi_poor_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(multi_poor_var_munid) gamma nolog ///
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

save "$dataout/fh_multipoor.dta", replace

asdoc sum pobre_extremo_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_Multipoor.doc) ///
title(FH Model - Multi Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label replace

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_multipoor.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_multipoor.png", replace 

restore


***Simple model with ampl  

preserve

fayherriot multi_poor_wb_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(multi_poor_wb_var_munid) gamma nolog ///
sigmamethod(ampl) //initialvalue(`=r(p50)')
 
predict eblupROR, eblup //obtain the EBLUPs
label var eblupROR "EBLUP estimator"
predict mseROR, mse //level of precision (MSE)
label var mseROR "MSE EBLUP"
predict cvROR_FH, cvfh //CV for the direct estimate
label var cvROR_FH "CV (FH Model)"
predict cvROR_direct, cvdirect //CV for FH estimate
label var cvROR_direct "CV (Direct estimator)"
label var multi_poor_wb_munid "Direct estimator"

save "$dataout/fh_multipoor_ampl_wb.dta", replace

*asdoc sum multi_poor_munid cvROR_direct eblupROR cvROR_FH mseROR, save($tables\EBLUP_Multipoor.doc) ///
*title(FH Model - Multi Poverty Rate (2019/20)) fhc(\b) fs(11) dec(2) label replace

tab eblupROR //5 are below 0 

predict residuals, ehat
predict random_effects, uhat

kdensity residuals, normal
graph export "$figures/density_residuals_multipoor_ampl.png", replace 
kdensity random_effects, normal
graph export "$figures/density_randomeffects_multipoor_ampl.png", replace 

restore















