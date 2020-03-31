pr def outliers
    args var1 low up cri tol
	tempvar out_`var1' var z z1 z2 
	
//programa que detecta outliers
//var1: variable a  analizar
//low: primer percentil inferior
//up: primer percentil superior
//cri: cuantas desviaciones de la media se considera outliers
//tol: tolerancia sobre el criterio para encontrar los deciles donde es estable la muestra 

//Se utiliza el logaritmo de la variable principal para detectar outliers. 
//Con los percentiles que se dan como inputs se calcula un cambio endógeno en la desviación estándar y este se utiliza como criterio para ir agregando percentiles hasta encontrar un rango donde  se estabiliza la muestra.
//Con este rango se calcula un criterio para evaluar si existen valores outliers.


label drop _all	
qui {
g `var'=log(`var1')	if `var1'>0
g out_`var1'=0



   local l=`low'
  local u=`up'
  centile `var', centile(`l' `u')		
  local p_low = r(c_1)	
  local p_high = r(c_2)
   sum `var' if `var'>=`p_low' &  `var'<=`p_high'
   scalar sdw=r(sd)
    scalar sdl=sdw
scalar sdu=sdw
 
 local l=`low'+5
  local u=`up'
  centile `var', centile(`l' `u')		
  local p_low = r(c_1)	
  local p_high = r(c_2)
   sum `var' if `var'>=`p_low' &  `var'<=`p_high'
    scalar s2=r(sd)
    scalar to=abs(sdl-s2)/sdl
	 scalar tol2=(`tol'*to)*(sdw)
	 
 local l=`low'
  local u=`up'-5
  centile `var', centile(`l' `u')		
  local p_low = r(c_1)	
  local p_high = r(c_2)
   sum `var' if `var'>=`p_low' &  `var'<=`p_high'
   scalar s1=r(sd)
  scalar to1=abs(sdu-s1)/sdu
	 
scalar tol1=(`tol'*to1)*(sdw)
 local l=`low'
 local u=`up'
g `z'=1
g `z1'=1
g `z2'=1
while `z'==1 {
if `z1'==1 {
  local u1=`u'+1
  centile `var', centile(`l' `u1')		
  local p_low = r(c_1)	
  local p_high = r(c_2)
  sum `var' if `var'>=`p_low' & `var'<=`p_high'	
  scalar sd1=r(sd)
  scalar dif=abs(sd1-sdl)
  replace `z1'=0 if  dif>tol1
  scalar tol1=(`tol'*to1)*sd1
  scalar sdl=sd1
  }
 if `z2'==1 {
  local l1=`l'-1
  centile `var', centile(`l1' `u')		
  local p_low = r(c_1)	
  local p_high = r(c_2)
  sum `var' if `var'>=`p_low' & `var'<=`p_high'	
  scalar sd2=r(sd)
  scalar dif=abs(sd2-sdu)
  replace `z2'=0 if  dif>tol2
  scalar tol2=(`tol'*to)*sd2
  scalar sdu=sd2
 }
 if `z1'==1 {
  local u=`u1'
  }
  if `z2'==1 {
  local l=`l1'
 }
   replace `z'=0 if  `u1'==96 & `z1'==1 
   replace `z'=0 if  `l1'==6 & `z2'==1 
   replace `z'=0 if  `z1'==0  & `z2'==0
  }
  
  local u=`u1'-1
  local l=`l1'+1
  centile `var', centile(`l' `u')		
  local p_low = r(c_1)	
  local p_high = r(c_2)
  sum `var' if `var'>=`p_low' & `var'<=`p_high'	
  scalar sdt=r(sd)
  
  
 
 scalar outlier_high = r(mean)+ sdt*`cri'	
 replace  out_`var1' = 1 if `var'>=outlier_high & `var'!=.

  
label define outliers_1 0 "Normal" 1 "Abnormally High value"
label values out_`var1' outliers_1	
}
centile `var', centile(`l' `u')
tab out_`var1'

replace  `var1'=. if  out_`var1' == 1
  
  
  end
