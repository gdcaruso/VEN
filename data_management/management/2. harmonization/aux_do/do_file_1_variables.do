
/*=========================================================================================================================================================================
								2: Preparacion de los datos: Variables de segundo orden
==========================================================================================================================================================================*/

	/*
	local segundoorden=0
	* Leo indico este cambio para siguientes versiones que entregue: if (`year'==2017 & `country'!="ECU") local segundoorden=1
	if (`segundoorden'==1) {
	*---------------------------------------------------------------------	1.13: PRECIOS  ------------------------------------------------------------------------------------
	* 2. Ajuste por precios regionales: se ajustan los ingresos rurales por 0.8695
	gen	p_reg = 1
	replace p_reg = 0.8695			if  urbano==0

	foreach i of varlist iasalp_m iasalp_nm  ictapp_m ictapp_nm  ipatrp_m ipatrp_nm  iolp_m iolp_nm  iasalnp_m iasalnp_nm  ictapnp_m ictapnp_nm  ipatrnp_m ipatrnp_nm  iolnp_m iolnp_nm  ijubi_con ijubi_ncon ijubi_o  icap  icct inocct_m inocct_nm itrane_ns  itranext_m itranext_nm itranint_m itranint_nm itranp_ns  inla_otro	{
			replace `i' = `i' / p_reg 
			replace `i' = `i' / ipc_rel 
			}
	}
	*/


/*(************************************************************************************************************************************************************************ 
*-------------------------------------------------------------	2.3: Variables demograficas  ------------------------------------------------------------------------------
************************************************************************************************************************************************************************)*/

* Malena: Lo que se silencio a continuación ya está en nuestro dofile madre

/*
	* Genera grupos de edad
	gen     gedad1 = 1		if  edad<=14
	replace gedad1 = 2		if  edad>=15 & edad<=24
	replace gedad1 = 3		if  edad>=25 & edad<=40
	replace gedad1 = 4		if  edad>=41 & edad<=64
	replace gedad1 = 5		if  edad>=65 & edad~=.

	* Identifica al jefe 
	gen     jefe = 1		if  relacion==1
	replace jefe = 0		if  relacion!=1
	replace jefe = .		if  relacion==. | hogarsec==1

	* Identifica al cónyuge 
	gen     conyuge = 1		if  relacion==2
	replace conyuge = 0		if  relacion!=2
	replace conyuge = .		if  relacion==. | hogarsec==1

	* Identifica a los hijos del hogar principal
	gen     hijo = 1		if  relacion==3 
	replace hijo = 0		if  relacion!=3 
	replace hijo = .		if  relacion==. | hogarsec==1

	* Numero de hijos menores de 18 años en la familia
	gen     aux = 1			if  hijo==1 & edad<=18
	egen    nro_hijos = count(aux), by(id)
	replace nro_hijos = .		if  jefe~=1 & conyuge~=1
	drop aux


/*(************************************************************************************************************************************************************************ 
*-------------------------------------------------------------	2.7: Variables educativas  --------------------------------------------------------------------------------
************************************************************************************************************************************************************************)*/

	* Grupos de años de educación 
	gen       nivedu = 1		if  aedu>=0 & aedu<=8
	replace   nivedu = 2		if  aedu>=9 & aedu<=13
	replace   nivedu = 3		if  aedu>13 & aedu<50
		
		
	* Dummy del nivel educativo 
	gen     prii = 0		if  nivel>=0 & nivel<=6
	replace prii = 1		if  nivel==0 | nivel==1

	gen     pric = 0		if  nivel>=0 & nivel<=6
	replace pric = 1		if  nivel==2

	gen     seci = 0		if  nivel>=0 & nivel<=6
	replace seci = 1		if  nivel==3

	gen     secc = 0		if  nivel>=0 & nivel<=6
	replace secc = 1		if  nivel==4

	gen     supi = 0		if  nivel>=0 & nivel<=6
	replace supi = 1		if  nivel==5

	gen     supc = 0		if  nivel>=0 & nivel<=6
	replace supc = 1		if  nivel==6

	* Experiencia potencial 
	gen     exp = edad-aedu-7
	replace exp = 0			if  exp<0
	
		* Malena: nuestros dofiles hacen exp=edad-aedu-6 porque el manual decía:
			* "Se calcula como la diferencia entre la edad del individuo y sus años de educación formal más 6, 
			* excepto que sepamos con seguridad que la educación primaria en un determinado país o año comienza a una edad distinta de 6." 
	
/*(************************************************************************************************************************************************************************ 
*-------------------------------------------------------------	2.9: Variables laborales  --------------------------------------------------------------------------------
************************************************************************************************************************************************************************)*/

* Asalariado en la ocupación principal 
gen     asal = 1		if  relab==2
replace asal = 0		if  relab==1 | relab==3 | relab==4 

* Grupos de condicion laboral
gen     grupo_lab = 1		if  relab==1 
replace grupo_lab = 2		if  relab==2 & empresa==1
replace grupo_lab = 3		if  relab==2 & empresa==3
replace grupo_lab = 4		if  relab==3 & supc==1 
replace grupo_lab = 5		if  relab==2 & empresa==2 
replace grupo_lab = 6		if  relab==3 & supc~=1 
replace grupo_lab = 7		if  relab==4

* Categorias de condicion laboral
gen     categ_lab = 1		if  grupo_lab>=1 & grupo_lab<=4
replace categ_lab = 2		if  grupo_lab>=5 & grupo_lab<=7

*/	

/*(************************************************************************************************************************************************************************ 
*-------------------------------------------------------------	2.11: Variables de ingresos  ------------------------------------------------------------------------------
************************************************************************************************************************************************************************)*/

******************** INGRESOS LABORALES

******************** INGRESOS EN LA ACTIVIDAD PRINCIPAL 

* Ingreso en la Actividad Principal como Patron
egen    ipatrp = rsum(ipatrp_m ipatrp_nm), missing
replace ipatrp = .		if  ipatrp==0 & relab!=1

* Ingreso en la Actividad Principal como Asalariado
egen    iasalp = rsum(iasalp_m iasalp_nm), missing
replace iasalp = .		if  iasalp==0 & relab!=2

* Ingreso en la Actividad Principal como Cuenta Propia
egen    ictapp = rsum(ictapp_m ictapp_nm), missing
replace ictapp = .		if  ictapp==0 & relab!=3

* Ingreso en la Actividad Principal por relación no especificada
egen    iolp = rsum(iolp_m iolp_nm), missing
replace iolp = .		if  iolp==0

* Ingreso en la Actividad Principal 
egen    ip = rsum(ipatrp iasalp ictapp iolp), missing
replace ip = 0			if  ip<0
replace ip = 0			if  relab==4 & ip==.

egen    ip_m = rsum(ipatrp_m iasalp_m ictapp_m iolp_m), missing
replace ip_m = 0		if  ip_m<0
replace ip_m = 0		if  relab==4 & ip_m==.

* Salario Horario en la Actividad Principal 
gen     wage = ip / (hstrp * 4.3)
replace wage = .		if  wage==0

gen     wage_m = ip_m / (hstrp * 4.3)
replace wage_m = .		if  wage_m==0


***************** INGRESOS EN LA ACTIVIDAD NO PRINCIPAL 
* Ingreso en la Actividad no Principal como Patron
egen    ipatrnp = rsum(ipatrnp_m ipatrnp_nm), missing
replace ipatrnp = .		if  ipatrnp==0

* Ingreso en la Actividad no Principal como Asalariado
egen    iasalnp = rsum(iasalnp_m iasalnp_nm), missing
replace iasalnp = .		if  iasalnp==0

* Ingreso en la Actividad no Principal como Cuenta Propia
egen    ictapnp = rsum(ictapnp_m ictapnp_nm), missing
replace ictapnp = .		if  ictapnp==0

* Otros ingresos laborales
egen    iolnp = rsum(iolnp_m iolnp_nm), missing
replace iolnp = .		if  iolnp==0


* Ingreso en la Actividad no Principal 
egen    inp = rsum(ipatrnp iasalnp ictapnp iolnp), missing
replace inp = .			if  inp==0
replace inp = 0			if  inp<0
*replace inp = 0			if (relab_s==4 | relab_o==4) & inp==.

egen    inp_m = rsum(ipatrnp_m iasalnp_m ictapnp_m iolnp_m), missing
replace inp_m = .		if  inp_m==0
replace inp_m = 0		if  inp_m<0
*replace inp_m = 0		if (relab_s==4 | relab_o==4) & inp_m==.


******************** INGRESOS LABORALES TOTALES
* Ingreso en todas las Actividades como Patron
egen ipatr   = rsum(ipatrp   ipatrnp), missing
egen ipatr_m = rsum(ipatrp_m ipatrnp_m), missing

* Ingreso en todas las Actividad como Asalariado
egen iasal   = rsum(iasalp   iasalnp), missing
egen iasal_m = rsum(iasalp_m iasalnp_m), missing

* Ingreso en todas las Actividad como Cuenta Propia
egen ictap   = rsum(ictapp   ictapnp), missing
egen ictap_m = rsum(ictapp_m ictapnp_m), missing

* Ingreso Laboral Total
egen    ila = rsum(ipatr   iasal   ictap   iolp   iolnp), missing
replace ila = 0			if  ila<0
*replace ila = 0		if  ila==. & relab==4

egen    ila_m = rsum(ipatr_m iasal_m ictap_m iolp_m iolnp_m), missing
replace ila_m = 0		if  ila_m<0	

* Salario Horario en todas las Ocupaciones
gen     ilaho = ila / (hstrt * 4.3)
replace ilaho = .		if  ilaho==0

gen     ilaho_m = ila_m / (hstrt * 4.3)
replace ilaho_m = .		if  ilaho_m==0

* Identifica perceptores de ingresos laborales
gen     perila = 0
replace perila = 1		if  ila>0 & ila~=.



******************** INGRESOS NO LABORALES

* Ingresos por Jubilaciones y Pensiones
egen ijubi = rsum(ijubi_m ijubi_nm), missing

* Ingresos por Capital
egen icap = rsum(icap_m icap_nm), missing

* Ingresos por Transferencias Privadas
egen itranp   = rsum(rem itranp_o_m itranp_o_nm itranp_ns), missing
egen itranp_m = rsum(rem itranp_o_m), missing

* Ingreso por Transferencias Estatales
egen itrane   = rsum(cct itrane_o_m itrane_o_nm itrane_ns), missing
egen itrane_m = rsum(cct itrane_o_m), missing

* Ingresos por Transferencias Totales
egen itran   = rsum(itrane   itranp), missing
egen itran_m = rsum(itrane_m itranp_m), missing

* Ingreso no Laboral Total
egen inla   = rsum(ijubi icap itran   inla_otro), missing 
egen inla_m = rsum(ijubi icap itran_m inla_otro), missing



******************** INGRESOS INDIVIDUALES TOTALES

* Monetario
egen ii = rsum(ila inla), missing

* No Monetario
egen ii_m = rsum(ila_m inla_m), missing

* Identifica perceptores de ingresos 
gen       perii = 0
replace   perii = 1		if  ii>0 & ii~=.



******************** INGRESOS FAMILIARES TOTALES

* Numero de perceptores de ingresos 
egen n_perila_h = sum(perila)	if  hogarsec==0, by(id)
egen n_perii_h  = sum(perii)	if  hogarsec==0, by(id)


* Ingreso laboral familiar 
egen ilf_m = sum(ila_m)		if  hogarsec==0, by(id)
egen ilf   = sum(ila)		if  hogarsec==0, by(id)


* Ingreso no laboral familiar
egen inlaf_m = sum(inla_m)	if  hogarsec==0, by(id)
egen inlaf   = sum(inla)	if  hogarsec==0, by(id)


* Ingreso familiar total - monetario
egen itf_m = sum(ii_m)		if  hogarsec==0, by(id)


* Renta implícita de la vivienda propia e ingreso total familiar 
* Identifica a miembros propietarios
*egen    aux = max(propieta),	by(id)

*gen     aux_propieta = 0
*replace aux_propieta = 1	if  aux==1
*drop    aux

* Ingreso familiar total (antes de renta imputada)
egen itf_sin_ri = sum(ii)	if  hogarsec==0, by(id)

