/*=================================================================================
				SELECT SAMPLE CENSUS DATA
Project:       Poverty Map Venezuela
Author:        Mateo Uribe-Castro
---------------------------------------------------------------------------
Creation Date:      May, 2020
Notes:
- MANUALLY CHANGE merida & miranda FOLDER NAMES TO ALL CAPS
- MANUALLY CHANGE file AMAHOGAR.dta for AMAHOG.dta
- MAKE SURE FILES NAMES DON'T HAVE TRAILING BLANKS (ONLY HAPPENS FOR SOME VIV.dta FILES)
- FOR CONSISTENCY, CHANGE FILES NAMES IN DISTRITO FROM DIST[] TO DIS[]
- FOR LARA - LAR2[] FILES ARE ACTULLY IDENTICAL TO MERIDA's FILES. DELETE LAR2 AND CHANGE LAR1[] TO LAR[]
==================================================================================*/

* -------------------Share of Households from each parroquia sampled
                             local factsamp = 1
*---------------------------------------------------------------------

*One-time quick fix to ZUL3HOG
/*
use "${census}/ZULIA/ZUL2HOG.dta", clear
save "${census}/ZULIA/ZUL3HOG.dta", replace

use "${census}/ZULIA/ZUL2PER.dta", clear
keep redcode entidad municipio parroquia centropo segmento codcarga tipseg sector manzana parcela nroedif nroviv numerodeho
gen hhsize = 1
decode redcode, gen(hhid)
collapse (first) hhid (sum) hhsize, by(entidad municipio parroquia centropo segmento codcarga tipseg sector manzana parcela nroedif nroviv numerodeho)
replace hhid = substr(hhid,1,39)
gen redcode = _n
save "${census}/ZULIA/ZUL2HOG.dta", replace
*/
*---------------------------------------------------------------------




local entidad `" "DISTRITO" "AMAZONAS" "ANZOATEGUI" "APURE" "ARAGUA" "BARINAS" "BOLIVAR" "CARABOBO" "COJEDES" "DELTA AMACURO" "FALCON" "GUARICO" "LARA" "MERIDA" "MIRANDA" "MONAGAS" "NUEVA ESPARTA" "PORTUGUESA" "SUCRE" "TACHIRA" "TRUJILLO" "VARGAS" "YARACUY" "ZULIA" "DEPENDENCIAS FEDERALES" "'
*local entidad `" "DISTRITO" "AMAZONAS" "'
*NOTE: BRITTA RUDE changed this from local data PER HOG VIV to local data PER 
local data PER HOG VIV  

local i = 1
foreach x of local entidad {

di "Working on: `x' - folder no. `i'"

	local ent = substr("`x'",1,3) 
	
	cd "${census}//`x'"
	local folder : dir . files "*"
	local nfiles : word count `folder'
	di "`nfiles'"
	
	if `nfiles' == 3 {
	
		use "`ent'HOG.dta", clear
		keep redcode entidad municipio parroquia centropo segmento codcarga tipseg sector manzana parcela nroedif nroviv numerodeho
	
		set seed 19922020
		gen random = runiform()
		
		bysort entidad municipio parroquia (random): gen counthh = _n
		g uno = 1
		
		egen parhhcount = sum(uno), by(entidad municipio parroquia)
		sum parhhcount
		gen samplehh = floor(parhhcount*`factsamp')
		
		keep if counthh <= samplehh
		
		decode redcode, gen(hhid)
		
		g check = "`x'"
		
		tempfile samp`ent'
		save `samp`ent'', replace
	
	}

	
	if `nfiles' > 3 {
		local num = `nfiles'/3
		
			forvalues z = 1(1)`num' {
			
				di "Working on: `x'`z'HOG - folder no. `i'"

				use "`ent'`z'HOG.dta", clear
				*rename *, lower
				*compress

				keep redcode entidad municipio parroquia centropo segmento codcarga tipseg sector manzana parcela nroedif nroviv numerodeho
				
				set seed 19922020
				gen random = runiform()
				
				bysort entidad municipio parroquia (random): gen counthh = _n
				g uno = 1
				
				egen parhhcount = sum(uno), by(entidad municipio parroquia)
				sum parhhcount
				gen samplehh = floor(parhhcount*`factsamp')
				
				keep if counthh <= samplehh
				
				if "`ent'`z'" != "ZUL2" {
					decode redcode, gen(hhid)
				}
				
				if "`ent'`z'" == "ZUL2" {
					merge 1:1 redcode using "`ent'`z'HOG.dta", keepusing(hhid) keep(match)
				}
				
				tempfile samp`ent'`z'
				save `samp`ent'`z'', replace
			
			}

			use `samp`ent'1', clear
			forvalues z=2(1)`num' {
				append using `samp`ent'`z''
			}
			
			g check = "`x'"
			tempfile samp`ent'
			save `samp`ent''
	}
	local ++i
}

use `sampDIS', clear 
local i = 1
foreach x of local entidad {
	local ent = substr("`x'",1,3)
	
		if `i'>1 {
			append using `samp`ent''
		}
		
	local ++i
}

g entid = substr(hhid,1,2)
g munid = substr(hhid,1,4)
g parid = substr(hhid,1,6)
g vivid = substr(hhid,1,38)

keep hhid entid munid parid vivid parhhcount samplehh uno check

save "${dataout}/census_sample.dta", replace

*Extract sample of dwellings where the sample of households live
preserve 
bysort vivid: gen vivorder = _n
egen hhperviv = sum(uno), by(vivid)
keep uno parhhcount samplehh hhperviv vivid vivorder
keep if vivorder == 1
drop vivorder

tempfile vivsample
save `vivsample'
restore

foreach y of local data {
	foreach x of local entidad {
		di in red "Working on: `x' - `y'"

		local ent = substr("`x'",1,3)
		
		cd "${census}//`x'"
		local folder : dir . files "*"
		local nfiles : word count `folder'
		
		if `nfiles' == 3 {
		
			use "`ent'`y'.dta", clear
			
			decode redcode, gen(code)

			if "`y'" == "HOG" {
				rename code hhid
				merge 1:1 hhid using "${dataout}/census_sample.dta", keepusing(uno parhhcount samplehh) keep(match)
			}
			
			if "`y'" == "PER" {
				rename code perid
				g hhid = substr(perid,1,39)
				merge m:1 hhid using "${dataout}/census_sample.dta", keepusing(uno parhhcount samplehh) keep(match)
			}
			
			if "`y'" == "VIV" {
				rename code vivid
				merge 1:1 vivid using `vivsample', keepusing(uno parhhcount samplehh) keep(match)
			}

			tempfile samp`ent'`y'
			save `samp`ent'`y'', replace
		
		}

		
		if `nfiles' > 3 {
			local num = `nfiles'/3
			
			forvalues z = 1(1)`num' {
			
				use "`ent'`z'`y'.dta", clear
			
				if "`ent'`z'`y'" != "ZUL2HOG" {
					decode redcode, gen(code)
				}
			
				if "`ent'`z'`y'" == "ZUL2HOG" {
					rename hhid code
				}
				
				if "`y'" == "HOG" {
					rename code hhid
					merge 1:1 hhid using "${dataout}/census_sample.dta", keepusing(uno parhhcount samplehh) keep(match)
				}
				
				if "`y'" == "PER" {
					rename code perid
					g hhid = substr(perid,1,39)
					merge m:1 hhid using "${dataout}/census_sample.dta", keepusing(uno parhhcount samplehh) keep(match)
				}
				
				if "`y'" == "VIV" {
					rename code vivid
					merge 1:1 vivid using `vivsample', keepusing(uno parhhcount samplehh) keep(match)
				}
				
				tempfile samp`ent'`z'`y'
				save `samp`ent'`z'`y'', replace

			}
			
			use `samp`ent'1`y'', clear
			forvalues z=2(1)`num' {
				append using `samp`ent'`z'`y''
			}

			tempfile samp`ent'`y'
			save `samp`ent'`y'', replace
		}
	}
	
	use `sampDIS`y'', clear
	foreach x of local entidad {		
		local ent = substr("`x'",1,3)
		
		if "`x'" != "DISTRITO" {
			append using `samp`ent'`y''
		}
	}
	
	if "`y'" != "VIV" {
		g entid = substr(hhid,1,2)
		g munid = substr(hhid,1,4)
		g parid = substr(hhid,1,6)
	}
	
	if "`y'" == "VIV" {
		g entid = substr(vivid,1,2)
		g munid = substr(vivid,1,4)
		g parid = substr(vivid,1,6)
	}

	save "${dataout}/census_sample`y'.dta", replace
}

















 
 
 
 
 
 
 
 

 