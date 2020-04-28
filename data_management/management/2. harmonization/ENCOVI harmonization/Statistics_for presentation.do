/*===========================================================================
Country name:		Venezuela
Year:			2019
Survey:			ECNFT
Vintage:		01M-01A
Project:	
---------------------------------------------------------------------------
Authors:			Malena Acuña, Trinidad Saavedra

Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			sedlac do-file template

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   1
		
		* User 3: Lautaro
		global lauta  0
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global roothpath2 "C:\Users\wb563583\GitHub\VEN" 
				global pathdo "C:\Users\wb563583\GitHub\VEN\data_management\management\2. harmonization\ENCOVI harmonization"
		}
	    if $lauta {
				global rootpath ""
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
				global roothpath2 "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
				global pathdo "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\dofiles\ENCOVI harmonization"
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN"
		}

program drop _all
clear all
set mem 300m
clear matrix
clear mata
capture log close
set matsize 11000
set more off
*** Add ados
adopath ++ "C:\Program Files (x86)\Stata15\plus"
		
// Set output data path
global data1418 "$rootpath2\data_management\output\cleaned"
global data19 "$rootpath\Databases ENCOVI 2019"

qui: do "$pathdo\tabby.do" //run the program
* povby(weight all byvar year nmatrix)

********************************************************************************
*** Opening databases
********************************************************************************
forv i=2014/2018{
use "$data1418\ENCOVI_`i'_COMP.dta", clear
tostring id, replace
tostring psu, replace
save, replace
}

use "$data19\ENCOVI_2019_English labels.dta", clear
forv i=2014/2018{
append using "$pathout\ENCOVI_`i'_COMP.dta"
}
sort ano id com

gen weight=pondera if ano!=2019
replace weight=1 if ano==2019
gen all=1
clonevar year=ano

********************************************************************************
*** Distribution of the population by sex and age
********************************************************************************
clonevar age=edad
gen female=hombre==0
putexcel set "$pathdo\Statistics_for presentation.xlsx", sheet("age_sex_dist") modify 
gen age_range=1 if age<=4
replace age_range=2 if age>=5 & age<=9
replace age_range=3 if age>=10 & age<=14
replace age_range=4 if age>=15 & age<=19
replace age_range=5 if age>=20 & age<=24
replace age_range=6 if age>=25 & age<=29
replace age_range=7 if age>=30 & age<=34
replace age_range=8 if age>=35 & age<=39
replace age_range=9 if age>=40 & age<=44
replace age_range=10 if age>=45 & age<=49
replace age_range=11 if age>=50 & age<=54
replace age_range=12 if age>=55 & age<=59
replace age_range=13 if age>=60 & age<=64
replace age_range=14 if age>=65 & age<=69
replace age_range=15 if age>=70 & age<=74
replace age_range=16 if age>=75
label define age_range 1 "[0-4]" 2 "[5-9]" 3 "[10-14]" 4 "[15-19]" 5 "[20-24]" 6 "[25-29]" 7 "[30-34]" ///
8 "[35-39]" 9 "[40-44]" 10 "[45-49]" 11 "[50-54]" 12 "[55-59]" 13 "[60-64]" 14 "[65-69]" 15 "[70-74]" ///
16 "[75+]"
label value age_range age_range

*levelsof age_range, local(age_range)
tab age_range female [aw=weight] if year==2019, matcell(pop)
mata: st_matrix("totpop", rowsum(colsum(st_matrix("pop"))))
mata: st_matrix("totpop_perc", ((st_matrix("pop") :/ st_matrix("totpop"))*100))
matrix age_dist=(totpop_perc)
matrix colnames age_dist="Male" "Female" 
matrix list age_dist
putexcel A1= "Distribution of the population by age and sex"
putexcel B2=matrix(age_dist), colnames

********************************************************************************
*** Demographics
********************************************************************************
putexcel set "$pathdo\Statistics_for presentation.xlsx", sheet("Demographics") modify 
* Age group
gen agegroup=1 if age<=14
replace agegroup=2 if age>=15 & age<=24
replace agegroup=3 if age>=25 & age<=34
replace agegroup=4 if age>=35 & age<=44
replace agegroup=5 if age>=45 & age<=54
replace agegroup=6 if age>=55 & age<=64
replace agegroup=7 if age>=65 
label def agegroup 1 "[0-14]" 2 "[15-24]" 3 "[25-34]" 4 "[35-44]" 5 "[45-54]" 6 "[55-64]" 7 "[65+]"
label value agegroup agegroup
* Number of children, adults, elders
bysort year id: egen nchildren14=sum(age<=14)
bysort year id: egen nchildren18=sum(age<=18)
bysort year id: egen nadults15=sum(age>=15)
bysort year id: egen nadults16=sum(age>=16)
bysort year id: egen nadults_15_64=sum(age>=15 & age<=64) //working age adults
bysort year id: egen nelders65=sum(age>=65)

* Household size
* Miembros de hogares secundarios (seleccionando personal doméstico): hogarsec 
capture drop hogarsec
gen hogarsec =.
replace hogarsec =1 if relacion_comp==12
replace hogarsec =0 if inrange(relacion_comp, 1,11)

* Numero de miembros del hogar (de la familia principal): miembros 
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno') if hogarsec==0 & relacion_comp!=., by(year id)

clonevar hhsize=miembros
replace hhsize=7 if miembros>=7
label def hhsize 7 "7+", add

sum year 
local ti=r(min)
local tf=r(max)
levelsof year, local(year)
local row=1
local n1 "sex"
local n2 "age group"
local n3 "marital status"
local n4 "household size"
local n5 "household size"
local i=1
foreach x in hombre agegroup estado_civil miembros hhsize{
tabby weight all `x' year demo 
putexcel A`row'="Distribution of the population by `n`i'', years `ti'-`tf'"
local row=`row'+2
putexcel B`row'=matrix(demo), colnames
local row=`row'+rowsof(demo)+2
matrix drop demo
local i=`i'+1
}

tab year
local ny=r(r)
tabstat nchildren14 nadults_15_64 nadults15 nelders65 hhsize [aw=weight] if relacion_comp==1, by(year) stat(mean) save
forv i=1/`ny'{
matrix nn=nullmat(nn)\r(Stat`i')
}
matrix nn=nn'
matrix colnames nn=`year'
matrix rownames nn="Children" "Adults (15-64)" "Adults 15+" "Elderly 65+" "Household size" 
matrix list nn
putexcel A`row'="Number of children, adults, elders, adults equivalents, and hhsize, years (%) `ti'-`tf'"
local row=`row'+2
putexcel A`row'=matrix(nn), names
local row=`row'+rowsof(nn)+3
matrix drop nn

********************************************************************************
*** Dwelling and durables
********************************************************************************
putexcel set "$pathdo\Statistics_for presentation.xlsx", sheet("Dwelling and Durables") modify 

sum year 
local ti=r(min)
local tf=r(max)
levelsof year, local(year)
local row=1
local n1 "type of flooring material"
local n2 "type of exterior wall material"
local n3 "type of roofing material"
local n4 "type of dwelling"
local n5 "water supply"
local n6 "electricity"
local n7 "type of toilet"
local n8 "housing tenure"

local i=1
foreach x in material_piso material_pared_exterior material_techo tipo_vivienda suministro_agua_comp electricidad tipo_sanitario_comp tenencia_vivienda_comp{
tabby weight all `x' year dwell 
putexcel A`row'="Distribution of households by `n`i'', years `ti'-`tf'"
local row=`row'+2
putexcel B`row'=matrix(dwell), colnames
local row=`row'+rowsof(dwell)+2
matrix drop dwell
local i=`i'+1
}

tab year
local ny=r(r)
gen ncarros2=ncarros/100
local durables auto ncarros2 heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas telefono_fijo
tabstat `durables' [aw=weight] if relacion_comp==1, by(year) stat(mean) save
forv i=1/`ny'{
matrix nn=nullmat(nn)\r(Stat`i')*100
}
matrix nn=nn'
matrix colnames nn=`year'
matrix rownames nn="Auto" "Numero de carros" "Heladera" "Lavarropas" "Secadora" "Computadora" "Internet" "Televisor" "Radio" "Calentador" "Aire" " TV cable" "Microondas" "Telefono fijo"
matrix list nn
putexcel A`row'="Percentage of households holding durable goods, years (%) `ti'-`tf'"
local row=`row'+2
putexcel A`row'=matrix(nn), names
local row=`row'+rowsof(nn)+3
matrix drop nn

********************************************************************************
*** Education
********************************************************************************
putexcel set "$pathdo\Statistics_for presentation.xlsx", sheet("Education") modify 
gen nivel_educ_head=nivel_educ if relacion_comp==1

sum year 
local ti=r(min)
local tf=r(max)
levelsof year, local(year)
local row=1
local n1 "attendance"
local n2 "educational attainment (3+)"
local n3 "educational attainment of the head"
local n4 "reasons for stop attending"

local i=1
foreach x in asiste nivel_educ nivel_educ_head razon_dejo_est_comp{
tabby weight all `x' year educ 
putexcel A`row'="Distribution of the population by `n`i'', years `ti'-`tf'"
local row=`row'+2
putexcel B`row'=matrix(educ), colnames
local row=`row'+rowsof(educ)+2
matrix drop educ
local i=`i'+1
}

tab year
local ny=r(r)
local fallas asiste fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir
tabstat `fallas' [aw=weight], by(year) stat(mean) save
forv i=1/`ny'{
matrix nn=nullmat(nn)\r(Stat`i')*100
}
matrix nn=nn'
matrix colnames nn=`year'
*matrix rownames nn="Auto" "Numero de carros" "Heladera" "Lavarropas" "Secadora" "Computadora" "Internet" "Televisor" "Radio" "Calentador" "Aire" " TV cable" "Microondas" "Telefono fijo"
matrix list nn
putexcel A`row'="Percentage of students reporting they stop attending the educational center where they regularly study due to the following failures , years (%) `ti'-`tf'"
local row=`row'+2
putexcel A`row'=matrix(nn), names
local row=`row'+rowsof(nn)+3
matrix drop nn

********************************************************************************
*** Banking
********************************************************************************
putexcel set "$pathdo\Statistics_for presentation.xlsx", sheet("Banking") modify 

sum year 
local ti=r(min)
local tf=r(max)
levelsof year, local(year)
local row=1
local n1 "cash"
local n2 "credit card"
local n3 "debit card"
local n4 "using online bank"
local n4 "reason for not having bank account or credit card"

tab year
local ny=r(r)
local cuenta cuenta_corr cuenta_aho tcredito tdebito no_banco
tabstat `cuenta' [aw=weight], by(year) stat(mean) save
forv i=1/`ny'{
matrix nn=nullmat(nn)\r(Stat`i')*100
}
matrix nn=nn'
matrix colnames nn=`year'
matrix rownames nn= "Cuenta corriente" "Cuenta de ahorro" "Tarjeta de credito" "Tarjeta de debito" "No tiene cuenta o tarjeta"
matrix list nn
putexcel A`row'="Do you have in any bank the following?, years (%) `ti'-`tf'"
local row=`row'+2
putexcel A`row'=matrix(nn), names
local row=`row'+rowsof(nn)+3
matrix drop nn
;
local i=1
foreach x in razon_nobanco{
tabby weight all `x' year bank 
matrix rownames bank= "La sucursal queda lejos" "Las comisiones son altas" "No confía en los bancos" "Piden requisitos que no tiene" "Insuficientes ingresos para tener cuenta" ///
                      "Prefiere otras formas de guardar el dinero" "No necesita" "Otra" "Total"
putexcel A`row'="Reasons for not having bank account or credit card, years `ti'-`tf'"
local row=`row'+2
putexcel A`row'=matrix(bank), names
local row=`row'+rowsof(bank)+2
matrix drop bank
local i=`i'+1
}

local i=1
foreach x in efectivo_f tcredito_f tdebito_f bancao_f pagomovil_f{
tabby weight all `x' year bank 
matrix rownames bank= "Frecuentemente" "A veces" "Casi nunca" "Nunca" "Total"
putexcel A`row'="How often do you pay with `n`i'', years `ti'-`tf'"
local row=`row'+2
putexcel A`row'=matrix(bank), names
local row=`row'+rowsof(bank)+2
matrix drop bank
local i=`i'+1
}


