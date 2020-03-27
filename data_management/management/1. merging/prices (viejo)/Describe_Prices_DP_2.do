/*===========================================================================
Purpose: error correction on precio_bs dataset

Country name:	Venezuela
Year:			2019
Project:	
---------------------------------------------------------------------------
Authors:			Daniel Pereira

Dependencies:		The World Bank -- Poverty unidad_medida
Creation Date:		March, 2020
Modification Date:  
Output:			    Cleaned precio_b data for unidad_medidas (other)

Note: 
=============================================================================*/
********************************************************************************

*--------- General
	// Eliminate precio_bs equal zero
	drop if precio_b==0			
	
*--------- Specific good error correction
//	Aceite

	drop if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio_b>999999

//	Aji dulce, pimentón, pimiento


//	Arroz

	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==1 & precio_b<1000
	replace precio_b=precio_b*10 if food=="Arroz" & unidad_medida==1 & cantidad==10 & precio_b<200000
	replace precio_b=precio_b*10 if food=="Arroz" & unidad_medida==1 & cantidad==20 & precio_b<200000
	drop if food=="Arroz" & cantidad==84  & precio_b==41	

//	Auyama

	replace precio_b=precio_b*8 if food=="Auyama" & unidad_medida==1 & cantidad==8 & precio_b<100000
	
//	Azúcar

	drop if food=="Azúcar" & unidad_medida==1 & cantidad==1 & precio==3100	
	replace precio_b=precio_b*20 if food=="Azúcar" & unidad_medida==1 & cantidad==20 & precio_b<100000
	replace unidad_medida=60 if food=="Azúcar" & unidad_medida==1 & unidad_medida_ot=="Teta"	
	replace unidad_medida=60 if food=="Azúcar" & unidad_medida==1 & unidad_medida_ot=="Teticas"	
	replace precio_b=precio_b*1000 if food=="Azúcar" & unidad_medida==2 & cantidad==50 & precio_b<1000		

	
//	Café

	replace precio_b=precio_b*20 if food=="Café" & unidad_medida==2 & cantidad==20 & precio_b<1000		
	replace precio_b=precio_b/1000 if (precio_b<999999999 & food=="Café" & unidad_medida==2 & cantidad==400)
	replace precio_b=precio_b/1000000 if precio_b>999999999 & food=="Café" & unidad_medida==2 & cantidad==400
	replace precio_b=precio_b*400/1000 if food=="Café" & unidad_medida==2 & cantidad==400 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==60 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==60 & cantidad==50 & precio_b<1000		
	replace cantidad=1 if unidad_medida==130 & food=="Café" & cantidad==50	


// Cambur


// Caraotas



//	Carne de pollo/gallina


//	Carne de res (bistec)

	replace precio_b=precio_b*50 if food=="Carne de res (bistec)" & unidad_medida==1 & cantidad==50 & precio_b<300000
	
//	Carne de res (molida)

	
//	Carne de res (para esmechar)


	
//	Cebolla

	replace precio_b=precio_b/10 if food=="Cebolla" & unidad_medida==1 & cantidad==20 & precio_b==10000000	
	
//	Cebollin, ajoporro.

	
//	Chorizo, jamón, mortaleda y otros embutidos

	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==10000
	replace cantidad=1500 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==15000
	
//	Cilantro

	drop if food=="Cilantro" & unidad_medida==1 & cantidad==1 & precio>999999			
	replace precio_b=precio_b*1000 if food=="Cilantro" & unidad_medida==2 & cantidad==. & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cilantro" & cantidad==.	
	
//	Frijoles

	
//	Harina de arroz

	replace precio_b=precio_b*5 if food=="Harina de arroz" & unidad_medida==1 & cantidad==5 & precio_b<100000	
	
//	Harina de maiz


	
//	Hueso de res, pata de res, pata de pollo

	
	
//	Huevos (unidades)

	replace unidad_medida=110 if food=="Huevos (unidades)" & unidad_medida==60 & unidad_medida_ot=="Mini cartón de 6 unidades"			
	replace cantidad=6 if unidad_medida==110 & food=="Huevos (unidades)" & cantidad==126
	replace cantidad=1 if unidad_medida==110 & food=="Huevos (unidades)" & cantidad==30
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==30

//	Leche en polvo, completa o descremada

		
	drop if food=="Leche en polvo, completa o descremada" & unidad_medida==110 & cantidad==1
	replace precio_b=precio_b*10000 if food=="Leche en polvo, completa o descremada" & unidad_medida==1 & cantidad==10

//	Lechosa

	
//	Lentejas


	
//	Margarina/Mantequilla
	
	replace cantidad=1 if unidad_medida==220 & food=="Margarina/Mantequilla" & cantidad==120

//	Pan de trigo

	replace cantidad=1 if food=="Pan de trigo" & cantidad==12 & tamano==5 & precio==18000	
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="De Sandwich")
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="De Sandwich")	
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="Paquete de acemitas")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="Paquete de acemitas")	
	replace cantidad=1 if (food=="Pan de trigo" & unidad_medida_ot=="Paquete de acemitas")
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes pequeños")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes pequeños")	
	replace cantidad=2 if (food=="Pan de trigo" & unidad_medida_ot=="bolsa de 10 panes pequeños")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="pan canilla")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="pan canilla")
	replace unidad_medida_ot="Paquete" if (food=="Pan de trigo" & unidad_medida_ot=="paquete de 10 unidades")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de 10 unidades")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de dos panes canilla")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de dos panes canilla")	
	replace cantidad=2 if (food=="Pan de trigo" & unidad_medida_ot=="paquete de dos panes canilla")
	replace unidad_medida=40 if (food=="Pan de trigo" & unidad_medida_ot=="pieza de pan dulce")	
	replace tamano=5 if (food=="Pan de trigo" & unidad_medida_ot=="pieza de pan dulce")

//	Papas

	

//	Papelón

	replace cantidad=0.5 if unidad_medida==60 & food=="Papelón" & cantidad==25
	replace cantidad=0.25 if unidad_medida==60 & food=="Papelón" & cantidad==1 & unidad_medida_ot=="pieza pequeña"
	replace precio_b=precio_b*1000 if food=="Papelón" & unidad_medida==110 & cantidad==1 & precio_b<100		
	drop if food=="Papelón" &  cantidad==.a		
	
//	Pastas (fideos)

	replace precio_b=precio_b*1000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==1 & precio_b<1000
	replace precio_b=precio_b*2000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==2 & precio_b<1000	
	

//	Pesacdo fresco



//	Plátanos
		
	
	
//	Queso blanco

	replace precio_b=precio_b*4 if food=="Queso blanco" & unidad_medida==2 & cantidad==4 & precio_b<1000		
	
	
//	Sal

	replace precio_b=precio_b/1000 if food=="Sal" & unidad_medida==1 & cantidad==1 & precio_b>999999		
	replace precio_b=precio_b/1000000 if food=="Sal" & unidad_medida==2 & cantidad==1 & precio_b>999999		
	replace cantidad=100 if unidad_medida==2 & food=="Sal" & cantidad==1 & precio_b==10000
	replace precio_b=precio_b*1000 if food=="Sal" & unidad_medida==60 & cantidad==1 & precio_b<100 & unidad_medida_ot=="bulto"		
	replace unidad_medida=1 if food=="Sal" & unidad_medida==110 & cantidad==1				
	
//	Sardinas frescas/congeladas


	
//	Tomates

	replace precio_b=precio_b*10 if food=="Tomates" & unidad_medida==1 & cantidad==10 & precio_b<200000	
	
//	Yuca

	
	
//	Zanahorias

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


























		
