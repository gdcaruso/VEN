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
	01. Energy
=============================================================================*/

label define comb_cocina 1 "Gas directo" 2 "Gas por bombona" 3 "Electricidad" 4 "Lenja" 5 "Otros" 6 "No cocina"
label val comb_cocina comb_cocina 

*Nacional
local varlist serv_elect_red_pub serv_elect_planta_priv serv_elect_otro serv_elect_otro_esp electricidad interrumpe_elect comb_cocina pelect danio_electrodom 
foreach x in `varlist'{
estpost tab `x' [fw=pondera_hh], label
esttab using "$tables/`x'_national.csv", cells("b pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Energy:`x' - National (ENCOVI 2019/20)) replace
}

*By region
local varlist serv_elect_red_pub serv_elect_planta_priv serv_elect_otro serv_elect_otro_esp electricidad interrumpe_elect comb_cocina pelect danio_electrodom 
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera_hh]
estpost tab region_est1 `x' [fw=pondera_hh], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Energy: `x' - Regional (ENCOVI 2019/20)) replace
}

*By income quintile
local varlist serv_elect_red_pub serv_elect_planta_priv serv_elect_otro serv_elect_otro_esp electricidad interrumpe_elect comb_cocina pelect danio_electrodom 
foreach x in `varlist'{
tab ipcf_q `x' [fw=pondera_hh]
estpost tab ipcf_q `x' [fw=pondera_hh], label
esttab using "$tables/`x'_quintiles.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Energy: `x' - Quintiles (ENCOVI 2019/20)) replace
}






