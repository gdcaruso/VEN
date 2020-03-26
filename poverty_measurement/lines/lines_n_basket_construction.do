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
* 1: merging with calories & proteins dataset
*************************************************************************************************************************************************)*/

use "$cleaneddatapath\product_hh_homogeneous.dta"
rename bien COD_GASTO
merge m:1 COD_GASTO using "$foodcomposition"

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
save "$baskets", replace


collapse (sum) cal_intake prot_intake consumio, by (interview__key interview__id quest)

/*(************************************************************************************************************************************************* 
* 1: calculate caloric and protein deficits per hh
*************************************************************************************************************************************************)*/
merge 1:1 interview__key interview__id quest using "$output/requerimets_col.dta"
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
save `comeafuera'
restore

// keep only hh that does not have lunch out of home
merge 1:1 interview__key interview__id quest using `comeafuera'
keep if _merge==1
drop _merge



//generate caloric and protein deficits
gen cal_ref_ae = 2550


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
// tab consumio, mi
// tab consumio cal_def, mi

// twoway hist consumio, w(1)
// graph
//keeps only surveys that shows 9 or more answers over 89 food products TO TEST
// keep if consumio>=9

// drop 0 or missing consumption
drop if (cal_int==0 | cal_int==.)

/*(************************************************************************************************************************************************* 
* 1: sets reference population
*************************************************************************************************************************************************)*/
// merges with income data
tempfile ipcf
preserve
use "$cleaneddatapath/base_out_nesstar_cedlas_2019.dta", replace
keep if interview_month==2
collapse (mean)ipcf_mean=ipcf (max)ipcf_max=ipcf (max) entidad , by (interview__key interview__id quest)
tab interview__key if ipcf_max!=ipcf_mean
save `ipcf'
restore

merge 1:1 interview__id interview__key quest using `ipcf'
keep if _merge==3
drop _merge

rename ipcf_max ipcf
drop ipcf_mean

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
sort ipcf
replace obs = _n

graph twoway dot cal_intake_pce obs if cal_intake_pce<5000 & ipcf<5000000, yaxis(1) yscale(range(0) axis(1)) msize("tiny") ///
 || line ipcf obs if cal_intake_pce<5000 & ipcf<50000000, yaxis(2) yscale(range(0) axis(2))

 
graph twoway scatter cal_intake_pce ipcf if cal_intake_pce<5000 & ipcf<5000000, yaxis(1) yscale(range(0) axis(1)) msize("tiny") ///
 || lfit cal_intake_pce ipcf if cal_intake_pce<5000 & ipcf<5000000


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

///////////PERCENTILES SECTION
// define xtiles by income
xtile quant = ipcf, nquantiles(100)

compress
save "$intakes", replace

/*
twoway line share_def quant, yaxis(1) yscale(range(0) axis(1)) ///
 || line cal_intake_pce quant if cal_intake_pce<8000, sort yaxis(2) yscale(range(0) axis(2)) 
graph

twoway line share_def quant, yaxis(1) yscale(range(0) axis(1)) ///
 || line cal_intake_pc quant if cal_intake_pc<8000, sort yaxis(2) yscale(range(0) axis(2)) 
graph
*/

///////////OTHERTILES SECTION

//gen q = ceil(quant/20)
gen q = ceil(quant/5)
bysort q: egen inc = mean(ipcf)
bysort q: egen p01 = pctile(cal_intake_pce), p(1)
bysort q: egen p30 = pctile(cal_intake_pce), p(30)
bysort q: egen p40 = pctile(cal_intake_pce), p(40)
bysort q: egen p50 = pctile(cal_intake_pce), p(50)
bysort q: egen p60 = pctile(cal_intake_pce), p(60)
bysort q: egen p70 = pctile(cal_intake_pce), p(70)
bysort q: egen p99 = pctile(cal_intake_pce), p(99)
bysort q: egen p95 = pctile(cal_intake_pce), p(95)
bysort q: egen uncon_mean = mean(cal_intake_pce)
bysort q: egen con_mean = mean(cal_intake_pce) if cal_intake_pce < p99 & cal_intake_pce > p01

graph twoway line inc q if q<20, yaxis(1) lpattern("dash") ///
  || line uncon_mean q if q<20, yaxis(2) lcolor("red") lpattern("dash")  ///
  || line p40 q if q<20, yaxis(2) lcolor("black") lpattern("dash") ///
  || line p50 q if q<20, yaxis(2) lcolor("black") ///
  || line p60 q if q<20, yaxis(2) lcolor("black") lpattern("dash") ///
  || line cal_ref_ae q if q<20, yaxis(2) lcolor("yellow") ///
  || line con_mean q if q<20, yaxis(2) lcolor("red")
  


/// quantile analysis
/// why are big peaks in q6/20, q16, q1 and valleys in q7 and q11???? 
bysort q: egen uncon_sd = sd(cal_intake_pce)
bysort q: egen con99_sd = sd(cal_intake_pce) if cal_intake_pce < p99
bysort q: egen con95_sd = sd(cal_intake_pce) if cal_intake_pce < p95
graph twoway line uncon_sd q if q<20, yaxis(1) ///
  || line con99_sd q if q<20, yaxis(1) ///
  || line con95_sd q if q<20, yaxis(1) ///
  || line uncon_mean q if q<20, yaxis(2) lcolor("red") lpattern("dash")

// where are they? q6 q16 q9 q13
tab entidad q

// what do they eat?
merge 1:m interview__id interview__key quest using "$baskets"
gen pico = 1 if quant == 6 | quant == 16 | quant == 9  | quant == 13  
replace pico = 0 if pico !=1
stop

restore
///////////QUANTILES MOV SECTION

matrix R=J(81, 11, .)
forvalues i = 0(1)80{
preserve
keep if quant>=`i'+1
keep if quant<=`i'+20


egen share_def = mean(cal_def)
egen mean_ipcf = mean(ipcf)
egen mean_cal = mean(cal_intake_pce)
egen p20 =  pctile(cal_intake_pce), p(20)
egen p30 =  pctile(cal_intake_pce), p(30)
egen p40 =  pctile(cal_intake_pce), p(40)
egen p50 =  pctile(cal_intake_pce), p(50)
egen p60 =  pctile(cal_intake_pce), p(60)
egen p70 =  pctile(cal_intake_pce), p(70)
egen p80 =  pctile(cal_intake_pce), p(80)

matrix R[`i'+1,1] = `i' 
matrix R[`i'+1,2] = mean_ipcf[1]
matrix R[`i'+1,3] = mean_cal[1]
matrix R[`i'+1,4] = p20[1]
matrix R[`i'+1,5] = p30[1]
matrix R[`i'+1,6] = p40[1]
matrix R[`i'+1,7] = p50[1]
matrix R[`i'+1,8] = p60[1]
matrix R[`i'+1,9] = p70[1]
matrix R[`i'+1,10] = p80[1]
matrix R[`i'+1,11] = cal_ref_ae[1]

restore
}

preserve
svmat R
graph twoway line R2 R1 if R1<78, yaxis(1) lpattern("dash") ///
  || line R3 R1 if R1<78, yaxis(2) lcolor("red")  ///
  || line R4 R1 if R1<78, yaxis(2) lcolor("grey") lpattern("dot") ///
  || line R5 R1 if R1<78, yaxis(2) lcolor("grey") lpattern("dot") ///
  || line R6 R1 if R1<78, yaxis(2) lcolor("black") lpattern("dash") ///
  || line R7 R1 if R1<78, yaxis(2) lcolor("black") ///
  || line R8 R1 if R1<78, yaxis(2) lcolor("black") lpattern("dash") ///
  || line R9 R1 if R1<78, yaxis(2) lcolor("grey") lpattern("dot") ///
  || line R10 R1 if R1<78, yaxis(2) lcolor("grey") lpattern("dot") ///
  || line R11 R1 if R1<78, yaxis(2) lcolor("orange")
restore






/*(************************************************************************************************************************************************* 
* 1: sets reference population
*************************************************************************************************************************************************)*/
// selects the quantile determined as reference
// collapse (mean) cal_def_mean = cal_def ///
//	(mean) cal_intake_pce_mean = cal_intake_pce ///
//	(mean) ipcf_mean = ipcf ///
//	(sd) cal_def_sd = cal_def ///
//	(sd) cal_intake_pce_sd=cal_intake_pce ///
//	(sd) ipcf_sd=ipcf,  by (quant)

keep if inrange(quant, 40,59)

//graph twoway line cal_def_mean quant if cal_intake_pce_mean<5000 & ipcf_mean<5000000, yaxis(1) yscale(range(0) axis(1)) ///
// || line ipcf_mean quant if cal_intake_pce_mean<5000 & ipcf_mean<5000000, yaxis(2) yscale(range(0) axis(1))
//stop

//graph twoway line cal_intake_pce_mean quant if cal_intake_pce_mean<5000 & ipcf_mean<5000000, yaxis(1) yscale(range(0) axis(1)) ///
// || line ipcf_mean quant if cal_intake_pce_mean<5000 & ipcf_mean<5000000, yaxis(2) yscale(range(0) axis(1))
//stop
	


/*(************************************************************************************************************************************************* 
* 1: creates baskets
*************************************************************************************************************************************************)*/
	
// merges intake and requirements with baskets only in the population of reference
merge 1:m interview__key interview__id quest using $baskets
keep if _merge==3
drop _merge


// creates food "popularity" across hh REMOVED!
bysort bien: gen popularity = _N
qui tab interview__id
gen totalhh = r(r)

replace popularity = popularity/totalhh
drop totalhh

// produces  quatities per day and per man (equivalent)
gen cantidad_h_pce = ((cantidad_h/7)/he_cal)
gen cantidad_h_pc = ((cantidad_h/7)/miembro)


// complete with 0s where goods have no obs
egen newid = group(interview__id interview__key quest)
keep newid interview__id interview__key quest bien cantidad_h_pce popularity
tsset newid bien
tsfill, full
replace cantidad_h=0 if cantidad_h==.
tsset, clear
drop newid

// generate interquartile mean
bysort bien: egen p25 =  pctile(cantidad_h_pce), p(25)
bysort bien: egen p75 =  pctile(cantidad_h_pce), p(75)
bysort bien: egen q = mean(cantidad_h_pce) if cantidad_h_pce>=p25 & cantidad_h_pce<=p75
bysort bien: replace q = 0 if cantidad<p25 & cantidad>p75

// summarises baskets into representative basket
collapse (median) qmedian=cantidad_h_pce (mean) qmean=cantidad_h_pce (max) qiqm=q (max) pop=pop, by (bien)

rename bien COD_GASTO
merge 1:1 COD_GASTO using $foodcomposition
keep if _merge==3
drop _merge

rename COD_GASTO bien
rename Energia cal
rename Proteina prot

replace cal = cal/100
replace prot = prot/100

//creates caloric contribution
gen cal_intake = qiqm*cal
gen prot_intake = qiqm*prot

egen tot_cal = sum(cal_intake)
egen tot_prot = sum(prot_intake)

gen cal_contrib = cal_intake/tot_cal
gen prot_contrib = prot_intake/tot_prot


//save $reprensentativebasket
export excel using "$output/canasta4060_col.xlsx", firstrow(var) replace
