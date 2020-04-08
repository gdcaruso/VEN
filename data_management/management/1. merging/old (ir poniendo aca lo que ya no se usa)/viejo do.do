/*-------- Some descriptive measures

ESTAN HECHAS CON LA FECHA DE APROBACION NO DE LA ENCUESTA

// Generate auxiliar variable to collapse and generate descriptive information
	 // Generate a variable to identify the month
	 gen month=substr(date,6,2)
	 // Create identification for stata and month
	 egen month_state=group(ENTIDAD month), label
	 egen month_state_bien=group(ENTIDAD month bien), label
	 
	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (bien ENTIDAD) 
	export excel using "$dataout/precio_desc", sheet("Todo",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (bien)
	export excel using "$dataout/precio_desc", sheet("Bien",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (ENTIDAD)
	export excel using "$dataout/precio_desc", sheet("Entidad",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_b=bien (count) c_b=bien (sd) sd_b=bien, by (ENTIDAD) 
	export excel using "$dataout/precio_desc", sheet("Bien Entidad",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_p=precio (count) c_p=precio  (sd) sd_p=precio, by (month_state)
	export excel using "$dataout/precio_desc", sheet("Precio-Mes",replace) firstrow(varlabels) 
	restore

	preserve
	collapse (mean) m_b=bien (count) c_b=bien (sd) sd_b=bien, by (month_state) 
	export excel using "$dataout/precio_desc", sheet("Bien-Mes",replace) firstrow(varlabels) 
	restore

*/

/*(************************************************************************************************************************************************* 
* 4: Quantities transformation: 
*************************************************************************************************************************************************)*/

	// Those goods with price equal 1 and strange quantity sre probably inverted
	// We need to switch 
		//replace precio=cantidad if (precio==1 & moneda==1)
		//replace cantidad=1

	// Aceite (COD:35)

		
	
	// Aji dulce, primenton, pimiento (COD:45)
	
	
	// Arroz (COD:1)
		// From kilos to grams 
		// For quantities between 100-900
		replace unidad_medida=2 if (cantidad>=100 & cantidad<=900 & unidad_medida==1 & bien==1)
		// For an article with price-quantity 
		replace precio=75000 if (cantidad==75000 & unidad_medida==1 & bien==1)
		replace cantidad=1 if (cantidad==75000 & precio==75000 & unidad_medida==1 & bien==1)
		// From grams to kilos
		replace unidad_medida=1 if (cantidad==1 & unidad_medida==2 & bien==1)
	
	// Auyama (COD:47)

		
	// Azucar (COD:66) 

		
	//Cafe (COD:71)
		

	// Cambur(COD:38)

		
	// Caraotas	(COD:53)
		
		
	// Carne de pollo/gallina (COD:22)

		
	// Carne de res (bistec) (COD:12)

		
	// Carne de res (molida) (COD:13)
		// From kilos to grams
		replace unidad_medida=2 if (bien==13 & unidad_medida==1 & cantidad>=20 & cantidad<=50)
		replace cantidad=(cantidad*10) if (bien==13 & unidad_medida==2 & cantidad>=20 & cantidad<=50)
	
	// Carne de res (para esmechar) (COD:14)
		// From kilos to grams
		replace unidad_medida=2 if (bien==14 & unidad_medida==1 & cantidad>=20 & cantidad<=50)
		replace cantidad=(cantidad*10) if (bien==14 & unidad_medida==2 & cantidad>=20 & cantidad<=50)

	
	// Cebolla (COD:46)
		
		
	// Cebollin/ ajoporro (COD:51)
	
	
	// Chorizo, jamón, mortaleda y otros embut (COD:20)
		// From kilos to grams 
		replace unidad_medida=2 if (bien==20 & unidad_medida==1 & cantidad>=10 & cantidad<=70)
		// Those grams to the right amount
		//replace cantidad=(cantidad*10) if (bien==20 & unidad_medida==2 & cantidad>=10 & cantidad<=70)
		// From grams to kilos
		replace unidad_medida=1 if (bien==20 & unidad_medida==2 & cantidad==1)
		// To fix grams
		replace cantidad=(cantidad*10) if (bien==20 & unidad_medida==2 & cantidad>=1 & cantidad<=90)

		
	// Cilantro (COD:52)

		
	// Condimentos (COD:75)
		
		
	//Frijoles (COD: 54)
	
	
	// Harina de arroz (COD: 2)
		// From kilos to grams 
		// For quantities over/equal 100-900
		replace unidad_medida=2 if (cantidad>=100 & unidad_medida==1 & bien==1)
		// From grams to kilos
		replace unidad_medida=1 if (cantidad<10 & unidad_medida==2 & bien==1)

		
	// Harina de maiz (COD: 7)
		// From kilos to grams 
		// For quantities over/equal 100-900
		replace unidad_medida=2 if (cantidad>=100 & unidad_medida==1 & bien==7)
		// For quntities between 10-60 ???
		// From grams to kilos
		replace unidad_medida=1 if (cantidad==1 & unidad_medida==2 & bien==7)
		
	// Hueso de res, pata de res, pata de pollo	(COD:19)
		// From kilos to grams
		replace unidad_medida=2 if (bien==19 & unidad_medida==1 & cantidad>=50)
	
	// "Huevos" (COD:34)

	
	//Leche en polvo, completa o descremada (COD:29)
		// From kilos to grams
		replace unidad_medida=2 if (bien==29 & unidad_medida==1 & cantidad==500)
		// From grams to kilos
		replace unidad_medida=1 if (bien==29 & unidad_medida==2 & cantidad==1)
		replace cantidad=(cantidad*10) if (bien==29 & unidad_medida==2 & (cantidad==20 | cantidad==96))
		// From units to kilos
		replace precio_b=(precio_b*10) if (bien==29 & unidad_medida==110 & cantidad==1)
		replace unidad_medida=1 if (bien==29 & unidad_medida==110)
		
	//Lechosa (COD:41)
		// Kilos: 10 kilos shows prices according to mean and median prices
		// 3/17/2020: no changes
		
	//Lentejas (COD:55)
		// From kilos to grams 
		//replace cantidad=(cantidad*10) if (bien==55 & unidad_medida==1 & (cantidad==11 | cantidad==90))
		//replace unidad_medida=2 if (bien==55 & unidad_medida==1 & (cantidad==110 | cantidad==900))
		// From grams to kilos
		replace unidad_medida=1 if (bien==55 & unidad_medida==2 & cantidad==1)
		replace cantidad=(cantidad*10) if (bien==55 & unidad_medida==2 & cantidad==20)
		replace cantidad=(cantidad/10) if (bien==55 & unidad_medida==2 & cantidad==2000)
		replace cantidad=(cantidad/1000) if (bien==55 & unidad_medida==2 & cantidad==250000)
	
	
	//Margarina/Mantequilla (COD:36)
		// From kilos to grams
		replace cantidad=1 if (bien==36 & unidad_medida==1 & precio==54000 & cantidad==6)
		replace cantidad=1 if (bien==36 & unidad_medida==1 & precio==48000 & cantidad==10)
		replace cantidad=1 if (bien==36 & unidad_medida==1 & precio==150000 & cantidad==20)
		// From 48000 and 240000 kilos to one kilo
		replace cantidad=1 if (bien==36 & unidad_medida==1 & (cantidad==48000 | cantidad==240000))
		// From kilos to grams (inverted price-quantity)
		replace precio=45000 if (bien==36 & unidad_medida==2 & cantidad==45000)
		replace cantidad=1 if (bien==36 & unidad_medida==2 & cantidad==45000)
		// From grams to kilos (inverted price-quantity)
		replace precio=45000 if (bien==36 & unidad_medida==2 & cantidad==45000)
		replace cantidad=1 if (bien==36 & unidad_medida==2 & cantidad==45000)
		// From grams to kilos
		replace unidad_medida=1 if (bien==36 & unidad_medida==2 & cantidad==1)
		// From 10-36 grams to 100-360 grams
		replace cantidad=(cantidad*10) if (bien==36 & unidad_medida==2 & cantidad>=10 & cantidad<=36)
		// From 250000 grams to 250 grams
		replace cantidad=250 if (bien==36 & unidad_medida==2 & cantidad==250000)
		
		
	// Pan de trigo (COD:9)
		// To fix extreme quantities wich seem to be 1 kilo
		replace cantidad=1 if (precio==1 & bien==9 & unidad_medida==1)
		// From grams to kilos
		replace unidad_medida=1 if (bien==9 & unidad_medida==2 & cantidad==1)
		
		
	//Papas (COD:62)
		// Kilos
		replace cantidad=1 if (bien==62 & unidad_medida==1 & cantidad==8 & precio_b==30000)
		replace cantidad=4 if (bien==62 & unidad_medida==1 & cantidad==40)
		// From kilos to grams
		replace unidad_medida=2 if (bien==62 & unidad_medida==1 & cantidad>200) 		
		// From grams to units
		replace unidad_medida=110 if (bien==62 & unidad_medida==2 & precio_b==5000)
		replace cantidad=1 if (bien==62 & unidad_medida==110 & cantidad==100)
		
	// Papelon (COD:67)
		// Kilos
		replace cantidad=1 if (bien==67 & unidad_medida==1 & cantidad==8 & precio==50000)
		replace cantidad=1 if (bien==67 & unidad_medida==1 & cantidad==15 & precio==38000)
		// Kilos to grams
		replace unidad_medida=2 if (bien==67 & unidad_medida==1 & cantidad>100)
		// Grams
		replace cantidad=(cantidad*10) if (bien==67 & unidad_medida==2 & cantidad==30 & precio==12000)
		replace cantidad=800 if (bien==67 & unidad_medida==2 & cantidad==8000)
		replace cantidad=1 if (bien==67 & unidad_medida==2 & cantidad==500000)
		// Grams to kilos
		replace unidad_medida=1 if (bien==67 & unidad_medida==2 & cantidad==1)
		// Panela (usually equal a kilo): The price was for one kilo but quantity was 25
		replace cantidad=1 if (bien==67 & unidad_medida==60 & unidad_medida_ot=="Panela" & cantidad==25 & precio==22000)
		
		
		
	// Pasta (fideos) (COD:10)
		// From kilos to grams
        replace unidad_medida=2 if (unidad_medida==1 & cantidad>=100 & bien==10)
		// To fix kilos between 10-72
		// From 3 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==3 & precio_b==100000)
		// From 4 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==4 & precio_b==97000)
		// From 10 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==10 & precio_b==55000)
		// From 12 kilos to 1
		// Something is wrong but i do not know how to fix it
		// From 15 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==15 & precio_b==145000)
		// From 20 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==20 & precio_b==100000)
		// From 24 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==24 & precio_b==120000)
		// From 25 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==25 & precio_b==110000)
		// From 30 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==30 & precio_b==99000)
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==30 & precio_b==140000)
		// From 40 kilos to 1
		// Something is wrong but i do not know how to fix it
		// From 60 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==60 & precio_b==108720)
		// From 72 kilos to 1
		replace cantidad= 1 if (bien==10 & unidad_medida==1 & cantidad==72 & precio_b==130000)
		// Grams
		replace cantidad=(cantidad*10) if (bien==10 & unidad_medida==2 & (cantidad==30 | cantidad==36 | cantidad==96))
		// From 50000 to 500
		replace cantidad=500 if (bien==10 & unidad_medida==2 & cantidad==50000)
		// From grams to kilos 
		replace unidad_medida=1 if (bien==10 & unidad_medida==2 & cantidad==1)

		
	//Pescado fresco (COD:26)
		// From grams to kilos
		replace unidad_medida=1 if (bien==26 & unidad_medida==2 & cantidad==1)
	
	// Platanos (COD:40)
		// Kilos
		// From 15 kilos to 1
		replace cantidad=1 if (bien==40 & unidad_medida==1 & cantidad==15 & precio_b==32000)
		// From 50 kilos to 1
		replace cantidad=1 if (bien==40 & unidad_medida==1 & cantidad==50 & precio_b==40000)
		// From kilos to grams
		replace unidad_medida=2 if (bien==40 & unidad_medida==1 & (cantidad==110 | cantidad==300))
		// Unidad
		// Price instead of quantity
		replace precio=cantidad if (bien==40 & unidad_medida==110 & (cantidad==7000 | cantidad==12000))
		replace cantidad=1 if (bien==40 & unidad_medida==110 & (cantidad==7000 | cantidad==12000))
	
	// Queso blanco (COD:31)
	// From kilos to grams
	replace unidad_medida=2 if (bien==31 & unidad_medida==1 & (cantidad==100 | cantidad==200| cantidad==250))
	// From grams to kilos
	
	// Sal (COD:74)

		
	// Sardinas frescas/congeladas (COD:24)
		
		
	//Tomate (COD:43)
		
		
	//Yuca (COD:61)
	
	
	// Zanahorias (COD:50)
	
