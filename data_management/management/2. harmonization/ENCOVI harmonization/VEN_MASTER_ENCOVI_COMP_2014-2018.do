/*===========================================================================
Country name:	Venezuela
Year:			2014-2018
Survey:			ENCOVI
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		January, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   1
		
			
		if $juli {
				global rootpath "C:\Users\WB563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global pathdo "C:\Users\WB563583\Github\VEN\data_management\management\2. harmonization\ENCOVI harmonization"
		}
	    if $lauta {
				
		}
		if $trini   {
		
		}
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
               	global pathdo "C:\Users\wb550905\Github\VEN\data_management\management\2. harmonization\ENCOVI harmonization"
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global incomevars "$rootpath\FINAL_SEDLAC_DATA_2014_2019"
global pathout "$rootpath\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018"

***************************************************************************************************************

foreach y in 2014 2015 2016 2017 2018 {

*** Year `y'

do "$pathdo\VEN_ENCOVI_COMP_`y'"

use "$incomevars\VEN_`y'_ENCOVI_SEDLAC-01_English labels.dta"

	keep id com ///
	pobreza_enc pobreza_extrema_enc iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ///
	ijubi_nm icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns ///
	rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp ///
	iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ///
	ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ///
	ila ila_m ilaho ilaho_m perila ijubi icap ///
	itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ///
	ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m ///
	itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m ///
	inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee  ///
	pipcf dipcf piea qiea ipc ipc11 ppp11 ipcf_cpi11 ipcf_ppp11

merge 1:1 id com using "$pathout\ENCOVI_`y'_COMP.dta"

save "$pathout\ENCOVI_`y'_COMP.dta", replace

clear all
}


