/*===========================================================================
Country name:	Venezuela
Year:			2014-2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Trinidad Saavedra

Dependencies:		The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			

Note: Income imputation - Identification missing values
=============================================================================*/
program drop _all
clear all
set mem 300m
clear matrix
clear mata
capture log close
set matsize 11000
set more off
********************************************************************************
	    * User 1: Trini
		global trini 1
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
			
		if $juli {
		}
	    if $lauta {

		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
                global rootpath2 "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela"
		}
		
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global rootpath2 ""
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global pathdata "$rootpath2\Income Imputation\data"
global pathout "$rootpath2\Income Imputation\output"
global pathdo "$rootpath2\Income Imputation\dofiles"

qui: do "$pathdo\outliers.do"
********************************************************************************
*** 2014
********************************************************************************
use "$data2014\CMHCVIDA.dta", clear
merge m:1 control using "$data2014\CODVIDA.dta"
drop _merge
*Incluyo las regiones de archivos 2014 
sort control lin
merge m:1 control lin using "$data2014\region_2014.dta"
drop _merge
rename _all, lower

rename control id
rename lin com
*** Labor income
gen ocupado=(tp47==1 | tp47==2) if (tp47!=98 | tp47!=99)
replace ocupado=1 if ocupado==. & (tp51m!=98 & tp51m!=99 & tp51m!=0) //those who reported missing in labor force status but have positive labor income
gen dlinc=1 if tp51==1 & ocupado==1 //dummy receive labor income
replace dlinc=1 if (tp51==98 | tp51==99) & (tp51m!=98 & tp51m!=99 & tp51m!=0) & ocupado==1 //those who reported they do not know if they received income, but then declare positive labor income
replace dlinc=0 if tp51==2 & ocupado==1 // real zeros: those who are employed but did not received labor income
replace dlinc=0 if ocupado==0 //those not employed
gen linc=tp51m if (tp51m!=98 & tp51m!=99 & tp51m!=0) & dlinc==1 //value labor income
replace linc= 0 if dlinc==0
* Outliers detection
*outliers linc 20 80 5 5 //15 outliers obs
* Missing values
gen dlinc_zero=tp51==2 if ocupado==1 //real zreros
gen dlinc_miss1=((tp51==98 | tp51==99) & (tp51m==98 | tp51m==99 | tp51m==0)) if ocupado==1 //those who reported they do not know if they received income and also have missing values in labor income
gen dlinc_miss2=(dlinc==1 & (tp51m==98 | tp51m==99 | tp51m==0)) if ocupado==1 //those who reported they received labor income, but they did not declare the amount
*gen dlinc_out=out_linc==1 if ocupado==1
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1 /*| dlinc_out*/) if ocupado==1 //all missing values
* Checking missing values
mdesc linc if ocupado==1
tab dlinc_miss3
note: fine!!

*** Pensions 
gen djubpen=pp61==1 if pp61!=98 & pp61!=99
replace djubpen=1 if djubpen==. & (pp63sm!=98 & pp63sm!=99 & pp63sm!=0) & (pp63em!=98 & pp63em!=99 & pp63em!=0) & (pp63pm!=98 & pp63pm!=99 & pp63pm!=0) & (pp630m!=98 & pp630m!=99 & pp630m!=0)

** IVSS
gen dpension_IVSS=1 if pp63ss==1 & djubpen==1 
replace dpension_IVSS=1 if (pp63ss==98 | pp63ss==99) & (pp63sm!=98 & pp63sm!=99 & pp63sm!=0) & djubpen==1
replace dpension_IVSS=0 if pp63ss==2 & djubpen==1 
replace dpension_IVSS=0 if djubpen==0 
gen pension_IVSS=pp63sm if (pp63sm!=98 & pp63sm!=99 & pp63sm!=0) & dpension_IVSS==1 
replace pension_IVSS=0 if dpension_IVSS==0 
* Outliers detection
*outliers pension_IVSS 20 80 5 5  //31 obs
* Missing values
gen dpension_IVSS_zero=pp63ss==2 if djubpen==1 //real zeros
gen dpension_IVSS_miss1=((pp63ss==98 | pp63ss==99) & (pp63sm==98 | pp63sm==99 | pp63sm==0)) if djubpen==1 
gen dpension_IVSS_miss2=(dpension_IVSS==1 & (pp63sm==98 | pp63sm==99 | pp63sm==0)) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_IVSS if djubpen==1
tab dpension_IVSS_miss3
note: fine!!

** Empresa publica
gen dpension_epu=1 if pp63ep==1 & djubpen==1  
replace dpension_epu=1 if (pp63ep==98 | pp63ep==99) & (pp63em!=98 & pp63em!=99 & pp63em!=0) & djubpen==1
replace dpension_epu=0 if pp63ep==2 & djubpen==1 
replace dpension_epu=0 if djubpen==0 
gen pension_epu=pp63em if (pp63em!=98 & pp63em!=99 & pp63em!=0) & dpension_epu==1 
replace pension_epu=0 if dpension_epu==0
* Outliers detection
*outliers pension_epu 20 80 5 5  //0 obs
* Missing values
gen dpension_epu_zero=pp63ep==2 if djubpen==1 //real zeros
gen dpension_epu_miss1=((pp63ep==98 | pp63ep==99) & (pp63em==98 | pp63em==99 | pp63em==0)) if djubpen==1 
gen dpension_epu_miss2=(dpension_epu==1 & (pp63em==98 | pp63em==99 | pp63em==0)) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epu if djubpen==1
tab dpension_epu_miss3
note: fine!!

** Empresa privada
gen dpension_epr=1 if pp63pr==1 & djubpen==1 
replace dpension_epr=1 if (pp63pr==98 | pp63pr==99) & (pp63pm!=98 & pp63pm!=99 & pp63pm!=0) & djubpen==1
replace dpension_epr=0 if pp63pr==2 & djubpen==1 
replace dpension_epr=0 if djubpen==0 
gen pension_epr=pp63pm if (pp63pm!=98 & pp63pm!=99 & pp63pm!=0) & dpension_epr==1 
replace pension_epr=0 if dpension_epr==0
* Outliers detection
*outliers pension_epr 20 80 5 5  //0 obs
* Missing values
gen dpension_epr_zero=pp63pr==2 if djubpen==1 //real zeros
gen dpension_epr_miss1=((pp63pr==98 | pp63pr==99) & (pp63pm==98 | pp63pm==99 | pp63pm==0)) if djubpen==1 
gen dpension_epr_miss2=(dpension_epr==1 & (pp63pm==98 | pp63pm==99 | pp63pm==0)) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epr if djubpen==1
tab dpension_epr_miss3
note: fine!!

** Otra
gen dpension_ot=1 if pp63ot==1 & djubpen==1
replace dpension_ot=1 if (pp63ot==98 | pp63ot==99) & (pp630m!=98 & pp630m!=99 & pp630m!=0) & djubpen==1
replace dpension_ot=0 if pp63ot==2 & djubpen==1 
replace dpension_ot=0 if djubpen==0 
gen pension_ot=pp630m if (pp630m!=98 & pp630m!=99 & pp630m!=0) & dpension_ot==1 
replace pension_ot=0 if dpension_ot==0
* Outliers detection
*outliers pension_ot 20 80 5 5  //0 obs
* Missing values
gen dpension_ot_zero=pp63ot==2 if djubpen==1 //real zeros
gen dpension_ot_miss1=((pp63ot==98 | pp63ot==99) & (pp630m==98 | pp630m==99 | pp630m==0)) if djubpen==1 
gen dpension_ot_miss2=(dpension_ot==1 & (pp630m==98 | pp630m==99 | pp630m==0)) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_ot if djubpen==1
tab dpension_ot_miss3
note: fine!!

gen pension=pension_IVSS+pension_epu+pension_epr+pension_ot //variable to use for imputation
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing //variable to replicate ENCOVI poverty estimates
egen income_off0=rowtotal(linc pension2) //official individual income (this is equivalent to impute with zero the missing values)

*** Scenario 0: ENCOVI estimates 
bysort id: egen income_off_hh0 = sum(income_off0) //official household income
bysort id: gen n_break = _N //household size
gen nodecla0=(dlinc_miss3==1 | dlinc_zero==1) //missing obs in ENCOVI codes: those who do not declare labor income including employed reporting zero labor income
egen nodecla_hh0 = sum(nodecla0==1), by(id) 
gen ingper0 = income_off_hh0 / n_break 

*** Variables for Mincer equation
* edad, sexo, relacion, estado civil, region, municipio, tipo de vivienda, regimen vivienda, activos del hogar, seguro salud, educacion, tipo de empleo, sector de trabajo, tipo contrato, tamano empresa, horas trabajadas, tipo de pension, pension de sobreviviente, beneficiario mision 
** Relation to the head
clonevar relacion_en=mhp25
clonevar relacion=mhp25 if mhp25!=98 & mhp25!=99
gen jefe=relacion==1
** Household size
gen hogarsec =.
replace hogarsec =1 if relacion_en==12
replace hogarsec = 0 if inrange(relacion_en,1,11) 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)
** Age
clonevar edad=mhp26
** Sex
clonevar sexo = mhp27 if mhp27!=98 & mhp27!=99
gen hombre=sexo==1 if sexo!=.
** Marital status
gen estado_civil_en= 1 if mhp28==1 | mhp28==2 //married 
replace estado_civil_en= 2 if mhp28==3 | mhp28==4 //living together
replace estado_civil_en= 3 if mhp28==5 | mhp28==6 //divorced/separated
replace estado_civil_en= 4 if mhp28==7 //widowed 
replace estado_civil_en= 5 if mhp28==8 //single
replace estado_civil_en= 6 if (mhp28==99 | mhp28==98) //NS/NR
tab estado_civil_en if ocupado==1
gen estado_civil = estado_civil_en if estado_civil_en!=6
** States
clonevar entidad= enti
** County
clonevar municipio= muni
** Type of dwelling
clonevar tipo_vivienda_en=vp4
tab tipo_vivienda_en if ocupado==1
gen tipo_vivienda=vp4 if vp4!=98 & vp4!=99
** Housing tenure
clonevar tenencia_vivienda_en=hp24 
tab tenencia_vivienda_en if ocupado==1
gen tenencia_vivienda=hp24 if hp24!=98 & hp24!=99
gen propieta_en = 1 if (tenencia_vivienda_en==1 | tenencia_vivienda_en==2) | (tenencia_vivienda_en==7 & cod24ot==6)
replace propieta_en = 2		if (tenencia_vivienda_en>=3 & tenencia_vivienda_en<=6) | (tenencia_vivienda_en==7 & cod24ot!=6)
replace propieta_en = 3		if  (tenencia_vivienda_en==98 | tenencia_vivienda_en==99)
tab propieta_en if ocupado==1
gen propieta = 1 if (tenencia_vivienda_en==1 | tenencia_vivienda_en==2) | (tenencia_vivienda_en==7 & cod24ot==6)
replace propieta = 0		if (tenencia_vivienda_en>=3 & tenencia_vivienda_en<=6) | (tenencia_vivienda_en==7 & cod24ot!=6)
replace propieta = .		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
** Durables
* Car
gen auto_en=.
gen     auto = .
* Heladera (hp23n): ¿Posee este hogar nevera?
clonevar     heladera_en = hp23n
recode heladera_en (98 99=3)
tab heladera_en if ocupado==1
gen     heladera = hp23n==1 if (hp23n!=98 & hp23n!=99)
* Lavarropas (hp23l): ¿Posee este hogar lavadora?
clonevar     lavarropas_en = hp23l
recode lavarropas_en (98 99=3)
tab lavarropas_en if ocupado==1
gen     lavarropas = hp23l==1 if (hp23l!=98 & hp23l!=99)
* Secadora (hp23s): ¿Posee este hogar secadora? 
clonevar    secadora_en = hp23s
recode secadora_en (98 99=3)
tab secadora_en if ocupado==1
gen     secadora = hp23s==1 if (hp23s!=98 & hp23s!=99)
* Computadora (hp23c): ¿Posee este hogar computadora?
clonevar computadora_en = hp23c
recode computadora_en (98 99=3)
tab computadora_en if ocupado==1
gen computadora = hp23c==1 if (hp23c!=98 & hp23c!=99)
* Internet (hp23i): ¿Posee este hogar internet?
clonevar     internet_en = hp23i
recode internet_en (98 99=3)
tab internet_en if ocupado==1
gen     internet = hp23i==1 if (hp23i!=98 & hp23i!=99) 
* Televisor (hp23t): ¿Posee este hogar televisor?
clonevar     televisor_en = hp23t
recode televisor_en (98 99=3)
tab televisor_en if ocupado==1
gen     televisor = hp23t==1 if (hp23t!=98 & hp23t!=99)
* Radio (hp23r): ¿Posee este hogar radio? 
clonevar     radio_en = hp23r
recode radio_en (98 99=3)
tab radio_en if ocupado==1
gen     radio = hp23r==1 if (hp23r!=98 & hp23r!=99)
* Calentador (hp23o): ¿Posee este hogar calentador? 
clonevar     calentador_en = hp23o
recode calentador_en (98 99=3)
tab calentador_en if ocupado==1
gen     calentador = hp23o==1 if (hp23o!=98 & hp23o!=99)
* Aire acondicionado (hp23a): ¿Posee este hogar aire acondicionado?
clonevar     aire_en = hp23a
recode aire_en (98 99=3)
tab  aire_en if ocupado==1
gen     aire = hp23a==1 if (hp23a!=98 & hp23a!=99)
* TV por cable o satelital (hp20v): ¿Posee este hogar TV por cable?
clonevar     tv_cable_en = hp23v
recode tv_cable_en (98 99=3)
tab tv_cable_en if ocupado==1
gen     tv_cable = hp23v==1 if (hp23v!=98 & hp23v!=99)
* Horno microonada (hp23h): ¿Posee este hogar horno microonda?
clonevar     microondas_en = hp23h
recode microondas_en (98 99=3)
tab microondas_en if ocupado==1
gen     microondas = hp23h==1 if (hp23h!=98 & hp23h!=99)
** Health insurance
gen     seguro_salud_en = 1	if  sp30>=1 & sp30<=5
replace seguro_salud_en = 2	if  sp30==6
replace seguro_salud_en = 3	if  sp30==98 | sp30==99
tab seguro_salud_en if ocupado==1
gen     seguro_salud = 1	if  sp30>=1 & sp30<=5
replace seguro_salud = 0	if  sp30==6
** Educational attainment
clonevar nivel_educ_en = ep37n
recode nivel_educ_en (98 99=8)
tab nivel_educ_en if ocupado==1
gen nivel_educ = ep37n if (ep37n!=98 & ep37n!=99)
** Type of employment
clonevar categ_ocu_en = tp50
recode categ_ocu_en (98 99=10)
tab categ_ocu_en if ocupado==1
gen categ_ocu = tp50    if (tp50!=98 & tp50!=99)
** Number of hours worked
gen nhorast = tp54 if (tp54!=998 & tp54!=999 & tp54!=0)
gen categ_nhorast_en= 1 if nhorast>=1 & nhorast<=20
replace categ_nhorast_en= 2 if nhorast>=21 & nhorast<=45
replace categ_nhorast_en= 3 if nhorast>=45 & nhorast!=.
replace categ_nhorast_en= 4 if tp54==998 | tp54==999 | tp54==0
tab categ_nhorast_en if ocupado==1
gen categ_nhorast= categ_nhorast_en if categ_nhorast_en!=4
** Firm size
clonevar firm_size_en = tp49 
recode firm_size_en (98 99 = 8)
tab firm_size_en if ocupado==1
gen firm_size = tp49 if (tp49!=98 & tp49!=99)
** Type of contract
gen     contrato_en = 1 if (tp52== 1 | tp52==2)
replace contrato_en = 2 if (tp52== 3 | tp52==4)
replace contrato_en = 3 if (tp52== 98 | tp52==99)
tab contrato_en if ocupado==1
gen     contrato = 1 if (tp52== 1 | tp52==2)
replace contrato = 0 if (tp52== 3 | tp52==4)
** Type of pension 
*Vejez
gen pension_vejez_en=1 if pp62==1 & djubpen==1
replace pension_vejez_en=2 if pp62!=1 & djubpen==1
replace pension_vejez_en=3 if (pp62==98 | pp62==99) & djubpen==1
tab pension_vejez_en if djubpen==1
gen pension_vejez = pp62==1 if djubpen==1 & pp62!=98 & pp62!=99
*Invalidez
gen pension_inva_en=1 if pp62==2 & djubpen==1
replace pension_inva_en=2 if pp62!=2 & djubpen==1
replace pension_inva_en=3 if (pp62==98 | pp62==99) & djubpen==1
tab pension_inva_en if djubpen==1
gen pension_inva = pp62==2 if djubpen==1 & pp62!=98 & pp62!=99
*Otra
gen pension_otra_en=1 if pp62==3 & djubpen==1
replace pension_otra_en=2 if pp62!=3 & djubpen==1
replace pension_otra_en=3 if (pp62==98 | pp62==99) & djubpen==1
tab pension_otra_en if djubpen==1
gen pension_otra = pp62==3 if djubpen==1 & pp62!=98 & pp62!=99
** Survivor pension
clonevar pension_sobrev_en=pp64 if edad>=40
recode pension_sobrev_en (98 99=3)
tab pension_sobrev_en if djubpen==1
gen pension_sobrev=pp64==1 if edad>=40 & pp64!=98 & pp64!=99
** Contribute to pensions
clonevar contribu_pen_en=pp65
tab contribu_pen_en if djubpen==1
recode contribu_pen_en (98 99=3)
gen contribu_pen=pp65==1 if pp65!=98 & pp65!=99
** Beneficiario misiones
clonevar misiones_en=psp66
recode misiones_en (98 99=3)
gen misiones=psp66==1 if psp66!=98 & psp66!=99

local demo relacion_en relacion hogarsec jefe miembros edad sexo hombre estado_civil_en estado_civil entidad municipio
local xvar_en tipo_vivienda_en tenencia_vivienda_en propieta_en auto_en heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en ///
              tv_cable_en microondas_en seguro_salud_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en misiones_en
local xvar tipo_vivienda tenencia_vivienda propieta auto heladera lavarropas secadora computadora internet televisor radio calentador aire ///
              tv_cable microondas seguro_salud nivel_educ categ_ocu categ_nhorast nhorast firm_size contrato pension_vejez pension_inva pension_otra pension_sobrev contribu_pen misiones

mdesc `demo' if ocupado==1
mdesc `xvar' if ocupado==1

*** Keep data base with variables of interest
gen year=2014
gen pondera= peso
order year id com
sort year id com
keep year id com pondera ocupado dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 /*dlinc_out*/ dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension pension2 income_off0 income_off_hh0 nodecla0 nodecla_hh0 n_break ingper0 ///
`demo' `xvar_en' `xvar'
*merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2014.dta"
tempfile encovi2014
save `encovi2014', replace

********************************************************************************
*** 2015
********************************************************************************
use "$data2015\Personas Encovi 2015.dta", clear

duplicates tag control lin, generate(duple)
tab control mhp24 if duple==1
//el hogar 1111 parece tener dos individuos distintos con la misma lin
//decisión: creo dos lin distintas
replace lin = 2 if control==1111 & mhp24==2
//el hogar 1330 parece tener dos individuos identicos con la misma lin
//decisión: elimino una observacion
drop if control==1330 & _n==5347
drop duple
merge m:1 control using "$data2015\Covida Encovi 2015.dta"
drop _merge
rename _all, lower

rename control id
rename lin com
capture drop nodecla

*** Labor Income
capture drop ocupado
gen ocupado=(tp45==1 | tp45==2) if (tp45!=98 | tp45!=99)
replace ocupado=1 if ocupado==. & (tp50m!=98 & tp50m!=99 & tp50m!=0 & tp50m!=.) //those who reported missing in labor force status but have positive labor income
gen dlinc=1 if tp50==1 & ocupado==1 //dummy receive labor income
replace dlinc=1 if (tp50==98 | tp50==99) & (tp50m!=98 & tp50m!=99 & tp50m!=0 & tp50m!=.) & ocupado==1 //those who reported they do not know if they received income, but then declare positive labor income
replace dlinc=0 if tp50==2 & ocupado==1 // real zeros: those who are employed but did not received labor income
replace dlinc=0 if ocupado==0 //those not employed
gen linc=tp50m if (tp50m!=98 & tp50m!=99 & tp50m!=0) & dlinc==1 //value labor income
replace linc= 0 if dlinc==0
* Outliers detection
*outliers linc 20 80 5 5  //9 obs
* Missing values
gen dlinc_zero=tp50==2 if ocupado==1 //real zreros
gen dlinc_miss1=((tp50==98 | tp50==99) & (tp50m==98 | tp50m==99 | tp50m==0 | tp50m==.)) if ocupado==1 //those who reported they do not know if they received income and also have missing values in labor income
gen dlinc_miss2=(dlinc==1 & (tp50m==98 | tp50m==99 | tp50m==0 | tp50m==.)) if ocupado==1 //those who reported they received labor income, but they did not declare the amount
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if ocupado==1 //all missing values
* Checking missing values
mdesc linc if ocupado==1
tab dlinc_miss3
note: fine!!

*** Pensions 
gen djubpen=pp61==1 if pp61!=98 & pp61!=99
replace djubpen=1 if djubpen==. & (pp63sm!=98 & pp63sm!=99 & pp63sm!=0) & (pp63em!=98 & pp63em!=99 & pp63em!=0) & (pp63pm!=98 & pp63pm!=99 & pp63pm!=0) & (pp63om!=98 & pp63om!=99 & pp63om!=0)

** IVSS
gen dpension_IVSS=1 if pp63ss==1 & djubpen==1 
replace dpension_IVSS=1 if (pp63ss==98 | pp63ss==99) & (pp63sm!=98 & pp63sm!=99 & pp63sm!=0) & djubpen==1
replace dpension_IVSS=0 if pp63ss==0 & djubpen==1 
replace dpension_IVSS=0 if djubpen==0 
gen pension_IVSS=pp63sm if (pp63sm!=98 & pp63sm!=99 & pp63sm!=0) & dpension_IVSS==1 
replace pension_IVSS=0 if dpension_IVSS==0 
* Outliers detection
*outliers pension_IVSS 20 80 5 5  //7 obs
* Missing values
gen dpension_IVSS_zero=pp63ss==0 if djubpen==1 //real zeros
gen dpension_IVSS_miss1=((pp63ss==98 | pp63ss==99) & (pp63sm==98 | pp63sm==99 | pp63sm==0)) if djubpen==1 
gen dpension_IVSS_miss2=(dpension_IVSS==1 & (pp63sm==98 | pp63sm==99 | pp63sm==0)) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_IVSS if djubpen==1
tab dpension_IVSS_miss3
note: fine!!

** Empresa publica
gen dpension_epu=1 if pp63ep==2 & djubpen==1  
replace dpension_epu=1 if (pp63ep==98 | pp63ep==99) & (pp63em!=98 & pp63em!=99 & pp63em!=0) & djubpen==1
replace dpension_epu=0 if pp63ep==0 & djubpen==1 
replace dpension_epu=0 if djubpen==0 
gen pension_epu=pp63em if (pp63em!=98 & pp63em!=99 & pp63em!=0) & dpension_epu==1 
replace pension_epu=0 if dpension_epu==0
* Outliers detection
*outliers pension_epu 20 80 5 5  //0 obs
* Missing values
gen dpension_epu_zero=pp63ep==0 if djubpen==1 //real zeros
gen dpension_epu_miss1=((pp63ep==98 | pp63ep==99) & (pp63em==98 | pp63em==99 | pp63em==0)) if djubpen==1 
gen dpension_epu_miss2=(dpension_epu==1 & (pp63em==98 | pp63em==99 | pp63em==0)) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epu if djubpen==1
tab dpension_epu_miss3
note: fine!!

** Empresa privada
gen dpension_epr=1 if pp63pr==3 & djubpen==1 
replace dpension_epr=1 if (pp63pr==98 | pp63pr==99) & (pp63pm!=98 & pp63pm!=99 & pp63pm!=0) & djubpen==1
replace dpension_epr=0 if pp63pr==0 & djubpen==1 
replace dpension_epr=0 if djubpen==0 
gen pension_epr=pp63pm if (pp63pm!=98 & pp63pm!=99 & pp63pm!=0) & dpension_epr==1 
replace pension_epr=0 if dpension_epr==0
* Outliers detection
*outliers pension_epr 20 80 5 5  //0 obs
* Missing values
gen dpension_epr_zero=pp63pr==0 if djubpen==1 //real zeros
gen dpension_epr_miss1=((pp63pr==98 | pp63pr==99) & (pp63pm==98 | pp63pm==99 | pp63pm==0)) if djubpen==1 
gen dpension_epr_miss2=(dpension_epr==1 & (pp63pm==98 | pp63pm==99 | pp63pm==0)) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epr if djubpen==1
tab dpension_epr_miss3
note: fine!!

** Otra
gen dpension_ot=1 if pp63ot==4 & djubpen==1
replace dpension_ot=1 if (pp63ot==98 | pp63ot==99) & (pp63om!=98 & pp63om!=99 & pp63om!=0) & djubpen==1
replace dpension_ot=0 if pp63ot==0 & djubpen==1 
replace dpension_ot=0 if djubpen==0 
gen pension_ot=pp63om if (pp63om!=98 & pp63om!=99 & pp63om!=0) & dpension_ot==1 
replace pension_ot=0 if dpension_ot==0
* Outliers detection
*outliers pension_ot 20 80 5 5  //4 obs
* Missing values
gen dpension_ot_zero=pp63ot==0 if djubpen==1 //real zeros
gen dpension_ot_miss1=((pp63ot==98 | pp63ot==99) & (pp63om==98 | pp63om==99 | pp63om==0)) if djubpen==1 
gen dpension_ot_miss2=(dpension_ot==1 & (pp63om==98 | pp63om==99 | pp63om==0)) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_ot if djubpen==1
tab dpension_ot_miss3
note: fine!!

*** Non-labor income
gen ing_nlb_ps= 1  if  tp51ps==1 // Pensión por sobreviviente, orfandad
gen ing_nlb_ay = 1  if tp51ay==2 // Ayuda familiar o de otra persona
gen ing_nlb_ss = 1  if tp51ss==3 // Pension por seguro social
gen ing_nlb_jv = 1  if tp51jv==4 // Jubilación por trabajo
gen ing_nlb_rp = 1  if tp51rp==5 // Renta por priopiedades
gen ing_nlb_id = 1  if tp51id==6 // Intereses o dividendos
gen ing_nlb_ot = 1  if tp51ot==7 // Otros
egen    recibe = rowtotal(ing_nlb_*), mi //number of non-labor income sources that the household received

gen dnlinc=(tp51ps==1 | tp51ss==3 | tp51jv==4 | tp51ay==2 | tp51rp==5 | tp51id==6 | tp51ot==7) 
gen aux=1 if (tp51ps==98 | tp51ps==99 | tp51ay==98 | tp51ay==99 | tp51ss==98 | tp51ss==99 | tp51jv==98 | tp51jv==99 | ///
             tp51rp==98 | tp51rp==99 | tp51id==98 | tp51id==99 | tp51ot==98 | tp51ot==99) 
replace dnlinc=1 if aux==1 &  (tp51m!=98 & tp51m!=99 & tp51m!=0 & tp51m!=.) 
gen nlinc=tp51m if (tp51m!=98 & tp51m!=99 & tp51m!=0) & dnlinc==1
replace nlinc=0 if dnlinc==0
* Outliers detection
*outliers nlinc 20 80 5 5  //1 obs
* Missing values
gen dnlinc_miss1=(aux==1 & (tp51m==98 | tp51m==99 | tp51m==0 | tp51m==.)) if dnlinc==1
gen dnlinc_miss2=(dnlinc==1 & (tp51m==98 | tp51m==99 | tp51m==0 | tp51m==.)) if dnlinc==1
gen dnlinc_miss3=(dnlinc_miss1==1 | dnlinc_miss2==1) if dnlinc==1
* Checking missing values
mdesc nlinc if dnlinc==1
tab dnlinc_miss3 if dnlinc==1
note: fine!!

** Pensions (from the non-labor income question)
gen dnlinc_jubpen=((tp51ps==1 | tp51ss==3 | tp51jv==4)) if dnlinc==1 
gen aux1=1 if (tp51ps==98 | tp51ps==99 | tp51ss==98 | tp51ss==99 | tp51jv==98 | tp51jv==99)
replace dnlinc_jubpen=1 if aux1==1 & (tp51m!=98 & tp51m!=99 & tp51m!=0 & tp51m!=.) 
gen nlinc_jubpen=tp51m if (tp51m!=98 & tp51m!=99 & tp51m!=0) & dnlinc_jubpen==1
replace nlinc_jubpen=0 if dnlinc==0
* Missing values
gen dnlinc_jubpen_miss1=(aux1==1 & (tp51m==98 | tp51m==99 | tp51m==0 | tp51m==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(dnlinc_jubpen==1 & (tp51m==98 | tp51m==99 | tp51m==0 | tp51m==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1 
* Checking missing values
mdesc nlinc_jubpen if dnlinc_jubpen==1
tab dnlinc_jubpen_miss3 if dnlinc_jubpen==1
note: fine!!

** Non-labor income other than pensions 
gen dnlinc_otro=(tp51ay==2 | tp51rp==5 | tp51id==6 | tp51ot==7)  if dnlinc==1 
gen aux2=1 if (tp51ay==98 | tp51ay==99 | tp51rp==98 | tp51rp==99 | tp51id==98 | tp51id==99 | tp51ot==98 | tp51ot==99) 
replace dnlinc_otro=1 if aux2==1 & (tp51m!=98 & tp51m!=99 & tp51m!=0 & tp51m!=.) 
gen nlinc_otro=tp51m if (tp51m!=98 & tp51m!=99 & tp51m!=0) & dnlinc_otro==1
replace nlinc_otro=0 if dnlinc==0
* Missing values
gen dnlinc_otro_miss1=(aux2==1 & (tp51m==98 | tp51m==99 | tp51m==0 | tp51m==.)) if dnlinc_otro==1
gen dnlinc_otro_miss2=(dnlinc_otro==1 & (tp51m==98 | tp51m==99 | tp51m==0 | tp51m==.)) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1 
* Checking missing values
mdesc nlinc_otro if dnlinc_otro==1
tab dnlinc_otro_miss3 if dnlinc_otro==1
note: fine!!

gen pension=pension_IVSS+pension_epu+pension_epr+pension_ot //variable to use for imputation
replace pension=tp51m if pension==. & djubpen==1 & tp51m!=98 & tp51m!=99 & tp51m!=0 & dnlinc_jubpen==1 & recibe==1
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing //variable to replicate ENCOVI poverty estimates

*** Scenario 0: ENCOVI estimates
egen income_off0=rowtotal(linc nlinc) if tp50m!=. & tp51m!=. //official individual income (this is equivalent to impute with zero the missing values)
bysort id: egen income_off_hh0 = sum(income_off)
bysort id: gen n_break = _N
gen nodecla0=(dlinc_miss2==1 & tp50m!=.) //missing obs in ENCOVI codes: those who received labor income but they did not declare the amount
egen nodecla_hh0 = sum(nodecla0==1), by(id) 
gen ingper0 = income_off_hh0 / n_break 

*** Variables for Mincer equation
* edad, sexo, relacion, estado civil, region, municipio, tipo de vivienda, regimen vivienda, activos del hogar, seguro salud, educacion, tipo de empleo, sector de trabajo, tipo contrato, tamano empresa, horas trabajadas, tipo de pension, pension de sobreviviente, beneficiario mision 
** Relation to the head
clonevar relacion_en=mhp24
clonevar relacion=mhp24 if mhp24!=98 & mhp24!=99
gen jefe=relacion==1
** Household size
gen hogarsec =.
replace hogarsec =1 if relacion_en==12
replace hogarsec = 0 if inrange(relacion_en,1,11) 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)
** Age
clonevar edad=mhp25
** Sex
clonevar sexo = mhp26 if mhp26!=98 & mhp26!=99
gen hombre=sexo==1 if sexo!=.
** Marital status
gen estado_civil_en= 1 if mhp27==1 | mhp27==2 //married 
replace estado_civil_en= 2 if mhp27==3 | mhp27==4 //living together
replace estado_civil_en= 3 if mhp27==5 | mhp27==6 //divorced/separated
replace estado_civil_en= 4 if mhp27==7 //widowed 
replace estado_civil_en= 5 if mhp27==8 //single
replace estado_civil_en= 6 if (mhp27==99 | mhp27==98) //NS/NR
tab estado_civil_en if ocupado==1
gen estado_civil = estado_civil_en if estado_civil_en!=6
** States
clonevar entidad= enti
** County
clonevar municipio= muni
** Type of dwelling
clonevar tipo_vivienda_en=vp4
tab tipo_vivienda_en if ocupado==1
gen tipo_vivienda=vp4 if vp4!=98 & vp4!=99
** Housing tenure
clonevar tenencia_vivienda_en=hp22 
tab tenencia_vivienda_en if ocupado==1
gen tenencia_vivienda=hp22 if hp22!=98 & hp22!=99
gen propieta_en = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2 
replace propieta_en = 2		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=7 
replace propieta_en = 3		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
tab propieta_en if ocupado==1
gen propieta = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2
replace propieta = 0		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=7
replace propieta = .		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
** Durables
* Car
gen     auto_en = 1 if hp21>0 & (hp21!=98 & hp21!=99)
replace auto_en = 2 if hp21==0
replace auto_en = 3 if (hp21==98 | hp21==99)
tab auto_en if ocupado==1
gen     auto = hp21>0 if (hp21!=98 & hp21!=99)
* Heladera (hp20n): ¿Posee este hogar nevera?
clonevar     heladera_en = hp20n
recode heladera_en (98 99=3)
tab heladera_en if ocupado==1
gen     heladera = hp20n==1 if (hp20n!=98 & hp20n!=99)
* Lavarropas (hp20l): ¿Posee este hogar lavadora?
clonevar     lavarropas_en = hp20l
recode lavarropas_en (98 99=3)
tab lavarropas_en if ocupado==1
gen     lavarropas = hp20l==1 if (hp20l!=98 & hp20l!=99)
* Secadora (hp20s): ¿Posee este hogar secadora? 
clonevar    secadora_en = hp20s
recode secadora_en (98 99=3)
tab secadora_en if ocupado==1
gen     secadora = hp20s==1 if (hp20s!=98 & hp20s!=99)
* Computadora (hp20c): ¿Posee este hogar computadora?
clonevar computadora_en = hp20c
recode computadora_en (98 99=3)
tab computadora_en if ocupado==1
gen computadora = hp20c==1 if (hp20c!=98 & hp20c!=99)
* Internet (hp20i): ¿Posee este hogar internet?
clonevar     internet_en = hp20i
recode internet_en (98 99=3)
tab internet_en if ocupado==1
gen     internet = hp20i==1 if (hp20i!=98 & hp20i!=99) 
* Televisor (hp20t): ¿Posee este hogar televisor?
clonevar     televisor_en = hp20t
recode televisor_en (98 99=3)
tab televisor_en if ocupado==1
gen     televisor = hp20t==1 if (hp20t!=98 & hp20t!=99)
* Radio (hp20r): ¿Posee este hogar radio? 
clonevar     radio_en = hp20r
recode radio_en (98 99=3)
tab radio_en if ocupado==1
gen     radio = hp20r==1 if (hp20r!=98 & hp20r!=99)
* Calentador (hp20o): ¿Posee este hogar calentador? 
clonevar     calentador_en = hp20o
recode calentador_en (98 99=3)
tab calentador_en if ocupado==1
gen     calentador = hp20o==1 if (hp20o!=98 & hp20o!=99)
* Aire acondicionado (hp20a): ¿Posee este hogar aire acondicionado?
clonevar     aire_en = hp20a
recode aire_en (98 99=3)
tab  aire_en if ocupado==1
gen     aire = hp20a==1 if (hp20a!=98 & hp20a!=99)
* TV por cable o satelital (hp20v): ¿Posee este hogar TV por cable?
clonevar     tv_cable_en = hp20v
recode tv_cable_en (98 99=3)
tab tv_cable_en if ocupado==1
gen     tv_cable = hp20v==1 if (hp20v!=98 & hp20v!=99)
* Horno microonada (hp20h): ¿Posee este hogar horno microonda?
clonevar     microondas_en = hp20h
recode microondas_en (98 99=3)
tab microondas_en if ocupado==1
gen     microondas = hp20h==1 if (hp20h!=98 & hp20h!=99)
** Health insurance
gen afiliado_seguro_salud = 1     if sp29_1==1 
replace afiliado_seguro_salud = 2 if sp29_1==2 
replace afiliado_seguro_salud = 3 if sp29_1==3 
replace afiliado_seguro_salud = 4 if sp29_1==4
replace afiliado_seguro_salud = 5 if sp29_1==5
replace afiliado_seguro_salud = 6 if sp29_1==6
replace afiliado_seguro_salud = . if sp29_1==98 | sp29_1==99
gen     seguro_salud_en = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud_en = 2	if  afiliado_seguro_salud==6
replace seguro_salud_en = 3	if  afiliado_seguro_salud==.
tab seguro_salud_en if ocupado==1
gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6
** Educational attainment
clonevar nivel_educ_en = ep36n
recode nivel_educ_en (98 99=8)
tab nivel_educ_en if ocupado==1
gen nivel_educ = ep36n if (ep36n!=98 & ep36n!=99)
** Type of employment
clonevar categ_ocu_en = tp49
recode categ_ocu_en (98 99=10)
tab categ_ocu_en if ocupado==1
gen categ_ocu = tp49    if (tp49!=98 & tp49!=99)
** Number of hours worked
gen nhorast = tp54 if (tp54!=98 & tp54!=99 & tp54!=0)
gen categ_nhorast_en= 1 if nhorast>=1 & nhorast<=20
replace categ_nhorast_en= 2 if nhorast>=21 & nhorast<=45
replace categ_nhorast_en= 3 if nhorast>=45 & nhorast!=.
replace categ_nhorast_en= 4 if tp54==98 | tp54==99 | tp54==0
tab categ_nhorast_en if ocupado==1
gen categ_nhorast= categ_nhorast_en if categ_nhorast_en!=4
** Firm size
clonevar firm_size_en = tp48 
recode firm_size_en (98 99 = 8)
tab firm_size_en if ocupado==1
gen firm_size = tp48 if (tp48!=98 & tp48!=99)
** Type of contract
gen     contrato_en = 1 if (tp52== 1 | tp52==2)
replace contrato_en = 2 if (tp52== 3 | tp52==4)
replace contrato_en = 3 if (tp52== 98 | tp52==99)
tab contrato_en if ocupado==1
gen     contrato = 1 if (tp52== 1 | tp52==2)
replace contrato = 0 if (tp52== 3 | tp52==4)
** Type of pension 
*Vejez
gen pension_vejez_en=1 if pp62==1 & djubpen==1
replace pension_vejez_en=2 if pp62!=1 & djubpen==1
replace pension_vejez_en=3 if (pp62==98 | pp62==99) & djubpen==1
tab pension_vejez_en if djubpen==1
gen pension_vejez = pp62==1 if djubpen==1 & pp62!=98 & pp62!=99
*Invalidez
gen pension_inva_en=1 if pp62==2 & djubpen==1
replace pension_inva_en=2 if pp62!=2 & djubpen==1
replace pension_inva_en=3 if (pp62==98 | pp62==99) & djubpen==1
tab pension_inva_en if djubpen==1
gen pension_inva = pp62==2 if djubpen==1 & pp62!=98 & pp62!=99
*Otra
gen pension_otra_en=1 if pp62==3 & djubpen==1
replace pension_otra_en=2 if pp62!=3 & djubpen==1
replace pension_otra_en=3 if (pp62==98 | pp62==99) & djubpen==1
tab pension_otra_en if djubpen==1
gen pension_otra = pp62==3 if djubpen==1 & pp62!=98 & pp62!=99
** Survivor pension
clonevar pension_sobrev_en=pp64 if edad>=40
recode pension_sobrev_en (98 99 .=3) if edad>40
tab pension_sobrev_en if djubpen==1
gen pension_sobrev=pp64==1 if edad>=40 & pp64!=98 & pp64!=99
** Contribute to pensions
clonevar contribu_pen_en=pp65
tab contribu_pen_en if djubpen==1
recode contribu_pen_en (98 99 .=3)
gen contribu_pen=pp65==1 if pp65!=98 & pp65!=99
** Beneficiario misiones
clonevar misiones_en=psp66
recode misiones_en (98 99=3)
gen misiones=psp66==1 if psp66!=98 & psp66!=99

local demo relacion_en relacion hogarsec jefe miembros edad sexo hombre estado_civil_en estado_civil entidad municipio
local xvar_en tipo_vivienda_en tenencia_vivienda_en propieta_en auto_en heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en ///
              tv_cable_en microondas_en seguro_salud_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en misiones_en
local xvar tipo_vivienda tenencia_vivienda propieta auto heladera lavarropas secadora computadora internet televisor radio calentador aire ///
              tv_cable microondas seguro_salud nivel_educ categ_ocu categ_nhorast nhorast firm_size contrato pension_vejez pension_inva pension_otra pension_sobrev contribu_pen misiones

mdesc `demo' if ocupado==1
mdesc `xvar' if ocupado==1

*** Keep data base with variables of interest
gen year=2015
gen pondera = xxp
order year id com
sort year id com
keep year id com pondera ocupado dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension pension2 dnlinc nlinc /*dnlinc_zero*/ dnlinc_miss1 dnlinc_miss2 dnlinc_miss3 ///
dnlinc_jubpen nlinc_jubpen /*dnlinc_jubpen_zero*/ dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro /*dnlinc_otro_zero*/ dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
income_off0 income_off_hh0 nodecla0 nodecla_hh0 n_break ingper0 ///
`demo' `xvar_en' `xvar'
*merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2015.dta"
tempfile encovi2015
save `encovi2015', replace

********************************************************************************
*** 2016
********************************************************************************
use "$data2016\Personas Encovi2016.dta", clear
rename control CONTROL
merge m:1 CONTROL using "$data2016\Hogares_ENCOVI2016.dta"
drop _merge
*Incluyo las regiones de archivos 2016
rename lin LIN
sort CONTROL LIN
merge m:1 CONTROL LIN using "$data2016\region_2016.dta"
drop _merge  
rename _all, lower

rename control id
rename lin com

*** Labor Income
capture drop ocupado
gen ocupado=(tp39==1 | tp39==2) if (tp39!=98 | tp39!=99)
replace ocupado=1 if ocupado==. & (tp47m!=98 & tp47m!=99 & tp47m!=0 & tp47m!=.) //those who reported missing in labor force status but have positive labor income
gen dlinc=1 if tp47==1 & ocupado==1 //dummy receive labor income
replace dlinc=1 if (tp47==98 | tp47==99) & (tp47m!=98 & tp47m!=99 & tp47m!=0 & tp47m!=.) & ocupado==1 //those who reported they do not know if they received income, but then declare positive labor income
replace dlinc=0 if tp47==2 & ocupado==1 // real zeros: those who are employed but did not received labor income
replace dlinc=0 if ocupado==0 //those not employed
gen linc=tp47m if (tp47m!=98 & tp47m!=99 & tp47m!=0) & dlinc==1 //value labor income
replace linc= 0 if dlinc==0
* Missing values
gen dlinc_zero=tp47==2 if ocupado==1 //real zreros
gen dlinc_miss1=((tp47==98 | tp47==99) & (tp47m==98 | tp47m==99 | tp47m==0 | tp47m==.)) if ocupado==1 //those who reported they do not know if they received income and also have missing values in labor income
gen dlinc_miss2=(dlinc==1 & (tp47m==98 | tp47m==99 | tp47m==0 | tp47m==.)) if ocupado==1 //those who reported they received labor income, but they did not declare the amount
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if ocupado==1 //all missing values
* Checking missing values
mdesc linc if ocupado==1
tab dlinc_miss3
note: fine!!

*** Pensions 
gen djubpen=(pp59==1 | pp59==2 | pp59==3) if pp59!=98 & pp59!=99
replace djubpen=1 if djubpen==. & (pp61sm!=98 & pp61sm!=99 & pp61sm!=0) & (pp61em!=98 & pp61em!=99 & pp61em!=0) & (pp61pm!=98 & pp61pm!=99 & pp61pm!=0) & (pp61om!=98 & pp61om!=99 & pp61om!=0)

** IVSS
gen dpension_IVSS=1 if pp61ss==1 & djubpen==1 
replace dpension_IVSS=1 if (pp61ss==98 | pp61ss==99) & (pp61sm!=98 & pp61sm!=99 & pp61sm!=0) & djubpen==1
replace dpension_IVSS=0 if pp61ss==0 & djubpen==1 
replace dpension_IVSS=0 if djubpen==0 
gen pension_IVSS=pp61sm if (pp61sm!=98 & pp61sm!=99 & pp61sm!=0) & dpension_IVSS==1 
replace pension_IVSS=0 if dpension_IVSS==0 
* Missing values
gen dpension_IVSS_zero=pp61ss==0 if djubpen==1 //real zeros
gen dpension_IVSS_miss1=((pp61ss==98 | pp61ss==99) & (pp61sm==98 | pp61sm==99 | pp61sm==0)) if djubpen==1 
gen dpension_IVSS_miss2=(dpension_IVSS==1 & (pp61sm==98 | pp61sm==99 | pp61sm==0)) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_IVSS if djubpen==1
tab dpension_IVSS_miss3
note: fine!!

** Empresa publica
gen dpension_epu=1 if pp61ep==2 & djubpen==1  
replace dpension_epu=1 if (pp61ep==98 | pp61ep==99) & (pp61em!=98 & pp61em!=99 & pp61em!=0) & djubpen==1
replace dpension_epu=0 if pp61ep==0 & djubpen==1 
replace dpension_epu=0 if djubpen==0 
gen pension_epu=pp61em if (pp61em!=98 & pp61em!=99 & pp61em!=0) & dpension_epu==1 
replace pension_epu=0 if dpension_epu==0
* Missing values
gen dpension_epu_zero=pp61ep==0 if djubpen==1 //real zeros
gen dpension_epu_miss1=((pp61ep==98 | pp61ep==99) & (pp61em==98 | pp61em==99 | pp61em==0)) if djubpen==1 
gen dpension_epu_miss2=(dpension_epu==1 & (pp61em==98 | pp61em==99 | pp61em==0)) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epu if djubpen==1
tab dpension_epu_miss3
note: fine!!

** Empresa privada
gen dpension_epr=1 if pp61pr==3 & djubpen==1 
replace dpension_epr=1 if (pp61pr==98 | pp61pr==99) & (pp61pm!=98 & pp61pm!=99 & pp61pm!=0) & djubpen==1
replace dpension_epr=0 if pp61pr==0 & djubpen==1 
replace dpension_epr=0 if djubpen==0 
gen pension_epr=pp61pm if (pp61pm!=98 & pp61pm!=99 & pp61pm!=0) & dpension_epr==1 
replace pension_epr=0 if dpension_epr==0
* Missing values
gen dpension_epr_zero=pp61pr==0 if djubpen==1 //real zeros
gen dpension_epr_miss1=((pp61pr==98 | pp61pr==99) & (pp61pm==98 | pp61pm==99 | pp61pm==0)) if djubpen==1 
gen dpension_epr_miss2=(dpension_epr==1 & (pp61pm==98 | pp61pm==99 | pp61pm==0)) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epr if djubpen==1
tab dpension_epr_miss3
note: fine!!

** Otra
gen dpension_ot=1 if pp61ot==4 & djubpen==1
replace dpension_ot=1 if (pp61ot==98 | pp61ot==99) & (pp61om!=98 & pp61om!=99 & pp61om!=0) & djubpen==1
replace dpension_ot=0 if pp61ot==0 & djubpen==1 
replace dpension_ot=0 if djubpen==0 
gen pension_ot=pp61om if (pp61om!=98 & pp61om!=99 & pp61om!=0) & dpension_ot==1 
replace pension_ot=0 if dpension_ot==0
* Missing values
gen dpension_ot_zero=pp61ot==0 if djubpen==1 //real zeros
gen dpension_ot_miss1=((pp61ot==98 | pp61ot==99) & (pp61om==98 | pp61om==99 | pp61om==0)) if djubpen==1 
gen dpension_ot_miss2=(dpension_ot==1 & (pp61om==98 | pp61om==99 | pp61om==0)) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_ot if djubpen==1
tab dpension_ot_miss3
note: fine!!

*** Non-labor income
gen ing_nlb_ps= 1  if  tp48ps==1 // Pensión por sobreviviente, orfandad
gen ing_nlb_ay = 1  if tp48ay==2 // Ayuda familiar o de otra persona
gen ing_nlb_ss = 1  if tp48ss==3 // Pension por seguro social
gen ing_nlb_jv = 1  if tp48jv==4 // Jubilación por trabajo
gen ing_nlb_rp = 1  if tp48rp==5 // Renta por priopiedades
gen ing_nlb_id = 1  if tp48id==6 // Intereses o dividendos
gen ing_nlb_ot = 1  if tp48ot==7 // Otros
egen    recibe = rowtotal(ing_nlb_*), mi //number of non-labor income sources that the household received

gen dnlinc=(tp48ps==1 | tp48ss==3 | tp48jv==4 | tp48ay==2 | tp48rp==5 | tp48id==6 | tp48ot==7) 
gen aux=1 if (tp48ps==98 | tp48ps==99 | tp48ay==98 | tp48ay==99 | tp48ss==98 | tp48ss==99 | tp48jv==98 | tp48jv==99 | ///
             tp48rp==98 | tp48rp==99 | tp48id==98 | tp48id==99 | tp48ot==98 | tp48ot==99) 
replace dnlinc=1 if aux==1 &  (tp48m!=98 & tp48m!=99 & tp48m!=0 & tp48m!=.)
gen nlinc=tp48m if (tp48m!=98 & tp48m!=99 & tp48m!=0) & dnlinc==1
replace nlinc=0 if dnlinc==0
* Missing values
gen dnlinc_miss1=(aux==1 & (tp48m==98 | tp48m==99 | tp48m==0 | tp48m==.)) if dnlinc==1
gen dnlinc_miss2=(dnlinc==1 & (tp48m==98 | tp48m==99 | tp48m==0 | tp48m==.)) if dnlinc==1
gen dnlinc_miss3=(dnlinc_miss1==1 | dnlinc_miss2==1) if dnlinc==1
* Checking missing values
mdesc nlinc if dnlinc==1
tab dnlinc_miss3 if dnlinc==1
note: fine!!


** Pensions (from the non-labor income question)
gen dnlinc_jubpen=((tp48ps==1 | tp48ss==3 | tp48jv==4)) if dnlinc==1 
gen aux1=1 if (tp48ps==98 | tp48ps==99 | tp48ss==98 | tp48ss==99 | tp48jv==98 | tp48jv==99)
replace dnlinc_jubpen=1 if aux1==1 & (tp48m!=98 & tp48m!=99 & tp48m!=0 & tp48m!=.) 
gen nlinc_jubpen=tp48m if (tp48m!=98 & tp48m!=99 & tp48m!=0) & dnlinc_jubpen==1
replace nlinc_jubpen=0 if dnlinc==0
* Missing values
gen dnlinc_jubpen_miss1=(aux1==1 & (tp48m==98 | tp48m==99 | tp48m==0 | tp48m==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(dnlinc_jubpen==1 & (tp48m==98 | tp48m==99 | tp48m==0 | tp48m==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1 
* Checking missing values
mdesc nlinc_jubpen if dnlinc_jubpen==1
tab dnlinc_jubpen_miss3 if dnlinc_jubpen==1
note: fine!!

** Non-labor income other than pensions 
gen dnlinc_otro=(tp48ay==2 | tp48rp==5 | tp48id==6 | tp48ot==7)  if dnlinc==1 
gen aux2=1 if (tp48ay==98 | tp48ay==99 | tp48rp==98 | tp48rp==99 | tp48id==98 | tp48id==99 | tp48ot==98 | tp48ot==99) 
replace dnlinc_otro=1 if aux2==1 & (tp48m!=98 & tp48m!=99 & tp48m!=0 & tp48m!=.) 
gen nlinc_otro=tp48m if (tp48m!=98 & tp48m!=99 & tp48m!=0) & dnlinc_otro==1
replace nlinc_otro=0 if dnlinc==0
* Missing values
gen dnlinc_otro_miss1=(aux2==1 & (tp48m==98 | tp48m==99 | tp48m==0 | tp48m==.)) if dnlinc_otro==1
gen dnlinc_otro_miss2=(dnlinc_otro==1 & (tp48m==98 | tp48m==99 | tp48m==0 | tp48m==.)) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1 
* Checking missing values
mdesc nlinc_otro if dnlinc_otro==1
tab dnlinc_otro_miss3 if dnlinc_otro==1
note: fine!!

gen pension=pension_IVSS+pension_epu+pension_epr+pension_ot //variable to use for imputation
replace pension=tp48m if pension==. & djubpen==1 & tp48m!=98 & tp48m!=99 & tp48m!=0 & dnlinc_jubpen==1 & recibe==1
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing //variable to replicate ENCOVI poverty estimates

*** Scenario 0: ENCOVI estimates
egen income_off0=rowtotal(linc nlinc pension2) //official individual income (this is equivalent to impute with zero the missing values)
bysort id: egen income_off_hh0 = sum(income_off)
bysort id: gen n_break = _N
gen nodecla0=(tp47m==99) | (tp47m < 98 & (tp47==1 | tp47==99)) | (tp48m==99) | (pp61sm ==99 | pp61em==99 | pp61pm==99 | pp61pm==99) //error en codigo encovi
egen nodecla_hh0 = sum(nodecla0==1), by(id) 
gen ingper0 = income_off_hh0 / n_break 

*** Variables for Mincer equation
* edad, sexo, relacion, estado civil, region, municipio, tipo de vivienda, regimen vivienda, activos del hogar, seguro salud, educacion, tipo de empleo, sector de trabajo, tipo contrato, tamano empresa, horas trabajadas, tipo de pension, pension de sobreviviente, beneficiario mision 
** Relation to the head
clonevar relacion_en=mhp15
clonevar relacion=mhp15 if mhp15!=98 & mhp15!=99
gen jefe=relacion==1
** Household size
gen hogarsec =.
replace hogarsec =1 if relacion_en==12
replace hogarsec = 0 if inrange(relacion_en,1,11) 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)
** Age
clonevar edad=mhp16
** Sex
clonevar sexo = mhp17 if mhp17!=98 & mhp17!=99
gen hombre=sexo==1 if sexo!=.
** Marital status
gen estado_civil_en= 1 if mhp18==1 | mhp18==2 //married 
replace estado_civil_en= 2 if mhp18==3 | mhp18==4 //living together
replace estado_civil_en= 3 if mhp18==5 | mhp18==6 //divorced/separated
replace estado_civil_en= 4 if mhp18==7 //widowed 
replace estado_civil_en= 5 if mhp18==8 //single
replace estado_civil_en= 6 if (mhp18==99 | mhp18==98) //NS/NR
tab estado_civil_en if ocupado==1
gen estado_civil = estado_civil_en if estado_civil_en!=6
** States
bysort id: egen entidad=max(enti)
** County
gen municipio= .
** Type of dwelling
clonevar tipo_vivienda_en=vp4
tab tipo_vivienda_en if ocupado==1
gen tipo_vivienda=vp4 if vp4!=98 & vp4!=99
** Housing tenure
clonevar tenencia_vivienda_en=hp13
tab tenencia_vivienda_en if ocupado==1
gen tenencia_vivienda=hp13 if hp13!=98 & hp13!=99
gen propieta_en = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2 
replace propieta_en = 2		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=8 
replace propieta_en = 3		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
tab propieta_en if ocupado==1
gen propieta = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2
replace propieta = 0		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=8
replace propieta = .		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
** Durables
* Car
gen     auto_en = 1 if hp11>0 & (hp11!=98 & hp11!=99)
replace auto_en = 2 if hp11==0
replace auto_en = 3 if (hp11==98 | hp11==99)
tab auto_en if ocupado==1
gen     auto = hp11>0 if (hp11!=98 & hp11!=99)
* Heladera (hp12n): ¿Posee este hogar nevera?
clonevar     heladera_en = hp12n
recode heladera_en (98 99=3)
tab heladera_en if ocupado==1
gen     heladera = hp12n==1 if (hp12n!=98 & hp12n!=99)
* Lavarropas (hp12l): ¿Posee este hogar lavadora?
clonevar     lavarropas_en = hp12l
recode lavarropas_en (98 99=3)
tab lavarropas_en if ocupado==1
gen     lavarropas = hp12l==1 if (hp12l!=98 & hp12l!=99)
* Secadora (hp12s): ¿Posee este hogar secadora? 
clonevar    secadora_en = hp12s
recode secadora_en (98 99=3)
tab secadora_en if ocupado==1
gen     secadora = hp12s==1 if (hp12s!=98 & hp12s!=99)
* Computadora (hp12c): ¿Posee este hogar computadora?
clonevar computadora_en = hp12c
recode computadora_en (98 99=3)
tab computadora_en if ocupado==1
gen computadora = hp12c==1 if (hp12c!=98 & hp12c!=99)
* Internet (hp12i): ¿Posee este hogar internet?
clonevar     internet_en = hp12i
recode internet_en (98 99=3)
tab internet_en if ocupado==1
gen     internet = hp12i==1 if (hp12i!=98 & hp12i!=99) 
* Televisor (hp12t): ¿Posee este hogar televisor?
clonevar     televisor_en = hp12t
recode televisor_en (98 99=3)
tab televisor_en if ocupado==1
gen     televisor = hp12t==1 if (hp12t!=98 & hp12t!=99)
* Radio (hp12r): ¿Posee este hogar radio? 
clonevar     radio_en = hp12r
recode radio_en (98 99=3)
tab radio_en if ocupado==1
gen     radio = hp12r==1 if (hp12r!=98 & hp12r!=99)
* Calentador (hp12o): ¿Posee este hogar calentador? 
clonevar     calentador_en = hp12o
recode calentador_en (98 99=3)
tab calentador_en if ocupado==1
gen     calentador = hp12o==1 if (hp12o!=98 & hp12o!=99)
* Aire acondicionado (hp12a): ¿Posee este hogar aire acondicionado?
clonevar     aire_en = hp12a
recode aire_en (98 99=3)
tab  aire_en if ocupado==1
gen     aire = hp12a==1 if (hp12a!=98 & hp12a!=99)
* TV por cable o satelital (hp12v): ¿Posee este hogar TV por cable?
clonevar     tv_cable_en = hp12v
recode tv_cable_en (98 99=3)
tab tv_cable_en if ocupado==1
gen     tv_cable = hp12v==1 if (hp12v!=98 & hp12v!=99)
* Horno microonada (hp12h): ¿Posee este hogar horno microonda?
clonevar     microondas_en = hp12h
recode microondas_en (98 99=3)
tab microondas_en if ocupado==1
gen     microondas = hp12h==1 if (hp12h!=98 & hp12h!=99)
** Health insurance
gen afiliado_seguro_salud = 1     if sp20==1 
replace afiliado_seguro_salud = 2 if sp20==2 
replace afiliado_seguro_salud = 3 if sp20==3 
replace afiliado_seguro_salud = 4 if sp20==4
replace afiliado_seguro_salud = 5 if sp20==5
replace afiliado_seguro_salud = 6 if sp20==6
replace afiliado_seguro_salud = . if sp20==98 | sp20==99
gen     seguro_salud_en = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud_en = 2	if  afiliado_seguro_salud==6
replace seguro_salud_en = 3	if  afiliado_seguro_salud==.
tab seguro_salud_en if ocupado==1
gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6
** Educational attainment
clonevar nivel_educ_en = ep30n
recode nivel_educ_en (98 99=8)
tab nivel_educ_en if ocupado==1
gen nivel_educ = ep30n if (ep30n!=98 & ep30n!=99)
** Type of employment
clonevar categ_ocu_en = tp46
recode categ_ocu_en (98 99=10)
tab categ_ocu_en if ocupado==1
gen categ_ocu = tp46    if (tp46!=98 & tp46!=99)
** Number of hours worked
gen nhorast = tp51 if (tp51!=98 & tp51!=99 & tp51!=0)
gen categ_nhorast_en= 1 if nhorast>=1 & nhorast<=20
replace categ_nhorast_en= 2 if nhorast>=21 & nhorast<=45
replace categ_nhorast_en= 3 if nhorast>=45 & nhorast!=.
replace categ_nhorast_en= 4 if tp51==98 | tp51==99 | tp51==0
tab categ_nhorast_en if ocupado==1
gen categ_nhorast= categ_nhorast_en if categ_nhorast_en!=4
** Firm size
clonevar firm_size_en = tp45
recode firm_size_en (98 99 = 8)
tab firm_size_en if ocupado==1
gen firm_size = tp45 if (tp45!=98 & tp45!=99)
** Type of contract
gen     contrato_en = 1 if (tp49== 1 | tp49==2)
replace contrato_en = 2 if (tp49== 3 | tp49==4)
replace contrato_en = 3 if (tp49== 98 | tp49==99)
tab contrato_en if ocupado==1
gen     contrato = 1 if (tp49== 1 | tp49==2)
replace contrato = 0 if (tp49== 3 | tp49==4)
** Type of pension (vejez, invalidez, incapacidad, sobreviviente)
*Vejez
clonevar pension_vejez_en=pp60ve if djubpen==1
recode pension_vejez_en (0=2) (98 99=3)
tab pension_vejez_en if djubpen==1
gen pension_vejez = pp60ve==1 if djubpen==1 & pp60ve!=98 & pp60ve!=99
*Invalidez
clonevar pension_inva_en=pp60iv if djubpen==1
recode pension_inva_en (2=1) (0=2) (98 99=3)
tab pension_inva_en if djubpen==1
gen pension_inva = pp60iv==2 if djubpen==1 & pp60iv!=98 & pp60iv!=99
*Incapacidad u Otra
gen pension_otra_en=1 if (pp60ic==3 | pp60ot==5) & djubpen==1
replace pension_otra_en =2 if (pp60ic==0 & pp60ot==0) & djubpen==1
replace pension_otra_en =3 if (pp60ic==98 | pp60ic==99 | pp60ic==.) & (pp60ot==98 | pp60ot==99 | pp60ot==.) & djubpen==1
tab pension_otra_en if djubpen==1,m
recode pension_otra_en (.=3) if pension_otra_en==. & djubpen==1
gen pension_otra = (pp60ic==3 | pp60ot==5) if (pp60ic!=98 & pp60ic!=99) & (pp60ot!=98 & pp60ot!=99) & djubpen==1
** Survivor pension
clonevar pension_sobrev_en=pp60sv if djubpen==1
recode pension_sobrev_en (4=1)(0=2) (98 99=3)
tab pension_sobrev_en if djubpen==1
gen pension_sobrev = pp60sv==4 if djubpen==1 & pp60sv!=98 & pp60sv!=99
** Contribute to pensions
clonevar contribu_pen_en=pp62
tab contribu_pen_en if djubpen==1
recode contribu_pen_en (98 99=3)
gen contribu_pen=pp62==1 if pp62!=98 & pp62!=99
** Beneficiario misiones
clonevar misiones_en=psp63
recode misiones_en (98 99=3)
gen misiones=psp63==1 if psp63!=98 & psp63!=99

local demo relacion_en relacion hogarsec jefe miembros edad sexo hombre estado_civil_en estado_civil entidad municipio
local xvar_en tipo_vivienda_en tenencia_vivienda_en propieta_en auto_en heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en ///
              tv_cable_en microondas_en seguro_salud_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en misiones_en
local xvar tipo_vivienda tenencia_vivienda propieta auto heladera lavarropas secadora computadora internet televisor radio calentador aire ///
              tv_cable microondas seguro_salud nivel_educ categ_ocu categ_nhorast nhorast firm_size contrato pension_vejez pension_inva pension_otra pension_sobrev contribu_pen misiones

mdesc `demo' if ocupado==1
mdesc `xvar' if ocupado==1

*** Keep data base with variables of interest
gen year=2016
gen pondera = xxp
order year id com
sort year id com
keep year id com pondera ocupado dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension pension2 dnlinc nlinc /*dnlinc_zero*/ dnlinc_miss1 dnlinc_miss2 dnlinc_miss3 ///
dnlinc_jubpen nlinc_jubpen /*dnlinc_jubpen_zero*/ dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro /*dnlinc_otro_zero*/ dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
income_off0 income_off_hh0 nodecla0 nodecla_hh0 n_break ingper0 ///
`demo' `xvar_en' `xvar'
*merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2016.dta"
tempfile encovi2016
save `encovi2016', replace

********************************************************************************
*** 2017
********************************************************************************
use "$data2017\VACUNACIÓN.dta", clear
rename LINVACU LIN
tempfile vacu
save `vacu'
use "$data2017\PERSONAS_ENCOVI_2017.dta", clear
rename ennumc ENNUMC
merge m:1 ENNUMC using "$data2017\HOGARES_ENCOVI2017.dta"
drop _merge
merge 1:1 ENNUMC LIN using `vacu'  //UNA OBS EN VACUNACION Y NO EN PERSONAS (TODO MISSING)
drop if _merge==2
tab CMHP18 if _merge==3 //cuatro observacions con edad mayor a 2
*brow if _merge==3 & CMHP18>2
drop _merge
/*
merge 1:1 ENNUM LIN using "$data2017\EMIGRACIÓN2017.dta" //NO ME QUEDA CLARO SI SE PUEDE HACER EL CRUCE (no hay identificador unico)
drop _merge
*/
rename _all, lower

rename ennumc id
rename lin com

*** Labor Income
capture drop ocupado
gen ocupado=(tmhp36==1 | tmhp36==2) if (tmhp36!=98 | tmhp36!=99)
replace ocupado=1 if ocupado==. & (tmhp44bs!=98 & tmhp44bs!=99 & tmhp44bs!=0 & tmhp44bs!=.) //those who reported missing in labor force status but have positive labor income
gen dlinc=1 if tmhp44==1 & ocupado==1 //dummy receive labor income
replace dlinc=1 if (tmhp44==98 | tmhp44==99) & (tmhp44bs!=98 & tmhp44bs!=99 & tmhp44bs!=0 & tmhp44bs!=.) & ocupado==1 //those who reported they do not know if they received income, but then declare positive labor income
replace dlinc=0 if tmhp44==2 & ocupado==1 // real zeros: those who are employed but did not received labor income
replace dlinc=0 if ocupado==0 //those not employed
gen linc=tmhp44bs if (tmhp44bs!=98 & tmhp44bs!=99 & tmhp44bs!=0) & dlinc==1 //value labor income
replace linc= 0 if dlinc==0
* Missing values
gen dlinc_zero=tmhp44==2 if ocupado==1 //real zreros
gen dlinc_miss1=((tmhp44==98 | tmhp44==99) & (tmhp44bs==98 | tmhp44bs==99 | tmhp44bs==0 | tmhp44bs==.)) if ocupado==1 //those who reported they do not know if they received income and also have missing values in labor income
gen dlinc_miss2=(dlinc==1 & (tmhp44bs==98 | tmhp44bs==99 | tmhp44bs==0 | tmhp44bs==.)) if ocupado==1 //those who reported they received labor income, but they did not declare the amount
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if ocupado==1 //all missing values
* Checking missing values
mdesc linc if ocupado==1
tab dlinc_miss3
note: fine!!

*** Pensions 
gen djubpen=(pmhp58j==1 | pmhp58p==2) if pmhp58j!=98 & pmhp58j!=99 & pmhp58p!=98 & pmhp58p!=99
replace djubpen=1 if djubpen==. & (pmhp60a!=98 & pmhp60a!=99 & pmhp60a!=0) & (pmhp60b!=98 & pmhp60b!=99 & pmhp60b!=0) & (pmhp60c!=98 & pmhp60c!=99 & pmhp60c!=0) & (pmhp60d!=98 & pmhp60d!=99 & pmhp60d!=0)
** IVSS
gen dpension_IVSS=1 if pmhp60a==1 & djubpen==1 
replace dpension_IVSS=1 if (pmhp60a==98 | pmhp60a==99) & (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & djubpen==1
replace dpension_IVSS=0 if pmhp60a==0 & djubpen==1 
replace dpension_IVSS=0 if djubpen==0 
gen pension_IVSS=pmhp60bs if (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & dpension_IVSS==1 
replace pension_IVSS=0 if dpension_IVSS==0 
* Missing values
gen dpension_IVSS_zero=pmhp60a==0 if djubpen==1 //real zeros
gen dpension_IVSS_miss1=((pmhp60a==98 | pmhp60a==99) & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1 
gen dpension_IVSS_miss2=(dpension_IVSS==1 & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_IVSS if djubpen==1
tab dpension_IVSS_miss3
note: fine!!

** Empresa publica
gen dpension_epu=1 if pmhp60b==2 & djubpen==1  
replace dpension_epu=1 if (pmhp60b==98 | pmhp60b==99) & (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & djubpen==1
replace dpension_epu=0 if pmhp60b==0 & djubpen==1 
replace dpension_epu=0 if djubpen==0 
gen pension_epu=pmhp60bs if (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & dpension_epu==1 
replace pension_epu=0 if dpension_epu==0
* Missing values
gen dpension_epu_zero=pmhp60b==0 if djubpen==1 //real zeros
gen dpension_epu_miss1=((pmhp60b==98 | pmhp60b==99) & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1 
gen dpension_epu_miss2=(dpension_epu==1 & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epu if djubpen==1
tab dpension_epu_miss3
note: fine!!

** Empresa privada
gen dpension_epr=1 if pmhp60c==3 & djubpen==1 
replace dpension_epr=1 if (pmhp60c==98 | pmhp60c==99) & (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & djubpen==1
replace dpension_epr=0 if pmhp60c==0 & djubpen==1 
replace dpension_epr=0 if djubpen==0 
gen pension_epr=pmhp60bs if (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & dpension_epr==1 
replace pension_epr=0 if dpension_epr==0
* Missing values
gen dpension_epr_zero=pmhp60c==0 if djubpen==1 //real zeros
gen dpension_epr_miss1=((pmhp60c==98 | pmhp60c==99) & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1 
gen dpension_epr_miss2=(dpension_epr==1 & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epr if djubpen==1
tab dpension_epr_miss3
note: fine!!

** Otra
gen dpension_ot=1 if pmhp60d==4 & djubpen==1
replace dpension_ot=1 if (pmhp60d==98 | pmhp60d==99) & (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & djubpen==1
replace dpension_ot=0 if pmhp60d==0 & djubpen==1 
replace dpension_ot=0 if djubpen==0 
gen pension_ot=pmhp60bs if (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & dpension_ot==1 
replace pension_ot=0 if dpension_ot==0
* Missing values
gen dpension_ot_zero=pmhp60d==0 if djubpen==1 //real zeros
gen dpension_ot_miss1=((pmhp60d==98 | pmhp60d==99) & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1 
gen dpension_ot_miss2=(dpension_ot==1 & (pmhp60bs==98 | pmhp60bs==99 | pmhp60bs==0)) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_ot if djubpen==1
tab dpension_ot_miss3
note: fine!!

*** Non-labor income
gen ing_nlb_pe = 1  if tmhp45pe==1 // Pensión de vejez
gen ing_nlb_op = 1  if tmhp45op==2 // Otra pensión del IVSS (invalidez, incapacidad, sobreviviente)
gen ing_nlb_ju = 1  if tmhp45ju==3 // Jubilación por trabajo
gen ing_nlb_af = 1  if tmhp45af==4 // Ayuda económica de algún familiar o de otra persona en el país
gen ing_nlb_ax = 1  if tmhp45ax==5 // Ayuda económica de algún familiar o de otra persona desde el exterior
gen ing_nlb_ps = 1  if tmhp45ps==6 // Pensión de la seguridad social de otro país
gen ing_nlb_re = 1  if tmhp45re==7 // Renta de propiedades
gen ing_nlb_id = 1  if tmhp45id==8 // Intereses o dividendos
gen ing_nlb_ot = 1  if tmhp45ot==9 // Otro
gen ing_nlb_ni = 1  if tmhp45ni==10 // Ninguno
gen ing_nlb_nsr = 1 if tmhp45nsr==11 // NS/NR
egen  recibe = rowtotal(ing_nlb_*) if ing_nlb_ni!= 1 | ing_nlb_nsr!= 1, mi //number of non-labor income sources that the household received

gen dnlinc=(tmhp45pe==1 | tmhp45op==2 | tmhp45ju==3 | tmhp45af==4 | tmhp45ax==5 | tmhp45ps==6 | tmhp45re==7 | tmhp45id==8 | tmhp45ot==9)


gen aux=1 if (tmhp45pe==98 | tmhp45op==98 | tmhp45ju==98 | tmhp45af==98 | tmhp45ax==98 | tmhp45ps==98 | tmhp45re==98 | tmhp45id==98 | tmhp45ot==98 | ///
              tmhp45pe==99 | tmhp45op==99 | tmhp45ju==99 | tmhp45af==99 | tmhp45ax==99 | tmhp45ps==99 | tmhp45re==99 | tmhp45id==99 | tmhp45ot==99 )

replace dnlinc=1 if aux==1 &  (tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0 & tmhp45bs!=.)
gen nlinc=tmhp45bs if (tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0) & dnlinc==1
replace nlinc=0 if dnlinc==0
* Missing values
gen dnlinc_miss1=(aux==1 & (tmhp45bs==98 | tmhp45bs==99 | tmhp45bs==0 | tmhp45bs==.)) if dnlinc==1
gen dnlinc_miss2=(dnlinc==1 & (tmhp45bs==98 | tmhp45bs==99 | tmhp45bs==0 | tmhp45bs==.)) if dnlinc==1
gen dnlinc_miss3=(dnlinc_miss1==1 | dnlinc_miss2==1) if dnlinc==1
* Checking missing values
mdesc nlinc if dnlinc==1
tab dnlinc_miss3 if dnlinc==1
note: fine!!


** Pensions (from the non-labor income question)
gen dnlinc_jubpen=((tmhp45pe==1 | tmhp45op==2 | tmhp45ju==3)) if dnlinc==1 
gen aux1=1 if (tmhp45pe==98 | tmhp45op==98 | tmhp45ju==98 | tmhp45pe==99 | tmhp45op==99 | tmhp45ju==99 )
replace dnlinc_jubpen=1 if aux1==1 & (tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0 & tmhp45bs!=.) 
gen nlinc_jubpen=tmhp45bs if (tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0) & dnlinc_jubpen==1
replace nlinc_jubpen=0 if dnlinc==0
* Missing values
gen dnlinc_jubpen_miss1=(aux1==1 & (tmhp45bs==98 | tmhp45bs==99 | tmhp45bs==0 | tmhp45bs==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(dnlinc_jubpen==1 & (tmhp45bs==98 | tmhp45bs==99 | tmhp45bs==0 | tmhp45bs==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1 
* Checking missing values
mdesc nlinc_jubpen if dnlinc_jubpen==1
tab dnlinc_jubpen_miss3 if dnlinc_jubpen==1
note: fine!!

** Non-labor income other than pensions 
gen dnlinc_otro=(tmhp45af==4 | tmhp45ax==5 | tmhp45ps==6 | tmhp45re==7 | tmhp45id==8 | tmhp45ot==9)  if dnlinc==1 
gen aux2=1 if (tmhp45af==98 | tmhp45ax==98 | tmhp45ps==98 | tmhp45re==98 | tmhp45id==98 | tmhp45ot==98 | ///
               tmhp45af==99 | tmhp45ax==99 | tmhp45ps==99 | tmhp45re==99 | tmhp45id==99 | tmhp45ot==99 )
replace dnlinc_otro=1 if aux2==1 & (tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0 & tmhp45bs!=.) 
gen nlinc_otro=tmhp45bs if (tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0) & dnlinc_otro==1
replace nlinc_otro=0 if dnlinc==0
* Missing values
gen dnlinc_otro_miss1=(aux2==1 & (tmhp45bs==98 | tmhp45bs==99 | tmhp45bs==0 | tmhp45bs==.)) if dnlinc_otro==1
gen dnlinc_otro_miss2=(dnlinc_otro==1 & (tmhp45bs==98 | tmhp45bs==99 | tmhp45bs==0 | tmhp45bs==.)) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1 
* Checking missing values
mdesc nlinc_otro if dnlinc_otro==1
tab dnlinc_otro_miss3 if dnlinc_otro==1
note: fine!!

gen pension=pmhp60bs if (pmhp60bs!=98 & pmhp60bs!=99 & pmhp60bs!=0) & djubpen==1 //variable to use for imputation
replace pension=0 if djubpen==0 
replace pension=tmhp45bs if pension==. & djubpen==1 & tmhp45bs!=98 & tmhp45bs!=99 & tmhp45bs!=0 & dnlinc_jubpen==1 & recibe==1
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing //variable to replicate ENCOVI poverty estimates

*** Scenario 0: ENCOVI estimates
egen income_off0=rowtotal(linc nlinc pension2) //official individual income (this is equivalent to impute with zero the missing values) 
bysort id: egen income_off_hh0 = sum(income_off0)
bysort id: gen n_break = _N
gen nodecla0=(tmhp44bs==99) | (tmhp44==99) | (tmhp45bs==99) | (pmhp60bs==99) | (pmhp60a==99)
egen nodecla_hh0 = sum(nodecla0==1), by(id) 
gen ingper0 = income_off_hh0 / n_break 

*** Variables for Mincer equation
* edad, sexo, relacion, estado civil, region, municipio, tipo de vivienda, regimen vivienda, activos del hogar, seguro salud, educacion, tipo de empleo, sector de trabajo, tipo contrato, tamano empresa, horas trabajadas, tipo de pension, pension de sobreviviente, beneficiario mision 
** Relation to the head
clonevar relacion_en=cmhp17
clonevar relacion=cmhp17 if cmhp17!=98 & cmhp17!=99
gen jefe=relacion==1
** Household size
gen hogarsec =.
replace hogarsec =1 if relacion_en==13
replace hogarsec = 0 if inrange(relacion_en,1,12) 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)
** Age
clonevar edad=cmhp18
** Sex
clonevar sexo = cmhp19 if cmhp19!=98 & cmhp19!=99
gen hombre=sexo==1 if sexo!=.
** Marital status
gen estado_civil_en= 1 if cmhp22==1 | cmhp22==2 //married 
replace estado_civil_en= 2 if cmhp22==3 | cmhp22==4 //living together
replace estado_civil_en= 3 if cmhp22==5 | cmhp22==6 //divorced/separated
replace estado_civil_en= 4 if cmhp22==7 //widowed 
replace estado_civil_en= 5 if cmhp22==8 //single
replace estado_civil_en= 6 if (cmhp22==99 | cmhp22==98) //NS/NR
tab estado_civil_en if ocupado==1
gen estado_civil = estado_civil_en if estado_civil_en!=6
** States
capture drop aux
bysort id: egen aux=max(entidad)
drop entidad
rename aux entidad
** County
gen municipio= .
** Type of dwelling
clonevar tipo_vivienda_en=vsp4
tab tipo_vivienda_en if ocupado==1
gen tipo_vivienda=vsp4 if vsp4!=98 & vsp4!=99
** Housing tenure
clonevar tenencia_vivienda_en=hp15
tab tenencia_vivienda_en if ocupado==1
gen tenencia_vivienda=hp15 if hp15!=98 & hp15!=99
gen propieta_en = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2 
replace propieta_en = 2		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=8 
replace propieta_en = 3		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
tab propieta_en if ocupado==1
gen propieta = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2
replace propieta = 0		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=8
replace propieta = .		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
** Durables
* Car
gen     auto_en = 1 if dhp13>0 & (dhp13!=98 & dhp13!=99)
replace auto_en = 2 if dhp13==0
replace auto_en = 3 if (dhp13==98 | dhp13==99)
tab auto_en if ocupado==1
gen     auto = dhp13>0 if (dhp13!=98 & dhp13!=99)
* Heladera (hp14n): ¿Posee este hogar nevera?
clonevar     heladera_en = hp14n
recode heladera_en (98 99=3)
tab heladera_en if ocupado==1
gen     heladera = hp14n==1 if (hp14n!=98 & hp14n!=99)
* Lavarropas (hp14l): ¿Posee este hogar lavadora?
clonevar     lavarropas_en = hp14l
recode lavarropas_en (98 99=3)
tab lavarropas_en if ocupado==1
gen     lavarropas = hp14l==1 if (hp14l!=98 & hp14l!=99)
* Secadora (hp14s): ¿Posee este hogar secadora? 
clonevar    secadora_en = hp14s
recode secadora_en (98 99=3)
tab secadora_en if ocupado==1
gen     secadora = hp14s==1 if (hp14s!=98 & hp14s!=99)
* Computadora (hp14c): ¿Posee este hogar computadora?
clonevar computadora_en = hp14c
recode computadora_en (98 99=3)
tab computadora_en if ocupado==1
gen computadora = hp14c==1 if (hp14c!=98 & hp14c!=99)
* Internet (hp14i): ¿Posee este hogar internet?
clonevar     internet_en = hp14i
recode internet_en (98 99=3)
tab internet_en if ocupado==1
gen     internet = hp14i==1 if (hp14i!=98 & hp14i!=99) 
* Televisor (hp14t): ¿Posee este hogar televisor?
clonevar     televisor_en = hp14t
recode televisor_en (98 99=3)
tab televisor_en if ocupado==1
gen     televisor = hp14t==1 if (hp14t!=98 & hp14t!=99)
* Radio (hp14r): ¿Posee este hogar radio? 
clonevar     radio_en = hp14r
recode radio_en (98 99=3)
tab radio_en if ocupado==1
gen     radio = hp14r==1 if (hp14r!=98 & hp14r!=99)
* Calentador (hp14o): ¿Posee este hogar calentador? 
clonevar     calentador_en = hp14o
recode calentador_en (98 99=3)
tab calentador_en if ocupado==1
gen     calentador = hp14o==1 if (hp14o!=98 & hp14o!=99)
* Aire acondicionado (hp14a): ¿Posee este hogar aire acondicionado?
clonevar     aire_en = hp14a
recode aire_en (98 99=3)
tab  aire_en if ocupado==1
gen     aire = hp14a==1 if (hp14a!=98 & hp14a!=99)
* TV por cable o satelital (hp14v): ¿Posee este hogar TV por cable?
clonevar     tv_cable_en = hp14v
recode tv_cable_en (98 99=3)
tab tv_cable_en if ocupado==1
gen     tv_cable = hp14v==1 if (hp14v!=98 & hp14v!=99)
* Horno microonada (hp14h): ¿Posee este hogar horno microonda?
clonevar     microondas_en = hp14h
recode microondas_en (98 99=3)
tab microondas_en if ocupado==1
gen     microondas = hp14h==1 if (hp14h!=98 & hp14h!=99)
** Health insurance
gen afiliado_seguro_salud = 1     if cmhp25a==1 
replace afiliado_seguro_salud = 2 if cmhp25b==2 
replace afiliado_seguro_salud = 3 if cmhp25c==3 
replace afiliado_seguro_salud = 4 if cmhp25d==4
replace afiliado_seguro_salud = 5 if cmhp25e==5
replace afiliado_seguro_salud = 6 if cmhp25f==6
replace afiliado_seguro_salud = . if cmhp25f==98 | cmhp25f==99
gen     seguro_salud_en = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud_en = 2	if  afiliado_seguro_salud==6
replace seguro_salud_en = 3	if  afiliado_seguro_salud==.
tab seguro_salud_en if ocupado==1
gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6
** Educational attainment
clonevar nivel_educ_en = emhp28n
recode nivel_educ_en (98 99=8)
tab nivel_educ_en if ocupado==1
gen nivel_educ = emhp28n if (emhp28n!=98 & emhp28n!=99)
** Type of employment
clonevar categ_ocu_en = tmhp43
recode categ_ocu_en (98 99=10)
tab categ_ocu_en if ocupado==1
gen categ_ocu = tmhp43   if (tmhp43!=98 & tmhp43!=99)
** Number of hours worked
gen nhorast = tmhp48 if (tmhp48!=98 & tmhp48!=99 & tmhp48!=0)
gen categ_nhorast_en= 1 if nhorast>=1 & nhorast<=20
replace categ_nhorast_en= 2 if nhorast>=21 & nhorast<=45
replace categ_nhorast_en= 3 if nhorast>=45 & nhorast!=.
replace categ_nhorast_en= 4 if tmhp48==98 | tmhp48==99 | tmhp48==0
tab categ_nhorast_en if ocupado==1
gen categ_nhorast= categ_nhorast_en if categ_nhorast_en!=4
** Firm size
clonevar firm_size_en = tmhp42
recode firm_size_en (98 99 = 8)
tab firm_size_en if ocupado==1
gen firm_size = tmhp42 if (tmhp42!=98 & tmhp42!=99)
** Type of contract
gen     contrato_en = 1 if (tmhp46== 1 | tmhp46==2)
replace contrato_en = 2 if (tmhp46== 3 | tmhp46==4)
replace contrato_en = 3 if (tmhp46== 98 | tmhp46==99)
tab contrato_en if ocupado==1
gen     contrato = 1 if (tmhp46== 1 | tmhp46==2)
replace contrato = 0 if (tmhp46== 3 | tmhp46==4)
** Type of pension (vejez, invalidez, incapacidad, sobreviviente)
*Vejez
clonevar pension_vejez_en=pmhp59a if djubpen==1
recode pension_vejez_en (0=2) (98 99=3)
tab pension_vejez_en if djubpen==1
gen pension_vejez = pmhp59a==1 if djubpen==1 & pmhp59a!=98 & pmhp59a!=99
*Invalidez
clonevar pension_inva_en=pmhp59b if djubpen==1
recode pension_inva_en (2=1) (0=2) (98 99=3)
tab pension_inva_en if djubpen==1
gen pension_inva = pmhp59b==2 if djubpen==1 & pmhp59b!=98 & pmhp59b!=99
*Incapacidad u Otra
gen pension_otra_en=1 if (pmhp59c==3 | pmhp59f==5) & djubpen==1
replace pension_otra_en =2 if (pmhp59c==0 & pmhp59f==0) & djubpen==1
replace pension_otra_en =3 if (pmhp59c==98 | pmhp59c==99) & (pmhp59f==98 | pmhp59f==99) & djubpen==1
tab pension_otra_en if djubpen==1, m
recode pension_otra_en (.=3) if pension_otra_en==. & djubpen==1
gen pension_otra = (pmhp59c==3 | pmhp59f==5) if (pmhp59c!=98 & pmhp59c!=99) & (pmhp59f!=98 & pmhp59f!=99) & djubpen==1
** Survivor pension
clonevar pension_sobrev_en=pmhp59e if djubpen==1
recode pension_sobrev_en (4=1)(0=2) (98 99=3)
tab pension_sobrev_en if djubpen==1
gen pension_sobrev = pmhp59e==4 if djubpen==1 & pmhp59e!=98 & pmhp59e!=99
** Contribute to pensions
gen contribu_pen_en=1 if (pmhp611==1 | pmhp612==2 | pmhp613==3 | pmhp614==4) 
replace contribu_pen_en=2 if pmhp615==5
replace contribu_pen_en=3 if (pmhp611==98 | pmhp611==99) & (pmhp612==98 | pmhp612==99) & (pmhp613==98 | pmhp613==99) & (pmhp614==98 | pmhp614==99) & (pmhp615==98 | pmhp615==99)
tab contribu_pen_en if djubpen==1,m
recode contribu_pen_en (.=3) if contribu_pen_en==. & djubpen==1
gen contribu_pen=(pmhp611==1 | pmhp612==2 | pmhp613==3 | pmhp614==4) if (pmhp611!=98 & pmhp611!=99) & (pmhp612!=98 & pmhp612!=99) & (pmhp613!=98 & pmhp613!=99) & (pmhp614!=98 & pmhp614!=99) & (pmhp615!=98 & pmhp615!=99)
** Beneficiario misiones
destring mmhp62, replace
clonevar misiones_en=mmhp62
recode misiones_en (98 99=3)
gen misiones=mmhp62==1 if mmhp62!=98 & mmhp62!=99

local demo relacion_en relacion hogarsec jefe miembros edad sexo hombre estado_civil_en estado_civil entidad municipio
local xvar_en tipo_vivienda_en tenencia_vivienda_en propieta_en auto_en heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en ///
              tv_cable_en microondas_en seguro_salud_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en misiones_en
local xvar tipo_vivienda tenencia_vivienda propieta auto heladera lavarropas secadora computadora internet televisor radio calentador aire ///
              tv_cable microondas seguro_salud nivel_educ categ_ocu categ_nhorast nhorast firm_size contrato pension_vejez pension_inva pension_otra pension_sobrev contribu_pen misiones

mdesc `demo' if ocupado==1
mdesc `xvar' if ocupado==1

*** Keep data base with variables of interest
gen year=2017
gen pondera = pesopersona
order year id com
sort year id com
keep year id com pondera ocupado dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension pension2 dnlinc nlinc /*dnlinc_zero*/ dnlinc_miss1 dnlinc_miss2 dnlinc_miss3 ///
dnlinc_jubpen nlinc_jubpen /*dnlinc_jubpen_zero*/ dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro /*dnlinc_otro_zero*/ dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
income_off0 income_off_hh0 nodecla0 nodecla_hh0 n_break ingper0 ///
`demo' `xvar_en' `xvar'
*merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2017.dta"
tempfile encovi2017
save `encovi2017', replace

********************************************************************************
*** 2018
********************************************************************************
use "$data2018\VACUNACION.dta", clear
rename LINVACU LIN
tempfile vacu
save `vacu'
use "$data2018\PERSONAS ENCOVI 2018.dta", clear
merge m:1 ENNUM using "$data2018\HOGARES ENCOVI 2018.dta"
drop _merge
tab CMHP19 if EP96==1 // INCONSISTENCIA SEXO MASCULINO PARA PERSONAS QUE REPORTAN ESTAR EMBARAZADA
/*
    El sexo |
   de...es: |      Freq.     Percent        Cum.
------------+-----------------------------------
  Masculino |        140       48.28       48.28
   Femenino |        150       51.72      100.00
------------+-----------------------------------
      Total |        290      100.00
*/

merge 1:1 ENNUM LIN using "$data2018\Antropometria_2018.dta"
drop _merge
merge 1:1 ENNUM LIN using `vacu' 
tab CMHP18 if _merge==3 // hay dos observacions con edad mayor a 2, aunque las respuestas estas codificadas como NA
*brow if _merge==3 & CMHP18>2
drop _merge
/*
merge 1:1 ENNUM LIN using "$data2018\MIGRACION.dta" //NO ME QUEDA CLARO SI SE PUEDE HACER EL CRUCE (no hay identificador unico)
drop _merge
*/
rename _all, lower

rename ennum id
rename lin com

*** Labor Income
capture drop ocupado
gen ocupado=(tmhp34==1 | tmhp34==2) if (tmhp34!=98 | tmhp34!=99)
replace ocupado=1 if ocupado==. & (tmhp42bs!=98 & tmhp42bs!=99 & tmhp42bs!=0 & tmhp42bs!=.) //those who reported missing in labor force status but have positive labor income
gen dlinc=1 if tmhp42==1 & ocupado==1 //dummy receive labor income
replace dlinc=1 if (tmhp42==98 | tmhp42==99) & (tmhp42bs!=98 & tmhp42bs!=99 & tmhp42bs!=0 & tmhp42bs!=.) & ocupado==1 //those who reported they do not know if they received income, but then declare positive labor income
replace dlinc=0 if tmhp42==2 & ocupado==1 // real zeros: those who are employed but did not received labor income
replace dlinc=0 if ocupado==0 //those not employed
gen linc=tmhp42bs if (tmhp42bs!=98 & tmhp42bs!=99 & tmhp42bs!=0) & dlinc==1 //value labor income
replace linc= 0 if dlinc==0
* Missing values
gen dlinc_zero=tmhp42==2 if ocupado==1 //real zreros
gen dlinc_miss1=((tmhp42==98 | tmhp42==99) & (tmhp42bs==98 | tmhp42bs==99 | tmhp42bs==0 | tmhp42bs==.)) if ocupado==1 //those who reported they do not know if they received income and also have missing values in labor income
gen dlinc_miss2=(dlinc==1 & (tmhp42bs==98 | tmhp42bs==99 | tmhp42bs==0 | tmhp42bs==.)) if ocupado==1 //those who reported they received labor income, but they did not declare the amount
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if ocupado==1 //all missing values
* Checking missing values
mdesc linc if ocupado==1
tab dlinc_miss3
note: fine!!

*** Pensions 
gen djubpen=(pmhp53j==1 | pmhp53p==2) if pmhp53j!=98 & pmhp53j!=99 & pmhp53p!=98 & pmhp53p!=99
replace djubpen=1 if djubpen==. & (pmhp55ss!=98 & pmhp55ss!=99 & pmhp55ss!=0) & (pmhp55ep!=98 & pmhp55ep!=99 & pmhp55ep!=0) & (pmhp55ip!=98 & pmhp55ip!=99 & pmhp55ip!=0) & (pmhp55ot!=98 & pmhp55ot!=99 & pmhp55ot!=0)
** IVSS
gen dpension_IVSS=1 if pmhp55ss==1 & djubpen==1 
replace dpension_IVSS=1 if (pmhp55ss==98 | pmhp55ss==99) & (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0 & pmhp55bs!=.) & djubpen==1
replace dpension_IVSS=0 if pmhp55ss==0 & djubpen==1 
replace dpension_IVSS=0 if djubpen==0 
gen pension_IVSS=pmhp55bs if (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0 & pmhp55bs!=.) & dpension_IVSS==1 
replace pension_IVSS=0 if dpension_IVSS==0 
* Missing values
gen dpension_IVSS_zero=pmhp55ss==0 if djubpen==1 //real zeros
gen dpension_IVSS_miss1=((pmhp55ss==98 | pmhp55ss==99) & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0 | pmhp55bs==.)) if djubpen==1 
gen dpension_IVSS_miss2=(dpension_IVSS==1 & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0 | pmhp55bs==.)) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_IVSS if djubpen==1
tab dpension_IVSS_miss3
note: fine!!

** Empresa publica
gen dpension_epu=1 if pmhp55ep==2 & djubpen==1  
replace dpension_epu=1 if (pmhp55ep==98 | pmhp55ep==99) & (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0) & djubpen==1
replace dpension_epu=0 if pmhp55ep==0 & djubpen==1 
replace dpension_epu=0 if djubpen==0 
gen pension_epu=pmhp55bs if (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0) & dpension_epu==1 
replace pension_epu=0 if dpension_epu==0
* Missing values
gen dpension_epu_zero=pmhp55ep==0 if djubpen==1 //real zeros
gen dpension_epu_miss1=((pmhp55ep==98 | pmhp55ep==99) & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0)) if djubpen==1 
gen dpension_epu_miss2=(dpension_epu==1 & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0)) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epu if djubpen==1
tab dpension_epu_miss3
note: fine!!

** Empresa privada
gen dpension_epr=1 if pmhp55ip==3 & djubpen==1 
replace dpension_epr=1 if (pmhp55ip==98 | pmhp55ip==99) & (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0) & djubpen==1
replace dpension_epr=0 if pmhp55ip==0 & djubpen==1 
replace dpension_epr=0 if djubpen==0 
gen pension_epr=pmhp55bs if (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0) & dpension_epr==1 
replace pension_epr=0 if dpension_epr==0
* Missing values
gen dpension_epr_zero=pmhp55ip==0 if djubpen==1 //real zeros
gen dpension_epr_miss1=((pmhp55ip==98 | pmhp55ip==99) & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0)) if djubpen==1 
gen dpension_epr_miss2=(dpension_epr==1 & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0)) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_epr if djubpen==1
tab dpension_epr_miss3
note: fine!!

** Otra
gen dpension_ot=1 if pmhp55ot==4 & djubpen==1
replace dpension_ot=1 if (pmhp55ot==98 | pmhp55ot==99) & (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0) & djubpen==1
replace dpension_ot=0 if pmhp55ot==0 & djubpen==1 
replace dpension_ot=0 if djubpen==0 
gen pension_ot=pmhp55bs if (pmhp55bs!=98 & pmhp55bs!=99 & pmhp55bs!=0) & dpension_ot==1 
replace pension_ot=0 if dpension_ot==0
* Missing values
gen dpension_ot_zero=pmhp55ot==0 if djubpen==1 //real zeros
gen dpension_ot_miss1=((pmhp55ot==98 | pmhp55ot==99) & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0)) if djubpen==1 
gen dpension_ot_miss2=(dpension_ot==1 & (pmhp55bs==98 | pmhp55bs==99 | pmhp55bs==0)) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1
* Checking missing values
mdesc pension_ot if djubpen==1
tab dpension_ot_miss3
note: fine!!

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
gen aux=1 if (tmhp52pv==98 | tmhp52pi==98 | tmhp52jt==98 | tmhp52ef==98 | tmhp52af==98 | tmhp52pp==98 | tmhp52rp==98 | tmhp52id==98 | tmhp52ot==98 | ///
              tmhp52pv==99 | tmhp52pi==99 | tmhp52jt==99 | tmhp52ef==99 | tmhp52af==99 | tmhp52pp==99 | tmhp52rp==99 | tmhp52id==99 | tmhp52ot==99 )

replace dnlinc=1 if aux==1 &  (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0 & tmhp52bs!=.)
gen nlinc=tmhp52bs if (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0) & dnlinc==1
replace nlinc=0 if dnlinc==0
* Missing values
gen dnlinc_miss1=(aux==1 & (tmhp52bs==98 | tmhp52bs==99 | tmhp52bs==0 | tmhp52bs==.)) if dnlinc==1
gen dnlinc_miss2=(dnlinc==1 & (tmhp52bs==98 | tmhp52bs==99 | tmhp52bs==0 | tmhp52bs==.)) if dnlinc==1
gen dnlinc_miss3=(dnlinc_miss1==1 | dnlinc_miss2==1) if dnlinc==1
* Checking missing values
mdesc nlinc if dnlinc==1
tab dnlinc_miss3 if dnlinc==1
note: fine!!


** Pensions (from the non-labor income question)
gen dnlinc_jubpen=(tmhp52pv==1 | tmhp52pi==2 | tmhp52jt==3) if dnlinc==1 
gen aux1=1 if (tmhp52pv==98 | tmhp52pi==98 | tmhp52jt==98 | tmhp52pv==99 | tmhp52pi==99 | tmhp52jt==99)
replace dnlinc_jubpen=1 if aux1==1 & (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0 & tmhp52bs!=.) 
gen nlinc_jubpen=tmhp52bs if (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0) & dnlinc_jubpen==1
replace nlinc_jubpen=0 if dnlinc==0
* Missing values
gen dnlinc_jubpen_miss1=(aux1==1 & (tmhp52bs==98 | tmhp52bs==99 | tmhp52bs==0 | tmhp52bs==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(dnlinc_jubpen==1 & (tmhp52bs==98 | tmhp52bs==99 | tmhp52bs==0 | tmhp52bs==.)) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1 
* Checking missing values
mdesc nlinc_jubpen if dnlinc_jubpen==1
tab dnlinc_jubpen_miss3 if dnlinc_jubpen==1
note: fine!!

** Non-labor income other than pensions 
gen dnlinc_otro=(tmhp52ef==4 | tmhp52af==5 | tmhp52pp==6 | tmhp52rp==7 | tmhp52id==8 | tmhp52ot==9)  if dnlinc==1 
gen aux2=1 if (tmhp52ef==98 | tmhp52af==98 | tmhp52pp==98 | tmhp52rp==98 | tmhp52id==98 | tmhp52ot==98 | ///
              tmhp52ef==99 | tmhp52af==99 | tmhp52pp==99 | tmhp52rp==99 | tmhp52id==99 | tmhp52ot==99 )
replace dnlinc_otro=1 if aux2==1 & (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0 & tmhp52bs!=.) 
gen nlinc_otro=tmhp52bs if (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0) & dnlinc_otro==1
replace nlinc_otro=0 if dnlinc==0
* Missing values
gen dnlinc_otro_miss1=(aux2==1 & (tmhp52bs==98 | tmhp52bs==99 | tmhp52bs==0 | tmhp52bs==.)) if dnlinc_otro==1
gen dnlinc_otro_miss2=(dnlinc_otro==1 & (tmhp52bs==98 | tmhp52bs==99 | tmhp52bs==0 | tmhp52bs==.)) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1 
* Checking missing values
mdesc nlinc_otro if dnlinc_otro==1
tab dnlinc_otro_miss3 if dnlinc_otro==1
note: fine!!

gen pension=tmhp52bs if (tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0) & djubpen==1 //variable to use for imputation
replace pension=0 if djubpen==0 
replace pension=tmhp52bs if pension==. & djubpen==1 & tmhp52bs!=98 & tmhp52bs!=99 & tmhp52bs!=0 & tmhp52bs!=. & dnlinc_jubpen==1 & recibe==1
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing //variable to replicate ENCOVI poverty estimates

*** Scenario 0: ENCOVI estimates
egen income_off0=rowtotal(linc nlinc pension2) //official individual income (this is equivalent to impute with zero the missing values) 
bysort id: egen income_off_hh0 = sum(income_off0)
bysort id: gen n_break = _N
gen nodecla0=(tmhp42bs==99) | (tmhp42==99) | (tmhp52bs==99) | (pmhp55bs==99) | (pmhp55ss==99)
egen nodecla_hh0 = sum(nodecla0==1), by(id) 
gen ingper0 = income_off_hh0 / n_break 

*** Variables for Mincer equation
* edad, sexo, relacion, estado civil, region, municipio, tipo de vivienda, regimen vivienda, activos del hogar, seguro salud, educacion, tipo de empleo, sector de trabajo, tipo contrato, tamano empresa, horas trabajadas, tipo de pension, pension de sobreviviente, beneficiario mision 
** Relation to the head
clonevar relacion_en=cmhp17
clonevar relacion=cmhp17 if cmhp17!=98 & cmhp17!=99
gen jefe=relacion==1
** Household size
gen hogarsec =.
replace hogarsec =1 if relacion_en==13
replace hogarsec = 0 if inrange(relacion_en,1,12) 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion!=., by(id)
** Age
clonevar edad=cmhp18
** Sex
clonevar sexo = cmhp19 if cmhp19!=98 & cmhp19!=99
gen hombre=sexo==1 if sexo!=.
** Marital status
gen estado_civil_en= 1 if cmhp22==1 | cmhp22==2 //married 
replace estado_civil_en= 2 if cmhp22==3 | cmhp22==4 //living together
replace estado_civil_en= 3 if cmhp22==5 | cmhp22==6 //divorced/separated
replace estado_civil_en= 4 if cmhp22==7 //widowed 
replace estado_civil_en= 5 if cmhp22==8 //single
replace estado_civil_en= 6 if (cmhp22==99 | cmhp22==98) //NS/NR
tab estado_civil_en if ocupado==1
gen estado_civil = estado_civil_en if estado_civil_en!=6
** States
gen entidad= enti
** County
gen municipio= .
** Type of dwelling
clonevar tipo_vivienda_en=vsp4
tab tipo_vivienda_en if ocupado==1
gen tipo_vivienda=vsp4 if vsp4!=98 & vsp4!=99
** Housing tenure
clonevar tenencia_vivienda_en=dhp15
tab tenencia_vivienda_en if ocupado==1
gen tenencia_vivienda=dhp15 if dhp15!=98 & dhp15!=99
gen propieta_en = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2 
replace propieta_en = 2		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=8 
replace propieta_en = 3		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
tab propieta_en if ocupado==1
gen propieta = 1 if tenencia_vivienda_en==1 | tenencia_vivienda_en==2
replace propieta = 0		if  tenencia_vivienda_en>=3 & tenencia_vivienda_en<=8
replace propieta = .		if  tenencia_vivienda_en==98 | tenencia_vivienda_en==99
** Durables
* Car
gen     auto_en = 1 if dhp13>0 & (dhp13!=98 & dhp13!=99)
replace auto_en = 2 if dhp13==0
replace auto_en = 3 if (dhp13==98 | dhp13==99)
tab auto_en if ocupado==1
gen     auto = dhp13>0 if (dhp13!=98 & dhp13!=99)
* Heladera (dhp14n): ¿Posee este hogar nevera?
clonevar     heladera_en = dhp14n
recode heladera_en (98 99=3)
tab heladera_en if ocupado==1
gen     heladera = dhp14n==1 if (dhp14n!=98 & dhp14n!=99)
* Lavarropas (dhp14l): ¿Posee este hogar lavadora?
clonevar     lavarropas_en = dhp14l
recode lavarropas_en (98 99=3)
tab lavarropas_en if ocupado==1
gen     lavarropas = dhp14l==1 if (dhp14l!=98 & dhp14l!=99)
* Secadora (dhp14s): ¿Posee este hogar secadora? 
clonevar    secadora_en = dhp14s
recode secadora_en (98 99=3)
tab secadora_en if ocupado==1
gen     secadora = dhp14s==1 if (dhp14s!=98 & dhp14s!=99)
* Computadora (dhp14c): ¿Posee este hogar computadora?
clonevar computadora_en = dhp14c
recode computadora_en (98 99=3)
tab computadora_en if ocupado==1
gen computadora = dhp14c==1 if (dhp14c!=98 & dhp14c!=99)
* Internet (hp14i): ¿Posee este hogar internet?
clonevar     internet_en = dhp14i
recode internet_en (98 99=3)
tab internet_en if ocupado==1
gen     internet = dhp14i==1 if (dhp14i!=98 & dhp14i!=99) 
* Televisor (hp14t): ¿Posee este hogar televisor?
clonevar     televisor_en = dhp14t
recode televisor_en (98 99=3)
tab televisor_en if ocupado==1
gen     televisor = dhp14t==1 if (dhp14t!=98 & dhp14t!=99)
* Radio (dhp14r): ¿Posee este hogar radio? 
clonevar     radio_en = dhp14r
recode radio_en (98 99=3)
tab radio_en if ocupado==1
gen     radio = dhp14r==1 if (dhp14r!=98 & dhp14r!=99)
* Calentador (dhp14o): ¿Posee este hogar calentador? 
clonevar     calentador_en = dhp14o
recode calentador_en (98 99=3)
tab calentador_en if ocupado==1
gen     calentador = dhp14o==1 if (dhp14o!=98 & dhp14o!=99)
* Aire acondicionado (dhp14a): ¿Posee este hogar aire acondicionado?
clonevar     aire_en = dhp14a
recode aire_en (98 99=3)
tab  aire_en if ocupado==1
gen     aire = dhp14a==1 if (dhp14a!=98 & dhp14a!=99)
* TV por cable o satelital (dhp14v): ¿Posee este hogar TV por cable?
clonevar     tv_cable_en = dhp14v
recode tv_cable_en (98 99=3)
tab tv_cable_en if ocupado==1
gen     tv_cable = dhp14v==1 if (dhp14v!=98 & dhp14v!=99)
* Horno microonada (dhp14h): ¿Posee este hogar horno microonda?
clonevar     microondas_en = dhp14h
recode microondas_en (98 99=3)
tab microondas_en if ocupado==1
gen     microondas = dhp14h==1 if (dhp14h!=98 & dhp14h!=99)
** Health insurance
gen afiliado_seguro_salud = 1     if smhp24a==1 
replace afiliado_seguro_salud = 2 if smhp24b==2 
replace afiliado_seguro_salud = 3 if smhp24c==3 
replace afiliado_seguro_salud = 4 if smhp24d==4
replace afiliado_seguro_salud = 5 if smhp24e==5
replace afiliado_seguro_salud = 6 if smhp24f==6
replace afiliado_seguro_salud = . if smhp24f==98 | smhp24f==99
gen     seguro_salud_en = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud_en = 2	if  afiliado_seguro_salud==6
replace seguro_salud_en = 3	if  afiliado_seguro_salud==.
tab seguro_salud_en if ocupado==1
gen     seguro_salud = 1	if  afiliado_seguro_salud>=1 & afiliado_seguro_salud<=5
replace seguro_salud = 0	if  afiliado_seguro_salud==6
** Educational attainment
clonevar nivel_educ_en = emhp27n
recode nivel_educ_en (98 99=8)
tab nivel_educ_en if ocupado==1
gen nivel_educ = emhp27n if (emhp27n!=98 & emhp27n!=99)
** Type of employment
clonevar categ_ocu_en = tmhp41
recode categ_ocu_en (98 99=10)
tab categ_ocu_en if ocupado==1
gen categ_ocu = tmhp41   if (tmhp41!=98 & tmhp41!=99)
** Number of hours worked
gen nhorast = tmhp45 if (tmhp45!=98 & tmhp45!=99 & tmhp45!=0)
gen categ_nhorast_en= 1 if nhorast>=1 & nhorast<=20
replace categ_nhorast_en= 2 if nhorast>=21 & nhorast<=45
replace categ_nhorast_en= 3 if nhorast>=45 & nhorast!=.
replace categ_nhorast_en= 4 if tmhp45==98 | tmhp45==99 | tmhp45==0
tab categ_nhorast_en if ocupado==1
gen categ_nhorast= categ_nhorast_en if categ_nhorast_en!=4
** Firm size
clonevar firm_size_en = tmhp40
recode firm_size_en (98 99 = 8)
tab firm_size_en if ocupado==1
gen firm_size = tmhp40 if (tmhp40!=98 & tmhp40!=99)
** Type of contract
gen     contrato_en = 1 if (tmhp43== 1 | tmhp43==2)
replace contrato_en = 2 if (tmhp43== 3 | tmhp43==4)
replace contrato_en = 3 if (tmhp43== 98 | tmhp43==99)
tab contrato_en if ocupado==1
gen     contrato = 1 if (tmhp43== 1 | tmhp43==2)
replace contrato = 0 if (tmhp43== 3 | tmhp43==4)
** Type of pension (vejez, invalidez, incapacidad, sobreviviente)
*Vejez
clonevar pension_vejez_en=pmhp54ve if djubpen==1
recode pension_vejez_en (0=2) (98 99=3)
tab pension_vejez_en if djubpen==1
gen pension_vejez = pmhp54ve==1 if djubpen==1 & pmhp54ve!=98 & pmhp54ve!=99
*Invalidez
clonevar pension_inva_en=pmhp54in if djubpen==1
recode pension_inva_en (2=1) (0=2) (98 99=3)
tab pension_inva_en if djubpen==1
gen pension_inva = pmhp54in ==2 if djubpen==1 & pmhp54in !=98 & pmhp54in !=99
*Incapacidad u Otra
gen pension_otra_en=1 if (pmhp54ic==3 | pmhp54ot==5) & djubpen==1
replace pension_otra_en =2 if (pmhp54ic==0 & pmhp54ot==0) & djubpen==1
replace pension_otra_en =3 if (pmhp54ic==98 | pmhp54ic==99) & (pmhp54ot==98 | pmhp54ot==99) & djubpen==1
tab pension_otra_en if djubpen==1
gen pension_otra = (pmhp54ic==3 | pmhp54ot==5) if (pmhp54ic!=98 & pmhp54ic!=99) & (pmhp54ot!=98 & pmhp54ot!=99) & djubpen==1
** Survivor pension
clonevar pension_sobrev_en=pmhp54sv if djubpen==1
recode pension_sobrev_en (4=1)(0=2) (98 99=3)
tab pension_sobrev_en if djubpen==1
gen pension_sobrev = pmhp54sv==4 if djubpen==1 & pmhp54sv!=98 & pmhp54sv!=99
** Contribute to pensions
gen contribu_pen_en=1 if (pmhp56sv==1 | pmhp56si==2 | pmhp56se==3 | pmhp56so==4) 
replace contribu_pen_en=2 if pmhp56no==5
replace contribu_pen_en=3 if (pmhp56sv==98 | pmhp56sv==99) & (pmhp56si==98 | pmhp56si==99) & (pmhp56se==98 | pmhp56se==99) & (pmhp56so==98 | pmhp56so==99) & (pmhp56no==98 | pmhp56no==99)
tab contribu_pen_en if djubpen==1,m
recode contribu_pen_en (.=3) if contribu_pen_en==. & djubpen==1
gen contribu_pen=(pmhp56sv==1 | pmhp56si==2 | pmhp56se==3 | pmhp56so==4) if (pmhp56sv!=98 & pmhp56sv!=99) & (pmhp56si!=98 & pmhp56si!=99) & (pmhp56se!=98 & pmhp56se!=99) & (pmhp56so!=98 & pmhp56so!=99) & (pmhp56no!=98 & pmhp56no!=99)
** Beneficiario misiones
clonevar misiones_en=mmhp57
recode misiones_en (98 99=3)
gen misiones=mmhp57==1 if mmhp57!=98 & mmhp57!=99

local demo relacion_en relacion hogarsec jefe miembros edad sexo hombre estado_civil_en estado_civil entidad municipio
local xvar_en tipo_vivienda_en tenencia_vivienda_en propieta_en auto_en heladera_en lavarropas_en secadora_en computadora_en internet_en televisor_en radio_en calentador_en aire_en ///
              tv_cable_en microondas_en seguro_salud_en nivel_educ_en categ_ocu_en categ_nhorast_en firm_size_en contrato_en pension_vejez_en pension_inva_en pension_otra_en pension_sobrev_en contribu_pen_en misiones_en
local xvar tipo_vivienda tenencia_vivienda propieta auto heladera lavarropas secadora computadora internet televisor radio calentador aire ///
              tv_cable microondas seguro_salud nivel_educ categ_ocu categ_nhorast nhorast firm_size contrato pension_vejez pension_inva pension_otra pension_sobrev contribu_pen misiones

mdesc `demo' if ocupado==1
mdesc `xvar' if ocupado==1

*** Keep data base with variables of interest
gen year=2018
gen pondera = pesoper
order year id com
sort year id com
keep year id com pondera ocupado dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension pension2 dnlinc nlinc /*dnlinc_zero*/ dnlinc_miss1 dnlinc_miss2 dnlinc_miss3 ///
dnlinc_jubpen nlinc_jubpen /*dnlinc_jubpen_zero*/ dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro /*dnlinc_otro_zero*/ dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
income_off0 income_off_hh0 nodecla0 nodecla_hh0 n_break ingper0 ///
`demo' `xvar_en' `xvar'
*merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2018.dta"
tempfile encovi2018
save `encovi2018', replace

********************************************************************************
*** Append all datasets
********************************************************************************
use `encovi2014', clear
append using `encovi2015'
append using `encovi2016'
append using `encovi2017'
append using `encovi2018'
*append using `encovi2019'

gen agegroup=1 if edad<=14
replace agegroup=2 if edad>=15 & edad<=24
replace agegroup=3 if edad>=25 & edad<=34
replace agegroup=4 if edad>=35 & edad<=44
replace agegroup=5 if edad>=45 & edad<=54
replace agegroup=6 if edad>=55 & edad<=64
replace agegroup=7 if edad>=65 
label def agegroup 1 "[0-14]" 2 "[15-24]" 3 "[25-34]" 4 "[35-44]" 5 "[45-54]" 6 "[55-64]" 7 "[65+]"
label value agegroup agegroup

gen edad2=edad^2
gen all=1
save "$pathdata\encovi_2014_2018.dta", replace
;
********************************************************************************
*** Counting missing values and real zeros in each year
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
gen ano=year
*** Labor income
foreach x in linc{
forv y=2014/2018{
** Zeros
sum d`x'_zero if year==`y' & ocupado==1
local a0=r(sum)
** Missing values: Those who replied they do not know if they received income
sum d`x'_miss1 if year==`y' & ocupado==1
local a1=r(sum)
** Missing values: Those who replied they received income but they did not declare the amount
sum d`x'_miss2 if year==`y' & ocupado==1
local a2=r(sum)
** Total missing values
sum d`x'_miss3 if year==`y' & ocupado==1
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & year==`y' & ocupado==1
local a4=r(N)
** Total employed
sum ocupado  if year==`y' & ocupado==1
local a5=r(N)
matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
matrix a=nullmat(a), aux1, aux2
}
}
*** Pensions
local i=1
foreach x in pension_IVSS pension_epu pension_epr pension_ot{
forv y=2014/2018{
** Zeros
sum d`x'_zero if year==`y' & djubpen==1
local a0=r(sum)
** Missing values: Those who replied they do not know if they received pensions
sum d`x'_miss1 if year==`y' & djubpen==1
local a1=r(sum)
** Missing values: Those who replied they received pensions but they did not declare the amount
sum d`x'_miss2 if year==`y' & djubpen==1
local a2=r(sum)
** Total missing values
sum d`x'_miss3 if year==`y' & djubpen==1
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & ano==`y' & djubpen==1
local a4=r(N)
** All pensioners and retired
sum djubpen  if year==`y' & djubpen==1
local a5=r(N)
matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
matrix a`i'=nullmat(a`i'), aux1, aux2
}
local i=`i'+1
}
*** Non-labor income: pensions and other non-labor income
foreach x in nlinc_jubpen nlinc_otro{
forv y=2014/2018{
** Zeros
*sum d`x'_zero if ano==`y' & d`x'==1
*local a0=r(sum)
local a0=0
** Missing values: Those who replied they do not know if they received pensions or other non labor income
sum d`x'_miss1 if ano==`y' & d`x'==1 
local a1=r(sum)
** Missing values: Those who replied they received income but they did not declare the amount
sum d`x'_miss2 if ano==`y' & d`x'==1
local a2=r(sum)
** Total missing values
sum d`x'_miss3 if ano==`y' & d`x'==1
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & ano==`y' & d`x'==1
local a4=r(N)
** All 
sum d`x'  if ano==`y' & d`x'==1
local a5=r(N)
matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
matrix a`i'=nullmat(a`i'), aux1, aux2
}
local i=`i'+1
}

local row=4
putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("missing_values") modify
putexcel B`row'=matrix(a)
local row= `row' + rowsof(a)+4
putexcel B`row'=matrix(a1)
local row= `row' + rowsof(a1)+4
putexcel B`row'=matrix(a2)
local row= `row' + rowsof(a2)+4
putexcel B`row'=matrix(a3)
local row= `row' + rowsof(a3)+4
putexcel B`row'=matrix(a4)
local row= `row' + rowsof(a4)+4
putexcel B`row'=matrix(a5)
local row= `row' + rowsof(a5)+4
putexcel B`row'=matrix(a6)

matrix drop aux1 aux2 a a1 a2 a3 a4
/*
gen dlinc1=(linc>0 & linc!=.) if ocupado==1
matrix miss=J(6,5,.)
local j=1
forv y=2014/2018{
local i=1
foreach x in dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 dlinc1 ocupado{
sum `x' if ano==`y'
matrix miss[`i',`j']=r(sum)
local i=`i'+1
}
local j=`j'+1
}
*/

*** Summary missing values

********************************************************************************
*** Pension comparison
********************************************************************************
cd "$pathout\income_imp"
foreach x in linc pension1 pension2 nlinc_jubpen nlinc_otro {
gen log_`x'=ln(`x')
}
forv y=2015/2018{
twoway (kdensity log_pension2 if pension2>0 & djubpen==1 & dnlinc_jubpen==1 & year==`y', lcolor(blue)) ///
       (kdensity log_nlinc_jubpen if nlinc_jubpen>0 & djubpen==1 & dnlinc_jubpen==1 & year==`y', lcolor(green) /*lp(dash)*/), ///
	    legend(order(1 "pensions (pensioner or retired)" 2 "pensions (non-labor income)")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_pension_comp_`y', replace) saving(kd_pension_comp_`y', replace)
*graph export kd_pension_comp_`y'.png, replace
}

twoway (kdensity log_pension2 if pension2>0  & year==2014, lcolor(blue)), ///
	    legend(order(1 "pensions (pensioner or retired)" 2 "pensions (non-labor income)")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_pension_comp_2014, replace) saving(kd_pension_comp_2014, replace)
*graph export kd_pension_comp_2014.png, replace


********************************************************************************
*** Profile of employed with missing values in labor income
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
*** Individuals
local location all 
local varlist1 2014 2015 2016 2017 2018
local varlist2 hombre agegroup estado_civil_en nivel_educ_en categ_ocu_en firm_size_en contrato_en propieta_en
foreach z in `varlist2' {
tab `z', g(`z')
}
local l=1
foreach x in `location' {
matrix a`l'=J(100,6, .)
local j=1
foreach y in `varlist1' {
local i=1
foreach z in `varlist2' {
tab `z'
local s=r(r)
forv k=1/`s'{
sum `z'`k' /*[w=weight]*/ if `x'==1 & year==`y' & dlinc_miss3==1
local i=`i'+ 1
matrix a`l'[`i',`j']=r(mean)*100
}
local i=`i'+1
}
local j=`j'+1
}
matrix colnames a`l'="2014" "2015" "2016" "2017" "2018" "2019"
local l=`l'+1
}
matrix a=(a1)

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("profile_missing_values") modify
putexcel B2=matrix(a), colnames
