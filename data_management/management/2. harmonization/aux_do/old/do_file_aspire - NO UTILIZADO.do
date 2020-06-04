* PERU - 2016

**************************************************************************************************
**************************************************************************************************
*** PRIMERA PARTE - VARIABLES ESPECIFICAS DE CADA PAIS/A�O
**************************************************************************************************
**************************************************************************************************


********************************************************************************
**** SOCIAL INSURANCE
********************************************************************************

** 01- CONTRIBUTORY PENSIONS

* Pensi�n de jubilaci�n/cesant�a: participatory			(SP_PI_PENSION)
* P5564A:  En los �ltimos 6 meses, �recibi� usted ingresos por conceptos de Pensi�n de jubilaci�n/cesant�a?
gen     sp_pi_pension = 0          if p5564a==2
replace sp_pi_pension = 1          if p5564a==1

* Pensi�n de jubilaci�n/cesant�a: monetary			(SP_MI_PENSION)
* P5564C-P5564E:  Monto Pensi�n por jubilaci�n/cesant�a en el pa�s / en el exterior (aux_inl4_n-aux_inl4_e: deflactadas y mensualizadas)
egen  sp_mi_pension = rsum(aux_inl4_n aux_inl4_e), missing

* Pensi�n por viudez, orfandad o sobrevivencia: participatory	(SP_PI_SURVIVORSPENSION)
* P5565A:  En los �ltimos 6 meses, �recibi� usted ingresos por conceptos de Pensi�n por viudez, orfandad o sobrevivencia?
gen     sp_pi_survivorspension = 0          if p5565a==2
replace sp_pi_survivorspension = 1          if p5565a==1

* Pensi�n por viudez, orfandad o sobrevivencia: monetary	(SP_MI_SURVIVORSPENSION)
* P5565C-P5565E:  Monto Pensi�n por viudez, orfandad o sobrevivencia en el pa�s / en el exterior (aux_inl5_n-aux_inl5_e: deflactadas y mensualizadas)
egen  sp_mi_survivorspension = rsum(aux_inl5_n aux_inl5_e), missing


** 02- OTHER SOCIAL INSURANCE
* No existe informaci�n en la encuesta


********************************************************************************
**** LABOR MARKET
********************************************************************************

** 03- PASSIVE LABOR MARKET PROGRAMS
* No existe informaci�n en la encuesta


** 04- ACTIVE LABOR MARKET PROGRAMS
* No existe informaci�n en la encuesta

********************************************************************************
**** SOCIAL ASSISTANCE
********************************************************************************

** 05- UNCONDITIONAL CASH TRANSFERS ALLOWANCES, LAST RESORT PROGRAMS
* No existe informaci�n en la encuesta


** 06- CONDITIONAL CASH TRANSFERS

* Transferencia del programa JUNTOS: participatory		(SP_PI_JUNTOS)
* P5566A:  En los �ltimos 6 meses, �recibi� usted ingresos por conceptos de Transferencia del programa JUNTOS?
gen     sp_pi_juntos = 0          if p5566a==2
replace sp_pi_juntos = 1          if p5566a==1

* Transferencia del programa JUNTOS: monetary			(SP_MI_JUNTOS)
* P5566C-P5566E:  Monto Transferencia del programa JUNTOS en el pa�s / en el exterior (aux_inl6_n-aux_inl6_e: deflactadas y mensualizadas)
egen  sp_mi_juntos = rsum(aux_inl6_n aux_inl6_e), missing

** 07- NON-CONTRIBUTORY SOCIAL PENSIONS

* Transferencia del programa PENSI�N 65: participatory		(SP_PI_PENSION65)
* P5567A:  En los �ltimos 6 meses, �recibi� usted ingresos por conceptos de Transferencia del programa PENSI�N 65?
gen     sp_pi_pension65 = 0          if p5567a==2 
replace sp_pi_pension65 = 1          if p5567a==1 
/* grupo relevante: los adultos mayores de 65 a�os en adelante */
replace sp_pi_pension65 = .          if edad<65 | edad==.

* Transferencia del programa PENSI�N 65: monetary		(SP_MI_PENSION65)
* P5567C-P5567E:  Monto Transferencia del programa PENSI�N 65 en el pa�s / en el exterior (aux_inl7_n-aux_inl7_e: deflactadas y mensualizadas)
egen  sp_mi_pension65 = rsum(aux_inl7_n aux_inl7_e), missing


** 08- FOOD AND IN-KIND TRANSFERS

* Vaso de leche: participatory		(SP_PI_VASODELECHE)
* P702: �qui�n recibi� la ayuda alimentaria o nutricional? N�mero de componente que recibi� el programa alimentario numerado en p703
* P703: 1 = Vaso de leche
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_a" seguido por el n�mero de programa mencionado en p703
gen     sp_pi_vasodeleche = 0
replace sp_pi_vasodeleche = 1   if  prog_a1==1

* Comedor popular (incluye club de madres): participatory	(SP_PI_COMEDORPOPULAR)
* P702: �qui�n recibi� la ayuda alimentaria o nutricional? N�mero de componente que recibi� el programa alimentario numerado en p703
* P703: 2 = Comedor popular (incluye club de madres)
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_a" seguido por el n�mero de programa mencionado en p703
gen     sp_pi_comedorpopular = 0
replace sp_pi_comedorpopular = 1   if  prog_a2==1

* Atenci�n Alimentaria Wawa Wasi / Cuna M�s : participatory	(SP_PI_ALIMENTARIOWAWAWASI)
* P702: �qui�n recibi� la ayuda alimentaria o nutricional? N�mero de componente que recibi� el programa alimentario numerado en p703
* P703: 5 = Atenci�n Alimentaria Wawa Wasi / Cuna M�s (Servicio de cuidado diurno)
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_a" seguido por el n�mero de programa mencionado en p703
gen     sp_pi_alimentariowawawasi = 0
replace sp_pi_alimentariowawawasi = 1   if  prog_a5==1
/* grupo relevante: los menores a 36 meses */
replace sp_pi_alimentariowawawasi = . 	if edad>=3

* Otro Programa Social de ayuda alimentaria o nutricional: participatory	(SP_PI_OTROALIMENTARIO)
* P702: �qui�n recibi� la ayuda alimentaria o nutricional? N�mero de componente que recibi� el programa alimentario numerado en p703
* P703: 6 = Otro/a? (Especifique); 7 = Otro/a? (Especifique); 8 = Otro/a? (Especifique)
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_a" seguido por el n�mero de programa mencionado en p703
gen     sp_pi_otroalimentario = 0
replace sp_pi_otroalimentario = 1   if  prog_a6==1 | prog_a7==1 | prog_a8==1

* Textos y �tiles escolares gratis: participatory		(SP_PI_UNIFORMSHOES)
* P311_1-P311_2: En los �ltimos 12 meses, gast�, obtuvo, consigui� o le regalaron? Uniforme escolar(P311_1)-Calzado escolar(P311_2): 1 = S�; 2=No
* P311A6_1-P311A6_2: �C�mo lo obtuvo? 1 = Programa social
gen sp_pi_uniformshoes = 0
replace sp_pi_uniformshoes = 1 if (p311_1==1 & p311a6_1==1) | (p311_2==1 & p311a6_2==1)
/* grupo relevante: los matriculados este a�o o el a�o anterior en alg�n centro de ense�anza */
replace sp_pi_uniformshoes = . if p311_1==. | p311_2==.

* Uniformes o calzado escolar: participatory			(SP_PI_BOOKSSUPPLIES)
* P311_3-P311_4: En los �ltimos 12 meses, gast�, obtuvo, consigui� o le regalaron? Libros y textos(P311_3)-�tiles escolares(P311_4): 1 = S�; 2=No
* P311A6_3-P311A6_4: �C�mo lo obtuvo? 1 = Programa social
gen sp_pi_bookssupplies = 0
replace sp_pi_bookssupplies = 1 if (p311_3==1 & p311a6_3==1) | (p311_4==1 & p311a6_4==1)
/* grupo relevante: los matriculados este a�o o el a�o anterior en alg�n centro de ense�anza */
replace sp_pi_bookssupplies = . if p311_3==. | p311_4==.

* Laptop del Programa �Una Laptop por Ni�o�: participatory		(SP_PI_LAPTOPPERCHILD)
* P311_8: En los �ltimos 12 meses, gast�, obtuvo, consigui� o le regalaron? Laptop del Programa �Una Laptop por Ni�o�: 1 = S�; 2=No
* P311A6_8: �C�mo lo obtuvo? 1 = Programa social
gen sp_pi_laptopperchild = 0 
replace sp_pi_laptopperchild = 1 if p311_8==1 & p311a6_8==1
/* grupo relevante: ni�os en edad escolar (6-17) asistentes a escuelas primarias o secundarias */
replace sp_pi_laptopperchild = . if asiste!=1 | nivel==0 | nivel==4 | nivel==5 | nivel==6 | edad<6 | edad>17

** 09- SCHOOL FEEDING

* Desayunos y Almuerzos Escolares: participatory		(SP_PI_SCHOOLFEEDING)
* P702: �qui�n recibi� la ayuda alimentaria o nutricional? N�mero de componente que recibi� el programa alimentario numerado en p703
* P703: 3 = Desayunos Escolares en Instituciones Educativas de Inicial, PRONOEI o Primaria � QALI WARMA; 4 = Almuerzos Escolares en Instituciones Educativas de Inicial, PRONOEI o Primaria � QALI WARMA
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_a" seguido por el n�mero de programa mencionado en p703
gen     sp_pi_schoolfeeding = 0
replace sp_pi_schoolfeeding = 1	        if  prog_a3==1 | prog_a4==1 
/* grupo relevante: los que asisten al sistema educativo */
replace sp_pi_schoolfeeding = .		if  asiste==0


** 10- PUBLIC WORKS & FOOD FOR WORK
* No existe informaci�n en la encuesta

** 11- FEE WAIVERS AND TARGETED SUBSIDIES 
* No existe informaci�n en la encuesta

** 12- OTHER SOCIAL ASSISTANCE

* Programa Nacional Wawa Wasi / Cuna M�s - Cuidado Diurno	(SP_PI_WAWAWASI)
* P711n: �qui�n recibi� la ayuda no alimentaria? N�mero de componente que recibi� el programa no alimentario numerado en p712
* P712 : 1 = Programa Nacional Wawa Wasi / Cuna M�s � Cuidado Diurno
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_na" seguido por el n�mero de programa mencionado en p712
gen     sp_pi_wawawasi = 0
replace sp_pi_wawawasi = 1   if  prog_na1==1
/* grupo relevante: ni�os menores de 47 meses de edad*/
replace sp_pi_wawawasi = . 	if edad>=4

* Programa Wawa Wasi / Cuna M�s - Acompa�amiento a Familias	(SP_PI_WAWAWASIACOMP)
* P711n: �qui�n recibi� la ayuda no alimentaria? N�mero de componente que recibi� el programa no alimentario numerado en p712
* P712 : 2 = Programa Nacional Wawa Wasi / Cuna M�s � Acompa�amiento a Familias
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_na" seguido por el n�mero de programa mencionado en p712
gen     sp_pi_wawawasiacomp = 0
replace sp_pi_wawawasiacomp = 1   if  prog_na2==1
/* grupo relevante: los menores a 36 meses */
replace sp_pi_wawawasiacomp = . 	if edad>=3

* Programa Nacional contra la Violencia Familiar y Sexual	(SP_PI_VIOLENCIA)
* P711n: �qui�n recibi� la ayuda no alimentaria? N�mero de componente que recibi� el programa no alimentario numerado en p712
* P712 : 3 = Programa Nacional contra la Violencia Familiar y Sexual � Centro de Emergencia Mujer (CEN)
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_na" seguido por el n�mero de programa mencionado en p712
gen     sp_pi_violencia = 0
replace sp_pi_violencia = 1   if  prog_na3==1

* Programa Beca 18						(SP_PI_BECA18)
* P711n: �qui�n recibi� la ayuda no alimentaria? N�mero de componente que recibi� el programa no alimentario numerado en p712
* P712 : 10 = Programa Beca 18
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_na" seguido por el n�mero de programa mencionado en p712
gen     sp_pi_beca18 = 0
replace sp_pi_beca18 = 1   if  prog_na10==1
/* grupo relevante: menores de 22 a�os con estudios secundarios completos que asisten a un establecimiento educativo */
replace sp_pi_beca18 = . 	if (edad>=23 | nivel==0 | nivel==1 | nivel==2 | nivel==3 | asiste==0) 

* Otro Programa Social no alimentario				(SP_PI_OTRO)
* P711n: �qui�n recibi� la ayuda no alimentaria? N�mero de componente que recibi� el programa no alimentario numerado en p712
* P712 : 11 = Otro/a? (Especifique); 12 = Otro/a? (Especifique); 13 = Otro/a? (Especifique)
* Estas variables son convertidas en el do _base de Per� en dummies de percepci�n de programa con el nombre "prog_na" seguido por el n�mero de programa mencionado en p712
gen     sp_pi_otro = 0
replace sp_pi_otro = 1   if  prog_na11==1 | prog_na12==1 | prog_na13==1 

* Matricula, APAFA y otras ayudas escolares			(SP_PI_FEESANDOTHER)
* P311_5-P311_6-P311_7: En los �ltimos 12 meses, gast�, obtuvo, consigui� o le regalaron? Matr�cula(P311_5)-APAFA(P311_5)-Otros(fotocopias, cuotas extraordinarias, etc)(P311_6): 1 = S�; 2=No
* P311A6_5-P311A6_6-P311A6_7: �C�mo lo obtuvo? 1 = Programa social
gen sp_pi_feesandother = 0
replace sp_pi_feesandother = 1 if (p311_5==1 & p311a6_5==1) | (p311_6==1 & p311a6_6==1) | (p311_7==1 & p311a6_7==1)
/* grupo relevante: los matriculados este a�o o el a�o anterior en alg�n centro de ense�anza */
replace sp_pi_feesandother = . if p311_5==. | p311_6==. | p311_7==.

********************************************************************************
**** PRIVATE TRANSFERS
********************************************************************************


** 13- DOMESTIC PRIVATE TRANSFERS

* Pensi�n por divorcio/separaci�n del pa�s: monetary		(PT_MI_DIVORCIO_ALIMT_LOCAL)
* P5561C:  Monto Pensi�n por divorcio/separaci�n del pa�s       (aux_inl1_n: deflactada y mensualizada)
gen  pt_mi_divorcio_alimt_local = aux_inl1_n

* Pensi�n por alimentaci�n dentro del pais: monetary		(PT_MI_ALIMENT_LOCAL)
* P5562C:  Monto Pensi�n por alimentaci�n del pa�s	        (aux_inl2_n: deflactada y mensualizada)
gen  pt_mi_aliment_local  = aux_inl2_n

* Remesas nacionales						(PT_MI_DOMESTICREMITTANCES)
* P5563C:  Monto Remesas de otros hogares o personas del pais   (aux_inl3_n: deflactada y mensualizada)
gen  pt_mi_domesticremittances = aux_inl3_n

** 14- INTERNATIONAL PRIVATE TRANSFERS

* Pensi�n por divorcio/separaci�n del extranjero: monetary	(PT_MI_DIVORCIO_EXTRA)
* P5561E:  Monto Pensi�n por divorcio/separaci�n del extranjero (aux_inl1_e: deflactada y mensualizada)
gen  pt_mi_divorcio_extra = aux_inl1_e

* Pensi�n por alimentaci�n del extranjero: monetary		(PT_MI_ALIMENT_EXTRA)
* P5562E:  Monto Pensi�n por alimentaci�n del extranjero	(aux_inl2_e: deflactada y mensualizada)
gen  pt_mi_aliment_extra  = aux_inl2_e

* Remesas del extranjero					(PT_MI_REMITTANCESFROMABROAD)
* P5563E:  Monto Remesas de otros hogares o personas del extranjero   (aux_inl3_e: deflactada y mensualizada)
gen  pt_mi_remittancesfromabroad = aux_inl3_e






**************************************************************************************************
**************************************************************************************************
*** SEGUNDA PARTE - VARIABLES ARMONIZADAS
**************************************************************************************************
**************************************************************************************************
sort id com

**********************************************
******* SOCIAL INSURANCE 
**********************************************

***** 01 - CONTRIBUTORY PENSIONS   	
egen   auxi_pensions = rsum(sp_mi_pension sp_mi_survivorspension), missing
by id: egen pensions = sum(auxi_pensions), missing

egen    aux_pension	     = max(sp_pi_pension), by(id)
egen    aux_survivorspension = max(sp_pi_survivorspension), by(id)

gen     d_pensions = 0		
replace d_pensions = 1		if  aux_pension==1 | aux_survivorspension==1  
replace d_pensions = 1		if  pensions>0 & pensions<.


***** 02 - OTHER SOCIAL INSURANCE
* No existe informaci�n sobre ingresos en esta categor�a
gen     socialsecu = .

gen     d_socialsecu = 0
replace d_socialsecu = 1 	if  socialsecu>0 & socialsecu<.	  
 




**********************************************
******* LABOR MARKET 
**********************************************

***** 03 - LABOR MARKET POLICY MEASURES (ACTIVE LM PROGRAMS)
* No existe informaci�n sobre ingresos en esta categor�a
gen     activelabor = .

gen     d_activelabor = 0	 
replace d_activelabor = 1	if  activelabor>0 & activelabor<.


***** 04 - LABOR MARKET POLICY SUPPORT (PASSIVE LM PROGRAMS)
* No existe informaci�n sobre ingresos en esta categor�a
gen     passivelabor = .

gen     d_passivelabor = 0	   
replace d_passivelabor = 1	if  passivelabor>0 & passivelabor<.  




**********************************************
******* SOCIAL ASSISTANCE 
**********************************************
  
***** 05 - UNCONDITIONAL CASH TRANSFERS	
* No existe informaci�n sobre ingresos en esta categor�a
gen     cashtransfer = . 

gen     d_cashtransfer = 0	   
replace d_cashtransfer = 1	if  cashtransfer>0 & cashtransfer<.    


***** 06 - CONDITIONAL CASH TRANSFERS	
by id: egen cct = sum(sp_mi_juntos), missing

egen    aux_cct = max(sp_pi_juntos), by(id)

gen     d_cct = 0
replace d_cct = 1		if  aux_cct==1
replace d_cct = 1		if  cct>0 & cct<.            


***** 07 - Social pensions (non-contributory)	
by id: egen socialpension = sum(sp_mi_pension65), missing 

egen    aux_socialpension = max(sp_pi_pension65), by(id)

gen     d_socialpension = 0	
replace d_socialpension = 1 	if  aux_socialpension==1
replace d_socialpension = 1 	if  socialpension>0 & socialpension<.   


***** 08 - Food and in-kind transfers 
* No existe informaci�n sobre ingresos en esta categor�a
gen     inkind = .   

local programs = "vasodeleche comedorpopular alimentariowawawasi otroalimentario bookssupplies uniformshoes laptopperchild"
foreach i of local programs {
	egen    aux_`i' = max(sp_pi_`i'), by(id)
	}

gen     d_inkind = 0		         
replace d_inkind = 1		if  aux_vasodeleche==1 | aux_comedorpopular==1 | aux_alimentariowawawasi==1 | aux_otroalimentario==1 | aux_bookssupplies==1 | aux_uniformshoes==1 | aux_laptopperchild==1
replace d_inkind = 1		if  inkind>0 & inkind<.         


***** 09 - SCHOOL FEEDING 
* No existe informaci�n sobre ingresos en esta categor�a
gen     schoolfeed = .

egen    aux_feeding = max(sp_pi_schoolfeeding), by(id) 

gen     d_schoolfeed = 0	    
replace d_schoolfeed = 1 	if  aux_feeding==1    
replace d_schoolfeed = 1 	if  schoolfeed>0 & schoolfeed<.


***** 10 - PUBLIC WORKS, WORKFARE AND DIRECT JOB CREATION  
* No existe informaci�n sobre ingresos en esta categor�a
gen     publicworks = .

gen     d_publicworks = 0	   
replace d_publicworks = 1	if  publicworks>0 & publicworks<.   


***** 11 - FEE WAIVERS AND SUBSIDIES 	
* No existe informaci�n sobre ingresos en esta categor�a
gen     subsidies = . 

gen     d_subsidies = 0		     
replace d_subsidies = 1		if  subsidies>0 & subsidies<.     


***** 12 - OTHER SOCIAL ASSISTANCE	
* No existe informaci�n sobre ingresos en esta categor�a
gen     othersa = .   

local programs = "wawawasi wawawasiacomp violencia beca18 otro feesandother"
foreach i of local programs {
	egen    aux_`i' = max(sp_pi_`i'), by(id)
	}

gen     d_othersa = 0	
replace d_othersa = 1		if  aux_wawawasi==1 | aux_wawawasiacomp==1 | aux_violencia==1 | aux_beca18==1 | aux_otro==1 | aux_feesandother==1
replace d_othersa = 1		if  othersa>0 & othersa<.     




**********************************************
******* PRIVATE TRANSFERS
**********************************************

***** 13 - DOMESTIC PRIVATE TRANSFERS 
egen   auxi_domprivate = rsum(pt_mi_divorcio_alimt_local pt_mi_aliment_local pt_mi_domesticremittances), missing
by id: egen domprivate = sum(auxi_domprivate), missing

gen     d_domprivate = 0	  
replace d_domprivate = 1	if  domprivate>0 & domprivate<.  


***** 14 - INTERNATIONAL PRIVATE TRANSFERS 	
egen auxi_interprivate   = rsum(pt_mi_divorcio_extra pt_mi_aliment_extra pt_mi_remittancesfromabroad), missing   
by id: egen interprivate = sum(auxi_interprivate), missing

gen     d_interprivate = 0	  
replace d_interprivate = 1 	if  interprivate>0 & interprivate<. 






