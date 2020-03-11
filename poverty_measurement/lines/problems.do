global root "C:\Users\wb563365\Desktop\ENCOVI-2019"


use "$root\poverty_measurement\input\lowcalcheck.dta", replace

merge 1:m interview__key interview__id quest using "$root\poverty_measurement\input\baskets_with_nutritional_intakes.dta"
keep if _merge==3
drop _merge
merge m:1 interview__key interview__id quest using "$root\data_management\output\merged\household.dta"
keep if _merge==3
drop _merge

sort cal_intake_pce
keep interview__key interview__id quest cal_intake cal_intake_pce bien consumio cantidad unidad_medida tamano cantidad_h Energia_kcal_m s3q4 s4q1 s4q2 s4q3 s4q4 s5q4a s5q6__1 s5q6__2 s5q6__3 s5q6__4 s5q6__5 s12aq10
