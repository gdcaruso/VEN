/*====================================================================
project:       Weights calibration for ENCOVI main Survey
Authors:        Daniel Pereira, Malena Acuña
----------------------------------------------------------------------
Creation Date:     13 May 2020 - 16:30:00
====================================================================*/

/* PATH AND OPEN DATASET */
/*
global mainpath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\"

* use most recent data from onedrive
use "${mainpath}FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018\ENCOVI_2019_English labels.dta", clear

//set universal dopaths
global harmonization "$dopath\data_management\management\2. harmonization"
global pathaux "$harmonization\aux_do"
*/

/*====================================================================
                        1: Imputing missing ages
====================================================================*/

* Note: there used to be 3 observations without age, this could distort the calculations a little bit
*		2 of those correspond to spouses, I will go and substitute these values for their corresponding spouse age
*		This step can be erased, and we would only have a slight change of values. 
*		With all the this we are doing, this might not make any significat difference

sort interview__key relacion_en
by interview__key: replace edad=edad[1] if _n==2 & edad==.

/*====================================================================
                        2: Generate age brackets 
====================================================================*/

recode edad (0/4 = 1 "0/4")(5/9 = 2 "5/9")(10/14 = 3 "10/14")(15/19 = 4 "15/19") ///
			(20/24 = 5 "20/24")(25/29 = 6 "25/29")(30/34 = 7 "30/34")(35/39 = 8 "35/39") ///
			(40/44 = 9 "40/44")(45/49 = 10 "45/49")(50/54 = 11 "50/54")(55/59 = 12 "55/59") ///
			(60/64 = 13 "60/64")(65/69 = 14 "65/69")(70/74 = 15 "70/74")(75/79 = 16 "75/79") ///
			(80/84 = 17 "80/84")(85/89 = 18 "85/89")(90/94 = 19 "90/94")(95/99 = 20 "95/99") ///
			(100/max = 21 "100/max"), gen(g_edad)


/*====================================================================
                        3: Generating Auxiliary Files 
====================================================================*/
			
* I am going to create the auxiliary file with the factors. For that I use the age structure that comes directly from
* UN's WPP files. Also attached in case you need it. This code creates a new auxiliary file that is large merged with the main database
* for the final calculations

preserve

drop if g_edad==.
collapse (sum) pondera, by(g_edad)
egen encovi_total=sum(pondera)  
gen encovi_frac=pondera/encovi_total
keep g_edad encovi_frac
merge 1:1 g_edad using "$pathaux\wpp_un_age.dta"
gen factor_edad=pop_share/encovi_frac
keep g_edad factor_edad
save "$pathaux\factor_edad.dta", replace

restore

/*====================================================================
                        4: Merging Aux + Main files
====================================================================*/

merge m:1 g_edad using "$pathaux\factor_edad.dta"


/*====================================================================
                   5: Calculating age-calibrated weights
====================================================================*/

* calculating new age-calibrated weights. Please note that I am creating a new variable. You could modify this code 
* so as to keep the same "pondera" varaible as the final set of person-level weights by simply 
* changing "gen" by "replace", and "new_pondera" by "pondera"

gen new_pondera=pondera*factor_edad


/*====================================================================
                   6: Expanding weights to UN total POP
====================================================================*/

* calculating new un-pop-calibrated weights. Please note that I am creating a new variable. You could modify this code 
* so as to keep the same "pondera" varaible as the final set of person-level weights by simply 
* changing "gen" by "replace", and "new_pondera_un" & "new_pondera" by "pondera"

sum new_pondera
local old=`r(N)'*`r(mean)'
dis "`old'"

* un pop== 28,435,943
local new=28435943

local un_factor=`new'/`old'

gen new_pondera_un=new_pondera*`un_factor'

/*====================================================================
           7: Expanding hh weights to match UN pop / member per hh
====================================================================*/

sum pondera_hh
local old2=`r(N)'*`r(mean)'
dis "`old2'"

* hh totales = poblacion expandida usando new_pondera_un / miembros por hogar (sin ponderar, 3.331051)
	gen uno=1
	sum uno [w=new_pondera_un]
	local poblatotal=r(sum_w)
	display `poblatotal'

	sum miembros if relacion_en==1 // we count only once each household - we don't use weights
	local miembrosporhh=r(mean)
	display `miembrosporhh'

	local hogarestotales = `poblatotal'/`miembrosporhh' // 8536633
	display `hogarestotales'

local hh_factor=`new'/`old2'

gen new_pondera_hh=pondera_hh*`hh_factor'

/*====================================================================
           8: Rounding
====================================================================*/

* rounding (so as to be able to do posterior analysis)
replace new_pondera=round(new_pondera)
replace new_pondera_un=round(new_pondera_un)
replace new_pondera_hh=round(new_pondera_hh)

/*====================================================================
             9: dropping & renaming
====================================================================*/

* do the drops of your preferences so as to save the final version of the database

drop g_edad
drop factor_edad
drop _merge
drop uno
drop new_pondera
drop pondera
drop pondera_hh
rename new_pondera_hh pondera_hh
rename new_pondera_un pondera
