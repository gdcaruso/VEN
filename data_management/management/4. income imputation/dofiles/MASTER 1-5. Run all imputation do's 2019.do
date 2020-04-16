* Run 1-5 imputation do's 2019
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   1
			
		if $juli {
				global pathrun "C:\Users\wb563583\Github\VEN\data_management\management\4. income imputation\dofiles"
		}
	    if $lauta {

		}
		if $trini   {
		}
		
		if $male   {
		        	global pathrun "C:\Users\wb550905\Github\VEN\data_management\management\4. income imputation\dofiles"
		}

//*** Running all imputations ***//
run "$pathrun\1. Imputation 2019 - Identification missing values & possible variables for regression.do"
run "$pathrun\2. Imputation 2019 - Monetary labor income.do"
run "$pathrun\3. Imputation 2019 - Pensions.do"
run "$pathrun\4. Imputation 2019 - Non Labor Income.do"
run "$pathrun\5. Imputation 2019 - Labor benefits (non monetary income).do"


//*** Merging ENCOVI 2019 database with imputed incomes ***//

use "$path\ENCOVI_forimputation_2019.dta", clear

	* Mergeamos ila_m_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$path\VEN_ila_m_imp1.dta" // da lo mismo usando id com

	* Mergeamos jubpen_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$path\VEN_jubpen_imp1.dta"

	* Mergeamos inlanojub_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$path\VEN_inlanojub_imp1.dta"

	* Mergeamos bene_imp1
	capture drop _merge
	merge 1:1 interview__key interview__id quest com using "$path\VEN_bene_imp1.dta"


//*** Replacing imputed labor income variables ***//

	drop ingresoslab_mon
	rename ila_m_imp1 ingresoslab_mon
	drop ingresoslab_bene 
	rename bene_imp1 ingresoslab_bene
	drop ipatrp_m ipatrp_nm iasalp_m iasalp_nm ictapp_m ictapp_nm iolp_m iolp_nm

	****** 9.1.PRIMARY LABOR INCOME ******
	
	
	/*
	ipatrp_m: ingreso monetario laboral de la actividad principal si es patrón
	iasalp_m: ingreso monetario laboral de la actividad principal si es asalariado
	ictapp_m: ingreso monetario laboral de la actividad principal si es cuenta propia */


	*****  i)  PATRÓN
		* Monetario	
		* Ingreso monetario laboral de la actividad principal si es patrón
		gen     ipatrp_m = ingresoslab_mon if relab==1  

		* No monetario
		gen     ipatrp_nm = ingresoslab_bene if relab==1 	

	****  ii)  ASALARIADOS
		* Monetario	
		* Ingreso monetario laboral de la actividad principal si es asalariado
		gen     iasalp_m = ingresoslab_mon if relab==2

		* No monetario
		gen     iasalp_nm = ingresoslab_bene if relab==2


	***** iii)  CUENTA PROPIA
		* Monetario	
		* Ingreso monetario laboral de la actividad principal si es cuenta propia
		gen     ictapp_m = ingresoslab_mon if relab==3

		* No monetario
		gen     ictapp_nm = ingresoslab_bene if relab==3
		
	***** iv) Otros - trabajador sin salario
		gen iolp_m = ingresoslab_mon if relab==4
		
		gen iolp_nm = ingresoslab_bene if relab==4

		
	***** iv) AGREGADO POR NOSOTROS: relab=. pero ganan dinero
			// (como se les pregunta el dinero que ganan con base anual, 
			//por lo que puede haber gente no ocupada -medido en la última semana- que gana ingreso laboral)

		gen irelabmisspr_m = ingresoslab_mon if inlist(relab,.,5) & ingresoslab_mon!=.
		
		gen irelabmisspr_nm = ingresoslab_bene if inlist(relab,.,5) & ingresoslab_mon!=.

		





