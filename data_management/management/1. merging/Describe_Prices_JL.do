/*===========================================================================
Purpose: generate descriptive statistics for prices from ENCOVI Survey 2019
ONLY for completed surveys

Country name:	Venezuela
Year:			2019
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Information on price behaviour (Venezuela)
                    Transformation o 

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   1
		
		* User 3: Lautaro
		global lauta   0
		
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

	global dataofficial "$rootpath\data_management\input\03_10_20"
	global dataout "$rootpath\data_management\output"
	global dataint "$dataout\intermediate"
    // Set the  path for prices
	global pathprc "$dataofficial\ENCOVI_prices_2_STATA_All"
	global exch_rate "$rootpath\data_management\management\1. merging\exchange rates"
********************************************************************************
	
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Merge prices data   --------------------------------------------------

*************************************************************************************************************************************************)*/ 
**** Preliminary information: completed surveys

	//Keep completed by HQ 
	use "$pathprc\interview__actions.dta", clear
	
	// Create a tempfile for completed surveys
    tempfile completed_surveys
	
	// Create identification for completed surveys
	bys interview__key interview__id (date): keep if action==3 // 3=Completed 

	// To identify unique interviews according the last date and time entered
    bys interview__key interview__id (date time) : keep if _n==_N

	// Change format
	replace date = subinstr(date, "-", "/",.)
	gen edate=date(date,"YMD")
	format edate %td	
	
	// Check duplicates 
	duplicates report interview__key interview__id 
	duplicates report interview__key interview__id date time
	
	// save temporary db with surveys completed

	save `completed_surveys'	

	
**** Main price data 
	
	*-------- Append households 
	// Compile the three questionnaires as temporary file 
    tempfile main_prices
	
	// To Old questionnaire
	use "$pathprc\ENCOVI_prices.dta", clear
    duplicates report interview__key interview__id
	
	// Selecting only the completed by HQ
	merge 1:1 interview__key interview__id using `completed_surveys', keep(matched)
	drop _merge
	
	// Check duplicates 
	duplicates report interview__key interview__id
	duplicates report interview__key interview__id date time

    // Save the temporary file
    save `main_prices'


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

	save "$dataint\`dtafile'", replace
	}

// Append the data files	
	 use "$dataint\aceites_grasas.dta", clear
	 append using "$dataint\azucares_edulcorantes"
	 append using "$dataint\bebidas" 
	 append using "$dataint\cafe_te" 
	 append using "$dataint\carne"
	 append using "$dataint\cereales"
	 append using "$dataint\condimentos_salsas"
	 append using "$dataint\frutas_frescas" 
	 append using "$dataint\leche_queso" 
	 append using "$dataint\leguminosas" 
	 append using "$dataint\nueces" 
	 append using "$dataint\Papa_yuca_tuberculos" 
	 append using "$dataint\pescado" 
	 append using "$dataint\tabaco" 
	 append using "$dataint\vegetales_Frescos"

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
	
/*(************************************************************************************************************************************************* 
*     Currency transformation
*************************************************************************************************************************************************)
	 The survey includes 4 types currencies:
	 Bolivares, Dolares, Euros & Pesos Colombianos
	 
	 Prices should be converted into Bolivares using 
	 exchange rates data from: 	 
	 Banco Central de Venezuela (BCV), daily data (http://www.bcv.org.ve/estadisticas/tipo-de-cambio). 

*-------- Generate date variable which allow to merge with exchange rate data
*/
	//To identify the date were prices were collected
		// Generate the date of data collection from variable: s2q4
		// Dates looks like: YYYY-MM-DD
		gen date_price=substr(s2q4,1,10)
		gen mes=substr(s2q4,6,2)
		// Include label
		label var mes "Month of data collection"
			
*-------- Merge with exhange rates data	
		// Exchange rates 
		merge m:1 mes moneda using "$exch_rate\exchenge_rate_price"
		// Delete information which is only in the exchange rates dataset 
		drop if _merge==2
		// Drop auxiliary variable
		drop _merge

*-------- Save prices dataset
// save the product-household dataset
//save "$rootpath\data_management\output\merged\prices.dta", replace

/*-------- Some descriptive measures

ESTAN HECHAS CON LA FECHA DE APROBACION NO DE LA ENCUESTA

// Generate auxiliar variable to collapse and generate descriptive information
	 // Generate a variable to identify the month
	 gen month=substr(date,6,2)
	 // Create identification for stata and month
	 egen month_state=group(ENTIDAD month), label
	 egen month_state_bien=group(ENTIDAD month bien), label
	 
	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (bien ENTIDAD) 
	export excel using "$dataout/precio_desc", sheet("Todo",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (bien)
	export excel using "$dataout/precio_desc", sheet("Bien",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (ENTIDAD)
	export excel using "$dataout/precio_desc", sheet("Entidad",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_b=bien (count) c_b=bien (sd) sd_b=bien, by (ENTIDAD) 
	export excel using "$dataout/precio_desc", sheet("Bien Entidad",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (month_state)
	export excel using "$dataout/precio_desc", sheet("Precio-Mes",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_b=bien (count) c_b=bien (sd) sd_b=bien, by (month_state) 
	export excel using "$dataout/precio_desc", sheet("Bien-Mes",replace) firstrow(varlabels) 
	restore

*/


/*(************************************************************************************************************************************************* 
* Selection of items
*************************************************************************************************************************************************)
  Select only items which we are going to use for the basket in the poverty lines
  This simplify the problem of units and measures correction 
*/

		keep if bien== 1 | bien== 2 | bien== 7 | bien== 9 | bien== 10 | ///           
		bien== 12 | bien== 13 | bien==  14 |  bien== 19 | bien==  20 | ///
		bien== 22 | bien== 24 |  bien==  26 | bien== 29 | bien== 31 | ///
		bien== 34 | bien== 35 | bien== 36 |  bien== 38 | bien== 40 | bien== 41 | bien== 43 | ///
		bien== 45 |  bien== 46 | bien== 47 | bien== 50 | bien== 51 | bien== 52 | ///
		bien== 53 | bien== 54 | bien== 55 | bien== 61 | bien== 62 | bien== 66 | ///                   
		bien== 67 | bien== 71 | bien== 74 |  bien== 75 

/*
As a result we have the following list of units

                           Unidad |      Freq.     Percent        Cum.
----------------------------------+-----------------------------------
                       Kilogramos |      3,170       60.48       60.48
                           Gramos |      1,116       21.29       81.78
                           Litros |        230        4.39       86.17
                       Mililitros |         34        0.65       86.82
                             Taza |          2        0.04       86.85
Pieza (bistec,chuleta, similares) |          4        0.08       86.93
                     Pieza de pan |        123        2.35       89.28
                             Otro |         76        1.45       90.73
                             Lata |          2        0.04       90.77
                           Cartón |         84        1.60       92.37
                     Medio cartón |         29        0.55       92.92
                           Unidad |        363        6.93       99.85
                            Bolsa |          7        0.13       99.98
                   Torta (casabe) |          1        0.02      100.00
----------------------------------+-----------------------------------
                            Total |      5,241      100.00

 Without taking into account other measures or sizes
 
*/

/*(************************************************************************************************************************************************* 
* 1: Units (missing values) correction 
*************************************************************************************************************************************************)*/

// Kilograms
	// For Azucar we can replace missing values of units if the quantity is 1
	// We assume it is 1 kg
	replace unidad_medida=1 if (bien==66 & cantidad==1)
    replace unidad_medida=1 if (bien==1 & cantidad==1)
	
/*(************************************************************************************************************************************************* 
* 1: Units (other) correction 
*************************************************************************************************************************************************)*/
// COMPLETAR UNA VEZ CORREGIDO EL LOOP DE ERRORES !!!!!!!


//Paquetes
	*-----------
	// This measure appears in "Other Units" but it should be part of "Units"
	// First: standarized the names
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="PAQUETES") 
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="paquete")  
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="paquetes") 
	
//Unidad
	*-----------
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidad de Oreo" & bien==4) // Galletas dulces
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidades") 
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidad") 
	
 //Tetas
	*-----------
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="teta")  
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="tetas")
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="paquetito (teta)")
	replace unidad_medida_ot="Teticas" if (unidad_medida_ot=="bolsitas de 100 grs. (teticas)")
	replace unidad_medida_ot="Teticas" if (unidad_medida_ot=="teticas") 
	replace unidad_medida_ot="Teticas" if (unidad_medida_ot=="bolsita (teticas)") 

//Bolsita
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bosita")  
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bolsita")
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bolsitas")
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bolsistas")

//Panela	
	replace unidad_medida_ot="Panela" if (unidad_medida_ot=="panela")  
	replace unidad_medida_ot="Panela" if (unidad_medida_ot=="panelas") 	
	
//Sobrecito
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="Sobresitos")  
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="sobresito")
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="SOBRE")
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="sobre 100 gr")

/*(************************************************************************************************************************************************* 
* 0: Assesment of errors (quantities)
*************************************************************************************************************************************************)*/

log using "$rootpath\data_management\management\3. cleaning\quantities_for_price_data", text replace


qui levelsof bien, local(foodlist)
local fname: value label bien

foreach f of local foodlist {

	local vf: label `fname' `f'
		
	qui levelsof unidad_medida if bien ==`f', local(units)
	local uname: value label unidad_medida
		
			foreach u of local units {
			local vu: label `uname' `u'
			
			//Levels of sizes
				qui levelsof tamano if bien ==`f' & unidad_medida==`u' , local(tamanos)
				local tname: value label tamano
				local tcounts : list sizeof tamanos
			
				// Unidades de medida de la encuesta
				if "`vu'" != "Otro" {
				
									if `tcounts' == 0 {
									display "food = `vf' (`f')"
									display "unit = `vu' (`u')"
									display "size = no size"
									tab cantidad if (bien ==`f' & unidad_medida==`u'), mi
									   }
									else {
									foreach t of local tamanos{
									local vt: label `tname' `t'
									display "food = `vf' (`f')"
									display "unit = `vu' (`u')"	
									display "size = `vt' (`t')"	 
									tab cantidad if (bien ==`f' & unidad_medida==`u'), mi
											}
										}
									}
				//Otras unidades de medida					
				else   				{
				//Local de las otras unidades de medida
				qui levelsof unidad_medida_ot if bien ==`f' & unidad_medida ==`u', local(units_ot)
				
				//Para cada 
				foreach o of local units_ot {
				
				qui levelsof tamano if bien ==`f' & unidad_medida==`u' & unidad_medida_ot=="`o'", local(tamanos_ot)
				local tnamet: value label tamano
				local tcountst : list sizeof tamanos
				
										if `tcountst' == 0 {
										display "food = `vf' (`f')"
										display "unit = `vu' (`u')"
										display "unit_ot = `o'"
										tab cantidad if (bien ==`f' & unidad_medida ==`u' & unidad_medida_ot=="`o'"), mi
														 }
										else {
										foreach k of local tamanos_ot {
										local vk: label `tnamet' `k'
										display "food = `vf' (`f')"
										display "unit = `vu' (`u')"
										display "unit_ot = `o'"
										tab cantidad if (bien ==`f' & unidad_medida ==`u' & unidad_medida_ot=="`o'" & tamano==`k'), mi
										
																		}
										}
				
					
											}
									}
				}
			}

	// To list the places where prices were observed
		tab s2q1_os
log close
	
/*(************************************************************************************************************************************************* 
* 2: Measure correction 
*************************************************************************************************************************************************)*/
/*

PRELIMINARY

For non sense measures:
    Examples:
	1 gram of Flour -> 1 kilo, 
	500 kilos of Flour -> 500 gramos	          
*/

*-----------
// Change Units 
*-----------
	
	// From kilos to grams 
	replace unidad_medida=2 if (cantidad>=50 & unidad_medida==1)
	
	// From grams to kilos	
	replace unidad_medida=1	if (cantidad<50 & unidad_medida==2)
	
	// Fromo militers to liters
	replace unidad_medida=4 if (cantidad>= 50 & unidad_medida==3)
	
	// From liters to militers
	replace unidad_medida=3 if (cantidad<= 10 & unidad_medida==4)
	
	// From envases to milititers
	replace unidad_medida=4 if (cantidad>=50 & unidad_medida==120)
	
	// From lata to grams
	replace unidad_medida=2 if (cantidad>=100 & unidad_medida==80)
	
	
*-----------	
// Fix extreme quantities
*-----------	

	// To fix extreme quantities for kilos	
	replace cantidad=(cantidad/10) if (cantidad>=20 & unidad_medida==1)
	
	// To fix extreme quantities for grams	
	replace cantidad=(cantidad/100) if (cantidad>=10000 & unidad_medida==2)
	
	// To fix extreme quantities for paquetes	
	replace cantidad=(cantidad/1000) if (cantidad>=1000 & unidad_medida==60 & unidad_medida_ot=="Paquete")

	// To fix extreme quatities for units
    replace cantidad=(cantidad/100) if (cantidad>=1000 & unidad_medida==110)
	
/*(************************************************************************************************************************************************* 
* 3: Units transformation
*************************************************************************************************************************************************)
	// We need to transform all the products into grams in order to
	have the obtain the price per gram 
	
	// In this section we transform from multiple measures to gram, liters or unit
	in the next one, we transform other measures into grams, liters or units
	
	Equivalence:
	#1: grams = #1: mililiters
*/
	// Homogeneous unit #1: grams
	gen cantidad_3 = cantidad if unidad_medida == 2
	gen unidad_3 = 1 if unidad_medida == 2

	// From kilograms to grams
	replace cantidad_3 = cantidad*1000 if unidad_medida == 1
	replace unidad_3 = 1 if unidad_medida == 1
	
	// Homogeneous unit #2: mililiters
	replace cantidad_3 = cantidad if unidad_medida == 4
	replace unidad_3 = 2 if unidad_medida == 4

	// From liters to mililiters
	replace cantidad_3 = cantidad*1000 if unidad_medida == 3
	replace unidad_3 = 2 if unidad_medida == 3

	// From gallon to mililiters
	replace cantidad_3 = cantidad*4546.09 if unidad_medida == 140
	replace unidad_3 = 2 if unidad_medida == 140
	

/*(************************************************************************************************************************************************* 
* 4: Units trasnformation for specific products
*************************************************************************************************************************************************)
 This section address the problem of multiple presentations :
 
	// Many products have multiple size of presentation (large, medium, small)
	// The trasnformations were based on:
	
	1) Source: Spanish Journal of Human Nutrition and Dietetics"
	   Publication title: Hernandez et al (2015)-Desarrollo de un atlas fotográfico de porciones de alimentos venezolanos
	
	2) Information available online 	 
*/
	// From cups to grams Hernandez et al (2015)	
	// "Taza (cup)" (1) to grams (150)
	replace cantidad_3 = cantidad*150 if (unidad_medida == 20)
	replace unidad_3 = 1 if (unidad_medida == 20)
	

	// Aceite (COD:35)
		// "Cucharada" "grande" (10g)
		// based on Hernandez et al (2015)
		replace cantidad_3 = cantidad*10 if (unidad_medida == 210 & bien == 35 & tamano==1)
		// "Cucharada" "pequeña" (5g)
		// based on Hernandez et al (2015)
		replace cantidad_3 = cantidad*5 if (unidad_medida == 210 & bien == 35 & tamano==3)
		replace unidad_3 = 1 if (unidad_medida==210 & bien==35)
		// Teta (between 200-500) --> we use "Teta" (1): 250ml
		replace cantidad_3= cantidad*250 if (unidad_medida == 60 & bien == 35 & unidad_medida_ot=="Teta")
		replace unidad_3= 2 if (unidad_medida == 60 & bien == 35 & unidad_medida_ot=="Teta")
	
	// Aji dulce, primenton, pimiento (COD:45)
		// Bolsita (1): 100g
		replace cantidad_3=cantidad*100	if (unidad_medida == 60 & bien == 45 & unidad_medida_ot=="Bolsita")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 45 & unidad_medida_ot=="Bolsita")
		// Unidad (1): 200g
		// Pimiento de cuatro cascos, de forma cuadrada, de 10 a 15 cm de largo y peso entre 150 a 250 g.
		replace cantidad_3=cantidad*200	if (unidad_medida ==110 & bien == 45)
		replace unidad_3=1 if (unidad_medida ==110 & bien == 45)
	
	
	// Arroz (COD:1)
		// Unidad de medida is always either kilograms or grams
		// Date: 3/9/2020
	
	
	// Auyama (COD:47)
		// Unidad de medida is always either kilograms or grams
		// Date: 3/9/2020
		// Unidad (1): 200g
		// Los frutos son de tamaño mediano, de cuello largo y peso promedio de 1,72 kg
		replace cantidad_3=cantidad*1720 if (unidad_medida ==110 & bien == 47)
		replace unidad_3=1 if (unidad_medida ==110 & bien == 47)


	// Azucar
		// Teta (between 200-500) --> we use "Teta" (1): 250gr
		replace cantidad_3=cantidad*250	if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teta")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teta")
		// Teticas (between 50-150 grams) --> we use "Tetica" (1): 100g
		replace cantidad_3=cantidad*250	if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teticas")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teticas")

		
	//Cafe (COD:71)
		// Unidad (otro):bolsa de 200 grs.
		replace cantidad_3=cantidad*200 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot=="bolsa de 200 grs.")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot=="bolsa de 200 grs.")
		// Unidad (otro): de cuarto de kilo
		// "1/4 de kilo" (1) to gram (250)
		replace cantidad_3=cantidad*250 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot=="de cuarto de kilo")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot=="de cuarto de kilo")
		// Teta (between 100-500 grams) --> we use "Teta" (1): 250g
		replace cantidad_3=cantidad*250 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "Teta")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "Teta")
		// Teticas (between 50-150 grams) --> we use "Tetica" (1): 100g
		replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "Teticas")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "Teticas")
		// Bulto (1): 50kg : 5000g
		// For those reporting the weight of "Bulto" in kg
		replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "bulto" & cantidad>=10)
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "bulto" & cantidad>=10)	
	    // Bulto (1): 50kg : 5000g
		// For those reporting "Bulto"
		replace cantidad_3=cantidad*5000 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "bulto" & cantidad<10)
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "bulto" & cantidad<10)	
		// Bolsa
		// Assume equal "Teta" (between 100-500 grams) --> we use "Teta" (1): 250g
		replace cantidad_3=cantidad*250 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "Bolsa")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "Bolsa")


	// Cambur(COD:38)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/9/2020
		// Unidades (1): 110g
		replace cantidad_3=cantidad*110 if (unidad_medida ==110 & bien == 38)
		replace unidad_3=1 if (unidad_medida ==110 & bien == 38)

		
	// Caraotas	(COD:53)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/9/2020
		
		
	// Carne de pollo/gallina (COD:22)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/9/2020

		
	// Carne de res (bistec) (COD:12)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020

		
	// Carne de res (molida) (COD:13)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020
	
	
	// Carne de res (para esmechar) (COD:14)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020
	
	
	// Cebolla (COD:46)
		// Unidad (1) cebolla mediana:75g
	    replace cantidad_3=cantidad*75 if (unidad_medida == 110 & bien == 46 )
		replace unidad_3=1 if (unidad_medida == 110 & bien == 46 )
		
		
	// Cebollin/ ajoporro (COD:51)
		// Unidad (1) cebolla mediana:75g
	    replace cantidad_3=cantidad*75 if (unidad_medida == 110 & bien == 51)
		replace unidad_3=1 if (unidad_medida == 110 & bien == 51)
	
	
	// Chorizo, jamón, mortaleda y otros embut (COD:20)
		// Pieza(1): 100g
	    replace cantidad_3=cantidad*100 if (unidad_medida == 30 & bien == 20 )
		replace unidad_3=1 if (unidad_medida == 30 & bien == 20 )
		// Unidad (1): 100g
	    replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="Unidad")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="Unidad")
		
		
	// Cilantro (COD:52)
		// Bolsita (1): 120g
		replace cantidad_3=cantidad*120 if (unidad_medida == 60 & bien == 52 & unidad_medida_ot== "bolsita")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "bolsita")		
		// Paquete (1): 200g
		replace cantidad_3=cantidad*200 if (unidad_medida == 60 & bien == 52 & unidad_medida_ot== "paquete")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "paquete")

		
	// Condimentos (COD:75)
		//Bolsita 
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Bolsita" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Bolsita" & bien==75)
        //Caja
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Caja" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Caja" & bien==75)
        //Frasco
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Frasco" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Frasco" & bien==75)
        //Papeletas
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Papeletas" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Papeletas" & bien==75)	
        //Pote 
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "pote" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "pote" & bien==75)
        //Sobresito
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "sobresito" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "sobresito" & bien==75)	
		//Onza
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "onza" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "onza" & bien==75)

		
	//Frijoles (COD: 54)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020
	
	
	// Harina de arroz (COD: 2)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020

*************************
*PROVISIORIO!!! CORREGIR PIEZA DE PAN (SE USARON LOS GRAMOS DE REBANADA)
*************************			
		
	// Harina de maiz (COD: 7)
		// Pieza de pan 
		//Tamano: Grande (campesino)
		replace cantidad_3=cantidad*250 if (unidad_medida == 40 & bien==7 & tamano==4 )
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==4 & tamano==4)
		// Pieza de pan 
		//Tamano: Mediano (canilla)		
		replace cantidad_3=cantidad*130 if (unidad_medida == 40 & bien==7 & tamano==5)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==7 & tamano==5)
		// Pieza de pan 
		//Tamano: Pequeno (frances)
		replace cantidad_3=cantidad*50 if (unidad_medida == 40 & bien==7 & tamano==6)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==7 & tamano==6)

	// Hueso de res, pata de res, pata de pollo	(COD:19)
		// Pieza
		// Pata de pollo (120-150g)
		
		// Otro (Unidad)
	
	
	// "Huevos" in "carton" and "medio carton"
		// "carton" (1) to unit (30)
		replace cantidad_3= cantidad*30 if unidad_medida == 91 & (bien==34) 
		// "medio carton" (1) to unit (15)
		replace cantidad_3= cantidad*15 if unidad_medida == 92 & (bien==34) 
		replace unidad_3= 3 if (unidad_medida == 91 | unidad_medida == 92) & bien== 34
		// Carton de 6 unidades
		replace cantidad_3=cantidad*6 if (unidad_medida==60 & bien==34 & unidad_medida_ot=="Mini cartón de 6 unidades")
		replace unidad_3=3 if (unidad_medida==60 & bien==34 & unidad_medida_ot=="Mini cartón de 6 unidades")
	    // Unidad: 60g
		replace cantidad_3=cantidad if (unidad_medida==110 & bien==34 )
		replace unidad_3=3 if (unidad_medida==110 & bien==34 )

	
	//Leche en polvo, completa o descremada
		// Unidad(1): 500g
		replace cantidad_3=cantidad*500 if (unidad_medida == 110 & bien == 29 )
		replace unidad_3= 1 if (unidad_medida == 110 & bien == 29 )
		// Teta (between 100-500 grams) --> we use "Teta" (1): 250g
		replace cantidad_3=cantidad*250 if (unidad_medida == 60 & bien == 29 & unidad_medida_ot== "Teta")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 29 & unidad_medida_ot== "Teta")

	
*************************
*PROVISIORIO!!! CORREGIR PIEZA DE PAN (SE USARON LOS GRAMOS DE REBANADA)
*************************			
	// Pan de trigo 
		// Grande (campesino)
		replace cantidad_3=cantidad*250 if (unidad_medida == 40 & bien==9 & tamano==4 )
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9 & tamano==4)
		// Mediano (canilla)
		replace cantidad_3=cantidad*130 if (unidad_medida == 40 & bien==9 & tamano==5)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9 & tamano==5)
		// Pequeno (frances)
		replace cantidad_3=cantidad*50 if (unidad_medida == 40 & bien==9 & tamano==6)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9 & tamano==6)
		// "Rebanada de pan" 23g
		// using data from Hernandez et al (2015)
		replace cantidad_3 = cantidad*23 if (unidad_medida == 40 & bien==9)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9)
        // Otro "De Sandwich"
		// We assume that it has 10 rebanadas
		// "Rebanada de pan" 23g
		replace cantidad_3 =cantidad*23*10 if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="De Sandwich")
		replace unidad_3 =1	if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="De Sandwich")
		// Otro	"Bolsa de 10 panes pequenos" 
		// Pan (1): 23g
        replace cantidad_3 = cantidad*50*10 if (unidad_medida == 60 & bien == 9 & unidad_medida_ot== "bolsa de 10 panes pequeños")
		replace unidad_3 =1	if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="bolsa de 10 panes pequeños")
		// Otro	"Paquete" 
		// We assume that it has 10 rebanadas
		// "Rebanada de pan" 23g
        replace cantidad_3 = (cantidad*23*10) if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="paquete") 
		replace unidad_3 =1	if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="paquete" )
		// Otro	"Paqute de 10 panes pequenos" 	 
        replace cantidad_3 = (cantidad*50*10) if (unidad_medida == 60 & bien == 9 & unidad_medida_ot==  "paquete de 10 unidades")
		replace unidad_3 =1	if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="paquete de 10 unidades")
		// Otro	"paquete de dos panes canilla"	 
        replace cantidad_3 = (cantidad*2*130) if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="paquete de dos panes canilla")
		replace unidad_3 =1	if (unidad_medida == 60 & bien == 9 & unidad_medida_ot=="paquete de dos panes canilla")

		
	// Platanos
		// Unidad (mediana sin piel): 80g
		replace cantidad_3=cantidad*80 if (unidad_medida==110 & bien==40)
		replace unidad_3=1 if (unidad_medida==110 & bien==40)

		
	// Papelon		
		//Panela
		// We assume #(1): 250g
	    replace cantidad_3=cantidad*250 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Panela")
		replace unidad_3=3 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Panela")
		//Unidad
		// We assume #(1): 250g
	    replace cantidad_3=cantidad*250 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Unidad")
		replace unidad_3=3 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Unidad")
		//Pieza 
		// We assume #(1): 250g
		replace cantidad_3=cantidad*250 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Pieza")
		replace unidad_3=3 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Pieza")
		//Pieza pequena
		// We assume #(1): 100g
		replace cantidad_3=cantidad*250 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="pieza pequena")
		replace unidad_3=3 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="pieza pequena")
		
		
	// Sardinas frescas/congeladas
		// Lata (1): 120g
		replace cantidad_3=cantidad*120 if (unidad_medida == 80 & bien == 24 & tamano==.)
		replace unidad_3= 1 if (unidad_medida == 80 & bien == 24 & tamano==.)
		

		
	//Tomate
		// Unidad(1): 100g
		replace cantidad_3=cantidad*100 if (unidad_medida == 110 & bien == 43 )
		replace unidad_3= 1 if (unidad_medida == 110 & bien == 43 )
		
		
	//Margarina/Mantequilla
		// "Margarina/Mantequilla" in "Lata"
		// "lata" (1) to gram (360)
		// using "Lactuario de Maracay mantequilla" standard size as benchmark
		replace cantidad_3 = cantidad*360 if (unidad_medida == 60 & unidad_medida_ot== "lata" & bien==36)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "lata" & bien==36)
		// "Margarina/Mantequilla" in "Barra"
		// "Barra" (1) to grams (200)
		// based on brand Los Andes product "mantequilla en barra"
		replace cantidad_3 = cantidad*200 if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad<10 & bien==36)
        replace unidad_3 = 1 if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad<10 & bien==36)
		// "Margarina/Mantequilla" in "Barra" when the quantity reported is actually grams
		replace cantidad_3 = cantidad if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad>100 & bien==36)
		replace unidad_3 = 1 if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad>100 & bien==36)

		
	//Yuca
		// "torta" (1) to gramos (283)
		// based on torta casaba "Guarani 283 gr." (Dominicana)
		replace cantidad_3 = cantidad*283 if (unidad_medida == 160 & bien==61)
		replace unidad_3 = 1 if (unidad_medida == 160 & bien==61)

		
	// "Casabe" in "torta" 
		// "torta" (1) to gramos (283)
		// based on torta casaba "Guarani 283 gr." (Dominicana)
		replace cantidad_3 = cantidad*283 if (unidad_medida == 160 & bien==65)
		replace unidad_3 = 1 if (unidad_medida == 160 & bien==65)

		
	// Sal
		// Bolsita
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Bolsita" & bien==74 & cantidad<10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Bolsita" & bien==74 & cantidad<10)
		// Teta
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad<10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad<10)
		replace cantidad_3 = cantidad if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad>=10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad>=10)
		// Teticas
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Teticas" & bien==74 & cantidad<10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Teticas" & bien==74 & cantidad<10)
		// Bulto (1): 5kg : 5000g
		replace cantidad_3 = cantidad*5000 if (unidad_medida == 60 & unidad_medida_ot== "bulto" & bien==74)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "bulto" & bien==74)
	

/*		
//mm	//"Galletas"
		// Based on Venezuelean famous brands' packaging
		// "paquete pequeño" 25g
		replace cantidad_3 = cantidad*25 if (unidad_medida == 60 & bien== 3 & tamano==3)
		replace unidad_3 = 1 if (unidad_medida == 60 & bien==3 & tamano== 3)
		// "paquete mediano" 108g
		replace cantidad_3 = cantidad*108 if (unidad_medida == 60 & bien== 3 & tamano==2)
		replace unidad_3 = 1 if (unidad_medida == 60 & bien== 3 & tamano== 2)
		// "paquete grande" 240g
		replace cantidad_3 = cantidad*240 if (unidad_medida == 60 & bien== 3 & tamano==1)
		replace unidad_3 = 1 if (unidad_medida == 60 & bien== 3 & tamano==1)

//mm	// "Pescado enlatado" 
		// "lata" (1) to gram (129)
		// Atunmar standard size 
		replace cantidad_3 = cantidad*129 if unidad_medida == 80 & bien==19
		replace unidad_3 = 1 if (unidad_medida == 80 & bien==19)
		// Any other fish in can units
		// "lata" (1) to gram (129)
		// // Atunmar standard size 
		replace cantidad_3 = cantidad*270 if unidad_medida == 80 & inrange(bien,20, 23)
		replace unidad_3 = 1 if unidad_medida == 80 & bien== 80 & inrange(bien,20, 23)
	
		 
//mm		 //"Manteca"
	// "Cucharada" "grande" (10g)
	// "Cucharada" "pequeña" (5g)
	// based on Hernandez et al (2015)
	replace cantidad_3 = cantidad*10 if (unidad_medida == 210 & bien == 34 & tamano==1)
	replace cantidad_3 = cantidad*5 if (unidad_medida == 210 & bien == 34 & tamano==3)
	replace unidad_3 = 1 if (unidad_medida==210 & bien==34)
	

//mm	// "Carne enlatada" in "lata" 
		// "lata" 340g
		// based on SPAM standard size, a US brand with strong presence in Venezuela
		replace cantidad_3 = cantidad*340 if (unidad_medida == 80 & bien==16)
		replace unidad_3 = 1 if (unidad_medida == 80 & bien==16)

//mm	//"Suero"
		// "envase de plastico" 900ml
		replace cantidad_3 = cantidad*900 if (unidad_medida == 120 & bien == 30)
		replace unidad_3 = 2 if (unidad_medida==120 & bien==30)
	


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
*/

	tab bien unidad_medida if cantidad_3==. & unidad_3==.
	tab bien unidad_medida if cantidad_3==. & unidad_3==., nolab

/*(************************************************************************************************************************************************* 
* 4: Price transformation: From gram, liters or unit to grams
*************************************************************************************************************************************************)*/
	// Standardrized grams
	gen cantidad_h = .
	replace cantidad_h = cantidad_3 if unidad_3==1
	
	// From mililiters to standarized grams 
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

	
	// Transform units to grams
	// "Huevos"
	// used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
	// weight = 52.5 gr/unit
	replace cantidad_h = cantidad_3*52.5 if unidad_3==3 & bien==34

	
/*(************************************************************************************************************************************************* 
* 5: Price transformation
*************************************************************************************************************************************************)
 This section calculates the price per gram 
   Given that the previous section transform all units into grams or equivalents,
   we only need to divide the prices from the survey with the new quantities	 
*/

// 5.1 Currency transformation
*----------- Transform prices from euros, dollar & pesos colombianos to bolivares
*----------- Using the monthly average exchange rate
	gen precio_b=precio
	replace precio_b=(precio*mean_moneda) if (moneda==2 | moneda==3 | moneda==4)
	
// 5.2 Units transformation
*----------- Transform regular prices to price per gram
	gen precio_gramo=(precio_b/cantidad_3)
	// Genera missing values para aquellos productos que no estan corregidos
	
/*(************************************************************************************************************************************************* 
* 0: Assesment of errors (prices)
*************************************************************************************************************************************************)

foreach level of local foodlist {
	local vf: label `fname' `f'
	display "food = `vf'"	
	qui levelsof unidad_medida if bien ==`f', local(units)
	local uname: value label unidad_medida


	foreach u of local units {
		display "-------------"
		display "-------------"
		
		local vu: label `uname' `u'
		qui levelsof unidad_medida_ot if bien ==`f' & unidad_medida ==`u', local(units_ot)
		

	tab precio if (bien ==`f' & unidad_medida==`u'), mi
	}
}
*/
	
/*(************************************************************************************************************************************************* 
* 6: Price Index (low quality)
*************************************************************************************************************************************************)
*/

// Data to analyse coverage: number of goods and prices by region-month
// Converted to Bolivares but not standard units
preserve
	collapse (mean) mean_p = precio_b (median) median_b = precio_b (count) obs_p = precio_b , by (ENTIDAD mes bien)
	//export excel using "$dataout/precio_desc", sheet("Precio medio y mediano (mes-reg-prod)",replace) firstrow(varlabels)
restore

// Data to analyse price behaviour
// Converted to Bolivares per gram
//preserve
//	collapse (mean) mean_p = precio_gramo (median) median_p = precio_gramo (count) obs_p = precio_gramo, by (ENTIDAD mes bien)
//	export excel using "$dataout/precio_desc", sheet("Cantidad de precios (mes-reg)",replace) firstrow(varlabels)
//restore


// Preliminary prices for poverty lines
preserve
	collapse (median) median_b = precio_gramo (count) obs_p = precio_gramo , by (ENTIDAD mes bien)
	//export excel using "$dataout/precio_desc", sheet("Index (median)",replace) firstrow(varlabels)
	save "$dataout/cleaned/median_price_gram.dta", replace
restore



