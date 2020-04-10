*****************************************************************
*** ENCOVI 2019 - IMPUTATION - POSSIBLE VARIABLES FOR REGRESSION 
*****************************************************************

*Variables for Mincer Equation
	gen propieta = (tenencia_vivienda==1 | tenencia_vivienda==2) if tenencia_vivienda!=.

	gen agegroup=1 if edad<=14 & edad!=.
	replace agegroup=2 if edad>=15 & edad<=24 & edad!=.
	replace agegroup=3 if edad>=25 & edad<=34 & edad!=.
	replace agegroup=4 if edad>=35 & edad<=44 & edad!=.
	replace agegroup=5 if edad>=45 & edad<=54 & edad!=.
	replace agegroup=6 if edad>=55 & edad<=64 & edad!=.
	replace agegroup=7 if edad>=65 & edad!=.
	label def agegroup 1 "[0-14]" 2 "[15-24]" 3 "[25-34]" 4 "[35-44]" 5 "[45-54]" 6 "[55-64]" 7 "[65+]"
	label value agegroup agegroup
	
	gen edad2=edad^2
		
	* Ingreso laboral - hacerlo por categ. ocup?
	local mineq_ila = "edad edad2 agegroup hombre relacion_comp miembros estado_civil region_est1 municipio tipo_vivienda propieta auto anio_auto heladera lavarropas computadora internet televisor calentador aire tv_cable microondas seguro_salud nivel_educ tarea sector_encuesta categ_ocu hstr_todos aporte_pension clap"
		
		* Copio variables para que no tengan missing (missing una variables más)
		foreach i of varlist `mineq_ila' {
			sum `i'
			clonevar `i'_sinmis = `i'
			replace `i'_sinmis = r(max) + 1 if `i'==.
	}
	
	br if (edad_sinmis==. |	hombre_sinmis==. |	relacion_comp_sinmis==. |	miembros_sinmis==. |	estado_civil_sinmis==. |	region_est1_sinmis==. |	municipio_sinmis==. |	tipo_vivienda_sinmis==. |	propieta_sinmis==. |	auto_sinmis==. |	anio_auto_sinmis==. |	heladera_sinmis==. |	lavarropas_sinmis==. |	computadora_sinmis==. |	internet_sinmis==. |	televisor_sinmis==. |	calentador_sinmis==. |	aire_sinmis==. |	tv_cable_sinmis==. |	microondas_sinmis==. |	seguro_salud_sinmis==. |	nivel_educ_sinmis==. |	tarea_sinmis==. |	sector_encuesta_sinmis==. |	categ_ocu_sinmis==. |	hstr_todos_sinmis==. |	aporte_pension_sinmis==. |	clap_sinmis==. )
		* Da ok, ninguna
	
	local mineq_ila_sinmis = "edad_sinmis	edad2_sinmis  agegroup_sinmis	hombre_sinmis 	relacion_comp_sinmis 	miembros_sinmis 	estado_civil_sinmis 	region_sinmis 	municipio_sinmis 	tipo_vivienda_sinmis 	propieta_sinmis 	auto_sinmis 	anio_auto_sinmis 	heladera_sinmis 	lavarropas_sinmis 	computadora_sinmis 	internet_sinmis 	televisor_sinmis 	calentador_sinmis 	aire_sinmis 	tv_cable_sinmis 	microondas_sinmis 	seguro_salud_sinmis 	nivel_educ_sinmis 	tarea_sinmis 	sector_encuesta_sinmis 	categ_ocu_sinmis 	hstr_todos_sinmis 	aporte_pension_sinmis 	clap_sinmis"



	* Ingreso laboral no monetario (no jubilación)
	
	
	* Ingreso no laboral
	
	
	* Jubilación
