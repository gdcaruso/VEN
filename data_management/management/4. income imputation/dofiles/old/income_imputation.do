/*===========================================================================
Country name:	Venezuela
Year:			2014
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Trinidad Saavedra

Dependencies:		The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			

Note: Income imputation
=============================================================================*/
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
				global rootpath "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Desktop\worldbank\analisis\ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}
		
		if $male   {
				global rootpath "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
				global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
		}

global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global datafinalharm "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI harmonized data"
global datafinalimp "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI imputation data"
global pathdata "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\Income Imputation\data"
global pathout "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\Income Imputation\output"

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

gen dlinc=((tp47==1 | tp47==2) & tp51==1) //dummy receive income
replace dlinc=1 if tp51==99 & tp51m!=99
replace dlinc= . if tp51==99 & tp51m==99
gen linc=tp51m if (tp51m!=98 & tp51m!=99) & (tp47==1 | tp47==2) //value labor income
replace linc= 0 if dlinc==0
gen dlinc_zero=tp51==2 if (tp47==1 | tp47==2)
gen dlinc_miss1=(tp51==99 & tp51m==99) if (tp47==1 | tp47==2)
gen dlinc_miss2=(tp51m==99 & dlinc==1) if (tp47==1 | tp47==2)
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if (tp47==1 | tp47==2)

gen djubpen=pp61==1
gen dpension_IVSS=1 if pp63ss==1 & djubpen==1 //IVSS
replace dpension_IVSS=0 if pp63ss==2 | pp63ss==98 
gen pension_IVSS=pp63sm if dpension_IVSS==1 & djubpen==1 & pp63sm!=99 //IVSS
replace pension_IVSS=0 if dpension_IVSS==0
gen dpension_IVSS_zero=pp63ss==2 if djubpen==1
gen dpension_IVSS_miss1=(pp63ss==99) if djubpen==1
gen dpension_IVSS_miss2=(pp63sm==99 & dpension_IVSS==1) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1

gen dpension_epu=1 if pp63ep==1 & djubpen==1  //empresa publica
replace dpension_epu=0 if pp63ep==2 | pp63ep==98
gen pension_epu=pp63em if dpension_epu==1 & djubpen==1 & pp63em!=99 
replace pension_epu=0 if dpension_epu==0
gen dpension_epu_zero=pp63ep==2 if djubpen==1
gen dpension_epu_miss1=(pp63ep==99) if djubpen==1
gen dpension_epu_miss2=(pp63em==99 & dpension_epu==1) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1

gen dpension_epr=1 if pp63pr==1 & djubpen==1 //empresa privada
replace dpension_epr=0 if pp63pr==2 | pp63pr==98
gen pension_epr=pp63pm if dpension_epr==1 & djubpen==1 & pp63pm!=99 
replace pension_epr=0 if dpension_epr==0
gen dpension_epr_zero=pp63pr==2 if djubpen==1
gen dpension_epr_miss1=(pp63pr==99) if djubpen==1
gen dpension_epr_miss2=(pp63pm==99 & dpension_epr==1) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1

gen dpension_ot=1 if pp63ot==1 & djubpen==1 //otra
replace dpension_ot=0 if pp63ot==2 | pp63ot==98
gen pension_ot=pp630m if dpension_ot==1 & djubpen==1 & pp630m!=99 
replace pension_ot=0 if dpension_ot==0
gen dpension_ot_zero=pp63ot==2 if djubpen==1
gen dpension_ot_miss1=(pp63ot==99) if djubpen==1
gen dpension_ot_miss2=(pp630m==99 & dpension_ot==1) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1

gen pension1=pension_IVSS+pension_epu+pension_epr+pension_ot
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing

egen income_off=rowtotal(linc pension2)
clonevar income_off1=income_off

egen income_off_hh = sum(income_off), by(id)
egen income_off_hh1 = sum(income_off1), by(id)
bysort id: gen n_break = _N
gen nodecla=(dlinc_miss3==1 | dlinc_zero==1)
gen nodecla1=dlinc_miss3==1 
egen nodecla_hh = sum(nodecla==1), by(id) // excluyen los missing y los ocupados que dicen no recibir ingresos 
egen nodecla_hh1 = sum(nodecla1==1), by(id)
gen ingper0 = income_off_hh / n_break 
gen ingper1 = income_off_hh1 / n_break 

*** Variables para equacion de Mincer
* edad, sexo, jefe de hogar, estado civil, region, educacion, tipo de empleo, sector de trabajo 
clonevar estado_civil_encuesta = mhp28
clonevar nivel_educ = ep37n
clonevar categ_ocu = tp50
clonevar labor_status = tp47
clonevar nhorast = tp54
clonevar firm_size = tp49
clonevar contrato_encuesta = tp52


keep id com dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension1 pension2 income_off income_off1 income_off_hh income_off_hh1 n_break nodecla nodecla1 nodecla_hh nodecla_hh1 ingper0 ingper1 ///
estado_civil_encuesta nivel_educ categ_ocu labor_status nhorast firm_size contrato_encuesta
merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2014.dta"
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
gen dlinc=((tp45==1 | tp45==2) & tp50==1) //dummy receive income
replace dlinc= . if tp50==99
gen linc=tp50m if (tp50m!=98 & tp50m!=99) & (tp45==1 | tp45==2) //value labor income
replace linc= 0 if dlinc==0
gen dlinc_zero=tp50==2 if (tp45==1 | tp45==2)
gen dlinc_miss1=(tp50==99) if (tp45==1 | tp45==2)
gen dlinc_miss2=((tp50m==99 | tp50m==.) & dlinc==1) if (tp45==1 | tp45==2)
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if (tp45==1 | tp45==2)

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

** Esta jubilado o pensionado (dos preguntas)
gen djubpen=pp61==1
gen dpension_IVSS=1 if pp63ss==1 & djubpen==1 //IVSS
replace dpension_IVSS=0 if pp63ss==0 | pp63ss==98 | (pp63ss==99 & djubpen==0)
gen pension_IVSS=pp63sm if dpension_IVSS==1 & djubpen==1 & pp63sm!=98 & pp63sm!=99 //IVSS
replace pension_IVSS=0 if dpension_IVSS==0
gen dpension_IVSS_zero=pp63ss==0 if djubpen==1
gen dpension_IVSS_miss1=(pp63ss==99) if djubpen==1
gen dpension_IVSS_miss2=(pp63sm==99 & dpension_IVSS==1) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1

gen dpension_epu=1 if pp63ep==2 & djubpen==1  //empresa publica
replace dpension_epu=0 if pp63ep==0 | pp63ep==98 | (pp63ep==99 & djubpen==0)
gen pension_epu=pp63em if dpension_epu==1 & djubpen==1 & pp63em!=98 & pp63em!=99 
replace pension_epu=0 if dpension_epu==0
gen dpension_epu_zero=pp63ep==0 if djubpen==1
gen dpension_epu_miss1=(pp63ep==99) if djubpen==1
gen dpension_epu_miss2=(pp63em==99 & dpension_epu==1) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1

gen dpension_epr=1 if pp63pr==3 & djubpen==1 //empresa privada
replace dpension_epr=0 if pp63pr==0 | pp63pr==98 | (pp63pr==99 & djubpen==0)
gen pension_epr=pp63pm if dpension_epr==1 & djubpen==1 & pp63pm!=98 & pp63pm!=99 
replace pension_epr=0 if dpension_epr==0
gen dpension_epr_zero=pp63pr==0 if djubpen==1
gen dpension_epr_miss1=(pp63pr==99) if djubpen==1
gen dpension_epr_miss2=(pp63pm==99 & dpension_epr==1) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1

gen dpension_ot=1 if pp63ot==4 & djubpen==1  //otra
replace dpension_ot=0 if pp63ot==0 | pp63ot==98 | (pp63ot==99 & djubpen==0)
gen pension_ot=pp63om if dpension_ot==1 & djubpen==1 & pp63om!=98 & pp63om!=99
replace pension_ot=0 if dpension_ot==0
gen dpension_ot_zero=pp63ot==0 if djubpen==1
gen dpension_ot_miss1=(pp63ot==99) if djubpen==1
gen dpension_ot_miss2=(pp63om==99 & dpension_ot==1) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1

gen pension1=pension_IVSS+pension_epu+pension_epr+pension_ot
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing

gen dnlinc_jubpen=(tp51ps==1 | tp51ss==3 | tp51jv==4)
gen nlinc_jubpen=tp51m if dnlinc_jubpen==1 & tp51m!=98 & tp51m!=99
replace nlinc_jubpen= 0 if dnlinc_jubpen==0
gen dnlinc_jubpen_zero=tp51m==0 if dnlinc_jubpen==1
gen dnlinc_jubpen_miss1=0 if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(tp51m==99) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1

gen dnlinc_otro= (tp51ay==2 | tp51rp==5 | tp51id==6 | tp51ot==7)
gen nlinc_otro=tp51m if dnlinc_otro==1 & tp51m!=98 & tp51m!=99
replace nlinc_otro=0 if dnlinc_otro==0
gen dnlinc_otro_zero=tp51m==0 if dnlinc_otro==1
gen dnlinc_otro_miss1=0 if dnlinc_otro==1
gen dnlinc_otro_miss2=(tp51m==99) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1

gen nlinc=tp51m if (tp51m!=98 & tp51m!=99)
replace nlinc=0 if tp51m==98
replace nlinc=0 if tp51m==99 & dnlinc==0

gen nlinc1= pension1 + nlinc_otro
egen nlinc2=rowtotal(pension2 nlinc_otro)

egen income_off=rowtotal(linc nlinc) if tp50m!=. & tp51m!=.
egen income_off1=rowtotal(linc nlinc_otro pension2)
egen income=rowtotal(linc nlinc_jubpen nlinc_otro), missing

egen income_off_hh = sum(income_off), by(id)
egen income_off_hh1 = sum(income_off1), by(id)
bysort id: gen n_break = _N
gen nodecla=(dlinc_miss2==1 & tp50m!=.)
gen nodecla1=dlinc_miss3==1
egen nodecla_hh = sum(nodecla==1), by(id) // excluyen los ocupados que dicen recibir ingresos pero no declaran monto
egen nodecla_hh1 = sum(nodecla1==1), by(id)
gen ingper0 = income_off_hh / n_break 
gen ingper1 = income_off_hh1 / n_break 

*** Variables para equacion de Mincer
* edad, sexo, jefe de hogar, estado civil, region, educacion, tipo de empleo, sector de trabajo 
clonevar estado_civil_encuesta = mhp27
clonevar nivel_educ = ep36n
clonevar categ_ocu = tp49
clonevar labor_status = tp45
clonevar nhorast = tp54
clonevar firm_size = tp48
clonevar contrato_encuesta = tp52


keep id com dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension1 pension2 income_off income_off1 income_off_hh income_off_hh1 n_break nodecla nodecla1 nodecla_hh nodecla_hh1 ingper0 ingper1 ///
dnlinc_jubpen nlinc_jubpen dnlinc_jubpen_zero dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro dnlinc_otro_zero dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
dnlinc nlinc nlinc1 nlinc2 estado_civil_encuesta nivel_educ categ_ocu labor_status nhorast firm_size contrato_encuesta
merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2015.dta"
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
gen dlinc=((tp39==1 | tp39==2) & tp47==1) //dummy receive income
replace dlinc=1 if tp47==99 & (tp47m!=98 & tp47m!=99)
replace dlinc= . if tp47==99
gen linc=tp47m if (tp47m!=98 & tp47m!=99) & (tp39==1 | tp39==2) //value labor income
replace linc= 0 if dlinc==0
gen dlinc_zero=tp47==2 if (tp39==1 | tp39==2)
gen dlinc_miss1=(tp47==99 & (tp47m==98 | tp47m==99)) if (tp39==1 | tp39==2)
gen dlinc_miss2=(tp47m==99 & dlinc==1) if (tp39==1 | tp39==2)
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if (tp39==1 | tp39==2)

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

** Esta jubilado o pensionado (dos preguntas)
gen djubpen=(pp59==1 | pp59==2 | pp59==3)
gen dpension_IVSS=1 if pp61ss==1 & djubpen==1 //IVSS
replace dpension_IVSS=0 if pp61ss==0 | pp61ss==98 | (pp61ss==99 & djubpen==0)
gen pension_IVSS=pp61sm if dpension_IVSS==1 & djubpen==1 & pp61sm!=98 & pp61sm!=99 //IVSS
replace pension_IVSS=0 if dpension_IVSS==0
gen dpension_IVSS_zero=pp61ss==0 if djubpen==1
gen dpension_IVSS_miss1=(pp61ss==99) if djubpen==1
gen dpension_IVSS_miss2=((pp61sm==98 | pp61sm==99) & dpension_IVSS==1) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1

gen dpension_epu=1 if pp61ep==2 & djubpen==1  //empresa publica
replace dpension_epu=1 if pp61ep==0 & pp61em!=98 & pp61em!=99
replace dpension_epu=0 if (pp61ep==0 & dpension_epu==.) | pp61ep==98 | (pp61ep==99 & djubpen==0)
gen pension_epu=pp61em if dpension_epu==1 & djubpen==1 & pp61em!=98 & pp61em!=99
replace pension_epu=0 if dpension_epu==0
gen dpension_epu_zero=pp61ep==0 if djubpen==1
gen dpension_epu_miss1=(pp61ep==99) if djubpen==1
gen dpension_epu_miss2=(pp61em==99 & dpension_epu==1) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1

gen dpension_epr=1 if pp61pr==3 & djubpen==1 //empresa privada
replace dpension_epr=0 if pp61pr==0 | pp61pr==98 | (pp61pr==99 & djubpen==0)
gen pension_epr=pp61pm if dpension_epr==1 & djubpen==1 & pp61pm!=98 & pp61pm!=99 
replace pension_epr=0 if dpension_epr==0
gen dpension_epr_zero=pp61pr==0 if djubpen==1
gen dpension_epr_miss1=(pp61pr==99) if djubpen==1
gen dpension_epr_miss2=(pp61pm==99 & dpension_epr==1) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1

gen dpension_ot=1 if pp61ot==4 & djubpen==1  //otra
replace dpension_ot=0 if pp61ot==0 | pp61ot==98 | (pp61ot==99 & djubpen==0)
gen pension_ot=pp61om if dpension_ot==1 & djubpen==1 & pp61om!=98 & pp61om!=99 
replace pension_ot=0 if dpension_ot==0
gen dpension_ot_zero=pp61ot==0 if djubpen==1
gen dpension_ot_miss1=(pp61ot==99) if djubpen==1
gen dpension_ot_miss2=(pp61om==99 & dpension_ot==1) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1

gen pension1=pension_IVSS+pension_epu+pension_epr+pension_ot
egen pension2=rowtotal(pension_IVSS pension_epu pension_epr pension_ot), missing

gen dnlinc_jubpen=(tp48ps==1 | tp48ss==3 | tp48jv==4)
gen nlinc_jubpen=tp48m if dnlinc_jubpen==1 & tp48m!=98 & tp48m!=99
replace nlinc_jubpen= 0 if dnlinc_jubpen==0
gen dnlinc_jubpen_zero=tp48m==0 if dnlinc_jubpen==1
gen dnlinc_jubpen_miss1=0 if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(tp48m==99) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1

gen dnlinc_otro= (tp48ay==2 | tp48rp==5 | tp48id==6 | tp48ot==7)
gen nlinc_otro=tp48m if dnlinc_otro==1 & tp48m!=98 & tp48m!=99
replace nlinc_otro=0 if dnlinc_otro==0
gen dnlinc_otro_zero=tp48m==0 if dnlinc_otro==1
gen dnlinc_otro_miss1=0 if dnlinc_otro==1
gen dnlinc_otro_miss2=(tp48m==99) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1

gen nlinc=tp48m if (tp48m!=98 & tp48m!=99)
*replace nlinc=0 if (tp48ps!=1 & tp48ss!=3 & tp48jv!=4 & tp48ay!=2 & tp48rp!=5 & tp48id!=6 & tp48ot!=7)
replace nlinc=tp48m==98
replace nlinc=tp48m==99 & dnlinc==0

gen nlinc1= pension1 + nlinc_otro
egen nlinc2=rowtotal(pension2 nlinc_otro)

egen income_off=rowtotal(linc nlinc pension2) 
egen income_off1=rowtotal(linc nlinc pension2) 
egen income=rowtotal(linc nlinc_jubpen nlinc_otro), missing

egen income_off_hh = sum(income_off), by(id)
egen income_off_hh1 = sum(income_off1), by(id)
bysort id: gen n_break = _N
gen nodecla=(tp47m==99) | (tp47m < 98 & (tp47==1 | tp47==99)) | (tp48m==99) | (pp61sm ==99 | pp61em==99 | pp61pm==99 | pp61pm==99)
gen nodecla1=dlinc_miss3==1
egen nodecla_hh = sum(nodecla==1), by(id) // excluyen los ocupados que dicen recibir ingresos pero no declaran monto
egen nodecla_hh1 = sum(nodecla1==1), by(id) 
gen ingper0 = income_off_hh / n_break 
gen ingper1 = income_off_hh1 / n_break 

*** Variables para equacion de Mincer
* edad, sexo, jefe de hogar, estado civil, region, educacion, tipo de empleo, sector de trabajo 
clonevar estado_civil_encuesta = mhp18
clonevar nivel_educ = ep30n
clonevar categ_ocu = tp46
clonevar labor_status = tp39
clonevar nhorast = tp51
clonevar firm_size = tp45
clonevar sector_encuesta = tp44
clonevar contrato_encuesta = tp49


keep id com dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension1 pension2 income_off income_off1 income_off_hh income_off_hh1 n_break nodecla nodecla1 nodecla_hh nodecla_hh1 ingper0 ingper1 ///
dnlinc_jubpen nlinc_jubpen dnlinc_jubpen_zero dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro dnlinc_otro_zero dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
dnlinc nlinc nlinc1 nlinc2 estado_civil_encuesta nivel_educ categ_ocu labor_status nhorast firm_size contrato_encuesta
merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2016.dta"
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
gen dlinc=((tmhp36==1 | tmhp36==2) & tmhp44==1) //dummy receive income
replace dlinc=1 if tmhp44==99 & (tmhp44bs!=98 | tmhp44bs!=99)
replace dlinc= . if tmhp44==99
gen linc=tmhp44bs if (tmhp44bs!=98 & tmhp44bs!=99) & (tmhp36==1 | tmhp36==2) //value labor income
replace linc= 0 if dlinc==0
gen dlinc_zero=tmhp44==2 if (tmhp36==1 | tmhp36==2)
gen dlinc_miss1=(tmhp44==99 & (tmhp44bs==98 | tmhp44bs==99)) if (tmhp36==1 | tmhp36==2)
gen dlinc_miss2=(tmhp44bs==99 & dlinc==1) if (tmhp36==1 | tmhp36==2)
gen dlinc_miss3=(dlinc_miss1==1 | dlinc_miss2==1) if (tmhp36==1 | tmhp36==2)

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
*egen recibe_pen=rowtotal(dpension_IVSS dpension_epu dpension_epr dpension_ot)

** Esta jubilado o pensionado (dos preguntas)
gen djubpen=(pmhp58j==1 | pmhp58p==2)
replace djubpen=1 if pmhp60a==1 & djubpen==0
gen dpension_IVSS=1 if pmhp60a==1 & djubpen==1 //IVSS
replace dpension_IVSS=0 if pmhp60a==0 | pmhp60a==98 | (pmhp60a==99 & djubpen==0)
gen pension_IVSS=pmhp60bs if dpension_IVSS==1 & djubpen==1 & pmhp60bs!=98 & pmhp60bs!=99 //IVSS
replace pension_IVSS=0 if dpension_IVSS==0
gen dpension_IVSS_zero=pmhp60a==0 if djubpen==1
gen dpension_IVSS_miss1=(pmhp60a==99) if djubpen==1
gen dpension_IVSS_miss2=((pmhp60bs==98 | pmhp60bs==99) & dpension_IVSS==1) if djubpen==1
gen dpension_IVSS_miss3=(dpension_IVSS_miss1==1 | dpension_IVSS_miss2==1) if djubpen==1

gen dpension_epu=1 if pmhp60b==2 & djubpen==1  //empresa publica
replace dpension_epu=0 if pmhp60b==0 | pmhp60b==98 | (pmhp60b==99 & djubpen==0)
gen pension_epu=pmhp60bs if dpension_epu==1 & djubpen==1 & pmhp60bs!=98 & pmhp60bs!=99
replace pension_epu=0 if dpension_epu==0
gen dpension_epu_zero=pmhp60b==0 if djubpen==1
gen dpension_epu_miss1=(pmhp60b==99) if djubpen==1
gen dpension_epu_miss2=((pmhp60bs==98 | pmhp60bs==99) & dpension_epu==1) if djubpen==1
gen dpension_epu_miss3=(dpension_epu_miss1==1 | dpension_epu_miss2==1) if djubpen==1

gen dpension_epr=1 if pmhp60c==3 & djubpen==1 //empresa privada
replace dpension_epr=0 if pmhp60c==0 | pmhp60c==98 | (pmhp60c==99 & djubpen==0)
gen pension_epr=pmhp60bs if dpension_epr==1 & djubpen==1 & pmhp60bs!=98 & pmhp60bs!=99 
replace pension_epr=0 if dpension_epr==0
gen dpension_epr_zero=pmhp60c==0 if djubpen==1
gen dpension_epr_miss1=(pmhp60c==99) if djubpen==1
gen dpension_epr_miss2=((pmhp60bs==98 | pmhp60bs==99) & dpension_epr==1) if djubpen==1
gen dpension_epr_miss3=(dpension_epr_miss1==1 | dpension_epr_miss2==1) if djubpen==1

gen dpension_ot=1 if pmhp60d==4 & djubpen==1  //otra
replace dpension_ot=0 if pmhp60d==0 | pmhp60d==98 | (pmhp60d==99 & djubpen==0)
gen pension_ot=pmhp60bs if dpension_ot==1 & djubpen==1 & pmhp60bs!=98 & pmhp60bs!=99 
replace pension_ot=0 if dpension_ot==0
gen dpension_ot_zero=pmhp60d==0 if djubpen==1
gen dpension_ot_miss1=(pmhp60d==99) if djubpen==1
gen dpension_ot_miss2=((pmhp60bs==98 | pmhp60bs==99) & dpension_ot==1) if djubpen==1
gen dpension_ot_miss3=(dpension_ot_miss1==1 | dpension_ot_miss2==1) if djubpen==1

gen pension1=pension_IVSS+pension_epu+pension_epr+pension_ot
gen pension2=pmhp60bs if djubpen==1 & pmhp60bs!=98 & pmhp60bs!=99 
replace pension2=0 if djubpen==0

gen dnlinc_jubpen=(tmhp45pe==1 | tmhp45op==2 | tmhp45ju==3)
gen nlinc_jubpen=tmhp45bs if dnlinc_jubpen==1 & tmhp45bs!=98 & tmhp45bs!=99
replace nlinc_jubpen= 0 if dnlinc_jubpen==0
gen dnlinc_jubpen_zero=tmhp45bs==0 if dnlinc_jubpen==1
gen dnlinc_jubpen_miss1=(tmhp45bs==98) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss2=(tmhp45bs==99) if dnlinc_jubpen==1
gen dnlinc_jubpen_miss3=(dnlinc_jubpen_miss1==1 | dnlinc_jubpen_miss2==1) if dnlinc_jubpen==1

gen dnlinc_otro= (tmhp45af==4 | tmhp45ax==5 | tmhp45ps==6 | tmhp45re==7 | tmhp45id==8 | tmhp45ot==9)
gen nlinc_otro=tmhp45bs  if dnlinc_otro==1 & tmhp45bs !=98 & tmhp45bs !=99
replace nlinc_otro=0 if dnlinc_otro==0
gen dnlinc_otro_zero=tmhp45bs ==0 if dnlinc_otro==1
gen dnlinc_otro_miss1=tmhp45bs==98 if dnlinc_otro==1
gen dnlinc_otro_miss2=(tmhp45bs ==99) if dnlinc_otro==1
gen dnlinc_otro_miss3=(dnlinc_otro_miss1==1 | dnlinc_otro_miss2==1) if dnlinc_otro==1

gen nlinc=tmhp45bs  if (tmhp45bs!=98 & tmhp45bs!=99)
*replace nlinc=0 if (tmhp45pe!=1 | tmhp45op!=2 | tmhp45ju!=3 | tmhp45af!=4 | tmhp45ax!=5 | tmhp45ps!=6 | tmhp45re!=7 | tmhp45id!=8 | tmhp45ot!=9)
replace nlinc=0 if tmhp45bs==98 
replace nlinc=0 if tmhp45bs==99 & dnlinc==0

gen nlinc1= pension1 + nlinc_otro
egen nlinc2=rowtotal(pension2 nlinc_otro)

egen income_off=rowtotal(linc nlinc pension2) 
egen income_off1=rowtotal(linc nlinc pension2) 
egen income=rowtotal(linc nlinc_jubpen nlinc_otro), missing

egen income_off_hh = sum(income_off), by(id)
egen income_off_hh1 = sum(income_off), by(id)
bysort id: gen n_break = _N
gen nodecla=(tmhp44bs==99) | (tmhp44==99) | (tmhp45bs==99) | (pmhp60bs==99) | (pmhp60a==99)
gen nodecla1=dlinc_miss3==1
egen nodecla_hh = sum(nodecla==1), by(id) // excluyen los ocupados que dicen recibir ingresos pero no declaran monto
egen nodecla_hh1 = sum(nodecla1==1), by(id)
gen ingper0 = income_off_hh / n_break 
gen ingper1 = income_off_hh1 / n_break 

*** Variables para equacion de Mincer
* edad, sexo, jefe de hogar, estado civil, region, educacion, tipo de empleo, sector de trabajo 
clonevar estado_civil_encuesta = cmhp22
clonevar nivel_educ = emhp28n
clonevar categ_ocu = tmhp43
clonevar labor_status = tmhp36
clonevar nhorast = tmhp48
clonevar firm_size = tmhp42
clonevar sector_encuesta = tmhp41
clonevar contrato_encuesta = tmhp46


keep id com dlinc linc dlinc_zero dlinc_miss1 dlinc_miss2 dlinc_miss3 djubpen dpension_IVSS pension_IVSS dpension_IVSS_zero dpension_IVSS_miss1 dpension_IVSS_miss2 dpension_IVSS_miss3 ///
dpension_epu pension_epu dpension_epu_zero dpension_epu_miss1 dpension_epu_miss2 dpension_epu_miss3 dpension_epr pension_epr dpension_epr_zero dpension_epr_miss1 dpension_epr_miss2 dpension_epr_miss3 ///
dpension_ot pension_ot dpension_ot_zero dpension_ot_miss1 dpension_ot_miss2 dpension_ot_miss3 pension1 pension2 income_off income_off1 income_off_hh income_off_hh1 n_break nodecla nodecla1 nodecla_hh nodecla_hh1 ingper0 ingper1 ///
dnlinc_jubpen nlinc_jubpen dnlinc_jubpen_zero dnlinc_jubpen_miss1 dnlinc_jubpen_miss2 dnlinc_jubpen_miss3 dnlinc_otro nlinc_otro dnlinc_otro_zero dnlinc_otro_miss1 dnlinc_otro_miss2 dnlinc_otro_miss3 ///
dnlinc nlinc nlinc1 nlinc2 estado_civil_encuesta nivel_educ categ_ocu labor_status nhorast firm_size contrato_encuesta
merge 1:1 id com using "$dataout\base_out_nesstar_cedlas_2017.dta"
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
gen aux=(tmhp34==1 | tmhp34==2 | (tmhp34==99 & tmhp42bs!=99 & tmhp42bs!=0) | (tmhp34==5 & tmhp42bs!=98))
gen dlinc=(aux==1 & tmhp42==1) //dummy receive income
replace dlinc=1 if tmhp42==98 & tmhp42bs!=98 & tmhp42bs!=99
replace dlinc=1 if tmhp42==99 & tmhp42bs!=98 & tmhp42bs!=99 & tmhp42bs!=0
replace dlinc=. if tmhp42==99 & (tmhp42bs==98 | tmhp42bs==99 | tmhp42bs==0) & aux==1
*replace dlinc=. if tmhp42==1 & tmhp42bs==0 & aux==1
gen linc=tmhp42bs*(1000/100000) if (tmhp42bs!=98 & tmhp42bs!=99 & aux==1) //value labor income
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

use `encovi2014', clear
append using `encovi2015'
append using `encovi2016'
append using `encovi2017'
append using `encovi2018'


gen agegroup=1 if edad<=14
replace agegroup=2 if edad>=15 & edad<=24
replace agegroup=3 if edad>=25 & edad<=34
replace agegroup=4 if edad>=35 & edad<=44
replace agegroup=5 if edad>=45 & edad<=54
replace agegroup=6 if edad>=55 & edad<=64
replace agegroup=7 if edad>=65 
label def agegroup 1 "[0-14]" 2 "[15-24]" 3 "[25-34]" 4 "[35-44]" 5 "[45-54]" 6 "[55-64]" 7 "[65+]"
label value agegroup agegroup
replace estado_civil=6 if estado_civil==. & estado_civil_encuesta==99
replace nivel_educ=. if nivel_educ==98
replace categ_ocu=. if categ_ocu==98

/*
gen     estado_civil = 1	if  estado_civil_encuesta==1 | estado_civil_encuesta==2
replace estado_civil = 2	if  estado_civil_encuesta==8 
replace estado_civil = 3	if  estado_civil_encuesta==3 | estado_civil_encuesta==4
replace estado_civil = 4	if  estado_civil_encuesta==5 | estado_civil_encuesta==6
replace estado_civil = 5	if  estado_civil_encuesta==7
label def estado_civil 1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
label value estado_civil estado_civil
*/
gen edad2=edad^2

bysort id: egen region=max(region_est1)
replace region_est1=region if region_est1==.
drop region
bysort id: egen region=max(region_est2)
replace region_est2=region if region_est2==.
drop region
bysort id: egen region=max(region_est3)
replace region_est3=region if region_est3==.
drop region

gen all=1
save "$pathdata\encovi_2014_2018.dta", replace
;

********************************************************************************
*** Counting missing values and real zeros in each year
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
foreach x in linc{
forv y=2014/2018{
** Zeros
sum d`x'_zero if ano==`y' & ocupado==1
local a0=r(sum)
** Missing values: Those who replied they do not know if they received income
sum d`x'_miss1 if ano==`y' & ocupado==1
local a1=r(sum)
** Missing values: Those who replied they received income but they did not declare the amount
sum d`x'_miss2 if ano==`y' & ocupado==1
local a2=r(sum)
** Total missing values
sum d`x'_miss3 if ano==`y' & ocupado==1
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & ano==`y' & ocupado==1
local a4=r(N)
** Total employed
sum ocupado  if ano==`y' & ocupado==1
local a5=r(N)
matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
matrix a=nullmat(a), aux1, aux2
}
}

local i=1
foreach x in pension_IVSS pension_epu pension_epr pension_ot{
forv y=2014/2018{
** Zeros
sum d`x'_zero if ano==`y' & djubpen==1
local a0=r(sum)
** Missing values: Those who replied they do not know if they received income
sum d`x'_miss1 if ano==`y' & djubpen==1
local a1=r(sum)
** Missing values: Those who replied they received income but they did not declare the amount
sum d`x'_miss2 if ano==`y' & djubpen==1
local a2=r(sum)
** Total missing values
sum d`x'_miss3 if ano==`y' & djubpen==1
local a3=r(sum)
** Non-zero values
sum `x' if `x'>0 & `x'!=. & ano==`y' & djubpen==1
local a4=r(N)
** Total employed
sum djubpen  if ano==`y' & djubpen==1
local a5=r(N)
matrix aux1=( `a0' \ `a1' \ `a2' \ `a3' \ `a4' \ `a5' )
matrix aux2=((`a0'/`a5')\(`a1'/`a5')\(`a2'/`a5')\(`a3'/`a5')\(`a4'/`a5')\(`a5'/`a5'))*100
matrix a`i'=nullmat(a`i'), aux1, aux2
}
local i=`i'+1
}
putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("missing_values") modify
putexcel B4=matrix(a)
putexcel B14=matrix(a1)
putexcel B24=matrix(a2)
putexcel B34=matrix(a3)
putexcel B44=matrix(a4)
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
********************************************************************************
*** Pension comparison
********************************************************************************
cd "$pathout\income_imp"
foreach x in linc pension1 pension2 nlinc_jubpen nlinc_otro {
gen log_`x'=ln(`x')
}
forv y=2015/2018{
twoway (kdensity log_pension2 if pension2>0 & djubpen==1 & dnlinc_jubpen==1 & ano==`y', lcolor(blue)) ///
       (kdensity log_nlinc_jubpen if nlinc_jubpen>0 & djubpen==1 & dnlinc_jubpen==1 & ano==`y', lcolor(green) /*lp(dash)*/), ///
	    legend(order(1 "pensions (pensioner or retired)" 2 "pensions (non-labor income)")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_pension_comp_`y', replace) saving(kd_pension_comp_`y', replace)
*graph export kd_pension_comp_`y'.png, replace
}

twoway (kdensity log_pension2 if pension2>0  & ano==2014, lcolor(blue)), ///
	    legend(order(1 "pensions (pensioner or retired)" 2 "pensions (non-labor income)")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_pension_comp_2014, replace) saving(kd_pension_comp_2014, replace)
*graph export kd_pension_comp_2014.png, replace


********************************************************************************
*** Profile of employed with missing values in labor income
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
*** Individuals
local location all 
local varlist1 2014 2015 2016 2017 2018
local varlist2 hombre agegroup estado_civil nivel_educ categ_ocu region_est1
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
sum `z'`k' /*[w=weight]*/ if `x'==1 & ano==`y' & dlinc_miss3==1
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

********************************************************************************
*** Labor income imputation model: using regress imputation techniques
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
foreach x in linc pension1 pension2 nlinc_jubpen nlinc_otro {
gen log_`x'=ln(`x')
}
reg log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ano==2014
scalar sig2_linc1=(e(rmse))^2
reg log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ano==2015
scalar sig2_linc2=(e(rmse))^2
reg log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ano==2016
scalar sig2_linc3=(e(rmse))^2
reg log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ano==2017
scalar sig2_linc4=(e(rmse))^2
reg log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ano==2018
scalar sig2_linc5=(e(rmse))^2


set more off
mi set flong
set seed 66778899
mi register imputed log_linc
mi impute regress log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ocupado==1 & ano==2014, add(30) rseed(66778899) force noi 
mi impute regress log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ocupado==1 & ano==2015, replace rseed(66778899) force noi 
mi impute regress log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ocupado==1 & ano==2016, replace rseed(66778899) force noi 
mi impute regress log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ocupado==1 & ano==2017, replace rseed(66778899) force noi 
mi impute regress log_linc hombre edad edad2 jefe i.estado_civil i.nivel_educ i.categ_ocu i.region_est2 i.contrato_encuesta i.firm_size nhorast if log_linc>0 & ocupado==1 & ano==2018, replace rseed(66778899) force noi 
mi unregister log_linc

*** Retrieving original variables
foreach x of varlist linc {
gen `x'2=.
local j=1
forv i=2014/2018 {
sum `x' if `x'>0 & ocupado==1 & ano==`i' &  _mi_m==0
scalar min_`x'`j'=r(min)
replace `x'2= exp(log_`x'+0.5*sig2_`x'`j') if ocupado==1 & ano==`i' & d`x'_miss3==1 
replace `x'2=min_`x'`j' if (ocupado==1 & ano==`i' & `x'2<min_`x'`j' & d`x'_miss3==1)
replace `x'=`x'2 if (ocupado==1 & ano==`i' & d`x'_miss3==1 & _mi_m!=0)
}
drop `x'2
}	
mdesc linc if _mi_m==0
mdesc linc if _mi_m==1

gen imp_id=_mi_m
*mi unset
char _dta[_mi_style] 
char _dta[_mi_marker] 
char _dta[_mi_M] 
char _dta[_mi_N] 
char _dta[_mi_update] 
char _dta[_mi_rvars] 
char _dta[_mi_ivars] 
drop _mi_id _mi_miss _mi_m	

drop if imp_id==0
collapse (mean) linc, by(ano id com)
rename linc linc_imp

save "$pathdata\VEN_linc_imp.dta", replace

use "$pathdata\encovi_2014_2018.dta", clear
capture drop _merge
merge 1:1 ano id com using "$pathdata\VEN_linc_imp.dta"

cd "$pathout\income_imp"
foreach x of varlist linc{
gen log_`x'=ln(`x')
gen log_`x'_imp=ln(`x'_imp)
}

foreach x in linc{
forv y=2014/2018{
twoway (kdensity log_`x' if `x'>0 & ocupado==1 & ano==`y' [aw=pondera], lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp if `x'_imp>0 & ocupado==1 & ano==`y' [aw=pondera], lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("`y'") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'_`y', replace) saving(kd_`x'_`y', replace)
graph export kd_`x'_`y'.png, replace
}
}
/*
putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("labor_income_imp_stochastic_reg") modify
putexcel A1="Labor income"
putexcel A2=picture("kd_linc_2014.png")
*/

foreach x in linc{
forv y=2014/2018{
tabstat `x' if `x'>0 & ano==`y', stat(mean p10 p25 p50 p75 p90) save
matrix aux1=r(StatTotal)'
tabstat `x'_imp if `x'_imp>0 & ano==`y', stat(mean p10 p25 p50 p75 p90) save
matrix aux2=r(StatTotal)'
matrix imp=nullmat(imp)\(aux1,aux2)
}
}
levelsof ano, local(year)
matrix rownames imp=`year'
matrix list imp

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("labor_income_imp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp

********************************************************************************
*** Poverty rates
********************************************************************************
use "$pathdata\encovi_2014_2018.dta", clear
capture drop _merge
merge 1:1 ano id com using "$pathdata\VEN_linc_imp.dta"
gen cpi_imf = . 
replace cpi_imf = 273.354 if ano == 2014		
replace cpi_imf = 578.963 if ano == 2015
replace cpi_imf = 2051.844 if ano == 2016
replace cpi_imf = 24365.653 if ano == 2017
replace cpi_imf = 333833811 if ano == 2018
gen cpi2011=cpi_imf/100				
gen icp2011=2.915005297

gen pl19=1.9*(365/12)
gen pl32=3.2*(365/12)
gen pl55=5.5*(365/12)

gen canasta=.
replace canasta= 5741.06 if ano==2014
replace canasta= 15556 if ano==2015
replace canasta= 69540 if ano==2016
replace canasta= 686000 if ano==2017
replace canasta= 4800 if ano==2018

replace lp_extrema = (canasta / 5.2)  
replace lp_moderada = (2 * canasta) / 5.2  



** ingreso oficial income_off
** ingreso oficial corregido income_off1
clonevar income0=income_off
clonevar income1=income_off1
clonevar income2=income_off1
egen income3=rowtotal(linc_imp nlinc pension2) 

foreach x in income0 income1 income2 income3 {
bysort ano id: egen `x'_hh=sum(`x')
}
gen renta=.
replace renta=0.10*income3_hh if propieta==1  
egen income4_hh=rowtotal(income3_hh renta)

foreach x in income0 income1 income2 income3 income4{
gen `x'_pc=`x'_hh/n_break
gen `x'_ppp_pc=`x'_pc/(cpi2011*icp2011)
}

*Scenario 0: Official poverty estimates 
*Scenario 1: Official poverty estimates 
*Scenario 2: Official poverty estimates 
*Scenario 3: Official poverty estimates 
*Scenario 3: Official poverty estimates 

forv i=0/4{
gen pov_mod_`i'=income`i'_pc<lp_moderada
gen pov_ext_`i'=income`i'_pc<lp_extrema
gen pov55_`i'=income`i'_ppp_pc<pl55
gen pov32_`i'=income`i'_ppp_pc<pl32
gen pov19_`i'=income`i'_ppp_pc<pl19
}

rename nodecla nodecla0
rename nodecla_hh nodecla_hh0

forv i=0/1{
replace pov_mod_`i'=. if nodecla_hh`i'>0 & pov_mod_`i'==1
replace pov_ext_`i'=. if nodecla_hh`i'>0 & pov_ext_`i'==1
replace pov55_`i'=. if nodecla_hh`i'>0 & pov55_`i'==1
replace pov32_`i'=. if nodecla_hh`i'>0 & pov32_`i'==1
replace pov19_`i'=. if nodecla_hh`i'>0 & pov19_`i'==1
}
forv i=2/2{
replace pov_mod_`i'=. if nodecla1==1 & pov_mod_`i'==1
replace pov_ext_`i'=. if nodecla1==1 & pov_ext_`i'==1
replace pov55_`i'=. if nodecla1==1 & pov55_`i'==1
replace pov32_`i'=. if nodecla1==1 & pov32_`i'==1
replace pov19_`i'=. if nodecla1==1 & pov19_`i'==1
}

tab ano
local s=r(r)
forv i=0/4{
tabstat pov_mod_`i' pov_ext_`i' pov55_`i' pov32_`i' pov19_`i' [aw=pondera], by(ano) save
forv j=1/`s'{
matrix pov_`i'=nullmat(pov_`i'),r(Stat`j')'*100
}
}

putexcel set "$pathout\VEN_income_imputation.xlsx", sheet("poverty") modify
putexcel B3=matrix(pov_0)
putexcel B11=matrix(pov_1)
putexcel B19=matrix(pov_2)
putexcel B27=matrix(pov_3)
putexcel B35=matrix(pov_4)

matrix drop _all
/*
gen pobreza2 = 99
*IF (INGPER <UNCAN)  POBREZA2=2.
replace pobreza2 = 2 if (ingper0 < lp_extrema)
*IF ((INGPER>=UNCAN) AND (INGPER<DOSCAN)) POBREZA2=1.
replace pobreza2 = 1 if (ingper0>=lp_extrema) & (ingper0 < lp_moderada)
*IF (INGPER>=DOSCAN) POBREZA2=0.
replace pobreza2 = 0 if ingper0 >= lp_moderada
*IF ((nodecla_sum_1>0) AND (POBREZA2>0))   POBREZA2=99. 
replace pobreza2 = 99 if  ((nodecla_hh0>0) & (pobreza2>0)) 

* El valor de la canasta considerado fue de 5741.06 y el número de personas para la canasta per cápita fue de 5.2.  El valor de pobreza 99 corresponde a los hogares que hayan sido calificados como pobres y algún miembro del hogar no declaro ingresos.

gen pobreza_enc = (pobreza2 == 1 | pobreza2 == 2) if pobreza2 != 99
gen pobreza_extrema_enc = (pobreza2 == 2) if pobreza2 != 99
