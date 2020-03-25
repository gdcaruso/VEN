/*===========================================================================
Puropose: This script tries to replicate Colombian methodolody of pov estimation 
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		21th Feb, 2020
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
				global rootpath "C:\Users\wb563365\OneDrive - WBG\Documents\GitHub\VEN"
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


/*(************************************************************************************************************************************************* 
* 1: sets population of reference
*************************************************************************************************************************************************)*/

// merges with income data
use "$cleaneddatapath/base_out_nesstar_cedlas_2019.dta", replace
keep if interview_month==2
collapse (mean)ipcf_mean=ipcf (max)ipcf_max=ipcf (max) miembros (max) entidad, by (interview__key interview__id quest)

rename ipcf_max ipcf
drop ipcf_mean


// keeps quantiles in poverty prior surrounding
xtile quant = ipcf, nquantiles(100)
global pprior = 50
keep if inrange(quant, $pprior -15, $pprior +15)


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


/*(************************************************************************************************************************************************* 
* 1: merge with basket and caloric supply
*************************************************************************************************************************************************)*/
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
/*(************************************************************************************************************************************************* 
* 1: creates representative baskets
*************************************************************************************************************************************************)*/
	
// merges with baskets only in the population of reference
merge 1:m interview__key interview__id quest using `baskets'
keep if _merge==3
drop _merge

keep interview__key interview__id quest ipcf miembros entidad quant bien cantidad_h Energia_kcal_m Proteina_m


// identify large outliars (testing)
gen cantidad_pc = cantidad_h/miembros
bysort bien: egen outliars = pctile(cantidad_pc), p(99) 
bysort bien: egen cantidad_media_pc = mean(cantidad_pc) if cantidad_pc<outliars 
replace cantidad_h = cantidad_media_pc*miembros if cantidad_pc>=outliars



// complete with 0s in quantities where goods have no obs
egen newid = group(interview__id interview__key quest)
tsset newid bien
tsfill, full
replace cantidad_h=0 if cantidad_h==.
tsset, clear

// renaming and fixing variables to complete panel
egen prot = max(Proteina_m), by(bien)
egen cal = max(Energia_kcal_m), by(bien)
replace prot = prot/100
replace cal = cal/100
drop Proteina_m
drop Energia_kcal_m

replace cantidad_h = cantidad_h/7

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
replace popularity = 0 if popularity==.


// creates caloric share across hh
gen calintake = cal*cantidad_h
egen totintake = total(calintake)
bysort bien: egen foodcalintake = total(calintake)
gen shareintake = foodcalintake/totintake


// filters of food
keep if shareintake>0.01 | popularity>0.3


// gen total intake after filters
qui sum(calintake)
gen totintake_after_filters = r(sum)



// output unbalanced basket


/*(************************************************************************************************************************************************* 
* 1: quantity adjustment
*************************************************************************************************************************************************)*/


//generate caloric requirement
gen cal_req = 2092

// generate population
bysort newid: gen first = 1 if _n == 1 
egen pop = total(miembros) if first==1
egen population = max(pop)
drop pop

//compare requirement to actual calories to adjust basket
gen totintake_pc = totintake_after_filters/population
gen ajuste_calorico = cal_req/totintake_pc
gen cantidad_ajustada = cantidad_h*ajuste_calorico

// output canasta ajustada
preserve 
collapse (sum) cantidad_ajustada (max) population (max) cal, by(bien) 
replace cantidad_ajustada = cantidad_ajustada/population
gen cal_intake = cantidad_ajustada*cal
save "$output/canastapercapita_metocol_sin_outliars.dta", replace
export excel using "$output/canastapercapita_metocol_sin_outliars.xlsx", firstrow(var) replace

restore
