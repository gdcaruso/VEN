/*===========================================================================
Country name:	Venezuela
Year:			2021
Survey:			ENCOVI 2014 - ENCOVI 2019/20

---------------------------------------------------------------------------
Authors:			Britta Rude/ Monica Robayo
Dependencies:		The World Bank
Creation Date:		January, 2021
Modification Date:  
Description: 		This do-file generates input for the different sections of the RPBA Venezuela 
Output:			    Child Labor over time   


=============================================================================*/
********************************************************************************
*Paths

* User 1: Monica 
global monica 0

*User 2: Britta
global britta 1

if $britta {
				global rootpath "F:\WB\ENCOVI"
				global rawdata "$rootpath\ENCOVI Data\ENCOVI SEDLAC" 
				global exrate "$rootpath\Additional Data\exchenge_rate_price.dta"
				global exchange "F:\Working with Github\WB\VEN\data_management\management\1. merging\exchange rates"
				global figures "F:\Working with Github\WB\VEN\RPVA Feb 2021\Growth Incidence Curve\Output\Graphs"
		}
	    if $monica {
				global rootpath ""
		}

		
********************************************************************************
*Upload data

use "$rawdata\VEN_2014_ENCOVI_SEDLAC-01_English labels.dta", clear
destring id, replace
append using "$rawdata\VEN_2015_ENCOVI_SEDLAC-01_English labels.dta"
append using "$rawdata\VEN_2016_ENCOVI_SEDLAC-01_English labels.dta"
append using "$rawdata\VEN_2017_ENCOVI_SEDLAC-01_English labels.dta"
append using "$rawdata\VEN_2018_ENCOVI_SEDLAC-01_English labels.dta"
tostring id, replace
tostring psu, replace
append using "$rawdata\VEN_2019_ENCOVI_SEDLAC-01_English labels.dta"

gen year=ano

********************************************************************************
*Child labor over time 

tab year ocupado [fw=pondera] if edad>=5 & edad<16, row		
		
		
		
		
		
		
		
		