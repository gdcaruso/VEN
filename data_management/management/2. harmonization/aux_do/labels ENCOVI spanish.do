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
label var	pondera         "Factor de ponderacion a nivel individual"
cap label var 	pondera_hh		"Factor de ponderacion a nivel de los hogares"
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
