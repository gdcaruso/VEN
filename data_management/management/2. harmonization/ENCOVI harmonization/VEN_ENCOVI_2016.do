/*===========================================================================
Country name:		Venezuela
Year:			2016
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
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
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
set more off
quietly include "$aux_do\cuantiles.do"

local country  "VEN"    // Country ISO code
local year     "2016"   // Year of the survey
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
								1: Data preparation: First-Order Variables
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Open Databases  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
* Opening official database  
use "$data2016\Personas Encovi2016.dta", clear
rename control CONTROL
merge m:1 CONTROL using "$data2016\Hogares_ENCOVI2016.dta"
drop _merge

* Adding regions
rename lin LIN
sort CONTROL LIN
merge m:1 CONTROL LIN using "$data2016\region_2016.dta"
drop _merge  
rename _all, lower

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables  --------------------------------------------------
*************************************************************************************************************************************************)*/

* Country identifier: country
gen country = "VEN"

* Year identifier: year
capture drop year
gen year = 2016

* Survey identifier: survey
gen survey = "ENCOVI - 2016"

* Household identifier: id      
gen id = control

* Component identifier: com
gen com  = lin
duplicates report id com

gen double pid = lin
notes pid: original variable used was: lin

* Weights: pondera
gen pondera = xxp  

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
* RELACION_EN (mhp15): Relación de parentesco con el jefe de hogar en la encuesta
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
clonevar relacion_en = mhp15
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
/* SEXO (mhp17): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
gen sex = mhp17
label define sex 1 "Male" 2 "Female"
label value sex sex

* Age
* EDAD_ENCUESTA (mhp16): Cuantos años cumplidos tiene?
gen     age = mhp16
notes   age: range of the variable: 0-105

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
replace   nro_hijos = .  if  jefe!=1 & conyuge!=1


* Marital status
/* ESTADO_CIVIL_ENCUESTA (mhp18): Cual es su situacion conyugal
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
gen estado_civil_encuesta = mhp18 if (mhp18!=98 & mhp18!=99)
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
gen     children_born_alive = sp28 if (sp28!=98 & sp28!=99)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     children_alive = sp29 if sp28!=0 & sp29<=sp28 & (sp29!=98 & sp29!=99)

/*(*************************************************************************************************************************************************
*-------------------------------------------------------------	1.3: Regional variables  ---------------------------------------------------------
*************************************************************************************************************************************************)*/
* Creación de Variable Geográficas Desagregadas
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

* Desagregación 3 (Municipios): region_est3
gen region_est3 = .

* Dummy urbano-rural: urbano  //REVISAR SI SE PUEDE CONSTRUIR ESTA VARIABLE
/* : area de residencia
		 1 = urbana  
		 2 = rural						
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

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/

* Propiedad de la vivienda:	propieta
/* TENENCIA_VIVIENDA (hp13): régimen de tenencia de la vivienda 
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
destring (hp13ot_cod), replace

clonevar tenencia_vivienda = hp13 if (hp13!=98 & hp13!=99)
gen     propieta = 1		if  tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==6 | (tenencia_vivienda==8 & hp13ot_cod==2)
replace propieta = 0		if  (tenencia_vivienda>=3 & tenencia_vivienda<=5) | (tenencia_vivienda==7) | (tenencia_vivienda==8 & inlist(hp13ot_cod,4,5,7))
replace propieta = .		if  relacion!=1

* Habitaciones, contando baño y cocina: habita 
gen     habita = .
notes   habita: the survey does not include information to define this variable

* Dormitorios de uso exclusivo: dormi
* NDORMITORIOS (hp10): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormitorios = hp10 if (hp10!=98 & hp10!=99)
gen     dormi = ndormitorios 
replace dormi =. if relacion!=1
 
* Vivienda en lugar precario: precaria
/* TIPO_VIVIENDA (vp4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
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
/* ACCESO_AGUA (vp5): A esta vivienda el agua llega normalmente por (no se puede identificar si el acceso es dentro del terreno o vivienda)
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
*/	

gen     agua = vp5==1 | vp5==2 if (vp5!=98 & vp5!=99)
replace agua = 0 if agua==1 & vp6==5
replace agua= .		if  relacion!=1

* Baño con arrastre de agua: banio
/* TIPO_SANITARIO (vp8): Esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
gen tipo_sanitario = vp8 if (vp8!=98 & vp8!=99)
gen     banio = (tipo_sanitario>=1 & tipo_sanitario<=3) if tipo_sanitario!=.
replace banio = .		if  relacion!=1

* Cloacas: cloacas
gen     cloacas = (tipo_sanitario==1) if tipo_sanitario!=.
replace cloacas = .		if  relacion!=1

* Electricidad en la vivienda: elect
/* SERVICIO_ELECTRICO (vp7): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe
			5 = No tiene servicio electrico
			99 = NS/NR					
*/
gen servicio_electrico = vp7 if (vp7!=98 & vp7!=99)
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
* NEVERA (hp12n): ¿Posee este hogar nevera?
gen nevera = hp12n if (hp12n!=98 & hp12n!=99)
gen     heladera = 0		if  nevera==2
replace heladera = 1		if  nevera==1
replace heladera = .		if  relacion!=1 

* Lavarropas: lavarropas
* LAVADORA (hp12l): ¿Posee este hogar lavadora?
gen lavadora = hp12l if (hp12l!=98 & hp12l!=99)
gen     lavarropas = 0		if  lavadora==2
replace lavarropas = 1		if  lavadora==1
replace lavarropas = .		if  relacion!=1 

* Aire acondicionado: aire
* AIRE_ACONDICIONADO (hp12a): ¿Posee este hogar aire acondicionado?
gen aire_acondicionado = hp12a if (hp12a!=98 & hp12a!=99)
gen     aire = 0		    if  aire_acondicionado==2
replace aire = 1		    if  aire_acondicionado==1
replace aire = .		    if  relacion!=1 

* Calefacción fija: calefaccion_fija
* CALENTADOR (hp12o): ¿Posee este hogar calentador? //NO ESTOY SEGURA SI ES COMPLETAMENTE COMPARABLE
*gen calentador = hp12o if (hp12o!=98 & hp12o!=99)
gen     calefaccion_fija = .
notes calefaccion_fija: the survey does not include information to define this variable

* Teléfono fijo: telefono_fijo
gen     telefono_fijo = .
notes telefono_fijo: the survey does not include information to define this variable

* Teléfono movil (individual): celular_ind
gen     celular_ind = 1 if (mhp19==1)
replace celular_ind = 0 if (mhp19==2)

* Telefono celular: celular
tempvar allmiss
egen celular = max(celular_ind==1), by (id)
egen `allmiss' = min(celular_ind == .), by(id)
replace celular =. if `allmiss' == 1
replace celular =. if relacion!=1

* Televisor: televisor
* TELEVISOR (hp12t): ¿Posee este hogar televisor?
gen televisor_encuesta = hp12t if (hp12t!=98 & hp12t!=99)
gen     televisor = 0		if  televisor_encuesta==2
replace televisor = 1		if  televisor_encuesta==1
replace televisor = .		if  relacion!=1 

* TV por cable o satelital:		tv_cable
* TVCABLE_ENCUESTA (hp12v): ¿Posee este hogar TV por cable?
gen tvcable_encuesta = hp12v if (hp12v!=98 & hp12v!=99)
gen     tv_cable = 0		if  tvcable_encuesta==2
replace tv_cable = 1		if  tvcable_encuesta==1
replace tv_cable = .		if  relacion!=1 

* VCR o DVD: video 
gen     video = .		
notes   video: the survey does not include information to define this variable

* Computadora: computadora
* COMPUTADOR (hp12c): ¿Posee este hogar computadora?
gen computador = hp12c if (hp12c!=98 & hp12c!=99)
gen     computadora = 0		if  computador==2 
replace computadora = 1		if  computador==1 
replace computadora = .		if  relacion!=1 

* Conexión a Internet en el hogar: internet_casa
* INTERNET (hp12i): ¿Posee este hogar internet?
gen internet = hp12i if (hp12i!=98 & hp12i!=99)
gen     internet_casa = 0	if  internet==2
replace internet_casa = 1	if  internet==1
replace internet_casa = .	if  relacion!=1 

* Uso de Internet: uso_internet
gen   uso_internet = .
notes uso_internet: the survey does not include information to define this variable

* Auto: auto 
* NCARROS (hp11) : ¿Cuantos carros de uso familiar tiene este hogar?
gen ncarros = hp11 if (hp11!=98 & hp11!=99)
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
/* NIVEL_EDUC (ep30n): ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
		99 = NS/NR
* A_EDUC (ep20a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Preescolar, Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* S_EDUC (ep30s): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
*/
clonevar nivel_educ = ep30n if (ep30n!=98 & ep30n!=99)
gen a_educ = ep30a     if (ep30a!=98 & ep30a!=99)
gen s_educ = ep30s     if (ep30s!=98 & ep30s!=99)
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
gen asiste_encuesta = ep32  if (ep32!=98 & ep32!=99)   
capture drop asiste                                        
gen     asiste = 1	if  asiste_encuesta==1 
replace asiste = 0	if  (asiste_encuesta==2 | asiste_encuesta==3)
replace asiste = .  if  edad<3
notes   asiste: variable defined for individuals aged 3 and older

* Establecimiento educativo público: edu_pub
/* TIPO_CENTRO_EDUC (ep35): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		98 = No aplica
		3 = NS/NR								
*/
gen tipo_centro_educ = ep35 if (ep35!=98 & ep35!=99)
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
*brow id pid nivel_educ a_educ s_educ if nivel!=. & aedu==. // se pierden 165 obs que reportan nivel_educ, pero no reportan a_educ o s_educ 

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

*label def nivedu 1 "Baja educacion (menos de 9 años)" 2 "Media educacion (de 9-12 años)" 3 "Alta educacion (mas de 13 años)"
*label value nivedu nivedu

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
/* AFILIADO_SEGURO_SALUD (sp20): ¿está afiliado a algún seguro medico?
        1 = Instituto Venezolano de los Seguros Sociales (IVSS)
	    2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
	    3 = Seguro medico contratado por institucion publica
	    4 = Seguro medico contratado por institucion privada
	    5 = Seguro medico privado contratado de forma particular
	    6 = No tiene plan de seguro de atencion medica
	    99 = NS/NR
*/

gen afiliado_seguro_salud = 1     if sp20==1 
replace afiliado_seguro_salud = 2 if sp20==2 
replace afiliado_seguro_salud = 3 if sp20==3 
replace afiliado_seguro_salud = 4 if sp20==4
replace afiliado_seguro_salud = 5 if sp20==5
replace afiliado_seguro_salud = 6 if sp20==6

gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6

* Tipo de seguro de salud: tipo_seguro
/*      0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
        1 = si esta afiliado a algun seguro de salud privado
*/
gen 	tipo_seguro = 0     if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=4
replace tipo_seguro = 1     if  afiliado_seguro_salud==4 //SOLO 5 o 4 y 5?

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
notes lugar_control_embarazo: the survey does not include information to define this 

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
// ¿Cuantos cigarrillos consume diariamente: (sp27)
*/
gen    fumar = (sp27>0) if (sp27!=98 & sp27!=999)
notes fumar: the variable is not completely comparable

* ¿Hace deporte regularmente?: deporte
/*     1 = si hace deporte regularmente (1 vez por semana)
       0 = si no hace deporte regularmente
* ACTIVIDAD_FISICA (cep70fm,cep70fm): ¿En un dia promedio, cuanto tiempo dedica usted a actividad fisica?
*/
gen actividad_fisica = cep70fh*60+cep70fm if (cep70fh!=98 & cep70fh!=99) & (cep70fm!=98 & cep70fm!=99)
gen deporte = (actividad_fisica >=20) if actividad_fisica!=.

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

* LABOR_STATUS (tp39): La semana pasada estaba:
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
* CATEG_OCUP (tp46): En su trabajo se desempena como
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
gen labor_status = tp39 if (tp39!=98 & tp39!=99)
gen categ_ocu = tp46    if (tp46!=98 & tp46!=99)
gen     relab = .
replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  // Employer 
replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee - Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6)  // Self-employed
replace relab = 4 if (labor_status==1 | labor_status==2) & (categ_ocu== 8) //unpaid family worker
replace relab = 2 if (labor_status==1 | labor_status==2) & (categ_ocu== 8 & tp47m>0 & tp47m!=98 & tp47m!=99) //paid family worker
replace relab = 5 if (labor_status==3 | labor_status==4) //unemployed

* Duracion del desempleo: durades (en meses)
/* DILIGENCIAS_BT (tp41): ¿Cuando fue la ultima vez que hizo diligencias para buscar trabajo?
        1 = Entre 1 y 6 meses
		2 = Entre 7 y 12 meses
		3 = Mas de 12 meses
		98 = No aplica
		99 - NS/NR
*/
gen diligencias_bt = tp41 if (tp41!=98 & tp41!=99)
gen     durades = 0   if relab==5
replace durades = 3.5   if relab==5 & diligencias_bt==1
replace durades = 9.5 if relab==5 & diligencias_bt==2
replace durades = 13  if relab==5 & diligencias_bt==3 //NO ESTOY SEGURA SI SE DEBE ASIGNAR ESTE VALOR
*Assumption: we complete with 13 months when more than 12 months

* Horas trabajadas totales y en ocupacion principal: hstrt y hstrp
* NHORAST (tp51): ¿Cuantas horas en promedio trabajo la semana pasada? 
gen nhorast = tp51 if (tp51!=98 & tp51!=99)
gen      hstrt = .
replace  hstrt = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

gen      hstrp = .
replace  hstrp = nhorast if (relab>=1 & relab<=4) & (nhorast>=0 & nhorast!=.)

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
/* DMASHORAS (tp53): ¿Preferiria trabajar mas de 30 horas por semana?
   BMASHORAS (tp54): ¿Ha hecho algo parar trabajar mas horas?
   CAMBIO_EMPLEO (tp56):  ¿ Ha cambiado de trabajo durante los 12 ultimos meses?
*/
gen dmashoras = tp53     if (tp53!=98 & tp53!=99)
gen bmashoras = tp54      if (tp54!=98 & tp54!=99)
gen cambio_empleo = tp56  if (tp56!=98 & tp56!=99)
gen     deseamas = 0 if (relab>=1 & relab<=4)
replace deseamas = 1 if  dmashoras==1 | bmashoras == 1 

* Antiguedad: antigue
gen     antigue = .
notes   antigue: variable defined for all individuals

* Asalariado en la ocupacion principal: asal
gen     asal = (relab==2) if (relab>=1 & relab<=4)

* Tipo de empresa: empresa 
/*      1 = Empresa privada grande (mas de cinco trabajadores)
        2 = Empresa privada pequena (cinco o menos trabajadores)
		3 = Empresa publica
* FIRM_SIZE (tp45): Contando a ¿cuantas personas trabajan en el establecimiento o lugar en el que trabaja?
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
gen firm_size = tp45 if (tp45!=98 & tp45!=99)
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

gen relab_s =.
gen relab_o =.

* Sector de actividad: sector1d (clasificacion CIIU un digito) y sector (10 sectores)
/*Clasificacion CIIU: 
		1. A 01, 02 Agricultura, ganadería, caza y silvicultura
		2. B 05 Pesca
		3. C 10-14 Explotación de minas y canteras
		4. D 15-37 Industrias manufactureras
		5. E 40, 41 Suministro de electricidad, gas y agua
		6. F 45 Construcción
		7. G 50-52 Comercio al por mayor y al por menor; reparación de vehículos
		automotores, motocicletas, efectos personales y enseres
		domésticos
		8. H 55 Hoteles y restaurantes
		9. I 60-64 Transporte, almacenamiento y comunicaciones
		10. J 65-67 Intermediación financiera
		11. K 70-74 Actividades inmobiliarias, empresariales y de alquiler
		12. L 75 Administración pública y defensa; planes de seguridad social de
		afiliación obligatoria
		13. M 80 Enseñanza
		14. N 85 Servicios sociales y de salud
		15. O 90-93 Otras actividades de servicios comunitarios, sociales y
		personales
		16. P 95-97 Actividades de hogares privados como empleadores
		y actividades no diferenciadas de hogares privados como
		productores
		17. Q 99 Organizaciones y órganos extraterritoriales
Sector (10 sectores)		
        1 = Agricola, actividades primarias
	    2 = Industrias de baja tecnologia (industria alimenticia, bebidas y tabaco, textiles y confecciones) 
	    3 = Resto de industria manufacturera
	    4 = Construccion
	    5 = Comercio minorista y mayorista, restaurants, hoteles, reparaciones
	    6 = Electricidad, gas, agua, transporte, comunicaciones
	    7 = Bancos, finanzas, seguros, servicios profesionales
	    8 = Administración pública, defensa y organismos extraterritoriales
	    9 = Educacion, salud, servicios personales 
	    10 = Servicio domestico 
* SECTOR_ENCUESTA (tp44 y cod44): ¿A que se dedica el negocio, organismo o empresa en la que trabaja? //corresponde a clasificacion de 2 digitos CIIU
*/
destring cod44, replace
clonevar sector_encuesta = cod44 if cod44!=98 & cod44!=999
tab tp44 if sector_encuesta==99

gen     sector1d = .  
notes sector1d: the survey does not include information to define this variable

/*
gen     sector1d = 1  if (sector_encuesta<=1 & sector_encuesta<=2) | (sector_encuesta<=92 & sector_encuesta<=93) & (relab>=1 & relab<=4) //Agricultura, ganadería, caza y silvicultura
replace sector1d = 2  if sector_encuesta==5 & (relab>=1 & relab<=92) //Pesca
replace sector1d = 3  if sector_encuesta>=10 & sector_encuesta<=14 & (relab>=1 & relab<=4) //Explotación de minas y canteras
replace sector1d = 4  if sector_encuesta>=15 & sector_encuesta<=37 & (relab>=1 & relab<=4) //Industrias manufactureras
replace sector1d = 5  if sector_encuesta>=40 & sector_encuesta<=41 & (relab>=1 & relab<=4) //Suministro de electricidad, gas y agua
replace sector1d = 6  if sector_encuesta>=45 & (relab>=1 & relab<=4) //Construcción
replace sector1d = 7  if sector_encuesta>=50 & sector_encuesta<=52 & (relab>=1 & relab<=4) //Comercio al por mayor y al por menor; reparación de vehículos automotores, motocicletas, efectos personales y enseres domésticos
replace sector1d = 8  if sector_encuesta>=55 & (relab>=1 & relab<=4) //Hoteles y restaurantes
replace sector1d = 9  if sector_encuesta>=60 & sector_encuesta<=64 & (relab>=1 & relab<=4) //Transporte, almacenamiento y comunicaciones
replace sector1d = 10 if sector_encuesta>=65 & sector_encuesta<=67 & (relab>=1 & relab<=4) //Intermediacion financiera
replace sector1d = 11 if sector_encuesta>=70 & sector_encuesta<=74 & (relab>=1 & relab<=4) //Actividades inmobiliarias, empresariales y de alquiler
replace sector1d = 12 if sector_encuesta>=75 & (relab>=1 & relab<=4) //Administración pública y defensa; planes de seguridad social de afiliación obligatoria
replace sector1d = 13 if sector_encuesta>=80 & (relab>=1 & relab<=4) //Ensenanza
replace sector1d = 14 if sector_encuesta>=85 & (relab>=1 & relab<=4) //Servicios sociales y de salud
replace sector1d = 15 if sector_encuesta>=90 & sector_encuesta<=93 & (relab>=1 & relab<=4) //Otras actividades de servicios comunitarios, sociales y personales
replace sector1d = 16 if sector_encuesta>=95 & sector_encuesta<=97 & (relab>=1 & relab<=4) //Actividades de hogares privados como empleadores y actividades no diferenciadas de hogares privados como productores
replace sector1d = 17 if sector_encuesta>=99 & (relab>=1 & relab<=4) //Organizaciones y órganos extraterritoriales
*/

gen     sector = .
notes sector: the survey does not include information to define this variable
/*
gen     sector = 1  if  sector1d>0 & sector1d<4  // Agricola, actividades primarias
replace sector = 2  if  sector_encuesta>=15 & sector_encuesta>=20 & (relab<=1 & relab>=4)  //Industrias de baja tecnologia 
replace sector = 3  if  sector_encuesta>=21 & sector_encuesta>=37 & (relab<=1 & relab>=4)  //Resto de industria manufacturera
replace sector = 4  if  sector1d==6 //Construccion
replace sector = 5  if  sector1d==7  | sector1d==8 //Comercio
replace sector = 6  if  sector1d==5  | sector1d==9 //Electricidad, agua, gas, transporte y comunicaciones
replace sector = 7  if  sector1d==10 | sector1d==11 //Entidades financieras
replace sector = 8  if  sector1d==12 | sector1d==17 // Administracion publica, defensa y organismos extraterritoriales
replace sector = 9  if  sector1d>=13 & sector1d<=15 // Educacion, salud y servicios personales
replace sector = 10 if  sector1d==16 // Servicio domestico
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
* TAREA ENCUESTA (cod43)
		1 = Oficiales de las fuerzas armadas
		3 2= Otros miembros de las fuerzas armadas 
		11 12 13 = Directores ejecutivos, personal directi
		14 = Gerentes de hoteles, restaurantes, come
		21 25= Profesionales de las ciencias y de la i
		22 = Profesionales de la salud
		23 = Profesionales de la enseñanza 
		24 = Especialistas en organización de la adm
		26 = Profesionales en derecho, en ciencias s 
		31 = Profesionales de las ciencias y la inge
		32 = Profesionales de nivel medio de la salu
		33 = Profesionales de nivel medio en operaci
		34 = Profesionales de nivel medio de servici
		35 = Técnicos de la tecnología de la informa
		41 = Oficinistas
		42 = Empleados en trato directo con el públi
		43 = Empleados contables y encargados del re
		44 = Otro personal de apoyo administrativo
		51 = Trabajadores de los servicios personale
		52 = Vendedores
		53 = Trabajadores de los cuidados personales
		54 = Personal de los servicios de protección
		61 = Agricultores y trabajadores calificados
		62 = Trabajadores forestales calificados, pe
		63 = Trabajadores agropecuarios, pescadores,
		71 = Oficiales y operarios de la construcció
		72 = Oficiales y operarios de la metalurgia,
		73 = Artesanos y operarios de las artes gráf
		74 = Trabajadores especializados en electric
		75 = Operarios y oficiales de procesamiento
		81 = Operadores de instalaciones fijas y máq
		83 82 = Conductores de vehículos y operadores d
		91 = Limpiadores y asistentes
		92 = Peones agropecuarios, pesqueros y fores
		93 = Peones de la minería, la construcción,
		94 = Ayudantes de preparación de alimentos
		96 95 = Recolectores de desechos y otras ocupac 
		98 = No aplica
		99 = NS/NR //REVISAR BIEN
		999 = No clasificable
*/
destring cod43, replace
clonevar tarea= cod43 if cod43!=98 & cod43!=999
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
/* CONTRATO_ENCUESTA (tp49): ¿En su trabajo, tienen contrato?
        1 = Formal (contrato firmado por tiempo indefinido)
		2 = Formal (contrato firmado por tiempo determinado)
		3 = Acuerdo verbal? 
		4 = No tiene contrato
		98 = No aplica 
		99 = NS/NR
*/
clonevar contrato_encuesta = tp49 if (tp49!=98 & tp49!=99)
gen     contrato = 1 if relab==2 & (contrato_encuesta== 1 | contrato_encuesta==2)
replace contrato = 0 if relab==2 & (contrato_encuesta== 3 | contrato_encuesta==4)

* Ocupacion permanente
gen     ocuperma = (contrato_encuesta==1) if relab==2 

* Derecho a percibir una jubilacion: djubila
/*APORTE_PENSION (pp62)
        0 = 
		1 = Si, para otra institucion o empresa publica
		2 = Si, para institucion o empresa privada
		98 = No aplica
		99 = NS/NR  
*/
clonevar aporte_pension = pp62 if (pp62!=98 & pp62!=99)
gen     djubila = (aporte_pension==1 | aporte_pension==2) if  relab==2   

* Seguro de salud ligado al empleo: dsegsale
gen     dsegsale = (afiliado_seguro_salud==3 | afiliado_seguro_salud==4) if relab==2 

* Derecho a aguinaldo: aguinaldo
gen     aguinaldo = .
notes aguinaldo: the survey does not include information to define this variable

* Derecho a vacaciones pagas: dvacaciones
gen     dvacaciones = tp50v==1 if ((tp50v!=98 & tp50v!=99) & relab==2) 
notes dvacaciones: the survey does not include information to define this variable

* Sindicalizado: sindicato
gen     sindicato = tp50s==1 if ((tp50s!=98 & tp50s!=99) & relab==2) 

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
tab tp47m tp47 

* Situacion laboral y recepcion de ingresos
tab tp39 tp47
/*                     
                      |   �Cu�nto recibi� en total durante el mes
    La semana pasada |      pasado por el trabajo realizado?
           estaba...? | Si recibi  No recibi  No aplica  No sabe/N |     Total
----------------------+--------------------------------------------+----------
         Trabajando? |     8,389        134          0        731 |     9,254 
No trabaj� pero tien |       352         30          0         42 |       424 
Buscando trabajo por |         0          0        192          0 |       192 
Buscando trabajo hab |         0          0        765          0 |       765 
En quehaceres del ho |         0          0      3,675          0 |     3,675 
         Estudiando? |         0          0      4,415          0 |     4,415 
         Pensionado? |         0          0      1,251          0 |     1,251 
       Incapacitado? |         0          0        308          0 |       308 
     Otra situacion? |         0          0        414          0 |       414 
           No aplica |         0          0      5,101          0 |     5,101 
 No sabe/No responde |         0          0         97          0 |        97 
---------------------+--------------------------------------------+----------
               Total |     8,741        164     16,218        773 |    25,896 

*/


* Se reemplazan como missing NR y NA
replace tp47m = . if tp47m==99 // Cedlas clasifica la NR como missing
replace tp47m = . if tp47m==98 // Los NA como missing?? VER

/*  Solo se incluyen ingresos monetarios
La variable tp47 identifica a los que recibieron ingresos laborales
La variable tp47m menciona los montos recibidos en el mes anterior a la encuesta

ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia*/

*****  i)  PATRON
* Monetario	
* Ingreso monetario laboral de la actividad principal si es patrón
gen     ipatrp_m = tp47m if relab==1  

* No monetario
gen     ipatrp_nm = .	

****  ii)  ASALARIADOS
* Monetario	
* Ingreso monetario laboral de la actividad principal si es asalariado
gen     iasalp_m = tp47m if relab==2

* No monetario
gen     iasalp_nm = .


***** iii)  CUENTA PROPIA
* Monetario	
* Ingreso monetario laboral de la actividad principal si es cuenta propia
gen     ictapp_m = tp47m if relab==3

* No monetario
gen     ictapp_nm = .

***** IV)otros
gen iolp_m = tp47m if relab==4 | ((inlist(tp39,1,2)) & (inlist(tp46,98,99)))
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
/*
gen     ing_nlb = .
replace ing_nlb = 1  if tp48ps==1 // Pension de sobreviviente, orfandad, etc
replace ing_nlb = 2  if tp48ay==2 // Ayuda familiar o de otra persona
replace ing_nlb = 3  if tp48ss==3 // Pension por seguro social
replace ing_nlb = 4  if tp48jv==4 // Jubilación por trabajo
replace ing_nlb = 5  if tp48rp==5 // Renta de propiedades
replace ing_nlb = 6  if tp48id==6 // Intereses o dividendos
replace ing_nlb = 7  if tp48ot==7 // Otros
*/

gen ing_nlb_ps = 1  if tp48ps==1 // Pensión por sobreviviente, orfandad
gen ing_nlb_ay = 1  if tp48ay==2 // Ayuda familiar o de otra persona
gen ing_nlb_ss = 1  if tp48ss==3 // Pension por seguro social
gen ing_nlb_jv = 1  if tp48jv==4 // Jubilación por trabajo
gen ing_nlb_rp = 1  if tp48rp==5 // Renta por priopiedades
gen ing_nlb_id = 1  if tp48id==6 // Intereses o dividendos
gen ing_nlb_ot = 1  if tp48ot==7 // Otros

*Cuantas categorias de ingresos reciben
egen    recibe = rowtotal(ing_nlb_*), mi
tab recibe
/*  
     recibe |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     25,440       98.24       98.24
          1 |        430        1.66       99.90
          2 |         25        0.10      100.00
          3 |          1        0.00      100.00
------------+-----------------------------------
      Total |     25,896      100.00
*/

****** 9.3.1.JUBILACIONES Y PENSIONES ******	  
/*
pp61sm pp61em pp61pm pp61om     // Monto recibido por jubilacion o pension
pp59 = 1    // Jubilado
pp59 = 2    // Pensionado
pp59 = 3    // Jubilado y pensionado 
tp48m       // Monto ingresos no laborales
*/

*Se reemplazan como missing NR y NA
replace tp48m  = . if (tp48m==99 | tp48m==98)

*Jubilaciones y pensiones
* Monetario
* ijubi_m: Ingreso monetario por jubilaciones y pensiones	
clonevar jubi_encuesta_ss = pp61sm if pp61sm!=99 & pp61sm!=98 & pp61sm!=. 
clonevar jubi_encuesta_ep = pp61em if pp61em!=99 & pp61em!=98 & pp61em!=. 
clonevar jubi_encuesta_pr = pp61pm if pp61pm!=99 & pp61pm!=98 & pp61pm!=. 
clonevar jubi_encuesta_ot = pp61om if pp61om!=99 & pp61om!=98 & pp61om!=. 

egen ijubi_m = rowtotal(jubi_encuesta_ss jubi_encuesta_ep jubi_encuesta_pr jubi_encuesta_ot ), mi
replace ijubi_m = tp48m if ijubi_m==. &  (ing_nlb_ps==1 | ing_nlb_jv==1) & recibe==1

* No monetario	
gen     ijubi_nm=.

****** 9.3.2.INGRESOS DE CAPITAL ******	
/*icap_m: Ingreso monetario de capital, intereses, alquileres, rentas, beneficios y dividendos*/
gen     icap_m = .
replace icap_m = tp48m if (ing_nlb_ps!=1 & ing_nlb_ay !=1 & ing_nlb_ss !=1 & ing_nlb_jv !=1 & ing_nlb_ot !=1) & (ing_nlb_rp == 1 | ing_nlb_id == 1)
gen icap_nm =.

****** 9.3.3.REMESAS ******	
/*rem: Ingreso monetario de remesas */
gen     rem = .

****** 9.3.4.TRANSFERENCIAS PRIVADAS ******	
/*TMHP52EF=4 // Ayuda económica de algún familiar o de otra persona en el país
itranp_o_m Ingreso monetario de otras transferencias privadas diferentes a remesas*/
gen     itranp_o_m = .
* No monetario	
gen     itranp_o_nm=. 

****** 9.3.5 TRANSFERENCIAS PRIVADAS ******	
*itranp_ns: Ingreso monetario de transferencias privadas, cuando no se puede distinguir entre remesas y otras
gen itranp_ns = tp48m if (ing_nlb_ps!=1 & ing_nlb_ay == 1 & ing_nlb_ss!=1 & ing_nlb_jv!=1 & ing_nlb_ot!=1 & ing_nlb_rp!=1 & ing_nlb_id!=1)

****** 9.3.6 TRANSFERENCIAS ESTATALES ******	
*HASTA AHORA SOLO SE PUEDEN ENCONTRAR BENEFICIARIOS PERO los montos HABRIA QUE IMPUTARLOS
*cct: Ingreso monetario por transferencias estatales relacionadas con transferencias monetarias condicionadas
*itrane_o_m Ingreso monetario por transferencias estatales diferentes a las transferencias monetarias condicionadas
*itrane_ns Ingreso monetario por transferencias cuando no se puede distinguir
gen     cct = .
gen     itrane_o_m = .
gen     itrane_o_nm = .
gen     itrane_ns = . // SSocial

***** iV) OTROS INGRESOS NO LABORALES 
gen     inla_otro = .
replace inla_otro = tp48m if (ing_nlb_ps!=1 & ing_nlb_ay!=1 & (ing_nlb_ss==1 | ing_nlb_ot==1) & ing_nlb_jv!=1 & ing_nlb_rp!=1 & ing_nlb_id!=1)| (recibe>=3 & recibe!=.) // Otro

/* SON SECUNDARIAS GENERADAS POR LOS DO AUXILIARES
***** V) INGRESOS NO LABORALES EXTRAORDINARIOS 
gen     inla_extraord = .

****** 9.3.7 INGRESOS DE LA OCUPACION PRINCIPAL ******

gen     ip_m = tp47m //	Ingreso monetario en la ocupación principal 
gen     ip   = .	// Ingreso total en la ocupación principal 

****** 9.3.8 INGRESOS TODAS LAS OCUPACIONES ******

gen     ila_m  = tp47m    // Ingreso monetario en todas las ocupaciones 
gen     ila    = .   // Ingreso total en todas las ocupaciones 
gen     perila = .   // Perceptores de ingresos laborales 

****** 9.3.9 INGRESOS LABORALES HORARIOS ******

gen     wage_m= ip_m/(hstrp*4)  // Ingreso laboral horario monetario en la ocupación principal
*gen wage=    // Ingreso laboral horario total en la ocupación principal 
*gen ilaho_m	// Ingreso laboral horario monetario en todos los trabajos 
*gen ilaho   // Ingreso laboral horario total en todos los trabajos 
*/

/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.10: LINEAS DE POBREZA  -------------------------------------------------------------
************************************************************************************************************************************************)*/

tab pobreza if pobreza!=99 [aw=pondera]
/*
     Pobreza por |
        ingresos |      Freq.     Percent        Cum.
-----------------+-----------------------------------
        No pobre | 3,364.8684       12.99       12.99
Pobre no extremo | 6,677.4489       25.79       38.78
   Pobre extremo | 13,186.917       50.92       89.70
    No declarado | 2,666.7656       10.30      100.00
-----------------+-----------------------------------
           Total |     25,896      100.00
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
tab pobreza_enc [aw=pondera]
/*
pobreza_enc |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 3,423.9353       14.49       14.49
          1 | 20,213.065       85.51      100.00
------------+-----------------------------------
      Total |     23,637      100.00
*/


/*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- 1.1: PRECIOS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/
* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .

* IPC del mes base
gen ipc = 103801.1			/*  MES BASE: promedio Enero-Diciembre			*/

gen cpiperiod = "2016m01-2016m12"

gen     ipc_rel = 1
/*
replace ipc_rel = 1 if  mes==1
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


*******RENTA IMPUTADA********
*al no tener datos de pago de alquieleres para estimar el valor del alquier imputado usamos una regla ad hoc de aumentar 10% del ingreso		
/* TENENCIA_VIVIENDA (hp13): régimen de tenencia de la vivienda 
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

gen aux_propieta_no_paga = 1 if tenencia_vivienda==1| tenencia_vivienda==6 |(tenencia_vivienda==8 & hp13ot_cod==2)
replace aux_propieta_no_paga = 0 if (tenencia_vivienda>=2 & tenencia_vivienda<=5)| (tenencia_vivienda>=7) |(tenencia_vivienda==8 & inlist(hp13ot_cod,4,5,7))
bysort id: egen propieta_no_paga = max(aux_propieta_no_paga)

gen     renta_imp = .
replace renta_imp = 0.10*itf_sin_ri  if  propieta_no_paga == 1

replace renta_imp = renta_imp / p_reg 
replace renta_imp = renta_imp / ipc_rel 


include "$aux_do\do_file_2_variables.do"
include "$aux_do\labels.do"
compress

/*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- QUALITY CHECKS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/

/*
* analisis de no ingreso
*a) total 2644
tab pobreza_enc if (ipcf==. | ipcf==0)
*b) exclusion hogares secundarios XX
tab pobreza_enc if ((ipcf==. | ipcf==0) & hogarsec==1)
*c) reporta trabajo pero no de que se desempeña (patron, empleado, etc). Se lo envió a la categoría otros 
tab pobreza_enc if (ipcf==. | ipcf==0) & (inlist(tp39,1,2)&(tp46==99)&(tp47m)>0)

bro id relacion ipcf tp39 tp45 tp46 tp47 tp47m tp48m pp61*m relab ipatrp_m iasalp_m ictapp_m iolp_m ip_m ii itf_sin_ri itf_m perii hogarsec if (ipcf==. | ipcf==0)		
*/
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
pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg /*ipc*/ pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i /*ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/  

save "$dataout\base_out_nesstar_cedlas_2016.dta", replace // poner el año que corresponde
