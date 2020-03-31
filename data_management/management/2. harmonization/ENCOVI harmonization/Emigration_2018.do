/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global emigracion informant_emig hogar_emig numero_emig ///
nombre_emig_* edad_emig_* sexo_emig_* relemig_* anoemig_* mesemig_* ///
leveledu_emig_* gradedu_emig_* regedu_emig_* anoedu_emig_* semedu_emig_* paisemig_* ///
opaisemig_* ciuemig_* soloemig_* conemig_* razonemig_* ocupaemig_* ocupnemig_* ///
volvioemig_* volvioanoemig_* volviomesemig_* miememig_*

*--------- Emigrant from the household
 /* 2019-Emigrant(): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 2018-Emigrant(emp62)¿Durante los últimos 5 años, desde junio de 2013,
 ¿Alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
		 1 = Si
         2 = No
		99 = NS/NR
 */
	*-- Check values
	tab emp62, mi
	*-- Standarization of missing values
	replace emp62=. if emp62==99
	*-- Generate variable
	clonevar hogar_emig = emp62
	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 2 "No"
	label value hogar_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(emp63): 2. Cuántas personas?
 
 */
	*-- Check values
	tab emp63, mi
	*-- Standarization of missing values
	replace emp63=. if emp63==98 //NA
	replace emp63=. if emp63==99
	*-- Generate variable
	clonevar numero_emig = emp63
	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	*-- Cross check
	tab numero_emig hogar_emig, mi
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household: NA in our database but it was asked
        
 */	

	
 *--------- Age of the emigrant
 /* Age of the emigrant(emp67): 3. Cuántos años cumplidos tiene X?
        
 */
 	
	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8 {
	*-- Rename main variable 
	rename emp67e`i' emp67_`i'
	*-- Label original variable
	label var emp67_`i' "3.Cuántos años cumplidos tiene X?"
	*-- Standarization of missing values
	replace emp67_`i'=. if emp67_`i'==.a
	replace emp67_`i'=. if emp67_`i'==99
		*-- Generate variable
		clonevar edad_emig_`i' = emp67_`i'
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		*-- Cross check
		tab edad_emig_`i' hogar_emig
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (emp78): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8 {
	*-- Rename main variable 
	rename emp78x`i' emp78_`i'
	*-- Label original variable
	label var emp78_`i' "4. El sexo de X es?"
	*-- Standarization of missing values
	replace emp78_`i'=. if emp78_`i'==.a
		*-- Generate variable
		clonevar sexo_emig_`i' = emp78_`i'
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i' 1 "Male" 2 "Female"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		
	
 /*
 *--------- Relationship of the emigrant with the head of the household
 Relationship (emp68): 5. Cuál es el parentesco de X con el Jefe(a) del hogar?
        
 */ 
	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8 {
	*-- Rename main variable 
	rename emp68`i' emp68_`i'
	*-- Label original variable
	label var emp68_`i' "5. Cuál es el parentesco de X con el Jefe(a) del hogar?"
	*-- Standarization of missing values
	replace emp68_`i'=. if emp68_`i'==.a
	replace emp68_`i'=. if emp68_`i'==98
	replace emp68_`i'=. if emp68_`i'==99
	*-- Generate variable
	clonevar relemig_`i'  = emp68_`i'
	replace relemig_`i'  = 1		if  emp68_`i'==1
	replace relemig_`i'  = 2		if  emp68_`i'==2
	replace relemig_`i'  = 3		if  emp68_`i'==3  | emp68_`i'==4
	replace relemig_`i'  = 4		if  emp68_`i'==5  
	replace relemig_`i'  = 5		if  emp68_`i'==6 
	replace relemig_`i'  = 6		if  emp68_`i'==7
	replace relemig_`i'  = 7		if  emp68_`i'==8  
	replace relemig_`i'  = 8		if  emp68_`i'==9
	replace relemig_`i'  = 9		if  emp68_`i'==10
	replace relemig_`i'  = 10	    if  emp68_`i'==11
	replace relemig_`i'  = 11	    if  emp68_`i'==12
	replace relemig_`i'  = 12	    if  emp68_`i'==13
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
 /* Year (emp69a): 6a. En qué año se fue X ?
        
 */	
	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8 {
	*-- Rename original variable 
	rename emp69a`i' emp69a_`i'
	*-- Label original variable
	label var emp69a_`i' "6a. En qué año se fue X ?"
	*-- Standarization of missing values
	replace emp69a_`i'=. if emp69a_`i'==.a
	replace emp69a_`i'=. if emp69a_`i'==98
	replace emp69a_`i'=. if emp69a_`i'==99
	*-- Generate variable
	clonevar anoemig_`i' = emp69a_`i'
	*-- Label variable
	label var anoemig_`i' "Year of emigration"
	*-- Cross check
	tab anoemig_`i' hogar_emig
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (emp69m): 6a. En qué mes se fue X ?
        
 */	
	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8 {
	*-- Rename original variable 
	rename emp69m`i' emp69m_`i'
	*-- Label original variable
	label var emp69m_`i' "6b. En qué mes se fue X ?"
	*-- Standarization of missing values
	replace emp69m_`i'=. if emp69m_`i'==.a
	replace emp69m_`i'=. if emp69m_`i'==98
	replace emp69m_`i'=. if emp69m_`i'==99
	*-- Generate variable
	clonevar mesemig_`i' = emp69m_`i'
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
			
		2018:	
			1. Ninguno
			2. Preescolar
			3. Primaria
			4. Media
			5. Técnico (TSU)
			6. Universitario
			7. Postgrado
			99. NS/NR

 */
 	
	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8 {
	*-- Rename main variable 
	rename emp70n`i' emp70n_`i'
	*-- Label original variable
	label var emp70n_`i' "7. Cuál fue el último nivel educativo en el que X aprobó un grado, año, semestre o trimestre?"
	*-- Standarization of missing values
	replace emp70n_`i'=. if emp70n_`i'==.a
	replace emp70n_`i'=. if emp70n_`i'==98
	replace emp70n_`i'=. if emp70n_`i'==99
	*-- Generate variable
	gen leveledu_emig_`i' = .
	replace leveledu_emig_`i' = 1 	if emp70n_`i'==1 // Ninguno
	replace leveledu_emig_`i' = 2 	if emp70n_`i'==2 // Preescolar
	//replace leveledu_emig_`i' = 3 	if emp70n_`i'==.
	//replace leveledu_emig_`i' = 4 	if emp70n_`i'==.
	replace leveledu_emig_`i' = 5 	if emp70n_`i'==3 // Primaria (1-6)
	replace leveledu_emig_`i' = 6 	if emp70n_`i'==4 // Media (1-6)
	replace leveledu_emig_`i' = 7 	if emp70n_`i'==5 // Tecnico
	replace leveledu_emig_`i' = 8 	if emp70n_`i'==6 // Universitario
	replace leveledu_emig_`i' = 9 	if emp70n_`i'==7 // Posgrado
	*-- Label variable
	label var leveledu_emig_`i' "Education level emigrant"
	*-- Label values
	label def leveledu_emig_`i' 1 "Ninguno" 2 "Preescolar" 3 "Régimen anterior: Básica (1-9)" ///
			6 "Régimen actual: Media (1-6)" ///
			7 "Técnico (TSU)" 8 "Universitario" 9 "Postgrado"
	label value	leveledu_emig_`i' leveledu_emig_`i'	
	}
	

 *--------- Latest education grade atained by the emigrant: NA
 /* Education level (): 7a. Cuál fue el último GRADO aprobado por X?     
	
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
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
 */	

 *--------- Education regime: NA
 /* Education regime (): 7ba. El régimen de estudio era anual, semestral o
							   trimestral?
								01 Anual
								02 Semestral
								03 Trimestral     
	
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
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
	 */
 *--------- Latest year 
 /* Education regime (emp70a): 7b. Cuál fue el último AÑO aprobado por X?    
 */
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp70a`i' emp70a_`i'
	*-- Label original variable
	label var emp70a_`i' "7b. Cuál fue el último AÑO aprobado por X?   "
	*-- Standarization of missing values
	replace emp70a_`i'=. if emp70a_`i'==.a
	replace emp70a_`i'=. if emp70a_`i'==98
	replace emp70a_`i'=. if emp70a_`i'==99
	*-- Generate variable
	clonevar anoedu_emig_`i' = emp70a_`i'
	*-- Label variable
	label var anoedu_emig_`i' "Last year of education attained"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (amp70s): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp70s`i' emp70s_`i'
	*-- Label original variable
	label var emp70s_`i' "7c. Cuál fue el último SEMESTRE aprobado por X?"
	*-- Standarization of missing values
	replace emp70s_`i'=. if emp70s_`i'==.a
	replace emp70s_`i'=. if emp70s_`i'==98
	replace emp70s_`i'=. if emp70s_`i'==99
	*-- Generate variable
	clonevar semedu_emig_`i' = emp70s_`i'
	*-- Label variable
	label var semedu_emig_`i' "Last semester of education attained"
	*-- Cross check
	tab semedu_emig_`i' hogar_emig
	}

  *--------- Country of residence of the emigrant
 /* Country () 2019: 8. En cuál país vive actualmente X? 
    Country (emp71) 2018: 71. ¿A que pais se fue…?
 */
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp71`i' emp71_`i'
	*-- Label original variable
	label var emp71_`i' "8. En cuál país vive actualmente X?"
	*-- Standarization of missing values
	replace emp71_`i'=. if emp71_`i'==.a
	replace emp71_`i'=. if emp71_`i'==98
	replace emp71_`i'=. if emp71_`i'==99
	*-- Generate variable
	clonevar paisemig_`i' = emp71_`i'
	*-- Label variable
	label var paisemig_`i' "Country in which X lives"
	*-- Cross check
	tab paisemig_`i' hogar_emig
	}

  *--------- Other country of residence 
 /* Other Country (emp71_ot): 8a. Otro país, especifique
 */
 	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp71ot`i' emp71ot_`i'
	*-- Label original variable
	label var emp71ot_`i' "8a. Otro país, especifique"
	*-- Standarization of missing values
	replace emp71ot_`i'="." if emp71ot_`i'=="NO APLICA"
	replace emp71ot_`i'="." if emp71ot_`i'=="SIN RESPUESTA"
	*-- Generate variable
	gen opaisemig_`i' = emp71ot_`i'
	*-- Label variable
	label var opaisemig_`i' "Country in which X lives (Other)"
	*-- Cross check
	tab opaisemig_`i' hogar_emig
	}

  *--------- City of residence 
 /* City (s10q8b): 8b. Y en cuál ciudad ?

  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
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
 */
   *--------- Emigrated alone or not: NA
 /* City (s10q8c): 8c. X emigró solo/a ?	
					01 Si
					02 No

  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
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
 */

  *--------- Emigrated with other people 
 /*  (s10q8d):8d. Con quién emigró X?				
				01 Padre/madre
				02 Hermano/a
				03 Conyuge/pareja
				04 Hijos/hijas
				05 Otro pariente
				06 No parientes

  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
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
 */
  *--------- Reason for leaving the country
 /*  Reason (emp72):9. Cuál fue el motivo por el cual X se fue				
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
  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp72`i' emp72_`i'
	*-- Label original variable
	label var emp72_`i' "9. Cuál fue el motivo por el cual X se fue"
	*-- Standarization of missing values
	replace emp72_`i'=. if emp72_`i'==99
	*-- Generate variable
	gen razonemig_`i' = emp72_`i'
	*-- Label variable
	label var razonemig_`i' "Why X emigrated"
	*-- Cross check
	tab razonemig_`i' hogar_emig
	} 

  *--------- Other Reasons for leaving the country
 /*  Reason (emp72):9. Cuál fue el motivo por el cual X se fue (Otros)*/
  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp72ot`i' emp72ot_`i'
	*-- Label original variable
	label var emp72ot_`i' "9a. Cuál fue el motivo por el cual X se fue (Otros)"
	*-- Standarization of missing values
	replace emp72ot_`i'="." if emp72ot_`i'=="98"
	replace emp72ot_`i'="." if emp72ot_`i'=="99"
	*-- Generate variable
	gen razonemigot_`i' = emp72ot_`i'
	*-- Label variable
	label var razonemigot_`i' "Why X emigrated (Other reasons)"
	*-- Cross check
	tab razonemigot_`i' hogar_emig
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
    
  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
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
 */
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
   
  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
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

  */ 
    *--------- The emigrant moved back to the country
 /*  Moved back (emp64): 12. X regresó a residenciarse nuevamente al país?
							01 Si
							02 No
		
 */    
  	*-- Given that the maximum number of emigrants per household is 8 
	*-- We will have 8 variables with names
	forval i = 1/8{
	*-- Rename main variable 
	rename emp64`i' emp64_`i'
	*-- Label original variable
	label var emp64_`i' "12. X regresó a residenciarse nuevamente al país?"
	*-- Standarization of missing values
	replace emp64_`i'=. if emp64_`i'==98
	replace emp64_`i'=. if emp64_`i'==99
	*-- Generate variable
	clonevar volvioemig_`i' = emp64_`i'
	*-- Label variable
	label var volvioemig_`i' "Does X moved back to the country?"
	*-- Cross check
	tab volvioemig_`i' hogar_emig
	*-- Label values
	label def volvioemig_`i' 1 "Yes" 2 "No"
	label value volvioemig_`i' volvioemig_`i'
	} 


     *--------- Year: The emigrant moved back to the country
 /*  Year (emp65a): 13a. En qué año regresó X?
		
 */    
	forval i = 1/8{
	*-- Rename main variable 
	rename emp65a`i' emp65a_`i'
	*-- Label original variable
	label var emp65a_`i' "13a. En qué año regresó X?"
	*-- Standarization of missing values
	replace emp65a_`i'=. if emp65a_`i'==98
	replace emp65a_`i'=. if emp65a_`i'==99
	*-- Generate variable
	gen volvioanoemig_`i' = emp65a_`i'
	*-- Label variable
	label var volvioanoemig_`i' "Year: X moved back to the country?"
	*-- Cross check
	tab volvioanoemig_`i' hogar_emig
	} 

      *--------- Month: The emigrant moved back to the country
 /*  Month (emp65m): 13b. En qué mes regresó X?
		
 */ 
 	forval i = 1/8{
	*-- Rename main variable 
	rename emp65m`i' emp65m_`i'
	*-- Label original variable
	label var emp65m_`i' "13b. En qué mes regresó X?"
	*-- Standarization of missing values
	replace emp65m_`i'=. if emp65m_`i'==98
	replace emp65m_`i'=. if emp65m_`i'==99
	*-- Generate variable
	clonevar volviomesemig_`i' = emp65m_`i'
	*-- Label variable
	label var volviomesemig_`i' "Month: X moved back to the country?"
	*-- Cross check
	tab volviomesemig_`i' hogar_emig
	} 

 
      *--------- Member of the household
 /*  Member (emp66):14. En el presente X forma parte de este hogar?
						01 Si
						02 No
	
 */   
 	forval i = 1/8{
	*-- Rename main variable 
	rename emp66`i' emp66_`i'
	*-- Label original variable
	label var emp66_`i' "14. En el presente X forma parte de este hogar?"
	*-- Standarization of missing values
	replace emp66_`i'=. if emp66_`i'==98
	replace emp66_`i'=. if emp66_`i'==99
	*-- Generate variable
	clonevar miememig_`i' = emp66_`i'
	*-- Label variable
	label var miememig_`i' "Is X a member of the household?"
	*-- Cross check
	tab miememig_`i' hogar_emig
	*-- Label values
	label def miememig_`i' 1 "Yes" 2 "No"
	label value miememig_`i' miememig_`i'
	} 

	
      *--------- Member of the household (Identification)
 /*  Member (emp66l): Numero de linea en la encuesta
						01 Si
						02 No
	
 */   
 	forval i = 1/8{
	*-- Rename main variable 
	rename emp66l`i' emp66l_`i'
	*-- Label original variable
	label var emp66l_`i' "Numero de linea en la encuesta"
	*-- Standarization of missing values
	replace emp66l_`i'=. if emp66l_`i'==98
	replace emp66l_`i'=. if emp66l_`i'==99
	*-- Generate variable
	clonevar numeroemig_`i' = emp66l_`i'
	*-- Label variable
	label var numeroemig_`i' "Is X a member of the household?"
	*-- Cross check
	tab numeroemig_`i' hogar_emig
	*-- Label values
	label def numeroemig_`i' 1 "Yes" 2 "No"
	label value numeroemig_`i' numeroemig_`i'
	} 
	