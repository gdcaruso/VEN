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
	01. Agriculture - National
=============================================================================*/

local varlist ingsuf_comida preocucomida_norecursos faltacomida_norecursos nosaludable_norecursos pocovariado_norecursos salteacomida_norecursos comepoco_norecursos hambre_norecursos nocomedia_norecursos pocovariado_me18_norecursos salteacomida_me18_norecursos comepoco_me18_norecursos comida_trueque
foreach x in `varlist'{

label define `x'_lab 0 "No" 1 "Yes"
label val `x' `x'_lab

}

*Food security variables
local varlist ingsuf_comida preocucomida_norecursos faltacomida_norecursos nosaludable_norecursos pocovariado_norecursos salteacomida_norecursos comepoco_norecursos hambre_norecursos nocomedia_norecursos pocovariado_me18_norecursos salteacomida_me18_norecursos comepoco_me18_norecursos comida_trueque
foreach x in `varlist'{
estpost tab `x' [fw=pondera], label
esttab using "$tables/`x'_national.csv", cells("b(fmt(a1)) pct") collabels("Frequency" "Percent") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Food security:`x' - National (ENCOVI 2019/20)) replace 
}


/*=============================================================================
	02. Agriculture - Regional
=============================================================================*/

local varlist ingsuf_comida preocucomida_norecursos faltacomida_norecursos nosaludable_norecursos pocovariado_norecursos salteacomida_norecursos comepoco_norecursos hambre_norecursos nocomedia_norecursos pocovariado_me18_norecursos salteacomida_me18_norecursos comepoco_me18_norecursos comida_trueque
foreach x in `varlist'{
tab region_est1 `x' [fw=pondera]
estpost tab region_est1 `x' [fw=pondera], label
esttab using "$tables/`x'_regional.csv", cells("b") collabels("`x'") label unstack varlabels(`e(labels)') eqlabels(`e(eqlabels)') ///
title(Food Security: `x' - Regional (ENCOVI 2019/20)) replace
}










