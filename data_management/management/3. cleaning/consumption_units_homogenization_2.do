/*===========================================================================
Puropose: New homogenization of products, based on direct answers
in ENCOVI and almost no priors
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
		global lauta  0
		
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


/*==============================================================================
1: Any unit to grams
==============================================================================*/

//gen homgeneous unit
gen cantidad_h =.


// food = Arroz, harina de arroz (1)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==1 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==1 & unidad_medida==1 & cantidad>=50


// food = Arroz, harina de arroz (1)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==1 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==1 & unidad_medida==2 & cantidad >=50


// food = Avena, avena en hojuelas, harina de avena (2)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==2 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==2 & unidad_medida==1 & cantidad >=50


// food = Avena, avena en hojuelas, harina de avena (2)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==2 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==2 & unidad_medida==2 & cantidad >=50


// food = Galletas, dulces, saladas, integrales (3)
// unit = Paquete (60)
// size = Grande (1)

*based on Galleta Maria Paquete de 12 250g (AB*)
replace cantidad_h = cantidad*250 if bien==3 & unidad_medida==60 & tamano==1  & cantidad<50
replace cantidad_h = cantidad if bien==3 & unidad_medida==60 & tamano==1 & cantidad >=50

// food = Galletas, dulces, saladas, integrales (3)
// unit = Paquete (60)
// size = Mediana (2)

*based on Galleta de Soda Paquete de 6 240g (AB)
replace cantidad_h = cantidad*240 if bien==3 & unidad_medida==60  & tamano==2 & cantidad<50
replace cantidad_h = cantidad if bien==3 & unidad_medida==60 & tamano==2 & cantidad >=50


// food = Galletas, dulces, saladas, integrales (3)
// unit = Paquete (60)
// size = Pequena (3)

*based on Galleta Individual de Soda 40g (AB)
replace cantidad_h = cantidad*40 if bien==3 & unidad_medida==60  & tamano==3 & cantidad<50
replace cantidad_h = cantidad if bien==3 & unidad_medida==60 & tamano==3 & cantidad >=50


// food = Harina de maiz (4)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==4 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==4 & unidad_medida==1 & cantidad >=50


// food = Harina de maiz (4)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==4 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==4 & unidad_medida==2 & cantidad >=50


// food = Maiz en granos (5)
// unit = Kilogramos (1)
// size = no size

*ALERTA: demasiados valores entre 20 y 50. Kilos o gramos?
replace cantidad_h = cantidad*1000 if bien==5 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==5 & unidad_medida==1 & cantidad >=50


// food = Maiz en granos (5)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==5 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==5 & unidad_medida==2 & cantidad >=50


// food = Pan de trigo (6)
// unit = Pieza de pan (40)
// size = Grande (campesino) (4)

*based on Campesino size 250g (AB)
replace cantidad_h = cantidad*250 if bien==6 & unidad_medida==40  & tamano==4


// food = Pan de trigo (6)
// unit = Pieza de pan (40)
// size = Mediano ( canilla) (5)

*based on Canilla size 130g (AB)
replace cantidad_h = cantidad*130 if bien==6 & unidad_medida==40  & tamano==5


// food = Pan de trigo (6)
// unit = Pieza de pan (40)
// size = Pequeño (Francés) (6)

*based on Frances size 35g (ME)
*https://serviciodesalud.pucp.edu.pe/noticia/el-pan-engorda-mitos-de-la-nutricion-moderna/

replace cantidad_h = cantidad*35 if bien==6 & unidad_medida==40  & tamano==5


// food = Pan de trigo (6)
// unit = Pieza de pan (40)
// size = Pequeño (Francés) (6)

*based on Frances size 35g (ME*)
*https://serviciodesalud.pucp.edu.pe/noticia/el-pan-engorda-mitos-de-la-nutricion-moderna/

replace cantidad_h = cantidad*35 if bien==6 & unidad_medida==40  & tamano==6 & cantidad<50
replace cantidad_h = cantidad if bien==6 & unidad_medida==40  & tamano==6 & cantidad>=50 


// food = Pastas alimenticias (7)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==7 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==7 & unidad_medida==1 & cantidad>=50 


// food = Pastas alimenticias (7)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==7 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==7 & unidad_medida==2 & cantidad>=50 


// food = Fororo (8)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==8 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==8 & unidad_medida==1 & cantidad>=50 


// food = Carne de res (bistec, carne molida, carne para esmechar) (10)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==10 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==10 & unidad_medida==1 & cantidad>=50 


// food = Carne de res (bistec, carne molida, carne para esmechar) (10)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==10 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==10 & unidad_medida==2 & cantidad>=50 


// food = Visceras (higado, riñonada, corazon, asadura, morcillas) (11)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==11 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==11 & unidad_medida==1 & cantidad>=50 

// food = Visceras (higado, riñonada, corazon, asadura, morcillas) (11)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==11 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==11 & unidad_medida==2 & cantidad>=50 


// food = Chuleta de cerdo ahumada (12)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==12 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==12 & unidad_medida==1 & cantidad>=50 


// food = Chuleta de cerdo ahumada (12)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==12 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==12 & unidad_medida==2 & cantidad>=50 


// food = Carne de cerdo fresca (chuleta, costilla, pernil) (13)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==13 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==13 & unidad_medida==1 & cantidad>=50


// food = Carne de cerdo fresca (chuleta, costilla, pernil) (13)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==13 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==13 & unidad_medida==2 & cantidad>=50


// food = Hueso de res, pata de res, pata de pollo (14)
// unit = Kilogramos (1)
// size = no size

*ALERT: what we shoud take as representative for caloric supply? Pata de pollo?
replace cantidad_h = cantidad*1000 if bien==14 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==14 & unidad_medida==1 & cantidad>=50


// food = Hueso de res, pata de res, pata de pollo (14)
// unit = Gramos (2)
// size = no size

*ALERT: what we shoud take as representative for caloric supply? Pata de pollo?
replace cantidad_h = cantidad*1000 if bien==14 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==14 & unidad_medida==2 & cantidad>=50


// food = Chorizo, jamon, mortadela y otros embutidos (15)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==15 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==15 & unidad_medida==1 & cantidad>=50


// food = Chorizo, jamon, mortadela y otros embutidos (15)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==15 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==15 & unidad_medida==2 & cantidad>=50


// food = Carne enlatada (16)
// unit = Lata (80)
// size = Grande (1)

*based on Carne de almuerzo Goya 340g (ME)
* https://articulo.mercadolibre.com.ve/MLV-553748508-carne-de-almuerzo-spam-190g-caja-12-latas-goya-340g-24-latas-_JM?quantity=1#position=1&type=item&tracking_id=8a69699a-eaed-4743-9ed1-4eff7c0209a5 

replace cantidad_h = cantidad*340 if bien==16 & unidad_medida==80 & tamano==1


// food = Carne enlatada (16)
// unit = Lata (80)
// size = Mediana (2)

*based on Carne de almuerzo SPAM 190g (AB)
replace cantidad_h = cantidad*190 if bien==16 & unidad_medida==80 & tamano==2


// food = Carne enlatada (16)
// unit = Lata (80)
// size = Pequeña (3)

*based on Carne de almuerzo SPAM 190g (AB)
replace cantidad_h = cantidad*190 if bien==16 & unidad_medida==80 & tamano==3


// food = Carne de pollo (17)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==17 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==17 & unidad_medida==1 & cantidad>=50


// food = Carne de pollo (17)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==17 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==17 & unidad_medida==2 & cantidad>=50


// food = Pescado enlatado (19)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==19 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==19 & unidad_medida==1 & cantidad>=50


// food = Pescado enlatado (19)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==19 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==19 & unidad_medida==2 & cantidad>=50

// food = Pescado enlatado (19)
// unit = Lata (80)
// size = Grande (1)
*based on Atun Eveba grande 400g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*400 if bien==19 & unidad_medida==80 & tamano==1


// food = Pescado enlatado (19)
// unit = Lata (80)
// size = Mediana (2)
*based on Atun Eveba grande 170g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*170 if bien==19 & unidad_medida==80 & tamano==2

// food = Pescado enlatado (19)
// unit = Lata (80)
// size = Pequeña (3)
*based on Atun Eveba grande 140g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*140 if bien==19 & unidad_medida==80 & tamano==3


// food = Sardinas frescas/congeladas (20)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==20 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==20 & unidad_medida==1 & cantidad>=50


// food = Sardinas frescas/congeladas (20)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==20 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==20 & unidad_medida==2 & cantidad>=50

//
// food = Sardinas frescas/congeladas (20)
// unit = Lata (80)
// size = Grande (1)
*based on ? 360g (AB)
replace cantidad_h = cantidad*360 if bien==20 & unidad_medida==80 & tamano==1


// food = Sardinas frescas/congeladas (20)
// unit = Lata (80)
// size = Mediana (2)
*based on ? 170g (AB)
replace cantidad_h = cantidad*170 if bien==20 & unidad_medida==80 & tamano==2


// food = Sardinas frescas/congeladas (20)
// unit = Lata (80)
// size = Pequeña (3)
*based on ? 170g (AB)
replace cantidad_h = cantidad*170 if bien==20 & unidad_medida==80 & tamano==3


// food = Atun fresco/congelado (21)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==21 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==21 & unidad_medida==1 & cantidad>=50


// food = Atun fresco/congelado (21)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==21 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==21 & unidad_medida==2 & cantidad>=50


// food = Atun fresco/congelado (21)
// unit = Lata (80)
// size = Grande (1)
*based on Atun Eveba grande 400g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*400 if bien==21 & unidad_medida==80 & tamano==1

// food = Atun fresco/congelado (21)
// unit = Lata (80)
// size = Mediana (2)
*based on Atun Eveba grande 170g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*170 if bien==21 & unidad_medida==80 & tamano==2


// food = Atun fresco/congelado (21)
// unit = Lata (80)
// size = Pequeña (3)
*based on Atun Eveba grande 140g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/
replace cantidad_h = cantidad*140 if bien==21 & unidad_medida==80 & tamano==3


// food = Pescado fresco (22)
// unit = Kilogramos (1)
// size = no size

replace cantidad_h = cantidad*1000 if bien==22 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==22 & unidad_medida==1 & cantidad>=50


// food = Pescado fresco (22)
// unit = Gramos (2)
// size = no size

replace cantidad_h = cantidad*1000 if bien==22 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==22 & unidad_medida==2 & cantidad>=50


// food = Pescado fresco (22)
// unit = Lata (80)
// size = Grande (1)
*based on Atun Eveba grande 400g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*400 if bien==22 & unidad_medida==80 & tamano==1

// food = Pescado fresco (22)
// unit = Lata (80)
// size = Mediana (2)
*based on Atun Eveba grande 170g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/

replace cantidad_h = cantidad*170 if bien==22 & unidad_medida==80 & tamano==2

// food = Pescado fresco (22)
// unit = Lata (80)
// size = Chica (3)
*based on Atun Eveba grande 140g (ME)
*https://www.notiactual.com/que-esta-comiendo-el-venezolano/
replace cantidad_h = cantidad*140 if bien==22 & unidad_medida==80 & tamano==3


// food = Pescado seco/salado (23)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==23 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==23 & unidad_medida==1 & cantidad>=50


// food = Pescado seco/salado (23)
// unit = Gramos (2)
// size = no size
replace cantidad_h = cantidad*1000 if bien==23 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==23 & unidad_medida==2 & cantidad>=50


// food = Leche liquida, completa o descremada (25)
// unit = Litros (3)
// size = no size
* density = 1.032 gr/ml https://es.wikipedia.org/wiki/Leche (ME)
replace cantidad_h = cantidad*1000*1.032 if bien==25 & unidad_medida==3 & cantidad<50
replace cantidad_h = cantidad*1.032 if bien==25 & unidad_medida==3 & cantidad>=50


// food = Leche liquida, completa o descremada (25)
// unit = Mililitros (4)
// size = no size
replace cantidad_h = cantidad*1000*1.032 if bien==25 & unidad_medida==4 & cantidad<50
replace cantidad_h = cantidad*1.032 if bien==25 & unidad_medida==4 & cantidad>=50


// food = Leche liquida, completa o descremada (25)
// unit = Envase de plastico (120)
// size = 0.375 litro (7)
replace cantidad_h = cantidad*375*1.032 if bien==25 & unidad_medida==120 & tamano==7


// food = Leche liquida, completa o descremada (25)
// unit = Envase de plastico (120)
// size = 1 litro (9)
replace cantidad_h = cantidad*1000*1.032 if bien==25 & unidad_medida==120 & tamano==9


// food = Leche liquida, completa o descremada (25)
// unit = Envase de plastico (120)
// size = 2 litros (10)
replace cantidad_h = cantidad*2000*1.032 if bien==25 & unidad_medida==120 & tamano==10


// food = Leche en polvo, completa o descremada (26)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==26 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==26 & unidad_medida==1 & cantidad>=50


// food = Leche en polvo, completa o descremada (26)
// unit = Gramos (2)
// size = no size
replace cantidad_h = cantidad*1000 if bien==26 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==26 & unidad_medida==2 & cantidad>=50



// food = Queso requeson, ricota (27)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==27 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==27 & unidad_medida==1 & cantidad>=50


// food = Queso requeson, ricota (27)
// unit = Gramos (2)
// size = no size
*ALERT: treshold to move kilos to grams changed (30)
replace cantidad_h = cantidad*1000 if bien==27 & unidad_medida==2 & cantidad<30
replace cantidad_h = cantidad if bien==27 & unidad_medida==2 & cantidad>=30


// food = Queso blanco (28)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==28 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==28 & unidad_medida==1 & cantidad>=50


// food = Queso blanco (28)
// unit = Gramos (2)
// size = no size
*ALERT: treshold to move kilos to grams changed (14)
replace cantidad_h = cantidad*1000 if bien==28 & unidad_medida==2 & cantidad<14
replace cantidad_h = cantidad if bien==28 & unidad_medida==2 & cantidad>=14


// food = Queso amarillo (29)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==29 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==29 & unidad_medida==1 & cantidad>=50


// food = Queso amarillo (29)
// unit = Gramos (2)
// size = no size
replace cantidad_h = cantidad*1000 if bien==29 & unidad_medida==2 & cantidad<50
replace cantidad_h = cantidad if bien==29 & unidad_medida==2 & cantidad>=50


// food = Suero, natilla, nata (30)
// unit = Litros (3)
// size = no size
* density = 1.024 gr/ml http://www.actaf.co.cu/revistas/Revista%20ACPA/2009/REVISTA%2003/10%20SUERO%20QUESO.pdf (ME)
replace cantidad_h = cantidad*1000*1.024 if bien==30 & unidad_medida==3



// food = Suero, natilla, nata (30)
// unit = Mililitros (4)
// size = no size
* density = 1.024 gr/ml http://www.actaf.co.cu/revistas/Revista%20ACPA/2009/REVISTA%2003/10%20SUERO%20QUESO.pdf (ME)
replace cantidad_h = cantidad*1.024 if bien==30 & unidad_medida==4


// food = Suero, natilla, nata (30)
// unit = Envase de plastico (120)
// size = 0.375 litro (7)
* density = 1.024 gr/ml http://www.actaf.co.cu/revistas/Revista%20ACPA/2009/REVISTA%2003/10%20SUERO%20QUESO.pdf (ME)
replace cantidad_h = cantidad*375*1.024 if bien==30 & unidad_medida==120 & tamano==7

// food = Suero, natilla, nata (30)
// unit = Envase de plastico (120)
// size = 0.5 litro (8)
* density = 1.024 gr/ml http://www.actaf.co.cu/revistas/Revista%20ACPA/2009/REVISTA%2003/10%20SUERO%20QUESO.pdf
replace cantidad_h = cantidad*500*1.024 if bien==30 & unidad_medida==120 & tamano==8


// food = Suero, natilla, nata (30)
// unit = Envase de plastico (120)
// size = 1 litro (9)
* density = 1.024 gr/ml http://www.actaf.co.cu/revistas/Revista%20ACPA/2009/REVISTA%2003/10%20SUERO%20QUESO.pdf (ME)
replace cantidad_h = cantidad*1000*1.024 if bien==30 & unidad_medida==120 & tamano==9

// food = Huevos (unidades) (31)
// unit = Cartón (91)
// size = no size
* used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
* weight = 52.5 gr/unit (ME)
replace cantidad_h = cantidad*36*52.5 if bien==31 & unidad_medida==91 & cantidad<=5
replace cantidad_h = cantidad*52.5 if bien==31 & unidad_medida==91 & cantidad>5

// food = Huevos (unidades) (31)
// unit = Medio cartón (92)
// size = no size
* used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
* weight = 52.5 gr/unit (ME)
replace cantidad_h = cantidad*18*52.5 if bien==31 & unidad_medida==92 & cantidad<=5
replace cantidad_h = cantidad*52.5 if bien==31 & unidad_medida==92 & cantidad>5 & cantidad<36
replace cantidad_h = cantidad if bien==31 & unidad_medida==92 & cantidad>=100

// food = Huevos (unidades) (31)
// unit = Docena (100)
// size = no size
* used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
* weight = 52.5 gr/unit (ME)
replace cantidad_h = cantidad*12*52.5 if bien==31 & unidad_medida==100 & cantidad<10
replace cantidad_h = cantidad*52.5 if bien==31 & unidad_medida==100 & cantidad>=10


// food = Huevos (unidades) (31)
// unit = Unidad (110)
// size = no size
* used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
* weight = 52.5 gr/unit (ME)
replace cantidad_h = cantidad*52.5 if bien==31 & unidad_medida==110 & cantidad<200

// food = Aceite (33)
// unit = Litros (3)
// size = no size
*density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/ (ME)
replace cantidad_h = cantidad*0.92*1000 if bien==33 & unidad_medida==3 & cantidad<50
replace cantidad_h = cantidad*0.92 if bien==33 & unidad_medida==3 & cantidad>=50


// food = Aceite (33)
// unit = Mililitros (4)
// size = no size
*density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/ (ME)
*ALERT: treshold changed (10)
replace cantidad_h = cantidad*0.92*1000 if bien==33 & unidad_medida==4 & cantidad<10
replace cantidad_h = cantidad*0.92 if bien==33 & unidad_medida==4 & cantidad>=10


// food = Aceite (33)
// unit = Cucharada (210)
// size = Grande (1)
* "Cucharada" "grande" (10g) based on Hernandez et al (2015)* (ME)
replace cantidad_h = cantidad*10 if bien==33 & unidad_medida==210 & tamano==1


// food = Aceite (33)
// unit = Cucharada (210)
// size = Pequeña (3)
* "Cucharada" "pequena" (5g) based on Hernandez et al (2015)* (ME)
replace cantidad_h = cantidad*5 if bien==33 & unidad_medida==210 & tamano==3 & cantidad<100


// food = Margarina/Mantequilla (34)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==34 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==34 & unidad_medida==1 & cantidad>=50


// food = Margarina/Mantequilla (34)
// unit = Gramos (2)
// size = no size
*ALERT: treshold changed
replace cantidad_h = cantidad*1000 if bien==34 & unidad_medida==2 & cantidad<10
replace cantidad_h = cantidad if bien==34 & unidad_medida==2 & cantidad>=10


// food = Margarina/Mantequilla (34)
// unit = Lata (80)
// size = Grande (1)
* Pote grande de margarina 1000g (AB) 
replace cantidad_h = cantidad*1000 if bien==34 & unidad_medida==80 & tamano==1 & cantidad<10


// food = Margarina/Mantequilla (34)
// unit = Lata (80)
// size = Mediana (2)
* Pote mediano de margarina 500g (AB) 
replace cantidad_h = cantidad*500 if bien==34 & unidad_medida==80 & tamano==2 & cantidad<10
replace cantidad_h = cantidad if bien==34 & unidad_medida==80 & tamano==2 & cantidad>=10

// food = Margarina/Mantequilla (34)
// unit = Lata (80)
// size = Pequeña (3)
* Pote pequeno margarina 105g (AB)
replace cantidad_h = cantidad*105 if bien==34 & unidad_medida==80 & tamano==3 & cantidad<10
replace cantidad_h = cantidad if bien==34 & unidad_medida==80 & tamano==3 & cantidad>=10


// food = Margarina/Mantequilla (34)
// unit = Cucharada (210)
// size = Grande (1)
* "Cucharada" "grande" (10g) based on Hernandez et al (2015)* (ME)
replace cantidad_h = cantidad*10 if bien==34 & unidad_medida==210 & tamano==1

// food = Margarina/Mantequilla (34)
// unit = Cucharada (210)
// size = Pequeña (3)
* "Cucharada" "pequena" (5g) based on Hernandez et al (2015)* (ME)
replace cantidad_h = cantidad*5 if bien==34 & unidad_medida==210 & tamano==3

// food = Margarina/Mantequilla (34)
// unit = Barra (220)
// size = Grande (1)
* Barra grande (250g)
replace cantidad_h = cantidad*250 if bien==34 & unidad_medida==220 & tamano==1

// food = Margarina/Mantequilla (34)
// unit = Barra (220)
// size = Pequeña (3)
* Barra pequena (105g) (AB)
replace cantidad_h = cantidad*105 if bien==34 & unidad_medida==220 & tamano==3

// food = Mayonesa (35)
// unit = Kilogramos (1)
// size = no size
replace cantidad_h = cantidad*1000 if bien==35 & unidad_medida==1 & cantidad<50
replace cantidad_h = cantidad if bien==35 & unidad_medida==1 & cantidad>=50
//
// food = Mayonesa (35)
// unit = Gramos (2)
// size = no size
//
// food = Mayonesa (35)
// unit = Frasco (150)
// size = Grande (1)
//
// food = Mayonesa (35)
// unit = Frasco (150)
// size = Mediana (2)
//
// food = Mayonesa (35)
// unit = Frasco (150)
// size = Pequeña (3)
//
// food = Mayonesa (35)
// unit = Cucharada (210)
// size = Grande (1)
//
// food = Mayonesa (35)
// unit = Cucharada (210)
// size = Pequeña (3)


stop
*AB = reportado por la Universidad Catolica Andres Bello
*ME = investigacion priopia
*Hernadez et al (2015) Desarrollo de un atlas fotográfico de porciones de alimentos venezolanos. Revista Española de
Nutrición Humana y Dietética