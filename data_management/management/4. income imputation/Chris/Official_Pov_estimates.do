/*====================================================================
project:       ENCOVI poverty calculations check
Author:        Christian G Canon 
----------------------------------------------------------------------
Creation Date:     3 Mar 2020 - 15:29:57
====================================================================*/



/*====================================================================
                        0: Program set up
====================================================================*/


/*				Opening file		*/
tempfile pfile
tempname pname
postfile `pname' str30(Year Measure Base Value) using `pfile', replace
/*
global data "Z:\wb509172\Venezuela\ENCOVI\Data\FINAL_DATA_BASES\Data"
global excel "Z:\wb509172\Venezuela\ENCOVI\Projects\5. ENCOVI Scripts\excel"
*/
global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
global dataout "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\bases"
global aux_do "$rootpath\ENCOVI 2014 - 2018\Projects\SEDLAC Harmonization\dofiles\aux_do"
global dataofficial "$rootpath\ENCOVI 2014 - 2018\Data\OFFICIAL_ENCOVI"
global data2014 "$dataofficial\ENCOVI 2014\Data"
global data2015 "$dataofficial\ENCOVI 2015\Data"
global data2016 "$dataofficial\ENCOVI 2016\Data"
global data2017 "$dataofficial\ENCOVI 2017\Data"
global data2018 "$dataofficial\ENCOVI 2018\Data"
global datafinalharm "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI harmonized data"
global datafinalimp "$rootpath\ENCOVI 2014 - 2018\Data\FINAL_DATA_BASES\ENCOVI imputation data"

/*====================================================================
                        1. Calculations
====================================================================*/

/********************************************************************/
/**************** Calculation for 2014 ******************************/
/********************************************************************/ 

*use "Z:\wb509172\Venezuela\ENCOVI\Data\OFFICIAL_ENCOVI\ENCOVI 2014\Data\CMHCVIDA", clear
use "$data2014\CMHCVIDA.dta", clear

* compute nodecla=0.
gen nodecla = 0
* compute monto=0.
gen monto = 0
* if ((tp51m<98)  or  (tp51m>99)) monto=tp51m.
replace monto = tp51m if ((tp51m<98) | (tp51m>99))
* if ((tp51m=99) AND (tp47>0) AND (tp47 <3))   nodecla=1.
replace nodecla = 1 if ((tp51m==99) & (tp47>0) & (tp47 <3))
* if ((pp630m<98) or  (pp630m>99)) monto=monto+ pp630m.
replace monto = monto + pp630m if ((pp630m<98) | (pp630m>99)) //error pp630m no em
* if ((pp63em<98) or  (pp63em>99)) monto=monto+ pp63em.
replace monto = monto + pp63em if ((pp63em<98) | (pp63em>99))
* if ((pp63pm<98) or  (pp63pm>99)) monto=monto+ pp63pm.
replace monto = monto + pp63pm if ((pp63pm<98) |  (pp63pm>99))
* if ((pp63sm<98) or  (pp63sm>99)) monto=monto+ pp63sm.
replace monto = monto + pp63sm if ((pp63sm<98) | (pp63sm>99))


**Posteriormente se agregó utilizando como variable clave CONTROL y se generó un archivo de ingresos a nivel de hogar con el ingreso con los siguientes campos: monto_sum_1(Monto del ingreso del hogar), nodecla_sum_1(Número de personas sin ingreso declarado) y N_BREAK (Número de personas por hogar).
**Esas variables fueron incorporadas al archivo de hogares CODVIDA.SAV y se aplicó la siguiente sintaxis: 

egen monto_sum_1 = sum(monto), by(control)
gen pt = 1
egen n_break = sum(pt), by(control) 
egen nodecla_sum_1 = sum(nodecla), by(control)

*COMPUTE INGPER = monto_sum_1 /N_BREAK. 
gen ingper = monto_sum_1 / n_break 

*COMPUTE UNCAN=5741.06/5.2.
gen uncan = 5741.06 / 5.2

*COMPUTE DOSCAN=2*5741.06/5.2. 
gen doscan = (2 * (5741.06) / (5.2))

*COMPUTE POBREZA2=99.
gen pobreza2 = 99
*IF (INGPER <UNCAN)  POBREZA2=2.
replace pobreza2 = 2 if (ingper < uncan)
*IF ((INGPER>=UNCAN) AND (INGPER<DOSCAN)) POBREZA2=1.
replace pobreza2 = 1 if (ingper>=uncan) & (ingper < doscan)
*IF (INGPER>=DOSCAN) POBREZA2=0.
replace pobreza2 = 0 if ingper >= doscan
*IF ((nodecla_sum_1>0) AND (POBREZA2>0))   POBREZA2=99. 
replace pobreza2 = 99 if  ((nodecla_sum_1>0) & (pobreza2>0)) 

* El valor de la canasta considerado fue de 5741.06 y el número de personas para la canasta per cápita fue de 5.2.  El valor de pobreza 99 corresponde a los hogares que hayan sido calificados como pobres y algún miembro del hogar no declaro ingresos.

gen pobreza_enc = (pobreza2 == 1 | pobreza2 == 2) if pobreza2 != 99
gen pobreza_extrema_enc = (pobreza2 == 2) if pobreza2 != 99
sum pobreza_enc 
local pov = `r(mean)' * 100
sum pobreza_extrema_enc 
local pov_ext = `r(mean)' * 100
sum pt 
local pob = `r(sum)'
;
post `pname' ("2014") ("Observaciones") ("Script") ("`pob'")
post `pname' ("2014") ("Pobreza") ("Script") ("`pov'")
post `pname' ("2014") ("Pobreza extrema") ("Script") ("`pov_ext'")
  

/********************************************************************/
/**************** Calculation for 2015 ******************************/
/********************************************************************/ 

*La siguiente rutina se corrió sobre el archive de personas : PersonasEncovi2015.SAV
*use "Z:\wb509172\Venezuela\ENCOVI\Data\OFFICIAL_ENCOVI\ENCOVI 2015\Data\Personas Encovi 2015", clear
use "$data2015\Personas Encovi 2015.dta", clear

* compute nodecla=0.
cap drop nodecla monto
gen nodecla = 0
* compute monto=0.
gen monto = 0
*if ((tp50m<98)  or  (tp50m>99)) monto=tp50m.
replace monto = tp50m if ((tp50m<98) | (tp50m>99))
*if (((tp50m=99) OR  (tp50m=0)) AND (tp45>0) AND (tp45 <3)) nodecla=1.
replace nodecla = 1 if (((tp50m==99) | (tp50m==0)) & (tp45>0) & (tp45 <3))
*if ((tp51m<98) or  (tp51m>99)) monto=monto+ tp51m.
replace monto = monto + tp51m if  ((tp51m<98) | (tp51m>99))

**Posteriormente se agregó utilizando como variable clave CONTROL y se generó un archivo de ingresos a nivel de hogar con el ingreso con los siguientes campos: monto_sum_1(Monto del ingreso del hogar), nodecla_sum_1(Número de personas sin ingreso declarado) y N_BREAK (Número de personas por hogar).
**Esas variables fueron incorporadas al archivo de hogares Personas Encovi 2015 y se aplicó la siguiente sintaxis: 

egen monto_sum_1 = sum(monto), by(control)
gen pt = 1
egen n_break = sum(pt), by(control) 
egen nodecla_sum_1 = sum(nodecla), by(control)


* COMPUTE INGPER =monto_sum/N_BREAK. 
gen ingper = monto_sum_1 / n_break 
* COMPUTE UNCAN=15556/5.2.
gen uncan = 15556 / 5.2
* COMPUTE DOSCAN=2*15556/5.2. 
gen doscan =  (2 * 15556) / 5.2
* COMPUTE POBREZA=99.
gen pobreza = 99
* IF (INGPER <UNCAN)  POBREZA=2.
replace pobreza = 2 if (ingper < uncan)
* IF ((INGPER>=UNCAN) AND (INGPER<DOSCAN)) POBREZA=1.
replace pobreza = 1 if (ingper>=uncan) & (ingper < doscan)
* IF (INGPER>=DOSCAN) POBREZA=0.
replace pobreza = 0 if ingper >= doscan
* IF ((nodecla_first>0) AND (POBREZA>0))   POBREZA=99. 
replace pobreza = 99 if  ((nodecla_sum_1>0) & (pobreza>0)) 

* El valor de la canasta considerado fue de 15.556 Bs y el número de personas para la canasta per cápita fue de 5.2.  El valor de pobreza 99 corresponde a los hogares que hayan sido calificados como pobres y algún miembro del hogar no declaro ingresos.


gen pobreza_enc = (pobreza == 1 | pobreza == 2) if pobreza != 99
gen pobreza_extrema_enc = (pobreza == 2) if pobreza != 99
sum pobreza_enc 
local pov = `r(mean)' * 100
sum pobreza_extrema_enc 
local pov_ext = `r(mean)' * 100
sum pt
local pob = `r(sum)'

post `pname' ("2015") ("Observaciones") ("Script") ("`pob'")
post `pname' ("2015") ("Pobreza") ("Script") ("`pov'")
post `pname' ("2015") ("Pobreza extrema") ("Script") ("`pov_ext'")


/********************************************************************/
/**************** Calculation for 2016 ******************************/
/********************************************************************/ 

*use "Z:\wb509172\Venezuela\ENCOVI\Data\OFFICIAL_ENCOVI\ENCOVI 2016\Data\Personas Encovi2016", clear
use "$data2016\Personas Encovi2016.dta", clear

*compute nodecla=0.
gen nodecla = 0
*compute monto=0.
gen monto = 0
*compute t1=tp47m.
gen t1 = TP47M

**MONTO DE INGRESO CON LA PREGUNTA 48.
**NO DECLARADOS POR INGRESOS**.
* if t1 =99  nodecla=1.
replace nodecla = 1 if t1 == 99
* if (t1 <98)  AND ((tp47=1)  or (tp47=99 ))   nodecla=1.
replace nodecla = 1 if (t1 < 98)  & ((TP47==1) | (TP47==99 )) //mal codificado deberia ser 

*****NO DECLARADOS POR INGRESOS PREGUNTA 48.
*if TP48M =99  nodecla=1.
replace nodecla = 1 if TP48M == 99
***NO DECLARADO POR PENSIONES.
*IF (PP61SM =99 OR PP61EM=99 OR PP61PM=99 OR PP61PM=99)  nodecla=1. 
replace nodecla = 1 if (PP61SM ==99 | PP61EM==99 | PP61PM==99 | PP61PM==99) //error
**MONTO DE INGRESO CON LA PREGUNTA 61.
* if ((t1 >99)) monto=t1 .
replace monto = t1 if ((t1 >99))
* if ( TP48M >99) monto=monto+TP48M.
replace monto= monto + TP48M if ( TP48M >99)
* if ((PP61SM >99)) monto=monto+ PP61SM .
replace monto = monto + PP61SM if ((PP61SM >99))
* if ( (PP61EM >99)) monto=monto+ PP61EM .
replace monto = monto + PP61EM if ( (PP61EM >99)) 
* if ((PP61PM>99)) monto=monto+ PP61PM.
replace monto = monto + PP61PM if ((PP61PM>99))
* if ((PP61PM>99)) monto=monto+ PP61PM.
replace monto = monto + PP61OM if (PP61OM>99) //error

**Posteriormente se agregó utilizando como variable clave CONTROL y se generó un archivo de ingresos a nivel de hogar con el ingreso con los siguientes campos: monto_sum (Monto del ingreso del hogar), nodecla_sum (Número de personas sin ingreso declarado) y N_BREAK (Número de personas por hogar).
**Por último  se aplicó la siguiente sintaxis: 

egen monto_sum_1 = sum(monto), by(control)
gen pt = 1
egen n_break = sum(pt), by(control) 
egen nodecla_sum_1 = sum(nodecla), by(control)

* COMPUTE CANASTA=69540.
gen canasta = 69540
* COMPUTE INGPER3=  monto_sum_1/  N_BREAK.
gen ingper = monto_sum_1 / n_break
* COMPUTE UNCAN=CANASTA/5.2.
gen uncan = canasta / 5.2
* COMPUTE DOSCAN=2*CANASTA/5.2.
gen doscan = (2 * canasta) / 5.2 
* COMPUTE POBREZA=99.
gen pobreza = 99

* IF (INGPER3 <UNCAN)  POBREZA=2.
replace pobreza = 2 if (ingper < uncan)
* IF ((INGPER3>=UNCAN) AND (INGPER3<DOSCAN)) POBREZA=1.
replace pobreza = 1 if ((ingper>=uncan) & (ingper<doscan))
* IF (INGPER3>=DOSCAN) POBREZA=0.
replace pobreza = 0 if ingper > doscan 
*IF ((   NODECLA_SUM_1>0) AND (POBREZA>0))   POBREZA=99. 
replace pobreza = 99 if ((nodecla_sum_1>0) & (pobreza>0))
 
* El valor de la canasta considerado fue de 69.540 BS.y el número de personas para la canasta per cápita fue de 5.2.  El valor de pobreza 99 corresponde a los hogares que hayan sido calificados como pobres y algún miembro del hogar no declaro ingresos.


gen pobreza_enc = (pobreza == 1 | pobreza == 2) if pobreza != 99
gen pobreza_extrema_enc = (pobreza == 2) if pobreza != 99
sum pobreza_enc 
local pov = `r(mean)' * 100
sum pobreza_extrema_enc 
local pov_ext = `r(mean)' * 100
sum pt
local pob = `r(sum)'

post `pname' ("2016") ("Observaciones") ("Script") ("`pob'")
post `pname' ("2016") ("Pobreza") ("Script") ("`pov'")
post `pname' ("2016") ("Pobreza extrema") ("Script") ("`pov_ext'")



/********************************************************************/
/**************** Calculation for 2017 ******************************/
/********************************************************************/ 
*La siguiente rutina se corrió sobre el archive de personas: PERSONAS_ENCOVI_2017.SAV

*use "Z:\wb509172\Venezuela\ENCOVI\Data\OFFICIAL_ENCOVI\ENCOVI 2017\Data\PERSONAS_ENCOVI_2017" , clear
use "$data2017\PERSONAS_ENCOVI_2017.dta", clear
* compute nodecla=0.
cap drop nodecla monto
gen nodecla = 0
* compute monto=0.
gen monto = 0 
 
*ingreso por trabajo.
* compute t1=TMHP44BS.
gen t1 = TMHP44BS
* if t1 =99  nodecla=1.
replace nodecla = 1 if t1 == 99
 * if TMHP44=99 nodecla=1.
replace nodecla = 1 if TMHP44 == 99

*Otros ingresos.
*compute t2= TMHP45BS.
gen t2 = TMHP45BS
*if t2 =99  nodecla=1.
replace nodecla = 1 if t2 == 99
**MONTO DE INGRESO CON LA PREGUNTA 61.

* COMPUTE T3= PMHP60BS.
gen t3 = PMHP60BS
* if t3 =99  nodecla=1.
replace nodecla = 1 if t3 == 99
* if PMHP60A=99 nodecla=1.
replace nodecla = 1 if PMHP60A == 99
* IF T1>99 MONTO=MONTO+T1.
replace monto = monto + t1 if t1>99
* IF T2>99 MONTO=MONTO+T2.
replace monto = monto + t2 if t2>99
* IF T3>99 MONTO=MONTO+T3.
replace monto = monto + t3 if t3>99

**Posteriormente se agregó utilizando como variable clave CONTROL y se generó un archivo de ingresos a nivel de hogar con el ingreso con los siguientes campos: monto_sum (Monto del ingreso del hogar), nodecla_sum (Número de personas sin ingreso declarado) y N_BREAK (Número de personas por hogar).
**Por último  se aplicó la siguiente sintaxis: 

egen monto_sum_1 = sum(monto), by(ennumc)
gen pt = 1
egen n_break = sum(pt), by(ennumc) 
egen nodecla_sum_1 = sum(nodecla), by(ennumc)

* COMPUTE  CANASTA=686000.
gen canasta = 686000
* COMPUTE INGPER3=  monto_sum/  N_BREAK.
gen ingper = monto_sum_1 / n_break
* COMPUTE UNCAN=CANASTA/5.2.
gen uncan = canasta / 5.2
* COMPUTE DOSCAN=2*CANASTA/5.2. 
gen doscan = (2 * canasta / 5.2)
* COMPUTE POBREZA=99.
gen pobreza = 99

* IF (INGPER3 <UNCAN)  POBREZA=2.
replace pobreza = 2 if ingper < uncan 
* IF ((INGPER3>=UNCAN) AND (INGPER3<DOSCAN)) POBREZA=1.
replace pobreza = 1 if (ingper>= uncan & ingper < doscan)
* IF (INGPER3>=DOSCAN) POBREZA=0.
replace pobreza = 0 if ingper >= doscan
* IF ((   NODECLA_SUM>0) AND (POBREZA>0))   POBREZA=99. 
replace pobreza = 99 if (nodecla_sum_1>0 & pobreza>0)


* El valor de la canasta considerado fue de 686.000 BS.y el número de personas para la canasta per cápita fue de 5.2.  El valor de pobreza 99 corresponde a los hogares que hayan sido calificados como pobres y algún miembro del hogar no declaro ingresos.


gen pobreza_enc = (pobreza == 1 | pobreza == 2) if pobreza != 99
gen pobreza_extrema_enc = (pobreza == 2) if pobreza != 99
sum pobreza_enc 
local pov = `r(mean)' * 100
sum pobreza_extrema_enc 
local pov_ext = `r(mean)' * 100
sum pt
local pob = `r(sum)'

post `pname' ("2017") ("Observaciones") ("Script") ("`pob'")
post `pname' ("2017") ("Pobreza") ("Script") ("`pov'")
post `pname' ("2017") ("Pobreza extrema") ("Script") ("`pov_ext'")



/********************************************************************/
/**************** Calculation original dataset***********************/
/********************************************************************/ 

forvalues y = 2014/2017 {
	dlw, coun(VEN) y(`y') t(SEDLAC-03) mod(ALL) verm(01) vera(01) sur(ENCOVI)
	sum pobreza_enc 
	local pov = `r(mean)' * 100
	sum pobreza_extrema_enc 
	local pov_ext = `r(mean)' * 100
	gen pt = 1
	sum pt 
	local pob = `r(sum)'

	post `pname' ("`y'") ("Observaciones") ("Base") ("`pob'") 
	post `pname' ("`y'") ("Pobreza") ("Base") ("`pov'")
	post `pname' ("`y'") ("Pobreza extrema") ("Base") ("`pov_ext'")
	}


/*			Close file and use it				*/

postclose `pname'
use `pfile', clear


export excel "${excel}/Script_base_comparisson.xlsx", sheetreplace sheet(raw) first(variables)
























/*


Encuesta: ENCOVI 2018
La siguiente rutina se corrió sobre el archive de personas: PERSONAS_ENCOVI_2018.SAV

use "$data2018\PERSONAS ENCOVI 2018.dta", clear

COMPUTE T1=0. 
COMPUTE T2=0.
COMPUTE T3=0.
compute monto=0.



*ingreso por trabajo.

IF TMHP42BS>99 T1=TMHP42BS.
IF TMHP42BS=99 NODECLA=1.


if TMHP42=99 nodecla=1.

*if TMHP42=1 AND  TMHP52BS<100  nodecla=1.

*Otros ingresos.
IF TMHP52BS>99  T2=TMHP52BS.
IF TMHP52BS=99 NODECLA=1.

IF PMHP55BS>99 T3=PMHP55BS. 
IF PMHP55BS=99 AND TMHP52BS=99 NODECLA=1.. 

IF T1>99 MONTO=MONTO+T1.
IF T2>99 MONTO=MONTO+T2.
IF T3>99 AND TMHP52BS=99  MONTO=MONTO+T3.

**Posteriormente se agregó utilizando como variable clave CONTROL y se generó un archivo de ingresos a nivel de hogar con el ingreso con los siguientes campos: monto_sum (Monto del ingreso del hogar), nodecla_sum (Número de personas sin ingreso declarado) y N_BREAK (Número de personas por hogar).

    
COMPUTE  CANASTA=4800.		.

			
COMPUTE INGPER3=  (monto_sum*1000/100000)/N_BREAK.



COMPUTE UNCAN=CANASTA/5.2.
COMPUTE DOSCAN=2*CANASTA/5.2. 
COMPUTE POBREZA=99.


IF (INGPER3 <UNCAN)  POBREZA=2.
IF ((INGPER3>=UNCAN) AND (INGPER3<DOSCAN)) POBREZA=1.
IF (INGPER3>=DOSCAN) POBREZA=0.

IF (( NODECLA_SUM>0) AND (POBREZA>0))   POBREZA=99. 
   
VALUE LABELS POBREZA
0"No pobre"
1"Pobre no extremo"
2"Pobre extremo"
99"No declarado".



El valor de la canasta considerado fue de 4.800 BS y el número de personas para la canasta per cápita fue de 5.2.  El valor de pobreza 99 corresponde a los hogares que hayan sido calificados como pobres y algún miembro del hogar no declaro ingresos.












exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
