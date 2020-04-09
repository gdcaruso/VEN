/**********************************************************************************************************
************************************ VENEZUELA ENCOVI SURVEY *********************************************
**********************************     MAIN SURVEY SUPERVISION      **************************************
*********	Written:	  Daniel Pereira - January 29, 2020 - (dpereiraarellano@worldbank.org)  **********
*********	Modified:	  Daniel Pereira - January 29, 2020 - (dpereiraarellano@worldbank.org)  **********
******  Dev't Note: This Syntax File is Intended to Generate Report Quality of Ongoing Survey ************
**********************************************************************************************************

NOTE: The files used in this program are downloaded from the survey's server:
	https://maincovi.mysurvey.solutions/DataExport/New

For this excersise I will only use the first version of the questionnaire. 
I will later adapt the code so as to include what is done in the second version. 

Download data from "ENCOVI 2019 MAIN SURVEY FINAL" quesitonnaire, version 3 in 
stata format.	
	
********************************************************************************
********************************************************************************

				***** Globas I Use Throughout the Program *****

********************************************************************************
********************************************************************************/


//	Set Up global Directories
	
	if c(username)=="danielpereiraarellano"{ // type "di c(username)" in Stata and copy the response from result window here as yourusername
		global path_old		"/Users/danielpereiraarellano/Dropbox/WB/2 - STC - Poverty Economist/2 - Work/9 - ENCOVI/1 - App/Reporte Avance/Encuesta/Original Files/ENCOVI_MainSurvey_Final_3_STATA_All/" // put here the folder path
		global path_new		"/Users/danielpereiraarellano/Dropbox/WB/2 - STC - Poverty Economist/2 - Work/9 - ENCOVI/1 - App/Reporte Avance/Encuesta/Original Files/ENCOVI_3_STATA_All/" // put here the folder path
		global path_pix		"/Users/danielpereiraarellano/Dropbox/WB/2 - STC - Poverty Economist/2 - Work/9 - ENCOVI/1 - App/Reporte Avance/Encuesta/Original Files/ENCOVI_pixel_Qx_9_STATA_All/" // put here the folder path
		global avance		"/Users/danielpereiraarellano/Dropbox/WB/2 - STC - Poverty Economist/2 - Work/9 - ENCOVI/1 - App/Reporte Avance/Encuesta/Avance Semanal/"
		}
		
	if c(username)=="WBXXXXX"{	// type "di c(username)" in Stata and copy the response from result window here as yourusername
		global sample_path "C:\Users\wbXXXX\" // put here the folder path
		}
		
//	Clear and Set up the System
	clear all
	set more off
		
//	Dates for wich I want the report
	global inicio=date("2019/11/20","YMD")
	global fin=date("`c(current_date)'","DMY")
	dis "${inicio} y ${fin}"	

********************************************************************************
********************************************************************************

						***** Interviewers' File *****

********************************************************************************
********************************************************************************

// 	Using the file that contains the interviewrs' information
// 	I will created a dta to link for later divide report at the interviewer and 
// 	superivors level
	
	cd "${path_old}"
	use interview__actions.dta, clear
	gen quest="Tradicioinal - Viejo"
	
	append using "${path_new}interview__actions.dta"
	replace quest="Tradicional - Nuevo" if quest==""
	
	append using "${path_pix}interview__actions.dta"
	replace quest="Remoto" if quest==""

//	Creating supevisors and interviewer
	preserve
	bys quest interview__key interview__id (date): gen x=1 if action==3
	drop if x==.
	bys quest interview__key interview__id (date time): keep if _n==_N
	keep interview* origina responsible__name quest
	rename ori interviewer
	rename respo coordinator
	tempfile cr_int
	save `cr_int'
	restore
	
//	Keeping only "First Answer Set" interviews	
	bys quest interview__key interview__id (date): gen x=1 if action==2
	drop if x==.

//	Keeping 1 line with interviewr and supervisor	
	bys quest interview__key interview__id (date time): keep if _n==_N


// 	Cleaning and Keeping useful variables	
	keep interview* date time quest
	merge 1:1 quest interview__key interview__id using `cr_int', nogen
	
// Creating date variables
	replace date = subinstr(date, "-", "/",.)
	gen edate=date(date,"YMD")
	format edate %td


//	Export as DTA File all completed surveys by date
	local today : display %tdCYND date(c(current_date), "DMY")
	display "`today'"
	save "${avance}firstanswerset`today'.dta", replace
	
********************************************************************************
********************************************************************************

						***** HH Level Information *****

********************************************************************************
********************************************************************************
	
	
// 	Using the file that contains HH information
	
	cd "${path_old}"
	use ENCOVI_MainSurvey_Final.dta, clear
	gen quest="Tradicioinal - Viejo"
	
	append using "${path_new}ENCOVI.dta"
	replace quest="Tradicional - Nuevo" if quest==""
	
	append using "${path_pix}ENCOVI_pixel_Qx.dta"
	replace quest="Remoto" if quest==""


//	Adding the date of the first data imputed
	local today : display %tdCYND date(c(current_date), "DMY")
	display "`today'"

	merge m:1 interview__key interview__id quest using "${avance}firstanswerset`today'.dta", keep( using matched)
	

// Gen weeks	
	gen weeknumb=.
	gen endweek=.
	local x=${inicio}
	local w=${fin}
	local y=`x'+6
	local z=1
	while `y'<=`w' {
		replace endweek=`y' if edate>=`x' & edate<=`y'
		replace weeknumb=`z' if edate>=`x' & edate<=`y'
		local x=`x'+7
		local y=`y'+7
		local ++z
		dis "`z'"
	}
	
	replace weeknumb=`z' if weeknumb==.
	replace endweek=${fin} if endweek==.
	format endweek %td	

// Gen consumption variables
	egen c_pan=rowtotal(s12aq1_1__1 s12aq1_1__2 s12aq1_1__3 s12aq1_1__4 s12aq1_1__5 s12aq1_1__6 s12aq1_1__7 s12aq1_1__8 s12aq1_1__9 )
	egen c_carne=rowtotal(s12aq1_2__10 s12aq1_2__11 s12aq1_2__12 s12aq1_2__13 s12aq1_2__14 s12aq1_2__15 s12aq1_2__16 s12aq1_2__17 s12aq1_2__18 )
	egen c_pescados=rowtotal(s12aq1_3__19 s12aq1_3__20 s12aq1_3__21 s12aq1_3__22 s12aq1_3__23 s12aq1_3__24 )
	egen c_lacteos=rowtotal(s12aq1_4__25 s12aq1_4__26 s12aq1_4__27 s12aq1_4__28 s12aq1_4__29 s12aq1_4__30 s12aq1_4__31 s12aq1_4__32 )
	egen c_aceites=rowtotal(s12aq1_5__33 s12aq1_5__34 s12aq1_5__35 s12aq1_5__36 )
	egen c_frutas=rowtotal(s12aq1_6__37 s12aq1_6__38 s12aq1_6__39 s12aq1_6__40 s12aq1_6__41 s12aq1_6__42 )
	egen c_vegetales=rowtotal(s12aq1_7__43 s12aq1_7__44 s12aq1_7__45 s12aq1_7__46 s12aq1_7__47 s12aq1_7__48 s12aq1_7__49 s12aq1_7__50 s12aq1_7__51 s12aq1_7__52 )
	egen c_leguminosas=rowtotal(s12aq1_8__53 s12aq1_8__54 s12aq1_8__55 s12aq1_8__56 s12aq1_8__57 )
	egen c_frutos_secos=rowtotal(s12aq1_9__58 s12aq1_9__59 s12aq1_9__60 s12aq1_9__61 )
	egen c_tuberculos=rowtotal(s12aq1_10__62 s12aq1_10__63 s12aq1_10__64 s12aq1_10__65 s12aq1_10__66 s12aq1_10__67 )
	egen c_azucar=rowtotal(s12aq1_11__68 s12aq1_11__69 s12aq1_11__70 s12aq1_11__71 s12aq1_11__72 s12aq1_11__73 )
	egen c_care=rowtotal(s12aq1_12__74 s12aq1_12__75 s12aq1_12__76 s12aq1_12__77 )
	egen c_condimentos=rowtotal(s12aq1_13__78 s12aq1_13__79 s12aq1_13__80 s12aq1_13__81 s12aq1_13__82 s12aq1_13__83 )
	egen c_bebidas=rowtotal(s12aq1_14__84 s12aq1_14__85 s12aq1_14__86 s12aq1_14__87 s12aq1_14__88 s12aq1_14__89 )
	egen c_tabaco=rowtotal(s12aq1_15__90 s12aq1_15__91 s12aq1_15__92)
	
	*** Check variable yes_items	
	egen yes_check=rowtotal(c_*)
	
	
	egen c_aseo=rowtotal(aseo_personal__101 aseo_personal__102 aseo_personal__103 aseo_personal__104 aseo_personal__105 aseo_personal__106 aseo_personal__107 aseo_personal__108 aseo_personal__109 aseo_personal__110 aseo_personal__111 aseo_personal__112 aseo_personal__113 )
	egen c_limpieza=rowtotal(articulos_lipieza__114 articulos_lipieza__115 articulos_lipieza__116 articulos_lipieza__117 articulos_lipieza__118 articulos_lipieza__119 articulos_lipieza__120 articulos_lipieza__121 articulos_lipieza__122 )
	egen c_ropa=rowtotal(ropa__123 ropa__124 ropa__125 ropa__126 ropa__127 ropa__128 ropa__129 ropa__130 ropa__131 )
	egen c_electrodomesticos=rowtotal(electrodomesticos__132 electrodomesticos__133 electrodomesticos__134 electrodomesticos__135 electrodomesticos__136 electrodomesticos__137 electrodomesticos__138 electrodomesticos__139 electrodomesticos__140 )
	egen c_electronicos=rowtotal(electronicos__141 electronicos__142 electronicos__143 electronicos__144 electronicos__145 electronicos__146 )
	egen c_vehiculos=rowtotal(vehiculos__147 vehiculos__148 vehiculos__149 vehiculos__150 )
	egen c_fuera_hogar=rowtotal(s12cq1__1 s12cq1__2 s12cq1__3 s12cq1__4 s12cq1__5 )
	egen c_recreacion=rowtotal(s12dq1__1 s12dq1__2 s12dq1__3 s12dq1__4 s12dq1__5 s12dq1__6 s12dq1__7 s12dq1__8 s12dq1__9 s12dq1__10 s12dq1__11 s12dq1__12 s12dq1__13 s12dq1__14 s12dq1__15 s12dq1__16 s12dq1__17 s12dq1__18 s12dq1__19 s12dq1__20 s12dq1__21 s12dq1__22)
	
//	Gen colabora variables

	*** Colabora sin inhabitadas

	gen colabora1=(colabora==1)
	
	gen colabora2=colabora_
	replace colabora2=. if razon==1
	replace colabora2=0 if colabora2==2
	
	
//	keeping usufull HH variables
	keep 	interview__key interview__id entidad sample_type colabora1 colabora2 razon_rechazo Tot_members ///
			s5q1 s5q3 s5q4a s5q6__1 s5q6__2 s5q6__3 s5q6__4 s5q6__5 s5q6__6 s5q6__7 s5q6__8 s5q6__9 s5q6__10 s5q6__11 s5q6__12 ///
			s12aq10 c_pan c_carne c_pescados c_lacteos c_aceites c_frutas c_vegetales c_leguminosas c_frutos_secos c_tuberculos c_azucar c_care c_condimentos c_bebidas c_tabaco yes* ///
			c_aseo c_limpieza c_ropa c_electrodomesticos c_electronicos c_vehiculos c_fuera_hogar c_recreacion ///
			interviewer coordinator weeknumb endweek edate quest

//	Renaming Variables and cleaning variables

	*** Electrodomesticos
	
	rename s5q6__1 nevera
	rename s5q6__2 lavadora
	rename s5q6__3 secadora
	rename s5q6__4 computadora
	rename s5q6__5 internet
	rename s5q6__6 televisor
	rename s5q6__7 radio
	rename s5q6__8 calentador
	rename s5q6__9 aire_acond
	rename s5q6__10 cable
	rename s5q6__11 microondas
	rename s5q6__12	telefono


	*** Dormitorios y baños
	rename s5q1 dormitorio
	rename s5q3 baños
	
	*** Carros
	rename s5q4a carros
	replace carros=0 if carros==.
	
	*** Clap
	gen clap=(s12aq10==1)
	drop s12aq10
	

//	Order and saving	
	order interview__key interview__id coordinator interviewer entidad quest sample_type edate weeknumb endweek colabora*
	save "${avance}HHdiagnostics`today'.dta", replace
	export excel using "${avance}avance_HH_input.xlsx", sheet("data") sheetmodify cell(a1) firstrow(variables)

	
	
	
/********************************************************************************
********************************************************************************

						***** Individual Level Information *****

********************************************************************************
********************************************************************************
	
	
// 	Using the file that contains the HH members' information
	
	cd "${path_old}"
	use Miembro.dta, clear
	gen quest="Tradicioinal - Viejo"
	
	append using "${path_new}Miembro.dta"
	replace quest="Tradicional - Nuevo" if quest==""
	
	append using "${path_pix}Miembro.dta"
	replace quest="Remoto" if quest==""


//	Keeping only "Approved by Headquarters" interviews ad merging with responsible data 	
	local today : display %tdCYND date(c(current_date), "DMY")
	display "`today'"

	merge m:1 interview__key interview__id quest using "${avance}firstanswerset`today'.dta", keep( using matched)
	
// Gen weeks	
	gen weeknumb=.
	gen endweek=.
	local x=${inicio}
	local w=${fin}
	local y=`x'+6
	local z=1
	while `y'<=`w' {
		replace endweek=`y' if edate>=`x' & edate<=`y'
		replace weeknumb=`z' if edate>=`x' & edate<=`y'
		local x=`x'+7
		local y=`y'+7
		local ++z
		dis "`z'"
	}
	
	replace weeknumb=`z' if weeknumb==.
	replace endweek=${fin} if endweek==.
	format endweek %td	
	
//	Refusal rate: _merge==2
	preserve
		keep if _merge==2
		collapse (count) _merge, by(interviewer coordinator entidad quest)
		rename _merge refuse
		save "${avance}diagnostics`today'.dta", replace
	restore

// 	Keeping only real interviews
	keep if _merge==3
	drop _merge

// 	HH Size:
	preserve
		bys interview__k interview__i quest (Miembro__i): keep if _n==_N
		collapse (mean) hhsize=Miembro__i (sd) hhsize_sd=Miembro__i (count) interviews=Miembro__i , by(interviewer coordinator entidad quest) 
		append using diagnostics.dta
		save diagnostics.dta, replace
	restore

// 	Gender:
	preserve
	
	
