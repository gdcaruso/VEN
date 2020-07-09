/*===========================================================================
Country name:	Venezuela
Year:			2019/2020
Survey:			ENCOVI
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		June, 2020
Modification Date:  
Output:				Databases with both English and Spanish labels
Note: 
=============================================================================*/
********************************************************************************
version 14
drop _all
set more off

******************************
****  ALL OF ENCOVI 2019  ****
******************************

use "$outENCOVI\ENCOVI_2019_Spanish labels.dta"

label language es, rename

label language es
label language en, new copy
do "$pathaux\labels ENCOVI english.do"

save "$outENCOVI\ENCOVI_2019.dta", replace

clear 

*************************
****   ONLY SEDLAC   ****
*************************

foreach i in 2014 2015 2016 2017 2018 2019 {
	
	use "$outSEDLAC\VEN_`i'_ENCOVI_SEDLAC-01_English labels.dta"
	label language en, rename

	label language en
	label language es, new copy
	do "$pathaux\labels SEDLAC spanish.do"

	save "$outSEDLAC\VEN_`i'_ENCOVI_SEDLAC-01.dta"

clear
}
