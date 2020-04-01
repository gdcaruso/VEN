/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global emigracion informant_emig hogar_emig numero_emig nombre_emig_0 nombre_emig_1 nombre_emig_2 nombre_emig_3 nombre_emig_4 nombre_emig_5 nombre_emig_6 nombre_emig_7 nombre_emig_8 nombre_emig_9 edad_emig_1 edad_emig_2 edad_emig_3 edad_emig_4 edad_emig_5 edad_emig_6 edad_emig_7 edad_emig_8 edad_emig_9 edad_emig_10 sexo_emig_1 sexo_emig_2 sexo_emig_3 sexo_emig_4 sexo_emig_5 sexo_emig_6 sexo_emig_7 sexo_emig_8 sexo_emig_9 sexo_emig_10


*--------- Informant in this section
 /* Informante (s10q00): 00. Quién es el informante de esta sección?
		01 = Jefe del Hogar	
		02 = Esposa(o) o Compañera(o)
		03 = Hijo(a)		
		04 = Hijastro(a)
		05 = Nieto(a)		
		06 = Yerno, nuera, suegro (a)
		07 = Padre, madre       
		08 = Hermano(a)
		09 = Cunado(a)         
		10 = Sobrino(a)
 */
	*-- Check values
	tab s10q00, mi
	*-- Standarization of missing values
	replace s10q00=. if s10q00==.a
	*-- Create auxiliary variable
	clonevar informant_ref = s10q00
	*-- Generate variable
	gen     informant_emig  = 1		if  informant_ref==1
	replace informant_emig  = 2		if  informant_ref==2
	replace informant_emig  = 3		if  informant_ref==3  | informant_ref==4
	replace informant_emig  = 4		if  informant_ref==5  
	replace informant_emig  = 5		if  informant_ref==6 
	replace informant_emig  = 6		if  informant_ref==7
	replace informant_emig  = 7		if  informant_ref==8  
	replace informant_emig  = 8		if  informant_ref==9
	replace informant_emig  = 9		if  informant_ref==10
	replace informant_emig  = 10	if  informant_ref==11
	replace informant_emig  = 11	if  informant_ref==12
	replace informant_emig  = 12	if  informant_ref==13
	
	*-- Label variable
	label var informant_emig "Informant: Emigration"
	*-- Label values	
	label def informant_emig  1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" ///
							  4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)"  6 "Padre, madre" 7 "Hermano(a)" ///
							  8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" ///
							  12 "Servicio Domestico"	
	label value informant_emig  informant_emig 


*--------- Emigrant from the household
 /* Emigrant(s10q1): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 */
	*-- Check values
	tab s10q1, mi
	*-- Standarization of missing values
	replace s10q1=. if s10q1==.a
	*-- Generate variable
	clonevar hogar_emig = s10q1
	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 2 "No"
	label value hogar_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(s10q2): 2. Cuántas personas?
 
 */
	*-- Check values
	tab s10q2, mi
	*-- Standarization of missing values
	replace s10q2=. if s10q2==.a
	*-- Generate variable
	clonevar numero_emig = s10q2
	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	*-- Cross check
	tab numero_emig hogar_emig, mi
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household(s10q2a): 2. Cuántas personas?
        
 */	
	*-- From s10q2a__0 to s10q2a__9 there is information on the names of emigrants
	*-- Drop from s10q2a__10 to s10q2a__59 (repeated variables)
	forval i = 10/59{
	drop s10q2a__`i'
	}
	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 0/9{
	*-- Standarization of missing values
	replace s10q2a__`i'="" if s10q2a__`i'=="##N/A##"
	tab s10q2a__`i', mi
	*-- Generate variable
	clonevar nombre_emig_`i' = s10q2a__`i'
	*-- Label variable
	label var nombre_emig_`i' "Name of Emigrants from the household"
	}

	*-- Cross check
	forval i = 0/9{
	tab nombre_emig_`i' hogar_emig
	}
	
	
 *--------- Age of the emigrant
 /* Age of the emigrant(s10q3): 3. Cuántos años cumplidos tiene X?
        
 */
 	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q3`i' s10q3_`i'
	*-- Label original variable
	label var s10q3_`i' "3.Cuántos años cumplidos tiene X?"
	*-- Standarization of missing values
	replace s10q3_`i'=. if s10q3_`i'==.a
		*-- Generate variable
		clonevar edad_emig_`i' = s10q3_`i'
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		*-- Cross check
		tab edad_emig_`i' hogar_emig
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (s10q4): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q4`i' s10q4_`i'
	*-- Label original variable
	label var s10q4_`i' "4. El sexo de X es?"
	*-- Standarization of missing values
	replace s10q4_`i'=. if s10q4_`i'==.a
		*-- Generate variable
		clonevar sexo_emig_`i' = s10q4_`i'
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i' 1 "Male" 2 "Female"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		
