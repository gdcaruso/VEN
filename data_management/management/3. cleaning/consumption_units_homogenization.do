/*===========================================================================
Puropose: This script cleans product consumption data to set them in an
homogeneous unit of mesure
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
Output:			product-hh level dataset with all products expresed in grams

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
		

		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN"
		}

	    if $lauta {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set raw data path
global datapath "$rootpath\data_management\output\merged"
global output "$rootpath\data_management\output\cleaned"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

// set paths to dta
global productdta "$datapath\product-hh.dta"
global householddta  "$datapath\household.dta"
global individualdta  "$datapath\individual.dta"

/*==============================================================================
1: Measurement unit homogeneization of food
==============================================================================*/

*************************************************************************************************************
*** COMPLETAR UNIDADES MAL IMPUTADAS (KG x GR o viceversa)
*** COMPLETAR TAMAñOS
*** COMPLETAR BIENES NO ESTANDARIZADOS
****************************************************************************************************************

// load food data
use  "$productdta", clear

// drop if its not food
drop if grupo_bien != 1

// drop cigarrettes
drop if bien >= 90

//drop no consumption
keep if consumio==1 & cantidad>0 & (cantidad!=.|cantidad!=.a)


/*
019
          23 Noviembre 2019
          24 Diciembre 2019
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
          91 Tabaco (unidades)
          92 Otro (especifique)
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

/*(************************************************************************************************************************************************* 
* 1: Correction of wrong values
*************************************************************************************************************************************************)*/
// Correct values wrongly expressed in a measure
// example 1 gram of Flour -> 1 kilo, 500 kilos of Flour -> 500 gramos
// COMPLETAR TEMPORARY 

// kilos to grams
replace unidad_medida=2 if cantidad>= 50 & unidad_medida==1
// grams to kilos
replace unidad_medida=1 if cantidad<= 10 & unidad_medida==2 
// militers to liters
replace unidad_medida=4 if cantidad>= 50 & unidad_medida==3 
// liters to militers
replace unidad_medida=3 if cantidad<= 10 & unidad_medida==4
// envases to milititers
replace unidad_medida=4 if cantidad>=50 & unidad_medida==120


/*(************************************************************************************************************************************************* 
* 1: From multiple measures to gram, liters or unit
*************************************************************************************************************************************************)*/



// homogeneous unit #1: gram
gen cantidad_3 = cantidad if unidad_medida == 2
gen unidad_3 = 1 if unidad_medida == 2

// kilogram to gram
replace cantidad_3 = cantidad*1000 if unidad_medida == 1
replace unidad_3 = 1 if unidad_medida == 1


// homogeneous unit #2: mililiters
replace cantidad_3 = cantidad if unidad_medida == 4
replace unidad_3 = 2 if unidad_medida == 4

// liters to mililiters
replace cantidad_3 = cantidad*1000 if unidad_medida == 3
replace unidad_3 = 2 if unidad_medida == 3

// gallon to mililiters
replace cantidad_3 = cantidad*4546.09 if unidad_medida == 140
replace unidad_3 = 2 if unidad_medida == 140

// homogeneous unit #3: units
replace cantidad_3 = cantidad if unidad_medida == 110
replace unidad_3 = 3 if unidad_medida == 110

// dozens to units
replace cantidad_3 = cantidad*12 if unidad_medida == 100
replace unidad_3 = 3 if unidad_medida == 100



/*(************************************************************************************************************************************************* 
* 1: product specific measure transformation
*************************************************************************************************************************************************)*/

// many products have multiple size of presentation (large, medium, small)
// in some cases where we cant find a benchmark each different
// presentation, we just use the available information
 

// "rebanada de pan" 23g
// using data from Hernandez et al (2015) COMPLETAR BIBLIOGRAFIA DEBAJO
replace cantidad_3 = cantidad*23 if (unidad_medida == 40 & bien==6)
replace unidad_3 = 1 if (unidad_medida == 40 & bien==6)


//"galletas"
// based on Venezuelean famous brands' packaging
// "paquete pequeño" 25g
replace cantidad_3 = cantidad*25 if (unidad_medida == 60 & bien== 3 & tamano==3)
replace unidad_3 = 1 if (unidad_medida == 60 & bien==3 & tamano== 3)

// "paquete mediano" 108g
replace cantidad_3 = cantidad*108 if (unidad_medida == 60 & bien== 3 & tamano==2)
replace unidad_3 = 1 if (unidad_medida == 60 & bien== 3 & tamano== 2)

// "paquete grande" 240g
replace cantidad_3 = cantidad*240 if (unidad_medida == 60 & bien== 3 & tamano==1)
replace unidad_3 = 1 if (unidad_medida == 60 & bien== 3 & tamano==1)

// "pescado enlatado" 
// "lata" (1) to gram (129)
// Atunmar standard size 
replace cantidad_3 = cantidad*129 if unidad_medida == 80 & bien==19
replace unidad_3 = 1 if (unidad_medida == 80 & bien==19)

// Any other fish in can units
// "lata" (1) to gram (129)
// // Atunmar standard size 
replace cantidad_3 = cantidad*270 if unidad_medida == 80 & inrange(bien,20, 23)
replace unidad_3 = 1 if unidad_medida == 80 & bien== 80 & inrange(bien,20, 23)

// "Margarina/Mantequilla" in "Lata"
// "lata" (1) to gram (360)
// using "Lactuario de Maracay mantequilla" standard size as benchmark
replace cantidad_3 = cantidad*360 if unidad_medida == 80 & (bien==34)
replace unidad_3 = 1 if unidad_medida == 80 & (bien==34)

// "Huevos" in "carton" and "medio carton"
// "carton" (1) to unit (30)
// "medio carton" (1) to unit (15)
replace cantidad_3 = cantidad*30 if unidad_medida == 91 & (bien==31) & cantidad<=10
replace cantidad_3 = cantidad if unidad_medida == 91 & (bien==31) & cantidad>10

replace cantidad_3 = cantidad*15 if unidad_medida == 92 & (bien==31) & cantidad<=10
replace cantidad_3 = cantidad if unidad_medida == 92 & (bien==31) & cantidad>10

replace cantidad_3 = cantidad*15 if unidad_medida == 100 & (bien==31) & cantidad<12
replace cantidad_3 = cantidad*15 if unidad_medida == 100 & (bien==31) & cantidad>=12


replace unidad_3 = 3 if (unidad_medida == 91|unidad_medida == 92) & bien== 31

// "Casabe" in "torta" 
// "torta" (1) to gramos (283)
// based on torta casaba "Guarani 283 gr." (Dominicana)
replace cantidad_3 = cantidad*283 if (unidad_medida == 160 & bien==66)
replace unidad_3 = 1 if (unidad_medida == 160 & bien==66)


// "Carne enlatada" in "lata" 
// "lata" 340g
// based on SPAM standard size, a US brand with strong presence in Venezuela
replace cantidad_3 = cantidad*340 if (unidad_medida == 80 & bien==16)
replace unidad_3 = 1 if (unidad_medida == 80 & bien==16)

//"Suero"
// "envase de plastico" 900ml
replace cantidad_3 = cantidad*900 if (unidad_medida == 120 & bien == 30)
replace unidad_3 = 2 if (unidad_medida==120 & bien==30)

//"Aceite"
// "Cucharada" "grande" (10g)
// "Cucharada" "pequeña" (5g)
// based on Hernandez et al (2015)
replace cantidad_3 = cantidad*10 if (unidad_medida == 210 & bien == 33 & tamano==1)
replace cantidad_3 = cantidad*5 if (unidad_medida == 210 & bien == 33 & tamano==3)
replace unidad_3 = 1 if (unidad_medida==210 & bien==33)


//"Manteca"
// "Cucharada" "grande" (10g)
// "Cucharada" "pequeña" (5g)
// based on Hernandez et al (2015)
replace cantidad_3 = cantidad*10 if (unidad_medida == 210 & bien == 34 & tamano==1)
replace cantidad_3 = cantidad*5 if (unidad_medida == 210 & bien == 34 & tamano==3)
replace unidad_3 = 1 if (unidad_medida==210 & bien==34)

//"Manteca/Mantequilla"
// "Barra" (200g)
// based on brand Los Andes product "mantequilla en barra"
replace cantidad_3 = cantidad*200 if (unidad_medida == 220 & bien == 34)
replace unidad_3 = 1 if (unidad_medida==220 & bien==34)

//"Mayonesa"
// "Frasco" (445g)
// based on brand Dovo
replace cantidad_3 = cantidad*445 if (unidad_medida == 150 & bien == 35)
replace unidad_3 = 1 if (unidad_medida==150 & bien==35)

//"Te"
// "caja" (20 u)
// based on brand Te Negro
replace cantidad_3 = cantidad*10 if (unidad_medida == 170 & bien == 75)
replace unidad_3 = 3 if (unidad_medida== 170 & bien==75)

//"Concentrados"
// "caja" (8 u)
// based on "caja cubitos 8 u) brand Maggi
replace cantidad_3 = cantidad*8 if (unidad_medida == 170 & bien == 80)
replace unidad_3 = 3 if (unidad_medida== 170 & bien==80)

//"Concentrados"
// "sobre" (65 g)
// based on "sopa de pollo" (brand Maggi) 
replace cantidad_3 = cantidad*65 if (unidad_medida == 180 & bien == 80)
replace unidad_3 = 1 if (unidad_medida== 180 & bien==80)

//"Salsa de tomate"
// "frasco" (397g)
// based on brand Pampero
replace cantidad_3 = cantidad*397 if (unidad_medida == 150 & bien == 81)
replace unidad_3 = 1 if (unidad_medida== 150 & bien==81)

//"Bebidas alcoholicas"
// "gavera o caja" (36 u)
// based on brand Polar
replace cantidad_3 = cantidad*36 if (unidad_medida == 190 & bien == 88)
replace unidad_3 = 3 if (unidad_medida== 190 & bien==88)

//"Mayonesa"
// "Cucharada" "grande" (10g)
// "Cucharada" "pequeña" (5g)
// based on Hernandez et al (2015)
replace cantidad_3 = cantidad*10 if (unidad_medida == 210 & bien == 35 & tamano==1)
replace cantidad_3 = cantidad*5 if (unidad_medida == 210 & bien == 35 & tamano==3)
replace unidad_3 = 1 if (unidad_medida==210 & bien==35)

tab bien unidad_medida if cantidad_3==. & unidad_3==.
tab bien unidad_medida if cantidad_3==. & unidad_3==., nolab

/*(************************************************************************************************************************************************* 
* 2: From gram, liters or unit to grams
*************************************************************************************************************************************************)*/
tab bien unidad_3 [fw=cantidad]
tab bien unidad_3 [fw=cantidad], nolab

// generates an homogenous unit of measure in grams
gen cantidad_h = .
replace cantidad_h = cantidad_3 if unidad_3==1

// converts militiers into grams using density of liquids

// "Leche"
// density = 1.032 gr/ml https://es.wikipedia.org/wiki/Leche
replace cantidad_h = cantidad_3*1.032 if unidad_3==2 & bien==25

// "Suero"
// density = 1.024 gr/ml http://www.actaf.co.cu/revistas/Revista%20ACPA/2009/REVISTA%2003/10%20SUERO%20QUESO.pdf
replace cantidad_h = cantidad_3*.92 if unidad_3==2 & bien==30

// "Aceite"
// density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/
replace cantidad_h = cantidad_3*.92 if unidad_3==2 & bien==33


// "Otros grasas y aceites"
// density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/
replace cantidad_h = cantidad_3*1.032 if unidad_3==2 & bien==36


// "Endulzante" 
// density = 1.04 gr/ml used coca cola density 
replace cantidad_h = cantidad_3*1.04 if unidad_3==2 & bien==70

// "Miel"
// density = 1,406 gr/ml  http://guadanatur.es/caracteristicas-fisicas-de-la-miel/
replace cantidad_h = cantidad_3*1.406 if unidad_3==2 & bien==71

// "Melaza"
// density = 1,406 gr/ml // used the same as honey 
replace cantidad_h = cantidad_3*1.406 if unidad_3==2 & bien==72

// "Te"
// transformed to grams of dry tea using 250 ml per tea bag, and 2 grams per tea bag 
replace cantidad_h = cantidad_3/250*2 if unidad_3==2 & bien==75

// "Leche chocolatada"
// density = 1,032 gr/ml used milk density as its it's main ingredient 
replace cantidad_h = cantidad_3*1.032 if unidad_3==2 & bien==76

// "Jugo"
// density = 1,052 gr/ml used jugo de naranja in http://repositorio.uncp.edu.pe/bitstream/handle/UNCP/1876/Aucayauri%20Meza.pdf?sequence=1&isAllowed=y
replace cantidad_h = cantidad_3*1.053 if unidad_3==2 & bien==84

// "Agua"
// density = 1 gr/ml
replace cantidad_h = cantidad_3*1 if unidad_3==2 & bien==85

// "Gaseosa"
// density = 1,04 gr/ml using regular coca cola density https://cluster-divulgacioncientifica.blogspot.com/2009/05/experimento-de-las-coca-colas.html
replace cantidad_h = cantidad_3*1.04 if unidad_3==2 & bien==86

// "Otras bebidas"
// density = 1,04 gr/ml using regular coca cola density https://cluster-divulgacioncientifica.blogspot.com/2009/05/experimento-de-las-coca-colas.html
replace cantidad_h = cantidad_3*1.04 if unidad_3==2 & bien==87

// "Bebidas alcoholicas"
// density = 1,10 gr/ml using mean of cervezas http://www.cervezadeargentina.com.ar/articulos/Uso%20del%20dens%C3%ADmetro.html
replace cantidad_h = cantidad_3*1.1 if unidad_3==2 & bien==88

// turns units into grams using representative weights
// "Huevos"
// used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
// weight = 52.5 gr/unit
replace cantidad_h = cantidad_3*52.5 if unidad_3==3 & bien==31

// "Cambur"
// used medium size mean https://www.foodstandards.gov.au/science/monitoringnutrients/ausnut/foodmeasures/Pages/-Fruits-and-vegetable-measures-program---data-table.aspx
// weight = 151 gr/unit
replace cantidad_h = cantidad_3*151 if unidad_3==3 & bien==37


// "Mangos"
// used medium size mean https://www.foodstandards.gov.au/science/monitoringnutrients/ausnut/foodmeasures/Pages/-Fruits-and-vegetable-measures-program---data-table.aspx
// weight = 300 gr/unit
replace cantidad_h = cantidad_3*300 if unidad_3==3 & bien==38


// "Platanos"
// used medium size https://www.consumer.es/alimentacion/cuantas-calorias-tiene-un-platano.html
// weight = 90 gr/unit
replace cantidad_h = cantidad_3*90 if unidad_3==3 & bien==39

// "Lechosa"
// used papaya small size https://fdc.nal.usda.gov/fdc-app.html#/food-details/169926/nutrients
// weight = 157 gr/unit
replace cantidad_h = cantidad_3*157 if unidad_3==3 & bien==40


// "Guayaba"
// used guayaba http://huitoto.udea.edu.co/FrutasTropicales/guayaba.html
// weight = 61.3 gr/unit
replace cantidad_h = cantidad_3*61.3 if unidad_3==3 & bien==41

// "Tomates"
// used toamto italian https://fdc.nal.usda.gov/fdc-app.html#/food-details/342502/nutrients
// weight = 62 gr/unit
replace cantidad_h = cantidad_3*62 if unidad_3==3 & bien==43

// "Aguacate"
// used avocado florida https://fdc.nal.usda.gov/fdc-app.html#/food-details/341528/nutrients
// weight = 304 gr/unit
replace cantidad_h = cantidad_3*304 if unidad_3==3 & bien==44

// "Aji dulce, pimenton"
// used sweet pepper medium https://fdc.nal.usda.gov/fdc-app.html#/food-details/342633/nutrients
// weight = 119 gr/unit
replace cantidad_h = cantidad_3*119 if unidad_3==3 & bien==45

// "Cebolla"
// used onion medium https://fdc.nal.usda.gov/fdc-app.html#/food-details/342633/nutrients
// weight = 110 gr/unit
replace cantidad_h = cantidad_3*110 if unidad_3==3 & bien==46


// "Lechuga"
// used boston https://fdc.nal.usda.gov/fdc-app.html#/food-details/342619/nutrients
// weight = 163 gr/unit
replace cantidad_h = cantidad_3*163 if unidad_3==3 & bien==48

// "Berenjena"
// used globosa mean https://verduras.consumer.es/berenjena/introduccion
// weight = 270 gr/unit
replace cantidad_h = cantidad_3*270 if unidad_3==3 & bien==49

// "Zanahoria"
// used medium https://fdc.nal.usda.gov/fdc-app.html#/food-details/342354/nutrients
// weight = 61 gr/unit
replace cantidad_h = cantidad_3*61 if unidad_3==3 & bien==50

// "Cebollin, ajoporro, etc."
// searched for habitual size of product in internet. example https://www.lafruteria.es/verdura/285-cebollino-bandeja.html
// weight = 80 gr/unit
replace cantidad_h = cantidad_3*80 if unidad_3==3 & bien==51

// "Te"
//weight = 2 gr/unit
replace cantidad_h = cantidad_3*2 if unidad_3==3 & bien==75

// "Concentrados cubitos"
//weight = 11.5 gr/unit used maggi brand
replace cantidad_h = cantidad_3*11.5 if unidad_3==3 & bien==80

// "Bebidas Alocholicas"
// used Polar 330 ml as reference, that's the beer size of x36 package called "gaveras" and previous 1.10 density
//weight = 330*1.1 gr/unit
replace cantidad_h = cantidad_3*330*1.1 if unidad_3==3 & bien==88


/*(************************************************************************************************************************************************* 
* 1: Quality control
*************************************************************************************************************************************************)*/


//products not homogenized

tab bien if cantidad_h==.

compress

/*(************************************************************************************************************************************************* 
* Frequency of expenditure
*************************************************************************************************************************************************)*/
//
// *---Generate a variable to identify the mode in the frequency of expenditure
// 	*Using the date of the last shopping
// 	bysort bien: egen frecuencia=mode(fecha_ultima_compra)
// 	*Label values
// 	label def frecuencia 1 "Ayer" 2 "Últimos 7 días" 3 "Últimos 15 días" 4 "Más de 15 días" 5 "Nunca"
// 	label val frecuencia frecuencia
// *---Generate a variable to share comsuption over expenditure in the last 7 days
// 	//gen over_consumption=
// *---Generate a dummy variable to identify the products frecuency of expenditure
// 	bysort bien: gen seven=1 if frecuencia==2 
//	
//	
*---Generate a variable to identify the mode quantity 
	//bysort bien fecha_ultima_compra: egen frec_cantidad=mode(cantidad_h), maxmode
	
/*(************************************************************************************************************************************************* 
* Save final database
*************************************************************************************************************************************************)*/
	
// now, mostly of the products are expressed in grams
save "$output\product_hh_homogeneous.dta", replace

