/*===========================================================================
Puropose: This script takes prices and baskets and calculates basket's value
over time and region and creates indexes
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
Output:			dta with baskets values and indexes

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
				global rootpath "C:\Users\wb563365\OneDrive - WBG\Documents\GitHub\VEN"
		}

// set raw data path
global cleaneddatapath "$rootpath\data_management\output\cleaned"
global mergeddatapath "$rootpath\data_management\output\merged"
global input  "$rootpath\poverty_measurement\input"
global output "$rootpath\poverty_measurement\input"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off
// for label handling, we use labutil module 
// ssc install labutil


/*(************************************************************************************************************************************************* 
* 1: merging baskets and prices
*************************************************************************************************************************************************)*/

/*
goods_label:
           1 Arroz, harina de arroz
           2 Avena, avena en hojuelas, harina de avena
           3 Galletas, dulces, saladas, integrales
           4 Harina de maiz
           5 Maiz en granos
           6 Pan de trigo
           7 Pastas alimenticias
           8 Fororo
           9 Otro (especifique)
          10 Carne de res (bistec, carne molida, carne para esmechar)
          11 Visceras (higado, riñonada, corazon, asadura, morcillas)
          12 Chuleta de cerdo ahumada
          13 Carne de cerdo fresca (chuleta, costilla, pernil)
          14 Hueso de res, pata de res, pata de pollo
          15 Chorizo, jamon, mortadela y otros embutidos
          16 Carne enlatada
          17 Carne de pollo
          18 Otro (especifique)
          19 Pescado enlatado
          20 Sardinas frescas/congeladas
          21 Atun fresco/congelado
          22 Pescado fresco
          23 Pescado seco/salado
          24 Otro (especifique)
          25 Leche liquida, completa o descremada
          26 Leche en polvo, completa o descremada
          27 Queso requeson, ricota
          28 Queso blanco
          29 Queso amarillo
          30 Suero, natilla, nata
          31 Huevos (unidades)
          32 Otro (especifique)
          33 Aceite
          34 Margarina/Mantequilla
          35 Mayonesa
          36 Otro (especifique)
          37 Cambur
          38 Mangos
          39 Platanos
          40 Lechosa
          41 Guayaba
          42 Otro (especifique)
          43 Tomates
          44 Aguacate
          45 Aji dulce, pimenton, pimiento
          46 Cebolla
          47 Auyama
          48 Lechuga
          49 Berenjena
          50 Zanahorias
          51 Cebollin, ajoporro, cilantro y similares
          52 Otro (especifique)
          53 Caraotas
          54 Frijoles
          55 Lentejas
          56 Garbanzo
          57 Otro (especifique)
          58 Nueces
          59 Mani
          60 Merey
          61 Otro (especifique)
          62 Yuca
          63 Papas
          64 Ocumo
          65 Apio
          66 Casabe
          67 Otro (especifique)
          68 Azucar
          69 Papelon
          70 Edulcorantes
          71 Miel
          72 Melaza
          73 Otro (especifique)
          74 Cafe
          75 Te
          76 Bebida achocolatada
          77 Otro (especifique)
          78 Sal
          79 Condimentos (comino, pimienta, curry, cubitos)
          80 Concentrados (cubitos, sopas de sobre)
          81 Salsa de tomate
          82 Otras salsas
          83 Otro (especifique)
          84 Jugos
          85 Agua embotellada
          86 Gaseosas/refrescos
          87 Otras bebidas no alcoholicas
          88 Bebidas alcoholicas
          89 Otro (especifique)
          90 Cigarrillos (unidades)

*/

// import prices
use "$input/resumen_precio_gramo_L.dta", replace

// keep relevant variables
keep bien ENTIDAD mes median_

// goods in price dataset are classified differently than products in consumption dataset
// so we use a function to map goods from one dataset to the other

//generate mapping
preserve
use "$input/Labels_Prices_Consumption_Goods.dta", replace
drop if COD_PRECIO==.
isid COD_PRECIO
rename COD_PRECIO bien
tempfile mapping
save `mapping'
restore

// map goods of price dataset to goods of consumption dataset
merge m:1 bien using `mapping'



// cleaning
// correct mapping in some specific products

// drop product with no (relevant) price
drop if _merge==2

// consumption data mixes arroz and harina de arroz, but arroz is way more popular that harina de arroz. So we prefer a price for arroz only.
drop if bien==2

// Many products of the price data set are agregated in the consumption dataset. Example carne de res bistec, molida and desmechada. With no prior on within-group relevance, we just input a mean.
collapse (mean) precio=median_, by (ENTIDAD mes COD_GASTO LABEL_GASTO)


// merge prices with representative baskets
rename COD_GASTO bien
merge m:1 bien using "$input/canastapercapita_metocol_sin_outliars.dta"

// cleaning
keep if _merge==3
keep ENTIDAD mes bien LABEL_GASTO precio cantidad
rename LABEL_GASTO label_bien
rename ENTIDAD entidad
rename cantidad_ajustada cantidad


//generate labels
labmask bien, values(label_bien)
drop label_bien



/*(************************************************************************************************************************************************* 
* 1: basket value, indexes and outputs
*************************************************************************************************************************************************)*/

// generate value of each products
bysort entidad mes: gen valor = precio * cantidad

//generate baskets
collapse (sum) valor, by (entidad mes)

// set basis for indexes
gen temp = valor if mes=="02" & entidad == 1
egen valorbase = max (temp)
drop temp

gen index=100*valor/valorbase

// set time 
replace mes = "nov2019" if mes=="11"
replace mes = "dec2019" if mes=="12"
replace mes = "jan2020" if mes=="01"
replace mes = "feb2020" if mes=="02"
replace mes = "mar2020" if mes=="03"
replace mes = "apr2020" if mes=="04"
replace mes = "may2020" if mes=="05"
replace mes = "jun2020" if mes=="06"

gen t = monthly(mes, "MY")
format t %tm

sort entidad t

export excel "$output/indice_precios.xlsx", replace

STOP
graph twoway line index t if entidad==1
graph twoway line index t if entidad==23
graph twoway line index t if entidad==7
graph twoway line index t if entidad==18

//seguir

levelsof entidad, local(entidades_list)

for each ent in `entidad_list'
graph twoway line index t if entidad==`entidad_list'
stop

// takes Feb2020-Districto Capital as basis for indexes
gen 100 if mes==""

