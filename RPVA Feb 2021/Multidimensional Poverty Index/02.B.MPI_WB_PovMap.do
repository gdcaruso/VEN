/*===========================================================================
Country name:	Venezuela
Year:			2021
Survey:			ENCOVI 2019/20

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the different sections of the RPBA Venezuela 
Output:			    Multidimensional Poverty Index


=============================================================================*/
********************************************************************************


***Merge with strata information for survey design 

encode id, gen(hhid)

gen stringlength = strlen(psu)
tab stringlength //some are 11 some are 12
replace psu = "0" + psu if stringlength==11

merge m:1 psu using "$rawdata\Info_strata_conpsu.dta", keepusing(psu stratum1) //171 cannot be matched as no psu (checked with Daniel)
drop _merge //check

*Survey set data
svyset psu [pw=pondera_hh], strata(stratum1)


********************************************************************************
*Prepare dataset

***create unique municipio and parid id
gen str5 		temps		= "00000"

gen str2 		entidads	= substr(temps + string(entidad),-2,2)
gen str2 		municipios	= substr(temps + string(municipio),-2,2)
gen str2 		parroquias	= substr(temps + string(parroquia),-2,2)

gen str6		parid = entidads + municipios + parroquias
gen str4		munid = entidads + municipios

drop temps entidads municipios parroquias



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

*******************************************************************************
*Keep only responses by household head 

keep if relacion_en == 1
keep entidad region_est1 munid nombmun parid npers_viv npers_gasto_sep id pondera_hh ///
		ipcf gpcf pobre_extremo ownviv dormi banio auto tvradio lavsec heladera calentac /// 
		techo pared piso acue freqagua elecpub poceac nhogviv /// 
		h_* miembros nchild nchildsch nadult nocupado npei ///
		multi_poor_wb psu stratum1
		
		g shoccadult = nocupado / nadult
		g shchild = nchild / miembros
		g notsch = (nchildsch < nchild)




*******************************************************************************
*Generate direct estimator from household data for FH model (weighted mean and direct variance of family per capita income and extreme poverty rate) 
encode munid, gen(munid2)

local var multi_poor_wb //define variables of interest for fh estimation
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
sum multi_poor_wb_munid,d //Check
tab multi_poor_wb_munid, m //269 are missing
tab multi_poor_wb_var_munid, m //269 are missing 
sum multi_poor_wb_var_munid,d //Check



*******************************************************************************
*Define variables of interest

global directestimators multi_poor_wb_munid multi_poor_wb_var_munid
global vivvars ownviv auto heladera dormi banio lavsec tvradio calentac nhogviv techo pared piso acue freqagua poceac elecpub  
global headvars h_age h_fem h_single h_primaria h_secundaria h_educ h_ocupado h_desocup h_selfemp h_entrepreneur h_publicsect
global hhvars miembros shchild shoccadult notsch



********************************************************************************
*Collapse to municipality level 

collapse (mean) ipcf ${vivvars} ${headvars} ${hhvars} (first) ${directestimators} ///
region_est1 nombmun [fw=pondera_hh], by(munid)
gen munid_str = munid
destring munid, replace


********************************************************************************
*Save household data ready for FH model at munid level
save "${dataout}/survey_hhlevel_fhmodel_multipoor_wb.dta", replace

 



