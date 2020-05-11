*INCOME ANALYSIS

	clear all
/*
	use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned\ENCOVI_2019_pre pobreza.dta"

	tab tenencia_vivienda_comp if relacion_en==1, mi
	tab propieta_no_paga if relacion_en==1, mi
	stop

	gen part_ilf = ilf/itf
	gen part_inlaf = inlaf/itf
	gen part_rentaimp= renta_imp/itf

	sum part_ilf [w=pondera] if d_renta_imp_b==1
	sum part_inlaf [w=pondera] if d_renta_imp_b==1
	sum part_rentaimp [w=pondera] if d_renta_imp_b==1

	sum part_ilf [w=pondera] if d_renta_imp_b!=1
	sum part_inlaf [w=pondera] if d_renta_imp_b!=1
	sum part_rentaimp [w=pondera] if d_renta_imp_b!=1

	tab propieta_no_paga if relacion_en==1, mi

stop
*/

**********************

use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\ENCOVI_2019_Spanish labels.dta"

* Cómo se compone el ingreso total familiar?
	gen part_ilf = .
	replace part_ilf=ilf/itf if itf!=.
	replace part_ilf = 0 if ilf==. | ilf==0
	replace part_ilf =. if itf==0
	
	gen part_inlaf = .
	replace part_inlaf=inlaf/itf if itf!=.  & itf!=0
	replace part_inlaf = 0 if inlaf==. | inlaf==0
	replace part_inlaf =. if itf==0
	
	gen part_rentaimp= .
	replace part_rentaimp=renta_imp/itf if itf!=. & itf!=0
	replace part_rentaimp = 0 if renta_imp==. | renta_imp==0
	replace part_rentaimp =. if itf==0
	
	*gen partitf = part_ilf + part_inlaf + part_rentaimp
	*br itf itf_sin_ri part_ilf part_inlaf part_rentaimp if partitf>1.05 | partitf<0.95

	sum renta_imp
	*Solo 10 obs. no tienen nada porque no tenían ingreso. el resto que no tienen dato acá son los que (tenencia_vivienda==1 | tenencia_vivienda==6 | tenencia_vivienda==7 | tenencia_vivienda==8 | tenencia_vivienda==9 | tenencia_vivienda==10)

	sum part_ilf [w=pondera] if hogarsec==0 & part_ilf!=.
	sum part_inlaf [w=pondera] if hogarsec==0 & part_inlaf!=.
	sum part_rentaimp [w=pondera] if hogarsec==0 & part_rentaimp!=.

	
* Cuántas hh reciben/responden cada inla?
	
	global recibeninlalocal pens_soi pens_vss jubi_emp pens_dsa beca_pub beca_pri ayuda_pu ayuda_pr ayuda_fa asig_men otros
	global recibeninlaext indemn remesa penjub intdiv becaes extrao alquil

			/*
			sort id, stable
			foreach i of $inla {	
			bys id: egen hhrecibe`i' = max(`i') if (`i'!=. & s9q19__`i'!=.a)
			tab hhrecibe`i' if jefe==1
			}
			*/
			
			sort id, stable
			foreach i of global recibeninlalocal {		
			by id: egen hhrecibeinla_`i' = max(inla_`i') if (inla_`i'!=.)
			tab hhrecibeinla_`i' [w=pondera] if relacion_en==1, mi
			}
			
			sort id, stable
			foreach i of global recibeninlaext {
			by id: egen hhrecibeiext_`i' = max(iext_`i') if (iext_`i'!=.)
			tab hhrecibeiext_`i' [w=pondera] if relacion_en==1, mi
			}
			
			sort id, stable
			by id: egen aux_hhrecibeinla = max(inla) if (inla!=.)
			gen hhrecibeinla = 0
			replace hhrecibeinla = 1 if aux_hhrecibeinla>0 & aux_hhrecibeinla!=.
			tab hhrecibeinla [w=pondera] if relacion_en==1, mi

			
* Qué % del ingreso individual es cada componente del inla?

	global inlas ijubi_m icap_m rem itranp_o_m itranp_ns itrane_o_m itrane_ns inla_extraord inla_otro
	
	sort id, stable

	foreach i of global inlas {		
			
	gen part_`i'_eninla= .
	replace part_`i'_eninla=`i'/inla if inla!=. & inla!=0
	replace part_`i'_eninla = 0 if `i'==. | `i'==0
	replace part_`i'_eninla =. if inla==0
	
	sum part_`i'_eninla [w=pondera] if part_`i'_eninla!=. & inla!=.
	}
	
	gen part_eninla = part_ijubi_m_eninla + part_icap_m_eninla + part_rem_eninla + part_itranp_o_m_eninla + part_itranp_ns_eninla + part_itrane_o_m_eninla + part_itrane_ns_eninla + part_inla_extraord_eninla + part_inla_otro_eninla
	*br inla ijubi_m icap_m rem itranp_o_m itranp_ns itrane_o_m itrane_ns inla_extraord inla_otro if inla!=. & (part_eninla>1.05 | part_eninla<0.95)

/// Tenencia vivienda ///

tab tenencia_vivienda if relacion_en==1, mi


/// Poverty analysis ///

* One side

	*Todos
	tab pobre_extremo [w=pondera] if ocupado==1, mi
	
	*Sector
	tablecol sector pobre_extremo [w=pondera] if ocupado==1, rowpct nofreq mi
			
	*Región
	tablecol region_est1 pobre_extremo [w=pondera], rowpct nofreq mi
			
	*Grupos de edad
		gen agegroup=1 if edad<=14 & edad!=.
		replace agegroup=2 if edad>=15 & edad<=24 & edad!=.
		replace agegroup=3 if edad>=25 & edad<=34 & edad!=.
		replace agegroup=4 if edad>=35 & edad<=44 & edad!=.
		replace agegroup=5 if edad>=45 & edad<=54 & edad!=.
		replace agegroup=6 if edad>=55 & edad<=64 & edad!=.
		replace agegroup=7 if edad>=65 & edad!=.
		label def agegroup 1 "[0-14]" 2 "[15-24]" 3 "[25-34]" 4 "[35-44]" 5 "[45-54]" 6 "[55-64]" 7 "[65+]"
		label value agegroup agegroup
	tablecol agegroup pobre_extremo [w=pondera], rowpct nofreq mi
	
	*Sexo
	tablecol hombre pobre_extremo [w=pondera], rowpct nofreq mi
	
	*Nivel educativo del jefe
	sort id relacion_en, stable
	gen nivel_educ_jefe=.
	by id: replace nivel_educ_jefe = nivel_educ[1] if relacion_en!=13 // Les pongo a todos los de la casa el valor del jefe
	
	bys nivel_educ: sum pobre_extremo [w=pondera]
	
* The other side
	tablecol sector pobre_extremo [w=pondera] if ocupado==1, colpct nofreq mi
	tablecol region_est1 pobre_extremo [w=pondera], colpct nofreq mi
	tablecol agegroup pobre_extremo [w=pondera], colpct nofreq mi
	tablecol hombre pobre_extremo [w=pondera], colpct nofreq mi
	tablecol nivel_educ_jefe pobre_extremo [w=pondera], colpct nofreq mi
	
stop
