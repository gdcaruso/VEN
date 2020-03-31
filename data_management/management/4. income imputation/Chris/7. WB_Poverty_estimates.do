/*====================================================================
project:    WB Poverty estimates - ENCOVI 2014-2017
Author:        Christian C Gomez C 
----------------------------------------------------------------------
Creation Date:    28 Dic 2018 - 8:20:48
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/
drop _all
clear
global input "Z:\wb509172\Venezuela\ENCOVI\Data\FINAL_DATA_BASES\ENCOVI imputation data"
global lineas "Z:\wb509172\Venezuela\DATA_BASES\VEN 2011-2015\VEN_2012_EHM\VEN_2012_EHM_v01_M_v01_A_SEDLAC_02\Data\Harmonized" // lineas oficiales 2012
global output "Z:\wb509172\Venezuela\ENCOVI\Projects\Income Imputation and WB poverty estimates\excel"

/*====================================================================
                        1: Rent imputation
====================================================================*/

local p = 0
cap mat drop Pov
foreach year in /*2015 2016 */ 2017 2018 {
local ++p
	di in y `year'
	use "${input}\ENCOVI_imputed_`year'.dta", clear
	qui {
		
	noi di in g "***********************************************"
	noi di in g "******************`year'*************************"
	noi di in g "***********************************************"
		
		
		if "`year'" == "2015" local per p25
		if "`year'" == "2016" local per p1
		if "`year'" == "2017" local per min
		if "`year'" == "2018" local per min
		* Identifica linea de pobreza de la ENCOVI 
		noi tab pobreza_enc [w=pondera]  if pobreza_enc!= 99
		tab pobreza_enc [w=pondera] if inrange(pobreza_enc,0,2)
		noi sum ipcf [w=pondera], d
		sum ipcf [w=pondera] if pobreza ==0, d
		gen linea_poor = `r(`per')'
		noi sum linea_poor
				
		sum ipcf [w=pondera] if pobreza_enc==1, d
		gen linea_ext_poor = `r(`per')'
		noi sum linea_ext_poor 
		
		local lp = `r(mean)'
		
		* Medias 
		sum ipcf [w=pondera] if pobreza_enc!= 99, d
		local mean = `r(p50)'
		sum ipcf_imputed [w=pondera] , d
		local rp95_impu = `r(p95)'
		local impu_mean = `r(p50)'
		
		*Ingresos descontando imputación
		gen inla_impu_pc = inla_tot_imputed/nper
		gen ila_impu_pc = ila_tot_imputed/nper
		gen rent_impu_pc = renta_imp/nper
		
		/*Ajuste de la linea tomando linea de CNA*/
		if "`year'" == "2014" local cna 5391 // 6382.62
		
		/*Generacion de CPIs*/
		gen cpi_11 = 100  // Todos los indices los lleve a 100 en 2011 basado en el crecimiento anualizado
				
		gen cpi_cendas_basket = .  		
		replace cpi_cendas_basket = 1061.572 if ano == 2015
		replace cpi_cendas_basket = 6791.048 if ano == 2016
		replace cpi_cendas_basket = 39678.513 if ano == 2017
		replace cpi_cendas_basket = 28111464.31 if ano == 2018
		
		
		gen cpi_cendas_food = .
		replace cpi_cendas_food = 1541.792 if ano == 2015
		replace cpi_cendas_food = 11692.382 if ano == 2016
		replace cpi_cendas_food = 61292.094 if ano == 2017
		replace cpi_cendas_food = 35597743.33 if ano == 2018
		
		gen cpi_imf = .
		replace cpi_imf = 578.963 if ano == 2015
		replace cpi_imf = 2051.844 if ano == 2016
		replace cpi_imf = 24365.653 if ano == 2017
		replace cpi_imf = 333833811 if ano == 2018
		
		/*Conversion de bolivares soberanos a bolivares fuertes*/  // bajo el supuesto de elminacion de 5 ceros
		if "`year'" == "2018" {
			noi sum ipcf ipcf_imputed
			replace ipcf = ipcf * 100000
			replace ipcf_imputed = ipcf_imputed * 100000
		}
		
		noi di in r  "`year'"
		noi sum ipcf ipcf_imputed
		
		/*Generacion de ingreso en PPP11*/
		gen ipcf_ppp11_basket = ipcf * (cpi_11/cpi_cendas_basket) / 2.91501   // Tomado de PovCalNet estimacion 2015 "Z:\wb509172\Venezuela\DATA_BASES\PovCalNet"
		gen ipcf_ppp11_food = ipcf * (cpi_11/cpi_cendas_food) / 2.91501
		gen ipcf_ppp11_imf = ipcf * (cpi_11/cpi_imf) / 2.91501
		
		gen ipcf_ppp11_impu_basket = ipcf_imputed * (cpi_11/cpi_cendas_basket) / 2.91501   // Tomado de PovCalNet estimacion 2015 "Z:\wb509172\Venezuela\DATA_BASES\PovCalNet"
		gen ipcf_ppp11_impu_food = ipcf_imputed * (cpi_11/cpi_cendas_food) / 2.91501
		gen ipcf_ppp11_impu_imf = ipcf_imputed * (cpi_11/cpi_imf) / 2.91501
		
		
				
		/* lineas en Bolivares */
		
			local i = 0
			foreach income in ipcf ipcf_imputed  {
				local ++i
				local scenario linea_ext_poor bb_cendas fb_cendas imf 
					local sc = 0
					foreach s of local scenario {
						local ++sc 
						sum linea_ext_poor if ano==`year'
						local cna = `r(mean)' * 5.2
						
						if "`s'" != "linea_ext_poor" {
						if "`s'" == "bb_cendas"	local inflation "17270	110476 645486 457314498"
						if "`s'" == "fb_cendas"	local inflation "20244	153522 804773 467402753"
						if "`s'" == "imf"	local inflation "11419	40469 480564 6584200998"
						local cna: word `p' of `inflation'
						}
						
						*local cna 14556  // Valor tomado del documento de LPE "Pobreza, cobertura misiones ..."
						local linea = (`cna' / 5.2) // Valor tomado del documento CNA-Feb14 en la documentacion de la ENCOVI
						local iff ""
						if ("`income'" == "ipcf" | "`income'" == "ipcf_ppp11_basket" | "`income'" == "ipcf_ppp11_food" | "`income'" == "ipcf_ppp11_imf" )  local iff "if pobreza_enc!= 99"
						
						apoverty `income' [w=pondera] `iff', line(`linea') h pgr fgt3 apg
						local fgt0 = `r(head_1)'  
						local fgt1 = `r(pogapr_1)'
						local fgt2 = `r(fogto3_1)'
						local agap = `r(pogap1_1)'
						
						sum `income' [w=pondera] `iff', d
						local mean = `r(mean)'
						local median = `r(p50)'
						
						mat Pov = nullmat(Pov) \ `year', `i', `sc', 0, `fgt0'
						mat Pov = nullmat(Pov) \ `year', `i', `sc', 1, `fgt1'
						mat Pov = nullmat(Pov) \ `year', `i', `sc', 2, `fgt2'
						mat Pov = nullmat(Pov) \ `year', `i', `sc', 3, `mean'
						mat Pov = nullmat(Pov) \ `year', `i', `sc', 4, `median'
						
					}
				}
			
			/* lineas en PPP11 */
			
			local j = 2
			foreach income in ipcf_ppp11_basket ipcf_ppp11_food ipcf_ppp11_imf ipcf_ppp11_impu_basket ipcf_ppp11_impu_food ipcf_ppp11_impu_imf {
				local ++j
				local scenario 1.9 3.2 5.5
					local sc = 4
					foreach s of local scenario {
						local ++sc 
						local linea = `s' * (365/12)
						local iff ""
						if ("`income'" == "ipcf_ppp11_basket" | "`income'" == "ipcf_ppp11_food" | "`income'" == "ipcf_ppp11_imf" )  local iff "if pobreza_enc!= 99"
						
						apoverty `income' [w=pondera] `iff', line(`linea') h pgr fgt3 apg
						local fgt0 = `r(head_1)'  
						local fgt1 = `r(pogapr_1)'
						local fgt2 = `r(fogto3_1)'
						local agap = `r(pogap1_1)'
						
						sum `income' [w=pondera] `iff', d
						local mean = `r(mean)'
						local median = `r(p50)'
						noi di in r "`income' - `linea' - `fgt0' - `sc'"
						mat Pov = nullmat(Pov) \ `year', `j', `sc', 0, `fgt0'
						mat Pov = nullmat(Pov) \ `year', `j', `sc', 1, `fgt1'
						mat Pov = nullmat(Pov) \ `year', `j', `sc', 2, `fgt2'
						mat Pov = nullmat(Pov) \ `year', `j', `sc', 3, `mean'
						mat Pov = nullmat(Pov) \ `year', `j', `sc', 4, `median'			
					
				}
			}
		}


*twoway (kdensity ipcf [w=pondera] if pobreza_enc==0 & ipcf<10000000) (kdensity ipcf [w=pondera] if pobreza_enc==1 | pobreza_enc==2 & ipcf<10000000)
*twoway (kdensity ipcf [w=pondera] if ipcf<linea_poor & pobreza_enc!= 99) (kdensity ipcf_imputed [w=pondera] if ipcf_imputed<`rp95_impu')
	
	/*Graphs*/
	* local angle = 75
	* if ("`year'" == "2017") local angle = 90
	* set scheme s1rcolor
	* twoway (kdensity ipcf [w=pondera] if ipcf<`rp95_impu' & pobreza_enc!= 99) (kdensity ipcf_imputed [w=pondera] if ipcf_imputed<`rp95_impu') ///
	* , title (ENCOVI income estimations - Year: `year') xline (`lp')   xline(`mean' `impu_mean', lpattern(dash) lcolor(grey))  xlabel(0 `lp' "ENCOVI Poverty line" `mean' "Original median" `impu_mean' "Imputed median" `rp95_impu', labsize(vsmall) angle(`angle')) subtitle(Distribution after imputation of missing values, size(small)) xti(Percapita income, size(small))  yti(Density, size(small)) ylabel(, labsize(vsmall)) legend(label( 1 "Original percapita income") label( 2 "Imputed percapita income"))  ///
	* note(`"Note: includes labor, non labor and rent imputation. Top 5% excluded for visualization."', size(vsmall))
	* graph export "${output}/Graph_`year'.png", as(png) replace
	
}
	
/* Mat results */
	
	mat list Pov
	mat colnames Pov = year income scenario indicator value
		
	drop _all
	svmat Pov, n(col)

	* label variables                                              
	label define income 1 "Original" 2 "Imputed" 3 "Original PPP11 Basket" 4 "Original PPP11 Food" 5 "Original PPP11 IMF" 6 "Imputed PPP11 Basket" 7 "Imputed PPP11 Food" 8 "Imputed PPP11 IMF", modify
	label values income income

	rename scenario linea
	label define linea 1 "linea_ext_poor" 2 "CNA_basket_cendas" 3 "CNA_food_cendas" 4 "CNA_IMF" 5 "1.9 USD PPP11" 6 "3.2 USD PPP11" 7 "5.5 USD PPP11", modify
	label values linea linea
	
	label define indicator 0 "FGT0" 1 "FGT1" 2 "FGT2" 3 "Mean" 4 "Median" , modify
	label values indicator indicator
	

/* Export results */	
	
*export excel using "${output}/Poverty_estimation_WB_PPP11.xlsx", first(variables) sheet(Raw) sheetreplace 

	
	
