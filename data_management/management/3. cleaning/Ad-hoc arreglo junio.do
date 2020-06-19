/*===========================================================================
Country name:	Venezuela
Year:			2019/2020
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		June, 2020
Modification Date:  
Output:				Arreglar deseamashs, buscamashs, djubila y dsegsale (SEDLAC), variables part-time y antropometría (ENCOVI), y ingresos=0 donde corresponde (SEDLAC y ENCOVI)

Note: 
=============================================================================*/
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	Open Databases  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 
*Generate unique household identifier by strata
use "$merged\household.dta", clear
tempfile household_hhid
sort combined_id, stable // Instead of "bysort", to make sure we keep order
by combined_id: gen hh_by_combined_id = _n
save `household_hhid'

* Open "output" database
use "$merged\individual.dta", clear
merge m:1 interview__key interview__id quest using `household_hhid'
drop _merge
* Dropping those who do not collaborate in the survey
drop if colabora_entrevista==2
rename _all, lower

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1. ENCOVI - PART TIME VARIABLES FIX ----------------------------------------------------
*************************************************************************************************************************************************)*/ 

gen razon_menoshs2 = s9q30 if (s9q18<35 | s9q16<35) & (s9q30!=. & s9q30!=.a) 
gen	razon_menoshs_o2 = s9q30_os if (s9q18<35 | s9q16<35) & s9q30==6
gen deseamashs2 = s9q31==1 if (s9q18<35 | s9q16<35) & (s9q31!=. & s9q31!=.a)
gen	buscamashs2 = s9q32==1 if (s9q18<35 | s9q16<35) & (s9q32!=. & s9q32!=.a)
gen razon_nobusca2 = s9q33 if (s9q18<35 | s9q16<35) & (s9q33!=. & s9q33!=.a)
gen razon_nobusca_o2 = s9q33_os if (s9q18<35 | s9q16<35) & s9q33==11

preserve

keep razon_menoshs2 razon_menoshs_o2 deseamashs2 buscamashs2 razon_nobusca2 razon_nobusca_o2 interview__key interview__id quest miembro__id
save "$cleaned\adhocfixesENCOVIparttime.dta", replace

restore

/*(************************************************************************************************************************************************* 
*----------------------------------------------------------- 2. SEDLAC - LABOR VARIABLES FIX ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 

* Deseo o busqueda de otro trabajo o mas horas: deseamas (el trabajador ocupado manifiesta el deseo de trabajar mas horas y/o cambiar de empleo (proxy de inconformidad con su estado ocupacional actual)
	/* DESEAMASHS (s9q31): ¿Preferiria trabajar mas de 35 horas por semana?
	   BUSCAMASHS (s9q32): ¿Ha hecho algo parar trabajar mas horas?
	   CAMBIOTR (s9q34): ¿Ha cambiado de trabajo durante los últimos meses?
	*/
cap gen deseamashs2 = s9q31 if (s9q18<35 | s9q16<35) & (s9q31!=. & s9q31!=.a) // Only asked if capi4==true, i.e. s9q18<35 or s9q16<35, worked less than 35 hs -> worked part-time
cap gen buscamashs2 = s9q32 if (s9q18<35 | s9q16<35) & (s9q32!=. & s9q32!=.a) // Only asked if capi4==true, i.e. s9q18<35 or s9q16<35, worked less than 35 hs -> worked part-time
	*Assumption: only part-time workers can want to work more

	
	*AUXILIAR 
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
					1 = Empleado u obrero en el sector publico
					3 = Empleado u obrero en empresa privada
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
	
				* Tipo de seguro de salud: tipo_seguro
				/*  0 = esta afiliado a algun seguro de salud publico o vinculado al trabajo (obra social)
					1 = si esta afiliado a algun seguro de salud privado
				*/
				/* s8q18: ¿Con cuál seguro médico está afiliado? 
					1 = Instituto Venezolano de los Seguros Sociales (IVSS)
					2 = Instituto de prevision social publico (IPASME, IPSFA, otros)
					3 = Seguro medico contratado por institucion publica
					4 = Seguro medico contratado por institucion privada
					5 = Seguro medico privado contratado de forma particular
				 */
				gen afiliado_segsalud = 1     if s8q18==1 
				replace afiliado_segsalud = 2 if s8q18==2 
				replace afiliado_segsalud = 3 if s8q18==3 
				replace afiliado_segsalud = 4 if s8q18==4
				replace afiliado_segsalud = 5 if s8q18==5
				replace afiliado_segsalud = 6 if s8q17==2
				
				*Seguro social obligatorio
				clonevar    c_sso 		= s9q20__1 if inlist(s9q15,1,2,3,4,7,8,9) & (s9q20__1!=. & s9q20__1!=.a) 
				
				*** Do you make contributions to any pension fund?
				/* s9q36 ¿Realiza aportes para algún fondo de pensiones?	
							1 = si
							2 = no	*/
				gen		aporta_pension = s9q36==1 if (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & (s9q36!=. & s9q36!=.a)

* Right to receive retirement benefits: djubila
	/*APORTE_PENSION (created using s9q36 & s9q37__* to match previous ENCOVIs)
			1 = Si, para el IVSS
			2 = Si, para otra institucion o empresa publica
			3 = Si, para institucion o empresa privada
			4 = Si, para otra
			5 = No
	*/
*gen     djubila2 = (s9q36==1) if relab==2 & (s9q1==1 | s9q2==1 | s9q2==2 | s9q3==1 | s9q5==1) & s9q36!=. & s9q36!=.a  //the last parenthesis means means being economically active

gen djubila2	=0 & relab==2 & ((aporta_pension!=. & aporta_pension!=.a) | (c_sso!=. & c_sso!=.a))
replace djubila2=1 if c_sso==1 & relab==2
replace djubila2=1 if aporta_pension==1 & relab==2
	
	
* Health insurance linked to employment: dsegsale
gen     dsegsale2 = (afiliado_segsalud==3 | afiliado_segsalud==4) if relab==2 & afiliado_segsalud!=.

preserve
keep deseamashs2 buscamashs2 djubila2 dsegsale2 interview__key interview__id quest miembro__id
save "$cleaned\adhocfixesSEDLAC.dta", replace
restore

/*(************************************************************************************************************************************************* 
*----------------------------------------------------------- 3. ENCOVI - Add some antropometric variables  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 

keep interview__key interview__id miembro__id posicion

recode posicion (.a = .)
recode posicion (.b = .)

label def posmeasure 1 "Standing" 2 "Recumbent"
label values posicion

save "$cleaned\antropofixesENCOVI.dta", replace

/*(************************************************************************************************************************************************* 
*----------------------------------------- 4. SEDLAC Y ENCOVI - ILA_M, WAGE_M 0 (INSTEAD OF MISSING) FIX -------------------------------------------
*************************************************************************************************************************************************)*/ 

use "$output\ENCOVI_2019_postpobreza.dta", clear

		rename ingresoslab_bene ila_nm
		
*ila
	replace ila_m = 0 		if recibe_ingresolab_mon==0
	replace ila_nm = 0 		if recibe_ingresolab_nomon==0
	replace ila = 0 		if recibe_ingresolab_mon==0 & recibe_ingresolab_nomon==0 & categ_ocu!=6
	replace ila = 0 		if recibe_ingresolab_mon==0 & categ_ocu==6
	
*inla
	replace inla_m = 0		if recibe_ingresonolab==0 & recibe_ingresopenjub==0
	replace inla = 0 		if recibe_ingresonolab==0 & recibe_ingresopenjub==0 // because there is no non-monetary
	replace ijubi_m = 0 	if recibe_ingresopenjub==0
	replace ijubi = 0 		if recibe_ingresopenjub==0 // because there is no non-monetary

* sedlac income variables	
	
		* Monetario
		egen ii2 = rsum(ila inla), missing
		* No Monetario
		egen ii_m2 = rsum(ila_m inla_m), missing

		* Ingreso laboral familiar 
		egen ilf_m2 = sum(ila_m)		if  hogarsec==0, by(id)
		egen ilf2   = sum(ila)		if  hogarsec==0, by(id)

		* Ingreso no laboral familiar
		egen inlaf_m2 = sum(inla_m)	if  hogarsec==0, by(id)
		egen inlaf2   = sum(inla)	if  hogarsec==0, by(id)

		* Ingreso familiar total - monetario
		egen itf_m2 = sum(ii_m2)		if  hogarsec==0, by(id)

		* Ingreso familiar total (antes de renta imputada)
		egen itf_sin_ri2 = sum(ii2)	if  hogarsec==0, by(id)

		* Ingreso familiar total - total
		egen    itf2 = rsum(itf_sin_ri2 renta_imp) 
		replace itf2 = .		if  itf_sin_ri2==.

		* Coherente a nivel individual
			gen     cohi2 = 1

			* Trabajadores ocupados, con el ingresos laboral de la ocupación principal missing
			replace cohi2 = 800		if            ocupado==1 & ip==.  & relab!=4

			* Trabajadores ocupados, con todas las fuentes de ingresos laborales missing
			replace cohi2 = 810		if  cohi2==1 & ocupado==1 & ila==. & relab!=4

			* Trabajadores que se identifican como asalariados, con ingresos de trabajo asalariado missing
			replace cohi2 = 811		if  cohi2==1 & relab==2   & iasalp==. 

			* Trabajadores cuentapropistas, con ingresos por cuenta propia missing
			replace cohi2 = 812		if  cohi2==1 & relab==3   & ictap==. 

			* Patrones con ingresos por patrón missing
			replace cohi2 = 813		if  cohi2==1 & relab==1   & ipatrp==. 

			* Otras inconsistencias
			replace cohi2 = 815		if  iasalp!=.  & relab!=2
			replace cohi2 = 816		if  ipatrp!=.  & relab!=1	
			replace cohi2 = 817		if  ictapp!=.  & relab!=3	

		* Coherente a nivel del hogar
			gen cohh2 = 1

			* Familias con jefe con ingreso individual inconsistente
			gen	aux = 0
			replace aux = cohi2		if  cohi2~=1 & relacion==1
			egen    aux2 = sum(aux),	by(id)
			replace cohh2 = aux2		if  cohh2==1 & aux2>0
			drop aux aux2

			* Familias con Único Ocupado (no Jefe) con Ingreso Individual Inconsistente
			egen  aux = sum(ocupado),	by(id)
			gen unico2 = 1			if  ocupado==aux & ocupado==1
			drop aux
			gen   aux = cohi2		if  cohi2~=1 & unico2==1
			egen aux2 = sum(aux),		by(id)
			replace cohh2 = 801		if  cohh2==1 & aux2>0 & aux2<.
			drop aux aux2

			* Familias con Jefe no Ocupado y Ocupado con Mayor Nivel Educativo Inconsistente

			* Identifica Hogar con Jefe Ocupado
			gen   aux_ocu2 = 1		if  relacion==1 & ocupado==1
			egen jefe_ocu2 = max(aux_ocu2),	by(id)

			* Identifica Miembro (no Jefe) de Mayor Educación Incoherente
			egen    max_edu2 = max(nivel),	by(id)
			gen     edu_max2 = 1		if  max_edu2==nivel & ocupado==1
			replace edu_max2 = .		if  cohi==1
			replace edu_max2 = .		if  relacion==1
			replace edu_max2 = .		if  jefe_ocu2==1

			gen     aux = 0
			replace aux = cohi2		if  edu_max2==1
			egen    aux2 = sum(aux),	by(id)
			replace cohh2 = 802		if  cohh2==1 & aux2>0 & aux2<.
			drop aux aux2

			* Familias con ingresos laborales totales negativos o invalidados
			replace cohh2 = 902		if  cohh2==1 & ilf<0
			
			* Familias con ingresos totales negativos o invalidados
			replace cohh2 = 903		if  cohh2==1 & itf<0

foreach i in ila_m ila_nm ila inla_m inla ijubi_m ijubi {

rename `i' `i'2
}
 
keep recibe_ingresolab_mon interview__key interview__id quest miembro__id ila_m2 ila_nm2 ila2 inla_m2 inla2 ijubi_m2 ijubi2 ii2 ii_m2 ilf_m2 ilf2 inlaf_m2 inlaf2 itf_m2 itf_sin_ri2 itf2 cohi2 cohh2

save "$cleaned\adhocfixes_incomes.dta", replace

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- MERGING TO FINAL DATABASES --------------------------------------------------------------
*************************************************************************************************************************************************)*/ 

* 1)
	foreach x in English Spanish {

	use "$outENCOVI\ENCOVI_2019_`x' labels.dta", replace
	cap drop _merge
	merge 1:1 interview__id interview__key miembro__id using "$cleaned\adhocfixesENCOVIparttime.dta"
	cap drop _merge

	foreach i in razon_menoshs razon_menoshs_o deseamashs buscamashs razon_nobusca razon_nobusca_o {
		replace `i' = `i'2 
		drop `i'2 
	}
	save "$outENCOVI\ENCOVI_2019_`x' labels.dta", replace

	clear 
	}

* 2)

	foreach x in English Spanish {

	use "$outSEDLAC\VEN_2019_ENCOVI_SEDLAC-01_`x' labels.dta", replace
	cap drop _merge
	merge 1:1 interview__id interview__key miembro__id using "$cleaned\adhocfixesSEDLAC.dta"
	cap drop _merge

	foreach i in deseamashs buscamashs djubila dsegsale {
		replace `i' = `i'2 
		drop `i'2 
	}

	save "$outSEDLAC\VEN_2019_ENCOVI_SEDLAC-01_`x' labels.dta", replace

	clear 
	}

* 3)
	foreach i in English Spanish {

	use "$outENCOVI\ENCOVI_2019_`i' labels.dta", replace
	cap drop posicion hfa wfa wfh
	cap drop _merge
	merge 1:1 interview__id interview__key miembro__id using "$cleaned\antropofixesENCOVI.dta"
	cap drop _merge

	save "$outENCOVI\ENCOVI_2019_`i' labels.dta", replace

	clear 
	}

* 4)

	foreach x in English Spanish {

	use "$outSEDLAC\VEN_2019_ENCOVI_SEDLAC-01_`x' labels.dta", replace
	cap drop _merge
	merge 1:1 interview__id interview__key miembro__id using "$cleaned\adhocfixes_incomes.dta"
	cap drop _merge

	foreach i in ila_m ila_nm ila inla_m inla ijubi_m ijubi ii ii_m ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri itf cohi cohh {
		cap replace `i' = `i'2 
		drop `i'2 
	}

	save "$outSEDLAC\VEN_2019_ENCOVI_SEDLAC-01_`x' labels.dta", replace

	clear 
	}

	foreach x in English Spanish {

	use "$outENCOVI\ENCOVI_2019_`x' labels.dta", replace
	cap drop _merge
	merge 1:1 interview__id interview__key miembro__id using "$cleaned\adhocfixes_incomes.dta"
	cap drop _merge

	foreach i in ila_m ila_nm ila inla_m inla ijubi_m ijubi ii ii_m ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri itf cohi cohh  {
		replace `i' = `i'2 
		drop `i'2 
	}

	save "$outENCOVI\ENCOVI_2019_`x' labels.dta", replace

	clear 
	}
	

