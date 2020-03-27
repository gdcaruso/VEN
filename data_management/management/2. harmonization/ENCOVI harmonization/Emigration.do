/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global emigracion informant_emig hogar_emig numero_emig ///
nombre_emig_* edad_emig_* sexo_emig_* relemig_* anoemig_* mesemig_* ///
leveledu_emig_* gradedu_emig_* regedu_emig_* anoedu_emig_* semedu_emig_* paisemig_* ///
opaisemig_* ciuemig_* soloemig_* conemig_* razonemig_* ocupaemig_* ocupnemig_* ///
volvioemig_* volvioanoemig_* volviomesemig_* miememig_*


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
		
	
 /*
 *--------- Relationship of the emigrant with the head of the household
 Relationship (s10q5): 5. Cuál es el parentesco de X con el Jefe(a) del hogar?
        
 */ 
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q5`i' s10q5_`i'
	*-- Label original variable
	label var s10q5_`i' "5. Cuál es el parentesco de X con el Jefe(a) del hogar?"
	*-- Standarization of missing values
	replace s10q5_`i'=. if s10q5_`i'==.a
	*-- Generate variable
	clonevar relemig_`i'  = s10q5_`i'
	replace relemig_`i'  = 1		if  s10q5_`i'==1
	replace relemig_`i'  = 2		if  s10q5_`i'==2
	replace relemig_`i'  = 3		if  s10q5_`i'==3  | s10q5_`i'==4
	replace relemig_`i'  = 4		if  s10q5_`i'==5  
	replace relemig_`i'  = 5		if  s10q5_`i'==6 
	replace relemig_`i'  = 6		if  s10q5_`i'==7
	replace relemig_`i'  = 7		if  s10q5_`i'==8  
	replace relemig_`i'  = 8		if  s10q5_`i'==9
	replace relemig_`i'  = 9		if  s10q5_`i'==10
	replace relemig_`i'  = 10	    if  s10q5_`i'==11
	replace relemig_`i'  = 11	    if  s10q5_`i'==12
	replace relemig_`i'  = 12	    if  s10q5_`i'==13
	*-- Label variable
	label var relemig_`i' "Emigrant's relationship with the head of the household"
	*-- Label values
	label def remig_`i' 1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" ///
						  4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)"  6 "Padre, madre" 7 "Hermano(a)" ///
						  8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" ///
						  12 "Servicio Domestico"
	label value relemig_`i' remig_`i'
	}
	
	
 *--------- Year in which the emigrant left the household
 /* Year (s10q6a): 6a. En qué año se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename original variable 
	rename s10q6a`i' s10q6a_`i'
	*-- Label original variable
	label var s10q6a_`i' "6a. En qué año se fue X ?"
	*-- Standarization of missing values
	replace s10q6a_`i'=. if s10q6a_`i'==.a
	*-- Generate variable
	clonevar anoemig_`i' = s10q6a_`i'
	*-- Label variable
	label var anoemig_`i' "Year of emigration"
	*-- Cross check
	tab anoemig_`i' hogar_emig
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (s10q6b): 6a. En qué mes se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename original variable 
	rename s10q6b`i' s10q6b_`i'
	*-- Label original variable
	label var s10q6b_`i' "6b. En qué mes se fue X ?"
	*-- Standarization of missing values
	replace s10q6b_`i'=. if s10q6b_`i'==.a
	*-- Generate variable
	clonevar mesemig_`i' = s10q6b_`i'
	*-- Label variable
	label var mesemig_`i' "Month of emigration"
	*-- Cross check
	tab mesemig_`i' hogar_emig
	}


  *--------- Latest education level atained by the emigrant 
 /* Education level (s10q7): 7. Cuál fue el último nivel educativo en el que
							 X aprobó un grado, año, semestre o trimestre?  
			01 Ninguno
			02 Preescolar
			03 Régimen anterior: Básica (1-9)
			04 Régimen anterior: Media Diversificado y Profesional (1-3)
			05 Régimen actual: Primaria (1-6)
			06 Régimen actual: Media (1-6)
			07 Técnico (TSU)
			08 Universitario
			09 Postgrado

 */
 	
	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Rename main variable 
	rename s10q7`i' s10q7_`i'
	*-- Label original variable
	label var s10q7_`i' "7. Cuál fue el último nivel educativo en el que X aprobó un grado, año, semestre o trimestre?"
	*-- Standarization of missing values
	replace s10q7_`i'=. if s10q7_`i'==.a
	*-- Generate variable
	clonevar leveledu_emig_`i' = s10q7_`i'
	*-- Label variable
	label var leveledu_emig_`i' "Education level emigrant"
	}
	

 *--------- Latest education grade atained by the emigrant 
 /* Education level (s10q7a): 7a. Cuál fue el último GRADO aprobado por X?     
 */	
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7a`i' s10q7a_`i'
	*-- Label original variable
	label var s10q7a_`i' "7a. Cuál fue el último GRADO aprobado por X?"
	*-- Standarization of missing values
	replace s10q7a_`i'=. if s10q7a_`i'==.a
	*-- Generate variable
	clonevar gradedu_emig_`i' = s10q7a_`i'
	*-- Label variable
	label var gradedu_emig_`i' "Education grade emigrant"
	*-- Cross check
	tab gradedu_emig_`i' hogar_emig
	}
	

 *--------- Education regime 
 /* Education regime (s10q7ba): 7ba. El régimen de estudio era anual, semestral o
							   trimestral?
								01 Anual
								02 Semestral
								03 Trimestral     
 */	
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7ba`i' s10q7ba_`i'
	*-- Label original variable
	label var s10q7ba_`i' "7ba. El régimen de estudio era anual, semestral o trimestral?"
	*-- Standarization of missing values
	replace s10q7ba_`i'=. if s10q7ba_`i'==.a
	*-- Generate variable
	clonevar regedu_emig_`i' = s10q7ba_`i'
	*-- Label variable
	label var regedu_emig_`i' "Education regime: annual, biannual or quarterly"
	*-- Cross check
	tab regedu_emig_`i' hogar_emig
	*-- Label values
	label def regedu_emig_`i' 1 "Annual" 2 "Biannual" 3 "Quarterly"
	label value regedu_emig_`i' regedu_emig_`i'
	}
	
 *--------- Latest year 
 /* Education regime (s10q7b): 7b. Cuál fue el último AÑO aprobado por X?    
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7b`i' s10q7b_`i'
	*-- Label original variable
	label var s10q7b_`i' "7b. Cuál fue el último AÑO aprobado por X?   "
	*-- Standarization of missing values
	replace s10q7b_`i'=. if s10q7b_`i'==.a
	*-- Generate variable
	clonevar anoedu_emig_`i' = s10q7b_`i'
	*-- Label variable
	label var anoedu_emig_`i' "Last year of education attained"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (s10q7c): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q7c`i' s10q7c_`i'
	*-- Label original variable
	label var s10q7c_`i' "7c. Cuál fue el último SEMESTRE aprobado por X?"
	*-- Standarization of missing values
	replace s10q7c_`i'=. if s10q7c_`i'==.a
	*-- Generate variable
	clonevar semedu_emig_`i' = s10q7b_`i'
	*-- Label variable
	label var semedu_emig_`i' "Last semester of education attained"
	*-- Cross check
	tab semedu_emig_`i' hogar_emig
	}

  *--------- Country of residence of the emigrant
 /* Country (s10q8): 8. En cuál país vive actualmente X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8`i' s10q8_`i'
	*-- Label original variable
	label var s10q8_`i' "8. En cuál país vive actualmente X?"
	*-- Standarization of missing values
	replace s10q8_`i'=. if s10q8_`i'==.a
	*-- Generate variable
	clonevar paisemig_`i' = s10q8_`i'
	*-- Label variable
	label var paisemig_`i' "Country in which X lives"
	*-- Cross check
	tab paisemig_`i' hogar_emig
	}

  *--------- Other country of residence 
 /* Other Country (s10q8_os): 8a. Otro país, especifique
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8_os`i' s10q8_os_`i'
	*-- Label original variable
	label var s10q8_os_`i' "8a. Otro país, especifique"
	*-- Standarization of missing values
	replace s10q8_os_`i'="." if s10q8_os_`i'==".a"
	*-- Standarization of other
	replace s10q8_os_`i'="Bolivia" if s10q8_os_`i'=="bolivia"
	replace s10q8_os_`i'="Venezuela" if s10q8_os_`i'=="Venezuela."
	replace s10q8_os_`i'="Arabia" if s10q8_os_`i'=="arabia"
	replace s10q8_os_`i'="Bonaire" if s10q8_os_`i'=="bonaire"
	replace s10q8_os_`i'="Isla San Martin" if s10q8_os_`i'=="isla San Martin"
	*-- Generate variable
	gen opaisemig_`i' = s10q8_os_`i'
	*-- Label variable
	label var opaisemig_`i' "Country in which X lives (Other)"
	*-- Cross check
	tab opaisemig_`i' hogar_emig
	}

  *--------- City of residence 
 /* City (s10q8b): 8b. Y en cuál ciudad ?
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8b`i' s10q8b_`i'
	*-- Label original variable
	label var s10q8b_`i' "8b. Y en cuál ciudad ?"
	*-- Standarization of missing values
	replace s10q8b_`i'="." if s10q8b_`i'==".a"
	replace s10q8b_`i'="." if s10q8b_`i'=="##N/A##"
	*-- Standarization of values
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="No Saben"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="No saben"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="No Saben"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="NO RECUERDA"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabe que ciudad" 
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabe la ciudad"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabes"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabe"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sabr"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no se acordó del nombre dónde esta"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no sé acuerda"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no recuerda el nombre"
	replace s10q8b_`i'="No sabe/no recuerda" if s10q8b_`i'=="no lo recuerda"
	*-- Generate variable
	gen ciuemig_`i' = s10q8b_`i'
	*-- Label variable
	label var ciuemig_`i' "City in which X lives"
	*-- Cross check
	tab ciuemig_`i' hogar_emig
	}

   *--------- Emigrated alone or not
 /* City (s10q8c): 8c. X emigró solo/a ?	
					01 Si
					02 No
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8c`i' s10q8c_`i'
	*-- Label original variable
	label var s10q8c_`i' "8c. X emigró solo/a ?"
	*-- Standarization of missing values
	replace s10q8c_`i'=. if s10q8c_`i'==.a
	*-- Generate variable
	clonevar soloemig_`i' = s10q8c_`i'
	*-- Label variable
	label var soloemig_`i' "Has X emigrated alone"
	*-- Cross check
	tab soloemig_`i' hogar_emig
	*-- Label values
	label def soloemig_`i' 1 "Yes" 2 "No"
	label value soloemig_`i' soloemig_`i'
	}


  *--------- Emigrated with other people 
 /*  (s10q8d):8d. Con quién emigró X?				
				01 Padre/madre
				02 Hermano/a
				03 Conyuge/pareja
				04 Hijos/hijas
				05 Otro pariente
				06 No parientes
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q8d`i' s10q8d_`i'
	*-- Label original variable
	label var s10q8d_`i' "8d. Con quién emigró X?"
	*-- Standarization of missing values
	replace s10q8d_`i'=. if s10q8d_`i'==.a
	*-- Generate variable
	clonevar conemig_`i' = s10q8d_`i'
	*-- Label variable
	label var conemig_`i' "Who emigrated with X"
	*-- Cross check
	tab conemig_`i' hogar_emig
	*-- Label values
	label def conemig_`i' 1 "Father/Mother" 2 "Brother/sister" 3 "Partner" 4 "Son/duther" 5 "Other relative" 6 "Non relative"
	label value conemig_`i' conemig_`i'
	} 

  *--------- Reason for leaving the country
 /*  Reason (s10q9_os):9. Cuál fue el motivo por el cual X se fue				
						01 Fue a buscar/consiguió trabajo
						02 Cambió su lugar de trabajo
						03 Por razones de estudio
						04 Reagrupación familiar
						05 Se casó o unió
						06 Por motivos de salud
						07 Por violencia e inseguridad
						08 Por razones políticas
						09 Otro			
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q9_os`i' s10q9_os_`i'
	*-- Label original variable
	label var s10q9_os_`i' "9. Cuál fue el motivo por el cual X se fue"
	*-- Standarization of missing values
	replace s10q9_os_`i'="." if s10q9_os_`i'==".a"
	*-- Generate variable
	gen razonemig_`i' = s10q9_os_`i'
	*-- Label variable
	label var razonemig_`i' "Why X emigrated"
	*-- Cross check
	tab razonemig_`i' hogar_emig
	} 

  *--------- Occupation: Before leaving the country
 /*  Occupation before (s10q10):10. Cuál era la ocupación principal de X antes de emigrar?
			
					01 Director o gerente
					02 Profesional científico o intelectual
					03 Técnico o profesional de nivel medio
					04 Personal de apoyo administrativo
					05 Trabajador de los servicios o vendedor de comercios y mercados
					06 Agricultor o trabajador calificado agropecuario, forestal o pesquero
					07 Oficial, operario o artesano de artes mecánicas y otros oficios
					08 Operador de instalaciones fijas y máquinas y maquinarias
					09 Ocupaciones elementales
					10 Ocupaciones militares
					11 No se desempeñaba en alguna ocupación			
 */    
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q10`i' s10q10_`i'
	*-- Label original variable
	label var s10q10_`i' "10. Cuál era la ocupación principal de X antes de emigrar?"
	*-- Standarization of missing values
	replace s10q10_`i'=. if s10q10_`i'==.a
	*-- Generate variable
	clonevar ocupaemig_`i' = s10q10_`i'
	*-- Label variable
	label var ocupaemig_`i' "Which was X occupation before leaving"
	*-- Cross check
	tab ocupaemig_`i' hogar_emig
	} 

   *--------- Occupation: in the new country
 /*  Occupation now (s10q11): 11. Qué ocupación tiene X en el país donde vive ?
			
					01 Director o gerente
					02 Profesional científico o intelectual
					03 Técnico o profesional de nivel medio
					04 Personal de apoyo administrativo
					05 Trabajador de los servicios o vendedor de comercios y mercados
					06 Agricultor o trabajador calificado agropecuario, forestal o pesquero
					07 Oficial, operario o artesano de artes mecánicas y otros oficios
					08 Operador de instalaciones fijas y máquinas y maquinarias
					09 Ocupaciones elementales
					10 Ocupaciones militares
					11 No se desempeñaba en alguna ocupación			
 */    
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q11`i' s10q11_`i'
	*-- Label original variable
	label var s10q11_`i' "11. Qué ocupación tiene X en el país donde vive?"
	*-- Standarization of missing values
	replace s10q11_`i'=. if s10q11_`i'==.a
	*-- Generate variable
	gen ocupnemig_`i' = s10q11_`i'
	*-- Label variable
	label var ocupnemig_`i' "Which is X occupation now"
	*-- Cross check
	tab ocupnemig_`i' hogar_emig
	} 

 
    *--------- The emigrant moved back to the country
 /*  Moved back (s10q12): 12. X regresó a residenciarse nuevamente al país?
							01 Si
							02 No
		
 */    
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q12`i' s10q12_`i'
	*-- Label original variable
	label var s10q12_`i' "12. X regresó a residenciarse nuevamente al país?"
	*-- Standarization of missing values
	replace s10q12_`i'=. if s10q12_`i'==.a
	*-- Generate variable
	clonevar volvioemig_`i' = s10q12_`i'
	*-- Label variable
	label var volvioemig_`i' "Does X moved back to the country?"
	*-- Cross check
	tab volvioemig_`i' hogar_emig
	*-- Label values
	label def volvioemig_`i' 1 "Yes" 2 "No"
	label value volvioemig_`i' volvioemig_`i'
	} 


     *--------- Year: The emigrant moved back to the country
 /*  Year (s10q13a): 13a. En qué año regresó X?
		
 */    
	forval i = 1/10{
	*-- Rename main variable 
	rename s10q13a`i' s10q13a_`i'
	*-- Label original variable
	label var s10q13a_`i' "13a. En qué año regresó X?"
	*-- Standarization of missing values
	replace s10q13a_`i'=. if s10q13a_`i'==.a
	*-- Generate variable
	gen volvioanoemig_`i' = s10q13a_`i'
	*-- Label variable
	label var volvioanoemig_`i' "Year: X moved back to the country?"
	*-- Cross check
	tab volvioanoemig_`i' hogar_emig
	} 

      *--------- Month: The emigrant moved back to the country
 /*  Month (s10q13b): 13b. En qué mes regresó X?
		
 */ 
 	forval i = 1/10{
	*-- Rename main variable 
	rename s10q13b`i' s10q13b_`i'
	*-- Label original variable
	label var s10q13b_`i' "13b. En qué mes regresó X?"
	*-- Standarization of missing values
	replace s10q13b_`i'=. if s10q13b_`i'==.a
	*-- Generate variable
	clonevar volviomesemig_`i' = s10q13b_`i'
	*-- Label variable
	label var volviomesemig_`i' "Month: X moved back to the country?"
	*-- Cross check
	tab volviomesemig_`i' hogar_emig
	} 

 
      *--------- Member of the household
 /*  Member (s10q14):14. En el presente X forma parte de este hogar?
						01 Si
						02 No
	
 */   
 	forval i = 1/10{
	*-- Rename main variable 
	rename s10q14`i' s10q14_`i'
	*-- Label original variable
	label var s10q14_`i' "14. En el presente X forma parte de este hogar?"
	*-- Standarization of missing values
	replace s10q14_`i'=. if s10q14_`i'==.a
	*-- Generate variable
	clonevar miememig_`i' = s10q14_`i'
	*-- Label variable
	label var miememig_`i' "Is X a member of the household?"
	*-- Cross check
	tab miememig_`i' hogar_emig
	*-- Label values
	label def miememig_`i' 1 "Yes" 2 "No"
	label value miememig_`i' miememig_`i'
	} 
