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

// Define rootpath according to user

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta  1
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global dopath "C:\Users\wb563583\GitHub\VEN"
// 				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// 		}
// 	    if $lauta {
// 				global dopath "C:\Users\wb563365\GitHub\VEN"
// 				global datapath "C:\Users\wb563365\DataEncovi\"
// 		}
// 		if $trini   {
// 				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
// 		}
// 		if $male   {
// 				global dopath "C:\Users\wb550905\Github\VEN"
// 				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// }		
//
//
// //set universal datapaths
// global merged "$datapath\data_management\output\merged"
// global cleaned "$datapath\data_management\output\cleaned"
// global forinflation "$datapath\data_management\output\for inflation"
//
// //set universal dopath
// global harmonization "$dopath\data_management\management\2. harmonization"
// global inflado "$dopath\data_management\management\5. inflation"
//
// //Exchange rate inputs and auxiliaries
//
// global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
// global pathaux "$harmonization\aux_do"
//
//
// // set path of data
// global povmeasure "$dopath\poverty_measurement\scripts"
// global input "$datapath\poverty_measurement\input"
// global output "$datapath\poverty_measurement\output"
// global exrate "$datapath\data_management\input\exchenge_rate_price.dta"
//
// global orsh = 1.9
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
use "$cleaned/ENCOVI_2019_pre pobreza.dta" , replace



// gen ipc and ppp
cap drop ipc ipc11 ppp11 pobre
gen ipc = 2659537979000 //feb20 CENDAS food basket
gen ipc11 = 3558.84 //dic11 CENDAS food basket
gen ppp11 = 2.915005297 / 100000 //bol. fuertes/ dolarppp * bol.sob / bol.fuerte

gen cpiperiod = "2020m02"
drop pobre_extremo

// gen new lines
gen le_new = $costodiario * 30.42
gen lp_new = $orsh* le_new 

// gen international lines
gen lp_19 = 1.9 *30.42 
gen lp_32 = 3.2 *30.42  
gen lp_55 = 5.5 *30.42

gen lp_19_ready = lp_19 * ppp11 * ipc/ipc11
gen lp_32_ready = lp_32 * ppp11 * ipc/ipc11 
gen lp_55_ready = lp_55 * ppp11 * ipc/ipc11


// gen last national oficial lines corrected by inflation
gen le_ofi = 1600/5.2/100000 * ipc/ipc11 // 1600 is 2011 cost of official basket
gen lp_ofi = le_ofi*2 //2 is the last official orshansky of venezuela pov. estimates

// clasificates population using diff lines
gen extremo_new = ipcf<le_new
gen pobre_new = ipcf<lp_new
gen extremo_ofi = ipcf<le_ofi
gen pobre_ofi = ipcf<lp_ofi
gen pobre_19 = ipcf<lp_19
gen pobre_32 = ipcf<lp_32
gen pobre_55 = ipcf<lp_55


// just to tabulate, 0 is extreme poverty
gen pobreza_new = 2
replace pobreza_new = 1 if pobre_new == 1
replace pobreza_new = 0 if extremo_new == 1
gen pobreza_ofi = 2
replace pobreza_ofi = 1 if pobre_ofi == 1
replace pobreza_ofi = 0 if extremo_ofi == 1

// tabs
tab pobreza_new  [fw=pondera], mi
tab pobreza_ofi [fw=pondera], mi
tab pobre_19 [fw=pondera], mi
tab pobre_32 [fw=pondera], mi
tab pobre_55 [fw=pondera], mi

// lines and sorted ipcf plot
sort ipcf, stable
gen obs = sum(pondera) //running sum
egen max_obs = max(obs)
local maxobs = max_obs[1]*0.98

preserve
graph twoway line ipcf obs [fw=pondera]   if obs<`maxobs', lcolor("black") ///
|| line lp_19_ready obs  [fw=pondera], lcolor("blue") ///
|| line lp_32_ready obs [fw=pondera], lcolor("blue") ///
|| line lp_55_ready obs [fw=pondera], lcolor("blue") ///
|| line lp_new obs [fw=pondera], lcolor("red") ///
|| line le_new obs [fw=pondera], lcolor("red") ///
|| line le_ofi obs [fw=pondera], lcolor("green") ///
|| line lp_ofi obs [fw=pondera], lcolor("green") 

//sensitivity check

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

sum pob_base pob_??off ext_base ext_??off  [fw=pondera]

sum pob_base pob_??off ext_base ext_??off  [fw=pondera] if ipcf>0
restore

rename le_new lp_extrema
rename lp_new lp_moderada

gen pobre = ipcf<lp_moderada
gen pobre_extremo = ipcf<lp_extrema

//cleaning

drop lp_ofi le_ofi 
drop extremo_new extremo_ofi
drop pobre_19 pobre_32 pobre_55 pobre_new pobre_ofi pobreza_new pobreza_ofi


replace pobre =. if hogarsec ==1
replace pobre_extremo =. if hogarsec ==1


//save
save "$output\ENCOVI_2019_postpobreza.dta", replace
