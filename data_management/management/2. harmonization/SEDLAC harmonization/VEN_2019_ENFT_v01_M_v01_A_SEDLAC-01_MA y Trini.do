/*===========================================================================
Country name:	Venezuela
Year:			2019/2020
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		February, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user (silenced as this is done by main now)
/*
 	    * User 1: Trini
 		global trini 0
		
 		* User 2: Julieta
 		global juli   0
		
 		* User 3: Lautaro
 		global lauta  0
		
 		* User 4: Malena
 		global male   1
		
 		if $juli {
  				global dopath "C:\Users\wb563583\GitHub\VEN"
  				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
  		}
  	    if $lauta {
 				global dopath "C:\Users\wb563365\GitHub\VEN"
 				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
 		}
  		if $trini   {
  		}
  		if $male   {
  				global dopath "C:\Users\wb550905\Github\VEN"
  				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
 		}

		
// Set output data path
*Inputs
global merged "$datapath\data_management\output\merged"
*Outputs
global cleaned "$datapath\data_management\output\cleaned"
*/
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

local country  "VEN"    // Country ISO code
local year     "2019"   // Year of the survey
local survey   "ENCOVI"  // Survey acronym
local vm       "01"     // Master version
local va       "01"     // Alternative version
local project  "03"     // Project version
local period   ""       // Periodo, ejemplo -S1 -S2
local alterna  ""       // 
local vr       "01"     // version renta

/*==================================================================================================================================================
								1: Data preparation: First-Order Variables
==================================================================================================================================================*/

* The other do-file, with all the ENCOVI data (not SEDLAC harmonization) imports exchange rates and inflation at first, 
* this one won't do it as we will merge all the income agreggates from the other, more complete, database

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Open Databases  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
*Generate unique household identifier by strata
use "$merged\household.dta", clear
tempfile household_hhid
sort combined_id, stable
by combined_id: gen hh_by_combined_id = _n
save `household_hhid'

* Open "output" database
use "$merged\individual.dta", clear
merge m:1 interview__key interview__id quest using `household_hhid'
drop _merge
* I drop those who do not collaborate in the survey
drop if colabora_entrevista==2

*Obs: the is 1 observation which does not merge. Maybe they are people who started to answer but then stopped answering

*Change names to lower cases
rename _all, lower

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables --------------------------------------------------
*************************************************************************************************************************************************)*/

* Country identifier:		pais
	gen pais = "VEN"

* Country identifier:		ano
	capture drop ano
	gen ano = 2019

* Survey identifier:		encuesta
	gen encuesta = "ENCOVI - 2019"

* Household identifier:		id
	**Variables id_hh, hhid, id_str were generated for the listing, we shouldn't use them to generate id
	
	*combined_id concatenates 5 variables: entidad, municipio, parroquia, centro poblado, segmento
	*It has 11 or 12 characters, we add 0 to the ones which have 11 so they are all the same length
	replace combined_id = "0"+combined_id if substr(combined_id, 1,1)==string(entidad) & length(combined_id)==11 
	*Obs: when uploading the data, ENSURE ANNONIMITY (because combined_id makes families identifiable) 
	tostring hh_by_combined_id, replace
	*Up to 10 hh by combined_id
	replace hh_by_combined_id = "0"+hh_by_combined_id if length(hh_by_combined_id)==1
	gen id = combined_id + hh_by_combined_id 
	
* Component identifier: com
	** ENCOVI 2018 used "lin" (número de linea) which seems to be a created variable
	
	* Ensuring the order of household members is always the same: sort in ascending order of id, descending order of age, ascending order of random variable (in case 2 people in the same hh have same age)
		*Id
		gen id_numeric=id
		destring id_numeric, replace
		format id_numeric %14.0f
		*Age
			clonevar edad = s6q5 if (s6q5!=. & s6q5!=.a)
		* Sex 
			/* SEXO (s6q3): El sexo de ... es
				1 = Masculino
				2 = Femenino
			*/
			gen hombre = (s6q3==1) if (s6q3!=. & s6q3!=.a)
			label define hombre 1 "Masculino" 0 "Femenino"
			label value hombre hombre
		* Name
			clonevar nombre = s6q1
		*Random var
		sort interview__key interview__id quest edad hombre nombre, stable
		set seed 123
		generate z = runiform()
		sort z 
		*Sorting
		gsort id_numeric -edad z
		egen min =  min(_n), by(id)
		replace min = -min
		
	gen com  = _n + min + 1
		drop z min
	
	duplicates report id com //verification

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

*** Weights/Factor de ponderacion: pondera

merge m:1 interview__key interview__id using "$merged\final_encovi_weights.dta" // Sent by Michael and modified by Daniel on April 30th
drop _merge

	* Individual weights
		gen pondera = encovi_pw
		replace pondera = round(pondera) // some commands later cannot work with non-integer weights
		
	* Household weights
		sort interview__key interview__id quest relacion_en, stable
		by interview__key interview__id quest: replace encovi_w=. if _n!=1
			*Obs: we did it in this way instead of:
				*gen pondera_hh = encovi_w if relacion_en==1
			*Because there was one household which did not have "jefe de hogar" - one we have fixed it though. check for the fix:
				/*Check:
				gen primeroqueaparece=.
				sort id relacion_en, stable
				by id: replace primeroqueaparece = relacion_en[1]
				tab primeroqueaparece if relacion_en!=1
				*Its okay!
				*/
		gen pondera_hh=encovi_w 
		replace pondera_hh = round(pondera_hh) // some commands later cannot work with non-integer weights
	
	* Checking population estimates
		gen uno=1
		*	Population
		sum uno [w=pondera] , detail 	// 24.9 M de personas
		*	Households
		sum uno [w=pondera_hh] , detail	// 6.5 M de hogares
		drop uno
		
* Estrato: strata
	gen strata = . // problem: we don't know how they were generated. We believe they were socioeconomic (AB, C, D, EF; not geographic) but not done statistically. If so, we should delete them from the Datalib uploaded database 
	**In ENCOVI 2019 there are 2 strata, geographical, by size of the segment. Check later with Daniel

* Unidad Primaria de Muestreo: psu  
gen psu = combined_id


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Demographic variables  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_SEDLAC relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua

* Relation to the head:	relacion
* Done above

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
*clonevar sexo = s6q3 if s6q3!=. & s6q3!=.a
*gen 	hombre = 0 if sexo==2
*replace hombre = 1 if sexo==1

* Años cumplidos: edad
* EDAD_ENCUESTA (s6q5): Cuantos años cumplidos tiene?
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
global regional_SEDLAC // completar

* Creación de Variable Geográficas Desagregadas
	
* Desagregación 1 (Regiones politico-administrativas): region_est1
/* Las  categorias de la variable original entidad son las siguientes:
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

* Generamos las regiones, la base es representativa al nivel de region

gen     region_est1 =  1 if entidad==5 | entidad==8 | entidad==13					// Region Central: Aragua (5), Carabobo (8), Lara (13)
replace region_est1 =  2 if entidad==12 | entidad==4 | entidad==6          			// Region LLanera: Guarico (12), Apure (4), Barinas (6)
replace region_est1 =  3 if entidad==9 | entidad==11 | entidad==18 | entidad==22	// Region Occidental: Cojedes (9), Falcon (11), Portuguesa (18), Yaracuy (22)
replace region_est1 =  4 if entidad==23												// Region Zuliana: Zulia (23)
replace region_est1 =  5 if entidad==14 | entidad==20 | entidad==21					// Region Andina: Merida (14), Tachira (20), Trujillo (21)
replace region_est1 =  6 if entidad==3 | entidad==7 | entidad==16 | entidad==17 | entidad==19	// Region Oriental: Bolivar (7), Anzoategui (3), Monagas (16), Nueva Esparta (17), Sucre (19)
replace region_est1 =  7 if entidad==15 | entidad==24 | entidad==1					// Region Capital: Distrito Capital (1), Miranda (15), Vargas (24) 
label var region_est1 "Region"
label def region_est1 1 "Region Central"  2 "Region Llanera" 3 "Region Occidental" 4 "Region Zuliana" ///
          5 "Region Andina" 6 "Region Nor-Oriental" 7 "Capital"
label value region_est1 region_est1
* Obs: Delta Amacuro and Amazonas were not surveyed.

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
replace   cen = 1 if enti==13 // Lara
replace   cen = 0 if enti!=5 & enti!=8 & enti!=13 & enti!=.
label var  cen   "Region Central"

*2. Región LLanera
gen       lla = .
replace   lla = 1 if enti==12 // Guarico
replace   lla = 1 if enti==4  // Apure
replace   lla = 1 if enti==6  // Barinas
replace   lla = 0 if enti!=12 & enti!=4 & enti!=6 & enti!=.
label var  lla   "Region Los Llanos"

*3. Región Centro-Occidental o Occidental
gen       ceo = .
replace   ceo = 1 if enti==11 // Falcon
replace   ceo = 1 if enti==9  // Cojedes
replace   ceo = 1 if enti==18 // Portuguesa
replace   ceo = 1 if enti==22 // Yaracuy
replace   ceo = 0 if enti!=11 & enti!=9 & enti!=18 & enti!=22 & enti!=.
label var  ceo   "Region (Centro)Occidental"

*4. Región Zuliana: Zulia
gen       zul = .
replace   zul = 1 if enti==23 // Zulia
replace   zul = 0 if enti!=23 & enti!=.
label var  zul   "Region Zuliana"

*5. Región Andina
gen       and = .
replace   and = 1 if enti==14 // Merida
replace   and = 1 if enti==20 // Tachira 
replace   and = 1 if enti==21 // Trujillo
replace   and = 0 if enti!=14 & enti!=20 & enti!=21 & enti!=.
label var  pais   "Region Andina"

*6. Región Nor-Oriental
gen       nor = .
replace   nor = 1 if enti==3  // Anzoategui
replace   nor = 1 if enti==7  // Bolivar
replace   nor = 1 if enti==16 // Monagas
replace   nor = 1 if enti==17 // Nueva Esparta
replace   nor = 1 if enti==19 // Sucre
replace   nor = 0 if enti!=3 & enti!=7 & enti!=16 & enti!=17 & enti!=19 & enti!=.
label var  nor   "Region (Nor)Oriental"

*7. Región Capital
gen       capital = .
replace   capital = 1 if enti==15  // Miranda
replace   capital = 1 if enti==24  // Vargas
replace   capital = 1 if enti==1  // Distrito Capital
replace   capital = 0 if enti!=15 & enti!=24 & enti!=1 & enti!=.
label var  capital   "Region Capital"

* Areas no incluidas en años previos:	nueva_region
* gen       nuevareg = .
* No hay observaciones 

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
*/

clonevar tenencia_vivienda = s5q7 if (s5q7!=. & s5q7!=.a)
gen     propieta = 1		if  tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==5 | tenencia_vivienda==6  // Daniel: "Ambos tienen título de propiedad. Una es financiada, y otra es regalada" 
replace propieta = 0		if  tenencia_vivienda==3 | tenencia_vivienda==4 | tenencia_vivienda>=7 & tenencia_vivienda<=10
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
*--------------------------------------------------------- 1.5: Durable goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/
global durables_SEDLAC // completar

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
gen anio_auto= s5q5 if s5q4==1 & (s5q5!=. & s5q5!=.a)
gen   ant_auto = ano-anio_auto
replace ant_auto= . if ant_auto<0

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

/* NIVEL_EDUC_EN (s7q11): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  
		1 = Ninguno		
        2 = Preescolar
		3 = Regimen anterior: Basica (1-9)
		4 = Regimen anterior: Media (1-3)
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado			
* G_EDUC (s7q11a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* A_EDUC (s7q4b): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
* S_EDUC (emhp27c): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
* T_EDUC (emhp27d): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
* NIVEL_EDUC: ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
*/
clonevar nivel_educ_en = s7q11 if s7q1==1 & (s7q11!=. & s7q11!=.a) & edad>3
gen     g_educ = s7q11a        if s7q1==1 & (s7q11==3 | s7q11==4 | s7q11==5 | s7q11==6) & (s7q11a!=. & s7q11a!=.a) & edad>3
replace g_educ=3               if s7q11a>3 & s7q11==4
gen a_educ = s7q11b    if s7q1==1 & (s7q11==7 | s7q11==8 | s7q4==9) & s7q11ba==1 & (s7q11b!=. & s7q11b!=.a) //for those who study or studied tertiary education on annual basis, there are individuals in categories 4 and 6 who replied this question
gen s_educ = s7q11c    if s7q1==1 & (s7q11==7 | s7q11==8 | s7q4==9) & s7q11ba==2 & (s7q11c!=. & s7q11c!=.a) //for those who study or studied tertiary education on biannual basis
gen t_educ = s7q11d    if s7q1==1 & (s7q11==7 | s7q11==8 | s7q4==9) & s7q11ba==3 & (s7q11d!=. & s7q11d!=.a) //for those who study or studied tertiary education on quarterly basis

gen nivel_educ = 1 if nivel_educ_en==1
replace nivel_educ = 2 if nivel_educ_en==2 
replace nivel_educ = 3 if nivel_educ_en==3 | nivel_educ_en==5
replace nivel_educ = 4 if nivel_educ_en==4 | nivel_educ_en==6
replace nivel_educ = 5 if nivel_educ_en==7
replace nivel_educ = 6 if nivel_educ_en==8
replace nivel_educ = 7 if nivel_educ_en==9
label def nivel_educ 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
label value nivel_educ nivel_educ

* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (g_educ>=2 & g_educ<=9)) | (nivel_educ>=4 & nivel_educ<=7)
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

gen     aedu = 0	if  nivel_educ_en==1 | nivel_educ_en==2
replace aedu = 0	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==0

replace aedu = 1	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==1
replace aedu = 2	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==2
replace aedu = 3	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==3
replace aedu = 4	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==4
replace aedu = 5	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==5
replace aedu = 6	if  (nivel_educ_en==3 | nivel_educ_en==5) & g_educ==6

replace aedu = 7	if  nivel_educ_en==3 & g_educ==7
replace aedu = 8	if  nivel_educ_en==3 & g_educ==8
replace aedu = 9	if  nivel_educ_en==3 & g_educ==9
replace aedu = 10	if  nivel_educ_en==4 & g_educ==1
replace aedu = 11	if  nivel_educ_en==4 & g_educ==2
replace aedu = 12	if  nivel_educ_en==4 & g_educ==3

replace aedu = 7	if  nivel_educ_en==6 & g_educ==1
replace aedu = 8	if  nivel_educ_en==6 & g_educ==2
replace aedu = 9	if  nivel_educ_en==6 & g_educ==3
replace aedu = 10	if  nivel_educ_en==6 & g_educ==4
replace aedu = 11	if  nivel_educ_en==6 & g_educ==5
replace aedu = 12	if  nivel_educ_en==6 & g_educ==6

replace aedu = 12	if (nivel_educ_en==7 | nivel_educ_en==8 ) & (a_educ==0 | s_educ<=1 | t_educ<=2)	 
replace aedu = 13	if  nivel_educ_en==7 & (a_educ==1 | (s_educ>=2 & s_educ<=3) | (t_educ>=3 & t_educ<=5))
replace aedu = 14	if  nivel_educ_en==7 & (a_educ==2 | (s_educ>=4 & s_educ<=5) | (t_educ>=6 & t_educ<=8))
replace aedu = 15	if  nivel_educ_en==7 & (a_educ==3 | s_educ==6 | t_educ==9)
               
replace aedu = 13	if  nivel_educ_en==8 & (a_educ==1 | (s_educ>=2 & s_educ<=3)   | (t_educ>=3 & t_educ<=5))
replace aedu = 14	if  nivel_educ_en==8 & (a_educ==2 | (s_educ>=4 & s_educ<=5)   | (t_educ>=6 & t_educ<=8))
replace aedu = 15	if  nivel_educ_en==8 & (a_educ==3 | (s_educ>=6 & s_educ<=7)   | (t_educ>=9 & t_educ<=11))
replace aedu = 16	if  nivel_educ_en==8 & (a_educ==4 | (s_educ>=8 & s_educ<=9)   | (t_educ>=12 & t_educ<=14))
replace aedu = 17	if  nivel_educ_en==8 & (a_educ==5 | (s_educ>=10 & s_educ<=11) | (t_educ>=15 & t_educ<=17))
replace aedu = 18	if  nivel_educ_en==8 & (a_educ==6 | (s_educ>=12 & s_educ<=13) | (t_educ>=18 & t_educ<=20))
replace aedu = 19	if  nivel_educ_en==8 & (a_educ==7 | s_educ==14 | t_educ==21)

replace aedu = 17   if  nivel_educ_en==9 & (a_educ==0 | s_educ<=1 | t_educ<=2) //we are considering that the average of tertiary (university) education is five years  
replace aedu = 18   if  nivel_educ_en==9 & (a_educ==1 | (s_educ>=2 & s_educ<=3) | (t_educ>=3 & t_educ<=5))
replace aedu = 19	if  nivel_educ_en==9 & (a_educ==2 | (s_educ>=4 & s_educ<=5) | (t_educ>=6 & t_educ<=8))
replace aedu = 20	if  nivel_educ_en==9 & (a_educ==3 | (s_educ>=6 & s_educ<=7) | (t_educ>=9 & t_educ<=11))
replace aedu = 21	if  nivel_educ_en==9 & (a_educ==4 | (s_educ>=8 & s_educ<=9) | (t_educ>=12 & t_educ<=14))
replace aedu = 22	if  nivel_educ_en==9 & (a_educ==5 | (s_educ>=10 & s_educ<=11) | (t_educ>=15 & t_educ<=17))
replace aedu = 23	if  nivel_educ_en==9 & (a_educ==6 | s_educ==12 | t_educ==18)
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

gen     nivel = 0	if  nivel_educ_en==1 | nivel_educ_en==2
replace nivel = 1	if  nivel_educ_en==3 & g_educ<=8
replace nivel = 1	if  nivel_educ_en==5 & g_educ<=5
replace nivel = 2	if  nivel_educ_en==3 & g_educ==9
replace nivel = 2	if  nivel_educ_en==5 & g_educ==6 
replace nivel = 3	if  nivel_educ_en==4 & g_educ<=2
replace nivel = 3	if  nivel_educ_en==6 & g_educ<=5
replace nivel = 4	if  nivel_educ_en==4 & g_educ==3
replace nivel = 4	if  nivel_educ_en==6 & g_educ==6
replace nivel = 5   if (nivel_educ_en==7 & (a_educ<=2 | s_educ<=5 | t_educ<=8)) | (nivel_educ_en==8 & (a_educ<=4 | s_educ<=9 | t_educ<=14)) // Consideramos tecnica completa si completo almenos 6 semestres y universitaria completa si completo al menos 10 semestres
replace nivel = 6   if (nivel_educ_en==7 & (a_educ==3 | s_educ==6 | t_educ==9)) | (nivel_educ_en==8 & ((a_educ>=5 & a_educ!=.) | (s_educ>=10 & s_educ!=.) | (t_educ>=15 & t_educ!=.))) | nivel_educ_en==9
notes nivel: variable defined for individuals aged 3 and older 

label def nivel 0 "Nunca asistio" 1 "Primario Incompleto" 2 "Primario Completo" 3 "Secundario Incompleto" 4 "Secundario Completo" ///
                5 "Superior Incompleto" 6 "Superior Completo"
label value nivel nivel

tab nivel_educ_en
sum aedu
tab nivel
*brow id pid nivel_educ_en g_educ a_educ s_educ if nivel!=. & aedu==. // se pierden 165 obs que reportan nivel_educ, pero no reportan a_educ o s_educ segun corresponde

* Nivel educativo: niveduc
/*   0 = baja educacion  (menos de 9 años)      
     1 = media educacion (de 9 a 13 años)
     2 = alta educacion  (mas de 13 años) 
*/
gen     nivedu = 1 if aedu<9
replace nivedu = 2 if aedu>=9 & aedu<=13
replace nivedu = 3 if aedu>13 & aedu!=.

*label def nivedu 0 "Baja educacion (menos de 9 años)" 1 "Media educacion (de 9-13 años)" 2 "Alta educacion (mas de 13 años)"
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
*------------------------------------------------------------- 1.7: Health Variables ---------------------------------------------------------------
************************************************************************************************************************************************)*/
global salud_SEDLAC seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///

* Seguro de salud: seguro_salud
	/* s8q17: ¿está afiliado a algún seguro medico?
			1 = si
			2 = no
			99 = NS/NR 
	*/
gen     seguro_salud = 1	if  s8q17==1
replace seguro_salud = 0	if  s8q17==2

* Tipo de seguro de salud: tipo_seguro
	/*  0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
        1 = si esta afiliado a algun seguro de salud privado
	*/
	/* s8q18: ¿Con cuál seguro médico está afiliado? 
		1 = Instituto Venezolano de los Seguros Sociales (IVSS)
	    2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
	    3 = Seguro medico contratado por institucion publica
	    4 = Seguro medico contratado por institucion privada
	    5 = Seguro medico privado contratado de forma particular
	 */
gen afiliado_segsalud = 1     if s8q18==1 
replace afiliado_segsalud = 2 if s8q18==2 
replace afiliado_segsalud = 3 if s8q18==3 
replace afiliado_segsalud = 4 if s8q18==4
replace afiliado_segsalud = 5 if s8q18==5
replace afiliado_segsalud = 6 if s8q17==2
label define afiliado_segsalud 1 "Instituto Venezolano de los Seguros Sociales (IVSS)" 2 "Instituto de prevision social publico (IPASME, IPSFA, otros)" ///
3 "Seguro medico contratado por institucion publica" 4 "Seguro medico contratado por institucion privada" 5 "Seguro medico privado contratado de forma particular" ///
6 "No tiene plan de seguro de atencion medica"

gen 	tipo_seguro = 0     if  (afiliado_segsalud>=1 & afiliado_segsalud<=4) 
replace tipo_seguro = 1     if  afiliado_segsalud==5 //SOLO 5 o 4 y 5?

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
gen     control_embarazo=. 
notes control_embarazo: the survey does not include information to define this variable

* Lugar control del embarazo: lugar_control_embarazo
/*      1 = si el control del embarazo fue en un lugar privado
        0 = si el control del embarazo fue en un lugar publico o vinculado al trabajo (obra social)
*/
gen     lugar_control_embarazo=.
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
*Obs: Refers to last 30 days

* ¿Por que no consulto al medico?: razon_no_medico
/*     1 = si no consulto al medico por razones economicas
       0 = si no consulto al medico por razones no economicas
*/

	/* s8q4 Razón por la cual no consultó para tratarse 
			1 = Se automedicó, utilizó remedios caseros
			2 = No tiene dinero para pagar consulta, exámenes, medicinas
			3 = No lo consideró necesario, no hizo nada
			4 = Lugar de atención queda lejos del domicilio
			5 = La atención no es adecuada
			6 = Hay que esperar mucho tiempo
			7 = No lo atendieron
			8 = Otra
	*/

gen    razon_no_medico = 1 if s8q4==2 & (s8q1==1 & s8q3==2)
replace razon_no_medico = 0	if (s8q4==1 | s8q4>=3 & s8q4<=8) & s8q1==1
*Assumption: We included "4. Lugar de atencion queda lejos del domicilio" in "not economic" but are aware it could be argued it could be linked to economic issues... However, till Feb 25 2020 les than 1% of respondants of this question chose option 4.

* Lugar de ultima consulta: lugar_consulta
/*     1 = si el lugar de la ultima consulta es privado
       0 = si el lugar de la ultima consulta es publico o vinculado al trabajo
*/
	/* s8q6: ¿Dónde acudió para su atención? 
		1 = Ambulatorio/clínica popular/ CDI
		2 = Hospital público o del Seguro Social
		3 = Servicio privado sin hospitalización
		4 = Clínica privada
		5 = Centro de salud privado sin fines de lucro
		6 = Servicio médico en el lugar de trabajo
		7 = Farmacia
		8 = Otro
	 */
gen    lugar_consulta = 1 if s8q6>=3 & s8q6<=5 & (s8q1==1 & s8q3==1)
replace lugar_consulta = 0	if s8q6<=2 | s8q6==6 & (s8q1==1 & s8q3==1)
*Doubt: What to do with "Farmacia" (MA thinks they are private, TS had coded as not) and "Otro" (s8q6_os allows them to specify - could be coded once we have it)? 
*Assumption: at least for now we will leave them as missing

* Pago de la ultima consulta: pago_consulta
/*     1 = si el pago de la ultima consulta fue privado
       0 = si el pago de la ultima consulta es publico o vinculado al trabajo
*/
gen    pago_consulta = 1 if s8q7==1 & (s8q1==1 & s8q3==1)
replace pago_consulta = 0	if  s8q7==2 & (s8q1==1 & s8q3==1)
*Assumption: we understand private payments as "pocket payments" (even done in public places or your places linked to work, as they may pay for one part and you pay for another). Thus we dont mix it with lugar_consulta

* Tiempo que tardo en llegar al medico medido en horas: tiempo_consulta
gen    tiempo_consulta = .
notes tiempo_consulta: the survey does not include information to define this variable

* ¿Obtuvo remedios prescriptos?: obtuvo_remedio
	/*     1 = si obtuvo medicamentos prescriptos
		   0 = si no obtuvo medicamentos prescriptos
	*/

		/* s8q9: ¿Se recetó algún medicamento para la enfermedad o accidente? 
			1 = Si
			2 = No
			
		*s8q10: ¿Cómo obtuvo los medicamentos?
			1 = Los recibió todos gratis
			2 = Recibió algunos gratis y otros los compró
			3 = Los compró todos
			4 = Compró algunos
			5 = Recibió algunos gratis y los otros no pudo comprarlos
			6 = No pudo obtener ninguno
		 */
	gen     receto_remedio=.
	replace receto_remedio=s8q9==1 if (s8q1==1 & s8q3==1)

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

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.8: Labor Variables ---------------------------------------------------------------
*************************************************************************************************************************************************)*/
global labor_SEDLAC // completar

*Notes: interviews done if age>9

* Relacion laboral en su ocupacion principal: relab
/* LABOR_STATUS: La semana pasada estaba:
        1 = Trabajando
		2 = No trabajó, pero tiene trabajo
		
		3 = Buscando trabajo (antes esto se subdividía entre 3."por primera vez" y 4."habiendo trabajado antes")
		
		5 = En quehaceres del hogar
		6 = Incapacitado
		7 = Otra situacion
		8 = Estudiando o de vacaciones escolares
		9 = Pensionado o jubilado
	*/
	gen labor_status = 1 if s9q1==1 | s9q2==1 | s9q2==2 | s9q5==1
	*Assumption: if someone received a wage or benefits last week, we consider he has worked 
	replace labor_status = 2 if s9q2==3 & s9q3==1
	replace labor_status = 3 if s9q3==2 & (s9q6==1 | (s9q6==2 & s9q7==1) )
	replace labor_status = 5 if s9q3==2 & (s9q6==1 | (s9q6==2 & s9q7==2) ) & s9q12==3
	replace labor_status = 6 if s9q3==2 & (s9q6==1 | (s9q6==2 & s9q7==2) ) & (s9q12==7 | s9q12==8)
	replace labor_status = 7 if s9q3==2 & (s9q6==1 | (s9q6==2 & s9q7==2) ) & (s9q12==2 | s9q12==4 | s9q12==9 | s9q12==10 | s9q12==11)
	replace labor_status = 8 if s9q3==2 & (s9q6==1 | (s9q6==2 & s9q7==2) ) & s9q12==1
	replace labor_status = 9 if s9q3==2 & (s9q6==1 | (s9q6==2 & s9q7==2) ) & s9q12==6
	tab labor_status

/* CATEG_OCUP (s9q15): En su trabajo se desempena como
        1 = Empleado u obrero en el sector publico
		3 = Empleado u obrero en empresa privada
		5 = Patrono o empleador
		6 = Trabajador por cuenta propia
		7 = Miembro de cooperativas
		8 = Ayudante familiar remunerado/no remunerado
		9 = Servicio domestico
	*/
	gen categ_ocu = s9q15 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //what comes after the "if" means being economically active

/* RELAB:
        1 = Empleador
		2 = Empleado (asalariado)
		3 = Independiente (cuenta propista)
		4 = Trabajador sin salario
		5 = Desocupado
		. = No economicamente activos
	*/
	gen     relab = .
	replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  // Employer 
	replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee. Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
	replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6)  //self-employed 
	replace relab = 4 if (labor_status==1 | labor_status==2) & categ_ocu== 8 //unpaid family worker
	replace relab = 2 if (labor_status==1 | labor_status==2) & (categ_ocu== 8 & (s9q19__1==1 | s9q19__2==1 | s9q19__3==1 | s9q19__4==1 | s9q19__5==1 | s9q19__6==1 | s9q19__7==1 | s9q19__8==1 | s9q19__9==1 | s9q19__10==1 | s9q19__11==1 | s9q19__12==1)) //paid family worker
	replace relab = 5 if (labor_status==3)

	gen relab_s = .
	gen relab_o = .
	
* Duracion del desempleo: durades (en meses)
	/* cuando_buscotr (s9q8): ¿Cuándo fue la ultima vez que hizo diligencias para conseguir trabajo o establecer un negocio solo o asociado?
			1 = En los últimos 2 meses
			2 = En los últimos 12 meses
			3 = Hace mas de un año
			4 = No hizo diligencias
	*/
	gen cuando_buscotr = s9q8 if (s9q6==2 & s9q7==2 & s9q3==2 & s9q1==2 & s9q2==3)

	gen     durades = 0   if relab==5
	replace durades = 1   if relab==5 & cuando_buscotr==1
	replace durades = 6 if relab==5 & cuando_buscotr==2
	replace durades = 13  if relab==5 & cuando_buscotr==3 
	*Assumption: we complete with 13 months when more than 12 months

* Horas trabajadas totales y en ocupacion principal: hstrt y hstrp

	* s9q18: ¿Cuántas horas trabaja a la semana en todos sus trabajos o negocios?
	gen      hstrt = . 
	replace  hstrt = s9q16 if (relab>=1 & relab<=4) & (s9q16>=0 & s9q16!=.) & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //the last parenthesis means being economically active
	replace  hstrt = s9q18 if s9q17==1 & (relab>=1 & relab<=4) & (s9q18>=0 & s9q18!=.) & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) // para los que tienen dos trabajos
	
	* s9q16: ¿Cuántas horas trabajó durante la semana pasada en su ocupación principal?
	gen      hstrp = . 
	replace  hstrp = s9q16 if (relab>=1 & relab<=4) & (s9q16>=0 & s9q16!=.) & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //the last parenthesis means being economically active

	*Problem: it should not be possible but there is at least one case in which the total hours worked appears to be greater than the hours worked for the main job

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
	/* DESEAMASHS (s9q31): ¿Preferiria trabajar mas de 35 horas por semana?
	   BUSCAMASHS (s9q32): ¿Ha hecho algo parar trabajar mas horas?
	   CAMBIOTR (s9q34): ¿Ha cambiado de trabajo durante los últimos meses?
	*/
	gen deseamashs = s9q31 if s9q18<35 & (s9q31!=. & s9q31!=.a) // Only asked if capi4==true, i.e. s9q18<35 , worked less than 35 hs -> worked part-time
	gen buscamashs = s9q32 if s9q18<35 & (s9q32!=. & s9q32!=.a) // Only asked if capi4==true, i.e. s9q18<35 , worked less than 35 hs -> worked part-time
	*Assumption: only part-time workers can want to work more
	
	gen cambiotr = s9q34 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //what comes after the "if" means being economically active

	gen     deseamas = 0 if (relab>=1 & relab<=4)
	replace deseamas = 1 if deseamashs==1 | buscamashs==1 

* Antiguedad: antigue
	gen     antigue = .
	notes   antigue: the survey does not include information to define this variable

* Asalariado en la ocupacion principal: asal
	* Dummy "asalariado" entre trabajadores
	gen     asal = (relab==2) if (relab>=1 & relab<=4)

* Tipo de empresa: empresa 
	/*      1 = Empresa privada grande (mas de cinco trabajadores)
			2 = Empresa privada pequena (cinco o menos trabajadores)
			3 = Empresa publica
	*/
	gen empresa = .
	notes empresa: the survey does not include information to define this variable

* Grupos de condicion laboral: grupo_lab
	/*      1 = Patrones //formal
			2 = Trabajadores asalariados en empresas grandes //formal
			3 = Trabajadores asalariados en el sector publico //formal
			4 = Trabajadores independientes profesionales (educacion superior completa) //formal
			5 = Trabajadores asalariados en empresas pequenas //informal
			6 = Trabajadores independientes no profesionales  //informal
			7 = Trabajadores sin salario                      //informal
	*/
	
	/*		gen     grupo_lab = 1		if  relab==1 
			replace grupo_lab = 2		if  relab==2 & empresa==1
			replace grupo_lab = 3		if  relab==2 & empresa==3
			replace grupo_lab = 4		if  relab==3 & supc==1 
			replace grupo_lab = 5		if  relab==2 & empresa==2 
			replace grupo_lab = 6		if  relab==3 & supc~=1 
			replace grupo_lab = 7		if  relab==4
	*/
	
	gen     grupo_lab = .
	notes grupo_lab: the survey does not include information to define this variable

* Categorias de condicion laboral: categ_lab
/*      1 = Trabajadores considerados formales bajo definicion en grupo_lab 
        2 = Trabajadores considerados informales o de baja productividad
*/
/*		gen     categ_lab = 1		if  grupo_lab>=1 & grupo_lab<=4
		replace categ_lab = 2		if  grupo_lab>=5 & grupo_lab<=7
*/
	gen     categ_lab = .
	notes categ_lab: the survey does not include information to define this variable

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
* SECTOR_ENCUESTA (s9q14): ¿A que se dedica el negocio, organismo o empresa en la que trabaja?
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
*/
	clonevar sector_encuesta = s9q14 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //what comes after the "if" means being economically active

	gen     sector1d = .
	notes sector1d: the survey does not include information to define this variable

	rename sector secturbabarr
	*The database already had a variable called "sector", referring to the sector, urbanization or neighborhood. We rename that one to leave only one "sector"
	
	gen     sector = .
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

* Tarea que desempeña: tarea
	/* TAREA (s9q13): ¿Cuál es el oficio o trabajo que realiza?
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
	*/
	clonevar tarea= s9q13 if (relab>=1 & relab<=4) & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //the last parenthesis means means being economically active

*Características del empleo y acceso a beneficios a partir del empleo
*Nota: Las variables referidas al acceso a beneficios laborales se construyen solo para trabajadores asalariados

* Workers with contract:  contrato
	gen     contrato = .
	notes contrato: the survey does not include information to define this variable

* Permanent occupation
	gen     ocuperma = .
	notes ocuperma: the survey does not include information to define this variable

* Right to receive retirement benefits: djubila
	/*APORTE_PENSION (created using s9q36 & s9q37__* to match previous ENCOVIs)
			1 = Si, para el IVSS
			2 = Si, para otra institucion o empresa publica
			3 = Si, para institucion o empresa privada
			4 = Si, para otra
			5 = No
	*/
	gen aporte_pension = 1     if s9q36==1 & s9q37__1==1
	replace aporte_pension = 2 if s9q36==1 & s9q37__2==1
	replace aporte_pension = 3 if s9q36==1 & s9q37__3==1
	replace aporte_pension = 4 if s9q36==1 & s9q37__4==1
	replace aporte_pension = 5 if s9q36==2

	gen     djubila = (s9q36==1) if relab==2 & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //the last parenthesis means means being economically active

* Health insurance linked to employment: dsegsale
gen     dsegsale = (afiliado_segsalud==3 | afiliado_segsalud==4) if relab==2

* Right to be paid 13 months a year (instead of 12): aguinaldo
gen     aguinaldo = .
notes aguinaldo: the survey does not include information to define this variable

* Right to paid vacations: dvacaciones
gen     dvacaciones = .
notes dvacaciones: the survey does not include information to define this variable

* Unionized: sindicato
gen     sindicato = .
notes sindicato: the survey does not include information to define this variable

* Employment program: prog_empleo //si el individuo esta trabajando en un plan de empleo publico
gen     prog_empleo = .
notes prog_empleo: the survey does not include information to define this variable

* Employed:	ocupado
gen     ocupado = inrange(labor_status,1,2) //trabajando o no trabajando pero tiene trabajo

* Unemployed: desocupa
gen     desocupa = (labor_status==3)  //buscando trabajo
		
* Inactive: inactivos	(we don't include it as it mirrors pea)
*gen     inactivo= inrange(labor_status,5,9) 

* Economically active population: pea	
gen     pea = (ocupado==1 | desocupa ==1)


/*(*****************************************************************************************************************************************
*---------------------------------------------------------- 1.9: Income Variables ----------------------------------------------------------
*****************************************************************************************************************************************)*/

* This was done with the complete dataset (not only SEDLAC variables), information on aggregate income variables will be attached at the end

/*(******************************************************************************************************************************************* 
*-------------------------------------------------------- 1.10: LINEAS DE POBREZA  -------------------------------------------------------------
********************************************************************************************************************************************)*/

* This was done in another dofile, the variables will be attached at the end

/*
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
*/

*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- 1.1: PRECIOS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/

* This was done in another dofile, most of them will be attached at the end

/*
**** Ajuste por inflacion
* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .

* IPC del mes base
*/
* gen ipc = .
/*
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
*/
* gen p_reg = .
/*
gen     p_reg = 1
*replace p_reg = 0.8695				if  urbano==0
	
foreach i of varlist iasalp_m iasalp_nm  ictapp_m ictapp_nm  ipatrp_m ipatrp_nm ///
					 iasalnp_m iasalnp_nm  ictapnp_m ictapnp_nm  ipatrnp_m ipatrnp_nm  iolnp_m iolnp_nm ///
					 ijubi_m ijubi_nm /// 
					 icap_m icap_nm rem itranp_o_m itranp_o_nm itranp_ns cct itrane_o_m itrane_o_nm itrane_ns ing_pob_ext ing_pob_mod{
		replace `i' = `i' / p_reg 
		replace `i' = `i' / ipc_rel 
		}
*/

/*=================================================================================================================================================
					2: Preparacion de los datos: Variables de segundo orden
=================================================================================================================================================*/
* This was done in another dofile, will be attached at the end

	* iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap  itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee */ ///
	* pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11 
	* renta_imp

capture label drop relacion
capture label drop hombre
capture label drop nivel
*include "$dopath\data_management\management\2. harmonization\aux_do\cuantiles.do"
*include "$dopath\data_management\management\2. harmonization\aux_do\do_file_1_variables.do"
*include "$dopath\data_management\management\2. harmonization\aux_do\do_file_2_variables.do"
*include "$dopath\data_management\management\2. harmonization\aux_do\labels.do" /// this will get done in the Master

compress

/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables a Documentar Base de Datos CEDLAS --------------
*************************************************************************************************************************************************)*/

sort id com, stable

order pais ano encuesta id com pondera strata psu relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua ///
region_est1 region_est2 region_est3 cen lla ceo zul and nor capital urbano migrante migra_ext migra_rur anios_residencia migra_rec ///
propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici ///
alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp ///
seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector sector_encuesta tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
/*iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee*/ ///
/*aux do_file_2_variables*/ /* pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11 */ ///
/*pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/ ///
interview_month interview__key interview__id quest
				
keep pais ano encuesta id com pondera strata psu relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua ///
region_est1 region_est2 region_est3 cen lla ceo zul and nor capital urbano migrante migra_ext migra_rur anios_residencia migra_rec ///
propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici ///
alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp ///
seguro_salud tipo_seguro anticonceptivo ginecologo papanicolao mamografia /*embarazada*/ control_embarazo lugar_control_embarazo lugar_parto tiempo_pecho vacuna_bcg vacuna_hepatitis vacuna_cuadruple vacuna_triple vacuna_hemo vacuna_sabin vacuna_triple_viral ///
enfermo interrumpio visita razon_no_medico lugar_consulta pago_consulta tiempo_consulta obtuvo_remedio razon_no_remedio fumar deporte ///
relab durades hstrt hstrp deseamas antigue asal empresa grupo_lab categ_lab sector1d sector sector_encuesta tarea contrato ocuperma djubila dsegsale /*d*/aguinaldo dvacaciones sindicato prog_empleo ocupado desocupa pea ///
/* iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ijubi_nm /*ijubi_o*/ icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap  itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee */ ///
/*aux do_file_2_variables*/ /* pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11 */ ///
/* pobreza_enc pobreza_extrema_enc lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11 ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11*/  ///
interview_month interview__key interview__id quest

notes: Income variables were changed to be expressed in bolivares of February 2020.

save "$cleaned\base_out_nesstar_cedlas_2019_pre labels and missing vars.dta", replace

