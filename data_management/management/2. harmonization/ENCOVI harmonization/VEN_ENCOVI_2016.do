/*===========================================================================
Country name:		Venezuela
Year:			2016
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		March, 2020
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
				global rootpath1 "C:\Users\WB563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global rootpath2 "
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Desktop\worldbank\analisis\ENCOVI"
		}
		if $trini   {
				global rootpath1 "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global rootpath2 "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global rootpath1 "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
                global rootpath2 "C:\Users\wb550905\Github\VEN" 
		}

global dataofficial "$rootpath1\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global pathout "$rootpath2\VEN\data_management\output\cleaned"

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
gen pais = "VEN"

* Year identifier: year
capture drop year
gen ano = 2016

* Survey identifier: survey
gen encuesta = "ENCOVI - 2016"

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
rename reltohead relacion_comp

*** Sex 
/* SEXO (mhp17): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
gen sexo = mhp17 if  (mhp17!=98 & mhp17!=99)
label define sexo 1 "Male" 2 "Female"
label value sexo sexo
gen hombre = sexo==1 if sexo!=.

*** Age
* EDAD_ENCUESTA (mhp16): Cuantos años cumplidos tiene?
gen     edad = mhp16
notes   edad: range of the variable: 0-105

*** Marital status
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
* Estado civil
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
rename marital_status estado_civil

*** Number of sons/daughters born alive
gen     hijos_nacidos_vivos = sp28 if (sp28!=98 & sp28!=99)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     hijos_vivos = sp29 if sp28!=0 & sp29<=sp28 & (sp29!=98 & sp29!=99)

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global dwell_ENCOVI material_piso material_pared_exterior material_techo tipo_vivienda suministro_agua suministro_agua_comp frecuencia_agua ///
electricidad interrumpe_elect tipo_sanitario tipo_sanitario_comp ndormi banio_con_ducha nbanios tenencia_vivienda ///

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
gen  material_techo = vp3           if (vp3!=98 & vp3!=99)

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
/* SUMINISTRO_AGUA (vp5): A esta vivienda el agua llega normalmente por (no se puede identificar si el acceso es dentro del terreno o vivienda)
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
*/	
gen     suministro_agua = vp5 if (vp5!=98 & vp5!=99)
label def suministro_agua 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Pozo con bomba" 5 "Pozo protegido" 6 "Otros medios"
label value suministro_agua suministro_agua
* Comparable across all years
recode suministro_agua (5 6=4), g(suministro_agua_comp)
label def suministro_agua_comp 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Otros medios"
label value suministro_agua_comp suministro_agua_comp

*** Frequency of water supply
/* FRECUENCIA_AGUA (vp6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
*/
clonevar frecuencia_agua = vp6 if (vp6!=98 & vp6!=99)	

*** Electricity
/* SERVICIO_ELECTRICO (vp7): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe
			5 = No tiene servicio electrico
			99 = NS/NR					
*/
gen servicio_electrico = vp7 if (vp7!=98 & vp7!=99)
gen     electricidad = (servicio_electrico>=1 & servicio_electrico<=4) if servicio_electrico!=.

*** Electric power interruptions
/* electric_interrup (vp7): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
gen interrumpe_elect = servicio_electrico if (servicio_electrico>=1 & servicio_electrico<=4)
label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
label value interrumpe_elect interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (vp8): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
gen tipo_sanitario = vp8 if (vp8!=98 & vp8!=99)
* comparable across all years
recode tipo_sanitario (2=1) (3=2)(4=3) (5=4), g(tipo_sanitario_comp)
label def tipo_sanitario 1 "Poceta a cloaca/Pozo septico" 2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" 4 "No tiene poseta o excusado"
label value tipo_sanitario_comp tipo_sanitario_comp

*** Number of rooms used exclusively to sleep
* NDORMITORIOS (hp10): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormi = hp10 if (hp10!=98 & hp10!=99)

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
		6 = De algun programa de gobierno (con titulo de propiedad)
		7 = De algun programa de gobierno (sin titulo de propiedad)
		8 = Otra
		99 = NS/NR								
*/
destring (hp13ot_cod), replace
clonevar tenencia_vivienda = hp13 if (hp13!=98 & hp13!=99)
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
global dur_ENCOVI auto ncarros anio_auto heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas telefono_fijo

*** Dummy household owns cars
*  AUTO (hp11): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
gen     auto = hp11>0 if (hp11!=98 & hp11!=99)
replace auto = .		if  relacion_en!=1 

*** Number of functioning cars in the household
* NCARROS (hp11) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
gen     ncarros = hp11 if (hp11!=98 & hp11!=99)
replace ncarros = .		if  relacion_en!=1 

*** Does the household have fridge?
* Heladera (hp12n): ¿Posee este hogar nevera?
gen     heladera = hp12n==1 if (hp12n!=98 & hp12n!=99)
replace heladera = .		if  relacion_en!=1 

*** Does the household have washing machine?
* Lavarropas (hp12l): ¿Posee este hogar lavadora?
gen     lavarropas = hp12l==1 if (hp12l!=98 & hp12l!=99)
replace lavarropas = .		if  relacion_en!=1 

*** Does the household have dryer
* Secadora (hp12s): ¿Posee este hogar secadora? 
gen     secadora = hp12s==1 if (hp12s!=98 & hp12s!=99)
replace secadora = .		if  relacion_en!=1 

*** Does the household have computer?
* Computadora (hp12c): ¿Posee este hogar computadora?
gen computadora = hp12c==1 if (hp12c!=98 & hp12c!=99)
replace computadora = .		if  relacion_en!=1 

*** Does the household have internet?
* Internet (hp12i): ¿Posee este hogar internet?
gen     internet = hp12i==1 if (hp12i!=98 & hp12i!=99)
replace internet = .	if  relacion_en!=1 

*** Does the household have tv?
* Televisor (hp12t): ¿Posee este hogar televisor?
gen     televisor = hp12t==1 if (hp12t!=98 & hp12t!=99)
replace televisor = .	if  relacion_en!=1 

*** Does the household have radio?
* Radio (hp12r): ¿Posee este hogar radio? 
gen     radio = hp12r==1 if (hp12r!=98 & hp12r!=99)
replace radio = .		if  relacion_en!=1 

*** Does the household have heater?
* Calentador (hp12o): ¿Posee este hogar calentador? 
gen     calentador = hp12o==1 if (hp12o!=98 & hp12o!=99)
replace calentador = .		if  relacion_en!=1 

*** Does the household have air conditioner?
* Aire acondicionado (hp12a): ¿Posee este hogar aire acondicionado?
gen     aire = hp12a==1 if (hp12a!=98 & hp12a!=99)
replace aire = .		    if  relacion_en!=1 

*** Does the household have cable tv?
* TV por cable o satelital (dhp14v): ¿Posee este hogar TV por cable?
gen     tv_cable = hp12v==1 if (hp12v!=98 & hp12v!=99)
replace tv_cable = .		if  relacion_en!=1

*** Does the household have microwave oven?
* Horno microonada (hp12h): ¿Posee este hogar horno microonda?
gen     microondas = hp12h==1 if (hp12h!=98 & hp12h!=99)
replace microondas = .		if  relacion_en!=1

*** Does the household have landline telephone?
* Teléfono fijo (): telefono_fijo
gen     telefono_fijo =.
replace telefono_fijo = .	 if  relacion_en!=1 

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.6: Variables educativas --------------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI asiste alfabeto edu_pub ///
fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
nivel_educ_en nivel_educ g_educ regimen a_educ s_educ t_educ /*titulo*/ edad_dejo_estudios razon_dejo_estudios razon_dejo_estudios_comp

*** Do you attend any educational center? //for age +3
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

*** Educational attainment
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

*** Literacy
* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (a_educ>=2 & a_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

*** Establecimiento educativo público: edu_pub
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

*** During this school period, did you stop attending the educational center where you regularly study due to:
/*
1. Fallas del servicio de agua?
2. Fallas del servicio eléctrico?
3. Huelga (protestas) del personal docente?
4. Falta de transporte?
5. Falta de comida en el hogar?
6. Falta de comida en el centro educativo?
8. Nunca deja de asistir
99. NS/NR
*/
* Water failiures
gen fallas_agua =  ep36sa==1  if asiste==1 & (ep36sa!=98 & ep36sa!=99)
* Electricity failures
gen fallas_elect = ep36se==2  if asiste==1 & (ep36se!=98 & ep36se!=99)
* Huelga de personal docente
gen huelga_docente = ep36pd==3  if asiste==1 & (ep36pd!=98 & ep36pd!=99)
* Falta transporte
gen falta_transporte = ep36ft==4  if asiste==1 & (ep36ft!=98 & ep36ft!=99)
* Falta de comida en el hogar
gen falta_comida_hogar = ep36fc==5  if asiste==1 & (ep36fc!=98 & ep36fc!=99)
* Falta de comida en el centro educativo
gen falta_comida_centro = ep36fe==6  if asiste==1 & (ep36fe!=98 & ep36fe!=99)
* Inasistencia del personal docente
gen inasis_docente = .
* Manifestaciones, movilizaciones o protestas
gen protestas = .
* Nunca deje de asistir
gen nunca_deja_asistir = ep36nf==8  if asiste==1 & (ep36nf!=98 & ep36nf!=99)

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
gen razon_dejo_est_comp= ep34 if (ep34!=98 & ep34!=99)
label def razon_dejo_est_comp 1 "Terminó los estudios" 2 "Escuela distante" 3 "Escuela cerrada" 4 "Muchos paros/inasistencia de maestros" 5 "Costo de los útiles" 6 "Costo de los uniformes" ///
7 "Enfermedad/discapacidad" 8 "Tiene que trabajar" 9 "No quiso seguir estudiando" 10 "Inseguridad al asistir al centro educativo" 11 "Discriminación o violencia" ///
12 "Por embarazo/cuidar a los hijos" 13 "Tiene que ayudar en tareas del hogar" 14 "No lo considera importante" 15 "Otra"
label value razon_dejo_est_comp razon_dejo_est_comp

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
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables --------------
*************************************************************************************************************************************************)*/
sort id com
order $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $bank_ENCOVI
keep $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $bank_ENCOVI

save "$pathout\ENCOVI_2016_COMP.dta", replace
