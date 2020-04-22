/*===========================================================================
Puropose: Main .do that construct encovi database
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Malena Acuña

Dependencies:		The World Bank
Creation Date:		17th April, 2020
Modification Date:  
Output:			

Note: 
=============================================================================*/
********************************************************************************
clear all

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  1
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global dopath "C:\Users\wb563583\GitHub\VEN"
				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\DataEncovi\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global dopath "C:\Users\wb550905\Github\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
}		
********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

//set universal datapaths
global merged "$datapath\data_management\output\merged"
global cleaned "$datapath\data_management\output\cleaned"
global forinflation "$datapath\data_management\output\for inflation"

//set universal dopaths
global harmonization "$dopath\data_management\management\2. harmonization"
global inflado "$dopath\data_management\management\5. inflation"
global pathaux "$harmonization\aux_do"

//exchange rate input
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"



/*==============================================================================
 merging data
 ==============================================================================*/

*set path of data
global merging "$dopath\data_management\management\1. merging"
global input "$datapath\data_management\input\latest"
global output "$datapath\data_management\output\merged"

* run merge
run "$merging\__main__merge.do"

/*==============================================================================
Inflation
==============================================================================*/

// specific path to inflation estimation

global povinput "$datapath\poverty_measurement\input"
global inflationout "$datapath\data_management\input"


// calculates inflation
run "$inflado/__main__inflation.do"

// set global inflation input
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"

/*==============================================================================
hh-individual database
==============================================================================*/

//run ENCOVI harmonization
run "$harmonization\ENCOVI harmonization\VEN_ENCOVI_2019.do"

/*==============================================================================
imputation
==============================================================================*/

*Specific for imputation
global impdos "$dopath\data_management\management\4. income imputation\dofiles"
global forimp 	"$datapath\data_management\output\for imputation"
global pathoutexcel "$dopath\data_management\management\4. income imputation\output"

//run ENCOVI imputation
do "$impdos\MASTER 1-5. Run all imputation do's 2019.do"


/*==============================================================================
poverty estimation
==============================================================================*/
// set global inflation input
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
// set path of data
global povmeasure "$dopath\poverty_measurement\scripts"
global input "$datapath\poverty_measurement\input"
global output "$datapath\poverty_measurement\output"

//run poverty estimation
do "$povmeasure\__main__pobreza.do"

/*==============================================================================
creating separate dataset for variables to merge with SEDLAC version
==============================================================================*/

use "$output\ENCOVI_2019_postpobreza.dta", replace

	keep interview__key interview__id com ///
	iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ///
	ijubi_nm icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns ///
	rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp ///
	iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ///
	ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ///
	ila ila_m ilaho ilaho_m perila ijubi icap ///
	itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ///
	ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m ///
	itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m ///
	inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee  pipcf dipcf ///
	piea qiea ipc11 ppp11 ipcf_cpi11 ipcf_ppp11  pipcf dipcf  piea qiea ipc11 ppp11 ipcf_cpi11 ipcf_ppp11

save "$pathaux\Variables to merge with SEDLAC.dta", replace

/*==============================================================================
final variable selection
==============================================================================*/

//run cleaning of variables
run "$dopath\data_management\management\3. cleaning\final_variable_selection.do"

/*==============================================================================
labeling and saving final full databases
==============================================================================*/

//run spanish labeling
preserve
run "$pathaux\labels ENCOVI spanish.do"
save "$datapath\ENCOVI_2019_Spanish labels.dta", replace
restore

//run english labeling
run "$pathaux\labels ENCOVI english.do"
save "$datapath\ENCOVI_2019_English labels.dta", replace

/*==============================================================================
run sedlac and adding variables of income, prices and poverty
==============================================================================*/

run "$harmonization\SEDLAC harmonization\VEN_2019_ENFT_v01_M_v01_A_SEDLAC-01_MA y Trini.do"
merge 1:1 interview__key interview__id com using "$pathaux\Variables to merge with SEDLAC.dta"

/*==============================================================================
sedlac-format labeling and saving final full dataset
==============================================================================*/

//run spanish labeling
preserve
run "$pathaux\labels SEDLAC spanish.do"
save "$datapath\VEN_2019_ENFT_v01_M_v01_A_SEDLAC-01_Spanish labels.dta", replace
restore

//run english labeling
run "$pathaux\labels SEDLAC english.do"
save "$datapath\VEN_2019_ENFT_v01_M_v01_A_SEDLAC-01_English labels.dta", replace

clear all
