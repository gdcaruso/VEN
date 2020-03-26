/*===========================================================================
Country name:		Venezuela
Year:			2015
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CE	DLAS/UNLP -- The World Bank
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
		global lauta   0
		
		* User 4: Malena
		global male   0
		
			
		if $juli {
				global rootpath "C:\Users\WB563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Desktop\worldbank\analisis\ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\1. Data Harmonization\output"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\1. Data Harmonization\dofiles\aux_do"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global datafinalharm "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI harmonized data"
global datafinalimp "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI imputation data"


********************************************************************************

/*===============================================================================
                          0: Program set up
===============================================================================*/
version 14
drop _all

local country  "VEN"    // Country ISO code
local year     "2015"   // Year of the survey
local survey   "ENCOVI"  // Survey acronym
local vm       "01"     // Master version
local va       "01"     // Alternative version
local project  "03"     // Project version
local period   ""       // Periodo, ejemplo -S1 -S2
local alterna  ""       // 
local vr       "01"     // version renta
local vsp      "01"	// version ASPIRE
*include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

/*==================================================================================================================================================
								1: Data preparation: First-Order Variables
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Open Databases  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
* Opening official database  
use "$data2015\Personas Encovi 2015.dta", clear
/*
gen pov=(pobreza==1 | pobreza==2) if pobreza!=99
tab pov [aw=xxp]
/*       pov |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 1,324.5448       24.39       24.39
          1 | 4,105.4552       75.61      100.00
------------+-----------------------------------
      Total |      5,430      100.00
*/
drop pov
*/
* Checking duplicate observations
duplicates tag control lin, generate(duple)
tab control mhp24 if duple==1
//el hogar 1111 parece tener dos individuos distintos con la misma lin
//decisión: creo dos lin distintas
replace lin = 2 if control==1111 & mhp24==2
//el hogar 1330 parece tener dos individuos identicos con la misma lin
//decisión: elimino una observacion
drop if control==1330 & _n==5347
drop duple

merge m:1 control using "$data2015\Covida Encovi 2015.dta"
/*
gen pov=(pobreza==1 | pobreza==2) if pobreza!=99
tab pov [aw=xxp]
/*       pov |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 1,325.0373       24.41       24.41
          1 | 4,103.9627       75.59      100.00
------------+-----------------------------------
      Total |      5,429      100.00
*/
drop pov
*/
drop _merge

rename _all, lower //En esta base existen la variable Pobreza y pobreza_max, la variable pobreza_max es la que replica el numero de pobreza publicado, al hacer el rename Pobreza se transforma en pobreza y por eso cambia el numero
/*
gen pov=(pobreza==1 | pobreza==2) if pobreza!=99
tab pov [aw=xxp]
/*        pov |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 1,227.2454       22.61       22.61
          1 | 4,201.7546       77.39      100.00
------------+-----------------------------------
      Total |      5,429      100.00
*/
drop pov
*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables  --------------------------------------------------
*************************************************************************************************************************************************)*/

* Country identifier: country
gen country = "VEN"

* Year identifier: year
capture drop year
gen year = 2015

* Survey identifier: survey
gen survey = "ENCOVI - 2015"

* Household identifier: id      
gen id = control

* Component identifier: com
gen com  = lin
duplicates report id com

gen double pid = lin
notes pid: original variable used was: lin

* Weights: pondera
gen pondera = xxp  //round(xxp)

* Strata: strata
gen strata = .
*La variable "estrato" en la base refiere a un muestreo no probabilístico (para el cual se seleccionaron áreas geográficas, grupos de edad y grupos de estrato socioeconómico de la A la F). Esto no es lo mismo que el "strata" al que se refiere CEDLAS 

* Primary Sample Unit: psu 
gen psu = .

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Demographic variables  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_ENCOVI reltohead sex age agegroup country_birth 
* Relation to the head:	reltohead
/* Categories of the new harmonized variable:
		01 = Jefe del Hogar	
		02 = Esposa(o) o Compañera(o)
		03 = Hijo(a)/Hijastro(a)
		04 = Nieto(a)		
		05 = Yerno, nuera, suegro (a)
		06 = Padre, madre       
		07 = Hermano(a)
		08 = Cunado(a)         
		09 = Sobrino(a)
		10 = Otro pariente      
		11 = No pariente
		12 = Servicio Domestico	
* RELACION_EN (mhp24): Relación de parentesco con el jefe de hogar en la encuesta
		01 = Jefe del Hogar	
		02 = Esposa(o) o Compañera(o)
		03 = Hijo(a)/Hijastro(a)
		04 = Nieto(a)		
		05 = Yerno, nuera, suegro (a)
		06 = Padre, madre       
		07 = Hermano(a)
		08 = Cunado(a)         
		9 = Sobrino(a)
		10 = Otro pariente      
		11 = No pariente
		12 = Servicio Domestico
*/
clonevar relacion_en = mhp24
gen     reltohead = 1		if  relacion_en==1
replace reltohead = 2		if  relacion_en==2
replace reltohead = 3		if  relacion_en==3  
replace reltohead = 4		if  relacion_en==4  
replace reltohead = 5		if  relacion_en==5 
replace reltohead = 6		if  relacion_en==6
replace reltohead = 7		if  relacion_en==7  
replace reltohead = 8		if  relacion_en==8
replace reltohead = 9		if  relacion_en==9
replace reltohead = 10		if  relacion_en==10
replace reltohead = 11		if  relacion_en==11
replace reltohead = 12		if  relacion_en==12

label def reltohead 1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" 4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)" ///
		            6 "Padre, madre" 7 "Hermano(a)" 8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" 12 "Servicio Domestico"	
label value reltohead reltohead

* Identificador de hogares: hogar
gen hogar = (reltohead==1)	

* Miembros de hogares secundarios (seleccionando personal doméstico): hogarsec 
gen hogarsec =.
replace hogarsec =1 if relacion_en==12
replace hogarsec = 0 if inrange(relacion_en,1,11) //está mal en el manual CEDLAS

* Hogares con presencia de miembros secundarios: presec	
tempvar aux
egen `aux' = sum(hogarsec), by(id)
gen       presec = 0
replace   presec = 1  if  `aux'>0  
replace   presec = .  if  relacion~=1
drop `aux'

* Numero de miembros del hogar (de la familia principal): miembros 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)

* Sex 
/* SEXO (mhp26): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
gen sex = mhp26
label define sex 1 "Male" 2 "Female"
label value sex sex

* Age
* EDAD_ENCUESTA (mhp25): Cuantos años cumplidos tiene?
gen     age = mhp25
notes   age: range of the variable: 0-93

* Age group: agegroup
/* 1 = individuos de 14 anos o menos
   2 = individuos entre 15 y 24 
   3 = individuos entre 25 y 40
   4 = individuos entre 41 y 64
   5 = individuos mayores a 65
*/
gen agegroup = .
replace agegroup = 1 if age<=14
replace agegroup = 2 if age>=15 & age<=24
replace agegroup = 3 if age>=25 & age<=40
replace agegroup = 4 if age>=41 & age<=64
replace agegroup = 5 if age>=65 & age!=.

/*label def gedad1 1 "[0-14]" 2 "[15-24]" 3 "[25-40]" 4 "[41-64]" 5 "65+"
label value gedad1 gedad1*/

* Identificador de miembros del hogar
gen     jefe = (reltohead==1)
gen     conyuge = (reltohead==2)
gen     hijo = (reltohead==3)

* Numero de hijos menores de 18
tempvar aux
gen `aux' = (hijo==1 & age<=18)
egen      nro_hijos = count(`aux'), by(id)
replace   nro_hijos = .  if  jefe~=1 & conyuge~=1

* Dummy de estado civil 1: casado/unido
/* ESTADO_CIVIL_ENCUESTA (mhp27): Cual es la situacion conyugal
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
* Marital status
	   1 = married
	   2 = never married
	   3 = living together
	   4 = divorced/separated
	   5 = widowed
*/
gen estado_civil_encuesta = mhp27 if (mhp27!=98 & mhp27!=99)
gen     marital_status = 1	if  estado_civil_encuesta==1 | estado_civil_encuesta==2
replace marital_status = 2	if  estado_civil_encuesta==8 
replace marital_status = 3	if  estado_civil_encuesta==3 | estado_civil_encuesta==4
replace marital_status = 4	if  estado_civil_encuesta==5 | estado_civil_encuesta==6
replace marital_status = 5	if  estado_civil_encuesta==7
label def marital_status 1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
label value marital_status marital_status

gen     married = 0		if  estado_civil_encuesta>=5 & estado_civil_encuesta<=8
replace married = 1		if  estado_civil_encuesta>=1 & estado_civil_encuesta<=4
gen     single = estado_civil_encuesta==8 if estado_civil_encuesta!=.

rename  estado_civil_encuesta marital_status_survey

*** Number of sons/daughters born alive
gen     children_born_alive = .

*** From the total of sons/daughters born alive, how many are currently alive?
gen     children_alive =.

/*(*************************************************************************************************************************************************
*-------------------------------------------------------------	1.3: Regional variables  ---------------------------------------------------------
*************************************************************************************************************************************************)*/
* Creación de Variable Geográficas Desagregadas
	
* Desagregación 1 (Regiones politico-administrativas): region 



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
	   1 Amazonas
	   2 Anzo�tegui
	   3 Apure
	   4 Aragua
	   5 Barinas
	   6 Bol�var
	   7 Carabobo
	   8 Cojedes
	   9 Delta Amacuro
	  10 Distrito Capital (Caracas)
	  11 Falc�n
	  12 Gu�rico
	  13 Lara
	  14 M�rida
	  15 Miranda
	  16 Monagas
	  17 Nueva Esparta
	  18 Portuguesa
	  19 Sucre
	  20 T�chira
	  21 Trujillo
	  22 Vargas
	  23 Yaracuy
	  24 Zulia
	  99 No sabe/No responde
*/

gen     region_est1 =  1 if enti==4 | enti==7 | enti==8                //Region Central
replace region_est1 =  2 if enti==12 | enti==3                         // Region de los LLanos
replace region_est1 =  3 if enti==11 | enti==13 | enti==18 | enti==23  // Region Centro-Occidental
replace region_est1 =  4 if enti==24                                   // Region Zuliana
replace region_est1 =  5 if enti==5 | enti==14 | enti==20 | enti==21   // Region de los Andes
replace region_est1 =  6 if enti==2 | enti==16 | enti==19              // Region Nor-Oriental
replace region_est1 =  7 if enti==17                                   // Region Insular
replace region_est1 =  8 if enti==6 | enti==1 | enti==9                // Region Guayana
replace region_est1 =  9 if enti==15 | enti==22 | enti==10              // Region Capital

label def region_est1 1 "Region Central"  2 "Region de los LLanos" 3 "Region Centro-Occidental" 4 "Region Zuliana" ///
          5 "Region de los Andes" 6 "Region Nor-Oriental" 7 "Insular" 8 "Guayana" 9 "Capital"
label value region_est1 region_est1

* Desagregación 2 (Estados): region_est2
clonevar region_est2 = enti

* Desagregación 3 (Municipio): region_est3
clonevar region_est3 = muni

* Dummy urbano-rural: urbano  //REVISAR SI SE PUEDE CONSTRUIR ESTA VARIABLE
/* : area de residencia
		 1 = urbana  
		 2 = rural								

gen     urbano = 1		if  zona==1
replace urbano = 0		if  zona==2
*/
gen     urbano =.
							 
* Dummies regionales 							 

*1.	Región Central
gen       cen = .
replace   cen = 1 if enti==4 // Aragua
replace   cen = 1 if enti==7 // Carabobo
replace   cen = 1 if enti==8 // Cojedes
replace   cen = 0 if enti!=4 & enti!=7 & enti!=8 & enti!=.


*2. Región de los Llanos
gen       lla = .
replace   lla = 1 if enti==12 // Guarico
replace   lla = 1 if enti==3  // Apure
replace   lla = 0 if enti!=12 & enti!=3 & enti!=.

*3. Región Centro-Occidental
gen       ceo = .
replace   ceo = 1 if enti==11 // Falcon
replace   ceo = 1 if enti==13 // Lara
replace   ceo = 1 if enti==18 // Portuguesa
replace   ceo = 1 if enti==23 // Yaracuy
replace   ceo = 0 if enti!=11 & enti!=13 & enti!=18 & enti!=23 & enti!=.

*4. Región Zuliana: Zulia
gen       zul = .
replace   zul = 1 if enti==24 // Zulia
replace   zul = 0 if enti!=24 & enti!=.

*5. Región de los Andes
gen       and = .
replace   and = 1 if enti==5  // Barinas
replace   and = 1 if enti==14 // Merida
replace   and = 1 if enti==20 // Tachira 
replace   and = 1 if enti==21 // Trujillo
replace   and = 0 if enti!=5 & enti!=14 & enti!=20 & enti!=21 & enti!=.

*6. Región Nor-Oriental 
gen       nor = .
replace   nor = 1 if enti==2  // Anzoategui
replace   nor = 1 if enti==16 // Monagas
replace   nor = 1 if enti==19 // Sucre
replace   nor = 0 if enti!=2 & enti!=16 & enti!=19 & enti!=.

*7. Región Insular
gen       isu = .
replace   isu = 1 if enti==17 // Nueva Esparta
replace   isu = 0 if enti!=17 & enti!=.
// Dependencias Federales aparece dentro de Insular a partir de 2016


*8. Región Guayana
gen       gua = .
replace   gua = 1 if enti==6  // Bolivar
replace   gua = 1 if enti==1  // Amazonas
replace   gua = 1 if enti==9 // Delta Amacuro
replace   gua = 0 if enti!=6 & enti!=1 & enti!=9 & enti!=.

*8. Región Capital
gen       capital = .
replace   capital = 1 if enti==15  // Miranda
replace   capital = 1 if enti==22  // Vargas
replace   capital = 1 if enti==10  // Distrito Capital
replace   capital = 0 if enti!=15 & enti!=22 & enti!=10 & enti!=.

* Areas no incluidas en años previos:	nuevareg
* para 2016 SE AGREGA LAS DEPENDENCIAS FEDERALES
gen       nuevareg=.

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/

* Propiedad de la vivienda:	propieta
/* TENENCIA_VIVIENDA (hp22): régimen de tenencia de la vivienda 
           1 ¿Propia pagada?
           2 ¿Propia pagandose?
           3 ¿Alquilada?
           4 ¿Prestada?
           5 ¿ Invadida?
           6 ¿De algún programa del gobierno?
           7 ¿Otra?
          99 NS/NR.	
		  
 La categoria Otra (especifique) codifica como 6 a las viviendas heredadas		  
*/
destring (codhp22o), replace
clonevar tenencia_vivienda = hp22 if (hp22!=98 & hp22!=99)
gen     propieta = 1		if  tenencia_vivienda==1 | tenencia_vivienda==2 | (tenencia_vivienda==8 & codhp22o==6)
replace propieta = 0		if  tenencia_vivienda>=3 & tenencia_vivienda<=7 | (tenencia_vivienda==8 & codhp22o==1)
replace propieta = .		if  relacion!=1


* Habitaciones, contando baño y cocina: habita 
gen     habita = .
notes   habita: the survey does not include information to define this variable

* Dormitorios de uso exclusivo: dormi
* NDORMITORIOS (hp19): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormitorios = hp19 if (hp19!=98 & hp19!=99 & hp19!=888)
gen     dormi = ndormitorios 
replace dormi =. if relacion!=1
 
* Vivienda en lugar precario: precaria
/* TIPO_VIVIENDA (vp4): Tipo de Vivienda 
           1 Casa Quinta
           2 Casa
           3 Apto en edificio
           4 Anexo en casaquinta
           5 Rancho
           6 Habitación en vivienda o local de trabajo
           7 Vivienda rural (malariología o similar)
          99 NS/NR
*/
clonevar tipo_vivienda = vp4 if (vp4!=98 & vp4!=99)
gen     precaria = 0		if  (tipo_vivienda>=1 & tipo_vivienda<=4) | tipo_vivienda==6
replace precaria = 1		if  tipo_vivienda==5  | tipo_vivienda==7   
replace precaria = .		if  relacion!=1

* Material de construcción precario: matpreca
/* MATERIAL_PISO (vp1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
		 5 = Otros		
		 
   MATERIAL_PARED_EXTERIOR (vp2)
		1 = Bloque, ladrillo frisado	
		2 = Bloque ladrillo sin frisar  
		3 = Concreto	
		4 = Madera aserrada 
		5 = Bloque de plocloruro de vinilo	
		6 = Adobe, tapia o bahareque frisado
		7 = Adobe, tapia o bahareque sin frisado
		8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  

   MATERIAL_TECHO (vp3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)

   APARIENCIA_VIVIENDA (no se pregunta) 
*/
gen  material_piso = vp1            if (vp1!=98 & vp1!=99)
gen  material_pared_exterior = vp2  if (vp2!=98 & vp2!=99)
gen  material_techo = vp3           if (vp3!=98 & vp3!=99)

gen     matpreca = 0     
replace matpreca = 1		if  material_pared_exterior>=5 & material_pared_exterior<=8 
replace matpreca = 1		if  material_techo==5
replace matpreca = 1		if  material_piso>=3 & material_piso<=5
replace matpreca = .        if  material_piso==. & material_pared_exterior==. & material_techo==.
replace matpreca = .		if  relacion!=1

* Instalacion de agua corriente: agua
/* ACCESO_AGUA (vp7): A esta vivienda el agua llega normalmente por (no se puede identificar si el acceso es dentro del terreno o vivienda)
           1 ¿Acueducto?
           2 ¿Pila o estanque?
           3 ¿Camión cisterna?
           4 ¿Otros medios?
         888 VERIFICAR NS/NR
*/
gen acceso_agua = vp7	if (vp7!=888)  //REVISAR
gen     agua = .
replace agua = 1 if (vp7==1 | vp7==2) & vp8!=5	
replace agua = 0 if (vp7==3 | vp7==4)	

* Baño con arrastre de agua: banio
/* TIPO_SANITARIO (vp10): Esta vivienda tiene 
           1 ¿Poceta a cloaca/pozo séptico?
           2 ¿Poceta sin conexión (tubo)?
           3 ¿Excusado de hoyo o letrina?
           4 ¿No tiene poceta o excusado?
          98 NO APLICA
          99 NS/NR
         888 VERIFICAR NS/NR
*/
gen tipo_sanitario = vp10 if (vp10!=98 & vp10!=99 & vp10!=888)
gen     banio = (tipo_sanitario==1 | tipo_sanitario==2) if tipo_sanitario!=.
replace banio = .		if  relacion!=1

* Cloacas: cloacas
gen     cloacas = .
notes   cloacas: it's not possible differentiate between cloaca and pozo septico

* Electricidad en la vivienda: elect
/* SERVICIO_ELECTRICO (vp7): En esta vivienda el servicio electrico se interrumpe

           1 ¿Diariamente por varias horas?
           2 ¿Alguna vez a la semana por varias horas?
           3 ¿Alguna vez al mes?
           4 ¿Nunca se interrumpe?
          98 NO APLICA
          99 NS/NR
         888 VERIFICAR NS/NR				
*/
gen servicio_electrico = vp9 if (vp9!=98 & vp9!=99 & vp9!=888)
gen     elect = (servicio_electrico>=1 & servicio_electrico<=4) if servicio_electrico!=.		

* Teléfono:	telef
* TELEFONO: Si algun integrante de la vivienda tiene telefono fijo o movil
// LA ENCUESTA SOLO PREGUNTA POR CELULAR, NO POR FIJO. SÓLO DEJAMOS LA VARIABLE CELULAR, MÁS ADELANE

gen telef =.
notes   telef: the survey does not include information to define this variable

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Bienes durables y servicios --------------------------------------------------------
*************************************************************************************************************************************************)*/

* Heladera (con o sin freezer): heladera
* NEVERA (hp20n): ¿Posee este hogar nevera?
gen nevera = hp20n if (hp20n!=888 & hp20n!=99)
gen     heladera = 0		if  nevera==2
replace heladera = 1		if  nevera==1
replace heladera = .		if  relacion!=1 

* Lavarropas: lavarropas
* LAVADORA (hp20l): ¿Posee este hogar lavadora?
gen lavadora = hp20l if (hp20l!=888 & hp20l!=99)
gen     lavarropas = 0		if  lavadora==2
replace lavarropas = 1		if  lavadora==1
replace lavarropas = .		if  relacion!=1 

* Aire acondicionado: aire
* AIRE_ACONDICIONADO (hp20a): ¿Posee este hogar aire acondicionado?
gen aire_acondicionado = hp20a if (hp20a!=888 & hp20a!=99)
gen     aire = 0		    if  aire_acondicionado==2
replace aire = 1		    if  aire_acondicionado==1
replace aire = .		    if  relacion!=1 

* Calefacción fija: calefaccion_fija
* CALENTADOR (hp20o): ¿Posee este hogar calentador? //NO ESTOY SEGURA SI ES COMPLETAMENTE COMPARABLE
gen     calefaccion_fija = .
notes calefaccion_fija: the survey does not include information to define this variable

* Teléfono fijo: telefono_fijo
gen     telefono_fijo = .
notes telefono_fijo: the survey does not include information to define this variable

* Teléfono movil (individual): celular_ind (mhp28)
gen     celular_ind = 1 if (mhp28==1)
replace celular_ind = 0 if (mhp28==2)

* Telefono celular: celular
tempvar allmiss
egen celular = max(celular_ind==1), by (id)
egen `allmiss' = min(celular_ind == .), by(id)
replace celular =. if `allmiss' == 1
replace celular =. if relacion!=1


* Televisor: televisor
* TELEVISOR (hp20t): ¿Posee este hogar televisor?
gen televisor_encuesta = hp20t if (hp20t!=99)
gen     televisor = 0		if  televisor_encuesta==2
replace televisor = 1		if  televisor_encuesta==1
replace televisor = .		if  relacion!=1 

* TV por cable o satelital:		tv_cable
* TVCABLE_ENCUESTA (hp20v): ¿Posee este hogar TV por cable?
gen tvcable_encuesta = hp20v if (hp20v!=99)
gen     tv_cable = 0		if  tvcable_encuesta==2
replace tv_cable = 1		if  tvcable_encuesta==1
replace tv_cable = .		if  relacion!=1 

* VCR o DVD: video 
gen     video = .		
notes   video: the survey does not include information to define this variable

* Computadora: computadora
* COMPUTADOR (hp12c): ¿Posee este hogar computadora?
gen computador = hp20c if (hp20c!=99)
gen     computadora = 0		if  computador==2 
replace computadora = 1		if  computador==1 
replace computadora = .		if  relacion!=1 

* Conexión a Internet en el hogar: internet_casa
* INTERNET (hp20i): ¿Posee este hogar internet?
gen internet = hp20i if (hp20i!=99)
gen     internet_casa = 0	if  internet==2
replace internet_casa = 1	if  internet==1
replace internet_casa = .	if  relacion!=1 

* Uso de Internet: uso_internet
gen   uso_internet = .
notes uso_internet: the survey does not include information to define this variable

* Auto: auto 
* NCARROS (hp21) : ¿Cuantos carros de uso familiar tiene este hogar?
gen ncarros = hp21 if (hp21!=98 & hp21!=99)
gen     auto = 0		if  ncarros==0
replace auto = 1		if  ncarros>=1 & ncarros!=.
replace auto = .		if  relacion!=1 

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
*---------------------------------------------------------- 1.6: Variables educativas --------------------------------------------------------------
*************************************************************************************************************************************************)*/

* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
/* NIVEL_EDUC (ep36n): ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
		98 = No Aplica
		99 = NS/NR		
* a_educ (ep36a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Preescolar, Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* s_educ (ep36s): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
*/
clonevar nivel_educ = ep36n if (ep36n!=98 & ep36n!=99)
gen a_educ = ep36a     if (ep36a!=98 & ep36a!=99)
gen s_educ = ep36s     if (ep36s!=98 & ep36s!=99)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (a_educ>=2 & a_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

* Asiste a la educación formal:	asiste
/* ASISTE_ENCUESTA (ep38): ¿asiste regularmente a un centro educativo como estudiante? 
        1 = Si
		2 = No
		3 = Nunca asistio
		98 = No aplica
		99 = NS/NR
*/
gen asiste_encuesta = ep38  if (ep38!=98 & ep38!=99)   
capture drop asiste                                        
gen     asiste = 1	if  asiste_encuesta==1 
replace asiste = 0	if  (asiste_encuesta==2 | asiste_encuesta==3)
replace asiste = .  if  edad<3
notes   asiste: variable defined for individuals aged 3 and older

* Establecimiento educativo público: edu_pub
/* TIPO_CENTRO_EDUC (ep41): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		98 = No aplica
		99 = NS/NR								
*/
gen tipo_centro_educ = ep41 if (ep41!=98 & ep41!=99)
gen     edu_pub = 1	if  tipo_centro_educ==2  
replace edu_pub = 0	if  tipo_centro_educ==1
replace edu_pub = . if  edad<3


* Educación en años: aedu //REVISAR (I have censored to 19+)

gen     aedu = 0	if  nivel_educ==1 | nivel_educ==2
replace aedu = 0	if  nivel_educ==3 & a_educ==0
replace aedu = 1	if  nivel_educ==3 & a_educ==1
replace aedu = 2	if  nivel_educ==3 & a_educ==2
replace aedu = 3	if  nivel_educ==3 & a_educ==3
replace aedu = 4	if  nivel_educ==3 & a_educ==4
replace aedu = 5	if  nivel_educ==3 & a_educ==5
replace aedu = 6	if  nivel_educ==3 & a_educ==6
replace aedu = 6	if  nivel_educ==4 & a_educ==0

replace aedu = 7	if  nivel_educ==4 & a_educ==1
replace aedu = 8	if  nivel_educ==4 & a_educ==2
replace aedu = 9	if  nivel_educ==4 & a_educ==3
replace aedu = 10	if  nivel_educ==4 & a_educ==4
replace aedu = 11	if  nivel_educ==4 & a_educ==5
replace aedu = 12	if  nivel_educ==4 & a_educ==6
replace aedu = 12	if  nivel_educ==5 & s_educ==1
replace aedu = 12	if  nivel_educ==6 & s_educ==1
	 
replace aedu = 13	if  nivel_educ==5 & (s_educ==2 | s_educ==3)
replace aedu = 14	if  nivel_educ==5 & (s_educ==4 | s_educ==5)
replace aedu = 15	if  nivel_educ==5 & (s_educ==6 | s_educ==7)
replace aedu = 16	if  nivel_educ==5 & (s_educ==8 | s_educ==9)
replace aedu = 17	if  nivel_educ==5 &  s_educ==10
               
replace aedu = 13	if  nivel_educ==6 & (s_educ==2 | s_educ==3)
replace aedu = 14	if  nivel_educ==6 & (s_educ==4 | s_educ==5)
replace aedu = 15	if  nivel_educ==6 & (s_educ==6 | s_educ==7)
replace aedu = 16	if  nivel_educ==6 & (s_educ==8 | s_educ==9)
replace aedu = 17	if  nivel_educ==6 & (s_educ==10 | s_educ==11)
replace aedu = 18	if  nivel_educ==6 &  s_educ==12

replace aedu = 17   if  nivel_educ==7 &  s_educ==1 //consideramos promedio de educacion superior 5 anos 
replace aedu = 18   if  nivel_educ==7 &  (s_educ==2 | s_educ==3)
replace aedu = 19	if  nivel_educ==7 & (s_educ==4 | s_educ==5)
replace aedu = 20	if  nivel_educ==7 & (s_educ==6 | s_educ==7)
replace aedu = 21	if  nivel_educ==7 & (s_educ==8 | s_educ==9)
replace aedu = 22	if  nivel_educ==7 & (s_educ==10 | s_educ==11)
replace aedu = 23	if  nivel_educ==7 &  s_educ==12
notes aedu: variable defined for individuals aged 3 and older
*brow id pid nivel_educ a_educ s_educ if nivel_educ!=. & aedu==. // se pierden obs que reportan nivel_educ, pero no reportan a_educ o s_educ

* Nivel educativo: nivel // SE PIERDEN OBSERVACIONES DEBIDO A MISSING VALUES IN A_EDUC Y S_EDUC
/*   0 = Nunca asistió      
     1 = Primario incompleto
     2 = Primario completo   
	 3 = Secundario incompleto
     4 = Secundario completo 
	 5 = Superior incompleto 
     6 = Superior completo						
*/
gen     nivel = 0	if  nivel_educ==1 | nivel_educ==2
replace nivel = 1	if  nivel_educ==3 & a_educ<=5
replace nivel = 2	if  nivel_educ==3 & a_educ==6 
replace nivel = 3	if  nivel_educ==4 & a_educ<=5
replace nivel = 4	if  nivel_educ==4 & a_educ==6
replace nivel = 5   if (nivel_educ==5 & s_educ<=5) | (nivel_educ==6 & s_educ<=9) // consideramos técnica completa si completo  al menos 6 semestres y universitaria completa si completo al menos 10 semestres
replace nivel = 6   if (nivel_educ==5 & s_educ>=6 & s_educ!=.) | (nivel_educ==6 & s_educ>=10 & s_educ!=.) | nivel_educ==7
notes nivel: variable defined for individuals aged 3 and older

label def nivel 0 "Nunca asistio" 1 "Primario Incompleto" 2 "Primario Completo" 3 "Secundario Incompleto" 4 "Secundario Completo" ///
                5 "Superior Incompleto" 6 "Superior Completo"
label value nivel nivel

* Nivel educativo: niveduc
/*   1 = baja educacion  (menos de 9 años)      
     2 = media educacion (de 9 a 13 años)
     3 = alta educacion  (mas de 13 años) //DONDE SE INCLUYE EL 13?
*/

gen nivedu = 1 if aedu<9
replace nivedu = 2 if aedu>=9 & aedu<=13
replace nivedu = 3 if aedu>13 & aedu!=.

*label def nivedu 1 "Baja educacion (menos de 9 años)" 2 "Media educacion (de 9-12 años)" 3 "Alta educacion (mas de años)"
*label value nivedu nivedu

* Dummies nivel educativo
gen     prii = (nivel==0 | nivel==1) if nivel!=.
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

* Seguro de salud: seguro_salud
/* AFILIADO_SEGURO_SALUD (sp29_1): ¿está afiliado a algún seguro medico?
        1 = Instituto Venezolano de los Seguros Sociales (IVSS)
	    2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
	    3 = Seguro medico contratado por institucion publica
	    4 = Seguro medico contratado por institucion privada
	    5 = Seguro medico privado contratado de forma particular
	    6 = No tiene plan de seguro de atencion medica
	    99 = NS/NR
*/

gen afiliado_seguro_salud = 1     if sp29_1==1 
replace afiliado_seguro_salud = 2 if sp29_1==2 
replace afiliado_seguro_salud = 3 if sp29_1==3 
replace afiliado_seguro_salud = 4 if sp29_1==4
replace afiliado_seguro_salud = 5 if sp29_1==5
replace afiliado_seguro_salud = 6 if sp29_1==6
replace afiliado_seguro_salud = . if sp29_1==99

gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6

* Tipo de seguro de salud: tipo_seguro
/*      0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
        1 = si esta afiliado a algun seguro de salud privado
*/
gen 	tipo_seguro = 0     if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=4
replace tipo_seguro = 1     if  afiliado_seguro_salud==5 //SOLO 5 o 4 y 5?

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

* Control durante el embarazo: control_embarazo /
gen     control_embarazo = .
notes control_embarazo: the survey does not include information to define this variable

* Lugar control del embarazo: lugar_control_embarazo
gen     lugar_control_embarazo = .
notes lugar_control_embarazo: the survey does not include information to define this variable

* Lugar parto: lugar_parto
gen     lugar_parto= .
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
gen    enfermo = .
notes enfermo: the survey does not include information to define this variable
// solo pregunta por diabetes y hipertension y el resto de las preguntas de salud
// dependen solamente de estas dos dolencias

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
gen    visita = .
notes visita: the survey does not include information to define this variable

* ¿Por qué no consulto al médico?: razon_no_medico
/*     1 = si no consulto al médico por razones economicas
       0 = si no consulto al médico por razones no economicas
*/
gen    razon_no_medico = .
notes razon_no_medico: the survey does not include information to define this variable

* Lugar de ultima consulta: lugar_consulta
/*     1 = si el lugar de la ultima consulta es privado
       0 = si el lugar de la ultima consulta es publico o vinculado al trabajo
*/
gen    lugar_consulta = .
notes lugar_consulta: the survey does not include information to define this variable

* Pago de la ultima consulta: pago_consulta
/*     1 = si el pago de la ultima consulta fue privado
       0 = si el pago de la ultima consulta es publico o vinculado al trabajo
*/
gen    pago_consulta = .
notes pago_consulta: the survey does not include information to define this variable

* Tiempo que tardo en llegar al medico medido en horas: tiempo_consulta
gen    tiempo_consulta = .
notes tiempo_consulta: the survey does not include information to define this variable

* ¿Obtuvo remedios prescriptos?: obtuvo_remedio
/*     1 = si obtuvo medicamentos prescriptos
       0 = si no obtuvo medicamentos prescriptos
*/
gen    obtuvo_remedio = .
notes obtuvo_remedio: the survey does not include information to define this variable

* ¿Por que no obtuvo remedios prescriptos?: razon_no_remedio
/*     1 = si no obtuvo remedios por razones economicas
       0 = si no obtuvo remedios por otras razones
*/
gen    razon_no_remedio = .
notes razon_no_remedio: the survey does not include information to define this variable

* ¿Fuma?: fumar
/*     1 = si fuma o fumo alguna vez
       0 = si nunca fumo
// ¿Cuantos cigarrillos consume diariamente: (sp35)

1	Ninguno.
2	Menos de 10 cigarrillos.
3	Entre 10 y 20 cigarrillos.
4	Mas de 20 cigarrillos
98	No aplica
99	NS/NR.
*/
gen    fumar = (sp35>1 & sp35<98) if (sp35!=98 & sp35!=999)
notes fumar: the variable is not completely comparable

* ¿Hace deporte regularmente?: deporte
* ¿Hace deporte regularmente?: deporte
/*     1 = si hace deporte regularmente (1 vez por semana)
       0 = si no hace deporte regularmente
* ACTIVIDAD_FISICA (cep89fm,cep89fm): ¿En un dia promedio, cuanto tiempo dedica usted a actividad fisica?
*/
gen actividad_fisica = cep89fh*60+cep89fm if (cep89fh!=98 & cep89fh!=99) & (cep89fm!=98 & cep89fm!=99)
gen deporte = (actividad_fisica >=20) if actividad_fisica!=.
gen embarazada=.
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

* LABOR_STATUS (tp45): La semana pasada estaba:
        1 = Trabajando
		2 = No trabajo', pero tiene trabajo
		3 = Buscando trabajo por primera vez
		4 = Buscando trabajo habiendo trabajado antes
		5 = En quehaceres del hogar
		6 = Estudiando
		7 = Pensionado
		8 = Incapacitado
		9 = Otra situacion
		98 = No aplica
		99 = NS/NR

* CATEG_OCUP (tp49): En su trabajo se desempena como
        1 = Empleado en el sector publico
		2 = Obrero en el sector publico
		3 = Empleado en empresa privada
		4 = Obrero en empresa privada
		5 = Patrono o empleador
		6 = Trabajador por cuenta propia
		7 = Miembro de cooperativas
		8 = Ayudante familiar remunerado/no remunerado
		9 = Servicio domestico
		98 = No aplica
		99 = NS/NR
*/
gen labor_status = tp45 if (tp45!=98 & tp45!=99)
gen categ_ocu = tp49    if (tp49!=98 & tp49!=99)
gen     relab = .
replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  // Employer 
replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee - Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==8)  // Self-employed
replace relab = 4 if (labor_status==1 | labor_status==2) & categ_ocu== 8 & (tp50m!=98 | tp50m!=99) //unpaid family worker
replace relab = 5 if (labor_status==3 | labor_status==4)
replace relab = 2 if (labor_status==1 | labor_status==2) & categ_ocu== 8 & (tp50m>=1 & tp50m!=98 & tp50m!=99) //move paid family worker to employee

gen relab_s =.
gen relab_o =.

* Duracion del desempleo: durades (en meses)
gen     durades = . 
notes durades: the survey does not include information to define this variable

* Horas trabajadas totales y en ocupacion principal: hstrt y hstrp
* NHORAST (tp54): ¿Cuantas horas en promedio trabajo la semana pasada? 
gen nhorast = tp54 if (tp54!=98 & tp54!=99)
gen      hstrt = .
replace  hstrt = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

gen      hstrp = .
replace hstrp = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.) 

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
/* DMASHORAS (tp56): ¿Preferiria trabajar mas de 30 horas por semana?
   BMASHORAS (tp57): ¿Ha hecho algo para trabajar mas horas?
   CAMBIO_EMPLEO (tp59):  ¿ Ha cambiado de trabajo durante los 12 ultimos meses?
*/
gen dmashoras = tp56     if (tp56!=98 & tp56!=99)
gen bmashoras = tp57      if (tp57!=98 & tp57!=99)
gen cambio_empleo = tp59  if (tp59!=98 & tp59!=99)
gen     deseamas = 0 if (relab>=1 & relab<=4)
replace deseamas = 1 if dmashoras==1 | bmashoras == 1

* Antiguedad: antigue
gen     antigue = .
notes antigue: the survey does not include information to define this variable

* Asalariado en la ocupacion principal: asal
gen     asal = (relab==2) if (relab>=1 & relab<=4)

* Tipo de empresa: empresa 
/*      1 = Empresa privada grande (mas de cinco trabajadores)
        2 = Empresa privada pequena (cinco o menos trabajadores)
		3 = Empresa publica
* FIRM_SIZE (tp48): Contando a ¿cuantas personas trabajan en el establecimiento o lugar en el que trabaja?
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
gen firm_size = tp48 if (tp48!=98 & tp48!=99)
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
* SECTOR_ENCUESTA (cod47): ¿A que se dedica el negocio, organismo o empresa en la que trabaja?
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
****************************************************
IMPORTANTE ARREGLAR SECTORES Y TAREAS		
****************************************************
		*/
destring cod47 cod46, replace
clonevar sector_encuesta = cod47 if (cod47!=98 & cod47!=99)

gen     sector1d = .
notes sector1d: the survey does not include information to define this variable

gen     sector= .
notes sector1d: the survey does not include information to define this variable
/*
gen     sector8= 1  if (relab>=1 & relab<=4) & sector_encuesta==1 // Actividades agricolas y ganaderas
replace sector8 = 2 if (relab>=1 & relab<=4) & sector_encuesta==2 // Minas
replace sector8 = 3 if (relab>=1 & relab<=4) & sector_encuesta==3 // Manufactura
replace sector8 = 4 if (relab>=1 & relab<=4) & sector_encuesta==5 // Construccion
replace sector8 = 5 if (relab>=1 & relab<=4) & sector_encuesta==6 // Comercio
replace sector8 = 6 if (relab>=1 & relab<=4) & (sector_encuesta==4 | sector_encuesta==7) // Electricidad, agua, gas, transporte y comunicaciones
replace sector8 = 7 if (relab>=1 & relab<=4) & sector_encuesta==8 // Entidades financieras
replace sector8 = 8 if (relab>=1 & relab<=4) & (sector_encuesta==9 | sector_encuesta==10) // otros servicios
*/

* Tarea que desempena: tarea
/* TAREA (): ¿Cual es el oficio o trabajo que realiza?
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
gen     tarea = cod46 if (cod46!=98 & cod46!=99)
label def tarea 1 "Oficiales de las fuerzas armadas" 2 "Otros miembros de las fuerzas armadas"  3 "Otros miembros de las fuerzas armadas" ///
		11 "Directores ejecutivos, personal directi" 12 "Directores ejecutivos, personal directi" 13 "Directores ejecutivos, personal directi" 14 "Gerentes de hoteles, restaurantes, come" ///
		21 "Profesionales de las ciencias y de la i" 25 "Profesionales de las ciencias y de la i" 22 "Profesionales de la salud" ///
		23 "Profesionales de la enseñanza" 24 "Especialistas en organización de la adm" ///
		26 "Profesionales en derecho, en ciencias s" 31 "Profesionales de las ciencias y la inge" ///	
		32 "Profesionales de nivel medio de la salu" 33 "Profesionales de nivel medio en operaci" ///
		34 "Profesionales de nivel medio de servici" 35 "Técnicos de la tecnología de la informa" ///
		41 "Oficinistas" 42 "Empleados en trato directo con el públi" ///
		43 "Empleados contables y encargados del re" 44 "Otro personal de apoyo administrativo" ///
		51 "Trabajadores de los servicios personale" 52 "Vendedores" ///
		53 "Trabajadores de los cuidados personales" 54 "Personal de los servicios de protección" ///
		61 "Agricultores y trabajadores calificados" 62 "Trabajadores forestales calificados, pe" ///
		63 "Trabajadores agropecuarios, pescadores" 71 "Oficiales y operarios de la construcció" ///
		72 "Oficiales y operarios de la metalurgia" 73 "Artesanos y operarios de las artes gráf" ///
		74 "Trabajadores especializados en electric" 75 "Operarios y oficiales de procesamiento" ///
		81 "Operadores de instalaciones fijas y máq" 82 "Conductores de vehículos y operadores d" 83 "Conductores de vehículos y operadores d" ///
		91 "Limpiadores y asistentes" 92 "Peones agropecuarios, pesqueros y fores" ///
		93 "Peones de la minería, la construcción" 94 "Ayudantes de preparación de alimentos" ///
		95 "Recolectores de desechos y otras ocupac" 96 "Recolectores de desechos y otras ocupac" 98 "No aplica" ///
		99 "NS/NR" 999 "No clasificable"
label value tarea tarea
 
* Caracteristicas del empleo y acceso a beneficios a partir del empleo
* Trabajador con contrato:  contrato (definida para trabajadores asalariados)
/* CONTRATO_ENCUESTA (tp52): ¿En su trabajo, tienen contrato?
        1 = Formal (contrato firmado por tiempo indefinido)
		2 = Formal (contrato firmado por tiempo determinado)
		3 = Acuerdo verbal? 
		4 = No tiene contrato
		98 = No aplica 
		99 = NS/NR
*/
clonevar contrato_encuesta = tp52 if (tp49!=98 & tp49!=99)
gen     contrato = 1 if relab==2 & (contrato_encuesta== 1 | contrato_encuesta==2)
replace contrato = 0 if relab==2 & (contrato_encuesta== 3 | contrato_encuesta==4)

* Ocupacion permanente
gen     ocuperma = (contrato_encuesta==1) if relab==2 

* Derecho a percibir una jubilacion: djubila
gen    djubila = (pp65==1) if relab==2 & (pp65!=98 & pp65!=.) //tomo si realiza aportes a fondo de pension publico o privado

* Seguro de salud ligado al empleo: dsegsale
gen     dsegsale = (afiliado_seguro_salud==3 | afiliado_seguro_salud==4) if relab==2 

* Derecho a aguinaldo: aguinaldo
gen     aguinaldo = .
notes aguinaldo: the survey does not include information to define this variable

* Derecho a vacaciones pagas: dvacaciones
gen     dvacaciones = tp53v==1 if ((tp53v!=98 & tp53v!=99) & relab==2) 

* Sindicalizado: sindicato
gen     sindicato = tp53s==1 if ((tp53s!=98 & tp53s!=99) & relab==2) 

* Programa de empleo: prog_empleo //si el individuo está trabajando en un plan de empleo publico
gen     prog_empleo = .
notes prog_empleo: the survey does not include information to define this variable

* Empleado:	ocupado
rename  ocupado ocupado_encuesta
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
tab tp50m tp50 //OK!

* Situacion laboral y recepcion de ingresos
tab tp45 tp50 //
/*
                      | �Cu�nto recibi�... En total durante el mes
     La semana pasada |    pasado como ingreso por el trabajo r
              estaba: | Si recibi  No recibi  No aplica      NS/NR |     Total
----------------------+--------------------------------------------+----------
         �Trabajando? |     1,901         40          0         78 |     2,019 
�No trabaj� pero tien |       141         15          0         14 |       170 
�Buscando trabajo por |         0          0         43          0 |        43 
�Buscando trabajo hab |         0          0        168          0 |       168 
�En quehaceres del ho |         0          0        955          0 |       955 
         �Estudiando? |         0          0        786          0 |       786 
         �Pensionado? |         0          0        238          0 |       238 
       �Incapacitado? |         0          0         79          0 |        79 
     �Otra situaci�n? |         0          0        333          0 |       333 
            No aplica |         0          0      1,136          0 |     1,136 
               NS/NR. |         0          0         18          0 |        18 
----------------------+--------------------------------------------+----------
                Total |     2,042         55      3,756         92 |     5,945 
*/

/* Esto implica que no deberiamos preocuparnos por los que NA cuando 
vemos la tabla de ingresos ya que los que NA son casi los mismos que figuran en 
la misma categoria luego */

* Se reemplazan como missing NR y NA
replace tp50m = . if tp50m==99 // Cedlas clasifica la NR como missing
replace tp50m = . if tp50m==98 // Los NA como missing?? VER

/*  Solo se incluyen ingresos monetarios
La variable tp50 identifica a los que recibieron ingresos laborales
La variable tp50m menciona los montos recibidos en el mes anterior a la encuesta

ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia*/

*****  i)  PATRON
* Monetario	
* Ingreso monetario laboral de la actividad principal si es patrón
gen     ipatrp_m = tp50m if relab==1  

* No monetario
gen     ipatrp_nm = .	
notes ipatrp_nm: the survey does not include information to define this variable 


****  ii)  ASALARIADOS
* Monetario	
* Ingreso monetario laboral de la actividad principal si es asalariado
gen     iasalp_m = tp50m if relab==2

* No monetario
gen     iasalp_nm = .
notes iasalp_nm: the survey does not include information to define this variable 


***** iii)  CUENTA PROPIA
* Monetario	
* Ingreso monetario laboral de la actividad principal si es cuenta propia
gen     ictapp_m = tp50m if relab==3

* No monetario
gen     ictapp_nm = .
notes ictapp_nm: the survey does not include information to define this variable 

***** IV)otros
gen iolp_m = tp50m if relab==4
gen iolp_nm=.

****** 9.2.INGRESO LABORAL SECUNDARIO ******
*No se distingue

* Monetario	
gen     ipatrnp_m = .
gen     iasalnp_m = .
gen     ictapnp_m = .
gen     iolnp_m=.
notes ipatrnp_m: the survey does not include information to define this variable 
notes iasalnp_m: the survey does not include information to define this variable 
notes ictapnp_m: the survey does not include information to define this variable 
notes iolnp_m: the survey does not include information to define this variable


* No monetario
gen     ipatrnp_nm = .
gen     iasalnp_nm = .
gen     ictapnp_nm = .
gen     iolnp_nm = .
notes ipatrnp_nm: the survey does not include information to define this variable 
notes iasalnp_nm: the survey does not include information to define this variable 
notes ictapnp_nm: the survey does not include information to define this variable 
notes iolnp_nm: the survey does not include information to define this variable

****** 9.3.INGRESO NO LABORAL ******
/* MONTOS RELEVANTES: tp51m y pp63*m

Incluye 
	1) jubilaciones y pensiones ---> pp63*m
	2) ingresos de capital ------> tp51m
	3) transferencias privadas y estatales ------> tp51m
*/

/* Es necesario construir categorias para Ingresos no laborales a partir de la encuesta 
   dado que hay una unica categoria donde se reportan todos los ingresos*/
/*
gen     ing_nlb = .
replace ing_nlb = 1  if tp51ps==1 // Pensión por sobreviviente, orfandad
replace ing_nlb = 2  if tp51ay==2 // Ayuda familiar o de otra persona
replace ing_nlb = 3  if tp51ss==3 // Pension por seguro social
replace ing_nlb = 4  if tp51jv==4 // Jubilación por trabajo
replace ing_nlb = 5  if tp51rp==5 // Renta por priopiedades
replace ing_nlb = 6  if tp51id==6 // Intereses o dividendos
replace ing_nlb = 7  if tp51ot==7 // Otros
*/

gen ing_nlb_ps= 1  if  tp51ps==1 // Pensión por sobreviviente, orfandad
gen ing_nlb_ay = 1  if tp51ay==2 // Ayuda familiar o de otra persona
gen ing_nlb_ss = 1  if tp51ss==3 // Pension por seguro social
gen ing_nlb_jv = 1  if tp51jv==4 // Jubilación por trabajo
gen ing_nlb_rp = 1  if tp51rp==5 // Renta por priopiedades
gen ing_nlb_id = 1  if tp51id==6 // Intereses o dividendos
gen ing_nlb_ot = 1  if tp51ot==7 // Otros

*Cuantas categorias de ingresos reciben
egen    recibe = rowtotal(ing_nlb_*), mi
tab recibe 
*** Cuantas personas reciben distintos tipos de ingreso no laboral en 2015?
/*
. tab recibe

     recibe |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      5,839       98.22       98.22
          1 |        104        1.75       99.97
          2 |          2        0.03      100.00
------------+-----------------------------------
      Total |      5,945      100.00
*/


****** 9.3.1.JUBILACIONES Y PENSIONES ******	  
/*
pp63*m // Monto recibido por jubilacion o pension  de IVSS, pública o privada
pp63sm // monto por IVSS
pp63em // monto por otra institucion publica
pp63pm // monto por otra institucion publica
pp63om // monto por otra institucion publica
*/
*Se reemplazan como missing NR y NA
replace tp51m  = . if (tp51m==99 | tp51m==98)

*Jubilaciones y pensiones
* Monetario
* ijubi_m: Ingreso monetario por jubilaciones y pensiones	

clonevar jubi_encuesta_ss = pp63sm if pp63sm!=99 & pp63sm!=98 & pp63sm!=. 
clonevar jubi_encuesta_ep = pp63em if pp63em!=99 & pp63em!=98 & pp63em!=. 
clonevar jubi_encuesta_pr = pp63pm if pp63pm!=99 & pp63pm!=98 & pp63pm!=. 
clonevar jubi_encuesta_ot = pp63om if pp63om!=99 & pp63om!=98 & pp63om!=. 

egen ijubi_m = rowtotal(jubi_encuesta_ss jubi_encuesta_ep jubi_encuesta_pr jubi_encuesta_ot), mi
replace ijubi_m = tp51m if ijubi_m==. &  (ing_nlb_ps==1 | ing_nlb_jv==1) & recibe==1

// medido en BSF

* No monetario	
gen     ijubi_nm=.
notes ijubi_nm: the survey does not include information to define this variable 

****** 9.3.2.INGRESOS DE CAPITAL ******	
/*icap_m: Ingreso monetario de capital, intereses, alquileres, rentas, beneficios y dividendos*/
gen     icap_m = .
replace icap_m = tp51m if (ing_nlb_ps!=1 & ing_nlb_ay!=1 & ing_nlb_ss!=1 & ing_nlb_jv!=1 & ing_nlb_ot!=1) & (ing_nlb_rp == 1 | ing_nlb_id == 1)  & recibe==1 
gen     icap_nm = .

****** 9.3.3.REMESAS ******	
/*rem: Ingreso monetario de remesas */
gen     rem = .
notes rem: the survey does not include information to define this variable 

****** 9.3.4.TRANSFERENCIAS PRIVADAS ******	
/*TMHP52EF=4 // Ayuda económica de algún familiar o de otra persona en el país
itranp_o_m Ingreso monetario de otras transferencias privadas diferentes a remesas*/
gen     itranp_o_m = .
notes itranp_o_m: the survey does not include information to define this variable 
gen     itranp_o_nm = .

****** 9.3.5.TRANSFERENCIAS PRIVADAS ******	
*itranp_ns: Ingreso monetario de transferencias privadas, cuando no se puede distinguir entre remesas y otras
gen     itranp_ns = .
replace itranp_ns = tp51m if (ing_nlb_ps!=1 & ing_nlb_ay == 1 & ing_nlb_ss!=1 & ing_nlb_jv!=1 & ing_nlb_ot!=1 & ing_nlb_rp!=1 & ing_nlb_id!=1)

****** 9.3.6.TRANSFERENCIAS ESTATALES ******	
*HASTA AHORA SOLO SE PUEDEN ENCONTRAR BENEFICIARIOS PERO los montos HABRIA QUE IMPUTARLOS
*cct: Ingreso monetario por transferencias estatales relacionadas con transferencias monetarias condicionadas
*itrane_o_m Ingreso monetario por transferencias estatales diferentes a las transferencias monetarias condicionadas
*itrane_o_nm Ingreso no monetario por transferencias estatales
*itrane_ns Ingreso monetario por transferencias cuando no se puede distinguir
gen     cct = .
gen     itrane_o_m = .
gen     itrane_o_nm = .
gen     itrane_ns = .

***** iV) OTROS INGRESOS NO LABORALES 
gen inla_otro=tp51m if (ing_nlb_ps!=1 & ing_nlb_ay!=1 & ing_nlb_ss==1 & ing_nlb_jv!=1 & ing_nlb_ot==1 & ing_nlb_rp!=1 & ing_nlb_id!=1) | (recibe>=2 & recibe!=.)


/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.10: LINEAS DE POBREZA  -------------------------------------------------------------
************************************************************************************************************************************************)*/

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
*rename Pobreza pobreza
gen     pobreza_enc = (pobreza_max==1 | pobreza_max==2) if pobreza_max!=99
gen     pobreza_extrema_enc = (pobreza_max==2) if pobreza_max!=99
tab pobreza_enc [aw=pondera]
/*
pobreza_enc |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 1,325.0373       24.41       24.41
          1 | 4,103.9627       75.59      100.00
------------+-----------------------------------
      Total |      5,429      100.00
*/

/************************************************************************************************************************************************* 
*---------------------------------------------------------------- 1.1: PRECIOS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/

* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .

* IPC del mes base
gen ipc = 13687.52	/*  MES BASE: promedio Enero-Diciembre			*/

gen cpiperiod = "2015m01-2015m12"

gen     ipc_rel = 1
*replace ipc_rel = 1    if  mes==1
*replace ipc_rel = 1	if  mes==2
*replace ipc_rel = 1	if  mes==3
*replace ipc_rel = 1	if  mes==4
*replace ipc_rel = 1    if  mes==5
*replace ipc_rel = 1	if  mes==6
*replace ipc_rel = 1	if  mes==7
*replace ipc_rel = 1	if  mes==8
*replace ipc_rel = 1	if  mes==9
*replace ipc_rel = 1	if  mes==10
*replace ipc_rel = 1	if  mes==11
*replace ipc_rel = 1    if  mes==12

* Ajuste por precios regionales: se ajustan los ingresos rurales por 0.8695 
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
*include "$aux_do\do_file_renta_implicita.do"

* Renta imputada
gen aux_propieta_no_paga = 1 if tenencia_vivienda==1|(tenencia_vivienda==8 & codhp22o==6)
replace aux_propieta_no_paga = 0 if (tenencia_vivienda>=2 & tenencia_vivienda<=5)| (tenencia_vivienda>=7)
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
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector /*sector_encuesta*/ tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 /*ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/  

keep pais ano encuesta id com pondera strata psu relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua ///
region_est1 region_est2 region_est3 cen lla ceo zul and nor isu gua capital urbano migrante migra_ext migra_rur anios_residencia migra_rec ///
propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici ///
alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp ///
seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector /*sector_encuesta*/ tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap  itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i /*ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/

save "$dataout\base_out_nesstar_cedlas_2015.dta", replace 

