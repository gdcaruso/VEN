use "C:\Users\wb563365\GitHub\VEN\data_management\output\cleaned\ENCOVI_2019.dta" , replace

gen le_chi = 2281370

gen le_col =  2449419

gen lp_chi = 2.4*le_chi

gen lp_col = 2.4*le_col

gen pobre_chi = ipcf<lp_chi

gen pobre_col = ipcf<lp_col

gen ext_col = ipcf<le_col

gen ext_chi = ipcf<le_chi

gen pobreza_chi = 0
replace pobreza_chi = 1 if pobre_chi == 1
replace pobreza_chi = 2 if ext_chi == 1

gen pobreza_col = 0
replace pobreza_col = 1 if pobre_col == 1
replace pobreza_col = 2 if ext_col == 1



bys id: gen miembros = _N



tab pobreza_col [fw=miembros], mi

tab pobreza_chi [fw=miembros], mi
