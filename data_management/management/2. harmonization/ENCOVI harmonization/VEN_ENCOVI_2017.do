/*===========================================================================
Country name:		Venezuela
Year:			2018
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

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
local year     "2017"   // Year of the survey
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
use "$data2017\VACUNACIÓN.dta", clear
rename LINVACU LIN
tempfile vacu
save `vacu'
use "$data2017\PERSONAS_ENCOVI_2017.dta", clear
rename ennumc ENNUMC
merge m:1 ENNUMC using "$data2017\HOGARES_ENCOVI2017.dta"
drop _merge
merge 1:1 ENNUMC LIN using `vacu'  //UNA OBS EN VACUNACION Y NO EN PERSONAS (TODO MISSING)
drop if _merge==2
tab CMHP18 if _merge==3 //cuatro observacions con edad mayor a 2
*brow if _merge==3 & CMHP18>2
drop _merge
/*
merge 1:1 ENNUM LIN using "$data2017\EMIGRACIÓN2017.dta" 
drop _merge
*/
rename _all, lower

*Incluyo las regiones de archivos 2017

preserve
use "$data2017\region_merge.dta", clear
rename LIN lin
tempfile region
save `region'
restore
merge m:1 ennumc lin using `region'
drop _merge  

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables  --------------------------------------------------
*************************************************************************************************************************************************)*/

* Country identifier: country
gen country = "VEN"

* Year identifier: year
capture drop year
gen year = 2017

* Survey identifier: survey
gen survey = "ENCOVI - 2017"

* Household identifier: id      
gen id = ennum

* Component identifier: com
gen com  = lin
duplicates report id com

gen double pid = lin
notes pid: original variable used was: lin

* Weights: pondera
gen pondera = pesopersona  //round(pesopersona)

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
* RELACION_EN (cmhp17): Variable identifying the relation to the head in the survey
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
clonevar relacion_en = cmhp17
gen     reltohead = 1		if  relacion_en==1
replace reltohead = 2		if  relacion_en==2
replace reltohead = 3		if  relacion_en==3  | relacion_en==4
replace reltohead = 4		if  relacion_en==5  
replace reltohead = 5		if  relacion_en==6 
replace reltohead = 6		if  relacion_en==7
replace reltohead = 7		if  relacion_en==8  
replace reltohead = 8		if  relacion_en==9
replace reltohead = 9		if  relacion_en==10
replace reltohead = 10		if  relacion_en==11
replace reltohead = 11		if  relacion_en==12
replace reltohead = 12		if  relacion_en==13

label def reltohead 1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" 4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)" ///
		            6 "Padre, madre" 7 "Hermano(a)" 8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" 12 "Servicio Domestico"	
label value reltohead reltohead

* Identificador de hogares: hogar
gen hogar = (reltohead==1)	

* Miembros de hogares secundarios (seleccionando personal doméstico): hogarsec 
gen hogarsec =.
replace hogarsec =1 if relacion_en==13
replace hogarsec =0 if inrange(relacion_en, 1,12)

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
/* SEXO (cmhp19): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
gen sex = cmhp19
label define sex 1 "Male" 2 "Female"
label value sex sex

* Age
* EDAD_ENCUESTA (cmhp18): Cuantos años cumplidos tiene?
gen     age = cmhp18
notes   age: range of the variable: 0-100

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

* Identificador de miembros del hogar
gen     jefe = (reltohead==1)
gen     conyuge = (reltohead==2)
gen     hijo = (reltohead==3)

* Numero de hijos menores de 18
tempvar aux
gen `aux' = (hijo==1 & age<=18)
egen      nro_hijos = count(`aux'), by(id)
replace   nro_hijos = .  if  jefe!=1 & conyuge!=1

* Marital status
/* ESTADO_CIVIL_ENCUESTA (cmhp22): Cual es su situacion conyugal
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
gen estado_civil_encuesta = cmhp22 if (cmhp22!=98 & cmhp22!=99)
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
gen     children_born_alive = cmhp26 if (cmhp26!=98 & cmhp26!=99)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     children_alive = cmhp27 if cmhp26!=0 & cmhp27<=cmhp26 & (cmhp27!=98 & cmhp27!=99)
;
/*(*************************************************************************************************************************************************
*-------------------------------------------------------------	1.3: Regional variables  ---------------------------------------------------------
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
gen     region_est1 =  1 if enti==5 | enti==8 | enti==9                //Region Central
replace region_est1 =  2 if enti==12 | enti==4                         // Region de los LLanos
replace region_est1 =  3 if enti==11 | enti==13 | enti==18 | enti==22  // Region Centro-Occidental
replace region_est1 =  4 if enti==23                                   // Region Zuliana
replace region_est1 =  5 if enti==6 | enti==14 | enti==20 | enti==21   // Region de los Andes
replace region_est1 =  6 if enti==3 | enti==16 | enti==19              // Region Nor-Oriental
replace region_est1 =  7 if enti==17 | enti==25                        // Region Insular
replace region_est1 =  8 if enti==7 | enti==2 | enti==10               // Region Guayana
replace region_est1 =  9 if enti==15 | enti==24 | enti==1              // Region Capital

label def region_est1 1 "Region Central"  2 "Region de los LLanos" 3 "Region Centro-Occidental" 4 "Region Zuliana" ///
          5 "Region de los Andes" 6 "Region Nor-Oriental" 7 "Insular" 8 "Guayana" 9 "Capital"
label value region_est1 region_est1

* Desagregación 2 (Estados): region_est2
clonevar region_est2 = enti

* Desagregación 3 (Municipio): region_est3
*clonevar region_est3 = muni
gen       region_est3 = .

* Dummy urbano-rural: urbano  //REVISAR SI SE PUEDE CONSTRUIR ESTA VARIABLE
/* : area de residencia
		 1 = urbana  
		 2 = rural								

gen     urbano = 1		if  zona==1
replace urbano = 0		if  zona==2
*/
gen     urbano = .						 
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

* Areas no incluidas en años previos:	nuevareg
gen       nuevareg=.

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/

* Propiedad de la vivienda:	propieta
/* TENENCIA_VIVIENDA (hp15): régimen de tenencia de la vivienda 
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

destring (hp15ot_cod), replace
clonevar tenencia_vivienda = hp15 if (hp15!=98 & hp15!=99)
gen     propieta = 1		if  tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==6
replace propieta = 1        if  tenencia_vivienda==8 & hp15ot_cod==1
replace propieta = 0		if  tenencia_vivienda==3 | tenencia_vivienda==4 | tenencia_vivienda==5 | tenencia_vivienda==7 | (tenencia_vivienda==8 & hp15ot_cod==4)
replace propieta = .		if  relacion!=1

* Habitaciones, contando baño y cocina: habita 
gen     habita = .
notes   habita: the survey does not include information to define this variable

* Dormitorios de uso exclusivo: dormi
* NDORMITORIOS (dhp10): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormitorios = dhp10 if (dhp10!=98 & dhp10!=99)
gen     dormi = ndormitorios 
replace dormi =. if relacion!=1
 
* Vivienda en lugar precario: precaria
/* TIPO_VIVIENDA (vsp4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
*/
clonevar tipo_vivienda = vsp4 if (vsp4!=98 & vsp4!=99)
gen     precaria = 0		if  (tipo_vivienda>=1 & tipo_vivienda<=4) | tipo_vivienda==6
replace precaria = 1		if  tipo_vivienda==5  | tipo_vivienda==7   
replace precaria = .		if  relacion!=1

* Material de construcción precario: matpreca
/* MATERIAL_PISO (vsp1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
		 5 = Otros		
		 
   MATERIAL_PARED_EXTERIOR (vsp2)
		1 = Bloque, ladrillo frisado	
		2 = Bloque ladrillo sin frisar  
		3 = Concreto	
		4 = Madera aserrada 
		5 = Bloque de plocloruro de vinilo	
		6 = Adobe, tapia o bahareque frisado
		7 = Adobe, tapia o bahareque sin frisado
		8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  

   MATERIAL_TECHO (vsp3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)

   APARIENCIA_VIVIENDA (no se pregunta) 
*/
gen  material_piso = vsp1            if (vsp1!=98 & vsp1!=99)
gen  material_pared_exterior = vsp2  if (vsp2!=98 & vsp2!=99)
gen  material_techo = vsp3           if (vsp3!=98 & vsp3!=99)

gen     matpreca = 0     
replace matpreca = 1		if  material_pared_exterior>=5 & material_pared_exterior<=8 
replace matpreca = 1		if  material_techo==5
replace matpreca = 1		if  material_piso>=3 & material_piso<=5
replace matpreca = .        if  material_piso==. & material_pared_exterior==. & material_techo==.
replace matpreca = .		if  relacion!=1

* Instalacion de agua corriente: agua
/* ACCESO_AGUA (vsp5): A esta vivienda el agua llega normalmente por (no se puede identificar si el acceso es dentro del terreno o vivienda)
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
*/	
gen acceso_agua = vsp5
gen     agua = .
replace agua = 1 if (acceso_agua==1 | acceso_agua==2)
replace agua = 0 if (acceso_agua==3 | acceso_agua==4)
replace agua = 0 if vsp6==5

* Baño con arrastre de agua: banio
/* TIPO_SANITARIO (vsp8): Esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
gen tipo_sanitario = vsp8 if (vsp8!=98 & vsp8!=99)
gen     banio = (tipo_sanitario>=1 & tipo_sanitario<=3) if tipo_sanitario!=.
replace banio = .		if  relacion!=1

* Cloacas: cloacas
gen     cloacas = (tipo_sanitario==1) if tipo_sanitario!=.
replace cloacas = .		if  relacion!=1

* Electricidad en la vivienda: elect
/* SERVICIO_ELECTRICO (vsp7): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe
			5 = No tiene servicio electrico
			99 = NS/NR					
*/
gen servicio_electrico = vsp7 if (vsp7!=98 & vsp7!=99)
gen     elect = (servicio_electrico>=1 & servicio_electrico<=4) if servicio_electrico!=.
replace elect = .		if  relacion!=1

* Teléfono:	telef
* TELEFONO: Si algun integrante de la vivienda tiene telefono fijo o movil
gen	telef =.
notes   telef: the survey does not include information to define this variable

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Bienes durables y servicios --------------------------------------------------------
*************************************************************************************************************************************************)*/

* Heladera (con o sin freezer): heladera
* NEVERA (hp14n): ¿Posee este hogar nevera?
gen nevera = hp14n if (hp14n!=98 & hp14n!=99)
gen     heladera = 0		if  nevera==2
replace heladera = 1		if  nevera==1
replace heladera = .		if  relacion!=1 

* Lavarropas: lavarropas
* LAVADORA (hp14l): ¿Posee este hogar lavadora?
gen lavadora = hp14l if (hp14l!=98 & hp14l!=99)
gen     lavarropas = 0		if  lavadora==2
replace lavarropas = 1		if  lavadora==1
replace lavarropas = .		if  relacion!=1 

* Aire acondicionado: aire
* AIRE_ACONDICIONADO (hp14a): ¿Posee este hogar aire acondicionado?
gen aire_acondicionado = hp14a if (hp14a!=98 & hp14a!=99)
gen     aire = 0		    if  aire_acondicionado==2
replace aire = 1		    if  aire_acondicionado==1
replace aire = .		    if  relacion!=1 

* Calefacción fija: calefaccion_fija
gen     calefaccion_fija = .
notes calefaccion_fija: the survey does not include information to define this variable

* Teléfono fijo: telefono_fijo
gen     telefono_fijo = .
notes telefono_fijo: the survey does not include information to define this variable

* Telefono celular: celular
gen     celular = .
notes   celular: the survey does not include information to define this variable

* Teléfono movil (individual): celular_ind
gen     celular_ind = .
notes   celular_ind: the survey does not include information to define this variable

* Televisor: televisor
* TELEVISOR (hp14t): ¿Posee este hogar televisor?
gen televisor_encuesta = hp14t if (hp14t!=98 & hp14t!=99)
gen     televisor = 0		if  televisor_encuesta==2
replace televisor = 1		if  televisor_encuesta==1
replace televisor = .		if  relacion!=1 

* TV por cable o satelital:		tv_cable
* TVCABLE_ENCUESTA (hp14v): ¿Posee este hogar TV por cable?
gen tvcable_encuesta = hp14v if (hp14v!=98 & hp14v!=99)
gen     tv_cable = 0		if  tvcable_encuesta==2
replace tv_cable = 1		if  tvcable_encuesta==1
replace tv_cable = .		if  relacion!=1 

* VCR o DVD: video 
gen     video = .		
notes   video: the survey does not include information to define this variable

* Computadora: computadora
* COMPUTADOR (hp14c): ¿Posee este hogar computadora?
gen computador = hp14c if (hp14c!=98 & hp14c!=99)
gen     computadora = 0		if  computador==2 
replace computadora = 1		if  computador==1 
replace computadora = .		if  relacion!=1 

* Conexión a Internet en el hogar: internet_casa
* INTERNET (hp14i): ¿Posee este hogar internet?
gen internet = hp14i if (hp14i!=98 & hp14i!=99)
gen     internet_casa = 0	if  internet==2
replace internet_casa = 1	if  internet==1
replace internet_casa = .	if  relacion!=1 

* Uso de Internet: uso_internet
gen   uso_internet = .
notes uso_internet: the survey does not include information to define this variable

* Auto: auto 
* NCARROS (dhp13) : ¿Cuantos carros de uso familiar tiene este hogar?
gen ncarros = dhp13 if (dhp13!=98 & dhp13!=99)
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
/* NIVEL_EDUC (emhp28n): ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
		99 = NS/NR
* A_EDUC (emhp28a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Preescolar, Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* S_EDUC (emhp28a): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
*/
clonevar nivel_educ = emhp28n if (emhp28n!=98 & emhp28n!=99)
gen a_educ = emhp28a     if (emhp28a!=98 & emhp28a!=99)
gen s_educ = emhp28s     if (emhp28s!=98 & emhp28s!=99)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (a_educ>=2 & a_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

* Asiste a la educación formal:	asiste
/* ASISTE_ENCUESTA (emhp29): ¿asiste regularmente a un centro educativo como estudiante? 
        1 = Si
		2 = No
		3 = Nunca asistio
		98 = No aplica
		99 = NS/NR
*/
gen asiste_encuesta = emhp29  if (emhp29!=98 & emhp29!=99)                                             
gen     asiste = 1	if  asiste_encuesta==1 
replace asiste = 0	if  (asiste_encuesta==2 | asiste_encuesta==3)
replace asiste = .  if  edad<3
notes   asiste: variable defined for individuals aged 3 and older

* Establecimiento educativo público: edu_pub
/* TIPO_CENTRO_EDUC (emhp32): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		98 = No aplica
		3 = NS/NR								
*/
gen tipo_centro_educ = emhp32 if (emhp32!=98 & emhp32!=99)
gen     edu_pub = 1	if  tipo_centro_educ==2  
replace edu_pub = 0	if  tipo_centro_educ==1
replace edu_pub = . if  edad<3

* Educación en años: aedu 

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
replace nivel = 5   if  (nivel_educ==5 & s_educ<=5) | (nivel_educ==6 & s_educ<=9) // consideramos técnica completa si completo  al menos 6 semestres y universitaria completa si completo al menos 10 semestres
replace nivel = 6   if  (nivel_educ==5 & s_educ>=6 & s_educ!=.) | (nivel_educ==6 & s_educ>=10 & s_educ!=.) | nivel_educ==7
notes nivel: variable defined for individuals aged 3 and older

label def nivel 0 "Nunca asistio" 1 "Primario Incompleto" 2 "Primario Completo" 3 "Secundario Incompleto" 4 "Secundario Completo" ///
                5 "Superior Incompleto" 6 "Superior Completo"
label value nivel nivel

* Nivel educativo: niveduc
/*   1 = baja educacion  (menos de 9 años)      
     2 = media educacion (de 9 a 13 años)
     3 = alta educacion  (mas de 13 años) //DONDE SE INCLUYE EL 13?
*/
gen     nivedu = 1 if aedu<9
replace nivedu = 2 if aedu>=9 & aedu<=13
replace nivedu = 3 if aedu>13 & aedu!=.
/*
label def nivedu 1 "Baja educacion (menos de 9 años)" 2 "Media educacion (de 9-12 años)" 3 "Alta educacion (mas de 13 años)"
label value nivedu nivedu
*/
* Dummies niveles de educacion
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
/* AFILIADO_SEGURO_SALUD (smhp24a-smhp24g): ¿está afiliado a algún seguro medico?
        1 = Instituto Venezolano de los Seguros Sociales (IVSS)
	    2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
	    3 = Seguro medico contratado por institucion publica
	    4 = Seguro medico contratado por institucion privada
	    5 = Seguro medico privado contratado de forma particular
	    6 = No tiene plan de seguro de atencion medica
	    99 = NS/NR
*/

gen afiliado_seguro_salud = 1     if cmhp25a==1 
replace afiliado_seguro_salud = 2 if cmhp25b==2 
replace afiliado_seguro_salud = 3 if cmhp25c==3 
replace afiliado_seguro_salud = 4 if cmhp25d==4
replace afiliado_seguro_salud = 5 if cmhp25e==5
replace afiliado_seguro_salud = 6 if cmhp25f==6

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

* Control durante el embarazo: control_embarazo //SOLO PARA EMBARAZADAS O TAMBIEN PARA QUIENES TUVIERON HIJOS VIVOS PREVIAMENTE?
/*      1 = si se realizo controles durante el embarazo
        0 = si no se realizo controles durante el embarazo
* LUGAR_CONTROL_EMB (ep98): ¿Donde se controla el embarazo?
        1 = Ambulatorio/clinica popular/CDI
		2 = Hospital/maternidad del sector público
		3 = Consultorio privado sin hospitalización
		4 = Clinica/maternidad del sector privado
		5 = Centro de salud privado sin fines de lucro
		6 = Servicio medico de la empresa o institucion donde trabaja usted o alguien del hogar
		7 = Otro centro de atencion medica
		8 = No se controla el embarazo
		98 = No aplica
		99 NS/NR
*/		
tab hombre ep111 //INCONSISTENCIA APARECEN HOMBRES CONTESTANDO ESTA PREGUNTA
gen embarazada = (ep111==1) if (ep111!=98 & ep111!=99) 
gen hijo_nacido_vivo = ep116 if (ep116!=98 & ep116!=99)
clonevar lugar_control_emb = ep113 if (ep113!=98 & ep113!=99) & embarazada==1
clonevar lugar_controlo_emb = ep121 if (ep121!=98 & ep121!=99) & (embarazada==0 & hijo_nacido_vivo==1)
gen     control_embarazo = 1 if lugar_control_emb>=1 & lugar_control_emb<=7
replace control_embarazo = 1 if lugar_controlo_emb>=1 & lugar_controlo_emb<=7
replace control_embarazo = 0 if lugar_control_emb==8 
replace control_embarazo = 0 if lugar_controlo_emb==8 

* Lugar control del embarazo: lugar_control_embarazo
/*      1 = si el control del embarazo fue en un lugar privado
        0 = si el control del embarazo fue en un lugar publico o vinculado al trabajo (obra social)
*/
gen     lugar_control_embarazo = 1 if  (lugar_control_emb>=3 & lugar_control_emb<=5) | (lugar_controlo_emb>=3 & lugar_controlo_emb<=5)
replace lugar_control_embarazo = 0 if  (lugar_control_emb==1 | lugar_control_emb==2 | lugar_control_emb==6 | lugar_control_emb==7 )
replace lugar_control_embarazo = 0 if  (lugar_controlo_emb==1 | lugar_controlo_emb==2 | lugar_controlo_emb==6 | lugar_controlo_emb==7) // NO ESTOY SEGURA DONDE AGREGAR CATEG 7 

* Lugar del parto: lugar_parto
/*      1 = si el parto fue en un lugar privado
        0 = si el parto fue en un lugar publico o vinculado al trabajo (obra social)
*/
gen     lugar_parto = .
notes lugar_parto: the survey does not include information to define this variable

* ¿Hasta que edad le dio pecho?: tiempo_pecho
/*      1 = si le dio mas de tres meses el pecho
        0 = si el dio menos de 3 meses el pecho
*/
gen    tiempo_pecho = .
notes tiempo_pecho: the survey does not include information to define this variable

* Vacunas
*  ¿Ha recibido vacuna Anti-BCG (contra la tuberculosis): vacuna_bcg
gen    vacuna_bcg = (vp122bg==1) if (vp122bg!=98 & vp122bg!=99) & edad<=2 

*  ¿Ha recibido vacuna Anti-hepatitis B: vacuna_hepatitis
gen    vacuna_hepatitis = (vp122hb==2) if (vp122hb!=98 & vp122hb!=99) & edad<=2 

*  ¿Ha recibido vacuna Cuadruple (contra la difteria, el tetanos y la influenza tipo b): vacuna_cuadruple
gen    vacuna_cuadruple = .
notes vacuna_cuadruple: the survey does not include information to define this variable 

*  ¿Ha recibido vacuna Triple Bacteriana (contra la difteria, el tetanos y la tos convulsa): vacuna_triple
gen    vacuna_triple = . 
notes vacuna_triple: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Antihemophilus (contra la influenza tipo b): vacuna_hemo
gen    vacuna_hemo = (vp122fl==5) if (vp122fl!=98 & vp122fl!=99) & edad<=2 

*  ¿Ha recibido vacuna Sabin (contra la poliomielitis): vacuna_sabin
gen    vacuna_sabin = (vp122ap==6 | vp122po==7) if (vp122ap!=98 & vp122ap!=99 & vp122po!=98 & vp122po!=99) & edad<=2 

*  ¿Ha recibido vacuna Triple Viral (contra el sarampion, las paperas y la rubeola): vacuna_triple_viral
gen    vacuna_triple_viral = (vp122tr==10) if (vp122tr!=98 & vp122tr!=99) & edad<=2 

*** ADICIONALES
*  ¿Ha recibido vacuna Antirotavirus: vacuna_rotavirus
gen    vacuna_rotavirus = (vp122ro==3) if (vp122ro!=98 & vp122ro!=99) & edad<=2 

*  ¿Ha recibido vacuna Pentavalente (contra la difteria, tos ferina, tetanos, hepatitis B, meningitis y neumonias por Hib): vacuna_pentavalente
gen    vacuna_pentavalente = (vp122pt==4) if (vp122pt!=98 & vp122pt!=99) & edad<=2 

*  ¿Ha recibido vacuna Anti-neumococo : vacuna_neumococo
gen    vacuna_neumococo = (vp122ne==8) if (vp122ne!=98 & vp122ne!=99) & edad<=2 

*  ¿Ha recibido vacuna Anti-amarilica (contra la fiebre amarilla) : vacuna_amarilica
gen    vacuna_amarilica = (vp122am==9) if (vp122am!=98 & vp122am!=99) & edad<=2 

*  ¿Ha recibido vacuna contra la Varicela: vacuna_varicela
gen    vacuna_varicela = (vp122var==11) if (vp122var!=98 & vp122var!=99) & edad<=2 

* No ha recibido ninguna vacuna: vacuna_ninguna
gen    vacuna_ninguna = .

* ¿Estuvo enfermo?: enfermo
/*     1 = si estuvo enfermo o sintio malestar en el ultimo mes
       0 = si no estuvo enfermo ni sintio malestar en el ultimo mes
*/
gen    enfermo = .
notes enfermo: the survey does not include information to define this variable

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

* ¿Por que no consulto al medico?: razon_no_medico
/*     1 = si no consulto al medico por razones economicas
       0 = si no consulto al medico por razones no economicas
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
*/
gen    fumar = .
notes fumar: the survey does not include information to define this variable

* ¿Hace deporte regularmente?: deporte
/*     1 = si hace deporte regularmente (1 vez por semana)
       0 = si no hace deporte regularmente
*/
gen    deporte = .
notes deporte: the survey does not include information to define this variable

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.8: Variables laborales ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

*Chequeo
	gen error = 0
	replace error = 1 if (tmhp36==1 | tmhp36==2) & ( tmhp37!=98 | tmhp38!=98 | tmhp39!=98 )
	tab error // OK
	drop error

	gen error = 0
	replace error = 1 if (tmhp36==8 | tmhp36==9 | tmhp36==99) & ( tmhp37!=98 | tmhp38!=98 | tmhp39!=98 | tmhp40!=98 | tmhp41!=98 | tmhp42!=98 | tmhp43!=98 | tmhp44!=98 | tmhp44bs!=98 )
	*Corrijo casos sin sentido
		replace tmhp39=98 if (tmhp36==8 | tmhp36==9 | tmhp36==99) & tmhp39==99 // 3 cases
		replace tmhp43=98 if (tmhp36==8 | tmhp36==9 | tmhp36==99) & tmhp43==99 // 39 cases
		replace tmhp44=98 if (tmhp36==8 | tmhp36==9 | tmhp36==99) & tmhp44==99
		drop error
	gen error = 0
	replace error = 1 if (tmhp36==8 | tmhp36==9 | tmhp36==99) & ( tmhp37!=98 | tmhp38!=98 | tmhp39!=98 | tmhp40!=98 | tmhp41!=98 | tmhp42!=98 | tmhp43!=98 | tmhp44!=98 | tmhp44bs!=98 )
	tab error // only 2 errors
	drop error

	gen error = 0
	replace error = 1 if (tmhp37==2 | tmhp36==99) & ( tmhp38!=98 )
	tab error // OK
	drop error
	
	gen error = 0
	replace error = 1 if (tmhp39!=98) & ( tmhp40!=98 | tmhp41!=98 | tmhp42!=98 | tmhp43!=98 | tmhp44!=98 | tmhp44bs!=98 )
	tab error
	*Corrijo casos sin sentido
		replace tmhp41=98 if tmhp39!=98 & tmhp41==99 // 2 casos
		replace tmhp42=98 if tmhp39!=98 & tmhp42==99 // 2 casos
		replace tmhp43=98 if tmhp39!=98 & tmhp43==99 // 11 casos
	drop error
	gen error = 0
	replace error = 1 if (tmhp39!=98) & ( tmhp40!=98 | tmhp41!=98 | tmhp42!=98 | tmhp43!=98 | tmhp44!=98 | tmhp44bs!=98 )
	tab error // Only 3 errors
	drop error
	
	gen error = 0
	*replace error = 1 if (tmhp36==3 | tmhp36==4 | tmhp36==5 | tmhp36==6 | tmhp36==7 |tmhp36==8 | tmhp36==9 | tmhp36==99 ) & (tmhp47ut!=98 | tmhp47bv!=98 | tmhp47pr!=98 | tmhp47ss!=98 | tmhp47sp!=98 | tmhp47ca!=98 | tmhp47gi!=98 | tmhp47bt!=98 | tmhp47ba!=98 | tmhp47ta!=98 | tmhp47fh!=98 | tmhp47sf!=98 | tmhp47br!=98 | tmhp47as!=98 | tmhp47cc!=98 )
	replace error = 1 if (tmhp36==3 | tmhp36==4 | tmhp36==5 | tmhp36==6 | tmhp36==7 |tmhp36==8 | tmhp36==9 | tmhp36==99 ) & (tmhp48!=98 | tmhp49!=98 | tmhp50!=98 | tmhp51!=98 | tmhp52!=98 | tmhp53!=98 )
	tab error //OK
	drop error
	
* Relacion laboral en su ocupacion principal: relab
/* RELAB:
        1 = Empleador
		2 = Empleado (asalariado)
		3 = Independiente (cuenta propista)
		4 = Trabajador sin salario
		5 = Desocupado
		. = No economicamente activos

* LABOR_STATUS (tmhp36): La semana pasada estaba:
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
* CATEG_OCUP (tmhp43): En su trabajo se desempena como
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
gen labor_status = tmhp36 if (tmhp36!=98 & tmhp36!=99)
gen categ_ocu = tmhp43    if (tmhp43!=98 & tmhp43!=99)
gen     relab = .
replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  //employer 
replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee - Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6)  // Self-employed
replace relab = 4 if (labor_status==1 | labor_status==2) & categ_ocu== 8 //unpaid family worker (but includes paid too)
replace relab = 2 if (labor_status==1 | labor_status==2) & categ_ocu== 8 & (tmhp44bs>=1 & tmhp44bs!=98 & tmhp44bs!=99) //move paid family worker to employee
replace relab = 5 if (labor_status==3 | labor_status==4)

gen     relab_s =.
gen     relab_o =.

* Duracion del desempleo: durades (en meses)
/* DILIGENCIAS_BT (tmhp38): ¿Cuando fue la ultima vez que hizo diligencias para buscar trabajo?
        1 = 1 a 3 meses
		2 = 4 a 6 meses
		3 = Entre 7 y 12 meses
		4 = Mas de 12 meses
		5 = No hizo diligencias
        99 = NS/NR
*/
gen diligencias_bt = tmhp38 if (tmhp38!=98 & tmhp38!=99)
gen     durades = 0   if relab==5
replace durades = 2   if relab==5 & diligencias_bt==1
replace durades = 5 if relab==5 & diligencias_bt==2
replace durades = 9.5  if relab==5 & diligencias_bt==3
replace durades = 13  if relab==5 & diligencias_bt==4 //NO ESTOY SEGURA SI SE DEBE ASIGNAR ESTE VALOR
*Assumption: we complete with 13 months when more than 12 months

* Horas trabajadas totales y en ocupacion principal: hstrt y hstrp
* NHORAST (tmhp48): ¿Cuantas horas en promedio trabajo la semana pasada? 
gen nhorast = tmhp48 if (tmhp48!=98 & tmhp48!=99)
gen      hstrt = .
replace  hstrt = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

gen      hstrp = . 
replace  hstrp = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
/* DMASHORAS (tmhp50): ¿Preferiria trabajar mas de 35 horas por semana?
   BMASHORAS (tmhp51): ¿Ha hecho algo parar trabajar mas horas?
   CAMBIO_EMPLEO (tmhp53):  ¿ Ha cambiado de trabajo durante los ultimos meses?
*/
gen dmashoras = tmhp50     if (tmhp50!=98 & tmhp50!=99)
gen bmashoras = tmhp51      if (tmhp51!=98 & tmhp51!=99)
gen cambio_empleo = tmhp53  if (tmhp53!=98 & tmhp53!=99)
gen     deseamas = 0 if (relab>=1 & relab<=4)
replace deseamas = 1 if dmashoras==1  | bmashoras==1

* Antiguedad: antigue
gen     antigue = .
notes   antigue: variable defined for all individuals

* Asalariado en la ocupacion principal: asal
gen     asal = (relab==2) if (relab>=1 & relab<=4)

* Tipo de empresa: empresa 
/*      1 = Empresa privada grande (mas de cinco trabajadores)
        2 = Empresa privada pequena (cinco o menos trabajadores)
		3 = Empresa publica
* FIRM_SIZE (tmhp42): Contando a ¿cuantas personas trabajan en el establecimiento o lugar en el que trabaja?
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
gen firm_size = tmhp42 if (tmhp42!=98 & tmhp42!=99)
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
* SECTOR_ENCUESTA (tmhp41): ¿A que se dedica el negocio, organismo o empresa en la que trabaja?
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
clonevar sector_encuesta = tmhp41 if (tmhp41!=98 & tmhp41!=99)
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
/* TAREA (tmhp40): ¿Cual es el oficio o trabajo que realiza?
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
clonevar tarea= tmhp40 if (relab>=1 & relab<=4) & (tmhp40!=98 & tmhp40!=99)

* Caracteristicas del empleo y acceso a beneficios a partir del empleo
* Trabajador con contrato:  contrato (definida para trabajadores asalariados)
/* CONTRATO_ENCUESTA (tmhp46): ¿En su trabajo, tienen contrato?
        1 = Formal (contrato firmado por tiempo indefinido)
		2 = Formal (contrato firmado por tiempo determinado)
		3 = Acuerdo verbal? 
		4 = No tiene contrato
		98 = No aplica 
		99 = NS/NR
*/
clonevar contrato_encuesta = tmhp46 if (tmhp46!=98 & tmhp46!=99)
gen     contrato = 1 if relab==2 & (contrato_encuesta== 1 | contrato_encuesta==2)
replace contrato = 0 if relab==2 & (contrato_encuesta== 3 | contrato_encuesta==4)

* Ocupacion permanente
gen     ocuperma = (contrato_encuesta==1) if relab==2 

* Derecho a percibir una jubilacion: djubila
/*APORTE_PENSION (pmhp611,pmhp612,pmhp613,pmhp614,pmhp615)
        1 = Si, para el IVSS
		2 = Si, para otra institucion o empresa publica
		3 = Si, para institucion o empresa privada
		4 = Si, para otra
		5 = No
		98 = No aplica
		99 = NS/NR  
*/
gen aporte_pension = 1     if pmhp611==1
replace aporte_pension = 2 if pmhp612==2
replace aporte_pension = 3 if pmhp613==3
replace aporte_pension = 4 if pmhp614==4
replace aporte_pension = 5 if pmhp615==5
gen     djubila = (aporte_pension>=1 & aporte_pension<=4) if  relab==2   

* Seguro de salud ligado al empleo: dsegsale
gen     dsegsale = (afiliado_seguro_salud==3 | afiliado_seguro_salud==4) if relab==2 

* Derecho a aguinaldo: aguinaldo
gen     aguinaldo = tmhp47ut==1 if ((tmhp47ut!=98 & tmhp47ut!=99) & relab==2) 

* Derecho a vacaciones pagas: dvacaciones
gen     dvacaciones = .
notes dvacaciones: the survey does not include information to define this variable

* Sindicalizado: sindicato
gen     sindicato = tmhp47as==1 if ((tmhp47as!=98 & tmhp47as!=99) & relab==2)

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
tab tmhp44bs tmhp44 //OK

* Situacion laboral y recepcion de ingresos
tab tmhp36 tmhp44 //OK

/*                      |   ¿Cuánto recibió en total durante el mes
     La semana pasada |      pasado por el trabajo realizado?
          ¿Estaba...? | Si recibi  No recibi  No aplica  No sabe/N |     Total
----------------------+--------------------------------------------+----------
           Trabajando |     7,183        160          0        729 |     8,072 
No trabajó pero tiene |       470         47          0         64 |       581 
Buscando trabajo por  |         0          0        169          0 |       169 
Buscando trabajo habi |         0          0        719          0 |       719 
En quehaceres del hog |         0          1      3,427          0 |     3,428 
         Incapacitado |         0          0        294          0 |       294 
       Otra situación |         0          1        505          0 |       506 
           Estudiando |         0          0      3,683          0 |     3,683 
           Pensionado |         0          0      1,188          0 |     1,188 
            No aplica |         0          0      5,096          0 |     5,096 
  No sabe/No responde |         0          0        186          0 |       186 
----------------------+--------------------------------------------+----------
                Total |     7,653        209     15,267        793 |    23,922 

ESTAS CATEGORIAS CAMBIARON RESPECTO A 2016
*/

/* Esto implica que no deberiamos preocuparnos por los que NA cuando 
vemos la tabla de ingresos ya que los que NA son casi los mismos que figuran en 
la misma categoria luego */

* Se reemplazan como missing NR y NA
replace tmhp44bs = . if tmhp44bs==99 // Cedlas clasifica la NR como missing
replace tmhp44bs = . if tmhp44bs==98 // Los NA como missing?? VER

/*  Solo se incluyen ingresos monetarios
La variable TMHP44 identifica a los que recibieron ingresos laborales
La variable TMHP44BS menciona los montos recibidos en el mes anterior a la encuesta

ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia*/

*****  i)  PATRON
* Monetario	
* Ingreso monetario laboral de la actividad principal si es patrón
gen     ipatrp_m = tmhp44bs if relab==1  

* No monetario
gen     ipatrp_nm = .	
notes ipatrp_nm: the survey does not include information to define this variable 

****  ii)  ASALARIADOS
* Monetario	
* Ingreso monetario laboral de la actividad principal si es asalariado
gen     iasalp_m = tmhp44bs if relab==2

* No monetario
gen     iasalp_nm = .
notes iasalp_nm: the survey does not include information to define this variable

***** iii)  CUENTA PROPIA
* Monetario	
* Ingreso monetario laboral de la actividad principal si es cuenta propia
gen     ictapp_m = tmhp44bs if relab==3

* No monetario
gen     ictapp_nm = .
notes ictapp_nm: the survey does not include information to define this variable

***** IV)   INGRESO MONETARIO LABORAL DE LA ACTIVIDAD PRINCIPAL
gen iolp_m = tmhp44bs if relab==4 //nombrar esta categoria con otro nombre, dado que olp hace referencia a la suma de todos los ingresos de la ocupacion principal
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
notes ipatrnp_m: the survey does not include information to define this variable 
notes iasalnp_m: the survey does not include information to define this variable 
notes ictapnp_m: the survey does not include information to define this variable 
notes iolnp_m: the survey does not include information to define this variable

****** 9.3.INGRESO NO LABORAL ******
/* Incluye 
	1) jubilaciones y pensiones
	2) ingresos de capital
	3) transferencias privadas y estatales
*/

/* Es necesario construir categorias para Ingresos no laborales a partir de la encuesta 
   dado que hay una unica tagoria donde se reportan todos los ingresos*/
/*
gen     ing_nlb = .
replace ing_nlb = 1  if tmhp45pe==1 // Pensión de vejez
replace ing_nlb = 2  if tmhp45op==2 // Otra pensión del IVSS (invalidez, incapacidad, sobreviviente)
replace ing_nlb = 3  if tmhp45ju==3 // Jubilación por trabajo
replace ing_nlb = 4  if tmhp45af==4 // Ayuda económica de algún familiar o de otra persona en el país
replace ing_nlb = 5  if tmhp45ax==5 // Ayuda económica de algún familiar o de otra persona desde el exterior
replace ing_nlb = 6  if tmhp45ps==6 // Pensión de la seguridad social de otro país
replace ing_nlb = 7  if tmhp45re==7 // Renta de propiedades
replace ing_nlb = 8  if tmhp45id==8 // Intereses o dividendos
replace ing_nlb = 9  if tmhp45ot==9 // Otro
replace ing_nlb = 10 if tmhp45ni==10 // Ninguno
replace ing_nlb = 11 if tmhp45nsr==11 // NS/NR
*/

gen ing_nlb_pe = 1  if tmhp45pe==1 // Pensión de vejez
gen ing_nlb_op = 1  if tmhp45op==2 // Otra pensión del IVSS (invalidez, incapacidad, sobreviviente)
gen ing_nlb_ju = 1  if tmhp45ju==3 // Jubilación por trabajo
gen ing_nlb_af = 1  if tmhp45af==4 // Ayuda económica de algún familiar o de otra persona en el país
gen ing_nlb_ax = 1  if tmhp45ax==5 // Ayuda económica de algún familiar o de otra persona desde el exterior
gen ing_nlb_ps = 1  if tmhp45ps==6 // Pensión de la seguridad social de otro país
gen ing_nlb_re = 1  if tmhp45re==7 // Renta de propiedades
gen ing_nlb_id = 1  if tmhp45id==8 // Intereses o dividendos
gen ing_nlb_ot = 1  if tmhp45ot==9 // Otro
gen ing_nlb_ni = 1  if tmhp45ni==10 // Ninguno
gen ing_nlb_nsr = 1 if tmhp45nsr==11 // NS/NR

*Cuantas categorias de ingresos reciben
egen recibe = rowtotal(ing_nlb_*) if ing_nlb_ni!= 1 | ing_nlb_nsr!= 1
tab recibe
/*   recibe |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      6,152       25.72       25.72
          1 |     17,556       73.39       99.11
          2 |        199        0.83       99.94
          3 |         14        0.06      100.00
          4 |          1        0.00      100.00
------------+-----------------------------------
      Total |     23,922      100.00
*/

****** 9.3.1.JUBILACIONES Y PENSIONES ******	  
/*
PMHP60BS    // Monto recibido por jubilacion o pension
PMHP58J==1  // Jubilado
PMHP58P==2  // Pensionado
TMHP45bs    // Monto de ingresos no laborales
*/

*Se reemplazan como missing NR y NA
replace pmhp60bs = . if (pmhp60bs==99 | pmhp60bs==98)
replace tmhp45bs = . if (tmhp45bs==99 | tmhp45bs==98)

*Jubilaciones y pensiones
* Monetario
* ijubi_m: Ingreso monetario por jubilaciones y pensiones
	
gen     ijubi_m = .                          
replace ijubi_m = pmhp60bs if pmhp58j==1 // Jubilado (reportados 626)
replace ijubi_m = pmhp60bs if pmhp58p==2 // Pensionado (reportados 1,442 ) //por que utilizar esto y no lo otro
replace ijubi_m = tmhp45bs if ijubi_m==. & (ing_nlb_ju==1 | ing_nlb_op==1 | ing_nlb_ju==1) & recibe==1

* No monetario	
gen     ijubi_nm= .
notes ijubi_nm: the survey does not include information to define this variable

****** 9.3.2.INGRESOS DE CAPITAL ******	
/*icap_m: Ingreso monetario de capital, intereses, alquileres, rentas, beneficios y dividendos*/
gen     icap_m = .
replace icap_m = tmhp45bs if ing_nlb_pe!=1 & ing_nlb_op!=1 & ing_nlb_ju!=1 & ing_nlb_af!=1 & ing_nlb_ax!=1 & ing_nlb_ps!=1 & (ing_nlb_re==1 | ing_nlb_id==1) & ing_nlb_ot!=1 & ing_nlb_ni!=1 & ing_nlb_nsr!=1
gen     icap_nm = . 

****** 9.3.3.REMESAS ******	
/*rem: Ingreso monetario de remesas */
gen     rem = .
replace rem = tmhp45bs if ing_nlb_pe != 1 & ing_nlb_op != 1 & ing_nlb_ju != 1 & ing_nlb_af != 1 & ing_nlb_ax == 1 & ing_nlb_ps != 1 & ing_nlb_re != 1 & ing_nlb_id != 1 & ing_nlb_ot != 1 & ing_nlb_ni != 1 & ing_nlb_nsr != 1


****** 9.3.4.TRANSFERENCIAS PRIVADAS ******	
/*TMHP52EF=4 // Ayuda económica de algún familiar o de otra persona en el país
itranp_o_m Ingreso monetario de otras transferencias privadas diferentes a remesas*/

gen     itranp_o_m = .
replace itranp_o_m = tmhp45bs if ing_nlb_pe != 1 & ing_nlb_op != 1 & ing_nlb_ju != 1 & ing_nlb_af == 1 & ing_nlb_ax != 1 & ing_nlb_ps != 1 & ing_nlb_re != 1 & ing_nlb_id != 1 & ing_nlb_ot != 1 & ing_nlb_ni != 1 & ing_nlb_nsr != 1
gen     itranp_o_nm = .

****** 9.3.5 TRANSFERENCIAS PRIVADAS ******	
*itranp_ns: Ingreso monetario de transferencias privadas, cuando no se puede distinguir entre remesas y otras
gen     itranp_ns = .

****** 9.3.6 TRANSFERENCIAS ESTATALES ******	
*HASTA AHORA SOLO SE PUEDEN ENCONTRAR BENEFICIARIOS PERO los montos HABRIA QUE IMPUTARLOS
*cct: Ingreso monetario por transferencias estatales relacionadas con transferencias monetarias condicionadas
*itrane_o_m Ingreso monetario por transferencias estatales diferentes a las transferencias monetarias condicionadas
*itrane_ns Ingreso monetario por transferencias cuando no se puede distinguir
gen     cct = .
gen     itrane_o_m = .
gen     itrane_o_nm = .
gen     itrane_ns = .

***** iV) OTROS INGRESOS NO LABORALES 
gen     inla_otro = .
replace inla_otro = tmhp45bs if ing_nlb_pe != 1 & ing_nlb_op != 1 & ing_nlb_ju != 1 & ing_nlb_af != 1 & ing_nlb_ax != 1 & ing_nlb_re != 1 & ing_nlb_id != 1 & (ing_nlb_ot == 1 |ing_nlb_ps == 1) & ing_nlb_ni != 1 & ing_nlb_nsr != 1 | (recibe>=2 & recibe!=.)

/*
***** V) INGRESOS NO LABORALES EXTRAORDINARIOS 
gen     inla_extraord = .

****** 9.3.7 INGRESOS DE LA OCUPACION PRINCIPAL ****** //chequear que las distintas fuentes agregan al total

gen     ip_m = tmhp44bs //	Ingreso monetario en la ocupación principal 
gen     ip   = .	    // Ingreso total en la ocupación principal 

****** 9.3.8 INGRESOS TODAS LAS OCUPACIONES ******

gen     ila_m  = tmhp44bs    // Ingreso monetario en todas las ocupaciones 
gen     ila    = .           // Ingreso total en todas las ocupaciones 
gen     perila = .           // Perceptores de ingresos laborales 

****** 9.3.9 INGRESOS LABORALES HORARIOS ******

*gen     wage_m= ip_m/(hstrp*4)  // Ingreso laboral horario monetario en la ocupación principal
*gen wage=    // Ingreso laboral horario total en la ocupación principal 
*gen ilaho_m	// Ingreso laboral horario monetario en todos los trabajos 
*gen ilaho   // Ingreso laboral horario total en todos los trabajos 
*/
/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.10: LINEAS DE POBREZA  -------------------------------------------------------------
************************************************************************************************************************************************)*/
tab pobreza [aw=pondera]
/*
     Pobreza por |
        ingresos |      Freq.     Percent        Cum.
-----------------+-----------------------------------
        No pobre | 1,446.7106        6.05        6.05
Pobre no extremo | 3,563.7962       14.90       20.95
   Pobre extremo |9,740.74235       40.72       61.66
    No declarado | 9,170.7508       38.34      100.00
-----------------+-----------------------------------
           Total |     23,922      100.00
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
tab     pobreza_enc [aw=pondera]
/*
pobreza_enc |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 1,554.4693        9.81        9.81
          1 | 14,295.531       90.19      100.00
------------+-----------------------------------
      Total |     15,850      100.00
*/

/*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- 1.1: PRECIOS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/

* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .

* IPC del mes base
gen ipc = 544131				/*  MES BASE: promedio Enero-Diciembre			*/

gen cpiperiod = "2017m01-2017m12"

gen     ipc_rel = 1
/*
replace ipc_rel = 0.989033	if  mes==1
replace ipc_rel = 0.991853	if  mes==2
replace ipc_rel = 0.990799	if  mes==3
replace ipc_rel = 0.994561	if  mes==4
replace ipc_rel = 0.998450	if  mes==5
replace ipc_rel = 1.001074	if  mes==6
replace ipc_rel = 1.003158	if  mes==7
replace ipc_rel = 1.003004	if  mes==8
replace ipc_rel = 1.003312	if  mes==9
replace ipc_rel = 1.004084	if  mes==10
replace ipc_rel = 1.006322	if  mes==11
replace ipc_rel = 1.002772	if  mes==12
*/

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

*Renta imputada
	gen aux_propieta_no_paga = 1 if tenencia_vivienda==1 | tenencia_vivienda==6
	replace aux_propieta_no_paga = 1 if tenencia_vivienda==8 & hp15ot_cod==1
	replace aux_propieta_no_paga = 0 if (tenencia_vivienda>=2 & tenencia_vivienda<=5) | tenencia_vivienda==7 | (tenencia_vivienda==8 & hp15ot_cod==4) // quedan como missing "otra" y "NS/NR"
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
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 /*ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/  

keep pais ano encuesta id com pondera strata psu relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua ///
region_est1 region_est2 region_est3 cen lla ceo zul and nor isu gua capital urbano migrante migra_ext migra_rur anios_residencia migra_rec ///
propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici ///
alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp ///
seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector sector_encuesta tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap  itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg /*ipc*/ pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i /*ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/  

save "$dataout\base_out_nesstar_cedlas_2017.dta", replace

