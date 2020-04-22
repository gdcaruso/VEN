*******************************************************************************
*** Description
********************************************************************************
* This program delivers a matrix with the poverty rates, the distribution of the poor and non-poor, the distribution of the bottom 40 and top 60, 
* and the distribution of the population by a given socio-demographic variable (for instance, educational attainment) and different years.
 
********************************************************************************
*** Inputs for the program
********************************************************************************
* The user should provide the following information
* povby (path name country group year country_names priority_area pa1 pa2 pa3 pa4 pa5)
*
*  Inputs
* pov: variable identifying individual poverty status 1=poor, 0=non-poor
* b40: variable identifying whether an individual belong to the b40 of the welfare distribution, 1=b40, 0=t60
* all: variable indentifying all population of interest
* byvar: socio-demographic variable by the poverty rate, distribution of poor, non-poor, b40, and t60 are going to be calculated
* year: variable identifying the years
* nmatrix: name of the output matrix
* weight: variable identifying population weights
********************************************************************************
pr def tabby
	args weight /*pov b40*/ all byvar year nmatrix 
	set more off
	set matsize 11000


levelsof `year', local(nyear)

/*
foreach y in `nyear'{
estpost tabstat `pov' [aw=weight] if year==`y', by(`byvar') 
matrix hhs=nullmat(hhs),e(mean)'*100
}
matrix colnames hhs=`nyear'
*matrix list hhs
*/
/*
tab `byvar' year [iw=`weight'] if `pov'==1, matcell(poor)
tab `byvar' year [iw=`weight'] if `pov'==0, matcell(npoor)
tab `byvar' year [iw=`weight'] if `b40'==1, matcell(b40)
tab `byvar' year [iw=`weight'] if `b40'==0, matcell(t60)
*/
tab `byvar' year [iw=`weight'] if `all'==1, matcell(pop)
/*
mata: st_matrix("totpoor", colsum(st_matrix("poor")))
mata: st_matrix("totnpoor", colsum(st_matrix("npoor")))
mata: st_matrix("totb40", colsum(st_matrix("b40")))
mata: st_matrix("tott60", colsum(st_matrix("t60")))
*/
mata: st_matrix("totpop", colsum(st_matrix("pop")))
/*
mata: st_matrix("poor_perc", ((st_matrix("poor") :/ st_matrix("totpoor"))*100))
mata: st_matrix("npoor_perc", ((st_matrix("npoor") :/ st_matrix("totnpoor"))*100))
mata: st_matrix("b40_perc", ((st_matrix("b40") :/ st_matrix("totb40"))*100))
mata: st_matrix("t60_perc", ((st_matrix("t60") :/ st_matrix("tott60"))*100))
*/
mata: st_matrix("pop_perc", ((st_matrix("pop") :/ st_matrix("totpop"))*100))
/*
matrix colnames poor_perc=`nyear'
matrix colnames npoor_perc=`nyear'
matrix colnames b40_perc=`nyear'
matrix colnames t60_perc=`nyear'
*/
matrix colnames pop_perc=`nyear'
matrix dist1=/*poor_perc,npoor_perc,b40_perc,t60_perc,*/pop_perc
mata: st_matrix("dist2", colsum(st_matrix("dist1")))
matrix dist=dist1\dist2
*matrix list dist
matrix `nmatrix'=(/*hhs,*/dist)
matrix list `nmatrix'
matrix drop /*hhs*/ dist 
end
