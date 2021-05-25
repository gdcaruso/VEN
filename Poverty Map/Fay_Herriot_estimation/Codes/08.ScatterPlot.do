/*===============================================================================
*Author: Britta Rude
*Creation Date: Feb, 2021
*Topic: Fay-Herriot model for poverty map at the municipality level 
*===============================================================================
*Estimate Fay-Harriot model: 
Only uses census data (Census 2011) as explanatory variables

*===============================================================================*/

***Scatter Plot Extreme Poverty 
use "$dataout/fh_pobreextremo_ampl.dta", clear

twoway scatter pobre_extremo_munid eblupROR, title("Small-Area Estimates versus direct estimates of extreme poverty", size(medsmall)) 
graph export "$figures/Scatter_EBLUP_Direct.png", replace

***Scatter Plot Extreme Poverty Gap
use "$dataout/fh_povrtygap_ampl.dta", clear

twoway scatter pobre_extremo_munid eblupROR, title("Small-Area Estimates versus direct estimates of extreme poverty gaps", size(medsmall)) 
graph export "$figures/Scatter_EBLUP_Direct_PovertyGap.png", replace

***Scatter Plot Income of the extreme poor
use "$dataout/fh_income_ampl.dta", clear

twoway scatter pobre_extremo_munid eblupROR, title("Small-Area Estimates versus direct estimates of extreme poverty gaps", size(medsmall)) 
graph export "$figures/Scatter_EBLUP_Direct_PovertyGap.png", replace














