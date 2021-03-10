*===============================================================================
*Author: Britta Rude
*Creation Date: Feb, 2021
*Topic: Fay-Herriot model for poverty map at the municipality level 
*===============================================================================
*Prepare ENCOVI 2019/20 data for Fay-Herriot model
*===============================================================================
*Set-up

*a) Exchange Rate
*Source: Banco Central Venezuela http://www.bcv.org.ve/estadisticas/tipo-de-cambio
			
local monedas 1 2 3 4 // 1=bolivares, 2=dolares, 3=euros, 4=colombianos
local meses 1 2 3 4 10 11 12 // 11=nov, 12=dic, 1=jan, 2=feb, 3=march, 4=april (these are the months the data was collected)
			
use "$exrate", clear
			
// if we consider that incomes are earned one month previous to data collection use this			
					destring mes, replace
					foreach i of local monedas {
						foreach j of local meses {
							if `j' !=12 {
							  local k=`j'+1
							 }
							else {
							  local k=1 // if the month is 12 we send it to month 1
							}
							sum mean_moneda	if moneda==`i' & mes==`j' // if we pick ex rate of month=2
							local tc`i'mes`k' = r(mean)
							display `tc`i'mes`k''
							}
						}

						
*b) ENCOVI Household data 2019/20
**** ENCOVI Database	
use "$rawdata\ENCOVI_2019_English labels.dta", clear


*Convert Bolivares to Dollars: Labor Income, Total Family Income and per capita income

local incomevar ila itf ipcf //these are monthly values 
foreach i of local incomevar {
*Dólares
 	gen `i'_usd = `i' /`tc2mes11' if interview_month==11 
	replace `i'_usd = `i' /`tc2mes12' if interview_month==12 
	replace `i'_usd = `i' /`tc2mes1' if interview_month==1 
	replace `i'_usd = `i' /`tc2mes2' if interview_month==2 
	replace `i'_usd = `i' /`tc2mes3' if interview_month==3 
	replace `i'_usd = `i' /`tc2mes4' if interview_month==4 	
}


*** Label variables
label var ila_usd "Labor Income(dollars)" //monthly
label var itf_usd "Total Family Income(dollars)" //monthly
label var ipcf_usd "IPCF (dollars)" //monthly

***Calculate 2011-PPP-$

*** Labor income, family income and IPCF in Dollar PPP 2011
gen ila_ppp = ila/ ppp11 / ipc*ipc11
gen itf_ppp = itf/ ppp11 / ipc*ipc11
gen ipcf_11 = ipcf/ ppp11 / ipc*ipc11

*** Label variables
label var ila_ppp "Labor Income PPP(dollars)"
label var itf_ppp "Total Family Income PPP(dollars)"
label var ipcf_11 "IPCF PPP (dollars)"


********************************************************************************
*Prepare variables for Fay-Herriot
********************************************************************************


********************************************************************************
*create unique municipio and parid id
gen str5 		temps		= "00000"

gen str2 		entidads	= substr(temps + string(entidad),-2,2)
gen str2 		municipios	= substr(temps + string(municipio),-2,2)
gen str2 		parroquias	= substr(temps + string(parroquia),-2,2)

gen str6		parid = entidads + municipios + parroquias
gen str4		munid = entidads + municipios

drop temps entidads municipios parroquias


*Plot observations per unique municipio id 
tab munid
list munid municipio in 1/10
codebook nombmun //172 unique values
codebook municipio //25 unique values
codebook munid //210 unique values 
list munid nombmun in 1/10

*Extract table with sample distribution 
bysort munid: egen obs_munid=count(interview__id)
label var obs_munid "Municipalities"

preserve
collapse (mean) obs_munid, by(munid)
asdoc sum obs_munid, stat(N mean min p10 p25 p50 max) replace nocf save($tables\obs_munid.doc) ///
title(Sample distribution of municipalities (ENCOVI 2019/20)) fhc(\b) fs(11) dec(1) ///
cnames(Number Mean Min 10-perc 25-perc Median Max)
restore

foreach v in region_est1 entidad nombmun { 
	asdoc tabulate `v', replace nocf save($tables\Obs_`v'_obs.doc) title(Number of observations - `v') fhc(\b) fs(11) dec(1)
}


********************************************************************************
*Create explanatory variables at household level (adapted from Poverty Maps by Mateo Uribe-Castro)

gen				ownviv = (tenencia_vivienda_comp == 1 | tenencia_vivienda_comp == 2)
gen				lavsec = (lavarropas == 1 | secadora == 1)
gen				tvradio = (televisor == 1 | radio == 1)
gen				calentac = (calentador == 1 | aire == 1)

rename			ndormi dormi
rename			banio_con_ducha banio 

gen				nhogviv = 1 if comparte_gasto_viv == 1
replace			nhogviv = npers_gasto_sep if comparte_gasto_viv == 0
recode			nhogviv (0 .=1)

gen				techo = (inlist(material_techo,1,2,3)) if material_techo != .
gen				pared = (material_pared == 1) if material_pared != .
gen				piso = (material_piso == 1) if material_piso != .
gen 			acue = (suministro_agua_comp == 1) if suministro_agua_comp != .
gen				freqagua = (suministro_agua_comp == 1 & frecuencia_agua == 1) if suministro_agua_comp != .
gen				elecpub = (serv_elect_red_pub == 1) if serv_elect_red_pub != .
gen				poceac = (tipo_sanitario == 1) if tipo_sanitario != .

g 				educyears = 0 if nivel_educ_en < 3
replace 		educyears = g_educ if nivel_educ_en == 3 
replace 		educyears = 9 + g_educ if nivel_educ_en == 4
replace 		educyears = g_educ if nivel_educ_en == 5
replace 		educyears = 6 + g_educ if nivel_educ_en == 6
replace 		educyears = 12 + a_educ if nivel_educ_en == 7
replace 		educyears = floor(12 + s_educ*0.5) if nivel_educ_en == 8
replace 		educyears = 19 if nivel_educ_en == 9

replace			educyears = 0 if educyears == . & nivel_educ_en == .
replace			educyears = 6 if educyears == . & nivel_educ_en ==3
replace			educyears = 12 if educyears == . & nivel_educ_en == 5
replace			educyears = 12 if educyears == . & nivel_educ_en == 6
replace			educyears = 15 if educyears == . & nivel_educ_en == 7
replace			educyears = 17 if educyears == . & nivel_educ_en == 8

g 				child7_12 = (edad >= 7 & edad <=12)
g 				noschool7_12 = (asiste == 0 & child7_12 == 1)

g 				schatt = (asiste == 1 & edad>=3 &  edad <15)
g 				literate = (alfabeto == 1)
g 				primaria = (g_educ == 6 & nivel_educ_en == 3)
replace 		primaria = 1 if nivel_educ_en == 5 & g_educ == 6
g 				secundaria =  (nivel_educ_en == 4 & g_educ == 3)
replace 		secundaria = 1 if nivel_educ_en == 5 & g_educ >= 5
g 				educsuper = (nivel_educ_en>7) 

g 				child = (edad < 15)
g 				adult = (edad >= 18)
g 				pet = (edad >= 12)

g 				labforce = (ocupado == 1 | desocup == 1) if pet == 1
g 				pei = (labforce == 0) if pet == 1 

g 				h_age = edad if relacion_en == 1
g 				h_fem = (hombre == 0) if relacion_en == 1
g 				h_single = (estado_civil==2 | estado_civil==4) if relacion_en == 1
g 				h_educ = educyears if relacion_en == 1
g 				h_primaria = (primaria == 1) if relacion_en == 1
g 				h_secundaria = (secundaria == 1) if relacion_en == 1
g 				h_ocupado = (ocupado == 1) if relacion_en == 1
g 				h_desocup = (desocup == 1) if relacion_en == 1
g 				h_selfemp = (relab == 3) if relacion_en == 1
g 				h_entrepreneur = (relab == 1) if relacion_en == 1
g 				h_publicsect = (categ_ocu == 1) if relacion_en == 1

*Sum by household (id=household unique identifier)
egen 			nchild = sum(child), by(id)
egen 			nchildsch = sum(schatt), by(id)
egen 			nadult = sum(adult), by(id)
egen 			nocupado = sum(ocupado), by(id)
egen 			npei = sum(pei), by(id)


*Generate variables that in povmap by Mateo Uribe-Castro come from census 2011 - here based on ENCOVI 2019/2020
g selfemp = (relab==3)
g entrepreneur = (relab == 1)
g publicsect = (categ_ocu == 1)
gen person__id = _n ///unique identifier for every person in sample


local variables ocupado pet desocup selfemp entrepreneur publicsect schatt child secundaria 
tempfile temptest 
save `temptest', emptyok

preserve
collapse (sum) `variables' (count) person__id [fw=pondera], by(munid)
tab munid 

foreach v of varlist `variables'{
	rename `v' p_`v'
}

rename person__id p_person__id
list in 1/10

save `temptest', replace

restore

merge m:1 munid using `temptest' //all match
drop _merge

g occrate = p_ocupado / p_pet
g unemprate = p_desocup / (p_ocupado + p_desocup)
*g pobrenbi11 = p_pnbi / samplehh //not included in ENCOVI, only in census
g shselfemp = p_selfemp / (p_ocupado + p_desocup)
g shentrepreneur = p_entrepreneur / (p_ocupado + p_desocup)
g shpublicsect = p_publicsect / (p_ocupado + p_desocup)
g shschatt = p_schatt / p_child
g shsecundaria = p_secundaria / p_person__id

		
gen id_pers = _n
egen samplesize = count(id_pers), by(munid)


*******************************************************************************
*Keep only responses by household head 

keep if relacion_en == 1
keep entidad region_est1 munid nombmun parid npers_viv npers_gasto_sep id pondera_hh ///
		ipcf gpcf pobre_extremo ownviv dormi banio auto tvradio lavsec heladera calentac /// 
		techo pared piso acue freqagua elecpub poceac nhogviv /// 
		h_* miembros nchild nchildsch nadult nocupado npei ///
		psu samplesize ///
		occrate unemprate shselfemp shentrepreneur shpublicsect shschatt shsecundaria //in povmap by mateo these come from census 2011, here encovi
		
		g shoccadult = nocupado / nadult
		g shchild = nchild / miembros
		g notsch = (nchildsch < nchild)



		


*******************************************************************************
*Save household data 
save "${dataout}/survey_hhlevel.dta", replace




*******************************************************************************
*Prepare for FH Model (1 line per munid)

*Get stratas
use "F:\WB\ENCOVI\ENCOVI Data\Info_strata.dta", clear
gen centropo2 = substr(centropo, 3,5)
destring entidad, gen(entidad2)
gen entidad3 = string(entidad2)
gen psu = entidad3 + municipio + parroquia + centropo2 + segmento 

gen stringlength = strlen(psu)
tab stringlength //some are 11 some are 12
replace psu = "0" + psu if stringlength==11
replace stringlength = strlen(psu)
tab stringlength //some are 11 some are 12

save "F:\WB\ENCOVI\ENCOVI Data\Info_strata_conpsu.dta", replace

use "${dataout}/survey_hhlevel.dta", clear
encode id, gen(hhid)

gen stringlength = strlen(psu)
tab stringlength //some are 11 some are 12
replace psu = "0" + psu if stringlength==11

merge m:1 psu using "$rawdata\Info_strata_conpsu.dta", keepusing(psu stratum1) //53 cannot be matched as no psu (checked with Daniel)
drop _merge //check



********************************************************************************
*Calculate poverty gap and poverty severity from survey data

*Poverty Gap Index
gen poverty_gap = (2240342 - ipcf)/2240342 //2240342 is extreme poverty line
replace poverty_gap = 0 if poverty_gap<0
sum poverty_gap, d

*Poverty Severity Index
gen poverty_severity = ((2240342 - ipcf)/2240342)^2 //2240342 is extreme poverty line
replace poverty_severity = 0 if ipcf>2240342
sum poverty_severity, d




********************************************************************************
*Calculate simple mean (without survey setting) to calculate the design effect
********************************************************************************

encode munid, gen(munid2)

local var ipcf pobre_extremo poverty_gap poverty_severity //define variables of interest for fh estimation
foreach x in `var'{
mean `x', over(munid2)

mat a= e(b)
mat b = e(V)
mata: bb=st_matrix("b")
mata: bb=diagonal(bb)
mata: st_matrix("b",bb)	
mat c = a',b

preserve
	collapse (first) munid2, by(munid)
	svmat2 c, names(simple_mean_`x' simple_var_`x')
	tempfile `x'
	codebook munid
	list in 1/10
	save ``x''
restore

merge m:1 munid using ``x'' //all match 
drop _merge

}

sum simple_mean_ipcf
sum simple_mean_pobre_extremo
sum simple_mean_poverty_gap
sum simple_mean_poverty_severity
sum simple_var_ipcf
sum simple_var_pobre_extremo
sum simple_var_poverty_gap
sum simple_var_poverty_severity


********************************************************************************
*Survey set data
svyset psu [pw=pondera_hh], strata(stratum1)



*******************************************************************************
*Generate direct estimator from household data for FH model (weighted mean and direct variance of family per capita income and extreme poverty rate) 

local var ipcf pobre_extremo poverty_gap poverty_severity //define variables of interest for fh estimation
foreach x in `var'{
svy: mean `x', over(munid2)

mat a= e(b)
mat b = e(V)
mata: bb=st_matrix("b")
mata: bb=diagonal(bb)
mata: st_matrix("b",bb)	
mat c = a',b

codebook munid 

preserve
	collapse (first) munid2, by(munid)
	svmat2 c, names(`x'_munid `x'_var_munid)
	tempfile `x'
	codebook munid
	list in 1/10
	save ``x''
restore


merge m:1 munid using ``x'' //all match 
drop _merge
}

*Check
sum pobre_extremo_munid,d //Check
tab pobre_extremo_munid, m //None is missing
tab pobre_extremo_var_munid, m //None is missing
sum ipcf_munid,d //Check
sum poverty_gap_munid, d
sum poverty_severity_munid, d

*gen pobre_extremo_munid_se=sqrt(pobre_extremo_var_munid)	
*gen pobre_extremo_munid_cv = 100*pobre_extremo_munid_se/pobre_extremo_munid		
*gen ipcf_munid_se = sqrt(ipcf_var_munid)
*gen ipcf_munid_cv=100*ipcf_munid_se/ipcf_munid


*******************************************************************************
*Define variables of interest

global directestimators ipcf_munid ipcf_var_munid pobre_extremo_munid pobre_extremo_var_munid poverty_gap_munid poverty_gap_var_munid ///
poverty_severity_munid poverty_severity_var_munid simple_mean_poverty_severity simple_var_poverty_severity ///
samplesize simple_mean_ipcf simple_mean_pobre_extremo simple_mean_poverty_gap simple_var_ipcf simple_var_pobre_extremo simple_var_poverty_gap
global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global hhvars miembros shchild shoccadult notsch
*Second set from census 2011 in povmap, here from encovi: all but pobrenbi11 and regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9
global munvars occrate unemprate shselfemp shentrepreneur shpublicsect shschatt



********************************************************************************
*Collapse to municipality level 

preserve
tempfile collapsed
collapse (mean) ipcf ${vivvars} ${headvars} ${hhvars} (first) ${munvars} (first) ${directestimators} region_est1 nombmun [fw=pondera_hh], by(munid)
save `collapsed'
list munid pobre_extremo_munid in 1/10
restore
//Check

collapse (mean) ipcf ${vivvars} ${headvars} ${hhvars} (first) ${munvars} ${directestimators} ///
region_est1 nombmun [fw=pondera_hh], by(munid)
gen munid_str = munid
destring munid, replace



********************************************************************************
*Plot summary statistics for income at munid level 

label var ipcf_munid "Income (direct estimator)"
label var pobre_extremo_munid "Extreme Poverty Rate (direct estimator)"
label var poverty_gap_munid "Extreme Poverty Gap (direct estimator)"
label var poverty_severity_munid "Extreme Poverty Severity (direct estimator)"

asdoc sum ipcf_munid pobre_extremo_munid poverty_gap_munid poverty_severity_munid, stat(N mean min max sd) dec(2) ///
replace nocf save($tables\sum_povertyindicators_munid.doc) label ///
title(Summary of poverty indicators and their standard deviation by municipality) fhc(\b) fs(11) abb(.)


********************************************************************************
*Save household data ready for FH model at munid level
save "${dataout}/survey_hhlevel_fhmodel.dta", replace






