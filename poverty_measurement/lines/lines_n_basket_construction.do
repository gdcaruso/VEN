/*===========================================================================
Puropose: This script takes the product-hh level dataset, defines population
of reference and creates food basket
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
		global lauta   1
		
		* User 3: Lautaro
		global lauta2   0
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\Desktop\ENCOVI-2019"
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
* 1: merging with calories & proteins dataset
*************************************************************************************************************************************************)*/

use "$cleaneddatapath\product_hh_homogeneous.dta"
rename bien COD_GASTO
merge m:1 COD_GASTO using $foodcomposition

keep if _merge==3
drop _merge


/*(************************************************************************************************************************************************* 
* 1: calculate caloric and protein intake by hh
*************************************************************************************************************************************************)*/


rename COD_GASTO bien
// creates diary caloric and protein intake per hh
// food composition data is in calories or gram of proteins per 100 grams of food
// assumption: food purchased in the last 7 days is fully consumed within the week.

gen cal_intake = (((cantidad_h*Energia_kcal_m)/100)/7)
gen prot_intake = (((cantidad_h*Proteina_m)/100)/7)

compress
save $baskets, replace


collapse (sum) cal_intake prot_intake consumio, by (interview__key interview__id quest)

/*(************************************************************************************************************************************************* 
* 1: calculate caloric and protein deficits per hh
*************************************************************************************************************************************************)*/
merge 1:1 interview__key interview__id quest using "$output/requerimets_ven.dta"
keep if _merge==3
drop _merge	



//drop households that eat outside of their home

// idetify hh
tempfile comeafuera
preserve
use "$mergeddatapath/product-hh.dta", replace
keep if bien>199 & bien<299
keep interview__id interview__key quest
duplicates drop
save comeafuera
restore

// keep only hh that does not have lunch out of home
merge 1:1 interview__key interview__id quest using comeafuera
keep if _merge==1
drop _merge



//generate caloric and protein deficits
gen cal_ref_ae = 2685


gen cal_def=.
replace cal_def=1 if cal_int<req_cal
replace cal_def=0 if cal_int>=req_cal

gen prot_def=.
replace prot_def=1 if prot_int<req_prot
replace prot_def=0 if prot_int>=req_prot

gen nut_def =.
replace nut_def=1 if cal_def==1 | prot_def==1
replace nut_def=0 if cal_def==0 & prot_def==0

tab cal_def prot_def
tab cal_def prot_def [fw=miembro]

//quality control. are many households giving few answers to consumption module?
tab consumio, mi
tab consumio cal_def, mi

twoway hist consumio, w(1)
graph
//keeps only surveys that shows 9 or more answers over 89 food products TO TEST
// keep if consumio>=9



/*(************************************************************************************************************************************************* 
* 1: sets reference population
*************************************************************************************************************************************************)*/
// merges with income data

//merge


//generate variables of intake per capita
gen cal_intake_pce = cal_intake/he_cal
gen prot_intake_pce = prot_intake/he_prot
gen cal_intake_pc = cal_intake/miembro
gen prot_intake_pc = prot_intake/miembro


// sort hh by cal intake
sort cal_intake_pce
gen obs = _n
replace obs = _n

graph twoway (line cal_intake_pce obs, sort)(line cal_def obs, sort) if  cal_intake_pce<10000

twoway line cal_intake_pce obs if cal_intake_pce<5000, yaxis(1) yscale(range(0) axis(1)) ///
 || line cal_def obs if cal_intake_pce<5000, sort yaxis(2) yscale(range(0) axis(2)) 
graph


twoway (scatter cal_intake_pce cal_intake_pc if cal_intake_pce <5000, msize("tiny")) (lfit cal_intake_pce cal_intake_pc if cal_intake_pce <5000, mcolor("red"))
graph


// sort hh by income
//sort XX
// replace obs = _n

//graph twoway (line cal_intake_pce obs, sort) (line XX obs, sort)(line cal_def obs, sort) if  cal_intake_pce<10000


/*
sort cal_intake_pc
replace obs = _n
graph twoway (line cal_intake_pc obs, sort)(line cal_ref_ae obs, sort) if  cal_intake_pc<10000


sort prot_intake_pce
replace obs = _n
gen prot_ref_ae = 82
graph twoway (line prot_intake_pce obs, sort)(line prot_ref_ae obs, sort) if  prot_intake_pce<200

sort prot_intake_pc
replace obs = _n
graph twoway (line prot_intake_pc obs, sort)(line prot_ref_ae obs, sort) if  prot_intake_pc<200
*/


// define xtiles by income
xtile quant = cal_intake_pce, nquantiles(100)

compress
save $intakes, replace

/*
twoway line share_def quant, yaxis(1) yscale(range(0) axis(1)) ///
 || line cal_intake_pce quant if cal_intake_pce<8000, sort yaxis(2) yscale(range(0) axis(2)) 
graph

twoway line share_def quant, yaxis(1) yscale(range(0) axis(1)) ///
 || line cal_intake_pc quant if cal_intake_pc<8000, sort yaxis(2) yscale(range(0) axis(2)) 
graph
*/
/*
matrix R=J(81, 2, .)
forvalues i = 0(1)80{
preserve
keep if quant>=`i'+1
keep if quant<=`i'+20

egen share_def = mean(cal_def)
matrix R[`i'+1,1] = `i' 
matrix R[`i'+1,2] = share_def[1]
restore
}
*/

/*(************************************************************************************************************************************************* 
* 1: sets reference population
*************************************************************************************************************************************************)*/
// selects the quantile determined as reference
preserve
collapse (mean) cal_def,  by (quant)
keep if cal_def<.5
global pobref=quant[1]
restore


keep if quant==$pobref

// merges intake and requirements with baskets only in the population of reference
merge 1:m interview__key interview__id quest using $baskets
keep if _merge==3
drop _merge


// creates food "popularity" across hh REMOVED!
tab bien
global quantsize = r(ndistinct)

bysort bien: gen count = _N
gen popularity = count/$quantsize


// sees how many distinct products are by popularity cutoff

forvalues i = 0(5)40{
preserve
display "`i'/100"
keep if popularity>=`i'/100

restore
}

//keeps only good used by at least 0% of the hh of reference
keep if popularity>=0

bysort interview__id interview__key quest: gen new_id=1 if _n==1
replace new_id = sum(new_id)

// produces  quatities per day and per man (equivalent)
gen cantidad_h_pce = ((cantidad_h/7)/he_cal)
gen cantidad_h_pc = ((cantidad_h/7)/miembro)
keep new_id interview__id interview__key quest bien cantidad_h_pce
tsset new_id bien
tsfill, full
replace cantidad_h=0 if cantidad_h==.

// takes median quantites as 
collapse (median) median_cantidad_h_pce=cantidad_h_pce (mean) mean_cantidad_h_pce=cantidad_h_pce, by (bien)

rename bien COD_GASTO
merge 1:1 COD_GASTO using $foodcomposition
keep if _merge==3
drop _merge

rename COD_GASTO bien
rename Energia cal
rename Proteina prot

replace cal = cal/100
replace prot = prot/100

//save $reprensentativebasket
export excel using "$output/reprensentativebasket_ven.xlsx", firstrow(var) replace

