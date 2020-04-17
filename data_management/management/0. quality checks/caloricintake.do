use "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\poverty_measurement\output\VEN_2019_ENCOVI_v01_M_v01_A_FULL-03_all.dta" , replace

gen extremo = ipcf<(lp_extrema*0.5)

collapse (max) extremo (max) miembros (max) ipcf, by (interview__id interview__key quest)

merge 1:1 interview__id interview__key quest using "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\poverty_measurement\output\pob_cal_intake.dta"

gen few_calories = 0 if overcal ==1
replace few_calories = 1 if overcal ==0
tab extremo few_calories [fw=miembros]
