/*===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Trinidad Saavedra, Lautaro Chittaro, Julieta Ladronis

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
		global juli   1
		
		* User 3: Lautaro
		global lauta  0	
		
		* User 4: Malena
		global male   0
		
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN"
				global dataout 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned"
		}
	    if $lauta {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
				global dataout 	"C:\Users\wb563365\GitHub\VEN\data_management\output\cleaned"
				//"C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN" 
				global dataout 	PONGAN ONE DRIVE PORQUE YA ES MUY PESADA (VER ABAJO EN MALE)
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN"
				global dataout "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned"
		}

		
// Set paths
global dataofficial "$rootpath\data_management\output\merged"
global input "$rootpath\data_management\input"

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

*** 0.0 To take everything to bolívares of Feb 2020 (month with greatest sample) ***
		
		* Deflactor
			*Source: Inflacion verdadera http://www.inflacionverdadera.com/venezuela/
			
			*use "$rootpath\data_management\output\cleaned\inflacion\InflacionVerdadera_04-09-20.dta", clear
			*use "$rootpath\data_management\output\cleaned\inflacion\Inflacion_PARA NOMINAL.dta", clear
			use "$rootpath\data_management\output\cleaned\inflacion\inflacion_canasta_alimentos_diaria_precios_implicitos.dta", clear
			*use "$rootpath\data_management\output\cleaned\inflacion\Inflacion_Asamblea Nacional.dta", clear

			
			forvalues j = 10(1)12 {
				sum indice if mes==`j' & ano==2019
				local indice`j' = r(mean) 			
				}
			forvalues j = 1(1)4 {
				sum indice if mes==`j' & ano==2020
				display r(mean)
				local indice`j' = r(mean)				
				}
				
			// if we consider that incomes are earned in the previous month than the month of the interview use this
						local deflactor11 `indice2'/`indice10'
						local deflactor12 `indice2'/`indice11'
						local deflactor1 `indice2'/`indice12'
						local deflactor2 `indice2'/`indice1'
						local deflactor3 `indice2'/`indice2'
						local deflactor4 `indice2'/`indice3'
						
						display `deflactor11'
						display `deflactor4'
						
			// if we consider that incomes are earned in the same month than the survey is collected use this
			// 			local deflactor11 `indice2'/`indice11'
			// 			local deflactor12 `indice2'/`indice12'
			// 			local deflactor1 `indice2'/`indice1'
			// 			local deflactor2 `indice2'/`indice2'
			// 			local deflactor3 `indice2'/`indice3'
			//			local deflactor4 `indice2'/`indice4'

		* Exchange Rates / Tipo de cambio
			*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
			local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
			local meses 1 2 3 4 10 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march, 4=april
			
			use "$rootpath\data_management\management\1. merging\exchange rates\exchenge_rate_price.dta", clear
			
		// if we consider that incomes are earned one month previous to data collection use this			
					destring mes, replace
					foreach i of local monedas {
						foreach j of local meses {
							if `j' !=12 {
							  local k=`j'+1
							 }
							else {
							  local k=1 // if the month is 12 we send it to month 1
							}
							sum mean_moneda	if moneda==`i' & mes==`j' // if we pick ex rate of month=2
							local tc`i'mes`k' = r(mean)
							display `tc`i'mes`k''
							}
						}

		// if we consider that incomes are earned the same month as data is collected use this
		// 			destring mes, replace
		// 			foreach i of local monedas {
		// 				foreach j of local meses {
		// 					sum mean_moneda	if moneda==`i' & mes==`j'
		// 					local tc`i'mes`j' = r(mean)
		// 				}
		// 			}

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
*----------------------------------------	II. Interview Control / Control de la entrevista  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global control_ent entidad region_est1 municipio nombmun parroquia nombpar centropo nombcp segmento peso_segmento combined_id tipo_muestra gps* id_str statut sector_urb 

rename sample_type tipo_muestra
rename segment_weight peso_segmento
rename sector sector_urb
rename gps_struc__latitude 	gps_struc_latitud
rename gps_struc__longitude	gps_struc_longitud
rename gps_struc__accuracy 	gps_struc_exactitud
rename gps_struc__altitude 	gps_struc_altitud
rename gps_struc__timestamp	gps_struc_tiempo
rename gps_coordenadas__latitude 	gps_coord_latitud
rename gps_coordenadas__longitude 	gps_coord_longitud
rename gps_coordenadas__accuracy 	gps_coord_exactitud
rename gps_coordenadas__altitude 	gps_coord_altitud
rename gps_coordenadas__timestamp	gps_coord_tiempo

* We identify interview_month for the observations with missing
gen string_interview_month = substr(s4_start,6,2)
gen new_interview_month = real(string_interview_month)
replace interview_month = new_interview_month if (interview_month==.a | interview_month==.)

// this is only to test wha
//drop if interview month is november
// drop if interview_month==11

gen     region_est1 =  1 if entidad==5 | entidad==8 | entidad==9                   //Region Central
replace region_est1 =  2 if entidad==12 | entidad==4                               // Region de los LLanos
replace region_est1 =  3 if entidad==11 | entidad==13 | entidad==18 | entidad==22  // Region Centro-Occidental
replace region_est1 =  4 if entidad==23                                            // Region Zuliana
replace region_est1 =  5 if entidad==6 | entidad==14 | entidad==20 | entidad==21   // Region de los Andes
replace region_est1 =  6 if entidad==3 | entidad==16 | entidad==19                 // Region Nor-Oriental
replace region_est1 =  7 if entidad==17 | entidad==25                              // Region Insular
replace region_est1 =  8 if entidad==7 | entidad==2 | entidad==10                  // Region Guayana
replace region_est1 =  9 if entidad==15 | entidad==24 | entidad==1                 // Region Capital
label var region_est1 "Region"
label def region_est1 1 "Region Central"  2 "Region de los LLanos" 3 "Region Centro-Occidental" 4 "Region Zuliana" ///
          5 "Region de los Andes" 6 "Region Nor-Oriental" 7 "Insular" 8 "Guayana" 9 "Capital"
label value region_est1 region_est1

/*(************************************************************************************************************************************************* 
*-------------------------------	III Household determination / Determinacion de hogares  -------------------------------------------------------
*************************************************************************************************************************************************)*/
global det_hogares npers_viv comparte_gasto_viv npers_gasto_sep npers_gasto_comp

* Cuántas personas residen actualmente en esta vivienda?
clonevar npers_viv=s3q1 if s3q1!=. & s3q1!=.a
* Todas las personas que viven en esta vivienda comparten gastos para la compra de comida?
gen comparte_gasto_viv=(s3q2==1) if s3q2!=. & s3q2!=.a
* Cuántos grupos de personas mantienen gastos separados para la compra de comida?
clonevar npers_gasto_sep=s3q3 if s3q3!=. & s3q3!=.a
* Cuántas personas, contándose a usted, comparten gastos para la compra de comida? Este grupo de personas conforma su HOGAR.
clonevar npers_gasto_comp=s3q4 if s3q4!=. & s3q4!=.a

/*(************************************************************************************************************************************************* 
*-----------------------------------------	1.1: Identification Variables / Variables de identificación --------------------------------------------
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
		gen edad = s6q5 if (s6q5!=. & s6q5!=.a)
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
*------------------------------------------	1.2: Demographic variables  / Variables demográficas --------------------------------------------------
*************************************************************************************************************************************************)*/
global demo_ENCOVI relacion_en relacion_comp hombre edad anio_naci mes_naci dia_naci pais_naci residencia resi_estado resi_municipio razon_cambio_resi razon_cambio_resi_o pert_2014 razon_incorp_hh razon_incorp_hh_o ///
certificado_naci cedula razon_nocertificado razon_nocertificado_o estado_civil_en estado_civil hijos_nacidos_vivos hijos_vivos anio_ult_hijo mes_ult_hijo dia_ult_hijo

*** Relation to the head:
/* Categories of the new harmonized variable: relacion_comp
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
gen hombre = sexo==1 if sexo!=.

*** Age
* EDAD_ENCUESTA (s6q5): Cuantos años cumplidos tiene?
notes   edad: range of the variable: 0-97
*clonevar edad = s6q5 if (s6q5!=. & s6q5!=.a)

*** Year of birth
clonevar anio_naci = s6q4_year if (s6q4_year!=. & s6q4_year!=.a & s6q4_year!=9999 & s6q4_year!=9 ) 

*** Month of birth
clonevar mes_naci = s6q4_month if (s6q4_month!=. & s6q4_month!=.a & s6q4_month!=9999) 

*** Day of birth
clonevar dia_naci = s6q4_day if (s6q4_day!=. & s6q4_day!=.a & s6q4_day!=9999) 

*** Country of birth
clonevar pais_naci = s6q6 if (s6q6!=. & s6q6!=.a)

*** In September 2018 where do you reside?
clonevar residencia = s6q7 if (s6q7!=. & s6q7!=.a)

*** In which state did you reside in September 2018?
clonevar resi_estado = s6q7a if (s6q7a!=. & s6q7a!=.a)

*** In which county did you reside in September 2018?
clonevar resi_municipio = s6q7b if (s6q7b!=. & s6q7b!=.a)

*** Which was the main reason for moving to another residency?
clonevar razon_cambio_resi = s6q7c if (s6q7c!=. & s6q7c!=.a)
replace  razon_cambio_resi = . if s6q7b==.

*** Specify others
clonevar razon_cambio_resi_o = s6q7d if s6q7c==7

*** Are you part of this household since the last 5 years?
gen pert_2014 = (s6q8==1) if (s6q8!=. & s6q8!=.a)

*** Reason for incorporating to the household
clonevar razon_incorp_hh = s6q9 if (s6q9!=. & s6q9!=.a) & s6q8==1

*** Other reason
clonevar razon_incorp_hh_o = s6q9_os if s6q9==12

*** Birth certificate
gen certificado_naci = (s6q10==1) if (s6q10!=. & s6q10!=.a) & s6q5<18

*** ID card
gen cedula = (s6q11==1) if (s6q11!=. & s6q11!=.a)

*** Reasons for not having birth certificate
clonevar razon_nocertificado = s6q12 if (s6q12!=. & s6q12!=.a) & s6q10==2

*** Other reason
clonevar razon_nocertificado_o = s6q12_os if (s6q12!=. & s6q12!=.a) & s6q12==7

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
* estado_civil
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
clonevar     hijos_nacidos_vivos = s6q14 if (s6q14!=. & s6q14!=.a)

*** From the total of sons/daughters born alive, how many are currently alive?
clonevar     hijos_vivos = s6q15 if s6q14!=0 & s6q15<=s6q14 & (s6q15!=. & s6q15!=.a)

*** Which year was your last son/daughter born?
gen     anio_ult_hijo = s6q16a if s6q14!=0 & (s6q16a!=9999 & s6q16a!=. & s6q16a!=.a)
replace anio_ult_hijo = 2005 if anio_ult_hijo==20005
replace anio_ult_hijo = 2011 if anio_ult_hijo==20011
replace anio_ult_hijo = 2013 if anio_ult_hijo==20013
replace anio_ult_hijo = 2017 if anio_ult_hijo==20017
replace anio_ult_hijo = 2012 if anio_ult_hijo==212
replace anio_ult_hijo = s6q16c if s6q16c>31 &  s6q16c!=. & s6q16c!=.a & s6q16c!=9999 //wronly codified in day
replace anio_ult_hijo = . if s6q16a<1000

*** Which month was your last son/daughter born?
clonevar	mes_ult_hijo = s6q16b if s6q14!=0 & (s6q16b!=9999)

*** Which day was your last son/daughter born?
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
pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m danio_electrodom tenencia_vivienda_comp

*** Type of flooring material
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas 
*/
clonevar  material_piso = s4q1            if (s4q1!=. & s4q1!=.a)	

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
clonevar  material_pared_exterior = s4q2  if (s4q2!=. & s4q2!=.a)

*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
*/
clonevar  material_techo = s4q3           if (s4q3!=. & s4q3!=.a)

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
label def frecuencia_agua 1 "Todos los dias" 2 "Algunos dias de la semana" ///
		3 "Una vez por semana" ///
		4 "Una vez cada 15 dias" ///
		5 "Nunca"
label val frecuencia_agua frecuencia_agua
*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/
clonevar serv_elect_red_pub=s4q7__1 if s4q7__1!=. & s4q7__1!=.a
clonevar serv_elect_planta_priv=s4q7__2 if s4q7__2!=. & s4q7__2!=.a
clonevar serv_elect_otro=s4q7__3 if s4q7__3!=. & s4q7__3!=.a
gen electricidad= (s4q7__1==1 | s4q7__2==1 | s4q7__3==1)  if (s4q7__1!=. & s4q7__1!=.a & s4q7__2!=. & s4q7__2!=.a & s4q7__3!=. & s4q7__3!=.a)
* tab s4q7__4

tab serv_elect_red_pub
tab serv_elect_planta_priv
tab serv_elect_otro
tab electricidad

*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
*/
clonevar interrumpe_elect = s4q8 if (s4q8!=. & s4q8!=.a)
tab interrumpe_elect 
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
label def tipo_sanitario_comp 1 "Poceta a cloaca/Pozo septico" 2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" 4 "No tiene poseta o excusado"
label value tipo_sanitario_comp tipo_sanitario_comp

*** Number of rooms used exclusively to sleep
* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
clonevar ndormi= s5q1 if (s5q1!=. & s5q1!=.a) //up to 9
replace ndormi=. if s5q1>20

*** Bath with shower 
* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
clonevar banio_con_ducha = s5q2 if (s5q2!=. & s5q2!=.a)
replace banio_con_ducha = 1 if (s5q2==1) 
replace banio_con_ducha = 0 if (s5q2==2)
label def banio_con_ducha 1 "Si" 0 "No"
label val banio_con_ducha banio_con_ducha

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
clonevar pago_alq_mutuo=s5q8a if s5q8a!=. & s5q8a!=.a

*** In which currency did you make the payment?
clonevar pago_alq_mutuo_mon=s5q8b if s5q8b!=. & s5q8b!=.a

*** In which month did you make the payment?
clonevar pago_alq_mutuo_m=s5q8c if s5q8c!=. & s5q8c!=.a

*** During the last year, have you had arrears in payments?
clonevar atrasos_alq_mutuo=s5q9 if s5q9!=. & s5q9!=.a
replace atrasos_alq_mutuo=1 if s5q9==1
replace atrasos_alq_mutuo=0 if s5q9==2
*Label values
label def sino 1 "Si" 0 "No"
label val atrasos_alq_mutuo sino

*** What consequences did the arrears in payments had?
clonevar implicancias_nopago=s5q10 if s5q10!=. & s5q10!=.a

*** If you had to rent similar dwelling, how much did you think you should pay?
clonevar renta_imp_en=s5q11 if s5q11!=. & s5q11!=.a

*** In which currency ?
clonevar renta_imp_mon=s5q11a if s5q11a!=. & s5q11a!=.a

*** What type of property title do you have?
clonevar titulo_propiedad=s5q12 if s5q12!=. & s5q12!=.a

*** What are the main sources of drinking water in your household?
* Acueducto
clonevar fagua_acueduc=s5q13__1 if s5q13__1!=. & s5q13__1!=.a
* Pila o estanque
clonevar fagua_estanq=s5q13__2 if s5q13__2!=. & s5q13__2!=.a
* Camión cisterna
clonevar fagua_cisterna=s5q13__3 if s5q13__3!=. & s5q13__3!=.a
* Pozo con bomba
clonevar fagua_bomba=s5q13__4 if s5q13__4!=. & s5q13__4!=.a
* Pozo protegido
clonevar fagua_pozo=s5q13__5 if s5q13__5!=. & s5q13__5!=.a
* Aguas superficiales (manantial,río, lago, canal de irrigación)
clonevar fagua_manantial=s5q13__6 if s5q13__6!=. & s5q13__6!=.a
* Agua embotellada
clonevar fagua_botella=s5q13__7 if s5q13__7!=. & s5q13__7!=.a
* Otros
clonevar fagua_otro=s5q13__8 if s5q13__8!=. & s5q13__8!=.a

label def aqua 0 "Otra" 1 "Primera (1)" 2 "Segunda (2)" 3 "Tercera(3)" 
label val fagua_acueduc aqua
label val fagua_estanq aqua
label val fagua_cisterna aqua
label val fagua_bomba aqua
label val fagua_pozo aqua
label val fagua_manantial aqua
label val fagua_botella aqua
label val fagua_otro aqua

*** In your household, is the water treated to make it drinkable
clonevar tratamiento_agua= s5q14 if s5q14!=. & s5q14!=.a
replace tratamiento_agua= 1 if s5q14==1
replace tratamiento_agua= 0 if s5q14==2
* Label values
label def tratamiento_agua 1 "Si" 0 "No"
label val tratamiento_agua tratamiento_agua


*** How do you treat the water to make it more safe for drinking
clonevar tipo_tratamiento=s5q15 if s5q15!=. & s5q15!=.a

*** Which type of fuel do you use for cooking?
clonevar comb_cocina=s5q16 if s5q16!=. & s5q16!=.a

*** Did you pay for the following utilities?
* Water
clonevar pagua=s5q17__1 if s5q17__1!=. & s5q17__1!=.a 
* Electricity
clonevar pelect=s5q17__2 if s5q17__2!=. & s5q17__2!=.a
replace pelect=1 if s5q17__2==1 
replace pelect=0 if s5q17__2==2

* Gas
clonevar pgas=s5q17__3 if s5q17__3!=. & s5q17__3!=.a
replace pgas=1 if s5q17__3==1
replace pgas=0 if s5q17__3==2

* Carbon, wood
clonevar pcarbon=s5q17__4 if s5q17__4!=. & s5q17__4!=.a
replace pcarbon=1 if s5q17__4==1
replace pcarbon=0 if s5q17__4==2

* Paraffin
clonevar pparafina=s5q17__5 if s5q17__5!=. & s5q17__5!=.a
replace pparafina=1 if s5q17__5==1
replace pparafina=0 if s5q17__5==2

* Landline, internet and tv cable
gen ptelefono=(s5q17__7==1) if s5q17__7!=. & s5q17__7!=.a

*** How much did you pay for the following utilities?
clonevar pagua_monto=s5q17a1 if s5q17a1!=. & s5q17a1!=.a 
* Electricity
clonevar pelect_monto=s5q17a2 if s5q17a2!=. & s5q17a2!=.a
* Gas
clonevar pgas_monto=s5q17a3 if s5q17a3!=. & s5q17a3!=.a
* Carbon, wood
clonevar pcarbon_monto=s5q17a4 if s5q17a4!=. & s5q17a4!=.a
* Paraffin
clonevar pparafina_monto=s5q17a5 if s5q17a5!=. & s5q17a5!=.a
* Landline, internet and tv cable
clonevar ptelefono_monto=s5q17a7 if s5q17a7!=. & s5q17a7!=.a

*** In which currency did you pay for the following utilities?
clonevar pagua_mon=s5q17b1 if s5q17b1!=. & s5q17b1!=.a 
* Electricity
clonevar pelect_mon=s5q17b2 if s5q17b2!=. & s5q17b2!=.a
* Gas
clonevar pgas_mon=s5q17b3 if s5q17b3!=. & s5q17b3!=.a
* Carbon, wood
clonevar pcarbon_mon=s5q17b4 if s5q17b4!=. & s5q17b4!=.a
* Paraffin
clonevar pparafina_mon=s5q17b5 if s5q17b5!=. & s5q17b5!=.a
* Landline, internet and tv cable
clonevar ptelefono_mon=s5q17b7 if s5q17b7!=. & s5q17b7!=.a

*** In which month did you pay for the following utilities?
clonevar pagua_m=s5q17c1 if s5q17c1!=. & s5q17c1!=.a 
* Electricity
clonevar pelect_m=s5q17c2 if s5q17c2!=. & s5q17c2!=.a
* Gas
clonevar pgas_m=s5q17c3 if s5q17c3!=. & s5q17c3!=.a
* Carbon, wood
clonevar pcarbon_m=s5q17c4 if s5q17c4!=. & s5q17c4!=.a
* Paraffin
clonevar pparafina_m=s5q17c5 if s5q17c5!=. & s5q17c5!=.a
* Landline, internet and tv cable
clonevar ptelefono_m=s5q17c7 if s5q17c7!=. & s5q17c7!=.a

*** In your household, have any home appliences damaged due to blackouts or voltage inestability?
clonevar danio_electrodom=s5q20 if s5q20!=. & s5q20!=.a
replace danio_electrodom=1 if s5q20==1
replace danio_electrodom=0 if s5q20==2

foreach x in $dwell_ENCOVI {
replace `x'=. if relacion_en!=1
}

/*(************************************************************************************************************************************************* 
*----------------------------------------------- 1.5: Durables goods  / Bienes durables --------------------------------------------------------
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
* Fix missing values 
replace s5q5 = . if s5q5==0 & s5q4==1
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
*------------------------------------------------------ VII. EDUCATION / EDUCACIÓN -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI contesta_ind_e quien_contesta_e asistio_educ razon_noasis asiste nivel_educ_act g_educ_act regimen_act a_educ_act s_educ_act t_educ_act edu_pub ///
fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
pae pae_frecuencia pae_desayuno pae_almuerzo pae_meriman pae_meritard pae_otra ///
cuota_insc compra_utiles compra_uniforme costo_men costo_transp otros_gastos ///
cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto ///
cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon ///
cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m ///
nivel_educ_en nivel_educ g_educ regimen a_educ s_educ t_educ alfabeto /*titulo*/ edad_dejo_estudios razon_dejo_estudios razon_dejo_est_comp

*** Is the "member" answering by himself/herself?
gen contesta_ind_e=s7q0 if (s7q0!=. & s7q0!=.a)
replace contesta_ind_e=0 if s7q0==2

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
gen asiste= s7q3==1 if (s7q3!=. & s7q3!=.a) & edad>=3
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
clonevar cuota_insc_mon=s7q10b_1 if s7q10_0__1==1 & (s7q10b_1!=. & s7q10b_1!=.a)
* Compra de útiles y libros escolares
clonevar compra_utiles_mon=s7q10b_2 if s7q10_0__2==1 & (s7q10b_2!=. & s7q10b_2!=.a)
* Compra de uniformes y calzados escolares
clonevar compra_uniforme_mon=s7q10b_3 if s7q10_0__3==1 & (s7q10b_3!=. & s7q10b_3!=.a)
* Costo de la mensualidad
clonevar costo_men_mon=s7q10b_4 if s7q10_0__4==1 & (s7q10b_4!=. & s7q10b_4!=.a)
* Uso de transporte público o escolar
clonevar costo_transp_mon=s7q10b_5 if s7q10_0__5==1 & (s7q10b_5!=. & s7q10b_5!=.a)
* Otros gastos
clonevar otros_gastos_mon=s7q10b_6 if s7q10_0__6==1 & (s7q10b_6!=. & s7q10b_6!=.a)

*** Mes en que se realizo el pago
clonevar cuota_insc_m=s7q10c_1 if s7q10_0__1==1 & (s7q10c_1!=. & s7q10c_1!=.a)
* Compra de útiles y libros escolares
clonevar compra_utiles_m=s7q10c_2 if s7q10_0__2==1 & (s7q10c_2!=. & s7q10c_2!=.a)
* Compra de uniformes y calzados escolares
clonevar compra_uniforme_m=s7q10c_3 if s7q10_0__3==1 & (s7q10c_3!=. & s7q10c_3!=.a)
* Costo de la mensualidad
clonevar costo_men_m=s7q10c_4 if s7q10_0__4==1 & (s7q10c_4!=. & s7q10c_4!=.a)
* Uso de transporte público o escolar
clonevar costo_transp_m=s7q10c_5 if s7q10_0__5==1 & (s7q10c_5!=. & s7q10c_5!=.a)
* Otros gastos
clonevar otros_gastos_m=s7q10c_6 if s7q10_0__6==1 & (s7q10c_6!=. & s7q10c_6!=.a)

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
*------------------------------------------------------ VIII. HEALTH / SALUD ---------------------------------------------------------------------
************************************************************************************************************************************************)*/

global health_ENCOVI enfermo enfermedad enfermedad_o visita razon_no_medico razon_no_medico_o medico_o_quien medico_o_quien_o lugar_consulta lugar_consulta_o pago_consulta cant_pago_consulta mone_pago_consulta ///
	mes_pago_consulta receto_remedio recibio_remedio donde_remedio donde_remedio_o pago_remedio mone_pago_remedio mes_pago_remedio pago_examen cant_pago_examen ///
	mone_pago_examen mes_pago_examen remedio_tresmeses cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses seguro_salud ///
	afiliado_segsalud pagosegsalud quien_pagosegsalud cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud


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
clonevar enfermedad = s8q2 if (s8q1!=. & s8q1!=.a) & s8q1==1

*** Other
* Otro
clonevar enfermedad_o = s8q2_os if s8q1==1 & s8q2==14

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
clonevar	razon_no_medico = s8q4 if (s8q4!=. & s8q4!=.a) & (s8q1==1 & s8q3==2)

***Other
*Otra
clonevar	razon_no_medico_o = s8q4_os if s9q4==9

*** Who did you mainly consult to treat the sickness or accident?
/*	s8q5 ¿A quién consultó principalmente para tratar esta enfermedad síntoma o malestar y/o accidente?
	 	1 = Médico
		2 = Enfermera u otro auxiliar paramédico
		3 = Farmacéutico
		4 = Curandero, yerbatero o brujo
		5 = Otro 	*/
clonevar   medico_o_quien = s8q5 if (s8q5!=. & s8q5!=.a) & (s8q1==1 & s8q3==1)

***Other
*Otro
clonevar medico_o_quien_o = s8q5_os if (s8q1==1 & s8q3==1) & s8q5==5

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
clonevar lugar_consulta = s8q6 if (s8q6!=. & s8q6!=.a) & (s8q1==1 & s8q3==1)

***Other
*Otro
clonevar lugar_consulta_o = s8q6_os if (s8q1==1 & s8q3==1) & s8q6==8

*** Did you pay for consultation or healthcare attention?
/* 	s8q7 ¿Pagó por consultas o atención médica?: pago_consulta
	 	1 = si 
		2 = no  */
gen	pago_consulta = s8q7==1 & (s8q1==1 & s8q3==1) & (s8q7!=. & s8q7!=.a)

*** How much did you pay? 
* 	s8q8a ¿Cuánto pagó?: cant_pago_consulta
clonevar   	cant_pago_consulta = s8q8a if s8q1==1 & s8q3==1 & s8q7==1

*** In which currency did you pay?
/* 	s8q8b ¿En qué moneda realizó el pago?: mone_pago_consulta
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
clonevar	mone_pago_consulta = s8q8b if (s8q8b!=. & s8q8b!=.a) & (s8q1==1 & s8q3==1 & s8q7==1)

*** In which month did you pay?
/* 	s8q8c ¿En qué mes pagó?: mes_pago_consulta
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
clonevar	mes_pago_consulta = s8q8c if (s8q8c!=. & s8q8c!=.a) & (s8q1==1 & s8q3==1 & s8q7==1)
		
*** Did you get any medicine prescribed for the illness of accident?
/* s8q9 ¿Se recetó a algún medicamento para la enferemedad o accidente?: receto_remedio
		 	1 = Si
			2 = No */
gen     receto_remedio = s8q9==1 if (s8q1==1 & s8q3==1) & s8q9!=. & s8q9!=.a

*** How did you get the medicines?
/* s8q10 ¿Cómo obtuvo los medicamentos?: recibio_remedio
			1 = Los recibió todos gratis
			2 = Recibió algunos gratis y otros los compró
			3 = Los compró todos
			4 = Compró algunos
			5 = Recibió algunos gratis y los otros no pudo comprarlos
			6 = No pudo obtener ninguno */
clonevar 	recibio_remedio = s8q10 if (s8q1==1 & s8q9==1) & (s8q10!=. & s8q10!=.a) 

*** Where did you buy the medicines?
/* s8q11 ¿Dónde compró los medicamentos?
			1 = Boticas o farmacias populares
			2 = Otras farmacias comerciales
			3 = Institutos de Previsión Social u otras fundaciones (IPAS-ME, IPSFA, otros)
			4 = Otro	*/		
clonevar    donde_remedio = s8q11 if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)
	
***Other
* Otro
clonevar    donde_remedio_o = s8q11_os if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4) & s8q11==4

*** How much did you pay for the medicines?
* s8q12a ¿Cuánto pagó por los medicamentos?: pago_remedio
clonevar	pago_remedio = s8q12a if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)

*** In which currency did you pay for the medicines?
/* 	s8q12b ¿En qué moneda realizó el pago?: moneda_pago_remedio
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
clonevar   	mone_pago_remedio = s8q12b if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)

*** In which month did you pay for the medicines?
/* 	s8q12c ¿En qué mes pagó?: mes_pago_remedio
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
clonevar   	mes_pago_remedio = s8q12c if s8q1==1 & (s8q10==2 | s8q10==3 | s8q10==4)

*** Did you pay for Xrays, lab exams or similar?
/* s8q13 ¿Pagó por radiografías, exámenes de laboratorio o similares?: pago_examen
			1 = Si
			2 = No 		*/
gen 	pago_examen = s8q13==1 if s8q1==1 & s8q3==1 & (s8q13!=. & s8q13!=.a)
			
*** How much did you pay for Xrays, lab exams or similar?
* s8q14a ¿Cuánto pagó?: cant_pago_examen
clonevar     cant_pago_examen = s8q14a if s8q1==1 & s8q3==1 

*** In which currency did you pay for Xrays, lab exams or similar?
/* 	s8q14b ¿En qué moneda realizó el pago?: mone_pago_examen
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
clonevar   	mone_pago_examen = s8q14b if s8q1==1 & s8q3==1 

*** In which month did you pay for Xrays, lab exams or similar?
/* 	s8q14c ¿En qué mes pagó?: mes_pago_examen
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
clonevar   	mes_pago_examen = s8q14c if s8q1==1 & s8q3==1 

*** Although you answered you didn't have any health problem, illness or accident in the last month, did you spend money in medicines due to illnesses, accidents or health problems in the last 3 months?
/*  s8q15 Aunque usted ya indicó que no consultó a ningún personal médico, ¿gastó dinero en los ultimos 3 meses en medicinas por enfermedad, accidente, o quebrantos de salud que tuvo?
			1 = Si
			2 = No 		*/
gen 	remedio_tresmeses = s8q15==1 if s8q1==2 & (s8q15!=. & s8q15!=.a)

*** How much did you pay for medicines in the last 3 months?
* s8q16a ¿Cuánto gastó?: cant_remedio_tresmeses
clonevar    cant_remedio_tresmeses = s8q16a if s8q1==2 & s8q15==1

*** In which currency did you pay for medicines in the last 3 months?
/* 	s8q16b ¿En qué moneda realizó el pago?: mone_remedio_tresmeses
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
clonevar   	mone_remedio_tresmeses = s8q16b if s8q1==2 & s8q15==1

*** In which month did you pay for medicines in the last 3 months?
/* 	s8q16c ¿En qué mes pagó?: mes_remedio_tresmeses
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
clonevar   	mes_remedio_tresmeses = s8q16c if s8q1==2 & s8q15==1

*** Are you affiliated to health insurance?
/* 	s8q17 ¿Está afiliado a algún seguro medico?: seguro_salud
			1 = si
			2 = no	 */
gen     seguro_salud = s8q17==1	if (s8q17!=. & s8q17!=.a)

*** Which is the main health insurance or that with greatest coverage you are affiliated to?
/* s8q18: ¿Cuál es el seguro médico principal o de mayor cobertura al cual está afiliado?: afiliado_segsalud
		1 = Instituto Venezolano de los Seguros Sociales (IVSS)
		2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
		3 = Seguro medico contratado por institucion publica
		4 = Seguro medico contratado por institucion privada
		5 = Seguro medico privado contratado de forma particular */
clonevar 	afiliado_segsalud = s8q18   if s8q17==1 & (s8q18!=. & s8q18!=.a) 
* Problema: este "afiliado_segsalud" no es comparable con años anteriores! Corregir


*** Did you pay for health insurance?
/* 	s8q19 ¿Pagó por el seguro médico?: pagosegsalud
		1 = si
		2 = no	 */
gen     pagosegsalud = s8q19==1 if s8q17==1 & (s8q19!=. & s8q19!=.a)

*** Who paid for the health insurance?
/* s8q20 ¿Quién pagó por el seguro médico?: quien_pagosegsalud
		1 = Beneficio laboral
		2 = Familiar en el exterior
		3 = Otro miembro del hogar
		4 = Otro (especifique) */
clonevar	quien_pagosegsalud = s8q20  if s8q17==1 & s8q18==5 & s8q19==2

*** Other
* Otro
clonevar	quien_pagosegsalud_o = s8q20_os  if s8q17==1 & s8q18==5 & s8q20==4

*** How much did you pay for the health insurance?
* s8q21a ¿Cuál fue el monto pagado por el seguro de salud?: cant_pagosegsalud
clonevar	cant_pagosegsalud = s8q21a if s8q19==1 & (s8q21a!=. & s8q21a!=.a)

*** In which currency did you pay for the health insurance?
/* 	s8q21b ¿En qué moneda realizó el pago?: mone_pagosegsalud
	1=bolivares, 2=dolares, 3=euros, 4=colombianos */
clonevar   	mone_pagosegsalud = s8q21b if s8q19==1 & (s8q21b!=. & s8q21b!=.a)

*** In which month did you pay for the health insurance?
/* 	s8q21c ¿En qué mes pagó?: mes_pagosegsalud
	1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre */
clonevar   	mes_pagosegsalud = s8q21c if s8q19==1 & (s8q21c!=. & s8q21c!=.a)


/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- IX: LABOR / EMPLEO ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

global labor_ENCOVI trabajo_semana trabajo_semana_2 trabajo_independiente razon_no_trabajo razon_no_trabajo_o sueldo_semana busco_trabajo empezo_negocio cuando_buscotr ///
dili_agencia dili_aviso dili_planilla dili_credito dili_tramite dili_compra dili_contacto ///
como_busco_semana razon_no_busca razon_no_busca_o actividades_inactivos tarea sector_encuesta categ_ocu hstr_ppal trabajo_secundario hstr_todos /// 
im_sueldo im_hsextra im_propina im_comision im_ticket im_guarderia im_beca im_hijos im_antiguedad im_transporte im_rendimiento im_otro im_petro ///
im_sueldo_cant im_hsextra_cant im_propina_cant im_comision_cant im_ticket_cant im_guarderia_cant im_beca_cant im_hijos_cant im_antiguedad_cant im_transporte_cant im_rendimiento_cant im_otro_cant im_petro_cant ///
im_sueldo_mone im_hsextra_mone im_propina_mone im_comision_mone im_ticket_mone im_guarderia_mone im_beca_mone im_hijos_mone im_antiguedad_mone im_transporte_mone im_rendimiento_mone im_otro_mone ///
c_sso c_rpv c_spf c_aca c_sps c_otro c_sso_cant c_rpv_cant c_spf_cant c_aca_cant c_sps_cant c_otro_cant c_sso_mone c_rpv_mone c_spf_mone c_aca_mone c_sps_mone c_otro_mone ///
inm_comida inm_productos inm_transporte inm_vehiculo inm_estaciona inm_telefono inm_servicios inm_guarderia inm_otro ///
inm_comida_cant inm_productos_cant inm_transporte_cant inm_vehiculo_cant inm_estaciona_cant inm_telefono_cant inm_servicios_cant inm_guarderia_cant inm_otro_cant ///
inm_comida_mone inm_productos_mone inm_transporte_mone inm_vehiculo_mone inm_estaciona_mone inm_telefono_mone inm_servicios_mone inm_guarderia_mone inm_otro_mone ///
d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone ///
im_patron im_patron_cant im_patron_mone inm_patron inm_patron_cant inm_patron_mone im_indep im_indep_cant im_indep_mone i_indep_mes i_indep_mes_cant i_indep_mes_mone ///
g_indep_mes_cant g_indep_mes_mone razon_menoshs razon_menoshs_o deseamashs buscamashs razon_nobusca razon_nobusca_o cambiotr razon_cambiotr razon_cambiotr_o ///
aporta_pension pension_IVSS pension_publi pension_priv pension_otro pension_otro_o aporte_pension cant_aporta_pension mone_aporta_pension 

*Notes: interviews done if age>9

* Identifying economically active and inactive, and reasons

	*** Did you work at least one hour last week? 
	/* 	s9q1 ¿La semana pasada trabajó al menos una hora?: trabajo_semana
			1 = si
			2 = no	 */
	gen     trabajo_semana = s9q1==1 if (s9q1!=. & s9q1!=.a) 

	*** Independently of last answer, did you dedicate last week at least one hour to: 
	/* 	s9q2 Independientemente de lo que me acaba de decir, ¿le dedicó la semana pasada, al menos una hora a...: trabajo_semana_2
			1 = Realizar una actividad que le proporcionó ingresos
			2 = Ayudar en las tierras o en el negocio de un familiar o de otra persona
			3 = No trabajó la semana pasada	 */
	clonevar	trabajo_semana_2 = s9q2 if s9q1==2 & (s9q2!=. & s9q2!=.a) 

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
	clonevar	razon_no_trabajo = s9q4 if s9q3==1 & (s9q2!=. & s9q2!=.a) 
		
	***Other reason
	*Otra razón
	clonevar	razon_no_trabajo_o = s9q4_os if s9q4==16
	
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

	*** When was the last time you did something to find a job or start a business jointly or alone?
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
	clonevar dili_agencia 	= s9q9__1 if (s9q6==1 | s9q7==1) & (s9q9__1!=. & s9q9__1!=.a) 
	clonevar dili_aviso 	= s9q9__2 if (s9q6==1 | s9q7==1) & (s9q9__2!=. & s9q9__2!=.a) 
	clonevar dili_planilla 	= s9q9__3 if (s9q6==1 | s9q7==1) & (s9q9__3!=. & s9q9__3!=.a) 
	clonevar dili_credito 	= s9q9__4 if (s9q6==1 | s9q7==1) & (s9q9__4!=. & s9q9__4!=.a) 
	clonevar dili_tramite 	= s9q9__5 if (s9q6==1 | s9q7==1) & (s9q9__5!=. & s9q9__5!=.a) 
	clonevar dili_compra 	= s9q9__6 if (s9q6==1 | s9q7==1) & (s9q9__6!=. & s9q9__6!=.a) 
	clonevar dili_contacto 	= s9q9__7 if (s9q6==1 | s9q7==1) & (s9q9__7!=. & s9q9__7!=.a) 
	clonevar dili_otro	 	= s9q9__8 if (s9q6==1 | s9q7==1) & (s9q9__8!=. & s9q9__8!=.a) 
	
	*** Have you carried out any of those proceedings last week?
	/* s9q10 ¿Realizó alguna de esas diligencias la semana pasada?: como_busco_semana
			1 = si
			2 = no	*/
	gen     como_busco_semana = s9q10==1 if (s9q9__1!=. | s9q9__2!=. | s9q9__3!=. | s9q9__4!=. | s9q9__5!=. | s9q9__6!=. | s9q9__7!=. | s9q9__8!=.) & (s9q10!=. & s9q10!=.a) 

	*** Why aren't you currently looking for a job?
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
	clonevar  razon_no_busca = s9q11 if inlist(s9q8,1,2,3,4) & (s9q11!=. & s9q11!=.a) 

	***Other reason
	*Otra razón
	clonevar	razon_no_busca_o = s9q11_os if s9q11==9
	
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
	clonevar	actividades_inactivos = s9q12 if (s9q11==1|2|3|4|5|6|7|8|9) & (s9q12!=. & s9q12!=.a) 

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
	clonevar	tarea = s9q13 		if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q13!=. & s9q13!=.a) // the first parenthesis means being economically active

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
	clonevar 	sector_encuesta = s9q14 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q14!=. & s9q14!=.a) // the first parenthesis means being economically active

	*** In your work you work as...
	/* s9q15 En su trabajo se desempeña como...: categ_ocu
			1 = Empleado u obrero en el sector publico
				*Obs: 1 used to be divided in 2 before, thats why number 2 is skipped.
			3 = Empleado u obrero en empresa privada		
				*Obs: 3 used to be divided in 2 before, thats why number 4 is skipped.
			5 = Patrono o empleador
			6 = Trabajador por cuenta propia
			7 = Miembro de cooperativas
			8 = Ayudante familiar remunerado/no remunerado
			9 = Servicio domestico		*/
	clonevar 	categ_ocu = s9q15 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q15!=. & s9q15!=.a) // the first parenthesis means being economically active
	*Obs. CAPI1: s9q15==(1|2|3|4|7|8|9) i.e. workers not self-employed or employer

	*** How many hours did you work last week in your main occupation?
	/* s9q16 ¿Cuántas horas trabajó durante la semana pasada en su ocupación principal?: hstr_ppal	*/
	clonevar	hstr_ppal = s9q16 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q16!=. & s9q16!=.a) 

	*** Besides your main occupation, did you do any other activity through which you received income, such as selling things, contracted work, etc?
	/* s9q17 Además de su trabajo principal, ¿realizó la semana pasada alguna otra actividad por la que percibió ingresos tales como, venta de artículos, trabajos contratados, etc?: trabajo_secundario
			1 = si
			2 = no		*/
	gen     trabajo_secundario = s9q17==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q17!=. & s9q17!=.a) 

	*** How many hours do you normally work weekly in all your jobs or businesses?
	/* s9q18 ¿Cuántas horas trabaja normalmente a la semana en todos sus trabajos o negocios?: hstr_todos */

	clonevar hstr_todos = s9q18 if s9q17==1 & (s9q18!=. & s9q18!=.a) 

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
	clonevar	im_sueldo 		= s9q19__1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__1!=. & s9q19__1!=.a) 
	clonevar	im_hsextra 		= s9q19__2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__2!=. & s9q19__2!=.a) 
	clonevar	im_propina 		= s9q19__3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__3!=. & s9q19__3!=.a) 
	clonevar	im_comision	 	= s9q19__4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__4!=. & s9q19__4!=.a) 
	clonevar	im_ticket		= s9q19__5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__5!=. & s9q19__5!=.a) 
	clonevar	im_guarderia	= s9q19__6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__6!=. & s9q19__6!=.a) 
	clonevar	im_beca			= s9q19__7 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__7!=. & s9q19__7!=.a) 
	clonevar	im_hijos		= s9q19__8 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__8!=. & s9q19__8!=.a) 
	clonevar	im_antiguedad 	= s9q19__9 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__9!=. & s9q19__9!=.a) 
	clonevar	im_transporte	= s9q19__10 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__10!=. & s9q19__10!=.a) 
	clonevar	im_rendimiento	= s9q19__11 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__11!=. & s9q19__11!=.a) 
	clonevar	im_otro			= s9q19__12 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19__12!=. & s9q19__12!=.a) 
	gen			im_petro		= (s9q19_petro==1) if (s9q19_petro!=. & s9q19_petro!=.a) & (s9q19__12!=. & s9q19__12!=.a)
		label def im_petro 1 "Sí" 0 "No"
		label values im_petro im_petro
	
	*** Amount received (1 variable for each of the 12 options)
	* s9q19a_* Monto recibido: im_*_cant
	* Note: cant stands for cantidad/quantity
	clonevar    im_sueldo_cant 		= s9q19a_1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_1!=. & s9q19a_1!=.a) 
	clonevar    im_hsextra_cant 	= s9q19a_2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_2!=. & s9q19a_2!=.a) 
	clonevar    im_propina_cant		= s9q19a_3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_3!=. & s9q19a_3!=.a) 
	clonevar    im_comision_cant	= s9q19a_4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_4!=. & s9q19a_4!=.a) 
	clonevar 	im_ticket_cant		= s9q19a_5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_5!=. & s9q19a_5!=.a) 
	clonevar 	im_guarderia_cant 	= s9q19a_6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_6!=. & s9q19a_6!=.a) 
	clonevar 	im_beca_cant		= s9q19a_7 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_7!=. & s9q19a_7!=.a) 
	clonevar 	im_hijos_cant		= s9q19a_8 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_8!=. & s9q19a_8!=.a) 
	clonevar 	im_antiguedad_cant	= s9q19a_9 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_9!=. & s9q19a_9!=.a) 
	clonevar 	im_transporte_cant	= s9q19a_10 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_10!=. & s9q19a_10!=.a) 
	clonevar 	im_rendimiento_cant	= s9q19a_11 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_11!=. & s9q19a_11!=.a) 
	clonevar 	im_otro_cant		= s9q19a_12 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q19a_12!=. & s9q19a_12!=.a) 
	clonevar	im_petro_cant		= s9q19_petromonto if (s9q19_petromonto!=. & s9q19_petromonto!=.a) 
	
	*** In which currency? (1 variable for each of the 12 options)
	* s9q19b_* En qué moneda?: im_*_mone
	* 1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos
	clonevar    im_sueldo_mone 		= s9q19b_1 if s9q19__1!=. & (s9q19b_1!=. & s9q19b_1!=.a) 
	clonevar    im_hsextra_mone 	= s9q19b_2 if s9q19__2!=. & (s9q19b_2!=. & s9q19b_2!=.a) 
	clonevar    im_propina_mone		= s9q19b_3 if s9q19__3!=. & (s9q19b_3!=. & s9q19b_3!=.a) 
	clonevar    im_comision_mone	= s9q19b_4 if s9q19__4!=. & (s9q19b_4!=. & s9q19b_4!=.a) 
	clonevar 	im_ticket_mone		= s9q19b_5 if s9q19__5!=. & (s9q19b_5!=. & s9q19b_5!=.a) 
	clonevar 	im_guarderia_mone 	= s9q19b_6 if s9q19__6!=. & (s9q19b_6!=. & s9q19b_6!=.a) 
	clonevar 	im_beca_mone		= s9q19b_7 if s9q19__7!=. & (s9q19b_7!=. & s9q19b_7!=.a) 
	clonevar 	im_hijos_mone		= s9q19b_8 if s9q19__8!=. & (s9q19b_8!=. & s9q19b_8!=.a) 
	clonevar 	im_antiguedad_mone	= s9q19b_9 if s9q19__9!=. & (s9q19b_9!=. & s9q19b_9!=.a) 
	clonevar 	im_transporte_mone	= s9q19b_10 if s9q19__10!=. & (s9q19b_10!=. & s9q19b_10!=.a) 
	clonevar 	im_rendimiento_mone = s9q19b_11 if s9q19__11!=. & (s9q19b_11!=. & s9q19b_11!=.a) 
	clonevar 	im_otro_mone		= s9q19b_12 if s9q19__12!=. & (s9q19b_12!=. & s9q19b_12!=.a)

	*** With respect to last month, did you receive in your jobs contributions from your employer to social security for any of the following concepts? (each one is a dummy)
	/* s9q20__* ¿Con respecto al mes pasado recibió en su trabajo u otros empleos, contribuciones de los patronos a la seguridad social por los siguientes conceptos?: c_*
				1 = Seguro social obligatorio
				2 = Régimen de prestaciones Vivienda y hábitat
				3 = Seguro de paro forzoso
				4 = Aporte patronal de la caja de ahorro
				5 = Contribuciones al sistema privado de seguros
				6 = Otras contribuciones */
			* Note: For those not self-employed or employers (s9q15==1|3|7|8|9) // CAPI1=true	
	clonevar    c_sso 		= s9q20__1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__1!=. & s9q20__1!=.a) 
	clonevar    c_rpv 		= s9q20__2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__2!=. & s9q20__2!=.a) 
	clonevar    c_spf 		= s9q20__3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__3!=. & s9q20__3!=.a) 
	clonevar    c_aca	 	= s9q20__4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__4!=. & s9q20__4!=.a) 
	clonevar 	c_sps		= s9q20__5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__5!=. & s9q20__5!=.a) 
	clonevar 	c_otro		= s9q20__6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__6!=. & s9q20__6!=.a) 
		
	*** Amount received (1 variable for each of the 6 options)
	* s9q20a_* Monto recibido: c_*_cant
	clonevar    c_sso_cant 	= s9q20a_1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20a_1!=. & s9q20a_1!=.a) 
	clonevar    c_rpv_cant 	= s9q20a_2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20a_2!=. & s9q20a_2!=.a) 
	clonevar    c_spf_cant  = s9q20a_3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20a_3!=. & s9q20a_3!=.a) 
	clonevar    c_aca_cant 	= s9q20a_4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20a_4!=. & s9q20a_4!=.a) 
	clonevar 	c_sps_cant 	= s9q20a_5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20a_5!=. & s9q20a_5!=.a) 
	clonevar 	c_otro_cant = s9q20a_6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20a_6!=. & s9q20a_6!=.a)

	*** In which currency? (1 variable for each of the 12 options)
	* s9q20b_* En qué moneda?: c_*_mone
	* 1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos
	clonevar    c_sso_mone 	= s9q20b_1 if s9q20__1!=. & (s9q20b_1!=. & s9q20b_1!=.a) 
	clonevar    c_rpv_mone 	= s9q20b_2 if s9q20__2!=. & (s9q20b_2!=. & s9q20b_2!=.a) 
	clonevar    c_spf_mone  = s9q20b_3 if s9q20__3!=. & (s9q20b_3!=. & s9q20b_3!=.a) 
	clonevar    c_aca_mone 	= s9q20b_4 if s9q20__4!=. & (s9q20b_4!=. & s9q20b_4!=.a) 
	clonevar 	c_sps_mone 	= s9q20b_5 if s9q20__5!=. & (s9q20b_5!=. & s9q20b_5!=.a) 
	clonevar 	c_otro_mone = s9q20b_6 if s9q20__6!=. & (s9q20b_6!=. & s9q20b_6!=.a)

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
	clonevar	inm_comida 			= s9q21__1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__1!=. & s9q21__1!=.a) 
	clonevar    inm_productos 		= s9q21__2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__2!=. & s9q21__2!=.a) 
	clonevar    inm_transporte 		= s9q21__3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__3!=. & s9q21__3!=.a) 
	clonevar    inm_vehiculo	 	= s9q21__4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__4!=. & s9q21__4!=.a) 
	clonevar 	inm_estaciona		= s9q21__5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__5!=. & s9q21__5!=.a) 
	clonevar 	inm_telefono		= s9q21__6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__6!=. & s9q21__6!=.a) 
	clonevar 	inm_servicios		= s9q21__7 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__7!=. & s9q21__7!=.a) 
	clonevar 	inm_guarderia		= s9q21__8 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__8!=. & s9q21__8!=.a) 
	clonevar 	inm_otro	 		= s9q21__9 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21__9!=. & s9q21__9!=.a) 
		
	*** Amount received, or estimation of how much they would have paid for the benefit (1 variable for each of the 9 options)
	* s9q21a_*: Monto recibido (Si no percibe el beneficio en dinero, estime cuánto tendría que haber pagado por ese concepto (p.e. pago de guardería infantil, comedor en la empresa o transporte))
	clonevar    inm_comida_cant 	= s9q21a_1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_1!=. & s9q21a_1!=.a) 
	clonevar    inm_productos_cant 	= s9q21a_2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_2!=. & s9q21a_2!=.a) 
	clonevar    inm_transporte_cant	= s9q21a_3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_3!=. & s9q21a_3!=.a) 
	clonevar    inm_vehiculo_cant	= s9q21a_4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_4!=. & s9q21a_4!=.a) 
	clonevar 	inm_estaciona_cant	= s9q21a_5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_5!=. & s9q21a_5!=.a) 
	clonevar 	inm_telefono_cant 	= s9q21a_6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_6!=. & s9q21a_6!=.a) 
	clonevar 	inm_servicios_cant	= s9q21a_7 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_7!=. & s9q21a_7!=.a) 
	clonevar 	inm_guarderia_cant	= s9q21a_8 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_8!=. & s9q21a_8!=.a) 
	clonevar 	inm_otro_cant 		= s9q21a_9 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q21a_9!=. & s9q21a_9!=.a) 

	*** In which currency? (1 variable for each of the 12 options)
	* s9q21b_* En qué moneda?: inm_*_moneda
	* 1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos
	clonevar    inm_comida_mone 	= s9q21b_1 if s9q21__1!=. & (s9q21b_1!=. & s9q21b_1!=.a) 
	clonevar    inm_productos_mone 	= s9q21b_2 if s9q21__2!=. & (s9q21b_2!=. & s9q21b_2!=.a) 
	clonevar    inm_transporte_mone	= s9q21b_3 if s9q21__3!=. & (s9q21b_3!=. & s9q21b_3!=.a) 
	clonevar    inm_vehiculo_mone	= s9q21b_4 if s9q21__4!=. & (s9q21b_4!=. & s9q21b_4!=.a) 
	clonevar 	inm_estaciona_mone	= s9q21b_5 if s9q21__5!=. & (s9q21b_5!=. & s9q21b_5!=.a) 
	clonevar 	inm_telefono_mone 	= s9q21b_6 if s9q21__6!=. & (s9q21b_6!=. & s9q21b_6!=.a) 
	clonevar 	inm_servicios_mone	= s9q21b_7 if s9q21__7!=. & (s9q21b_7!=. & s9q21b_7!=.a) 
	clonevar 	inm_guarderia_mone	= s9q21b_8 if s9q21__8!=. & (s9q21b_8!=. & s9q21b_8!=.a) 
	clonevar 	inm_otro_mone		= s9q21b_9 if s9q21__9!=. & (s9q21b_9!=. & s9q21b_9!=.a)

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
	clonevar    d_sso	 	= s9q22__1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__1!=. & s9q22__1!=.a) 
	clonevar    d_spf	 	= s9q22__2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__2!=. & s9q22__2!=.a) 
	clonevar    d_isr 		= s9q22__3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__3!=. & s9q22__3!=.a) 
	clonevar    d_cah		= s9q22__4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__4!=. & s9q22__4!=.a) 
	clonevar 	d_cpr		= s9q22__5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__5!=. & s9q22__5!=.a) 
	clonevar 	d_rpv		= s9q22__6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__6!=. & s9q22__6!=.a) 
	clonevar 	d_otro		= s9q22__7 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22__7!=. & s9q22__7!=.a) 
		
	*** Amount discounted
	* s9q22a_*: Monto descontado
	clonevar    d_sso_cant 	= s9q22a_1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_1!=. & s9q22a_1!=.a) 
	clonevar    d_spf_cant 	= s9q22a_2 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_2!=. & s9q22a_2!=.a) 
	clonevar    d_isr_cant 	= s9q22a_3 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_3!=. & s9q22a_3!=.a) 
	clonevar    d_cah_cant 	= s9q22a_4 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_4!=. & s9q22a_4!=.a) 
	clonevar 	d_cpr_cant 	= s9q22a_5 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_5!=. & s9q22a_5!=.a) 
	clonevar 	d_rpv_cant  = s9q22a_6 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_6!=. & s9q22a_6!=.a) 
	clonevar 	d_otro_cant = s9q22a_7 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q22a_7!=. & s9q22a_7!=.a) 

	*** In which currency? (1 variable for each of the 7 options)
	/* s9q22b_* En qué moneda?: d_*_moneda
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar    d_sso_mone 	= s9q22b_1 if s9q22__1!=. & (s9q22b_1!=. & s9q22b_1!=.a) 
	clonevar    d_spf_mone 	= s9q22b_2 if s9q22__2!=. & (s9q22b_2!=. & s9q22b_2!=.a) 
	clonevar    d_isr_mone	= s9q22b_3 if s9q22__3!=. & (s9q22b_3!=. & s9q22b_3!=.a) 
	clonevar    d_cah_mone	= s9q22b_4 if s9q22__4!=. & (s9q22b_4!=. & s9q22b_4!=.a) 
	clonevar 	d_cpr_mone	= s9q22b_5 if s9q22__5!=. & (s9q22b_5!=. & s9q22b_5!=.a) 
	clonevar 	d_rpv_mone 	= s9q22b_6 if s9q22__6!=. & (s9q22b_6!=. & s9q22b_6!=.a) 
	clonevar 	d_otro_mone	= s9q22b_7 if s9q22__7!=. & (s9q22b_7!=. & s9q22b_7!=.a)
	
* For employers (s9q15==5) // CAPI2=true
	
	*** Last month did you receive money due to the selling of products, goods, or services from your business or activity?
	/* s9q23 ¿El mes pasado recibió dinero por la venta de los productos, bienes o servicios de su negocio o actividad?: im_patron
				1 = si
				2 = no*/
		* Note: For employers (s9q15==5) // CAPI2=true	
	gen     im_patron 	= s9q23==1 if s9q15==5 & (s9q23!=. & s9q23!=.a) 
		
	*** Amount received
	* s9q23a: Monto recibido: im_patron_cant
	clonevar	im_patron_cant 	= s9q23a if s9q15==5 & (s9q23a!=. & s9q23a!=.a) 

	*** In which currency?
	/* s9q23b En qué moneda?
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar	im_patron_mone 	= s9q23b if s9q15==5 & (s9q23b!=. & s9q23b!=.a) 

	*** Last month did you take products from your business or activity for you own or your household's consumption?
	/* s9q24 ¿El mes pasado retiró productos del negocio o actividad para consumo propio o de su hogar?: inm_patron
				1 = si
				2 = no*/
		* Note: For employers (s9q15==5) // CAPI2=true	
	gen     inm_patron 	= s9q24==1 if s9q15==5 & (s9q24!=. & s9q24!=.a) 
		
	*** How much you would have had to pay for these products?
	* s9q24a: ¿Cuánto hubiera tenido que pagar por esos productos?: inm_patron_cant
	clonevar	inm_patron_cant 	= s9q24a if s9q15==5 & (s9q24a!=. & s9q24a!=.a) 

	*** In which currency? 
	/* s9q24b ¿En qué moneda?: inm_patron_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar	inm_patron_mone 	= s9q24b if s9q15==5 & (s9q24b!=. & s9q24b!=.a)

* For self-employed workers (s9q15==6) // CAPI3=true
	
	*** During the last 12 months, did you receive money or net benefits derived from your business or activity?
	/* s9q25 ¿Durante los últimos doce (12) meses, recibió dinero por ganancias o utilidades netas derivadas del negocio o actividad? : im_indep
				1 = si
				2 = no	*/
		* Note: For self-employed workers (s9q15==6) // CAPI3=true	
	gen     im_indep 	= s9q25==1 if s9q15==6 & (s9q25!=. & s9q25!=.a) 
		
	*** Amount received
	* s9q25a: Cuánto recibió?: im_indep_cant
	clonevar     im_indep_cant 	= s9q25a if s9q15==6 & (s9q25a!=. & s9q25a!=.a) 

	*** In which currency? 
	/* s9q25b En qué moneda?: im_indep_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar     im_indep_mone 	= s9q25b if s9q15==6 & (s9q25b!=. & s9q25b!=.a) 

	*** Last month did you receive income from your activity for own expenses or from your household?
	/* s9q26 ¿El mes pasado, recibió ingresos por su actividad para gastos propios o de su hogar?: i_indep_mes
				1 = si
				2 = no	*/
		* Note: For self-employed workers (s9q15==6) // CAPI3=true	
	gen     i_indep_mes 	= s9q26==1 if s9q15==6 & (s9q26!=. & s9q26!=.a) 
		
	*** How much did you receive?
	* s9q26a: Cuánto recibió?: i_indep_mes_cant
	clonevar     i_indep_mes_cant 	= s9q26a if s9q15==6 & (s9q26a!=. & s9q26a!=.a) 

	*** In which currency? 
	/* s9q26b En qué moneda?: i_indep_mes_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar     i_indep_mes_mone 	= s9q26b if s9q15==5 & (s9q26b!=. & s9q26b!=.a)
	
	*** Last month, how much money did you spend to generate income (e.g. office renting, transport expenditures, cleaning products)?
	* s9q27: El mes pasado, ¿cuánto dinero gastó  para generar el ingreso (p.e. alquiler de oficina, gastos de transporte, productos de limpieza)?: gm_indep_mes_cant
		* Note: For self-employed workers (s9q15==6) // CAPI3=true	
		* Note2: g stands for gasto monetario
	clonevar     g_indep_mes_cant 	= s9q27 if s9q15==5 & (s9q27!=. & s9q27!=.a) 
		
	*** In which currency? 
	/* s9q27b En qué moneda?: inm_indep_mes_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar     g_indep_mes_mone 	= s9q27a if s9q15==5 & (s9q27a!=. & s9q27a!=.a)

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
	clonevar 	razon_menoshs = s9q30 if s9q18<35 & (s9q30!=. & s9q30!=.a) 

	***Other
	* Otra
	clonevar 	razon_menoshs_o = s9q30_os if s9q18<35 & s9q30==6

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
	clonevar	razon_nobusca = s9q33 if s9q18<35 & (s9q33!=. & s9q33!=.a)
	
	*** Other reason
	*Otra razón
	clonevar 	razon_nobusca_o = s9q33_os if s9q18<35 & s9q33==11
	
* For all workers

	*** Have you changed jobs in the last 12 months?
	/* s9q34 ¿Ha cambiado de trabajo en los últimos 12 meses?: cambiotr
				1 = si
				2 = no	*/
	gen 	cambiotr = s9q34==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q34!=. & s9q34!=.a)

	*** Which is the main reason why you changed jobs?
	/* s9q35 ¿Cuál fue la razón principal por la que cambió de trabajo?
		1 = Conseguir ingresos más altos
		2 = Tener un trabajo más adecuado
		3 = Finalización del contrato o empleo laboral
		4 = Dificultades con la empresa (despido, reducción de personal, cierre de la empresa)
		5 = Dificultades económica (falta de materiales e insumos para trabajar)
		6 = Otra (Especifique)	*/
	clonevar	razon_cambiotr = s9q35 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q35!=. & s9q35!=.a)

	*** Other reason
	*Otra razón
	clonevar razon_cambiotr_o = s9q35_os if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & s9q35==6
		
	*** Do you make contributions to any pension fund?
	/* s9q36 ¿Realiza aportes para algún fondo de pensiones?	
				1 = si
				2 = no	*/
	gen		aporta_pension = s9q36==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q36!=. & s9q36!=.a)

	*** To which pension fund?
	/* s9q37__* ¿A cuál fondo de pensión?	
				1 = El IVSS
				2 = Otra institución o empresa pública
				3 = Para institución o empresa privada
				4 = Otro	*/
	clonevar	pension_IVSS 	= s9q37__1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__1!=. & s9q37__1!=.a)
	clonevar	pension_publi 	= s9q37__2 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__2!=. & s9q37__2!=.a)
	clonevar	pension_priv 	= s9q37__3 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__3!=. & s9q37__3!=.a)
	clonevar	pension_otro 	= s9q37__4 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q37__4!=. & s9q37__4!=.a)
	
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
	
	***Other
	*Otro
	clonevar	pension_otro_o = s9q37_os if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & s9q37__4==1
	
	*** How much did you pay last month for pension funds?
	* s9q38 En el último mes, ¿cuánto pagó en total por fondos de pensiones? 
	clonevar	cant_aporta_pension = s9q38 if s9q36==1 & (s9q38!=. & s9q38!=.a)

	*** In which currency?
	/* s9q39a ¿En qué moneda? 
		1=bolivares, 2=dolares, 3=euros, 4=colombianos */
	clonevar	mone_aporta_pension = s9q39a if s9q36==1 & (s9q39a!=. & s9q39a!=.a)

* From CEDLAS, which might be useful

	/* LABOR_STATUS: La semana pasada estaba:
        1 = Trabajando
		2 = No trabajó, pero tiene trabajo
		3 = Buscando trabajo (antes esto se subdividía entre 3."por primera vez" y 4."habiendo trabajado antes")
		5 = En quehaceres del hogar
		6 = Incapacitado
		7 = Otra situacion
		8 = Estudiando o de vacaciones escolares
		9 = Pensionado o jubilado	*/
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

	/* RELAB:
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

	
/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- XVI: BANKING / BANCARIZACIÓN ---------------------------------------------------------------
************************************************************************************************************************************************)*/
global bank_ENCOVI contesta_ind_b quien_contesta_b cuenta_corr cuenta_aho tcredito tdebito no_banco ///
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
gen no_banco=s16q1__5 if (s16q1__5!=. & s16q1__5!=.a)

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

/*(*********************************************************************************************************************************************** 
*---------------------------------- 9: Otros ingresos y pensiones / Other income and pensions ----------------------------------------------------
***********************************************************************************************************************************************)*/	

global otherinc_ENCOVI inla_pens_soi	inla_pens_vss	inla_jubi_emp	inla_pens_dsa	inla_beca_pub	inla_beca_pri	inla_ayuda_pu	inla_ayuda_pr	inla_ayuda_fa	inla_asig_men	inla_otros	inla_petro ///
inla_pens_soi_cant	inla_pens_vss_cant	inla_jubi_emp_cant	inla_pens_dsa_cant	inla_beca_pub_cant	inla_beca_pri_cant	inla_ayuda_pu_cant	inla_ayuda_pr_cant	inla_ayuda_fa_cant	inla_asig_men_cant	inla_otros_cant	inla_petro_cant ///
inla_pens_soi_mone	inla_pens_vss_mone	inla_jubi_emp_mone	inla_pens_dsa_mone	inla_beca_pub_mone	inla_beca_pri_mone	inla_ayuda_pu_mone	inla_ayuda_pr_mone	inla_ayuda_fa_mone	inla_asig_men_mone	inla_otros_mone ///
iext_sueldo	iext_ingnet	iext_indemn	iext_remesa	iext_penjub	iext_intdiv	iext_becaes	iext_extrao iext_alquil ///
iext_sueldo_cant	iext_ingnet_cant	iext_indemn_cant	iext_remesa_cant	iext_penjub_cant	iext_intdiv_cant	iext_becaes_cant	iext_extrao_cant    iext_alquil_cant ///
iext_sueldo_mone	iext_ingnet_mone	iext_indemn_mone	iext_remesa_mone	iext_penjub_mone	iext_intdiv_mone	iext_becaes_mone	iext_extrao_mone	iext_alquil_mone


*** Did you receive last month income for any of the following concepts and how much? (each one is a dummy)
	/* s9q28__* Recibió el mes pasado ingresos por alguno de los siguientes conceptos y cuánto?
				1=Pensión de sobreviviente, orfandad, incapacidad
				2=Pensión de vejez por el seguro social
				3=Jubilación por trabajo
				4=Pensión por divorcio, separación, alimentación
				5=Beca o ayuda escolar pública
				6=Beca o ayuda escolar privada
				7=Ayuda de instituciones públicas
				8=Ayuda de instituciones privadas
				9=Ayudas familiares o contribuciones de otros hogares
				10=Asignación familiar por menores a su cargo
				11=Otro	*/
	clonevar    inla_pens_soi	= s9q28__1 if (s9q28__1!=. & s9q28__1!=.a) 
	clonevar    inla_pens_vss	= s9q28__2 if (s9q28__2!=. & s9q28__2!=.a) 
	clonevar    inla_jubi_emp	= s9q28__3 if (s9q28__3!=. & s9q28__3!=.a) 
	clonevar    inla_pens_dsa	= s9q28__4 if (s9q28__4!=. & s9q28__4!=.a) 
	clonevar 	inla_beca_pub	= s9q28__5 if (s9q28__5!=. & s9q28__5!=.a) 
	clonevar 	inla_beca_pri	= s9q28__6 if (s9q28__6!=. & s9q28__6!=.a) 
	clonevar 	inla_ayuda_pu	= s9q28__7 if (s9q28__7!=. & s9q28__7!=.a)
	clonevar 	inla_ayuda_pr	= s9q28__8 if (s9q28__8!=. & s9q28__8!=.a)
	clonevar 	inla_ayuda_fa	= s9q28__9 if (s9q28__9!=. & s9q28__9!=.a)
	clonevar 	inla_asig_men	= s9q28__10 if (s9q28__10!=. & s9q28__10!=.a)
	clonevar 	inla_otros		= s9q28__11 if (s9q28__11!=. & s9q28__11!=.a)
	gen			inla_petro		= (s9q28_petro==1) if (s9q28_petro!=. & s9q28_petro!=.a)
		label def inla_petro 1 "Sí" 0 "No"
		label values inla_petro inla_petro
	
	*** Amount discounted
	* s9q28a_*: Monto descontado *_cant
	clonevar    inla_pens_soi_cant	= s9q28a_1 if (s9q28a_1!=. & s9q28a_1!=.a) 
	clonevar    inla_pens_vss_cant	= s9q28a_2 if (s9q28a_2!=. & s9q28a_2!=.a) 
	clonevar    inla_jubi_emp_cant	= s9q28a_3 if (s9q28a_3!=. & s9q28a_3!=.a) 
	clonevar    inla_pens_dsa_cant	= s9q28a_4 if (s9q28a_4!=. & s9q28a_4!=.a) 
	clonevar 	inla_beca_pub_cant	= s9q28a_5 if (s9q28a_5!=. & s9q28a_5!=.a) 
	clonevar 	inla_beca_pri_cant	= s9q28a_6 if (s9q28a_6!=. & s9q28a_6!=.a) 
	clonevar 	inla_ayuda_pu_cant	= s9q28a_7 if (s9q28a_7!=. & s9q28a_7!=.a)
	clonevar 	inla_ayuda_pr_cant	= s9q28a_8 if (s9q28a_8!=. & s9q28a_8!=.a)
	clonevar 	inla_ayuda_fa_cant	= s9q28a_9 if (s9q28a_9!=. & s9q28a_9!=.a)
	clonevar 	inla_asig_men_cant	= s9q28a_10 if (s9q28a_10!=. & s9q28a_10!=.a)
	clonevar 	inla_otros_cant		= s9q28a_11 if (s9q28a_11!=. & s9q28a_11!=.a)
	clonevar	inla_petro_cant		= s9q28_petromonto if (s9q28_petromonto!=. & s9q28_petromonto!=.a)
	
	*** In which currency?
	/* s9q28b_* En qué moneda?: *_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar    inla_pens_soi_mone	= s9q28b_1 if (s9q28b_1!=. & s9q28b_1!=.a) 
	clonevar    inla_pens_vss_mone	= s9q28b_2 if (s9q28b_2!=. & s9q28b_2!=.a) 
	clonevar    inla_jubi_emp_mone	= s9q28b_3 if (s9q28b_3!=. & s9q28b_3!=.a) 
	clonevar    inla_pens_dsa_mone	= s9q28b_4 if (s9q28b_4!=. & s9q28b_4!=.a) 
	clonevar 	inla_beca_pub_mone	= s9q28b_5 if (s9q28b_5!=. & s9q28b_5!=.a) 
	clonevar 	inla_beca_pri_mone	= s9q28b_6 if (s9q28b_6!=. & s9q28b_6!=.a) 
	clonevar 	inla_ayuda_pu_mone	= s9q28b_7 if (s9q28b_7!=. & s9q28b_7!=.a)
	clonevar 	inla_ayuda_pr_mone	= s9q28b_8 if (s9q28b_8!=. & s9q28b_8!=.a)
	clonevar 	inla_ayuda_fa_mone	= s9q28b_9 if (s9q28b_9!=. & s9q28b_9!=.a)
	clonevar 	inla_asig_men_mone	= s9q28b_10 if (s9q28b_10!=. & s9q28b_10!=.a)
	clonevar 	inla_otros_mone		= s9q28b_11 if (s9q28b_11!=. & s9q28b_11!=.a)

	
	*** Did you receive last month income for any of the following concepts and how much? (each one is a dummy)
	/* s9q29a__* Con respecto a los últimos 12 meses, ¿recibió ingresos provenientes del extreior por alguno de los siguientes conceptos y cuánto?
				1=Sueldos o salarios
				2=Ingresos netos de los trabajadores independientes
				3=Indemnizaciones por enfermedad o accidente
				4=Remesas o ayudas periódicas de otros hogares del exterior
				5=Pensión y jubilaciones
				6=Intereses y dividendos
				7=Becas y/o ayudas escolares
				8=Transferencias extraordinarias (indemnizaciones por seguro, herencia, ayuda de otros hogares)
				9=Alquileres (vehículos, tierras o terrenos, inmueble residenciales o no)? */
	clonevar    iext_sueldo	= s9q29a__1 if (s9q29a__1!=. & s9q29a__1!=.a) 
	clonevar    iext_ingnet	= s9q29a__2 if (s9q29a__2!=. & s9q29a__2!=.a) 
	clonevar 	iext_indemn	= s9q29a__3 if (s9q29a__3!=. & s9q29a__3!=.a) 
	clonevar 	iext_remesa	= s9q29a__4 if (s9q29a__4!=. & s9q29a__4!=.a) 
	clonevar 	iext_penjub	= s9q29a__5 if (s9q29a__5!=. & s9q29a__5!=.a)
	clonevar 	iext_intdiv	= s9q29a__6 if (s9q29a__6!=. & s9q29a__6!=.a)
	clonevar 	iext_becaes	= s9q29a__7 if (s9q29a__7!=. & s9q29a__7!=.a)
	clonevar 	iext_extrao	= s9q29a__8 if (s9q29a__8!=. & s9q29a__8!=.a)
	clonevar 	iext_alquil	= s9q29a__9 if (s9q29a__9!=. & s9q29a__9!=.a)

	*** Amount discounted
	* s9q29b_*: Monto descontado *_cant
	clonevar    iext_sueldo_cant	= s9q29b_1 if (s9q29b_1!=. & s9q29b_1!=.a) 
	clonevar    iext_ingnet_cant	= s9q29b_2 if (s9q29b_2!=. & s9q29b_2!=.a) 
	clonevar    iext_indemn_cant	= s9q29b_3 if (s9q29b_3!=. & s9q29b_3!=.a) 
	clonevar    iext_remesa_cant	= s9q29b_4 if (s9q29b_4!=. & s9q29b_4!=.a) 
	clonevar 	iext_penjub_cant	= s9q29b_5 if (s9q29b_5!=. & s9q29b_5!=.a) 
	clonevar 	iext_intdiv_cant	= s9q29b_6 if (s9q29b_6!=. & s9q29b_6!=.a) 
	clonevar 	iext_becaes_cant	= s9q29b_7 if (s9q29b_7!=. & s9q29b_7!=.a)
	clonevar 	iext_extrao_cant	= s9q29b_8 if (s9q29b_8!=. & s9q29b_8!=.a)
	clonevar 	iext_alquil_cant	= s9q29b_9 if (s9q29b_9!=. & s9q29b_9!=.a)

	*** In which currency?
	/* s9q29c_* En qué moneda?: *_mone
		1 = Bolívares, 2 = Dólares, 3 = Euros, 4 = Pesos colombianos */
	clonevar    iext_sueldo_mone	= s9q29c_1 if (s9q29c_1!=. & s9q29c_1!=.a) 
	clonevar    iext_ingnet_mone	= s9q29c_2 if (s9q29c_2!=. & s9q29c_2!=.a) 
	clonevar    iext_indemn_mone	= s9q29c_3 if (s9q29c_3!=. & s9q29c_3!=.a) 
	clonevar    iext_remesa_mone	= s9q29c_4 if (s9q29c_4!=. & s9q29c_4!=.a) 
	clonevar 	iext_penjub_mone	= s9q29c_5 if (s9q29c_5!=. & s9q29c_5!=.a) 
	clonevar 	iext_intdiv_mone	= s9q29c_6 if (s9q29c_6!=. & s9q29c_6!=.a) 
	clonevar 	iext_becaes_mone	= s9q29c_7 if (s9q29c_7!=. & s9q29c_7!=.a)
	clonevar 	iext_extrao_mone	= s9q29c_8 if (s9q29c_8!=. & s9q29c_8!=.a)
	clonevar 	iext_alquil_mone	= s9q29c_9 if (s9q29c_9!=. & s9q29c_9!=.a)

	
/*(*********************************************************************************************************************************************** 
*----------------------------------------------- 10: Emigración / Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	

global emigra_ENCOVI informant_emig hogar_emig numero_emig nombre_emig_* edad_emig_* sexo_emig_* relemig_* anoemig_* mesemig_* leveledu_emig_* ///
gradedu_emig_* regedu_emig_* anoedu_emig_* semedu_emig_* paisemig_* opaisemig_* ciuemig_* soloemig_* conemig_* razonemig_* ocupaemig_* ocupnemig_* ///
volvioemig_* volvioanoemig_* volviomesemig_* miememig_*


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
	drop informant_ref
	
	*-- Label variable
	label var informant_emig "0.Informante: Emigracion"
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
	replace  hogar_emig = 0 if s10q1==2
	*-- Label variable
	label var hogar_emig "1.Durante los últimos 5 años, desde septiembre de 2014, ¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país? household left the country" 
	*-- Label values
	label def house_emig 1 "Si" 0 "No"
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
	label var numero_emig "2.Cuántas personas emigraron?"
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
	label var nombre_emig_`i' "2a.Nombre de las personas que emigraron"
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
	label var s10q3_`i' "3.Cuántos años cumplidos tiene el emigrante?"
	*-- Standarization of missing values
	replace s10q3_`i'=. if s10q3_`i'==.a
		*-- Generate variable
		clonevar edad_emig_`i' = s10q3_`i'
		*-- Label variable
		label var edad_emig_`i' "3.Cuántos años cumplidos tiene el emigrante?"
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
	label var s10q4_`i' "4.El sexo de X es?"
	*-- Standarization of missing values
	replace s10q4_`i'=. if s10q4_`i'==.a
		*-- Generate variable
		clonevar sexo_emig_`i' = s10q4_`i'
		replace  sexo_emig_`i' = 0 if sexo_emig_`i'==2
		*-- Label variable
		label var sexo_emig_`i' "4.El sexo del emigrante es?"
		*-- Label values
		label def sexo_emig_`i' 1 "Hombre" 0 "Mujer"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		
	
 /*
 *--------- Relationship of the emigrant with the head of the household
 Relationship (s10q5): 5. Cuál es el parentesco de X con el Jefe(a) del hogar?
        
 */ 
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q5`i' s10q5_`i'
	*-- Label original variable
	label var s10q5_`i' "5.Cuál es el parentesco de X con el Jefe(a) del hogar?"
	*-- Standarization of missing values
	replace s10q5_`i'=. if s10q5_`i'==.a
	*-- Generate variable
	clonevar relemig_`i'  = s10q5_`i'
	replace relemig_`i'  = 1		if  s10q5_`i'==1
	replace relemig_`i'  = 2		if  s10q5_`i'==2
	replace relemig_`i'  = 3		if  s10q5_`i'==3  | s10q5_`i'==4
	replace relemig_`i'  = 4		if  s10q5_`i'==5  
	replace relemig_`i'  = 5		if  s10q5_`i'==6 
	replace relemig_`i'  = 6		if  s10q5_`i'==7
	replace relemig_`i'  = 7		if  s10q5_`i'==8  
	replace relemig_`i'  = 8		if  s10q5_`i'==9
	replace relemig_`i'  = 9		if  s10q5_`i'==10
	replace relemig_`i'  = 10	    if  s10q5_`i'==11
	replace relemig_`i'  = 11	    if  s10q5_`i'==12
	replace relemig_`i'  = 12	    if  s10q5_`i'==13
	*-- Label variable
	label var relemig_`i' "5.Parentesco del emigrante con el Jefe(a) del hogar"
	*-- Label values
	label def remig_`i' 1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" ///
						  4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)"  6 "Padre, madre" 7 "Hermano(a)" ///
						  8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" ///
						  12 "Servicio Domestico"
	label value relemig_`i' remig_`i'
	}
	
	
 *--------- Year in which the emigrant left the household
 /* Year (s10q6a): 6a. En qué año se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename original variable 
	rename s10q6a`i' s10q6a_`i'
	*-- Label original variable
	label var s10q6a_`i' "6a. En qué año se fue X ?"
	*-- Standarization of missing values
	replace s10q6a_`i'=. if s10q6a_`i'==.a
	*-- Generate variable
	clonevar anoemig_`i' = s10q6a_`i'
	*-- Label variable
	label var anoemig_`i' "6a.En qué año emigro"
	*-- Cross check
	tab anoemig_`i' hogar_emig
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (s10q6b): 6a. En qué mes se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename original variable 
	rename s10q6b`i' s10q6b_`i'
	*-- Label original variable
	label var s10q6b_`i' "6b. En qué mes se fue X ?"
	*-- Standarization of missing values
	replace s10q6b_`i'=. if s10q6b_`i'==.a
	*-- Generate variable
	clonevar mesemig_`i' = s10q6b_`i'
	*-- Label variable
	label var mesemig_`i' "6b.En qué mes emigro"
	*-- Cross check
	tab mesemig_`i' hogar_emig
	}


  *--------- Latest education level atained by the emigrant 
 /* Education level (s10q7): 7. Cuál fue el último nivel educativo en el que
							 X aprobó un grado, año, semestre o trimestre?  
			01 Ninguno
			02 Preescolar
			03 Régimen anterior: Básica (1-9)
			04 Régimen anterior: Media Diversificado y Profesional (1-3)
			05 Régimen actual: Primaria (1-6)
			06 Régimen actual: Media (1-6)
			07 Técnico (TSU)
			08 Universitario
			09 Postgrado

 */
 	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q7`i' s10q7_`i'
	*-- Label original variable
	label var s10q7_`i' "7.Cuál fue el último nivel educativo en el que X aprobó un grado, año, semestre o trimestre?"
	*-- Standarization of missing values
	replace s10q7_`i'=. if s10q7_`i'==.a
	*-- Generate variable
	clonevar leveledu_emig_`i' = s10q7_`i'
	*-- Label variable
	label var leveledu_emig_`i' "7.Nivel educativo del emigrante"
	}
	

 *--------- Latest education grade atained by the emigrant 
 /* Education level (s10q7a): 7a. Cuál fue el último GRADO aprobado por X?     
 */	
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7a`i' s10q7a_`i'
	*-- Label original variable
	label var s10q7a_`i' "7a. Cuál fue el último GRADO aprobado por X?"
	*-- Standarization of missing values
	replace s10q7a_`i'=. if s10q7a_`i'==.a
	*-- Generate variable
	clonevar gradedu_emig_`i' = s10q7a_`i'
	*-- Label variable
	label var gradedu_emig_`i' "7a.Ultimo grado aprobado por el emigrante"
	*-- Cross check
	tab gradedu_emig_`i' hogar_emig
	}
	

 *--------- Education regime 
 /* Education regime (s10q7ba): 7ba. El régimen de estudio era anual, semestral o
							   trimestral?
								01 Anual
								02 Semestral
								03 Trimestral     
 */	
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7ba`i' s10q7ba_`i'
	*-- Label original variable
	label var s10q7ba_`i' "7ba. El régimen de estudio era anual, semestral o trimestral?"
	*-- Standarization of missing values
	replace s10q7ba_`i'=. if s10q7ba_`i'==.a
	*-- Generate variable
	clonevar regedu_emig_`i' = s10q7ba_`i'
	*-- Label variable
	label var regedu_emig_`i' "7ba.Régimen de estudio: anual, semestral o trimestral"
	*-- Cross check
	tab regedu_emig_`i' hogar_emig
	*-- Label values
	label def regedu_emig_`i' 1 "Anual" 2 "Semestral" 3 "Trimestral"
	label value regedu_emig_`i' regedu_emig_`i'
	}
	
 *--------- Latest year 
 /* Education regime (s10q7b): 7b. Cuál fue el último AÑO aprobado por X?    
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7b`i' s10q7b_`i'
	*-- Label original variable
	label var s10q7b_`i' "7b. Cuál fue el último AÑO aprobado por X?   "
	*-- Standarization of missing values
	replace s10q7b_`i'=. if s10q7b_`i'==.a
	*-- Generate variable
	clonevar anoedu_emig_`i' = s10q7b_`i'
	*-- Label variable
	label var anoedu_emig_`i' "7b.Ultimo ano educativo aprobado (emigrante)"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (s10q7c): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7c`i' s10q7c_`i'
	*-- Label original variable
	label var s10q7c_`i' "7c.Cuál fue el último SEMESTRE aprobado por X?"
	*-- Standarization of missing values
	replace s10q7c_`i'=. if s10q7c_`i'==.a
	*-- Generate variable
	clonevar semedu_emig_`i' = s10q7b_`i'
	*-- Label variable
	label var semedu_emig_`i' "7c.Ultimo semestre educativo aprobado (emigrante)"
	*-- Cross check
	tab semedu_emig_`i' hogar_emig
	}

  *--------- Country of residence of the emigrant
 /* Country (s10q8): 8. En cuál país vive actualmente X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8`i' s10q8_`i'
	*-- Label original variable
	label var s10q8_`i' "8.En cuál país vive actualmente X?"
	*-- Standarization of missing values
	replace s10q8_`i'=. if s10q8_`i'==.a
	*-- Generate variable
	clonevar paisemig_`i' = s10q8_`i'
	*-- Label variable
	label var paisemig_`i' "8.País en que vive actualmente (emigrante)"
	*-- Cross check
	tab paisemig_`i' hogar_emig
	}

  *--------- Other country of residence 
 /* Other Country (s10q8_os): 8a. Otro país, especifique
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8_os`i' s10q8_os_`i'
	*-- Label original variable
	label var s10q8_os_`i' "8a. Otro país, especifique"
	*-- Standarization of missing values
	replace s10q8_os_`i'="." if s10q8_os_`i'==".a"
	*-- Standarization of other
	replace s10q8_os_`i'="Bolivia" if s10q8_os_`i'=="bolivia"
	replace s10q8_os_`i'="Venezuela" if s10q8_os_`i'=="Venezuela."
	replace s10q8_os_`i'="Arabia" if s10q8_os_`i'=="arabia"
	replace s10q8_os_`i'="Bonaire" if s10q8_os_`i'=="bonaire"
	replace s10q8_os_`i'="Isla San Martin" if s10q8_os_`i'=="isla San Martin"
	*-- Generate variable
	gen opaisemig_`i' = s10q8_os_`i'
	*-- Label variable
	label var opaisemig_`i' "8a.Otro: País en que vive actualmente (emigrante)"
	*-- Cross check
	tab opaisemig_`i' hogar_emig
	}

  *--------- City of residence 
 /* City (s10q8b): 8b. Y en cuál ciudad ?
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8b`i' s10q8b_`i'
	*-- Label original variable
	label var s10q8b_`i' "8b. Y en cuál ciudad ?"
	*-- Standarization of missing values
	replace s10q8b_`i'="." if s10q8b_`i'==".a"
	replace s10q8b_`i'="." if s10q8b_`i'=="##N/A##"
	*-- Standarization of values
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="No Saben"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="No saben"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="No Saben"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="NO RECUERDA"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabe que ciudad" 
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabe la ciudad"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabes"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabe"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabr"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no se acordó del nombre dónde esta"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sé acuerda"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no recuerda el nombre"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no lo recuerda"
	*-- Generate variable
	gen ciuemig_`i' = s10q8b_`i'
	*-- Label variable
	label var ciuemig_`i' "Ciudad en que vive actualmente (emigrante)"
	*-- Cross check
	tab ciuemig_`i' hogar_emig
	}

   *--------- Emigrated alone or not
 /* City (s10q8c): 8c. X emigró solo/a ?	
					01 Si
					02 No
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8c`i' s10q8c_`i'
	*-- Label original variable
	label var s10q8c_`i' "8c. X emigró solo/a?"
	*-- Standarization of missing values
	replace s10q8c_`i'=. if s10q8c_`i'==.a
	*-- Generate variable
	clonevar soloemig_`i' = s10q8c_`i'
	replace  soloemig_`i' = 0 if soloemig_`i' == 2
	*-- Label variable
	label var soloemig_`i' "8c.La persona emigró solo/a"
	*-- Label values
	label def soloemig_`i' 1 "Si" 0 "No"
	label value soloemig_`i' soloemig_`i'
	*-- Cross check
	tab soloemig_`i' hogar_emig
	}


  *--------- Emigrated with other people 
 /*  (s10q8d):8d. Con quién emigró X?				
				01 Padre/madre
				02 Hermano/a
				03 Conyuge/pareja
				04 Hijos/hijas
				05 Otro pariente
				06 No parientes
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8d`i' s10q8d_`i'
	*-- Label original variable
	label var s10q8d_`i' "8d. Con quién emigró X?"
	*-- Standarization of missing values
	replace s10q8d_`i'=. if s10q8d_`i'==.a
	*-- Generate variable
	clonevar conemig_`i' = s10q8d_`i'
	*-- Label variable
	label var conemig_`i' "8d.Con quién emigró?"
	*-- Cross check
	tab conemig_`i' hogar_emig
	} 

  *--------- Reason for leaving the country
 /*  Reason (s10q9_os):9. Cuál fue el motivo por el cual X se fue				
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


  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q9`i' s10q9_`i'
	*-- Label original variable
	label var s10q9_`i' "9. Cuál fue el motivo por el cual X se fue"
	*-- Standarization of missing values
	replace s10q9_`i'=. if s10q9_`i'==.a
	*-- Generate variable
	clonevar razonemig_`i' = s10q9_`i'
	*-- Label variable
	label var razonemig_`i' "9. Cuál fue el motivo por el cual X se fue"
	*-- Cross check
	tab razonemig_`i' hogar_emig
	} 
	
	*-- Other Reasons (s10q9_os)
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q9_os`i' s10q9_os_`i'
	*-- Label original variable
	label var s10q9_os_`i' "9a. Cuál fue el motivo por el cual se fue (otro)"
	*-- Standarization of missing values
	replace s10q9_os_`i'="." if s10q9_os_`i'==".a"
	*-- Generate variable
	clonevar orazonemig_`i' = s10q9_os_`i'
	*-- Label variable
	label var orazonemig_`i' "9a. Cuál fue el motivo por el cual se fue (Otro)"
	*-- Cross check
	tab orazonemig_`i' hogar_emig
	} 

  *--------- Occupation: Before leaving the country
 /*  Occupation before (s10q10):10. Cuál era la ocupación principal de X antes de emigrar?
			
					01 Director o gerente
					02 Profesional científico o intelectual
					03 Técnico o profesional de nivel medio
					04 Personal de apoyo administrativo
					05 Trabajador de los servicios o vendedor de comercios y mercados
					06 Agricultor o trabajador calificado agropecuario, forestal o pesquero
					07 Oficial, operario o artesano de artes mecánicas y otros oficios
					08 Operador de instalaciones fijas y máquinas y maquinarias
					09 Ocupaciones elementales
					10 Ocupaciones militares
					11 No se desempeñaba en alguna ocupación			
 */    
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q10`i' s10q10_`i'
	*-- Label original variable
	label var s10q10_`i' "10. Cuál era la ocupación principal de X antes de emigrar?"
	*-- Standarization of missing values
	replace s10q10_`i'=. if s10q10_`i'==.a
	*-- Generate variable
	clonevar ocupaemig_`i' = s10q10_`i'
	*-- Label variable
	label var ocupaemig_`i' "10.Cuál era la ocupación principal antes de emigrar?"
	*-- Cross check
	tab ocupaemig_`i' hogar_emig
	} 

   *--------- Occupation: in the new country
 /*  Occupation now (s10q11): 11. Qué ocupación tiene X en el país donde vive ?
			
					01 Director o gerente
					02 Profesional científico o intelectual
					03 Técnico o profesional de nivel medio
					04 Personal de apoyo administrativo
					05 Trabajador de los servicios o vendedor de comercios y mercados
					06 Agricultor o trabajador calificado agropecuario, forestal o pesquero
					07 Oficial, operario o artesano de artes mecánicas y otros oficios
					08 Operador de instalaciones fijas y máquinas y maquinarias
					09 Ocupaciones elementales
					10 Ocupaciones militares
					11 No se desempeñaba en alguna ocupación			
 */    
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q11`i' s10q11_`i'
	*-- Label original variable
	label var s10q11_`i' "11.Qué ocupación tiene X en el país donde vive?"
	*-- Standarization of missing values
	replace s10q11_`i'=. if s10q11_`i'==.a
	*-- Generate variable
	gen ocupnemig_`i' = s10q11_`i'
	*-- Label variable
	label var ocupnemig_`i' "11.Qué ocupación tiene en el país donde vive?"
	*-- Cross check
	tab ocupnemig_`i' hogar_emig
	} 

 
    *--------- The emigrant moved back to the country
 /*  Moved back (s10q12): 12. X regresó a residenciarse nuevamente al país?
							01 Si
							02 No
		
 */    
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q12`i' s10q12_`i'
	*-- Label original variable
	label var s10q12_`i' "12.Regresó a residenciarse nuevamente al país?"
	*-- Standarization of missing values
	replace s10q12_`i'=. if s10q12_`i'==.a
	*-- Generate variable
	clonevar volvioemig_`i' = s10q12_`i'
	replace  volvioemig_`i' = 0 if s10q12_`i'==2
	*-- Label variable
	label var volvioemig_`i' "12.Regresó a residenciarse nuevamente al país?"
	*-- Cross check
	tab volvioemig_`i' hogar_emig
	*-- Label values
	label def volvioemig_`i' 1 "Si" 0 "No"
	label value volvioemig_`i' volvioemig_`i'
	} 


     *--------- Year: The emigrant moved back to the country
 /*  Year (s10q13a): 13a. En qué año regresó X?
		
 */    
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q13a`i' s10q13a_`i'
	*-- Label original variable
	label var s10q13a_`i' "13a. En qué año regresó X?"
	*-- Standarization of missing values
	replace s10q13a_`i'=. if s10q13a_`i'==.a
	*-- Generate variable
	gen volvioanoemig_`i' = s10q13a_`i'
	*-- Label variable
	label var volvioanoemig_`i' "Year: X moved back to the country?"
	*-- Cross check
	tab volvioanoemig_`i' hogar_emig
	} 

      *--------- Month: The emigrant moved back to the country
 /*  Month (s10q13b): 13b. En qué mes regresó X?
		
 */ 
 	forval i = 1/10{
	*-- Rename main variable 
	rename s10q13b`i' s10q13b_`i'
	*-- Label original variable
	label var s10q13b_`i' "13b.En qué mes regresó al pais?"
	*-- Standarization of missing values
	replace s10q13b_`i'=. if s10q13b_`i'==.a
	*-- Generate variable
	clonevar volviomesemig_`i' = s10q13b_`i'
	*-- Label variable
	label var volviomesemig_`i' "13b.En qué mes regresó al pais?"
	*-- Cross check
	tab volviomesemig_`i' hogar_emig
	} 

 
      *--------- Member of the household
 /*  Member (s10q14):14. En el presente X forma parte de este hogar?
						01 Si
						02 No
	
 */   
 	forval i = 1/10{
	*-- Rename main variable 
	rename s10q14`i' s10q14_`i'
	*-- Label original variable
	label var s10q14_`i' "14.En el presente el emeigrante forma parte de este hogar?"
	*-- Standarization of missing values
	replace s10q14_`i'=. if s10q14_`i'==.a
	*-- Generate variable
	clonevar miememig_`i' = s10q14_`i'
	replace  miememig_`i' = 0 if s10q14_`i'==2
	*-- Label variable
	label var miememig_`i' "14.En el presente el emigrante forma parte de este hogar?"
	*-- Cross check
	tab miememig_`i' hogar_emig
	*-- Label values
	label def miememig_`i' 1 "Si" 0 "No"
	label value miememig_`i' miememig_`i'
	} 


/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- XI: MORTALITY / MORTALIDAD ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

global mortali_ENCOVI ctoshnosyud ctoshnosme hnohombre1 hnohombre2 hnohombre3 hnohombre4 hnohombre5 hnohombre6 hnohombre7 hnohombre8 hnohombre9 hnohombre10 ///
hnohombre11 hnohombre12 hnohombre13 hnohombre14 hnohombre15 hnohombre16 hnohombre17 hnohombre18 hnohombre19 hnovivo1 hnovivo2 hnovivo3 hnovivo4 hnovivo5 ///
hnovivo6 hnovivo7 hnovivo8 hnovivo9 hnovivo10 hnovivo11 hnovivo12 hnovivo13 hnovivo14 hnovivo15 hnovivo16 hnovivo17 hnovivo18 hnovivo19 hnoedad1 hnoedad2 ///
hnoedad3 hnoedad4 hnoedad5 hnoedad6 hnoedad7 hnoedad8 hnoedad9 hnoedad10 hnoedad11 hnoedad12 hnoedad13 hnoedad14 hnoedad15 hnoedad16 hnoedad17 hnoedad18 ///
hnoedad19 hnocontactoano1 hnocontactoano2 hnocontactoano3 hnocontactoano4 hnocontactoano5 hnocontactoano6 hnocontactoano7 hnocontactoano8 hnocontactoano9 ///
hnocontactoano10 hnocontactoano11 hnocontactoano12 hnocontactoano13 hnocontactoano14 hnocontactoano15 hnocontactoano16 hnocontactoano17 hnocontactoano18 ///
hnocontactoano19 hnocontactomes1 hnocontactomes2 hnocontactomes3 hnocontactomes4 hnocontactomes5 hnocontactomes6 hnocontactomes7 hnocontactomes8 hnocontactomes9 ///
hnocontactomes10 hnocontactomes11 hnocontactomes12 hnocontactomes13 hnocontactomes14 hnocontactomes15 hnocontactomes16 hnocontactomes17 hnocontactomes18 ///
hnocontactomes19 hnofallecioano1 hnofallecioano2 hnofallecioano3 hnofallecioano4 hnofallecioano5 hnofallecioano6 hnofallecioano7 hnofallecioano8 hnofallecioano9 ///
hnofallecioano10 hnofallecioano11 hnofallecioano12 hnofallecioano13 hnofallecioano14 hnofallecioano15 hnofallecioano16 hnofallecioano17 hnofallecioano18 ///
hnofallecioano19 hnofalleciomes1 hnofalleciomes2 hnofalleciomes3 hnofalleciomes4 hnofalleciomes5 hnofalleciomes6 hnofalleciomes7 hnofalleciomes8 hnofalleciomes9 ///
hnofalleciomes10 hnofalleciomes11 hnofalleciomes12 hnofalleciomes13 hnofalleciomes14 hnofalleciomes15 hnofalleciomes16 hnofalleciomes17 hnofalleciomes18 hnofalleciomes19 ///
hnoedadfallecio1 hnoedadfallecio2 hnoedadfallecio3 hnoedadfallecio4 hnoedadfallecio5 hnoedadfallecio6 hnoedadfallecio7 hnoedadfallecio8 hnoedadfallecio9 hnoedadfallecio10 ///
hnoedadfallecio11 hnoedadfallecio12 hnoedadfallecio13 hnoedadfallecio14 hnoedadfallecio15 hnoedadfallecio16 hnoedadfallecio17 hnoedadfallecio18 hnoedadfallecio19

*** How many sons or daughters did your biological mother have, including you?
	* s11q1 Cuántos hijos o hijas tuvo su madre biológica incluyéndolo usted?
	gen		ctoshnosyud = s11q1 if s11q1>=1 & (s11q1!=. & s11q1!=.a)

*** How many of these sons or daughters were born before you?
	* s11q2 Cuántos de estos hijos o hijas nacieron antes de usted?
	gen 	ctoshnosme = s11q2 if (s11q2!=. & s11q2!=.a)
	*Ok nadie contesta que tiene hermanos menores si son hijos únicos
	
*** You can mention the name of your siblings from the same biological mother, starting from the oldest
	* s11q3__* A continuación, puede mencionar el nombre de cada uno de sus hermanos o hermanas nacidos de su madre biológica comenzando por el de mayor edad
	*forvalues i = 0(1)19 {
	*gen 	nombrehno`i' = s11q3__`i' if s11q1>=2 & (s11q3__`i'!=. & s11q3__`i'!=.a)
	*}

* SIBLINGS / HERMANOS

*** Whats the sex of your siblings?
	/*s11q4* Cuál es el sexo de cada uno de sus hermanos/as?
		1= Masculino
		2= Femenino
	*/
	forvalues i = 1(1)19 {
	gen 	hnohombre`i' = 1 if s11q4`i'==1 & s11q1>=2 & (s11q4`i'!=. & s11q4`i'!=.a)
	replace 	hnohombre`i' = 0 if s11q4`i'==2 & s11q1>=2 & (s11q4`i'!=. & s11q4`i'!=.a)
	}
	
*** Are they still alive? (one variable for each)
	/*s11q5* Continúa vivo?
		1=Si
		2=No
		3=No sabe
	*/
	forvalues i = 1(1)19 {
	gen 	hnovivo`i' = s11q5`i' if s11q1>=2 & (s11q5`i'!=. & s11q5`i'!=.a)
	}

*** How old are they? (one variable for each)
	*s11q6* Qué edad tiene?
	forvalues i = 1(1)19 {
	gen 	hnoedad`i' = s11q6`i' if s11q5`i'==1 & s11q1>=2 & (s11q6`i'!=. & s11q6`i'!=.a)
	}

*** In which year did you last have contact with them? (one variable for each - for those who they don't know if alive)
	*s11q7a* En qué año fue la última vez que tuvo contacto con ...? (para aquellos que no sabe si están vivos)
	forvalues i = 1(1)19 {
	gen 	hnocontactoano`i' = s11q7a`i' if s11q5`i'==3 & s11q1>=2 & (s11q7a`i'!=. & s11q7a`i'!=.a)
	}
	
*** In which month did you last have contact with them? (one variable for each - for those who they don't know if alive)
	*s11q7b* En qué mes fue la última vez que tuvo contacto con ...? (para aquellos que no sabe si están vivos)
	forvalues i = 1(1)19 {
	gen 	hnocontactomes`i' = s11q7b`i' if s11q5`i'==3 & s11q1>=2 & (s11q7b`i'!=. & s11q7b`i'!=.a)
	}
	
*** In which year did they die? (one variable for each who passed away)
	*s11q8a* En qué año falleció ...? (para aquellos que fallecieron)
	forvalues i = 1(1)19 {
		gen 	hnofallecioano`i' = s11q8a`i' if s11q5`i'==2 & s11q1>=2 & (s11q8a`i'!=. & s11q8a`i'!=.a)
		}
		
*** In which month did they die? (one variable for each who passed away)
	*s11q8b* En qué mes falleció ...?
	forvalues i = 1(1)19 {
		gen 	hnofalleciomes`i' = s11q8b`i' if s11q5`i'==2 & s11q1>=2 & (s11q8b`i'!=. & s11q8b`i'!=.a)
		}

*** How old was him/her when she/he passed away? (one variable for each who passed away)
	*s11q8c* Qué edad tenía ... cuando falleció?
	forvalues i = 1(1)19 {
		gen 	hnoedadfallecio`i' = s11q8c`i' if s11q5`i'==2 & s11q1>=2 & (s11q8c`i'!=. & s11q8c`i'!=.a)
		}

/*(************************************************************************************************************************************************* 
*----------------------------------- XII: FOOD CONSUMPTION / CONSUMO DE ALIMENTO --------------------------------------------------------
*************************************************************************************************************************************************)*/

global foodcons_ENCOVI clap clap_cuando

*Most variables are part of the consumption module, but we will add the 2 questions on CLAP here

*** This household has been beneficiary of the "Bolsa-Caja" of CLAP for households?
	/* s12aq10 Este hogar es/ha sido beneficiario de la Bolsa-Caja del CLAP?
				1 = si
				2 = no	*/
		*Note: For part-time workers, i.e. worked less than 35 hs s9q18<35 // CAPI4==true
	gen 	clap = s12aq10==1 if (s12aq10!=. & s12aq10!=.a)
	
*** When was the last time that the "Bolsa-Caja" CLAP arrived to the household?
	/* s12aq10_a Cuándo fue la última vez que llegó la Bolsa-Caja del CLAP al hogar?
				1 = Últimos 7 días
				2 = Últimos 15 días
				3 = Más de 15 días	*/
	gen 	clap_cuando = s12aq10_a if s12aq10==1 & (s12aq10_a!=. & s12aq10_a!=.a)


/*(************************************************************************************************************************************************ 
*----------------------------------------------------- XIII: FOOD SAFETY / SEGURIDAD ALIMENTARIA --------------------------------------------------
************************************************************************************************************************************************)*/

global segalimentaria_ENCOVI ingsuf_comida preocucomida_norecursos faltacomida_norecursos nosaludable_norecursos pocovariado_norecursos salteacomida_norecursos comepoco_norecursos ///
hambre_norecursos nocomedia_norecursos pocovariado_me18_norecursos salteacomida_me18_norecursos comepoco_me18_norecursos nocomedia_me18_norecursos comida_trueque

*** Do you believe that the income of the household is sufficient for buying groceries/food to consume inside and outside the household?
	/*s13q1 Considera usted que el ingreso del hogar es suficiente para la compra de alimentos/comida para consumir dentro y fuera del hogar?
			1=Si
			2=No 
	*/
	gen 	ingsuf_comida = s13q1==1 if (s13q1!=. & s13q1!=.a)

*** During the last month, due to lack of money or other resources, did...
	*DURANTE EL ÚLTIMO MES, POR FALTA DE DINERO U OTROS RECURSOS, ¿ALGUNA VEZ…
		/* 	1=Si
			2=No */
	
	* ...you worry about food running out in your household?
		*s13q2_1 ...usted se preocupó porque los alimentos se acabaran en su hogar? 
		gen 	preocucomida_norecursos = s13q2_1==1 	if (s13q2_1!=. & s13q2_1!=.a)

	* ...your household run out of food? 
		* s13q2_2 ...en su hogar se quedaron sin alimentos?
		gen 	faltacomida_norecursos = s13q2_2==1 	if (s13q2_2!=. & s13q2_2!=.a)

	* ...your household stop having a healthy diet? (meat, fish, vegetables, fruits, cereals)
		* s13q2_3 ...en su hogar dejaron de tener una alimentación saludable (contiene carnes, pescados, verduras, hortalizas, frutas, cereales)?
		gen 	nosaludable_norecursos = s13q2_3==1 	if (s13q2_3!=. & s13q2_3!=.a)

	* ...you or any adult in your household fed based on a low variety of food types? (always eat the same)
		* s13q2_4 ...usted o algún adulto en su hogar tuvo una alimentación basada en poca variedad de alimentos (siempre come lo mismo)?
		gen 	pocovariado_norecursos = s13q2_4==1 	if (s13q2_4!=. & s13q2_4!=.a)

	* ...you or an adult in your house stopped eating breakfast, lunch or dinner?
		* s13q2_5 ...usted o algún adulto en su hogar dejó de desayunar, almorzar o cenar?
		gen 	salteacomida_norecursos = s13q2_5==1 	if (s13q2_5!=. & s13q2_5!=.a)

	* ...you or an adult in your household ate less than what he/she should eat?
		* s13q2_6 ...usted o algún adulto en su hogar comió menos de lo que debía comer?
		gen 	comepoco_norecursos = s13q2_6==1 		if (s13q2_6!=. & s13q2_6!=.a)
	
	* ...you or an adult in your household felt hunger but didn't eat?
		* s13q2_7 ...usted o algún adulto en su hogar sintió hambre pero no comió?
		gen 	hambre_norecursos = s13q2_7==1 			if (s13q2_7!=. & s13q2_7!=.a)
	
	* ...you or an adult in your household only ate once a day, or stopped eating during a whole day?
		* s13q2_8 ...usted o algún adulto en su hogar sólo comió una vez al día, o dejó de comer durante todo un día?
		gen 	nocomedia_norecursos = s13q2_8==1 		if (s13q2_8!=. & s13q2_8!=.a)
	
	* ...any person younger than 18 years old in your household fed based on a low variety of food types? 
		* s13q2_9 ...algún menor de 18 años en su hogar tuvo una alimentación basada en poca variedad de alimentos?
		gen 	pocovariado_me18_norecursos = s13q2_9==1 if (s13q2_9!=. & s13q2_9!=.a)
		
	* ...any person younger than 18 years old in your household stopped eating breakfast, lunch or dinner?
		* s13q2_10 ...algún menor de 18 años en su hogar dejó de desayunar, almorzar o cenar?
		gen 	salteacomida_me18_norecursos = s13q2_10==1 if (s13q2_10!=. & s13q2_10!=.a)
	
	* ...you ever had to dimish the portions served to any person younger than 18 years old?
		* s13q2_11 ...tuvieron que disminuir la cantidad servida en las comidas a algún menor de 18 años en su hogar?
		gen 	comepoco_me18_norecursos = s13q2_11==1 	if (s13q2_11!=. & s13q2_11!=.a)
	
	* ...any person younger than 18 years old in your household only ate once a day, or stopped eating during a whole day?
		* s13q2_12 ...algún menor de 18 años en su hogar solo comió una vez al día, o dejó de comer durante todo un día?
		gen 	nocomedia_me18_norecursos = s13q2_12==1 if (s13q2_12!=. & s13q2_12!=.a)
		
*** During the last month, due to lack of money, did you or an adult in your household had to make in-kind payments or barter to consume food?
	/* s13q3 Durante el último mes, por falta de dinero, ¿alguna vez usted o algún adulto en su hogar tuvo que hacer pagos en especie o trueque para consumir alimentos?
			1=Si
			2=No 
	*/
	gen 	comida_trueque = s13q3==1 if (s13q3!=. & s13q3!=.a)
		
/*(************************************************************************************************************************************************ 
*---------------------------------------- XV: SHOCKS AFFECTING HOUSEHOLDS / EVENTOS QUE AFECTAN A LOS HOGARES -------------------------------------
************************************************************************************************************************************************)*/

global shocks_ENCOVI informant_shock evento_* evento_ot imp_evento_* veces_evento_* ano_evento_* ///
reaccion_evento_* reaccionot_evento*


*--------- Informant in this section
 /* Informante (s15q00): 00. Quién es el informante de esta sección?
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
	tab s15q00, mi
	*-- Standarization of missing values
	replace s15q00=. if s15q00==.a
	*-- Create auxiliary variable
	clonevar informant_ref = s15q00
	*-- Generate variable
	gen     informant_shock  = 1		if  informant_ref==1
	replace informant_shock  = 2		if  informant_ref==2
	replace informant_shock  = 3		if  informant_ref==3  | informant_ref==4
	replace informant_shock  = 4		if  informant_ref==5  
	replace informant_shock  = 5		if  informant_ref==6 
	replace informant_shock  = 6		if  informant_ref==7
	replace informant_shock  = 7		if  informant_ref==8  
	replace informant_shock  = 8		if  informant_ref==9
	replace informant_shock  = 9		if  informant_ref==10
	replace informant_shock  = 10		if  informant_ref==11
	replace informant_shock  = 11		if  informant_ref==12
	replace informant_shock  = 12		if  informant_ref==13
	drop informant_ref
	
	*-- Label variable
	label var informant_shock "Informant: Shocks"
	*-- Label values	
	label def informant_shock  1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" ///
							  4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)"  6 "Padre, madre" 7 "Hermano(a)" ///
							  8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" ///
							  12 "Servicio Domestico"	
	label value informant_shock  informant_shock 


*--------- Events which affected the household
 /* Events(s15q1): 1. Cuáles de los siguientes eventos han afectado a
su hogar desde el año 2017 ?
         0 = No
         1 = Si
 */

	forval i = 1/21{
	*-- Standarization of missing values
	replace s15q1__`i'=. if s15q1__`i'==.a
	tab s15q1__`i', mi
	*-- Label values (main variable)
	label def s15q1__`i' 0 "No" 1 "Si"
	label value s15q1__`i' s15q1__`i'
	*-- Generate variable
	gen evento_`i' = s15q1__`i'
	}

	*-- Other events
	*-- Check
	tab s15q1_os, mi
	*-- Standarization of missing values
	replace s15q1_os="." if s15q1_os==".a"
	gen evento_ot = s15q1_os
	*-- Label variable
	label var evento_ot "1a.Especifique otro choque"
	
 *--------- Most important events
 /* s15q2: 2. De la lista de eventos acontecidos en su hogar desde el año 2017, 
 señale cuáles han sido los 3 más significativos?
Categories: 
			1:Muerte o discapacidad de un miembro adulto del hogar que trabajaba
			2:Muerte de alguien que enviaba remesas al hogar 
			3:Enfermedad de la persona con el ingreso más importante del hogar
			4:Pérdida de un contacto importante, 
			5:Perdida de trabajo de la persona con el ingreso más importante del hogar
			6:Salida del miembro del hogar que generaba ingresos debido a separación/divorcio
			7:Salida del miembro de la familia que generaba ingresos debido al matrimonio
			8:Salida de un miembro del hogar que generaba ingresos por emigración
			9:Fracaso empresarial no agrícola/cierre de negocio o emprendimiento
			10:Robo de cultivos, dinero en efectivo, ganado u otros bienes
			11:Pérdida de cosecha por incendio/sequía/inundaciones
			12:Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento
			13:Vivienda dañada / demolida
			14:Pérdida de propiedad por incendio o inundación
			15:Pérdida de tierras, 16:Muerte de ganado por enfermedad
			17:Incremento en el precio de los insumos
			18:Caída en el precio de los productos
			19:Incremento en el precio de los principales alimentos consumidos
			20:Secuestro/robo/asalto
			21:Otro
        
 */
// Pasa algo raro que no corre cuando se corre de cero pero que se si corre solo este loop anda
// Aunque se rompe el loop crea las variables, asi que no se 
	cap forval i = 1/22 {
	*rename s15q2__`i' s15q2_`i'
	*-- Standarization of missing values
	replace s15q2__`i'=. if s15q2__`i'==.a
	*-- Generate variable
	clonevar imp_evento_`i'=s15q2__`i'
	}
	
	
 *--------- How many times have the shock occurred since 2017
 /* (s15q2a)2a. Cuántas veces ocurrió %rostertitle% desde 2017?
 */

	forval i = 1/21 {
	*-- Label original variable
	label var s15q2a_`i' "2a.Cuántas veces ocurrió el evento desde 2017?"
	*-- Standarization of missing values
	replace s15q2a_`i'=. if s15q2a_`i'==.a
		*-- Generate variable
		clonevar veces_evento_`i' = s15q2a_`i'
		*-- Label variable
		//label var veces_evento_`i' "How many times have the shock occurred since 2017"
		}
		
	
 /*
 *--------- Year of the event
 (s15q2b) 2b. En qué año ocurrió ?
        
 */ 

	forval i = 1/21 {
	*-- Label original variable
	label var s15q2b_`i' "2b.En qué año ocurrió?"
	*-- Standarization of missing values
	replace s15q2b_`i'=. if s15q2b_`i'==.a
	*-- Generate variable
	clonevar ano_evento_`i'  = s15q2b_`i'
	*-- Label variable
	label var ano_evento_`i' "2b.Año en que ocurrió el evento"
	}
	

 *--------- How the houselhold coped with the shock
 /* (s15q2c): 2c. Cómo se las arregló su hogar con el choque más reciente?*/
 
local x 1 2 3 4 5 6 8 9 10 12 13 14 15 16 17 18 19 20 21 22 23 24
	foreach i of local x {
		forval k = 1/21 {
	*-- Rename original variable 
	rename (s15q2c__`i'_`k') (s15q2c_`i'_`k')
	*-- Label original variable
	label var s15q2c_`i'_`k' "2c.Cómo se las arregló su hogar con el choque más reciente?"
	*-- Standarization of missing values
	replace s15q2c_`i'_`k'=. if s15q2c_`i'_`k'==.a
	*-- Generate variable
	clonevar reaccion_evento_`i'_`k' = s15q2c_`i'_`k'
	*-- Label variable
	label var reaccion_evento_`i'_`k' "2c.Cómo se las arregló su hogar con el choque más reciente?"
	*-- Label values
	label def reaccion_evento_`i'_`k' 0 "No codificado" 1 "Venta de ganado" 2 "Venta de terreno" 3 "Venta de propiedad" ///
	4 "Envían niños a vivir con amigos" 5 "Se retiraron los niños de escuela" ///
	6 "Trabajando en otras actividades generadoras de ingreso" ///
	8 "Asistencia recibida de amigos y familia" 9 "Préstamos de amigos y familia" ///
	10 "Tomó un préstamo de una institución financiera" ///
	12 "Miembros del hogar migraron por trabajo" ///
	13 "Compras al crédito" 14 "Pago retrasado de obligaciones" ///
	15 "Vendió la cosecha por adelantado" 16 "Reducción del consumo de alimentos" /// 
	17 "Reducción de consumo de no alimentos" 18 "Usando ahorros" ///
	19 "Asistencia recibida de ONG" 20 "Tomó pago por adelantado de empleador" ///
	21 "Asistencia recibida del gobierno" 22 "Cubierto por un seguro" ///
	23 "No hizo nada" 24 "Otro"
	label val reaccion_evento_`i'_`k' reaccion_evento_`i'_`k'
		}
	}
	
 *--------- Other responses to the event
 /* (s15q2d): 2d. Otro arreglo, especifique */	
	forval i = 1/21 {
	*-- Label original variable
	label var s15q2d_`i' "2d.Otro arreglo, especifique"
	*-- Standarization of missing values
	replace s15q2d_`i'="." if s15q2d_`i'==".a"
	*-- Generate variable
	clonevar reaccionot_evento`i' = s15q2d_`i'
	*-- Label variable
	label var reaccionot_evento`i' "2d.Otro arreglo, especifique"
	*-- Cross check
	tab reaccionot_evento`i'
	}

	
/*(*****************************************************************************************************************************************
*---------------------------------------------------------- 1.9: Income Variables ----------------------------------------------------------
*****************************************************************************************************************************************)*/

global ingreso_ENCOVI ingresoslab_mon_local ingresoslab_mon_afuera ingresoslab_mon ingresoslab_bene ijubi_m icap_m rem itranp_o_m itranp_ns itrane_o_m itrane_ns /*inla_otro*/ inla_extraord

* Check for negative variables
	forvalues i = 1(1)12 {	
	tab s9q19a_`i' if s9q19a_`i'<0
	}
	forvalues i = 1(1)9 {	
	tab s9q21a_`i' if s9q21a_`i'<0
	}
	forvalues i = 1(1)6 {	
	tab s9q20a_`i' if s9q20a_`i'<0
	}
	forvalues i = 1(1)7 {	
	tab s9q22a_`i' if s9q22a_`i'<0
	}
	tab s9q23a if s9q23a<0
	tab s9q24a if s9q24a<0
	tab s9q25a if s9q25a<0
	tab s9q26a if s9q26a<0
	tab s9q27 if s9q27<0
	forvalues i = 1(1)11 {		
	tab s9q28a_`i' if s9q28a_`i'<0
	}
	* One is negative (less than 0), change for 0
	replace s9q28a_11=0 if s9q28a_11<0
	forvalues i = 1(1)9 {
	tab s9q29b_`i' if s9q29b_`i'<0
	}

	* What to do with questions 20, 22, 26 y 27? We take them as "auxiliares", they won't end up counting for the final income aggregates
	
********** A. LABOR INCOME **********
	
****** 9.0. SET-UP ******

* Assumption for our new variables: No response and doesn't apply both are categorized as missing

*** We take all variables we will need to Bolivares of February 2020 (given that we have more sample) ***

*Note: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio
*Note: We used Inflacion verdadera's inflation to build the deflactor
		
	* gen XX_bolfeb = XX		*tipo de cambio	* deflactor a febrero if interview_month=M & moneda=J

	local incomevar19 _1  _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 
	foreach i of local incomevar19 {

		* Bolívares s9q19a`i'_bolfeb = s9q19a`i' * `deflactor11'
			gen s9q19a`i'_bolfeb = s9q19a`i' * `deflactor11'  if interview_month==11 & s9q19b`i'==1 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'				* `deflactor12'	if interview_month==12 & s9q19b`i'==1 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'				* `deflactor1'	if interview_month==1 & s9q19b`i'==1 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'				* `deflactor2' 	if interview_month==2 & s9q19b`i'==1 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'				* `deflactor3'	if interview_month==3 & s9q19b`i'==1 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'				* `deflactor4' 	if interview_month==4 & s9q19b`i'==1 & s9q19a`i'!=. & s9q19a`i'!=.a
		* Dólares
			replace s9q19a`i'_bolfeb = s9q19a`i' * `tc2mes11' * `deflactor11' 	if interview_month==11 & s9q19b`i'==2 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc2mes12' * `deflactor12'	if interview_month==12 & s9q19b`i'==2 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc2mes1' 	* `deflactor1'	if interview_month==1 & s9q19b`i'==2 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc2mes2' 	* `deflactor2' 	if interview_month==2 & s9q19b`i'==2 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc2mes3'	* `deflactor3'	if interview_month==3 & s9q19b`i'==2 & s9q19a`i'!=. & s9q19a`i'!=.a 
			cap replace s9q19a`i'_bolfeb = s9q19a`i' *`tc2mes4'	* `deflactor4' 	if interview_month==4 & s9q19b`i'==2 & s9q19a`i'!=. & s9q19a`i'!=.a
		* Euros
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc3mes11' * `deflactor11'	if interview_month==11 & s9q19b`i'==3 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc3mes12' * `deflactor12'	if interview_month==12 & s9q19b`i'==3 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc3mes1' 	* `deflactor1' 	if interview_month==1 & s9q19b`i'==3 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc3mes2'	* `deflactor2' 	if interview_month==2 & s9q19b`i'==3 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc3mes3'	* `deflactor3'	if interview_month==3 & s9q19b`i'==3 & s9q19a`i'!=. & s9q19a`i'!=.a
			cap replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc3mes4'* `deflactor4' if interview_month==4 & s9q19b`i'==3 & s9q19a`i'!=. & s9q19a`i'!=.a
		* Colombianos
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc4mes11'	* `deflactor11'	if interview_month==11 & s9q19b`i'==4 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc4mes12' * `deflactor12'	if interview_month==12 & s9q19b`i'==4 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc4mes1'	* `deflactor1'	if interview_month==1 & s9q19b`i'==4 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc4mes2'	* `deflactor2' 	if interview_month==2 & s9q19b`i'==4 & s9q19a`i'!=. & s9q19a`i'!=.a
			replace s9q19a`i'_bolfeb = s9q19a`i'	*`tc4mes3'	* `deflactor3'	if interview_month==3 & s9q19b`i'==4 & s9q19a`i'!=. & s9q19a`i'!=.a
			cap replace s9q19a`i'_bolfeb = s9q19a`i'*`tc4mes4' 	* `deflactor4' 	if interview_month==4 & s9q19b`i'==4 & s9q19a`i'!=. & s9q19a`i'!=.a 
	}
		
	local incomevar21 _1 _2 _3 _4 _5 _6 _7 _8 _9
	foreach i of local incomevar21 {
		* Bolívares
			gen s9q21a`i'_bolfeb = s9q21a`i'					* `deflactor11'	if interview_month==11 & s9q21b`i'==1 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'				* `deflactor12'	if interview_month==12 & s9q21b`i'==1 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'				* `deflactor1'	if interview_month==1 & s9q21b`i'==1 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'				* `deflactor2' 	if interview_month==2 & s9q21b`i'==1 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'				* `deflactor3' if interview_month==3 & s9q21b`i'==1 & s9q21a`i'!=. & s9q21a`i'!=.a
			cap replace s9q21a`i'_bolfeb = s9q21a`i'			* `deflactor4' if interview_month==4 & s9q21b`i'==1 & s9q21a`i'!=. & s9q21a`i'!=.a 
		* Dólares
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc2mes11'	* `deflactor11'	if interview_month==11 & s9q21b`i'==2 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc2mes12' * `deflactor12'	if interview_month==12 & s9q21b`i'==2 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc2mes1' 	* `deflactor1'	if interview_month==1 & s9q21b`i'==2 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc2mes2' 	* `deflactor2' 	if interview_month==2 & s9q21b`i'==2 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc2mes3'	* `deflactor3'	if interview_month==3 & s9q21b`i'==2 & s9q21a`i'!=. & s9q21a`i'!=.a
			cap replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc2mes4'* `deflactor4' if interview_month==4 & s9q21b`i'==2 & s9q21a`i'!=. & s9q21a`i'!=.a 
		* Euros
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc3mes11' * `deflactor11'	if  interview_month==11 & s9q21b`i'==3 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc3mes12' * `deflactor12'	if  interview_month==12 & s9q21b`i'==3 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc3mes1' 	* `deflactor1' 	if  interview_month==1 & s9q21b`i'==3 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc3mes2'	* `deflactor2' 	if  interview_month==2 & s9q21b`i'==3 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc3mes3'	* `deflactor3'	if  interview_month==3 & s9q21b`i'==3 & s9q21a`i'!=. & s9q21a`i'!=.a
			cap replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc3mes4'* `deflactor4' if  interview_month==4 & s9q21b`i'==3 & s9q21a`i'!=. & s9q21a`i'!=.a 
		* Colombianos
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc4mes11'	* `deflactor11'	if  interview_month==11 & s9q21b`i'==4 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc4mes12' * `deflactor12'	if  interview_month==12 & s9q21b`i'==4 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc4mes1'	* `deflactor1'	if  interview_month==1 & s9q21b`i'==4 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc4mes2'* `deflactor2' 	if  interview_month==2 & s9q21b`i'==4 & s9q21a`i'!=. & s9q21a`i'!=.a
			replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc4mes3'	* `deflactor3'	if  interview_month==3 & s9q21b`i'==4 & s9q21a`i'!=. & s9q21a`i'!=.a
			cap replace s9q21a`i'_bolfeb = s9q21a`i'	*`tc4mes4'* `deflactor4' if  interview_month==4 & s9q21b`i'==4 & s9q21a`i'!=. & s9q21a`i'!=.a 
		}

	local incomevar23456 23 24 25 26
	foreach i of local incomevar23456 {
		* Bolívares
			gen s9q`i'a_bolfeb = s9q`i'a					* `deflactor11'	if interview_month==11 & s9q`i'b==1 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a				* `deflactor12'	if interview_month==12 & s9q`i'b==1 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a				* `deflactor1'	if interview_month==1 & s9q`i'b==1 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a				* `deflactor2' 	if interview_month==2 & s9q`i'b==1 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a				* `deflactor3'	if interview_month==3 & s9q`i'b==1 & s9q`i'a!=. & s9q`i'a!=.a
			cap replace s9q`i'a_bolfeb = s9q`i'a			* `deflactor4' 	if interview_month==4 & s9q`i'b==1 & s9q`i'a!=. & s9q`i'a!=.a 
		* Dólares
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc2mes11'	* `deflactor11'	if interview_month==11 & s9q`i'b==2 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc2mes12' * `deflactor12'	if interview_month==12 & s9q`i'b==2 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc2mes1' 	* `deflactor1'	if interview_month==1 & s9q`i'b==2 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc2mes2' 	* `deflactor2' 	if interview_month==2 & s9q`i'b==2 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc2mes3'	* `deflactor3'	if interview_month==3 & s9q`i'b==2 & s9q`i'a!=. & s9q`i'a!=.a
			cap replace s9q`i'a_bolfeb = s9q`i'a	*`tc2mes4'* `deflactor4' if interview_month==4 & s9q`i'b==2 & s9q`i'a!=. & s9q`i'a!=.a 
		* Euros
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc3mes11' * `deflactor11'	if interview_month==11 & s9q`i'b==3 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc3mes12' * `deflactor12'	if interview_month==12 & s9q`i'b==3 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc3mes1' 	* `deflactor1' 	if interview_month==1 & s9q`i'b==3 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc3mes2'	* `deflactor2' 	if interview_month==2 & s9q`i'b==3 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc3mes3'	* `deflactor3'	if interview_month==3 & s9q`i'b==3 & s9q`i'a!=. & s9q`i'a!=.a
			cap replace s9q`i'a_bolfeb = s9q`i'a	*`tc3mes4'* `deflactor4' 		if interview_month==4 & s9q`i'b==3 & s9q`i'a!=. & s9q`i'a!=.a 
		* Colombianos
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc4mes11'	* `deflactor11'	if interview_month==11 & s9q`i'b==4 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc4mes12' * `deflactor12'	if interview_month==12 & s9q`i'b==4 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc4mes1'	* `deflactor1'	if interview_month==1 & s9q`i'b==4 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc4mes2'	* `deflactor2'	if interview_month==2 & s9q`i'b==4 & s9q`i'a!=. & s9q`i'a!=.a
			replace s9q`i'a_bolfeb = s9q`i'a	*`tc4mes3'	* `deflactor3'	if interview_month==3 & s9q`i'b==4 & s9q`i'a!=. & s9q`i'a!=.a
			cap replace s9q`i'a_bolfeb = s9q`i'a	*`tc4mes4'* `deflactor4'if interview_month==4 & s9q`i'b==4 & s9q`i'a!=. & s9q`i'a!=.a /
		}
	
	local incomevar27 27
	foreach i of local incomevar27 {
		* Bolívares
			gen s9q`i'_bolfeb = s9q`i'					* `deflactor11'	if interview_month==11 & s9q`i'a==1 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'				* `deflactor12'	if interview_month==12 & s9q`i'a==1 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'				* `deflactor1'	if interview_month==1 & s9q`i'a==1 & s9q`i'!=. & s9q`i'!=.a 
			replace s9q`i'_bolfeb = s9q`i'				* `deflactor2'	if interview_month==2 & s9q`i'a==1 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'				* `deflactor3'	if interview_month==3 & s9q`i'a==1 & s9q`i'!=. & s9q`i'!=.a
			cap replace s9q`i'_bolfeb = s9q`i'			* `deflactor4'	if interview_month==4 & s9q`i'a==1 & s9q`i'!=. & s9q`i'!=.a 
		* Dólares
			replace s9q`i'_bolfeb = s9q`i'	*`tc2mes11'	* `deflactor11'	if interview_month==11 & s9q`i'a==2 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc2mes12' * `deflactor12'	if interview_month==12 & s9q`i'a==2 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc2mes1' 	* `deflactor1'	if interview_month==1 & s9q`i'a==2 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc2mes2'  * `deflactor2'	if interview_month==2 & s9q`i'a==2 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc2mes3'	* `deflactor3'	if interview_month==3 & s9q`i'a==2 & s9q`i'!=. & s9q`i'!=.a
			cap replace s9q`i'_bolfeb = s9q`i'	*`tc2mes4' *`deflactor4' if interview_month==4 & s9q`i'a==2 & s9q`i'!=. & s9q`i'!=.a 
		* Euros
			replace s9q`i'_bolfeb = s9q`i'	*`tc3mes11' * `deflactor11'	if interview_month==11 & s9q`i'a==3 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc3mes12' * `deflactor12'	if interview_month==12 & s9q`i'a==3 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc3mes1' 	* `deflactor1' 	if interview_month==1 & s9q`i'a==3 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc3mes2'  * `deflactor2' 	if interview_month==2 & s9q`i'a==3 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc3mes3'	* `deflactor3'	if interview_month==3 & s9q`i'a==3 & s9q`i'!=. & s9q`i'!=.a
			cap replace s9q`i'_bolfeb = s9q`i'	*`tc3mes4'* `deflactor4' if interview_month==4 & s9q`i'a==3 & s9q`i'!=. & s9q`i'!=.a 
		* Colombianos
			replace s9q`i'_bolfeb = s9q`i'	*`tc4mes11'	* `deflactor11'	if interview_month==11 & s9q`i'a==4 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc4mes12' * `deflactor12'	if interview_month==12 & s9q`i'a==4 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc4mes1'	* `deflactor1'	if interview_month==1 & s9q`i'a==4 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc4mes2'	* `deflactor2'  if interview_month==2 & s9q`i'a==4 & s9q`i'!=. & s9q`i'!=.a
			replace s9q`i'_bolfeb = s9q`i'	*`tc4mes3'	* `deflactor3'	if interview_month==3 & s9q`i'a==4 & s9q`i'!=. & s9q`i'!=.a
			cap replace s9q`i'_bolfeb = s9q`i'	*`tc4mes4'* `deflactor4' if interview_month==4 & s9q`i'a==4 & s9q`i'!=. & s9q`i'!=.a 
		}

	local incomevar28 _1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11
	foreach i of local incomevar28 {
		* Bolívares
			gen s9q28a`i'_bolfeb = s9q28a`i'					* `deflactor11'	if  interview_month==11 & s9q28b`i'==1 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'				* `deflactor12'	if  interview_month==12 & s9q28b`i'==1 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'				* `deflactor1'	if  interview_month==1 & s9q28b`i'==1 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'				* `deflactor2'	if  interview_month==2 & s9q28b`i'==1 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'				* `deflactor3'	if  interview_month==3 & s9q28b`i'==1 & s9q28b`i'!=. & s9q28b`i'!=.a
			cap replace s9q28a`i'_bolfeb = s9q28a`i'			* `deflactor4'	if  interview_month==4 & s9q28b`i'==1 & s9q28b`i'!=. & s9q28b`i'!=.a 
		* Dólares
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc2mes11'	* `deflactor11'	if  interview_month==11 & s9q28b`i'==2 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc2mes12' * `deflactor12'	if  interview_month==12 & s9q28b`i'==2 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc2mes1' 	* `deflactor1'	if  interview_month==1 & s9q28b`i'==2 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc2mes2'  * `deflactor2' 	if  interview_month==2 & s9q28b`i'==2 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc2mes3'	* `deflactor3'	if  interview_month==3 & s9q28b`i'==2 & s9q28b`i'!=. & s9q28b`i'!=.a
			cap replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc2mes4'* `deflactor4'	if  interview_month==4 & s9q28b`i'==2 & s9q28b`i'!=. & s9q28b`i'!=.a 
		* Euros
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc3mes11' * `deflactor11'	if  interview_month==11 & s9q28b`i'==3 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc3mes12' * `deflactor12'	if  interview_month==12 & s9q28b`i'==3 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc3mes1' 	* `deflactor1' 	if  interview_month==1 & s9q28b`i'==3 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc3mes2'	* `deflactor2' 	if  interview_month==2 & s9q28b`i'==3 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc3mes3'	* `deflactor3'	if  interview_month==3 & s9q28b`i'==3 & s9q28b`i'!=. & s9q28b`i'!=.a 
			cap replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc3mes4'	* `deflactor4' if  interview_month==4 & s9q28b`i'==3 & s9q28b`i'!=. & s9q28b`i'!=.a 
		* Colombianos
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc4mes11'	* `deflactor11'	if  interview_month==11 & s9q28b`i'==4 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc4mes12' * `deflactor12'	if interview_month==12 & s9q28b`i'==4 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc4mes1'	* `deflactor1'	if interview_month==1 & s9q28b`i'==4 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc4mes2'	* `deflactor2'	if interview_month==2 & s9q28b`i'==4 & s9q28b`i'!=. & s9q28b`i'!=.a
			replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc4mes3'	* `deflactor3'	if interview_month==3 & s9q28b`i'==4 & s9q28b`i'!=. & s9q28b`i'!=.a 
			cap replace s9q28a`i'_bolfeb = s9q28a`i'	*`tc4mes4' * `deflactor4' if interview_month==4 & s9q28b`i'==4 & s9q28b`i'!=. & s9q28b`i'!=.a 
		}

	local incomevar29 _1 _2 _3 _4 _5 _6 _7 _8 _9
	foreach i of local incomevar21 {
		* Bolívares
			gen s9q29b`i'_bolfeb = s9q29b`i'					* `deflactor11'	if interview_month==11 & s9q29c`i'==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'				* `deflactor12'	if interview_month==12 & s9q29c`i'==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'				* `deflactor1'	if interview_month==1 & s9q29c`i'==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'				* `deflactor2' if interview_month==2 & s9q29c`i'==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'				* `deflactor3'	if interview_month==3 & s9q29c`i'==1 & s9q29b`i'!=. & s9q29b`i'!=.a
			cap replace s9q29b`i'_bolfeb = s9q29b`i'	     	* `deflactor4'	if interview_month==4 & s9q29c`i'==1 & s9q29b`i'!=. & s9q29b`i'!=.a 
		* Dólares
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc2mes11'	* `deflactor11'	if interview_month==11 & s9q29c`i'==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc2mes12' * `deflactor12'	if interview_month==12 & s9q29c`i'==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc2mes1' 	* `deflactor1'	if interview_month==1 & s9q29c`i'==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc2mes2' 	* `deflactor2' 	if interview_month==2 & s9q29c`i'==2 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc2mes3'	* `deflactor3'	if interview_month==3 & s9q29c`i'==2 & s9q29b`i'!=. & s9q29b`i'!=.a 
			cap replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc2mes4'* `deflactor4'	if interview_month==4 & s9q29c`i'==2 & s9q29b`i'!=. & s9q29b`i'!=.a 
		* Euros
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc3mes11' * `deflactor11'	if interview_month==11 & s9q29c`i'==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc3mes12' * `deflactor12'	if interview_month==12 & s9q29c`i'==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc3mes1' 	* `deflactor1' 	if interview_month==1 & s9q29c`i'==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc3mes2'	* `deflactor2' 	if interview_month==2 & s9q29c`i'==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc3mes3'	* `deflactor3'	if interview_month==3 & s9q29c`i'==3 & s9q29b`i'!=. & s9q29b`i'!=.a
			cap replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc3mes4'* `deflactor4' if interview_month==4 & s9q29c`i'==3 & s9q29b`i'!=. & s9q29b`i'!=.a 
		* Colombianos
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc4mes11'	* `deflactor11'	if interview_month==11 & s9q29c`i'==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc4mes12' * `deflactor12'	if interview_month==12 & s9q29c`i'==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc4mes1'	* `deflactor1'	if interview_month==1 & s9q29c`i'==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc4mes2'	* `deflactor2' 	if interview_month==2 & s9q29c`i'==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc4mes3'	* `deflactor3'	if interview_month==3 & s9q29c`i'==4 & s9q29b`i'!=. & s9q29b`i'!=.a
			cap replace s9q29b`i'_bolfeb = s9q29b`i'	*`tc4mes4'* `deflactor4' if interview_month==4 & s9q29c`i'==4 & s9q29b`i'!=. & s9q29b`i'!=.a 
		}

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

		* MONETARY PAYMENTS (s9q19_petro): Received payment through Petro (mostly for aguinaldo) // Added in the last questionnaire update
		* MONTO (s9q19_petromonto): Amount received
		
		* MONETARY PAYMENTS (s9q29a): Con respecto a los últimos 12 meses: ¿recibió ingresos provenientes del exterior por alguno de los siguientes conceptos y cuánto:
			1=Sueldos o salarios
			2=Ingresos netos de los trabajadores independientes
			...
		* MONTO (s9q29b_*): Amount received
		* CURRENCY (s9q29c_*): Currency  
		
	* For employers (s9q15==5)	
		* MONETARY PAYMENTS (s9q23): ¿El mes pasado recibió dinero por la venta de los productos, bienes o servicios de su negocio o actividad? (only for employers, s9q15==5)
			1 = si
			2 = no
		* MONTO (s9q23a): Amount received
		* CURRENCY (s9q23b): Currency
		
	* For self-employed (s9q15==6)
		* MONETARY PAYMENTS (s9q25): Durante los últimos doce (12) meses, recibió dinero por ganancias o utilidades netas derivadas del negocio o actividad?
			1 = si
			2 = no
		* MONTO (s9q25a): Amount received
		* CURRENCY (s9q25b): Currency
		
			* For monthly analysis (no taken into account here because of inconsistencies in the results, e.g. negative income because of people who answer q27 and not q26, or there may be confusion with time span with q25):
			* MONETARY PAYMENTS (s9q26): El mes pasado, recibió ingresos por su actividad para gastos propios o de su hogar?
				*Obs: this question seemed to be elaborated to represent non-monetary payments but the execution makes it seem more monetary so we added it here.
			* SUBSTRACTED FROM MONETARY PAYMENTS (s9q27): El mes pasado, ¿cuánto dinero gastó para generar el ingreso (p.e. alquiler de oficina, gastos de transporte, productos de limpieza)?
*/


* Creating local (not foreign) variables

	* Note: while respondants can register different concepts with different currencies, they can't register one concept with multiple currencies (ej. "sueldo y salario" paid in 2 different currencies) 
	
	gen ingresoslab_mon_local = .
	
	*For the not self-employed nor employers (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9)
		forvalues i = 1(1)12 {
		replace ingresoslab_mon_local = ingresoslab_mon_local + s9q19a_`i'_bolfeb 	if ingresoslab_mon_local!=. & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q19a_`i'!=. & s9q19a_`i'!=.a)
		replace ingresoslab_mon_local = s9q19a_`i'_bolfeb 							if ingresoslab_mon_local==. & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q19a_`i'!=. & s9q19a_`i'!=.a)
			* Obs: First line is for the first not missing one to add up, second line is for the next ones to add up (same later for employers and self-employed)
			* Obs: The last parenthesis controls for cases where they say they were paid in a certain money, but don't say how much (same later for employers and self-employed)
	}
		gen ingresoslab_monpe = . 	// Those who received payment in Petro
		replace ingresoslab_monpe = s9q19_petromonto 	if s9q19_petro==1 & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q19_petro!=. & s9q19_petro!=.a)	// Al final no usamos esto
		gen ingresoslab_monpe_dummy = .
		replace ingresoslab_monpe_dummy = 1 	if ingresoslab_monpe>=0 & ingresoslab_monpe!=.
		* Assumption: Dado que la gente contestaba números muy raros sobre lo que cobró en petro, vamos a asumir 1/2, que es el valor del aguinaldo/pensiones recibidas. También asumiremos que 1 petro=$US 30
		gen ingresoslab_monpe_bolfeb  = ingresoslab_monpe_dummy	* 30 * 73460.1238 		if ingresoslab_monpe_dummy==1
	
	*For employers (s9q15==5)
		replace ingresoslab_mon_local = ingresoslab_mon_local + s9q23a_bolfeb 	if ingresoslab_mon_local!=. & s9q15==5 & (s9q23a!=. & s9q23a!=.a) 
		replace ingresoslab_mon_local = s9q23a_bolfeb 							if ingresoslab_mon_local==. & s9q15==5 & (s9q23a!=. & s9q23a!=.a) 
		
	*For self-employed (s9q15==6)
		* Special case: We will use what they report they earned (q26a) and spent (q27) last month, as long as their substraction is not negative and as long as both are not missing.
		* If not, we will use the yearly data (q25a) divided by 12 when available.
		
		gen indep_ingneto_mens 	= cond(missing(s9q26a_bolfeb), ., s9q26a_bolfeb) - cond(missing(s9q27_bolfeb), 0, s9q27_bolfeb)
		gen indep_registraingpaglabmon_men = 1 if (s9q26a_bolfeb>=0 & s9q26a_bolfeb!=. & s9q26a_bolfeb!=.a) & (s9q27_bolfeb>=0 & s9q27_bolfeb!=. & s9q27_bolfeb!=.a)
		gen indep_usamos_mens = 1 if indep_registraingpaglabmon_men==1 & indep_ingneto_mens>=0

		replace ingresoslab_mon_local = ingresoslab_mon_local + indep_ingneto_mens	if ingresoslab_mon_local!=. & s9q15==6 & indep_usamos_mens==1
		replace ingresoslab_mon_local = indep_ingneto_mens							if ingresoslab_mon_local==. & s9q15==6 & indep_usamos_mens==1
		
		replace ingresoslab_mon_local = ingresoslab_mon_local + s9q25a_bolfeb / 12	if ingresoslab_mon_local!=. & s9q15==6 & (s9q25a!=. & s9q25a!=.a) & indep_usamos_mens!=1
		replace ingresoslab_mon_local = s9q25a_bolfeb / 12 							if ingresoslab_mon_local==. & s9q15==6 & (s9q25a!=. & s9q25a!=.a) & indep_usamos_mens!=1
				
		
	/* Note: by February 25, of the people that reported having monetary payments, 81.4% reported having at least one in Bolívares, 7.8% in Dollars, 8.9% in Colombian pesos, none in Euros, and 11% in Petro (employers and self employed use foreign currency more).
	* Check: OK porque a Febrero 26, 4374 reportes de monedas - 480 repetidos + 123 que no reportan ninguna moneda = 3934 - 480 + 123 = 4017, el total que reportan haber recibido ingreso laboral monetario
		gen noreporta=1 if ingresoslab_mon1_dummy==0 & ingresoslab_mon2_dummy==0 & ingresoslab_mon3_dummy==0 & ingresoslab_mon4_dummy==0 & ingresoslab_monpe_dummy==0
		egen cuantasreporta=rowtotal(ingresoslab_mon1_dummy ingresoslab_mon2_dummy ingresoslab_mon3_dummy ingresoslab_mon4_dummy ingresoslab_monpe_dummy)
		tab cuantasreporta
		tab noreporta
		drop noreporta cuantasreporta */
		tab relab, sum(ingresoslab_mon_local)
	
		rename ingresoslab_mon_local ingresoslab_mon_local_sinpetro 
		
	egen ingresoslab_mon_local = rowtotal(ingresoslab_mon_local_sinpetro ingresoslab_monpe_bolfeb), missing
	
			
* Creating foreign variables (salary or net income for independent workers)
	
	gen ingresoslab_mon_afuera = .
	foreach i of numlist 1 2 {
		replace ingresoslab_mon_afuera = ingresoslab_mon_afuera + s9q29b_`i'_bolfeb / 12 	if ingresoslab_mon_afuera!=. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		replace ingresoslab_mon_afuera = s9q29b_`i'_bolfeb / 12 							if ingresoslab_mon_afuera==. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}
	
* Monetary labor income (local and foreign)

	egen ingresoslab_mon = rowtotal(ingresoslab_mon_local ingresoslab_mon_afuera), missing
	sum ingresoslab_mon
	

	
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
		* MONTO (s9q24a): Amount received, or estimation of how much they would have paid for the benefit
		* CURRENCY (s9q24b): Currency
*/
		
	gen ingresoslab_bene = .
		
	forvalues i = 1(1)9 {
			
		*For the not self-employed or employers (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9)
		replace ingresoslab_bene = ingresoslab_bene + s9q21a_`i'_bolfeb if ingresoslab_bene!=. & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q21a_`i'!=. & s9q21a_`i'!=.a)
		replace ingresoslab_bene = s9q21a_`i'_bolfeb 					if ingresoslab_bene==. & (s9q15==1 | s9q15==3 | s9q15==7 | s9q15==8 | s9q15==9) & (s9q21a_`i'!=. & s9q21a_`i'!=.a)
		* Obs: First line is for the first not missing one to add up, second line is for the next ones to add up (same later for employers)
		* Obs: The last parenthesis controls for cases where they say they received benefits, but don't say how much (same later for employers)
	}
		*For employers (s9q15==5)
		replace ingresoslab_bene = ingresoslab_bene + s9q24a_bolfeb if ingresoslab_bene!=. & s9q15==5 & (s9q24!=. & s9q24a!=.a)
		replace ingresoslab_bene = s9q24a_bolfeb 					if ingresoslab_bene==. & s9q15==5 & (s9q24!=. & s9q24a!=.a)
			
		sum ingresoslab_bene

	/* Note: by February 26, of the people who reported having benefits, 89.5% reported their value in Bolívares, 2.7% in Dollars, 6.2% in Colombian pesos, and none in Euros.
	* Corroboro: OK porque a Feb26 367 reportan en una u otra moneda, más 9 que no reportan ninguna moneda, menos 3 que repiten monedas = 367-9+3 = 373, el total que reportan haber recibido ingreso laboral no monetario
		gen noreporta=1 if ingresoslab_bene1_dummy==0 & ingresoslab_bene2_dummy==0 & ingresoslab_bene3_dummy==0 & ingresoslab_bene4_dummy==0
		egen cuantasreporta=rowtotal(ingresoslab_bene1_dummy ingresoslab_bene2_dummy ingresoslab_bene3_dummy ingresoslab_bene4_dummy)
		tab cuantasreporta
		tab noreporta
		drop noreporta cuantasreporta */

	
****** 9.1.PRIMARY LABOR INCOME ******

/*
ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia */


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

	
***** iv) AGREGADO POR NOSOTROS: relab=. pero ganan dinero
		// (como se les pregunta el dinero que ganan con base anual, 
		//por lo que puede haber gente no ocupada -medido en la última semana- que gana ingreso laboral)

	gen irelabmisspr_m = ingresoslab_mon if inlist(relab,.,5) & ingresoslab_mon!=.
	
	gen irelabmisspr_nm = ingresoslab_bene if inlist(relab,.,5) & ingresoslab_mon!=.

	
****** 9.2. SECONDARY LABOR INCOME ******
*The survey does not differenciate between both

	* Monetary
	gen     ipatrnp_m = .
	gen     iasalnp_m = .
	gen     ictapnp_m = .
	gen     iolnp_m=.
	*gen 	irelabmissnp_m=.
	
	* Non-monetary
	gen     ipatrnp_nm = .
	gen     iasalnp_nm = .
	gen     ictapnp_nm = .
	gen     iolnp_nm = .
	*gen 	irelabmissnp_nm=.

		
********** B. NON-LABOR INCOME **********

****** 9.3.NON-LABOR INCOME ******
/* Incluye 
	1) Jubilaciones y pensiones
	2) Ingresos de capital (capital, intereses, alquileres, rentas, beneficios y dividendos)
	3) Transferencias privadas y estatales
*/

*Organization
	*Locales (no provenientes del exterior)
		*Jubilaciones y pensiones // ijubi_m
			* s9q28__1==1 // Pensión de incapacidad, orfandad, sobreviviente
			* s9q28__2==1 // Pensión de vejez por el seguro social
			* s9q28__3==1 // Jubilación por trabajo
			* s9q28__4==1 // Pensión por divorcio, separación, alimentación
			* s9q28_petro==1 // Petro - Dado como pago de pensión  // Added in the last questionnaire update
		*Transferencias estatales // itrane_o_m 
			* s9q28__5==1 // Beca o ayuda escolar pública 
			* s9q28__7==1 // Ayuda de instituciones públicas
		*Transferencias privadas // itranp_o_m 
			* s9q28__6==1 // Beca o ayuda escolar privada
			* s9q28__8==1 // Ayuda de instituciones privadas
			* s9q28__9==1 // Ayudas familiares o contribuciones de otros hogares
			* s9q28__10==1 // Asignación familiar por menores a su cargo
		*Transferencias (no claro si públicas o privadas) // otro - itrane_ns 	
			* s9q28__11==1 
	*Provenientes del exterior
		*Jubilaciones y pensiones
			* s9q29a__5==1 // Pensión y jubilaciones // ijubi_m
		*Transferencias privadas y estatales
			* s9q29a__4==1 // Remesas o ayudas periódicas de otros hogares del exterior  //  rem
			* s9q29a__7==1 // Becas y/o ayudas escolares // itranp_ns
		*Ingresos de capital //  icap_m
			* s9q29a__6==1 // Intereses y dividendos
			* s9q29a__9==1 // Alquileres (vehículos, tierras o terrenos, inmueble residenciales o no)
		* Ingresos no laborales extraordinarios
			* s9q29a__8==1 // Transferencias extraordinarias (indemnizaciones por seguro, herencia, ayuda de otros hogares)  //  inla_extraord o inla_otro
			* s9q29a__3==1 // Indemnizaciones por enfermedad o accidente  //  inla_extraord o inla_otro

  
****** 9.3.1.JUBILACIONES Y PENSIONES ******	  
	
	/* 	s9q12==6 // Está jubilado o pensionado

	s9q28__1 // Recibe pensión de sobreviviente, orfandad, incapacidad
	s9q28__2 // Recibe pensión de vejez por el seguro social
	s9q28__4 // Recibe pensión por divorcio, separación, alimentación

	s9q28__3 // Recibe jubilación por trabajo

	s9q28a_* // Monto recibido
	s9q28b_* // Moneda
	
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
	
	*We create ijubi_m
	gen ijubi_mpetro=.
	gen ijubi_mpetro_dummy=.

	gen ijubi_m_bolfeb = .
	gen ijubi_m_dummy = .
		
	*Local
		forvalues i = 1(1)4 {
		replace ijubi_m_bolfeb = ijubi_m_bolfeb + s9q28a_`i'_bolfeb 	if ijubi_m_bolfeb!=. & (s9q28a_`i'!=. & s9q28a_`i'!=.a) // For the next ones to add up (same later for employers)
		replace ijubi_m_bolfeb = s9q28a_`i'_bolfeb 						if ijubi_m_bolfeb==. & (s9q28a_`i'!=. & s9q28a_`i'!=.a) // For the first not missing one to add up
		* Obs: The last parenthesis controls for cases where they say they received jubilaciones o pensiones, but don't say how much		
		}		
	*From abroad
		replace ijubi_m_bolfeb = ijubi_m_bolfeb + s9q29b_5_bolfeb / 12 	if ijubi_m_bolfeb!=. & (s9q29b_5!=. & s9q29b_5!=.a)
		replace ijubi_m_bolfeb = s9q29b_5_bolfeb / 12 					if ijubi_m_bolfeb==. & (s9q29b_5!=. & s9q29b_5!=.a)
	
	*Putting all together by currency
		replace ijubi_m_dummy = 0 	if recibe_penojub_mon==1 & ijubi_m_bolfeb==. // Dicen que reciben pero no reportan cuánto
		replace ijubi_m_dummy = 1 	if ijubi_m_bolfeb>=0 & ijubi_m_bolfeb!=.
			
		tab ijubi_m_dummy
		sum ijubi_m_bolfeb
	
	*Petro "currency"
		replace ijubi_mpetro = ijubi_mpetro + s9q28_petromonto 	if ijubi_mpetro!=. & s9q28_petro==1 & (s9q28_petro!=. & s9q28_petro!=.a)
		replace ijubi_mpetro = s9q28_petromonto 				if ijubi_mpetro==. & s9q28_petro==1 & (s9q28_petro!=. & s9q28_petro!=.a)

		replace ijubi_mpetro_dummy = 0 	if recibe_penojub_mon==1 & ijubi_mpetro==. // Dicen que reciben pero no reportan cuánto
		replace ijubi_mpetro_dummy = 1 	if ijubi_mpetro>=0 & ijubi_mpetro!=.
			
		* Supuesto: Dado que la gente contestaba números muy raros sobre lo que cobró en petro, vamos a asumir 1/2, que es el valor del aguinaldo/pensiones recibidas. También asumiremos que 1 petro=$US 30
		gen ijubi_mpe_bolfeb  = ijubi_mpetro_dummy	* 30 * 73460.1238 	if ijubi_mpetro_dummy==1
	
		tab ijubi_mpetro_dummy
		sum ijubi_mpetro
			
	/*Checking
		gen noreporta=1 if ijubi_m1_dummy==0 & ijubi_m2_dummy==0 & ijubi_m3_dummy==0 & ijubi_m4_dummy==0 & ijubi_mpetro_dummy==0
		egen cuantasreporta=rowtotal(ijubi_m1_dummy ijubi_m2_dummy ijubi_m3_dummy ijubi_m4_dummy ijubi_mpetro_dummy)
		tab cuantasreporta
		tab noreporta
		drop noreporta cuantasreporta
		* Note: by February 26, of the people who reported having jubilacion o pension, 92.1% reported in Bolívares, 0.08% in Dollars, 0.04% in Euros, 0.3% in Colombian pesos, and 48.6% in Petros.
	*/
		
	egen ijubi_m = rowtotal(ijubi_m_bolfeb ijubi_mpe_bolfeb), missing
	sum ijubi_m
                         

* No monetario	
	gen     ijubi_nm=.
	notes ijubi_nm: the survey does not include information to define this variable

	
****** 9.3.2.INGRESOS DE CAPITAL ******	
		
/*icap_m: Ingreso monetario de capital, intereses, alquileres, rentas, beneficios y dividendos */
		
		gen icap_m = .
		
		foreach i of numlist 6 9 {
				
			replace icap_m = icap_m + s9q29b_`i'_bolfeb / 12 	if icap_m!=. & (s9q29b_`i'!=. & s9q29b_`i'!=.a) // for the next ones to add up
			replace icap_m = s9q29b_`i'_bolfeb / 12				if icap_m==. & (s9q29b_`i'!=. & s9q29b_`i'!=.a) // for the first not missing one to add up
				* Obs: The last parenthesis controls for cases where they say they received interests, dividends or rent from abroad, but don't say how much
		}		
			sum icap_m

	* No monetario	
	gen     icap_nm=.
	notes icap_nm: the survey does not include information to define this variable

****** 9.3.3.REMESAS ******	

/*rem: Ingreso monetario de remesas */
	
	gen rem = .
		
	foreach i of numlist 4 {
	*Assumption only the option "Remesas o ayudas periódicas de otros hogares del exterior" counts as remesas
		replace rem = rem + s9q29b_`i'_bolfeb / 12	if rem!=. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		replace rem = s9q29b_`i'_bolfeb / 12		if rem==. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}		
		sum rem 
	
	
****** 9.3.4.TRANSFERENCIAS PRIVADAS ******	
		
/* itranp_o_m Ingreso monetario de otras transferencias privadas diferentes a remesas */

* Monetario

	gen itranp_o_m = .
		
	foreach i of numlist 6 8 9 10 {
		replace itranp_o_m = itranp_o_m + s9q28a_`i'_bolfeb 	if itranp_o_m!=. & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
		replace itranp_o_m = s9q28a_`i'_bolfeb 					if itranp_o_m==. & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
	}		
	sum itranp_o_m
	
	
* No monetario	
	gen    itranp_o_nm =.

****** 9.3.5 TRANSFERENCIAS PRIVADAS ******	

* Monetario
*itranp_ns: Ingreso monetario de transferencias privadas, cuando no se puede distinguir entre remesas y otras

	gen itranp_ns = .
		
	foreach i of numlist 7 {
		replace itranp_ns = itranp_ns + s9q29b_`i'_bolfeb / 12	if itranp_ns!=. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		replace itranp_ns = s9q29b_`i'_bolfeb / 12				if itranp_ns==. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
	}		
	sum itranp_ns
		

****** 9.3.6 TRANSFERENCIAS ESTATALES ******	

****** 9.3.6.1 TRANSFERENCIAS ESTATALES CONDICIONADAS******
* cct: Ingreso monetario por transferencias estatales relacionadas con transferencias monetarias condicionadas

	gen     cct = .
	notes cct: the survey does not include information to define this variable
	
****** 9.3.6.2 OTRAS TRANSFERENCIAS ESTATALES******
* itrane_o_m Ingreso monetario por transferencias estatales diferentes a las transferencias monetarias condicionadas

* Monetarias
	
	gen itrane_o_m = .
		
	foreach i of numlist 5 7 {
		replace itrane_o_m = itrane_o_m + s9q28a_`i'_bolfeb 	if itrane_o_m!=. & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
		replace itrane_o_m = s9q28a_`i'_bolfeb 					if itrane_o_m==. & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
	}		
	sum itrane_o_m
	
	
*No monetarias
	gen     itrane_o_nm = .
	notes itrane_o_nm: the survey does not include information to define this variable


****** 9.3.7 OTRAS TRANSFERENCIAS ******	
*itrane_ns Ingreso monetario por transferencias cuando no se puede distinguir 

	gen itrane_ns = .
		
	foreach i of numlist 11 {
		replace itrane_ns = itrane_ns + s9q28a_`i'_bolfeb 	if itrane_ns!=. & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
		replace itrane_ns = s9q28a_`i'_bolfeb 					if itrane_ns==. & (s9q28a_`i'!=. & s9q28a_`i'!=.a)
	}		
	sum itrane_ns
	
		
***** iV) OTROS INGRESOS NO LABORALES / V) INGRESOS NO LABORALES EXTRAORDINARIOS 

	gen inla_extraord = .
	foreach i of numlist 3 8 {
		replace inla_extraord = inla_extraord + s9q29b_`i'_bolfeb / 12	if inla_extraord!=. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		replace inla_extraord = s9q29b_`i'_bolfeb / 12					if inla_extraord==. & (s9q29b_`i'!=. & s9q29b_`i'!=.a)
		}		
	sum inla_extraord

	* rename  inla_extraord inla_otro // Because it appeared like this in CEDLAS' do_file_1_variables
	



	

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

*Solo para que corran los do aux de CEDLAS
	gen hstrp=hstr_ppal
	gen hstrt= hstr_ppal 
		replace hstrt = hstr_todos if hstr_todos!=. // los que tienen dos trabajos

	gen hogarsec=0
	gen     	relacion = 1		if  relacion_en==1
		replace relacion = 2		if  relacion_en==2
		replace relacion = 3		if  relacion_en==3  | relacion_en==4
		replace relacion = 4		if  relacion_en==7  
		replace relacion = 5		if  relacion_en==8 
		replace relacion = 6		if  relacion_en==5
		replace relacion = 7		if  relacion_en==6  | relacion_en==9  | relacion_en==10 | relacion_en==11 
		replace relacion = 8		if  relacion_en==12 | relacion_en==13
	gen nivel=.
	tempvar uno
	gen `uno' = 1
	egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)

include "$rootpath\data_management\management\2. harmonization\ENCOVI harmonization\aux_do\do_file_1_variables_MA.do"

* RENTA IMPUTADA
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
			
			*Obs: Before there were options saying "De algun programa de gobierno (con titulo de propiedad)" and "De algun programa de gobierno (sin titulo de propiedad)" */

	gen aux_propieta_no_paga = 1 if tenencia_vivienda==1 | tenencia_vivienda==2 | tenencia_vivienda==5 | tenencia_vivienda==6 | tenencia_vivienda==7 | tenencia_vivienda==8
	replace aux_propieta_no_paga = 0 if tenencia_vivienda==3 | tenencia_vivienda==4 | (tenencia_vivienda>=9 & tenencia_vivienda<=10) | tenencia_vivienda==.
	bysort id: egen propieta_no_paga = max(aux_propieta_no_paga)

	// Creates implicit rent from hh guess of its housing costs if they do noy pay rent and 10% of actual income if hh do not make any guess
		gen     renta_imp = .
		
		levelsof interview_month, local(rent_month)
		foreach m in `rent_month'{
			levelsof renta_imp_mon, local(rent_currency)

			foreach c in `rent_currency'{
				di "////"
				di `m'
				di `c'
				di  `tc`c'mes`m''
				di `deflactor`m''
				replace renta_imp = renta_imp_en * `tc`c'mes`m'' * `deflactor`m'' if interview_month == `m' & renta_imp_mon == `c' & propieta_no_paga == 1
			}
		}

		// tab tenencia_vivienda if renta_imp==. // to check cases of reported rent but not imputated   
		//
		//       7. Para su hogar, la vivienda es? |      Freq.     Percent        Cum.
		// ----------------------------------------+-----------------------------------
		//                           Propia pagada |        252       11.91       11.91
		//                        Propia pagándose |         62        2.93       14.84
		//                               Alquilada |        420       19.85       34.69
		//          Alquilada parte de la vivienda |         14        0.66       35.35
		// Adjudicada pagándose Gran Misión Vivien |         23        1.09       36.44
		//         Adjudicada Gran Misión Vivienda |         10        0.47       36.91
		//           Cedida por razones de trabajo |         33        1.56       38.47
		//           Prestada por familiar o amigo |        895       42.30       80.77
		//                                  Tomada |        181        8.55       89.32
		//                                    Otra |        226       10.68      100.00
		// ----------------------------------------+-----------------------------------
		//                                   Total |      2,116      100.00
		gen renta_imp_b = itf_sin_ri*0.1

		// twoway scatter renta_imp renta_imp_b if renta_imp<10000000 & renta_imp_b<10000000, msize(tiny) ///
		// || line renta_imp renta_imp if renta_imp<10000000 & renta_imp_b<10000000

		// gen test_renta = renta_imp>renta_imp_b
		// tab test_renta
		//  test_renta |      Freq.     Percent        Cum.
		// ------------+-----------------------------------
		//           0 |      1,021        3.20        3.20
		//           1 |     30,927       96.80      100.00
		// ------------+-----------------------------------
		//       Total |     31,948      100.00

		replace renta_imp = renta_imp_b  if  propieta_no_paga == 1 & renta_imp ==. //complete with 10% in cases where no guess is provided by hh.

		*replace renta_imp = renta_imp / p_reg
		*replace renta_imp = renta_imp / ipc_rel 

include "$rootpath\data_management\management\2. harmonization\ENCOVI harmonization\aux_do\do_file_2_variables.do"
* El do de CEDLAS que está en aux_do parece disinto que el do de CEDLAS adentro de ENCOVI harmonization, chequear

include "$rootpath\data_management\management\2. harmonization\ENCOVI harmonization\aux_do\Labels_ENCOVI.do"
* Terminar de chequear nuestros labels!!


*(************************************************************************************************************************************************ 
*---------------------------------------------------------------- 1.1: linea pobreza  ------------------------------------------------------------------
************************************************************************************************************************************************)*/	
gen linea_pobreza = . // prices from asamblea nacional, orsh =2, no laged incomes, no imputation
gen linea_pobreza_extrema = .  // prices from asamblea nacional, orsh =2, no laged incomes, no imputation

gen pobre = ipcf<linea_pobreza
gen pobre_extremo = ipcf<linea_pobreza_extrema

compress


/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables a Documentar Base de Datos CEDLAS --------------
*************************************************************************************************************************************************)*/

sort id com

*Silencing para que se corra más rápido (des-silenciar luego)
/* 
order $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $health_ENCOVI $labor_ENCOVI $otherinc_ENCOVI $bank_ENCOVI $mortali_ENCOVI $emigra_ENCOVI $foodcons_ENCOVI $segalimentaria_ENCOVI $shocks_ENCOVI $antropo_ENCOVI $ingreso_ENCOVI ///
/* Más variables de ingreso CEDLAS */ iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_nm /*ijubi_o*/ icap_nm cct itrane_o_nm itranp_o_nm ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap  itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
interview_month interview__id interview__key quest labor_status miembros relab s9q25a_bolfeb s9q26a_bolfeb s9q27_bolfeb s9q28a_1_bolfeb s9q28a_2_bolfeb s9q28a_3_bolfeb s9q28a_4_bolfeb ijubi_mpe_bolfeb s9q29b_5_bolfeb linea_pobreza linea_pobreza_extrema pobre pobre_extremo // additional
*/

keep $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $health_ENCOVI $labor_ENCOVI $otherinc_ENCOVI $bank_ENCOVI $mortali_ENCOVI $emigra_ENCOVI $foodcons_ENCOVI $segalimentaria_ENCOVI $shocks_ENCOVI $antropo_ENCOVI $ingreso_ENCOVI ///
/* Más variables de ingreso CEDLAS */ iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_nm /*ijubi_o*/ icap_nm cct itrane_o_nm itranp_o_nm ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
interview_month interview__id interview__key quest labor_status miembros relab s9q25a_bolfeb s9q26a_bolfeb s9q27_bolfeb s9q28a_1_bolfeb s9q28a_2_bolfeb s9q28a_3_bolfeb s9q28a_4_bolfeb ijubi_mpe_bolfeb s9q29b_5_bolfeb linea_pobreza linea_pobreza_extrema pobre pobre_extremo  // additional


*save "$dataout\ENCOVI_2019.dta", replace
*save "$dataout\ENCOVI_2019_ING SIN AJUSTE POR INFLACION.dta", replace
save "$dataout\ENCOVI_2019_PRECIOS IMPLICITOS_lag_ingresos.dta", replace
*save "$dataout\ENCOVI_2019_Asamblea Nacional_lag_ingresos.dta", replace
