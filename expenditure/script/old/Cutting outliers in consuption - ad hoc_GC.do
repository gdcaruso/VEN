
*Open the data
*use "C:\Users\WB339789\OneDrive - WBG\Ven PA\ENCOVI_2019_English labels.dta", clear
use "C:\Users\WB339789\OneDrive - WBG\Ven PA\ENCOVI_2019_Spanish labels.dta", clear


*Replace outliers after P95
	*Food
	summ gpcf_food , detail
	gen gpcf_food_p95=gpcf_food
	replace gpcf_food_p95=r(p95) if gpcf_food>r(p95) 

	*Non-Food
	summ gpcf_housing , detail
	gen gpcf_housing_p95=gpcf_housing
	replace gpcf_housing_p95=r(p95) if gpcf_housing>r(p95) 

	summ gpcf_other , detail
	gen gpcf_other_p95=gpcf_other
	replace gpcf_other_p95=r(p95) if gpcf_other>r(p95) 

	gen gpcf_nonfood_p95 = gpcf_housing_p95 + gpcf_other_p95

	*Total Exp
	gen gpcf_p95= gpcf_nonfood_p95 + gpcf_food_p95

*Drop old variables and rename
	drop gpcf- share_other

	foreach v in gpcf_food gpcf_housing gpcf_other gpcf_nonfood gpcf{ 
	rename `v'_p95 `v'
	}


*Save changes
compress
*save "C:\Users\WB339789\OneDrive - WBG\Ven PA\ENCOVI_2019_English labels.dta", replace
save "C:\Users\WB339789\OneDrive - WBG\Ven PA\ENCOVI_2019_Spanish labels.dta", replace
