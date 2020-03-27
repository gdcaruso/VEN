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
		global trini 1
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   0
		
			
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
global dataout "$rootpath\VEN\data_management\output\cleaned"
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


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Control de la entrevista  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global control_ent entidad municipio nombmun parroquia nombpar centropo nombcp segmento peso_segmento combined_id tipo_muestra gps_struc id_struc statut sector_urb 
rename segment_weight peso_segmento
rename sector sector_urb

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.0: Determinacion de hogares  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global det_hogares npers_viv comparte_gasto_viv npers_gasto_sep npers_gasto_comp
gen npers_viv=s3q1 if s3q1!=. & s3q1!=.a
gen comparte_gasto_viv=s3q2 if s3q2!=. & s3q2!=.a
gen npers_gasto_sep=s3q3 if s3q3!=. & s3q3!=.a
gen npers_gasto_comp=s3q4 if s3q4!=. & s3q4!=.a

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Identification Variables --------------------------------------------------
*************************************************************************************************************************************************)*/
global id_ENCOVI pais ano encuesta id com psu
* Country identifier: country
	gen pais = "VEN"

* Year identifier: year
	capture drop year
	gen ano = 2019

* Survey identifier: survey
	gen encuesta = "ENCOVI - 2019"

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
global demo_ENCOVI relacion_en relacion_comp hombre edad anio_naci mes_naci pais_naci residencia resi_estado resi_municipio razon_cambio_resi perte_2014 razon_incorp_hh ///
certificado_naci cedula razon_nocertificado estado_civil_en estado_civil hijos_nacidos_vivos hijos_vivos anio_ult_hijo anio_mes_hijo anio_dia_hijo

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
clonevar relacion_en = s6q2 if s6q2!=. & s6q2!=.a

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
/* SEXO (s6q3): El sexo de ... es
	1 = Masculino
	2 = Femenino
*/
clonevar sexo = s6q3 if (s6q3!=. & s6q3!=.a)
label define sexo 1 "Male" 2 "Female"
label value sexo sexo
gen hombre = sexo ==1 if sexo!=.

*** Age
* EDAD_ENCUESTA (s6q5): Cuantos años cumplidos tiene?
notes   edad: range of the variable: 0-97
*clonevar sexo = s6q5 if (s6q5!=. & s6q5!=.a)

*** Year of birth
clonevar anio_naci = s6q4_year if (s6q4_year!=. & s6q4_year!=.a & s6q4_year!=9999 & s6q4_year!=9 ) 

*** Month of birth
clonevar mes_naci = s6q4_month if (s6q4_month!=. & s6q4_month!=.a & s6q4_month!=9999) 

*** Day of birth
clonevar dia_naci = s6q4_day if (s6q4_day!=. & s6q4_day!=.a & s6q4_day!=9999) 

*** Country of birth
gen pais_naci = s6q6 if (s6q6!=. & s6q6!=.a)

*** In September 2018 where do you reside?
gen residencia = s6q7 if (s6q7!=. & s6q7!=.a)

*** In which state did you reside in September 2018?
gen resi_estado = s6q7a if (s6q7a!=. & s6q7a!=.a)

*** In which county did you reside in September 2018?
gen resi_municipio = s6q7b if (s6q7b!=. & s6q7b!=.a)

*** Which was the main reason for moving to another residency?
gen razon_cambio_resi = s6q7c if (s6q7c!=. & s6q7c!=.a)

*** Are you part of this household since the last 5 years?
gen pert_2014 = (s6q8==1) if (s6q8!=. & s6q8!=.a)

*** Reason for incorporating to the household
gen razon_incorp_hh = (s6q9==1) if (s6q9!=. & s6q9!=.a)

*** Birth certificate
gen certificado_naci = (s6q10==1) if (s6q10!=. & s6q10!=.a)

*** ID card
gen cedula = (s6q11==1) if (s6q11!=. & s6q11!=.a)

*** Reasons for not having birth certificate
gen razon_nocertificado = (s6q12==1) if (s6q12!=. & s6q12!=.a)

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
* Estado civil
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
rename marital_status estado_civil

*** Number of sons/daughters born alive
gen     hijos_nacidos_vivos = s6q14 if (s6q14!=. & s6q14!=.a)

*** From the total of sons/daughters born alive, how many are currently alive?
gen     hijos_vivos = s6q15 if s6q14!=0 & s6q15 <=s6q14 & (s6q15!=. & s6q15!=.a)

*** Which year was your last son born?
gen     anio_ult_hijo = s6q16a if s6q14!=0 & (s6q16a!=9999 & s6q16a!=. & s6q16a!=.a)
replace anio_ult_hijo = 2005 if anio_ult_hijo==20005
replace anio_ult_hijo = 2011 if anio_ult_hijo==20011
replace anio_ult_hijo = 2013 if anio_ult_hijo==20013
replace anio_ult_hijo = 2017 if anio_ult_hijo==20017
replace anio_ult_hijo = 2012 if anio_ult_hijo==212
replace anio_ult_hijo = s6q16c if s6q16c>31 &  s6q16c!=. & s6q16c!=.a & s6q16c!=9999 //wronly codified in day
replace anio_ult_hijo = . if s6q16a<1000

*** Which month was your last son born?
gen     mes_ult_hijo = s6q16b if s6q14!=0 & (s6q16b!=9999)

*** Which day was your last son born?
gen     dia_ult_hijo = s6q16c if s6q14!=0 & (s6q16c!=9999)
replace dia_ult_hijo = s6q16a if s6q16c>31 &  s6q16c!=. & s6q16c!=.a & s6q16c!=9999 //wronly codified in year

/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global dwell_ENCOVI material_piso material_pared_exterior material_techo tipo_vivienda suministro_agua suministro_agua_comp frecuencia_agua ///
serv_elect_red_pub serv_elect_planta_priv serv_elect_otro electricidad interrumpe_elect tipo_sanitario tipo_sanitario_comp ndormi banio_con_ducha nbanios tenencia_vivienda ///
pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m atrasos_alq_mutuo implicancias_nopago renta_imp_en renta_imp_mon titulo_propiedad ///
fagua_acueduc fagua_estanq fagua_cisterna fagua_bomba fagua_pozo fagua_manantial fagua_botella fagua_otro tratamiento_agua tipo_tratamiento ///
comb_cocina pagua pelect pgas pcarbon pparafina ptelefono pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon ///
pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m danio_electrodom

*** Type of flooring material
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
*/
gen  material_piso = s4q1            if (s4q1!=. & s4q1!=.a)	
label def material_piso 1 "Mosaic,granite,vynil, brick.." 2 "Cement" 3 "Ground floor" 4 "Boards" 5 "Other"
label value material_piso material_piso

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
gen  material_pared_exterior = s4q2  if (s4q2!=. & s4q2!=.a)
label def material_pared_exterior 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete" 4 "" 5 "" 6 "" 7 "" 8 ""
label value material_pared_exterior material_pared_exterior

*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
*/
gen  material_techo = s4q3           if (s4q3!=. & s4q3!=.a)

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
clonevar tipo_vivienda = s4q4 if (s4q4!=. & s4q4!=.a)

*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda?
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
*/
gen     suministro_agua = 1 if  s4q5__1==1
replace suministro_agua = 2 if  s4q5__2==1
replace suministro_agua = 3 if  s4q5__3==1
replace suministro_agua = 4 if  s4q5__4==1
replace suministro_agua = 5 if  s4q5__5==1
replace suministro_agua = 6 if  s4q5__6==1	
label def suministro_agua 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Pozo con bomba" 5 "Pozo protegido" 6 "Otros medios"
label value suministro_agua suministro_agua
* Comparable across all years
recode suministro_agua (5 6=4), g(suministro_agua_comp)
label def suministro_agua_comp 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Otros medios"
label value suministro_agua_comp suministro_agua_comp

*** Frequency of water supply
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
*/
clonevar frecuencia_agua = s4q6 if (s4q6!=. & s4q6!=.a)	

*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/
gen serv_elect_red_pub=s4q7__1 if s4q7__1!=. & s4q7__1!=.a
gen serv_elect_planta_priv=s4q7__2 if s4q7__2!=. & s4q7__2!=.a
gen serv_elect_otro=s4q7__3 if s4q7__3!=. & s4q7__3!=.a
gen electricidad= (s4q7__1==1 | s4q7__2==1 | s4q7__3==1)  if (s4q7__1!=. & s4q7__1!=.a & s4q7__2!=. & s4q7__2!=.a & s4q7__3!=. & s4q7__3!=.a)
* tab s4q7__4

*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
gen interrumpe_elect = s4q8 if (s4q8!=. & s4q8!=.a)
label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
label value interrumpe_elect interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
*/
clonevar tipo_sanitario = s4q9 if (s4q9!=. & s4q9!=.a)
* comparable across all years
recode tipo_sanitario (2=1) (3=2)(4=3) (5=4), g(tipo_sanitario_comp)
label def tipo_sanitario 1 "Poceta a cloaca/Pozo septico" 2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" 4 "No tiene poseta o excusado"
label value tipo_sanitario_comp tipo_sanitario_comp

*** Number of rooms used exclusively to sleep
* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormi= s5q1 if (s5q1!=. & s5q1!=.a) //up to 9

*** Bath with shower 
* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
gen     banio_con_ducha = s5q2==1 if (s5q2!=. & s5q2!=.a)

*** Number of bathrooms with shower
* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 

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
clonevar tenencia_vivienda = s5q7 if (s5q7!=. & s5q7!=.a)
gen tenencia_vivienda_comp=1 if tenencia_vivienda==1
replace tenencia_vivienda_comp=2 if tenencia_vivienda==2
replace tenencia_vivienda_comp=3 if tenencia_vivienda==3 | tenencia_vivienda==4
replace tenencia_vivienda_comp=4 if tenencia_vivienda==8
replace tenencia_vivienda_comp=5 if tenencia_vivienda==9
replace tenencia_vivienda_comp=6 if tenencia_vivienda==5 | tenencia_vivienda==6
replace tenencia_vivienda_comp=7 if tenencia_vivienda==7 | tenencia_vivienda==10
label define tenencia_vivienda_comp 1 "Propia pagada" 2 "Propia pagandose" 3 "Alquilada" 4 "Prestada" 5 "Invadida" 6 "De algun programa de gobierno" 7 "Otra"
label value tenencia_vivienda_comp tenencia_vivienda_comp

*** How much did you pay for rent or mortgage the last month?
gen pago_alq_mutuo=s5q8a if s5q8a!=. & s5q8a!=.a

*** In which currency did you make the payment?
gen pago_alq_mutuo_mon=s5q8b if s5q8b!=. & s5q8b!=.a

*** In which month did you make the payment?
gen pago_alq_mutuo_m=s5q8c if s5q8c!=. & s5q8c!=.a

*** During the last year, have you had arrears in payments?
gen atrasos_alq_mutuo=(s5q9==1) if s5q9!=. & s5q9!=.a

*** What consequences did the arrears in payments had?
gen implicancias_nopago=s5q10 if s5q10!=. & s5q10!=.a

*** If you had to rent similar dwelling, how much did you think you should pay?
gen renta_imp_en=s5q11 if s5q11!=. & s5q11!=.a

*** In which currency ?
gen renta_imp_mon=s5q11a if s5q11a!=. & s5q11a!=.a

*** What type of property title do you have?
gen titulo_propiedad=s5q12 if s5q12!=. & s5q12!=.a

*** What are the main sources of drinking water in your household?
* Acueducto
gen fagua_acueduc=s5q13__1 if s5q13__1!=. & s5q13__1!=.a
* Pila o estanque
gen fagua_estanq=s5q13__2 if s5q13__2!=. & s5q13__2!=.a
* Camión cisterna
gen fagua_cisterna=s5q13__3 if s5q13__3!=. & s5q13__3!=.a
* Pozo con bomba
gen fagua_bomba=s5q13__4 if s5q13__4!=. & s5q13__4!=.a
* Pozo protegido
gen fagua_pozo=s5q13__5 if s5q13__5!=. & s5q13__5!=.a
* Aguas superficiales (manantial,río, lago, canal de irrigación)
gen fagua_manantial=s5q13__6 if s5q13__6!=. & s5q13__6!=.a
* Agua embotellada
gen fagua_botella=s5q13__7 if s5q13__7!=. & s5q13__7!=.a
* Otros
gen fagua_otro=s5q13__8 if s5q13__8!=. & s5q13__8!=.a

*** In your household, is the water treated to make it drinkable
gen tratamiento_agua=(s5q14==1) if s5q14!=. & s5q14!=.a

*** How do you treat the water to make it more safe for drinking
gen tipo_tratamiento=s5q15 if s5q15!=. & s5q15!=.a

*** Which type of fuel do you use for cooking?
gen comb_cocina=s5q16 if s5q16!=. & s5q16!=.a

*** Did you pay for the following utilities?
* Water
gen pagua=(s5q17__1==1) if s5q17__1!=. & s5q17__1!=.a 
* Electricity
gen pelect=(s5q17__2==1) if s5q17__2!=. & s5q17__2!=.a
* Gas
gen pgas=(s5q17__3==1) if s5q17__3!=. & s5q17__3!=.a
* Carbon, wood
gen pcarbon=(s5q17__4==1) if s5q17__4!=. & s5q17__4!=.a
* Paraffin
gen pparafina=(s5q17__5==1) if s5q17__5!=. & s5q17__5!=.a
* Landline, internet and tv cable
gen ptelefono=(s5q17__7==1) if s5q17__7!=. & s5q17__7!=.a

*** How much did you pay for the following utilities?
gen pagua_monto=s5q17a1 if s5q17a1!=. & s5q17a1!=.a 
* Electricity
gen pelect_monto=s5q17a2 if s5q17a2!=. & s5q17a2!=.a
* Gas
gen pgas_monto=s5q17a3 if s5q17a3!=. & s5q17a3!=.a
* Carbon, wood
gen pcarbon_monto=s5q17a4 if s5q17a4!=. & s5q17a4!=.a
* Paraffin
gen pparafina_monto=s5q17a5 if s5q17a5!=. & s5q17a5!=.a
* Landline, internet and tv cable
gen ptelefono_monto=s5q17a7 if s5q17a7!=. & s5q17a7!=.a

*** In which currency did you pay for the following utilities?
gen pagua_mon=s5q17b1 if s5q17b1!=. & s5q17b1!=.a 
* Electricity
gen pelect_mon=s5q17b2 if s5q17b2!=. & s5q17b2!=.a
* Gas
gen pgas_mon=s5q17b3 if s5q17b3!=. & s5q17b3!=.a
* Carbon, wood
gen pcarbon_mon=s5q17b4 if s5q17b4!=. & s5q17b4!=.a
* Paraffin
gen pparafina_mon=s5q17b5 if s5q17b5!=. & s5q17b5!=.a
* Landline, internet and tv cable
gen ptelefono_mon=s5q17b7 if s5q17b7!=. & s5q17b7!=.a

*** In which month did you pay for the following utilities?
gen pagua_m=s5q17c1 if s5q17c1!=. & s5q17c1!=.a 
* Electricity
gen pelect_m=s5q17c2 if s5q17c2!=. & s5q17c2!=.a
* Gas
gen pgas_m=s5q17c3 if s5q17c3!=. & s5q17c3!=.a
* Carbon, wood
gen pcarbon_m=s5q17c4 if s5q17c4!=. & s5q17c4!=.a
* Paraffin
gen pparafina_m=s5q17c5 if s5q17c5!=. & s5q17c5!=.a
* Landline, internet and tv cable
gen ptelefono_m=s5q17c7 if s5q17c7!=. & s5q17c7!=.a

*** In your household, have any home appliences damaged due to blackouts or voltage inestability?
gen danio_electrodom=(s5q20==1) if s5q20!=. & s5q20!=.a

foreach x in $dwell_ENCOVI {
replace `x'=. if relacion_en!=1
}

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/
global dur_ENCOVI auto ncarros anio_auto heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas telefono_fijo

*** Dummy household owns cars
*  AUTO (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
gen     auto = s5q4==1		if  s5q4!=. & s5q4!=.a
replace auto = .		if  relacion_en!=1 

*** Number of functioning cars in the household
* NCARROS (s5q4a) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
gen     ncarros = s5q4a if s5q4==1 & (s5q4a!=. & s5q4a!=.a)
replace ncarros = .		if  relacion_en!=1 

*** Year of the most recent car
gen anio_auto= s5q5 if s5q4==1 & (s5q5!=. & s5q5!=.a)
replace anio_auto = . if relacion_en==1

*** Does the household have fridge?
* Heladera (s5q6__1): ¿Posee este hogar nevera?
gen     heladera = s5q6__1==1 if (s5q6__1!=. & s5q6__1!=.a)
replace heladera = .		if  relacion_en!=1 

*** Does the household have washing machine?
* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
gen     lavarropas = s5q6__2==1 if (s5q6__2!=. & s5q6__2!=.a)
replace lavarropas = .		if  relacion_en!=1 

*** Does the household have dryer
* Secadora (s5q6__3): ¿Posee este hogar secadora? 
gen     secadora = s5q6__3==1 if (s5q6__3!=. & s5q6__3!=.a)
replace secadora = .		if  relacion_en!=1 

*** Does the household have computer?
* Computadora (s5q6__4): ¿Posee este hogar computadora?
gen computadora = s5q6__4==1 if (s5q6__4!=. & s5q6__4!=.a)
replace computadora = .		if  relacion_en!=1 

*** Does the household have internet?
* Internet (s5q6__5): ¿Posee este hogar internet?
gen     internet = s5q6__5==1 if (s5q6__5!=. & s5q6__5!=.a)
replace internet = .	if  relacion_en!=1 

*** Does the household have tv?
* Televisor (s5q6__6): ¿Posee este hogar televisor?
gen     televisor = s5q6__6==1 if (s5q6__6!=. & s5q6__6!=.a)
replace televisor = .	if  relacion_en!=1 

*** Does the household have radio?
* Radio (s5q6__7): ¿Posee este hogar radio? 
gen     radio = s5q6__7==1 if (s5q6__7!=. & s5q6__7!=.a)
replace radio = .		if  relacion_en!=1 

*** Does the household have heater?
* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
gen     calentador = s5q6__8==1 if (s5q6__8!=. & s5q6__8!=.a)
replace calentador = .		if  relacion_en!=1 

*** Does the household have air conditioner?
* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
gen     aire = s5q6__9==1 if (s5q6__9!=. & s5q6__9!=.a)
replace aire = .		    if  relacion_en!=1 

*** Does the household have cable tv?
* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
gen     tv_cable = s5q6__10==1 if (s5q6__10!=. & s5q6__10!=.a)
replace tv_cable = .		if  relacion_en!=1

*** Does the household have microwave oven?
* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
gen     microondas = s5q6__11==1 if (s5q6__11!=. & s5q6__11!=.a)
replace microondas = .		if  relacion_en!=1

*** Does the household have landline telephone?
* Teléfono fijo (s5q6__12): telefono_fijo
gen     telefono_fijo = s5q6__12==1 if (s5q6__12!=. & s5q6__12!=.a)
replace telefono_fijo = .		    if  relacion_en!=1 

/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- 1.6: Education --------------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI contesta_ind_e quien_contesta_e asistio_educ razon_noasis asiste nivel_educ_act g_educ_act regimen_act a_educ_act s_educ_act t_educ_act edu_pub ///
fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
pae pae_frecuencia pae_desayuno pae_almuerzo pae_meriman pae_meritard pae_otra ///
cuota_insc compra_utiles compra_uniforme costo_men costo_transp otros_gastos ///
cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto ///
cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon ///
cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m ///
nivel_educ_en nivel_educ g_educ regimen a_educ s_educ t_educ alfabeto /*titulo*/ edad_dejo_estudios razon_dejo_estudios razon_dejo_estudios_comp

*** Is the "member" answering by himself/herself?
gen contesta_ind_e=s7q0 if (s7q0!=. & s7q0!=.a)

*** Who is answering instead of "member"?
gen quien_contesta_e=s7q00 if (s7q00!=. & s7q00!=.a)

*** Have you ever attended any educational center? //for age +3
gen asistio_educ = s7q1==1 if (s7q1!=. & s7q1!=.a) & edad>=3

*** Reasons for never attending
/* RAZONES_NO_ASIS (s7q2): Cual fue la principal razon por la que nunca asistio?
		1 = Muy joven
		2 = Escuela distante
		3 = Escuela cerrada
		4 = Muchos paros/inasistencia de maestros
		5 = Costo de los útiles
		6 = Costo de los uniformes
		7 = Enfermedad/discapacidad
		8 = Debía trabajar
		9 = Inseguridad al asistir al centro educativo
		10 = Discriminación
		11 = Violencia
		14 = Obligaciones en el hogar
		15 = No lo considera importante
		16 = Otra, especifique
*/
clonevar razon_noasis = s7q2 if s7q1==2 & (s7q2!=. & s7q2!=.a)

*** During the period 2019-2020 did you attend any educational center? //for age +3
gen asiste= s7q1==1 if (s7q1!=. & s7q1!=.a) & edad>=3
replace asiste = .  if  edad<3
notes   asiste: variable defined for individuals aged 3 and older

*** Which is the educational level you are currently attending?
/* NIVEL_EDUC_ACT (s7q4): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  
		1 = Ninguno		
        2 = Preescolar
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado	
*/
gen nivel_educ_act=s7q4 if (s7q4!=. & s7q4!=.a) & edad>=3
label def nivel_educ_act 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
label value nivel_educ_act nivel_educ_act

*** Which grade are you currently attending
/* G_EDUC_ACT (s7q4a): ¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
gen g_educ_act = s7q4a if  s7q3==1 & (s7q4==3 | s7q4==4 | s7q4==5 | s7q4==6) & (s7q4a!=. & s7q4a!=.a) 

*** Regimen de estudios
* REGIMEN_ACT (s7q4b): El regimen de estudios es anual, semestral o trimestral?
clonevar regimen_act = s7q4b if s7q3==1 & (s7q4>=7 & s7q4<=9) & (s7q4b!=. & s7q4b!=.a)
replace regimen_act =3 if regimen_act==5 //8 obs wrongly codified

*** Which year are you currently attending	?	
/* A_EDUC_ACT (s7q4c): ¿Cuál es el ano al que asiste? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
gen a_educ_act = s7q4c    if s7q3==1 & (s7q4==7 | s7q4==8 | s7q4==9) & s7q4b==1 & (s7q4c!=. & s7q4c!=.a) //for those who study tertiary education on annual basis

*** Which semester are you currently attending?
/* S_EDUC_ACT (s7q4d): ¿Cuál es el semestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
gen s_educ_act = s7q4d    if s7q3==1 & (s7q4==7 | s7q4==8 | s7q4==9) & s7q4b==2 & (s7q4d!=. & s7q4d!=.a) //for those who study tertiary education on biannual basis

*** Which quarter are you currently attending?
/* T_EDUC_ACT (s7q4e): ¿Cuál esel trimestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
gen t_educ_act = s7q4e    if s7q3==1 & (s7q4==7 | s7q4==8 | s7q4==9) & s7q4b==3 & (s7q4e!=. & s7q4e!=.a) //for those who study tertiary education on quarterly basis

*** Type of educational center
/* TIPO_CENTRO_EDUC (s7q5): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		.
		.a
*/
gen tipo_centro_educ = s7q5 if s7q3==1 & (s7q5!=. & s7q5!=.a)
gen     edu_pub = 1	if  tipo_centro_educ==2  
replace edu_pub = 0	if  tipo_centro_educ==1
replace edu_pub = . if  edad<3

*** During this school period, did you stop attending the educational center where you regularly study due to:
* Water failiures
gen fallas_agua = s7q6__1  if s7q3==1 & (s7q6__1!=. & s7q6__1!=.a)
* Electricity failures
gen fallas_elect = s7q6__2  if s7q3==1 & (s7q6__2!=. & s7q6__2!=.a)
* Huelga de personal docente
gen huelga_docente = s7q6__3  if s7q3==1 & (s7q6__3!=. & s7q6__3!=.a)
* Falta transporte
gen falta_transporte = s7q6__4  if s7q3==1 & (s7q6__4!=. & s7q6__4!=.a)
* Falta de comida en el hogar
gen falta_comida_hogar = s7q6__5  if s7q3==1 & (s7q6__5!=. & s7q6__5!=.a)
* Falta de comida en el centro educativo
gen falta_comida_centro = s7q6__6  if s7q3==1 & (s7q6__6!=. & s7q6__6!=.a)
* Inasistencia del personal docente
gen inasis_docente = s7q6__7  if s7q3==1 & (s7q6__7!=. & s7q6__7!=.a)
* Manifestaciones, movilizaciones o protestas
gen protestas = s7q6__8  if s7q3==1 & (s7q6__8!=. & s7q6__8!=.a)
* Nunca deje de asistir
gen nunca_deja_asistir = s7q6__9  if s7q3==1 & (s7q6__9!=. & s7q6__9!=.a)

*** El centro educativo al que asiste cuenta con el programa de alimentacion escolar PAE?
gen pae = s7q7==1 if s7q3==1 & (s7q7!=. & s7q7!=.a)

*** En el centro educativo al que asiste, el programa PAE funciona:
/* 		1.Todos los días
		2.Solo algunos días
		3.Casi nunca
*/
gen pae_frecuencia = s7q8 if s7q7==1 & (s7q8!=. & s7q8!=.a)

*** En el centro educativo al que asiste, el programa pae ofrece:
* Desayuno
gen pae_desayuno= s7q9__1 if  s7q7==1 & (s7q9__1!=. & s7q9__1!=.a)
* Almuerzo
gen pae_almuerzo= s7q9__2 if  s7q7==1 & (s7q9__2!=. & s7q9__2!=.a)
* Merienda en la manana
gen pae_meriman= s7q9__3 if  s7q7==1 & (s7q9__3!=. & s7q9__3!=.a)
* Merienda en la tarde
gen pae_meritard= s7q9__4 if  s7q7==1 & (s7q9__4!=. & s7q9__4!=.a)
* Otra
gen pae_otra= s7q9__5 if  s7q7==1 & (s7q9__5!=. & s7q9__5!=.a)

*** Durante el periodo escolar 2019-2020 gasto, consiguio, recibio donancion en alguno de los siguientes conceptos?
* Cuota de inscripción
gen cuota_insc=s7q10_0__1 if s7q3==1 & (s7q10_0__1!=. & s7q10_0__1!=.a)
* Compra de útiles y libros escolares
gen compra_utiles=s7q10_0__2 if s7q3==1 & (s7q10_0__2!=. & s7q10_0__2!=.a)
* Compra de uniformes y calzados escolares
gen compra_uniforme=s7q10_0__3 if s7q3==1 & (s7q10_0__3!=. & s7q10_0__3!=.a)
* Costo de la mensualidad
gen costo_men=s7q10_0__4 if s7q3==1 & (s7q10_0__4!=. & s7q10_0__4!=.a)
* Uso de transporte público o escolar
gen costo_transp=s7q10_0__5 if s7q3==1 & (s7q10_0__5!=. & s7q10_0__5!=.a)
* Otros gastos
gen otros_gastos=s7q10_0__6 if s7q3==1 & (s7q10_0__6!=. & s7q10_0__6!=.a)

*** Monto pagado
* Cuota de inscripción
gen cuota_insc_monto=s7q10a_1 if s7q10_0__1==1 & (s7q10a_1!=. & s7q10a_1!=.a & s7q10a_1!=9999)
* Compra de útiles y libros escolares
gen compra_utiles_monto=s7q10a_2 if s7q10_0__2==1 & (s7q10a_2!=. & s7q10a_2!=.a & s7q10a_2!=9999)
* Compra de uniformes y calzados escolares
gen compra_uniforme_monto=s7q10a_3 if s7q10_0__3==1 & (s7q10a_3!=. & s7q10a_3!=.a & s7q10a_3!=9999)
* Costo de la mensualidad
gen costo_men_monto=s7q10a_4 if s7q10_0__4==1 & (s7q10a_4!=. & s7q10a_4!=.a & s7q10a_4!=9999)
* Uso de transporte público o escolar
gen costo_transp_monto=s7q10a_5 if s7q10_0__5==1 & (s7q10a_5!=. & s7q10a_5!=.a & s7q10a_5!=9999)
* Otros gastos
gen otros_gastos_monto=s7q10a_6 if s7q10_0__6==1 & (s7q10a_6!=. & s7q10a_6!=.a & s7q10a_6!=9999)

*** Moneda en que se realizo el pago
* Cuota de inscripción
gen cuota_insc_mon=s7q10b_1 if s7q10_0__1==1 & (s7q10b_1!=. & s7q10b_1!=.a)
* Compra de útiles y libros escolares
gen compra_utiles_mon=s7q10b_2 if s7q10_0__2==1 & (s7q10b_2!=. & s7q10b_2!=.a)
* Compra de uniformes y calzados escolares
gen compra_uniforme_mon=s7q10b_3 if s7q10_0__3==1 & (s7q10b_3!=. & s7q10b_3!=.a)
* Costo de la mensualidad
gen costo_men_mon=s7q10b_4 if s7q10_0__4==1 & (s7q10b_4!=. & s7q10b_4!=.a)
* Uso de transporte público o escolar
gen costo_transp_mon=s7q10b_5 if s7q10_0__5==1 & (s7q10b_5!=. & s7q10b_5!=.a)
* Otros gastos
gen otros_gastos_mon=s7q10b_6 if s7q10_0__6==1 & (s7q10b_6!=. & s7q10b_6!=.a)

*** Mes en que se realizo el pago
gen cuota_insc_m=s7q10b_1 if s7q10_0__1==1 & (s7q10b_1!=. & s7q10b_1!=.a)
* Compra de útiles y libros escolares
gen compra_utiles_m=s7q10b_2 if s7q10_0__2==1 & (s7q10b_2!=. & s7q10b_2!=.a)
* Compra de uniformes y calzados escolares
gen compra_uniforme_m=s7q10b_3 if s7q10_0__3==1 & (s7q10b_3!=. & s7q10b_3!=.a)
* Costo de la mensualidad
gen costo_men_m=s7q10b_4 if s7q10_0__4==1 & (s7q10b_4!=. & s7q10b_4!=.a)
* Uso de transporte público o escolar
gen costo_transp_m=s7q10b_5 if s7q10_0__5==1 & (s7q10b_5!=. & s7q10b_5!=.a)
* Otros gastos
gen otros_gastos_m=s7q10b_6 if s7q10_0__6==1 & (s7q10b_6!=. & s7q10b_6!=.a)

*** Educational attainment
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
*/
clonevar nivel_educ_en = s7q11 if s7q1==1 & (s7q11!=. & s7q11!=.a) & edad>3
/* NIVEL_EDUC: Comparable across years
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
*/
gen nivel_educ = 1 if nivel_educ_en==1
replace nivel_educ = 2 if nivel_educ_en==2 
replace nivel_educ = 3 if nivel_educ_en==3 | nivel_educ_en==5
replace nivel_educ = 4 if nivel_educ_en==4 | nivel_educ_en==6
replace nivel_educ = 5 if nivel_educ_en==7
replace nivel_educ = 6 if nivel_educ_en==8
replace nivel_educ = 7 if nivel_educ_en==9
label def nivel_educ 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
label value nivel_educ nivel_educ

*** Which was the last grade you completed?
/* G_EDUC (s7q11a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
gen     g_educ = s7q11a        if s7q1==1 & (s7q11==3 | s7q11==4 | s7q11==5 | s7q11==6) & (s7q11a!=. & s7q11a!=.a) & edad>3
replace g_educ=3               if s7q11a>3 & s7q11==4

*** Cual era el regimen de estudios
* REGIMEN (s7q11ba): El regimen de estudios era anual, semestral o trimestral?
clonevar regimen = s7q11ba if s7q1==1 & (s7q11>=7 & s7q11<=9) & (s7q11ba!=. & s7q11ba!=.a)

*** Which was the last year you completed?
/** A_EDUC (s7q4b): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
gen a_educ = s7q11b    if s7q1==1 & (s7q11==7 | s7q11==8 | s7q4==9) & s7q11ba==1 & (s7q11b!=. & s7q11b!=.a) //for those who study or studied tertiary education on annual basis, there are individuals in categories 4 and 6 who replied this question

*** Which was the last semester you completed?
/* S_EDUC (emhp27c): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
gen s_educ = s7q11c    if s7q1==1 & (s7q11==7 | s7q11==8 | s7q4==9) & s7q11ba==2 & (s7q11c!=. & s7q11c!=.a) //for those who study or studied tertiary education on biannual basis

*** Which was the last quarter you completed?
/* T_EDUC (emhp27d): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
gen t_educ = s7q11d    if s7q1==1 & (s7q11==7 | s7q11==8 | s7q4==9) & s7q11ba==3 & (s7q11d!=. & s7q11d!=.a) //for those who study or studied tertiary education on quarterly basis

***  Literacy
*Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
gen     alfabeto = 0 if nivel_educ!=.	
replace alfabeto = 1 if (nivel_educ==3 & (g_educ>=2 & g_educ<=9)) | (nivel_educ>=4 & nivel_educ<=7)
notes   alfabeto: variable defined for all individuals

/*
*** Obtuvo el titulo respectivo //missing in database
gen titulo = s7q11e==1 if s7q1==1 & (s7q11>=7 & s7q11<=9) 
*/

*** A que edad termini/dejo los estudios
gen edad_dejo_estudios = s7q12 if (s7q12!=. & s7q12!=.a)

*** Cual fue la principal razon por la que dejo los estudios?
/* RAZONES_ABAN_ESTUDIOS
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
clonevar razon_dejo_estudios= s7q13 if (s7q13!=. & s7q13!=.a)
recode razon_dejo_estudios (11 12=11) (13=12) (14=13) (15=14) (16=15), g(razon_dejo_est_comp)
label def razon_dejo_est_comp 1 "Terminó los estudios" 2 "Escuela distante" 3 "Escuela cerrada" 4 "Muchos paros/inasistencia de maestros" 5 "Costo de los útiles" 6 "Costo de los uniformes" ///
7 "Enfermedad/discapacidad" 8 "Tiene que trabajar" 9 "No quiso seguir estudiando" 10 "Inseguridad al asistir al centro educativo" 11 "Discriminación o violencia" ///
12 "Por embarazo/cuidar a los hijos" 13 "Tiene que ayudar en tareas del hogar" 14 "No lo considera importante" 15 "Otra"
label value razon_dejo_est_comp razon_dejo_est_comp

/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.?: Banking ---------------------------------------------------------------
************************************************************************************************************************************************)*/
global bank_ENCOVI contesta_ind_b quien_contesta_b cuenta_corr cuenta_aho tcredito tdebito nobanco ///
efectivo_f tcredito_f tdebito_f bancao_f pagomovil_f razon_nobanco

*** Section for individuals 15+
*** Is the "member" answering by himself/herself?
gen contesta_ind_b=s16q0 if (s16q0!=. & s16q0!=.a)

*** Who is answering instead of "member"?
gen quien_contesta_b=s16q00 if (s16q00!=. & s16q00!=.a)

*** Do you have in any bank the following?
* Checking account
gen cuenta_corr=s16q1__1 if (s16q1__1!=. & s16q1__1!=.a)
* Saving account
gen cuenta_aho=s16q1__2 if (s16q1__2!=. & s16q1__2!=.a)
* Credit card
gen tcredito=s16q1__3 if (s16q1__3!=. & s16q1__3!=.a)
* Debit card
gen tdebito=s16q1__4 if (s16q1__4!=. & s16q1__4!=.a)
* None
gen no_banco=s16q1__4 if (s16q1__4!=. & s16q1__4!=.a)

*** How often do you pay with cash ?
gen efectivo_f=s16q2 if (s16q2!=. & s16q2!=.a)

*** How often do you pay with credit card ?
gen tcredito_f=s16q3 if (s16q3!=. & s16q3!=.a)

*** How often do you pay with debit card ?
gen tdebito_f=s16q4 if (s16q4!=. & s16q4!=.a)

*** How often do you pay using online bank?
gen bancao_f=s16q5 if (s16q5!=. & s16q5!=.a)

*** How often do you use mobile payment?
gen pagomovil_f=s16q7 if (s16q7!=. & s16q7!=.a)

*** Reasons for not holding any bank account or card?
gen razon_nobanco=s16q7 if (s16q7!=. & s16q7!=.a)
;
/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- 1.?: Shocks afecting households ---------------------------------------------------------------
************************************************************************************************************************************************)*/
global shocks_ENCOVI

*** Who is the informant in this section?
gen contesta_ind_b=s15q00 if (s15q00!=. & s15q00!=.a)

*** Which of the following events have affected to yor household
/* "1.Muerte o discapacidad de un
miembro adulto del hogar que
trabajaba
2.Muerte de alguien que enviaba
remesas al hogar
3.Enfermedad de la persona con el
ingreso más importante del hogar
4.Pérdida de un contacto importante
 5.Perdida de trabajo de la persona con
el ingreso más importante del hogar
6.Salida del miembro del hogar que
generaba ingresos debido a
separación/divorcio
7.Salida del miembro de la familia que
generaba ingresos debido al
matrimonio
8.Salida de un miembro del hogar que
generaba ingresos por emigración
9.Fracaso empresarial no
agrícola/cierre de negocio o
emprendimiento
10.Robo de cultivos, dinero en efectivo,
ganado u otros bienes
11.Pérdida de cosecha por
incendio/sequía/inundaciones
12.Invasión de plagas que causó el
fracaso de la cosecha o la pérdida de
almacenamiento
13.Vivienda dañada / demolida
14.Pérdida de propiedad por incendio o
inundación
15.Pérdida de tierras
16.Muerte de ganado por enfermedad"
*/
forv i=1/16{
gen evento_`i'= s15q1__`i' if (s15q1__`i'!=. & s15q1__`i'!=.a) 
}
label var evento_1 "Death or disability of a employed household member"
label var evento_2 "Death of a household member sending remittances"
label var evento_3 "Illness of the main earner"
label var evento_4 "Loss of an important contact"
label var evento_5 "Loss of work of the person with the most important household incomet"
label var evento_6 "Departure of the household member who generated income due to separation / divorce"
label var evento_7 "Departure of the family member who generated income due to marriage"
label var evento_8 "Departure of a household member who generated income due to emigration"
label var evento_9 "Non-agricultural business failure/closure of business or entrepreneurship "
label var evento_10 "Theft of crops, cash,livestock or other property"
label var evento_11 "Loss of harvest due to fire / drought / flood"
label var evento_12 "Invasion of pests that caused loss of harvest or loss of storage"
label var evento_13 "Damaged / demolished dwelling"
label var evento_14 "Loss of property due to fire or flood"
label var evento_15 "Loss of land"
label var evento_16 "Death of cattle due to disease"

/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 1.?: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global emigracion informant_emig hogar_emig numero_emig nombre_emig_0 nombre_emig_1 nombre_emig_2 nombre_emig_3 nombre_emig_4 nombre_emig_5 nombre_emig_6 nombre_emig_7 nombre_emig_8 nombre_emig_9 edad_emig_1 edad_emig_2 edad_emig_3 edad_emig_4 edad_emig_5 edad_emig_6 edad_emig_7 edad_emig_8 edad_emig_9 edad_emig_10 sexo_emig_1 sexo_emig_2 sexo_emig_3 sexo_emig_4 sexo_emig_5 sexo_emig_6 sexo_emig_7 sexo_emig_8 sexo_emig_9 sexo_emig_10


*--------- Informant in this section
 /* Informante (s10q00): 00. Quién es el informante de esta sección?
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
 */
	*-- Check values
	tab s10q00, mi
	*-- Standarization of missing values
	replace s10q00=. if s10q00==.a
	*-- Create auxiliary variable
	clonevar informant_ref = s10q00
	*-- Generate variable
	gen     informant_emig  = 1		if  informant_ref==1
	replace informant_emig  = 2		if  informant_ref==2
	replace informant_emig  = 3		if  informant_ref==3  | informant_ref==4
	replace informant_emig  = 4		if  informant_ref==5  
	replace informant_emig  = 5		if  informant_ref==6 
	replace informant_emig  = 6		if  informant_ref==7
	replace informant_emig  = 7		if  informant_ref==8  
	replace informant_emig  = 8		if  informant_ref==9
	replace informant_emig  = 9		if  informant_ref==10
	replace informant_emig  = 10	if  informant_ref==11
	replace informant_emig  = 11	if  informant_ref==12
	replace informant_emig  = 12	if  informant_ref==13
	
	*-- Label variable
	label var informant_emig "Informant: Emigration"
	*-- Label values	
	label def informant_emig  1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" ///
							  4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)"  6 "Padre, madre" 7 "Hermano(a)" ///
							  8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" ///
							  12 "Servicio Domestico"	
	label value informant_emig  informant_emig 


*--------- Emigrant from the household
 /* Emigrant(s10q1): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 */
	*-- Check values
	tab s10q1, mi
	*-- Standarization of missing values
	replace s10q1=. if s10q1==.a
	*-- Generate variable
	clonevar hogar_emig = s10q1
	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 2 "No"
	label value hogar_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(s10q2): 2. Cuántas personas?
 
 */
	*-- Check values
	tab s10q2, mi
	*-- Standarization of missing values
	replace s10q2=. if s10q2==.a
	*-- Generate variable
	clonevar numero_emig = s10q2
	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	*-- Cross check
	tab numero_emig hogar_emig, mi
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household(s10q2a): 2. Cuántas personas?
        
 */	
	*-- From s10q2a__0 to s10q2a__9 there is information on the names of emigrants
	*-- Drop from s10q2a__10 to s10q2a__59 (repeated variables)
	forval i = 10/59{
	drop s10q2a__`i'
	}
	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 0/9{
	*-- Standarization of missing values
	replace s10q2a__`i'="" if s10q2a__`i'=="##N/A##"
	tab s10q2a__`i', mi
	*-- Generate variable
	clonevar nombre_emig_`i' = s10q2a__`i'
	*-- Label variable
	label var nombre_emig_`i' "Name of Emigrants from the household"
	}

	*-- Cross check
	forval i = 0/9{
	tab nombre_emig_`i' hogar_emig
	}
	
	
 *--------- Age of the emigrant
 /* Age of the emigrant(s10q3): 3. Cuántos años cumplidos tiene X?
        
 */
 	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q3`i' s10q3_`i'
	*-- Label original variable
	label var s10q3_`i' "3.Cuántos años cumplidos tiene X?"
	*-- Standarization of missing values
	replace s10q3_`i'=. if s10q3_`i'==.a
		*-- Generate variable
		clonevar edad_emig_`i' = s10q3_`i'
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		*-- Cross check
		tab edad_emig_`i' hogar_emig
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (s10q4): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q4`i' s10q4_`i'
	*-- Label original variable
	label var s10q4_`i' "4. El sexo de X es?"
	*-- Standarization of missing values
	replace s10q4_`i'=. if s10q4_`i'==.a
		*-- Generate variable
		clonevar sexo_emig_`i' = s10q4_`i'
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i' 1 "Male" 2 "Female"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		


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
	/* s8q18: ¿Con cuál seguro médico está afiliado? 
		1 = Instituto Venezolano de los Seguros Sociales (IVSS)
	    2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
	    3 = Seguro medico contratado por institucion publica
	    4 = Seguro medico contratado por institucion privada
	    5 = Seguro medico privado contratado de forma particular
	 */
		
	/*  0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
        1 = si esta afiliado a algun seguro de salud privado
	*/
	
gen afiliado_seguro_salud = 1     if s8q18==1 
replace afiliado_seguro_salud = 2 if s8q18==2 
replace afiliado_seguro_salud = 3 if s8q18==3 
replace afiliado_seguro_salud = 4 if s8q18==4
replace afiliado_seguro_salud = 5 if s8q18==5
replace afiliado_seguro_salud = 6 if s8q17==2
label define afiliado_seguro_salud 1 "Instituto Venezolano de los Seguros Sociales (IVSS)" 2 "Instituto de prevision social publico (IPASME, IPSFA, otros)" ///
3 "Seguro medico contratado por institucion publica" 4 "Seguro medico contratado por institucion privada" 5 "Seguro medico privado contratado de forma particular" ///
6 "No tiene plan de seguro de atencion medica"

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
        1 = Empleado en el sector publico
		2 = Obrero en el sector publico
		3 = Empleado en empresa privada
		4 = Obrero en empresa privada
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

* Duracion del desempleo: durades (en meses)
	/* DILIGENCIAS_BT (s9q8): ¿Cuándo fue la ultima vez que hizo diligencias para conseguir trabajo o establecer un negocio solo o asociado?
			1 = En los últimos 2 meses
			2 = En los últimos 12 meses
			3 = Hace mas de un año
			4 = No hizo diligencias
	*/
	gen diligencias_bt = s9q8 if (s9q6==2 & s9q7==2 & s9q3==2 & s9q1==2 & s9q2==3)

	gen     durades = 0   if relab==5
	replace durades = 1   if relab==5 & diligencias_bt==1
	replace durades = 6 if relab==5 & diligencias_bt==2
	replace durades = 13  if relab==5 & diligencias_bt==3 
	*Assumption: we complete with 13 months when more than 12 months

* Horas trabajadas totales y en ocupacion principal: hstrt y hstrp

	* s9q18: ¿Cuántas horas trabaja a la semana en todos sus trabajos o negocios?
	gen      hstrt = . 
	replace  hstrt = s9q18 if (relab>=1 & relab<=4) & (s9q18>=0 & s9q18!=.) & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //the last parenthesis means being economically active

	* s9q16: ¿Cuántas horas trabajó durante la semana pasada en su ocupación principal?
	gen      hstrp = . 
	replace  hstrp = s9q16 if (relab>=1 & relab<=4) & (s9q16>=0 & s9q16!=.) & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //the last parenthesis means being economically active

	*Problem: it should not be possible but there is at least one case in which the total hours worked appears to be greater than the hours worked for the main job

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
	/* DMASHORAS (s9q31): ¿Preferiria trabajar mas de 35 horas por semana?
	   BMASHORAS (s9q32): ¿Ha hecho algo parar trabajar mas horas?
	   CAMBIO_EMPLEO (s9q34): ¿Ha cambiado de trabajo durante los últimos meses?
	*/
	gen dmashoras = s9q31 if s9q18<35 // Only asked if capi4==true, i.e. s9q18<35 , worked less than 35 hs -> worked part-time
	gen bmashoras = s9q32 if s9q18<35 // Only asked if capi4==true, i.e. s9q18<35 , worked less than 35 hs -> worked part-time
	*Assumption: only part-time workers can want to work more
	
	gen cambio_empleo = s9q34 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) //what comes after the "if" means being economically active

	gen     deseamas = 0 if (relab>=1 & relab<=4)
	replace deseamas = 1 if dmashoras==1 | bmashoras==1 

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
	gen firm_size = .
	notes firm_size: the survey does not include information to define this variable

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
gen     dsegsale = (afiliado_seguro_salud==3 | afiliado_seguro_salud==4) if relab==2

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

/* * For those not self-employed or employers (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9)
		* MONETARY PAYMENTS (s9q19__*): ¿Con respecto al mes pasado, recibió en todos sus trabajos o negocios ingresos por los siguientes conceptos? (each one is a dummy)
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
			12 = Otros bonos y compensaciones
		* MONTO (s9q19a_*): Amount received (1 variable for each of the 12 options)
		* CURRENCY (s9q19b_*): Currency (1 variable for each of the 12 options) 

		* MONETARY PAYMENTS (s9q28_petro): Received payment through Petro (mostly for aguinaldo) // Added in the last questionnaire update
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

/*  * For those not self-employed or employers (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9)
		* BENEFITS / NON-MONETARY PAYMENTS (s9q21__*): ¿Con respecto al mes pasado, recibió alguno de los siguientes beneficios en su trabajo u otros empleos? 
			1 = Alimentación
			2 = Productos de la empresa
			3 = Transporte
			4 = Vehículo para uso privado
			5 = Exoneración del pago de estacionamiento
			6 = Teléfono personal
			7 = Servicios básicos de vivienda
			8 = Guardería del trabajo
			9 = Otros beneficios
		* MONTO (s9q21a_*): Amount received, or estimation of how much they would have paid for the benefit (1 variable for each of the 9 options)
		* CURRENCY (s9q21b_*): Currency (1 variable for each of the 9 options)
		
	* For employers (s9q15==5)	
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

*Para Lautaro:
	histogram ipcf if ipcf!=0 & ipcf<=20000000
	histogram ipcf if ipcf!=0 & interview_month==2 & ipcf<=20000000
	
stop - hasta acá llegó MA. Ver labels!

include "$rootpath\data_management\management\2. harmonization\aux_do\labels.do"
compress


/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables a Documentar Base de Datos CEDLAS --------------
*************************************************************************************************************************************************)*/
sort id com
order $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $bank_ENCOVI
keep $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $bank_ENCOVI

save "$pathout\ENCOVI_2019.dta", replace

