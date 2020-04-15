//// this do tries to detect why are outliars income before imputing

use "C:\Users\wb563365\GitHub\VEN\data_management\management\0. quality checks\outliars_for_imputation\ENCOVI_forimputation_2019.dta", replace

keep if dila_m_out == 1 | djubpen_out == 1
keep interview__key interview__id quest com i* djubpen_out dila_m_out


tempfile outliars
save `outliars'

use "C:\Users\wb563365\GitHub\VEN\data_management\output\cleaned\individualconid.dta", replace
merge 1:1 interview__key interview__id quest com using `outliars'
