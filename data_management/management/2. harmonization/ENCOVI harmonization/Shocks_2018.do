/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Shocks ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global choques informant_shock evento_* evento_ot imp_evento_* veces_evento_* ano_evento_* ///
reaccion_evento_* reaccionot_evento*


*--------- Informant in this section
 /* Informante (s15q00): 00. Quién es el informante de esta sección?
		01 = Jefe del Hogar	
		02 = Esposa(o) o Compañera(o)
		03 = Hijo(a)		
		04 = Hijastro(a)
		05 = Nieto(a)		
		06 = Yerno, nuera, suegro (a)
		07 = Padre, madre       
		08 = Hermano(a)
		09 = Cunado(a)         
		10 = Sobrino(a)
 */
	*-- Check values
	tab s15q00, mi
	*-- Standarization of missing values
	replace s15q00=. if s15q00==.a
	*-- Create auxiliary variable
	clonevar informant_ref = s15q00
	*-- Generate variable
	gen     informant_shock  = 1		if  informant_ref==1
	replace informant_shock  = 2		if  informant_ref==2
	replace informant_shock  = 3		if  informant_ref==3  | informant_ref==4
	replace informant_shock  = 4		if  informant_ref==5  
	replace informant_shock  = 5		if  informant_ref==6 
	replace informant_shock  = 6		if  informant_ref==7
	replace informant_shock  = 7		if  informant_ref==8  
	replace informant_shock  = 8		if  informant_ref==9
	replace informant_shock  = 9		if  informant_ref==10
	replace informant_shock  = 10		if  informant_ref==11
	replace informant_shock  = 11		if  informant_ref==12
	replace informant_shock  = 12		if  informant_ref==13
	
	*-- Label variable
	label var informant_shock "Informant: Shocks"
	*-- Label values	
	label def informant_shock  1 "Jefe del Hogar" 2 "Esposa(o) o Compañera(o)" 3 "Hijo(a)/Hijastro(a)" ///
							  4 "Nieto(a)" 5 "Yerno, nuera, suegro (a)"  6 "Padre, madre" 7 "Hermano(a)" ///
							  8 "Cunado(a)" 9 "Sobrino(a)" 10 "Otro pariente" 11 "No pariente" ///
							  12 "Servicio Domestico"	
	label value informant_shock  informant_shock 


*--------- Events which affected the household
 /* Events(s15q1): 1. Cuáles de los siguientes eventos han afectado a
su hogar desde el año 2017 ?
         0 = No
         1 = Si
 */

	forval i = 1/21{
	*-- Standarization of missing values
	replace s15q1__`i'=. if s15q1__`i'==.a
	tab s15q1__`i', mi
	*-- Label values (main variable)
	label def s15q1__`i' 0 "No" 1 "Si"
	label value s15q1__`i' s15q1__`i'
	*-- Generate variable
	gen evento_`i' = s15q1__`i'
	}

	*-- Other events
	*-- Check
	tab s15q1_os, mi
	*-- Standarization of missing values
	replace s15q1_os="." if s15q1_os==".a"
	gen evento_ot = s15q1_os
	*-- Label variable
	label var evento_ot "1a.Especifique otro choque"
	
 *--------- Most important events
 /* s15q2: 2. De la lista de eventos acontecidos en su hogar desde el año 2017, 
 señale cuáles han sido los 3 más significativos?
Categories: 
			1:Muerte o discapacidad de un miembro adulto del hogar que trabajaba
			2:Muerte de alguien que enviaba remesas al hogar 
			3:Enfermedad de la persona con el ingreso más importante del hogar
			4:Pérdida de un contacto importante, 
			5:Perdida de trabajo de la persona con el ingreso más importante del hogar
			6:Salida del miembro del hogar que generaba ingresos debido a separación/divorcio
			7:Salida del miembro de la familia que generaba ingresos debido al matrimonio
			8:Salida de un miembro del hogar que generaba ingresos por emigración
			9:Fracaso empresarial no agrícola/cierre de negocio o emprendimiento
			10:Robo de cultivos, dinero en efectivo, ganado u otros bienes
			11:Pérdida de cosecha por incendio/sequía/inundaciones
			12:Invasión de plagas que causó el fracaso de la cosecha o la pérdida de almacenamiento
			13:Vivienda dañada / demolida
			14:Pérdida de propiedad por incendio o inundación
			15:Pérdida de tierras, 16:Muerte de ganado por enfermedad
			17:Incremento en el precio de los insumos
			18:Caída en el precio de los productos
			19:Incremento en el precio de los principales alimentos consumidos
			20:Secuestro/robo/asalto
			21:Otro
        
 */

	forval i = 1/22 {
	rename s15q2__`i' s15q2_`i'
	*-- Standarization of missing values
	replace s15q2_`i'=. if s15q2_`i'==.a
		*-- Generate variable
		clonevar imp_evento_`i' = s15q2_`i'
	}
	
	
 *--------- How many times have the shock occurred since 2017
 /* (s15q2a)2a. Cuántas veces ocurrió %rostertitle% desde 2017?
 */

	forval i = 1/21 {
	*-- Label original variable
	label var s15q2a_`i' "2a. Cuántas veces ocurrió X desde 2017?"
	*-- Standarization of missing values
	replace s15q2a_`i'=. if s15q2a_`i'==.a
		*-- Generate variable
		clonevar veces_evento_`i' = s15q2a_`i'
		*-- Label variable
		//label var veces_evento_`i' "How many times have the shock occurred since 2017"
		}
		
	
 /*
 *--------- Year of the event
 (s15q2b) 2b. En qué año ocurrió ?
        
 */ 

	forval i = 1/21 {
	*-- Label original variable
	label var s15q2b_`i' "2b. En qué año ocurrió?"
	*-- Standarization of missing values
	replace s15q2b_`i'=. if s15q2b_`i'==.a
	*-- Generate variable
	clonevar ano_evento_`i'  = s15q2b_`i'
	*-- Label variable
	label var ano_evento_`i' "Year of the event"
	}
	

 *--------- How the houselhold coped with the shock
 /* (s15q2c): 2c. Cómo se las arregló su hogar con el choque más reciente?*/
 
local x 1 2 3 4 5 6 8 9 10 12 13 14 15 16 17 18 19 20 21 22 23 24
	foreach i of local x {
		forval k = 1/21 {
	*-- Rename original variable 
	rename (s15q2c__`i'_`k') (s15q2c_`i'_`k')
	*-- Label original variable
	label var s15q2c_`i'_`k' "2c. Cómo se las arregló su hogar con el choque más reciente?"
	*-- Standarization of missing values
	replace s15q2c_`i'_`k'=. if s15q2c_`i'_`k'==.a
	*-- Generate variable
	clonevar reaccion_evento_`i'_`k' = s15q2c_`i'_`k'
	*-- Label variable
	label var reaccion_evento_`i'_`k' "Response to event"
	*-- Label values
	label def reaccion_evento_`i'_`k' 0 "No codificado" 1 "Venta de ganado" 2 "Venta de terreno" 3 "Venta de propiedad" ///
	4 "Envían niños a vivir con amigos" 5 "Se retiraron los niños de escuela" ///
	6 "Trabajando en otras actividades generadoras de ingreso" ///
	8 "Asistencia recibida de amigos y familia" 9 "Préstamos de amigos y familia" ///
	10 "Tomó un préstamo de una institución financiera" ///
	12 "Miembros del hogar migraron por trabajo" ///
	13 "Compras al crédito" 14 "Pago retrasado de obligaciones" ///
	15 "Vendió la cosecha por adelantado" 16 "Reducción del consumo de alimentos" /// 
	17 "Reducción de consumo de no alimentos" 18 "Usando ahorros" ///
	19 "Asistencia recibida de ONG" 20 "Tomó pago por adelantado de empleador" ///
	21 "Asistencia recibida del gobierno" 22 "Cubierto por un seguro" ///
	23 "No hizo nada" 24 "Otro"
	label val reaccion_evento_`i'_`k' reaccion_evento_`i'_`k'
		}
	}
	
 *--------- Other responses to the event
 /* (s15q2d): 2d. Otro arreglo, especifique */	
	forval i = 1/21 {
	*-- Label original variable
	label var s15q2d_`i' "2d. Otro arreglo, especifique"
	*-- Standarization of missing values
	replace s15q2d_`i'="." if s15q2d_`i'==".a"
	*-- Generate variable
	clonevar reaccionot_evento`i' = s15q2d_`i'
	*-- Label variable
	label var reaccionot_evento`i' "Other responses to the event"
	*-- Cross check
	tab reaccionot_evento`i'
	}


