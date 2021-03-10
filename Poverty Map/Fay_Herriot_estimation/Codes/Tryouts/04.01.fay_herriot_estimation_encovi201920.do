/*===============================================================================
*Author: Britta Rude
*Creation Date: Feb, 2021
*Topic: Fay-Harriot model for poverty map at the municipality level 
*===============================================================================
*Estimate Fay-Harriot model: 
Version 1: Only uses household data (ENCOVI 2019/20)
Version 2: Only uses census data (Census 2011)
Version 3: Uses census data at municipality level and household data at the regional level
*===============================================================================*/
*******************************************************************************

/*===============================================================================
Version 1: Only use household data (ENCOVI 2019/20)
===============================================================================*/

use "${dataout}/survey_hhlevel_fhmodel.dta", clear

*******************************************************************************
*Define variables for estimation

*First set from ENCOVI 2019/20
global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global hhvars miembros shchild shoccadult notsch
*Second set from census 2011 in povmap, here from encovi: all but pobrenbi11 and regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9
global munvars occrate unemprate shselfemp shentrepreneur shpublicsect shschatt




********************************************************************************
*Run simple OLS model for comparison reasons 
********************************************************************************

regress ipcf ${vivvars} ${headvars} ${hhvars} ${munvars} i.region_est1
asdoc reg ipcf ${vivvars} ${headvars} ${hhvars} ${munvars} i.region_est1, save($tables\OLS_Reg.doc) label ///
title(OLS Regression) fhc(\b) fs(11) dec(1) replace

predict predict_ipcf //Get prediced income from simple OLS regression
list ipcf predict_ipcf in 1/10

predict resid_ipcf, residuals //Get residuals 
list ipcf predict_ipcf resid_ipcf in 1/10

scatter resid_ipcf predict_ipcf, title("OLS Model for mean equ. household income p.c.") xtitle(Predicted income) ytitle(Residuals) ///
xlabel(,format(%12.0fc)) ylabel(,format(%12.0fc))
graph export "$figures/scatter_ols.png", replace 

kdensity resid_ipcf, normal title("Residual plot of OLS model") ylabel(,format(%12.2g) labsize(small)) //Check if residuals are normally distributed 	
graph export "$figures/density_ols.png", replace 
pnorm resid_ipcf 
graph export "$figures/pnorm_ols.png", replace 

drop predict_ipcf
predictnl predict_ipcf = predict(), var(predict_ipcf_var) //estimated variance for each predicted probability
list ipcf predict_ipcf resid_ipcf predict_ipcf_var in 1/10



********************************************************************************
*Run Fay-Herriot model: Simple Model
********************************************************************************

*gamma option to display summary statistics of shrinkage factors, nolog suppresses the iteration log of the optimization algorithm
*The variance of the random effects, σbu2, is estimated using the REML approach (the default).
*Together with the sampling error variances σe2d, it determines the shrinkage factor γbd.
*The shrinkage factor shows how direct estimates and model predictions are weighted when calculating the EBLUP. 
*The Shapiro–Wilk test for normality shows that neither normality of the realized residuals, ebd, nor of the random effects, ubd, is rejected (Model assumptions). 

*a) Income
fayherriot ipcf_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(ipcf_var_munid) gamma nolog 

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for the direct estimate
predict cvROR_direct, cvdirect //CV for FH estimate

*b) Extreme Poverty Rate
fayherriot pobre_extremo_munid ${vivvars} ${headvars} ${hhvars} ${munvars}, variance(pobre_extremo_var_munid) gamma nolog 


********************************************************************************
*Run Fay-Herriot model: Log-transformed Model
********************************************************************************

*a) Income
generate log_ipcf = log(ipcf_munid)
generate directlogvariance = ipcf_var_munid/(ipcf_munid*ipcf_munid)

*estimation method is MLE and the bias correction follows Slud and Maiti (2006)
*In this default setting, only estimates for the 357 in-sample districts are calculated.
fayherriot log_ipcf ${vivvars} ${headvars}, variance(directlogvariance) gamma nolog logarithm 

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for the direct estimate
predict cvROR_direct, cvdirect //CV for FH estimate

*biascorrection(crude) could be specified to obtain in- and out-of-sample estimates
fayherriot log_ipcf ${vivvars} ${headvars}, variance(directlogvariance) gamma nolog biascorrection(crude) logarithm 

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for the direct estimate
predict cvROR_direct, cvdirect //CV for FH estimate


*b) Extreme poverty rate
generate log_pobre_extremo = log(pobre_extremo_munid)
generate directlogvariance = pobre_extremo_var_munid/(pobre_extremo_munid*pobre_extremo_munid)

*estimation method is MLE and the bias correction follows Slud and Maiti (2006)
*In this default setting, only estimates for the 357 in-sample districts are calculated.
fayherriot log_pobre_extremo ${vivvars} ${headvars}, variance(directlogvariance) gamma nolog logarithm 

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for the direct estimate
predict cvROR_direct, cvdirect //CV for FH estimate

*biascorrection(crude) could be specified to obtain in- and out-of-sample estimates
fayherriot log_pobre_extremo ${vivvars} ${headvars}, variance(directlogvariance) gamma nolog biascorrection(crude) logarithm 

predict eblupROR, eblup //obtain the EBLUPs
predict mseROR, mse //level of precision (MSE)
predict cvROR_FH, cvfh //CV for the direct estimate
predict cvROR_direct, cvdirect //CV for FH estimate






















