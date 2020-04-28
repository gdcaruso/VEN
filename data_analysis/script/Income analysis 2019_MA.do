*INCOME ANALYSIS

clear all

use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\cleaned\ENCOVI_2019_pre pobreza.dta"
gen part_ilf = ilf/itf
gen part_inlaf = inlaf/itf
gen part_rentaimp= renta_imp/itf

sum part_ilf [w=pondera] if d_renta_imp_b==1
sum part_inlaf [w=pondera] if d_renta_imp_b==1
sum part_rentaimp [w=pondera] if d_renta_imp_b==1

sum part_ilf [w=pondera] if d_renta_imp_b!=1
sum part_inlaf [w=pondera] if d_renta_imp_b!=1
sum part_rentaimp [w=pondera] if d_renta_imp_b!=1

stop

**********************

use "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\ENCOVI_2019_English labels.dta"

* Cómo se compone el ingreso total familiar?
gen part_ilf = ilf/itf
gen part_inlaf = inlaf/itf
gen part_rentaimp= renta_imp/itf

sum renta_imp


sum part_ilf [w=pondera] 
sum part_inlaf [w=pondera] 
sum part_rentaimp [w=pondera] 

stop
ila_m
ila_nm
inla

* inla
ijubi_m
icap_m
rem
itranp_o_m
itranp_ns
itrane_o_m
itrane_ns
inla_extraord
inla_otro

