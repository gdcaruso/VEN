/*==================================================
project:       Compare income between years
Author:        Luz Carazo 
E-email:       lcarazo@worldbank.org
url:           
Dependencies:  World Bank
----------------------------------------------------
Creation Date:     8 Apr 2020 - 16:22:33
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 16
drop _all

********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   0
		
		* User 5: Luz
		global luz   1
		
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN"
				global dataout 	PONGAN ONE DRIVE PORQUE YA ES MUY PESADA (VER ABAJO EN MALE)
		}
	    if $lauta {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
				global dataout 	"$rootpath/data_management\output\cleaned"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN" 
				global dataout 	PONGAN ONE DRIVE PORQUE YA ES MUY PESADA (VER ABAJO EN MALE)
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN"
				global dataout "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned"
		}

		if $luz   {
				global pathgit "C:\Users\wb546181\VEN"
				global pathONEDrive "C:\Users\wb546181\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global bases "${pathONEDrive}\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI harmonized data"
				global base2019 "${pathONEDrive}\Databases ENCOVI 2019\data_management\output\cleaned"
				global output "${pathgit}\data_analysis\excels"
		}
		
// For Exports
global excelName	\Income Analysis ENCOVI 2014-2019

global sheetraw Income 2014-2018

/*==================================================
            1. Deflactator
==================================================*/

/*  
Sources of Inflation Index
	1. IMF
	2. CENDAS
	3. Inflación Verdadera


*/


clear all
set obs 100000

*----------1.1: CPI 

*---IMF

gen double ipcIMF2014 = 276.2  
gen double ipcIMF2015 = 612.3 
gen double ipcIMF2016 = 2173.0 
gen double ipcIMF2017 = 11692.7 
gen double ipcIMF2018 = 7655693.5

*gen double ipc2019 = 
*gen double ipc2020 = 

*----------1.2:

forvalues y = 2014(1)2018{
	gen double def_IMF_`y' = ipcIMF2018 / ipcIMF`y'
	qui levelsof def_IMF_`y' , local(def_IMF_`y')
	global def_IMF_`y' `def_IMF_`y''
	
	noi di "Deflactor IMF `y': ${def_IMF_`y'}"
}


/*==================================================
              2: 
==================================================*/

*----------2.1:

tempname pname
tempfile pfile
postfile `pname' year str30(incs) str30(type) value using `pfile', replace

//	 SELECT years FOR ANALYSIS			<------------------
global years "2014/2018"

*global years 2014

//	SELECT VARIABLES FOR ANALYSIS		<------------------

local inc_var ipcf ila inla 


*---------------------------------------------*

foreach year of numlist $years {		
	if `year'==2019 {
		 use "${base2019}\ENCOVI_2019.dta", clear
	}
	
	else {
		use "${bases}\ENCOVI_harmonized_`year'.dta", clear
	}
		
	cap gen year = ano
	
*----------2.2:

	// IN 2018 TERMS
	local incs_2018 ""
	foreach var in `inc_var' {
		cap drop `var'_2018
		gen double `var'_2018 = (`var' * ${def_IMF_`year'} ) if year == `year'
		local incs_2018 "`incs_2018' `var'_2018" // list of income in 2018
		noi di "incs_2018: `incs_2018'"
	}
	
/*	
	// IN PPP11 TERMS
	local incs_ppp ""
	foreach var in `inc_var' {
		cap drop `var'_ppp11
		gen double `var'_ppp11 = (`var' * ${def_`year'} * (conversion/ppp11)) if year == `year'
		local incs_ppp "`incs_ppp' `var'_ppp11" // list of income in ppp
		noi di "incs_ppp: `incs_ppp'"
	}
*/
/*----------->	PER CAPITA FAMILIAR
	// SUM BY HH
	foreach incs of local incs_ppp {	
	
		egen double `incs'_pcf = sum(`incs')	if  hogarsec==0, by(year id)
		
	}
	
	// Local of components ("comp_ppp_pcf")
	local comp_ppp_pcf itf_ppp11
	foreach var in `incs_ppp' {
		local comp_ppp_pcf "`comp_ppp_pcf' `var'_pcf" // list of income sources in ppp
		noi di "comp_ppp_pcf: `comp_ppp_pcf'"
	}


	// Collapse MEAN by HH-YEAR (PER CAPITA FAMILIAR)
	collapse (mean) `comp_ppp_pcf' miembros pondera urbano, by (year id)
	
	// WEIGHTS by HH
	gen double peso = (pondera*miembros)
			
	
		
	// 	Dummy bottom 40 (BASED ON TOTAL FAMILIAR INCOME)
	tempvar b40`year'
	b40 ipcf_ppp11_pcf [aw=peso] if year==`year', generate(b40`year') 		
*/	

*----------2.3:
	foreach incs of local incs_2018 {
	
		di "`incs'"
			
		***		Mean aggregates
		*--National
		sum `incs' [aw=pondera] if year==`year' , meanonly
		local value = r(mean)
		local type "National"
		post `pname' (`year') ("`incs'") ("`type'") (`value')
		
		/*
		*--Bottom 40
		sum `incs' [aw=peso] if b40`year'==1 & year==`year', meanonly
		local value = r(mean)
		local type "Bottom40"
		post `pname' (`year') ("`incs'") ("`type'") (`value')
		
		*--Top 60
		sum `incs' [aw=peso] if b40`year'==0 & year==`year', meanonly
		local value = r(mean)
		local type "Top60"
		post `pname' (`year') ("`incs'") ("`type'") (`value')	
		*/
	}	//end loop mean income
	
}	// end loop year


*restore

postclose `pname'
use `pfile', clear

br

/*==================================================
              3: Export
==================================================*/

export excel using "${output}${excelName}", firstrow(var) sheetreplace sheet("${sheetraw}")


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


