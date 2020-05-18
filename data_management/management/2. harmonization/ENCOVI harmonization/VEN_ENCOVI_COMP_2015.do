/*===========================================================================
Country name:		Venezuela
Year:			2015
Survey:			ENCOVI
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra, Malena Acuña

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************
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
				global rootpath "C:\Users\WB563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global rootpath2 "C:\Users\WB563583\Github\VEN" 
		}
	    if $lauta {
				
		}
		if $trini   {
	
		}
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
                global rootpath2 "C:\Users\WB550905\Github\VEN" 
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global pathout "$rootpath2\data_management\output\cleaned"
*/
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
global id_ENCOVI pais ano encuesta id com pondera strata psu

* Country identifier: country
gen pais = "VEN"

* Year identifier: year
capture drop year
gen ano = 2015

* Survey identifier: survey
gen encuesta = "ENCOVI - 2015"

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
*----------------------------------------	II. Interview Control / Control de la entrevista  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global control_ent entidad 

clonevar entidad=enti

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Demographic variables  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_ENCOVI relacion_en relacion_comp hombre edad estado_civil_en estado_civil hijos_nacidos_vivos hijos_vivos 

*** Relation to the head:	relacion_en
/* RELACION_EN (mhp24): Relación de parentesco con el jefe de hogar en la encuesta
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
rename reltohead relacion_comp

*** Sex 
/* SEXO (mhp26): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
gen sexo = mhp26 if (mhp26!=98 & mhp26!=99)
label define sexo 1 "Male" 2 "Female"
label value sexo sexo
gen hombre = sexo==1 if sexo!=.

*** Age
* EDAD_ENCUESTA (mhp25): Cuantos años cumplidos tiene?
gen     edad = mhp25
notes   edad: range of the variable: 0-93

*** Marital status
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
* Estado civil
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
rename marital_status estado_civil

*** Number of sons/daughters born alive
gen     hijos_nacidos_vivos = .

*** From the total of sons/daughters born alive, how many are currently alive?
gen     hijos_vivos =.

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global dwell_ENCOVI material_piso material_pared_exterior material_techo tipo_vivienda suministro_agua suministro_agua_comp frecuencia_agua ///
electricidad interrumpe_elect tipo_sanitario tipo_sanitario_comp ndormi banio_con_ducha nbanios tenencia_vivienda tenencia_vivienda_comp

*** Type of flooring material
/* MATERIAL_PISO (vp1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
		 5 = Otros		
*/
gen  material_piso = vp1            if (vp1!=98 & vp1!=99)
label def material_piso 1 "Mosaic,granite,vynil, brick.." 2 "Cement" 3 "Tierra" 4 "Boards" 5 "Other"
label value material_piso material_piso

*** Type of exterior wall material			 
/* MATERIAL_PARED_EXTERIOR (vp2)
		1 = Bloque, ladrillo frisado	
		2 = Bloque ladrillo sin frisar  
		3 = Concreto	
		4 = Madera aserrada 
		5 = Bloque de plocloruro de vinilo	
		6 = Adobe, tapia o bahareque frisado
		7 = Adobe, tapia o bahareque sin frisado
		8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  
*/
gen  material_pared_exterior = vp2  if (vp2!=98 & vp2!=99)
label def material_pared_exterior 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete"
label value material_pared_exterior material_pared_exterior

*** Type of roofing material
/* MATERIAL_TECHO (vp3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
*/
gen material_techo = vp3   if (vp3!=98 & vp3!=99)

*** Type of dwelling
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

*** Water supply
/* SUMINISTRO_AGUA (vp7): A esta vivienda el agua llega normalmente por (no se puede identificar si el acceso es dentro del terreno o vivienda)
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
* SUMINISTRO_AGUA_COM
		1 = Acueducto?
		2 = Pila o estanque?
		3 = Camión cisterna?
		4 = Otros medios?
*/	
gen suministro_agua = .
gen     suministro_agua_comp = vp7 if (vp7!=98 & vp7!=99)
label def suministro_agua_comp 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Otros medios"
label value suministro_agua_comp suministro_agua_comp

*** Frequency of water supply
/* FRECUENCIA_AGUA (vp8): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
*/
clonevar frecuencia_agua = vp8 if (vp8!=98 & vp8!=99)	

*** Electricity
/* SERVICIO_ELECTRICO (vp9): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe //falta categoria 5 "No tiene servicio electrico)
			99 = NS/NR					
*/
gen servicio_electrico = vp9 if (vp9!=98 & vp9!=99)
gen     electricidad = (servicio_electrico>=1 & servicio_electrico<=4) if servicio_electrico!=.

*** Electric power interruptions
/* electric_interrup (vp9): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
gen interrumpe_elect = servicio_electrico if (servicio_electrico>=1 & servicio_electrico<=4)
label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
label value interrumpe_elect interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (vp10): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
* TIPO_SANITARIO_COMP
		1 = Poceta a cloaca/pozo séptico?
		2 = Poceta sin conexión (tubo)?
		3 = Excusado de hoyo o letrina?
		4 = No tiene poceta o excusado?.
*/
gen tipo_sanitario = .
gen tipo_sanitario_comp = vp10 if (vp10!=98 & vp10!=99)
label def tipo_sanitario 1 "Poceta a cloaca/Pozo septico" 2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" 4 "No tiene poseta o excusado"
label value tipo_sanitario_comp tipo_sanitario_comp

*** Number of rooms used exclusively to sleep
* NDORMITORIOS (hp19): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormi = hp19 if (hp19!=98 & hp19!=99)

*** Bath with shower 
* BANIO : Su hogar tiene uso exclusivo de bano con ducha o regadera?
gen     banio_con_ducha = .

*** Number of bathrooms with shower
* NBANIOS : cuantos banos con ducha o regadera?
gen nbanios = .

*** Housing tenure
/* TENENCIA_VIVIENDA (hp13): régimen de  de la vivienda  
		1 = Propia pagada		
		2 = Propia pagandose
		3 = Alquilada
		4 = Prestada	
		5 = Invadida
		6 = De algun programa de gobierno 
		7 = Otra
		99 = NS/NR								
*/
destring (codhp22o), replace
clonevar tenencia_vivienda = hp22 if (hp22!=98 & hp22!=99)
gen tenencia_vivienda_comp=1 if tenencia_vivienda==1
replace tenencia_vivienda_comp=2 if tenencia_vivienda==2
replace tenencia_vivienda_comp=3 if tenencia_vivienda==3 
replace tenencia_vivienda_comp=4 if tenencia_vivienda==4
replace tenencia_vivienda_comp=5 if tenencia_vivienda==5
replace tenencia_vivienda_comp=6 if tenencia_vivienda==6 | tenencia_vivienda==7
replace tenencia_vivienda_comp=7 if tenencia_vivienda==8
label define tenencia_vivienda_comp 1 "Propia pagada" 2 "Propia pagandose" 3 "Alquilada" 4 "Prestada" 5 "Invadida" 6 "De algun programa de gobierno" 7 "Otra"
label value tenencia_vivienda_comp tenencia_vivienda_comp

foreach x in $dwell_ENCOVI {
replace `x'=. if relacion_en!=1
}

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods --------------------------------------------------------
*************************************************************************************************************************************************)*/
global dur_ENCOVI auto ncarros heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas telefono_fijo

*** Dummy household owns cars
*  AUTO (hp21): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
gen     auto = hp21>0 if (hp21!=98 & hp21!=99)
replace auto = .		if  relacion_en!=1 

*** Number of functioning cars in the household
* NCARROS (hp21) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
gen     ncarros = hp21 if (hp21!=98 & hp21!=99)
replace ncarros = .		if  relacion_en!=1 

*** Does the household have fridge?
* Heladera (hp20n): ¿Posee este hogar nevera?
gen     heladera = hp20n==1 if (hp20n!=98 & hp20n!=99)
replace heladera = .		if  relacion_en!=1 

*** Does the household have washing machine?
* Lavarropas (hp20l): ¿Posee este hogar lavadora?
gen     lavarropas = hp20l==1 if (hp20l!=98 & hp20l!=99)
replace lavarropas = .		if  relacion_en!=1 

*** Does the household have dryer
* Secadora (hp20s): ¿Posee este hogar secadora? 
gen     secadora = hp20s==1 if (hp20s!=98 & hp20s!=99)
replace secadora = .		if  relacion_en!=1 

*** Does the household have computer?
* Computadora (hp20c): ¿Posee este hogar computadora?
gen computadora = hp20c==1 if (hp20c!=98 & hp20c!=99)
replace computadora = .		if  relacion_en!=1 

*** Does the household have internet?
* Internet (hp20i): ¿Posee este hogar internet?
gen     internet = hp20i==1 if (hp20i!=98 & hp20i!=99)
replace internet = .	if  relacion_en!=1 

*** Does the household have tv?
* Televisor (hp20t): ¿Posee este hogar televisor?
gen     televisor = hp20t==1 if (hp20t!=98 & hp20t!=99)
replace televisor = .	if  relacion_en!=1 

*** Does the household have radio?
* Radio (hp20r): ¿Posee este hogar radio? 
gen     radio = hp20r==1 if (hp20r!=98 & hp20r!=99)
replace radio = .		if  relacion_en!=1 

*** Does the household have heater?
* Calentador (hp20o): ¿Posee este hogar calentador? 
gen     calentador = hp20o==1 if (hp20o!=98 & hp20o!=99)
replace calentador = .		if  relacion_en!=1 

*** Does the household have air conditioner?
* Aire acondicionado (hp20a): ¿Posee este hogar aire acondicionado?
gen     aire = hp20a==1 if (hp20a!=98 & hp20a!=99)
replace aire = .		    if  relacion_en!=1 

*** Does the household have cable tv?
* TV por cable o satelital (hp20v): ¿Posee este hogar TV por cable?
gen     tv_cable = hp20v==1 if (hp20v!=98 & hp20v!=99)
replace tv_cable = .		if  relacion_en!=1

*** Does the household have microwave oven?
* Horno microonada (hp20h): ¿Posee este hogar horno microonda?
gen     microondas = hp20h==1 if (hp20h!=98 & hp20h!=99)
replace microondas = .		if  relacion_en!=1

*** Does the household have landline telephone?
* Teléfono fijo (): telefono_fijo
gen     telefono_fijo =.
replace telefono_fijo = .	 if  relacion_en!=1 

* Teléfono movil (individual): celular_ind (mhp28)
gen     celular_ind = 1 if (mhp28==1)
replace celular_ind = 0 if (mhp28==2)

* Telefono celular: celular
tempvar allmiss
egen celular = max(celular_ind==1), by (id)
egen `allmiss' = min(celular_ind == .), by(id)
replace celular =. if `allmiss' == 1
replace celular =. if relacion_en!=1

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.6: Education --------------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI asiste alfabeto edu_pub ///
nivel_educ g_educ s_educ razon_dejo_est_comp

*** Do you attend any educational center? //for age +3
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

*** Educational attainment
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
* G_EDUC (ep36a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Preescolar, Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* A_EDUC (ep36s): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
*/
clonevar nivel_educ = ep36n if (ep36n!=98 & ep36n!=99)
gen g_educ = ep36a     if (ep36a!=98 & ep36a!=99)
gen s_educ = ep36s     if (ep36s!=98 & ep36s!=99)

*** Literacy
* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (g_educ>=2 & g_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

*** Establecimiento educativo público: edu_pub
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

*** Cual fue la principal razon por la que dejo los estudios?
/* RAZONES_ABAN_EST_COMP
		1.Terminó los estudios
		2.Escuela distante
		3.Escuela cerrada
		4.Muchos paros/inasistencia de maestros
		5.Costo de los útiles
		6.Costo de los uniformes
		7.Enfermedad/discapacidad
		8.Debía trabajar
		9.No quiso seguir estudiando
		10.Inseguridad al asistir al centro educativo
		11.Discriminación
		12.Violencia
		13.Por embarazo/cuidar a los hijos
		14.Obligaciones en el hogar
		15.No lo considera importante
		16.Otra (Especifique)
*/
gen razon_dejo_est_comp= ep40 if (ep40!=98 & ep40!=99)
label def razon_dejo_est_comp 1 "Terminó los estudios" 2 "Escuela distante" 3 "Escuela cerrada" 4 "Muchos paros/inasistencia de maestros" 5 "Costo de los útiles" 6 "Costo de los uniformes" ///
7 "Enfermedad/discapacidad" 8 "Tiene que trabajar" 9 "No quiso seguir estudiando" 10 "Inseguridad al asistir al centro educativo" 11 "Discriminación o violencia" ///
12 "Por embarazo/cuidar a los hijos" 13 "Tiene que ayudar en tareas del hogar" 14 "No lo considera importante" 15 "Otra"
label value razon_dejo_est_comp razon_dejo_est_comp


*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- : Social Programs ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global socialprog_ENCOVI beneficiario mision_1 mision_2 mision_3 carnet_patria clap



*--------- Receive 'Mision' or social program
 /* (psp68):62. EN EL PRESENTE (2018),
 ¿… RECIBE O ES BENEFICIARIO DE ALGUNA MISIÓN O PROGRAMA SOCIAL?
 */
	*-- Check values
	tab psp68, mi
	*-- Standarization of missing values
	replace psp68=. if psp68==99
	*-- Label values
	label def psp68  1 "Si" 2 "No" 						  	
	label value psp68 psp68
	*-- Generate variable
	clonevar beneficiario= psp68
	replace beneficiario=0 if psp68==2
	*-- Label variable
	label var beneficiario "In 2015: do you receive a 'Mision' or social program"
	*-- Label values	
	label def beneficiario  1 "Yes" 0 "No" 						  	
	label value beneficiario beneficiario


*--------- Which type of 'Mision'
 /* 63. ¿PUEDE IDENTIFICAR CUÁL MISIÓN O PROGRAMA SOCIAL RECIBE ACTUALMENTE? 
 (selecciones hasta tres)
 
 Each person can chose three programs:
	 Variable 1: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 1
	(psp69m1)
	 Variable 2: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 2
	(psp69m2) 
	 Variable 3: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 3
	(psp69m3)
	 
	 Categories:
				1. Alimentación/Mercal
				2. Barrio Adentro
				3. Milagro
				4. Sonrisa
				5. Robinson
				6. Ribas
				7. Sucre
				8. Saber y Trabajo, Vuelvan Caras y/o Ché Guevara
				9. G. M. Vivienda y/o Barrio Tricolor
				10. Casa Bien Equipada
				11. Madres del Barrio
				12. Hijos de Venezuela
				13. Negra Hipólita
				14. Amor Mayor
				15. Identidad
				16. Otra
				98. NA
				99. NS/NR
 */

	forval i = 1/3{
	*-- Standarization of missing values
	replace psp69m`i'=. if psp69m`i'==99
	*-- Generate variable
	clonevar mision_`i' = psp69m`i' 
	*-- Label variable
	label var mision_`i' "Name of the social program: Mision `i'"
	*-- Label values 
	label def mision_`i' 1 "Alimentación/Mercal" 2 "Barrio Adentro" 3 "Milagro" ///
					     4 "Sonrisa" 5 "Robinson" 6 "Ribas" 7 "Sucre" ///
						 8 "Saber y Trabajo, Vuelvan Caras y/o Ché Guevara" ///
						 9 "G. M. Vivienda y/o Barrio Tricolor" 10 "Casa Bien Equipada" ///
						11 "Madres del Barrio" 12 "Hijos de Venezuela" 13 "Negra Hipólita" ///
						14 "Amor Mayor"	15 "Identidad" 16 "Otra" 98 "NA"
	label value mision_`i' mision_`i'
	*-- Check values
	tab mision_`i' beneficiario, mi 
	}


	
 *--------- 'Carnet patria' 
 /* 64. ¿SE HA SACADO USTED EL CARNET DE LA PATRIA?
				1. Sí
				2. No. Indique por qué no:  */

	*-- Check values
	gen carnet_patria=.
	*-- Label variable
	label var carnet_patria "Has at least one member of the houselhold obtained the 'Carnet Patria'"

	
 *--------- 'Caja CLAP' (In kind-transfer)
 /* 65. ¿EN ESTE HOGAR HAN ADQUIRIDO LA BOLSA/CAJA DEL CLAP?*/
*-- Check values
	gen clap = .
	*-- Label variable
	label var clap "Has the houselhold received the 'CLAP'"

		


/*
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


/*=================================================================================================================================================
					2: Preparacion de los datos: Variables de segundo orden
=================================================================================================================================================*/

capture label drop relacion
capture label drop hombre
capture label drop nivel
include "$aux_do\cuantiles.do"
*include "$aux_do\do_file_aspire.do"
*include "$aux_do\do_file_1_variables.do" // Generated in the whole SEDLAC harmonization and then merged here by main.do
*include "$aux_do\do_file_2_variables.do" // Generated in the whole SEDLAC harmonization and then merged here by main.do
include "$aux_do\labels.do"
compress

*/
/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables --------------
*************************************************************************************************************************************************)*/
sort id com
order $id_ENCOVI $control_ent $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $foodcons_ENCOVI $socialprog_ENCOVI
keep  $id_ENCOVI $control_ent $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $foodcons_ENCOVI $socialprog_ENCOVI

save "$pathout\ENCOVI_2015_COMP.dta", replace

