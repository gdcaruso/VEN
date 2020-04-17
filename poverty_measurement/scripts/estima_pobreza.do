/*===========================================================================
Puropose: TThis scrip takes basket value, orshansky and ENCOVI ipcf and estimates
poverty
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		31th march, 2020
Modification Date:  
Output:			dta with baskets values and indexes

Note: 
=============================================================================*/
********************************************************************************

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta   1
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath "C:\Users\wb563583\GitHub\VEN"
// 		}
// 	    if $lauta {
// 		global dopath "C:\Users\wb563365\GitHub\VEN"
// 		global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// 		}
// 		if $trini   {
// 				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
// 		}
// 		if $male   {
// 				global rootpath "C:\Users\wb550905\GitHub\VEN"
// 		}
//
// //
// // set path of data
// global encovifilename "ENCOVI_2019.dta"
// global cleaned "$datapath\data_management\output\cleaned"
// global merged "$datapath\data_management\output\merged"
// global input "$datapath\poverty_measurement\input"
// global output "$datapath\poverty_measurement\output"
// global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off



/*(***************************************************************************** 
* 1: generate lines
*******************************************************************************/
// import basket costs
use "$output/costo_canasta_diaria.dta", replace
di "%%%%%%%%%%%%%%%%%%"
di $orsh

// calculate total daily cost
egen costo_canasta = total(valor)
global costodiario = costo_canasta[1]
di $costodiario
// import harmonized hh-individual data with incomes
use "$cleaned/$encovifilename" , replace

// gen new lines
gen le_new = $costodiario * 30.42
gen lp_new = $orsh* le_new 

// gen international lines
gen lp19 = 1.9 *30.42 * 2.92/100000 * 747304733.8
gen lp32 = 3.2 *30.42 * 2.92/100000  * 747304733.8
gen lp55 = 5.5 *30.42 * 2.92/100000  * 747304733.8

// gen last national oficial lines corrected by inflation
gen le_ofi = 1600/5.2/100000* 747304733.8
gen lp_ofi = le_ofi*2 //2 is the official orshansky of venezuela pov. estimates

// clasificates population using diff lines
gen extremo_new = ipcf<le_new
gen pobre_new = ipcf<lp_new
gen extremo_ofi = ipcf<le_ofi
gen pobre_ofi = ipcf<lp_ofi
gen pobre_19 = ipcf<lp19
gen pobre_32 = ipcf<lp32
gen pobre_55 = ipcf<lp55


// just to tabulate, 0 is extreme poverty
gen pobreza_new = 2
replace pobreza_new = 1 if pobre_new == 1
replace pobreza_new = 0 if extremo_new == 1
gen pobreza_ofi = 2
replace pobreza_ofi = 1 if pobre_ofi == 1
replace pobreza_ofi = 0 if extremo_ofi == 1

// tabs
tab pobreza_new, mi
tab pobreza_ofi, mi
tab pobre_19, mi
tab pobre_32, mi
tab pobre_55, mi

// lines and sorted ipcf plot
sort ipcf
gen obs = _n
preserve
graph twoway line ipcf obs  if obs<30000, lcolor("black") ///
|| line lp19 obs, lcolor("blue") ///
|| line lp32 obs, lcolor("blue") ///
|| line lp55 obs, lcolor("blue") ///
|| line lp_new obs, lcolor("red") ///
|| line le_new obs, lcolor("red") ///
|| line le_ofi obs, lcolor("green") ///
|| line lp_ofi obs, lcolor("green") 

//generate proper output!! TODO

gen pob_base = ipcf<lp_new
gen ext_base = ipcf<le_new

gen ext_10off = ipcf<le_new*0.9
gen ext_20off = ipcf<le_new*0.8
gen ext_50off = ipcf<le_new*0.5
gen ext_75off = ipcf<le_new*0.25
gen pob_10off = ipcf<lp_new*0.9
gen pob_20off = ipcf<lp_new*0.8
gen pob_50off = ipcf<lp_new*0.5
gen pob_75off = ipcf<lp_new*0.25

sum pob_base pob_??off ext_base ext_??off

sum pob_base pob_??off ext_base ext_??off if ipcf>0

rename le_new lp_extrema
rename lp_new lp_moderada

drop ipc ipc11 ppp11 pobre
// gen ipc = 2659537979000 
// gen ipc11 = 3558.84
// gen ppp11 = 2.915005297 / 100000 //bol. fuertes/ dolarppp * bol.sob / bol.fuerte
gen pobre = ipcf<lp_moderada


// * IPC del mes base
// gen ipc = 2661830760000 // Updated with Canasta Alimentaria CENDAS
// gen cpiperiod = "2020m02"
//
// from Malena Acuna (internal) to everyone:
// replace ppp11 =    2.92 / 100000    if  pais=="VEN" // Fuente Banco Mundial expresados en bolívares soberanos
//
// from Malena Acuna (internal) to everyone:
// gen ipc11 =.
// replace ipc11 = 3321.98        if  pais=="VEN" // Canasta alimentaria CENDAS Octubre 2011 (cuando en general se hacían las ENCOVIs anteriores) vs. Febrero 2020 (el momento en el que tenemos más muestra)


drop  lp19 lp32 lp55 lp_ofi le_ofi extremo_new extremo_ofi pobre_19 pobre_32 pobre_55 pobre_new pobre_ofi pobreza_new pobreza_ofi ext_10off ext_20off ext_50off ext_75off pob_??off
save "$output/VEN_2019_ENCOVI_v01_M_v01_A_FULL-03_all.dta", replace