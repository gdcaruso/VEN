
/*(************************************************************************************************************************************************* 
*------------------------------------------------------ VII. EDUCATION / EDUCACIÓN -----------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Is the "member" answering by himself/herself?
		*-- Label variable
		label var contesta_ind "Esta contestando por si mismo?"
		*-- Label values
		label def contesta_ind 1 "Si" 0 "No"
		label val contesta_ind contesta_ind
		
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
		label var tipo_centro_educ "¿El centro de educacion donde estudia es:"
		*-- Label values
		label def tipo_centro_educ 1 "Privado" 2 "Publico"
		label value tipo_centro_educ tipo_centro_educ
		
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
		1 "Ninguno" 2 "Preescolar" 3 "Regimen anterior: Basica (1-9)" ///  
		4 "Regimen anterior: Media (1-3)" 5 "Regimen actual: Primaria (1-6)" ///	
		6 "Regimen actual: Media (1-6)" 7 "Tecnico (TSU)" ///	
		8 "Universitario" 		9 "Postgrado"
	label def nivel_educ_en
	label value nivel_educ_en nivel_educ_en
	
/* NIVEL_EDUC: Comparable across years */
	*-- Label variable
	label var nivel_educ  "Último grado, año, semestre o trimestre y de cuál nivel educativo aprobado (armonizada)"
	label var nivel_educ 
		1 "Ninguno" 2 "Preescolar" 3 "Primaria"	///
		4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
	label def nivel_educ
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
