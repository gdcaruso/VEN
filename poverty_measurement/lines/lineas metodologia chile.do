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

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 3: Lautaro
		global lauta2   1
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\VEN"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned"
global mergeddatapath "$rootpath\data_management\output\merged"
global foodcomposition "$rootpath/poverty_measurement/input/Calories.dta"
global hhrequirementsdta  "$rootpath\poverty_measurement\input\hh_requirements.dta"

global intakes "$rootpath\poverty_measurement\input\nutritional_intake_and_req.dta"
global baskets "$rootpath\poverty_measurement\input\baskets_with_nutritional_intakes.dta"
global reprensentativebasket "$rootpath\poverty_measurement\input\representative_basket.dta"
global output "$rootpath\poverty_measurement\input"
*
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
use "$cleaneddatapath/ENCOVI_2019", replace
keep if interview_month==2
bys interview__id interview__key quest: egen miembros = max(com)

collapse (max)ipcf_max=ipcf (max) miembros (max) entidad, by (interview__key interview__id quest)


rename ipcf_max ipcf


// generate quantiles
sort ipcf
xtile quant = ipcf, nquantiles($binsize)

/*(************************************************************************************************************************************************* 
* Remove households eating outside
*************************************************************************************************************************************************)*/

//drop households that eat outside of their home

// idetify hh
tempfile comeafuera
preserve
use "$mergeddatapath/product-hh.dta", replace
keep if bien>199 & bien<299
keep interview__id interview__key quest
duplicates drop
save `comeafuera'
restore

// keep only hh that does not have lunch out of home
merge 1:1 interview__key interview__id quest using `comeafuera'
keep if _merge==1
drop _merge
sort ipcf


/*(************************************************************************************************************************************************* 
* 1: merge hh data with basket and caloric supply
*************************************************************************************************************************************************)*/

//gen baskets and caloric supply of each food
tempfile baskets
preserve
use "$cleaneddatapath\product_hh_homogeneous.dta", replace
rename bien COD_GASTO
merge m:1 COD_GASTO using "$foodcomposition"

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

keep interview__key interview__id quest ipcf miembros entidad quant bien cantidad_h Energia_kcal_m Proteina_m


// identify large outliars (testing)
gen cantidad_pc = cantidad_h/miembros
bysort bien: egen outliars = pctile(cantidad_pc), p(99) 
bysort bien: egen cantidad_media_pc = mean(cantidad_pc) if cantidad_pc<outliars 
replace cantidad_h = cantidad_media_pc*miembros if cantidad_pc>=outliars

// changes from weekly consumption to diary
replace cantidad_h = cantidad_h/7

// calculate caloric intake per capita for food and hh
rename (Energia_kcal_m Proteina_m) (cal prot)
gen cal_intake = (((cantidad_h*cal)/100))
gen prot_intake = (((cantidad_h*prot)/100))

keep bien cantidad_h cal_intake prot_intake interview__key interview__id quest ipcf miembros quant entidad cal prot
tempfile basketnoout
save `basketnoout'

collapse (sum) cal_intake prot_intake, by (interview__key interview__id quest ipcf miembros quant entidad)
rename (cal_intake prot_intake) (cal_intake_hh prot_intake_hh)
gen cal_intake_pc = cal_intake_hh/miembros


/*(************************************************************************************************************************************************* 
* 1: sets population of reference
*************************************************************************************************************************************************)*/



// plot cal intake average, median and requirement
preserve
collapse (median) median_cal = cal_intake_pc (mean) av_cal  = cal_intake_pc, by (quant)
gen cal_req = $calreq

twoway line av_cal quant if quant<99 ///
|| line median_cal quant if quant<99 ///
|| line cal_req quant if quant<99
restore


// generate a moving window of 20 percentiles and search the first pcentile where the mean caloric intake pc mathces with the requirements

// to save results
matrix R=J(81, 3, .)
matrix colnames R = mobquant av_cal median_cal

// loops over each group of consecutive 20 pctiles
forvalues i = 1(1)81{
preserve

keep if quant>=`i'
keep if quant<=`i'+19

egen av_cal = mean(cal_intake_pc)
egen median_cal = median(cal_intake_pc)

matrix R[`i',1] = `i' 
matrix R[`i',2] = av_cal[1]
matrix R[`i',3] = median_cal[1]
restore
}

// saves which has the av_cal greater that requirements
preserve
clear
svmat R,  names(col)
gen cal_req = $calreq

// plot where mobile quantiles match requirements
twoway line av_cal mobquant if mobquant<81 ///
|| line median_cal mobquant if mobquant<81 ///
|| line cal_req mobquant if mobquant<81

// select where mobile quant matchs requirements
keep if cal_req <= av_cal & mobquant!=1 // we exclude mobile quant=1 because there are 0 income hh that report sustancial consumption
local ref = mobquant[1]
display "`ref'"
restore

// population of reference
// all pcetiles from the saved one to saved+window size)
keep if quant>= `ref'
keep if quant<= `ref'+19

save "$output/reference_metochi.dta", replace

/*(************************************************************************************************************************************************* 
* 1: generates basket
*************************************************************************************************************************************************)*/

// chilenean methodolody does not provide details on how to summaries each basket from the population of reference into a representative basket. We choose then to follow (cuasi) Colombian approach.


// recover product dimension
merge 1:m interview__id interview__key quest using `basketnoout'
sort quant _merge
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

// creates food "popularity" across hh
bysort bien: egen popularity = count(cantidad_h) if cantidad_h>0 & cantidad_h!=. 
egen totalhh = max(newid)
replace popularity = popularity/totalhh
sort bien popularity
// this is just to complete observations
bysort bien (popularity): replace popularity = popularity[1]
replace popularity = 0 if popularity==.


// creates caloric share across hh
replace cal_intake = 0 if cal_intake ==.
egen tot_intake = total(cal_intake)
bysort bien: egen food_cal_intake = total(cal_intake)
gen share_intake = food_cal_intake/tot_intake


// filters of food
keep if share_intake>0.01 | popularity>0.3


// drop condimentos (no prices collected)
drop if bien == 79


/*(************************************************************************************************************************************************* 
* 1: quantity adjustment
*************************************************************************************************************************************************)*/


//generate caloric requirement
gen cal_req = $calreq

// generate population
bysort newid: gen first = 1 if _n == 1 
egen pop = total(miembros) if first==1
egen population = max(pop)
drop pop

// gen total intake after filters
egen tot_intake_after_filters = total(cal_intake)


//compare requirement to actual calories to adjust basket
gen tot_intake_pc = tot_intake_after_filters/population
gen ajuste_calorico = cal_req/tot_intake_pc
gen cantidad_ajustada = cantidad_h*ajuste_calorico


// output canasta ajustada
preserve 
collapse (sum) cantidad_h cantidad_ajustada (max) population (max) cal, by(bien) 
replace cantidad_ajustada = cantidad_ajustada/population
replace cantidad_h = cantidad_h/population
gen cal_intake = cantidad_ajustada*cal/100
gsort -cal_intake
save "$output/canastapercapita_metochi_sin_outliars.dta", replace
export excel using "$output/canastapercapita_metocchi_sin_outliars.xlsx", firstrow(var) replace


