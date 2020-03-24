/*===========================================================================
Country name:		Venezuela
Year:			2019
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   1
		
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath ""
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"  
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN"
		}

		
// Set output data path
global dataofficial "$rootpath\data_management\output\merged"

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
/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Open Databases  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
*Generate unique household identifier by strata
use "$dataofficial\household.dta", clear
tempfile household_hhid
bysort combined_id: gen hh_by_combined_id = _n
save `household_hhid'

* Open "output" database
use "$dataofficial\individual.dta", clear
merge m:1 interview__key interview__id quest using `household_hhid'
drop _merge
* I drop those who do not collaborate in the survey
drop if colabora_entrevista==2
*Obs: there are still 2 observations which do not merge. Maybe they are people who started to answer but then stopped answering

*Change names to lower cases
rename _all, lower

stop

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables --------------------------------------------------
*************************************************************************************************************************************************)*/

* Country identifier: country
	gen country = "VEN"

* Year identifier: year
	capture drop year
	gen year = 2019

* Survey identifier: survey
	gen survey = "ENCOVI - 2019"

* Household identifier: id
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
		gen edad = s6q5
		*Random var
		set seed 123
		generate z = runiform()
		gsort z 
		*Sorting
		gsort id_numeric -edad z
		egen min =  min(_n), by(id)
		replace min = -min
		
	gen com  = _n + min + 1
		drop z min
	
	duplicates report id com //verification

* Weights: pondera
	*Old: gen pondera = pesoper  //round(pesoper)
	**Will be done later, at the end of the survey

* Strata: strata
	*Old: gen strata = estrato // problem: we don't know how they were generated. We believe they were socioeconomic (AB, C, D, EF; not geographic) but not done statistically. If so, we should delete them from the Datalib uploaded database 
	**In ENCOVI 2019 there are 2 strata, geographical, by size of the segment. Check later with Daniel

* Primary Sample Unit: psu  
gen psu = combined_id

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Demographic variables  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_SEDLAC relacion relacion_en hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza lengua
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

* Household identifier: hogar
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
replace   presec = .  if  relacion!=1
drop `aux'

* Numero de miembros del hogar (de la familia principal): miembros 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)

* Sex 
/* SEXO (s6q3): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
clonevar sex = s6q3
label define sex 1 "Male" 2 "Female"
label value sex sex

* Age
* EDAD_ENCUESTA (s6q5): Cuantos años cumplidos tiene?
notes   edad: range of the variable: 0-97
gen age = edad

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

* Country of birth
gen country_birth = s6q6 if (s6q6!=. & s6q6!=.a)

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
* Marital status
	   1 = married
	   2 = never married
	   3 = living together
	   4 = divorced/separated
	   5 = widowed		
*/
clonevar estado_civil_encuesta= s6q13 if (s6q13!=. & s6q13!=.a)

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
gen     children_born_alive = s6q14 if (s6q14!=. & s6q14!=.a)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     children_alive = s6q15 if s6q14!=0 & s6q15 <=s6q14 & (s6q15!=. & s6q15!=.a)

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
global dwell_ENCOVI flooring_material exterior_wall_malterial roofing_material dwelling_type water_supply frecuencia_agua tipo_sanitario servicio_electrico interr_serv_electrico $dwell_SEDLAC 

*** Type of flooring material
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
*/
gen  flooring_material = s4q1            if (s4q1!=. & s4q1!=.a)	
label def flooring_material 1 "Mosaic,granite,vynil, brick.." 2 "Cement" 3 "Tierra" 4 "Boards" 5 "Other"
label value flooring_material flooring_material

*** Type of exterior wall material		 
/* MATERIAL_PARED_EXTERIOR (s4q2)
		 1 = Bloque, ladrillo frisado	
		 2 = Bloque ladrillo sin frisar  
		 3 = Concreto	
		 4 = Madera aserrada 
		 5 = Bloque de plocloruro de vinilo	
		 6 = Adobe, tapia o bahareque frisado
		 7 = Adobe, tapia o bahareque sin frisado
		 8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  
*/
gen  exterior_wall_material = s4q2  if (s4q2!=. & s4q2!=.a)
label def exterior_wall_material 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete"
label value exterior_wall_material exterior_wall_material

*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
*/
gen  roofing_material = s4q3           if (s4q3!=. & s4q3!=.a)

*** Type of dwelling
/* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
*/
clonevar dwelling_type = s4q4 if (s4q4!=. & s4q4!=.a)

*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda?
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
*/
gen     water_supply = 1 if  s4q5__1==1
replace water_supply = 2 if  s4q5__2==1
replace water_supply = 3 if  s4q5__3==1
replace water_supply = 4 if  s4q5__4==1
replace water_supply = 5 if  s4q5__5==1
replace water_supply = 6 if  s4q5__6==1	
label def water_supply 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Pozo con bomba" 5 "Pozo protegido" 6 "Otros medios"
label value water_supply water_supply

*** Frequency of water supply
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
*/
clonevar frequency_water = s4q6 if (s4q6!=. & s4q6!=.a)	

*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/
gen electricity= (s4q7__1==1 | s4q7__2==1 | s4q7__3==1)  if (s4q7__1!=. & s4q7__1!=.a & s4q7__2!=. & s4q7__2!=.a & s4q7__3!=. & s4q7__3!=.a)

*** Electric power interruptions
/* electric_interrup (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
gen electric_interrup = s4q8 if (s4q8!=. & s4q8!=.a)
replace electric_interrup = 5 if s4q7__4==1 //add category "No tiene servicio electrico" to make it comaparable to previous years
label def electric_interrup 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 5 "No tiene servicio electrico"
label value electric_interrup electric_interrup

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
clonevar toilet_type = s4q9 if (s4q9!=. & s4q9!=.a)

*** Number of rooms used exclusively to sleep
* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar nbedrooms = s5q1 if (s5q1!=. & s5q1!=.a) //up to 9

*** Bath with shower 
* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
gen     bath = s5q2==1 if (s5q2!=. & s5q2!=.a)

*** Number of bathrooms with shower
* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbaths = s5q3 if bath==1 //up to 9

*********************************************************************************
*** Housing tenure
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
clonevar housing_tenure = s5q7 if (s5q7!=. & s5q7!=.a)
gen     propieta = 1		if  tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==5 | tenencia_vivienda==6  // Daniel: "Ambos tienen título de propiedad. Una es financiada, y otra es regalada" 
replace propieta = 0		if  tenencia_vivienda==3 | tenencia_vivienda==4 | (tenencia_vivienda>=7 & tenencia_vivienda<=10)
replace propieta = .		if  relacion!=1

*** How much did you pay for rent or mortgage the last month?

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/
*** Dummy household owns cars
*  AUTO (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
gen     car = s5q4==1		if  s5q4!=. & s5q4!=.a
*replace car = .		if  relacion!=1 

*** Number of functioning cars in the household
* NCARROS (s5q4a) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
gen     ncars = s5q4a if s5q4==1 & (s5q4a!=. & s5q4a!=.a)
*replace ncars = .		if  relacion!=1 

*** Year of the most recent car
gen year_car= s5q5 if s5q4==1 & (s5q5!=. & s5q5!=.a)
replace year_car = . if relacion==1

*** Does the household have fridge?
* Heladera (s5q6__1): ¿Posee este hogar nevera?
gen     fridge = s5q6__1==1 if (s5q6__1!=. & s5q6__1!=.a)
*replace fridge = .		if  relacion!=1 

*** Does the household have washing machine?
* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
gen     washing_machine = s5q6__2==1 if (s5q6__2!=. & s5q6__2!=.a)
*replace washing_machine = .		if  relacion!=1 

*** Does the household have dryer
* Secadora (s5q6__3): ¿Posee este hogar secadora? 
gen     dryer = s5q6__3==1 if (s5q6__3!=. & s5q6__3!=.a)
*replace dryer = .		if  relacion!=1 

*** Does the household have computer?
* Computadora (s5q6__4): ¿Posee este hogar computadora?
gen computer = s5q6__4==1 if (s5q6__4!=. & s5q6__4!=.a)
*replace computer = .		if  relacion!=1 

*** Does the household have internet?
* Internet (s5q6__5): ¿Posee este hogar internet?
gen     internet = s5q6__5==1 if (s5q6__5!=. & s5q6__5!=.a)
*replace internet = .	if  relacion!=1 

*** Does the household have tv?
* Televisor (s5q6__6): ¿Posee este hogar televisor?
gen     tv = s5q6__6==1 if (s5q6__6!=. & s5q6__6!=.a)
*replace tv = .	if  relacion!=1 

*** Does the household have radio?
* Radio (s5q6__7): ¿Posee este hogar radio? 
gen     radio = s5q6__7==1 if (s5q6__7!=. & s5q6__7!=.a)
*replace radio = .		if  relacion!=1 

*** Does the household have heater?
* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
gen     heater = s5q6__8==1 if (s5q6__8!=. & s5q6__8!=.a)
*replace heater = .		if  relacion!=1 

*** Does the household have air conditioner?
* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
gen     air_conditioner = s5q6__9==1 if (s5q6__9!=. & s5q6__9!=.a)
*replace air_conditioner = .		    if  relacion!=1 

*** Does the household have cable tv?
* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
gen     tv_cable = s5q6__10==1 if (s5q6__10!=. & s5q6__10!=.a)
*replace tv_cable = .		if  relacion!=1

*** Does the household have microwave oven?
* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
gen     microwave = s5q6__11==1 if (s5q6__11!=. & s5q6__11!=.a)
*replace microwave = .		if  relacion!=1

*** Does the household have landline telephone?
* Teléfono fijo (s5q6__12): telefono_fijo
gen     landline_phone = s5q6__12==1 if (s5q6__12!=. & s5q6__12!=.a)
*replace landline_phone = .		    if  relacion!=1 
;
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
*------------------------------------------------------------- VIII. HEALTH VARIABLES ---------------------------------------------------------------
************************************************************************************************************************************************)*/

*** Have you had any health problem, illness, or accident in the last 30 days?
/* s8q1 ¿Ha tenido un problema de salud, enfermedad o accidente en los últimos 30 días?: enfermo
		1 = si
        2 = no */
gen    enfermo = s8q1==1 & (s8q1!=. & s8q1!=.a)

*** Which was your main health problem?
/* s8q2 ¿Cual fue el principal problema de salud que tuvo?
		1 = Fiebre / Malaria
		2 = Diarrea
		3 = Accidente / Lesión
		4 = Problema dental
		5 = Problema de la piel
		6 = Enfermedad de los ojos
		7 = Problema de tensión
		8 = Fiebre tifoidea
		9 = Problema estomacal
		10 = Dolor de garganta
		11 = Tos, resfriado, gripe
		12 = Diabetes
		13 = Meningitis
		14 = Otro */
gen enfermedad = s8q2 if (s8q1!=. & s8q1!=.a) & s8q1==1

*** Have you gone to get healthcare in the last 30 days?
/* s8q3 ¿Ha consultado un servicio de salud (incluida una farmacia) o con un curandero tradicional en los últimos 30 días debido a este problema de salud?: visita
		1 = si  
        2 = no  */
gen    visita = s8q3==1 if s8q1==1 & (s8q3!=. & s8q3!=.a)
*Obs: Refers to last 30 days

*** Why didn't you try to consult to treat the sickness or accident?
/* 	s8q4 ¿Cuál es la razón por la cual no consultó para tratar esta enfermedad síntoma o malestar y/o accidente?: razon_no_medico
	 	1 = Se automedicó, utilizó remedios caseros
		2 = No tiene dinero para pagar consulta, exámenes, medicinas
		3 = No lo consideró necesario, no hizo nada
		4 = Lugar de atención queda lejos del domicilio
		5 = La atención no es adecuada
		6 = Hay que esperar mucho tiempo
		7 = No lo atendieron
		8 = Otra	*/
gen    razon_no_medico = s8q4 if (s8q4!=. & s8q4!=.a) & (s8q1==1 & s8q3==2)

*** Who did you mainly consult to treat the sickness or accident?
/*	s8q5 ¿A quién consultó principalmente para tratar esta enfermedad síntoma o malestar y/o accidente?
	 	1 = Médico
		2 = Enfermera u otro auxiliar paramédico
		3 = Farmacéutico
		4 = Curandero, yerbatero o brujo
		5 = Otro 	*/
gen    medico_o_quien = s8q5 if (s8q5!=. & s8q5!=.a) & (s8q1==1 & s8q3==1)
		
*** Where did you go for healthcare attention?
/* 	s8q6 ¿Donde acudió para su atención?: lugar_consulta
		1 = Ambulatorio/clínica popular/ CDI
		2 = Hospital público o del Seguro Social
		3 = Servicio privado sin hospitalización
		4 = Clínica privada
		5 = Centro de salud privado sin fines de lucro
		6 = Servicio médico en el lugar de trabajo
		7 = Farmacia
		8 = Otro	 */
gen    lugar_consulta = s8q6 if (s8q6!=. & s8q6!=.a) & (s8q1==1 & s8q3==1)

*** Did you pay for consulting or healthcare attention?
/* 	s8q7 ¿Pagó por consultas o atención médica?: pago_consulta
	 	1 = si 
		2 = no  */
gen    	pago_consulta = s8q7==1 & (s8q1==1 & s8q3==1)

*** How much did you pay? 
* 	s8q8a ¿Cuánto pagó?: cant_pago_consulta
gen    	cant_pago_consulta = s8q8a if s8q1==1 & s8q3==1 & s8q7==1

*** In which currency did you pay?
/* 	s8q8b ¿En qué moneda realizó el pago?: mone_pago_consulta
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
gen    	mone_pago_consulta = s8q8b if (s8q8b!=. & s8q8b!=.a) & (s8q1==1 & s8q3==1 & s8q7==1)

*** In which month did you pay?
/* 	s8q8c ¿En qué mes pagó?: mes_pago_consulta
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
gen    mes_pago_consulta = s8q8c if (s8q8c!=. & s8q8c!=.a) & (s8q1==1 & s8q3==1 & s8q7==1)
		
*** Did you get any medicine prescribed for the illness of accident?
/* s8q9 ¿Se recetó a algún medicamento para la enferemedad o accidente?: receto_remedio
		 	1 = Si
			2 = No */
gen     receto_remedio = s8q9==1 if (s8q1==1 & s8q3==1)

*** How did you get the medicines?
/* s8q10 ¿Cómo obtuvo los medicamentos?: recibio_remedio
			1 = Los recibió todos gratis
			2 = Recibió algunos gratis y otros los compró
			3 = Los compró todos
			4 = Compró algunos
			5 = Recibió algunos gratis y los otros no pudo comprarlos
			6 = No pudo obtener ninguno */
gen  	recibio_remedio = s8q10 if (s8q1==1 & s8q9==1) & (s8q10!=. & s8q10!=.a) 

*** Where did you buy the medicines?
/* s8q11 ¿Dónde compró los medicamentos?
			1 = Boticas o farmacias populares
			2 = Otras farmacias comerciales
			3 = Institutos de Previsión Social u otras fundaciones ( IPAS-ME, IPSFA, otros)
			4 = Otro	*/		
gen     donde_remedio = s8q11==1 if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)
		
*** How much did you pay for the medicines?
* s8q12a ¿Cuánto pagó por los medicamentos?: pago_remedio
gen     pago_remedio = s8q12a if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)

*** In which currency did you pay?
/* 	s8q12b ¿En qué moneda realizó el pago?: moneda_pago_remedio
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
gen    	mone_pago_remedio = s8q12b if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)

*** In which month did you pay?
/* 	s8q12c ¿En qué mes pagó?: mes_pago_remedio
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
gen    	mes_pago_remedio = s8q12c if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)

*** Did you pay for Xrays, lab exams or similar?
/* s8q13 ¿Pagó por radiografías, exámenes de laboratorio o similares?: pago_estudio
			1 = Si
			2 = No 		*/
gen 	pago_estudio = s8q13==1 if s8q1==1 & s8q3==1 
			
*** How much did you pay?
* s8q14a ¿Cuánto pagó?: pago_examen
gen     pago_examen = s8q14a if s8q1==1 & s8q3==1 

*** In which currency did you pay?
/* 	s8q14b ¿En qué moneda realizó el pago?: mone_pago_examen
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
gen    	mone_pago_examen = s8q14b if s8q1==1 & s8q3==1 

*** In which month did you pay?
/* 	s8q14c ¿En qué mes pagó?: mes_pago_examen
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
gen    	mes_pago_examen = s8q14c if s8q1==1 & s8q3==1 

*** Although you answered you did not have any health problem, illness or accident in the last month, did you spend money in medicines due to illnesses, accidents or health problems in the last 3 months?
/*  s8q15 Aunque usted ya indicó que no consultó a ningún personal médico, ¿gastó dinero en los ultimos 3 meses en medicinas por enfermedad, accidente, o quebrantos de salud que tuvo ?
			1 = Si
			2 = No 		*/
gen 	remedio_tresmeses = s8q15==1 if s8q1==2

*** How much did you pay?
* s8q16a ¿Cuánto gastó?: cant_remedio_tresmeses
gen     cant_remedio_tresmeses = s8q16a if s8q1==2 & s8q15==1

*** In which currency did you pay?
/* 	s8q16b ¿En qué moneda realizó el pago?: mone_remedio_tresmeses
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
gen    	mone_remedio_tresmeses = s8q16b if s8q1==2 & s8q15==1

*** In which month did you pay?
/* 	s8q16c ¿En qué mes pagó?: mes_remedio_tresmeses
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
gen    	mes_remedio_tresmeses = s8q16c if s8q1==2 & s8q15==1

*** Are you affiliated to health insurance?
/* 	s8q17 ¿Está afiliado a algún seguro medico?: seguro_salud
			1 = si
			2 = no	 */
gen     seguro_salud = 1	if  s8q17==1
replace seguro_salud = 0	if  s8q17==2

*** Which is the main health insurance or that with greatest coverage you are affiliated to?
/* s8q18: ¿Cuál es el seguro médico principal o de mayor cobertura al cual está afiliado?: afiliado_segsalud
		1 = Instituto Venezolano de los Seguros Sociales (IVSS)
		2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
		3 = Seguro medico contratado por institucion publica
		4 = Seguro medico contratado por institucion privada
		5 = Seguro medico privado contratado de forma particular */
gen 	afiliado_segsalud = s8q18   if s8q17==1 & (s8q18!=. & s8q18!=.a) 
label 	define afiliado_segsalud ///
		1 "Instituto Venezolano de los Seguros Sociales (IVSS)" ///
		2 "Instituto de prevision social publico (IPASME, IPSFA, otros)" ///
		3 "Seguro medico contratado por institucion publica" ///
		4 "Seguro medico contratado por institucion privada" ///
		5 "Seguro medico privado contratado de forma particular"

*** Did you pay for health insurance?
/* 	s8q19 ¿Pagó por el seguro médico?: pagosegsalud
		1 = si
		2 = no	 */
gen     pagosegsalud = s8q19==1  if s8q17==1

*** Who paid for the health insurance?
/* s8q20 ¿Quién pagó por el seguro médico?: quien_pagosegsalud
		1 = Beneficio laboral
		2 = Familiar en el exterior
		3 = Otro miembro del hogar
		4 = Otro (especifique) */
gen     quien_pagosegsalud = s8q19==1  if s8q17==1 & s8q18==5

*** How much did you pay?
* s8q21a ¿Cuál fue el monto pagado por el seguro de salud?: cant_pagosegsalud
gen     cant_pagosegsalud = s8q21a if s8q19==1

*** In which currency did you pay?
/* 	s8q21b ¿En qué moneda realizó el pago?: mone_pagosegsalud
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
gen    	mone_pagosegsalud = s8q21b if s8q19==1

*** In which month did you pay?
/* 	s8q21c ¿En qué mes pagó?: mes_pagosegsalud
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
gen    	mes_pagosegsalud= s8q21c if s8q19==1
		

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- IX: LABOR / EMPLEO ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

*Notes: interviews done if age>9

* Identifying economically active and inactive, and reasons

	*** Did you work at least one hour last week? 
	/* 	s9q1 ¿La semana pasada trabajó al menos una hora?: trabajo_semana
			1 = si
			2 = no	 */
	gen     trabajo_semana = s9q1==1 & (s9q1!=. & s9q1!=.a) 

	*** Independently of last answer, did you dedicate last week at least one hour to: 
	/* 	s9q2 Independientemente de lo que me acaba de decir, ¿le dedicó la semana pasada, al menos una hora a...: trabajo_semana_2
			1 = Realizar una actividad que le proporcionó ingresos
			2 = Ayudar en las tierras o en el negocio de un familiar o de otra persona
			3 = No trabajó la semana pasada	 */
	gen     trabajo_semana_2 = s9q2 if s9q1==2 & (s9q2!=. & s9q2!=.a) 

	*** Despite you already said you didnt work last week, do you have any job, business, or do you do any activity on your own? 
	/* 	s9q3 Aunque ya me dijo que no trabajó la semana pasada, ¿tiene algún empleo, negocio o realiza alguna actividad por su cuenta?: trabajo_independiente
			1 = si
			2 = no	 */
	gen     trabajo_independiente = s9q3==1 if (s9q1==2 & s9q2==3) & (s9q3!=. & s9q3!=.a) 

	*** Main reason for not working last week
	/* s9q4 Cuál es la razón principal por la que no trabajó la semana pasada?: razon_no_trabajo
			1 = Estaba enfermo
			2 = Vacaciones
			3 = Permiso
			4 = Conflictos laborales
			5 = Reparación de equipo, maquinaria, vehículo
			*Obs: number 6 is missing
			7 = No quiere trabajar
			8 = Falta de trabajo, clientes o pedidos
			9 = Impedimento de autoridades municipales o nacionales
			10 = Nuevo empleo a empezar en 30 días
			11 = Factores estacionales
			16 = Otro 	*/
	gen     razon_no_trabajo = s9q4 if s9q3==1 & (s9q2!=. & s9q2!=.a) 
		
	*** Last week did you receive wages or benefits? 
	/* 	s9q5 Durante la semana pasada recibió sueldo o ganancias?: sueldo_semana
			1 = si
			2 = no	 */
	gen     sueldo_semana = s9q5==1 if s9q3==1 & (s9q5!=. & s9q5!=.a) 

	*** Did you do anything to look for a paid job in the last 4 weeks?
	/* s9q6 Durante las últimas 4 semanas, ¿hizo algo para encontrar un trabajo remunerado?: busco_trabajo
			1 = si
			2 = no	*/
	gen     busco_trabajo = s9q6==1 if (s9q3==2 & s9q1==2 & s9q2==3) & (s9q6!=. & s9q6!=.a) 

	*** Or did you do anything to start a business?
	/* s9q7 O hizo algo para empezar un negocio?: empezo_negocio
			1 = si
			2 = no	*/
	gen     empezo_negocio = s9q7==1 if (s9q6==2 & s9q3==2 & s9q1==2 & s9q2==3) & (s9q7!=. & s9q7!=.a) 

	*** When was the last time did you did something to find a job or start a business joinlty or alone?
	/* s9q8 Cuándo fue la última vez que hizo algo para conseguir trabajo o establecer un negocio solo o asociado? (para quienes no buscaron en las últimas 4 semanas): cuando_buscotr
			1 = En los últimos 2 meses
			2 = En los últimos 12 meses
			3 = Hace más de un año
			4 = No ha hecho diligencias	*/
	gen     cuando_buscotr = s9q8 if (s9q7==2 & s9q6==2 & s9q3==2 & s9q1==2 & s9q2==3) & (s9q8!=. & s9q8!=.a) 

	*** Have you carried out any of these proceedings in that period? (4 weeks)
	/* s9q9__* Ha realizado alguna de estas diligencias en ese período? (4 semanas): dili_*
			1 = Consultó a una agencia de empleo
			2 = Puso o contestó aviso
			3 = Llenó alguna planilla
			4 = Búsqueda de crédito o local
			5 = Trámites de permiso o legalización de documentos
			6 = Compra de insumos o materia prima
			7 = Contacto personal
			8 = Otra diligencia		*/
	gen     dili_agencia 	= s9q9__1==1 if (s9q6==1 | s9q7==1) & (s9q9__1!=. & s9q9__1!=.a) 
	gen     dili_aviso 		= s9q9__2==1 if (s9q6==1 | s9q7==1) & (s9q9__2!=. & s9q9__2!=.a) 
	gen     dili_planilla 	= s9q9__3==1 if (s9q6==1 | s9q7==1) & (s9q9__3!=. & s9q9__3!=.a) 
	gen     dili_credito 	= s9q9__4==1 if (s9q6==1 | s9q7==1) & (s9q9__4!=. & s9q9__4!=.a) 
	gen     dili_tramite 	= s9q9__5==1 if (s9q6==1 | s9q7==1) & (s9q9__5!=. & s9q9__5!=.a) 
	gen     dili_compra 	= s9q9__6==1 if (s9q6==1 | s9q7==1) & (s9q9__6!=. & s9q9__6!=.a) 
	gen     dili_contacto 	= s9q9__7==1 if (s9q6==1 | s9q7==1) & (s9q9__7!=. & s9q9__7!=.a) 
	gen     dili_otro	 	= s9q9__8==1 if (s9q6==1 | s9q7==1) & (s9q9__8!=. & s9q9__8!=.a) 
	
	*** Have you carried out any of these proceedings last week?
	/* s9q10 ¿Realizó alguna de esas diligencias la semana pasada?: como_busco_semana
			1 = si
			2 = no	*/
	gen     como_busco_semana = s9q10==1 if (s9q9__1!=. | s9q9__2!=. | s9q9__3!=. | s9q9__4!=. | s9q9__5!=. | s9q9__6!=. | s9q9__7!=. | s9q9__8!=.) & (s9q10!=. & s9q10!=.a) 

	*** Have you carried out any of these proceedings in that period? (4 weeks)
	/* s9q11 ¿Por cuál de estos motivos no está buscando trabajo actualmente?: razon_no_busca
			1 = Está cansado de buscar trabajo
			2 = No encuentra el trabajo apropiado
			3 = Cree que no va a encontrar trabajo
			4 = No sabe cómo ni dónde buscar trabajo
			5 = Cree que por su edad no le darán trabajo
			6 = Ningún trabajo se adapta a sus capacidades
			7 = No tiene quién le cuide los niños
			8 = Está enfermo/motivos de salud
			9 = Otro motivo ? Especifique */
	gen     razon_no_busca = s9q11 if (s9q8==1|2|3|4) & (s9q11!=. & s9q11!=.a) 

	*** What are you doing right now? (only for those who did not work)
	/* s9q12 ¿Qué es lo que está haciendo actualmente? (sólo para aquellos que no trabajaron): actividades_inactivos
			1 = Estudiando
			2 = Entrenando
			3 = Actividades del hogar o responsabilidades de la familia
			4 = Trabajando en una parcela para uso familiar
			* Obs: number 5 is missing
			6 = Jubilado o pensionado
			7 = Enfermedad de largo plazo
			8 = Discapacidad
			9 = Trabajo voluntario
			10 = Trabajo caridad
			11 = Actividades culturales o de ocio	*/
	gen     actividades_inactivos = s9q12 if (s9q11==1|2|3|4|5|6|7|8|9) & (s9q12!=. & s9q12!=.a) 

* For all the economically active

	*** What is your position at your main occupation? 
	/* s9q13 ¿Cuál es la ocupación que desempeña en su trabajo principal? (encuestas anteriores: ¿Cuál es el oficio o trabajo que realiza?): tarea
			1 = Director o gerente
			2 = Profesional científico o intelectual
			3 = Técnico o profesional de nivel medio
			4 = Personal de apoyo administrativo
			5 = Trabajador de los servicios o vendedor de comercios y mercados
			6 = Agricultor o trabajador calificado agropecuario, forestal o pesquero
			7 = Oficial, operario o artesano de artes mecánicas y otros oficios
			8 = Operador de instalaciones fijas y máquinas y maquinarias
			9 = Ocupaciones elementales
			10 = Ocupaciones militares */
	gen     tarea = s9q13 		if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q13!=. & s9q13!=.a) // the first parenthesis means being economically active

	*** What does the business, institution or firm in which you work do?
	/* s9q14 ¿A que se dedica el negocio, organismo o empresa en la que trabaja/desempaña su trabajo principal?: sector_encuesta
			1 = Agricultura, ganaderia, pesca, caza y actividades de servicios conexas
			2 = Explotación de minas y canteras
			3 = Industria manufacturera
			4 = Instalacion/ suministro/ distribucion de electricidad, gas o agua
			5 = Construccion
			6 = Comercio al por mayor y al por menor; reparacion de vehiculos automotores y motocicletas
			7 = Transporte, almacenamiento, alojamiento y servicio de comida, comunicaciones y servicios de computacion
			8 = Entidades financieras y de seguros, inmobiliarias, profesionales, cientificas y tecnicas; y servicios administrativos de apoyo
			9 = Administración publica y defensa, enseñanza, salud, asistencia social, arte, entretenimiento, embajadas
			10 = Otras actividades de servicios como reparaciones, limpieza, peluqueria, funeraria y servicio domestico	*/
	gen 	sector_encuesta = s9q14 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q14!=. & s9q14!=.a) // the first parenthesis means being economically active

	*** In your work you are...
	/* s9q15 En su trabajo se desempña como...: categ_ocu
			1 = Empleado u obrero en el sector publico
				*Obs: 1 used to be divided in 2 before, thats why number 2 is skipped.
			3 = Empleado u obrero en empresa privada		
				*Obs: 3 used to be divided in 2 before, thats why number 4 is skipped.
			5 = Patrono o empleador
			6 = Trabajador por cuenta propia
			7 = Miembro de cooperativas
			8 = Ayudante familiar remunerado/no remunerado
			9 = Servicio domestico		*/
	gen 	categ_ocu = s9q15 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q15!=. & s9q15!=.a) // the first parenthesis means being economically active
	*Obs. CAPI1: s9q15==(1|2|3|4|7|8|9) i.e. workers not self-employed or employer

	*** How many hours did you work last week in your main occupation?
	/* s9q16 ¿Cuántas horas trabajó durante la semana pasada en su ocupación principal?: hstr_ppal	*/
	gen     hstr_ppal = s9q16 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q16!=. & s9q16!=.a) 

	*** Besides your main occupation, did you do any other activity through which you received income, such as selling things, contracted work, etc?
	/* s9q17 Además de su trabajo principal, ¿realizó la semana pasada alguna otra actividad por la que percibió ingresos tales como, venta de artículos, trabajos contratados, etc?: trabajo_secundario
			1 = si
			2 = no		*/
	gen     trabajo_secundario = s9q17==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q17!=. & s9q17!=.a) 

	*** How many hours do you normally work weekly in all your jobs or businesses?
	/* s9q18 ¿Cuántas horas trabaja normalmente a la semana en todos sus trabajos o negocios?: hstr_todos */
		*Note: For part-time workers, i.e. worked less than 35 hs s9q18<35 // CAPI4==true
	gen     hstr_todos = s9q18 if s9q17==1 & (s9q18!=. & s9q18!=.a) 

		*Problem: it should not be possible but there is at least one case in which the total hours worked appears to be greater than the hours worked for the main job
		
* For those not self-employed or employers (s9q15==1|3|7|8|9) // CAPI1=true
	
	*** With respect to last month, did you receive income in all of your jobs or businesses for the following concepts? (each one is a dummy)
	/* s9q19__* ¿Con respecto al mes pasado, recibió en todos sus trabajos o negocios ingresos por los siguientes conceptos?: im_*
				1 = Sueldos y salarios
				2 = Horas extras
				3 = Propinas
				4 = Comisiones
				5 = Cesta ticket, tarjeta de alimentación
				6 = Aporte por guardería
				7 = Beca estudio
				8 = Prima por hijos
				9 = Antigüedad
				10 = Bono de transporte
				11 = Bono por rendimiento
				12 = Otros bonos y compensaciones */
			*Note: im stands for ingreso monetario
			*Note2: For those not self-employed or employers (s9q15==1|3|7|8|9)	// CAPI1=true
	gen     im_sueldo 		= s9q19__1==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__1!=. & s9q19__1!=.a) 
	gen     im_hsextra 		= s9q19__2==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__2!=. & s9q19__2!=.a) 
	gen     im_propina 		= s9q19__3==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__3!=. & s9q19__3!=.a) 
	gen     im_comision	 	= s9q19__4==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__4!=. & s9q19__4!=.a) 
	gen 	im_ticket		= s9q19__5==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__5!=. & s9q19__5!=.a) 
	gen 	im_guarderia	= s9q19__6==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__6!=. & s9q19__6!=.a) 
	gen 	im_beca			= s9q19__7==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__7!=. & s9q19__7!=.a) 
	gen 	im_hijos		= s9q19__8==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__8!=. & s9q19__8!=.a) 
	gen 	im_antiguedad 	= s9q19__9==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__9!=. & s9q19__9!=.a) 
	gen 	im_transporte	= s9q19__10==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__10!=. & s9q19__10!=.a) 
	gen 	im_rendimiento	= s9q19__11==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__11!=. & s9q19__11!=.a) 
	gen 	im_otro			= s9q19__12==1 if s9q15==(1|2|3|4|7|8|9) & (s9q19__12!=. & s9q19__12!=.a) 
		
	*** Amount received (1 variable for each of the 12 options)
	* s9q19a_* Monto recibido: im_*_cant
	* Note: cant stands for cantidad/quantity
	gen     im_sueldo_cant 		= s9q19a_1 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_1!=. & s9q19a_1!=.a) 
	gen     im_hsextra_cant 	= s9q19a_2 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_2!=. & s9q19a_2!=.a) 
	gen     im_propina_cant		= s9q19a_3 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_3!=. & s9q19a_3!=.a) 
	gen     im_comision_cant	= s9q19a_4 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_4!=. & s9q19a_4!=.a) 
	gen 	im_ticket_cant		= s9q19a_5 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_5!=. & s9q19a_5!=.a) 
	gen 	im_guarderia_cant 	= s9q19a_6 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_6!=. & s9q19a_6!=.a) 
	gen 	im_beca_cant		= s9q19a_7 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_7!=. & s9q19a_7!=.a) 
	gen 	im_hijos_cant		= s9q19a_8 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_8!=. & s9q19a_8!=.a) 
	gen 	im_antiguedad_cant	= s9q19a_9 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_9!=. & s9q19a_9!=.a) 
	gen 	im_transporte_cant	= s9q19a_10 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_10!=. & s9q19a_10!=.a) 
	gen 	im_rendimiento_cant	= s9q19a_11 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_11!=. & s9q19a_11!=.a) 
	gen 	im_otro_cant		= s9q19a_12 if s9q15==(1|2|3|4|7|8|9) & (s9q19a_12!=. & s9q19a_12!=.a) 

	*** In which currency? (1 variable for each of the 12 options)
	* s9q19b_* En qué moneda?: i_*_mone
	* 1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos
	gen     i_sueldo_mone 		= s9q19b_1 if s9q19__1!=. & (s9q19b_1!=. & s9q19b_1!=.a) 
	gen     i_hsextra_mone 		= s9q19b_2 if s9q19__2!=. & (s9q19b_2!=. & s9q19b_2!=.a) 
	gen     i_propina_mone		= s9q19b_3 if s9q19__3!=. & (s9q19b_3!=. & s9q19b_3!=.a) 
	gen     i_comision_mone		= s9q19b_4 if s9q19__4!=. & (s9q19b_4!=. & s9q19b_4!=.a) 
	gen 	i_ticket_mone		= s9q19b_5 if s9q19__5!=. & (s9q19b_5!=. & s9q19b_5!=.a) 
	gen 	i_guarderia_mone 	= s9q19b_6 if s9q19__6!=. & (s9q19b_6!=. & s9q19b_6!=.a) 
	gen 	i_beca_mone			= s9q19b_7 if s9q19__7!=. & (s9q19b_7!=. & s9q19b_7!=.a) 
	gen 	i_hijos_mone		= s9q19b_8 if s9q19__8!=. & (s9q19b_8!=. & s9q19b_8!=.a) 
	gen 	i_antiguedad_mone	= s9q19b_9 if s9q19__9!=. & (s9q19b_9!=. & s9q19b_9!=.a) 
	gen 	i_transporte_mone	= s9q19b_10 if s9q19__10!=. & (s9q19b_10!=. & s9q19b_10!=.a) 
	gen 	i_rendimiento_mone 	= s9q19b_11 if s9q19__11!=. & (s9q19b_11!=. & s9q19b_11!=.a) 
	gen 	i_otro_mone			= s9q19b_12 if s9q19__12!=. & (s9q19b_12!=. & s9q19b_12!=.a)

	*** With respect to last month, did you receive in your jobs contributions from your employer to social security for any of the folowing concepts? (each one is a dummy)
	/* s9q20__* ¿Con respecto al mes pasado recibió en su trabajo u otros empleos, contribuciones de los patronos a la seguridad social por los siguientes conceptos?: c_*
				1 = Seguro social obligatorio
				2 = Régimen de prestaciones Vivienda y hábitat
				3 = Seguro de paro forzoso
				4 = Aporte patronal de la caja de ahorro
				5 = Contribuciones al sistema privado de seguros
				6 = Otras contribuciones */
			* Note: For those not self-employed or employers (s9q15==1|3|7|8|9) // CAPI1=true	
	gen     c_sso 		= s9q20__1==1 if s9q15==(1|2|3|4|7|8|9) & (s9q20__1!=. & s9q20__1!=.a) 
	gen     c_rpv 		= s9q20__2==1 if s9q15==(1|2|3|4|7|8|9) & (s9q20__2!=. & s9q20__2!=.a) 
	gen     c_spf 		= s9q20__3==1 if s9q15==(1|2|3|4|7|8|9) & (s9q20__3!=. & s9q20__3!=.a) 
	gen     c_aca	 	= s9q20__4==1 if s9q15==(1|2|3|4|7|8|9) & (s9q20__4!=. & s9q20__4!=.a) 
	gen 	c_sps		= s9q20__5==1 if s9q15==(1|2|3|4|7|8|9) & (s9q20__5!=. & s9q20__5!=.a) 
	gen 	c_otro		= s9q20__6==1 if s9q15==(1|2|3|4|7|8|9) & (s9q20__6!=. & s9q20__6!=.a) 
		
	*** Amount received (1 variable for each of the 6 options)
	* s9q20a_* Monto recibido: c_*_cant
	gen     c_sso_cant 		= s9q20a_1 if s9q15==(1|2|3|4|7|8|9) & (s9q20a_1!=. & s9q20a_1!=.a) 
	gen     c_rpv_cant 		= s9q20a_2 if s9q15==(1|2|3|4|7|8|9) & (s9q20a_2!=. & s9q20a_2!=.a) 
	gen     c_spf_cant  	= s9q20a_3 if s9q15==(1|2|3|4|7|8|9) & (s9q20a_3!=. & s9q20a_3!=.a) 
	gen     c_aca_cant 	 	= s9q20a_4 if s9q15==(1|2|3|4|7|8|9) & (s9q20a_4!=. & s9q20a_4!=.a) 
	gen 	c_sps_cant 		= s9q20a_5 if s9q15==(1|2|3|4|7|8|9) & (s9q20a_5!=. & s9q20a_5!=.a) 
	gen 	c_otro_cant 	= s9q20a_6 if s9q15==(1|2|3|4|7|8|9) & (s9q20a_6!=. & s9q20a_6!=.a)

	*** In which currency? (1 variable for each of the 12 options)
	* s9q20b_* En qué moneda?: c_*_mone
	* 1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos
	gen     c_sso_mone 		= s9q20b_1 if s9q20__1!=. & (s9q20b_1!=. & s9q20b_1!=.a) 
	gen     c_rpv_mone 		= s9q20b_2 if s9q20__2!=. & (s9q20b_2!=. & s9q20b_2!=.a) 
	gen     c_spf_mone  	= s9q20b_3 if s9q20__3!=. & (s9q20b_3!=. & s9q20b_3!=.a) 
	gen     c_aca_mone 	 	= s9q20b_4 if s9q20__4!=. & (s9q20b_4!=. & s9q20b_4!=.a) 
	gen 	c_sps_mone 		= s9q20b_5 if s9q20__5!=. & (s9q20b_5!=. & s9q20b_5!=.a) 
	gen 	c_otro_mone 	= s9q20b_6 if s9q20__6!=. & (s9q20b_6!=. & s9q20b_6!=.a)

	*** With respect to last month, did you receive any of the following benefits in your work or other jobs? (each one is a dummy)
	/* s9q21__* ¿Con respecto al mes pasado, recibió alguno de los siguientes beneficios en su trabajo u otros empleos? 
				1 = Alimentación
				2 = Productos de la empresa
				3 = Transporte
				4 = Vehículo para uso privado
				5 = Exoneración del pago de estacionamiento
				6 = Teléfono personal
				7 = Servicios básicos de vivienda
				8 = Guardería del trabajo
				9 = Otros beneficios	*/
		* Note: For those not self-employed or employers (s9q15==1|3|7|8|9)	// CAPI1=true
		* Note 2: inm stands for ingreso no monetario
	gen     inm_comida 			= s9q21__1==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__1!=. & s9q21__1!=.a) 
	gen     inm_productos 		= s9q21__2==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__2!=. & s9q21__2!=.a) 
	gen     inm_transporte 		= s9q21__3==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__3!=. & s9q21__3!=.a) 
	gen     inm_vehiculo	 	= s9q21__4==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__4!=. & s9q21__4!=.a) 
	gen 	inm_estaciona		= s9q21__5==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__5!=. & s9q21__5!=.a) 
	gen 	inm_telefono		= s9q21__6==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__6!=. & s9q21__6!=.a) 
	gen 	inm_servicios		= s9q21__7==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__7!=. & s9q21__7!=.a) 
	gen 	inm_guarderia		= s9q21__8==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__8!=. & s9q21__8!=.a) 
	gen 	inm_otro	 		= s9q21__9==1 if s9q15==(1|2|3|4|7|8|9) & (s9q21__9!=. & s9q21__9!=.a) 
		
	*** Amount received, or estimation of how much they would have paid for the benefit (1 variable for each of the 9 options)
	* s9q21a_*: Monto recibido (Si no percibe el beneficio en dinero, estime cuánto tendría que haber pagado por ese concepto (p.e. pago de guardería infantil, comedor en la empresa o transporte))
	gen     inm_comida_cant 	= s9q21a_1 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_1!=. & s9q21a_1!=.a) 
	gen     inm_productos_cant 	= s9q21a_2 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_2!=. & s9q21a_2!=.a) 
	gen     inm_transporte_cant	= s9q21a_3 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_3!=. & s9q21a_3!=.a) 
	gen     inm_vehiculo_cant	= s9q21a_4 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_4!=. & s9q21a_4!=.a) 
	gen 	inm_estaciona_cant	= s9q21a_5 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_5!=. & s9q21a_5!=.a) 
	gen 	inm_telefono_cant 	= s9q21a_6 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_6!=. & s9q21a_6!=.a) 
	gen 	inm_servicios_cant	= s9q21a_7 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_7!=. & s9q21a_7!=.a) 
	gen 	inm_guarderia_cant	= s9q21a_8 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_8!=. & s9q21a_8!=.a) 
	gen 	inm_otro_cant 		= s9q21a_9 if s9q15==(1|2|3|4|7|8|9) & (s9q21a_9!=. & s9q21a_9!=.a) 

	*** In which currency? (1 variable for each of the 12 options)
	* s9q21b_* En qué moneda?: inm_*_moneda
	* 1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos
	gen     inm_comida_mone 	= s9q21b_1 if s9q21__1!=. & (s9q21b_1!=. & s9q21b_1!=.a) 
	gen     inm_productos_mone 	= s9q21b_2 if s9q21__2!=. & (s9q21b_2!=. & s9q21b_2!=.a) 
	gen     inm_transporte_mone	= s9q21b_3 if s9q21__3!=. & (s9q21b_3!=. & s9q21b_3!=.a) 
	gen     inm_vehiculo_mone	= s9q21b_4 if s9q21__4!=. & (s9q21b_4!=. & s9q21b_4!=.a) 
	gen 	inm_estaciona_mone	= s9q21b_5 if s9q21__5!=. & (s9q21b_5!=. & s9q21b_5!=.a) 
	gen 	inm_telefono_mone 	= s9q21b_6 if s9q21__6!=. & (s9q21b_6!=. & s9q21b_6!=.a) 
	gen 	inm_servicios_mone	= s9q21b_7 if s9q21__7!=. & (s9q21b_7!=. & s9q21b_7!=.a) 
	gen 	inm_guarderia_mone	= s9q21b_8 if s9q21__8!=. & (s9q21b_8!=. & s9q21b_8!=.a) 
	gen 	inm_otro_mone		= s9q21b_9 if s9q21__9!=. & (s9q21b_9!=. & s9q21b_9!=.a)

	*** With respect to last month, how much was discounted from your monthly labor income as part of…? (each one is a dummy)
	/* s9q22__* Con respecto al mes pasado, ¿cuánto fue descontado del ingreso mensual de en su empleo por concepto de…?: d_*
				1 = Seguro social obligatorio
				2 = Seguro de paro forzoso
				3 = Impuesto sobre la renta
				4 = Caja de ahorro
				5 = Cuotas de préstamo
				6 = Régimen de Prestaciones de Vivienda y Hábitat
				7 = Otros	*/
		* Note: For those not self-employed or employers (s9q15==1|3|7|8|9)	// CAPI1=true
	gen     d_sso	 	= s9q22__1==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__1!=. & s9q22__1!=.a) 
	gen     d_spf	 	= s9q22__2==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__2!=. & s9q22__2!=.a) 
	gen     d_isr 		= s9q22__3==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__3!=. & s9q22__3!=.a) 
	gen     d_cah		= s9q22__4==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__4!=. & s9q22__4!=.a) 
	gen 	d_cpr		= s9q22__5==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__5!=. & s9q22__5!=.a) 
	gen 	d_rpv		= s9q22__6==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__6!=. & s9q22__6!=.a) 
	gen 	d_otro		= s9q22__7==1 if s9q15==(1|2|3|4|7|8|9) & (s9q22__7!=. & s9q22__7!=.a) 
		
	*** Amount received, or estimation of how much they would have paid for the benefit (1 variable for each of the 9 options)
	* s9q22a_*: Monto recibido (Si no percibe el beneficio en dinero, estime cuánto tendría que haber pagado por ese concepto (p.e. pago de guardería infantil, comedor en la empresa o transporte))
	gen     d_sso_cant 	= s9q22a_1 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_1!=. & s9q22a_1!=.a) 
	gen     d_spf_cant 	= s9q22a_2 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_2!=. & s9q22a_2!=.a) 
	gen     d_isr_cant 	= s9q22a_3 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_3!=. & s9q22a_3!=.a) 
	gen     d_cah_cant 	= s9q22a_4 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_4!=. & s9q22a_4!=.a) 
	gen 	d_cpr_cant 	= s9q22a_5 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_5!=. & s9q22a_5!=.a) 
	gen 	d_rpv_cant  = s9q22a_6 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_6!=. & s9q22a_6!=.a) 
	gen 	d_otro_cant = s9q22a_7 if s9q15==(1|2|3|4|7|8|9) & (s9q22a_7!=. & s9q22a_7!=.a) 

	*** In which currency? (1 variable for each of the 7 options)
	/* s9q22b_* En qué moneda?: d_*_moneda
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	gen     d_sso_mone 	= s9q22b_1 if s9q22__1!=. & (s9q22b_1!=. & s9q22b_1!=.a) 
	gen     d_spf_mone 	= s9q22b_2 if s9q22__2!=. & (s9q22b_2!=. & s9q22b_2!=.a) 
	gen     d_isr_mone	= s9q22b_3 if s9q22__3!=. & (s9q22b_3!=. & s9q22b_3!=.a) 
	gen     d_cah_mone	= s9q22b_4 if s9q22__4!=. & (s9q22b_4!=. & s9q22b_4!=.a) 
	gen 	d_cpr_mone	= s9q22b_5 if s9q22__5!=. & (s9q22b_5!=. & s9q22b_5!=.a) 
	gen 	d_rpv_mone 	= s9q22b_6 if s9q22__6!=. & (s9q22b_6!=. & s9q22b_6!=.a) 
	gen 	d_otro_mone	= s9q22b_7 if s9q22__7!=. & (s9q22b_7!=. & s9q22b_7!=.a)

* For employers (s9q15==5) // CAPI2=true
	
	*** Last month did you receive money due to the selling of products, goods, or services from your business or activity?
	/* s9q23 ¿El mes pasado recibió dinero por la venta de los productos, bienes o servicios de su negocio o actividad?: im_patron
				1 = si
				2 = no*/
		* Note: For employers (s9q15==5) // CAPI2=true	
	gen     im_patron 	= s9q23==1 if s9q15==5 & (s9q23!=. & s9q23!=.a) 
		
	*** Amount received
	* s9q23a: Monto recibido: im_patron_cant
	gen     im_patron_cant 	= s9q23a if s9q15==5 & (s9q23a!=. & s9q23a!=.a) 

	*** In which currency?
	/* s9q23b En qué moneda?
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	gen     im_patron_mone 	= s9q23b if s9q15==5 & (s9q23b!=. & s9q23b!=.a) 

	*** Last month did you take products from your business or activity you own or your household's consumption?
	/* s9q24 ¿El mes pasado retiró productos del negocio o actividad para consumo propio o de su hogar?: inm_patron
				1 = si
				2 = no*/
		* Note: For employers (s9q15==5) // CAPI2=true	
	gen     inm_patron 	= s9q24==1 if s9q15==5 & (s9q24!=. & s9q24!=.a) 
		
	*** How much you would have had to pay for these products?
	* s9q24a: ¿Cuánto hubiera tenido que pagar por esos productos?: inm_patron_cant
	gen     inm_patron_cant 	= s9q24a if s9q15==5 & (s9q24a!=. & s9q24a!=.a) 

	*** In which currency? 
	/* s9q24b ¿En qué moneda?: inm_patron_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	gen     inm_patron_mone 	= s9q24b if s9q15==5 & (s9q24b!=. & s9q24b!=.a)

* For self-employed workers (s9q15==6) // CAPI3=true
	
	*** During the last 12 months, did you receive money or net benefits derived from your business or activity?
	/* s9q25 ¿Durante los últimos doce (12) meses, recibió dinero por ganancias o utilidades netas derivadas del negocio o actividad? : im_indep
				1 = si
				2 = no	*/
		* Note: For self-employed workers (s9q15==6) // CAPI3=true	
	gen     im_indep 	= s9q25==1 if s9q15==6 & (s9q25!=. & s9q25!=.a) 
		
	*** Amount received
	* s9q25a: Cuánto recibió?: im_indep_cant
	gen     im_indep_cant 	= s9q25a if s9q15==6 & (s9q25a!=. & s9q25a!=.a) 

	*** In which currency? 
	/* s9q25b En qué moneda?: im_indep_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	gen     im_indep_mone 	= s9q25b if s9q15==6 & (s9q25b!=. & s9q25b!=.a) 

	*** Last month did you receive income from your activity for own expenses or from your household?
	/* s9q26 ¿El mes pasado, recibió ingresos por su actividad para gastos propios o de su hogar?: inm_indep
				1 = si
				2 = no	*/
		* Note: For self-employed workers (s9q15==6) // CAPI3=true	
	gen     inm_indep 	= s9q26==1 if s9q15==6 & (s9q26!=. & s9q26!=.a) 
		
	*** How much did you receive?
	* s9q26a: Cuánto recibió?: inm_indep_cant
	gen     inm_indep_cant 	= s9q26a if s9q15==6 & (s9q26a!=. & s9q26a!=.a) 

	*** In which currency? 
	/* s9q26b En qué moneda?: inm_indep_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	gen     inm_indep_mone 	= s9q26b if s9q15==5 & (s9q26b!=. & s9q26b!=.a)

	*** Last month, how much money did you spend to generate income (e.g. office renting, transport expenditures, cleaning products)?
	* s9q27: El mes pasado, ¿cuánto dinero gastó  para generar el ingreso (p.e. alquiler de oficina, gastos de transporte, productos de limpieza)?: gm_indep_cant
		* Note: For self-employed workers (s9q15==6) // CAPI3=true	
		* Note2: gm stands for gasto monetario
	gen     gm_indep_cant 	= s9q27 if s9q15==5 & (s9q27!=. & s9q27!=.a) 
		
	*** In which currency? 
	/* s9q27b En qué moneda?: inm_indep_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	gen     gm_indep_mone 	= s9q27a if s9q15==5 & (s9q27a!=. & s9q27a!=.a)

* For part-time workers (those who worked less than 35 hours last week in all their jobs) // CAPI4
				
	*** Why did you work less than 35 hours a week last week in all your jobs?
	/* s9q30: ¿Por qué trabajó menos de 35 horas la semana pasada en todos sus trabajos?: razon_menoshs
		1 = Trabaja a tiempo parcial
		2 = Conflicto laboral (huelga, protesta, paro)
		3 = Enfermedad, permiso, vacaciones
		4 = Falta de trabajo
		5 = Escasez de materiales o equipos en reparación
		6 = Otra (Especifique)	*/
		*Note: for part-time workers, i.e. those who worked less than 35 hours last week in all their jobs // CAPI4
	gen 	razon_menoshs = s9q30 if s9q18<35 & (s9q30!=. & s9q30!=.a) 

	*** Would you prefer to work more than 35 hs per week?
	/* s9q31 ¿Preferiría trabajar más de 35 horas por semana? 
				1 = si
				2 = no	*/
		*Note: For part-time workers, i.e. worked less than 35 hs s9q18<35 // CAPI4==true
	gen 	deseamashs = s9q31==1 if s9q18<35 & (s9q31!=. & s9q31!=.a)

	*** Have you done something to work more hours?
	/* s9q32 ¿Ha hecho algo parar trabajar mas horas?: buscamashs
				1 = si
				2 = no	*/
		*Note: For part-time workers, i.e. worked less than 35 hs s9q18<35 // CAPI4==true
	gen 	buscamashs = s9q32==1 if s9q18<35 & (s9q32!=. & s9q32!=.a)
		
	*** Why haven't you done something to work additional hours?
	/* s9q33 ¿Por cuál motivo no ha hecho diligencias para trabajar horas adicionales?: razon_nobusca
			1 = Cree que no hay trabajo
			2 = Está cansado de buscar trabajo
			3 = No sabe buscar trabajo
			4 = No encuentra trabajo apropiado
			5 = Está esperando trabajo o negocio
			6 = Dificultad para tramitar permisos
			7 = No consigue créditos o financiamientos
			8 = Es estudiante
			9 = Se ocupa del hogar
			10 = Enfermedad o discapacidad
			11 = Otra (Especifique)	*/
		* Note: For part-time workers, i.e. worked less than 35 hs s9q18<35 // CAPI4==true
	gen 	razon_nobusca = s9q33 if s9q18<35 & (s9q33!=. & s9q33!=.a)
	
* For all workers

	*** Have you changed jobs in the last 12 months?
	/* s9q34 ¿Ha cambiado de trabajo en los últimos 12 meses?: cambio_empleo
				1 = si
				2 = no	*/
	gen 	cambiotr = s9q34==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q34!=. & s9q34!=.a)

	*** What is the main reason why you changed jobs?
	/* s9q35 ¿Cuál fue la razón principal por la que cambió de trabajo?
		1 = Conseguir ingresos más altos
		2 = Tener un trabajo más adecuado
		3 = Finalización del contrato o empleo laboral
		4 = Dificultades con la empresa (despido, reducción de personal, cierre de la empresa)
		5 = Dificultades económica (falta de materiales e insumos para trabajar)
		6 = Otra (Especifique)	*/
	gen		razon_cambiotr = s9q35 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q35!=. & s9q35!=.a)

	*** Do you make contributions to any pension fund?
	/* s9q36 ¿Realiza aportes para algún fondo de pensiones?	
				1 = si
				2 = no	*/
	gen		aporta_pension = s9q36==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q36!=. & s9q36!=.a)

	*** Which pension fund?
	/* s9q37__* ¿A cuál fondo de pensión?	
				1 = El IVSS
				2 = Otra institución o empresa pública
				3 = Para institución o empresa privada
				4 = Otro	*/
	gen		pension_IVSS 	= s9q37__1==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__1!=. & s9q37__1!=.a)
	gen		pension_publi 	= s9q37__2==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__2!=. & s9q37__2!=.a)
	gen		pension_priv 	= s9q37__3==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__3!=. & s9q37__3!=.a)
	gen		pension_otro 	= s9q37__4==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__4!=. & s9q37__4!=.a)
	
	/* Bringing together s9q36 & s9q37__* to match previous ENCOVIs: aporte_pension
			1 = Si, para el IVSS
			2 = Si, para otra institucion o empresa publica
			3 = Si, para institucion o empresa privada
			4 = Si, para otra
			5 = No	*/
	gen 	aporte_pension = 1 if s9q36==1 & s9q37__1==1
	replace aporte_pension = 2 if s9q36==1 & s9q37__2==1
	replace aporte_pension = 3 if s9q36==1 & s9q37__3==1
	replace aporte_pension = 4 if s9q36==1 & s9q37__4==1
	replace aporte_pension = 5 if s9q36==2
	
	*** How much did you pay last month for pension funds?
	* s9q38 En el último mes, ¿cuánto pagó en total por fondos de pensiones? 
	gen		cant_aporta_pension = s9q38 if s9q36==1 & (s9q38!=. & s9q38!=.a)

	*** In which currency?
	/* s9q39a ¿En qué moneda? 
		1=bolivares, 2=dolares, 3=euros, 4=colombianos */
	gen		mone_aporta_pension = s9q39a if s9q36==1 & (s9q39a!=. & s9q39a!=.a)

	stop

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

* From CEDLAS which might be useful

	/* RELAB (FROM CEDLAS, might be useful):
			1 = Empleador
			2 = Empleado (asalariado)
			3 = Independiente (cuenta propista)
			4 = Trabajador sin salario
			5 = Desocupado
			. = No economicamente activos */
	gen     relab = .
	replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  // Employer 
	replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee. Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
	replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6)  //self-employed 
	replace relab = 4 if (labor_status==1 | labor_status==2) & categ_ocu== 8 //unpaid family worker
	replace relab = 2 if (labor_status==1 | labor_status==2) & (categ_ocu== 8 & (s9q19__1==1 | s9q19__2==1 | s9q19__3==1 | s9q19__4==1 | s9q19__5==1 | s9q19__6==1 | s9q19__7==1 | s9q19__8==1 | s9q19__9==1 | s9q19__10==1 | s9q19__11==1 | s9q19__12==1)) //paid family worker
	replace relab = 5 if (labor_status==3)

	* Asalariado en la ocupacion principal: asal
		* Dummy "asalariado" entre trabajadores
		gen     asal = (relab==2) if (relab>=1 & relab<=4)

	* Employed:	ocupado
	gen     ocupado = inrange(labor_status,1,2) //trabajando o no trabajando pero tiene trabajo

	* Unemployed: desocupa
	gen     desocupa = (labor_status==3)  //buscando trabajo
			
	* Inactive: inactivos	
	gen     inactivo= inrange(labor_status,5,9) 

	* Economically active population: pea	
	gen     pea = (ocupado==1 | desocupa ==1)


/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 1.9: Income Variables ----------------------------------------------------------
***********************************************************************************************************************************************)*/	

********** A. LABOR INCOME **********
	
****** 9.0. SET-UP ******
* Assumption for our new variables: No response and doesn't apply both are categorized as missing

*** MONETARY

/* 		* MONETARY PAYMENTS (s9q28_petro): Received payment through Petro (mostly for aguinaldo) // Added in the last questionnaire update
		* MONTO (s9q19_petromonto): Amount received
		
	* For employers (s9q15==5)	
		* MONETARY PAYMENTS (s9q23): ¿El mes pasado recibió dinero por la venta de los productos, bienes o servicios de su negocio o actividad? (only for employers, s9q15==5)
			1 = si
			2 = no
		* MONTO (s9q23a): Amount received
		* CURRENCY (s9q23b): Currency
		
	* For self-employed (s9q15==6)
		* MONETARY PAYMENTS (s9q26): El mes pasado, recibió ingresos por su actividad para gastos propios o de su hogar?
			1 = si
			2 = no
		* MONTO (s9q26a): Amount received
		* CURRENCY (s9q26b): Currency
		
		* HAS TO BE SUBSTRACTED FROM MONETARY PAYMENTS (s9q27): El mes pasado, ¿cuánto dinero gastó para generar el ingreso (p.e. alquiler de oficina, gastos de transporte, productos de limpieza)?
			Amount paid
		* CURRENCY (s9q27a): Currency
*/

* Ingreso laboral monetario, segun si recibieron o no en el ultimo mes
	gen recibe_ingresolab_mon = .
	replace recibe_ingresolab_mon = 1 if (s9q19__1==1 | s9q19__2==1 | s9q19__3==1 | s9q19__4==1 | s9q19__5==1 | s9q19__6==1 | s9q19__7==1 | s9q19__8==1 | s9q19__9==1 | s9q19__10==1 | s9q19__11==1 | s9q19__12==1) | s9q19_petro==1 | s9q23==1 | s9q26==1 // Recibió ingreso monetario en algún concepto
	replace recibe_ingresolab_mon = 0 if (s9q19__1==0 & s9q19__2==0 & s9q19__3==0 & s9q19__4==0 & s9q19__5==0 & s9q19__6==0 & s9q19__7==0 & s9q19__8==0 & s9q19__9==0 & s9q19__10==0 & s9q19__11==0 & s9q19__12==0) & s9q19_petro==2 & s9q23==2 & s9q26==2 // No recibió ingreso monetario en ningún concepto

* Checks: labor status and reception of monetary labor income
	tab labor_status recibe_ingresolab_mon, missing

	/*	  labor_status |      recibe_ingresolab_mon
					   |         1          . |     Total
			-----------+----------------------+----------
					 1 |     3,942        826 |     4,768 
					 2 |        75         65 |       140 
					 3 |         0        206 |       206 
					 5 |         0      2,111 |     2,111 
					 6 |         0        394 |       394 
					 7 |         0        455 |       455 
					 8 |         0      1,718 |     1,718 
					 9 |         0        707 |       707 
					 . |         0      1,934 |     1,934 
			-----------+----------------------+----------
				 Total |     4,017      8,416 |    12,433 */
		/* There is no unemployed (3), inactive (5-9), or person with missing (.) labor status reporting they receive labor income */

* Creating variables

local monedas "1 2 3 4" // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
	* Note: while respondants can register different concepts with different currencies, they can't register one concept with multiple currencies (ej. "sueldo y salario" paid in 2 different currencies) 

	gen ingresoslab_monpe = . 	// For not self-employed nor employers who received payment in Petro
	gen ingresoslab_monpe_dummy = .

foreach j of local monedas {

	gen ingresoslab_mon`j' = .
	gen ingresoslab_mon`j'_dummy = .
	gen pagoslab_mon`j' = . 	// For self-employed
			
	forvalues i = 1(1)12 {
			
		*For the not self-employed nor employers (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9)
		replace ingresoslab_mon`j' = s9q19a_`i' 						if ingresoslab_mon`j'==. & s9q19b_`i'==`j' & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q19a_`i'!=. & s9q19a_`i'!=.a)
		replace ingresoslab_mon`j' = ingresoslab_mon`j' + s9q19a_`i' 	if ingresoslab_mon`j'!=. & s9q19b_`i'==`j' & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q19a_`i'!=. & s9q19a_`i'!=.a)
			* Obs: First line is for the first not missing one to add up, second line is for the next ones to add up (same later for employers and self-employed)
			* Obs: The last parenthesis controls for cases where they say they were paid in a certain money, but don't say how much (same later for employers and self-employed)
	}
		replace ingresoslab_monpe = s9q19_petromonto 				if s9q19_petro==1 & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q19_petro!=. & s9q19_petro!=.a)	

		*For employers (s9q15==5)
		replace ingresoslab_mon`j' = s9q23a 						if ingresoslab_mon`j'==. & s9q23b==`j' & s9q15==5 & (s9q23a!=. & s9q23a!=.a) 
		replace ingresoslab_mon`j' = ingresoslab_mon`j' + s9q23a 	if ingresoslab_mon`j'!=. & s9q23b==`j' & s9q15==5 & (s9q23a!=. & s9q23a!=.a) 
	
		*For self-employed (s9q15==6)
		replace ingresoslab_mon`j' = s9q26a 						if ingresoslab_mon`j'==. & s9q26b==`j' & s9q15==6 & (s9q26a!=. & s9q26a!=.a)
		replace ingresoslab_mon`j' = ingresoslab_mon`j' + s9q26a 	if ingresoslab_mon`j'!=. & s9q26b==`j' & s9q15==6 & (s9q26a!=. & s9q26a!=.a)
			
		replace pagoslab_mon`j' = s9q27								if pagoslab_mon`j'==. & s9q27a==`j' & s9q15==6 & (s9q27!=. & s9q27!=.a)
		replace pagoslab_mon`j' = pagoslab_mon`j' + s9q27 			if pagoslab_mon`j'!=. & s9q27a==`j' & s9q15==6 & (s9q27!=. & s9q27!=.a)
			
		*Putting all together
		replace ingresoslab_mon`j'_dummy = 0 	if recibe_ingresolab_mon==1 & ingresoslab_mon`j'==. // Dicen que reciben pero no reportan cuánto
		replace ingresoslab_mon`j'_dummy = 1 	if ingresoslab_mon`j'>=0 & ingresoslab_mon`j'!=.
		
		tab ingresoslab_mon`j'_dummy
		sum ingresoslab_mon`j'
}
		*Putting all together for Petros
		replace ingresoslab_monpe_dummy = 0 	if recibe_ingresolab_mon==1 & ingresoslab_monpe==. // Dicen que reciben pero no reportan cuánto
		replace ingresoslab_monpe_dummy = 1 	if ingresoslab_monpe>=0 & ingresoslab_monpe!=.
		
		tab ingresoslab_monpe_dummy
		sum ingresoslab_monpe
				
	* Note: by February 25, of the people that reported having monetary payments, 81.4% reported having at least one in Bolívares, 7.8% in Dollars, 8.9% in Colombian pesos, none in Euros, and 11% in Petro (employers and self employed use foreign currency more).
	* Corroboro: OK porque a Febrero 26, 4374 reportes de monedas - 480 repetidos + 123 que no reportan ninguna moneda = 3934 - 480 + 123 = 4017, el total que reportan haber recibido ingreso laboral monetario
		gen noreporta=1 if ingresoslab_mon1_dummy==0 & ingresoslab_mon2_dummy==0 & ingresoslab_mon3_dummy==0 & ingresoslab_mon4_dummy==0 & ingresoslab_monpe_dummy==0
		egen cuantasreporta=rowtotal(ingresoslab_mon1_dummy ingresoslab_mon2_dummy ingresoslab_mon3_dummy ingresoslab_mon4_dummy ingresoslab_monpe_dummy)
		tab cuantasreporta
		tab noreporta
		drop noreporta cuantasreporta
		
	* We take everything to bolivares February 2020, given that there we have more sample // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio
		*Nota: We used Inflacion verdadera's inflation to build the deflactor
		* gen ingresoslab_monX_bolfeb = ingresoslab_monX		*tipo de cambio	* deflactor a febrero
		gen ingresoslab_mon1_bolfeb = ingresoslab_mon1					 		* 8.72818941228807	if interview_month==11
			replace ingresoslab_mon1_bolfeb = ingresoslab_mon1					* 6.01503214109115	if interview_month==12
			replace ingresoslab_mon1_bolfeb = ingresoslab_mon1					* 3.20509397505709	if interview_month==1
			replace ingresoslab_mon1_bolfeb = ingresoslab_mon1				 						if interview_month==2
		gen ingresoslab_mon2_bolfeb = ingresoslab_mon2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace ingresoslab_mon2_bolfeb = ingresoslab_mon2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace ingresoslab_mon2_bolfeb = ingresoslab_mon2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace ingresoslab_mon2_bolfeb = ingresoslab_mon2	*73460.1238 						if interview_month==2
		gen ingresoslab_mon3_bolfeb  = ingresoslab_mon3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace ingresoslab_mon3_bolfeb = ingresoslab_mon3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace ingresoslab_mon3_bolfeb = ingresoslab_mon3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace ingresoslab_mon3_bolfeb = ingresoslab_mon3	*80095.41371177						if interview_month==2
		gen ingresoslab_mon4_bolfeb = ingresoslab_mon4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace ingresoslab_mon4_bolfeb = ingresoslab_mon4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace ingresoslab_mon4_bolfeb = ingresoslab_mon4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace ingresoslab_mon4_bolfeb = ingresoslab_mon4	*21.66060704812						if interview_month==2
		* Supuesto: Dado que la gente contestaba números muy raros sobre lo que cobró en petro, vamos a asumir 1/2, que es el valor del aguinaldo/pensiones recibidas. También asumiremos que 1 petro=$US 30
		gen ingresoslab_monpe_bolfeb  = ingresoslab_monpe_dummy	*30*73460.1238 		if ingresoslab_monpe_dummy==1
	
	egen ingresoslab_mon = rowtotal(ingresoslab_mon1_bolfeb ingresoslab_mon2_bolfeb ingresoslab_mon3_bolfeb ingresoslab_mon4_bolfeb ingresoslab_monpe_bolfeb)

	* Substract payments done to get the self-employed's actual income
		gen pagoslab_mon1_bolfeb = pagoslab_mon1						 	* 8.72818941228807	if interview_month==11 & s9q15==6
			replace pagoslab_mon1_bolfeb = pagoslab_mon1					* 6.01503214109115	if interview_month==12 & s9q15==6
			replace pagoslab_mon1_bolfeb = pagoslab_mon1					* 3.20509397505709	if interview_month==1 & s9q15==6
			replace pagoslab_mon1_bolfeb = pagoslab_mon1				 						if interview_month==2 & s9q15==6
		gen pagoslab_mon2_bolfeb = pagoslab_mon2			*30097.14836 	* 8.72818941228807	if interview_month==11 & s9q15==6
			replace pagoslab_mon2_bolfeb = pagoslab_mon2	*44482.68537895 * 6.01503214109115	if interview_month==12 & s9q15==6
			replace pagoslab_mon2_bolfeb = pagoslab_mon2	*68780.160295 	* 3.20509397505709	if interview_month==1 & s9q15==6
			replace pagoslab_mon2_bolfeb = pagoslab_mon2	*73460.1238 						if interview_month==2 & s9q15==6
		gen pagoslab_mon3_bolfeb  = pagoslab_mon3			*33227.24238536 * 8.72818941228807	if interview_month==11 & s9q15==6
			replace pagoslab_mon3_bolfeb = pagoslab_mon3	*49431.92724323 * 6.01503214109115	if interview_month==12 & s9q15==6
			replace pagoslab_mon3_bolfeb = pagoslab_mon3	*76259.14734081 * 3.20509397505709 	if interview_month==1 & s9q15==6
			replace pagoslab_mon3_bolfeb = pagoslab_mon3	*80095.41371177						if interview_month==2 & s9q15==6
		gen pagoslab_mon4_bolfeb = pagoslab_mon4			*8.7947132815 	* 8.72818941228807	if interview_month==11 & s9q15==6
			replace pagoslab_mon4_bolfeb = pagoslab_mon4	*13.19404117947 * 6.01503214109115	if interview_month==12 & s9q15==6
			replace pagoslab_mon4_bolfeb = pagoslab_mon4	*20.6963505285 	* 3.20509397505709	if interview_month==1 & s9q15==6
			replace pagoslab_mon4_bolfeb = pagoslab_mon4	*21.66060704812						if interview_month==2 & s9q15==6
	
	egen pagoslab_mon = rowtotal(pagoslab_mon1_bolfeb pagoslab_mon2_bolfeb pagoslab_mon3_bolfeb pagoslab_mon4_bolfeb)

	*Final: putting everything together
	replace ingresoslab_mon = ingresoslab_mon - pagoslab_mon
		

*** NON-MONETARY

/*  * For employers (s9q15==5)	
		* BENEFITS/NON-MONETARY PAYMENTS FOR EMPLOYERS (s9q24): ¿El mes pasado retiró productos del negocio o actividad para consumo propio o de su hogar?
			1 = si
			2 = no
		* MONTO (s9q24a): Amount received, or estiamtion of how much they would have paid for the benefit
		* CURRENCY (s9q24b): Currency
*/
		
* Ingresos laboral no monetario, segun si recibieron o no en el ultimo mes
	gen recibe_ingresolab_nomon = .
	replace recibe_ingresolab_nomon = 1 if (s9q21__1==1 | s9q21__2==1 | s9q21__3==1 | s9q21__4==1 | s9q21__5==1 | s9q21__6==1 | s9q21__7==1 | s9q21__8==1 | s9q21__9==1 ) | s9q24==1 // Recibió ingreso no monetario en algún concepto
	replace recibe_ingresolab_nomon = 0 if (s9q21__1==0 & s9q21__2==0 & s9q21__3==0 & s9q21__4==0 & s9q21__5==0 & s9q21__6==0 & s9q21__7==0 & s9q21__8==0 & s9q21__9==0 ) & s9q24==2 // No recibió ingreso no monetario en ningún concepto

* Situacion laboral y recepcion de ingreso monetario
	tab labor_status recibe_ingresolab_nomon, missing

	/*    labor_status |     recibe_ingresolab_nomon
					   |         1          . |     Total
			-----------+----------------------+----------
					 1 |       365      4,403 |     4,768 
					 2 |         8        132 |       140 
					 3 |         0        206 |       206 
					 5 |         0      2,111 |     2,111 
					 6 |         0        394 |       394 
					 7 |         0        455 |       455 
					 8 |         0      1,718 |     1,718 
					 9 |         0        707 |       707 
					 . |         0      1,934 |     1,934 
			-----------+----------------------+----------
				 Total |       373     12,060 |    12,433   */
		/* There is no unemployed (3), inactive (5-9), or person with missing (.) labor status reporting they receive labor income */

foreach j of local monedas {

	gen ingresoslab_bene`j' = .
	gen ingresoslab_bene`j'_dummy = .
			
	forvalues i = 1(1)9 {
			
		*For the not self-employed or employers (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9)
		replace ingresoslab_bene`j' = s9q21a_`i' 						if ingresoslab_bene`j'==. & s9q21b_`i'==`j' & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q21a_`i'!=. & s9q21a_`i'!=.a)
		replace ingresoslab_bene`j' = ingresoslab_bene`j' + s9q21a_`i' 	if ingresoslab_bene`j'!=. & s9q21b_`i'==`j' & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q21a_`i'!=. & s9q21a_`i'!=.a)
		* Obs: First line is for the first not missing one to add up, second line is for the next ones to add up (same later for employers)
		* Obs: The last parenthesis controls for cases where they say they received benefits, but don't say how much (same later for employers)
	}
		*For employers (s9q15==5)
		replace ingresoslab_bene`j' = s9q24a 						if ingresoslab_bene`j'==. & s9q24b==`j' & s9q15==5 & (s9q24!=. & s9q24a!=.a)
		replace ingresoslab_bene`j' = ingresoslab_bene`j' + s9q24a 	if ingresoslab_bene`j'!=. & s9q24b==`j' & s9q15==5 & (s9q24!=. & s9q24a!=.a)
		
		*Putting all together
		replace ingresoslab_bene`j'_dummy = 0 	if recibe_ingresolab_nomon==1 & ingresoslab_bene`j'==. // Dicen que reciben pero no reportan cuánto
		replace ingresoslab_bene`j'_dummy = 1 	if ingresoslab_bene`j'>=0 & ingresoslab_bene`j'!=.
		
		tab ingresoslab_bene`j'_dummy
		sum ingresoslab_bene`j'
}
	* Note: by February 26, of the people who reported having benefits, 89.5% reported their value in Bolívares, 2.7% in Dollars, 6.2% in Colombian pesos, and none in Euros.
	* Corroboro: OK porque a Feb26 367 reportan en una u otra moneda, más 9 que no reportan ninguna moneda, menos 3 que repiten monedas = 367-9+3 = 373, el total que reportan haber recibido ingreso laboral no monetario
		gen noreporta=1 if ingresoslab_bene1_dummy==0 & ingresoslab_bene2_dummy==0 & ingresoslab_bene3_dummy==0 & ingresoslab_bene4_dummy==0
		egen cuantasreporta=rowtotal(ingresoslab_bene1_dummy ingresoslab_bene2_dummy ingresoslab_bene3_dummy ingresoslab_bene4_dummy)
		tab cuantasreporta
		tab noreporta
		drop noreporta cuantasreporta

		* We take everything to bolivares February 2020, given that there we have more sample // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio
		*Nota: We used Inflacion verdadera's inflation to build the deflactor
		* gen ingresoslab_monX_bolfeb = ingresoslab_monX		*tipo de cambio	* deflactor a febrero
		gen ingresoslab_bene1_bolfeb = ingresoslab_bene1					 		* 8.72818941228807	if interview_month==11
			replace ingresoslab_bene1_bolfeb = ingresoslab_bene1					* 6.01503214109115	if interview_month==12
			replace ingresoslab_bene1_bolfeb = ingresoslab_bene1					* 3.20509397505709	if interview_month==1
			replace ingresoslab_bene1_bolfeb = ingresoslab_bene1				 						if interview_month==2
		gen ingresoslab_bene2_bolfeb = ingresoslab_bene2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace ingresoslab_bene2_bolfeb = ingresoslab_bene2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace ingresoslab_bene2_bolfeb = ingresoslab_bene2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace ingresoslab_bene2_bolfeb = ingresoslab_bene2	*73460.1238 						if interview_month==2
		gen ingresoslab_bene3_bolfeb  = ingresoslab_bene3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace ingresoslab_bene3_bolfeb = ingresoslab_bene3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace ingresoslab_bene3_bolfeb = ingresoslab_bene3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace ingresoslab_bene3_bolfeb = ingresoslab_bene3	*80095.41371177						if interview_month==2
		gen ingresoslab_bene4_bolfeb = ingresoslab_mon4				*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace ingresoslab_bene4_bolfeb = ingresoslab_bene4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace ingresoslab_bene4_bolfeb = ingresoslab_bene4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace ingresoslab_bene4_bolfeb = ingresoslab_bene4	*21.66060704812						if interview_month==2
		* Supuesto: Dado que la gente contestaba números muy raros sobre lo que cobró en petro, vamos a asumir 1/2, que es el valor del aguinaldo/pensiones recibidas. También asumiremos que 1 petro=$US 30
		
	egen ingresoslab_bene = rowtotal(ingresoslab_bene1_bolfeb ingresoslab_bene2_bolfeb ingresoslab_bene3_bolfeb ingresoslab_bene4_bolfeb)
		
****** 9.1.PRIMARY LABOR INCOME ******

/*
ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia */


**Note: We are still missing the exchange rates, but when we have them we should change everything into bolívares following the daily rates.

*****  i)  PATRÓN
	* Monetario	
	* Ingreso monetario laboral de la actividad principal si es patrón
	gen     ipatrp_m = ingresoslab_mon if relab==1  

	* No monetario
	gen     ipatrp_nm = ingresoslab_bene if relab==1 	

****  ii)  ASALARIADOS
	* Monetario	
	* Ingreso monetario laboral de la actividad principal si es asalariado
	gen     iasalp_m = ingresoslab_mon if relab==2

	* No monetario
	gen     iasalp_nm = ingresoslab_bene if relab==2


***** iii)  CUENTA PROPIA
	* Monetario	
	* Ingreso monetario laboral de la actividad principal si es cuenta propia
	gen     ictapp_m = ingresoslab_mon if relab==3

	* No monetario
	gen     ictapp_nm = ingresoslab_bene if relab==3
	
***** iv) Otros - trabajador sin salario
	gen iolp_m = ingresoslab_mon if relab==4
	
	gen iolp_nm = ingresoslab_bene if relab==4

	
****** 9.2. SECONDARY LABOR INCOME ******
*The survey does not differenciate between both

	* Monetary
	gen     ipatrnp_m = .
	gen     iasalnp_m = .
	gen     ictapnp_m = .
	gen     iolnp_m=.

	* Non-monetary
	gen     ipatrnp_nm = .
	gen     iasalnp_nm = .
	gen     ictapnp_nm = .
	gen     iolnp_nm = .

********** B. NON-LABOR INCOME **********

****** 9.3.NON-LABOR INCOME ******
/* Incluye 
	1) Jubilaciones y pensiones
	2) Ingresos de capital (capital, intereses, alquileres, rentas, beneficios y dividendos)
	3) Transferencias privadas y estatales
*/

*Locales
	*Jubilaciones y pensiones // ijubi_m
		gen ing_nlb_pi = 1   if s9q28__1==1 // Pensión de incapacidad, orfandad, sobreviviente
		gen ing_nlb_pv = 1   if s9q28__2==1 // Pensión de vejez por el seguro social
		gen ing_nlb_jt = 1   if s9q28__3==1 // Jubilación por trabajo
		gen ing_nlb_pd = 1   if s9q28__4==1 // Pensión por divorcio, separación, alimentación
		gen ing_nlb_pe = 1   if s9q28_petro==1 // Petro - Dado como pago de pensión  // Added in the last questionnaire update
	*Transferencias estatales // itrane_o_m 
		gen ing_nlb_epu = 1  if s9q28__5==1 // Beca o ayuda escolar pública 
		gen ing_nlb_apu = 1  if s9q28__7==1 // Ayuda de instituciones públicas
	*Transferencias privadas // itranp_o_m 
		gen ing_nlb_epr = 1  if s9q28__6==1 // Beca o ayuda escolar privada
		gen ing_nlb_apr = 1  if s9q28__8==1 // Ayuda de instituciones privadas
		gen ing_nlb_afh = 1  if s9q28__9==1 // Ayudas familiares o contribuciones de otros hogares
		gen ing_nlb_afm = 1  if s9q28__10==1 // Asignación familiar por menores a su cargo
	*Transferencias (no claro si públicas o privadas) // otro - itrane_ns 	
		gen ing_nlb_ot = 1   if s9q28__11==1 
*Provenientes del exterior
	*Jubilaciones y pensiones
		gen ing_nlb_xpj = 1  if s9q29a__5==1 // Pensión y jubilaciones // ijubi_m
	*Transferencias privadas y estatales
		gen ing_nlb_xr = 1   if s9q29a__4==1 // Remesas o ayudas periódicas de otros hogares del exterior  //  rem
		gen ing_nlb_xba = 1  if s9q29a__7==1 // Becas y/o ayudas escolares // itranp_ns
	*Ingresos de capital //  icap_m
		gen ing_nlb_xid = 1  if s9q29a__6==1 // Intereses y dividendos
		gen ing_nlb_xa = 1   if s9q29a__9==1 // Alquileres (vehículos, tierras o terrenos, inmueble residenciales o no)
	* Ingresos no laborales extraordinarios
 		gen ing_nlb_xte = 1  if s9q29a__8==1 // Transferencias extraordinarias (indemnizaciones por seguro, herencia, ayuda de otros hogares)  //  inla_extraord
		gen ing_nlb_xi = 1   if s9q29a__3==1 // Indemnizaciones por enfermedad o accidente  //  inla_extraord

*How many non-labor incomes do people receive?
	egen    recibe = rowtotal(ing_nlb_*), mi
	tab recibe

	/*       recibe |      Freq.     Percent        Cum.
		------------+-----------------------------------
				  1 |      2,462       59.64       59.64
				  2 |      1,083       26.24       85.88
				  3 |        433       10.49       96.37
				  4 |        124        3.00       99.37
				  5 |         22        0.53       99.90
				  6 |          3        0.07       99.98
				  7 |          1        0.02      100.00
		------------+-----------------------------------
			  Total |      4,128      100.00			*/ 

****** 9.3.1.JUBILACIONES Y PENSIONES ******	  
	
	/* 	s9q12==6 // Está jubilado o pensionado

	s9q28__1 // Recibe pensión de sobreviviente, orfandad, incapacidad
	s9q28__2 // Recibe pensión de vejez por el seguro social
	s9q28__4 // Recibe pensión por divorcio, separación, alimentacion

	s9q28__3 // Recibe jubilación por trabajo

	s9q28a_* // Monto recibido
	s9q28a_* // Moneda
	
	s9q28_petro // Recibió petro
	s9q28_petromonto // Monto recibido
	
	s9q29a__5==1 // Recibe pensión o jubilacion del exterior
	s9q29b__5 // Monto que recibe del exterior por su pensión o jubilación
	s9q29b__5 // Moneda														*/

* Monetary
		
/* ijubi_m: Ingreso monetario por jubilaciones y pensiones */

	*Reception
	gen recibe_penojub_mon = .
	replace recibe_penojub_mon = 1 if (s9q28__1==1 | s9q28__2==1 | s9q28__3==1 | s9q28__4==1) | s9q28_petro==1 | s9q29a__5==1 // Recibió pensión o jubilación en algún concepto
	replace recibe_penojub_mon = 0 if (s9q28__1==0 & s9q28__2==0 & s9q28__3==0 & s9q28__4==0) & s9q28_petro==2 & s9q29a__5==0 // No recibió pensión o jubilación en ningún concepto
	tab recibe_penojub_mon s9q12, missing
	/* Obs: there are many people who did not say they were "jubilados o pensionados" but receive pensiones o jubilaciones, thus we will not control for having answered s9q12==6 */
	
	*We create ijubi_m* for each currency
	gen ijubi_mpetro=.
	gen ijubi_mpetro_dummy=.

	foreach j of local monedas {

		gen ijubi_m`j' = .
		gen ijubi_m`j'_dummy = .
		
		forvalues i = 1(1)4 {
			
			*Local
			replace ijubi_m`j' = s9q28a_`i' 				if ijubi_m`j'==. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
			replace ijubi_m`j' = ijubi_m`j' + s9q28a_`i' 	if ijubi_m`j'!=. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
			* Obs: First line is for the first not missing one to add up, second line is for the next ones to add up (same later for employers)
			* Obs: The last parenthesis controls for cases where they say they received jubilaciones o pensiones, but don't say how much
			
		}		
			*From abroad
			replace ijubi_m`j' = s9q29b_5	 				if ijubi_m`j'==. & s9q29c_5==`j' & (s9q29b_5!=. & s9q29b_5!=.a)
			replace ijubi_m`j' = ijubi_m`j' + s9q29b_5	 	if ijubi_m`j'!=. & s9q29c_5==`j' & (s9q29b_5!=. & s9q29b_5!=.a)

			*Putting all together by currency
			replace ijubi_m`j'_dummy = 0 	if recibe_penojub_mon==1 & ijubi_m`j'==. // Dicen que reciben pero no reportan cuánto
			replace ijubi_m`j'_dummy = 1 	if ijubi_m`j'>=0 & ijubi_m`j'!=.
			
			tab ijubi_m`j'_dummy
			sum ijubi_m`j'
	}
			*Petro "currency"
			replace ijubi_mpetro = s9q28_petromonto 				if ijubi_mpetro==. & s9q28_petro==1 & (s9q28_petro!=. & s9q28_petro!=.a)
			replace ijubi_mpetro = ijubi_mpetro + s9q28_petromonto 	if ijubi_mpetro!=. & s9q28_petro==1 & (s9q28_petro!=. & s9q28_petro!=.a)

			replace ijubi_mpetro_dummy = 0 	if recibe_penojub_mon==1 & ijubi_mpetro==. // Dicen que reciben pero no reportan cuánto
			replace ijubi_mpetro_dummy = 1 	if ijubi_mpetro>=0 & ijubi_mpetro!=.
			
			tab ijubi_mpetro_dummy
			sum ijubi_mpetro
			
			*Checking
			gen noreporta=1 if ijubi_m1_dummy==0 & ijubi_m2_dummy==0 & ijubi_m3_dummy==0 & ijubi_m4_dummy==0 & ijubi_mpetro_dummy==0
			egen cuantasreporta=rowtotal(ijubi_m1_dummy ijubi_m2_dummy ijubi_m3_dummy ijubi_m4_dummy ijubi_mpetro_dummy)
			tab cuantasreporta
			tab noreporta
			drop noreporta cuantasreporta
			* Note: by February 26, of the people who reported having jubilacion o pension, 92.1% reported in Bolívares, 0.08% in Dollars, 0.04% in Euros, 0.3% in Colombian pesos, and 48.6% in Petros.

		* We take everything to bolivares February 2020, given that there we have more sample // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio
		*Nota: We used Inflacion verdadera's inflation to build the deflactor
		* gen ingresoslab_monX_bolfeb = ingresoslab_monX		*tipo de cambio	* deflactor a febrero
		gen ijubi_m1_bolfeb = ijubi_m1					 		* 8.72818941228807	if interview_month==11
			replace ijubi_m1_bolfeb = ijubi_m1					* 6.01503214109115	if interview_month==12
			replace ijubi_m1_bolfeb = ijubi_m1					* 3.20509397505709	if interview_month==1
			replace ijubi_m1_bolfeb = ijubi_m1				 						if interview_month==2
		gen ijubi_m2_bolfeb = ijubi_m2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace ijubi_m2_bolfeb = ijubi_m2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace ijubi_m2_bolfeb = ijubi_m2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace ijubi_m2_bolfeb = ijubi_m2	*73460.1238 						if interview_month==2
		gen ijubi_m3_bolfeb  = ijubi_m3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace ijubi_m3_bolfeb = ijubi_m3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace ijubi_m3_bolfeb = ijubi_m3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace ijubi_m3_bolfeb = ijubi_m3	*80095.41371177						if interview_month==2
		gen ijubi_m4_bolfeb = ijubi_m4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace ijubi_m4_bolfeb = ijubi_m4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace ijubi_m4_bolfeb = ijubi_m4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace ijubi_m4_bolfeb = ijubi_m4	*21.66060704812						if interview_month==2
		* Supuesto: Dado que la gente contestaba números muy raros sobre lo que cobró en petro, vamos a asumir 1/2, que es el valor del aguinaldo/pensiones recibidas. También asumiremos que 1 petro=$US 30
		gen ijubi_mpe_bolfeb  = ijubi_mpetro_dummy	*30*73460.1238 		if ijubi_mpetro_dummy==1
	
	egen ijubi_m = rowtotal(ijubi_m1_bolfeb ijubi_m2_bolfeb ijubi_m3_bolfeb ijubi_m4_bolfeb ijubi_mpe_bolfeb)
                         
	/*
	replace ijubi_m = ijubi_m1 + ijubi_m2 + ijubi_m3 + ijubi_m4 + ijubi_mpetro if recibe_penojub_mon==1 // First making ijubi_m* in Bolívares 
	*/

* No monetario	
	gen     ijubi_nm=.
	notes ijubi_nm: the survey does not include information to define this variable

****** 9.3.2.INGRESOS DE CAPITAL ******	
		
/*icap_m: Ingreso monetario de capital, intereses, alquileres, rentas, beneficios y dividendos */
		
	foreach j of local monedas {

		gen icap_m`j' = .
		
		foreach i of numlist 6 9 {
				
			replace icap_m`j' = s9q29b_`i' 					if icap_m`j'==. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
			replace icap_m`j' = icap_m`j' + s9q29b_`i' 	if icap_m`j'!=. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
			* Obs: First line is for the first not missing one to add up, second line is for the next ones to add up
			* Obs: The last parenthesis controls for cases where they say they received interests, dividends or rent from abroad, but don't say how much
		}		
			sum icap_m`j'
	}

		gen icap_m1_bolfeb = icap_m1					 		* 8.72818941228807	if interview_month==11
			replace icap_m1_bolfeb = icap_m1					* 6.01503214109115	if interview_month==12
			replace icap_m1_bolfeb = icap_m1					* 3.20509397505709	if interview_month==1
			replace icap_m1_bolfeb = icap_m1				 						if interview_month==2
		gen icap_m2_bolfeb = icap_m2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace icap_m2_bolfeb = icap_m2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace icap_m2_bolfeb = icap_m2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace icap_m2_bolfeb = icap_m2	*73460.1238 						if interview_month==2
		gen icap_m3_bolfeb  = icap_m3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace icap_m3_bolfeb = icap_m3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace icap_m3_bolfeb = icap_m3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace icap_m3_bolfeb = icap_m3	*80095.41371177						if interview_month==2
		gen icap_m4_bolfeb = icap_m4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace icap_m4_bolfeb = icap_m4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace icap_m4_bolfeb = icap_m4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace icap_m4_bolfeb = icap_m4	*21.66060704812						if interview_month==2
	
	egen icap_m = rowtotal(icap_m1_bolfeb icap_m2_bolfeb icap_m3_bolfeb icap_m4_bolfeb)
	
	* No monetario	
	gen     icap_nm=.
	notes icap_nm: the survey does not include information to define this variable

****** 9.3.3.REMESAS ******	

/*rem: Ingreso monetario de remesas */
	
	foreach j of local monedas {

		gen rem`j' = .
		
		foreach i of numlist 4 {
		*Assumption only the option "Remesas o ayudas periódicas de otros hogares del exterior" counts as remesas
			replace rem`j' = s9q29b_`i' 			if rem`j'==. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
			replace rem`j' = rem`j' + s9q29b_`i' 	if rem`j'!=. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}		
			sum rem`j' // 89 report in bolívares
	}
	
		gen rem1_bolfeb = rem1					 		* 8.72818941228807	if interview_month==11
			replace rem1_bolfeb = rem1					* 6.01503214109115	if interview_month==12
			replace rem1_bolfeb = rem1					* 3.20509397505709	if interview_month==1
			replace rem1_bolfeb = rem1				 						if interview_month==2
		gen rem2_bolfeb = rem2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace rem2_bolfeb = rem2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace rem2_bolfeb = rem2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace rem2_bolfeb = rem2	*73460.1238 						if interview_month==2
		gen rem3_bolfeb  = rem3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace rem3_bolfeb = rem3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace rem3_bolfeb = rem3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace rem3_bolfeb = rem3	*80095.41371177						if interview_month==2
		gen rem4_bolfeb = rem4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace rem4_bolfeb = rem4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace rem4_bolfeb = rem4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace rem4_bolfeb = rem4	*21.66060704812						if interview_month==2
	
	egen rem = rowtotal(rem1_bolfeb rem2_bolfeb rem3_bolfeb rem4_bolfeb)

	
****** 9.3.4.TRANSFERENCIAS PRIVADAS ******	
		
/* itranp_o_m Ingreso monetario de otras transferencias privadas diferentes a remesas */

* Monetario

	foreach j of local monedas {

		gen itranp_o_m`j' = .
		
		foreach i of numlist 6 8 9 10 {
				
			replace itranp_o_m`j' = s9q28a_`i' 					if itranp_o_m`j'==. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
			replace itranp_o_m`j' = itranp_o_m`j' + s9q28a_`i' 	if itranp_o_m`j'!=. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
		}		
			sum itranp_o_m`j'
	}
	
		gen itranp_o_m1_bolfeb = itranp_o_m1					 		* 8.72818941228807	if interview_month==11
			replace itranp_o_m1_bolfeb = itranp_o_m1					* 6.01503214109115	if interview_month==12
			replace itranp_o_m1_bolfeb = itranp_o_m1					* 3.20509397505709	if interview_month==1
			replace itranp_o_m1_bolfeb = itranp_o_m1				 						if interview_month==2
		gen itranp_o_m2_bolfeb = itranp_o_m2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace itranp_o_m2_bolfeb = itranp_o_m2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace itranp_o_m2_bolfeb = itranp_o_m2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace itranp_o_m2_bolfeb = itranp_o_m2	*73460.1238 						if interview_month==2
		gen itranp_o_m3_bolfeb  = itranp_o_m3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace itranp_o_m3_bolfeb = itranp_o_m3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace itranp_o_m3_bolfeb = itranp_o_m3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace itranp_o_m3_bolfeb = itranp_o_m3	*80095.41371177						if interview_month==2
		gen itranp_o_m4_bolfeb = itranp_o_m4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace itranp_o_m4_bolfeb = itranp_o_m4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace itranp_o_m4_bolfeb = itranp_o_m4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace itranp_o_m4_bolfeb = itranp_o_m4	*21.66060704812						if interview_month==2
	
	egen itranp_o_m = rowtotal(itranp_o_m1_bolfeb itranp_o_m2_bolfeb itranp_o_m3_bolfeb itranp_o_m4_bolfeb)

	
* No monetario	
	gen    itranp_o_nm =.

****** 9.3.5 TRANSFERENCIAS PRIVADAS ******	

* Monetario
*itranp_ns: Ingreso monetario de transferencias privadas, cuando no se puede distinguir entre remesas y otras

foreach j of local monedas {

		gen itranp_ns`j' = .
		
		foreach i of numlist 7 {
			replace itranp_ns`j' = s9q29b_`i' 					if itranp_ns`j'==. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
			replace itranp_ns`j' = itranp_ns`j' + s9q29b_`i' 	if itranp_ns`j'!=. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}		
			sum itranp_ns`j'
	}
	
		gen itranp_ns1_bolfeb = itranp_ns1					 		* 8.72818941228807	if interview_month==11
			replace itranp_ns1_bolfeb = itranp_ns1					* 6.01503214109115	if interview_month==12
			replace itranp_ns1_bolfeb = itranp_ns1					* 3.20509397505709	if interview_month==1
			replace itranp_ns1_bolfeb = itranp_ns1				 						if interview_month==2
		gen itranp_ns2_bolfeb = itranp_ns2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace itranp_ns2_bolfeb = itranp_ns2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace itranp_ns2_bolfeb = itranp_ns2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace itranp_ns2_bolfeb = itranp_ns2	*73460.1238 						if interview_month==2
		gen itranp_ns3_bolfeb  = itranp_ns3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace itranp_ns3_bolfeb = itranp_ns3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace itranp_ns3_bolfeb = itranp_ns3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace itranp_ns3_bolfeb = itranp_ns3	*80095.41371177						if interview_month==2
		gen itranp_ns4_bolfeb = itranp_ns4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace itranp_ns4_bolfeb = itranp_ns4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace itranp_ns4_bolfeb = itranp_ns4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace itranp_ns4_bolfeb = itranp_ns4	*21.66060704812						if interview_month==2
	
	egen itranp_ns = rowtotal(itranp_ns1_bolfeb itranp_ns2_bolfeb itranp_ns3_bolfeb itranp_ns4_bolfeb)


****** 9.3.6 TRANSFERENCIAS ESTATALES ******	

****** 9.3.6.1 TRANSFERENCIAS ESTATALES CONDICIONADAS******
* cct: Ingreso monetario por transferencias estatales relacionadas con transferencias monetarias condicionadas

	gen     cct = .
	notes cct: the survey does not include information to define this variable
	
****** 9.3.6.2 OTRAS TRANSFERENCIAS ESTATALES******
* itrane_o_m Ingreso monetario por transferencias estatales diferentes a las transferencias monetarias condicionadas

* Monetarias
	foreach j of local monedas {

		gen itrane_o_m`j' = .
		
		foreach i of numlist 5 7 {
				
			replace itrane_o_m`j' = s9q28a_`i' 					if itrane_o_m`j'==. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
			replace itrane_o_m`j' = itrane_o_m`j' + s9q28a_`i' 	if itrane_o_m`j'!=. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
		}		
			sum itrane_o_m`j'
	}
	
		gen itrane_o_m1_bolfeb = itrane_o_m1					 		* 8.72818941228807	if interview_month==11
			replace itrane_o_m1_bolfeb = itrane_o_m1					* 6.01503214109115	if interview_month==12
			replace itrane_o_m1_bolfeb = itrane_o_m1					* 3.20509397505709	if interview_month==1
			replace itrane_o_m1_bolfeb = itrane_o_m1				 						if interview_month==2
		gen itrane_o_m2_bolfeb = itrane_o_m2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace itrane_o_m2_bolfeb = itrane_o_m2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace itrane_o_m2_bolfeb = itrane_o_m2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace itrane_o_m2_bolfeb = itrane_o_m2	*73460.1238 						if interview_month==2
		gen itrane_o_m3_bolfeb  = itrane_o_m3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace itrane_o_m3_bolfeb = itrane_o_m3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace itrane_o_m3_bolfeb = itrane_o_m3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace itrane_o_m3_bolfeb = itrane_o_m3	*80095.41371177						if interview_month==2
		gen itrane_o_m4_bolfeb = itrane_o_m4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace itrane_o_m4_bolfeb = itrane_o_m4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace itrane_o_m4_bolfeb = itrane_o_m4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace itrane_o_m4_bolfeb = itrane_o_m4	*21.66060704812						if interview_month==2
	
	egen itrane_o_m = rowtotal(itrane_o_m1_bolfeb itrane_o_m2_bolfeb itrane_o_m3_bolfeb itrane_o_m4_bolfeb)

	
*No monetarias
	gen     itrane_o_nm = .
	notes itrane_o_nm: the survey does not include information to define this variable


****** 9.3.7 OTRAS TRANSFERENCIAS ******	
*itrane_ns Ingreso monetario por transferencias cuando no se puede distinguir 

	foreach j of local monedas {

		gen itrane_ns`j' = .
		
		foreach i of numlist 11 {
				
			replace itrane_ns`j' = s9q28a_`i' 					if itrane_ns`j'==. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
			replace itrane_ns`j' = itrane_o_m`j' + s9q28a_`i' 	if itrane_ns`j'!=. & s9q28b_`i'==`j' & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
		}		
			sum itrane_ns`j'
	}
	
		gen itrane_ns1_bolfeb = itrane_ns1					 		* 8.72818941228807	if interview_month==11
			replace itrane_ns1_bolfeb = itrane_ns1					* 6.01503214109115	if interview_month==12
			replace itrane_ns1_bolfeb = itrane_ns1					* 3.20509397505709	if interview_month==1
			replace itrane_ns1_bolfeb = itrane_ns1				 						if interview_month==2
		gen itrane_ns2_bolfeb = itrane_ns2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace itrane_ns2_bolfeb = itrane_ns2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace itrane_ns2_bolfeb = itrane_ns2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace itrane_ns2_bolfeb = itrane_ns2	*73460.1238 						if interview_month==2
		gen itrane_ns3_bolfeb  = itrane_ns3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace itrane_ns3_bolfeb = itrane_ns3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace itrane_ns3_bolfeb = itrane_ns3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace itrane_ns3_bolfeb = itrane_ns3	*80095.41371177						if interview_month==2
		gen itrane_ns4_bolfeb = itrane_ns4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace itrane_ns4_bolfeb = itrane_ns4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace itrane_ns4_bolfeb = itrane_ns4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace itrane_ns4_bolfeb = itrane_ns4	*21.66060704812						if interview_month==2
	
	egen itrane_ns = rowtotal(itrane_ns1_bolfeb itrane_ns2_bolfeb itrane_ns3_bolfeb itrane_ns4_bolfeb)
	
	
***** iV) OTROS INGRESOS NO LABORALES 
gen     inla_otro = .

***** V) INGRESOS NO LABORALES EXTRAORDINARIOS 

foreach j of local monedas {

		gen inla_extraord`j' = .
		
		foreach i of numlist 3 8 {
			replace inla_extraord`j' = s9q29b_`i' 						if inla_extraord`j'==. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
			replace inla_extraord`j' = inla_extraord`j' + s9q29b_`i' 	if inla_extraord`j'!=. & s9q29c_`i'==`j' & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}		
			sum inla_extraord`j'
	}

		gen inla_extraord1_bolfeb = inla_extraord1					 		* 8.72818941228807	if interview_month==11
			replace inla_extraord1_bolfeb = inla_extraord1					* 6.01503214109115	if interview_month==12
			replace inla_extraord1_bolfeb = inla_extraord1					* 3.20509397505709	if interview_month==1
			replace inla_extraord1_bolfeb = inla_extraord1				 						if interview_month==2
		gen inla_extraord2_bolfeb = inla_extraord2			*30097.14836 	* 8.72818941228807	if interview_month==11
			replace inla_extraord2_bolfeb = inla_extraord2	*44482.68537895 * 6.01503214109115	if interview_month==12
			replace inla_extraord2_bolfeb = inla_extraord2	*68780.160295 	* 3.20509397505709	if interview_month==1
			replace inla_extraord2_bolfeb = inla_extraord2	*73460.1238 						if interview_month==2
		gen inla_extraord3_bolfeb  = inla_extraord3			*33227.24238536 * 8.72818941228807	if interview_month==11
			replace inla_extraord3_bolfeb = inla_extraord3	*49431.92724323 * 6.01503214109115	if interview_month==12
			replace inla_extraord3_bolfeb = inla_extraord3	*76259.14734081 * 3.20509397505709 	if interview_month==1
			replace inla_extraord3_bolfeb = inla_extraord3	*80095.41371177						if interview_month==2
		gen inla_extraord4_bolfeb = inla_extraord4			*8.7947132815 	* 8.72818941228807	if interview_month==11
			replace inla_extraord4_bolfeb = inla_extraord4	*13.19404117947 * 6.01503214109115	if interview_month==12
			replace inla_extraord4_bolfeb = inla_extraord4	*20.6963505285 	* 3.20509397505709	if interview_month==1
			replace inla_extraord4_bolfeb = inla_extraord4	*21.66060704812						if interview_month==2
	
	egen inla_extraord = rowtotal(inla_extraord1_bolfeb inla_extraord2_bolfeb inla_extraord3_bolfeb inla_extraord4_bolfeb)
	
/*
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

/* We are missing information to complete this */

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
*gen     ing_pob_mod_lp = ing_pob_mod / lp_moderada


*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- 1.1: PRECIOS  ------------------------------------------------------------------
************************************************************************************************************************************************)*/

/* We are missing information to complete this */

/*
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
*/

/*=================================================================================================================================================
					2: Preparacion de los datos: Variables de segundo orden
=================================================================================================================================================*/
capture label drop relacion
capture label drop hombre
capture label drop nivel
include "$rootpath\data_management\management\2. harmonization\aux_do\cuantiles.do"
*include "$aux_do\do_file_aspire.do" // It was used to create specific things for another World Bank Practice
include "$rootpath\data_management\management\2. harmonization\aux_do\do_file_1_variables.do"

/* TENENCIA_VIVIENDA (s5q7): Para su hogar, la vivienda es?
		1 = Propia pagada		
		2 = Propia pagandose
		3 = Alquilada
		4 = Alquilada parte de la vivienda
		5 = Adjudicada pagándose Gran Misión Vivienda
		6 = Adjudicada Gran Misión Vivienda
		7 = Cedida por razones de trabajo
		8 = Prestada por familiar o amigo
		9 = Tomada
		10 = Otra
		
		*Obs: Before there were options saying "De algun programa de gobierno (con titulo de propiedad)" and "De algun programa de gobierno (sin titulo de propiedad)"
*/

gen aux_propieta_no_paga = 1 if tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==5 | tenencia_vivienda==6
replace aux_propieta_no_paga = 0 if tenencia_vivienda==3 | tenencia_vivienda==4 | (tenencia_vivienda>=7 & tenencia_vivienda<=10) | tenencia_vivienda==.
bysort id: egen propieta_no_paga = max(aux_propieta_no_paga)

gen     renta_imp = .
replace renta_imp = 0.10*itf_sin_ri  if  propieta_no_paga == 1

*replace renta_imp = renta_imp / p_reg
*replace renta_imp = renta_imp / ipc_rel 

include "$rootpath\data_management\management\2. harmonization\aux_do\do_file_2_variables.do"

include "$rootpath\data_management\management\2. harmonization\aux_do\labels.do"
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

