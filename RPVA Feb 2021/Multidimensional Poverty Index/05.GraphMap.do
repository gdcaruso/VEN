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

clear all
	
cd "F:\Working with Github\WB\VEN\Poverty Map\Fay_Herriot_estimation\ven_adm_2021_shp"

shp2dta using "ven_admbnda_adm2.shp", data(ven_mun) coordinates(ven_mun_coord) replace

use "ven_mun.dta", clear
gen munid_str = substr(ADM2_PCODE,3,.)
gen munid = real(munid_str)

********************************************************************************
*Activate respective dataset

merge 1:1 munid using "$dataout/fh_multipoor_ampl_wb.dta" //12 cannot be matched from dropped entidades 
*merge 1:1 munid using "$dataout/fh_multipoor_ampl.dta" //12 cannot be matched from dropped entidades 


********************************************************************************
*Create map: POVERTY RATE

tab eblupROR  
replace eblupROR=100 if eblupROR>100 //0 are larger than 100 %
*replace eblupROR=2/3 if eblupROR==100 //1 is 100 and irrealistic
replace eblupROR=0 if eblupROR<0 //4 are smaller than 0
replace eblupROR=. if _merge==1 //12 municipalities

format eblupROR %9.2f

global mapgops legend(pos(8) ring(0) symxsize(3) keygap(2) symysize(3) size(small)) ndocolor(gs13) ndfcolor(gs13) legstyle(2)
spmap eblupROR using ven_mun_coord, id(_ID) fcolor(Blues) clnumber(9) legtitle("Multidimensional Poverty Rate (2019/20)") ${mapgops}
graph export "${figures}/povertymap_munid_201920_onlysampledentid_multipoor_wb.png", replace
	
drop _merge
























