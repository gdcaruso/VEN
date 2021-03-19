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
		01. Poverty program of three different programs 
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

 




/*===============================================================================
		02. Poverty impact of combined SP and Geo Targeting 
===============================================================================*/

use "$rawdata\ENCOVI_2019_English labels.dta", clear


********************************************************************************
*Case A: Universal transfer for all women with a bank account 
*********************************************************************************

***Women with bank account 
gen bank_account = (cuenta_aho==1 | cuenta_corr==1) if !missing(cuenta_aho, cuenta_corr)
tab bank_account [fw=pondera]
tab bank_account cuenta_aho, m
tab bank_account cuenta_corr, m
label var bank_account "Bank account holder"

tab hombre [fw=pondera] if bank_account==1 & edad>17

***Bank account holders and poverty
tab pobre_extremo hombre [fw=pondera] if bank_account==1 & edad>17, column
tab pobre_extremo hombre [fw=pondera] if bank_account==0 & edad>17, column


*A.1. 
*Per capita transfer = 20 US$ to all female bank account holders = 1,470,120 2020-bolivares

g ipcf_withtranfer = ipcf
replace ipcf_withtranfer = ipcf_withtranfer + 1470120 if !missing(ipcf) & hombre==0 & bank_account==1 & edad>17
g pobre_extremo_withtransfer = (ipcf_withtranfer<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer [fw=pondera] //65.70  

tab pobre_extremo [fw=pondera] //79.26


/*A.2. 
Budget: 88 million 2020-US$/month (see below) distributed among all women with bank account older than 17 years old (9.1 million)
*P.c. transfer = 9.7 2020 US$ or 713,075.5 2020 bolivares*/

g ipcf_withtransfer2 = ipcf
replace ipcf_withtransfer2 = ipcf_withtransfer2 + 713075.5 if !missing(ipcf) & hombre==0 & bank_account==1 & edad>17
g pobre_extremo_withtransfer2 = (ipcf_withtransfer2<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer2 [fw=pondera] //74.9

tab pobre_extremo [fw=pondera] //79.26

/*A.3: Per capita transfer of 17 2020-US$ or 1,246,130.3 2020-bolivares */

g ipcf_withtransfer3 = ipcf
replace ipcf_withtransfer3 = ipcf_withtransfer3 + 1246130.3 if !missing(ipcf) & hombre==0 & bank_account==1 & edad>17
g pobre_extremo_withtransfer3 = (ipcf_withtransfer3<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer3 [fw=pondera] //

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


*Women with bank account 
gen bank_account = (cuenta_aho==1 | cuenta_corr==1) if !missing(cuenta_aho, cuenta_corr)
tab bank_account [fw=pondera]
tab bank_account cuenta_aho, m
tab bank_account cuenta_corr, m
label var bank_account "Bank account holder"


*Create variables needed for estimation

***Number of female bank account holders at the municipality level 
gen personid=_n

tempfile temptest 
save `temptest', emptyok

preserve
collapse (count) personid [fw=pondera] if hombre==0 & bank_account==1 & edad>17, by(munid)
list in 1/10
rename personid pop_munid
save `temptest', replace
restore 

merge m:1 munid using `temptest' //33,086  (all) matched
drop _merge


*Distribute social transfer (20 2020-US$)

replace Potentialbeneficiary=1 if ExtremePovertyRateEBLUP>0.66

g ipcf_withtransfer = ipcf 
replace ipcf_withtransfer = ipcf_withtransfer + 1470120 if Potentialbeneficiary==1 & hombre==0 & bank_account==1 & edad>17

g pobre_extremo_withtransfer = (ipcf_withtransfer<2240342) if !missing(ipcf)
tab pobre_extremo_withtransfer [fw=pondera] //67.36

tab pobre_extremo [fw=pondera] //79.26


*Efficiency
tab pobre_extremo hombre [fw=pondera] if Potentialbeneficiary==1 & bank_account==1 & edad>17, column
















