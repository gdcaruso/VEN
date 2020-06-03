/// SPANISH LABELS ///


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
label var	pondera         "Factor de ponderacion individual (expande a personas)"
label var 	pondera_hh		"Factor de ponderacion de hogares (expande a hogares)"
*label var	strata          "Variable de estratificacion"   
label var   psu	     	 	"Unidad Primaria de Muestreo"
cap label var 	quest 			"Cuestionario (para uso admin ENCOVI)"
label def 	entidad		1 "Distrito Capital" 2 "Amazonas" 3 "Anzoategui" 4 "Apure" ///
						5 "Aragua" 6 "Barinas" 7 "Bolivar" 8 "Carabobo" 9 "Cojedes" ///
						10 "Delta Amacuro" 11 "Falcon" 12 "Guarico" 13 "Lara" 14 "Merida" ///
						15 "Miranda" 16 "Monagas" 17 "Nueva Esparta" 18 "Portuguesa" ///
						19 "Sucre" 20 "Tachira" 21 "Trujillo" 22 "Yaracuy" 23 "Zulia" 24 "Vargas"
label value entidad entidad

label var region_est1 "Region"
label def region_est1 1 "Central"  2 "Llanera" 3 "Occidental" 4 "Zuliana" ///
          5 "Andina" 6 "Nor-Oriental" 7 "Capital"
label value region_est1 region_est1

** Demographic variables  / Variables demográficas

label def 	relacion_en 	1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)" 4 "Hijastro(a)" ///
							5 "Nieto(a)" 6 "Yerno, nuera, suegro (a)" 7 "Padre, madre" 8 "Hermano(a)" ///
							9 "Cunado(a)" 10 "Sobrino(a)" 11 "Otro pariente" 12 "No pariente" 13 "Servicio Domestico"
label values relacion_en relacion_en					
			
label def 	relacion_comp 	1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" 4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)" ///
							6 "Padre, madre" 7 "Hermano(a)" 8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" 12 "Servicio Domestico"
label values relacion_comp relacion_comp
			
label var    gedad1          "Grupos de edad: 2=[15,24], 3=[25,40], 4=[41,64]"
label define gedad1 1 "[0,14]" 2 "[15,24]" 3 "[25,40]" 4 "[41,64]" 5 "[65+]"
label values gedad1 gedad1

label var    grupo_edad          "Grupos de edad: 10 en 10"
label def grupo_edad 1 "[0-9]" 2 "[10-19]" 3 "[20-29]" 4 "[30-39]" 5 "[40-49]" 6 "[50-59]" 7 "[60-69]" 8 "[70-79]" 7 "[80+]"
label value grupo_edad grupo_edad

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


/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Type of flooring material
/* MATERIAL_PISO (s4q1) */
	*-- Label variable
	label var material_piso " 1. El material predominante del piso"
	 *-- Label values
		label def material_piso 1 "Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares" ///
		 2 "Cemento" /// 
		 3 "Tierra" ///	
		 4 "Tablas"
		label value material_piso material_piso

*** Type of exterior wall material		 
/* MATERIAL_PARED_EXTERIOR (s4q2) */
	*-- Label variable
	label var material_pared_exterior "2. El material predominante de las paredes exteriores es:"
	*-- Label values
	label def material_pared_exterior 1 "Bloque, ladrillo frisado" 2 "Bloque ladrillo sin frisar" /// 
		 3 "Concreto" 4 "Madera aserrada" 5 "Bloque de plocloruro de vinilo" ///
		 6 "Adobe, tapia o bahareque frisado" 7 "Adobe, tapia o bahareque sin frisado" ///
		 8 "Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)"  
	label value material_pared_exterior material_pared_exterior


*** Type of roofing material
/* MATERIAL_TECHO (s4q3) */
	*-- Label variable
	label var material_techo "3. El material predominante del techo es"
	*-- Label values
	label def material_techo_en 1 "Platabanda (concreto o tablones)" ///	
		 2 "Tejas o similar" ///
		 3 "Lamina asfaltica" ///	
		 4 "Laminas metalicas (zinc, aluminio y similares)" ///   
		 5 "Materiales de desecho (tablon, tablas o similares, palma)"
	label val material_techo material_techo_en
	
*** Type of dwelling
* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
	*-- Label variable
	label var tipo_vivienda "Tipo de vivienda"
	*-- Label values
	label def tipo_vivienda_en 1 "Casa Quinta" ///
		2 "Casa" 3 "Apartamento en edificio" ///
		4 "Anexo en casaquinta" 5 "Vivienda rustica (rancho)" ///
		6 " Habitacion en vivienda o local de trabajo" ///
		7 "Rancho campesino"
	label val tipo_vivienda tipo_vivienda_en
	
*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda? */	
		*-- Label variable
		label var suministro_agua "5. Últimos 3 meses:principales fuentes de suministro de agua en esta vivienda:"

		*-- Label values
		label def suministro_agua 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Pozo con bomba" 5 "Pozo protegido" 6 "Otros medios"
		label value suministro_agua suministro_agua

		* Comparable across all years
		*-- Label variable
		label var suministro_agua_comp "5. Últimos 3 meses:principales fuentes de suministro de agua en esta vivienda:"
		*-- Label values
		label def suministro_agua_comp 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Otros medios"
		label value suministro_agua_comp suministro_agua_comp

*** Frequency of water supply
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda? */
		*-- Label variable
		label var frecuencia_agua "6. Últimos 3 meses: frecuencia suministro agua por acueducto (tubería de calle)"
		*-- Label values
		label def frecuencia_agua 1 "Todos los dias" ///
		2 "Algunos dias de la semana" ///
		3 "Una vez por semana" ///
		4 "Una vez cada 15 dias" ///
		5 "Nunca" 
		label val frecuencia_agua frecuencia_agua


*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por? */

		*-- Label variable
		label var serv_elect_red_pub "Ultimos 3 meses, el servicio electrico ha sido suministrado por? La red publica"
		*-- Label variable
		label var serv_elect_planta_priv "Ultimos 3 meses, el servicio electrico ha sido suministrado por? Planta electrica privada"
		*-- Label variable
		label var serv_elect_otro "Ultimos 3 meses, el servicio electrico ha sido suministrado por? Otra forma"
		
		label var 	electricidad 	"Tiene conexión a electricidad?"	
		*-- Label variable
		label def sino 1 "Si" 0 "No"
		label val serv_elect_red_pub sino
		label val serv_elect_planta_priv sino
		label val serv_elect_otro sino
		label val electricidad sino

*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe */
		*-- Label variable
		label var interrumpe_elect "En esta vivienda el servicio electrico se interrumpe"
		*-- Label values
		label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
		label value interrumpe_elect interrumpe_elect
		tab interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene */
		*-- Label variable
		label var tipo_sanitario_comp "Esta vivienda tiene el siguiente tipo de sanitario..."
		*-- Label values
		label def tipo_sanitario_en 1 "Poceta a cloaca/Pozo septico" ///
		2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" ///
		4 "No tiene poseta o excusado"
		label value tipo_sanitario_comp tipo_sanitario_comp_en

*** Number of rooms used exclusively to sleep
/* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
	VAR: ndormi= s5q1  //up to 9 */
		*-- Label variable
		label var ndormi "Cantidad de cuartos utilizados exclusivamente para dormir por las personas del hogar"
		
*** Bath with shower 
/* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera? */
		*-- Label variable
		label var banio_con_ducha "Baño con ducha"
		*-- Label values
		label def banio_con_ducha_en 1 "Yes" 0 "No"
		label val banio_con_ducha banio_con_ducha_en
		
*** Number of bathrooms with shower
/* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 */
		*-- Label variable
		label var nbanios "Cantidad de baños con ducha"
		
*** Housing tenure
/* TENENCIA_VIVIENDA (s5q7): régimen de  de la vivienda  */

*-- Label variable
label var tenencia_vivienda "Régimen de vivienda (esta encuesta)"
*-- Label values
label def tenencia_vivienda_en 1 "Propia pagada" 2 "Propia pagandose" ///
		3 "Alquilada" 4 "Alquilada parte de la vivienda" ///
		5 "Adjudicada pagandose Gran Mision Vivienda" /// 
		6 "Adjudicada Gran Mision Vivienda" ///
		7 "Cedida por razones de trabajo" ///
		8 "Prestada por familiar o amigo" ///
		9 "Tomada" ///
		10 "Otra"
label val tenencia_vivienda tenencia_vivienda_en

*-- Label variable
label var tenencia_vivienda_comp "Régimen de vivienda (armonizada)"


foreach i in agua elect gas carbon parafina telefono {
	label var p`i'_monto 	"s5q17a. Monto"
	label var p`i'_mon 		"s5q17b. Moneda"
	label def	p`i'_mon	1 "Bolivares" 2 "Dólares" 3 "Euros" 4 "Pesos Colombianos"
	label values p`i'_mon p`i'_mon
	label var p`i'_m		"s5q17c. Mes"
	label def	p`i'_m	1 "Enero" 2 "Febrero" 3 "Marzo" 4 "Abril" 5 "Mayo" 6 "Junio" 7 "Julio" 8 "Agosto" 9 "Septiembre" 10 "Octubre" 11 "Noviembre" 12 "Diciembre"
	label values p`i'_m p`i'_m
	
	}

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/

	foreach i in auto heladera lavarropas computadora internet televisor ///
	radio calentador aire tv_cable microondas telefono_fijo {
	cap label def sino 0 "No" 1 "Si" 
	label val `i' sino
	}
	




** Education

		*** Is the "member" answering by himself/herself?
				*-- Label variable
				label var contesta_ind_e "Esta contestando por si mismo?"
				*-- Label values
				label def contesta_ind_e 1 "Si" 0 "No"
				label val contesta_ind_e contesta_ind_e
				
		*** Who is answering instead of "member"?
				*-- Label variable
				label var quien_contesta_e "Quien esta contestando por X?"
				*-- Label values
				label def quien_contesta_e 1 "Jefe del Hogar" ///
				2 "Esposa(o) o Compañera(o)" ///
				3 "Hijo(a)" ///		
				4 "Hijastro(a)" ///
				5 "Nieto(a)" ///	
				6 "Yerno, nuera, suegro (a)" ///
				7 "Padre, madre" ///       
				8 "Hermano(a)" ///
				9 "Cunado(a)" ///         
				10 "Sobrino(a)" ///
				11 "Otro pariente" ///      
				12 "No pariente" ///
				13 "Servicio Domestico" 
				label val quien_contesta_e quien_contesta_e

		*** Have you ever attended any educational center? //for age +3
				*-- Label variable
				label var asistio_educ "¿Alguna vez asistió a algún centro educativo como estudiante? (mayores de 3 anos)"
				*-- Label values
				label def asistio_educ 1 "Si" 0 "No"
				label val asistio_educ asistio_educ

		*** During the period 2019-2020 did you attend any educational center? //for age +3
				*-- Label variable
				label var asiste "Entre 2019 y 2020: asistió a algún centro educativo como estudiante?(mayores de 3 anos)"
				*-- Label values
				label def asiste 1 "Si" 0 "No"
				label val asiste asiste

		*** Which is the educational level you are currently attending?
		/* NIVEL_EDUC_ACT (s7q4): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  	
		*/
				*-- Label variable
				label var nivel_educ_act "¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?"
				*-- Label values
				label def nivel_educ_act 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
				label value nivel_educ_act nivel_educ_act

		*** Which grade are you currently attending
		/* G_EDUC_ACT (s7q4a): ¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)
				Primaria: 1-6to
				Media: 1-6to
		*/
				*-- Label variable
				label var g_educ_act "¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)"

		*** Regimen de estudios
		* REGIMEN_ACT (s7q4b): El regimen de estudios es anual, semestral o trimestral?
				*-- Label variable
				label var regimen_act "El regimen de estudios es anual, semestral o trimestral?"
				*-- Label values
				label def regimen_act 1 "Anual" 2 "Semestral" 3 "Trimestral"
				label value regimen_act regimen_act

		*** Which year are you currently attending	?	
		/* A_EDUC_ACT (s7q4c): ¿Cuál es el ano al que asiste? (variable definida para nivel educativo Primaria y Media)
				Tecnico: 1-3
				Universitario: 1-7
				Postgrado: 1-6
		*/
				*-- Label variable
				label var a_educ_act "¿Cuál es el ano al que asiste?"

		*** Which semester are you currently attending?
		/* S_EDUC_ACT (s7q4d): ¿Cuál es el semestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
				Tecnico: 1-6 semestres
				Universitario: 1-14 semestres
				Postgrado: 1-12 semestres
		*/

				*-- Label variable
				label var s_educ_act "¿Cuál es el semestre al que asiste?"

		*** Which quarter are you currently attending?
		/* T_EDUC_ACT (s7q4e): ¿Cuál esel trimestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
				Tecnico: 1-9 semestres
				Universitario: 1-21 semestres
				Postgrado: 1-18
		*/
				*-- Label variable
				label var t_educ_act "¿Cuál es el trimestre al que asiste?"

		*** Type of educational center
		/* TIPO_CENTRO_EDUC (s7q5): ¿el centro de educacion donde estudia es:
				1 = Privado
				2 = Publico
		*/
				*-- Label variable
				*label var tipo_centro_educ "¿El centro de educacion donde estudia es:"
				*-- Label values
				*label def tipo_centro_educ 1 "Privado" 2 "Publico"
				*label value tipo_centro_educ tipo_centro_educ
				
				*-- Label variable
				label var edu_pub "¿el centro de educacion donde estudia es publico"
				*-- Label values
				label def edu_pub 0 "Privado" 1 "Publico"
				label value edu_pub edu_pub
			
		*** During this school period, did you stop attending the educational center where you regularly study due to:
		* Water failures
				*-- Label variable
				label var fallas_agua "Alguna vez deja de asistir a clases por: Fallas de agua"
				*-- Label values
				label def fallas_agua 0 "No" 1 "Si"
				label value fallas_agua fallas_agua

		* Electricity failures
				*-- Label variable
				label var fallas_elect "Alguna vez deja de asistir a clases por: Fallas de electricidad"
				*-- Label values
				label def fallas_elect 0 "No" 1 "Si"
				label value fallas_elect fallas_elect

		* Huelga de personal docente
				*-- Label variable
				label var huelga_docente "Alguna vez deja de asistir a clases por: Huelga docente"
				*-- Label values
				label def huelga_docente 0 "No" 1 "Si"
				label value huelga_docente huelga_docente

		* Falta transporte
				*-- Label variable
				label var falta_transporte "Alguna vez deja de asistir a clases por: Falta de trasnporte"
				*-- Label values
				label def falta_transporte 0 "No" 1 "Si"
				label value falta_transporte falta_transporte

		* Falta de comida en el hogar
				*-- Label variable
				label var falta_comida_hogar "Alguna vez deja de asistir a clases por: Falta de comida en el hogar"
				*-- Label values
				label def falta_comida_hogar 0 "No" 1 "Si"
				label value falta_comida_hogar falta_comida_hogar

		* Falta de comida en el centro educativo
				*-- Label variable
				label var falta_comida_centro "Alguna vez deja de asistir a clases por: Falta de comida en el centro educativo"
				*-- Label values
				label def falta_comida_centro 0 "No" 1 "Si"
				label value falta_comida_centro falta_comida_centro

		* Inasistencia del personal docente
				*-- Label variable
				label var inasis_docente "Alguna vez deja de asistir a clases por: Inasistencia de los docentes"
				*-- Label values
				label def inasis_docente 0 "No" 1 "Si"
				label value inasis_docente inasis_docente

		* Manifestaciones, movilizaciones o protestas
				*-- Label variable
				label var protestas "Alguna vez deja de asistir a clases por: Manifestaciones, movilizaciones o protestas"
				*-- Label values
				label def protestas 0 "No" 1 "Si"
				label value protestas protestas

		* Nunca deje de asistir
				*-- Label variable
				label var nunca_deja_asistir "Alguna vez deja de asistir a clases por: nunca deja de asistir"
				*-- Label values
				label def nunca_deja_asistir 0 "No" 1 "Si"
				label value nunca_deja_asistir nunca_deja_asistir

		*** El centro educativo al que asiste cuenta con el programa de alimentacion escolar PAE?
				*-- Label variable
				label var pae "El centro educativo al que asiste cuenta con el programa de alimentacion escolar PAE?"
				*-- Label values
				label def pae 0 "No" 1 "Si"
				label value pae pae
				
		*** En el centro educativo al que asiste, el programa PAE funciona:
				*-- Label variable
				label var pae_frecuencia "En el centro educativo al que asiste, el programa PAE funciona:"
				*-- Label values
				label def pae_frecuencia 1 "Todos los días" ///
				2 "Solo algunos días" ///
				3 "Casi nunca"
				label value pae_frecuencia pae_frecuencia

		*** En el centro educativo al que asiste, el programa pae ofrece:
		* Desayuno
				*-- Label variable
				label var pae_desayuno "En el centro educativo PAE ofrece: desayuno"
				*-- Label values
				label def pae_desayuno 1 "Si" 0 "No"
				label value pae_desayuno pae_desayuno

		* Almuerzo
				*-- Label variable
				label var pae_almuerzo "En el centro educativo PAE ofrece: almuerzo"
				*-- Label values
				label def pae_almuerzo 1 "Si" 0 "No"
				label value pae_almuerzo pae_almuerzo

		* Merienda en la manana
				*-- Label variable
				label var pae_meriman "En el centro educativo PAE ofrece: merienda a la manana"
				*-- Label values
				label def pae_meriman 1 "Si" 0 "No"
				label value pae_meriman pae_meriman

		* Merienda en la tarde
				*-- Label variable
				label var pae_meritard "En el centro educativo PAE ofrece: merienda a la tarde"
				*-- Label values
				label def pae_meritard 1 "Si" 0 "No"
				label value pae_meritard pae_meritard

		* Otra
				*-- Label variable
				label var pae_otra "En el centro educativo PAE ofrece: otra"
				*-- Label values
				label def pae_otra 1 "Si" 0 "No"
				label value pae_otra pae_otra

		*** Durante el periodo escolar 2019-2020 gasto, consiguio, recibio donancion en alguno de los siguientes conceptos?
		* Cuota de inscripción
				*-- Label variable
				label var cuota_insc "Durante 2019-2020 gasto, consiguio, recibio donancion: cuota de inscripcion"
				*-- Label values
				label def cuota_insc 1 "Si" 0 "No"
				label value cuota_insc cuota_insc

		* Compra de útiles y libros escolares
				*-- Label variable
				label var compra_utiles "Durante 2019-2020 gasto, consiguio, recibio donancion: útiles y libros escolares"
				*-- Label values
				label def compra_utiles 1 "Si" 0 "No"
				label value compra_utiles compra_utiles

		* Compra de uniformes y calzados escolares
				*-- Label variable
				label var compra_uniforme "Durante 2019-2020 gasto, consiguio, recibio donancion: uniformes y calzados escolares"
				*-- Label values
				label def compra_uniforme 1 "Si" 0 "No"
				label value compra_uniforme compra_uniforme

		* Costo de la mensualidad
				*-- Label variable
				label var costo_men "Durante 2019-2020 gasto, consiguio, recibio donancion: costo de la mensualidad"
				*-- Label values
				label def costo_men 1 "Si" 0 "No"
				label value costo_men costo_men

		* Uso de transporte público o escolar
				*-- Label variable
				label var costo_transp "Durante 2019-2020 gasto, consiguio, recibio donancion: costo transporte público o escolar"
				*-- Label values
				label def costo_transp 1 "Si" 0 "No"
				label value costo_transp costo_transp

		* Otros gastos
				*-- Label variable
				label var otros_gastos "Durante 2019-2020 gasto, consiguio, recibio donancion: otros gastos"
				*-- Label values
				label def otros_gastos 1 "Si" 0 "No"
				label value otros_gastos otros_gastos

		*** Monto pagado
		* Cuota de inscripción
				*-- Label variable
				label var cuota_insc_monto "Monto pagado: cuota de inscripción"

		* Compra de útiles y libros escolares
				*-- Label variable
				label var compra_utiles_monto "Monto pagado: compra de útiles y libros escolares"

		* Compra de uniformes y calzados escolares
				*-- Label variable
				label var compra_uniforme_monto "Monto pagado: compra de uniformes y calzados escolares"

		* Costo de la mensualidad
				*-- Label variable
				label var costo_men_monto "Monto pagado: costo de la mensualidad"

		* Uso de transporte público o escolar
				*-- Label variable
				label var costo_transp_monto "Monto pagado: uso de transporte público o escolar"

		* Otros gastos
				*-- Label variable
				label var otros_gastos_monto "Monto pagado: otros gastos"


		*** Moneda en que se realizo el pago
			* Cuota de inscripción
			*-- Label variable
				label var cuota_insc_mon "Moneda: cuota de inscripcion"
			* Compra de útiles y libros escolares
				*-- Label variable
				label var compra_utiles_mon "Moneda: compra de útiles y libros escolares"
			* Compra de uniformes y calzados escolares
				*-- Label variable
				label var compra_uniforme_mon "Moneda: compra de uniformes y calzados escolares"
			* Costo de la mensualidad
				*-- Label variable
				label var costo_men_mon "Moneda: costo de la mensualidad"
			* Uso de transporte público o escolar
				*-- Label variable
				label var costo_transp_mon "Moneda: uso de transporte público o escolar"
			* Otros gastos
				*-- Label variable
				label var otros_gastos_mon "Moneda: otros gastos"

		*** Mes en que se realizo el pago
			* Cuota de inscripción
				*-- Label variable
					label var cuota_insc_m "Mes del pago: cuota de inscripcion"
			* Compra de útiles y libros escolares
				*-- Label variable
					label var compra_utiles_m "Mes del pago: compra de útiles y libros escolares"
			* Compra de uniformes y calzados escolares
				*-- Label variable
				label var compra_uniforme_m "Mes del pago: compra de uniformes y calzados escolares"
			* Costo de la mensualidad
				*-- Label variable
				label var costo_men_m "Mes del pago: costo de la mensualidad"
			* Uso de transporte público o escolar
				*-- Label variable
				label var costo_transp_m "Mes del pago: uso de transporte público o escolar"
			* Otros gastos
				*-- Label variable
				label var otros_gastos_m "Mes del pago: otros gastos"

		*** Educational attainment
		/* NIVEL_EDUC_EN (s7q11): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?   */
			*-- Label variable
			label var nivel_educ_en  "Último grado, año, semestre o trimestre y de cuál nivel educativo aprobado (encuesta)"
			label def nivel_educ_en	1 "Ninguno" 2 "Preescolar" 3 "Regimen anterior: Basica (1-9)" ///  
				4 "Regimen anterior: Media (1-3)" 5 "Regimen actual: Primaria (1-6)" ///	
				6 "Regimen actual: Media (1-6)" 7 "Tecnico (TSU)" ///	
				8 "Universitario" 		9 "Postgrado"
			label value nivel_educ_en nivel_educ_en
			
		/* NIVEL_EDUC: Comparable across years */
			*-- Label variable
			label var nivel_educ  "Último grado, año, semestre o trimestre y de cuál nivel educativo aprobado (armonizada)"
			label def nivel_educ	1 "Ninguno" 2 "Preescolar" 3 "Primaria"	///
				4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
			label value nivel_educ nivel_educ

		*** Which was the last grade you completed?
		/* G_EDUC (s7q11a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
				Primaria: 1-6to
				Media: 1-6to
		*/
			*-- Label variable
			label var g_educ "Ultimo grado que aprobo"
			
		*** Cual era el regimen de estudios
		* REGIMEN (s7q11ba): El regimen de estudios era anual, semestral o trimestral?

		*** Which was the last year you completed?
		/** A_EDUC (s7q4b): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
				Tecnico: 1-3
				Universitario: 1-7
				Postgrado: 1-6
		*/
			*-- Label variable
			label var a_educ "Ultimo año que aprobo"

		*** Which was the last semester you completed?
		/* S_EDUC (emhp27c): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
				Tecnico: 1-6 semestres
				Universitario: 1-14 semestres
				Postgrado: 1-12 semestres
		*/
			*-- Label variable
			label var s_educ "Ultimo semestre que aprobo"

		*** Which was the last quarter you completed?
		/* T_EDUC (emhp27d): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
				Tecnico: 1-9 semestres
				Universitario: 1-21 semestres
				Postgrado: 1-18
		*/
			*-- Label variable
			label var t_educ "Ultimo trimestre que aprobo"

		***  Literacy
		*Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
			*-- Label variable
			label var alfabeto "Alfabetizado: ha recibido al menos dos años de educacion formal"

		/*
		*** Obtuvo el titulo respectivo //missing in database
		gen titulo = s7q11e==1 if s7q1==1 & (s7q11>=7 & s7q11<=9) 
		*/

		*** A que edad termini/dejo los estudios
			*-- Label variable
			label var edad_dejo_estudios "A que edad termino/dejo los estudios"




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

label var    pea            "Dummy de condicion de actividad: economicamente activo"
label define pea 			0 "Inactivo" 1 "Activo"
label values pea pea

label var    ocupado         "Dummy de condicion de actividad: ocupado"
label define ocupado 		0 "No ocupado" 1 "Ocupado"
label values ocupado ocupado

label var    desocupa        "Dummy de condicion de actividad: desocupado"
label define desocupa 		0 "No desocupado" 1 "Desocupado"
label values desocupa desocupa 


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
foreach i of varlist dili_agencia dili_aviso dili_planilla dili_credito dili_tramite dili_compra dili_contacto /*dili_otro*/ {
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
	label values `i'_mone `i'_mone
	}
label var 	im_petro		"Con respecto al mes pasado recibio ingresos por Petros?"

foreach i of varlist inm_comida inm_productos inm_transporte inm_vehiculo inm_estaciona inm_telefono inm_servicios inm_guarderia inm_otro  {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  `i'_cant		" Monto recibido (si no percibe el beneficio en dinero, estime cuánto tendría que haber pagado por esto)" 
	label var  	`i'_mone	"Moneda" 
	label def	`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
	label values `i'_mone `i'_mone
	}
foreach i of varlist d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro  {
	label def	`i'			1 "Yes" 0 "No"
	label values `i' `i'
	label var  `i'_cant		"Monto descontado" 
	label var  	`i'_mone	"Moneda" 
	label def	`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
	label values `i'_mone `i'_mone
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

label var inla_petro "Recibió el mes pasado ingresos por Petro?"

label var    relab            "Relación laboral en la ocupación principal"
label define relab 1 "Empleador" 2 "Asalariado" 3 "Cuentapropista" 4 "Sin Salario" 5 "Desocupado"
label values relab relab

** Otros ingresos y pensiones

	*s9q28
	foreach i in pens_soi pens_vss jubi_emp pens_dsa beca_pub beca_pri ayuda_pu ayuda_pr ayuda_fa asig_men otros {
		label var  inla_`i'_cant	"s9q28a. Monto" 
		label var  	inla_`i'_mone	"s9q28b. Moneda" 
		label def	inla_`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
		label values inla_`i'_mone inla_`i'_mone
	}
	
	*s9q29
	foreach i in sueldo ingnet indemn remesa penjub intdiv becaes extrao alquil {
		label var  iext_`i'_cant	"s9q29a. Monto" 
		label var  	iext_`i'_mone	"s9q29b. Moneda" 
		label def	iext_`i'_mone	1 "Bolívares" 2 "Dólares USD" 3 "Euros" 4 "Pesos colombianos"
		label values iext_`i'_mone iext_`i'_mone
	}
	
	label def categ_ocu 	1 "Empleado u obrero en el sector publico" 3 "Empleado u obrero en empresa privada"	5 "Patrono o empleador" 6 "Trabajador por cuenta propia" ///
							7 "Miembro de cooperativas" 8 "Ayudante familiar remunerado/no remunerado" 9 "Servicio domestico"
	label values categ_ocu categ_ocu

	
** Emigración

label define relemig_label 2 "Esposo(a)" 3 "Hijo(a)" 4 "Hijastro(a)" 5 "Nieto(a)" 6 "Yerno, nuera, suegro(a)" 7 "Padre, Madre" 8 "Hermano(a)" 9 "Cuñado(a)" 10 "Sobrino(a)" 11 "Otro pariente" 12 "No pariente"

forvalues x = 1/10 {
label values relemig_`x' relemig_label
} 


** Shocks

	*Cuáles de los siguientes eventos han afectado a su hogar desde el año 2017?
	* s15q15__* or evento_*
	label var evento_1 "Desde 2017, el hogar se vio afectado por: 1.Muerte o discapacidad de un miembro adulto del hogar que trabajaba"
	label var evento_2 "Desde 2017, el hogar se vio afectado por: 2.Muerte de alguien que enviaba remesas al hogar"
	label var evento_3 "Desde 2017, el hogar se vio afectado por: 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var evento_4 "Desde 2017, el hogar se vio afectado por: 4.Pérdida de un contacto importante"
	label var evento_5 "Desde 2017, el hogar se vio afectado por: 5.Perdida de trabajo de la persona con el ingreso más importante del hogar"
	label var evento_6 "Desde 2017, el hogar se vio afectado por: 6.Salida del miembro del hogar que generaba ingresos debido a separación/divorcio"
	label var evento_7 "Desde 2017, el hogar se vio afectado por: 7.Salida del miembro de la familia que generaba ingresos debido al matrimonio"
	label var evento_8 "Desde 2017, el hogar se vio afectado por: 8.Salida de un miembro del hogar que generaba ingresos por emigración"
	label var evento_9 "Desde 2017, el hogar se vio afectado por: 9.Fracaso empresarial no agrícola/cierre de negocio o emprendimiento"
	label var evento_10 "Desde 2017, el hogar se vio afectado por: 10.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var evento_11 "Desde 2017, el hogar se vio afectado por: 11.Pérdida de cosecha por incendio/sequía/inundaciones"
	label var evento_12 "Desde 2017, el hogar se vio afectado por: 12.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var evento_13 "Desde 2017, el hogar se vio afectado por: 13.Vivienda dañada / demolida"
	label var evento_14 "Desde 2017, el hogar se vio afectado por: 14.Pérdida de propiedad por incendio o inundación"
	label var evento_15 "Desde 2017, el hogar se vio afectado por: 15.Pérdida de tierras"
	label var evento_16 "Desde 2017, el hogar se vio afectado por: 16.Muerte de ganado por enfermedad"
	label var evento_17 "Desde 2017, el hogar se vio afectado por: 17:Incremento en el precio de los insumos,"
	label var evento_18 "Desde 2017, el hogar se vio afectado por: 18:Caída en el precio de los productos,"
	label var evento_19 "Desde 2017, el hogar se vio afectado por: 19:Incremento en el precio de los principales alimentos consumidos,"
	label var evento_20 "Desde 2017, el hogar se vio afectado por: 20:Secuestro/robo/asalto"
	label var evento_21 "Desde 2017, el hogar se vio afectado por: 21: Otro (especifique)"

	* s15q2 o imp_evento_*
	label var imp_evento_1 "Top 3 eventos: 1. Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var imp_evento_2 "Top 3 eventos: 2. Muerte de alguien que envía remesas a la casa"
	label var imp_evento_3 "Top 3 eventos: 3. Enfermedad de la persona con el ingreso más importante del hogar"
	label var imp_evento_4 "Top 3 eventos: 4. Pérdida de un contacto importante"
	label var imp_evento_5 "Top 3 eventos: 5. Perdida de trabajo"
	label var imp_evento_6 "Top 3 eventos: 6. Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var imp_evento_7 "Top 3 eventos: 7. Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var imp_evento_8 "Top 3 eventos: 8. Fracaso empresarial no agrícola"
	label var imp_evento_9 "Top 3 eventos: 9. Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var imp_evento_10 "Top 3 eventos: 10. Destrucción de cosecha por fuego"
	label var imp_evento_11 "Top 3 eventos: 11. Vivienda dañada / demolida"
	label var imp_evento_12 "Top 3 eventos: 12. Pocas lluvias que causaron el fracaso de la cosecha"
	label var imp_evento_13 "Top 3 eventos: 13. Inundaciones que causaron el fracaso de la cosecha"
	label var imp_evento_14 "Top 3 eventos: 14. Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var imp_evento_15 "Top 3 eventos: 15. Pérdida de propiedad por incendio o inundación"
	label var imp_evento_16 "Top 3 eventos: 16. Pérdida de tierra"
	label var imp_evento_17 "Top 3 eventos: 17:Muerte de ganado por enfermedad, "
	label var imp_evento_18 "Top 3 eventos: 18:Incremento en el precio de los insumos, "
	label var imp_evento_19 "Top 3 eventos: 19:Caída en el precio de los productos,"
	label var imp_evento_20 "Top 3 eventos: 20:Incremento en el precio de los principales alimentos consumidos, "
	label var imp_evento_21 "Top 3 eventos: 21:Secuestro / robo / asalto, "
	label var imp_evento_22 "Top 3 eventos: 22:Otra especificar"

	* Cómo se las arregló su hogar con el choque más reciente?
	* reaccion_evento_*_* or 15q2c__
	
	label var reaccion_evento_1_1 "2c. Hogar vendió ganado por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_2_1 "2c. Hogar vendió terreno por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_3_1 "2c. Hogar vendió propiedad por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_4_1 "2c. Hogar envió a los niños a vivir con amigos por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_5_1 "2c. Hogar retiró a los niños de la escuela por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_6_1 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_8_1 "2c. Hogar fue asistido por familiares/amigos por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_9_1 "2c. Hogar recibió préstamos de amigos/familia por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_10_1 "2c. Hogar tomó préstamo de institución financiera por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_12_1 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_13_1 "2c. Hogar compró al crédito por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_14_1 "2c. Hogar retrasó pagos por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_15_1 "2c. Hogar vendió cosecha por adelantado  por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_16_1 "2c. Hogar redujo el consumo de alimentos  por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_17_1 "2c. Hogar redujo el consumo de no alimentos  por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_18_1 "2c. Hogar usó ahorros por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_19_1 "2c. Hogar recibió asistencia de ONG por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_20_1 "2c. Hogar tomó pago por adelantado de empleador  por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_21_1 "2c. Hogar recibió asistencia del gobierno por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_22_1 "2c. Hogar fue cubierto por un seguro por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_23_1 "2c. Hogar no hizo nada por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_24_1 "2c. Hogar hizo otras cosas por reciente 1.Muerte o discapacidad de un miembro adulto del hogar que trabaja"
	label var reaccion_evento_1_2 "2c. Hogar vendió ganado por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_2_2 "2c. Hogar vendió terreno por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_3_2 "2c. Hogar vendió propiedad por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_4_2 "2c. Hogar envió a los niños a vivir con amigos por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_5_2 "2c. Hogar retiró a los niños de la escuela por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_6_2 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_8_2 "2c. Hogar fue asistido por familiares/amigos por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_9_2 "2c. Hogar recibió préstamos de amigos/familia por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_10_2 "2c. Hogar tomó préstamo de institución financiera por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_12_2 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_13_2 "2c. Hogar compró al crédito por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_14_2 "2c. Hogar retrasó pagos por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_15_2 "2c. Hogar vendió cosecha por adelantado  por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_16_2 "2c. Hogar redujo el consumo de alimentos  por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_17_2 "2c. Hogar redujo el consumo de no alimentos  por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_18_2 "2c. Hogar usó ahorros por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_19_2 "2c. Hogar recibió asistencia de ONG por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_20_2 "2c. Hogar tomó pago por adelantado de empleador  por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_21_2 "2c. Hogar recibió asistencia del gobierno por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_22_2 "2c. Hogar fue cubierto por un seguro por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_23_2 "2c. Hogar no hizo nada por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_24_2 "2c. Hogar hizo otras cosas por reciente 2.Muerte de alguien que envía remesas a la casa"
	label var reaccion_evento_1_3 "2c. Hogar vendió ganado por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_2_3 "2c. Hogar vendió terreno por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_3_3 "2c. Hogar vendió propiedad por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_4_3 "2c. Hogar envió a los niños a vivir con amigos por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_5_3 "2c. Hogar retiró a los niños de la escuela por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_6_3 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_8_3 "2c. Hogar fue asistido por familiares/amigos por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_9_3 "2c. Hogar recibió préstamos de amigos/familia por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_10_3 "2c. Hogar tomó préstamo de institución financiera por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_12_3 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_13_3 "2c. Hogar compró al crédito por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_14_3 "2c. Hogar retrasó pagos por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_15_3 "2c. Hogar vendió cosecha por adelantado  por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_16_3 "2c. Hogar redujo el consumo de alimentos  por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_17_3 "2c. Hogar redujo el consumo de no alimentos  por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_18_3 "2c. Hogar usó ahorros por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_19_3 "2c. Hogar recibió asistencia de ONG por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_20_3 "2c. Hogar tomó pago por adelantado de empleador  por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_21_3 "2c. Hogar recibió asistencia del gobierno por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_22_3 "2c. Hogar fue cubierto por un seguro por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_23_3 "2c. Hogar no hizo nada por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_24_3 "2c. Hogar hizo otras cosas por reciente 3.Enfermedad de la persona con el ingreso más importante del hogar"
	label var reaccion_evento_1_4 "2c. Hogar vendió ganado por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_2_4 "2c. Hogar vendió terreno por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_3_4 "2c. Hogar vendió propiedad por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_4_4 "2c. Hogar envió a los niños a vivir con amigos por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_5_4 "2c. Hogar retiró a los niños de la escuela por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_6_4 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_8_4 "2c. Hogar fue asistido por familiares/amigos por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_9_4 "2c. Hogar recibió préstamos de amigos/familia por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_10_4 "2c. Hogar tomó préstamo de institución financiera por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_12_4 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_13_4 "2c. Hogar compró al crédito por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_14_4 "2c. Hogar retrasó pagos por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_15_4 "2c. Hogar vendió cosecha por adelantado  por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_16_4 "2c. Hogar redujo el consumo de alimentos  por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_17_4 "2c. Hogar redujo el consumo de no alimentos  por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_18_4 "2c. Hogar usó ahorros por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_19_4 "2c. Hogar recibió asistencia de ONG por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_20_4 "2c. Hogar tomó pago por adelantado de empleador  por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_21_4 "2c. Hogar recibió asistencia del gobierno por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_22_4 "2c. Hogar fue cubierto por un seguro por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_23_4 "2c. Hogar no hizo nada por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_24_4 "2c. Hogar hizo otras cosas por reciente 4.Pérdida de un contacto importante"
	label var reaccion_evento_1_5 "2c. Hogar vendió ganado por reciente 5.Perdida de trabajo"
	label var reaccion_evento_2_5 "2c. Hogar vendió terreno por reciente 5.Perdida de trabajo"
	label var reaccion_evento_3_5 "2c. Hogar vendió propiedad por reciente 5.Perdida de trabajo"
	label var reaccion_evento_4_5 "2c. Hogar envió a los niños a vivir con amigos por reciente 5.Perdida de trabajo"
	label var reaccion_evento_5_5 "2c. Hogar retiró a los niños de la escuela por reciente 5.Perdida de trabajo"
	label var reaccion_evento_6_5 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 5.Perdida de trabajo"
	label var reaccion_evento_8_5 "2c. Hogar fue asistido por familiares/amigos por reciente 5.Perdida de trabajo"
	label var reaccion_evento_9_5 "2c. Hogar recibió préstamos de amigos/familia por reciente 5.Perdida de trabajo"
	label var reaccion_evento_10_5 "2c. Hogar tomó préstamo de institución financiera por reciente 5.Perdida de trabajo"
	label var reaccion_evento_12_5 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 5.Perdida de trabajo"
	label var reaccion_evento_13_5 "2c. Hogar compró al crédito por reciente 5.Perdida de trabajo"
	label var reaccion_evento_14_5 "2c. Hogar retrasó pagos por reciente 5.Perdida de trabajo"
	label var reaccion_evento_15_5 "2c. Hogar vendió cosecha por adelantado  por reciente 5.Perdida de trabajo"
	label var reaccion_evento_16_5 "2c. Hogar redujo el consumo de alimentos  por reciente 5.Perdida de trabajo"
	label var reaccion_evento_17_5 "2c. Hogar redujo el consumo de no alimentos  por reciente 5.Perdida de trabajo"
	label var reaccion_evento_18_5 "2c. Hogar usó ahorros por reciente 5.Perdida de trabajo"
	label var reaccion_evento_19_5 "2c. Hogar recibió asistencia de ONG por reciente 5.Perdida de trabajo"
	label var reaccion_evento_20_5 "2c. Hogar tomó pago por adelantado de empleador  por reciente 5.Perdida de trabajo"
	label var reaccion_evento_21_5 "2c. Hogar recibió asistencia del gobierno por reciente 5.Perdida de trabajo"
	label var reaccion_evento_22_5 "2c. Hogar fue cubierto por un seguro por reciente 5.Perdida de trabajo"
	label var reaccion_evento_23_5 "2c. Hogar no hizo nada por reciente 5.Perdida de trabajo"
	label var reaccion_evento_24_5 "2c. Hogar hizo otras cosas por reciente 5.Perdida de trabajo"
	label var reaccion_evento_1_6 "2c. Hogar vendió ganado por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_2_6 "2c. Hogar vendió terreno por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_3_6 "2c. Hogar vendió propiedad por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_4_6 "2c. Hogar envió a los niños a vivir con amigos por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_5_6 "2c. Hogar retiró a los niños de la escuela por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_6_6 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_8_6 "2c. Hogar fue asistido por familiares/amigos por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_9_6 "2c. Hogar recibió préstamos de amigos/familia por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_10_6 "2c. Hogar tomó préstamo de institución financiera por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_12_6 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_13_6 "2c. Hogar compró al crédito por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_14_6 "2c. Hogar retrasó pagos por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_15_6 "2c. Hogar vendió cosecha por adelantado  por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_16_6 "2c. Hogar redujo el consumo de alimentos  por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_17_6 "2c. Hogar redujo el consumo de no alimentos  por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_18_6 "2c. Hogar usó ahorros por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_19_6 "2c. Hogar recibió asistencia de ONG por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_20_6 "2c. Hogar tomó pago por adelantado de empleador  por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_21_6 "2c. Hogar recibió asistencia del gobierno por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_22_6 "2c. Hogar fue cubierto por un seguro por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_23_6 "2c. Hogar no hizo nada por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_24_6 "2c. Hogar hizo otras cosas por reciente 6.Salida del miembro de la familia que genera ingresos debido a la separación o el divorcio"
	label var reaccion_evento_1_7 "2c. Hogar vendió ganado por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_2_7 "2c. Hogar vendió terreno por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_3_7 "2c. Hogar vendió propiedad por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_4_7 "2c. Hogar envió a los niños a vivir con amigos por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_5_7 "2c. Hogar retiró a los niños de la escuela por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_6_7 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_8_7 "2c. Hogar fue asistido por familiares/amigos por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_9_7 "2c. Hogar recibió préstamos de amigos/familia por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_10_7 "2c. Hogar tomó préstamo de institución financiera por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_12_7 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_13_7 "2c. Hogar compró al crédito por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_14_7 "2c. Hogar retrasó pagos por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_15_7 "2c. Hogar vendió cosecha por adelantado  por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_16_7 "2c. Hogar redujo el consumo de alimentos  por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_17_7 "2c. Hogar redujo el consumo de no alimentos  por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_18_7 "2c. Hogar usó ahorros por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_19_7 "2c. Hogar recibió asistencia de ONG por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_20_7 "2c. Hogar tomó pago por adelantado de empleador  por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_21_7 "2c. Hogar recibió asistencia del gobierno por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_22_7 "2c. Hogar fue cubierto por un seguro por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_23_7 "2c. Hogar no hizo nada por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_24_7 "2c. Hogar hizo otras cosas por reciente 7.Salida del miembro de la familia que genera ingresos debido al matrimonio"
	label var reaccion_evento_1_8 "2c. Hogar vendió ganado por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_2_8 "2c. Hogar vendió terreno por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_3_8 "2c. Hogar vendió propiedad por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_4_8 "2c. Hogar envió a los niños a vivir con amigos por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_5_8 "2c. Hogar retiró a los niños de la escuela por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_6_8 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_8_8 "2c. Hogar fue asistido por familiares/amigos por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_9_8 "2c. Hogar recibió préstamos de amigos/familia por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_10_8 "2c. Hogar tomó préstamo de institución financiera por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_12_8 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_13_8 "2c. Hogar compró al crédito por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_14_8 "2c. Hogar retrasó pagos por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_15_8 "2c. Hogar vendió cosecha por adelantado  por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_16_8 "2c. Hogar redujo el consumo de alimentos  por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_17_8 "2c. Hogar redujo el consumo de no alimentos  por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_18_8 "2c. Hogar usó ahorros por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_19_8 "2c. Hogar recibió asistencia de ONG por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_20_8 "2c. Hogar tomó pago por adelantado de empleador  por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_21_8 "2c. Hogar recibió asistencia del gobierno por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_22_8 "2c. Hogar fue cubierto por un seguro por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_23_8 "2c. Hogar no hizo nada por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_24_8 "2c. Hogar hizo otras cosas por reciente 8.Fracaso empresarial no agrícola"
	label var reaccion_evento_1_9 "2c. Hogar vendió ganado por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_2_9 "2c. Hogar vendió terreno por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_3_9 "2c. Hogar vendió propiedad por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_4_9 "2c. Hogar envió a los niños a vivir con amigos por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_5_9 "2c. Hogar retiró a los niños de la escuela por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_6_9 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_8_9 "2c. Hogar fue asistido por familiares/amigos por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_9_9 "2c. Hogar recibió préstamos de amigos/familia por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_10_9 "2c. Hogar tomó préstamo de institución financiera por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_12_9 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_13_9 "2c. Hogar compró al crédito por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_14_9 "2c. Hogar retrasó pagos por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_15_9 "2c. Hogar vendió cosecha por adelantado  por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_16_9 "2c. Hogar redujo el consumo de alimentos  por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_17_9 "2c. Hogar redujo el consumo de no alimentos  por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_18_9 "2c. Hogar usó ahorros por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_19_9 "2c. Hogar recibió asistencia de ONG por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_20_9 "2c. Hogar tomó pago por adelantado de empleador  por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_21_9 "2c. Hogar recibió asistencia del gobierno por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_22_9 "2c. Hogar fue cubierto por un seguro por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_23_9 "2c. Hogar no hizo nada por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_24_9 "2c. Hogar hizo otras cosas por reciente 9.Robo de cultivos, dinero en efectivo, ganado u otros bienes"
	label var reaccion_evento_1_10 "2c. Hogar vendió ganado por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_2_10 "2c. Hogar vendió terreno por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_3_10 "2c. Hogar vendió propiedad por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_4_10 "2c. Hogar envió a los niños a vivir con amigos por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_5_10 "2c. Hogar retiró a los niños de la escuela por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_6_10 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_8_10 "2c. Hogar fue asistido por familiares/amigos por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_9_10 "2c. Hogar recibió préstamos de amigos/familia por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_10_10 "2c. Hogar tomó préstamo de institución financiera por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_12_10 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_13_10 "2c. Hogar compró al crédito por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_14_10 "2c. Hogar retrasó pagos por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_15_10 "2c. Hogar vendió cosecha por adelantado  por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_16_10 "2c. Hogar redujo el consumo de alimentos  por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_17_10 "2c. Hogar redujo el consumo de no alimentos  por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_18_10 "2c. Hogar usó ahorros por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_19_10 "2c. Hogar recibió asistencia de ONG por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_20_10 "2c. Hogar tomó pago por adelantado de empleador  por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_21_10 "2c. Hogar recibió asistencia del gobierno por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_22_10 "2c. Hogar fue cubierto por un seguro por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_23_10 "2c. Hogar no hizo nada por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_24_10 "2c. Hogar hizo otras cosas por reciente 10.Destrucción de cosecha por fuego"
	label var reaccion_evento_1_11 "2c. Hogar vendió ganado por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_2_11 "2c. Hogar vendió terreno por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_3_11 "2c. Hogar vendió propiedad por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_4_11 "2c. Hogar envió a los niños a vivir con amigos por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_5_11 "2c. Hogar retiró a los niños de la escuela por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_6_11 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_8_11 "2c. Hogar fue asistido por familiares/amigos por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_9_11 "2c. Hogar recibió préstamos de amigos/familia por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_10_11 "2c. Hogar tomó préstamo de institución financiera por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_12_11 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_13_11 "2c. Hogar compró al crédito por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_14_11 "2c. Hogar retrasó pagos por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_15_11 "2c. Hogar vendió cosecha por adelantado  por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_16_11 "2c. Hogar redujo el consumo de alimentos  por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_17_11 "2c. Hogar redujo el consumo de no alimentos  por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_18_11 "2c. Hogar usó ahorros por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_19_11 "2c. Hogar recibió asistencia de ONG por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_20_11 "2c. Hogar tomó pago por adelantado de empleador  por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_21_11 "2c. Hogar recibió asistencia del gobierno por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_22_11 "2c. Hogar fue cubierto por un seguro por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_23_11 "2c. Hogar no hizo nada por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_24_11 "2c. Hogar hizo otras cosas por reciente 11.Vivienda dañada / demolida"
	label var reaccion_evento_1_12 "2c. Hogar vendió ganado por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_2_12 "2c. Hogar vendió terreno por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_3_12 "2c. Hogar vendió propiedad por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_4_12 "2c. Hogar envió a los niños a vivir con amigos por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_5_12 "2c. Hogar retiró a los niños de la escuela por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_6_12 "2c. Hogar trabajó en otras actividades generadoras de ingreso por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_8_12 "2c. Hogar fue asistido por familiares/amigos por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_9_12 "2c. Hogar recibió préstamos de amigos/familia por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_10_12 "2c. Hogar tomó préstamo de institución financiera por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_12_12 "2c. Hogar tuvo miembros que emigraron por trabajo por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_13_12 "2c. Hogar compró al crédito por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_14_12 "2c. Hogar retrasó pagos por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_15_12 "2c. Hogar vendió cosecha por adelantado  por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_16_12 "2c. Hogar redujo el consumo de alimentos  por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_17_12 "2c. Hogar redujo el consumo de no alimentos  por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_18_12 "2c. Hogar usó ahorros por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_19_12 "2c. Hogar recibió asistencia de ONG por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_20_12 "2c. Hogar tomó pago por adelantado de empleador  por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_21_12 "2c. Hogar recibió asistencia del gobierno por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_22_12 "2c. Hogar fue cubierto por un seguro por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_23_12 "2c. Hogar no hizo nada por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_24_12 "2c. Hogar hizo otras cosas por recientes 12.Pocas lluvias que causaron el fracaso de la cosecha"
	label var reaccion_evento_1_13 "2c. Hogar vendió ganado por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_2_13 "2c. Hogar vendió terreno por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_3_13 "2c. Hogar vendió propiedad por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_4_13 "2c. Hogar envió a los niños a vivir con amigos por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_5_13 "2c. Hogar retiró a los niños de la escuela por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_6_13 "2c. Hogar trabajó en otras actividades generadoras de ingreso por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_8_13 "2c. Hogar fue asistido por familiares/amigos por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_9_13 "2c. Hogar recibió préstamos de amigos/familia por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_10_13 "2c. Hogar tomó préstamo de institución financiera por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_12_13 "2c. Hogar tuvo miembros que emigraron por trabajo por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_13_13 "2c. Hogar compró al crédito por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_14_13 "2c. Hogar retrasó pagos por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_15_13 "2c. Hogar vendió cosecha por adelantado  por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_16_13 "2c. Hogar redujo el consumo de alimentos  por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_17_13 "2c. Hogar redujo el consumo de no alimentos  por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_18_13 "2c. Hogar usó ahorros por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_19_13 "2c. Hogar recibió asistencia de ONG por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_20_13 "2c. Hogar tomó pago por adelantado de empleador  por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_21_13 "2c. Hogar recibió asistencia del gobierno por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_22_13 "2c. Hogar fue cubierto por un seguro por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_23_13 "2c. Hogar no hizo nada por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_24_13 "2c. Hogar hizo otras cosas por recientes 13.Inundaciones que causaron el fracaso de la cosecha"
	label var reaccion_evento_1_14 "2c. Hogar vendió ganado por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_2_14 "2c. Hogar vendió terreno por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_3_14 "2c. Hogar vendió propiedad por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_4_14 "2c. Hogar envió a los niños a vivir con amigos por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_5_14 "2c. Hogar retiró a los niños de la escuela por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_6_14 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_8_14 "2c. Hogar fue asistido por familiares/amigos por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_9_14 "2c. Hogar recibió préstamos de amigos/familia por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_10_14 "2c. Hogar tomó préstamo de institución financiera por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_12_14 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_13_14 "2c. Hogar compró al crédito por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_14_14 "2c. Hogar retrasó pagos por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_15_14 "2c. Hogar vendió cosecha por adelantado  por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_16_14 "2c. Hogar redujo el consumo de alimentos  por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_17_14 "2c. Hogar redujo el consumo de no alimentos  por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_18_14 "2c. Hogar usó ahorros por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_19_14 "2c. Hogar recibió asistencia de ONG por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_20_14 "2c. Hogar tomó pago por adelantado de empleador  por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_21_14 "2c. Hogar recibió asistencia del gobierno por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_22_14 "2c. Hogar fue cubierto por un seguro por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_23_14 "2c. Hogar no hizo nada por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_24_14 "2c. Hogar hizo otras cosas por reciente 14.Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento"
	label var reaccion_evento_1_15 "2c. Hogar vendió ganado por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_2_15 "2c. Hogar vendió terreno por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_3_15 "2c. Hogar vendió propiedad por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_4_15 "2c. Hogar envió a los niños a vivir con amigos por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_5_15 "2c. Hogar retiró a los niños de la escuela por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_6_15 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_8_15 "2c. Hogar fue asistido por familiares/amigos por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_9_15 "2c. Hogar recibió préstamos de amigos/familia por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_10_15 "2c. Hogar tomó préstamo de institución financiera por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_12_15 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_13_15 "2c. Hogar compró al crédito por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_14_15 "2c. Hogar retrasó pagos por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_15_15 "2c. Hogar vendió cosecha por adelantado  por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_16_15 "2c. Hogar redujo el consumo de alimentos  por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_17_15 "2c. Hogar redujo el consumo de no alimentos  por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_18_15 "2c. Hogar usó ahorros por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_19_15 "2c. Hogar recibió asistencia de ONG por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_20_15 "2c. Hogar tomó pago por adelantado de empleador  por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_21_15 "2c. Hogar recibió asistencia del gobierno por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_22_15 "2c. Hogar fue cubierto por un seguro por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_23_15 "2c. Hogar no hizo nada por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_24_15 "2c. Hogar hizo otras cosas por reciente 15.Pérdida de propiedad por incendio o inundación"
	label var reaccion_evento_1_16 "2c. Hogar vendió ganado por reciente 16.Pérdida de tierra"
	label var reaccion_evento_2_16 "2c. Hogar vendió terreno por reciente 16.Pérdida de tierra"
	label var reaccion_evento_3_16 "2c. Hogar vendió propiedad por reciente 16.Pérdida de tierra"
	label var reaccion_evento_4_16 "2c. Hogar envió a los niños a vivir con amigos por reciente 16.Pérdida de tierra"
	label var reaccion_evento_5_16 "2c. Hogar retiró a los niños de la escuela por reciente 16.Pérdida de tierra"
	label var reaccion_evento_6_16 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 16.Pérdida de tierra"
	label var reaccion_evento_8_16 "2c. Hogar fue asistido por familiares/amigos por reciente 16.Pérdida de tierra"
	label var reaccion_evento_9_16 "2c. Hogar recibió préstamos de amigos/familia por reciente 16.Pérdida de tierra"
	label var reaccion_evento_10_16 "2c. Hogar tomó préstamo de institución financiera por reciente 16.Pérdida de tierra"
	label var reaccion_evento_12_16 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 16.Pérdida de tierra"
	label var reaccion_evento_13_16 "2c. Hogar compró al crédito por reciente 16.Pérdida de tierra"
	label var reaccion_evento_14_16 "2c. Hogar retrasó pagos por reciente 16.Pérdida de tierra"
	label var reaccion_evento_15_16 "2c. Hogar vendió cosecha por adelantado  por reciente 16.Pérdida de tierra"
	label var reaccion_evento_16_16 "2c. Hogar redujo el consumo de alimentos  por reciente 16.Pérdida de tierra"
	label var reaccion_evento_17_16 "2c. Hogar redujo el consumo de no alimentos  por reciente 16.Pérdida de tierra"
	label var reaccion_evento_18_16 "2c. Hogar usó ahorros por reciente 16.Pérdida de tierra"
	label var reaccion_evento_19_16 "2c. Hogar recibió asistencia de ONG por reciente 16.Pérdida de tierra"
	label var reaccion_evento_20_16 "2c. Hogar tomó pago por adelantado de empleador  por reciente 16.Pérdida de tierra"
	label var reaccion_evento_21_16 "2c. Hogar recibió asistencia del gobierno por reciente 16.Pérdida de tierra"
	label var reaccion_evento_22_16 "2c. Hogar fue cubierto por un seguro por reciente 16.Pérdida de tierra"
	label var reaccion_evento_23_16 "2c. Hogar no hizo nada por reciente 16.Pérdida de tierra"
	label var reaccion_evento_24_16 "2c. Hogar hizo otras cosas por reciente 16.Pérdida de tierra"
	label var reaccion_evento_1_17 "2c. Hogar vendió ganado por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_2_17 "2c. Hogar vendió terreno por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_3_17 "2c. Hogar vendió propiedad por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_4_17 "2c. Hogar envió a los niños a vivir con amigos por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_5_17 "2c. Hogar retiró a los niños de la escuela por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_6_17 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_8_17 "2c. Hogar fue asistido por familiares/amigos por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_9_17 "2c. Hogar recibió préstamos de amigos/familia por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_10_17 "2c. Hogar tomó préstamo de institución financiera por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_12_17 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_13_17 "2c. Hogar compró al crédito por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_14_17 "2c. Hogar retrasó pagos por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_15_17 "2c. Hogar vendió cosecha por adelantado  por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_16_17 "2c. Hogar redujo el consumo de alimentos  por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_17_17 "2c. Hogar redujo el consumo de no alimentos  por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_18_17 "2c. Hogar usó ahorros por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_19_17 "2c. Hogar recibió asistencia de ONG por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_20_17 "2c. Hogar tomó pago por adelantado de empleador  por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_21_17 "2c. Hogar recibió asistencia del gobierno por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_22_17 "2c. Hogar fue cubierto por un seguro por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_23_17 "2c. Hogar no hizo nada por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_24_17 "2c. Hogar hizo otras cosas por reciente 17.Muerte de ganado por enfermedad, "
	label var reaccion_evento_1_18 "2c. Hogar vendió ganado por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_2_18 "2c. Hogar vendió terreno por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_3_18 "2c. Hogar vendió propiedad por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_4_18 "2c. Hogar envió a los niños a vivir con amigos por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_5_18 "2c. Hogar retiró a los niños de la escuela por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_6_18 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_8_18 "2c. Hogar fue asistido por familiares/amigos por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_9_18 "2c. Hogar recibió préstamos de amigos/familia por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_10_18 "2c. Hogar tomó préstamo de institución financiera por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_12_18 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_13_18 "2c. Hogar compró al crédito por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_14_18 "2c. Hogar retrasó pagos por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_15_18 "2c. Hogar vendió cosecha por adelantado  por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_16_18 "2c. Hogar redujo el consumo de alimentos  por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_17_18 "2c. Hogar redujo el consumo de no alimentos  por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_18_18 "2c. Hogar usó ahorros por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_19_18 "2c. Hogar recibió asistencia de ONG por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_20_18 "2c. Hogar tomó pago por adelantado de empleador  por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_21_18 "2c. Hogar recibió asistencia del gobierno por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_22_18 "2c. Hogar fue cubierto por un seguro por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_23_18 "2c. Hogar no hizo nada por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_24_18 "2c. Hogar hizo otras cosas por reciente 18.Incremento en el precio de los insumos, "
	label var reaccion_evento_1_19 "2c. Hogar vendió ganado por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_2_19 "2c. Hogar vendió terreno por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_3_19 "2c. Hogar vendió propiedad por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_4_19 "2c. Hogar envió a los niños a vivir con amigos por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_5_19 "2c. Hogar retiró a los niños de la escuela por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_6_19 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_8_19 "2c. Hogar fue asistido por familiares/amigos por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_9_19 "2c. Hogar recibió préstamos de amigos/familia por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_10_19 "2c. Hogar tomó préstamo de institución financiera por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_12_19 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_13_19 "2c. Hogar compró al crédito por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_14_19 "2c. Hogar retrasó pagos por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_15_19 "2c. Hogar vendió cosecha por adelantado  por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_16_19 "2c. Hogar redujo el consumo de alimentos  por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_17_19 "2c. Hogar redujo el consumo de no alimentos  por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_18_19 "2c. Hogar usó ahorros por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_19_19 "2c. Hogar recibió asistencia de ONG por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_20_19 "2c. Hogar tomó pago por adelantado de empleador  por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_21_19 "2c. Hogar recibió asistencia del gobierno por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_22_19 "2c. Hogar fue cubierto por un seguro por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_23_19 "2c. Hogar no hizo nada por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_24_19 "2c. Hogar hizo otras cosas por reciente 19.Caída en el precio de los productos"
	label var reaccion_evento_1_20 "2c. Hogar vendió ganado por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_2_20 "2c. Hogar vendió terreno por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_3_20 "2c. Hogar vendió propiedad por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_4_20 "2c. Hogar envió a los niños a vivir con amigos por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_5_20 "2c. Hogar retiró a los niños de la escuela por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_6_20 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_8_20 "2c. Hogar fue asistido por familiares/amigos por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_9_20 "2c. Hogar recibió préstamos de amigos/familia por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_10_20 "2c. Hogar tomó préstamo de institución financiera por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_12_20 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_13_20 "2c. Hogar compró al crédito por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_14_20 "2c. Hogar retrasó pagos por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_15_20 "2c. Hogar vendió cosecha por adelantado  por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_16_20 "2c. Hogar redujo el consumo de alimentos  por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_17_20 "2c. Hogar redujo el consumo de no alimentos  por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_18_20 "2c. Hogar usó ahorros por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_19_20 "2c. Hogar recibió asistencia de ONG por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_20_20 "2c. Hogar tomó pago por adelantado de empleador  por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_21_20 "2c. Hogar recibió asistencia del gobierno por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_22_20 "2c. Hogar fue cubierto por un seguro por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_23_20 "2c. Hogar no hizo nada por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_24_20 "2c. Hogar hizo otras cosas por reciente 20.Incremento en el precio de los principales alimentos consumidos, "
	label var reaccion_evento_1_21 "2c. Hogar vendió ganado por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_2_21 "2c. Hogar vendió terreno por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_3_21 "2c. Hogar vendió propiedad por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_4_21 "2c. Hogar envió a los niños a vivir con amigos por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_5_21 "2c. Hogar retiró a los niños de la escuela por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_6_21 "2c. Hogar trabajó en otras actividades generadoras de ingreso por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_8_21 "2c. Hogar fue asistido por familiares/amigos por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_9_21 "2c. Hogar recibió préstamos de amigos/familia por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_10_21 "2c. Hogar tomó préstamo de institución financiera por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_12_21 "2c. Hogar tuvo miembros que emigraron por trabajo por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_13_21 "2c. Hogar compró al crédito por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_14_21 "2c. Hogar retrasó pagos por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_15_21 "2c. Hogar vendió cosecha por adelantado  por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_16_21 "2c. Hogar redujo el consumo de alimentos  por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_17_21 "2c. Hogar redujo el consumo de no alimentos  por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_18_21 "2c. Hogar usó ahorros por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_19_21 "2c. Hogar recibió asistencia de ONG por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_20_21 "2c. Hogar tomó pago por adelantado de empleador  por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_21_21 "2c. Hogar recibió asistencia del gobierno por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_22_21 "2c. Hogar fue cubierto por un seguro por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_23_21 "2c. Hogar no hizo nada por reciente 21.Secuestro / robo / asalto"
	label var reaccion_evento_24_21 "2c. Hogar hizo otras cosas por reciente 21.Secuestro / robo / asalto"

/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- POVERTY ---------------------------------------------------------------
************************************************************************************************************************************************)*/
	
label var lp_19usd "Línea de pobreza internacional 1.9 USD (en dólares ppp mensuales)"
label var lp_32usd "Línea de pobreza internacional 3.2 USD (en dólares ppp mensuales)"
label var lp_55usd "Línea de pobreza internacional 5.5 USD (en dólares ppp mensuales)"
	
label var pobre 		"Identificador situación de pobreza"
label var pobre_extremo	"Identificador situación de pobreza extrema"

label var pobre_19 		"Identificador situación de pobreza: ingreso debajo de línea int. 1.9USD PPP al día"
label var pobre_32		"Identificador situación de pobreza: ingreso debajo de línea int. 3.2USD PPP al día"
label var pobre_55 		"Identificador situación de pobreza: ingreso debajo de línea int. 5.5USD PPP al día"

/*(************************************************************************************************************************************************ 
*---------------------------------------------------- INCOME VARIABLES / VARIABLES DE INGRESO ------------------------------------------------
************************************************************************************************************************************************)*/

label var    iasalp_m          "Ingreso asalariado en la ocupación principal - monetario"
label var    iasalp_nm         "Ingreso asalariado en la ocupación principal - no monetario"
label var    ictapp_m          "Ingreso por cuenta propia en la ocupación principal - monetario"
label var    ictapp_nm         "Ingreso por cuenta propia en la ocupación principal - no monetario"
label var    ipatrp_m          "Ingreso por patrón en la ocupación principal - monetario"
label var    ipatrp_nm         "Ingreso por patrón en la ocupación principal - no monetario"
label var    iolp_m            "Otros ingresos laborales en la ocupación principal - monetario"
label var    iolp_nm           "Otros ingresos laborales en la ocupación principal - no monetario"
label var    iasalnp_m         "Ingreso asalariado en la ocupación no principal - monetario"
label var    iasalnp_nm        "Ingreso asalariado en la ocupación no principal - no monetario"
label var    ictapnp_m         "Ingreso por cuenta propia en la ocupación no principal - monetario"
label var    ictapnp_nm        "Ingreso por cuenta propia en la ocupación no principal - no monetario"
label var    ipatrnp_m         "Ingreso por patrón en la ocupación no principal - monetario"
label var    ipatrnp_nm        "Ingreso por patrón en la ocupación no principal - no monetario"
label var    iolnp_m           "Otros ingresos laborales en la ocupación no principal - monetario"
label var    iolnp_nm          "Otros ingresos laborales en la ocupación no principal - no monetario"
label var    ijubi_m         "Ingreso monetario por jubilaciones y pensiones"
label var    ijubi_nm        "Ingreso no monetario por jubilaciones y pensiones"
*label var    ijubi_o	       "Ingreso por jubilaciones y pensiones (no identificado si contributiva o no)"
label var    icap_m              "Ingreso monetario del capital"
label var    icap_nm             "Ingreso no monetario del capital"
label var    icap             "Ingreso del capital"
label var    cct	       "Ingreso por programas de transferencias monetarias condicionadas"	 
label var    itrane_o_m	       "Ingreso por transferencias estatales no CCT - monetario"	
label var    itrane_o_nm         "Ingreso por transferencias estatales no CCT - no monetario"
label var    itrane_ns         "Ingreso por transferencias estatales no especificadas"
label var    rem               "Ingreso por remesas del exterior - monetario"
*label var    itranext_nm       "Ingreso por remesas del exterior - no monetario"
label var    itranp_o_m        "Ingreso por otras transferencias privadas del país - monetario"
label var    itranp_o_nm       "Ingreso por otras transferencias privadas del país - no monetario"
label var    itranp_ns         "Ingreso por transferencias privadas no especificadas"
label var    inla_extraord         "Ingresos no laborales extraordinarios"
label var    inla_otro         "Otros ingresos no laborales (imputación de inla excepto jubilaciones y pensiones"
label var    ipatrp            "Ingreso por patrón en la ocupación principal - total"
label var    iasalp            "Ingreso asalariado en la ocupación principal - total"
label var    ictapp            "Ingreso por cuenta propia en la ocupación principal - total"
label var    iolp	       "Otros ingresos laborales en la ocupación principal - total"
label var    ip_m              "Ingreso en la ocupación principal - monetario"
label var    ip                "Ingreso en la ocupación principal"
label var    wage_m            "Ingreso horario en la ocupación principal - monetario"
label var    wage              "Ingreso horario en la ocupación principal" 
label var    ipatrnp	       "Ingreso por patrón en la ocupación no principal - total"	
label var    iasalnp           "Ingreso asalariado en la ocupación no principal - total"
label var    ictapnp           "Ingreso por cuenta propia en la ocupación no principal - total"
label var    iolnp             "Otros ingresos laborales en la ocupación principal - total"
label var    inp	       "Ingreso por trabajo en la actividad no principal"	 
label var    ipatr_m           "Ingreso por trabajo como patrón - monetario"
label var    ipatr             "Ingreso por trabajo como patrón"
label var    iasal_m           "Ingreso por trabajo como asalariado - monetario" 
label var    iasal             "Ingreso por trabajo como asalariado" 
label var    ictap_m           "Ingreso por trabajo como cuentapropista - monetario"
label var    ictap             "Ingreso por trabajo como cuentapropista"
label var    ila_m             "Ingreso laboral - monetario"
label	var	ila_m_local			"Ingreso laboral monetario de origen local"
label	var	ila_m_ext			"Ingreso laboral monetario del exterior"
label var    ila               "Ingreso laboral total"
label var    ilaho_m           "Ingreso horario en todas las ocupaciones - monetario"
label var    ilaho             "Ingreso horario en todas las ocupaciones"
label var    perila            "Dummy de perceptor de ingresos laborales: =1 si percibe ingreso laboral"
label var    ijubi             "Ingreso por jubilaciones y pensiones"
label var    itranp_m          "Ingreso por transferencias privadas - monetario"
label var    itranp            "Ingreso por transferencias privadas"
label var    itrane_m          "Ingreso por transferencias estatales - monetario"
label var    itrane            "Ingreso por transferencias estatales"
label var    itran_m           "Ingreso por transferencias - monetario"
label var    itran             "Ingreso por transferencia"
label var    inla_m            "Ingreso no laboral total - monetario"
label var    inla              "Ingreso no laboral total"
label var    ii_m              "Ingreso individual total - monetario" 
label var    ii                "Ingreso individual total"
label var    perii             "Perceptor ingresos"
label var    n_perila_h        "Número de perceptores de ingreso laboral en el hogar"
label var    n_perii_h         "Número de perceptores de ingreso individual en el hogar"
label var    ilf_m             "Ingreso laboral total familiar - monetario"
label var    ilf               "Ingreso laboral total familiar"
label var    inlaf_m           "Ingreso no laboral total familiar - monetario"
label var    inlaf             "Ingreso no laboral total familiar"
label var    itf_m             "Ingreso total familiar - monetario"
label var    itf_sin_ri        "Ingreso total familiar sin renta imputada"
label var    renta_imp         "Renta imputada de la vivienda propia"
label var    itf               "Ingreso total familiar"
label var    cohi              "Indicador de respuesta de ingresos: =1 si coherente - individual"
label var    cohh              "Indicador de respuesta de ingresos: =1 si respuesta del hogar coherente"
label var    coh_oficial       "Indicador de respuesta de ingresos: =1 si respuesta del hogar coherente - para estimación oficial"
label var    ilpc_m            "Ingreso laboral per cápita - monetario" 
label var    ilpc              "Ingreso laboral per cápita" 
label var    inlpc_m           "Ingreso no laboral per cápita - monetario" 
label var    inlpc             "Ingreso no laboral per cápita"
label var    ipcf_sr           "Ingreso per cápita familiar sin renta implícita"
label var    ipcf_m            "Ingreso per cápita familiar - monetario" 
label var    ipcf              "Ingreso per cápita familiar" 
label var    iea               "Ingreso equivalente A" 
label var    ieb               "Ingreso equivalente B" 
label var    iec               "Ingreso equivalente C" 
label var    ied               "Ingreso equivalente D" 
label var    iee               "Ingreso equivalente E" 
cap label var    ilea_m            "Ingreso laboral equivalente - monetario" 
cap label var    lp_extrema	       "Línea de pobreza extrema  oficial"
cap label var    lp_moderada       "Línea de pobreza moderada oficial"
cap label var    ing_pob_ext       "Ingreso utilizado para estimar la pobreza extrema oficial"
cap label var    ing_pob_mod       "Ingreso utilizado para estimar la pobreza moderada oficial"
cap label var    ing_pob_mod_lp    "Ingreso oficial / LP"
cap label var    p_reg	       "Factor ajuste por precios regionales"
cap label var    ipc	       "IPC mes base" 
cap label var    pipcf	       "Percentiles ingreso per cápita familiar"
cap label var    dipcf	       "Deciles ingreso per cápita familiar"
cap label var    p_ing_ofi	       "Percentiles ingreso oficial para estimar pobreza"
cap label var    d_ing_ofi	       "Deciles ingreso oficial para estimar pobreza"
cap label var    piea	       "Percentiles ingreso equivalente A"
cap label var    qiea	       "Quintiles ingreso equivalente A"
cap label var    pondera_i	       "Ponderador para variables de ingreso"  
cap label var    ipc05	       "Índice de Precios al Consumidor Promedio de 2005"
cap label var    ipc11	       "Índice de Precios al Consumidor Promedio de 2011"
cap label var    ppp05	       "Factor de Ajuste de PPP 2005"
cap label var    ppp11	       "Factor de Ajuste de PPP 2011"
cap label var    ipcf_cpi05	       "Ingreso per cápita familiar en valores de 2005"
cap label var    ipcf_cpi11	       "Ingreso per cápita familiar en valores de 2011"
cap label var    ipcf_ppp05	       "Ingreso per cápita familiar en dólares de 2005"
cap label var    ipcf_ppp11	       "Ingreso per cápita familiar en dólares de 2011"

*** Colgadas

label var clap "Este hogar es/ha sido beneficiario de la Bolsa-Caja del CLAP?"

label var    hogarsec        "Miembro de un hogar secundario"
label define hogarsec 0 "No" 1 "Si"
label values hogarsec hogarsec

