********************************************************************************
*** 2019
********************************************************************************

*** OPEN DATABASES & IDENTIFICATION VARIABLES: CLEANED

use "C:\Users\wb550905\Github\VEN\data_management\output\cleaned\ENCOVI_2019", clear

*** Analysis in other dofile 

	/* 	recibe_ingresolab_mon_mes recibe_ingresolab_mon_ano recibe_ingresolab_mon report_inglabmon_perocuanto
		recibe_ingresolab_nomon report_inglabnomon_perocuanto 
		cuantasinlarecibe recibe_ingresonolab reportingnolab_perocuanto		*/
	
	*Conclusion: 
		*Laboral monetario
		tab report_inglabmon_perocuanto, mi // We will have to impute 287 observations that declare to have earned monetary labor income but don't say how much
		*Laboral no monetario
		tab report_inglabnomon_perocuanto, mi // We will have to impute 26 observations that declare to have earned non-monetary labor income but don't say how much
		*No laboral
		tab report_ingnolab_perocuanto, mi // We will have to impute 124 observations that declare to have received non labor income but don't say how much

		
*Chequear de acá para abajo

	/* Dummy working and receiving labor income
	gen aux = .
	replace aux=1 if (trabajo_semana==1 | trabajo_semana_2==1 | trabajo_semana_2==2 | sueldo_semana==1) // Trabajando - Assumption s9q5/sueldo_semana: if someone received a wage or benefits last week, we consider he has worked (although the answered no to having worked) 
	replace aux=1 if trabajo_semana_2==3 & trabajo_independiente==1	// No trabajó, pero tiene trabajo
	
	gen dlinc= (aux==1 & recibe_ingresolab_mon == 1) // Working: occupied, or doesn't answer if occupied but earns labor income, or works in household chorus and earns labor income
	replace dlinc=1 if recibe_ingresolab_mon == . & ila>0 & ila!=. // person doesn't answer if received income, but then reports income amount
	replace dlinc=. if recibe_ingresolab_mon == . & (ila==0 | ila==.) & aux==1 // person doesn't answer if received income, doesn't report any income amount, and working

	clonevar linc = ila // value labor income
	
	tab dlinc
	tab sueldo_semana recibe_ingresolab_mon */
	
replace linc= 0 if dlinc==0
gen dlinc_zero=tmhp42==2 if aux==1
gen dlinc_miss1=(tmhp42==99 & (tmhp42bs==0 | tmhp42bs==99 | tmhp42bs==99)) if aux==1
gen dlinc_miss2=((tmhp42bs==98 | tmhp42bs==99 | tmhp42bs==0) & dlinc==1) if aux==1
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if aux==1

*** Non-labor income
gen ing_nlb_pe = 1  if tmhp52pv==1 // Pensión de vejez
gen ing_nlb_op = 1  if tmhp52pi==2 // Otra pensión del IVSS (invalidez, incapacidad, sobreviviente)
gen ing_nlb_ju = 1  if tmhp52jt==3 // Jubilación por trabajo
gen ing_nlb_af = 1  if tmhp52ef==4 // Ayuda económica de algún familiar o de otra persona en el país
gen ing_nlb_ax = 1  if tmhp52af==5 // Ayuda económica de algún familiar o de otra persona desde el exterior
gen ing_nlb_ps = 1  if tmhp52pp==6 // Pensión de la seguridad social de otro país
gen ing_nlb_re = 1  if tmhp52rp==7 // Renta de propiedades
gen ing_nlb_id = 1  if tmhp52id==8 // Intereses o dividendos
gen ing_nlb_ot = 1  if tmhp52ot==9 // Otro
gen ing_nlb_ni = 1  if tmhp52ni==10 // Ninguno
gen ing_nlb_nsr = 1 if tmhp52nsr==11 // NS/NR
egen  recibe = rowtotal(ing_nlb_*) if ing_nlb_ni!= 1 | ing_nlb_nsr!= 1, mi //number of non-labor income sources that the household received
gen dnlinc=(tmhp52pv==1 | tmhp52pi==2 | tmhp52jt==3 | tmhp52ef==4 | tmhp52af==5 | tmhp52pp==6 | tmhp52rp==7 | tmhp52id==8 | tmhp52ot==9)
*egen recibe_pen=rowtotal(dpension_IVSS dpension_epu dpension_epr dpension_ot)

** Esta jubilado o pensionado (dos preguntas)
gen djubpen=(pmhp53j==1 | pmhp53p==2)
replace djubpen=1 if pmhp55ss==1 & djubpen==0
replace djubpen=1 if pmhp55ep==2 & djubpen==0
replace djubpen=1 if pmhp55ip==3 & djubpen==0
replace djubpen=1 if pmhp55ot==4 & djubpen==0
gen dpension_IVSS=1 if pmhp55ss==1 & djubpen==1 //IVSS
replace dpension_IVSS=1 if pmhp55ss==0 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_IVSS=1 if pmhp55ss==98 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_IVSS=1 if pmhp55ss==99 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_IVSS=0 if (pmhp55ss==0 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ss==98 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ss==99 & djubpen==0)
gen pension_IVSS=pmhp55bs*(1000/100000) if dpension_IVSS==1 & djubpen==1 & pmhp55bs!=98 & pmhp55bs!=99 //IVSS
replace pension_IVSS=0 if dpension_IVSS==0
gen dpension_IVSS_zero=pmhp55ss==0 if djubpen==1
gen dpension_IVSS_miss1=(pmhp55ss==99) if djubpen==1
gen dpension_IVSS_miss2=((pmhp55bs==98 | pmhp55bs==99) & dpension_IVSS==1) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1

gen dpension_epu=1 if pmhp55ep==2 & djubpen==1  //empresa publica
replace dpension_epu=1 if pmhp55ep==0 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_epu=1 if pmhp55ep==98 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_epu=1 if pmhp55ep==99 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_epu=0 if (pmhp55ep==0 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ep==98 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ep==99 & djubpen==0)
gen pension_epu=pmhp55bs*(1000/100000) if dpension_epu==1 & djubpen==1 & pmhp55bs!=98 & pmhp55bs!=99
replace pension_epu=0 if dpension_epu==0
gen dpension_epu_zero=pmhp55ep==0 if djubpen==1
gen dpension_epu_miss1=(pmhp55ep==99) if djubpen==1
gen dpension_epu_miss2=((pmhp55bs==98 | pmhp55bs==99) & dpension_epu==1) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1

gen dpension_epr=1 if pmhp55ip==3 & djubpen==1 //empresa privada
replace dpension_epr=1 if pmhp55ip==0 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_epr=1 if pmhp55ip==98 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_epr=1 if pmhp55ip==99 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_epr=0 if (pmhp55ip==0 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ip==98 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ip==99 & djubpen==0)
gen pension_epr=pmhp55bs*(1000/100000) if dpension_epr==1 & djubpen==1 & pmhp55bs!=98 & pmhp55bs!=99 
replace pension_epr=0 if dpension_epr==0
gen dpension_epr_zero=pmhp55ip==0 if djubpen==1
gen dpension_epr_miss1=(pmhp55ip==99) if djubpen==1
gen dpension_epr_miss2=((pmhp55bs==98 | pmhp55bs==99) & dpension_epr==1) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1

gen dpension_ot=1 if pmhp55ot==4 & djubpen==1  //otra
replace dpension_ot=1 if pmhp55ot==0 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_ot=1 if pmhp55ot==98 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_ot=1 if pmhp55ot==99 & (pmhp55bs!=0 & pmhp55bs!=98 & pmhp55bs!=99) & djubpen==1
replace dpension_ot=0 if (pmhp55ot==0 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ot==98 & (pmhp55bs==0 | pmhp55bs==98 | pmhp55bs==99)) | (pmhp55ot==99 & djubpen==0)
gen pension_ot=pmhp55bs*(1000/100000) if dpension_ot==1 & djubpen==1 & pmhp55bs!=98 & pmhp55bs!=99 
replace pension_ot=0 if dpension_ot==0
gen dpension_ot_zero=pmhp55ot==0 if djubpen==1
gen dpension_ot_miss1=(pmhp55ot==99) if djubpen==1
gen dpension_ot_miss2=((pmhp55bs==98 | pmhp55bs==99) & dpension_ot==1) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1

gen pension1=pension_IVSS+pension_epu+pension_epr+pension_ot
gen pension2=pmhp55bs*(1000/100000) if djubpen==1 & pmhp55bs!=98 & pmhp55bs!=99 
replace pension2=0 if djubpen==0

gen dnlinc_jubpen=(tmhp52pv==1 | tmhp52pi==2 | tmhp52jt==3)
gen nlinc_jubpen=tmhp52bs*(1000/100000) if dnlinc_jubpen==1 & tmhp52bs!=98 & tmhp52bs!=99
replace nlinc_jubpen= 0 if dnlinc_jubpen==0
gen dnlinc_jubpen_zero=tmhp52bs==0 if dnlinc_jubpen==1
gen dnlinc_jubpen_miss1=(tmhp52bs==98) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(tmhp52bs==99) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1

gen dnlinc_otro= (tmhp52ef==4 | tmhp52af==5 | tmhp52pp==6 | tmhp52rp==7 | tmhp52id==8 | tmhp52ot==9)
gen nlinc_otro=tmhp52bs*(1000/100000)  if dnlinc_otro==1 & tmhp52bs !=98 & tmhp52bs !=99
replace nlinc_otro=0 if dnlinc_otro==0
gen dnlinc_otro_zero=tmhp52bs ==0 if dnlinc_otro==1
gen dnlinc_otro_miss1=tmhp52bs==98 if dnlinc_otro==1
gen dnlinc_otro_miss2=(tmhp52bs ==99) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1

gen nlinc=tmhp52bs*(1000/100000)  if (tmhp52bs!=98 & tmhp52bs!=99)
replace nlinc=0 if tmhp52bs==98 
replace nlinc=0 if tmhp52bs==99 & dnlinc==0

gen nlinc1= pension1 + nlinc_otro
egen nlinc2=rowtotal(pension2 nlinc_otro)

egen income_off=rowtotal(linc nlinc pension2) 
egen income_off1=rowtotal(linc nlinc pension2) 
egen income=rowtotal(linc nlinc_jubpen nlinc_otro), missing

egen income_off_hh = sum(income_off), by(id)
egen income_off_hh1 = sum(income_off1), by(id)
bysort id: gen n_break = _N
gen nodecla=(tmhp42bs==99) | (tmhp42==99) | (tmhp52bs==99) | (pmhp55bs==99) | (pmhp55ss==99)
gen nodecla1=dlinc_miss3==1
egen nodecla_hh = sum(nodecla==1), by(id) // excluyen los ocupados que dicen recibir ingresos pero no declaran monto
egen nodecla_hh1 = sum(nodecla1==1), by(id)
gen ingper0 = income_off_hh / n_break 
gen ingper1 = income_off_hh1 / n_break 

*** Variables para equacion de Mincer
* edad, sexo, jefe de hogar, estado civil, region, educacion, tipo de empleo, sector de trabajo 
clonevar estado_civil_encuesta = cmhp22
clonevar nivel_educ = emhp27n
clonevar categ_ocu = tmhp41
clonevar labor_status = tmhp34
clonevar nhorast = tmhp45
clonevar firm_size = tmhp40
clonevar sector_encuesta = tmhp39
clonevar contrato_encuesta = tmhp43


keep id com dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension1 pension2 income_off income_off1 income_off_hh income_off_hh1 n_break nodecla nodecla1 nodecla_hh nodecla_hh1 ingper0 ingper1 ///
dnlinc_jubpen nlinc_jubpen dnlinc_jubpen_zero dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro dnlinc_otro_zero dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
dnlinc nlinc nlinc1 nlinc2 estado_civil_encuesta nivel_educ categ_ocu labor_status nhorast firm_size contrato_encuesta
merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2018.dta"
tempfile encovi2018
save `encovi2018', replace
