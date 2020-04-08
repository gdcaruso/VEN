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

* JULI LO HIZO - PERO NO CORRE
	
/*(************************************************************************************************************************************************* 
*------------------------------------------------------ VII. EDUCATION / EDUCACIÓN -----------------------------------------------------------
*************************************************************************************************************************************************)*/

*JULI LO EMPEZÓ - TERMINAR


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
label def	razon_menoshs 	1 "Work part time" 2 "Labor conflict (strike, protest, unemployment)" 3 "Illness, leave, vacation"
							4 "Lack of work" 5 "Shortage of materials or equipment under repair" 6 "Other (Specify"
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
label def	aporta_pension	1 "Yes" 0 "No"
label values aporta_pension aporta_pension

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

