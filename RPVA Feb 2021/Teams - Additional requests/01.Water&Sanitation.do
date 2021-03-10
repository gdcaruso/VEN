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
Output:			    Additional analysis for the RPBA 


=============================================================================
	01. Water and Sanitation: National
=============================================================================*/
*Only answered for household head, so use household weights. 

*Water supply national level
tab suministro_agua [fw=pondera_hh]
estpost tab suministro_agua [fw=pondera_hh], label
esttab using "$tables/watersupply_national.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Water supply - National (ENCOVI 2019/20)) replace

*Water frequency national level
tab frecuencia_agua [fw=pondera_hh]
estpost tab frecuencia_agua [fw=pondera_hh], label
esttab using "$tables/waterfrequency_national.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Water frequency - National (ENCOVI 2019/20)) replace

*sanitary type national level
tab tipo_sanitario [fw=pondera_hh]
estpost tab tipo_sanitario [fw=pondera_hh], label
esttab using "$tables/sanitarytype_national.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Sanitary Type - National (ENCOVI 2019/20)) replace

*Bathroom with shower
tab banio_con_ducha [fw=pondera_hh]
estpost tab banio_con_ducha [fw=pondera_hh], label
esttab using "$tables/banio_ducha.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Bathroom with shower- National (ENCOVI 2019/20)) replace

*Number of bathrooms
tab nbanios [fw=pondera_hh]
estpost tab nbanios [fw=pondera_hh], label
esttab using "$tables/nbanios.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Number of bathrooms- National (ENCOVI 2019/20)) replace

*Bathroom per people in household
tab miembros nbanios [fw=pondera_hh]
estpost tab miembros nbanios [fw=pondera_hh], label
esttab using "$tables/banios_miembros.csv", cells("b") collabels("Bathrooms") label unstack varlabels(`e(labels)') ///
title(Number of bathrooms per household members- National (ENCOVI 2019/20)) replace eqlabels(, lhs("Household members"))


*Drinking Water
local varlist fagua_acueduc fagua_estanq fagua_cisterna fagua_bomba fagua_pozo fagua_manantial fagua_otro fagua_botella
foreach x in `varlist'{
tab `x' [fw=pondera_hh]
estpost tab `x' [fw=pondera_hh], label
esttab using "$tables/`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Drinking Water `x' - National (ENCOVI 2019/20)) replace
}

*Water treatment 
local varlist tratamiento_agua tipo_tratamiento
foreach x in `varlist'{
tab `x' [fw=pondera_hh]
estpost tab `x' [fw=pondera_hh], label
esttab using "$tables/`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Water Treatment `x' - National (ENCOVI 2019/20)) replace
}

*Payment for services
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x' [fw=pondera_hh]
estpost tab `x' [fw=pondera_hh], label
esttab using "$tables/`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Payment Services `x' - National (ENCOVI 2019/20)) replace
}

*Payment for services
local varlist pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon
foreach x in `varlist'{
tab `x' [fw=pondera_hh]
estpost tab `x' [fw=pondera_hh], label
esttab using "$tables/`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Payment Services `x' - National (ENCOVI 2019/20)) replace
}

*School servies
local varlist fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protestas nunca_deja_asistir
foreach x in `varlist'{
tab `x' [fw=pondera]
estpost tab `x' [fw=pondera], label
esttab using "$tables/E_`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(School Absence `x' - National (ENCOVI 2019/20)) replace
}

*Health
local varlist enfermo enfermedad
foreach x in `varlist'{
tab `x' [fw=pondera]
estpost tab `x' [fw=pondera], label
esttab using "$tables/H_`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Health `x' - National (ENCOVI 2019/20)) replace
}


asdoc tab enfermedad_o [fw=pondera], replace nocf save($tables\illnesses_other.doc)

 

/*=============================================================================
	02. Water and Sanitation: Regional
=============================================================================*/

*Water
local varlist suministro_agua frecuencia_agua
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Water: `x' - Regional (ENCOVI 2019/20)) replace
}

*Sanitary
local varlist tipo_sanitario banio_con_ducha nbanios
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Sanitary: `x' - Regional (ENCOVI 2019/20)) replace
}

*Bathroom per people in household
gen banios_miembros = nbanios / miembros if !missing(nbanios, miembros)
estpost tabstat banios_miembros [fw=pondera_hh], by(region_est1) statistics(mean sd count) columns(statistics)
esttab using "$tables/banios_miembros_regional.csv", main(mean) aux(sd) label collabels("Mean") obs unstack ///
title(Bathroom per household members - Regional) replace

*Drinking Water
local varlist fagua_acueduc fagua_estanq fagua_cisterna fagua_bomba fagua_pozo fagua_manantial fagua_otro fagua_botella
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Drinking Water: `x' - Regional (ENCOVI 2019/20)) replace
}

*Water treatment 
local varlist tratamiento_agua tipo_tratamiento
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Water Treatment: `x' - Regional (ENCOVI 2019/20)) replace
}

*Payment for services
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Payment Services: `x' - Regional (ENCOVI 2019/20)) replace
}

*Payment for services
local varlist pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Payment Services Currency: `x' - Regional (ENCOVI 2019/20)) replace
}


*School servies
local varlist fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protestas nunca_deja_asistir
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera]
estpost tab region_est1 `x' [fw=pondera], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(School attendance: `x' - Regional (ENCOVI 2019/20)) replace
}


*Health
local varlist enfermo enfermedad
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera]
estpost tab region_est1 `x' [fw=pondera], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Health: `x' - Regional (ENCOVI 2019/20)) replace
}


/*=============================================================================
	03. Water and Sanitation: Income Quantiles
=============================================================================*/
tab ipcf_q

*Water
local varlist suministro_agua frecuencia_agua
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Water: `x' - Quintiles (ENCOVI 2019/20)) replace
}

*Sanitary
local varlist tipo_sanitario banio_con_ducha nbanios
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Sanitary: `x' - Quintiles (ENCOVI 2019/20)) replace
}

*Bathroom per people in household
estpost tabstat banios_miembros, by(ipcf_q) statistics(mean sd count) columns(statistics)
esttab using "$tables/banios_miembros_quintiles.csv", main(mean) aux(sd) label collabels("Mean") obs unstack ///
title(Bathroom per household members - Quintiles) replace

*Drinking Water
local varlist fagua_acueduc fagua_estanq fagua_cisterna fagua_bomba fagua_pozo fagua_manantial fagua_otro fagua_botella
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Drinking Water: `x' - Quintiles (ENCOVI 2019/20)) replace
}

*Water treatment 
local varlist tratamiento_agua tipo_tratamiento
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Water Treatment: `x' - Quintiles (ENCOVI 2019/20)) replace
}

*Payment for services
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Payment Services: `x' - Quintiles (ENCOVI 2019/20)) replace
}


*Payment for services
local varlist pagua_mon pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Payment Services Currency: `x' - Quintiles (ENCOVI 2019/20)) replace
}


*School servies
local varlist fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protestas nunca_deja_asistir
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera]
estpost tab ipcf_q `x' [fw=pondera], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(School attendance: `x' - Quintiles (ENCOVI 2019/20)) replace
}


*Health
local varlist enfermo enfermedad
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera]
estpost tab ipcf_q `x' [fw=pondera], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Health: `x' - Quintiles (ENCOVI 2019/20)) replace
}




/*=============================================================================
	04. Spending on Services analysis
=============================================================================*/

*Values from winsored dataset are also wrong...

*Water
*estpost tabstat gasto_men_pc_winsored if bien==911 [fw=pondera_hh], statistics(count mean sd min max p5 p50 p95) columns(statistics)
*esttab using "$tables/Water_winsored_distr.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p5 p50 p95") label ///
*collabels("N" "Mean" "SD" "Min" "Max" "p5" "Median" "p95") unstack ///
*title(Monthly spending in water services (per capita)) replace nonum noobs

*Electricity
*estpost tabstat gasto_men_pc_winsored if bien==912 [fw=pondera_hh], statistics(count mean sd min max p5 p50 p95) columns(statistics)
*esttab using "$tables/Water_winsored_distr.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p5 p50 p95") label ///
*collabels("N" "Mean" "SD" "Min" "Max" "p5" "Median" "p95") unstack ///
*title(Monthly spending in electricity services (per capita)) append nonum noobs


********************************************************************************
*Clean data

local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
hist `x'_monto
graph export "$figures/histogram_`x'_monto.png", replace 
}

*Check for outliers (all in dollar)
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
estpost tabstat `x'_monto_dollars, statistics(count mean sd min max p1 p5 p50 p95 p99) columns(statistics)
esttab using "$tables/outliers.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p1 p5 p50 p95 p99") label ///
collabels("N" "Mean" "SD" "Min" "Max" "p1" "p5" "Median" "p95" "p99") unstack ///
title(Monthly spending in `x') append nonum noobs
}


*Check for outliers (all in bol)
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
estpost tabstat `x'_monto_bol, statistics(count mean sd min max p1 p5 p50 p95 p99) columns(statistics)
esttab using "$tables/outliers2.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p1 p5 p50 p95 p99") label ///
collabels("N" "Mean" "SD" "Min" "Max" "p1" "p5" "Median" "p95" "p99") unstack ///
title(Monthly spending in `x') append nonum noobs
}


*Check for outliers (currency by currency)

use "$rawdata\ENCOVI_2019_English labels.dta", clear

*Bolivares
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
estpost tabstat `x'_monto if `x'_mon==1, statistics(count mean sd min max p1 p5 p50 p95 p99) columns(statistics)
esttab using "$tables/outliers_bol.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p1 p5 p50 p95 p99") label ///
collabels("N" "Mean" "SD" "Min" "Max" "p1" "p5" "Median" "p95" "p99") unstack ///
title(Monthly spending in `x'_bol) append nonum noobs
}

*Dollars
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
estpost tabstat `x'_monto if `x'_mon==2, statistics(count mean sd min max p1 p5 p50 p95 p99) columns(statistics)
esttab using "$tables/outliers_dollars.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p1 p5 p50 p95 p99") label ///
collabels("N" "Mean" "SD" "Min" "Max" "p1" "p5" "Median" "p95" "p99") unstack ///
title(Monthly spending in `x'_dollars) append nonum noobs
}

*Euros
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
estpost tabstat `x'_monto if `x'_mon==3, statistics(count mean sd min max p1 p5 p50 p95 p99) columns(statistics)
esttab using "$tables/outliers_euros.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p1 p5 p50 p95 p99") label ///
collabels("N" "Mean" "SD" "Min" "Max" "p1" "p5" "Median" "p95" "p99") unstack ///
title(Monthly spending in `x'_euros) append nonum noobs
}

*Pesos
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
estpost tabstat `x'_monto if `x'_mon==4, statistics(count mean sd min max p1 p5 p50 p95 p99) columns(statistics)
esttab using "$tables/outliers_pesos.csv", cells("count(fmt(a1)) mean sd(fmt(a1)) min max(fmt(a1)) p1 p5 p50 p95 p99") label ///
collabels("N" "Mean" "SD" "Min" "Max" "p1" "p5" "Median" "p95" "p99") unstack ///
title(Monthly spending in `x'_pesos) append nonum noobs
}


*Drop high values
tab pagua_monto_dollars
drop if pagua_monto_dollars>1000 &!missing(pagua_monto_dollars) 
tab pelect_monto_dollars
drop if pelect_monto_dollars>200 &!missing(pelect_monto_dollars) 
tab pgas_monto_dollars
drop if pgas_monto_dollars>400 &!missing(pgas_monto_dollars) 
tab pcarbon_monto_dollarsf
tab pparafina_monto_dollars
tab ptelefono_monto_dollars
drop if ptelefono_monto_dollars>500 &!missing(ptelefono_monto_dollars) 

label var pagua_monto_dollars "Spending in Water Services in US$"
label var pelect_monto_dollars "Spending in Electricity in US$"
label var pgas_monto_dollars "Spending in natural gas in US$"
label var pcarbon_monto_dollars "Spending in carbon in US$"
label var pparafina_monto_dollars "Spending in parrafin in US$"
label var ptelefono_monto_dollars "Spending in phones in US$"


*Payment for services - amounts
*local varlist pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto
*foreach x in `varlist'{
*tab `x' [fw=pondera_hh]
*estpost tab `x' [fw=pondera_hh], label
*esttab using "$tables/`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
*title(Payment Services `x' - National (ENCOVI 2019/20)) replace
*}

*Payment for services - amounts summary
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x'_monto_dollars [fw=pondera_hh]
estpost tabstat `x'_monto_dollars [fw=pondera_hh], statistics(mean sd p50 count) columns(statistics)
esttab using "$tables/`x'_sumstat.csv", cells("mean sd p50 count") label collabels("Mean" "Standard Dev." "Median" "N") obs unstack ///
title(Payment Services `x'_monto_dollars - National (ENCOVI 2019/20)) replace
}

********************************************************************************
*Regional

*Payment for services - amounts /// does not work as too many values
*local varlist pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto
*foreach x in `varlist'{
*tab region_est1 `x' [fw=pondera]
*estpost tab region_est1 `x' [fw=pondera], label
*esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
*title(Payment Services Currency: `x' - Regional (ENCOVI 2019/20)) replace
*}

*Payment for services - amounts summary
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x'_monto_dollars [fw=pondera_hh]
estpost tabstat `x'_monto_dollars [fw=pondera_hh], by(region_est1) statistics(mean sd p50 count) columns(statistics)
esttab using "$tables/`x'_sumstat.csv", cells("mean sd p50 count") label collabels("Mean" "Standard Dev." "Median" "N") obs unstack ///
title(Payment Services `x'_monto_dollars - National (ENCOVI 2019/20)) replace ///
varlabels(`e(labels)') eqlabels(`e(eqlabels)')
}


********************************************************************************
*Quintiles

*Payment for services - amount /// too many values
*local varlist pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto
*foreach x in `varlist'{
*tab ipcf_q `x' [fw=pondera]
*estpost tab ipcf_q `x' [fw=pondera], label
*esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
*title(Payment Services: `x' - Quintiles (ENCOVI 2019/20)) replace
*}

*Payment for services - amount summary
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x'_monto_dollars [fw=pondera_hh]
estpost tabstat `x'_monto_dollars [fw=pondera_hh], by(ipcf_q) statistics(mean sd p50 count) columns(statistics)
esttab using "$tables/`x'_sumstat.csv", cells("mean sd p50 count") label collabels("Mean" "Standard Dev." "Median" "N") obs unstack ///
title(Payment Services `x' - National (ENCOVI 2019/20)) replace ///
varlabels(`e(labels)') eqlabels(`e(eqlabels)')
}






/*=============================================================================
	05. Spending on Services per capita analysis
=============================================================================*/

local varlist pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto
foreach x in `varlist'{
	gen `x'_pc = `x' / miembros if !missing(`x', miembros)
}


********************************************************************************
*National


*Payment for services - amounts
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x'_monto_dollars [fw=pondera]
estpost tab `x'_monto_dollars [fw=pondera_hh], label
esttab using "$tables/`x'.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Payment Services `x' - National (ENCOVI 2019/20)) replace
}

********************************************************************************
*Regional
local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x' [fw=pondera]
estpost tabstat `x'_monto_dollars [fw=pondera_hh], by(region_est1) statistics(mean sd count) columns(statistics)
esttab using "$tables/`x'_regional_sumstat.csv", cells("mean sd count") label collabels("Mean" "Standard Dev." "N") obs unstack ///
title(Payment Services `x'_monto_dollars - National (ENCOVI 2019/20)) replace ///
varlabels(`e(labels)') eqlabels(`e(eqlabels)')
}

********************************************************************************
*Quintiles

local varlist pagua pelect pgas pcarbon pparafina ptelefono
foreach x in `varlist'{
tab `x' [fw=pondera]
estpost tabstat `x'_monto_dollars [fw=pondera_hh], by(ipcf_q) statistics(mean sd count) columns(statistics)
esttab using "$tables/`x'_quintiles_sumstat.csv", cells("mean sd count") label collabels("Mean" "Standard Dev." "N") obs unstack ///
title(Payment Services `x'_monto_dollars - National (ENCOVI 2019/20)) replace ///
varlabels(`e(labels)') eqlabels(`e(eqlabels)')
}




/*=============================================================================
	06. Indicators from SEDLAC Database
=============================================================================*/

use "$rawdata\VEN_2019_ENCOVI_SEDLAC-01_English labels.dta", clear

*These questions are only responded by hh head so use hh weights

*Quintiles
xtile ipcf_q = ipcf [fw=pondera], nquantiles(5)
label var ipcf_q "Income quintiles per capita household income"

label define quintiles 1 "Poorest quintile" 5 "Richest quintile"
label values ipcf_q quintiles

*Generate indicator for lack of access to public services
gen deficit_publicservices = (agua==0 | elect==0 | cloacas==0) if !missing(agua, elect, cloacas)
tab deficit_publicservices, m

label define deficit_publicservices 1 "Lack of access to one of water or electricity or sewages" 0 "No deficit"
label val deficit_publicservices deficit_publicservices

*National: Access to Water, sewages, electricity and public services in general

local varlist agua cloacas elect deficit_publicservices
foreach x in `varlist'{
tab `x' [fw=pondera_hh]
estpost tab `x' [fw=pondera_hh], label
esttab using "$tables/`x'_nacional.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') ///
title(Access to services `x' - National (ENCOVI SEDLAC 2019/20)) replace
}


*Regional

local varlist agua cloacas elect deficit_publicservices
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Access to services `x' - Regional (ENCOVI 2019/20)) replace
}


*Quintiles

local varlist agua cloacas elect deficit_publicservices
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintile.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Access to services `x' - Quintile (ENCOVI 2019/20)) replace
}















