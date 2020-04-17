/*===========================================================================
Puropose: this scripts takes raw data of the 2019 ENCOVY survey at product
level and integrates into a unique dataset at product level
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		12th Feb, 2020
Modification Date:  
Output:			products.dta

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta  1
//		
//
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath ""
// 		}
// 	    if $lauta {
// 				global rootpath "C:\Users\wb563365\GitHub\VEN\"
//
// 		}
// 		if $trini   {
// 				global rootpath ""
// 		}
//		
// 		if $male   {
// 				global rootpath ""
// 		}
//
// // // set raw data path
// global input "$datapath\data_management\input\latest"
// global output "$datapath\data_management\output"

********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off



/*==============================================================================
1: Construction of aproved surveys
==============================================================================*/
// There are different "actions" during the data collection of a survey such as
// first data input, completed, approved by supervisor, approved by HQ, rejected
// We will keep only the approved by HQ

// set the path for our 3 types of questionaires
global pathnew "$input\ENCOVI_3_STATA_All"
global pathold "$input\ENCOVI_MainSurvey_Final_3_STATA_All"
global pathpixel "$input\ENCOVI_pixel_Qx_9_STATA_All"


// load and append data of the 3 questionaires
use  "$pathold\interview__actions.dta", clear
gen quest=1

append using "$pathnew\interview__actions.dta"
replace quest=2 if quest==. & quest!=1

append using "$pathpixel\interview__actions.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

//	Create a temporary db with surveys approved by HQ 

bys quest interview__key interview__id (date time): keep if action[_N]==6 // Last condition:aprov. by HQ

// check, log and delete duplicates
duplicates tag interview__key interview__id quest, generate(dupli)
preserve
keep if dupli >= 1
save "$output\duplicates-prod.dta", replace
restore	

drop if dupli >= 1

// formatting
keep interview__key interview__id quest date
replace date = subinstr(date, "-", "/",.)
gen approved_date=date(date,"YMD")
format approved_date %td
drop date

// test if is id
isid interview__key interview__id quest


// save temporary db with surveys approved
tempfile approved_surveys
save `approved_surveys'


/*(************************************************************************************************************************************************* 
* 2: Structure 1 Questionnaries: food consumtion 
*************************************************************************************************************************************************)*/
// There are 2 types of product questionnaries, according to their Structure
// 1st Structure: food consumption
// 2sd Structure: non-food consumption
// 3rd Structure: recreation consumption

// We will first append separatly each structure
// then we will append between structures

// Structure 1: food consumption
// sets a dta with the first food to then append the rest 

global firstfood cereales

// Append first food (survey's order) across questionnaires
use "$pathold/$firstfood.dta", replace
gen quest=1

append using "$pathnew/$firstfood.dta"
replace quest=2 if quest==. & quest!=1

append using "$pathpixel/$firstfood.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// Keep only approved surveys
merge m:1 interview__key interview__id quest using `approved_surveys'
keep if _merge==3
drop _merge

// code for type of good
global id_grupo_bien = 1
gen tipo_bien = $id_grupo_bien

// rename variables in order to append with next goods
rename s12*_* s12*
rename $firstfood bien

// now we have our first food dataset,
// we loop over types of food (all of structure 1)

// List of food sections except first (cereales)
// its fundamental to keep this list order as it appears in the survey
global foodlist /*cereales*/ carne pescado leche_queso aceites_grasas ///
frutas_frescas vegetales_frescos leguminosas nueces Papa_yuca_tuberculos /// 
azucares_edulcorantes cafe_te condimentos_salsas bebidas tabaco

//sets the loop
foreach food in $foodlist{

preserve // the main individual level dataset


// append the 3 types of questionnaires of this sub-individual level dataset
use "$pathold/`food'.dta", replace
gen quest=1

append using "$pathnew/`food'.dta"
replace quest=2 if quest==. & quest!=1

append using "$pathpixel/`food'.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// merge to keep only approved surveys
merge m:1 interview__key interview__id quest using `approved_surveys'
keep if _merge==3
drop _merge

// code for type of good
global id_grupo_bien = $id_grupo_bien + 1
gen tipo_bien = $id_grupo_bien

// rename variables in order to append with other goods
rename s12*_* s12*
rename `food' bien


// temporary save
tempfile tempdta
save `tempdta'

restore // the main individual dataset

// appends the last product dataset from the loop to the main dataset

append using `tempdta'

}

/*(************************************************************************************************************************************************* 
* 2: Structure 2 Questionnaries: non-food consumtion 
*************************************************************************************************************************************************)*/
// we will append the non-food dataset to the the recently finished food dataset 

// there are differences inside this 2nd structure, so we make differents loops
global nonfoodlist1 aseo_personal_1 aseo_personal_2 Compra_3_meses // do not have date of purchase

// loop over nonfood without date of purchase
foreach nonfood in $nonfoodlist1{

preserve // the main product level dataset


// append the 3 types of questionnaires of this sub-individual level dataset
use "$pathold/`nonfood'.dta", replace
gen quest=1

append using "$pathnew/`nonfood'.dta"
replace quest=2 if quest==. & quest!=1

append using "$pathpixel/`nonfood'.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// merge to keep only approved surveys
merge m:1 interview__id using `approved_surveys'
keep if _merge==3
drop _merge

// code for type of good
global id_grupo_bien = $id_grupo_bien + 1
gen tipo_bien = $id_grupo_bien

// rename variables in order to append with other goods
rename `nonfood' bien
rename (s12bq*) (s12aq10a s12aq10b)

// temporary save
tempfile tempdta

save `tempdta'

restore // the main individual dataset

// appends the last product dataset from the loop to the main dataset

append using `tempdta'
}


global nonfoodlist2 electrodomestico electronico vehiculo // have date of purchase
// loop over nonfood with date of purchase
foreach nonfood in $nonfoodlist2{

preserve // the main product level dataset


// append the 3 types of questionnaires of this sub-individual level dataset
use "$pathold/`nonfood'.dta", replace
gen quest=1

append using "$pathnew/`nonfood'.dta"
replace quest=2 if quest==. & quest!=1

append using "$pathpixel/`nonfood'.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// merge to keep only approved surveys
merge m:1 interview__id using `approved_surveys'
keep if _merge==3
drop _merge

// code for type of good
global id_grupo_bien = $id_grupo_bien + 1
gen tipo_bien = $id_grupo_bien

// rename variables in order to append with other goods
rename `nonfood' bien
rename (s12bq*) (s12aq8 s12aq10a s12aq10b)
rename s12aq8 mes_compra

// temporary save
tempfile tempdta

save `tempdta'

restore // the main individual dataset

// appends the last product dataset from the loop to the main dataset

append using `tempdta'
}

/*(************************************************************************************************************************************************* 
* 4: Structure 3 Questionnaries: rest of consumption with idiosyncratic issues 
*************************************************************************************************************************************************)*/

// last group of goods with different name of variables
// Sec12c and consumo_recreacion need to  make particular fix to each one

// Sec12c


preserve // the main product level dataset


// append the 3 types of questionnaires of this sub-individual level dataset
use "$pathold/Sec12c.dta", replace
gen quest=1

append using "$pathnew/Sec12c.dta"
replace quest=2 if quest==. & quest!=1 

append using "$pathpixel/Sec12c.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// merge to keep only approved surveys
merge m:1 interview__key interview__id quest using `approved_surveys'
keep if _merge==3
drop _merge

// code for type of good
global id_grupo_bien = $id_grupo_bien + 1
gen tipo_bien = $id_grupo_bien

// code for good to be compatible with the rest
replace Sec12c__id =  Sec12c__id + 200


// rename variables in order to append with other goods
rename Sec12c bien
rename (s12cq4 s12cq5) (s12aq10a s12aq10b)

// temporary save
tempfile tempdta

save `tempdta'

restore // the main individual dataset

// appends the last product dataset from the loop to the main dataset

append using `tempdta'

// consumo_recreacion

preserve // the main product level dataset


// append the 3 types of questionnaires of this sub-individual level dataset
use "$pathold/consumo_recreacion.dta", replace
gen quest=1

append using "$pathnew/consumo_recreacion.dta"
replace quest=2 if quest==. & quest!=1 

append using "$pathpixel/consumo_recreacion.dta"
replace quest=3 if quest==. & quest!=1 & quest!=2

// merge to keep only approved surveys
merge m:1 interview__key interview__id quest using `approved_surveys'
keep if _merge==3
drop _merge

// code for type of good
global id_grupo_bien = $id_grupo_bien + 1
gen tipo_bien = $id_grupo_bien

// code for good to be compatible with the rest
replace consumo_recreacion__id =  consumo_recreacion__id + 300


// rename variables in order to append with other goods
rename consumo_recreacion bien
rename (s12dq2 s12dq3) (s12aq10a s12aq10b)

// temporary save
tempfile tempdta

save `tempdta'

restore // the main individual dataset

// appends the last product dataset from the loop to the main dataset

append using `tempdta'


/*(************************************************************************************************************************************************* 
* 5: Rename, labeling & save 
*************************************************************************************************************************************************)*/
// generate secondary variables
gen grupo_bien = 1
replace grupo_bien = 2 if tipo_bien >= 16 
replace grupo_bien = 3 if tipo_bien >= 22 
replace grupo_bien = 4 if tipo_bien >= 22 

// rename variables

rename s12aq2 consumio
rename s12aq3a cantidad
rename s12aq3b unidad_medida
rename s12aq3c tamano
rename s12aq4 comprado
rename s12aq5 transferido
rename s12aq6 otras_fuentes
rename s12aq7 producido
rename s12aq8 fecha_ultima_compra
rename s12aq9a cantidad_comprada_noclap
rename s12aq9b unidada_comprada_noclap
rename s12aq9c tamano_comprada_noclap
rename s12aq10a gasto 
rename s12aq10b moneda
rename s12cq3 pago_consumo_fuera

// relabels variables which labels got lost by appends
label variable bien "Nombre del producto"
label variable consumio "Consumio [PRODUCTO] en los ultimos 7 dias"


label define goods_label ///
1 "Arroz, harina de arroz" 2 "Avena, avena en hojuelas, harina de avena" 3 "Galletas, dulces, saladas, integrales" 4 "Harina de maiz" 5 "Maiz en granos" 6 "Pan de trigo" 7 "Pastas alimenticias" 8 "Fororo" 9 "Otro (especifique)" ///
10 "Carne de res (bistec, carne molida, carne para esmechar)" 11 "Visceras (higado, riñonada, corazon, asadura, morcillas)" 12 "Chuleta de cerdo ahumada" 13 "Carne de cerdo fresca (chuleta, costilla, pernil)" 14 "Hueso de res, pata de res, pata de pollo" 15 "Chorizo, jamon, mortadela y otros embutidos" 16 "Carne enlatada" 17 "Carne de pollo" 18  "Otro (especifique)" ///
19 "Pescado enlatado" 20 "Sardinas frescas/congeladas" 21 "Atun fresco/congelado" 22 "Pescado fresco" 23 "Pescado seco/salado" 24 "Otro (especifique)" ///
25 "Leche liquida, completa o descremada" 26 "Leche en polvo, completa o descremada" 27 "Queso requeson, ricota" 28 "Queso blanco" 29 "Queso amarillo" 30 "Suero, natilla, nata" 31 "Huevos (unidades)" 32 "Otro (especifique)" ///
33 "Aceite" 34 "Margarina/Mantequilla" 35 "Mayonesa" 36 "Otro (especifique)" ///
37 "Cambur" 38 "Mangos" 39 "Platanos" 40 "Lechosa" 41 "Guayaba" 42 "Otro (especifique)" ///
43 "Tomates" 44 "Aguacate" 45 "Aji dulce, pimenton, pimiento" 46 "Cebolla" 47 "Auyama" 48 "Lechuga" 49 "Berenjena" 50 "Zanahorias" 51 "Cebollin, ajoporro, cilantro y similares" 52 "Otro (especifique)" ///
53 "Caraotas" 54 "Frijoles" 55 "Lentejas" 56 "Garbanzo" 57 "Otro (especifique)" ///
58 "Nueces" 59 "Mani" 60 "Merey" 61 "Otro (especifique)" ///
62 "Yuca" 63 "Papas" 64 "Ocumo" 65 "Apio" 66 "Casabe" 67 "Otro (especifique)" ///
68 "Azucar" 69 "Papelon" 70 "Edulcorantes" 71 "Miel" 72 "Melaza" 73 "Otro (especifique)" ///
74 "Cafe" 75 "Te" 76 "Bebida achocolatada" 77 "Otro (especifique)" ///
78 "Sal" 79 "Condimentos (comino, pimienta, curry, cubitos)" 80 "Concentrados (cubitos, sopas de sobre)" 81 "Salsa de tomate"  82 "Otras salsas" 83 "Otro (especifique)" ///
84 "Jugos" 85 "Agua embotellada" 86 "Gaseosas/refrescos" 87 "Otras bebidas no alcoholicas" 88 "Bebidas alcoholicas" 89 "Otro (especifique)" ///
90 "Cigarrillos (unidades)" 91 "Tabaco (unidades)" 92 "Otro (especifique)" ///
101 "Pasta de diente" 102 "Jabon" 103 "Champu" 104 "Otros productos de peluqueria" 105 "Desodorante" 106 "Perfume / Colonia" 107 "Afeitadora" 108 "Crema de Afietar" 109 "Toallas sanitarias" 110 "Papel toilet" 111 "Pañales" 112 "Toallas humedas" 113 "Otro (especifique)" ///
114 "Detergente de ropa" 115 "Lavaplatos" 116 "Desinfectante" 117 "Limpia vidrios" 118 "Cloro y similares" 119 "Suavizante" 120 "Coleto" 121 "Escoba" 122 "Otro (especifique)" ///
123 "Camisas" 124 "Pantalon o short" 125 "Faldas y vestidos" 126 "Ropa interior" 127 "Zapatos" 128 "Pijama" 129 "Sueter, chaquetas y abrigos" 130 "Accesorios" 131 "Otro (especifique)" ///
132 "Plancha" 133 "Licuadora" 134 "Nevera" 135 "Lavadora" 136 "Secadora" 137 "Cocina" 138 "Microondas" 139 "Horno" 140 "Otro (especifique)" ///
141 "Television" 142 "Tableta" 143 "Computadora" 144 "Telefono Celular" 145 "Equipo de sonido" 146 "Otro (especifique)" ///
201 "Desayuno" 202 "Merienda en la mañana" 203 "Almuerzo" 204 "Merienda en la tarde" 205 "Cena" ///
301 "Alquiler de instalaciones o canchas deportivas para la practica de deportes (futbol, basket, bolas criollas, etc" 302 "Coutas a clubes sociales y deportivos" 303 "Entradas a cine" 304 "Entradas a teatro, espectaculos musicales, circos u otros" 305 "Entradas espectaculos deportivos (besibol, futbol, basket, etc)" 306 "Gastos en parques, parques de diversiones, juegos mecanicos" /// 
307 "Gastos en discotecas, bares y similares" 308 "Gastos en paseos cerca de su lugar de residencia (playa, parque nacioales, excursiones, etc.)" 309 "CD y DVD pregrabados" 310 "Accesorios para instrumentos musicales" 311 "Productos para animales domesticos y mascotas, productos de veterinaria, articulos para el cuidado e higiene (champu, jabon, desodorantes) y accesorios para mascotas (collares, perrera, jaula, acuarios y otros)" 312 "Servicios de veterinaria y de otro tipo para animales domesticos: cuidado, salon de belleza, alojamiento, entrenamiento, etc." 313 "Servicio de profesores o instructores particulares en clases recreativas y deportivas (ajedrez, gimnasia, natacion y otros)" ///
314 "Servicios de profesores o instructures particulares en clases de formacion artisitica (musica, baile, instrumentos musicales, canto, produccion artistica-recreativa)" 315 "Rifas y sorteos" 316 "Libros de lectura, revistas" 317 "Lienzos, telas para dibujo y pintura" 318 "Artículos para fiestas: piñatas, serpentinas, confetis, bombas plásticas, recordatorios, etc)" 319 "Servicios de transporte urbano (no incluye  transporte a centro educativo, lugar de trabajo o motivos de salud)" 320 "Viaje al interior del país" 321 "Viaje al exterior del país" 322 "Otro"

label values bien goods_label

 // Label values (Unit)
*Define the labels for each value
label define measure ///
1 "Kilogramos" ///
2 "Gramos" ///
3 "Litros" ///
4 "Mililitros" ///
10 "Rebanada" ///
20 "Taza" ///
30 "Pieza (bistec,chuleta, similares)" ///
40 "Pieza de pan" ///
50 "Pieza (rueda, pescado entero)" ///
60 "Paquete" ///
64 "Paquete" ///
70 "Plato" ///
80 "Lata" ///
91 "Cartón" ///
92 "Medio cartón" ///
100 "Docena" ///
110 "Unidad" ///
120 "Envase de plastico" ///
130 "Bolsa" ///
140 "Galón" /// 
150 "Frasco" ///
160 "Torta (casabe)" ///
170 "Caja" ///
180 "Sobre" ///
190 "Gavera  o caja" ///
200 "Cajetillas" ///
210 "Cucharada" ///
220 "Barra"

label values unidad_medida measure 

// Define labels for each type of questionnaire 
	label define quest_label 1 "Tradicional - Viejo" ///
	2 "Tradicional - Nuevo" ///
	3 "Remoto"

//Incorporate the values labels to the variable 		  
	label values quest quest_label




/*(************************************************************************************************************************************************* 
* 5: add names of other goods
*************************************************************************************************************************************************)*/

// looks for data of goods identified as others
// also pick dates when data collection started

preserve
use "$output\household", replace
keep interview__key interview__id quest s12aq1*os s12a_star

//date formt
gen date_consumption_survey=date(s12a_star,"YMD###")
format date_consumption_survey %tddmy
tempfile temp_other_food_label
save `temp_other_food_label'
restore

// add "others" labels to product dataset
merge m:1 interview__key interview__id quest using `temp_other_food_label'
keep if _merge==3
drop _merge


// include each "other" food as a level of food
// also creates a flag to easily identify "otros"

gen otros_alimentos =""

levelsof tipo_bien  if grupo_bien ==1, local(levels_tipo_bien)


foreach j in `levels_tipo_bien' {
quietly levelsof bien if tipo_bien==`j', local(levels_bien) 
local bname: value label bien

	foreach b in `levels_bien' {
		local vb: label `bname' `b'
		
		if "`vb'" == "Otro (especifique)"{
		replace otros_alimentos = s12aq1_`j'_os if (bien==`b')
		}
	}
}
drop s12aq1*_os




// save the product-household dataset
save "$output\product-hh.dta", replace




 
