/*=================================================================================
			   MASTER DO-FILE
Project:       Poverty Map Venezuela: Fay-Herriot Small area estimation  
Author:        Britta Rude
Output: 	   Poverty Map Venezuela at the municipality level 
---------------------------------------------------------------------------
Creation Date:      Feb, 2021
Description: 		Make sure you fill out all the globals with folders.
					Folder Secondary needs to have at least 40GB of storage space.
					It can be the same as dataout if it has enough space.
Modification Date:  
==================================================================================

==================================================================================
*Install packages
==================================================================================*/

ssc install fayherriot ///Runs on a dataset at the domain level with one observation for each domain
ssc inst _gwtmean //weighted mean

*==================================================================================*/

clear all
set more off
 
*Set-up

* User 1: Monica (World Bank)
global monica 0

*User 2: Britta (Personal Computer)
global britta 1

if $britta {
				global rootpath "F:\WB\ENCOVI" //have to take data from non-github as too large 
				global rawdata "$rootpath\ENCOVI Data" //have to take data from non-github as too large 
				global exrate "$rootpath\Additional Data\exchenge_rate_price.dta"
				global census "F:\WB\Poverty Map\venezuela_povertymap(2)\census2011" //have to take data from non-github as too large 
				global secondary "F:\WB\Poverty Map\venezuela_povertymap(2)\secondary" //have to take data from non-github as too large 
				global dataout "F:\Working with Github\WB\VEN\Poverty Map\Fay_Herriot_estimation\dataout"
				global dataout_census "F:\WB\Poverty Map\Fay_Herriot_VEN\dataout" //have to take data from non-github as too large 
				global results "F:\Working with Github\WB\VEN\Poverty Map\Fay_Herriot_estimation\Results"
				global tables "$results\Tables"
				global figures "$results\Figures"
				global population "F:\Working with Github\WB\VEN\Poverty Map\Fay_Herriot_estimation\WorldPop\"
				
				global povmap "F:\WB\Poverty Map\venezuela_povertymap(2)"

		}
	    if $monica {
				global rootpath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global rawdata "$rootpath\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018"
				global census ""
				global dataout ""
				global results ""
				global tables ""
				global figures ""
				global input "$rootpath\Databases ENCOVI 2019"
				global exrate "$input\data_management\input\exchenge_rate_price.dta"
				
				global povmap ""

		}


global censusdb "census_sample"

* Builds Census data samples. Choose sample size in do-file (line 17)
do "${root}\dofiles_Britta\01.build_census.do" //(From Mateo Uribe-Castro and POVMAP (SAE) - 2020)

* Process Census data: At municipality level 
do "${root}\dofiles_Britta\02.process_census.do"

* Process Survey Data
do "${root}/dofiles/03.process_survey.do"

* Estimate Fay-Herriot model at municipality level using only Census 2011 data 
do "${root}/dofiles/04.fay_herriot_estimation_census2011.do"

* Graph maps
do "${root}/dofiles/05.maps_census.do"
