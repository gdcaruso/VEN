/*===========================================================================
Purpose: 
1) Generate descriptive statistics for prices from ENCOVI Survey 2019
2) Clean price data
3) Generate the price database for Poverty Calculation 
(ONLY for completed surveys)

Country name:	Venezuela
Year:			2019
Project:	
---------------------------------------------------------------------------
Authors:			Julieta Ladronis & Daniel Pereira

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Claned Price Database 

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   1
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN"
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

	global dataofficial "$rootpath\data_management\input\04_07_20"
	global dataout "$rootpath\data_management\output"
	global dataint "$dataout\intermediate"
    // Set the  path for prices
	global pathprc "$dataofficial\ENCOVI_prices_2_STATA_All"
	global exch_rate "$rootpath\data_management\management\1. merging\exchange rates"
	
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Merge prices data   --------------------------------------------------

*************************************************************************************************************************************************)*/ 
**** Preliminary information: completed surveys

	//Keep completed by Approbed by HQ (only leaves 25 obs) So we are using completed
//	use "$pathprc\interview__actions.dta", clear
	
	// Create a tempfile for completed surveys
//  tempfile completed_surveys
	
	// Create identification for completed surveys
//	bys interview__key interview__id (date time): keep if action[_N]==6 // 3=Completed & approved by HQ (as last step)
	
	// To identify unique interviews according the last date and time entered
//  bys interview__key interview__id (date time) : keep if _n==_N

	
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
			
*-------- Merge with exchange rates data	
		// Exchange rates 
		merge m:1 mes moneda using "$exch_rate\exchenge_rate_price"
		// Delete information which is only in the exchange rates dataset 
		drop if _merge==2
		// Drop auxiliary variable
		drop _merge
		
*----------- Currency transformation
*----------- Transform prices from euros, dollar & pesos colombianos to bolivares
*----------- Using the monthly average exchange rate
		gen precio_b=precio
		replace precio_b=(precio*mean_moneda) if (moneda==2 | moneda==3 | moneda==4)
		label var precio_b "Precios convertidos a Bolivares"


/*(************************************************************************************************************************************************* 
* 		Selection of items
*************************************************************************************************************************************************)
  Select only items which we are going to use for the basket in the poverty lines
  This simplify the problem of units and measures correction 
*/
	// Items selection
		keep if bien== 1 | bien== 2 | bien== 7 | bien== 8 | bien== 9 | bien== 10 | ///           
		bien== 12 | bien== 13 | bien==  14 |  bien== 19 | bien==  20 | ///
		bien== 22 | bien== 24 |  bien==  26 | bien== 29 | bien== 31 | ///
		bien== 34 | bien== 35 | bien== 36 | bien== 37  | bien== 38 | bien== 40 | bien== 41 | bien== 43 | ///
		bien== 45 |  bien== 46 | bien== 47 | bien== 50 | bien== 51 | bien== 52 | ///
		bien== 53 | bien== 54 | bien== 55 | bien== 61 | bien== 62 | bien== 66 | ///                   
		bien== 67 | bien== 71 | bien== 74 

		
	// Check on Units 	
		tab unidad_medida
		tab unidad_medida_ot
		
/*
As a result we have the following list of units

					  
					  Unidad      |      Freq.     Percent        Cum.
----------------------------------+-----------------------------------
                       Kilogramos |      4,418       60.63       60.63
                           Gramos |      1,550       21.27       81.90
                           Litros |        309        4.24       86.14
                       Mililitros |         55        0.75       86.89
                             Taza |          2        0.03       86.92
Pieza (bistec,chuleta, similares) |          6        0.08       87.00
                     Pieza de pan |        170        2.33       89.34
                             Otro |        114        1.56       90.90
                             Lata |          4        0.05       90.96
                           Cartón |        126        1.73       92.69
                     Medio cartón |         41        0.56       93.25
                           Unidad |        482        6.61       99.86
                            Bolsa |          9        0.12       99.99
                   Torta (casabe) |          1        0.01      100.00
----------------------------------+-----------------------------------
                            Total |      7,287      100.00


 Without taking into account other measures or sizes
 
*/

/*(************************************************************************************************************************************************* 
* 1: Units (missing values) correction 
*************************************************************************************************************************************************)*/

// Missing values correction
	local errormis cantidad unidad_medida 
	foreach x of local errormis {
	replace `x'=. if `x'==.a
	}
	
// Kilograms
	// For Azucar we can replace missing values of units if the quantity is 1
	// We assume it is 1 kg
	replace unidad_medida=1 if (bien==66 & cantidad==1)
    replace unidad_medida=1 if (bien==1 & cantidad==1)
	
/*(************************************************************************************************************************************************* 
* 1: Units (other) correction 
*************************************************************************************************************************************************)*/

//Paquetes
	*-----------
	// This measure appears in "Other Units" but it should be part of "Units"
	// First: standarized the names
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="PAQUETES") 
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="paquete")  
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="paquetes")
	replace unidad_medida_ot="Paquete" if (unidad_medida_ot=="De Sandwich")
	// Replace the main variable for Unidad de Medida
	replace unidad_medida=64 if (unidad_medida_ot=="Paquete")
	
//Unidad
	*-----------
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidad de Oreo" & bien==4) // Galletas dulces
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidades") 
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidad") 
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="1")
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidad de Salchicha")  
	replace unidad_medida_ot="Unidad" if (unidad_medida_ot=="unidad de salchicha")  
	// Replace the main variable for Unidad de Medida
	replace unidad_medida=110 if (unidad_medida_ot=="Unidad")
	// Delete old unit
	replace unidad_medida_ot="" if (unidad_medida_ot=="Unidad" & unidad_medida==110)
 
 //Tetas
	*-----------
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="teta")  
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="tetas")
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="paquetito (teta)")
	replace unidad_medida_ot="Teticas" if (unidad_medida_ot=="bolsitas de 100 grs. (teticas)")
	replace unidad_medida_ot="Teticas" if (unidad_medida_ot=="teticas") 
	replace unidad_medida_ot="Teticas" if (unidad_medida_ot=="bolsita (teticas)") 
	replace unidad_medida_ot="Teta" if (unidad_medida_ot=="se vende prwsentacion.de.teta 100 gramos")

//Bolsita
	*-----------
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bosita")  
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bolsita")
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bolsitas")
	replace unidad_medida_ot="Bolsita" if (unidad_medida_ot=="bolsistas")

//Panela
	*-----------
	replace unidad_medida_ot="Panela" if (unidad_medida_ot=="panela")  
	replace unidad_medida_ot="Panela" if (unidad_medida_ot=="panelas") 	
	
//Pieza	
	*-----------
	replace unidad_medida_ot="Pieza" if (unidad_medida_ot=="pieza")
	// Replace the main variable: 30 "Pieza (bistec,chuleta, similares)"
	replace unidad_medida=30 if (unidad_medida_ot=="Pieza" & (bien==12 | bien==14 | bien==19| bien==20))
	// Replace the main variable: 40 "Pieza de pan" 
	replace unidad_medida=40 if (unidad_medida_ot=="Pieza" & bien==9)
	// Replace the main variable: 50 "Pieza (rueda, pescado entero)"
	replace unidad_medida=50 if (unidad_medida_ot=="Pieza" & bien==26)
	// Replace Pieza for Panela (Bien-COD:67)
	replace unidad_medida_ot="Panela" if (bien==67 & unidad_medida==60 & unidad_medida_ot=="Pieza")

//Sobre
	*-----------
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="Sobresitos")  
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="sobresito")
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="SOBRE")
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="sobre 100 gr")
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="sobre")  
	replace unidad_medida_ot="Sobre" if (unidad_medida_ot=="sobres")
	
// Barra
	*-----------
	replace unidad_medida_ot="Barra" if (unidad_medida_ot=="barra")  
	replace unidad_medida_ot="Barra" if (unidad_medida_ot=="barrita") 
	// Replace the main variable for Unidad de Medida
	replace unidad_medida=220 if (unidad_medida_ot=="Barra")

// Pasta de chorizo changed as grams
	*-----------
	replace unidad_medida=2 if (unidad_medida_ot=="pasta de chorizo")
	
// Cuarto de kilo
	*-----------	
	replace unidad_medida=2 if (bien==71 & unidad_medida_ot=="un cuarto de kilo")
	replace unidad_medida=2 if (bien==71 & unidad_medida_ot=="1/4 de kilo")
	replace cantidad=250 if (bien==71 & unidad_medida_ot=="un cuarto de kilo")
	replace cantidad=250 if (bien==71 & unidad_medida_ot=="1/4 de kilo")
	
// Bulto	
   replace unidad_medida_ot="Bulto" if unidad_medida_ot=="bulto"
   replace unidad_medida_ot="Bulto" if unidad_medida_ot=="bultos"

// Lata   
  replace unidad_medida=80 if unidad_medida==60 & unidad_medida_ot=="Lata" & bien==8  // Maiz en grano
  replace unidad_medida_ot="" if (unidad_medida==80 & unidad_medida_ot=="Lata" & bien==8)
/*(************************************************************************************************************************************************* 
* 0: Assesment of errors (quantities)
*************************************************************************************************************************************************)*/


log using "$rootpath\data_management\management\3. cleaning\quantities_for_price_data_v2", text replace


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
		

	// Prices at good-unit-size level

log close

	preserve
	collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida tamano cantidad)
	export excel using "$dataout/resumen_unidad", sheet("Unidad") firstrow(varlabels) replace
	restore	

	preserve
	collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida unidad_medida_ot tamano cantidad)
	export excel using "$dataout/resumen_otro", sheet("Unidad de medida (otro)") firstrow(varlabels) replace
	restore	
	

/*(************************************************************************************************************************************************* 
* 3: Error correction (First stage)
*************************************************************************************************************************************************)
	Authors:			Daniel Pereira
	Creation Date:		March, 2020
	Modification Date:  
	Output:			    First stage:
						Cleaned data for prices in Bolivares
						Considering the analysis units vs prices
						Considering only general units

*/
*************************************************************************************************************************************************)
*--------- General

//	Keep only precio_bs in Bolivares 
//  Without considering missing values
	drop if precio_b==.
	
// Auxiliary variable to make changes
	decode bien, gen(food)
	
*--------- Specific good error correction

//	Aceite
*-----------
	replace unidad_medida=2 if food=="Aceite" & unidad_medida==1 & cantidad==900	
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==2 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Aceite" & unidad_medida==2 & cantidad==1	
	drop if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio>1000000	
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==3 & cantidad==2 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==3 & cantidad==4 & precio_b<1000		
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==10
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==15
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==20
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==24
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==40
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==48
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==100
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==144
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==180
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==300
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==480
	replace cantidad=0.5 if unidad_medida==3 & food=="Aceite" & cantidad==500
	replace cantidad=0.9 if unidad_medida==3 & food=="Aceite" & cantidad==900
	replace precio_b=precio_b*100 if food=="Aceite" & unidad_medida==4 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==4 & food=="Aceite" & cantidad==1
	replace cantidad=1000 if unidad_medida==4 & food=="Aceite" & cantidad==15


//	Aji dulce, pimentón, pimiento
*-----------
	replace precio_b=precio_b*3000 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Aji dulce, pimentón, pimiento" & cantidad==9
	replace cantidad=1 if unidad_medida==1 & food=="Aji dulce, pimentón, pimiento" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Aji dulce, pimentón, pimiento" & cantidad==100
	replace precio_b=precio_b*1000 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Aji dulce, pimentón, pimiento" & cantidad==1
	replace precio_b=precio_b*10 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==2 & cantidad==2 & precio_b<10000		
	replace cantidad=2000 if unidad_medida==2 & food=="Aji dulce, pimentón, pimiento" & cantidad==2
	replace precio_b=precio_b*1000 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==110 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==110 & cantidad==1	


//	Arroz
*-----------
	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==3 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==3
	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==5 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==5
	replace precio_b=precio_b*10000 if food=="Arroz" & unidad_medida==1 & cantidad==20 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==29
	replace precio_b=precio_b*10 if food=="Arroz" & unidad_medida==1 & cantidad==30 & precio_b<1000000		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==48
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==80
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==100
	replace unidad_medida=2 if food=="Arroz" & unidad_medida==1 & cantidad==300	
	replace unidad_medida=2 if food=="Arroz" & unidad_medida==1 & cantidad==500	
	replace precio_b=75000 if cantidad==75000 & food=="Arroz"		
	replace cantidad=1 if cantidad==75000 & food=="Arroz"

//	Auyama
*-----------
	replace cantidad=1000 if unidad_medida==2 & food=="Auyama" & cantidad==1	
	
//	Azúcar
*-----------
	replace precio_b=precio_b*1000 if food=="Azúcar" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Azúcar" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace precio_b=precio_b*5000 if food=="Azúcar" & unidad_medida==1 & cantidad==5 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==6
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==8
	replace precio_b=precio_b*20000 if food=="Azúcar" & unidad_medida==1 & cantidad==20 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==25
	replace precio_b=precio_b*30 if food=="Azúcar" & unidad_medida==1 & cantidad==30 & precio_b<1000000		
	replace precio_b=precio_b*40 if food=="Azúcar" & unidad_medida==1 & cantidad==40 & precio_b<1000000		
	replace precio_b=precio_b*50000 if food=="Azúcar" & unidad_medida==1 & cantidad==50 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==55
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==80
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==120
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==380
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==480
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==1000
	replace precio_b=85000 if cantidad==85000 & food=="Azúcar"		
	replace cantidad=1 if cantidad==85000 & food=="Azúcar"
	replace cantidad=6000 if unidad_medida==2 & food=="Azúcar" & cantidad==6
*	drop if food=="Azúcar" & unidad==2 & cantidad==50		

//	Café
*-----------
	replace cantidad=1 if unidad_medida_ot=="Bulto" & food=="Café" 
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==6
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==12 & precio_b<1000000
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==15 & precio_b<1000000
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==20 & precio_b<1000000
	replace cantidad=0.25 if unidad_medida==1 & food=="Café" & cantidad==250
	replace cantidad=0.5 if unidad_medida==1 & food=="Café" & cantidad==500
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==4
	replace precio_b=precio_b*10000 if food=="Café" & unidad_medida==2 & cantidad==6		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==6
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==12
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==15
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==19
	replace precio_b=precio_b/50 if food=="Café" & unidad_medida==2 & cantidad==20 & precio_b>10000		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==24
	replace precio_b=precio_b*25 if food=="Café" & unidad_medida==2 & cantidad==25 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==48
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==72
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==2 & cantidad==400		
	replace cantidad=200 if unidad_medida==2 & food=="Café" & cantidad==2000
	replace cantidad=200 if unidad_medida==2 & food=="Café" & cantidad==200000
	replace cantidad=250 if unidad_medida==2 & food=="Café" & cantidad==250000
	//replace precio_b=precio_b*10000 if food=="Café" & unidad_medida==60 & cantidad==1		


// Cambur
*-----------
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==20 & precio_b<100000
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==50

// Caraotas
*-----------
	drop if precio_b>999999 & food=="Caraotas" & unidad_medida==1 & cantidad==1			
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==10 & precio_b<250000
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==11
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==15
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==70
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==120
	replace precio_b=90000 if cantidad==90000 & food=="Caraotas"		
	replace cantidad=1 if cantidad==90000 & food=="Caraotas"
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==18
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==20
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==25
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==100
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==340
	replace cantidad=250 if unidad_medida==2 & food=="Caraotas" & cantidad==250000


//	Carne de pollo/gallina
*-----------
	replace precio_b=precio_b*1000 if food=="Carne de pollo/gallina" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==70
	replace precio_b=precio_b*1000 if food=="Carne de pollo/gallina" & unidad_medida==1 & cantidad==100 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==200
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Carne de pollo/gallina" & cantidad==1


//	Carne de res (bistec)
*-----------
	replace precio_b=precio_b*1000 if food=="Carne de res (bistec)" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (bistec)" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (bistec)" & cantidad==50 & precio_b==210000
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (bistec)" & cantidad==300	

	
//	Carne de res (molida)
*-----------
	replace precio_b=precio_b*1000 if food=="Carne de res (molida)" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==40
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==400	

	
//	Carne de res (para esmechar)
*-----------
	replace precio_b=precio_b*1000 if food=="Carne de res (para esmechar)" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==40
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==400	
	
	
//	Cebolla
*-----------
	replace precio_b=precio_b*1000 if food=="Cebolla" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Cebolla" & cantidad==9
	replace precio_b=precio_b*10 if food=="Cebolla" & unidad_medida==1 & cantidad==10 & precio_b<100000		
	replace precio_b=precio_b*10 if food=="Cebolla" & unidad_medida==1 & cantidad==20		
	replace cantidad=1 if unidad_medida==1 & food=="Cebolla" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Cebolla" & cantidad==100
	replace precio_b=precio_b*1000 if food=="Cebolla" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==1
	replace precio_b=precio_b*1000 if food=="Cebolla" & unidad_medida==2 & cantidad==6 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==6
	replace precio_b=precio_b*10 if food=="Cebolla" & unidad_medida==2 & cantidad==100 & precio_b<10000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==100
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==200	
	
	
//	Cebollin, ajoporro.
*-----------
	replace cantidad=1 if unidad_medida==1 & food=="Cebollin, ajoporro." & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Cebollin, ajoporro." & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Cebollin, ajoporro." & cantidad==1	
	
//	Chorizo, jamón, mortaleda y otros embutidos
*-----------
	replace precio_b=precio_b*1000 if food=="Chorizo, jamón, mortaleda y otros embutidos" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000*10 if food=="Chorizo, jamón, mortaleda y otros embutidos" & unidad_medida==1 & cantidad==10 & precio_b<1000		
	replace precio_b=precio_b*1000*15 if food=="Chorizo, jamón, mortaleda y otros embutidos" & unidad_medida==1 & cantidad==15 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==35
	replace cantidad=1 if unidad_medida==1 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==70
	replace precio_b=270000 if cantidad==270000 & food=="Chorizo, jamón, mortaleda y otros embutidos"		
	replace cantidad=1 if cantidad==270000 & food=="Chorizo, jamón, mortaleda y otros embutidos"
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==1
	replace cantidad=10000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==10
	replace cantidad=15000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==15
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==48
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==150
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==200
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==650
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==750	

	
//	Cilantro
*-----------
	drop if food=="Cilantro" & unidad_medida==1 & cantidad==1 & precio==2938404864			
	replace cantidad=1 if unidad_medida==1 & food=="Cilantro" & cantidad==2
	replace cantidad=1 if unidad_medida==1 & food=="Cilantro" & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Cilantro" & cantidad==10
	replace cantidad=500 if unidad_medida==2 & food=="Cilantro" & cantidad==0
	replace precio_b=precio_b*1000 if food=="Cilantro" & unidad_medida==2 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Cilantro" & unidad_medida==2 & cantidad==1	
	replace cantidad=100 if unidad_medida==2 & food=="Cilantro" & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Cilantro" & cantidad==200 & precio_b>=100000
	replace cantidad=1 if unidad_medida==2 & food=="Cilantro" & cantidad==. & precio_b>=100000	


//	Frijoles
*-----------
	replace precio_b=precio_b*1000 if food=="Frijoles" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*10 if food=="Frijoles" & unidad_medida==1 & cantidad==10 & precio_b<100000		
	replace cantidad=1 if unidad_medida==1 & food=="Frijoles" & cantidad==200
	drop if precio_b>999999 & food=="Frijoles" & unidad_medida==2 & cantidad==1			
	replace cantidad=1000 if unidad_medida==2 & food=="Frijoles" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Frijoles" & cantidad==20
	replace cantidad=300 if unidad_medida==2 & food=="Frijoles" & cantidad==30
	replace cantidad=300 if unidad_medida==2 & food=="Frijoles" & cantidad==60	
	
//	Harina de arroz
*-----------
	replace precio_b=precio_b*1000 if food=="Harina de arroz" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de arroz" & cantidad==8
	replace cantidad=1 if unidad_medida==1 & food=="Harina de arroz" & cantidad==20
	replace precio_b=precio_b*1000 if food=="Harina de arroz" & unidad_medida==1 & cantidad==36 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de arroz" & cantidad==36
	replace cantidad=5.0 if unidad_medida==1 & food=="Harina de arroz" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Harina de arroz" & cantidad==1	
	
	
//	Harina de maiz
*-----------
	replace precio_b=precio_b*1000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*2000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==2 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==3
	replace precio_b=precio_b*4000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==4 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==15
	replace precio_b=precio_b*20000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==20 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==39
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==48
	replace precio_b=precio_b*1000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==53 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==53
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==200
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==216
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==300
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==600
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==1000
	replace cantidad=1000 if unidad_medida==2 & food=="Harina de maiz" & cantidad==1
	replace bien=9 if food=="Harina de maiz" & unidad_medida==40			
	replace bien=9 if food=="Harina de maiz" & unidad_medida==40			
	replace bien=9 if food=="Harina de maiz" & unidad_medida==40				

	
//	Hueso de res, pata de res, pata de pollo
*-----------
	replace precio_b=precio_b*1000 if food=="Hueso de res, pata de res, pata de pollo" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Hueso de res, pata de res, pata de pollo" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Hueso de res, pata de res, pata de pollo" & cantidad==140	
	
	
//	Huevos (unidades)
*-----------
	replace unidad_medida=110 if food=="Huevos (unidades)" & unidad_medida==1 & cantidad==1 & precio_b<20000	
	drop if food=="Huevos (unidades)" & unidad_medida==91 & precio_b>1000000			
	replace precio_b=precio_b*2000 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==2 & precio_b<1000	
	replace unidad_medida=110 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==2	
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==6
	replace precio_b=precio_b*8 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==8 & precio_b<300000		
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==10
	replace precio_b=precio_b*12000 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==12		
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==20
	replace precio_b=precio_b*30 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==30 & precio_b<300000		
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==36
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==100
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==120
	replace cantidad=0.5 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==1 & precio_b>200000
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==15
	replace cantidad=0.5 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==24 & precio_b>200000
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==35
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==48
	replace precio_b=precio_b*1000 if food=="Huevos (unidades)" & unidad_medida==110 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*36000 if food=="Huevos (unidades)" & unidad_medida==110 & cantidad==36 & precio_b<1000			
			

//	Leche en polvo, completa o descremada
*-----------
	replace cantidad=0.5 if unidad_medida==1 & food=="Leche en polvo, completa o descremada" & cantidad==5
	replace cantidad=0.5 if unidad_medida==1 & food=="Leche en polvo, completa o descremada" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Leche en polvo, completa o descremada" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Leche en polvo, completa o descremada" & cantidad==20
	replace cantidad=1000 if unidad_medida==2 & food=="Leche en polvo, completa o descremada" & cantidad==96
	replace precio_b=precio_b*100000 if food=="Leche en polvo, completa o descremada" & unidad_medida==2 & cantidad==125 & precio_b<1000			


//	Lechosa
*-----------
	replace cantidad=1 if unidad_medida==1 & food=="Lechosa" & cantidad==5	
	
//	Lentejas
*-----------
	replace precio_b=precio_b*1000 if food=="Lentejas" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Lentejas" & cantidad==11
	replace cantidad=1 if unidad_medida==1 & food=="Lentejas" & cantidad==90
	replace cantidad=1000 if unidad_medida==2 & food=="Lentejas" & cantidad==1
	replace precio_b=precio_b/5 if food=="Lentejas" & unidad_medida==2 & cantidad==20 & precio_b>100000		
	replace cantidad=200 if unidad_medida==2 & food=="Lentejas" & cantidad==20
	replace precio_b=precio_b/5 if food=="Lentejas" & unidad_medida==2 & cantidad==250 & precio_b>100000		
	replace cantidad=200 if unidad_medida==2 & food=="Lentejas" & cantidad==2000
	replace cantidad=250 if unidad_medida==2 & food=="Lentejas" & cantidad==250000	
	
//	Maiz
*-----------
	replace unidad_medida=1 if bien==8 & unidad_medida==2 & cantidad==1 & precio_b>100000
	replace unidad_medida=1 if bien==8 & unidad_medida==2 & cantidad==15 & precio_b>100000
	replace cantidad=1 if bien==8 & unidad_medida==1 & cantidad==15 & precio_b>100000
	replace unidad_medida=2 if bien==8 & unidad_medida==1 & cantidad==1 & precio_b<=10000
	replace unidad_medida=2 if bien==8 & unidad_medida==1 & cantidad>=300 & cantidad<=500 & precio_b>=50000	& precio_b<=70000	
	replace unidad_medida=2 if bien==8 & unidad_medida==1 & cantidad==25 & precio_b>=30000 & precio_b<=40000
	replace cantidad=cantidad*10 if bien==8 & unidad_medida==2 & cantidad>=12 & cantidad<=25 & precio_b>=30000 & precio_b<=40000
	replace precio_b=precio_b*10 if bien==8 & unidad_medida==1 & cantidad==1 & precio_b>=15000 & precio_b<=30000
	replace cantidad=cantidad*100 if bien==8 & unidad_medida==2 & cantidad==1 & precio_b>=30000	& precio_b<=40000
	replace cantidad=cantidad*100 if bien==8 & unidad_medida==2 & cantidad==1 & precio_b>=30000
	replace precio_b=precio_b*10  if bien==8 & unidad_medida==2 & precio_b>=4000 & precio_b<=10000
	replace unidad_medida=2 if bien==8 & unidad_medida==1 & precio_b==60000 & cantidad==1
	replace cantidad=cantidad*100 if bien==8 & unidad_medida==2 & precio_b==60000 & cantidad==1
	replace precio_b=precio_b*10 if bien==8 & unidad_medida==1 & precio_b==35000
	replace unidad_medida=1 if bien==8 & unidad_medida==2 & cantidad==1 & precio_b==100000
	replace cantidad=cantidad*100 if bien==8 & unidad_medida==2 & precio_b>=60000 & precio_b<=85000 & cantidad==1
	replace cantidad=1 if  bien==8 & unidad_medida==2 & precio_b==13000
	replace unidad_medida=1 if bien==8 & unidad_medida==2 & precio_b==13000 & cantidad==1
	replace precio_b=precio_b*10 if bien==8 & unidad_medida==1 & precio_b==13000 & cantidad==1
	replace precio_b=precio_b*10 if bien==8 & unidad_medida==2 & cantidad==500 & precio_b>=17500 & precio_b<=27500
	replace cantidad=1 if bien==8 & unidad_medida==2 & cantidad==500 & precio_b==275000
	replace unidad_medida=1 if  bien==8 & unidad_medida==2 & cantidad==1 & precio_b==275000
	replace cantidad=cantidad*100 if bien==8 & unidad_medida==1 & cantidad==1 & precio_b>=40000 & precio_b<=70000
	replace unidad_medida=2 if bien==8 & unidad_medida==1 & cantidad==100 & precio_b>=40000 & precio_b<=70000
	replace cantidad=1 if bien==8 & unidad_medida==2 & cantidad==100 & precio_b==93975
	replace unidad_medida=1 if bien==8 & unidad_medida==2 & cantidad==1 & precio_b==93975

		
//	Margarina/Mantequilla
*-----------	
	replace precio_b=precio_b*1000 if food=="Margarina/Mantequilla" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==6
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==20
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==48000
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==240000
	replace precio_b=precio_b*1000 if food=="Margarina/Mantequilla" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==12
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==20
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==24
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==35
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==36
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==125 & precio_b==78000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==150 & precio_b==72000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==200 & precio_b==80000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==240
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==250 & precio_b>25000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==400 & precio_b>70000
	drop if food=="Margarina/Mantequilla" & unidad_medida==2 & cantidad==500 & precio==1			
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==500 & precio_b>64981.8203125
	replace precio_b=45000 if cantidad==45000 & food=="Margarina/Mantequilla"		
	replace cantidad=1000 if cantidad==45000 & food=="Margarina/Mantequilla"
	replace cantidad=250 if cantidad==250000 & food=="Margarina/Mantequilla"	

//	Mayonesa
*-----------
	replace precio_b=precio_b*1000 if bien==37 & precio_b>=20 & precio_b<=350
	replace precio_b=precio_b*10 if bien==37 & precio_b>=10000 & precio_b<=15000
	replace unidad_medida=1 if bien==37 & unidad_medida==2 & precio_b>=100000 & cantidad>=1 & cantidad<=60
	replace cantidad=1 if bien==37 & unidad_medida_ot=="Sobre"
	replace unidad_medida=2 if bien==37 & unidad_medida==1 & precio_b>=40000 & precio_b<=70000

	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==8 & precio_b>=130000 & precio_b<=150000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==10 & precio_b>=150000 & precio_b<=170000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==11 & precio_b>=170000 & precio_b<=190000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==12 & precio_b>=140000 & precio_b<=190000
	replace cantidad=2 if bien==37 & unidad_medida==1 & cantidad==12 & precio_b>=28000 & precio_b<=550000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==14 & precio_b>=140000 & precio_b<=190000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==15 & precio_b>=140000 & precio_b<=190000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==20 & precio_b>=140000 & precio_b<=190000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==24 & precio_b>=140000 & precio_b<=215000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==30 & precio_b>=140000 & precio_b<=215000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==36 & precio_b>=140000 & precio_b<=215000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==41 & precio_b>=140000 & precio_b<=215000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==56 & precio_b>=140000 & precio_b<=215000
	replace cantidad=1 if bien==37 & unidad_medida==1 & cantidad==120 & precio_b>=140000 & precio_b<=215000

	replace cantidad=100 if bien==37 & unidad_medida==2 & cantidad==1 & precio_b<=90000
	replace cantidad=100 if bien==37 & unidad_medida==2 & cantidad==6 & precio_b<=90000
	replace cantidad=cantidad*10 if unidad_medida==2 & (cantidad==10 | cantidad==20) & precio_b<100000

	replace cantidad=1 if bien==37 & unidad_medida==2 & cantidad==140 & precio_b==149000
	replace unidad_medida=1 if bien==37 & unidad_medida==2 & cantidad==1 & precio_b==149000
	replace cantidad=1 if bien==37 & unidad_medida==2 & cantidad==240 & precio_b==150000
	replace unidad_medida=1 if bien==37 & unidad_medida==2 & cantidad==1 & precio_b==150000
	replace precio_b=precio_b*10 if bien==37 & unidad_medida==2 & cantidad==500 & precio_b==18000

	drop if precio_b==1 & bien==37 & unidad_medida==2
	replace cantidad=100 if bien==37 & unidad_medida==2 & cantidad==500 & precio_b>=30000 & precio_b<=40000

//	Pan de trigo
*-----------
	replace cantidad=1 if unidad_medida==1 & food=="Pan de trigo" & cantidad==35
	replace cantidad=1000 if unidad_medida==2 & food=="Pan de trigo" & cantidad==1
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==2 & cantidad==150 & precio_b<100		
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==40 & tamano==4 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*10000 if food=="Pan de trigo" & unidad_medida==40 & tamano==4 & cantidad==10 & precio_b<100		
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==40 & tamano==4 & cantidad==30 & precio_b<100		
	replace cantidad=1 if unidad_medida==40 & tamano==4 & food=="Pan de trigo" & cantidad==30
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==40 & tamano==6 & cantidad==1 & precio_b<100			
	
	
//	Papas
*-----------
	replace precio_b=precio_b*1000 if food=="Papas" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*3000 if food=="Papas" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==8
	replace precio_b=precio_b*1000 if food=="Papas" & unidad_medida==1 & cantidad==10 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==40
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==250	
	

//	Papelón
*-----------
	replace precio_b=precio_b*1000 if food=="Papelón" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Papelón" & cantidad==8
	replace cantidad=1 if unidad_medida==1 & food=="Papelón" & cantidad==15
	replace cantidad=0.5 if unidad_medida==1 & food=="Papelón" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Papelón" & cantidad==1
	replace cantidad=800 if unidad_medida==2 & food=="Papelón" & cantidad==8000
	replace cantidad=500 if unidad_medida==2 & food=="Papelón" & cantidad==500000
	
	
//	Pastas (fideos)
*-----------
	replace precio_b=precio_b*1000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*2000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==2 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==3
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==4
	replace precio_b=precio_b*5000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==5 & precio_b<100		
	replace precio_b=precio_b*6000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==6 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==15
	replace precio_b=precio_b*10 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==20 & precio_b==100000		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==25
	replace precio_b=precio_b*30 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==30 & precio_b<1000000		
	replace precio_b=precio_b*40 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==40 & precio_b<100000		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==72
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==400
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==450
	replace precio_b=precio_b*1000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==500 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==30
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==36
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==96
	replace cantidad=500 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==50000	
	

//	Pescado fresco
*-----------
	replace cantidad=1000 if unidad_medida==2 & food=="Pescado fresco" & cantidad==1	


//	Plátanos
*-----------		
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==4
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==15
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==300
	replace precio_b=precio_b*1000 if food=="Platanos" & unidad_medida==110 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Platanos" & unidad_medida==110 & cantidad==20 & precio_b<1000		
	replace cantidad=1 if unidad_medida==110 & food=="Platanos" & cantidad==20 & precio_b<100000
	replace cantidad=1 if unidad_medida==110 & food=="Platanos" & cantidad==50
	replace cantidad=1 if unidad_medida==110 & food=="Platanos" & cantidad==70
	replace precio_b=cantidad*1000 if cantidad==100 & food=="Platanos"		
	replace cantidad=12 if cantidad==100 & food=="Platanos"
	replace precio_b=cantidad if cantidad==7000 & food=="Platanos"		
	replace cantidad=1 if cantidad==7000 & food=="Platanos"
	replace precio_b=cantidad if cantidad==12000 & food=="Platanos"		
	replace cantidad=1 if cantidad==12000 & food=="Platanos"		
	
	
//	Queso blanco
*-----------
	replace precio_b=precio_b*1000 if food=="Queso blanco" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Queso blanco" & unidad_medida==1 & cantidad==8 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==8
	replace precio_b=precio_b*10 if food=="Queso blanco" & unidad_medida==1 & cantidad==10 & precio_b==220000		
	replace precio_b=precio_b*10 if food=="Queso blanco" & unidad_medida==1 & cantidad==15 & precio_b==450000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==16
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==20
	replace precio_b=precio_b*30000 if food=="Queso blanco" & unidad_medida==1 & cantidad==30 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==40
	replace precio_b=precio_b*2*50 if food=="Queso blanco" & unidad_medida==1 & cantidad==50 & precio_b==45000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==250
	replace precio_b=260000 if cantidad==260000 & food=="Queso blanco"		
	replace cantidad=1 if cantidad==260000 & food=="Queso blanco"
	replace cantidad=1000 if unidad_medida==2 & food=="Queso blanco" & cantidad==150
	replace precio_b=precio_b/2 if food=="Queso blanco" & unidad_medida==2 & cantidad==500 & precio_b==370000		
	replace unidad_medida=1 if food=="Queso blanco" & unidad_medida==3 & cantidad==1	
	replace unidad_medida=1 if food=="Queso blanco" & unidad_medida==91 & cantidad==1	
	replace precio_b=precio_b*2 if food=="Queso blanco" & unidad_medida==92 & cantidad==1 & precio_b==100000	
	replace unidad_medida=1 if food=="Queso blanco" & unidad_medida==92 & cantidad==1		
	replace cantidad=1 if food=="Queso blanco" & unidad_medida==1 & (cantidad==3 | cantidad==5) & precio_b>=260000 & precio_b<=275000	
	replace precio_b=precio_b*20 if food=="Queso blanco" & unidad_medida==110 & precio_b==12000

//	Sal
*-----------
	replace precio_b=precio_b*1000 if food=="Sal" & unidad_medida==1 & cantidad==1		
	replace precio_b=precio_b*3000 if food=="Sal" & unidad_medida==1 & cantidad==3		
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==4
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==12
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==15
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==20 & precio_b<100000
	replace precio_b=precio_b*24000 if food=="Sal" & unidad_medida==1 & cantidad==24		
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==25
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==36
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==80
	replace precio_b=precio_b*1000 if food=="Sal" & unidad_medida==2 & cantidad==1		
	replace cantidad=1 if unidad_medida==2 & food=="Sal" & cantidad==1
	replace cantidad=120 if unidad_medida==2 & food=="Sal" & cantidad==12
	replace cantidad=500 if unidad_medida==2 & food=="Sal" & cantidad==5000	
	
	
//	Sardinas frescas/congeladas
*-----------
	replace precio_b=precio_b*1000 if food=="Sardinas frescas/congeladas" & unidad_medida==2 & cantidad==3 & precio_b<1000		
	replace cantidad=3000 if unidad_medida==2 & food=="Sardinas frescas/congeladas" & cantidad==3
	replace precio_b=precio_b*1000 if food=="Sardinas frescas/congeladas" & unidad_medida==80 & cantidad==1 & precio_b<1000			
	
	
//	Tomates
*-----------
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Tomates" & cantidad==3
	replace cantidad=1 if unidad_medida==1 & food=="Tomates" & cantidad==5
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==1 & cantidad==10 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Tomates" & cantidad==1
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==110 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Tomates" & unidad_medida==110 & cantidad==1 & precio_b>=100000		
	
	
//	Yuca
*-----------
	drop if food=="Yuca" & unidad_medida==1 & cantidad==45	
	
	
//	Zanahorias
*-----------
	replace precio_b=precio_b*1000 if food=="Zanahorias" & unidad_medida==1 & cantidad==2 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Zanahorias" & cantidad==8
	replace cantidad=1 if unidad_medida==1 & food=="Zanahorias" & cantidad==10
	replace precio_b=precio_b*1000 if food=="Zanahorias" & unidad_medida==110 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Zanahorias" & unidad_medida==110 & cantidad==1 & precio_b==90000		
	
	
/*(************************************************************************************************************************************************* 
* 3: Error correction (Second stage)
*************************************************************************************************************************************************)
	Authors:			Daniel Pereira

	Dependencies:		The World Bank -- Poverty unidad_medida
	Creation Date:		March, 2020
	Modification Date:  3/20/2020 by Julieta Ladronis
	Output:			    Second stage:
						Cleaned data for prices in Bolivares
						Considering the analysis units vs prices
						Considering general units plus other units
	
*/
*************************************************************************************************************************************************)
*--------- General
	// Eliminate precio_bs equal zero
	drop if precio_b==0			
	
*--------- Specific good error correction

//	Aceite
*-----------
	drop if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio_b>999999
	replace cantidad=100 if food=="Aceite" & unidad_medida==1 & precio_b==13000 
	replace unidad_medida=4 if food=="Aceite" & unidad_medida==1 & precio_b==13000 
	replace unidad_medida=4 if food=="Aceite" & unidad_medida==2 & cantidad>=100 & cantidad<=900  
	replace cantidad=100 if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio_b>=13000 & precio_b<=20000
	replace unidad_medida=4 if food=="Aceite" & unidad_medida==3  & cantidad==1 & precio_b>=13000 & precio_b<=20000
	replace cantidad=1 if food=="Aceite" & unidad_medida==3 & (cantidad==50 | cantidad==60 | cantidad==150 | cantidad==250 | cantidad==800) & precio_b>=100000 & precio_b<=150000
	replace cantidad=1000 if food=="Aceite" & unidad_medida==4 & cantidad==30 & precio_b==140000

//	Aji dulce, pimentón, pimiento
*-----------
	replace precio_b=precio_b*100 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==1 & precio==1000 
	replace cantidad=1 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==110 & cantidad>=3 & cantidad<=5 & precio_b>=2000 & precio_b<=3000 
	replace precio_b=precio_b*1000 if food=="Aji dulce, pimentón, pimiento" & precio_b==95 & unidad_medida==1

//	Arroz
*-----------
	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==1 & precio_b<1000
	replace precio_b=precio_b*10 if food=="Arroz" & unidad_medida==1 & cantidad==10 & precio_b<200000
	replace precio_b=precio_b*10 if food=="Arroz" & unidad_medida==1 & cantidad==20 & precio_b<200000
	drop if food=="Arroz" & cantidad==84  & precio_b==41	
	replace cantidad=1 if food=="Arroz" & unidad_medida==1 & precio_b>=80000 & precio_b<=85000 & (cantidad==600 | cantidad==1000 | cantidad==2000)

//	Auyama
*-----------
	replace precio_b=precio_b*8 if food=="Auyama" & unidad_medida==1 & cantidad==8 & precio_b<100000
	replace precio_b=precio_b*1000 if food=="Auyama" & unidad_medida==1 & precio_b==15

//	Azúcar
*-----------
	drop if food=="Azúcar" & unidad_medida==1 & cantidad==1 & precio==3100	
	replace precio_b=precio_b*20 if food=="Azúcar" & unidad_medida==1 & cantidad==20 & precio_b<100000
	replace unidad_medida=60 if food=="Azúcar" & unidad_medida==1 & unidad_medida_ot=="Teta"	
	replace unidad_medida=60 if food=="Azúcar" & unidad_medida==1 & unidad_medida_ot=="Teticas"	
	replace precio_b=precio_b*1000 if food=="Azúcar" & unidad_medida==2 & cantidad==50 & precio_b<1000		
	replace cantidad=1 if food=="Azúcar" & unidad_medida_ot=="Teta" & cantidad==6 & precio_b==20000		
	replace cantidad=cantidad*100 if food=="Azúcar" & unidad_medida==1 & cantidad==1 & precio_b>=6000 & precio_b<=12000		
	replace unidad_medida=2 if food=="Azúcar" & unidad_medida==1 & cantidad==100 & precio_b>=6000 & precio_b<=12000		
	replace cantidad=1 if food=="Azúcar" & unidad_medida_ot=="Teta" & precio_b==18000
	replace cantidad=1 if food=="Azúcar" & unidad_medida==1 & precio_b>=65000 & precio_b<=85000 & (cantidad==100 | cantidad==150 | cantidad==200 | cantidad==500 | cantidad==2500)

//	Café
*-----------
	replace precio_b=precio_b*20 if food=="Café" & unidad_medida==2 & cantidad==20 & precio_b<1000		
	replace precio_b=precio_b/1000 if (precio_b<999999999 & food=="Café" & unidad_medida==2 & cantidad==400)
	replace precio_b=precio_b/1000000 if precio_b>999999999 & food=="Café" & unidad_medida==2 & cantidad==400
	//replace precio_b=precio_b*400/1000 if food=="Café" & unidad_medida==2 & cantidad==400 & precio_b<1000	
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==60 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==60 & cantidad==50 & precio_b<1000		
	replace cantidad=1 if unidad_medida==130 & food=="Café" & cantidad==50	
	replace cantidad=1 if food=="Café" & unidad_medida_ot=="de cuarto de kilo" & precio_b==89000
	replace cantidad=0.5 if food=="Café" & unidad_medida_ot=="Teta" & precio_b>=8000 & precio_b<=15000 & cantidad==10
	replace cantidad=0.5 if food=="Café" & unidad_medida_ot=="Teta" & precio_b>=8000 & precio_b<=15000 & cantidad==50
	replace cantidad=1 if food=="Café" & unidad_medida_ot=="Tetica" & precio_b>=8000 & precio_b<=15000 & cantidad==10
	replace cantidad=1 if food=="Café" & unidad_medida_ot=="Tetica" & precio_b>=8000 & precio_b<=15000 & cantidad==50
	replace cantidad=1 if food=="Café" & unidad_medida_ot=="Teta" & cantidad!=1
	replace cantidad=1 if food=="Café" & unidad_medida_ot=="Teticas" & cantidad!=1
	replace cantidad=1 if food=="Café" & unidad_medida_ot=="Teticas" & cantidad==50
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==2 & cantidad==400 & precio_b>=150 & precio_b<=170
	// Mes - Entidad
	replace cantidad=100 if bien==71 & unidad_medida==2 & cantidad==1000 & precio_b>=30000 & precio_b<=50000
	// February
	replace cantidad=50 if food=="Café" & unidad_medida==2 & cantidad==25 & precio_b>=2000 & precio_b<=5000
	replace cantidad=100 if food=="Café" & unidad_medida==2  & precio_b>=10000 & precio_b<=20000 & (cantidad==35| cantidad==40 | cantidad==45 | cantidad==50 | cantidad==60)
	replace cantidad=1 if food=="Café" & unidad_medida==2 & cantidad==100 & precio_b>=70000 & precio_b<=80000
	replace unidad_medida=1 if food=="Café" & unidad_medida==2 & cantidad==1 & precio_b>=70000 & precio_b<=80000


// Cambur
*-----------

// Caraotas
*-----------
	replace cantidad=600 if food=="Caraotas" & unidad_medida==2 & cantidad==60 & precio==70000
	replace cantidad=600 if food=="Caraotas" & unidad_medida==2 & cantidad==60 & precio==70000
	replace cantidad=100 if food=="Caraotas" & unidad_medida==1 & cantidad==1 & precio==35000
	replace unidad_medida=2 if food=="Caraotas" & unidad_medida==1 & cantidad==100 & precio_b==35000
	replace cantidad=250 if food=="Caraotas" & unidad_medida==2 & cantidad==500 & precio_b>=36000 & precio_b<=40000
	replace cantidad=100 if food=="Caraotas" & unidad_medida==2 & cantidad==1000 & precio_b==35000
	replace cantidad=500 if food=="Caraotas" & unidad_medida==2 & cantidad==1000 & precio==60000

//	Carne de pollo/gallina
*-----------
	replace cantidad=1 if food=="Carne de pollo/gallina" & unidad_medida==1 & (cantidad==250 | cantidad==1000) & precio_b>=125000 & precio_b<=130000

//	Carne de res (bistec)
*-----------
	replace precio_b=precio_b*50 if food=="Carne de res (bistec)" & unidad_medida==1 & cantidad==50 & precio_b<300000
	
//	Carne de res (molida)
*-----------
	
//	Carne de res (para esmechar)
*-----------

	
//	Cebolla
*-----------
	replace precio_b=precio_b/10 if food=="Cebolla" & unidad_medida==1 & cantidad==20 & precio_b==10000000	
	
//	Cebollin, ajoporro.
*-----------
	replace precio_b=80000 if food=="Cebollin, ajoporro." & unidad_medida==1 & cantidad==1 & precio_b==80
	replace cantidad=100 if food=="Cebollin, ajoporro." & unidad_medida==1 & cantidad==1 & precio_b==20000
	replace unidad_medida=2 if food=="Cebollin, ajoporro." & unidad_medida==1 & cantidad==100 & precio_b==20000
	replace cantidad=100 if food=="Cebollin, ajoporro." & unidad_medida==2 & cantidad==500 & precio_b==7000

//	Chorizo, jamón, mortaleda y otros embutidos
*-----------
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==10000
	replace cantidad=1500 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==15000
	
//	Cilantro
*-----------
	drop if food=="Cilantro" & unidad_medida==1 & cantidad==1 & precio>999999
	drop if food=="Cilantro" & unidad_medida==1 & COD_moneda=="USD" & precio>10000	
	replace precio_b=precio_b*1000 if food=="Cilantro" & unidad_medida==2 & cantidad==. & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cilantro" & cantidad==.	
	replace precio_b=precio_b*10 if food=="Cilantro" & unidad_medida==1 & precio_b>=18000 & precio_b<=28000
	replace precio_b=precio_b*100 if food=="Cilantro" & unidad_medida==1 & precio_b>=2000 & precio_b<=3000
	replace precio_b=precio_b*4 if food=="Cilantro" & unidad_medida==2 & cantidad==100 & precio_b>=2000 & precio_b<=3000

//	Frijoles
*-----------
	replace cantidad=1 if food=="Frijoles" & unidad_medida==1 & cantidad==150 & precio_b==85000
	replace cantidad=500 if food=="Frijoles" & unidad_medida==1 & cantidad==1 & precio_b>=35000 & precio_b<=40000
	replace unidad_medida=2 if food=="Frijoles" & unidad_medida==1 & cantidad==500 & precio_b>=35000 & precio_b<=40000

//	Harina de arroz
*-----------
	replace precio_b=precio_b*5 if food=="Harina de arroz" & unidad_medida==1 & cantidad==5 & precio_b<100000	
	replace cantidad=100 if food=="Harina de arroz" & unidad_medida==1 & cantidad==1 & precio_b==26000
	replace unidad_medida=2 if food=="Harina de arroz" & unidad_medida==1 & cantidad==100 & precio_b==26000
	replace cantidad=1 if food=="Harina de arroz" & unidad_medida==1 & cantidad==1000 & precio_b==100000

//	Harina de maiz
*-----------
	replace cantidad=1 if bien==7 & unidad_medida==1 & precio==90000 & cantidad==20
	replace cantidad=1 if bien==7 & unidad_medida==1 & precio==97000 & cantidad==20

	
//	Hueso de res, pata de res, pata de pollo
*-----------
	replace precio_b=50000 if bien==19 & unidad_medida==1 & precio_b==5000 & cantidad==1
	replace precio_b=100000 if bien==19 & unidad_medida==1 & precio==10000 & cantidad==1
	
	
//	Huevos (unidades)
*-----------
	replace unidad_medida=110 if food=="Huevos (unidades)" & unidad_medida==60 & unidad_medida_ot=="Mini cartón de 6 unidades"			
	replace cantidad=6 if unidad_medida==110 & food=="Huevos (unidades)" & cantidad==126
	replace cantidad=1 if unidad_medida==110 & food=="Huevos (unidades)" & cantidad==30
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==30
	replace cantidad=1 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==30 & precio_b==300000
	replace unidad_medida=92 if food=="Huevos (unidades)" & unidad_medida==110 & precio_b==150000
	replace unidad_medida=91 if food=="Huevos (unidades)" & unidad_medida==110 & precio_b==150000
	replace unidad_medida=91 if food=="Huevos (unidades)" & unidad_medida==110 & precio_b>=260000
	replace cantidad=1 if food=="Huevos (unidades)" & unidad_medida==91 & (cantidad==3 | cantidad==8 | cantidad==12 | cantidad==15 | cantidad==30 | cantidad==36 | cantidad==40 | cantidad==60 | cantidad==80 | cantidad==150 | cantidad==200 | cantidad==300 | cantidad==500) & precio_b>200000 & precio_b<400000
	replace cantidad=1 if food=="Huevos (unidades)" & unidad_medida==92 
	replace cantidad=1 if food=="Huevos (unidades)" & unidad_medida==110 & cantidad==60 & precio_b==10000
	replace unidad_medida=91 if food=="Huevos (unidades)" & unidad_medida==1
	drop if food=="Huevos (unidades)" & unidad_medida==92 & precio_b==10828733440
	
//	Leche en polvo, completa o descremada
*-----------
	replace cantidad=1 if bien==29 & unidad_medida==1 & precio==54000 & cantidad==10
	drop if food=="Leche en polvo, completa o descremada" & unidad_medida==110 & cantidad==1
	replace precio_b=precio_b*10 if food=="Leche en polvo, completa o descremada" & unidad_medida==1 & cantidad==10 & precio==54000
	replace precio_b=(precio_b/10) if food=="Leche en polvo, completa o descremada" & unidad_medida==1 & cantidad==1 & precio>=900000 & precio_b<=1021000 
	// 
	replace precio_b=precio_b*1000 if food=="Leche en polvo, completa o descremada"  & unidad_medida==1 & precio_b==340 & cantidad==1
	replace cantidad=100 if food=="Leche en polvo, completa o descremada"  & unidad_medida==1 & precio_b==60000 & cantidad==1
	replace unidad_medida=2 if food=="Leche en polvo, completa o descremada"  & unidad_medida==1 & precio_b==60000 & cantidad==100
	replace cantidad=1 if food=="Leche en polvo, completa o descremada"  & unidad_medida==1 & precio_b==200000 & cantidad==200
	replace cantidad=100 if food=="Leche en polvo, completa o descremada" & unidad_medida==2 & cantidad==1000 & precio_b==25000

//	Lechosa
*-----------
	
//	Lentejas
*-----------
	replace unidad_medida=2 if food=="Lentejas" & unidad_medida==1 & cantidad==200 & precio_b==50000
	
//	Margarina/Mantequilla
*-----------	
	replace cantidad=1 if unidad_medida==220 & food=="Margarina/Mantequilla" & cantidad==120
	replace precio_b=224000 if food=="Margarina/Mantequilla" & unidad_medida==1 & cantidad==1 & precio==2240000
	replace cantidad=100 if food=="Margarina/Mantequilla" & unidad_medida==1 & cantidad==1 & precio_b>=47000 & precio_b<=60000
	replace unidad_medida=2 if food=="Margarina/Mantequilla" & unidad_medida==1 & cantidad==100 & precio_b>=47000 & precio_b<=60000
	replace cantidad=1000 if food=="Margarina/Mantequilla" & unidad_medida==2 & (cantidad==30 | cantidad==50 | cantidad==60 | cantidad==72 | cantidad==100 | cantidad==300) & precio_b>=140000 & precio_b<=175000

//	Pan de trigo
*-----------
	replace cantidad=1 if food=="Pan de trigo" & cantidad==12 & tamano==5 & precio==18000	
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="De Sandwich")
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="De Sandwich")	
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="Paquete de acemitas")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="Paquete de acemitas")	
	replace cantidad=1 if (food=="Pan de trigo" & unidad_medida_ot=="Paquete de acemitas")
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes pequeños")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes pequeños")	
	replace cantidad=2 if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes pequeños")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="pan canilla")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="pan canilla")
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="paquete de 10 unidades")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de 10 unidades")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de dos panes canilla")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de dos panes canilla")	
	replace cantidad=2 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de dos panes canilla")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="pieza de pan dulce")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="pieza de pan dulce")

//	Papas
*-----------
	

//	Papelón
*-----------
	replace cantidad=0.5 if unidad_medida==60 & food=="Papelón" & cantidad==25
	replace cantidad=0.25 if unidad_medida==60 & food=="Papelón" & cantidad==1 & unidad_medida_ot=="pieza pequeña"
	replace precio_b=precio_b*1000 if food=="Papelón" & unidad_medida==110 & cantidad==1 & precio_b<100		
	drop if food=="Papelón" &  cantidad==.a		
	
//	Pastas (fideos)
*-----------
	replace precio_b=precio_b*1000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==1 & precio_b<1000
	replace precio_b=precio_b*2000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==2 & precio_b<1000	
	

//	Pesacdo fresco
*-----------


//	Plátanos
*-----------
	replace cantidad=10 if food=="Platanos" & unidad_medida==110 & cantidad==1 & precio==350000	
	
	
//	Queso blanco
*-----------
	replace precio_b=precio_b*4 if food=="Queso blanco" & unidad_medida==2 & cantidad==4 & precio_b<1000		
	replace cantidad=1 if food=="Queso blanco" & unidad_medida==1 & cantidad==30 & precio_b>=260000 & precio_b<=275000	
	replace cantidad=1 if food=="Queso blanco" & unidad_medida==1 & cantidad==50 & precio_b>=260000 & precio_b<=275000	

//	Sal
*-----------
	replace precio_b=precio_b/1000 if food=="Sal" & unidad_medida==1 & cantidad==1 & precio_b>999999		
	replace precio_b=precio_b/1000000 if food=="Sal" & unidad_medida==2 & cantidad==1 & precio_b>999999		
	replace cantidad=100 if unidad_medida==2 & food=="Sal" & cantidad==1 & precio_b==10000
	replace precio_b=precio_b*1000 if food=="Sal" & unidad_medida==60 & cantidad==1 & precio_b<100 & unidad_medida_ot=="bulto"		
	replace unidad_medida=1 if food=="Sal" & unidad_medida==110 & cantidad==1			
	
//	Sardinas frescas/congeladas
*-----------

	
//	Tomates
*-----------
	replace precio_b=precio_b*10 if food=="Tomates" & unidad_medida==1 & cantidad==10 & precio_b<200000	
	
//	Yuca
*-----------
	replace precio_b=precio_b*10 if food=="Yuca" & unidad_medida==1 & cantidad==1 & precio_b>=3000 & precio_b<=9000
	replace cantidad=1 if food=="Yuca" & unidad_medida==1 & cantidad==10 & precio_b>=20000 & precio_b<=30000
	replace cantidad=1 if food=="Yuca" & unidad_medida==1 & cantidad==2 & precio_b>=20000 & precio_b<=30000

//	Zanahorias
*-----------


/*(************************************************************************************************************************************************* 
* 3: Units transformation: general
*************************************************************************************************************************************************)
	// We need to transform all the products into grams in order to
	have the obtain the price per gram 
	
	// In this section we transform from multiple measures to gram, liters or unit
	in the next one, we transform other measures into grams, liters or units
	
	Equivalence:
	#1: grams = #1: mililiters
*/
*************************************************************************************************************************************************)

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
* 4: Units transformation for specific products
*************************************************************************************************************************************************)
 This section address the problem of multiple presentations :
 
	// Many products have multiple size of presentation (large, medium, small)
	// The trasnformations were based on:
	
	1) Source: Spanish Journal of Human Nutrition and Dietetics"
	   Publication title: Hernandez et al (2015)-Desarrollo de un atlas fotográfico de porciones de alimentos venezolanos
	
	2) Information available online 	 
*/
*************************************************************************************************************************************************)

	// From cups to grams Hernandez et al (2015)	
	// "Taza (cup)" (1) to grams (150)
	replace cantidad_3 = cantidad*150 if (unidad_medida == 20)
	replace unidad_3 = 1 if (unidad_medida == 20)
	

	// Aceite (COD:35)
		// "Cucharada" "grande" (15ml)
		// based on Hernandez et al (2015)
		replace cantidad_3 = cantidad*10 if (unidad_medida == 210 & bien == 35 & tamano==1)
		replace unidad_3 = 2 if (unidad_medida == 210 & bien == 35 & tamano==1)
		// "Cucharada" "pequeña" (5ml)
		// based on Hernandez et al (2015)
		replace cantidad_3 = cantidad*5 if (unidad_medida == 210 & bien == 35 & tamano==3)
		replace unidad_3 = 2 if (unidad_medida==210 & bien==35)
		// Teta (between 100-200ml) --> we use "Teta" (1): 150ml
		replace cantidad_3= cantidad*150 if (unidad_medida == 60 & bien == 35 & unidad_medida_ot=="Teta")
		replace unidad_3= 2 if (unidad_medida == 60 & bien == 35 & unidad_medida_ot=="Teta")
		// 3/4  de franco de compota (50ml)
		replace cantidad_3= cantidad*50 if (unidad_medida == 60 & bien == 35 & unidad_medida_ot=="3/4  de franco de compota")
		replace unidad_3= 2 if (unidad_medida == 60 & bien == 35 & unidad_medida_ot=="3/4  de franco de compota")
		
	
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
		// Unidad (1): 1720g
		// Los frutos son de tamaño mediano, de cuello largo y peso promedio de 1,72 kg
		replace cantidad_3=cantidad*1720 if (unidad_medida ==110 & bien == 47)
		replace unidad_3=1 if (unidad_medida ==110 & bien == 47)


	// Azucar (COD:66) 
		// Teta (between 200-500) --> we use "Teta" (1): 250gr
		replace cantidad_3=cantidad*250	if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teta")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teta")
		// Teticas (between 50-150 grams) --> we use "Tetica" (1): 100g
		replace cantidad_3=cantidad*100	if (unidad_medida == 60 & bien == 66 & unidad_medida_ot=="Teticas")
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
		replace cantidad_3=cantidad*1000 if (unidad_medida == 60 & bien == 71 & unidad_medida_ot== "bulto" & cantidad>=10)
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
		replace cantidad_3=cantidad*1000 if (unidad_medida == 30  & bien == 12)
		replace unidad_3=1 if (unidad_medida == 30 & bien == 12 )
		
	// Carne de res (molida) (COD:13)
		replace cantidad_3=cantidad*1000 if (unidad_medida == 30  & bien == 13)
		replace unidad_3=1 if (unidad_medida == 30 & bien == 13)	
	
	// Carne de res (para esmechar) (COD:14)
		replace cantidad_3=cantidad*1000 if (unidad_medida == 30 & bien == 14)
		replace unidad_3=1 if (unidad_medida == 30 & bien == 14)

	
	// Cebolla (COD:46)
		// Unidad (1) cebolla mediana:75g
	    replace cantidad_3=cantidad*75 if (unidad_medida == 110 & bien == 46 )
		replace unidad_3=1 if (unidad_medida == 110 & bien == 46 )
		
		
	// Cebollin/ ajoporro (COD:51)
		// Unidad (1) cebolla mediana:100g
	    replace cantidad_3=cantidad*100 if (unidad_medida == 110 & bien == 51)
		replace unidad_3=1 if (unidad_medida == 110 & bien == 51)
		// Bolsita (100g)
		replace cantidad_3=cantidad*100 if (unidad_medida == 110 & bien == 51)
		replace unidad_3=1 if (unidad_medida == 110 & bien == 51)
		// Rama (50g)
		replace cantidad_3=cantidad*50 if (unidad_medida == 110 & bien == 51)
		replace unidad_3=1 if (unidad_medida == 110 & bien == 51)

	// Chorizo, jamón, mortaleda y otros embut (COD:20)
		// Pieza(1): 500g
	    replace cantidad_3=cantidad*500 if (unidad_medida == 30 & bien == 20 )
		replace unidad_3=1 if (unidad_medida == 30 & bien == 20 )
		// Unidad (1): 100g
	    replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="Unidad")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="Unidad")
		// Unidad de salchicha (1): 100g
	    replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="Unidad de salchicha")
		replace unidad_3=1 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="Unidad de salchicha")
		// Pasta de chorizo already defined as (250g) in survey
		//replace cantidad_3=cantidad if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="pasta de chorizo")
		//replace unidad_3=1 if (unidad_medida == 60 & bien == 20 & unidad_medida_ot =="pasta de chorizo")

		
	// Cilantro (COD:52)
		// Bolsita (1): 200g
		replace cantidad_3=cantidad*200 if (unidad_medida == 60 & bien == 52 & unidad_medida_ot== "bolsita")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 52 & unidad_medida_ot== "bolsita")		
		// Paquete (1): 50g
		replace cantidad_3=cantidad*50 if (unidad_medida == 64 & bien == 52 & unidad_medida_ot== "paquete")
		replace unidad_3= 1 if (unidad_medida == 64 & bien == 52 & unidad_medida_ot== "paquete")
		replace cantidad_3=cantidad*50 if (unidad_medida == 60 & bien == 52 & unidad_medida_ot== "paquete")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 52 & unidad_medida_ot== "paquete")
		// Unidad (50g)
		replace cantidad_3=cantidad*50 if (unidad_medida == 110 & bien == 52 )
		replace unidad_3= 1 if (unidad_medida == 110 & bien == 52)
		
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
        //Sobre
		// When the quantity is reported
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "Sobre" & bien==75 & cantidad==1)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Sobre" & bien==75 & cantidad==1)	
		// Sobre 
		// When grams are reported
		replace cantidad_3 = cantidad if (unidad_medida == 60 & unidad_medida_ot== "Sobre" & bien==75 & cantidad>1)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Sobre" & bien==75 & cantidad>1)	
		//Onza
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "onza" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "onza" & bien==75)
		//Pote 
		replace cantidad_3 = cantidad*100 if (unidad_medida == 60 & unidad_medida_ot== "pote" & bien==75)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "pote" & bien==75)
		
		
	//Frijoles (COD: 54)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020
	
	
	// Harina de arroz (COD: 2)
		// Unidad de medida is always either kilograms or grams
		// Some extreme values fixed
		// Date: 3/10/2020

		
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
		// Pieza (1000g) 
		replace cantidad_3=cantidad*1000 if (unidad_medida == 30 & bien==19 & unidad_medida==110)
		replace unidad_3 = 1 if (unidad_medida == 30 & bien==19 & unidad_medida==110)
		// Otro (Unidad) --> we use "Unidad" (1): 1000g
		replace cantidad_3=cantidad*1000 if (unidad_medida == 60 & bien==19 & unidad_medida==110)
		replace unidad_3 = 1 if (unidad_medida == 60 & bien==19 & unidad_medida==110)
		replace cantidad_3=cantidad*1000 if (unidad_medida == 64 & bien==19 & unidad_medida==110)
		replace unidad_3 = 1 if (unidad_medida == 64 & bien==19 & unidad_medida==110)

	
	// "Huevos" (COD:34)
		// "Carton" (1) to unit (30)
		replace cantidad_3= cantidad*30 if (unidad_medida == 91 & bien==34) 
		// "Medio carton" (1) to unit (15)
		replace cantidad_3= cantidad*15 if (unidad_medida == 92 & bien==34) 
		replace unidad_3= 3 if (unidad_medida == 91 | unidad_medida == 92) & bien== 34
	    // Unidad
		replace cantidad_3=cantidad if (unidad_medida==110 & bien==34 )
		replace unidad_3=3 if (unidad_medida==110 & bien==34 )

	
	//Leche en polvo, completa o descremada (COD:29)
		// Unidad(1): 500g
		replace cantidad_3=cantidad*500 if (unidad_medida == 110 & bien == 29 )
		replace unidad_3= 1 if (unidad_medida == 110 & bien == 29 )
		// Teta (between 100-500 grams) --> we use "Teta" (1): 100g
		replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 29 & unidad_medida_ot== "Teta")
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 29 & unidad_medida_ot== "Teta")
	
	
	//Lechosa (COD:41)
		// Unidad de medida is always either kilograms or grams
		// Date: 3/12/2020
		
		
	//Lentejas (COD:55)
		// Unidad de medida is always either kilograms or grams
		// Date: 3/12/2020
		
	// Maiz en grano (COD:8)
		// Lata (1):1000g
		// According to the price
		replace cantidad_3=cantidad*1000 if (bien==8 & unidad_medida==80 & precio_b>=100000)
	
	//Margarina/Mantequilla (COD:36)
		// "Margarina/Mantequilla" in "Lata"
		// "lata" (1) to gram (500)
		// using "Lactuario de Maracay mantequilla" standard size as benchmark
		replace cantidad_3 = cantidad*500 if (unidad_medida == 60 & unidad_medida_ot== "lata" & bien==36)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "lata" & bien==36)
		// "Margarina/Mantequilla" in "Barra"
		// "Barra" (1) to grams (120)
		// based on brand Los Andes product "mantequilla en barra"
		replace cantidad_3 = cantidad*120 if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad<10 & bien==36)
        replace unidad_3 = 1 if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad<10 & bien==36)
		// "Margarina/Mantequilla" in "Barra" when the quantity reported is actually grams
		replace cantidad_3 = cantidad if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad>100 & bien==36)
		replace unidad_3 = 1 if (unidad_medida==60 & unidad_medida_ot== "barra" & cantidad>100 & bien==36)
	
	// Mayonesa (COD:37)
		// Frasco (1): 1000g 
		replace cantidad_3=cantidad*1000 if (bien==37 & unidad_medida_ot=="frasco" & precio_b>=100000)
		replace unidad_3 = 1 if (bien==37 & unidad_medida_ot=="frasco" & precio_b>=100000)
		// Frasco (1): 500g
		replace cantidad_3=cantidad*500 if (bien==37 & unidad_medida_ot=="frasco" & precio_b<90000)
		replace unidad_3 = 1 if (bien==37 & unidad_medida_ot=="frasco" & precio_b<9000)
		// Sobre (1): 100g
		replace cantidad_3=cantidad*100 if (bien==37 & unidad_medida_ot=="Sobre")
		replace unidad_3 = 1 if (bien==37 & unidad_medida_ot=="Sobre")
		
	// Pan de trigo (COD:9)
		// Pieza de pan
		// Grande (campesino)
		replace cantidad_3=cantidad*250 if (unidad_medida == 40 & bien==9 & tamano==4 )
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9 & tamano==4)
		// Pieza de pan
		// Mediano (canilla)
		replace cantidad_3=cantidad*130 if (unidad_medida == 40 & bien==9 & tamano==5)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9 & tamano==5)
		// Pieza de pan
		// Pequeno (frances)
		replace cantidad_3=cantidad*50 if (unidad_medida == 40 & bien==9 & tamano==6)
		replace unidad_3 = 1 if (unidad_medida == 40 & bien==9 & tamano==6)
		// Otro: paquete
		replace cantidad_3=cantidad*130 if (unidad_medida == 60 & bien==9 & unidad_medida_ot=="Paquete")
		replace unidad_3 = 1 if (unidad_medida == 60 & bien==9 & unidad_medida_ot=="Paquete")
		// Paquetes: paquete
		// Unidad
		// Pequena --> Pequeno (frances)
	
	
	//Papas (COD:62)
		// Unidad (1): (150-200g) ---> we use 100g (given prices information)
		replace cantidad_3=cantidad*100 if (unidad_medida == 60 & bien == 62 & unidad_medida_ot == "Unidad" )
		replace unidad_3= 1 if (unidad_medida == 60 & bien == 62 & unidad_medida_ot == "Unidad")
		
		
	// Papelon (COD:67)	
		//Panela
		// We assume #(1): 1000g (1k)
	    replace cantidad_3=cantidad*1000 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Panela")
		replace unidad_3=1 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Panela")
		//Unidad
		// We assume #(1): 1000g (1k)
	    replace cantidad_3=cantidad*1000 if (unidad_medida==60 & bien==67 & unidad_medida==110)
		replace unidad_3=1 if (unidad_medida==60 & bien==67 & unidad_medida==110)
		//Pieza 
		// We assume #(1): 1000g (1k)
		replace cantidad_3=cantidad*1000 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Pieza")
		replace unidad_3=1 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="Pieza")
		//Pieza pequena
		// We assume #(1): 250g (1/2 k)
		replace cantidad_3=cantidad*250 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="pieza pequena")
		replace unidad_3=1 if (unidad_medida==60 & bien==67 & unidad_medida_ot=="pieza pequena")
	
	
	// Pasta (fideos) (COD:10)
		// Unidad de medida is always either kilograms or grams
		// Date: 3/12/2020

		
	//Pescado fresco (COD:26)
		// Unidad de medida is always either kilograms or grams
		// Date: 3/12/2020

		
	// Platanos (COD:40)
		// Unidad (mediana sin piel): 80g
		replace cantidad_3=cantidad*80 if (unidad_medida==110 & bien==40)
		replace unidad_3=1 if (unidad_medida==110 & bien==40)

	// Queso blanco (COD:31)
		// Unidad (1): 50g
		replace cantidad_3=cantidad*500 if (unidad_medida==110 & bien==31)
		replace unidad_3=1 if (unidad_medida==110 & bien==31)

	// Sal (COD:74)
		// Bolsita (50g)
		replace cantidad_3 = cantidad*50 if (unidad_medida == 60 & unidad_medida_ot== "Bolsita" & bien==74 & cantidad<10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Bolsita" & bien==74 & cantidad<10)
		// Teta (50g)
		replace cantidad_3 = cantidad*50 if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad<10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad<10)
		replace cantidad_3 = cantidad if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad>=10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Teta" & bien==74 & cantidad>=10)
		// Teticas
		replace cantidad_3 = cantidad*25 if (unidad_medida == 60 & unidad_medida_ot== "Teticas" & bien==74 & cantidad<10)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "Teticas" & bien==74 & cantidad<10)
		// Bulto (1): 1kg : 1000g
		replace cantidad_3 = cantidad*1000 if (unidad_medida == 60 & unidad_medida_ot== "bulto" & bien==74)
		replace unidad_3 = 1 if (unidad_medida == 60 & unidad_medida_ot== "bulto" & bien==74)

		
	// Sardinas frescas/congeladas (COD:24)
		// Lata (1): 1000g
		replace cantidad_3=cantidad*1000 if (unidad_medida == 80 & bien == 24 & tamano==.)
		replace unidad_3= 1 if (unidad_medida == 80 & bien == 24 & tamano==.)
		
		
	//Tomate (COD:43)
		// Unidad(1): 100g
		replace cantidad_3=cantidad*100 if (unidad_medida == 110 & bien == 43 )
		replace unidad_3= 1 if (unidad_medida == 110 & bien == 43 )
		
		
	//Yuca (COD:61)
		// "torta" (1) to gramos (1000g) according to price information
		// based on torta casaba "Guarani 283 gr." (Dominicana)
		replace cantidad_3 = cantidad*1000 if (unidad_medida == 160 & bien==61)
		replace unidad_3 = 1 if (unidad_medida == 160 & bien==61)
	
	
	// Zanahorias (COD:50)
		// Unidad(1): (40-100g) ----> we use 100g according to price information
		replace cantidad_3=cantidad*100 if (unidad_medida == 110 & bien == 50 )
		replace unidad_3= 1 if (unidad_medida == 110 & bien == 50 )
		
	tab bien unidad_medida if cantidad_3==. & unidad_3==.
	tab bien unidad_medida if cantidad_3==. & unidad_3==., nolab
	
	preserve
	collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida tamano cantidad)
	export excel using "$dataout/resumen_unidad", sheet("Unidad") firstrow(varlabels) replace
	restore	

	preserve
	collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida unidad_medida_ot tamano cantidad)
	export excel using "$dataout/resumen_otro", sheet("Unidad de medida (otro)") firstrow(varlabels) replace
	restore	

/*(************************************************************************************************************************************************* 
* 4: Price transformation: From gram, liters or unit to grams
*************************************************************************************************************************************************)*/
	// Standardrized grams
	gen cantidad_h = .
	replace cantidad_h = cantidad_3 if unidad_3==1
	replace cantidad_h = cantidad_3 if unidad_3
	// From mililiters to standarized grams 
	// converts militiers into grams using density of liquids
			// "Aceite" (COD:35)
			// density = .92 gr/ml promedios https://www.aceitedelasvaldesas.com/faq/varios/densidad-del-aceite/
			replace cantidad_h = cantidad_3*.92 if unidad_3==2 & bien==35

	// Transform units to standarized grams 
			// "Huevos"
			// used mean between medium and large min bound size https://www.eggs.ca/eggs101/view/4/all-about-the-egg#
			// weight = 52.5 gr/unit
			replace cantidad_h = cantidad_3*52.5 if unidad_3==3 & bien==34
	
	// From mililiters to standarized grams 
	// converts militiers into grams using density of liquids
			// "Leche"
			// density = 1.032 gr/ml https://es.wikipedia.org/wiki/Leche
			replace cantidad_h = cantidad_3*1.032 if unidad_3==2 & bien==25


/*(************************************************************************************************************************************************* 
* 5: Price transformation
*************************************************************************************************************************************************)
 This section calculates the price per gram 
   Given that the previous section transform all units into grams or equivalents,
   we only need to divide the prices from the survey with the new quantities	 
*/
	
// Units transformation
*----------- Transform regular prices to price per gram
	gen precio_u=(precio_b/cantidad_h)
	label var precio_u "Precio estandarizado"
	

/*(************************************************************************************************************************************************* 
*  Final databases
*************************************************************************************************************************************************)

*/
// Save complete database
*-----------
	save "$dataout/Price_database_complete.dta", replace

// Price Distribution
*----------- 
/*	preserve
	collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida unidad_medida_ot tamano cantidad)
	export excel using "$dataout/resumen_otro_control", sheet("Unidad de medida (otro)") firstrow(varlabels) replace
	restore	

// Price Distribution (to check expenditure data)
*----------- 
	preserve
	*--- Arroz, harina de maiz, aceite y azucar
	keep if bien==1 | bien==7 | bien==35 | bien==66 | bien==12 | bien==13 | bien==14 | bien==31
	collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida unidad_medida_ot tamano cantidad)
	export excel using "$dataout/resumen_canasta1", sheet("Precio") firstrow(varlabels) replace
	restore	

	
// Price per gram by Good
*----------- 
	preserve
	keep if 
	collapse (mean) mean_p=precio_u  (median) median_p=precio_u (max) max_p=precio_u (min) min_p=precio_u (p1) p1_p =precio_u (p5) p5_p =precio_u  (p10) p10_p=precio_u (p90) p90=precio_u (p95) p95_p =precio_u (p99) p99_p=precio_u, by (bien)
	save "$dataout/resumen_precio_gramo_bien.dta", replace
	export excel using "$dataout/resumen_precio_gramo", sheet("Precios estandarizados") firstrow(varlabels) replace
	restore

// Price per gram by Good (to check expenditure data)
*----------- 
	preserve
	*--- Arroz, harina de maiz, aceite y azucar
	keep if bien==1 | bien==2 | bien==7 | bien==35 | bien==66 | bien==12 | bien==13 | bien==14 | bien==31
	collapse (mean) mean_p=precio_u  (median) median_p=precio_u , by (bien)
	save "$dataout/resumen_precio_gramo_bien.dta", replace
	export excel using "$dataout/resumen_canasta2", sheet("Precio gramo") firstrow(varlabels) replace
	restore
	
	//(max) max_p=precio_u (min) min_p=precio_u (p1) p1_p =precio_u (p5) p5_p =precio_u  (p10) p10_p=precio_u (p90) p90=precio_u (p95) p95_p =precio_u (p99) p99_p=precio_u
*/
// Price per gram by Good-Month-Region
*----------- 
	preserve
	keep if mes=="02" 
	collapse (mean) mean_p=precio_u  (median) median_p=precio_u (max) max_p=precio_u (min) min_p=precio_u (p1) p1_p =precio_u (p5) p5_p =precio_u  (p10) p10_p=precio_u (p90) p90=precio_u (p95) p95_p =precio_u (p99) p99_p=precio_u, by (bien ENTIDAD mes)
	export excel using "$dataout/resumen_precio_gramo_L", sheet("Precios estandarizados") firstrow(varlabels) replace
	save "$dataout/resumen_precio_gramo_L.dta", replace
	restore	

	preserve
	keep if bien==7
	keep bien precio_u
	save "$dataout/maiz_precio_gramo.dta", replace
	restore
	
/*(************************************************************************************************************************************************* 
*  Comparison with prices from expenditure survey
*************************************************************************************************************************************************)*/

*----------- Popularity filter
// This means that we are going to look for the most popular "presentations" for each good(bien unidad_medida tamano cantidad) and filter less popular
	preserve
	collapse (count) count=unidad_medida, by(bien)
	by bien: egen total = total(count)
	gen pop = count/total
	keep if pop>.15 //parametro clave, permite encontrar observaciones en todos los productos. revisar tab bien _merge luego del proximo merge antes de cambiar
	tempfile popular
	save `popular'
	restore
	
*----------- Popularity filter applied to February
	keep if mes=="02"
	merge m:1 bien using `popular'
	tab bien _merge
	keep if _merge == 3

	preserve
	keep if mes=="02" 
	collapse (mean) mean_p=precio_u (median) median_p=precio_u (max) max_p=precio_u (min) min_p=precio_u (p1) p1_p =precio_u (p5) p5_p =precio_u  (p10) p10_p=precio_u (p90) p90=precio_u (p95) p95_p =precio_u (p99) p99_p=precio_u, by (bien)
	export excel using "$dataout/resumen_precio_gramo_L", sheet("Precios estandarizados") firstrow(varlabels) replace
	save "$dataout/resumen_precio_gramo_L.dta", replace
	restore	

	//preserve
	//keep if mes=="02" 
	//collapse (mean) mean_p=precio_b  (median) median_p=precio_b (max) max_p=precio_b (min) min_p=precio_b (p1) p1_p =precio_b (p5) p5_p =precio_b (p95) p95_p =precio_b (p99) p99_p=precio_b, by (bien unidad_medida unidad_medida_ot tamano cantidad)
	//export excel using "$dataout/resumen_09_04", sheet("Unidad de medida (otro)") firstrow(varlabels) replace
	//restore	

	preserve
	keep if mes=="02" 
	collapse (mean) mean_p=precio_u  (median) median_p=precio_u, by (bien)
	export excel using "$dataout/explicitos(feb)_10_04", sheet("Unidad de medida (otro)") firstrow(varlabels) replace
	restore	
