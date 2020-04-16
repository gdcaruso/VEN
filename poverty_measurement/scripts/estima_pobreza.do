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

// // Define rootpath according to user
//
// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
//		
// 		* User 3: Lautaro
// 		global lauta   1
//		
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath ""
// 		}
//
// 	    if $lauta {
// 				global rootpath "C:\Users\wb563365\GitHub\VEN"
// 		}
//
// // set raw data path
// global cleaned "$rootpath\data_management\output\cleaned"
// global merged "$rootpath\data_management\output\merged"
// global input  "$rootpath\poverty_measurement\input"
// global output "$rootpath\poverty_measurement\output"
//
// global orsh=1.7

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
use "$cleaned\ENCOVI_2019.dta" , replace

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
