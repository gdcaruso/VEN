/*===========================================================================
Country name:		Venezuela
Year:			2019
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuna, Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		January, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************

	    * User 1: Trini
		global trini 1
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   0
		
			
		if $juli {
				global rootpath "C:\Users\WB563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Desktop\worldbank\analisis\ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
		if $trini   {
		        global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\ENCOVI-2019"      
				*global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
				*global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				*global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
		if $male   {
		        global rootpath "C:\Users\wb550905\Github\ENCOVI-2019"
				*global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				*global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				*global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}


// Set output data path
global dataofficial "$rootpath\data_management\output\merged"
/*
global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global datafinalharm "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI harmonized data"
global datafinalimp "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI imputation data"
*/

********************************************************************************

/*===============================================================================
                          0: Program set up
===============================================================================*/
version 14
drop _all
set more off
*quietly include "$aux_do\cuantiles.do"

local country  "VEN"    // Country ISO code
local year     "2019"   // Year of the survey
local survey   "ENCOVI"  // Survey acronym
local vm       "01"     // Master version
local va       "01"     // Alternative version
local project  "03"     // Project version
local period   ""       // Periodo, ejemplo -S1 -S2
local alterna  ""       // 
local vr       "01"     // version renta
local vsp      "00"	// version ASPIRE
*include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

/*==================================================================================================================================================
								1: Data preparation: First Order Variables
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Opening data base  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
* Open "output" database
use "$dataofficial\individual.dta", clear
merge m:1 interview__key interview__id quest using "$dataofficial\household.dta"
drop _merge
* I drop those who do not collaborate in the survey
drop if colabora_entrevista==2
*Obs: there are still 2 observations which do not merge. Maybe they are people who started to answer but then stopped answering

*Change names to lower cases
rename _all, lower
order interview__key interview__id quest miembro__id
sort interview__key interview__id quest miembro__id

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identifiers  --------------------------------------------------
*************************************************************************************************************************************************)*/
global id_SEDLAC pais ano encuesta id com pondera strata psu

* Country identifier:                         pais
gen pais = "VEN"

* Country identifier:                         ano
capture drop ano
gen ano = 2019

* Survey identifier:                          encuesta
gen encuesta = "ENCOVI - 2019"

* Household identifier:                       id      
egen id = group(interview__key interview__id quest)

* Member identifier: com
bysort id: gen com =_n
duplicates report id com 

* Weights:                                    pondera
*Old: gen pondera = pesoper  //round(pesoper)
*How to do this? We only have the "peso del segmento" till now...

* Strata: strata //PREGUNTAR A DANIEL SI SABE A QUE CORRESPONDE CADA ESTRATO
*Old: gen strata = estrato
*How to do this? Is it "segmento"?

* Primary sample unit: psu  
* UPM: Unidad Primaria de Muestreo
*Old: gen psu = .
*Which one is it? Ask Daniel? 

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Demographic variables  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_SEDLAC relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua
* Relation to the head:	relacion
/* Categories of the new harmonized variable:
		1:  Jefe		
		2:  Cónyuge/Pareja
		3:  Hijo/Hija		(Hijastro/Hijastra)		
		4:  Padre/Madre		
		5:  Hermano/Hermana
		6:  Nieto/Nieta	
		7:  Otros familiares	
		8:  Otros no familiares	
* RELACION_EN (s6q2): Variable identifying the relation to the head in the survey
		01 = Jefe del Hogar	
		02 = Esposa(o) o Compañera(o)
		03 = Hijo(a)		
		04 = Hijastro(a)
		05 = Nieto(a)		
		06 = Yerno, nuera, suegro (a)
		07 = Padre, madre       
		08 = Hermano(a)
		09 = Cunado(a)         
		10 = Sobrino(a)
		11 = Otro pariente      
		12 = No pariente
		13 = Servicio Domestico
*/
clonevar relacion_en = s6q2
gen     relacion = 1		if  relacion_en==1
replace relacion = 2		if  relacion_en==2
replace relacion = 3		if  relacion_en==3  | relacion_en==4
replace relacion = 4		if  relacion_en==7  
replace relacion = 5		if  relacion_en==8 
replace relacion = 6		if  relacion_en==5
replace relacion = 7		if  relacion_en==6  | relacion_en==9  | relacion_en==10 | relacion_en==11 
replace relacion = 8		if  relacion_en==12 | relacion_en==13

label def relacion 1 "Jefe" 2 "Cónyuge/Pareja" 3 "Hijo(a)/Hijastro(a)" 4 "Padre/Madre" ///		
		              5 "Hermano/Hermana"  6 "Nieto/Nieta"	7 "Otros familiares" 8 "Otros no familiares"
label value relacion relacion

* Household identifier: hogar
gen hogar = (relacion==1)	

* Miembros de hogares secundarios (seleccionando personal doméstico): hogarsec 
gen hogarsec =.
replace hogarsec =1 if relacion_en==13
replace hogarsec =0 if inrange(relacion_en, 1,12)

* Hogares con presencia de miembros secundarios: presec	
tempvar aux
egen `aux' = sum(hogarsec), by(id)
gen       presec = 0
replace   presec = 1  if  `aux'>0  
replace   presec = .  if  relacion!=1
drop `aux'

* Numero de miembros del hogar (de la familia principal): miembros 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)

* Dummy de hombre: hombre 
/* SEXO (s6q3): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
clonevar sexo = s6q3
gen 	hombre = 0 if sexo==2
replace hombre = 1 if sexo==1

* Años cumplidos: edad
* EDAD_ENCUESTA (s6q5): Cuantos años cumplidos tiene?
gen     edad = s6q5
notes   edad: range of the variable: 0-97

* Grupo de edad: gedad1
/* 1 = individuos de 14 anos o menos
   2 = individuos entre 15 y 24 
   3 = individuos entre 25 y 40
   4 = individuos entre 41 y 64
   5 = individuos mayores a 65
*/
gen gedad1 = .
replace gedad1 = 1 if edad<=14
replace gedad1 = 2 if edad>=15 & edad<=24
replace gedad1 = 3 if edad>=25 & edad<=40
replace gedad1 = 4 if edad>=41 & edad<=64
replace gedad1 = 5 if edad>=65 & edad!=.

* Identificador de miembros del hogar
gen     jefe = (relacion==1)
gen     conyuge = (relacion==2)
gen     hijo = (relacion==3)

* Numero de hijos menores de 18
tempvar aux
gen `aux' = (hijo==1 & edad<=18)
egen      nro_hijos = count(`aux'), by(id)
replace   nro_hijos = .  if  jefe!=1 & conyuge!=1

* Dummy de estado civil 1: casado/unido
/* ESTADO_CIVIL_ENCUESTA (s6q13): Cual es su situacion conyugal
       1 = casado con conyuge residente  
	   2 = casado con conyuge no residente
       3 = unido con conyuge residente            
       4 = unido con conyuge no residente
       5 = divorciado   
       6 = separado
	   7 = viudo
	   8 = soltero /nunca unido		
	   98 = No aplica
	   99 = NS/NR 
*/
gen estado_civil_encuesta = s6q13 if (s6q13!=98 & s6q13!=99)
gen     casado = 0		if  estado_civil_encuesta>=5 & estado_civil_encuesta<=8
replace casado = 1		if  estado_civil_encuesta>=1 & estado_civil_encuesta<=4

* Dummy de estado civil 2: soltero 
gen     soltero = 0		if  estado_civil_encuesta>=1 & estado_civil_encuesta<=7
replace soltero = 1		if  estado_civil_encuesta==8

* Estado Civil: estado_civil
/* 1 = married
   2 = never married
   3 = living together
   4 = divorced/separated
   5 = widowed									
*/
gen     estado_civil = 1	if  estado_civil_encuesta==1 | estado_civil_encuesta==2
replace estado_civil = 2	if  estado_civil_encuesta==8 
replace estado_civil = 3	if  estado_civil_encuesta==3 | estado_civil_encuesta==4
replace estado_civil = 4	if  estado_civil_encuesta==5 | estado_civil_encuesta==6
replace estado_civil = 5	if  estado_civil_encuesta==7

label def estado_civil 1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
label value estado_civil estado_civil

* Raza o etnicidad:	raza 
gen     raza = .
notes   raza: the survey does not include information to define this variable

* Lengua: lengua
gen     lengua = .
notes   lengua: the survey does not include information to define this variable

/*(*************************************************************************************************************************************************
*-------------------------------------------------------------	1.3: Variables regionales  ---------------------------------------------------------
*************************************************************************************************************************************************)*/
* Creación de Variable Geográficas Desagregadas
	
* Desagregación 1 (Regiones politico-administrativas): region_est1
/* Las regiones político-administrativas de Venezuela son:
	    1. Región Central:  Aragua, Carabobo y Cojedes.
	    2. Región de los Llanos: Guárico, Apure, con excepción del Municipio Páez.
	    3. Región Centro-Occidental: Falcón, Lara, Portuguesa y Yaracuy.
	    4. Región Zuliana: Zulia
	    5. Región de los Andes: Barinas, Mérida, Táchira, Trujillo y el municipio Páez del Estado Apure
	    6. Región Nor-Oriental: Anzoátegui, Monagas y Sucre.
	    7. Región Insular: Nueva Esparta y las Dependencias Federales Venezolanas.
	    8. Región Guayana:  Bolívar, Amazonas y Delta Amacuro.
	    9. Región Capital:  Miranda, Vargas y el Distrito Capital
    En la encuesta la variable categorica ENTI representa a los Estados, a partir de esta variable se crearan las regions politico-administrativas y las dummies regionales
    Las  categorias de la variable original ENTI son las siguientes:
        1 Distrito Capital
        2 Amazonas
        3 Anzoategui
        4 Apure
        5 Aragua
		6 Barinas
        7 Bolívar
        8 Carabobo
        9 Cojedes
        10 Delta Amacuro
		11 Falcón
        12 Guárico
        13 Lara
        14 Mérida
        15 Miranda
        16 Monagas
        17 Nueva Esparta
        18 Portuguesa
        19 Sucre
        20 Táchira
        21 Trujillo
        22 Yaracuy
        23 Zulia
        24 Vargas
        25 Dependencias Federales
 */
tab entidad, nolab
/*
      1. ENTIDAD |
         FEDERAL |      Freq.     Percent        Cum.
-----------------+-----------------------------------
      Anzoategui |        627       11.66       11.66
           Apure |         69        1.28       12.94
          Aragua |        421        7.83       20.77
         Bolivar |        134        2.49       23.26
         Cojedes |         53        0.99       24.24
          Falcon |         52        0.97       25.21
         Guarico |        210        3.90       29.11
            Lara |        141        2.62       31.73
         Miranda |         83        1.54       33.28
         Monagas |        219        4.07       37.35
   Nueva Esparta |        773       14.37       51.72
      Portuguesa |         69        1.28       53.00
           Sucre |        758       14.09       67.09
         Tachira |        964       17.92       85.02
         Yaracuy |        419        7.79       92.81
           Zulia |        387        7.19      100.00
-----------------+-----------------------------------
           Total |      5,379      100.00
*/
gen     region_est1 =  1 if entidad==5 | entidad==8 | entidad==9                   //Region Central
replace region_est1 =  2 if entidad==12 | entidad==4                               // Region de los LLanos
replace region_est1 =  3 if entidad==11 | entidad==13 | entidad==18 | entidad==22  // Region Centro-Occidental
replace region_est1 =  4 if entidad==23                                            // Region Zuliana
replace region_est1 =  5 if entidad==6 | entidad==14 | entidad==20 | entidad==21   // Region de los Andes
replace region_est1 =  6 if entidad==3 | entidad==16 | entidad==19                 // Region Nor-Oriental
replace region_est1 =  7 if entidad==17 | entidad==25                              // Region Insular
replace region_est1 =  8 if entidad==7 | entidad==2 | entidad==10                  // Region Guayana
replace region_est1 =  9 if entidad==15 | entidad==24 | entidad==1                 // Region Capital

label def region_est1 1 "Region Central"  2 "Region de los LLanos" 3 "Region Centro-Occidental" 4 "Region Zuliana" ///
          5 "Region de los Andes" 6 "Region Nor-Oriental" 7 "Insular" 8 "Guayana" 9 "Capital"
label value region_est1 region_est1

* Desagregación 2 (Estados): region_est2
clonevar region_est2 = entidad

* Desagregación 3 (Municipios): region_est3
clonevar region_est3 = municipio

* Dummy urbano-rural: urbano  //REVISAR SI SE PUEDE CONSTRUIR ESTA VARIABLE
/* : area de residencia
		 1 = urbana  
		 2 = rural								

gen     urbano = 1		if  zona==1
replace urbano = 0		if  zona==2
*/
gen urbano=.
							 
* Dummies regionales 							 

*1.	Región Central
gen       cen = .
replace   cen = 1 if enti==5 // Aragua
replace   cen = 1 if enti==8 // Carabobo
replace   cen = 1 if enti==9 // Cojedes
replace   cen = 0 if enti!=5 & enti!=8 & enti!=9 & enti!=.

*2. Región de los Llanos
gen       lla = .
replace   lla = 1 if enti==12 // Guarico
replace   lla = 1 if enti==4  // Apure
replace   lla = 0 if enti!=12 & enti!=4 & enti!=.

*3. Región Centro-Occidental
gen       ceo = .
replace   ceo = 1 if enti==11 // Falcon
replace   ceo = 1 if enti==13 // Lara
replace   ceo = 1 if enti==18 // Portuguesa
replace   ceo = 1 if enti==22 // Yaracuy
replace   ceo = 0 if enti!=11 & enti!=13 & enti!=18 & enti!=22 & enti!=.

*4. Región Zuliana: Zulia
gen       zul = .
replace   zul = 1 if enti==23 // Zulia
replace   zul = 0 if enti!=23 & enti!=.

*5. Región de los Andes
gen       and = .
replace   and = 1 if enti==6  // Barinas
replace   and = 1 if enti==14 // Merida
replace   and = 1 if enti==20 // Tachira 
replace   and = 1 if enti==21 // Trujillo
replace   and = 0 if enti!=6 & enti!=14 & enti!=20 & enti!=21 & enti!=.

*6. Región Nor-Oriental 
gen       nor = .
replace   nor = 1 if enti==3  // Anzoategui
replace   nor = 1 if enti==16 // Monagas
replace   nor = 1 if enti==19 // Sucre
replace   nor = 0 if enti!=3 & enti!=16 & enti!=19 & enti!=.

*7. Región Insular
gen       isu = .
replace   isu = 1 if enti==17 // Nueva Esparta
replace   isu = 1 if enti==25 // Dependencias Federales
replace   isu = 0 if enti!=17 & enti!=25 & enti!=.

*8. Región Guayana
gen       gua = .
replace   gua = 1 if enti==7  // Bolivar
replace   gua = 1 if enti==2  // Amazonas
replace   gua = 1 if enti==10 // Delta Amacuro
replace   gua = 0 if enti!=7 & enti!=2 & enti!=10 & enti!=.

*8. Región Capital
gen       capital = .
replace   capital = 1 if enti==15  // Miranda
replace   capital = 1 if enti==24  // Vargas
replace   capital = 1 if enti==1  // Distrito Capital
replace   capital = 0 if enti!=15 & enti!=24 & enti!=1 & enti!=.

* Areas no incluidas en años previos:	nueva_region
gen       nuevareg = .
* Por el momento no se detectaron cambios 

***************************************************************************************************************************************************
* Migrante:	migrante
/*      0 = si nacio en el municipio donde reside actualmente
        1 = nacio en un municipio distinto de donde vive actualmente
RESIDE_EN (s6q7): En septiembre de 2018 residia en:
       1 = En este mismo municipio
	   2 = En otro municipio
	   3 = En otro pais
	   4 = No habia nacido
*/
clonevar reside_en = s6q7
gen migrante = (reside_en==2 | reside_en==3) 

* Migrantes extranjeros: migra_ext 
/*      0 = migrante pero no es del extranjero
        1 = inmigrante de un pais extranjero
*/
gen migra_ext = (reside_en==3) if migrante==1

* Migrantes internos (urbano-rural): migra_rur
/*      1 = si la persona es migrante nacido en zona rural y ahora esta viviendo en zonas urbanas
        0 = si es nacido en zonas urbanas y ahora vive en rural, y missing si no es migrante, o no se puede saber si migro del campo a la ciudad o viceversa
*/
gen migra_rur = .
notes   migra_rur: the survey does not include information to define this variable
	
* Años en el actual lugar de residencia de un migrante: anios_residencia
gen   anios_residencia = .
notes anios_residencia: the survey does not include information to define this variable


* Migrante reciente (definida solo para los migrantes): migra_rec
/*      1 = si la persona migro hace tres años o menos
        0 = si la persona migro hace mas de tres años
		. = si no es migrante o no sabe cuando migro
*/
gen   migra_rec = .
notes migra_rec: the survey does not include information to define this variable

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global dwell_SEDLAC propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici 
* Propiedad de la vivienda:	propieta
/* TENENCIA_VIVIENDA (s5q7): régimen de  de la vivienda  
		1 = Propia pagada		
		2 = Propia pagandose
		3 = Alquilada
		4 = Alquilada parte de la vivienda
		5 = Adjudicada pagandose Gran Mision Vivienda
		6 = Adjudicada Gran Mision Vivienda
		7 = Cedida por razones de trabajo
		8 = Prestada por familiar o amigo
		9 = Tomada
		10 = Otra
		.
*/

clonevar tenencia_vivienda = s5q7 if (s5q7!=. & s5q7!=.a)
gen     propieta = 1		if  tenencia_vivienda==1 | tenencia_vivienda==2 // ask Daniel if we should include 5 and 6 
replace propieta = 0		if  tenencia_vivienda>=3 & tenencia_vivienda<=10
replace propieta = .		if  relacion!=1

* Habitaciones, contando baño y cocina: habita 
gen     habita = .
notes   habita: the survey does not include information to define this variable

* Dormitorios de uso exclusivo: dormi
* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormitorios = s5q1 if (s5q1!=. & s5q1!=.a)
gen     dormi = ndormitorios 
replace dormi =. if relacion!=1
 
* Vivienda en lugar precario: precaria
/* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
*/
clonevar tipo_vivienda = s4q4 if (s4q4!=. & s4q4!=.a)
gen     precaria = 0		if  (tipo_vivienda>=1 & tipo_vivienda<=4) | tipo_vivienda==6
replace precaria = 1		if  tipo_vivienda==5  | tipo_vivienda==7   
replace precaria = .		if  relacion!=1

* Material de construcción precario: matpreca
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
			 
   MATERIAL_PARED_EXTERIOR (s4q2)
		1 = Bloque, ladrillo frisado	
		2 = Bloque ladrillo sin frisar  
		3 = Concreto	
		4 = Madera aserrada 
		5 = Bloque de plocloruro de vinilo	
		6 = Adobe, tapia o bahareque frisado
		7 = Adobe, tapia o bahareque sin frisado
		8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  

   MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)

   APARIENCIA_VIVIENDA (no se pregunta) 
*/
gen  material_piso = s4q1            if (s4q1!=. & s4q1!=.a)
gen  material_pared_exterior = s4q2  if (s4q2!=. & s4q2!=.a)
gen  material_techo = s4q3           if (s4q3!=. & s4q3!=.a)

gen     matpreca = 0        
replace matpreca = 1		if  material_pared_exterior>=5 & material_pared_exterior<=8 
replace matpreca = 1		if  material_techo==5
replace matpreca = 1		if  material_piso>=3 & material_piso<=5
replace matpreca = .        if  material_piso==. & material_pared_exterior==. & material_techo==.
replace matpreca = .		if  relacion!=1

* Instalacion de agua corriente: agua
/* ACCESO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda?
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
   FREC_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
*/
gen     acceso_agua = 1 if  s4q5__1==1
replace acceso_agua = 2 if  s4q5__2==1
replace acceso_agua = 3 if  s4q5__3==1
replace acceso_agua = 4 if  s4q5__4==1
replace acceso_agua = 5 if  s4q5__5==1
replace acceso_agua = 6 if  s4q5__6==1	
clonevar frec_agua = s4q6 if (s4q6!=. & s4q6!=.a)	
gen     agua = (acceso_agua==1 | acceso_agua==2) if acceso_agua!=.
replace agua = 0 if agua==1 & frec_agua==5
replace agua= .		if  relacion!=1		

* Baño con arrastre de agua: banio
/* TIPO_SANITARIO (s4q9): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
gen tipo_sanitario = s4q9 if (s4q9!=. & s4q9!=.a)
gen     banio = (tipo_sanitario>=1 & tipo_sanitario<=3) if tipo_sanitario!=.
replace banio = .		if  relacion!=1

* Cloacas: cloacas
gen     cloacas = (tipo_sanitario==1) if tipo_sanitario!=.
replace cloacas = .		if  relacion!=1

* Electricidad en la vivienda: elect
/* (s4q7) : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
* INTERR_SERV_ELECTRICO (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
clonevar interr_serv_electrico = s4q8 if (s4q8!=. & s4q8!=.a)
replace interr_serv_electrico = 5 if s4q7__4==1
gen      elect = (s4q7__1==1 | s4q7__2==1 | s4q7__3==1)  if (s4q7__1!=. & s4q7__1!=.a & s4q7__2!=. & s4q7__2!=.a & s4q7__3!=. & s4q7__3!=.a)
replace elect = .		if  relacion!=1

* Teléfono:	telef
* TELEFONO: Si algun integrante de la vivienda tiene telefono fijo o movil
gen	telef =.
notes   telef: the survey does not include information to define this variable

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/

* Heladera (s5q6__1): ¿Posee este hogar nevera?
gen     heladera = s5q6__1==1 if (s5q6__1!=. & s5q6__1!=.a)
replace heladera = .		if  relacion!=1 

* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
gen     lavarropas = s5q6__2==1 if (s5q6__2!=. & s5q6__2!=.a)
replace lavarropas = .		if  relacion!=1 

* Secadora (s5q6__3): ¿Posee este hogar secadora? 
gen     secadora = s5q6__3==1 if (s5q6__3!=. & s5q6__3!=.a)
replace secadora = .		if  relacion!=1 

* Computadora (s5q6__4): ¿Posee este hogar computadora?
gen computadora = s5q6__4==1 if (s5q6__4!=. & s5q6__4!=.a)
replace computadora = .		if  relacion!=1 

* Internet (s5q6__5): ¿Posee este hogar internet?
gen     internet_casa = s5q6__5==1 if (s5q6__5!=. & s5q6__5!=.a)
replace internet_casa = .	if  relacion!=1 

* Uso de Internet: uso_internet
gen   uso_internet = .
notes uso_internet: the survey does not include information to define this variable

* Televisor (s5q6__6): ¿Posee este hogar televisor?
gen     televisor = s5q6__6==1 if (s5q6__6!=. & s5q6__6!=.a)
replace televisor = .	if  relacion!=1 

* Radio (s5q6__7): ¿Posee este hogar radio? 
gen     radio = s5q6__7==1 if (s5q6__7!=. & s5q6__7!=.a)
replace radio = .		if  relacion!=1 

* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
gen     calentador = s5q6__8==1 if (s5q6__8!=. & s5q6__8!=.a)
replace calentador = .		if  relacion!=1 

* Calefacción fija : calefaccion_fija
gen     calefaccion_fija = .
notes calefaccion_fija: the survey does not include information to define this variable

* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
gen     aire = s5q6__9==1 if (s5q6__9!=. & s5q6__9!=.a)
replace aire = .		    if  relacion!=1 

* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
gen     tv_cable = s5q6__10==1 if (s5q6__10!=. & s5q6__10!=.a)
replace tv_cable = .		if  relacion!=1

* VCR o DVD: video 
gen     video = .		
notes   video: the survey does not include information to define this variable

* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
gen     microonda = s5q6__11==1 if (s5q6__11!=. & s5q6__11!=.a)
replace microonda = .		if  relacion!=1

* Teléfono fijo (s5q6__12): telefono_fijo
gen     telefono_fijo = s5q6__12==1 if (s5q6__12!=. & s5q6__12!=.a)
replace telefono_fijo = .		    if  relacion!=1 

* Telefono celular: celular
gen     celular = .
notes   celular: the survey does not include information to define this variable

* Teléfono movil (individual): celular_ind
gen     celular_ind = .
notes   celular_ind: the survey does not include information to define this variable

* Auto (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
gen     auto = s5q4==1		if  s5q4!=. & s5q4!=.a
replace auto = .		if  relacion!=1 

* NCARROS (s5q4a) : ¿Cuantos carros de uso familiar tiene este hogar?
gen     ncarros = s5q4a if (s5q4a!=. & s5q4a!=.a)
replace ncarros = .		if  relacion!=1 

* Antiguedad del auto (en años): ant_auto
gen   ant_auto = .
notes ant_auto: the survey does not include information to define this variable

* Auto nuevo (5 o menos años): auto_nuevo
gen   auto_nuevo = .
notes auto_nuevo: the survey does not include information to define this variable

* Moto:	moto
* MOTOCICLETA: ¿Tiene usted o algún miembro del hogar motocicleta?
gen   moto = .
notes moto: the survey does not include information to define this variable 

* Bicicleta: bici
gen   bici = .
notes bici: the survey does not include information to define this variable

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.6: Education --------------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_SEDLAC alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp
/* NIVEL_EDUC_EN (s7q4): ¿Cual es el nivel educativo al que asiste en este periodo 2019-2020:  // this question is only asked to those who are currently attending. What happens with those who already finished?
		1 = Ninguno		
        2 = Preescolar
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado			
		99 = NS/NR
* A_EDUC (s7q4a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* S_EDUC (emhp27a): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
* NIVEL_EDUC: ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
		99 = NS/NR
*/
clonevar nivel_educ_en = s7q4 if (s7q4!=. & s7q4!=.a) //only available for those who are currently attending
gen nivel_educ = 1 if nivel_educ_en==1
replace nivel_educ = 2 if nivel_educ_en==2
replace nivel_educ = 3 if nivel_educ_en==5
replace nivel_educ = 4 if nivel_educ_en==6
replace nivel_educ = 5 if nivel_educ_en==7
replace nivel_educ = 6 if nivel_educ_en==8
replace nivel_educ = 7 if nivel_educ_en==9
label def nivel_educ 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
label value nivel_educ nivel_educ
gen g_educ = s7q4a    if (s7q4==5 | s7q4==6) & (s7q4a!=. & s7q4a!=.a) // for those attending either primary or secondary education
replace g_educ = s7q4c if (s7q4==5 | s7q4==6) & (s7q4c!=. & s7q4c!=.a) // wrongly codified in s7q4c intead of s7q4a
replace g_educ = s7q4d if (s7q4==5 | s7q4==6) & (s7q4d!=. & s7q4d!=.a) // wrongly codified in s7q4d intead of s7q4a
gen a_educ = s7q4c    if (s7q4==7 | s7q4==8 | s7q4==9) & s7q4b==1 & (s7q4c!=. & s7q4c!=.a) //for those attending tertiary annually
gen s_educ = s7q4d    if (s7q4==7 | s7q4==8 | s7q4==9) & s7q4b==2 & (s7q4d!=. & s7q4d!=.a) //for those attending tertiary on biannually
gen t_educ = s7q4e    if (s7q4==7 | s7q4==8 | s7q4==9) & (s7q4b==3 | s7q4b==5) & (s7q4e!=. & s7q4e!=.a) //for those attending tertiary on quarterly

* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
// check since educational attainment was only asked to those currently studying
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (g_educ>=2 & g_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

* Asiste a la educación formal:	asiste
/*ASISTE_ENCUESTA (s7q3): ¿Durante este periodo escolar 2019-2020, asiste regularmente a un centro educativo como estudiante? 
        1 = Si
		2 = No
*/
clonevar asiste_encuesta = s7q3  if (s7q3!=. & s7q3!=.a)                                             
gen     asiste = asiste_encuesta==1 if asiste_encuesta!=.
replace asiste = .  if  edad<3
notes   asiste: variable defined for individuals aged 3 and older

* Establecimiento educativo público: edu_pub
/* TIPO_CENTRO_EDUC (s7q5): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		.
		.a
*/
gen tipo_centro_educ = s7q5 if (s7q5!=. & s7q5!=.a)
gen     edu_pub = 1	if  tipo_centro_educ==2  
replace edu_pub = 0	if  tipo_centro_educ==1
replace edu_pub = . if  edad<3

* Educación en años: aedu //only for those who are currently attending

gen     aedu = 0	if  nivel_educ==1 | nivel_educ==2
replace aedu = 0	if  nivel_educ==3 & g_educ==0

replace aedu = 1	if  nivel_educ==3 & g_educ==1
replace aedu = 2	if  nivel_educ==3 & g_educ==2
replace aedu = 3	if  nivel_educ==3 & g_educ==3
replace aedu = 4	if  nivel_educ==3 & g_educ==4
replace aedu = 5	if  nivel_educ==3 & g_educ==5
replace aedu = 6	if  nivel_educ==3 & g_educ==6
replace aedu = 6	if  nivel_educ==4 & g_educ==0

replace aedu = 7	if  nivel_educ==4 & g_educ==1
replace aedu = 8	if  nivel_educ==4 & g_educ==2
replace aedu = 9	if  nivel_educ==4 & g_educ==3
replace aedu = 10	if  nivel_educ==4 & g_educ==4
replace aedu = 11	if  nivel_educ==4 & g_educ==5
replace aedu = 12	if  nivel_educ==4 & g_educ==6
replace aedu = 12	if (nivel_educ==5 | nivel_educ==6 ) & (a_educ==0 | s_educ<=1 | t_educ<=2)	 

replace aedu = 13	if  nivel_educ==5 & (a_educ==1 | (s_educ>=2 & s_educ<=3) | (t_educ>=3 & t_educ<=5))
replace aedu = 14	if  nivel_educ==5 & (a_educ==2 | (s_educ>=4 & s_educ<=5) | (t_educ>=6 & t_educ<=8))
replace aedu = 15	if  nivel_educ==5 & (a_educ==3 | s_educ==6 | t_educ==9)
               
replace aedu = 13	if  nivel_educ==6 & (a_educ==1 | (s_educ>=2 & s_educ<=3) | (t_educ>=3 & t_educ<=5))
replace aedu = 14	if  nivel_educ==6 & (a_educ==2 | (s_educ>=4 & s_educ<=5) | (t_educ>=6 & t_educ<=8))
replace aedu = 15	if  nivel_educ==6 & (a_educ==3 | (s_educ>=6 & s_educ<=7) | (t_educ>=9 & t_educ<=11))
replace aedu = 16	if  nivel_educ==6 & (a_educ==4 | (s_educ>=8 & s_educ<=9) | (t_educ>=12 & t_educ<=14))
replace aedu = 17	if  nivel_educ==6 & (a_educ==5 | (s_educ>=10 & s_educ<=11) | (t_educ>=15 & t_educ<=17))
replace aedu = 18	if  nivel_educ==6 & (a_educ==6 | (s_educ>=12 & s_educ<=13) | (t_educ>=18 & t_educ<=20))
replace aedu = 19	if  nivel_educ==6 & (a_educ==7 | s_educ==14 | t_educ==21)

replace aedu = 17   if  nivel_educ==7 & (a_educ==0 | s_educ<=1 | t_educ<=2) //consideramos promedio de educacion superior 5 anos 
replace aedu = 18   if  nivel_educ==7 & (a_educ==1 | (s_educ>=2 & s_educ<=3) | (t_educ>=3 & t_educ<=5))
replace aedu = 19	if  nivel_educ==7 & (a_educ==2 | (s_educ>=4 & s_educ<=5) | (t_educ>=6 & t_educ<=8))
replace aedu = 20	if  nivel_educ==7 & (a_educ==3 | (s_educ>=6 & s_educ<=7) | (t_educ>=9 & t_educ<=11))
replace aedu = 21	if  nivel_educ==7 & (a_educ==4 | (s_educ>=8 & s_educ<=9) | (t_educ>=12 & t_educ<=14))
replace aedu = 22	if  nivel_educ==7 & (a_educ==5 | (s_educ>=10 & s_educ<=11) | (t_educ>=15 & t_educ<=17))
replace aedu = 23	if  nivel_educ==7 & (a_educ==6 | s_educ==12 | t_educ==18)
notes aedu: variable defined for individuals aged 3 and older

* Nivel educativo: nivel 
/*   0 = Nunca asistió      
     1 = Primario incompleto
     2 = Primario completo   
	 3 = Secundario incompleto
     4 = Secundario completo 
	 5 = Superior incompleto 
     6 = Superior completo						
*/
gen     nivel = 0	if  nivel_educ==1 | nivel_educ==2
replace nivel = 1	if  nivel_educ==3 & g_educ<=5
replace nivel = 2	if  nivel_educ==3 & g_educ==6 
replace nivel = 3	if  nivel_educ==4 & g_educ<=5
replace nivel = 4	if  nivel_educ==4 & g_educ==6
replace nivel = 5   if  (nivel_educ==5 & a_educ<=2) | (nivel_educ==6 & s_educ<=9) // Consideramos tecnica completa si completo almenos 6 semestres y universitaria completa si completo al menos 10 semestres
replace nivel = 6   if  (nivel_educ==5 & a_educ>=3 & a_educ!=.) | (nivel_educ==6 & s_educ>=10 & s_educ!=.) | nivel_educ==7
notes nivel: variable defined for individuals aged 3 and older 

label def nivel 0 "Nunca asistio" 1 "Primario Incompleto" 2 "Primario Completo" 3 "Secundario Incompleto" 4 "Secundario Completo" ///
                5 "Superior Incompleto" 6 "Superior Completo"
label value nivel nivel

tab nivel_educ
sum aedu
tab nivel
*brow id pid nivel_educ g_educ a_educ s_educ if nivel!=. & aedu==. // se pierden 165 obs que reportan nivel_educ, pero no reportan a_educ o s_educ segun corresponde

* Nivel educativo: niveduc
/*   0 = baja educacion  (menos de 9 años)      
     1 = media educacion (de 9 a 13 años)
     2 = alta educacion  (mas de 13 años) 
*/
gen     nivedu = 0 if aedu<9
replace nivedu = 1 if aedu>=9 & aedu<=13
replace nivedu = 2 if aedu>13 & aedu!=.

*label def nivedu 0 "Baja educacion (menos de 9 años)" 1 "Media educacion (de 9-13 años)" 2 "Alta educacion (mas de 13 años)"
*label value nivedu nivedu

* Dummies niveles de educacion
gen     prii = (nivel==1) if nivel!=.
gen     pric = (nivel==2) if nivel!=.
gen     seci = (nivel==3) if nivel!=.
gen     secc = (nivel==4) if nivel!=.
gen     supi = (nivel==5) if nivel!=.
gen     supc = (nivel==6) if nivel!=.

* Experiencia potencial: exp
gen     exp = edad - aedu - 6
replace exp = 0  if exp<0

/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.7: Variables Salud ---------------------------------------------------------------
************************************************************************************************************************************************)*/
global salud_SEDLAC seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
* Seguro de salud: seguro_salud
/* AFILIADO_SEGURO_SALUD (smhp24a-smhp24g): ¿está afiliado a algún seguro medico?
        1 = Instituto Venezolano de los Seguros Sociales (IVSS)
	    2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
	    3 = Seguro medico contratado por institucion publica
	    4 = Seguro medico contratado por institucion privada
	    5 = Seguro medico privado contratado de forma particular
	    6 = No tiene plan de seguro de atencion medica
*/

gen afiliado_seguro_salud = s8q18   if  (s8q18!=. & s8q18!=.a) 
replace afiliado_seguro_salud = 6 if s8q17==2
label define afiliado_seguro_salud 1 "Instituto Venezolano de los Seguros Sociales (IVSS)" 2 "Instituto de prevision social publico (IPASME, IPSFA, otros)" ///
3 "Seguro medico contratado por institucion publica" 4 "Seguro medico contratado por institucion privada" 5 "Seguro medico privado contratado de forma particular" ///
6 "No tiene plan de seguro de atencion medica"
label value afiliado_seguro_salud afiliado_seguro_salud
gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6

* Tipo de seguro de salud: tipo_seguro
/*      0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
        1 = si esta afiliado a algun seguro de salud privado
*/
gen 	tipo_seguro = 0     if  (afiliado_seguro_salud>=1 & afiliado_seguro_salud<=4) 
replace tipo_seguro = 1     if  afiliado_seguro_salud==5 

* Uso de metodos anticonceptivos: anticonceptivo
gen     anticonceptivo = . 
notes anticonceptivo: the survey does not include information to define this variable

* ¿Consulto ginecologo en los ultimos 3 años?: ginecologo 
gen     ginecologo=. 
notes ginecologo: the survey does not include information to define this variable

* ¿Hizo papanicolao en los ultimos 3 años?: papanicolao
gen     papanicolao=. 
notes papanicolao: the survey does not include information to define this variable

* ¿Hizo mamografia en los ultimos 3 años?: mamografia
gen     mamografia=. 
notes mamografia: the survey does not include information to define this variable

* Control durante el embarazo: control_embarazo //SOLO PARA EMBARAZADAS O TAMBIEN PARA QUIENES TUVIERON HIJOS VIVOS PREVIAMENTE?
/*      1 = si se realizo controles durante el embarazo
        0 = si no se realizo controles durante el embarazo
*/		
gen     control_embarazo = .
notes control_embarazo: the survey does not include information to define this variable

* Lugar control del embarazo: lugar_control_embarazo
/*      1 = si el control del embarazo fue en un lugar privado
        0 = si el control del embarazo fue en un lugar publico o vinculado al trabajo (obra social)
*/
gen     lugar_control_embarazo = .
notes lugar_control_embarazo: the survey does not include information to define this variable

* Lugar del parto: lugar_parto
/*      1 = si el parto fue en un lugar privado
        0 = si el parto fue en un lugar publico o vinculado al trabajo (obra social)
*/
gen     lugar_parto = .
notes lugar_parto: the survey does not include information to define this variable

* ¿Hasta que edad le dio pecho?: tiempo_pecho
gen    tiempo_pecho = .
notes tiempo_pecho: the survey does not include information to define this variable

* Vacunas
*  ¿Ha recibido vacuna Anti-BCG (contra la tuberculosis): vacuna_bcg
gen    vacuna_bcg = .
notes vacuna_bcg: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Anti-hepatitis B: vacuna_hepatitis
gen    vacuna_hepatitis = .
notes vacuna_hepatitis: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Cuadruple (contra la difteria, el tetanos y la influenza tipo b): vacuna_cuadruple
gen    vacuna_cuadruple = .
notes vacuna_cuadruple: the survey does not include information to define this variable 

*  ¿Ha recibido vacuna Triple Bacteriana (contra la difteria, el tetanos y la tos convulsa): vacuna_triple
gen    vacuna_triple = . 
notes vacuna_triple: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Antihemophilus (contra la influenza tipo b): vacuna_hemo
gen    vacuna_hemo = .
notes vacuna_hemo: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Sabin (contra la poliomielitis): vacuna_sabin
gen    vacuna_sabin = .
notes vacuna_sabin: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Triple Viral (contra el sarampion, las paperas y la rubeola): vacuna_triple_viral
gen    vacuna_triple_viral = . 
notes vacuna_triple_viral: the survey does not include information to define this variable

*** ADICIONALES
*  ¿Ha recibido vacuna Antirotavirus: vacuna_rotavirus
gen    vacuna_rotavirus = . 
notes vacuna_rotavirus: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Pentavalente (contra la difteria, tos ferina, tetanos, hepatitis B, meningitis y neumonias por Hib): vacuna_pentavalente
gen    vacuna_pentavalente = .
notes vacuna_pentavalente: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Anti-neumococo : vacuna_neumococo
gen    vacuna_neumococo = .
notes vacuna_neumococo: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Anti-amarilica (contra la fiebre amarilla) : vacuna_amarilica
gen    vacuna_amarilica = .
notes vacuna_amarilica: the survey does not include information to define this variable

*  ¿Ha recibido vacuna contra la Varicela: vacuna_varicela
gen    vacuna_varicela = .
notes vacuna_varicela: the survey does not include information to define this variable

* No ha recibido ninguna vacuna: vacuna_ninguna
gen    vacuna_ninguna = . 
notes vacuna_ninguna: the survey does not include information to define this variable

* ¿Estuvo enfermo?: enfermo
/*     1 = si estuvo enfermo o sintio malestar en el ultimo mes
       0 = si no estuvo enfermo ni sintio malestar en el ultimo mes
*/
gen    enfermo = s8q1==1 if (s8q1!=. & s8q1!=.a)

* ¿Interrumpio actividades por estar enfermo?: interrumpio
/*      1 = si interrumpio sus actividades habituales por estar enfermo
        0 = si no interrumpio sus actividades habituales por estar enfermo
*/
gen    interrumpio = .
notes interrumpio: the survey does not include information to define this variable

* ¿Visito al medico?: visita
/*     1 = si consulto al medico en las ultimas 4 semanas
       0 = si no consulto al medico en las ultimas 4 semanas
*/
gen    visita = s8q3==1 if s8q1==1 & (s8q3!=. & s8q3!=.a)

* ¿Por que no consulto al medico?: razon_no_medico
/*     1 = si no consulto al medico por razones economicas
       0 = si no consulto al medico por razones no economicas
*/
gen    razon_no_medico = s8q4==2 if s8q1==1 & s8q3==2 & (s8q4!=. & s8q4!=.a)

* Lugar de ultima consulta: lugar_consulta
/*     1 = si el lugar de la ultima consulta es privado
       0 = si el lugar de la ultima consulta es publico o vinculado al trabajo
* LUGAR_ATENCION (s8q6): Donde acudio para su atencion?
       1 = Ambulatorio/clinica popular/CDI
	   2 = Hospital publico o del seguro social
	   3 = Servicio privado sin hospitalizacion
	   4 = Clinica privada
	   5 = Centro de salud privado sin fines de lucro
	   6 = Servicio medico en el lugar del trabajo
	   7 = Farmacia
	   8 = Otro
*/
clonevar lugar_atencion = s8q6 if s8q1==1 & s8q3==1 & (s8q6!=. & s8q6!=.a)
gen    lugar_consulta = (lugar_atencion==3 | lugar_atencion==4 | lugar_atencion==5) if lugar_atencion!=.

* Pago de la ultima consulta: pago_consulta
/*     1 = si el pago de la ultima consulta fue privado
       0 = si el pago de la ultima consulta es publico o vinculado al trabajo
*/
gen    pago_consulta = lugar_consulta==1 if s8q1==1 & s8q3==1 & s8q7==1

* Tiempo que tardo en llegar al medico medido en horas: tiempo_consulta
gen    tiempo_consulta = .
notes tiempo_consulta: the survey does not include information to define this variable

* ¿Obtuvo remedios prescriptos?: obtuvo_remedio
/*     1 = si obtuvo medicamentos prescriptos
       0 = si no obtuvo medicamentos prescriptos
* RECETO_REMEDIO (s8q9): Se le receto algun medicamento?
       1 = Si
	   2 = No
* RECIBIO_REMEDIO (s8q9): Como obtuvo los medicamentos?
       1 = Los recibio todos gratis
	   2 = Recibio algunos gratis y otros los compro
	   3 = Los compro todos
	   4 = Compro algunos
	   5 = Recibio algunos gratis y otros no pudo comprarlos
	   6 = No pudo obtener ninguno	   
*/
gen     receto_remedio=s8q9==1 if s8q1==1 & s8q3==1 & (s8q9!=. & s8q9!=.a)
clonevar  recibio_remedio = s8q10 if receto_remedio==1 & (s8q10!=. & s8q10!=.a) 
gen     obtuvo_remedio = (recibio_remedio>=1 & recibio_remedio<=5) if receto_remedio==1 

* ¿Por que no obtuvo remedios prescriptos?: razon_no_remedio
/*     1 = si no obtuvo remedios por razones economicas
       0 = si no obtuvo remedios por otras razones
*/
gen    razon_no_remedio = .
notes razon_no_remedio: the survey does not include information to define this variable

* ¿Fuma?: fumar
/*     1 = si fuma o fumo alguna vez
       0 = si nunca fumo
*/
gen   fumar = .
notes fumar: the survey does not include information to define this variable

* ¿Hace deporte regularmente?: deporte
/*     1 = si hace deporte regularmente (1 vez por semana)
       0 = si no hace deporte regularmente
*/
gen    deporte = .
notes deporte: the survey does not include information to define this variable
;
/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.8: Variables laborales ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

* Relacion laboral en su ocupacion principal: relab
/* RELAB:
        1 = Empleador
		2 = Empleado (asalariado)
		3 = Independiente (cuenta propista)
		4 = Trabajador sin salario
		5 = Desocupado
		. = No economicamente activos

* LABOR_STATUS (tmhp34): La semana pasada estaba:
        1 = Trabajando
		2 = No trabajo', pero tiene trabajo
		3 = Buscando trabajo por primera vez
		4 = Buscando trabajo habiendo trabajado antes
		5 = En quehaceres del hogar
		6 = Incapacitado
		7 = Otra situacion
		8 = Estudiando o de vacaciones escolares
		9 = Pensionado o jubilado
		99 = NS/NR
* CATEG_OCUP (tmhp41): En su trabajo se desempena como
        1 = Empleado en el sector publico
		2 = Obrero en el sector publico
		3 = Empleado en empresa privada
		4 = Obrero en empresa privada
		5 = Patrono o empleador
		6 = Trabajador por cuenta propia
		7 = Miembro de cooperativas
		8 = Ayudante familiar remunerado/no remunerado
		9 = Servicio domestico
		99 = NS/NR
*/
gen labor_status = tmhp34 if (tmhp34!=98 & tmhp34!=99)
gen categ_ocu = tmhp41    if (tmhp41!=98 & tmhp41!=99)
gen     relab = .
replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  //employer 
replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9) //employee
replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6 | categ_ocu==7)  //self-employed
replace relab = 4 if (labor_status==1 | labor_status==2) & categ_ocu== 8 //unpaid family worker
replace relab = 2 if (labor_status==1 | labor_status==2) & (categ_ocu== 8 & tmhp42bs>0 & tmhp42bs!=98 & tmhp42bs!=99) //paid family worker
replace relab = 5 if (labor_status==3 | labor_status==4)

gen     relab_s =.
gen     relab_o =.

* Duracion del desempleo: durades (en meses)
/* DILIGENCIAS_BT (tmhp36): ¿Cuando fue la ultima vez que hizo diligencias para buscar trabajo?
        1 = En el ultimo mes
		2 = Entre 1 y 5 meses
		3 = Entre 6 y 12 meses
		4 = Mas de doce meses
		5 = No hizo diligencias
        99 = NS/NR
*/
gen diligencias_bt = tmhp36 if (tmhp36!=98 & tmhp36!=99) // tambien la contesta gente que no esta desocupada
/* tab relab if tmhp36!=.
      relab |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        125        1.52        1.52
          2 |      3,872       47.20       48.73
          3 |      3,370       41.08       89.81
          4 |        122        1.49       91.30
          5 |        714        8.70      100.00
------------+-----------------------------------
      Total |      8,203      100.00
*/
gen     durades = 0   if relab==5
replace durades = 0.5   if relab==5 & diligencias_bt==1
replace durades = 3 if relab==5 & diligencias_bt==2
replace durades = 9  if relab==5 & diligencias_bt==3
replace durades = 13  if relab==5 & diligencias_bt==4 //NO ESTOY SEGURA SI SE DEBE ASIGNAR ESTE VALOR
*notes durades: the survey does not include information to define this variable

* Horas trabajadas totales y en ocupacion principal: hstrt y hstrp
* NHORAST (tmhp45): ¿Cuantas horas en promedio trabajo la semana pasada? 
gen nhorast = tmhp45 if (tmhp45!=98 & tmhp45!=99)
gen      hstrt = .
replace  hstrt = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

gen      hstrp = . 
replace  hstrp = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
/* DMASHORAS (tmhp47): ¿Preferiria trabajar mas de 35 horas por semana?
   BMASHORAS (tmhp48): ¿Ha hecho algo parar trabajar mas horas?
   CAMBIO_EMPLEO (tmhp50):  ¿ Ha cambiado de trabajo durante los ultimos meses?
*/
gen dmashoras = tmhp47      if (tmhp47!=98 & tmhp47!=99)
gen bmashoras = tmhp48      if (tmhp48!=98 & tmhp48!=99)
gen cambio_empleo = tmhp50  if (tmhp50!=98 & tmhp50!=99)
gen     deseamas = 0 if (relab>=1 & relab<=4)
replace deseamas = 1 if dmashoras==1 | bmashoras==1 

* Antiguedad: antigue
gen     antigue = .
notes   antigue: variable defined for all individuals

* Asalariado en la ocupacion principal: asal
gen     asal = (relab==2) if (relab>=1 & relab<=4)

* Tipo de empresa: empresa 
/*      1 = Empresa privada grande (mas de cinco trabajadores)
        2 = Empresa privada pequena (cinco o menos trabajadores)
		3 = Empresa publica
* FIRM_SIZE (tmhp40): Contando a ¿cuantas personas trabajan en el establecimiento o lugar en el que trabaja?
        1 = Una (1) persona
		2 = De 2 a 4 personas
		3 = Cinco personas
		4 = De 6 a 10 personas
		5 = De 11 a 20 personas
		6 = De 21 a 100 personas
		7 = Mas de 100 personas
		98 = No aplica
		99 = NS/NR
*/
gen firm_size = tmhp40 if (tmhp40!=98 & tmhp40!=99)
gen     empresa = 1 if (categ_ocu==3 | categ_ocu==4 | categ_ocu== 9) & (firm_size>=4 & firm_size!=.)
replace empresa = 2 if (categ_ocu==3 | categ_ocu==4 | categ_ocu== 9) & (firm_size>=1 & firm_size<=3)
replace empresa = 3 if (categ_ocu==1 | categ_ocu==2)

* Grupos de condicion laboral: grupo_lab
/*      1 = Patrones //formal
        2 = Trabajadores asalariados en empresas grandes //formal
		3 = Trabajadores asalariados en el sector publico //formal
		4 = Trabajadores independientes profesionales (educacion superior completa) //formal
		5 = Trabajadores asalariados en empresas pequenas //informal
		6 = Trabajadores independientes no profesionales  //informal
		7 = Trabajadores sin salario                      //informal
*/
gen     grupo_lab = 1 if relab==1
replace grupo_lab = 2 if relab==2 & empresa==1
replace grupo_lab = 3 if relab==2 & empresa==3 
replace grupo_lab = 4 if relab==3 & supc==1
replace grupo_lab = 5 if relab==2 & empresa==2
replace grupo_lab = 6 if relab==3 & supc!=1
replace grupo_lab = 7 if relab==4

* Categorias de condicion laboral: categ_lab
/*      1 = Trabajadores considerados formales bajo definicion en grupo_lab 
        2 = Trabajadores considerados informales o de baja productividad
*/
gen     categ_lab = .
replace categ_lab = 1 if grupo_lab>=1 & grupo_lab<=4
replace categ_lab = 2 if grupo_lab>=5 & grupo_lab<=7

* Sector de actividad: sector1d (clasificacion CIIU) y sector (10 sectores)
/*      1 = Agricola, actividades primarias
	    2 = Industrias de baja tecnologia (industria alimenticia, bebidas y tabaco, textiles y confecciones) 
	    3 = Resto de industria manufacturera
	    4 = Construccion
	    5 = Comercio minorista y mayorista, restaurants, hoteles, reparaciones
	    6 = Electricidad, gas, agua, transporte, comunicaciones
	    7 = Bancos, finanzas, seguros, servicios profesionales
	    8 = Administración pública, defensa y organismos extraterritoriales
	    9 = Educacion, salud, servicios personales 
	    10 = Servicio domestico 
* SECTOR_ENCUESTA (tmhp39): ¿A que se dedica el negocio, organismo o empresa en la que trabaja?
        1 = Agricultura, ganaderia, pesca, caza y actividades de servicios conexas
		2 = Explotación de minas y canteras
		3 = Industria manufacturera
	    4 = Instalacion/ suministro/ distribucion de electricidad, gas o agua
	    5 = Construccion
		6 = Comercio al por mayor y al por menor; reparacion de vehiculos automotores y motocicletas
		7 = Transporte, almacenamiento, alojamiento y servicio de comida, comunicaciones y servicios de computacion
		8 = Entidades financieras y de seguros, inmobiliarias, profesionales, cientificas y tecnicas; y servicios administrativos de apoyo
		9 = Admin publi, enseñanza, salud, asistencia social, arte, entretenimiento, embajadas
		10 = Otras actividades de servicios como reparaciones, limpieza, peluqueria, funeraria y servicio domestico
		98 = No aplica
	    99 = NS/NR
*/
clonevar sector_encuesta = tmhp39 if (tmhp39!=98 & tmhp39!=99)
gen     sector1d = .
notes sector1d: the survey does not include information to define this variable

gen     sector= .
notes sector: the survey does not allow to differentiate between low productivity manufacture industries and the rest of manufacture industries.
/*
gen     sector8= 1  if (relab>=1 & relab<=4) & sector_encuesta==1  //Actividades agricolas y ganaderas
replace sector8 = 2 if (relab>=1 & relab<=4) & sector_encuesta==2 //Minas
replace sector8 = 3 if (relab>=1 & relab<=4) & sector_encuesta==3 //Manufactura
replace sector8 = 4 if (relab>=1 & relab<=4) & sector_encuesta==5 //Construccion
replace sector8 = 5 if (relab>=1 & relab<=4) & sector_encuesta==6 //Comercio
replace sector8 = 6 if (relab>=1 & relab<=4) & (sector_encuesta==4 | sector_encuesta==7) //Electricidad, agua, gas, transporte y comunicaciones
replace sector8 = 7 if (relab>=1 & relab<=4) & sector_encuesta==8 //Entidades financieras
replace sector8 = 8 if (relab>=1 & relab<=4) & (sector_encuesta==9 | sector_encuesta==10) // otros servicios
*/

* Tarea que desempena: tarea
/* TAREA (tmhp38): ¿Cual es el oficio o trabajo que realiza?
        1 = Director o gerente
		2 = Profesionales cientifico o intelectual
		3 = Técnicos o profesional de nivel medio
		4 = Personal de apoyo administrativo
		5 = Trabajador de los servicios o vendedor de comercios y mercados
		6 = Agricultores y trabajadores calificado agropecuario, forestal o  pesquero
		7 = Oficiales y operario o artesano de artes mecanicas y otros oficios
		8 = Operadores de instalaciones fijas y máquinas y maquinarias
		9 = Ocupaciones elementales
		10 = Ocupaciones militares
		98 = No aplica
		99 = NS/NR
*/
clonevar tarea= tmhp38 if (relab>=1 & relab<=4) & (tmhp38!=98 & tmhp38!=99)

* Caracteristicas del empleo y acceso a beneficios a partir del empleo
* Trabajador con contrato:  contrato (definida para trabajadores asalariados)
/* CONTRATO_ENCUESTA (tmhp43): ¿En su trabajo, tienen contrato?
        1 = Formal (contrato firmado por tiempo indefinido)
		2 = Formal (contrato firmado por tiempo determinado)
		3 = Acuerdo verbal? 
		4 = No tiene contrato
		98 = No aplica 
		99 = NS/NR
*/
clonevar contrato_encuesta = tmhp43 if (tmhp43!=98 & tmhp43!=99)
gen     contrato = 1 if relab==2 & (contrato_encuesta== 1 | contrato_encuesta==2)
replace contrato = 0 if relab==2 & (contrato_encuesta== 3 | contrato_encuesta==4)

* Ocupacion permanente
gen     ocuperma = (contrato_encuesta==1) if relab==2 

* Derecho a percibir una jubilacion: djubila
/*APORTE_PENSION (pmhp56sv,pmhp56si,pmhp56se, pmhp56so, pmhp56no)
        1 = Si, para el IVSS
		2 = Si, para otra institucion o empresa publica
		3 = Si, para institucion o empresa privada
		4 = Si, para otra
		5 = No
		98 = No aplica
		99 = NS/NR  
*/
gen aporte_pension = 1     if pmhp56sv==1
replace aporte_pension = 2 if pmhp56si==2
replace aporte_pension = 3 if pmhp56se==3
replace aporte_pension = 4 if pmhp56so==4
replace aporte_pension = 5 if pmhp56so==5
gen     djubila = (aporte_pension>=1 & aporte_pension<=4) if  relab==2  

* Seguro de salud ligado al empleo: dsegsale
gen     dsegsale = (afiliado_seguro_salud==3 | afiliado_seguro_salud==4) if relab==2

* Derecho a aguinaldo: aguinaldo
gen     aguinaldo = (tmhp44ua==1) if ((tmhp44ua!=98 & tmhp44ua!=99) & relab==2) 

* Derecho a vacaciones pagas: dvacaciones
gen     dvacaciones = .
notes dvacaciones: the survey does not include information to define this variable

* Sindicalizado: sindicato
gen     sindicato = tmhp44as==1 if ((tmhp44as!=98 & tmhp44as!=99) & relab==2) 

* Programa de empleo: prog_empleo //si el individuo esta trabajando en un plan de empleo publico
gen     prog_empleo = .
notes prog_empleo: the survey does not include information to define this variable

* Empleado:	ocupado
gen     ocupado = inrange(labor_status,1,2) //trabajando o no trabajando pero tiene trabajo

* Desocupados: desocupa
gen     desocupa = inrange(labor_status,3,4)  //buscando trabajo por primera vez o buscando trabajo habiendo trabajado anteriormente
		
* Inactivos: inactivos	
gen     inactivo= inrange(labor_status,5,9) 

* Poblacion economicamte activa: pea	
gen     pea = (ocupado==1 | desocupa ==1)

/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 1.9: Variables de ingresos ----------------------------------------------------------
***********************************************************************************************************************************************)*/	

********** A. INGRESOS LABORALES **********
	
****** 9.1.INGRESO LABORAL PRIMARIO ******
* LIMPIEZA DE LA VARIABLE DE INGRESOS. TRATAMIENTO DE LA NO RESPUESTA

* Ingresos laborales segun si recibieron o no
tab tmhp42bs tmhp42 
tab tmhp42bs if tmhp42==99 // Personas que NR si recibieron pero despues responden un monto (113)

* Situacion laboral y recepcion de ingresos
tab tmhp34 tmhp42
/*                     |   ¿Cuánto recibió en total durante el mes
     La semana pasada |      pasado por el trabajo realizado?
          ¿Estaba...? | Si recibi  No recibi  No aplica      NS/NR |     Total
----------------------+--------------------------------------------+----------
           Trabajando |     6,700        128          0        438 |     7,266 
No trabajó pero tiene |       306         26          0         61 |       393 
Buscando trabajo por  |         0          0        177          0 |       177 
Buscando trabajo habi |         0          0        537          0 |       537 
En quehaceres del hog |         0          0      3,044          0 |     3,044 
         Incapacitado |         0          0        253          0 |       253 
       Otra situación |         0          0        400          0 |       400 
           Estudiando |         0          0      3,304          0 |     3,304 
Pensionado o jubilado |         0          0      1,640          0 |     1,640 
            No aplica |         0          0      4,491          0 |     4,491 
                NS/NR |         0          0          0        145 |       145 
----------------------+--------------------------------------------+----------
                Total |     7,006        154     13,846        644 |    21,650 
*/

/* Esto implica que no deberiamos preocuparnos por los que NA cuando 
vemos la tabla de ingresos ya que los que NA son casi los mismos que figuran en 
la misma categoria luego */

* Se reemplazan como missing NR y NA
replace tmhp42bs = . if tmhp42bs==99 // Cedlas clasifica la NR como missing
replace tmhp42bs = . if tmhp42bs==98 // Los NA como missing?? VER

/*  Solo se incluyen ingresos monetarios
La variable TMHP42 identifica a los que recibieron ingresos laborales
La variable TMHP42BS menciona los montos recibidos en el mes anterior a la encuesta

ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia*/

*****  i)  PATRON
* Monetario	
* Ingreso monetario laboral de la actividad principal si es patrón
gen     ipatrp_m = tmhp42bs if relab==1  

* No monetario
gen     ipatrp_nm = .	

****  ii)  ASALARIADOS
* Monetario	
* Ingreso monetario laboral de la actividad principal si es asalariado
gen     iasalp_m = tmhp42bs if relab==2

* No monetario
gen     iasalp_nm = .


***** iii)  CUENTA PROPIA
* Monetario	
* Ingreso monetario laboral de la actividad principal si es cuenta propia
gen     ictapp_m = tmhp42bs if relab==3

* No monetario
gen     ictapp_nm = .

***** IV)otros
gen iolp_m = tmhp42bs if relab==4 | ((inlist(tmhp34,1,2) & tmhp41==99))
gen iolp_nm=.

****** 9.2.INGRESO LABORAL SECUNDARIO ******
*No se distingue

* Monetario	
gen     ipatrnp_m = .
gen     iasalnp_m = .
gen     ictapnp_m = .
gen     iolnp_m=.

* No monetario
gen     ipatrnp_nm = .
gen     iasalnp_nm = .
gen     ictapnp_nm = .
gen     iolnp_nm = .

****** 9.3.INGRESO NO LABORAL ******
/* Incluye 
	1) jubilaciones y pensiones
	2) ingresos de capital
	3) transferencias privadas y estatales
*/

/* Es necesario construir categorias para Ingresos no laborales a partir de la encuesta 
   dado que hay una unica tagoria donde se reportan todos los ingresos*/

gen ing_nlb_pv = 1  if tmhp52pv==1 // Pensión de vejez del IVSS
gen ing_nlb_pi = 1  if tmhp52pi==2 // Otra pensión del IVSS (invalidez, incapacidad, sobreviviente)
gen ing_nlb_jt = 1  if tmhp52jt==3 // Jubilación por trabajo
gen ing_nlb_ef = 1  if tmhp52ef==4 // Ayuda económica de algún familiar o de otra persona en el país
gen ing_nlb_af = 1  if tmhp52af==5 // Ayuda económica de algún familiar o de otra persona desde el exterior
gen ing_nlb_pp = 1  if tmhp52pp==6 // Pensión de la seguridad social de otro país
gen ing_nlb_rp = 1  if tmhp52rp==7 // Renta de propiedades
gen ing_nlb_id = 1  if tmhp52id==8 // Intereses o dividendos
gen ing_nlb_ot = 1  if tmhp52ot==9 // Otro
gen ing_nlb_ni = 1  if tmhp52ni==10 // Ninguno
gen ing_nlb_nsr = 1 if tmhp52nsr==11 //NS/NR
/*  
gen ing_nlb_ps= 1  if tp51ps==1 // Pensión por sobreviviente, orfandad
gen ing_nlb_ay = 1  if tp51ay==2 // Ayuda familiar o de otra persona
gen ing_nlb_ss = 1  if tp51ss==3 // Pension por seguro social
gen ing_nlb_jv = 1  if tp51jv==4 // Jubilación por trabajo
gen ing_nlb_rp = 1  if tp51rp==5 // Renta por priopiedades
gen ing_nlb_id = 1  if tp51id==6 // Intereses o dividendos
gen ing_nlb_ot = 1  if tp51ot==7 // Otros
*/

*Cuantas categorias de ingresos reciben
egen    recibe = rowtotal(ing_nlb_*) if (ing_nlb_ni!= 1 & ing_nlb_nsr!= 1), mi
tab recibe

/*   recibe |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      5,394       24.91       24.91
          1 |     15,548       71.82       96.73
          2 |        635        2.93       99.66
          3 |         70        0.32       99.99
          4 |          3        0.01      100.00
------------+-----------------------------------
      Total |     21,650      100.00
*/ 

****** 9.3.1.JUBILACIONES Y PENSIONES ******	  
/*
pmhp55bs    // Monto recibido por jubilacion o pension
pmhp53j==1  // Jubilado
pmhp53p==1  // Pensionado
*/

*Se reemplazan como missing NR y NA
replace pmhp55bs = . if (pmhp55bs==99 | pmhp55bs==98)
replace tmhp52bs = . if (tmhp52bs==99 | tmhp52bs==98)

*Jubilaciones y pensiones
* Monetario
* ijubi_m: Ingreso monetario por jubilaciones y pensiones	

gen     ijubi_m = .                          
replace ijubi_m = pmhp55bs if pmhp53j==1 // Jubilado (reportados 656)
replace ijubi_m = pmhp55bs if pmhp53p==2 // Pensionado (reportados 1,669)
replace ijubi_m = tmhp52bs if (ijubi==0|ijubi==.) & (ing_nlb_pv==1 | ing_nlb_pi==1 | ing_nlb_jt==1) & recibe==1

* No monetario	
gen     ijubi_nm=.

****** 9.3.2.INGRESOS DE CAPITAL ******	
/*icap_m: Ingreso monetario de capital, intereses, alquileres, rentas, beneficios y dividendos*/
gen     icap_m = .
replace icap_m = tmhp52bs if ing_nlb_pv != 1 & ing_nlb_pi != 1 & ing_nlb_jt != 1 & ing_nlb_ef != 1 & ing_nlb_af != 1 & ing_nlb_pp != 1 & (ing_nlb_rp == 1 | ing_nlb_id == 1) & ing_nlb_ot != 1 & ing_nlb_ni != 1 & ing_nlb_nsr != 1

* No monetario	
gen     icap_nm=.

****** 9.3.3.REMESAS ******	
/*rem: Ingreso monetario de remesas */
gen     rem = .
replace rem = tmhp52bs if ing_nlb_pv != 1 & ing_nlb_pi != 1 & ing_nlb_jt != 1 & ing_nlb_ef != 1 & ing_nlb_af == 1 & ing_nlb_pp != 1 & ing_nlb_rp != 1 & ing_nlb_id != 1 & ing_nlb_ot != 1 & ing_nlb_ni != 1 & ing_nlb_nsr != 1

****** 9.3.4.TRANSFERENCIAS PRIVADAS ******	
/*TMHP52EF=4 // Ayuda económica de algún familiar o de otra persona en el país
itranp_o_m Ingreso monetario de otras transferencias privadas diferentes a remesas*/

* Monetario
gen     itranp_o_m = .
replace itranp_o_m = tmhp52bs if ing_nlb_pv != 1 & ing_nlb_pi != 1 & ing_nlb_jt != 1 & ing_nlb_ef == 1 & ing_nlb_af != 1 & ing_nlb_pp != 1 & ing_nlb_rp != 1 & ing_nlb_id != 1 & ing_nlb_ot != 1 & ing_nlb_ni != 1 & ing_nlb_nsr != 1

* No monetario	
gen    itranp_o_nm =.

****** 9.3.5 TRANSFERENCIAS PRIVADAS ******	
*itranp_ns: Ingreso monetario de transferencias privadas, cuando no se puede distinguir entre remesas y otras

* Monetario
gen     itranp_ns = .

****** 9.3.6 TRANSFERENCIAS ESTATALES ******	
*HASTA AHORA SOLO SE PUEDEN ENCONTRAR BENEFICIARIOS PERO los montos HABRIA QUE IMPUTARLOS
*icct: Ingreso monetario por transferencias estatales relacionadas con transferencias monetarias condicionadas

****** 9.3.6.1 TRANSFERENCIAS ESTATALES CONDICIONADAS******
gen     cct = .

****** 9.3.6.2 OTRAS TRANSFERENCIAS ESTATALES******
*itrane_o_m Ingreso monetario por transferencias estatales diferentes a las transferencias monetarias condicionadas

* Monetarias
gen itrane_o_m = .
*No monetarias

gen     itrane_o_nm = .
gen     itrane_ns = .

***** iV) OTROS INGRESOS NO LABORALES 
gen     inla_otro = tmhp52bs if (ing_nlb_pv != 1 & ing_nlb_pi != 1 & ing_nlb_jt != 1 & ing_nlb_ef != 1 & ing_nlb_af != 1 & ing_nlb_rp != 1 & ing_nlb_id != 1 & (ing_nlb_pp == 1 | ing_nlb_ot == 1) & ing_nlb_ni != 1 & ing_nlb_nsr != 1) | (recibe>=2 & recibe!=.)

/*
***** V) INGRESOS NO LABORALES EXTRAORDINARIOS 
gen     inla_extraord = .

****** 9.3.7 INGRESOS DE LA OCUPACION PRINCIPAL ******

gen     ip_m = tmhp42bs //	Ingreso monetario en la ocupación principal 
gen     ip   = .	    // Ingreso total en la ocupación principal 

****** 9.3.8 INGRESOS TODAS LAS OCUPACIONES ******

gen     ila_m  = tmhp42bs    // Ingreso monetario en todas las ocupaciones 
gen     ila    = .           // Ingreso total en todas las ocupaciones 
gen     perila = .   // Perceptores de ingresos laborales 

****** 9.3.9 INGRESOS LABORALES HORARIOS ******

gen     wage_m= ip_m/(hstrp*4)  // Ingreso laboral horario monetario en la ocupación principal
gen wage=    // Ingreso laboral horario total en la ocupación principal 
gen ilaho_m	// Ingreso laboral horario monetario en todos los trabajos 
gen ilaho   // Ingreso laboral horario total en todos los trabajos 
*/

/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.10: LINEAS DE POBREZA  -------------------------------------------------------------
************************************************************************************************************************************************)*/
tab pobreza [aw=pondera]
/*
Pobreza ingresos |      Freq.     Percent        Cum.
-----------------+-----------------------------------
        No pobre | 1,237.6271        5.72        5.72
Pobre no extremo | 2,202.6708       10.17       15.89
   Pobre extremo | 11,202.998       51.75       67.64
    No declarado | 7,006.7045       32.36      100.00
-----------------+-----------------------------------
           Total |     21,650      100.00
*/

**** Lineas internacionales 
* Linea de pobreza 1.9 USD a day at 2011 PPP
gen     lp_1usd= 1.9

* Linea de pobreza 3.2 USD a day at 2011 PPP
gen     lp_3usd= 3.2

* Linea de pobreza 5.5 USD a day at 2011 PPP
gen     lp_5usd= 5.5

**** Linea de Pobreza Oficial
gen     lp_extrema  = .
gen     lp_moderada = .

**** Ingreso Oficial
gen     ing_pob_ext    = .
gen     ing_pob_mod    = .
gen     ing_pob_mod_lp = ing_pob_mod / lp_moderada

*** Pobreza ENCOVI
gen     pobreza_enc = (pobreza==1 | pobreza==2) if pobreza!=99
gen     pobreza_extrema_enc = (pobreza==2) if pobreza!=99

/*
  d_pobreza |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 1,301.8361        8.45        8.45
          1 | 14,101.164       91.55      100.00
------------+-----------------------------------
      Total |     15,403      100.00
*/

/*
*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- 1.1: PRECIOS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/
**** Ajuste por inflacion
* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .

* IPC del mes base
gen ipc = 316025018				/*  MES BASE: promedio Enero-Diciembre			*/

gen cpiperiod = "2018m01-2018m11"

gen     ipc_rel = 1
/*replace ipc_rel = 1 if  mes==1
replace ipc_rel = 1	if  mes==2
replace ipc_rel = 1	if  mes==3
replace ipc_rel = 1	if  mes==4
replace ipc_rel = 1 if  mes==5
replace ipc_rel = 1	if  mes==6
replace ipc_rel = 1	if  mes==7
replace ipc_rel = 1	if  mes==8
replace ipc_rel = 1	if  mes==9
replace ipc_rel = 1	if  mes==10
replace ipc_rel = 1	if  mes==11
replace ipc_rel = 1 if  mes==12
*/
**** Ajuste por precios regionales: se ajustan los ingresos rurales 
gen     p_reg = 1
*replace p_reg = 0.8695				if  urbano==0
	
foreach i of varlist iasalp_m iasalp_nm  ictapp_m ictapp_nm  ipatrp_m ipatrp_nm ///
					 iasalnp_m iasalnp_nm  ictapnp_m ictapnp_nm  ipatrnp_m ipatrnp_nm  iolnp_m iolnp_nm ///
					 ijubi_m ijubi_nm /// 
					 icap_m icap_nm rem itranp_o_m itranp_o_nm itranp_ns cct itrane_o_m itrane_o_nm itrane_ns ing_pob_ext ing_pob_mod{
		replace `i' = `i' / p_reg 
		replace `i' = `i' / ipc_rel 
		}

/*=================================================================================================================================================
					2: Preparacion de los datos: Variables de segundo orden
=================================================================================================================================================*/
capture label drop relacion
capture label drop hombre
capture label drop nivel
include "$aux_do\cuantiles.do"
*include "$aux_do\do_file_aspire.do"
include "$aux_do\do_file_1_variables.do"

/* TENENCIA_VIVIENDA (dhp15): régimen de  de la vivienda  
		1 = Propia pagada		
		2 = Propia pagandose
		3 = Alquilada
		4 = Prestada	
		5 = Invadida
		6 = De algun programa de gobierno (con titulo de propiedad)
		7 = De algun programa de gobierno (sin titulo de propiedad)
		8 = Otra
		99 = NS/NR
*/

gen aux_propieta_no_paga = 1 if tenencia_vivienda==1| tenencia_vivienda==6
replace aux_propieta_no_paga = 0 if (tenencia_vivienda>=2 & tenencia_vivienda<=5)| ( tenencia_vivienda>=7 & tenencia_vivienda<=97)
bysort id: egen propieta_no_paga = max(aux_propieta_no_paga)

gen     renta_imp = .
replace renta_imp = 0.10*itf_sin_ri  if  propieta_no_paga == 1

replace renta_imp = renta_imp / p_reg
replace renta_imp = renta_imp / ipc_rel 

include "$aux_do\do_file_2_variables.do"
include "$aux_do\labels.do"
compress




/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables a Documentar Base de Datos CEDLAS --------------
*************************************************************************************************************************************************)*/
order pais ano encuesta id com pondera strata psu relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua ///
region_est1 region_est2 region_est3 cen lla ceo zul and nor isu gua capital urbano migrante migra_ext migra_rur anios_residencia migra_rec ///
propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici ///
alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp ///
seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector sector_encuesta tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11  

keep pais ano encuesta id com pondera strata psu relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua ///
region_est1 region_est2 region_est3 cen lla ceo zul and nor isu gua capital urbano migrante migra_ext migra_rur anios_residencia migra_rec ///
propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici ///
alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp ///
seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector sector_encuesta tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap  itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg /*ipc*/ pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i /*ipc05 ipc11 ppp05 ppp11 *//*ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/  

notes: Venezuela changed its currency during the recolection of data. Income variables might be expressed in different currencies.

save "$dataout\base_out_nesstar_cedlas_2018.dta", replace

