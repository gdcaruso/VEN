/*===========================================================================
Country name:		Venezuela
Year:			2018
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
global pathout "$rootpath2\data_management\output\cleaned"

********************************************************************************

/*===============================================================================
                          0: Program set up
===============================================================================*/
version 14
drop _all
set more off

local country  "VEN"    // Country ISO code
local year     "2018"   // Year of the survey
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
use "$data2018\VACUNACION.dta", clear
rename LINVACU LIN
tempfile vacu
save `vacu'
use "$data2018\PERSONAS ENCOVI 2018.dta", clear
merge m:1 ENNUM using "$data2018\HOGARES ENCOVI 2018.dta"
drop _merge
tab CMHP19 if EP96==1 // inconsistency: males reporting being pregnant
/*
    El sexo |
   de...es: |      Freq.     Percent        Cum.
------------+-----------------------------------
  Masculino |        140       48.28       48.28
   Femenino |        150       51.72      100.00
------------+-----------------------------------
      Total |        290      100.00
*/
merge 1:1 ENNUM LIN using "$data2018\Antropometria_2018.dta"
drop _merge
merge 1:1 ENNUM LIN using `vacu' 
tab CMHP18 if _merge==3 // hay dos observacions con edad mayor a 2, aunque las respuestas estas codificadas como NA
*brow if _merge==3 & CMHP18>2
drop _merge
/*
merge 1:1 ENNUM LIN using "$data2018\MIGRACION.dta" //NO ME QUEDA CLARO SI SE PUEDE HACER EL CRUCE (no hay identificador unico)
drop _merge
*/

rename _all, lower

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables  --------------------------------------------------
*************************************************************************************************************************************************)*/

* Country identifier: country
gen pais = "VEN"

* Year identifier: year
capture drop ano
gen ano = 2018

* Survey identifier: survey
gen encuesta = "ENCOVI - 2018"

* Household identifier: id    
gen id = ennum

* Component identifier: com
gen com  = lin
duplicates report id com

gen double pid = lin
notes pid: original variable used was: lin

* Weights: pondera
gen pondera = pesoper  //round(pesoper)

* Strata: strata
gen strata = .
*La variable "estrato" en la base refiere a un muestreo no probabilístico (para el cual se seleccionaron áreas geográficas, grupos de edad y grupos de estrato socioeconómico de la A la F). Esto no es lo mismo que el "strata" al que se refiere CEDLAS 
/* ESTRATO_ENCUESTA
     Estrato |      Freq.     Percent        Cum.
------------+-----------------------------------
         AB |      3,920       18.11       18.11
          C |      5,283       24.40       42.51
          D |      4,686       21.64       64.15
         EF |      7,761       35.85      100.00
------------+-----------------------------------
      Total |     21,650      100.00        	
*/

* Primary Sample Unit: psu   
gen psu = .

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Demographic variables  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_ENCOVI relacion_en relacion_comp hombre edad estado_civil_en estado_civil hijos_nacidos_vivos hijos_vivos 

*** Relation to the head:	reltohead
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
clonevar sexo = cmhp19 if (cmhp19!=98 & cmhp19!=99) 
label define sexo 1 "Male" 2 "Female"
label value sexo sexo
gen hombre = sexo==1 if sexo!=.

*** Age
* EDAD_ENCUESTA (cmhp18): Cuantos años cumplidos tiene?
notes   edad: range of the variable: 0-99
gen edad = cmhp18

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
* Estado civil
	   1 = married
	   2 = never married
	   3 = living together
	   4 = divorced/separated
	   5 = widowed	
*/
clonevar estado_civil_encuesta = cmhp22 if (cmhp22!=98 & cmhp22!=99)

gen     marital_status = 1	if  estado_civil_encuesta==1 | estado_civil_encuesta==2
replace marital_status = 2	if  estado_civil_encuesta==8 
replace marital_status = 3	if  estado_civil_encuesta==3 | estado_civil_encuesta==4
replace marital_status = 4	if  estado_civil_encuesta==5 | estado_civil_encuesta==6
replace marital_status = 5	if  estado_civil_encuesta==7
label def marital_status 1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
label value marital_status marital_status
rename marital_status estado_civil

*** Number of sons/daughters born alive
gen     hijos_nacidos_vivos = smhp25 if (smhp25!=98 & smhp25!=99)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     hijos_vivos = smhp26 if smhp25!=0 & smhp26<=smhp25 & (smhp26!=98 & smhp26!=99)

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
/* electric_interrup (vsp7): En esta vivienda el servicio electrico se interrumpe
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
clonevar tenencia_vivienda = dhp15 if (dhp15!=98 & dhp15!=99)
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
* Heladera (dhp14n): ¿Posee este hogar nevera?
gen     heladera = dhp14n==1 if (dhp14n!=98 & dhp14n!=99)
replace heladera = .		if  relacion_en!=1 

*** Does the household have washing machine?
* Lavarropas (dhp14l): ¿Posee este hogar lavadora?
gen     lavarropas = dhp14l==1 if (dhp14l!=98 & dhp14l!=99)
replace lavarropas = .		if  relacion_en!=1 

*** Does the household have dryer
* Secadora (dhp14s): ¿Posee este hogar secadora? 
gen     secadora = dhp14s==1 if (dhp14s!=98 & dhp14s!=99)
replace secadora = .		if  relacion_en!=1 

*** Does the household have computer?
* Computadora (dhp14c): ¿Posee este hogar computadora?
gen computadora = dhp14c==1 if (dhp14c!=98 & dhp14c!=99)
replace computadora = .		if  relacion_en!=1 

*** Does the household have internet?
* Internet (dhp14i): ¿Posee este hogar internet?
gen     internet = dhp14i==1 if (dhp14i!=98 & dhp14i!=99)
replace internet = .	if  relacion_en!=1 

*** Does the household have tv?
* Televisor (dhp14t): ¿Posee este hogar televisor?
gen     televisor = dhp14t==1 if (dhp14t!=98 & dhp14t!=99)
replace televisor = .	if  relacion_en!=1 

*** Does the household have radio?
* Radio (dhp14r): ¿Posee este hogar radio? 
gen     radio = dhp14r==1 if (dhp14r!=98 & dhp14r!=99)
replace radio = .		if  relacion_en!=1 

*** Does the household have heater?
* Calentador (dhp14o): ¿Posee este hogar calentador? 
gen     calentador = dhp14o==1 if (dhp14o!=98 & dhp14o!=99)
replace calentador = .		if  relacion_en!=1 

*** Does the household have air conditioner?
* Aire acondicionado (dhp14a): ¿Posee este hogar aire acondicionado?
gen     aire = dhp14a==1 if (dhp14a!=98 & dhp14a!=99)
replace aire = .		    if  relacion_en!=1 

*** Does the household have cable tv?
* TV por cable o satelital (dhp14v): ¿Posee este hogar TV por cable?
gen     tv_cable = dhp14v==1 if (dhp14v!=98 & dhp14v!=99)
replace tv_cable = .		if  relacion_en!=1

*** Does the household have microwave oven?
* Horno microonada (dhp14h): ¿Posee este hogar horno microonda?
gen     microondas = dhp14h==1 if (dhp14h!=98 & dhp14h!=99)
replace microondas = .		if  relacion_en!=1

*** Does the household have landline telephone?
* Teléfono fijo (): telefono_fijo
gen     telefono_fijo =.
replace telefono_fijo = .    if  relacion_en!=1 

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.6: Education --------------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI asiste alfabeto edu_pub ///
fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
nivel_educ g_educ s_educ razon_dejo_est_comp

*** Do you attend any educational center? //for age +3
/* ASISTE_ENCUESTA (emhp28): ¿asiste regularmente a un centro educativo como estudiante? 
        1 = Si
		2 = No
		3 = Nunca asistio
		98 = No aplica
		99 = NS/NR
*/
gen asiste_encuesta = emhp28  if (emhp28!=98 & emhp28!=99)                                             
gen     asiste = 1	if  asiste_encuesta==1 
replace asiste = 0	if (asiste_encuesta==2 | asiste_encuesta==3)
replace asiste = .  if  edad<3
notes   asiste: variable defined for individuals aged 3 and older

*** Educational attainment
/* NIVEL_EDUC (emhp27n): ¿Cual fue el ultimo grado o año aprobado y de que nivel educativo: 
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
		99 = NS/NR
* G_EDUC (emhp27a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Preescolar, Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
* S_EDUC (emhp27a): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-10 semestres
		Universitario: 1-12 semestres
		Postgrado: 1-12
*/
clonevar nivel_educ = emhp27n if (emhp27n!=98 & emhp27n!=99)
gen g_educ = emhp27a     if (emhp27a!=98 & emhp27a!=99)
gen s_educ = emhp27s     if (emhp27s!=98 & emhp27s!=99)

*** Literacy
* Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (g_educ>=2 & g_educ<=6)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

* Establecimiento educativo público: edu_pub
/* TIPO_CENTRO_EDUC (emhp31): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		98 = No aplica
		3 = NS/NR								
*/
gen tipo_centro_educ = emhp31 if (emhp31!=98 & emhp31!=99)
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
gen fallas_agua = emhp32a==1  if asiste==1 & (emhp32a!=98 & emhp32a!=99)
* Electricity failures
gen fallas_elect = emhp32b==2  if asiste==1 & (emhp32b!=98 & emhp32b!=99)
* Huelga de personal docente
gen huelga_docente = emhp32c==3  if asiste==1 & (emhp32c!=98 & emhp32c!=99)
* Falta transporte
gen falta_transporte = emhp32d==4  if asiste==1 & (emhp32d!=98 & emhp32d!=99)
* Falta de comida en el hogar
gen falta_comida_hogar = emhp32e==5  if asiste==1 & (emhp32e!=98 & emhp32e!=99)
* Falta de comida en el centro educativo
gen falta_comida_centro = emhp32f==6  if asiste==1 & (emhp32f!=98 & emhp32f!=99)
* Inasistencia del personal docente
gen inasis_docente = emhp32g==7  if asiste==1 & (emhp32g!=98 & emhp32g!=99)
* Manifestaciones, movilizaciones o protestas
gen protestas = emhp32h==8  if asiste==1 & (emhp32h!=98 & emhp32h!=99)
* Nunca deje de asistir
gen nunca_deja_asistir = emhp32i==9  if asiste==1 & (emhp32i!=98 & emhp32i!=99)

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
gen razon_dejo_est_comp= emhp30 if (emhp30!=98 & emhp30!=99)
label def razon_dejo_est_comp 1 "Terminó los estudios" 2 "Escuela distante" 3 "Escuela cerrada" 4 "Muchos paros/inasistencia de maestros" 5 "Costo de los útiles" 6 "Costo de los uniformes" ///
7 "Enfermedad/discapacidad" 8 "Tiene que trabajar" 9 "No quiso seguir estudiando" 10 "Inseguridad al asistir al centro educativo" 11 "Discriminación o violencia" ///
12 "Por embarazo/cuidar a los hijos" 13 "Tiene que ayudar en tareas del hogar" 14 "No lo considera importante" 15 "Otra"
label value razon_dejo_est_comp razon_dejo_est_comp

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

gen afiliado_seguro_salud = 1     if smhp24a==1 
replace afiliado_seguro_salud = 2 if smhp24b==2 
replace afiliado_seguro_salud = 3 if smhp24c==3 
replace afiliado_seguro_salud = 4 if smhp24d==4
replace afiliado_seguro_salud = 5 if smhp24e==5
replace afiliado_seguro_salud = 6 if smhp24f==6

gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6

* Tipo de seguro de salud: tipo_seguro
/*      0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
        1 = si esta afiliado a algun seguro de salud privado
*/
gen 	tipo_seguro = 0     if  (afiliado_seguro_salud>=1 & afiliado_seguro_salud<=4) 
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
tab hombre ep96 //INCONSISTENCIA APARECEN HOMBRES CONTESTANDO ESTA PREGUNTA
gen embarazada = (ep96==1) if (ep96!=98 & ep96!=99) 
gen hijo_nacido_vivo = ep101 if (ep101!=98 & ep101!=99)
clonevar lugar_control_emb = ep98 if (ep98!=98 & ep98!=99) & embarazada==1
clonevar lugar_controlo_emb = ep106 if (ep106!=98 & ep106!=99) & (embarazada==0 & hijo_nacido_vivo==1)
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
gen    tiempo_pecho = .
notes tiempo_pecho: the survey does not include information to define this variable

* Vacunas
*  ¿Ha recibido vacuna Anti-BCG (contra la tuberculosis): vacuna_bcg
gen    vacuna_bcg = (vp108bcg==1) if (vp108bcg!=98 & vp108bcg!=99) & edad<=2 

*  ¿Ha recibido vacuna Anti-hepatitis B: vacuna_hepatitis
gen    vacuna_hepatitis = (vp108hb==2) if (vp108hb!=98 & vp108hb!=99) & edad<=2 

*  ¿Ha recibido vacuna Cuadruple (contra la difteria, el tetanos y la influenza tipo b): vacuna_cuadruple
gen    vacuna_cuadruple = .
notes vacuna_cuadruple: the survey does not include information to define this variable 

*  ¿Ha recibido vacuna Triple Bacteriana (contra la difteria, el tetanos y la tos convulsa): vacuna_triple
gen    vacuna_triple = . 
notes vacuna_triple: the survey does not include information to define this variable

*  ¿Ha recibido vacuna Antihemophilus (contra la influenza tipo b): vacuna_hemo
gen    vacuna_hemo = (vp108fl==5) if (vp108fl!=98 & vp108fl!=99) & edad<=2 

*  ¿Ha recibido vacuna Sabin (contra la poliomielitis): vacuna_sabin
gen    vacuna_sabin = (vp108ap==6 | vp108po==7) if (vp108ap!=98 & vp108ap!=99 & vp108po!=98 & vp108po!=99) & edad<=2 

*  ¿Ha recibido vacuna Triple Viral (contra el sarampion, las paperas y la rubeola): vacuna_triple_viral
gen    vacuna_triple_viral = (vp108tri==10) if (vp108tri!=98 & vp108tri!=99) & edad<=2 

*** ADICIONALES
*  ¿Ha recibido vacuna Antirotavirus: vacuna_rotavirus
gen    vacuna_rotavirus = (vp108ro==3) if (vp108ro!=98 & vp108ro!=99) & edad<=2 

*  ¿Ha recibido vacuna Pentavalente (contra la difteria, tos ferina, tetanos, hepatitis B, meningitis y neumonias por Hib): vacuna_pentavalente
gen    vacuna_pentavalente = (vp108pt==4) if (vp108pt!=98 & vp108pt!=99) & edad<=2 

*  ¿Ha recibido vacuna Anti-neumococo : vacuna_neumococo
gen    vacuna_neumococo = (vp108ne==8) if (vp108ne!=98 & vp108ne!=99) & edad<=2 

*  ¿Ha recibido vacuna Anti-amarilica (contra la fiebre amarilla) : vacuna_amarilica
gen    vacuna_amarilica = (vp108ama==9) if (vp108ama!=98 & vp108ama!=99) & edad<=2 

*  ¿Ha recibido vacuna contra la Varicela: vacuna_varicela
gen    vacuna_varicela = (vp108var==11) if (vp108var!=98 & vp108var!=99) & edad<=2 

* No ha recibido ninguna vacuna: vacuna_ninguna
gen    vacuna_ninguna = (vp108ning==12) if (vp108ning!=98 & vp108ning!=99) & edad<=2 

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
gen   fumar = .
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
replace relab = 2 if (labor_status==1 | labor_status==2) & ((categ_ocu>=1 & categ_ocu<=4) | categ_ocu== 9 | categ_ocu==7) // Employee - Obs: survey's CAPI1 defines the miembro de cooperativas as not self-employed
replace relab = 3 if (labor_status==1 | labor_status==2) & (categ_ocu==6)  // Self-employed
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
*Assumption: we complete with 13 months when more than 12 months

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



*/
/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables  --------------
*************************************************************************************************************************************************)*/
sort id com
order $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI 
keep  $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI 

save "$pathout\ENCOVI_2018_COMP.dta", replace

