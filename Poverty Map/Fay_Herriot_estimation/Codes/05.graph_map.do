/*=================================================================================
			  Graph Maps
Project:      Poverty Map Venezuela
Author:        Britta Rude 
---------------------------------------------------------------------------
Creation Date:      Feb, 2021
==================================================================================
Graph Map for extreme poverty rate and income of the extreme poor
===============================================================================*/

clear all
	
cd "F:\Working with Github\WB\VEN\Poverty Map\Fay_Herriot_estimation\ven_adm_2021_shp"

shp2dta using "ven_admbnda_adm2.shp", data(ven_mun) coordinates(ven_mun_coord) replace

use "ven_mun.dta", clear
gen munid_str = substr(ADM2_PCODE,3,.)
gen munid = real(munid_str)


********************************************************************************
*Activate respective dataset

*merge 1:1 munid using "${dataout}/povertymap.dta" //from fhsae estimation 2 cannot be matched, one from master and one from using 
*merge 1:1 munid using "$dataout/fh_pobreextremo_ampl.dta" //from fayherriot 12 cannot be matched (dropped entities)
*merge 1:1 munid using "$dataout/fh_povertyseverity_ampl.dta"
merge 1:1 munid using "$dataout/fh_povrtygap_ampl.dta"
*merge 1:1 munid using "$dataout/fh_finaldataset.dta" //from fayherriot 12 cannot be matched (dropped entities)

********************************************************************************
*Create map: POVERTY RATE

*replace EBLUP = EBLUP*100
*format EBLUP %9.2f

replace eblupROR = eblupROR*100
tab eblupROR  
replace eblupROR=100 if eblupROR>100 &!missing(eblupROR) //5 are larger than 100 % 
format eblupROR %9.2f

global mapgops legend(pos(8) ring(0) symxsize(3) keygap(2) symysize(3) size(small)) ndocolor(gs13) ndfcolor(gs13) legstyle(2)
spmap eblupROR using ven_mun_coord, id(_ID) fcolor(Blues) clnumber(9) legtitle("Extreme Poverty Rate (2019/20)") ${mapgops}
graph export "${figures}/povertymap_munid_201920_onlysampledentid.png", replace
	
replace eblupROR = eblupROR/100
drop _merge



********************************************************************************
*Create map: EXTREME POVERTY GAP

replace eblupROR = eblupROR*100
tab eblupROR  
replace eblupROR=0 if eblupROR<0 &!missing(eblupROR) //2 are smaller than 0 
format eblupROR %9.2f

global mapgops legend(pos(8) ring(0) symxsize(3) keygap(2) symysize(3) size(small)) ndocolor(gs13) ndfcolor(gs13) legstyle(2)
spmap eblupROR using ven_mun_coord, id(_ID) fcolor(Greens) clnumber(9) legtitle("Extreme Poverty Gap Index in % (2019/20)") ${mapgops}
graph export "${figures}/povertymap_munid_201920_onlysampledentid_povertygap.png", replace
	



********************************************************************************
*Create map: INCOME OF THE EXTREME POOR

format eblup_income %9.0f

global mapgops legend(pos(8) ring(0) symxsize(3) keygap(2) symysize(3) size(small)) ndocolor(gs13) ndfcolor(gs13) legstyle(2)
spmap eblup_income using ven_mun_coord, id(_ID) fcolor(Oranges) clnumber(9) legtitle("Income of the extreme poor (2019/20)") ${mapgops}
graph export "${figures}/povertymap_munid_201920_onlysampledentid_income.png", replace
	

********************************************************************************
*Create map: EXTREME POVERTY SEVERITY

replace eblupROR = eblupROR*100
tab eblupROR  
replace eblupROR=0 if eblupROR<0 &!missing(eblupROR) //3 are smaller than 0 
format eblupROR %9.2f


global mapgops legend(pos(8) ring(0) symxsize(3) keygap(2) symysize(3) size(small)) ndocolor(gs13) ndfcolor(gs13) legstyle(2)
spmap eblupROR using ven_mun_coord, id(_ID) fcolor(Reds) clnumber(9) legtitle("Extreme Poverty Severity Index in % (2019/20)") ${mapgops}
graph export "${figures}/povertymap_munid_201920_onlysampledentid_povertyseverity.png", replace
	







