/*===========================================================================
Puropose: calculate implicit prices of some goods
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		march 4th, 2020
Modification Date:  
Output:			

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 3: Lautaro
		global lauta2   1
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set raw data path
global merged "$rootpath\data_management\output\merged"
global cleaned "$rootpath\data_management\output\cleaned"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off


/*==============================================================================
1:moves currencies to bolivares
==============================================================================*/
// generate exchange rates

*** 0.0 To take everything to bolívares ***

* Deflactor DEPRECIATED
*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
use "$cleaned\InflacionVerdadera_26-3-20.dta", clear
//		
// forvalues j = 11(1)12 {
// 	sum indice if mes==`j' & ano==2019
// 	local indice`j' = r(mean) 			
// 	di `indice`j''
// 	}
//
//	
// forvalues j = 1(1)3 {
// 	qui sum indice if mes==`j' & ano==2020
// 	display r(mean)
// 	local indice`j' = r(mean)				
// 	}
// local deflactor11 `indice2'/`indice11'
// local deflactor12 `indice2'/`indice12'
// local deflactor1 `indice2'/`indice1'
// local deflactor2 `indice2'/`indice2'
// local deflactor3 `indice2'/`indice3'


// or use this to mute all inflation effects
local deflactor11 1
local deflactor12 1
local deflactor1 1
local deflactor2 1
local deflactor3 1
	
* Exchange Rates / Tipo de cambio
*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio

local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
local meses 1 2 3 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march

use "$cleaned\exchenge_rate_price.dta", clear

destring mes, replace
foreach i of local monedas {
	foreach j of local meses {
		qui sum mean_moneda	if moneda==`i' & mes==`j'
		local tc`i'mes`j' = r(mean)
		di `tc`i'mes`j''
	}
}


/*==============================================================================
1: Data loading
==============================================================================*/

*************************************************************************************************************
*** COMPLETAR UNIDADES MAL IMPUTADAS (KG x GR o viceversa)
*** COMPLETAR TAMAñOS
*** COMPLETAR BIENES NO ESTANDARIZADOS
****************************************************************************************************************

// load food data
use  "$merged/product-hh.dta", clear


// keeps only harina de maiz, arroz, aceite y azucar, carne y queso
keep if inlist(bien, 1, 4, 10, 28, 33, 68)

//drop no consumption
keep if consumio==1 & cantidad>0 & (cantidad!=.|cantidad!=.a)


// drop unrelevant variables
keep interview__key interview__id quest bien unidad_medida tamano comprado fecha_ultima_compra cantidad_comprada_noclap unidada_comprada_noclap  tamano_comprada_noclap gasto moneda date_consumption_survey

// replace 0s at purchased ammounts just to dont avoid 0s at summary statistics
replace comprado =. if comprado==0

// replace 0s at expenditure ammounts just to dont avoid 0s at summary statistics
replace gasto =. if gasto==0


//drop if unidad_medida is missing
drop if unidad_medida==.


// merge with sedlac to get hh size
preserve
use  "$cleaned/ENCOVI_2019.dta", clear
collapse (max) com, by (interview__id interview__key quest)
rename com miembros
tempfile hhsize
save `hhsize'
restore

merge m:1 interview__id interview__key quest using `hhsize', keep(match)

// dates
// gen week of data
gen week = week(date_consumption_survey)-52

// gen month of data
gen month = month(date_consumption_survey)




// currency conversion

gen gasto_bol = gasto* 1*`deflactor2' if moneda == 1 & month == 2
replace gasto_bol = gasto*`tc2mes2'*`deflactor2' if moneda == 2 & month == 2
replace gasto_bol = gasto*`tc3mes2'*`deflactor2' if moneda == 3 & month == 2
replace gasto_bol = gasto*`tc4mes2'*`deflactor2' if moneda == 4 & month == 2


replace gasto_bol = gasto*1*`deflactor3' if moneda == 1 & month == 3
replace gasto_bol = gasto*`tc2mes3'*`deflactor3' if moneda == 2 & month == 3
replace gasto_bol = gasto*`tc3mes3'*`deflactor3' if moneda == 3 & month == 3
replace gasto_bol = gasto*`tc4mes3'*`deflactor3' if moneda == 4 & month == 3


replace gasto_bol = gasto*1*`deflactor1' if moneda == 1 & month == 1
replace gasto_bol = gasto*`tc2mes1'*`deflactor1' if moneda == 2 & month == 1
replace gasto_bol = gasto*`tc3mes1'*`deflactor1' if moneda == 3 & month == 1
replace gasto_bol = gasto*`tc4mes1'*`deflactor1' if moneda == 4 & month == 1


replace gasto_bol = gasto*1*`deflactor11' if moneda == 1 & month == 11
replace gasto_bol = gasto*`tc2mes11'*`deflactor11' if moneda == 2 & month == 11
replace gasto_bol = gasto*`tc3mes11'*`deflactor11' if moneda == 3 & month == 11
replace gasto_bol = gasto*`tc4mes11'*`deflactor11' if moneda == 4 & month == 11


replace gasto_bol = gasto*1*`deflactor12' if moneda == 1 & month == 12
replace gasto_bol = gasto*`tc2mes12'*`deflactor12' if moneda == 2 & month == 12
replace gasto_bol = gasto*`tc3mes12'*`deflactor12' if moneda == 3 & month == 12
replace gasto_bol = gasto*`tc4mes12'*`deflactor12' if moneda == 4 & month == 12

/*==============================================================================
1:corrects units
==============================================================================*/
// //gen corrected quantities
// gen comprado_h =.
//
//
// // food = Arroz, harina de arroz (1)
// // unit = Kilogramos (1)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==1 & unidad_medida==1 & comprado<50
// replace comprado_h = comprado if bien==1 & unidad_medida==1 & comprado>=50
//
//
// // food = Arroz, harina de arroz (1)
// // unit = Gramos (2)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==1 & unidad_medida==2 & comprado<50
// replace comprado_h = comprado if bien==1 & unidad_medida==2 & comprado >=50
//
// // food = Harina de maiz (4)
// // unit = Kilogramos (1)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==4 & unidad_medida==1 & comprado<50
// replace comprado_h = comprado if bien==4 & unidad_medida==1 & comprado >=50
//
//
// // food = Harina de maiz (4)
// // unit = Gramos (2)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==4 & unidad_medida==2 & comprado<50
// replace comprado_h = comprado if bien==4 & unidad_medida==2 & comprado >=50
//
//
// // food = Carne de res (bistec, carne molida, carne para esmechar) (10)
// // unit = Kilogramos (1)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==10 & unidad_medida==1 & comprado<50
// replace comprado_h = comprado if bien==10 & unidad_medida==1 & comprado>=50 
//
//
// // food = Carne de res (bistec, carne molida, carne para esmechar) (10)
// // unit = Gramos (2)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==10 & unidad_medida==2 & comprado<50
// replace comprado_h = comprado if bien==10 & unidad_medida==2 & comprado>=50 
//
//
// // food = Queso blanco (28)
// // unit = Kilogramos (1)
// // size = no size
// replace comprado_h = comprado*1000 if bien==28 & unidad_medida==1 & comprado<50
// replace comprado_h = comprado if bien==28 & unidad_medida==1 & comprado>=50
//
//
// // food = Queso blanco (28)
// // unit = Gramos (2)
// // size = no size
// *ALERT: treshold to move kilos to grams changed (14)
// replace comprado_h = comprado*1000 if bien==28 & unidad_medida==2 & comprado<14
// replace comprado_h = comprado if bien==28 & unidad_medida==2 & comprado>=14
//
//
// // food = Aceite (33)
// // unit = Litros (3)
// // size = no size
// *density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/ (ME)
// replace comprado_h = comprado*0.92*1000 if bien==33 & unidad_medida==3 & comprado<50
// replace comprado_h = comprado*0.92 if bien==33 & unidad_medida==3 & comprado>=50
//
//
// // food = Aceite (33)
// // unit = Mililitros (4)
// // size = no size
// *density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/ (ME)
// *ALERT: treshold changed (10)
// replace comprado_h = comprado*0.92*1000 if bien==33 & unidad_medida==4 & comprado<10
// replace comprado_h = comprado*0.92 if bien==33 & unidad_medida==4 & comprado>=10
//
//
// // food = Aceite (33)
// // unit = Cucharada (210)
// // size = Grande (1)
// * "Cucharada" "grande" (10g) based on Hernandez et al (2015)* (ME)
// replace comprado_h = comprado*10 if bien==33 & unidad_medida==210 & tamano==1
//
//
// // food = Aceite (33)
// // unit = Cucharada (210)
// // size = Pequeña (3)
// * "Cucharada" "pequena" (5g) based on Hernandez et al (2015)* (ME)
// replace comprado_h = comprado*5 if bien==33 & unidad_medida==210 & tamano==3 & comprado<100
//
//
// // food = Azucar (68)
// // unit = Kilogramos (1)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==68 & unidad_medida==1 & comprado<24
// replace comprado_h = comprado if bien==68 & unidad_medida==1 & comprado>=24 
//
// // food = Azucar (68)
// // unit = Gramos (2)
// // size = no size
//
// replace comprado_h = comprado*1000 if bien==68 & unidad_medida==2 & comprado<10
// replace comprado_h = comprado if bien==68 & unidad_medida==2 & comprado>=10 

/*==============================================================================
1:daniel correcciones for harina
==============================================================================*/
// drop anything else than harina de maiz
keep if bien==4
// drop unreal expenditure
drop if gasto_bol>9999999

// rename to make Daniels code to work
drop gasto
rename gasto_bol gasto
rename comprado cantidad
gen unit = "Kilogramos" if unidad_medida==1
replace unit = "Gramos" if unidad_medida==2
gen food ="Harina de maiz"

keep gasto cantidad unit food tamano

//	Harina de maiz

	drop if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==1 & gasto>999999 | food=="Harina de maiz" & unit=="Kilogramos" & cantidad==1 & gasto<10000			
	drop if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==2 & gasto>999999 | food=="Harina de maiz" & unit=="Kilogramos" & cantidad==2 & gasto<10	
	replace gasto=gasto*2000 if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==2 & gasto>10 & gasto<200		
	drop if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==3 & gasto>999999 | food=="Harina de maiz" & unit=="Kilogramos" & cantidad==3 & gasto<10			
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==3 & gasto<100000
	drop if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==4 & gasto>2000000	
	replace gasto=gasto*4000 if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==4 & gasto>10 & gasto<100		
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==4 & gasto<100000
	replace gasto=gasto*5000 if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==5 & gasto>10 & gasto<200		
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==5 & gasto<100000
	replace gasto=gasto*6000 if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==6 & gasto>10 & gasto<200		
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==6 & gasto<100000
	replace gasto=gasto*7000 if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==7 & gasto>10 & gasto<200		
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==7 & gasto<100000
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==8 & gasto<100000
	replace gasto=gasto*9000 if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==9 & gasto>10 & gasto<200		
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==9 & gasto<100000
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==10 & gasto<100000
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==12 & gasto<100000
	replace cantidad=1 if unit=="Kilogramos" & food=="Harina de maiz" & cantidad==14 & gasto<100000
	replace unit="Gramos" if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==500	
	replace unit="Gramos" if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==1500	
	replace unit="Gramos" if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==2500	
	replace unit="Gramos" if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==7000	
	drop if food=="Harina de maiz" & unit=="Kilogramos" & cantidad==.			
	replace unit="Kilogramos" if food=="Harina de maiz" & unit=="Gramos" & cantidad==1	
	replace unit="Kilogramos" if food=="Harina de maiz" & unit=="Gramos" & cantidad==2	
	replace unit="Kilogramos" if food=="Harina de maiz" & unit=="Gramos" & cantidad==3	
	replace cantidad=1000 if unit=="Gramos" & food=="Harina de maiz" & cantidad==4 & gasto<100000
	replace unit="Kilogramos" if food=="Harina de maiz" & unit=="Gramos" & cantidad==5	
	replace unit="Kilogramos" if food=="Harina de maiz" & unit=="Gramos" & cantidad==7	
	drop if food=="Harina de maiz" & unit=="Gramos" & cantidad==500 & gasto>1000000			
	replace gasto=gasto*1000 if food=="Harina de maiz" & unit=="Gramos" & cantidad==2500 & gasto>10 & gasto<300		
	drop if food=="Harina de maiz" & unit=="Gramos" & cantidad==.			

//



preserve
collapse (mean) mean_gasto = gasto (min) min_gasto= gasto (p1) p1_gasto = gasto (p5) p5_gasto = gasto (p10) p10_gasto = gasto (p50) p50_gasto = gasto (p90) p90_gasto = gasto (p95) p95_gasto = gasto (p99) p99_gasto = gasto (max) max_gasto= gasto (count) n = gasto, by(food unit tamano cantidad)

drop if n==0
sort  food cantidad unit tamano 
order food cantidad unit tamano
export excel "$cleaned\pimp_hmaiz.xlsx",  firstrow(variables) sheet("gasto", replace)
restore

preserve
replace cantidad = cantidad*1000 if unit=="Kilogramos"	
gen pimp = gasto/cantidad

kdensity pimp if pimp<300

sort  food cantidad unit tamano 
order food cantidad unit tamano
collapse (mean) mean_pimp = pimp (p50) p50_pimp = pimp (count) n = pimp, by(food)
export excel "$cleaned\pimp_hmaiz.xlsx",  firstrow(variables) sheet("summary", replace)
restore


stop
/*==============================================================================
1:gen secondary variables
==============================================================================*/
// // generate per capita measures of spending and paid quantities
// gen gastopc = gasto_bol/miembros
// gen cantidadpc = comprado/miembros
// gen cantidadhpc = comprado_h/miembros

//generate implicit prices

gen pimp = gasto_bol/comprado
// gen pimph = gasto_bol/comprado_h

order bien unidad_medida tamano moneda week fecha_ultima_compra //cantidadpc cantidadhpc gastopc pimp pimph 

// // replace 0s ammounts just to avoid 0s at summary statistics
// replace gastopc =. if gastopc==0
// replace cantidadpc =. if cantidadpc==0
// replace cantidadhpc =. if cantidadhpc==0
replace pimp =. if pimp==0
// replace pimph =. if pimph==0




// labels
/*
goods_label:
           1 Arroz, harina de arroz
           4 Harina de maiz
          10 Carne de res (bistec, carne molida, carne para esmechar)
          28 Queso blanco
          33 Aceite
          68 Azucar
*/
/*

measure:
           1 Kilogramos
           2 Gramos
           3 Litros
           4 Mililitros
          10 Rebanada
          20 Taza
          30 Pieza (bistec,chuleta, similares)
          40 Pieza de pan
          50 Pieza (rueda, pescado entero)
          60 Paquete
          64 Paquete
          70 Plato
          80 Lata
          91 Cartón
          92 Medio cartón
         100 Docena
         110 Unidad
         120 Envase de plastico
         130 Bolsa
         140 Galón
         150 Frasco
         160 Torta (casabe)
         170 Caja
         180 Sobre
         190 Gavera  o caja
         200 Cajetillas
         210 Cucharada
         220 Barra
*/


// // quantities and prices agregated by quantity levels
// preserve
// collapse (mean) mean_pimp = pimp (min) min_pimp= pimp (p1) p1_pimp = pimp (p5) p5_pimp = pimp (p10) p10_pimp = pimp (p50) p50_pimp = pimp (p90) p90_pimp = pimp (p95) p95_pimp = pimp (p99) p99_pimp = pimp (max) max_pimp= pimp (count) n = pimp, by(bien unidad_medida tamano comprado)
// rename comprado cantidad
// drop if n==0
// sort bien unidad_medida tamano cantidad
// order bien unidad_medida tamano cantidad
// export excel "$cleaned\preciosimplicitos_sininfla.xlsx",  firstrow(variables) replace
// restore

// expenditure agregated by quantity levels
preserve



// summary of quantities per capita (DEPRECIATED)
// preserve
// collapse (mean) mean_cantidad = cantidadpc (p50) p50_cantidad = cantidadpc (min) min_cantidad= cantidadpc (p1) p1_cantidad = cantidadpc (p5) p5_cantidad = cantidadpc (p95) p95_cantidad = cantidadpc (p99) p99_cantidad = cantidadpc  (max) max_cantidad= cantidadpc (count) n = cantidadpc, by(bien unidad_medida tamano)
// drop if n==0
//
// sort bien unidad_medida tamano
// export excel "$cleaned\preciosimplicitos.xlsx",  firstrow(variables) sheet("q_sin_corregir_pc", replace)
// restore


// summary of corrected quantities per capita (DEPRECIATED)
// preserve
// collapse (mean) mean_cantidad = cantidadhpc (p50) p50_cantidad = cantidadhpc  (min) min_cantidad = cantidadhpc (p1) p1_cantidad = cantidadhpc (p5) p5_cantidad = cantidadhpc (p95) p95_cantidad = cantidadhpc (p99) p99_cantidad = cantidadhpc  (max) max_cantidad= cantidadpc (count) n = cantidadhpc, by(bien unidad_medida tamano)
// drop if n==0
// sort bien unidad_medida tamano
// export excel "$cleaned\preciosimplicitos.xlsx",  firstrow(variables) sheet("q_corregida_pc", replace)
// restore


// summary of expenditure  per capita (DEPRECIATED)
// preserve
// collapse (mean) mean_gasto = gastopc (p50) p50_gasto = gastopc  (min) min_gasto= gastopc (p1) p1_gasto = gastopc (p5) p5_gasto = gastopc (p95) p95_gasto = gastopc (p99) p99_gasto = gastopc (max) max_gasto = gastopc (count) n = gastopc, by(bien unidad_medida tamano moneda week fecha_ultima_compra)
// drop if n==0
// sort bien unidad_medida tamano moneda week fecha_ultima_compra
// export excel "$cleaned\preciosimplicitos.xlsx",  firstrow(variables) sheet("gasto_pc", replace)
// restore


// summary of uncorrected prices
// preserve
// collapse (mean) mean_pimp = pimp (p50) p50_pimp = pimp (min) min_pimp= pimp (p1) p1_pimp = pimp (p5) p5_pimp = pimp (p95) p95_pimp = pimp (p99) p99_pimp = pimp (max) max_pimp= pimp (count) n = pimp, by(bien unidad_medida tamano moneda  moneda week fecha_ultima_compra)
// drop if n==0
// sort bien unidad_medida tamano moneda week fecha_ultima_compra
// export excel "$cleaned\preciosimplicitos.xlsx",  firstrow(variables) sheet("p_implicito_sin_corregir", replace)
// restore


// // summary of corrected prices
// preserve
// collapse (mean) mean_pimph = pimph (p50) p50_pimph = pimph (min) min_pimph= pimph (p1) p1_pimph = pimph (p5) p5_pimph = pimph (p95) p95_pimph = pimph (p99) p99_pimph = pimph (max) max_pimph= pimph (count) n = pimph, by(bien unidad_medida tamano moneda moneda week fecha_ultima_compra)
// drop if n==0
// sort bien unidad_medida tamano moneda week fecha_ultima_compra
// export excel "$cleaned\preciosimplicitos.xlsx",  firstrow(variables) sheet("p_implicito_corregidos", replace)
// restore


stop
