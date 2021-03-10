*===============================================================================
*Author: Britta Rude
*Creation Date: Feb, 2021
*Topic: Fay-Herriot model for poverty map at the municipality level 
/*===============================================================================
*Simulate different transfer schemes: Total budget = 15 Mio Feb-2020-US-$/1,102 billion Feb-
2020-bolivares
===============================================================================*/

*Upload household data
use "$rawdata\ENCOVI_2019_English labels.dta", clear


/*===============================================================================
Poverty program of three different programs 
===============================================================================*/


********************************************************************************
*Case A: Universal national transfer
*********************************************************************************

*A.1. 
*Per capita transfer = 15 Mio Feb-2020-US-$/5 Jahre/12 Monate/Total population (from WorldPop) = 

g ipcf_withtransfer = ipcf + 588 if !missing(ipcf)
g pobre_extremo_withtransfer = (ipcf_withtransfer<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer [fw=pondera] //79.22 

tab pobre_extremo [fw=pondera] //79.26

*A.2. 
*Per capit transfer of 6.6 2020 US$ (488,133 2020 bolivares)
drop ipcf_withtransfer
drop pobre_extremo_withtransfer

g ipcf_withtransfer = ipcf + 488133 if !missing(ipcf)
g pobre_extremo_withtransfer = (ipcf_withtransfer<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer [fw=pondera] //71.47 

tab pobre_extremo [fw=pondera] //79.26



********************************************************************************
*Case B: Geographic targeting program with 3 million US$ per year
********************************************************************************
*create unique municipio and parid id
gen str5 		temps		= "00000"

gen str2 		entidads	= substr(temps + string(entidad),-2,2)
gen str2 		municipios	= substr(temps + string(municipio),-2,2)
gen str2 		parroquias	= substr(temps + string(parroquia),-2,2)

gen str6		parid = entidads + municipios + parroquias
gen str4		munid = entidads + municipios

drop temps entidads municipios parroquias


*Plot observations per unique municipio id 
tab munid
codebook munid //210 unique values - problematic as targeted municipalities come from full-sample

g munid_str = munid
drop munid
g munid = real(munid_str)

*Randomly choose 7 municipalities with highest poverty rates

tab munid if munid==1515
tab munid if munid==501
tab munid if munid==802
tab munid if munid==1808
tab munid if munid==812
tab munid if munid==609
tab munid if munid==801

*Per capita transfer = 15 Mio Feb-2020-US-$/5 Jahre/12 Monate/Total population in eligible municipalities (from WorldPop)

g ipcf_withtransfer = ipcf + 19918 if !missing(ipcf)
g pobre_extremo_withtransfer = (ipcf_withtransfer<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer [fw=pondera] //78.97

tab pobre_extremo [fw=pondera] //79.26


********************************************************************************
*Case C: Geographic targeting program targeting all above extreme poverty rate
********************************************************************************

*Transform poverty gaps to stata file 
import excel "$results\PovertyGaps_SocialTransfers.xlsx", clear firstrow
drop if munid==.
save "$results\PovertyGaps_SocialTransfers.dta", replace


*Upload household data
use "$rawdata\ENCOVI_2019_English labels.dta", clear

*create unique municipio and parid id
gen str5 		temps		= "00000"

gen str2 		entidads	= substr(temps + string(entidad),-2,2)
gen str2 		municipios	= substr(temps + string(municipio),-2,2)
gen str2 		parroquias	= substr(temps + string(parroquia),-2,2)

gen str6		parid = entidads + municipios + parroquias
gen str4		munid = entidads + municipios

drop temps entidads municipios parroquias


*Plot observations per unique municipio id 
tab munid
codebook munid //210 unique values - problematic as targeted municipalities come from full-sample

g munid_str = munid
drop munid
g munid = real(munid_str)

*Merge with average poverty gaps
merge m:1 munid using "$results\PovertyGaps_SocialTransfers.dta" //113 cannot be matched at municipality level 
drop if _merge==2
drop _merge

*Distribute social transfer

g ipcf_withtransfer = ipcf
replace ipcf_withtransfer = ipcf + PovertyGapTransferpermunid if Potentialbeneficiary==1

g pobre_extremo_withtransfer = (ipcf_withtransfer<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer [fw=pondera] //36.9

tab pobre_extremo [fw=pondera] //79.26

 




















