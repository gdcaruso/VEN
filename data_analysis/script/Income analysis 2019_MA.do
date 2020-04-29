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
	gen part_ilf = ilf/itf
	gen part_inlaf = inlaf/itf
	gen part_rentaimp= renta_imp/itf

	sum renta_imp

	sum part_ilf [w=pondera] 
	sum part_inlaf [w=pondera] 
	sum part_rentaimp [w=pondera] 

* inla
	/*
	ijubi_m
	icap_m
	rem
	itranp_o_m
	itranp_ns
	itrane_o_m
	itrane_ns
	inla_extraord
	inla_otro
	*/
	
* Poverty analisis

	*Todos
	tablecol pobre_extremo [w=pondera] if ocupado==1, rowpct nofreq mi
	
	*Sector
	tablecol sector pobre_extremo [w=pondera] if ocupado==1, rowpct nofreq mi
			
	*Departamento
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
	
stop
