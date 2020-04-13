* ENCOVI 2019 - IMPUTATION
* Objective: Identification missing values and possible variables for regression

****************************************************************
*** IDENTIFICATION OF MISSING VALUES 
****************************************************************
 
///*** OPEN DATABASE & PATHS ***///

global pathout "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
global pathoutexcel "C:\Users\wb550905\Github\VEN\data_management\management\4. income imputation\output"

*ESTE NO use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned\ENCOVI_2019_INFLA VERDADERA", clear
*ESTE NO use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned\ENCOVI_2019_ING SIN AJUSTE POR INFLACION.dta", clear
use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned\ENCOVI_2019_Asamblea Nacional.dta", clear
*use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned\ENCOVI_2019_PRECIOS IMPLICITOS.dta", clear


///*** DESCRIPTION INCOME ***///
	
	xtile quintil=ipcf, n(5)
	bys interview_month quintil: sum ipcf
	
	* Percentage of each kind of income in itf
	gen perc_ilaenitf = ilf / itf if itf!=.
	replace perc_ilaenitf = 0 if itf>0 & ilf==.
	gen perc_inlaenitf = inlaf / itf if itf!=.
	replace perc_inlaenitf = 0 if itf>0 & inlaf==.
	gen perc_rentimpenitf = renta_imp / itf if itf!=.
	replace perc_rentimpenitf = 0 if itf>0 & renta_imp==.

	sum perc_ilaenitf if itf!=.
	sum perc_inlaenitf if itf!=.
	sum perc_rentimpenitf if itf!=.
	
	* Percentage each kind of income in inla
	foreach i of varlist ijubi_m icap_m rem itranp_o_m itranp_ns itrane_o_m itrane_ns inla_otro {
	gen perc_`i'eninla = `i' / inla if inla!=.
	replace perc_`i'eninla = 0 if inla>0 & `i'==.
	
	sum perc_`i'eninla if inla!=.
	}

	* Generate variable ocupado / "occupied"
		gen ocupado = .
		replace ocupado = 1 if inlist(labor_status,1,2)
			*Another exact way of doing it:
			*replace ocupado = 1 if trabajo_semana==1 | trabajo_semana_2==1 | trabajo_semana_2==2 | trabajo_independiente==1 | sueldo_semana==1 // Trabajando? 
		*(Redundant) Assumption: if received a wage or benefits last week (s9q5/sueldo_semana==1), the survey considers them as ocupados (although they answered no to having worked). However, This question is only asked to those who trabajo_independiente==1 so they were already included
		replace ocupado = 0 if trabajo_semana==0 & trabajo_semana_2==3 & trabajo_independiente==0
		label def ocupado 		1 "Ocupado" 0 "No ocupado"
		label values ocupado ocupado
			*Checks missings
			gen edad9 = (inlist(edad,0,1,2,3,4,5,6,7,8,9)) if edad!=. & edad!=.a
			tab ocupado edad9, mi
			* 4979 de los 4991 missing en ocupados son niños de 9 o menos
			*br if ocupado==. & edad>9
			* Los 12 restantes son encuestas incompletas 
	
	
/// *** CASES TO BE IMPUTED *** ///

 
*** 1. Those who report receiving but then don't report amount ***

	/* recibe_ingresolab_mon_mes recibe_ingresolab_mon_ano recibe_ingresolab_mon report_inglabmon_nocuanto ///
		recibe_ingresolab_nomon report_inglabnomon_nocuanto ///
		cuantasinlarecibe recibe_ingresonolab report_ingnolab_nocuanto */

	* 1.a. MONETARY LABOR INCOME

		* Ingreso laboral monetario (empleados y empleadores), segun si recibieron o no en el ultimo mes
			gen recibe_ingresolab_mon_mes = .
			replace recibe_ingresolab_mon_mes = 1 if (im_sueldo==1 | im_hsextra==1 | im_propina==1 | im_comision==1 | im_ticket==1 | im_guarderia==1 | im_beca==1 | im_hijos==1 | im_antiguedad==1 | im_transporte==1 | im_rendimiento==1 | im_otro==1) ///
				| im_petro==1 | im_patron==1 // Recibió ingreso monetario en algún concepto en el último mes (no usamos s9q26 porque se decidió que s9q25 engloba ambas 26 y 27)
			replace recibe_ingresolab_mon_mes = 0 if (im_sueldo==0 & im_hsextra==0 & im_propina==0 & im_comision==0 & im_ticket==0 & im_guarderia==0 & im_beca==0 & im_hijos==0 & im_antiguedad==0 & im_transporte==0 & im_rendimiento==0 & im_otro==0) ///
				& im_petro==0 & im_patron==0 // No recibió ingreso laboral monetario en ningún concepto mensual
			* Problem: income from abroad for salaries/wages and net benefits for independent workers (s9q29a_1 and _2), and local benefits/utilities of independent workers (s9q25) are measured on a yearly basis, not monthly as the others
			* If we include them in this dummy, there ends up being some unemployed or inactives who report labor income.
		
		*Ingreso laboral monetario (independientes y otros), segun si recibieron o no en el ultimo año
			* Thus, analysis on the side for imputation for those 3 variables, create a new variables
			gen recibe_ingresolab_mon_ano = .
			replace recibe_ingresolab_mon_ano = 1 if im_indep==1 | (iext_sueldo==1 | iext_ingnet==1)
			replace recibe_ingresolab_mon_ano = 0 if im_indep==0 & iext_sueldo==0 & iext_ingnet==0
		
		* Checks (data April 10)
		tab recibe_ingresolab_mon_ano recibe_ingresolab_mon_mes, mi
		tab labor_status recibe_ingresolab_mon_mes, mi // OK: No unemployed (3), inactive (5-9), or person with missing (.) labor status report receiving monetary labor income
		tab labor_status recibe_ingresolab_mon_ano, mi // 30 obs. unemployed or inactive with labor income
		*br if recibe_ingresolab_mon_ano==1 & inlist(labor_status,3,5,6,7,8,9,.)
		* They are all cases with (iext_sueldo==1 | iext_ingnet==1), which captures 1 year (not 1 week as ocupado variable)
		
		gen recibe_ingresolab_mon = .
		replace recibe_ingresolab_mon = 0 if recibe_ingresolab_mon_mes==0 & recibe_ingresolab_mon_ano==0 // Real zero
		replace recibe_ingresolab_mon = 1 if recibe_ingresolab_mon_mes==1
		replace recibe_ingresolab_mon = 2 if recibe_ingresolab_mon_ano==1
		replace recibe_ingresolab_mon = 3 if recibe_ingresolab_mon_mes==1 & recibe_ingresolab_mon_ano==1
			label def recibe_ingresolab_mon 0 "Dice que no recibe nada" 1 "Dice que recibio en el ultimo mes" 2 "Dice que recibio en el último año" 3 "Dice que en el último mes Y último año"
			label values recibe_ingresolab_mon recibe_ingresolab_mon
		
		tab recibe_ingresolab_mon, mi 
		
			* Crossed with the amount of income
			gen report_inglabmon_nocuanto = .
			replace report_inglabmon_nocuanto = 1 	if inlist(recibe_ingresolab_mon,1,2,3) & ingresoslab_mon==. // Dicen que reciben ila monetario, pero no reportan cuánto
			replace report_inglabmon_nocuanto = 0 	if inlist(recibe_ingresolab_mon,1,2,3) & ingresoslab_mon>=0 & ingresoslab_mon!=.
			*replace report_inglabmon_nocuanto = 0 	if ingresoslab_mon>=0 & ingresoslab_mon!=. // Same result as above line
				label def report_inglabmon_nocuanto 		1 "No reportan cuánto, pero dicen que reciben ila mon" 0 "Reportan cuánto"
				label values report_inglabmon_nocuanto report_inglabmon_nocuanto
			
		*Conclusion
		tab report_inglabmon_nocuanto, mi // We should impute 1,051 observations that declare to have earned monetary labor income but don't say how much
		
	* 1.b. NON-MONETARY LABOR INCOME
		
		* Ingreso laboral no monetario: todo analizado para el último mes (más fácil)
			gen recibe_ingresolab_nomon = .
			replace recibe_ingresolab_nomon = 1 if (inm_comida==1 | inm_productos==1 | inm_transporte==1 | inm_vehiculo==1 | inm_estaciona==1 | inm_telefono==1 | inm_servicios==1 | inm_guarderia==1 | inm_otro==1) | inm_patron==1 // Recibió ingreso no monetario en algún concepto
			replace recibe_ingresolab_nomon = 0 if (inm_comida==0 & inm_productos==0 & inm_transporte==0 & inm_vehiculo==0 & inm_estaciona==0 & inm_telefono==0 & inm_servicios==0 & inm_guarderia==0 & inm_otro==0) & inm_patron==0 // No recibió ingreso laboral no monetario en ningún concepto
			
		* Checks (data April 10)
		tab labor_status recibe_ingresolab_nomon, mi  // OK: No unemployed (3), inactive (5-9), or person with "." labor status report receiving non monetary labor income
		tab recibe_ingresolab_nomon, mi  // 816 receive non-monetary labor income
		
			* Crossed with the amount of income
			gen report_inglabnomon_nocuanto = .
			replace report_inglabnomon_nocuanto = 1 	if recibe_ingresolab_nomon==1 & ingresoslab_bene==. // Dicen que reciben ila no monetario, pero no reportan cuánto
			replace report_inglabnomon_nocuanto = 0 	if recibe_ingresolab_nomon==1 & ingresoslab_bene>=0 & ingresoslab_bene!=.
			*replace report_inglabnomon_nocuanto = 0 	if ingresoslab_bene>=0 & ingresoslab_bene!=. // Same result as above line
				label def report_inglabnomon_nocuanto 		1 "No reportan cuánto, pero dicen que reciben ila no mon" 0 "Reportan cuánto"
				label values report_inglabnomon_nocuanto report_inglabnomon_nocuanto
			
		*Conclusion
		tab report_inglabnomon_nocuanto, mi // We should impute 67 observations that declare to have earned non-monetary labor income but don't say how much
		
	* 1.c. MONETARY NON-LABOR INCOME 
			
			* Number of non-labor income sources that people received
			egen cuantasinlarecibe = rowtotal(inla_pens_soi	inla_pens_vss inla_jubi_emp inla_pens_dsa inla_beca_pub inla_beca_pri inla_ayuda_pu inla_ayuda_pr inla_ayuda_fa inla_asig_men inla_otros inla_petro ///
							iext_indemn	iext_remesa	iext_penjub	iext_intdiv	iext_becaes	iext_extrao iext_alquil), mi
			tab cuantasinlarecibe, mi // By April 10th, 8.3% received 0, 3.1% received 1, 0.1% missing, and the rest more than 1

		*1.C.1. ALL EXCEPT PENSIONS
			* Nota: inla_pens_dsa "Pensión por divorcio, separación, alimentación" la dejamos acá porque no es que son inactivos por ser jubilados/pensionados
				
			* Ingreso no laboral monetario (local) excepto jubilación/pension, segun si recibieron en el último MES
				gen recibe_ingresonolab_mes = .
				replace recibe_ingresonolab_mes = 1 if (inla_pens_dsa==1 | inla_beca_pub==1 | inla_beca_pri==1 | inla_ayuda_pu==1 | inla_ayuda_pr==1 | inla_ayuda_fa==1 | inla_asig_men==1 | inla_otro==1 )
					// Recibió ingreso monetario no laboral en algún concepto en el último mes
				replace recibe_ingresonolab_mes = 0 if (inla_pens_dsa==0 & inla_beca_pub==0 & inla_beca_pri==0 & inla_ayuda_pu==0 & inla_ayuda_pr==0 & inla_ayuda_fa==0 & inla_asig_men==0 & inla_otro==0) 
					// No recibió ingreso laboral monetario en ningún concepto mensual
				* Problem: income from abroad (s9q29a_3 to _9) are measured on a yearly basis, not monthly as the others.
			
			*Ingreso no laboral monetario (proveniente del exterior) excepto jubilación/pensión, segun si recibieron en el ultimo AÑO
				* Thus, analysis on the side for imputation for those 3 variables, create a new variables
				gen recibe_ingresonolab_ano = .
				replace recibe_ingresonolab_ano = 1 if (iext_indemn==1 | iext_remesa==1 | iext_intdiv==1 | iext_becaes==1 | iext_extrao==1 | iext_alquil==1)
				replace recibe_ingresonolab_ano = 0 if (iext_indemn==0 & iext_remesa==0 & iext_intdiv==0 & iext_becaes==0 & iext_extrao==0 & iext_alquil==0)
			
			* Checks (data April 10)
			tab recibe_ingresonolab_ano recibe_ingresonolab_mes, mi
			tab labor_status recibe_ingresonolab_mes, mi // all over different labor_status, its okay
			tab labor_status recibe_ingresonolab_ano, mi // all over different labor_status, its okay
			
			gen recibe_ingresonolab = .
			replace recibe_ingresonolab = 0 if recibe_ingresonolab_mes==0 & recibe_ingresonolab_ano==0
			replace recibe_ingresonolab = 1 if recibe_ingresonolab_mes==1
			replace recibe_ingresonolab = 2 if recibe_ingresonolab_ano==1
			replace recibe_ingresonolab = 3 if recibe_ingresonolab_mes==1 & recibe_ingresonolab_ano==1
				label def recibe_ingresonolab 0 "Dice que no recibe nada" 1 "Dice que recibio en el ultimo mes" 2 "Dice que recibio en el último año" 3 "Dice que en el último mes Y último año"
				label values recibe_ingresonolab recibe_ingresonolab
			
			tab recibe_ingresonolab, mi 

				* Crossed with the amount of income
				egen inla_aux = rsum(inla_otro itrane_ns itrane_o_m itranp_ns itranp_o_m rem icap_m s9q28a_4_bolfeb), mi
				gen report_ingnolab_nocuanto = .
				replace report_ingnolab_nocuanto = 1 	if inlist(recibe_ingresonolab,1,2,3) & inla_aux==. // Dicen que reciben inla monetario (no jubi/pens), pero no reportan cuánto
				replace report_ingnolab_nocuanto = 0 	if inlist(recibe_ingresonolab,1,2,3) & inla_aux>=0 & inla_aux!=.
				*replace report_ingnolab_nocuanto = 0 	if inla_aux>=0 & inla_aux!=. // Same result as above line
					label def report_ingnolab_nocuanto 			1 "No reportan cuánto, pero dicen que reciben inla" 0 "Reportan cuánto"
					label values report_ingnolab_nocuanto report_ingnolab_nocuanto
			
			* Conclusion:
			tab report_ingnolab_nocuanto, mi // We should impute 441 obs. that declare to have received non labor income but don't say how much
			
		* 1.c.2. RETIREMENT/PENSIONS
		
			* Jubilaciones/Pensiones (locales), segun si recibieron en el ultimo MES
				gen		recibe_ingresopenjub_mes = .
				replace	recibe_ingresopenjub_mes = 1 if (inla_pens_soi==1 | inla_pens_vss==1 | inla_jubi_emp==1	| inla_petro==1) // Recibió pensión/jubilación en algún concepto en el último mes
				replace recibe_ingresopenjub_mes = 0 if (inla_pens_soi==0 & inla_pens_vss==0 & inla_jubi_emp==0 & inla_petro==0) // No recibió pensión/jubilación en ningún concepto mensual
				* Problem: income from abroad (s9q29a_3 to _9) are measured on a yearly basis, not monthly as the others.
			
			*Ingreso no laboral monetario (proveniente del exterior), segun si recibieron en el ultimo AÑO
				* Thus, analysis on the side for imputation for those 3 variables, create a new variables
				gen recibe_ingresopenjub_ano = .
				replace recibe_ingresopenjub_ano = 1 if iext_penjub==1
				replace recibe_ingresopenjub_ano = 0 if iext_penjub==0
			
			* Checks (data April 10)
			tab recibe_ingresopenjub_ano recibe_ingresopenjub_mes, mi
			tab labor_status recibe_ingresopenjub_mes, mi // all over different labor_status, thats okay
			tab labor_status recibe_ingresopenjub_ano, mi // all over different labor_status, thats okay
			
			gen recibe_ingresopenjub = .
			replace recibe_ingresopenjub = 0 if recibe_ingresopenjub_mes==0 & recibe_ingresopenjub_ano==0
			replace recibe_ingresopenjub = 1 if recibe_ingresopenjub_mes==1
			replace recibe_ingresopenjub = 2 if recibe_ingresopenjub_ano==1
			replace recibe_ingresopenjub = 3 if recibe_ingresopenjub_mes==1 & recibe_ingresopenjub_ano==1
				label def recibe_ingresopenjub 0 "Dice que no recibe nada" 1 "Dice que recibio en el ultimo mes" 2 "Dice que recibio en el último año" 3 "Dice que en el último mes Y último año"
				label values recibe_ingresopenjub recibe_ingresopenjub
			
			tab recibe_ingresopenjub, mi 

				* Crossed with the amount of income
				egen ijubi_aux = rsum(s9q28a_1_bolfeb s9q28a_2_bolfeb s9q28a_3_bolfeb ijubi_mpe_bolfeb s9q29b_5_bolfeb), mi
				gen report_pensjub_nocuanto = .
				replace report_pensjub_nocuanto = 1 	if inlist(recibe_ingresopenjub,1,2,3) & ijubi_aux==. // Dicen que reciben jubi/pens, pero no reportan cuánto
				replace report_pensjub_nocuanto = 0 	if inlist(recibe_ingresopenjub,1,2,3) & ijubi_aux>=0 & inla_aux!=.
				*replace report_ingnolab_nocuanto = 0 	if ijubi_aux>=0 & ijubi_aux!=. // Same result as above line
					label def report_pensjub_nocuanto 			1 "No reportan cuánto, pero dicen que reciben jubi/pen" 0 "Reportan cuánto"
					label values report_pensjub_nocuanto report_pensjub_nocuanto
			
			* Conclusion:
			tab report_pensjub_nocuanto, mi // We should impute 17 obs. that declare to have received non labor income but don't say how much

			
*** 2. Dicen que trabajan pero después missing si cobran ila, y el monto // Person occupied but doesn't report if receives labor income (nor amount)
			
	* Ingreso
	gen ila_dummy=.
	replace ila_dummy=1 if ila>0 & ila!=. & ila!=.a // reports income amount
	replace ila_dummy=0 if ila==0 // real zero
	tab ila_dummy ocupado, mi // In 4,745 cases people say they are employed but do not report any labor income, however they might be answering they don't earn any
		*Check:
		gen recibe_ingresolab = 1 if (inlist(recibe_ingresolab_mon,1,2,3) | recibe_ingresolab_nomon==1)
		tab ila_dummy recibe_ingresolab, mi // OK: no hay casos donde reporten un monto de ingresos pero no reportaron recibir ingreso
	
	* No responde si gana ingreso laboral
	gen 	norta_sirecibeila = .
	replace norta_sirecibeila = 1 if (recibe_ingresolab_mon==. & recibe_ingresolab_nomon==.) 
	replace norta_sirecibeila = 1 if (recibe_ingresolab_mon == 0 & recibe_ingresolab_nomon==.) 
	replace norta_sirecibeila = 1 if (recibe_ingresolab_mon == . & recibe_ingresolab_nomon==0)
		// Dejamos afuera (.) casos donde contestan que no ganan ila monetario ni no monetario (ambos ==0), y casos donde dicen que ganan pero no reportan cuánto (alguno ==1, ya contemplado en 1.a y 1.b)
	
	*Identifico valores a imputar
	gen 	ocup_norta_sirecibeila = .
	*replace ocup_noreportaila = 0 if inlist(ila_dummy,1,0) & ocupado==1
	replace ocup_norta_sirecibeila = 1 if ila_dummy==. & ocupado==1 & norta_sirecibeila == 1
		label def ocup_norta_sirecibeila 	1 "No contestan si ganan ila, pero ocupados" 
		label values ocup_norta_sirecibeila ocup_norta_sirecibeila
		
		*Checking overlap:
		tab report_inglabmon_nocuanto ocup_norta_sirecibeila, mi // No cases overlap
		tab report_inglabnomon_nocuanto ocup_norta_sirecibeila, mi // No cases overlap

	* Conclusión:
	tab ocup_norta_sirecibeila, mi // We should impute 3724 obs. that declare they are occupied but don't report if receive labor income (nor amount)

	
	 
*** 3. Dicen que son jubilados o pensionados pero después missing si cobran jubilación/pensión, y el monto // Person retired/pensioned (inactive) but doesn't report if receives retirement/pension (nor amount)
	
	* Jubilado
	gen jubi_pens = .
	replace jubi_pens = 1 if actividades_inactivos==6
	replace jubi_pens = 0 if (ocupado==1 | busco_trabajo==1 | empezo_negocio==1 | inlist(actividades_inactivos,1,2,3,4,7,8,9,10,11) | edad<10)
	tab jubi_pens, mi
	label def jubi_pens 		1 "Jubilado o Pensionado" 0 "No jubilado o pensionado"
	label values jubi_pens jubi_pens // solo 14 missing
	
	* Monto jubi/pens
	gen ijubpen_dummy=.
	replace ijubpen_dummy=1 if ijubi_aux>0 & ijubi_aux!=. & ijubi_aux!=.a // reports retirement/pension amount
	replace ijubpen_dummy=0 if ijubi_aux==0 // Real zero 

	* Identifico valores a imputar
	gen jubi_norta_sirecibejubi = 1 if ijubpen_dummy==. & jubi_pens==1 & recibe_ingresopenjub==.
		// Dejamos afuera casos donde contestan que no ganan jubi/pen (recibe_ingresopenjub==0) y casos donde dicen que ganan pero no reportan cuanto (recibe_ingresopenjub==1, ya contemplado en 1.c.2)
	label def jubi_norta_sirecibejubi 	1 "No contestan si ganan jubi/pen, pero jubilado/pensionado" 
		label values jubi_norta_sirecibejubi jubi_norta_sirecibejubi
	
		*Check:
		tab jubi_norta_sirecibejubi report_pensjub_nocuanto, mi // No hay overlap
		
	*Conclusion:
	tab jubi_norta_sirecibejubi, mi // We should impute 18 cases of people who say are retired/pensioned but do not report any $
		
		
// *** Summary observations to impute ***//
	
		* Assumption: if no answer about receiving ila monetary and non-monetary, we will only impute monetary 
		egen aimputar_ila_mon = rowtotal(report_inglabmon_nocuanto ocup_norta_sirecibeila), mi
		replace aimputar_ila_mon = 1 if aimputar_ila_mon>0 & aimputar_ila_mon!=.

		egen aimputar_jubipen = rowtotal(report_pensjub_nocuanto jubi_norta_sirecibejubi), mi
		replace aimputar_jubipen = 1 if aimputar_jubipen>0 & aimputar_jubipen!=.

quietly foreach i of varlist report_inglabmon_nocuanto report_inglabnomon_nocuanto report_ingnolab_nocuanto report_pensjub_nocuanto ocup_norta_sirecibeila jubi_norta_sirecibejubi aimputar_ila_mon {
		sum `i' if `i'==1
		local `i' = r(N)
		}

	* Monetary ila - Adding "report_inglabmon_nocuanto" y "ocup_norta_sirecibeila"
		display `report_inglabmon_nocuanto'
		display `ocup_norta_sirecibeila' 
		display `aimputar_ila_mon'
		*Universo:
		gen ocup_o_rtarecibenilamon = 1 if (inlist(recibe_ingresolab_mon,1,2,3) | ocupado==1 )
	
	* Non-monetary ila (no jubi)
	display `report_inglabnomon_nocuanto'
	
	* Non-labor income
	display `report_ingnolab_nocuanto'
	
	* Retirement and pensions
	display `report_pensjub_nocuanto'
	display `jubi_norta_sirecibejubi' 
	display `aimputar_jubipen'
		*Universo:
		gen jubi_o_rtarecibejubi = 1 if (recibe_ingresopenjub==1 | jubi_pens==1)

/*	
//*** Descriptive Stats ***//

	foreach i of varlist 	report_inglabmon_nocuanto report_inglabnomon_nocuanto report_ingnolab_nocuanto report_pensjub_nocuanto ocup_norta_sirecibeila jubi_norta_sirecibejubi aimputar_ila_mon {
		tablecol region `i', rowpct // nofreq
		tablecol tarea `i', rowpct // nofreq
		tablecol sector_encuesta `i', rowpct // nofreq
		tablecol categ_ocu `i', rowpct // nofreq
	}
*/



** NO PUDE HACER EL EXCEL BIEN!

//*** Trini's Notation ***//

	clonevar linc_m = ingresoslab_mon // value labor income (monetary)
	clonevar linc_nm = ingresoslab_bene // value of labor income (non monetary)
	clonevar linc = ila // value labor income
	clonevar dlinc = ila_dummy
	clonevar jubpen = ijubi_aux
	clonevar djubpen = ijubpen_dummy
	
* Missing values - modificado para 2019
	* Ila monetario:
	gen dlinc_zero=(ila==0 | recibe_ingresolab_mon==0)
		label def dlinc_zero 1 "Real zeros (answered 0 or said didn't receive ila)"
		label values dlinc_zero dlinc_zero
	gen dlinc_miss1=(ocup_norta_sirecibeila==1)
		label def dlinc_miss1 1 "Occupied, but didn't answer if received ila"
		label values dlinc_miss1 dlinc_miss1
	gen dlinc_miss2=(report_inglabmon_nocuanto==1) 
		label def dlinc_miss2 1 "Said received monetary ila, but amount missing"
		label values dlinc_miss2 dlinc_miss2
	gen dlinc_miss3=(aimputar_ila_mon==1)
		label def dlinc_miss3 1 "Total missing (sum both cases)"
		label values dlinc_miss3 dlinc_miss3
	* Pensions:
	gen djubpen_zero=(ila==0 | recibe_ingresopenjub==0)
		label def djubpen_zero 1 "Real zeros (answered 0 or said didn't receive pension)"
		label values djubpen_zero djubpen_zero
	gen djubpen_miss1=(jubi_norta_sirecibejubi==1)
		label def djubpen_miss1 1 "Jubilado/Pensionado, but didn't answer if received pension"
		label values djubpen_miss1 djubpen_miss1
	gen djubpen_miss2=(report_pensjub_nocuanto==1) 
		label def djubpen_miss2 1 "Said received pension, but amount missing"
		label values djubpen_miss2 djubpen_miss2
	gen djubpen_miss3=(aimputar_jubipen==1)
		label def djubpen_miss3 1 "Total missing (sum both cases)"
		label values djubpen_miss3 djubpen_miss3
	
	/*
	sum dlinc_zero if dlinc_zero==1
	sum dlinc_miss1 if dlinc_miss1==1
	sum dlinc_miss2 if dlinc_miss2==1
	sum dlinc_miss3 if dlinc_miss3==1
	*/


********************************************************************************
*** Counting missing values and real zeros in 2019
********************************************************************************

*** Labor income

foreach x in linc{
** Real zeros (answered 0 or said didn't receive income)
sum d`x'_zero
local a0=r(sum)
** Missing values: Occupied, but didn't answer if received ila
sum d`x'_miss1
local a1=r(sum)
** Missing values: said received monetary ila, but amount missing
sum d`x'_miss2
local a2=r(sum)
** Missing values: Total missing (sum both cases)
sum d`x'_miss3
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & dlinc==1
local a4=r(N)
** Total employed, or receive ila mon
sum ocup_o_rtarecibenilamon  if ocup_o_rtarecibenilamon==1
local a5=r(N)
*Creating matrix
	matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
	*Percentage
	matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
	matrix a=nullmat(a), aux1, aux2
}

*** Pensions
local i=1
foreach x in jubpen {
** Zeros (answered 0 or said didn't receive pension)
sum d`x'_zero
local a0=r(sum)
** Missing values: Those who replied they do not know if they received pensions
sum d`x'_miss1
local a1=r(sum)
** Missing values: Those who replied they received pensions but they did not declare the amount
sum d`x'_miss2
local a2=r(sum)
** Total missing values
sum d`x'_miss3
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & djubpen==1
local a4=r(N)
** All pensioners and retired, or receive pension/retirement ben.
sum jubi_o_rtarecibejubi if jubi_o_rtarecibejubi==1
local a5=r(N)
matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
matrix a`i'=nullmat(a`i'), aux1, aux2
}

local row=4
putexcel set "$pathoutexcel\VEN_income_imputation_2019_MA.xlsx", sheet("missing_values") modify
putexcel B`row'=matrix(a)
local row= `row' + rowsof(a)+4
putexcel B`row'=matrix(a1)
local row= `row' + rowsof(a1)+4

matrix drop aux1 aux2 a a1


*****************************************************************
*** POSSIBLE VARIABLES FOR REGRESSION 
*****************************************************************

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
	
	*Juntamos la razón por la cual dejo estudios y si asiste (para cubrir a casi todos)
	clonevar asiste_o_dejoypq = razon_dejo_est_comp
	replace asiste_o_dejoypq = 0 if asiste==1
		*Al final no porque asiste solo está para edad escolar
	
	*Comparable con años anteriores (opción 6 no afiliado)
	clonevar afiliado_segsalud_comp = afiliado_segsalud
	replace afiliado_segsalud_comp = 6 if seguro_salud==0
	
	/*Checking the bancarization variables
	egen bancarization = rowtotal(cuenta_corr cuenta_aho tcredito tdebito)
	tab bancarization no_banco
	*/
	
	foreach i of varlist tipo_vivienda material_piso tipo_sanitario_comp propieta auto anio_auto heladera lavarropas computadora internet televisor calentador aire tv_cable microondas {
		bys id: egen `i'_hh=max(`i') // para asegurar que todos en el hogar tengan lo mismo, no solo el jefe
	}
	
	gen total_hrtr = hstr_ppal 
	replace total_hrtr = hstr_todos if hstr_todos!=. // los que tienen dos trabajos

	global vars_mineq 	edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
					tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh anio_auto_hh heladera_hh lavarropas_hh	computadora_hh internet_hh televisor_hh calentador_hh aire_hh	tv_cable_hh	microondas_hh  ///
					seguro_salud afiliado_segsalud_comp /*quien_pagosegsalud*/ ///
					nivel_educ asiste_o_dejoypq ///
					tarea sector_encuesta categ_ocu total_hrtr ///
					c_sso c_rpv c_spf c_aca c_sps c_otro ///
					cuenta_corr cuenta_aho tcredito tdebito no_banco ///
					aporte_pension clap ingsuf_comida comida_trueque
		
		* Copio variables para que no tengan missing (missing una variables más)

		foreach i of global vars_mineq {
			sum `i'
			clonevar `i'_sinmis = `i'
			replace `i'_sinmis = r(max) + 1 if `i'==.
	}
	
	*br if (edad_sinmis==. |	hombre_sinmis==. |	relacion_comp_sinmis==. |	miembros_sinmis==. |	estado_civil_sinmis==. |	region_est1_sinmis==. |	municipio_sinmis==. |	tipo_vivienda_sinmis==. |	propieta_sinmis==. |	auto_sinmis==. |	anio_auto_sinmis==. |	heladera_sinmis==. |	lavarropas_sinmis==. |	computadora_sinmis==. |	internet_sinmis==. |	televisor_sinmis==. |	calentador_sinmis==. |	aire_sinmis==. |	tv_cable_sinmis==. |	microondas_sinmis==. |	seguro_salud_sinmis==. |	nivel_educ_sinmis==. |	tarea_sinmis==. |	sector_encuesta_sinmis==. |	categ_ocu_sinmis==. |	hstr_todos_sinmis==. |	aporte_pension_sinmis==. |	clap_sinmis==. )
		* Check: Da ok, ninguna con missing
	
	global vars_mineq_sinmis 	edad_sinmis	edad2_sinmis  agegroup_sinmis hombre_sinmis relacion_comp_sinmis miembros_sinmis estado_civil_sinmis region_est1_sinmis municipio_sinmis 	///
								tipo_vivienda_hh_sinmis propieta_hh_sinmis auto_hh_sinmis anio_auto_hh_sinmis heladera_hh_sinmis lavarropas_hh_sinmis computadora_hh_sinmis	internet_hh_sinmis televisor_hh_sinmis calentador_hh_sinmis aire_hh_sinmis tv_cable_hh_sinmis microondas_hh_sinmis ///
								seguro_salud_sinmis afiliado_segsalud_comp_sinmis /*quien_pagosegsalud_sinmis*/ ///
								nivel_educ_sinmis asiste_o_dejoypq_sinmis ///
								tarea_sinmis sector_encuesta_sinmis categ_ocu_sinmis total_hrtr_sinmis ///
								c_sso_sinmis c_rpv_sinmis c_spf_sinmis c_aca_sinmis c_sps_sinmis c_otro_sinmis ///
								cuenta_corr_sinmis cuenta_aho_sinmis tcredito_sinmis tdebito_sinmis no_banco_sinmis ///
								aporte_pension_sinmis clap_sinmis ingsuf_comida_sinmis comida_trueque_sinmis

* Equations:
	* Ingreso laboral montario - hacerlo por categ. ocup?
	* Ingreso laboral no monetario (no jubilación)
	* Ingreso no laboral
	* Jubilación/Pensión
	
save "$pathout\ENCOVI_forimputation_2019.dta", replace
