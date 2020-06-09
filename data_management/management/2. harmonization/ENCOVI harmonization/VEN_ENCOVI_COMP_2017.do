/*===========================================================================
Country name:	Venezuela
Year:			2017
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
		global juli   1
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   0
		
			
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
                global rootpath2 "C:\Users\wb550905\Github\VEN" 
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
rename _all, lower

*-----Incluyo las regiones de archivos 2017
*******************************************
	preserve
	use "$data2017\region_merge.dta", clear
	rename _all, lower
	tempfile region
	save `region'
	restore
	merge m:1 ennumc lin using `region'
	drop _merge  
	*----- Save as temporary file
	tempfile house
	save `house' 

*----- Emigration
*******************************************
	tempfile emigracion
	use "$data2017\EMIGRACIÓN2017.dta", clear
	// Rename
	rename _all, lower
	// Identify duplicates
	duplicates report ennumc linemig
	// Rename 
	rename linemig lin
	// Reshape
	reshape wide emp*, i(ennumc) j(lin)
	save `emigracion'
	use `house', clear
	merge m:1 ennumc using `emigracion' 
	drop _merge
/*(************************************************************************************************************************************************* 
*----------------------------------------	II. Interview Control / Control de la entrevista  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global control_ent entidad 


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables  --------------------------------------------------
*************************************************************************************************************************************************)*/
global id_ENCOVI pais ano encuesta id com pondera strata psu

* Country identifier: country
gen pais = "VEN"

* Year identifier: year
capture drop year
gen ano = 2017

* Survey identifier: survey
gen encuesta = "ENCOVI - 2017"

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
global demo_ENCOVI relacion_en relacion_comp hombre edad estado_civil_en estado_civil hijos_nacidos_vivos hijos_vivos 

*** Relation to the head:	relacion_en
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
rename reltohead relacion_comp

*** Sex
/* SEXO (cmhp19): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
gen sexo = cmhp19 if (cmhp19!=98 & cmhp19!=99)
label define sexo 1 "Male" 2 "Female"
label value sexo sexo
gen hombre = sexo==1 if sexo!=.

*** Age
* EDAD_ENCUESTA (cmhp18): Cuantos años cumplidos tiene?
gen     edad = cmhp18
notes   edad: range of the variable: 0-100

*** Marital status
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
rename marital_status estado_civil

*** Number of sons/daughters born alive
gen     hijos_nacidos_vivos = cmhp26 if (cmhp26!=98 & cmhp26!=99)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     hijos_vivos = cmhp27 if cmhp26!=0 & cmhp27<=cmhp26 & (cmhp27!=98 & cmhp27!=99)

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global dwell_ENCOVI material_piso material_pared_exterior material_techo tipo_vivienda suministro_agua suministro_agua_comp frecuencia_agua ///
electricidad interrumpe_elect tipo_sanitario tipo_sanitario_comp ndormi banio_con_ducha nbanios tenencia_vivienda tenencia_vivienda_comp

*** Type of flooring material
/* MATERIAL_PISO (vsp1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
		 5 = Otros		
*/
gen  material_piso = vsp1            if (vsp1!=98 & vsp1!=99)
label def material_piso 1 "Mosaic,granite,vynil, brick.." 2 "Cement" 3 "Tierra" 4 "Boards" 5 "Other"
label value material_piso material_piso

*** Type of exterior wall material			 
/* MATERIAL_PARED_EXTERIOR (vsp2)
		1 = Bloque, ladrillo frisado	
		2 = Bloque ladrillo sin frisar  
		3 = Concreto	
		4 = Madera aserrada 
		5 = Bloque de plocloruro de vinilo	
		6 = Adobe, tapia o bahareque frisado
		7 = Adobe, tapia o bahareque sin frisado
		8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  
*/
gen  material_pared_exterior = vsp2  if (vsp2!=98 & vsp2!=99)
label def material_pared_exterior 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete"
label value material_pared_exterior material_pared_exterior

*** Type of roofing material
/* MATERIAL_TECHO (vsp3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
*/
gen  material_techo = vsp3           if (vsp3!=98 & vsp3!=99)

*** Type of dwelling
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

*** Water supply
/* SUMINISTRO_AGUA (vsp5): A esta vivienda el agua llega normalmente por (no se puede identificar si el acceso es dentro del terreno o vivienda)
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
*/	
gen     suministro_agua = vsp5 if (vsp5!=98 & vsp5!=99)
label def suministro_agua 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Pozo con bomba" 5 "Pozo protegido" 6 "Otros medios"
label value suministro_agua suministro_agua
* Comparable across all years
recode suministro_agua (5 6=4), g(suministro_agua_comp)
label def suministro_agua_comp 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Otros medios"
label value suministro_agua_comp suministro_agua_comp

*** Frequency of water supply
/* FRECUENCIA_AGUA (vsp6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
*/
clonevar frecuencia_agua = vsp6 if (vsp6!=98 & vsp6!=99)	

*** Electricity
/* SERVICIO_ELECTRICO (vsp7): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe
			5 = No tiene servicio electrico
			99 = NS/NR					
*/
gen servicio_electrico = vsp7 if (vsp7!=98 & vsp7!=99)
gen     electricidad = (servicio_electrico>=1 & servicio_electrico<=4) if servicio_electrico!=.

*** Electric power interruptions
/* interrumpe_elect (vsp7): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
gen interrumpe_elect = servicio_electrico if (servicio_electrico>=1 & servicio_electrico<=4)
label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
label value interrumpe_elect interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (vsp8): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
gen tipo_sanitario = vsp8 if (vsp8!=98 & vsp8!=99)
* comparable across all years
recode tipo_sanitario (2=1) (3=2)(4=3) (5=4), g(tipo_sanitario_comp)
label def tipo_sanitario 1 "Poceta a cloaca/Pozo septico" 2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" 4 "No tiene poseta o excusado"
label value tipo_sanitario_comp tipo_sanitario_comp

*** Number of rooms used exclusively to sleep
* NDORMITORIOS (dhp10): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormi = dhp10 if (dhp10!=98 & dhp10!=99)

*** Bath with shower 
* BANIO (dhp11): Su hogar tiene uso exclusivo de bano con ducha o regadera?
gen     banio_con_ducha = dhp11==1 if (dhp11!=98 & dhp11!=99)

*** Number of bathrooms with shower
* NBANIOS (dhp12): cuantos banos con ducha o regadera?
clonevar nbanios = dhp12 if banio_con_ducha==1 

*** Housing tenure
/* TENENCIA_VIVIENDA (hp15): régimen de  de la vivienda  
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
*  AUTO (dhp13): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
gen     auto = dhp13>0 if (dhp13!=98 & dhp13!=99)
replace auto = .		if  relacion_en!=1 

*** Number of functioning cars in the household
* NCARROS (dhp13) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
gen     ncarros = dhp13 if (dhp13!=98 & dhp13!=99)
replace ncarros = .		if  relacion_en!=1 

*** Does the household have fridge?
* Heladera (hp14n): ¿Posee este hogar nevera?
gen     heladera = hp14n==1 if (hp14n!=98 & hp14n!=99)
replace heladera = .		if  relacion_en!=1 

*** Does the household have washing machine?
* Lavarropas (hp14l): ¿Posee este hogar lavadora?
gen     lavarropas = hp14l==1 if (hp14l!=98 & hp14l!=99)
replace lavarropas = .		if  relacion_en!=1 

*** Does the household have dryer
* Secadora (hp14s): ¿Posee este hogar secadora? 
gen     secadora = hp14s==1 if (hp14s!=98 & hp14s!=99)
replace secadora = .		if  relacion_en!=1 

*** Does the household have computer?
* Computadora (hp14c): ¿Posee este hogar computadora?
gen computadora = hp14c==1 if (hp14c!=98 & hp14c!=99)
replace computadora = .		if  relacion_en!=1 

*** Does the household have internet?
* Internet (hp14i): ¿Posee este hogar internet?
gen     internet = hp14i==1 if (hp14i!=98 & hp14i!=99)
replace internet = .	if  relacion_en!=1 

*** Does the household have tv?
* Televisor (hp14t): ¿Posee este hogar televisor?
gen     televisor = hp14t==1 if (hp14t!=98 & hp14t!=99)
replace televisor = .	if  relacion_en!=1 

*** Does the household have radio?
* Radio (hp14r): ¿Posee este hogar radio? 
gen     radio = hp14r==1 if (hp14r!=98 & hp14r!=99)
replace radio = .		if  relacion_en!=1 

*** Does the household have heater?
* Calentador (hp14o): ¿Posee este hogar calentador? 
gen     calentador = hp14o==1 if (hp14o!=98 & hp14o!=99)
replace calentador = .		if  relacion_en!=1 

*** Does the household have air conditioner?
* Aire acondicionado (hp14a): ¿Posee este hogar aire acondicionado?
gen     aire = hp14a==1 if (hp14a!=98 & hp14a!=99)
replace aire = .		    if  relacion_en!=1 

*** Does the household have cable tv?
* TV por cable o satelital (dhp14v): ¿Posee este hogar TV por cable?
gen     tv_cable = hp14v==1 if (hp14v!=98 & hp14v!=99)
replace tv_cable = .		if  relacion_en!=1

*** Does the household have microwave oven?
* Horno microonada (hp14h): ¿Posee este hogar horno microonda?
gen     microondas = hp14h==1 if (hp14h!=98 & hp14h!=99)
replace microondas = .		if  relacion_en!=1

*** Does the household have landline telephone?
* Teléfono fijo (): telefono_fijo
gen     telefono_fijo =.
replace telefono_fijo = .   if  relacion_en!=1 

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.6: Education --------------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI asiste alfabeto edu_pub ///
fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
nivel_educ g_educ s_educ razon_dejo_est_comp

*** Do you attend any educational center? //for age +3
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

*** Educational attainment
/* NIVEL_EDUC (emhp28n): ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
		99 = NS/NR
* G_EDUC (emhp28a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Preescolar, Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* S_EDUC (emhp28a): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
*/
clonevar nivel_educ = emhp28n if (emhp28n!=98 & emhp28n!=99)
gen g_educ = emhp28a     if (emhp28a!=98 & emhp28a!=99)
gen s_educ = emhp28s     if (emhp28s!=98 & emhp28s!=99)

*** Literacy
* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (g_educ>=2 & g_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

*** Establecimiento educativo público: edu_pub
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

*** During this school period, did you stop attending the educational center where you regularly study due to:
/*
1. Fallas del servicio de agua?
2. Fallas del servicio eléctrico?
3. Huelga (protestas) del personal docente?
4. Falta de transporte?
5. Falta de comida en el hogar?
6. Falta de comida en el centro educativo?
7. Inasistencia del personal docente?
8. Manifestaciones, movilizaciones o protestas?
9. Nunca deja de asistir
99. NS/NR
*/
* Water failiures
gen fallas_agua = emhp33a==1  if asiste==1 & (emhp33a!=98 & emhp33a!=99)
* Electricity failures
gen fallas_elect = emhp33b==2  if asiste==1 & (emhp33b!=98 & emhp33b!=99)
* Huelga de personal docente
gen huelga_docente = emhp33c==3  if asiste==1 & (emhp33c!=98 & emhp33c!=99)
* Falta transporte
gen falta_transporte = emhp33d==4  if asiste==1 & (emhp33d!=98 & emhp33d!=99)
* Falta de comida en el hogar
gen falta_comida_hogar = emhp33e==5  if asiste==1 & (emhp33e!=98 & emhp33e!=99)
* Falta de comida en el centro educativo
gen falta_comida_centro = emhp33f==6  if asiste==1 & (emhp33f!=98 & emhp33f!=99)
* Inasistencia del personal docente
gen inasis_docente = emhp33g==7  if asiste==1 & (emhp33g!=98 & emhp33g!=99)
* Manifestaciones, movilizaciones o protestas
gen protestas = emhp33h==8  if asiste==1 & (emhp33h!=98 & emhp33h!=99)
* Nunca deje de asistir
gen nunca_deja_asistir = emhp33a==9  if asiste==1 & (emhp33a!=98 & emhp33a!=99)

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
gen razon_dejo_est_comp= emhp31 if (emhp31!=98 & emhp31!=99)
label def razon_dejo_est_comp 1 "Terminó los estudios" 2 "Escuela distante" 3 "Escuela cerrada" 4 "Muchos paros/inasistencia de maestros" 5 "Costo de los útiles" 6 "Costo de los uniformes" ///
7 "Enfermedad/discapacidad" 8 "Tiene que trabajar" 9 "No quiso seguir estudiando" 10 "Inseguridad al asistir al centro educativo" 11 "Discriminación o violencia" ///
12 "Por embarazo/cuidar a los hijos" 13 "Tiene que ayudar en tareas del hogar" 14 "No lo considera importante" 15 "Otra"
label value razon_dejo_est_comp razon_dejo_est_comp


/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global emigra_ENCOVI hogar_emig numero_emig ///
edad_emig_* sexo_emig_* anoemig_* mesemig_* ///
leveledu_emig_* anoedu_emig_* semedu_emig_* paisemig_* ///
opaisemig_* razonemig_*  razonemigot_* ///


*--------- Emigrant from the household
 /* 2019-Emigrant(): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 2018-Emigrant(emp70)¿Durante los últimos 5 años, desde junio de 2013,
 ¿Alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
		 1 = Si
         2 = No
		99 = NS/NR
 */
	*-- Check values
	tab emp70, mi
	*-- Standarization of missing values
	replace emp70=. if emp70==98
	replace emp70=. if emp70==99
	*-- Generate variable
	clonevar hogar_emig = emp70
	replace hogar_emig = 0 if emp70==2 
	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 0 "No"
	label value hogar_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(emp71): 2. Cuántas personas?
 
 */
	*-- Check values
	tab emp71, mi
	*-- Standarization of missing values
	replace emp71=. if emp71==98 //NA
	replace emp71=. if emp71==99
	*-- Generate variable
	clonevar numero_emig = emp71
	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	*-- Cross check
	tab numero_emig hogar_emig, mi
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household: NA in our database but it was asked
        
 */	

	
 *--------- Age of the emigrant
 /* Age of the emigrant(emp72): 3. Cuántos años cumplidos tiene X?
        
 */
 	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename main variable 
	rename emp72`i' emp72_`i'
	*-- Label original variable
	label var emp72_`i' "3.Cuántos años cumplidos tiene X?"
	*-- Standarization of missing values
	replace emp72_`i'=. if emp72_`i'==.a
	replace emp72_`i'=. if emp72_`i'==99
		*-- Generate variable
		clonevar edad_emig_`i' = emp72_`i'
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		*-- Cross check
		tab edad_emig_`i' hogar_emig
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (emp73): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename main variable 
	rename emp73`i' emp73_`i'
	*-- Label original variable
	label var emp73_`i' "4. El sexo de X es?"
	*-- Standarization of missing values
	replace emp73_`i'=. if emp73_`i'==98
	replace emp73_`i'=. if emp73_`i'==99
		*-- Generate variable
		clonevar sexo_emig_`i' = emp73_`i'
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i' 1 "Male" 2 "Female"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		

	
 *--------- Year in which the emigrant left the household
 /* Year (emp74a): 6a. En qué año se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename original variable 
	rename emp74a`i' emp74a_`i'
	*-- Label original variable
	label var emp74a_`i' "6a. En qué año se fue X ?"
	*-- Standarization of missing values
	replace emp74a_`i'=. if emp74a_`i'==.a
	replace emp74a_`i'=. if emp74a_`i'==98
	replace emp74a_`i'=. if emp74a_`i'==99
	*-- Generate variable
	clonevar anoemig_`i' = emp74a_`i'
	*-- Label variable
	label var anoemig_`i' "Year of emigration"
	*-- Cross check
	tab anoemig_`i' hogar_emig
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (emp74m): 6a. En qué mes se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename original variable 
	rename emp74m`i' emp74m_`i'
	*-- Label original variable
	label var emp74m_`i' "6b. En qué mes se fue X ?"
	*-- Standarization of missing values
	replace emp74m_`i'=. if emp74m_`i'==.a
	replace emp74m_`i'=. if emp74m_`i'==98
	replace emp74m_`i'=. if emp74m_`i'==99
	*-- Generate variable
	clonevar mesemig_`i' = emp74m_`i'
	*-- Label variable
	label var mesemig_`i' "Month of emigration"
	*-- Cross check
	tab mesemig_`i' hogar_emig
	}


  *--------- Latest education level atained by the emigrant 
 /* Education level (emp70n): 7. Cuál fue el último nivel educativo en el que
							 X aprobó un grado, año, semestre o trimestre?  
		2019:
			01 Ninguno
			02 Preescolar
			03 Régimen anterior: Básica (1-9)
			04 Régimen anterior: Media Diversificado y Profesional (1-3)
			05 Régimen actual: Primaria (1-6)
			06 Régimen actual: Media (1-6)
			07 Técnico (TSU)
			08 Universitario
			09 Postgrado
			
		2017:	
			1. Ninguno
			2. Preescolar
			3. Primaria
			4. Media
			5. Técnico (TSU)
			6. Universitario
			7. Postgrado
			99. NS/NR

 */
 	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename main variable 
	rename emp75n`i' emp75n_`i'
	*-- Label original variable
	label var emp75n_`i' "7. Cuál fue el último nivel educativo en el que X aprobó un grado, año, semestre o trimestre?"
	*-- Standarization of missing values
	replace emp75n_`i'=. if emp75n_`i'==.a
	replace emp75n_`i'=. if emp75n_`i'==98
	replace emp75n_`i'=. if emp75n_`i'==99
	*-- Generate variable
	gen leveledu_emig_`i' = .
	replace leveledu_emig_`i' = 1 	if emp75n_`i'==1 // Ninguno
	replace leveledu_emig_`i' = 2 	if emp75n_`i'==2 // Preescolar
	//replace leveledu_emig_`i' = 3 	if emp75n_`i'==.
	//replace leveledu_emig_`i' = 4 	if emp75n_`i'==.
	replace leveledu_emig_`i' = 5 	if emp75n_`i'==3 // Primaria (1-6)
	replace leveledu_emig_`i' = 6 	if emp75n_`i'==4 // Media (1-6)
	replace leveledu_emig_`i' = 7 	if emp75n_`i'==5 // Tecnico
	replace leveledu_emig_`i' = 8 	if emp75n_`i'==6 // Universitario
	replace leveledu_emig_`i' = 9 	if emp75n_`i'==7 // Posgrado
	*-- Label variable
	label var leveledu_emig_`i' "Education level emigrant"
	*-- Label values
	label def leveledu_emig_`i' 1 "Ninguno" 2 "Preescolar" 3 "Régimen anterior: Básica (1-9)" ///
			6 "Régimen actual: Media (1-6)" ///
			7 "Técnico (TSU)" 8 "Universitario" 9 "Postgrado"
	label value	leveledu_emig_`i' leveledu_emig_`i'	
	}
	

 *--------- Latest year 
 /* Education regime (emp75a): 7b. Cuál fue el último AÑO aprobado por X?    
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp75a`i' emp75a_`i'
	*-- Label original variable
	label var emp75a_`i' "7b. Cuál fue el último AÑO aprobado por X?   "
	*-- Standarization of missing values
	replace emp75a_`i'=. if emp75a_`i'==.a
	replace emp75a_`i'=. if emp75a_`i'==98
	replace emp75a_`i'=. if emp75a_`i'==99
	*-- Generate variable
	clonevar anoedu_emig_`i' = emp75a_`i'
	*-- Label variable
	label var anoedu_emig_`i' "Last year of education attained"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (amp70s): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp75s`i' emp75s_`i'
	*-- Label original variable
	label var emp75s_`i' "7c. Cuál fue el último SEMESTRE aprobado por X?"
	*-- Standarization of missing values
	replace emp75s_`i'=. if emp75s_`i'==.a
	replace emp75s_`i'=. if emp75s_`i'==98
	replace emp75s_`i'=. if emp75s_`i'==99
	*-- Generate variable
	clonevar semedu_emig_`i' = emp75s_`i'
	*-- Label variable
	label var semedu_emig_`i' "Last semester of education attained"
	*-- Cross check
	tab semedu_emig_`i' hogar_emig
	}

  *--------- Country of residence of the emigrant
 /* Country () 2019: 8. En cuál país vive actualmente X? 
    Country (emp71) 2018: 71. ¿A que pais se fue…?
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp76`i' emp76_`i'
	*-- Label original variable
	label var emp76_`i' "8. En cuál país vive actualmente X?"
	*-- Standarization of missing values
	replace emp76_`i'=. if emp76_`i'==.a
	replace emp76_`i'=. if emp76_`i'==98
	replace emp76_`i'=. if emp76_`i'==99
	*-- Generate variable
	clonevar paisemig_`i' = emp76_`i'
	*-- Label variable
	label var paisemig_`i' "Country in which X lives"
	*-- Cross check
	tab paisemig_`i' hogar_emig
	}

  *--------- Other country of residence 
 /* Other Country (emp71_ot): 8a. Otro país, especifique
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp76ot`i' emp76_ot_`i'
	*-- Label original variable
	label var emp76_ot_`i' "8a. Otro país, especifique"
	*-- Standarization of missing values
	replace emp76_ot_`i'="." if emp76_ot_`i'=="98"
	replace emp76_ot_`i'="." if emp76_ot_`i'=="99"
	*-- Generate variable
	gen opaisemig_`i' = emp76_ot_`i'
	*-- Label variable
	label var opaisemig_`i' "Country in which X lives (Other)"
	*-- Cross check
	tab opaisemig_`i' hogar_emig
	}

  *--------- Reason for leaving the country
 /*  Reason (emp77):9. Cuál fue el motivo por el cual X se fue				
						01 Fue a buscar/consiguió trabajo
						02 Cambió su lugar de trabajo
						03 Por razones de estudio
						04 Reagrupación familiar
						05 Se casó o unió
						06 Por motivos de salud
						07 Por violencia e inseguridad
						08 Por razones políticas
						09 Otro			
 */
  	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp77`i' emp77_`i'
	*-- Label original variable
	label var emp77_`i' "9. Cuál fue el motivo por el cual X se fue"
	*-- Standarization of missing values
	replace emp77_`i'=. if emp77_`i'==98
	replace emp77_`i'=. if emp77_`i'==99
	*-- Generate variable
	clonevar razonemig_`i' = emp77_`i'
	*-- Label variable
	label var razonemig_`i' "Why X emigrated"
	*-- Cross check
	tab razonemig_`i' hogar_emig
	} 

 
   *--------- Other Reasons for leaving the country
 /*  Reason (emp77ot):9a. Cuál fue el motivo por el cual X se fue (Otros)*/
  	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variaot_`i'=="98"
	forval i=1/5 {
	replace emp77ot_cod`i'=. if emp77ot_cod`i'==99
	replace emp77ot_cod`i'=. if emp77ot_cod`i'==98
	*-- Generate variable
	clonevar razonemigot_`i' = emp77ot_cod`i'
	*-- Label variable
	label var razonemigot_`i' "Why X emigrated (Other reasons)"
	*-- Cross check
	tab razonemigot_`i' hogar_emig
	*label def 1 "" 2 "" 3 
	} 

/*(*****************bles with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp77ot`i' emp77ot_`i'
	*-- Label original variable
	label var emp77ot_`i' "9a. Cuál fue el motivo por el cual X se fue (Otros)"
	*-- Standarization of missing values
	replace emp77ot_`i'="." if emp77
******************************************************************************************************************************** 
*----------------------------------- XII: FOOD CONSUMPTION / CONSUMO DE ALIMENTO --------------------------------------------------------
*************************************************************************************************************************************************)*/

global foodcons_ENCOVI  
	
 
/*
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
*/

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.8: Variables laborales ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

global labor_ENCOVI categ_ocu relab sector_encuesta aporta_pension ocupado desocupa inactivo pea empresa_enc contrato actividades razon_no_busca

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
gen actividades = labor_status

gen categ_ocu = tmhp43    if (tmhp43!=98 & tmhp43!=99)
replace categ_ocu = 1 if categ_ocu==2
replace categ_ocu = 3 if categ_ocu==4

gen     relab = .
replace relab = 1 if (labor_status==1 | labor_status==2) & categ_ocu== 5  //employer 
replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee - Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6)  // Self-employed
replace relab = 4 if (labor_status==1 | labor_status==2) & categ_ocu== 8 //unpaid family worker (but includes paid too)
replace relab = 2 if (labor_status==1 | labor_status==2) & categ_ocu== 8 & (tmhp44bs>=1 & tmhp44bs!=98 & tmhp44bs!=99) //move paid family worker to employee
replace relab = 5 if (labor_status==3 | labor_status==4)

gen     relab_s =.
gen     relab_o =.

/*
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
*/
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
gen empresa_enc = tmhp42 if (tmhp42!=98 & tmhp42!=99)
label define empresa_enc 1 "1 persona" 2 "2 a 4 personas" 3 "5 personas" 4 "6 a 10 personas" 5 "11 a 20 personas" 6 "21 a 100 personas" 7 "100+ personas"
label value empresa_enc empresa_enc

/*
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
*/

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

/*
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
*/
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
clonevar contrato_encuesta = tmhp46 if (tmhp46!=98 & tmhp46!=99 & tmhp46!=.a)
gen     contrato = (contrato_encuesta== 1 | contrato_encuesta==2) if relab==2 & contrato_encuesta!=.

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
gen     aporta_pension = (aporte_pension>=1 & aporte_pension<=4) if (relab>=1 & relab<=4) & aporte_pension!=.

/*
* Seguro de salud ligado al empleo: dsegsale
gen     dsegsale = (afiliado_seguro_salud==3 | afiliado_seguro_salud==4) if relab==2 

* Derecho a aguinaldo: aguinaldo
gen     aguinaldo = tmhp47ut==1 if ((tmhp47ut!=98 & tmhp47ut!=99) & relab==2) 

* Derecho a vacaciones pagas: dvacaciones
gen     dvacaciones = .
notes dvacaciones: the survey does not include information to define this variable

* Sindicalizado: sindicato
gen     sindicato = tmhp47as==1 if ((tmhp47as!=98 & tmhp47as!=99) & relab==2)

*/
 
* Empleado:	ocupado
gen     ocupado = inrange(labor_status,1,2) //trabajando o no trabajando pero tiene trabajo

* Desocupados: desocupa
gen     desocupa = inrange(labor_status,3,4)  //buscando trabajo por primera vez o buscando trabajo habiendo trabajado anteriormente
		
* Inactivos: inactivos	
gen     inactivo= inrange(labor_status,5,9) 

* Poblacion economicamte activa: pea	
gen     pea = (ocupado==1 | desocupa ==1)

*** Why aren't you currently looking for a job?
	/* tmhp39 ¿Por cuál de estos motivos no está buscando trabajo actualmente?: razon_no_busca
			1 = Está cansado de buscar trabajo
			2 = No encuentra el trabajo apropiado
			3 = Cree que no va a encontrar trabajo
			4 = No sabe cómo ni dónde buscar trabajo
			5 = Por su edad no le darán trabajo
			6 = Ningún trabajo se adapta a sus capacidades
			7 = No tiene quién le cuide los niños
			8 = Está enfermo/motivos de salud
			9 = Otro motivo ? Especifique */
clonevar  razon_no_busca = tmhp39 if inlist(tmhp37,2,99) & tmhp39!=. & tmhp39!=.a & tmhp39!=99 & tmhp39!=98

*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- : Social Programs ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global socialprog_ENCOVI beneficiario mision_1 mision_2 mision_3 carnet_patria carnet_patria_no clap



*--------- Receive 'Mision' or social program
 /* (mmhp62):62. EN EL PRESENTE (2017),
 ¿… RECIBE O ES BENEFICIARIO DE ALGUNA MISIÓN O PROGRAMA SOCIAL?
 */
	*-- Check values
	tab mmhp62, mi
	destring mmhp62, replace
	*-- Standarization of missing values
	replace mmhp62=. if mmhp62==99
	*-- Label values
	label def mmhp62  1 "Si" 2 "No" 						  	
	label value mmhp62 mmhp62
	*-- Generate variable
	clonevar beneficiario= mmhp62
	replace beneficiario=0 if mmhp62==2
	*-- Label variable
	label var beneficiario "In 2017: do you receive a 'Mision' or social program"
	*-- Label values	
	label def beneficiario  1 "Yes" 0 "No" 						  	
	label value beneficiario beneficiario


*--------- Which type of 'Mision'
 /* 63. ¿PUEDE IDENTIFICAR CUÁL MISIÓN O PROGRAMA SOCIAL RECIBE ACTUALMENTE? 
 (selecciones hasta tres)
 
 Each person can chose three programs:
	 Variable 1: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 1
	(mmhp63m1)
	 Variable 2: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 2
	(mmhp63m2) 
	 Variable 3: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 3
	(mmhp63m3)
	 
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
	replace mmhp63m`i'=. if mmhp63m`i'==99
	*-- Generate variable
	clonevar mision_`i' = mmhp63m`i' 
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
	tab mp64, mi
	*-- Standarization of missing values
	replace mp64=. if mp64==.
	*-- Generate variable
	clonevar carnet_patria = mp64
	replace carnet_patria = 0 if mp64==2
	replace carnet_patria = . if mp64==99
	*-- Label variable
	label var carnet_patria "Has at least one member of the houselhold obtained the 'Carnet Patria'"
	*-- Label values 
	label def carnet_patria 1 "Yes" 0 "No"
	label value carnet_patria carnet_patria
	

 *--------- 'Carnet patria' Not obtained: Reasons
	*-- Check values
	tab mp64pqn, mi
	*-- Standarization of missing values
	replace mp64pqn="." if mp64pqn=="98"
	replace mp64pqn="." if mp64pqn=="99"
	*-- Generate variable
	gen carnet_patria_no = mp64pqn
	*-- Label variable
	label var carnet_patria_no "Why not obtained the 'Carnet Patria'"
	
	
 *--------- 'Caja CLAP' (In kind-transfer)
 /* 65. ¿EN ESTE HOGAR HAN ADQUIRIDO LA BOLSA/CAJA DEL CLAP?*/
*-- Check values
	tab mp65, mi
	*-- Standarization of missing values
	replace mp65=. if mp65==99
	*-- Generate variable
	clonevar clap = mp65
	replace clap =0 if mp65==2
	*-- Label variable
	label var clap "Has the houselhold received the 'CLAP'"
	*-- Label values 
	label def clap 1 "Yes" 0 "No"
	label value clap clap

		
*--------- 'Caja CLAP' (In kind-transfer): Frequency
 /* 61. ¿CON QUÉ FRECUENCIA LES LLEGA LA BOLSA/CAJA DEL CLAP? */ 

*-- Check values
	tab mp66, mi
	*-- Standarization of missing values
	replace mp66=. if mp66==99
	*-- Generate variable
	clonevar clap_cuando = mp66
	*-- Label variable
	label var clap_cuando "How often the houselhold received the 'CLAP'"
	*-- Label values 
	label def clap_cuando 1 "Cada mes" 2 "Cada 2 meses" ///
	3 "No hay periodicidad" 98 "NA"  
	label value clap_cuando clap_cuando

	
/*

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
order  $id_ENCOVI $control_ent $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $labor_ENCOVI $emigra_ENCOVI $foodcons_ENCOVI $socialprog_ENCOVI
keep   $id_ENCOVI $control_ent $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $labor_ENCOVI $emigra_ENCOVI $foodcons_ENCOVI $socialprog_ENCOVI

save "$pathout\ENCOVI_2017_COMP.dta", replace

