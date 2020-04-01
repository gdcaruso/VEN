/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global emigracion hogar_emig numero_emig ///
edad_emig_* sexo_emig_* anoemig_* mesemig_* ///
leveledu_emig_* anoedu_emig_* semedu_emig_* paisemig_* ///
opaisemig_* razonemig_*  razonemigot_* ///


*--------- Emigrant from the household
 /* 2019-Emigrant(): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 2018-Emigrant(emp70)¿Durante los últimos 5 años, desde junio de 2013,
 ¿Alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
		 1 = Si
         2 = No
		99 = NS/NR
 */
	*-- Check values
	tab emp70, mi
	*-- Standarization of missing values
	replace emp70=. if emp70==98
	replace emp70=. if emp70==99
	*-- Generate variable
	clonevar hogar_emig = emp70
	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 2 "No"
	label value hogar_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(emp71): 2. Cuántas personas?
 
 */
	*-- Check values
	tab emp71, mi
	*-- Standarization of missing values
	replace emp71=. if emp71==98 //NA
	replace emp71=. if emp71==99
	*-- Generate variable
	clonevar numero_emig = emp71
	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	*-- Cross check
	tab numero_emig hogar_emig, mi
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household: NA in our database but it was asked
        
 */	

	
 *--------- Age of the emigrant
 /* Age of the emigrant(emp72): 3. Cuántos años cumplidos tiene X?
        
 */
 	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename main variable 
	rename emp72`i' emp72_`i'
	*-- Label original variable
	label var emp72_`i' "3.Cuántos años cumplidos tiene X?"
	*-- Standarization of missing values
	replace emp72_`i'=. if emp72_`i'==.a
	replace emp72_`i'=. if emp72_`i'==99
		*-- Generate variable
		clonevar edad_emig_`i' = emp72_`i'
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		*-- Cross check
		tab edad_emig_`i' hogar_emig
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (emp73): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename main variable 
	rename emp73`i' emp73_`i'
	*-- Label original variable
	label var emp73_`i' "4. El sexo de X es?"
	*-- Standarization of missing values
	replace emp73_`i'=. if emp73_`i'==98
	replace emp73_`i'=. if emp73_`i'==99
		*-- Generate variable
		clonevar sexo_emig_`i' = emp73_`i'
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i' 1 "Male" 2 "Female"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		

	
 *--------- Year in which the emigrant left the household
 /* Year (emp74a): 6a. En qué año se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename original variable 
	rename emp74a`i' emp74a_`i'
	*-- Label original variable
	label var emp74a_`i' "6a. En qué año se fue X ?"
	*-- Standarization of missing values
	replace emp74a_`i'=. if emp74a_`i'==.a
	replace emp74a_`i'=. if emp74a_`i'==98
	replace emp74a_`i'=. if emp74a_`i'==99
	*-- Generate variable
	clonevar anoemig_`i' = emp74a_`i'
	*-- Label variable
	label var anoemig_`i' "Year of emigration"
	*-- Cross check
	tab anoemig_`i' hogar_emig
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (emp74m): 6a. En qué mes se fue X ?
        
 */	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename original variable 
	rename emp74m`i' emp74m_`i'
	*-- Label original variable
	label var emp74m_`i' "6b. En qué mes se fue X ?"
	*-- Standarization of missing values
	replace emp74m_`i'=. if emp74m_`i'==.a
	replace emp74m_`i'=. if emp74m_`i'==98
	replace emp74m_`i'=. if emp74m_`i'==99
	*-- Generate variable
	clonevar mesemig_`i' = emp74m_`i'
	*-- Label variable
	label var mesemig_`i' "Month of emigration"
	*-- Cross check
	tab mesemig_`i' hogar_emig
	}


  *--------- Latest education level atained by the emigrant 
 /* Education level (emp70n): 7. Cuál fue el último nivel educativo en el que
							 X aprobó un grado, año, semestre o trimestre?  
		2019:
			01 Ninguno
			02 Preescolar
			03 Régimen anterior: Básica (1-9)
			04 Régimen anterior: Media Diversificado y Profesional (1-3)
			05 Régimen actual: Primaria (1-6)
			06 Régimen actual: Media (1-6)
			07 Técnico (TSU)
			08 Universitario
			09 Postgrado
			
		2017:	
			1. Ninguno
			2. Preescolar
			3. Primaria
			4. Media
			5. Técnico (TSU)
			6. Universitario
			7. Postgrado
			99. NS/NR

 */
 	
	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5 {
	*-- Rename main variable 
	rename emp75n`i' emp75n_`i'
	*-- Label original variable
	label var emp75n_`i' "7. Cuál fue el último nivel educativo en el que X aprobó un grado, año, semestre o trimestre?"
	*-- Standarization of missing values
	replace emp75n_`i'=. if emp75n_`i'==.a
	replace emp75n_`i'=. if emp75n_`i'==98
	replace emp75n_`i'=. if emp75n_`i'==99
	*-- Generate variable
	gen leveledu_emig_`i' = .
	replace leveledu_emig_`i' = 1 	if emp75n_`i'==1 // Ninguno
	replace leveledu_emig_`i' = 2 	if emp75n_`i'==2 // Preescolar
	//replace leveledu_emig_`i' = 3 	if emp75n_`i'==.
	//replace leveledu_emig_`i' = 4 	if emp75n_`i'==.
	replace leveledu_emig_`i' = 5 	if emp75n_`i'==3 // Primaria (1-6)
	replace leveledu_emig_`i' = 6 	if emp75n_`i'==4 // Media (1-6)
	replace leveledu_emig_`i' = 7 	if emp75n_`i'==5 // Tecnico
	replace leveledu_emig_`i' = 8 	if emp75n_`i'==6 // Universitario
	replace leveledu_emig_`i' = 9 	if emp75n_`i'==7 // Posgrado
	*-- Label variable
	label var leveledu_emig_`i' "Education level emigrant"
	*-- Label values
	label def leveledu_emig_`i' 1 "Ninguno" 2 "Preescolar" 3 "Régimen anterior: Básica (1-9)" ///
			6 "Régimen actual: Media (1-6)" ///
			7 "Técnico (TSU)" 8 "Universitario" 9 "Postgrado"
	label value	leveledu_emig_`i' leveledu_emig_`i'	
	}
	

 *--------- Latest year 
 /* Education regime (emp75a): 7b. Cuál fue el último AÑO aprobado por X?    
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp75a`i' emp75a_`i'
	*-- Label original variable
	label var emp75a_`i' "7b. Cuál fue el último AÑO aprobado por X?   "
	*-- Standarization of missing values
	replace emp75a_`i'=. if emp75a_`i'==.a
	replace emp75a_`i'=. if emp75a_`i'==98
	replace emp75a_`i'=. if emp75a_`i'==99
	*-- Generate variable
	clonevar anoedu_emig_`i' = emp75a_`i'
	*-- Label variable
	label var anoedu_emig_`i' "Last year of education attained"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (amp70s): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp75s`i' emp75s_`i'
	*-- Label original variable
	label var emp75s_`i' "7c. Cuál fue el último SEMESTRE aprobado por X?"
	*-- Standarization of missing values
	replace emp75s_`i'=. if emp75s_`i'==.a
	replace emp75s_`i'=. if emp75s_`i'==98
	replace emp75s_`i'=. if emp75s_`i'==99
	*-- Generate variable
	clonevar semedu_emig_`i' = emp75s_`i'
	*-- Label variable
	label var semedu_emig_`i' "Last semester of education attained"
	*-- Cross check
	tab semedu_emig_`i' hogar_emig
	}

  *--------- Country of residence of the emigrant
 /* Country () 2019: 8. En cuál país vive actualmente X? 
    Country (emp71) 2018: 71. ¿A que pais se fue…?
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp76`i' emp76_`i'
	*-- Label original variable
	label var emp76_`i' "8. En cuál país vive actualmente X?"
	*-- Standarization of missing values
	replace emp76_`i'=. if emp76_`i'==.a
	replace emp76_`i'=. if emp76_`i'==98
	replace emp76_`i'=. if emp76_`i'==99
	*-- Generate variable
	clonevar paisemig_`i' = emp76_`i'
	*-- Label variable
	label var paisemig_`i' "Country in which X lives"
	*-- Cross check
	tab paisemig_`i' hogar_emig
	}

  *--------- Other country of residence 
 /* Other Country (emp71_ot): 8a. Otro país, especifique
 */
 	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp76ot`i' emp76_ot_`i'
	*-- Label original variable
	label var emp76_ot_`i' "8a. Otro país, especifique"
	*-- Standarization of missing values
	replace emp76_ot_`i'="." if emp76_ot_`i'=="98"
	replace emp76_ot_`i'="." if emp76_ot_`i'=="99"
	*-- Generate variable
	gen opaisemig_`i' = emp76_ot_`i'
	*-- Label variable
	label var opaisemig_`i' "Country in which X lives (Other)"
	*-- Cross check
	tab opaisemig_`i' hogar_emig
	}

  *--------- Reason for leaving the country
 /*  Reason (emp77):9. Cuál fue el motivo por el cual X se fue				
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
  	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp77`i' emp77_`i'
	*-- Label original variable
	label var emp77_`i' "9. Cuál fue el motivo por el cual X se fue"
	*-- Standarization of missing values
	replace emp77_`i'=. if emp77_`i'==98
	replace emp77_`i'=. if emp77_`i'==99
	*-- Generate variable
	clonevar razonemig_`i' = emp77_`i'
	*-- Label variable
	label var razonemig_`i' "Why X emigrated"
	*-- Cross check
	tab razonemig_`i' hogar_emig
	} 

 
   *--------- Other Reasons for leaving the country
 /*  Reason (emp77ot):9a. Cuál fue el motivo por el cual X se fue (Otros)*/
  	*-- Given that the maximum number of emigrantes per household is 5
	*-- We will have 5 variables with names
	forval i = 1/5{
	*-- Rename main variable 
	rename emp77ot`i' emp77ot_`i'
	*-- Label original variable
	label var emp77ot_`i' "9a. Cuál fue el motivo por el cual X se fue (Otros)"
	*-- Standarization of missing values
	replace emp77ot_`i'="." if emp77ot_`i'=="98"
	replace emp77ot_`i'="." if emp77ot_`i'=="99"
	*-- Generate variable
	gen razonemigot_`i' = emp77ot_`i'
	*-- Label variable
	label var razonemigot_`i' "Why X emigrated (Other reasons)"
	*-- Cross check
	tab razonemigot_`i' hogar_emig
	} 

