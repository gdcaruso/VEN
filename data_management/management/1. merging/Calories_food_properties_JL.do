/*===========================================================================
Purpose: Import food property database and get mean features for each item

Country name:	Venezuela
Year:			2019
	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Food properties Dataset 

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

				global aux_do ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
				global dataout ""
				global aux_do ""
		}
		if $trini   {
				global rootpath ""
				global dataout ""
				global aux_do ""
				
		}
		
		if $male   {
				global rootpath ""
				global dataout ""
				global aux_do ""
		}

	
global dataofficial "$rootpath\poverty_measurement\doc"
global dataout "$rootpath\poverty_measurement\input"

*----Import excel dataset with full food properties	
	import excel "$dataofficial\Tabla De Composición De Alimentos Para Uso Práctico (2001).xlsx", sheet("Base") cellrange("A1:H205") firstrow clear
    
	*Change the names of variables
	rename Humedadg Humedad
	rename EnergiaKcal Energia_kcal
	rename EnergiakJ Energia_kj 
	rename Proteinag Proteina
	rename Lipidosg Lipidos
	
	*Calculate the mean properties for each category from the expenditure survey
	collapse (mean) Humedad_m=Humedad Energia_kcal_m=Energia_kcal Energia_kj_m=Energia_kj Proteina_m=Proteina Lipidos_m=Lipidos, by (COD_GASTO)
	
	*Label values of the codes from the expenditure survey
	label define cod_gasto_label 1 "Arroz, harina de arroz" ///
	2 "Avena, avena en hojuelas, harina de avena" /// 
	3 "Galletas, dulces, saladas, integrales" ///
	4 "Harina de maiz" ///
	5 "Maiz en granos" ///
	6 "Pan de trigo" ///
	7 "Pastas alimenticias" ///
	8 "Fororo" ///
	9 "Otro (especifique)" ///
	10 "Carne de res (bistec, carne molida, carne para esmechar)" ///
	11 "Visceras (higado, riñonada, corazon, asadura, morcillas)" ///
	12 "Chuleta de cerdo ahumada" ///
	13 "Carne de cerdo fresca (chuleta, costilla, pernil)" ///
	14 "Hueso de res, pata de res, pata de pollo" ///
	15 "Chorizo, jamon, mortadela y otros embutidos" ///
	16 "Carne enlatada" ///
	17 "Carne de pollo" ///
	18 "Otro (especifique)" ///
	19 "Pescado enlatado" ///
	20 "Sardinas frescas/congeladas" ///
	21 "Atun fresco/congelado" ///
	22 "Pescado fresco" ///
	23 "Pescado seco/salado" ///
	24 "Otro (especifique)" ///
	25 "Leche liquida, completa o descremada" ///
	26 "Leche en polvo, completa o descremada" ///
	27 "Queso requeson, ricota" ///
	28 "Queso blanco" ///
	29 "Queso amarillo" ///
	30 "Suero, natilla, nata" /// 
	31 "Huevos (unidades)" ///
	32 "Otro (especifique)" ///
	33 "Aceite" ///
	34 "Margarina/Mantequilla" ///
	35 "Mayonesa" ///
	36 "Otro (especifique)" ///
	37 "Cambur" ///
	38 "Mangos" ///
	39 "Platanos" ///
	40 "Lechosa" ///
	41 "Guayaba" ///
	42 "Otro (especifique)" ///
	43 "Tomates" ///
	44 "Aguacate" ///
	45 "Aji dulce, pimenton, pimiento" ///
	46 "Cebolla" ///
	47 "Auyama" ///
	48 "Lechuga" ///
	49 "Berenjena" ///
	50 "Zanahorias" ///
	51 "Cebollin, ajoporro, cilantro y similares" ///
	52 "Otro (especifique)" ///
	53 "Caraotas" ///
	54 "Frijoles" ///
	55 "Lentejas" ///
	56 "Garbanzo" ///
	57 "Otro (especifique)" ///
	58 "Nueces" ///
	59 "Mani" ///
	60 "Merey" ///
	61 "Otro (especifique)" ///
	62 "Yuca" ///
	63 "Papas" ///
	64 "Ocumo" ///
	65 "Apio" ///
	66 "Casabe" ///
	67 "Otro (especifique)" ///
	68 "Azucar" ///
	69 "Papelon" ///
	70 "Edulcorantes" /// 
	71 "Miel" ///
	72 "Melaza" /// 
	73 "Otro (especifique)" ///
	74 "Cafe" ///
	75 "Te" ///
	76 "Bebida achocolatada" ///
	77 "Otro (especifique)" ///
	78 "Sal" ///
	79 "Condimentos (comino, pimienta, curry, cubitos)" ///
	80 "Concentrados (cubitos, sopas de sobre)" ///
	81 "Salsa de tomate" ///
	82 "Otras salsas" ///
	83 "Otro (especifique)" /// 
	84 "Jugos" ///
	85 "Agua embotellada" ///
	86 "Gaseosas/refrescos" ///
	87 "Otras bebidas no alcoholicas" ///
	88 "Bebidas alcoholicas" /// 
	89 "Otro (especifique)" ///
	
	*Incorporate the values labels to the variable 		  
	label values COD_GASTO cod_gasto_label
	
	*Keep calories in kcal units
	keep COD_GASTO Energia_kcal_m Proteina_m
	
	compress	
	
	save "$dataout\Calories.dta", replace
