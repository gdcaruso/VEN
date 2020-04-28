/*===========================================================================
Puropose: This script tries to replicate Chilenian methodolody of pov estimation 
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		21th March, 2020
Modification Date:  
Output:			hh that belong to the reference population
				food basket for that population

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
********************************************************************************


/*==============================================================================
0: Program set up
==============================================================================*/

version 14
drop _all
set more off

global binsize = 100
global calreq = 2000

/*(************************************************************************************************************************************************* 
* 1: sorts hh
*************************************************************************************************************************************************)*/


// merges with income data

use "$cleaned/ENCOVI_2019_pre pobreza.dta", replace
keep if interview_month==2 // keep feb observations
keep if relacion_en == 1 //keep households
cap drop if hogarsec == 1


// generate quantiles
include "$pathaux/cuantiles.do"
set seed 4859276
sort ipcf interview__key, stable
cuantiles ipcf [fw=pondera_hh], n($binsize) gen(quant)
tab quant

/*(************************************************************************************************************************************************* 
* Remove households eating outside
*************************************************************************************************************************************************)*/

//drop households that eat outside of their home

// idetify hh
tempfile comeafuera
preserve
use "$merged/product-hh.dta", replace
keep if bien>199 & bien<299
keep interview__id interview__key quest
duplicates drop
save `comeafuera'
restore


// keep only hh that does not have lunch out of home
cap drop _merge
merge 1:1 interview__key interview__id quest using `comeafuera'
keep if _merge==1
drop _merge
sort ipcf, stable


/*(************************************************************************************************************************************************* 
* 1: merge hh data with basket and caloric supply
*************************************************************************************************************************************************)*/

//gen baskets and caloric supply of each food
tempfile baskets
preserve
use "$merged\product_hh_homogeneous.dta", replace
rename bien COD_GASTO
merge m:1 COD_GASTO using "$input/Calories.dta"

keep if _merge==3
drop _merge
rename COD_GASTO bien

compress
save `baskets'
restore

// merge with hh data
merge 1:m interview__id interview__key quest using `baskets'
keep if _merge == 3
drop _merge

keep interview__key interview__id quest ipcf miembros entidad quant bien cantidad_h Energia_kcal_m Proteina_m pondera_hh


// identify very large outliars (testing, now we replace outliars with the mean)
gen cantidad_pc = cantidad_h/miembros

bysort bien: egen outliars = pctile(cantidad_pc), p(99) 
bysort bien: egen cantidad_media_pc = mean(cantidad_pc) if cantidad_pc<outliars 
replace cantidad_h = cantidad_media_pc*miembros if cantidad_pc>=outliars

// changes from weekly consumption to diary
replace cantidad_h = cantidad_h/7

// calculate caloric intake per food
rename (Energia_kcal_m Proteina_m) (cal prot)
gen cal_int = (((cantidad_h*cal)/100))
gen prot_int = (((cantidad_h*prot)/100))


keep bien cantidad_h cal_int prot_int interview__key interview__id quest ipcf miembros quant entidad cal prot pondera_hh

tempfile basketnoout
save `basketnoout'

// calculate caloric intake per hh
bys interview__key interview__id quest ipcf miembros quant: egen cal_intake = total(cal_int)

bys interview__key interview__id quest ipcf miembros quant: egen prot_intake = total(prot_int)

keep interview__key interview__id quest ipcf miembros quant cal_intake prot_intake pondera_hh
duplicates drop

rename (cal_intake prot_intake) (cal_intake_hh prot_intake_hh)

// calculate caloric intake per capita
gen cal_intake_pc = cal_intake_hh/miembros
gen overcal = cal_intake_pc>$calreq

preserve
keep overcal cal_intake_pc interview__id interview__key quest
save "$output/pob_cal_intake.dta", replace
restore

/*(************************************************************************************************************************************************* 
* 1: sets population of reference
*************************************************************************************************************************************************)*/



// // plot cal intake average, median and requirement
// preserve
// gen median_cal =.
// gen av_cal =.
// levelsof quant, local(q_levels)
// quietly foreach i in `q_levels' { 
//    summarize cal_intake_pc [fw=pondera_hh] if quant == `i', detail 
//    replace median_cal = r(p50) if quant == `i'
//    replace av_cal = r(mean) if quant == `i'
// } 
//
//
// keep quant median_cal av_cal ipcf
// gen cal_req = $calreq
// sort ipcf
//
// twoway line av_cal quant if quant<99 ///
// || line median_cal quant if quant<99 ///
// || line cal_req quant if quant<99
// restore


// generate a moving window of 20 percentiles and search the first pcentile where the mean caloric intake pc mathces with the requirements

// to save results
matrix R=J(81, 3, .)
matrix colnames R = mobquant av_cal median_cal
// loops over each group of consecutive 20 pctiles
qui{
forvalues i = 1(1)81{
preserve

keep if quant>=`i'
keep if quant<=`i'+19

qui summarize cal_intake_pc [fw=pondera_hh], detail
gen av_cal = r(mean) //creates weigted average
gen median_cal = r(p50) //creates weigted mean


matrix R[`i',1] = `i' 
matrix R[`i',2] = av_cal[1]
matrix R[`i',3] = median_cal[1]
restore
}
}
// saves which has the av_cal greater that requirements
preserve
clear
svmat R,  names(col)
gen cal_req = $calreq

//plot where mobile quantiles match requirements
twoway line av_cal mobquant if mobquant<81 ///
|| line median_cal mobquant if mobquant<81 ///
|| line cal_req mobquant if mobquant<81


// select where mobile quant matchs requirements
keep if cal_req <= median_cal & mobquant!=1 // we exclude mobile quant=1 because there are 0 income hh that report sustancial consumption
local ref = mobquant[1]


display "`ref'"
restore



// population of reference
// all pcetiles from the saved one to saved+window size)
keep if quant>= `ref'
keep if quant<= `ref'+19

save "$output/pob_referencia.dta", replace

/*(************************************************************************************************************************************************* 
* 1: generates representative basket from many baskets
*************************************************************************************************************************************************)*/

keep interview__id interview__key quest miembros pondera_hh ipcf quant 

// recover product dimension
merge 1:m interview__id interview__key quest using `basketnoout'
sort quant _merge, stable
keep if _merge==3 
drop _merge



// first we need to complete the panel, replacing with 0 in any food undeclared
// complete with 0s in quantities where goods have no obs
egen newid = group(interview__id interview__key quest)
tsset newid bien
tsfill, full
replace cantidad_h=0 if cantidad_h==.
tsset, clear


// to replace missing in string variables 
bysort newid (interview__key): replace interview__key=interview__key[_N]
bysort newid (interview__id): replace interview__id=interview__id[_N]

// to replace missing in numeric variables 
bysort newid (quest): replace quest=quest[1]
bysort newid (quant): replace quant=quant[1]
bysort newid (miembros): replace miembros=miembros[1]
bysort newid (ipcf): replace ipcf=ipcf[1]
bysort newid (entidad): replace entidad=entidad[1]
bysort newid (pondera_hh): replace pondera_hh=pondera_hh[1]

//generate caloric requirement
gen cal_req = $calreq

// generate population
gsort interview__id interview__key quest -cantidad_h
by interview__id interview__key quest: gen first = 1 if _n==1 //first is to pick one observation per hh where are positive quantities
egen totalhh =  total(pondera_hh) if first ==1
bysort newid (totalhh): replace totalhh=totalhh[1] // to complete obs

//first filter, popularity of food
// creates food "popularity" across hh using weights
bysort bien: egen hh_consumer = total(pondera_hh) if cantidad_h>0 & cantidad_h!=. 
gen popularity = hh_consumer/totalhh
sort bien popularity, stable
bysort bien (popularity): replace popularity = popularity[1] // this is just to complete observations
replace popularity = 0 if popularity==.


// creates caloric intake share of each food in total consumption
bys interview__id interview__key quest: egen cal_int_hh = total(cal_int) // calories per hh not weighted
gen tot_intake_temp = cal_int_hh*pondera_hh if first ==1 //temporal
egen tot_intake = total(tot_intake_temp) if first ==1 // total calories of weighted hh
drop tot_intake_temp
bysort newid (tot_intake): replace tot_intake=tot_intake[1] //complete observations of total intake

gen food_intake_temp = cal_int*pondera_hh //calories of food weighted
bysort bien: egen food_cal_intake = total(food_intake_temp)
gen share_intake = food_cal_intake/tot_intake

// filters of food
keep if share_intake>0.01 | popularity>0.3

// drop condimentos (no prices collected)
drop if bien == 79
// drop alcohol and tobacco
keep if bien < 88


/*(************************************************************************************************************************************************* 
* 1: quantity adjustment to match caloric requirements
*************************************************************************************************************************************************)*/


// output: canasta ajustada

// renews first to cach all hh
drop first
sort interview__id interview__key quest, stable
by interview__id interview__key quest: gen first = 1 if _n==1

// new population after filters
egen population = total(pondera_hh) if first == 1
sort population, stable // to complete obs
replace population=population[1] // to complete obs

// generate quatities per capita
gen cantidad_h_temp = cantidad_h/miembros*pondera_hh 
bys bien: egen cantidad_h_tot = total(cantidad_h_temp) 


//drop duplicates
keep bien cantidad_h_tot population cal cal_req
drop if cal ==. //remove duplicates
duplicates drop  //remove duplicates

//generate quantities per capita without adj
gen cantidad_h = cantidad_h_tot/population

//generate intake pre adjustement
gen cal_intake_pre_adj = cantidad_h*cal/100


// generate adjustement on quantities
egen total_cal_pre_adj = total(cal_intake_pre_adj)
gen ajuste_calorico = cal_req/total_cal_pre_adj

gen cantidad_ajustada = cantidad_h * ajuste_calorico
gen cal_intake = cantidad_ajustada*cal/100

gsort -cal_intake

drop cantidad_h_tot

save "$output/canasta_diaria.dta", replace
export excel using "$output/canasta_diaria.xlsx", firstrow(var) replace


