/*=================================================================================
				PROCESS CENSUS DATA
Project:       Poverty Map Venezuela
Author:        Mateo Uribe-Castro
---------------------------------------------------------------------------
Creation Date:      June, 2020
==================================================================================*/

clear all 

use "${dataout_census}/${censusdb}PER.dta", clear
drop _merge

codebook munid

g cony = 1 if parentes == 2
g hij = 1 if parentes == 3 | parentes == 4
g sueg = 1 if parentes == 6 | parentes == 7 | parentes == 8 | parentes == 9

g educyears = 0 if niveleduc < 4
replace educyears = grado if niveleduc == 4
replace educyears = 6 + aniollego if niveleduc == 5
replace educyears = floor(12 + semestre*0.5) if niveleduc == 6
replace educyears = floor(12 + semestre*0.5) if niveleduc == 7

g child7_12 = (edad >= 7 & edad <=12)
g noschool7_12 = (asistesc == 2 & child7_12 == 1)

g schatt = (asistesc == 1 & edad>=3 & edad <15)
g literate = (alfabeta == 1)
g primaria = (grado == 6)
replace primaria = 1 if niveleduc == 5 & aniollego < 5
g secundaria =  (niveleduc == 5 & aniollego >= 5)
replace secundaria = 1 if titulouniv == 2
g educsuper = (titulouniv == 1)

g child = (edad < 15)
g adult = (edad >= 18)
g pet = (edad >= 12)

g ocupado = (sitecono == 1 | sitecono == 2) if pet == 1

g desocup = (sitecono == 3 | sitecono == 4) if pet == 1

g labforce = (ocupado == 1 | desocup == 1) if pet == 1

g pei = (labforce == 0) if pet == 1 

g selfemp = (tipoemp == 5) if labforce == 1

g entrepreneur = (tipoemp == 6) if labforce == 1

g publicsect = (tipoemp == 1 | tipoemp == 2) if labforce == 1

g h_age = edad if parentes == 1
g h_fem = (sexo == 2) if parentes == 1
g h_single = (sitconyug == 3) if parentes == 1
g h_educ = educyears if parentes == 1
g h_primaria = (primaria == 1) if parentes == 1
g h_secundaria = (secundaria == 1) if parentes == 1
g h_ocupado = (ocupado == 1) if parentes == 1
g h_desocup = (desocup == 1) if parentes == 1
g h_selfemp = (selfemp == 1) if parentes == 1
g h_entrepreneur = (entrepreneur == 1) if parentes == 1
g h_publicsect = (publicsect == 1) if parentes == 1
g h_loweduc = (educyears < 3 | educyears == .) if parentes == 1

egen attendance7_12 = sum(noschool7_12), by(hhid)

egen miembros = count(parentes), by(hhid)
egen nchild = sum(child), by(hhid)
egen nchildsch = sum(schatt), by(hhid)
egen nadult = sum(adult), by(hhid)
egen nocupado = sum(ocupado), by(hhid)
egen npei = sum(pei), by(hhid)

foreach x of varlist primaria secundaria ocupado desocup schatt pei child pet selfemp entrepreneur publicsect {
	egen p_`x' = total(`x'), by(munid) missing
}

keep if parentes == 1
drop perid
compress

egen munhhcount = sum(parhhcount), by(munid)
sum munhhcount

keep hhid parentes samplehh parhhcount munhhcount p_* attendance7_12 miembros nchild nchildsch nadult nocupado npei h_* munid

save "${secondary}/personas_munid.dta", replace


*----------------------------Households

use "${dataout_census}/${censusdb}HOG.dta"

g ownviv 	= (tenenciavi == 1 | tenenciavi == 2) if tenenciavi != .
g dormi 	= nucuador if nucuador != .
g banio		= numbaniio if numbaniio !=. 
g auto		= (carro==1) if carro != .
g tvradio	= (tv==1 | radio==1) if tv != .
g lavsec	= (lavadora==1 | secadora==1) if lavadora != .
g heladera	= (nevera==1) if nevera != .
g calentac	= (calentador==1 | aire==1) if calentador != .

keep hhid ownviv dormi banio auto tvradio lavsec heladera calentac
compress
save "${secondary}/hogares.dta", replace

*----------------------------Dwellings
clear all
use "${dataout_census}/${censusdb}VIV.dta"

keep if usoviv == 1
keep if condocu1 == 1

g precaria = (inlist(tipoviv,5,6,7,9)) if tipoviv != .z
g techo = (mattecho == 1 | mattecho == 2 | mattecho == 3) if mattecho != .z
g pared = (matpared == 1) if matpared != .z
g piso = (matpiso == 1) if matpiso != .z
g acue = (agua == 1) if agua != .z
g freqagua = (frecagua == 1 & agua == 1) if agua != .z
g elecpub = (accelectr == 1 | accelectr == 2) if accelectr != .z
g poceac = (poceta == 1) if poceta != .z
g nhogviv = t1hogar

keep vivid precaria techo pared piso acue freqagua elecpub poceac nhogviv
save "${secondary}/viviendas.dta", replace

*----------------------------Merge
clear all
use "${secondary}/personas_munid.dta"

merge 1:1 hhid using "${secondary}/hogares.dta", keep(matches) //all match
drop if _merge == 2
drop _merge

gen vivid = substr(hhid,1,38)
joinby vivid using "${secondary}/viviendas.dta", unmatched(master)

gen nbi1 = (attendance7_12 > 0) if parentes == 1 
gen nbi2 = (miembros / dormi > 3) if parentes == 1 & dormi != .
gen nbi3 = (precaria == 1) if parentes == 1 & precaria != .
gen nbi4 = (acue == 0 | poceac == 0) if parentes == 1 & acue != .
gen nbi5 = (miembros / nocupado > 3 & h_loweduc == 1) if parentes == 1
gen nbi = nbi1 + nbi2 + nbi3 + nbi4 + nbi5 if parentes == 1
g pnbi = (nbi>0) if parentes == 1
g pnbi_ext = (nbi>=2) if parentes == 1

gen parid = substr(hhid,1,6)
gen munid = substr(hhid,1,4)
gen entid = substr(hhid,1,2)

foreach x of varlist pnbi* nbi* {
	egen p_`x' = sum(`x'), by(munid) missing
}

egen munpop = total(miembros) if parentes == 1, by(munid) 

compress

*Save a dataset with one obs. per municipality to create municipality level controls
preserve
	bysort munid: gen munorder = _n
	keep if munorder == 1

	keep p_* samplehh parhhcount munhhcount parid munid entid munpop
	
	g occrate = p_ocupado / p_pet
	g unemprate = p_desocup / (p_ocupado + p_desocup)
	g pobrenbi11 = p_pnbi / samplehh
	g shselfemp = p_selfemp / (p_ocupado + p_desocup)
	g shentrepreneur = p_entrepreneur / (p_ocupado + p_desocup)
	g shpublicsect = p_publicsect / (p_ocupado + p_desocup)
	g shschatt = p_schatt / p_child
	g shsecundaria = p_secundaria / munpop
	
	keep occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt shsecundaria /// 
		samplehh parhhcount munhhcount parid munid entid munpop
	compress
	save "${dataout_census}/census_munlevel.dta", replace
restore

*Merge munlevel dataset to rest of census 
keep hhid entid parid munid vivid samplehh parhhcount munhhcount ownviv dormi banio auto tvradio lavsec heladera calentac /// 
		techo pared piso acue freqagua elecpub poceac nhogviv /// 
		h_* miembros nchild nchildsch nadult nocupado npei 
		
merge m:1 munid using "${dataout_census}/census_munlevel.dta", keepusing(occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt munpop)
drop _merge //all match

		g shoccadult = nocupado / nadult
		g shchild = nchild / miembros
		g notsch = (nchildsch < nchild)
		
destring munid, replace
rename hhid oghhid
gen hhid = _n

gen lp_extrema = 2243330
gen lp_moderada = 5546981
compress

replace entid = substr(oghhid,1,2)

g regionadm = 2 if entid == "01" // distrito
replace regionadm = 5  if entid == "02" // amazonas
replace regionadm = 8 if entid == "03" // anzoategui
replace regionadm = 7 if entid == "04" // apure
replace regionadm = 3 if entid == "05" // aragua
replace regionadm = 1 if entid == "06" // barinas
replace regionadm = 5 if entid == "07" // bolivar
replace regionadm = 3 if entid == "08" // carabobo
replace regionadm = 3 if entid == "09" // cojedes
replace regionadm = 6 if entid == "10" // dependencias federales
replace regionadm = 4 if entid == "11" // falcon
replace regionadm = 7 if entid == "12" // guarico
replace regionadm = 4 if entid == "13" // lara
replace regionadm = 1 if entid == "14" // merida
replace regionadm = 2 if entid == "15" // miranda
replace regionadm = 8 if entid == "16" // monagas
replace regionadm = 6 if entid == "17" // nuevaesparta
replace regionadm = 4 if entid == "18" // portuguesa
replace regionadm = 8 if entid == "19" // sucre
replace regionadm = 1 if entid == "20" // tachira
replace regionadm = 1 if entid == "21" // trujillo
replace regionadm = 4 if entid == "22" // yaracuy
replace regionadm = 9 if entid == "23" // zulia
replace regionadm = 2 if entid == "24" // vargas
replace regionadm = 5 if entid == "25" // delta

tab regionadm, gen(regadm)
drop regionadm

gen ponderac=1

save "${dataout_census}/census_hhlevel_munid.dta", replace




*******************************************************************************
*Prepare for FH Model (1 line per munid)

use "${dataout_census}/census_hhlevel_munid.dta", clear

global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global hhvars miembros shchild shoccadult notsch
global munvars munpop occrate unemprate pobrenbi11 shselfemp shentrepreneur shpublicsect shschatt regadm2 regadm3 regadm4 regadm5 regadm6 regadm7 regadm8 regadm9

collapse (mean) ${vivvars} ${headvars} ${hhvars} (first) ${munvars} entid, by(munid)

save "${dataout_census}/census_hhlevel_munid_fhmodel.dta", replace



























 








