/*===========================================================================
Puropose: value basket over time
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		25th Mar, 2020
Modification Date:  

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
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set path
global merged "$rootpath\data_management\output\merged"
global cleaned "$rootpath\data_management\output\cleaned"
global output "$rootpath\poverty_measurement\output"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off



// import prices
use "$output/precios_implicitos_nov_to_march.dta", replace
merge m:1 bien using "$output/canasta_diaria.dta"
drop _merge

// generate value of each products
gen valor_canasta = pimp * cantidad_ajustada

//collapse by month to make the series and the index
collapse (sum) valor_canasta, by(month)
replace month = month + 12 if month<10
tsset month
gen index = 100* valor_canasta/valor_canasta[4]
sort month
replace month = month - 12 if month<10

save $output/serie_inflacion_canasta.dta, replace
export excel $output/serie_inflacion_canasta.xlsx, firstrow(variables), replace
