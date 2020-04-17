/// SPANISH LABELS ///

/*
** Interview Control / Control de la entrevista
* Todos los labels están disponibles


** Household determination / Determinacion de hogares
label var 	comparte_gasto_viv 	"2. Todas las personas en esta vivienda comparten gastos para la compra de comida"
label def 	comparte_gasto_viv 	0 "No" 1 "Si"
label values comparte_gasto_viv comparte_gasto_viv
* Todos los demás labels están disponibles


** Identification Variables / Variables de identificación
label var   pais            "Pais"
label var   ano             "Año de la encuesta"
label var   encuesta        "Nombre de la encuesta"
label var   id              "Identificacion unica del hogar"
label var   com             "Identificacion del componente"   
*label var	pondera         "Factor de ponderacion"
*label var	strata          "Variable de estratificacion"   
label var   psu	     	 	"Unidad Primaria de Muestreo"


** Demographic variables  / Variables demográficas

label def 	relacion_comp 	1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" 4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)" ///
							6 "Padre, madre" 7 "Hermano(a)" 8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" 12 "Servicio Domestico"
label values relacion_comp relacion_comp
			
label var	hombre 			"Género"
label def 	hombre 			0 "Mujer" 1 "Hombre"
label values hombre hombre

label var	pert_2014		"8. Incorporó al hogar en los últimos 5 años?"
label def 	pert_2014		1 "Sí" 0 "No"
label values pert_2014 pert_2014

label var	certificado_naci 		"Tiene partida de nacimiento?"
label def 	certificado_naci		1 "Sí" 0 "No"
label values certificado_naci certificado_naci

label var	cedula 		"Tiene cedula de identidad?"
label def 	cedula		1 "Sí" 0 "No"
label values cedula cedula

label var	estado_civil 	"Estado civil (armonizada)"
label def	estado_civil	1 "Casado/a" 2 "Nunca casado/a" 3 "Conviendo" 4 "Divorciado/a o Separado/a" 5 "Viudo/a"
label values estado_civil estado_civil

label var	anio_ult_hijo 	"Año de nacimiento último hijo"
label var	mes_ult_hijo 	"Mes de nacimiento último hijo" 
label var	dia_ult_hijo	"Día de nacimiento último hijo"


** Juli **


** Health variables  / Variables de salud

label var	enfermo 		"1. Ha tenido un problema de salud, enfermedad o accidente en los último 30 días?"
label def 	enfermo			1 "Si" 0 "No"
label values enfermo enfermo

label var	visita 			"3. Ha consultado servicio de salud en los últimos 30d por este problema?"
label def	visita			1 "Sí" 0 "No"
label values visita visita

label var	pago_consulta 		"7. Pagó por la consulta o atención médica?"
label def 	pago_consulta		1 "Sí" 0 "No"
label values pago_consulta pago_consulta

label var 	receto_remedio		"9. Se recetó a algún medicamento para la enferemedad o accidente?"
label def 	receto_remedio		1 "Sí" 0 "No"
label values receto_remedio receto_remedio

label var	pago_examen			"13. Pagó por radiografías, exámenes de laboratorio o similares?"
label def 	pago_examen			1 "Sí" 0 "No"
label values pago_examen pago_examen

label var	remedio_tresmeses	"15. Gastó dinero en medicinas en los ultimos 3 meses?"
label def 	remedio_tresmeses	1 "Sí" 0 "No"
label values remedio_tresmeses remedio_tresmeses

label var 	seguro_salud		"17. Está afiliado a algún seguro médico?"
label def	seguro_salud		1 "Sí" 0 "No"
label values seguro_salud seguro_salud

label var 	pagosegsalud		"19. Pagó por el seguro médico?"
label def	pagosegsalud		1 "Sí" 0 "No"
label values pagosegsalud pagosegsalud


*** Labor / Empleo

label var  	trabajo_semana  	"¿La semana pasada trabajó al menos una hora? "
label def	trabajo_semana		1 "Si" 0 "No"
label values trabajo_semana trabajo_semana
label var  	trabajo_independiente  "¿Tiene algún empleo, negocio o realiza alguna actividad por su cuenta? "
label def	trabajo_independiente	1 "Si" 0 "No"
label values trabajo_independiente trabajo_independiente
label var  	sueldo_semana 		"¿Recibió sueldo o ganancias durante la semana pasada? "
label def	sueldo_semana		1 "Si" 0 "No"
label values sueldo_semana 
label var  	busco_trabajo 		"¿Hizo algo para encontrar un trabajo remunerado durante las últimas 4 semanas? "
label def	busco_trabajo		1 "Si" 0 "No"
label values busco_trabajo busco_trabajo
label var  	empezo_negocio  	"Hizo algo para empezar un negocio durante las últimas 4 semanas? "
label def	empezo_negocio		1 "Si" 0 "No"
label values empezo_negocio empezo_negocio
label var  	como_busco_semana 	"¿Realizó alguna de esas diligencias la semana pasada? "
label def	como_busco_semana	1 "Si" 0 "No"
label values  como_busco_semana como_busco_semana
foreach i of varlist dili_agencia dili_aviso dili_planilla dili_credito dili_tramite dili_compra dili_contacto dili_otro {
	label def	`i'				1 "Si" 0 "No"
	label values `i' `i'
	}
label var  	trabajo_secundario  "Además de su trabajo principal, ¿realizó la semana pasada alguna otra actividad por la que percibió ingresos tales como, venta de artículos, trabajos contratados, etc?"
foreach i of varlist ///
im_sueldo im_hsextra im_propina im_comision im_ticket im_guarderia im_beca im_hijos im_antiguedad im_transporte im_rendimiento im_otro ///
c_sso c_rpv c_spf c_aca c_sps c_otro {
	label def	`i'			1 "Si" 0 "No"
	label values `i' `i'
	label var  `i'_cant		"Monto" 
	label var  	`i'_mone	"Moneda" 
	label def	`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
	label values `i' `i'
	}
foreach i of varlist inm_comida inm_productos inm_transporte inm_vehiculo inm_estaciona inm_telefono inm_servicios inm_guarderia inm_otro  {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  `i'_cant		" Monto recibido (si no percibe el beneficio en dinero, estime cuánto tendría que haber pagado por esto)" 
	label var  	`i'_mone	"Moneda" 
	label def	`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
	label values `i' `i'
	}
foreach i of varlist d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro  {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  `i'_cant		"Monto descontado" 
	label var  	`i'_mone	"Moneda" 
	label def	`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
	label values `i' `i'
	}
label var  	im_patron  		"¿El mes pasado recibió dinero por la venta de los productos, bienes o servicios de su negocio o actividad?"
label def	im_patron		1 "Si" 0 "No"
label values im_patron im_patron
label var  	inm_patron  	"¿El mes pasado retiró productos del negocio o actividad para consumo propio o de su hogar? "
label def	inm_patron		1 "Si" 0 "No"
label values inm_patron inm_patron
label var  	im_indep  		"¿Durante los últimos 12 meses, recibió dinero por ganancias o utilidades netas derivadas del negocio o actividad? "
label def	im_indep		1 "Si" 0 "No"
label values im_indep im_indep
label var  	i_indep_mes  	"¿El mes pasado, recibió ingresos por su actividad para gastos propios o de su hogar? "
label def	i_indep_mes		1 "Si" 0 "No"
label values i_indep_mes i_indep_mes

label var  	deseamashs  	"¿Preferiría trabajar más de 35 horas por semana? "
label var  	buscamashs  	"¿Ha hecho algo parar trabajar mas horas? "
label var  	cambiotr  		"¿Ha cambiado de trabajo en los últimos 12 meses?"
label var  	aporta_pension  "¿Realiza aportes para algún fondo de pensiones? "
foreach i of varlist deseamashs buscamashs cambiotr aporta_pension {
	label def	`i'	1 		"Si" 0 "No"
	label values `i' `i'
	}
label var  	aporte_pension  "¿Realiza aportes para algún fondo de pensiones? ¿A cuál fondo de pensión?  (armonizada)"
label def	aporte_pension 	1 "Si, para el IVSS" 2 "Si, para otra institucion o empresa publica" ///
							3 "Si, para institucion o empresa privada" 4 "Si, para otra" 5 "No"
label values aporte_pension aporte_pension

*/




/// ENGLISH LABELS ///


/*(************************************************************************************************************************************************* 
*----------------------------------------	II. Interview Control / Control de la entrevista  -------------------------------------------------------
*************************************************************************************************************************************************)*/
label var    entidad 	"Federal entity"
label var    municipio 	"Municipality"
label var    nombmun 	"Municipality's name"
label var    parroquia 	"Parish"
label var    nombpar 	"Parish name"
label var    centropo 	"Populated center"
label var    nombcp 	"Name of populated center"
label var    segmento 	"Segment"
label var    peso_segmento	"Segment weight"
label var    combined_id 	"Combined identifiers"
label var    tipo_muestra 	"Sample type"			
label var    gps_struc_latitud	"GPS coordinates of the structure (from listing): Latitude"
label var    gps_struc_longitud	"GPS coordinates of the structure (from listing): Longitude"
label var    gps_struc_exactitud 	"GPS coordinates of the structure (from listing): Accuracy"
label var    gps_struc_altitud 	"GPS coordinates of the structure (from listing): Altitude"
label var    gps_struc_tiempo	"GPS coordinates of the structure (from listing): Time stamp"
label var    gps_coord_latitud 	"GPS coordinates: Latitude"
label var    gps_coord_longitud "GPS coordinates: Longitude"
label var    gps_coord_exactitud 	"GPS coordinates: Accuracy"
label var    gps_coord_altitud 	"GPS coordinates: Altitude"
label var    gps_coord_tiempo	"GPS coordinates: Time stamp"
label var    id_str 	"Number of structures according to listing"
label var    statut 	"Number of the household in the structure"
label def 	 status		1 "Residential" 2 "Non-residential"
label var    sector_urb "Sector/Urbanization/Neighborhood according to listing"


/*(************************************************************************************************************************************************* 
*-------------------------------	III Household determination / Determinacion de hogares  -------------------------------------------------------
*************************************************************************************************************************************************)*/
label var   npers_viv 			"Number of residents in dwelling"
label var   comparte_gasto_viv 	"All residents share expenses to buy food?"
label def 	relacion 			0 "No" 1 "Si"
label var   npers_gasto_sep 	"How many groups of people have separate food expenses"
label var   npers_gasto_comp	"How many people in household (sharing food expenses)"


/*(************************************************************************************************************************************************* 
*-----------------------------------------	1.1: Identification Variables / Variables de identificación --------------------------------------------
*************************************************************************************************************************************************)*/
label var    pais            "Country"
label var    ano             "Survey year"
label var    encuesta        "Household survey name"
label var    id              "Household unique identifier"
label var    com             "Identifier of household member"   
*label var   pondera         "Weighting factor"
*label var   strata          "Stratification variable"   
label var    psu	     	 "Primary sampling unit"


/*(************************************************************************************************************************************************* 
*------------------------------------------	1.2: Demographic variables / Variables demográficas --------------------------------------------------
*************************************************************************************************************************************************)*/
label var	relacion_en 	"Relationship with head of household (this survey)"
label def 	relacion_en	 	1 "Head" 2 "Spouse/Partner" 3 "Son/Daughter" 4 "Stepson/Stepdaughter" 5 "Granddaughter/Grandson" ///
							6 "Son/Daughter in law, father/mother in law" 7 "Mother/Father" 8 "Brother/Sister" 9 "Brother in law" ///
							10 "Nephew" 11 "Other family" 12 "Other non-family" 13 "Domestic service"
label values relacion_en relacion_en
label var	relacion_comp 	"Relationship with head of household (harmonized)"
label def 	relacion_comp 	1 "Head" 2 "Spouse/Partner" 3 "Son/Daughter/Stepson/Stepdaughter" 4 "Granddaughter/Grandson" ///
							5 "Son/Daughter in law, father/mother in law" 6 "Mother/Father" 7 "Brother/Sister" 8 "Brother in law" ///
							9 "Nephew" 10 "Other family" 11 "Other non-family" 12 "Domestic service"
label values relacion_comp relacion_comp
label var	hombre 			"Gender (Male?)"
label def 	hombre 			0 "Female" 1 "Male"
label values hombre hombre
label var	edad 			"Age"
label var	anio_naci 		"Year of birth"
label var	mes_naci 		"Month of birth"
label def 	mes_naci 		1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label var	dia_naci 		"Day of birth"
label var	pais_naci 		"Country of birth"
label def 	pais_naci		1 "Venezuela" 2 "Colombia" 3 "Ecuador" 4 "Peru" 5 "Chile" 6 "Argentina" 7 "Brasil" 8 "Guyana" ///
							9 "España" 10 "Italy" 11 "Portugal" 12 "United States" 13 "Siria" 14 "Lebanon" 15 "Other" 
label values pais_naci pais_naci
label var	residencia 		"Place of residence in September 2018"
label def 	residencia		1 "This same county" 2 "Another Venezuelan county" 3 "Another country" 4 "Not born"
label values residencia residencia
label var	resi_estado 	"Federal state of residence in September 2018"
label def 	resi_estado		1 "Distrito Capital" 2 "Amazonas" 3 "Anzoategui" 4 "Apure" 5 "Aragua" 6 "Barinas" 7 "Bolivar" ///
							8 "Carabobo" 9 "Cojedes" 10 "Delta Amacuro" 11 "Falcón" 12 "Guárico" 13 "Lara" 14 "Mérida" 15 "Miranda" 16 "Monagas"
label values resi_estado resi_estado
label var	resi_municipio 	"County of residence in September 2018"
/* label def 	resi_municipio	Libertador Anaco Juan Antonio Sotillo Libertad Piritu San Jose de Guanipa Simon Bolivar Simon Rodriguez Paez Romulo Gallegos San Fernando Bolivar Camatagua Girardot Jose Rafael Revenga Mario Briceno Iragorry San Sebastian Santiago Marino Francisco Linares Alcantara Alberto Arvelo Torrealba Barinas Cruz Paredes Sosa Gran Sabana Heres Piar Guacara Libertador Los Guayos San Diego San Joaquin Valencia Falcon Colina Falcon Leonardo Infante Las Mercedes Jose Tadeo Monagas Jose Felix Ribas Crespo Iribarren Palavecino Urdaneta Alberto Adriani Antonio Pinto Salinas Arzobispo Chacon Libertador Zea Cristobal Rojas Guaicaipuro Ezequiel Zamora Libertador Maturin Maneiro Marino Guanare Guanarito Turen Andres Mata Bermudez Bolivar Libertador Sucre Valdez Fernandez Feo Libertador San Felipe Urachiche Francisco Javier Pulgar Maracaibo Rosario de Perija San Francisco Santa Rita Sucre Vargas */
label var	razon_cambio_resi "Reason for moving"
label def	razon_cambio_resi 1 "Risks of natural disaster (flooding, landslide or earthquake" 2 "Threat or risk for life, freedom or phyisical integrity" 3 "Absense of subsistence means" ///
							4 "Lack of access to services" 5 "Difficulties to find a job" 6 "Health reasons" 7 "Other"
label values razon_cambio_resi razon_cambio_resi
label var 	razon_cambio_resi_o "Other reason for moving"
label var	pert_2014		"Incorporated to the household in the last 5 years?"
label def 	pert_2014		1 "Yes" 0 "No"
label values pert_2014 pert_2014
label var	razon_incorp_hh	"Reason for incorporating to the household"
label def 	razon_incorp_hh	1 "New born" 2 "Separated, divorced, cancelled marriage" 3 "Married or came to live with couple" 4 "Came to live as close friend" 5 "Came back from work" 6 "Came back from studying" ///
							7 "Came because of improved economic situation" 8 "Came because of worsened economic situation" 9 "Came because of bad family relationships" 10 "Came back from living abroad" 12 "Came for other reasons"
label values razon_incorp_hh razon_incorp_hh
label var razon_incorp_hh_o "Reason for incorporating to the household(Other)"
label var	certificado_naci "Birth certificate"
label var	cedula 			"ID card"
label var	razon_nocertificado "Reason for not having ID card"
label def	razon_nocertificado	1 "Not important" 2 "Doesn't know the requirements" 3 "Doesn't know where to process it" 4 "There are no offices near" 5 "Doesn't have the resources to process it" 6 "Its in process" 7 "Other reason"
label values razon_nocertificado razon_nocertificado
label var	razon_nocertificado_o "Other reason for not having ID card"
label var	estado_civil_en "Marital status (this survey)"
label def	estado_civil_en 1 "Married, living together" 2 "Married, not living together" 3 "United, living together" ///
							4 "United, not living together" 5 "Divorced" 6 "Separated" 7 "Widowed" 8 "Single / Never united"
label values estado_civil_en estado_civil_en
label var	estado_civil 	"Marital status (harmonized)"
label def	estado_civil	1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/separated" 5 "Widowed"
label values estado_civil estado_civil
label var	hijos_nacidos_vivos "Number of sons/daughters born alive"
label var	hijos_vivos 	"Number of sons/daughters currently alive"
label var	anio_ult_hijo 	"Year your last son/daughter was born"
label var	mes_ult_hijo 	"Month your last son/daughter was born" 
label var	dia_ult_hijo	"Day your last son/daughter was born"


/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
*** Type of flooring material
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas
		 
 VAR: material_piso = s4q1 */
	*-- Label variable
	label var material_piso "Type of flooring material"
	 *-- Label values
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

	VAR: material_pared_exterior = s4q2  */

	*-- Label variable
	label var material_pared_exterior "Type of exterior wall material"
	*-- Label values
	label def material_pared_exterior 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete" ///
	4 "Wood" 5 "Polyvinyl chloride block" 6 "Adobe, mud or frieze bahareque" 7 "Adobe, mud or non frieze bahareque" 8 "Other"
	label value material_pared_exterior material_pared_exterior

*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
		 
	VAR: material_techo = s4q3 	*/
	*-- Label variable
	label var material_techo "Type of roofing material"
	*-- Label values
	label def material_techo_en 1 "Platabanda (concrete or planks)" ///		
		 2 "Roof tile or similar"  3 "Asphalt sheet" ///
		 4 "Metal sheets (zinc, aluminum and the like)" ///
		 5 "Waste materials (plank, boards or the like, palm)"
	label val material_techo material_techo_en
	
*** Type of dwelling
/* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
		
	VAR: tipo_vivienda = s4q4	
*/
	*-- Label variable
	label var tipo_vivienda "Type of dwelling"
	*-- Label values
	label def tipo_vivienda_en 1 "Detached house" ///
		2 "House" 3 "Apartament in building complex" ///
		4 "Annex in detached house" 5 "Vivienda rustica (rancho)" ///
		6 "Room in a house or workplace" ///
		7 "Rancho campesino"
	label val tipo_vivienda tipo_vivienda_en
	
*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda?
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
		
		VAR: suministro_agua =  s4q5__1
*/
		*-- Label variable
		label var suministro_agua "Last 3 months: Water supply (this survey)"		

		*-- Label values
		label def suministro_agua_en 1 "From pipeline" 2 "Pile or pond" ///
		3 "Distributed by water tanker truck"	4 "Connected to water pump"	5 "Connected but no water pump" ///
		6 "Other"
		label value suministro_agua suministro_agua_en
		
		*-- Label variable
		label var suministro_agua_comp "Last 3 months: Water supply (harmonized)"
		*-- Label values
		label def suministro_agua_comp_en 1 "From pipeline" 2 "Pile or pond" ///
		3 "Distributed by water tanker truck" 4 "Other"
		label value suministro_agua_comp suministro_agua_comp_en

*** Frequency of water supply
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
		
		VAR: frecuencia_agua = s4q6
*/
		*-- Label variable
		label var frecuencia_agua "Last 3 months: Frequency of water supply"
		*-- Label values
		label def frecuencia_agua_en 1 "Every day" 2 "Some days every week" ///
		3 "Once a week"	4 "Once every two weeks" ///
		5 "Never"
		label val frecuencia_agua frecuencia_agua_en

*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/

		*-- Label variable
		label var serv_elect_red_pub "Last 3 months, electricity supply: public"
		*-- Label variable
		label var serv_elect_planta_priv "Last 3 months, electricity supply: private"
		*-- Label variable
		label var serv_elect_otro "Last 3 months, electricity supply: other"
		*-- Label variable
		label var  electricidad "Last 3 months, had access to electricity"
		label def elec 1 "Yes" 0 "No"
		label val serv_elect_red_pub elec
		label val serv_elect_planta_priv elec
		label val serv_elect_otro elec
		label val electricidad elec
		
*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
	VAR: interrumpe_elect = s4q8		
*/
		*-- Label variable
		label var interrumpe_elect "Electric power interruptions"
		*-- Label values
		label def interrumpe_elect_en 1 "Daily for long hours" ///
		2 "Once a week for long hours" ///
		3 "Once a month" 4 "Never" 
		label value interrumpe_elect interrumpe_elect_en

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
		
	VAR: tipo_sanitario_comp
	
		1 "Poceta a cloaca/Pozo septico" 
		2 "Poceta sin conexion" 
		3 "Excusado de hoyo o letrina" 
		4 "No tiene poseta o excusado"
*/
		*-- Label variable
		label var tipo_sanitario "Type of toilet (this survey)"
		*-- Label values
		label def tipo_sanitario 1 "Toilet with flush (connected to public sewerage system)" ///
		2 "Toilet with flush (connected to cesspit)" ///
		3 "Toilet but not connected" ///
		4 "Toilet without flush" ///
		5 "Without toilet"
		label val tipo_sanitario tipo_sanitario
		
		*-- Label variable
		label var tipo_sanitario_comp "Type of toilet (harmonized)"
		*-- Label values
		label def tipo_sanitario_comp_en 1 "Toilet with flush (connected to public sewerage system of cesspit)" ///
		2 "Toilet but not connected" 3 "Toilet without flush" ///
		4 "Without toilet"
		label value tipo_sanitario_comp tipo_sanitario_comp_en

*** Number of rooms used exclusively to sleep
/* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
	VAR: ndormi= s5q1  //up to 9 */
 
		*-- Label variable
		label var ndormi "Number of rooms used exclusively to sleep"
		
*** Bath with shower 
/* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
VAR: banio_con_ducha = s5q2*/
		*-- Label variable
		label var banio_con_ducha "Bath with shower"
		*-- Label values
		label def banio_con_ducha_en 1 "Yes" 0 "No"
		label val banio_con_ducha banio_con_ducha_en
		
*** Number of bathrooms with shower
/* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 */
		*-- Label variable
		label var nbanios "Number of bathrooms with shower"
		
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
		10 = Otra */
		
		*-- Label variable
		label var tenencia_vivienda "Housing tenure (this survey)"
		*-- Label values
		label def tenencia_vivienda_en 1 "Own housing (paid)" 2 "Own housing (paying)" ///
				3 "Rented housing" 4 "Rented part of the housing" ///
				5 "Awarded-Social housing: Gran Mision Vivienda (paying)" /// 
				6 "Awarded-Social housing: Gran Mision Vivienda" ///
				7 "Borrowed for work reasons" ///
				8 "Borrowed by relative or friend" ///
				9 "Taken over" ///
			   10 "Other"
		label val tenencia_vivienda tenencia_vivienda_en

		*-- Label variable
		label var tenencia_vivienda_comp "Housing tenure (harmonized)"
		*-- Label values
		label def tenencia_vivienda_comp_en 1 "Own housing (paid)" 2 "Own housing (paying)" ///
		3 "Rented housing" 4 "Borrowed" 5 "Taken over" 6 "Social housing: Government program" 7 "Other"
		label value tenencia_vivienda_comp tenencia_vivienda_comp_en

		*** How much did you pay for rent or mortgage the last month?
		*-- Label variable
		label var pago_alq_mutuo "How much did you pay for rent or mortgage the last month?"

		*** In which currency did you make the payment?
		*-- Label variable
		label var pago_alq_mutuo_mon "In which currency did you make the payment?"

		*** In which month did you make the payment?
		*-- Label variable
		label var pago_alq_mutuo_m "In which month did you make the payment?"
		*-- Label values
		label def month 1 "January" 2 "February" 3 "March" 4 "April" ///
		5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
		label val pago_alq_mutuo_m month
		
		*** During the last year, have you had arrears in payments?
		*-- Label variable
		label var atrasos_alq_mutuo "During the last year, have you had arrears in payments?"
		*-- Label values
		label def yesno 1 "Yes" 0 "No"
		label val atrasos_alq_mutuo yesno
		
		*** What consequences did the arrears in payments had?
		*-- Label variable
		label var implicancias_nopago "What consequences did the arrears in payments had?"
		*-- Label values
		label def implicancias_nopago 1 "Sold assets from the household to cancel debt" ///
							          2 "Asked your relatives for help" ///
									  3 "Sublease a room in the house" /// 
									  4 "Looked for a second job" ///
                                      5 "Other"
		label val implicancias_nopago implicancias_nopago
		
		*** If you had to rent similar dwelling, how much did you think you should pay?
		*-- Label variable
		label var renta_imp_en "If you had to rent similar dwelling, how much did you think you should pay?"
				
		*** In which currency ?
		*-- Label variable
		label var renta_imp_mon "In which currency?"

		*** What type of property title do you have?
		*-- Label variable
		label var titulo_propiedad "What type of property title do you have?"
		*-- Label values
		label def titulo_propiedad 1 "Título supletorio" ///
                    2 "Ownership certificate" ///                 
					3 "Without certificate" ///
                    4 "Other"
		label val titulo_propiedad titulo_propiedad 

*** What are the main sources of drinking water in your household?
		* Acueducto
		*-- Label variable
		label var fagua_acueduc "Main sources of drinking water in your household? Pipeline"
		* Pila o estanque
		*-- Label variable
		label var fagua_estanq "Main sources of drinking water in your household? Pile or pond"
		* Camión cisterna
		*-- Label variable
		label var fagua_cisterna "Main sources of drinking water in your household? Water tanker truck"
		* Pozo con bomba
		*-- Label variable
		label var fagua_bomba "Main sources of drinking water in your household? Water pump"
		* Pozo protegido
		*-- Label variable
		label var fagua_pozo "Main sources of drinking water in your household? Well water"
		* Aguas superficiales (manantial,río, lago, canal de irrigación)
		*-- Label variable
		label var fagua_manantial "Main sources of drinking water in your household? Spring, river, lake, irrigation canal"
		* Agua embotellada
		*-- Label variable
		label var fagua_botella "Main sources of drinking water in your household? Bottled water"
		* Otros
		*-- Label variable
		label var fagua_otro "Main sources of drinking water in your household? Other"

		*-- Label values
		label def aqua_en 0 "Other" 1 "First (1)" 2 "Second (2)" 3 "Third (3)" 
		label val fagua_acueduc aqua_en
		label val fagua_estanq aqua_en
		label val fagua_cisterna aqua_en
		label val fagua_bomba aqua_en
		label val fagua_pozo aqua_en
		label val fagua_manantial aqua_en
		label val fagua_botella aqua_en
		label val fagua_otro aqua_en

		*** In your household, is the water treated to make it drinkable
		*-- Label variable
		label var tratamiento_agua "In your household, is the water treated to make it drinkable"
		*-- Label values
		label val tratamiento_agua yesno
		
		*** How do you treat the water to make it more safe for drinking
		*-- Label variable
		label var tipo_tratamiento "How do you treat the water to make it more safe for drinking"
		label def tipo_tratamiento 1 "Boil the water" 2 "Add bleach" ///
						   3 "Use a filter for water" 4 "Boil and filter" ///
						   5 "Other"
	    label val tipo_tratamiento tipo_tratamiento
		
		*** Which type of fuel do you use for cooking?
		*-- Label variable
		label var comb_cocina "Which type of fuel do you use for cooking?"
		*-- Label values
		!label def comb_cocina 1 "Gas (direct)" 2 "Gas por bombona" 3 "Electricity" 4 "Wood" 5 "Other" 6 "Do not cook"
		label val comb_cocina comb_cocina

*** Did you pay for the following utilities?
* Water
		*-- Label variable
		label var pagua "Did you pay for the following utilities? Water"
		*-- Label values
		label val pagua yesno

* Electricity
		*-- Label variable
		label var pelect "Did you pay for the following utilities? Electricity"
		* Gas
		*-- Label variable
		label var pgas "Did you pay for the following utilities? Gas"
		* Carbon, wood
		*-- Label variable
		label var pcarbon "Did you pay for the following utilities? Carbon, wood"
		* Paraffin
		*-- Label variable
		label var pparafina "Did you pay for the following utilities? Paraffin"
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono "Did you pay for the following utilities? Landline, internet and tv cable"
		
		*-- Label values
		label val pelect yesno
		label val pgas yesno
		label val pcarbon yesno
		label val pparafina yesno
		label val ptelefono yesno

*** How much did you pay for the following utilities?
		*-- Label variable
		* Water
		label var pagua_monto "How much did you pay for the following utilities? Water"
		* Electricity
		*-- Label variable
		label var pelect_monto "How much did you pay for the following utilities? Electricity"
		* Gas
		*-- Label variable
		label var pgas_monto "How much did you pay for the following utilities? Gas"
		* Carbon, wood
		*-- Label variable
		label var pcarbon_monto "How much did you pay for the following utilities? Carbon, wood"
		* Paraffin
		*-- Label variable
		label var pparafina_monto "How much did you pay for the following utilities? Paraffin"
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_monto "How much did you pay for the following utilities? Landline, internet and tv cable"

*** In which currency did you pay for the following utilities?
		* Water
		*-- Label variable
		label var pagua_mon "In which currency did you pay for the following utilities? Water"
		* Electricity
		*-- Label variable
		label var pelect_mon "In which currency did you pay for the following utilities? Electricity"
		* Gas
		*-- Label variable
		label var pgas_mon"In which currency did you pay for the following utilities? Gas"
		* Carbon, wood
		*-- Label variable
		label var pcarbon_mon"In which currency did you pay for the following utilities? Carbon, wood"
		* Paraffin
		*-- Label variable
		label var pparafina_mon"In which currency did you pay for the following utilities? Paraffin"
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_mon "In which currency did you pay for the following utilities? Landline, internet and tv cable"

*** In which month did you pay for the following utilities?
		* Water
		*-- Label variable
		label var pagua_m "In which month did you pay for the following utilities? Water"
		*-- Label values
		label val pagua_m month 
		* Electricity
		*-- Label variable
		label var pelect_m "In which month did you pay for the following utilities? Electricity"
		*-- Label values
		label val pelect_m month
		* Gas
		*-- Label variable
		label var pgas_m "In which month did you pay for the following utilities? Gas"
		*-- Label values
		label val pgas month
		* Carbon, wood
		label var pcarbon_m "In which month did you pay for the following utilities? Carbon, wood"
		*-- Label values
		label val pcarbon_m month
		* Paraffin
		*-- Label variable
		label var pparafina_m "In which month did you pay for the following utilities? Paraffin"
		*-- Label values
		label val pparafina_m month
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_m "In which month did you pay for the following utilities? Landline, internet and tv cable"
		*-- Label values
		label val ptelefono_m month

*** In your household, have any home appliences damaged due to blackouts or voltage inestability?
		*-- Label variable
		label var danio_electrodom "In your household, have any home appliences damaged due to blackouts or voltage inestability?"
		*-- Label values
		label val danio_electrodom yesno

	
/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Dummy household owns cars
*  AUTO (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
		*-- Label variable
		label var auto "Dummy household owns cars"
		*-- Label values
		label def auto 1 "Yes" 0 "No"
		label val auto auto

*** Number of functioning cars in the household
* NCARROS (s5q4a) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
		*-- Label variable
		label var ncarros "Number of functioning cars in the household"

*** Year of the most recent car
		*-- Label variable
		label var anio_auto "Year of the most recent car"


*** Does the household have fridge?
* Heladera (s5q6__1): ¿Posee este hogar nevera?
		*-- Label variable
		label var heladera "Does the household have fridge?"
		*-- Label values
		label def heladera 1 "Yes" 0 "No"
		label val heladera heladera

*** Does the household have washing machine?
* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
		*-- Label variable
		label var lavarropas "Does the household have washing machine?"
		*-- Label values
		label def lavarropas 1 "Yes" 0 "No"
		label val lavarropas lavarropas

*** Does the household have dryer
* Secadora (s5q6__3): ¿Posee este hogar secadora? 
		*-- Label variable
		label var secadora "Does the household have dryer"
		*-- Label values
		label def secadora 1 "Yes" 0 "No"
		label val secadora secadora


*** Does the household have computer?
* Computadora (s5q6__4): ¿Posee este hogar computadora?
		*-- Label variable
		label var computadora "Does the household have computer?"
		*-- Label values
		label def computadora 1 "Yes" 0 "No"
		label val computadora computadora
		
*** Does the household have internet?
* Internet (s5q6__5): ¿Posee este hogar internet?
		*-- Label variable
		label var internet "Does the household have internet?"
		*-- Label values
		label def internet 1 "Yes" 0 "No"
		label val internet internet

*** Does the household have tv?
* Televisor (s5q6__6): ¿Posee este hogar televisor?
		*-- Label variable
		label var televisor "Does the household have tv?"
		*-- Label values
		label def televisor 1 "Yes" 0 "No"
		label val televisor televisor

*** Does the household have radio?
* Radio (s5q6__7): ¿Posee este hogar radio? 
		*-- Label variable
		label var radio "Does the household have radio?"
		*-- Label values
		label def radio 1 "Yes" 0 "No"
		label val radio radio

*** Does the household have heater?
* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
		*-- Label variable
		label var calentador "Does the household have heater?"
		*-- Label values
		label def calentador 1 "Yes" 0 "No"
		label val calentador calentador

*** Does the household have air conditioner?
* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
		*-- Label variable
		label var aire "Does the household have air conditioner?"
		*-- Label values
		label def aire 1 "Yes" 0 "No"
		label val aire aire

*** Does the household have cable tv?
* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
		*-- Label variable
		label var tv_cable "Does the household have cable tv?"
		*-- Label values
		label def tv_cable 1 "Yes" 0 "No"
		label val tv_cable tv_cable

*** Does the household have microwave oven?
* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
		*-- Label variable
		label var microondas "Does the household have microwave oven?"
		*-- Label values
		label def microondas 1 "Yes" 0 "No"
		label val microondas microondas

*** Does the household have landline telephone?
* Teléfono fijo (s5q6__12): telefono_fijo
		*-- Label variable
		label var telefono_fijo "Does the household have landline telephone?"
		*-- Label values
		label def telefono_fijo 1 "Yes" 0 "No"
		label val telefono_fijo telefono_fijo
		
/*(************************************************************************************************************************************************* 
*------------------------------------------------------ VII. EDUCATION / EDUCACIÓN -----------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Is the "member" answering by himself/herself?
		*-- Label variable
		label var contesta_ind_e "Is the 'member' answering by himself/herself?"
		*-- Label values
		label def contesta_ind_e 1 "Yes" 0 "No"
		label val contesta_ind_e contesta_ind
		
*** Who is answering instead of "member"?
		*-- Label variable
		label var quien_contesta_e "Who is answering instead of 'member'?"
		*-- Label values
		label def quien_contesta_e 1 "Head of the household" ///	
		02 "Spouse/partner" ///
		03 "Son/daughter" ///
		04 "Stepson/stepdaughter" ///
		05 "Grandchild"	 ///
		06 "Son/daugther/father/mother-in-law" ///
		07 "Father/mother"  ///
		08 "Sibling"  ///
		09 "Brother/sister-in-law"   ///  
		10 "Nephew/niece"  ///
		11 "Other relative"  ///
		12 "Other: non relative"  ///
		13 "House maid"
		label val quien_contesta_e quien_contesta_e

*** Have you ever attended any educational center? //for age +3
		*-- Label variable
		label var asistio_educ "Have you ever attended any educational center? (for age +3)"
		*-- Label values
		label def asistio_educ 1 "Yes" 0 "No"
		label val asistio_educ asistio_educ

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
		*-- Label variable
		label var razon_noasis "Reasons for never attending"
		*-- Label values
		label def razon_noasis 1 "Too young" ///
		2 "The school is too far" ///
		3 "The school is closed"  ///
		4 "Strikes/teachers absences"  ///
		5 "Cost of school supplies"  ///
		6 "Cost of school uniform"  ///
		7 "Illness/disability"  ///
		8 "Must work"  ///
		9 "Insecurity when attending the educational center"  ///
		10 "Discrimination"  ///
		11 "Violence"  ///
		14 "Duties in the household"  ///
		15 "Attending school is not important"  ///
		16 "Other. Mention it"
		label val razon_noasis razon_noasis

*** During the period 2019-2020 did you attend any educational center? //for age +3
		*-- Label variable
		label var asiste "During the period 2019-2020 did you attend any educational center? (for age +3)"
		*-- Label values
		label def asiste 1 "Yes" 0 "No"
		label val asiste asiste 

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
		*-- Label variable
		label var nivel_educ_act "During the period 2019-2020 did you attend any educational center? (for age +3)"
		*-- Label values
		label def nivel_educ_act_en 1 "None" ///		
        2 "Kindergarten" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"	
		label val nivel_educ_act nivel_educ_act_en


*** Which grade are you currently attending
/* G_EDUC_ACT (s7q4a): ¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
		*-- Label variable
		label var g_educ_act  "Which grade are you currently attending. For Regimen Actual: Primary and Media"

*** Regimen de estudios
* REGIMEN_ACT (s7q4b): El regimen de estudios es anual, semestral o trimestral?
		*-- Label variable
		label var regimen_act "Educational regimen (current): Annual, Biannual ot quarterly"
		*-- Label values
		label def regimen_act 1 "Annual" 2 "Biannual" 3 "Quarterly"
		label val regimen_act regimen_act

*** Which year are you currently attending	?	
/* A_EDUC_ACT (s7q4c): ¿Cuál es el ano al que asiste? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
		*-- Label variable
		label var a_educ_act "Which year are you currently attending?"

*** Which semester are you currently attending?
/* S_EDUC_ACT (s7q4d): ¿Cuál es el semestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
		*-- Label variable
		label var s_educ_act "Which semester are you currently attending?"


*** Which quarter are you currently attending?
/* T_EDUC_ACT (s7q4e): ¿Cuál esel trimestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
		*-- Label variable
		label var t_educ_act "Which quarter are you currently attending?"

*** Type of educational center
/* TIPO_CENTRO_EDUC (s7q5): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		.
		.a
*/

		*-- Label variable
		label var tipo_centro_educ "The educational center is: (this survey)"
		*-- Label values
		label def tipo_centro_educ 1 "Private" 2 "Public"
		label value tipo_centro_educ tipo_centro_educ
		
		*-- Label variable
		label var edu_pub "The educational center is:(harmonized)"
		*-- Label values
		label def edu_pub 0 "Private" 1 "Public"
		label value edu_pub edu_pub

*** During this school period, did you stop attending the educational center where you regularly study due to:
* Water failiures
		*-- Label variable
		label var fallas_agua "Have you ever stopped attending the educational center where you regularly study due to: water failiures"
		*-- Label values
		label def fallas_agua 0 "No" 1 "Yes"
		label value fallas_agua fallas_agua

* Electricity failures
		*-- Label variable
		label var fallas_elect "Have you ever stopped attending the educational center where you regularly study due to: electricity failiures"
		*-- Label values
		label def fallas_elect 0 "No" 1 "Yes"
		label value fallas_elect fallas_elect

* Teachers' strike
		*-- Label variable
		label var huelga_docente "Have you ever stopped attending the educational center where you regularly study due to: teachers' strike"
		*-- Label values
		*-- Label values
		label def huelga_docente 0 "No" 1 "Yes"
		label value huelga_docente huelga_docente

* Lack of means of transport
		*-- Label variable
		label var falta_transporte "Have you ever stopped attending the educational center where you regularly study due to: lack of means of transport"
		label def falta_transporte 0 "No" 1 "Yes"
		label value falta_transporte falta_transporte

* Lack of food in the household
		*-- Label variable
		label var falta_comida_hogar "Have you ever stopped attending the educational center where you regularly study due to: lack of food in the household"
		*-- Label values
		label def falta_comida_hogar 0 "No" 1 "Yes"
		label value falta_comida_hogar falta_comida_hogar

* Lack of food in the educational center
		*-- Label variable
		label var falta_comida_centro "Have you ever stopped attending the educational center where you regularly study due to: lack of food in the educational center"
		*-- Label values
		label def falta_comida_centro 0 "No" 1 "Yes"
		label value falta_comida_centro falta_comida_centro

* Teachers's non-attendance
		*-- Label variable
		label var inasis_docente "Have you ever stopped attending the educational center where you regularly study due to: teachers's non-attendance"
		*-- Label values
		label def inasis_docente 0 "No" 1 "Yes"
		label value inasis_docente inasis_docente

* Demonstrations or protests
		*-- Label variable
		label var protestas "Have you ever stopped attending the educational center where you regularly study due to: demonstrations or protests"
		*-- Label values
		label def protestas 0 "No" 1 "Yes"
		label value protestas protestas

* Never stopped attending 
		*-- Label variable
		label var nunca_deja_asistir "Have you ever stopped attending the educational center where you regularly study due to: never stopped attending "
		*-- Label values
		label def nunca_deja_asistir 0 "No" 1 "Yes"
		label value nunca_deja_asistir nunca_deja_asistir

*** The educational center where you attend has PAE's schools feeding program?
		*-- Label variable
		label var pae "The educational center where you attend has PAE's schools feeding program?"
		*-- Label values
		label def pae 0 "No" 1 "Yes"
		label value pae pae

*** In the educational center where you attend, PAE's schools feeding program is provided:
/* 		1.Every day
		2.Only few days
		3.Hardly ever
*/
		*-- Label variable
		label var pae_frecuencia "In the educational center where you attend, PAE's schools feeding program is provided:"
		*-- Label values
		label def pae_frecuencia 1 "Every day" ///
		2 "Only few days" ///
		3 "Hardly ever"
		label value pae_frecuencia pae_frecuencia

*** In the educational center where you attend, PAE's schools feeding program provides:
	* Breakfast
		*-- Label variable
		label var pae_desayuno "In the educational center where you attend, PAE's provides: breakfast"
		*-- Label values
		label def pae_desayuno 1 "Yes" 0 "No"
		label value pae_desayuno pae_desayuno

	* Lunch
		*-- Label variable
		label var pae_almuerzo "In the educational center where you attend, PAE's provides: lunch"
		*-- Label values
		label def pae_almuerzo 1 "Yes" 0 "No"
		label value pae_almuerzo pae_almuerzo

	* Snack in the morning (Merienda en la manana)
		*-- Label variable
		label var pae_meriman "In the educational center where you attend, PAE's provides: snack in the morning"
		*-- Label values
		label def pae_meriman 1 "Yes" 0 "No"
		label value pae_meriman pae_meriman

	* Snack in the afternoon (Merienda en la tarde)
		*-- Label variable
		label var pae_meritard "In the educational center where you attend, PAE's provides: snack in the afternoon"
		*-- Label values
		label def pae_meritard 1 "Yes" 0 "No"
		label value pae_meritard pae_meritard

	* Other
		*-- Label variable
		label var pae_otra "In the educational center where you attend, PAE's provides: other"
		*-- Label values
		label def pae_otra 1 "Yes" 0 "No"
		label value pae_otra pae_otra

*** During school year 2019-2020 did you pay for, obtain or receive donation of the following items?
	* Registration fee (Cuota de inscripción)
		*-- Label variable
		label var cuota_insc "During 2019-2020 did you pay for, obtain or receive donation of: registration fee"
		*-- Label values
		label def cuota_insc 1 "Yes" 0 "No"
		label value cuota_insc cuota_insc

	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
		label var compra_utiles "During 2019-2020 did you pay for, obtain or receive donation of: school supplies and books"
		*-- Label values
		*-- Label values
		label def compra_utiles 1 "Yes" 0 "No"
		label value compra_utiles compra_utiles

	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme "During 2019-2020 did you pay for, obtain or receive donation of: school uniforms and footwear"
		*-- Label values
		label def compra_uniforme 1 "Yes" 0 "No"
		label value compra_uniforme compra_uniforme

	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men "During 2019-2020 did you pay for, obtain or receive donation of: monthly fee"
		*-- Label values
		label def costo_men 1 "Yes" 0 "No"
		label value costo_men costo_men

	* Public transport or school bus(Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp "During 2019-2020 did you pay for, obtain or receive donation of: public transport or school bus"
		*-- Label values
		label def costo_transp 1 "Yes" 0 "No"
		label value costo_transp costo_transp

	* Other expenses
		*-- Label variable
		label var otros_gastos "During 2019-2020 did you pay for, obtain or receive donation of: other expenses"
		*-- Label values
		label def otros_gastos 1 "Yes"0 "No"
		label value otros_gastos otros_gastos

*** Amount paid for each item
	* Registration fee (Cuota de inscripción)
		*-- Label variable
		label var cuota_insc_monto "Amount: registration fee"

	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
		label var compra_utiles_monto "Amount: school supplies and books"

	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme_monto "Amount: school uniforms and footwear"

	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men_monto "Amount: monthly fee"

	* Public transport or school bus (Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp_monto "Amount: Public transport or school bus"

	* Other expenses
		*-- Label variable
		label var otros_gastos_monto "Amount: other expenses"

*** Currency unit 
* Registration fee (Cuota de inscripción)
	*-- Label variable
		label var cuota_insc_mon "Currency unit: registration fee"
	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
		label var compra_utiles_mon "Currency unit: school supplies and books"
	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme_mon "Currency unit: school uniforms and footwear"
	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men_mon "Currency unit: monthly fee"
	* Public transport or school bus (Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp_mon "Currency unit: public transport or school bus"
	* Other expenses
		*-- Label variable
		label var otros_gastos_mon "Currency unit: other expenses"

*** Month in which the item was paid
	* Registration fee (Cuota de inscripción)
		*-- Label variable
			label var cuota_insc_m "Month: registration fee"
	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
			label var compra_utiles_m "Month: school supplies and books"
	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme_m "Month: school uniforms and footwear"
	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men_m "Month: monthly fee"
	* Public transport or school bus (Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp_m "Month: public transport or school bus"
	* Other expenses
		*-- Label variable
		label var otros_gastos_m "Month: other expenses"

*** Educational attainment
/* NIVEL_EDUC_EN (s7q11): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  
		1 = None (Ninguno)	
        2 = Preescolar
		3 = Regimen anterior: Basica (1-9)
		4 = Regimen anterior: Media (1-3)
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado
		
		1 "None" ///		
        2 "Kindergarten" ///
		3 "Regimen anterior: Basica (1-9)" ///
		4 "Regimen anterior: Media (1-3)" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"	
*/
	*-- Label variable
	label var nivel_educ_en  "Education attained (this survey)"
	*-- Label values 
	label def nivel_educ_en 1 "None" ///		
        2 "Kindergarten" ///
		3 "Regimen anterior: Basica (1-9)" ///
		4 "Regimen anterior: Media (1-3)" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"
	label values nivel_educ_en nivel_educ_en	
	
/* NIVEL_EDUC: Comparable across years
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
*/
	*-- Label variable
	label var nivel_educ "Education attained (harmonized)"
	*-- Label values 	
	label def nivel_educ_eng 1 "None" 2 "Kindergarten" 3 "Primary" 4 "Media" 5 "Tecnico (TSU)" 6 "University" 7 "Postgraduated"
	label value nivel_educ nivel_educ_eng

*** Which was the last grade you completed?
/* G_EDUC (s7q11a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
	*-- Label variable
	label var g_educ "Last grade completed"
	
*** Cual era el regimen de estudios
* REGIMEN (s7q11ba): El regimen de estudios era anual, semestral o trimestral?
	*-- Label variable
	label var regimen "Educational regimen (completed): Annual, Biannual ot quarterly"
	*-- Label values
	label def regimen 1 "Annual" 2 "Biannual" 3 "Quarterly"
	label val regimen regimen

*** Which was the last year you completed?
/** A_EDUC (s7q4b): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
	*-- Label variable
	label var a_educ "Last year completed"

*** Which was the last semester you completed?
/* S_EDUC (emhp27c): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
	*-- Label variable
	label var s_educ "Last semester completed"

*** Which was the last quarter you completed?
/* T_EDUC (emhp27d): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
	*-- Label variable
	label var t_educ "Last quarter completed"

***  Literacy
*Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)

	*-- Label variable
	label var alfabeto "Literate: received at least two years of formal education"
	*-- Label values
	label def alfabeto 1 "Yes" 0 "No"
	label val alfabeto alfabeto

/*
*** Obtuvo el titulo respectivo //missing in database
gen titulo = s7q11e==1 if s7q1==1 & (s7q11>=7 & s7q11<=9) 
*/

*** A que edad termini/dejo los estudios
	*-- Label variable
	label var edad_dejo_estudios "Age when completed/left studies"

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
		
		1 "Completed studies" ///
		2 "The school was too far" ///
		3 "The school closed" ///
		4 "Strikes/teachers absences" ///
		5 "Cost of school supplies" ///
		6 "Cost of school uniform" ///
		7 "Illness/disability" ///
		8 "Must work" ///
		9 "Do not wanted to continue studying" ///
		10 "Insecurity when attending the educational center" ///
		11 "Discrimination" ///
		12 "Violence" ///
		13 "Pregnancy/take care of children" ///
		14 "Duties in the household" ///
		15 "Attending school was not important" ///
		16 "Other. Mention it"
*/
	*-- Label variable
	label var razon_dejo_estudios "Main reason: left studies (this survey)"
	*-- Label values	
	label def razon_dejo_estudios 	1 "Completed studies" ///
		2 "The school was too far" ///
		3 "The school closed" ///
		4 "Strikes/teachers absences" ///
		5 "Cost of school supplies" ///
		6 "Cost of school uniform" ///
		7 "Illness/disability" ///
		8 "Must work" ///
		9 "Do not wanted to continue studying" ///
		10 "Insecurity when attending the educational center" ///
		11 "Discrimination" ///
		12 "Violence" ///
		13 "Pregnancy/take care of children" ///
		14 "Duties in the household" ///
		15 "Attending school was not important" ///
		16 "Other. Mention it"
	label val razon_dejo_estudios razon_dejo_estudios 
	

	*-- Label variable
	label var razon_dejo_est_comp "Main reason: left studies (harmonized)"
	*-- Label values	
	label def razon_dejo_est_comp_eng 	1 "Completed studies" ///
		2 "The school was too far" ///
		3 "The school closed" ///
		4 "Strikes/teachers absences" ///
		5 "Cost of school supplies" ///
		6 "Cost of school uniform" ///
		7 "Illness/disability" ///
		8 "Must work" ///
		9 "Do not wanted to continue studying" ///
		10 "Insecurity when attending the educational center" ///
		11 "Discrimination or violence" ///
		12 "Pregnancy/take care of children" ///
		13 "Duties in the household" ///
		14 "Attending school was not important" ///
		15 "Other. Mention it"
	label val razon_dejo_est_comp razon_dejo_est_comp_eng


/*(************************************************************************************************************************************************ 
*------------------------------------------------------ VIII. HEALTH / SALUD ---------------------------------------------------------------------
************************************************************************************************************************************************)*/

label var	enfermo 		"Any health problem, illness, or accident in the last 30 days?"
label var	enfermedad 		"Which was your main health problem?"
label def	enfermedad 		1 "Fever / Malaria" 2 "Diarrhea" 3 "Accident / Injury" 4 "Dental problem" ///
							5 "Skin problem" 6 "Eye disease" 7 "Tension problem" 8 "Typhoid fever" 9 "Stomach problem" ///
							10 "Sore throat" 11 "Cough, cold, flu" 12 "Diabetes" 13 "Meningitis" 14 "Other"
label values enfermedad enfermedad
label var	enfermedad_o 	"Which was your main health problem? Other"
label var	visita 			"Have you gone to get healthcare in the last 30 days?"
label def	visita			1 "Yes" 0 "No"
label values visita visita
label var	razon_no_medico "Why didn't you try to consult to treat the sickness or accident?"
label def	razon_no_medico 1 "Self-medicated, used home-made medicines" 2 "Doesn't have money to pay for consultation, exams, medicines" 3 "Didn't consider it necessary, didn't do anything" ///
							4 "Consultation place is far from the household" 5 "Attention is not adecuate" 6 "Waiting time is too long" 7 "Didn't get attended" 8 "Other"
label values razon_no_medico razon_no_medico
label var razon_no_medico_o "Why didn't you try to consult to treat the sickness or accident?(Other)"
label var	medico_o_quien 	"Who did you mainly consult to treat the sickness or accident?"
label def	medico_o_quien	1 "Doctor" 2 "Nurse or another paramedic assistant" 3 "Pharmacist" 4 "Healer, herbalist, or warlock" 5 "Other"
label values medico_o_quien medico_o_quien
label var	medico_o_quien_o	"Who did you mainly consult to treat the sickness or accident? Other"
label var	lugar_consulta 		"Where did you go for healthcare attention?"
label def	lugar_consulta		1 "Outpatient clinic / popular clinic / CDI" 2 "Public hospital or of the social security" 3 "Private service without hospitalization" 4 "Private clinique" ///
								5 "Private health center non-for-profit" 6 "Health service in the work station" 7 "Pharmacy" 8 "Other"
label values lugar_consulta lugar_consulta
label var	lugar_consulta_o 	"Where did you go for healthcare attention? Other"
label var	pago_consulta 		"Did you pay for consultation or healthcare attention?"
label def 	pago_consulta		1 "Yes" 0 "No"
label values pago_consulta pago_consulta
label var	cant_pago_consulta 	"How much did you pay?"
label var	mone_pago_consulta 	"In which month did you pay?"
label def	mone_pago_consulta	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
label values mone_pago_consulta mone_pago_consulta
label var	mes_pago_consulta 	"In which month did you pay?"
label def 	mes_pago_consulta 	1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values mes_pago_consulta mes_pago_consulta
label var	receto_remedio 		"Did you get any medicine prescribed for the illness of accident?"
label def 	receto_remedio		1 "Yes" 0 "No"
label values receto_remedio receto_remedio
label var	recibio_remedio		"How did you get the medicines?"
label def	recibio_remedio		1 "Received all for free" 2 "Received some for free and others bought" 3 "Bought all" 4 "Bought some" 5 "Received some for free and others couldn't buy" 6 "Could not obtain any"
label values recibio_remedio recibio_remedio
label var	donde_remedio 		"Where did you buy the medicines?"
label def	donde_remedio		1 "Popular drugstores or pharmacies" 2 "Other commercial pharmacies" 3 "Institutes of Social Welfare or other foundations (IPAS-ME, IPSFA, others)" 4 "Other"
label values donde_remedio donde_remedio
label var	donde_remedio_o		"Where did you buy the medicines? Other"
label var	pago_remedio 		"How much did you pay for the medicines?"
label var	mone_pago_remedio 	"In which currency did you payfor the medicines?"
label def	mone_pago_remedio	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
label values mone_pago_remedio mone_pago_remedio
label var	mes_pago_remedio 	"In which month did you pay for the medicines?"
label def	mes_pago_remedio	1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values mes_pago_remedio mes_pago_remedio
label var	pago_examen 		"Did you pay for Xrays, lab exams or similar?"
label def	pago_examen			1 "Yes" 0 "No"
label values pago_examen pago_examen
label var	cant_pago_examen 	"How much did you pay for Xrays, lab exams or similar?"
label var	mone_pago_examen 	"In which currency did you pay for Xrays, lab exams or similar?"
label def	mone_pago_examen	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
label values mone_pago_examen mone_pago_examen
label var	mes_pago_examen 	"In which month did you pay for Xrays, lab exams or similar?"
label def	mes_pago_examen		1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values mes_pago_examen mes_pago_examen
label var	remedio_tresmeses 	"Spent money in medicines in the last 3 months?"
label var	cant_remedio_tresmeses 	"How much did you pay for medicines in the last 3 months?"
label var	mone_remedio_tresmeses 	"In which currency did you pay for medicines in the last 3 months?"
label var	mes_remedio_tresmeses 	"In which month did you pay for medicines in the last 3 months?"
label var	seguro_salud 		"Affiliated to health insurance?"
label def	seguro_salud		1 "Yes" 0 "No"
label values seguro_salud seguro_salud
label var	afiliado_segsalud 	"Main health insurance affiliated to"
label def 	afiliado_segsalud	1 "Venezuelan institute of Social Insurance (IVSS)" 2 "Public social welfare institute (IPASME, IPSFA, others)" 3 "Medical insurance contracted by a public institution" 4 "Medical insurance contracted by a private institution" 5 "Private health insurance contracted individually" 
label values afiliado_segsalud afiliado_segsalud
label var	pagosegsalud 		"Did you pay for health insurance?"
label def	pagosegsalud		1 "Yes" 0 "No"
label values pagosegsalud pagosegsalud
label var	quien_pagosegsalud 	"Who paid for the health insurance?"
label def 	quien_pagosegsalud	1 "Labor benefit" 2 "Family member abroad" 3 "Another household member" 4 "Other"
label values quien_pagosegsalud quien_pagosegsalud
label var  	quien_pagosegsalud_o "Who paid for the health insurance? Other"
label var	cant_pagosegsalud 	"How much did you pay for the health insurance?"
label var	mone_pagosegsalud 	"In which currency did you pay for the health insurance?"
label def	mone_pagosegsalud	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
label values mone_pagosegsalud mone_pagosegsalud
label var	mes_pagosegsalud	"In which month did you pay for the health insurance?"
label def	mes_pagosegsalud	1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec"
label values mes_pagosegsalud mes_pagosegsalud


/*(************************************************************************************************************************************************* 
*---------------------------------------------------------- IX: LABOR / EMPLEO ---------------------------------------------------------------
*************************************************************************************************************************************************)*/

label var  	trabajo_semana  	"Did you work at least one hour last week?"
label def	trabajo_semana		1 "Yes" 0 "No"
label values trabajo_semana trabajo_semana 
label var  	trabajo_semana_2  	"Did you dedicate last week at least one hour to..."
label def	trabajo_semana_2	1 "Perform an activity that provided you income" ///
								2 "Helped in lands or business from family or another person" ///
								3 "Did not work last week"			
label values trabajo_semana_2 trabajo_semana_2
label var  	trabajo_independiente  	"Do you have any job, business, or do you do any activity on your own?"
label def	trabajo_independiente	1 "Yes" 0 "No"
label values trabajo_independiente trabajo_independiente
label var  	razon_no_trabajo  	"Main reason for not working last week"
label def 	razon_no_trabajo 	1 "Was sick" 2 "Vacations" 3 "Permit" 4 "Labor conflicts" 5 "Reparation of equipment, machinery or vehicle" 7 "Does not want to work" 8 "Lack of work, clients or orders" /// 
								9 "Impediment of municipal or national authorities" 10 "Will start new employment in 30 days" 11 "Stationary factors" 16 "Other"		
label values razon_no_trabajo razon_no_trabajo
label var  	razon_no_trabajo_o 	"Other reason for not working last week"
label var  	sueldo_semana 		"Last week did you receive wages or benefits?"
label def	sueldo_semana		1 "Yes" 0 "No"
label values sueldo_semana 
label var  	busco_trabajo 	"Did you do anything to look for a paid job in the last 4 weeks?"
label def	busco_trabajo	1 "Yes" 0 "No"
label values busco_trabajo busco_trabajo
label var  	empezo_negocio  "Did you do anything to start a business in the last 4 weeks?"
label def	empezo_negocio	1 "Yes" 0 "No"
label values empezo_negocio empezo_negocio
label var  	cuando_buscotr 	"Last time you did something to find a job or start a business jointly or alone?"
label def	cuando_buscotr	1 "Last 2 months" 2 "Last 12 months" 3 "More than a year" 4 "Have not done anything"
label values cuando_buscotr

label var  	dili_agencia 	"Have you consulted an employment agency in the last 4 weeks?" 
label var  	dili_aviso  	"Have you published or answered work ads in the last 4 weeks?"
label var  	dili_planilla  	"Have you filled in any job-related forms in the last 4 weeks?"
label var  	dili_credito  	"Have you searched for credit or a shop in the last 4 weeks?"
label var  	dili_tramite 	"Have you done permit or legalization paperwork for work in the last 4 weeks?"
label var  	dili_compra 	"Have you bought supplies or raw materials in the last 4 weeks?"
label var  	dili_contacto  	"Have you contacted staff in the last 4 weeks?"
label var  	dili_otro	 	"Have you done other diligencies to start work in the last 4 weeks?"
label var  	como_busco_semana 	"Have you carried out any of these proceedings in that period? (4 weeks)"

foreach i of varlist dili_agencia dili_aviso dili_planilla dili_credito dili_tramite dili_compra dili_contacto dili_otro {
	label def	`i'	1 "Yes" 0 "No"
	label values `i' `i'
	}
	
label var  	razon_no_busca 	"Why aren't you currently looking for a job?"
label def	razon_no_busca 	1 "Tired of looking for a job" 2 "Doesn't find the appropriate job" 3 "Thinks that can't find job" ///
							4 "Doesn't know how nor where to look for a job" 5 "Thinks that won't be given a job due to age" ///
							6 "No job adapts to his/her capacities" 7 "Doesn't have someone to take care of the children" 8 "Sick/Health motives" ///
							9 "Other motives, specify"
label values razon_no_busca razon_no_busca
label var  	actividades_inactivos 	"What are you doing right now? (only for those who did not work)"
label def	actividades_inactivos 	1 "Studying" 2 "Training" 3 "Household activities or family responsibilities" 4 "Working on land for family use" ///
									6 "Retired or pensione" 7 "Long-term illness" 8 "Disability" 9 "Voluntary work" 10 "Charity work" 11 "Cultural or leisure activities"
label values  actividades_inactivos actividades_inactivos
label var  	tarea 	"What is your position at your main occupation?"
label def	tarea	1 "Director or manager" 2 "Scientific or intellectual professional" 3 "Technician or mid-level professional" 4 "Administrative support staff" ///
					5 "Service worker or seller of shops and markets" 6 "Farmer or skilled agricultural, forestry or fishing worker" ///
					7 "Official, operator or craftsman of mechanical arts and other trades" 8 "Operator of fixed installations and machines and machinery" ///
					9 "Elementary occupations" 10 "Military occupations"
label values  tarea tarea
label var  	sector_encuesta 	"What does the business, institution or firm in which you work do?"
label def	sector_encuesta		1 "Agriculture, livestock, fishing, hunting and related service activities" 2 "Mining and quarrying" 3 "Manufacturing industry" 4 "Installation / supply / distribution of electricity, gas or water" 5 "Construction" ///
								6 "Wholesale and retail trade; repair of motor vehicles and motorcycles" 7 "Transportation, storage, lodging and food service, communications and computer services" 8 "Financial and insurance, real estate, professional, scientific and technical entities; and administrative support services" ///
								9 "Public administration and defense, education, health, social assistance, art, entertainment, embassies" 10 "Other service activities such as repairs, cleaning, hairdressing, funeral and domestic service"
label values  sector_encuesta sector_encuesta
label var  	categ_ocu  	"In your work you work as..."
label def	categ_ocu	1 "Employee or worker in the public sector" 3 "Employee or worker in a private company" 5 "Employer or employer" ///
						6 "Self-employed worker" 7 "Member of cooperatives" 8 "Paid / unpaid family helper" 9 "Domestic service"
label values categ_ocu categ_ocu
label var  	hstr_ppal  			"How many hours did you work last week in your main occupation?"
label var  	trabajo_secundario  "Besides your main occupation, did you do any other activity through which you received income, such as selling things, contracted work, etc?"
label def	trabajo_secundario 	1 "Yes" 0 "No"
label values trabajo_secundario trabajo_secundario
label var  	hstr_todos 		"How many hours do you normally work weekly in all your jobs or businesses?"

label var  	im_sueldo  		"Received income in your job or business for wages and salaries in the last month?"
label var  	im_hsextra 		"Received income in your job or business for overtime in the last month?"
label var  	im_propina 		"Received income in your job or business for tips in the last month?"
label var  	im_comision 	"Received income in your job or business for commissions in the last month?"
label var  	im_ticket 		"Received income in your job or business for ticket basket, food card in the last month?"
label var  	im_guarderia 	"Received income in your job or business for childcare contribution in the last month?"
label var  	im_beca 		"Received income in your job or business for study grant in the last month?"
label var  	im_hijos 		"Received income in your job or business for child premium in the last month?"
label var  	im_antiguedad 	"Received income in your job or business for antiquity in the last month?"
label var  	im_transporte 	"Received income in your job or business for transportation voucher in the last month?"
label var  	im_rendimiento 	"Received income in your job or business for performance bonus in the last month?"
label var  	im_otro 		"Received income in your job or business for other bonuses and compensation in the last month?"

label var  	c_sso  	"Received contributions from your employer to social security for compulsory social security?"
label var  	c_rpv  	"Received contributions from your employer to social security for housing and habitat benefits scheme?"
label var  	c_spf  	"Received contributions from your employer to social security for forced unemployment insurance?"
label var  	c_aca  	"Received contributions from your employer to social security for contribution from the savings bank?"
label var  	c_sps  	"Received contributions from your employer to social security for contributions to the private insurance system?"
label var  	c_otro 	"Received contributions from your employer to social security for other contributions?"

foreach i of varlist ///
im_sueldo im_hsextra im_propina im_comision im_ticket im_guarderia im_beca im_hijos im_antiguedad im_transporte im_rendimiento im_otro ///
c_sso c_rpv c_spf c_aca c_sps c_otro {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  `i'_cant		"Amount" 
	label var  	`i'_mone	"Currency" 
	label def	`i'_mone	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
	label values `i' `i'
	}
	
label var  	inm_comida  	"Received this benefit in your work in the last month?: food"
label var  	inm_productos  	"Received this benefit in your work in the last month?: company products?"
label var  	inm_transporte  "Received this benefit in your work in the last month?: transportation?"
label var  	inm_vehiculo  	"Received this benefit in your work in the last month?: vehicle for private use?"
label var  	inm_estaciona  	"Received this benefit in your work in the last month?: parking fee exemption?"
label var  	inm_telefono 	"Received this benefit in your work in the last month?: personal phone?"
label var  	inm_servicios  	"Received this benefit in your work in the last month?: basic housing services?"
label var  	inm_guarderia  	"Received this benefit in your work in the last month?: daycare from work?"
label var  	inm_otro  		"Received this benefit in your work in the last month?: other benefits?"

foreach i of varlist inm_comida inm_productos inm_transporte inm_vehiculo inm_estaciona inm_telefono inm_servicios inm_guarderia inm_otro  {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  	`i'_cant	"Amount received, or estimation of how much they would have paid for the benefit" 
	label var  	`i'_mone	"Currency" 
	label def	`i'_mone	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
	label values `i' `i'
	}
	
label var  	d_sso  	"Discounted from your monthly labor income for compulsory social security last month?"
label var  	d_spf  	"Discounted from your monthly labor income for forced unemployment insurance last month?"
label var  	d_isr  	"Discounted from your monthly labor income for income tax last month?"
label var  	d_cah  	"Discounted from your monthly labor income for savings bank last month?"
label var  	d_cpr  	"Discounted from your monthly labor income for loan fees last month?"
label var  	d_rpv  	"Discounted from your monthly labor income for housing and Habitat Benefit Regime last month?"
label var  	d_otro  "Discounted from your monthly labor income for others last month?"

foreach i of varlist d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro  {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  	`i'_cant		"Amount discounted" 
	label var  	`i'_mone	"Currency" 
	label def	`i'_mone	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
	label values `i' `i'
	}

label var  	im_patron  	"Received money due to the selling of products, goods, or services from your business or activity last month?"
label var  	inm_patron  "Took products from your business or activity for you own or your household's consumption last month?"
label var  	im_indep  	"Received money or net benefits derived from your business or activity in the last 12 months?"
label var  	i_indep_mes  "Received income from your activity for own expenses or from your household in the last month?"

foreach i of varlist im_patron inm_patron im_indep i_indep_mes {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  	`i'_cant	"Amount" 
	label var  	`i'_mone	"Currency" 
	label def	`i'_mone	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
	label values `i' `i'
	}

label var  	g_indep_mes_cant  	"How much money did you spend to generate income (e.g. office renting, transport expenditures, cleaning products) last month?"
label var  	g_indep_mes_mone	"Currency" 
label def	g_indep_mes_mone	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
label values g_indep_mes_mone g_indep_mes_mone

label var  	razon_menoshs  	"Why did you work less than 35 hours a week last week in all your jobs?"
label def	razon_menoshs 	1 "Work part time" 2 "Labor conflict (strike, protest, unemployment)" 3 "Illness, leave, vacation" ///
							4 "Lack of work" 5 "Shortage of materials or equipment under repair" 6 "Other (Specify)"
label values razon_menoshs razon_menoshs

label var  	deseamashs  	"Would you prefer to work more than 35 hs per week?"
label var  	buscamashs  	"Have you done something to work more hours?"

label var  	razon_nobusca  	"Why haven't you done something to work additional hours?"
label def	razon_nobusca 	1 "Believe there is no work" 2 "Tired of looking for a job" 3 "Can't find a job" 4 "Can't find suitable job" ///
							5 "You are waiting for work or business" 6 "Difficulty in processing permits" 7 "Does not get credits or financing" ///
							8 "Is a student" 9 "Take care of the home" 10 "Illness or disability" 11 "Other (Specify)"
label values razon_nobusca razon_nobusca
label var  	razon_nobusca_o	"Other reason why not done something to work additional hours"

label var  	cambiotr  	"Have you changed jobs in the last 12 months?"
label var  	razon_cambiotr  "Main reason why you changed jobs?"	
label def	razon_cambiotr	1 "Get higher income" 2 "Have a more suitable job" 3 "Termination of contract or employment" ///
							4 "Difficulties with the company (dismissal, reduction of personnel, closure of the company)" ///
							5 "Economic difficulties (lack of materials and supplies to work)" 6 "Other (Specify)"
label values razon_cambiotr razon_cambiotr
label var  	razon_cambiotr_o	"Main reason why you changed jobs? Other"

label var  	aporta_pension  "Do you make contributions to any pension fund?"
label var  	pension_IVSS  	"To which pension fund? IVSS?"
label var  	pension_publi  	"To which pension fund? Another public institution or enterprise?"
label var  	pension_priv  	"To which pension fund? To a private institution or enterprise?"
label var  	pension_otro  	"To another pension fund?"


foreach i of varlist deseamashs buscamashs cambiotr aporta_pension pension_IVSS pension_publi pension_priv pension_otro {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	}

label var  	aporte_pension  "Do you make contributions to any pension fund? To which? (harmonized)"
label def	aporte_pension 	1 "Si, para el IVSS" 2 "Si, para otra institucion o empresa publica" ///
							3 "Si, para institucion o empresa privada" 4 "Si, para otra" 5 "No"
label values aporte_pension aporte_pension

label var  	cant_aporta_pension  	"How much did you pay last month for pension funds?"
label var  	mone_aporta_pension		"Currency" 
	label def	mone_aporta_pension	1 "Bolivares" 2 "US dollars" 3 "Euros" 4 "Colombian pesos"
	label values mone_aporta_pension mone_aporta_pension
	

/*(*********************************************************************************************************************************************** 
*---------------------------------- 9: Otros ingresos y pensiones / Other income and pensions ----------------------------------------------------
***********************************************************************************************************************************************)*/	

*COMPLETE

/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
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
		
		1 "Head of the household" ///	
		2 "Spouse/partner"
		3 "Son/daughter"		
		4 "Stepson/stepdaughter"
		5 "Grandchild"	
		6 "Son/daugther/father/mother-in-law"
		7 "Father/mother"       
		8 "Sibling"
		9 "Brother/sister-in-law"     
		10 "Nephew/niece"
		11 "Other relative"    
		12 "Other: non relative"
		13 "House maid"
 */
	
	*-- Label variable
	label var informant_emig "Informant: Emigration"
	*-- Label values	
	label def informant_emig_eng  1 "Head of the household" 2 "Spouse/partner" 3 "Son/daughter/stepson/stepdaughter" ///
							  4 "Grandchild" 5 "Son/daugther/father/mother-in-law" 6 "Father/mother" 7 "Sibling" ///
							  8 "Brother/sister-in-law" 9 "Nephew/niece" 10 "Other relative" 11 "Other: non relative" ///
							  12 "House maid"
	label value informant_emig  informant_emig_eng


*--------- Emigrant from the household
 /* Emigrant(s10q1): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 */

	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig_eng 1 "Yes" 2 "No"
	label value hogar_emig house_emig_eng

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(s10q2): 2. Cuántas personas?
 
 */

	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household(s10q2a): 2. Cuántas personas?
        
 */	
	
	*-- We will have 10 variables with names
	forval i = 0/9{
	label var nombre_emig_`i' "Name of Emigrants from the household"
	}

	
 *--------- Age of the emigrant
 /* Age of the emigrant(s10q3): 3. Cuántos años cumplidos tiene X?
        
 */
 	*-- We will have 10 variables with names	
	forval i = 1/10 {
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (s10q4): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- We will have 10 variables with names
	forval i = 1/10 {
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i'_eng 1 "Male" 0 "Female"
		label value sexo_emig_`i' sexo_emig_`i'_eng
		}
		
	
 /*
 *--------- Relationship of the emigrant with the head of the household
 Relationship (s10q5): 5. Cuál es el parentesco de X con el Jefe(a) del hogar?
        
 */ 
	*-- We will have 10 variables with names	
	forval i = 1/10 {
	*-- Label variable
	label var relemig_`i' "Emigrant's relationship with the head of the household"
	*-- Label values
	label def remig_`i'_eng 1 "Head of the household" 2 "Spouse/partner" 3 "Son/daughter/stepson/stepdaughter" ///
							  4 "Grandchild" 5 "Son/daugther/father/mother-in-law" 6 "Father/mother" 7 "Sibling" ///
							  8 "Brother/sister-in-law" 9 "Nephew/niece" 10 "Other relative" 11 "Other: non relative" ///
							  12 "House maid"
	label value relemig_`i' remig_`i'_eng
	}
	
	
 *--------- Year in which the emigrant left the household
 /* Year (s10q6a): 6a. En qué año se fue X ?
        
 */	
	*-- We will have 10 variables with names 
	forval i = 1/10 {
	*-- Label variable
	label var anoemig_`i' "Year of emigration"
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (s10q6b): 6a. En qué mes se fue X ?
        
 */	
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Label variable
	label var mesemig_`i' "Month of emigration"
	*-- Label values
	label def mesemig_`i'_eng 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" ///
	6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label val mesemig_`i' mesemig_`i'_eng 
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
	forval i = 1/10 {
	*-- Label variable
	label var leveledu_emig_`i' "Education level emigrant"
	*-- Label values
	label def leveledu_emig_`i'_eng 1 "None" ///		
        2 "Kindergarten" ///
		3 "Regimen anterior: Basica (1-9)" ///
		4 "Regimen anterior: Media (1-3)" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"
	label val leveledu_emig_`i' leveledu_emig_`i'_eng
	}
	

 *--------- Latest education grade atained by the emigrant 
 /* Education level (s10q7a): 7a. Cuál fue el último GRADO aprobado por X?     
 */	
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var gradedu_emig_`i' "Education grade emigrant"
	
	}
	

 *--------- Education regime 
 /* Education regime (s10q7ba): 7ba. El régimen de estudio era anual, semestral o
							   trimestral?
								01 Anual
								02 Semestral
								03 Trimestral     
 */	
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var regedu_emig_`i' "Education regime: annual, biannual or quarterly"
	*-- Label values
	label def regedu_emig_`i'_eng 1 "Annual" 2 "Biannual" 3 "Quarterly"
	label value regedu_emig_`i' regedu_emig_`i'_eng
	}
	
 *--------- Latest year 
 /* Education regime (s10q7b): 7b. Cuál fue el último AÑO aprobado por X?    
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var anoedu_emig_`i' "Last year of education attained"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (s10q7c): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var semedu_emig_`i' "Last semester of education attained"
	}

  *--------- Country of residence of the emigrant
 /* Country (s10q8): 8. En cuál país vive actualmente X?   
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var paisemig_`i' "Country in which X lives"
	}

  *--------- Other country of residence 
 /* Other Country (s10q8_os): 8a. Otro país, especifique
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var opaisemig_`i' "Country in which X lives (Other)"
	}

  *--------- City of residence 
 /* City (s10q8b): 8b. Y en cuál ciudad ?
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var ciuemig_`i' "City in which X lives"
	}

   *--------- Emigrated alone or not
 /* Alone (s10q8c): 8c. X emigró solo/a ?	
					01 Si
					02 No
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var soloemig_`i' "Has X emigrated alone"
	*-- Label values
	label def soloemig_`i'_eng 1 "Yes" 0 "No"
	label value soloemig_`i' soloemig_`i'_eng
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
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var conemig_`i' "Who emigrated with X"
	*-- Label values
	label def conemig_`i'_eng 1 "Father/Mother" 2 "Brother/sister" 3 "Partner" 4 "Son/daughter" 5 "Other relative" 6 "Non relative"
	label value conemig_`i' conemig_`i'_eng
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
						
						1 "Left looking for/got a job"
						2 "The location of the workplace changed"
						3 "Education/studies"
						4 "Family reunification"
						5 "Marriage/concubinage"
						6 "Health reasons"
						7 "Violence/insecurity"
						8 "Political reasons"
						9 "Other"
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var razonemig_`i' "Why X emigrated"
	*-- Label values
	label def razonemig_`i'_eng 1 "Left looking for/got a job" ///
						2 "The location of the workplace changed" ///
						3 "Education/studies" ///
						4 "Family reunification" ///
						5 "Marriage/concubinage" ///
						6 "Health reasons" ///
						7 "Violence/insecurity" ///
						8 "Political reasons" ///
						9 "Other"
	label val razonemig_`i' razonemig_`i'_eng
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
					
					 1 "Director or manager" 
					 2 "Scientific or intellectual professional" 
					 3 "Technician or mid-level professional" 
					 4 "Administrative support staff" 
                     5 "Service worker or seller of shops and markets" 
					 6 "Farmer or skilled agricultural, forestry or fishing worker" 
                     7 "Official, operator or craftsman of mechanical arts and other trades" 
					 8 "Operator of fixed installations and machines and machinery" ///
                     9 "Elementary occupations" 
					10 "Military occupations"
					11 "Without occupation"
 */    
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var ocupaemig_`i' "Which was X occupation before leaving"
	*-- Label values
	label def ocupaemig_`i'_eng 1 "Director or manager" ///
					 2 "Scientific or intellectual professional" ///
					 3 "Technician or mid-level professional" ///
					 4 "Administrative support staff" ///
                     5 "Service worker or seller of shops and markets" /// 
					 6 "Farmer or skilled agricultural, forestry or fishing worker" /// 
                     7 "Official, operator or craftsman of mechanical arts and other trades" ///
					 8 "Operator of fixed installations and machines and machinery" ///
                     9 "Elementary occupations" ///
					10 "Military occupations" ///
					11 "Without occupation"
	label val ocupaemig_`i'	ocupaemig_`i'_eng				
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
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var ocupnemig_`i' "Which is X occupation now"
	*-- Label values
	label def ocupnemig_`i'_eng 1 "Director or manager" ///
					 2 "Scientific or intellectual professional" ///
					 3 "Technician or mid-level professional" ///
					 4 "Administrative support staff" ///
                     5 "Service worker or seller of shops and markets" /// 
					 6 "Farmer or skilled agricultural, forestry or fishing worker" /// 
                     7 "Official, operator or craftsman of mechanical arts and other trades" ///
					 8 "Operator of fixed installations and machines and machinery" ///
                     9 "Elementary occupations" ///
					10 "Military occupations" ///
					11 "Without occupation"
	label val ocupnemig_`i' ocupnemig_`i'_eng
	} 

 
    *--------- The emigrant moved back to the country
 /*  Moved back (s10q12): 12. X regresó a residenciarse nuevamente al país?
							1 Si
							0 No
		
 */    
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var volvioemig_`i' "Does X moved back to the country?"
	*-- Label values
	label def volvioemig_`i'_eng 1 "Yes" 0 "No"
	label value volvioemig_`i' volvioemig_`i'_eng
	} 


     *--------- Year: The emigrant moved back to the country
 /*  Year (s10q13a): 13a. En qué año regresó X?
		
 */    
	forval i = 1/10{
	*-- Label variable
	label var volvioanoemig_`i' "Year: X moved back to the country?"
	} 

      *--------- Month: The emigrant moved back to the country
 /*  Month (s10q13b): 13b. En qué mes regresó X?
		
 */ 
 	forval i = 1/10{
	*-- Label variable
	label var volviomesemig_`i' "Month: X moved back to the country?"
	} 

 
      *--------- Member of the household
 /*  Member (s10q14):14. En el presente X forma parte de este hogar?
						1 Si
						0 No
	
 */   
 	forval i = 1/10{
	*-- Label variable
	label var miememig_`i' "Is X a member of the household?"
	*-- Label values
	label def miememig_`i'_eng 1 "Yes" 0 "No"
	label value miememig_`i' miememig_`i'_eng
	} 


/*(************************************************************************************************************************************************ 
*---------------------------------------- XV: SHOCKS AFFECTING HOUSEHOLDS / EVENTOS QUE AFECTAN A LOS HOGARES -------------------------------------
************************************************************************************************************************************************)*/


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
	
	*-- Label variable
	label var informant_shock "Informant: shocks affecting households"
	*-- Label values	
	label def informant_shock_eng  1 "Head of the household" 2 "Spouse/partner" 3 "Son/daughter/stepson/stepdaughter" ///
							  4 "Grandchild" 5 "Son/daugther/father/mother-in-law" 6 "Father/mother" 7 "Sibling" ///
							  8 "Brother/sister-in-law" 9 "Nephew/niece" 10 "Other relative" 11 "Other: non relative" ///
							  12 "House maid"
	label value informant_shock  informant_shock_eng


*--------- Events which affected the household
 /* Events(s15q1): 1. Cuáles de los siguientes eventos han afectado a
su hogar desde el año 2017 ?
         0 = No
         1 = Si
 */

	forval i = 1/21{
	*-- Label values 
	label def evento_`i'_eng 0 "No" 1 "Yes"
	label value evento_`i' evento_`i'_eng
	}
	
*-- Label variable
	*-- Label variable
	label var evento_1 "Since 2017, the household faced: dead or disability of an adult memeber which worked"
	label var evento_2 "Since 2017, the household faced: dead of a person which used to send remittances"
	label var evento_3 "Since 2017, the household faced: illness of the person with the most important household income"
	label var evento_4 "Since 2017, the household faced: loss of important contact"
	label var evento_5 "Since 2017, the household faced: the member with the most important household income lost his/her job"
	label var evento_6 "Since 2017, the household faced: Exit of family member which earned income due to divorce/separation"
	label var evento_7 "Since 2017, the household faced: Exit of family member which earned income due to marriage"
	label var evento_8 "Since 2017, the household faced: Emigration of a member of the household that earned income"
	label var evento_9 "Since 2017, the household faced: Non-agricultural business failure/closing of business or venture"
	label var evento_10 "Since 2017, the household faced: theft of crops, cash, livestock or other assets"
	label var evento_11 "Since 2017, the household faced: crop loss due to fire/drought/floods"
	label var evento_12 "Since 2017, the household faced: pest invasion that caused crop failure or loss of storage"
	label var evento_13 "Since 2017, the household faced: damaged/demolished home"
	label var evento_14 "Since 2017, the household faced: loss of property due to fire or flood"
	label var evento_15 "Since 2017, the household faced: loss of land"
	label var evento_16 "Since 2017, the household faced: dead of livestock due to disease"
	label var evento_17 "Since 2017, the household faced: higher cost of supplies"
	label var evento_18 "Since 2017, the household faced: lower prices of products"
	label var evento_19 "Since 2017, the household faced: higher prices of the main sources of food"
	label var evento_20 "Since 2017, the household faced: kidnapping/robbery/assault"
	label var evento_21 "Since 2017, the household faced: other"
	
	*-- Label variable
	label var evento_ot "Mention other shocks which affected your household"
	
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
	
	*-- Label variable
	label var imp_evento_1 "Importance: dead or disability of an adult memeber which worked"
	label var imp_evento_2 "Importance: dead of a person which used to send remittances"
	label var imp_evento_3 "Importance: illness of the person with the most important household income"
	label var imp_evento_4 "Importance: loss of important contact"
	label var imp_evento_5 "Importance: the member with the most important household income lost his/her job"
	label var imp_evento_6 "Importance: exit of family member which earned income due to divorce/separation"
	label var imp_evento_7 "Importance: exit of family member which earned income due to marriage"
	label var imp_evento_8 "Importance: emigration of a member of the household that earned income"
	label var imp_evento_9 "Importance: non-agricultural business failure/closing of business or venture"
	label var imp_evento_10 "Importance: theft of crops, cash, livestock or other assets"
	label var imp_evento_11 "Importance: crop loss due to fire/drought/floods"
	label var imp_evento_12 "Importance: pest invasion that caused crop failure or loss of storage"
	label var imp_evento_13 "Importance: damaged/demolished home"
	label var imp_evento_14 "Importance: loss of property due to fire or flood"
	label var imp_evento_15 "Importance: loss of land"
	label var imp_evento_16 "Importance: dead of livestock due to disease"
	label var imp_evento_17 "Importance: higher cost of supplies"
	label var imp_evento_18 "Importance: lower prices of products"
	label var imp_evento_19 "Importance: higher prices of the main sources of food"
	label var imp_evento_20 "Importance: kidnapping/robbery/assault"
	label var imp_evento_21 "Importance: other"

 *--------- How many times have the shock occurred since 2017
 /* (s15q2a)2a. Cuántas veces ocurrió %rostertitle% desde 2017?
 */

	forval i = 1/21 {
		*-- Label variable
		label var veces_evento_`i' "How many times have the shock occurred since 2017"
		}
		
	
 /*
 *--------- Year of the event
 (s15q2b) 2b. En qué año ocurrió ?
        
 */ 

	forval i = 1/21 {
	*-- Label variable
	label var ano_evento_`i' "Year of the event"
	}
	

 *--------- How the houselhold coped with the shock
 /* (s15q2c): 2c. Cómo se las arregló su hogar con el choque más reciente?*/
 
local x 1 2 3 4 5 6 8 9 10 12 13 14 15 16 17 18 19 20 21 22 23 24
	foreach i of local x {
		forval k = 1/21 {
	label var reaccion_evento_`i'_`k' "Response to event"
	*-- Label values
	label def reaccion_evento_`i'_`k'_eng 0 "Non code" 1 "Selling livestock" 2 "Selling land" 3 "Selling property" ///
	4 "Sending the children to live with friends" 5 "Stopped sending children to school" ///
	6 "Working in other income generating activities" ///
	8 "Received assiatnce from friends and relatives" 9 "Loans from friends and family" ///
	10 "Loans from financial institution" ///
	12 "Members of the household emigrated looking for a job" ///
	13 "Credit purchases" 14 "Delayed payment of obligations" ///
	15 "Sold the harvest in advance" 16 "Reduced the consumption of food" /// 
	17 "Reduced consumption of non-food item" 18 "Used savings" ///
	19 "Received assiatnce from a NGO" 20 "Advance payment from employer" ///
	21 "Received assiatence from the government" 22 "The insurance covered the costs" ///
	23 "Nothing" 24 "Other"
	label val reaccion_evento_`i'_`k' reaccion_evento_`i'_`k'_eng
		}
	}
	
 *--------- Other responses to the event
 /* (s15q2d): 2d. Otro arreglo, especifique */	
	forval i = 1/21 {
	*-- Label variable
	label var reaccionot_evento`i' "Other responses to the event"
	}
	
	
/*(************************************************************************************************************************************************ 
*---------------------------------------------------- INCOME VARIABLES / VARIABLES DE INGRESO ------------------------------------------------
************************************************************************************************************************************************)*/

* FALTAN AGREGAR MÁS

label	var	ijubi_m		"Monetary income for retirement benefits and pensions	"
label	var	icap_m		"Monetary income from capital	"
label	var	rem			"Income from remittances del exterior - monetary	"
label	var	itranp_o_m	"Income from other private transfers in the country - monetary	"
label	var	itranp_ns	"Income from non-specified private transfers	"
label	var	itrane_o_m	"Income from public transfers other than CCTs - monetary	"
label	var	itrane_ns	"Income from unspecified public transfers	"
label	var	inla_extraord	"Extraordinary non-labor income	"
label	var	iasalp_m	"Labor income from main occupation - monetary	"
label	var	iasalp_nm	"Labor income from main occupation - non-monetary	"
label	var	ictapp_m	"Self-employed income from main occupation - monetary	"
label	var	ictapp_nm	"Self-employed income from main occupation - non-monetary	"
label	var	ipatrp_m	"Employer income from main occupation - monetary	"
label	var	ipatrp_nm	"Employer income from main occupation - non-monetary	"
label	var	iolp_m		"Other labor income from main occupation - monetary	"
label	var	iolp_nm		"Other labor income from main occupation - non monetary	"
label	var	iasalnp_m	"Labor income from secondary occupation - monetary	"
label	var	iasalnp_nm	"Labor income from secondary occupation - non-monetary	"
label	var	ictapnp_m	"Self-employed income from secondary occupation - monetary	"
label	var	ictapnp_nm	"Self-employed income from secondary occupation - non-monetary	"
label	var	ipatrnp_m	"Employer income from secondary occupation - monetary	"
label	var	ipatrnp_nm	"Employer income from secondary occupation - non monetary	"
label	var	iolnp_m		"Other labor income from secondary occupation - monetary	"
label	var	iolnp_nm	"Other labor income from secondary occupation - non-monetary	"
label	var	ijubi_nm	"Non monetary income for retirement benefits and pensions 	"
label	var	icap_nm		"Non-monetary income from capital	"
label	var	cct			"Income from conditional cash transfer programs	"
label	var	itrane_o_nm	"Income from public transfers other than CCTs - non monetary	"
label	var	itranp_o_nm	"Income from other private transfers in the country - non monetary	"
label	var	ipatrp		"Employer income from main occupation - total	"
label	var	iasalp		"Salaried worker income from main occupation - total	"
label	var	ictapp		"Self-employed income from main occupation - total	"
label	var	iolp		"Other labor income from main occupation - total	"
label	var	ip			"Income in main occupation	"
label	var	ip_m		"Income from main occupation - monetary	"
label	var	wage		"Hourly wage in main occupation	"
label	var	wage_m	"Hourly income from main occupation - monetary	"
label	var	ipatrnp	"Employer income from secondary occupation - total	"
label	var	iasalnp	"Salaried worker income from secondary occupation - total	"
label	var	ictapnp	"Self-employed income from secondary occupation - total	"
label	var	iolnp	"Other labor income from main occupation - total	"
label	var	inp		"Labor income from secondary occupation	"
label	var	ipatr	"Employer income	"
label	var	ipatr_m	"Employer income - monetary	"
label	var	iasal	"Salaried worker income in main occupation	"
label	var	iasal_m	"Salaried worker income in main occupation: Monetary	"
label	var	ictap	"Self-employed labor income	"
label	var	ictap_m	"Self-employed labor income - monetary	"
label	var	ila		"Total labor income	"
label	var	ila_m	"Labor income - monetary	"
label	var	ilaho	"Hourly income in all occupations	"
label	var	ilaho_m	"Hourly income in all occupations - monetary	"
label	var	perila	"Dummy for labor income earner: =1 if labor income earner	"
label	var	ijubi	"Income from retirement benefits and pensions	"
label	var	icap	"Income from capital	"
label	var	itranp	"Income from private transfers	"
label	var	itranp_m	"Income from private transfers - monetary	"
label	var	itrane	"Income from public transfers	"
label	var	itrane_m	"Income from public transfers - monetary	"
label	var	itran	"Income from transfers	"
label	var	itran_m	"Income from transfers - monetary	"
label	var	inla	"Total non-labor income	"
label	var	inla_m	"Total non-labor income - monetary	"
label	var	ii		"Total individual income	"
label	var	ii_m	"Total individual income - monetary	"
label	var	perii	"Income earner	"
label	var	n_perila_h	"Number of labor income earners in household	"
label	var	n_perii_h	"Number of labor income earners in household	"
label	var	ilf_m	"Total household labor income - monetary	"
label	var	ilf		"Total household labor income	"
label	var	inlaf_m	"Total household non-labor income - monetary	"
label	var	inlaf	"Total household non-labor income	"
label	var	itf_m	"Total household income - monetary	"
label	var	itf_sin_ri	"Total household income without imputed rent	"
label	var	renta_imp	"Imputed income for home owners	"
label	var	itf		"Household total income"
label	var	cohi	"Indicators for income answers: =1 if answer is coherent (individual)	"
label	var	cohh	"Indicators for income answers: =1 if answer is coherent (household)	"
label	var	coh_oficial	"Indicators for income answers: =1 if answer is coherent (household) – for official estimate	"
label	var	ilpc_m	"Per capita labor income - monetary"
label	var	ilpc	"Per capita labor income"
label	var	inlpc_m	"Per capita non-labor income - monetary"
label	var	inlpc	"Per capita non-labor income "
label	var	ipcf_sr	"Per capita household income without implicit rent"
label	var	ipcf_m	"Per capita household income - monetary	"
label	var	ipcf	"Per capita household income"
label	var	iea		"Equivalized income A"
label	var	ilea_m	"Equivalized labor income - monetary"
label	var	ieb		"Equivalized income B"
label	var	iec		"Equivalized income C"
label	var	ied		"Equivalized income D"
label	var	iee		"Equivalized income E"
cap label var    ilea_m          "Equivalized labor income - monetary" 
cap label var    lp_extrema	     "Official extreme poverty line"
cap label var    lp_moderada     "Official moderate poverty line"
cap label var    ing_pob_ext     "Income used to estimate official extreme poverty"
cap label var    ing_pob_mod     "Income used to estimate official moderate poverty"
cap label var    ing_pob_mod_lp  "Official income / Poverty Line"
cap label var    p_reg	         "Adjustment factor for regional prices"
cap label var    ipc	         "CPI base month" 
cap label var    pipcf	         "Percentiles household per capita income"
cap label var    dipcf	         "Income deciles per capita household income"
cap label var    p_ing_ofi	     "Income percentiles to estimate official poverty"
cap label var    d_ing_ofi	     "Income deciles to estimate official poverty"
cap label var    piea	     	 "Percentiles equivalized income A"
cap label var    qiea	         "Quintiles equivalized income A"
cap label var    pondera_i	     "Weight for income variables"  
cap label var    ipc05	         "Average Consumer Price Index for 2005"
cap label var    ipc11	     	 "Average Consumer Price Index for 2011"
cap label var    ppp05	   	 	 "PPP conversion factor (2005)"
cap label var    ppp11	         "PPP conversion factor (2011)"
cap label var    ipcf_cpi05	     "Per capita household income (2005 values)"
cap label var    ipcf_cpi11	     "Per capita household income (2011 values)"
cap label var    ipcf_ppp05	     "Per capita household income (2005 dollars)"
cap label var    ipcf_ppp11	     "Per capita household income (2011 dollars)"
