use "C:\Users\wb563365\GitHub\VEN\data_management\output\cleaned\ENCOVI_2019.dta" , replace

gen le_chi = 2281370

gen le_col =  2449419

gen lp_chi = 2.4*le_chi

gen lp_col = 2.4*le_col

gen lp19 = 1.9 *30.4 * 2.92 * (76555.93+1) * (1914.12+1) /100000
gen lp32 = 3.2 *30.4 * 2.92 * (76555.93+1) * (1914.12+1) /100000
gen lp55 = 5.5 *30.4 * 2.92 * (76555.93+1) * (1914.12+1) /100000

gen le_ofi = 1560/5.2* (76555.93+1) * (1914.12+1) /100000
gen lp_ofi = le_ofi*2

gen pobre_chi = ipcf<lp_chi

gen pobre_col = ipcf<lp_col

gen ext_col = ipcf<le_col

gen ext_ofi = ipcf<le_ofi
gen pob_ofi = ipcf<lp_ofi


gen ext_chi = ipcf<le_chi
gen pobreza_19 = ipcf<lp19
gen pobreza_32 = ipcf<lp32
gen pobreza_55 = ipcf<lp55



gen pobreza_chi = 2
replace pobreza_chi = 1 if pobre_chi == 1
replace pobreza_chi = 0 if ext_chi == 1

gen pobreza_col = 2
replace pobreza_col = 1 if pobre_col == 1
replace pobreza_col = 0 if ext_col == 1


bys id: gen miembros = _N



tab pobreza_col, mi

tab pobreza_chi, mi

tab pobreza_19, mi

tab pobreza_32, mi

tab pobreza_55, mi


sort ipcf
gen obs = _n
preserve
drop if obs>31500
graph twoway line ipcf obs, lcolor("black") ///
|| line lp19 obs, lcolor("blue") ///
|| line lp32 obs, lcolor("blue") ///
|| line lp55 obs, lcolor("blue") ///
|| line lp_chi obs, lcolor("red") ///
|| line lp_col obs, lcolor("yellow") ///
|| line le_chi obs, lcolor("red") ///
|| line le_col obs, lcolor("yellow") ///
|| line le_ofi obs, lcolor("green") ///
|| line lp_ofi obs, lcolor("green") 

bro
