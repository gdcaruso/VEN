/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	


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
	clonevar house_emig = s10q1
	*-- Label variable
	label var house_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 2 "No"
	label value house_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(s10q2): 2. Cuántas personas?
 
 */
	*-- Check values
	tab s10q2, mi
	*-- Standarization of missing values
	replace s10q2=. if s10q2==.a
	*-- Generate variable
	clonevar number_emig = s10q2
	*-- Label variable
	label var number_emig "Number of Emigrants from the household"
	*-- Cross check
	tab number_emig house_emig, mi
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household(s10q2a): 2. Cuántas personas?
        
 */	
	*-- From s10q2a__0 to s10q2a__9 there is information on the names of emigrants
	*-- Drop from s10q2a__10 to s10q2a__59 (repeated variables)
	forval i = 10/59{
	drop s10q2a__`i'
	}
	
	*-- Standarization of missing values
	replace s10q2a__*="" if s10q2a=="##N/A##"
	replace s10q2a="." if s10q2a==""
	*-- Check values
	tab s10q2a, mi
	*-- Generate variable
	clonevar name_emig = s10q2a
	*-- Label variable
	label var name_emig "Name of Emigrants from the household"
	*-- Cross check
	tab name_emig house_emig
	
 *--------- Age of the emigrant
 /* Age of the emigrant(s10q3): 3. Cuántos años cumplidos tiene X?
        
 */
 	*-- Rename main variable 
	rename s10q31 s10q3
	*-- Label original variable
	label var s10q3 "3.Cuántos años cumplidos tiene X?"
	*-- Check values 
	tab s10q3, mi
	*-- Standarization of missing values
	replace s10q3=. if s10q3==.a
	*-- Generate variable
	clonevar age_emig = s10q3
	*-- Label variable
	label var age_emig "Age of Emigrants"
	tab age_emig
	
 *--------- Sex of the emigrant 
 /* Sex (s10q4): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
	*-- Rename main variable 
	rename s10q41 s10q4
	*-- Label original variable
	label var s10q4 "4. El sexo de X es?"
	*-- Check values
	tab s10q4, mi
	*-- Standarization of missing values
	replace s10q4=. if s10q4==.a
	*-- Generate variable
	clonevar sex_emig = s10q4
	*-- Label variable
	label var sex_emig "Sex of Emigrants"
	*-- Label values
	label def sex_em 1 "Male" 2 "Female"
	label value sex_em sex_emig
	*-- Cross check
	tab sex_emig house_emig

 *--------- Relationship of the emigrant with the head of the household
 /* Relationship (s10q5): 5. Cuál es el parentesco de X con el Jefe(a) del hogar?
        
 */
	*-- Rename main variable 
	rename s10q51 s10q5
	*-- Label original variable
	label var s10q5 "5. Cuál es el parentesco de X con el Jefe(a) del hogar?"
	*-- Check values
	tab s10q5, mi
	*-- Standarization of missing values
	replace s10q5=. if s10q5==.a
	*-- Generate variable
	//clonevar rel_emig = s10q5
	*-- Label variable
	//label var rel_emig "Sex of Emigrants"
	*-- Label values
	//label def rel_em 1 "Male" 2 "Female"
	//label value rel_em rel_emig
	*-- Cross check
	tab rel_emig house_emig
	
 *--------- Year in which the emigrant left the household
 /* Year (s10q6a): 6a. En qué año se fue X ?
        
 */	
	*-- Rename main variable 
	rename s10q6a1 s10q6a
	*-- Drop repeated variables 
	drop s10q6a*
	*-- Label original variable
	label var s10q6a "6a. En qué año se fue X ?"
	*-- Check values
	tab s10q6a, mi
	*-- Standarization of missing values
	replace s10q6a=. if s10q6a==.a
	*-- Generate variable
	clonevar year_emig = s10q6a
	*-- Label variable
	label var year_emig "Year of emigration"
	*-- Cross check
	tab year_emig house_emig
	
 *--------- Month in which the emigrant left the household
 /* Month (s10q6b): 6a. En qué mes se fue X ?
        
 */	
 	*-- Rename main variable 
	rename s10q6b1 s10q6b
	*-- Drop repeated variables 
	drop s10q6b*
	*-- Label original variable
	label var s10q6b "6b. En qué año se fue X ?"
	*-- Check values
	tab s10q6b, mi
	*-- Standarization of missing values
	replace s10q6b=. if s10q6b==.a
	*-- Generate variable
	clonevar month_emig = s10q6b
	*-- Label variable
	label var month_emig "Year of emigration"
	*-- Cross check
	tab month_emig house_emig


  *--------- Latest education level atained by the emigrant 
 /* Education level (s10q7): 7. Cuál fue el último nivel educativo en el que
							 X aprobó un grado, año, semestre o trimestre?       
 */
 	*-- Rename main variable 
	rename s10q71 s10q7
	*-- Drop repeated variables 
	drop s10q72 s10q73 s10q74 s10q75 s10q76 s10q77 s10q78 s10q79 s10q710
	*-- Label original variable
	label var s10q7 "7. Cuál fue el último nivel educativo en el que X aprobó un grado, año, semestre o trimestre?"
	*-- Check values
	tab s10q7, mi
	*-- Standarization of missing values
	replace s10q7=. if s10q7==.a
	*-- Generate variable
	clonevar leveledu_emig = s10q7
	*-- Label variable
	label var leveledu_emig "Education level emigrant"
	*-- Cross check
	tab leveledu_emig house_emig

 *--------- Latest education grade atained by the emigrant 
 /* Education level (s10q7a): 7a. Cuál fue el último GRADO aprobado por X?     
 */	
 	*-- Rename main variable 
	rename s10q7a1 s10q7a
	*-- Drop repeated variables 
	drop s10q7a*
	*-- Label original variable
	label var s10q7a "7a. Cuál fue el último GRADO aprobado por X?"
	*-- Check values
	tab s10q7a, mi
	*-- Standarization of missing values
	replace s10q7a=. if s10q7a==.a
	*-- Generate variable
	clonevar edug_emig = s10q7a
	*-- Label variable
	label var edug_emig "Education grade emigrant"
	*-- Cross check
	tab edug_emig house_emig


 *--------- Education regime 
 /* Education regime (s10q7ba): 7ab. El régimen de estudio era anual, semestral o
							   trimestral?
								01 Anual
								02 Semestral
								03 Trimestral     
 */	
	
 *--------- Latest year 
 /* Education regime (s10q7ba): 7b. Cuál fue el último AÑO aprobado por X?    
 */

  *--------- Latest semester
 /* Education regime (s10q7c): s10q7c 7b. Cuál fue el último SEMESTRE aprobado por X?   
 */

  *--------- Country of residence of the emigrant
 /* Country (s10q8): 8. En cuál país vive actualmente X?   
 */

  *--------- Other country of residence 
 /* Other Country (s10q8_os): 8a. Otro país, especifique
 */

  *--------- City of residence 
 /* City (s10q8b): 8b. Y en cuál ciudad ?
 */
 
   *--------- Emigrated alone or 
 /* City (s10q8c): 8c. X emigró solo/a ?	
					01 Si
					02 No
 */

  *--------- Emigrated with other 
 /*  (s10q8d):8d. Con quién emigró X?				
01 Padre/madre
02 Hermano/a
03 Conyuge/pareja
04 Hijos/hijas
05 Otro pariente
06 No parientes
 */
 


s10q9_os     9. Cuál fue el motivo por el cual X se fue
s10q10      10. Cuál era la ocupación principal de X antes de emigrar?
