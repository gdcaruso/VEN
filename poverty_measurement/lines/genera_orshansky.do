/*===========================================================================
Puropose: This script takes spending in food and compares it with spending
in non food goods to calculate orshansky indexes over population of reference
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

// set raw data path
global mergeddata "$rootpath\data_management\output\merged" //REPLACE ALL WITH CLEANED DATA
global cleaneddata "$rootpath\data_management\output\cleaned"

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
use "$mergeddata/base_out_nesstar_cedlas_2019.dta", replace
keep if interview_month==2
rename region_est2 entidad
collapse (max)ipcf_max=ipcf (max) miembros (max) entidad, by (interview__key interview__id quest)

rename ipcf_max ipcf


// keeps quantiles in poverty prior surrounding
xtile quant = ipcf, nquantiles(100)
global pprior = 50
keep if inrange(quant, $pprior -15, $pprior +15)

tempfile reference
save `reference'

/*(************************************************************************************************************************************************* 
* 1: collect data of spending in feb2020
*************************************************************************************************************************************************)*/

// there are two data sources of spending. 1) Household-individual section of survey and 2) Consumption section. Also, there are two types of spending: a) food b) non-food. So we aggregate each type of consumption in each section of the survey

// Household-individual section
//COMPLETE

// Consumption section
// import data
use "$mergeddata/product-hh.dta", replace

// problems and solutions: a) homogenize currencies, b) correct date of survey with date of purchase, c) define frequency of purchases d) define current goods e) define food and non food spending

// a) homogenize currencies
	* We move everything to bolivares February 2020, given that there we have more sample size // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio

/* tab moneda (number of spending obs. by currency)

      10b. Moneda |      Freq.     Percent        Cum.
------------------+-----------------------------------
        Bolívares |    131,356       91.18       91.18
          Dólares |      2,488        1.73       92.90
            Euros |         20        0.01       92.92
Pesos Colombianos |     10,205        7.08      100.00
------------------+-----------------------------------
            Total |    144,069      100.00
*/
		
global dolar_to_bol = 73460.1238
global euro_to_bol = 80095.41371177
global col_to_bol = 21.66060704812

gen gasto_bol = gasto if 