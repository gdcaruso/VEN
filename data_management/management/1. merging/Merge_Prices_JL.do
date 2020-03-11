/*===========================================================================
Purpose: merge raw data on prices from ENCOVI Survey 2019

Country name:	Venezuela
Year:			2014
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Merged Dataset ENCOVI (Prices)

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   1
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\Documents\GitHub\ENCOVI-2019"
				global dataout "$rootpath\"
				
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
				global dataout "$rootpath\"
		}
		if $trini   {
				global rootpath ""
				global dataout "$rootpath\"
		}
		
		if $male   {
				global rootpath ""
				global dataout "$rootpath\"
		}

	global dataofficial "$rootpath\data_management\input\03_04_20"
	global dataout "$rootpath\data_management\output"
	global dataint "$dataout\intermediate"
    // Set the  path for prices
	global pathprc "$dataofficial\ENCOVI_prices_2_STATA_All"
	
********************************************************************************
	
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Merge prices data   --------------------------------------------------

*************************************************************************************************************************************************)*/ 

**** Preliminary information: approved surveys

	//Keep approved by HQ 
	use "$pathprc\interview__actions.dta", clear
	
	// Create a tempfile for approved surveys	
    tempfile approved_surveys
	
	// Create identification for approved surveys
	bys interview__key interview__id (date): keep if action==6 // 6=approved by HQ

	// check, log and delete duplicates
	duplicates tag interview__key interview__id, generate(dupli)
	preserve
	keep if dupli >= 1
	save "$rootpath\data_management\output\merged\duplicates-price.dta", replace
	restore	
	drop if dupli >= 1
	
	keep interview* origina responsible__name date

	// Change format
	rename ori interviewer
	rename respo coordinator
	replace date = subinstr(date, "-", "/",.)
	gen edate=date(date,"YMD")
	format edate %td
	drop date
	// save temporary db with surveys approved
	save `approved_surveys'	


**** Main price data 
	
	*-------- Append households 
	// Compile the three questionnaires as temporary file 
    tempfile main_prices
	
	// To Old questionnaire
	use "$pathprc\ENCOVI_prices.dta", clear

	// Selecting only the approved by HQ
	merge 1:1 interview__key interview__id using `approved_surveys' , keep(using matched)
	drop _merge
	
    // Save the temporary file
    save `main_prices'

	// This file has a wide format while the other carctheristics have a long format
	// The following files: shocks, mortalidad, services and emigration are transformed 
	// in the following section before merging with the household data

**** Complementary price data

global sec_prices aceites_grasas azucares_edulcorantes bebidas cafe_te carne cereales ///
condimentos_salsas frutas_frescas leche_queso leguminosas nueces Papa_yuca_tuberculos ///
pescado tabaco vegetales_Frescos

foreach dtafile in $sec_prices{

// Select each database
use "$pathprc/`dtafile'.dta", replace

// Generate a variable with the name of the file
gen file_name = "`dtafile'"

// Prepare names format for append
rename (`dtafile'*id) (bien)
rename (s2q8_*) (unidad_medida)
rename (s2q8a_*) (unidad_medida_ot)
rename (s2q9_*) (cantidad)
rename (s2q10_*) (precio)
rename (s2q11_*) (moneda)

save "$dataint/`dtafile'", replace
}

// Append the datafiles	
 use "$dataint/aceites_grasas.dta", clear
 append using "$dataint/azucares_edulcorantes"
 append using "$dataint/bebidas" 
 append using "$dataint/cafe_te" 
 append using "$dataint/carne"
 append using "$dataint/cereales"
 append using "$dataint/condimentos_salsas"
 append using "$dataint/frutas_frescas" 
 append using "$dataint/leche_queso" 
 append using "$dataint/leguminosas" 
 append using "$dataint/nueces" 
 append using "$dataint/Papa_yuca_tuberculos" 
 append using "$dataint/pescado" 
 append using "$dataint/tabaco" 
 append using "$dataint/vegetales_Frescos"

 //Rename a variable whcih only was included in of the datasets
 rename (s2q9a_*) (tamano)
 
*-------- Recode file name identification
// Replace the variable file name according to the secton number of the survey
// Ex: cereales is the first section of the survey, so the "file_name" is replace with 1

	replace file_name="1" if file_name=="cereales"	
	replace file_name="2" if file_name=="carne"
	replace file_name="3" if file_name=="pescado"	
	replace file_name="4" if file_name=="leche_queso"
	replace file_name="5" if file_name=="aceites_grasas"
	replace file_name="6" if file_name=="frutas_frescas"
	replace file_name="7" if file_name=="vegetales_Frescos"
	replace file_name="8" if file_name=="leguminosas"
	replace file_name="9" if file_name=="nueces"
	replace file_name="10" if file_name=="Papa_yuca_tuberculos"
	replace file_name="11" if file_name=="azucares_edulcorantes"
	replace file_name="12" if file_name=="cafe_te"
	replace file_name="13" if file_name=="condimentos_salsas"
	replace file_name="14" if file_name=="bebidas"
	replace file_name="15" if file_name=="tabaco"

	// Change variable format to numeric
	destring file_name, replace
	
    //Save as temp file
	tempfile append_prices
	save `append_prices'

*-------- Combine with main prices data

	merge m:1 interview__key interview__id using `main_prices', keep(matched)
	drop _merge

*-------- Recode labels
*-------- UNITS

	// Label variables
	label var file_name "Price Survey Section"
	label var unidad_medida "Unidad"

	// Label values (Unidad)
	*Define the labels for each value 
	label def measure ///
	       1 "Kilogramos" ///
           2 "Gramos" ///
           3 "Litros" ///
           4 "Mililitros" ///
		  10 "Rebanada" ///
		  20 "Taza" ///
		  30 "Pieza (bistec,chuleta, similares)" ///
		  40 "Pieza de pan" ///
		  50 "Pieza (rueda, pescado entero)" ///
          60 "Otro" ///
		  64 "Paquetes" ///
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

		 
		*Incorporate the values labels to the variable 
		label values unidad_medida measure
		
*-------- Recode labels
*-------- GOODS

	label define goods_label /*Label cereales*/ 1 "Arroz" ///
           2 "Harina de arroz" ///
           3 "Avena, avena en hojuelas, hariina de avena" ///
           4 "Galletas dulces" ///
           5 "Galletas saladas" ///
           6 "Galletas integrales" ///
           7 "Harina de maiz" ///
           8 "Maiz en granos" ///
           9 "Pan de trigo" ///
          10 "Pasta (fideos)" ///
          11 "Fororo" ///  Label carne
          12 "Carne de res (bistec)" ///
          13 "Carne de res (molida)" ///
          14 "Carne de res (para esmechar)" ///
          15 "Visceras (higado,riñonada,corazón,asadura, morcillas)" ///
          16 "Chuleta de cerdo ahumada" ///
          17 "Carne de cerdo (chuleta)" ///
          18 "Carne de cerdo (costilla)" ///
          19 "Hueso de res, pata de res, pata de pollo" ///
          20 "Chorizo, jamón, mortaleda y otros embutidos" ///
          21 "Carne enlatada" ///
          22 "Carne de pollo/gallina" ///	
		  23 "Pescado enlatado" ///
          24 "Sardinas frescas/congeladas" ///
          25 "Atún fresco/congelado" ///
          26 "Pescado fresco" ///
          27 "Pescado seco/salado" /// 
		  28 "Leche líquida, completa o descremada" ///
          29 "Leche en polvo, completa o descremada" ///
          30 "Queso requesón, ricota" ///
          31 "Queso blanco" ///
          32 "Queso amarillo" ///
          33 "Suero, natilla, nata" ///
          34 "Huevos (unidades)" ///
          35 "Aceite" ///
          36 "Margarina/Mantequilla" ///
          37 "Mayonesa" ///
	      38 "Cambur" ///
          39 "Mangos" ///
          40 "Platanos" /// 
          41 "Lechosa" ///
          42 "Guayaba" ///
          43 "Tomates" ///
          44 "Aguacate" ///
          45 "Aji dulce, pimentón, pimiento" ///
          46 "Cebolla" ///
          47 "Auyama" ///
          48 "Lechuga" ///
          49 "Berenjena" ///
          50 "Zanahorias" ///
          51 "Cebollin, ajoporro." ///
          52 "Cilantro" ///
          53 "Caraotas" ///
          54 "Frijoles" ///
          55 "Lentejas" ///
          56 "Garbanzo" /// 57 does not exist given an error in survey 
		  58 "Nueces" ///
          59 "Maní" ///
          60 "Merey" ///
		  61 "Yuca" ///
          62 "Papas" ///
          63 "Ocumo" ///
          64 "Apio" ///
          65 "Casabe" ///
		  66 "Azúcar" ///
          67 "Papelón" ///
          68 "Edulcorantes" ///
          69 "Miel" ///
          70 "Melaza" /// 
          71 "Café" ///
          72 "Té" ///
          73 "Bebida achocolatada" ///
          74 "Sal" ///
          75 "Condimentos (comino, pimienta, curry, cubitos)" ///
          76 "Concentrados (cubitos, sopas de sobre)" ///
          77 "Salsa de tomate" ///
          78 "Otras salsas" ///		
          79 "Jugos pasteurizados" ///
          80 "Agua embotellada" ///
          81 "Gaseosas / refrescos" ///
          82 "Otras bebidas no alcoholicas" ///
          83 "Cerveza" ///
          84 "Vino tinto" ///	
          85 "Cigarrillos (unidades)" ///
          86 "Tabaco (Unidades)"
		  
	*Incorporate the values labels to the variable 		  
	label values bien goods_label
	
*-------- Recode labels
*-------- Price survey section

	label define section_label 1 "Cereales" ///
	2 "Carne" ///
    3 "Pescado" ///
	4 "Leche y queso" ///
	5 "Aceites y grasas" ///
	6 "Frutas frescas" ///
	7 "Vegetales frescos" ///
	8 "Leguminosas" ///
	9 "Nueces" ///
	10 "Papa, yuca y tuberculos" ///
	11 "Azucares y edulcorantes" /// 
	12 "Cafe y te" ///
	13 "Condimentos y salsas" ///
	14 "Bebidas" /// 
	15 "Tabaco" 
    
	label values file_name section_label
	
*-------- Save prices dataset
// save the product-household dataset
compress
save "$rootpath\data_management\output\merged\prices.dta", replace
