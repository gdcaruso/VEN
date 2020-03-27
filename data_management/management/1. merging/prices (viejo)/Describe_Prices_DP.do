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
Output:			    Cleaned precio_b data 

Note: 
=============================================================================*/
********************************************************************************

*--------- General

//	Keep only precio_bs in Bolivares 
//  Without considering missing values
	drop if precio_b==.
	
// Auxiliary variable to make changes
	decode bien, gen(food)
	//decode unidad_medida, gen(unit)
	//decode tamno, gen(size)
*--------- Specific good error correction

//	Aceite

	replace unidad_medida=2 if food=="Aceite" & unidad_medida==1 & cantidad==900	
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==2 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Aceite" & unidad_medida==2 & cantidad==1	
	drop if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio>1000000	
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==3 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==3 & cantidad==2 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Aceite" & unidad_medida==3 & cantidad==4 & precio_b<1000		
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==10
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==15
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==20
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==24
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==40
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==48
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==100
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==144
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==180
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==300
	replace cantidad=1 if unidad_medida==3 & food=="Aceite" & cantidad==480
	replace cantidad=0.5 if unidad_medida==3 & food=="Aceite" & cantidad==500
	replace cantidad=0.9 if unidad_medida==3 & food=="Aceite" & cantidad==900
	replace precio_b=precio_b*100 if food=="Aceite" & unidad_medida==4 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==4 & food=="Aceite" & cantidad==1
	replace cantidad=1000 if unidad_medida==4 & food=="Aceite" & cantidad==15


//	Aji dulce, pimentón, pimiento

	replace precio_b=precio_b*3000 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Aji dulce, pimentón, pimiento" & cantidad==9
	replace cantidad=1 if unidad_medida==1 & food=="Aji dulce, pimentón, pimiento" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Aji dulce, pimentón, pimiento" & cantidad==100
	replace precio_b=precio_b*1000 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Aji dulce, pimentón, pimiento" & cantidad==1
	replace precio_b=precio_b*10 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==2 & cantidad==2 & precio_b<10000		
	replace cantidad=2000 if unidad_medida==2 & food=="Aji dulce, pimentón, pimiento" & cantidad==2
	replace precio_b=precio_b*1000 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==110 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Aji dulce, pimentón, pimiento" & unidad_medida==110 & cantidad==1	


//	Arroz

	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==3 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==3
	replace precio_b=precio_b*1000 if food=="Arroz" & unidad_medida==1 & cantidad==5 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==5
	replace precio_b=precio_b*10000 if food=="Arroz" & unidad_medida==1 & cantidad==20 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==29
	replace precio_b=precio_b*10 if food=="Arroz" & unidad_medida==1 & cantidad==30 & precio_b<1000000		
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==48
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==80
	replace cantidad=1 if unidad_medida==1 & food=="Arroz" & cantidad==100
	replace unidad_medida=2 if food=="Arroz" & unidad_medida==1 & cantidad==300	
	replace unidad_medida=2 if food=="Arroz" & unidad_medida==1 & cantidad==500	
	replace precio_b=75000 if cantidad==75000 & food=="Arroz"		
	replace cantidad=1 if cantidad==75000 & food=="Arroz"

//	Auyama

	replace cantidad=1000 if unidad_medida==2 & food=="Auyama" & cantidad==1	
	
//	Azúcar

	replace precio_b=precio_b*1000 if food=="Azúcar" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Azúcar" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace precio_b=precio_b*5000 if food=="Azúcar" & unidad_medida==1 & cantidad==5 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==6
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==8
	replace precio_b=precio_b*20000 if food=="Azúcar" & unidad_medida==1 & cantidad==20 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==25
	replace precio_b=precio_b*30 if food=="Azúcar" & unidad_medida==1 & cantidad==30 & precio_b<1000000		
	replace precio_b=precio_b*40 if food=="Azúcar" & unidad_medida==1 & cantidad==40 & precio_b<1000000		
	replace precio_b=precio_b*50000 if food=="Azúcar" & unidad_medida==1 & cantidad==50 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==55
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==80
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==120
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==380
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==480
	replace cantidad=1 if unidad_medida==1 & food=="Azúcar" & cantidad==1000
	replace precio_b=85000 if cantidad==85000 & food=="Azúcar"		
	replace cantidad=1 if cantidad==85000 & food=="Azúcar"
	replace cantidad=6000 if unidad_medida==2 & food=="Azúcar" & cantidad==6
*	drop if food=="Azúcar" & unidad==2 & cantidad==50		

//	Café

	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==6
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==12 & precio_b<1000000
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==15 & precio_b<1000000
	replace cantidad=1 if unidad_medida==1 & food=="Café" & cantidad==20 & precio_b<1000000
	replace cantidad=0.25 if unidad_medida==1 & food=="Café" & cantidad==250
	replace cantidad=0.5 if unidad_medida==1 & food=="Café" & cantidad==500
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==4
	replace precio_b=precio_b*10000 if food=="Café" & unidad_medida==2 & cantidad==6		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==6
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==12
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==15
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==19
	replace precio_b=precio_b/50 if food=="Café" & unidad_medida==2 & cantidad==20 & precio_b>10000		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==24
	replace precio_b=precio_b*25 if food=="Café" & unidad_medida==2 & cantidad==25 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==48
	replace cantidad=1000 if unidad_medida==2 & food=="Café" & cantidad==72
	replace precio_b=precio_b*1000 if food=="Café" & unidad_medida==2 & cantidad==400		
	replace cantidad=200 if unidad_medida==2 & food=="Café" & cantidad==2000
	replace cantidad=200 if unidad_medida==2 & food=="Café" & cantidad==200000
	replace cantidad=250 if unidad_medida==2 & food=="Café" & cantidad==250000
	//replace precio_b=precio_b*10000 if food=="Café" & unidad_medida=="Otro" & cantidad==1		


// Cambur

	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==20 & precio_b<100000
	replace cantidad=1 if unidad_medida==1 & food=="Cambur" & cantidad==50

// Caraotas

	drop if precio_b>999999 & food=="Caraotas" & unidad_medida==1 & cantidad==1			
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==10 & precio_b<250000
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==11
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==15
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==70
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Caraotas" & cantidad==120
	replace precio_b=90000 if cantidad==90000 & food=="Caraotas"		
	replace cantidad=1 if cantidad==90000 & food=="Caraotas"
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==18
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==20
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==25
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==100
	replace cantidad=1000 if unidad_medida==2 & food=="Caraotas" & cantidad==340
	replace cantidad=250 if unidad_medida==2 & food=="Caraotas" & cantidad==250000


//	Carne de pollo/gallina

	replace precio_b=precio_b*1000 if food=="Carne de pollo/gallina" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==70
	replace precio_b=precio_b*1000 if food=="Carne de pollo/gallina" & unidad_medida==1 & cantidad==100 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==200
	replace cantidad=1 if unidad_medida==1 & food=="Carne de pollo/gallina" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Carne de pollo/gallina" & cantidad==1


//	Carne de res (bistec)

	replace precio_b=precio_b*1000 if food=="Carne de res (bistec)" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (bistec)" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (bistec)" & cantidad==50 & precio_b==210000
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (bistec)" & cantidad==300	

	
//	Carne de res (molida)

	replace precio_b=precio_b*1000 if food=="Carne de res (molida)" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==40
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (molida)" & cantidad==400	

	
//	Carne de res (para esmechar)

	replace precio_b=precio_b*1000 if food=="Carne de res (para esmechar)" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==40
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Carne de res (para esmechar)" & cantidad==400	
	
	
//	Cebolla

	replace precio_b=precio_b*1000 if food=="Cebolla" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Cebolla" & cantidad==9
	replace precio_b=precio_b*10 if food=="Cebolla" & unidad_medida==1 & cantidad==10 & precio_b<100000		
	replace precio_b=precio_b*10 if food=="Cebolla" & unidad_medida==1 & cantidad==20		
	replace cantidad=1 if unidad_medida==1 & food=="Cebolla" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Cebolla" & cantidad==100
	replace precio_b=precio_b*1000 if food=="Cebolla" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==1
	replace precio_b=precio_b*1000 if food=="Cebolla" & unidad_medida==2 & cantidad==6 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==6
	replace precio_b=precio_b*10 if food=="Cebolla" & unidad_medida==2 & cantidad==100 & precio_b<10000		
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==100
	replace cantidad=1000 if unidad_medida==2 & food=="Cebolla" & cantidad==200	
	
	
//	Cebollin, ajoporro.

	replace cantidad=1 if unidad_medida==1 & food=="Cebollin, ajoporro." & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Cebollin, ajoporro." & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Cebollin, ajoporro." & cantidad==1	
	
//	Chorizo, jamón, mortaleda y otros embutidos

	replace precio_b=precio_b*1000 if food=="Chorizo, jamón, mortaleda y otros embutidos" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000*10 if food=="Chorizo, jamón, mortaleda y otros embutidos" & unidad_medida==1 & cantidad==10 & precio_b<1000		
	replace precio_b=precio_b*1000*15 if food=="Chorizo, jamón, mortaleda y otros embutidos" & unidad_medida==1 & cantidad==15 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==35
	replace cantidad=1 if unidad_medida==1 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==70
	replace precio_b=270000 if cantidad==270000 & food=="Chorizo, jamón, mortaleda y otros embutidos"		
	replace cantidad=1 if cantidad==270000 & food=="Chorizo, jamón, mortaleda y otros embutidos"
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==1
	replace cantidad=10000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==10
	replace cantidad=15000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==15
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==48
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==150
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==200
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==650
	replace cantidad=1000 if unidad_medida==2 & food=="Chorizo, jamón, mortaleda y otros embutidos" & cantidad==750	

	
//	Cilantro

	drop if food=="Cilantro" & unidad_medida==1 & cantidad==1 & precio==2938404864			
	replace cantidad=1 if unidad_medida==1 & food=="Cilantro" & cantidad==2
	replace cantidad=1 if unidad_medida==1 & food=="Cilantro" & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Cilantro" & cantidad==10
	replace cantidad=500 if unidad_medida==2 & food=="Cilantro" & cantidad==0
	replace precio_b=precio_b*1000 if food=="Cilantro" & unidad_medida==2 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Cilantro" & unidad_medida==2 & cantidad==1	
	replace cantidad=100 if unidad_medida==2 & food=="Cilantro" & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Cilantro" & cantidad==200 & precio_b>=100000
	replace cantidad=1 if unidad_medida==2 & food=="Cilantro" & cantidad==. & precio_b>=100000	
	
	
//	Frijoles

	replace precio_b=precio_b*1000 if food=="Frijoles" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*10 if food=="Frijoles" & unidad_medida==1 & cantidad==10 & precio_b<100000		
	replace cantidad=1 if unidad_medida==1 & food=="Frijoles" & cantidad==200
	drop if precio_b>999999 & food=="Frijoles" & unidad_medida==2 & cantidad==1			
	replace cantidad=1000 if unidad_medida==2 & food=="Frijoles" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Frijoles" & cantidad==20
	replace cantidad=300 if unidad_medida==2 & food=="Frijoles" & cantidad==30
	replace cantidad=300 if unidad_medida==2 & food=="Frijoles" & cantidad==60	
	
//	Harina de arroz

	replace precio_b=precio_b*1000 if food=="Harina de arroz" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de arroz" & cantidad==8
	replace cantidad=1 if unidad_medida==1 & food=="Harina de arroz" & cantidad==20
	replace precio_b=precio_b*1000 if food=="Harina de arroz" & unidad_medida==1 & cantidad==36 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de arroz" & cantidad==36
	replace cantidad=5.0 if unidad_medida==1 & food=="Harina de arroz" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Harina de arroz" & cantidad==1	
	
	
//	Harina de maiz

	replace precio_b=precio_b*1000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*2000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==2 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==3
	replace precio_b=precio_b*4000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==4 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==15
	replace precio_b=precio_b*20000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==20 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==39
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==48
	replace precio_b=precio_b*1000 if food=="Harina de maiz" & unidad_medida==1 & cantidad==53 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==53
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==200
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==216
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==300
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==600
	replace cantidad=1 if unidad_medida==1 & food=="Harina de maiz" & cantidad==1000
	replace cantidad=1000 if unidad_medida==2 & food=="Harina de maiz" & cantidad==1
	replace bien=9 if food=="Harina de maiz" & unidad_medida==40			
	replace bien=9 if food=="Harina de maiz" & unidad_medida==40			
	replace bien=9 if food=="Harina de maiz" & unidad_medida==40				

	
//	Hueso de res, pata de res, pata de pollo

	replace precio_b=precio_b*1000 if food=="Hueso de res, pata de res, pata de pollo" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Hueso de res, pata de res, pata de pollo" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Hueso de res, pata de res, pata de pollo" & cantidad==140	
	
	
//	Huevos (unidades)

	replace unidad_medida=110 if food=="Huevos (unidades)" & unidad_medida==1 & cantidad==1 & precio_b<20000	
	drop if food=="Huevos (unidades)" & unidad_medida==91 & precio_b>1000000			
	replace precio_b=precio_b*2000 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==2 & precio_b<1000	
	replace unidad_medida=110 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==2	
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==6
	replace precio_b=precio_b*8 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==8 & precio_b<300000		
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==10
	replace precio_b=precio_b*12000 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==12		
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==20
	replace precio_b=precio_b*30 if food=="Huevos (unidades)" & unidad_medida==91 & cantidad==30 & precio_b<300000		
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==36
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==100
	replace cantidad=1 if unidad_medida==91 & food=="Huevos (unidades)" & cantidad==120
	replace cantidad=0.5 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==1 & precio_b>200000
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==15
	replace cantidad=0.5 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==24 & precio_b>200000
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==35
	replace cantidad=1 if unidad_medida==92 & food=="Huevos (unidades)" & cantidad==48
	replace precio_b=precio_b*1000 if food=="Huevos (unidades)" & unidad_medida==110 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*36000 if food=="Huevos (unidades)" & unidad_medida==110 & cantidad==36 & precio_b<1000			


//	Leche en polvo, completa o descremada

		
	replace cantidad=0.5 if unidad_medida==1 & food=="Leche en polvo, completa o descremada" & cantidad==5
	replace cantidad=0.5 if unidad_medida==1 & food=="Leche en polvo, completa o descremada" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Leche en polvo, completa o descremada" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Leche en polvo, completa o descremada" & cantidad==20
	replace cantidad=1000 if unidad_medida==2 & food=="Leche en polvo, completa o descremada" & cantidad==96
	replace precio_b=precio_b*100000 if food=="Leche en polvo, completa o descremada" & unidad_medida==2 & cantidad==125 & precio_b<1000			


//	Lechosa

	replace cantidad=1 if unidad_medida==1 & food=="Lechosa" & cantidad==5	
	
//	Lentejas

	replace precio_b=precio_b*1000 if food=="Lentejas" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Lentejas" & cantidad==11
	replace cantidad=1 if unidad_medida==1 & food=="Lentejas" & cantidad==90
	replace cantidad=1000 if unidad_medida==2 & food=="Lentejas" & cantidad==1
	replace precio_b=precio_b/5 if food=="Lentejas" & unidad_medida==2 & cantidad==20 & precio_b>100000		
	replace cantidad=200 if unidad_medida==2 & food=="Lentejas" & cantidad==20
	replace precio_b=precio_b/5 if food=="Lentejas" & unidad_medida==2 & cantidad==250 & precio_b>100000		
	replace cantidad=200 if unidad_medida==2 & food=="Lentejas" & cantidad==2000
	replace cantidad=250 if unidad_medida==2 & food=="Lentejas" & cantidad==250000	
	
	
//	Margarina/Mantequilla
	
	replace precio_b=precio_b*1000 if food=="Margarina/Mantequilla" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==6
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==20
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==48000
	replace cantidad=1 if unidad_medida==1 & food=="Margarina/Mantequilla" & cantidad==240000
	replace precio_b=precio_b*1000 if food=="Margarina/Mantequilla" & unidad_medida==2 & cantidad==1 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==10
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==12
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==20
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==24
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==35
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==36
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==125 & precio_b==78000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==150 & precio_b==72000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==200 & precio_b==80000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==240
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==250 & precio_b>25000
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==400 & precio_b>70000
	drop if food=="Margarina/Mantequilla" & unidad_medida==2 & cantidad==500 & precio==1			
	replace cantidad=1000 if unidad_medida==2 & food=="Margarina/Mantequilla" & cantidad==500 & precio_b>64981.8203125
	replace precio_b=45000 if cantidad==45000 & food=="Margarina/Mantequilla"		
	replace cantidad=1000 if cantidad==45000 & food=="Margarina/Mantequilla"
	replace cantidad=250 if cantidad==250000 & food=="Margarina/Mantequilla"	


//	Pan de trigo

		
	replace cantidad=1 if unidad_medida==1 & food=="Pan de trigo" & cantidad==35
	replace cantidad=1000 if unidad_medida==2 & food=="Pan de trigo" & cantidad==1
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==2 & cantidad==150 & precio_b<100		
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==40 & tamano==4 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*10000 if food=="Pan de trigo" & unidad_medida==40 & tamano==4 & cantidad==10 & precio_b<100		
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==40 & tamano==4 & cantidad==30 & precio_b<100		
	replace cantidad=1 if unidad_medida==40 & tamano==4 & food=="Pan de trigo" & cantidad==30
	replace precio_b=precio_b*1000 if food=="Pan de trigo" & unidad_medida==40 & tamano==6 & cantidad==1 & precio_b<100			
	
	
//	Papas

	replace precio_b=precio_b*1000 if food=="Papas" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*3000 if food=="Papas" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==8
	replace precio_b=precio_b*1000 if food=="Papas" & unidad_medida==1 & cantidad==10 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==40
	replace cantidad=1 if unidad_medida==1 & food=="Papas" & cantidad==250	
	

//	Papelón

	replace precio_b=precio_b*1000 if food=="Papelón" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Papelón" & cantidad==8
	replace cantidad=1 if unidad_medida==1 & food=="Papelón" & cantidad==15
	replace cantidad=0.5 if unidad_medida==1 & food=="Papelón" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Papelón" & cantidad==1
	replace cantidad=800 if unidad_medida==2 & food=="Papelón" & cantidad==8000
	replace cantidad=500 if unidad_medida==2 & food=="Papelón" & cantidad==500000
	
	
//	Pastas (fideos)

	replace precio_b=precio_b*1000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==1 & precio_b<100		
	replace precio_b=precio_b*2000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==2 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==3
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==4
	replace precio_b=precio_b*5000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==5 & precio_b<100		
	replace precio_b=precio_b*6000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==6 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==15
	replace precio_b=precio_b*10 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==20 & precio_b==100000		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==24
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==25
	replace precio_b=precio_b*30 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==30 & precio_b<1000000		
	replace precio_b=precio_b*40 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==40 & precio_b<100000		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==60
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==72
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==400
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==450
	replace precio_b=precio_b*1000 if food=="Pasta (fideos)" & unidad_medida==1 & cantidad==500 & precio_b<100		
	replace cantidad=1 if unidad_medida==1 & food=="Pasta (fideos)" & cantidad==500
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==1
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==30
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==36
	replace cantidad=1000 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==96
	replace cantidad=500 if unidad_medida==2 & food=="Pasta (fideos)" & cantidad==50000	
	

//	Pesacdo fresco

	replace cantidad=1000 if unidad_medida==2 & food=="Pescado fresco" & cantidad==1	


//	Plátanos
		
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==4
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==15
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==50
	replace cantidad=1 if unidad_medida==1 & food=="Platanos" & cantidad==300
	replace precio_b=precio_b*1000 if food=="Platanos" & unidad_medida==110 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Platanos" & unidad_medida==110 & cantidad==20 & precio_b<1000		
	replace cantidad=1 if unidad_medida==110 & food=="Platanos" & cantidad==20 & precio_b<100000
	replace cantidad=1 if unidad_medida==110 & food=="Platanos" & cantidad==50
	replace cantidad=1 if unidad_medida==110 & food=="Platanos" & cantidad==70
	replace precio_b=cantidad*1000 if cantidad==100 & food=="Platanos"		
	replace cantidad=12 if cantidad==100 & food=="Platanos"
	replace precio_b=cantidad if cantidad==7000 & food=="Platanos"		
	replace cantidad=1 if cantidad==7000 & food=="Platanos"
	replace precio_b=cantidad if cantidad==12000 & food=="Platanos"		
	replace cantidad=1 if cantidad==12000 & food=="Platanos"		
	
	
//	Queso blanco

	replace precio_b=precio_b*1000 if food=="Queso blanco" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Queso blanco" & unidad_medida==1 & cantidad==8 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==8
	replace precio_b=precio_b*10 if food=="Queso blanco" & unidad_medida==1 & cantidad==10 & precio_b==220000		
	replace precio_b=precio_b*10 if food=="Queso blanco" & unidad_medida==1 & cantidad==15 & precio_b==450000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==16
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==20
	replace precio_b=precio_b*30000 if food=="Queso blanco" & unidad_medida==1 & cantidad==30 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==40
	replace precio_b=precio_b*2*50 if food=="Queso blanco" & unidad_medida==1 & cantidad==50 & precio_b==45000		
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==100
	replace cantidad=1 if unidad_medida==1 & food=="Queso blanco" & cantidad==250
	replace precio_b=260000 if cantidad==260000 & food=="Queso blanco"		
	replace cantidad=1 if cantidad==260000 & food=="Queso blanco"
	replace cantidad=1000 if unidad_medida==2 & food=="Queso blanco" & cantidad==150
	replace precio_b=precio_b/2 if food=="Queso blanco" & unidad_medida==2 & cantidad==500 & precio_b==370000		
	replace unidad_medida=1 if food=="Queso blanco" & unidad_medida==3 & cantidad==1	
	replace unidad_medida=1 if food=="Queso blanco" & unidad_medida==91 & cantidad==1	
	replace precio_b=precio_b*2 if food=="Queso blanco" & unidad_medida==92 & cantidad==1 & precio_b==100000	
	replace unidad_medida=1 if food=="Queso blanco" & unidad_medida==92 & cantidad==1		
	
	
//	Sal

	replace precio_b=precio_b*1000 if food=="Sal" & unidad_medida==1 & cantidad==1		
	replace precio_b=precio_b*3000 if food=="Sal" & unidad_medida==1 & cantidad==3		
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==4
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==5
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==10
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==12
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==15
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==20 & precio_b<100000
	replace precio_b=precio_b*24000 if food=="Sal" & unidad_medida==1 & cantidad==24		
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==25
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==30
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==36
	replace cantidad=1 if unidad_medida==1 & food=="Sal" & cantidad==80
	replace precio_b=precio_b*1000 if food=="Sal" & unidad_medida==2 & cantidad==1		
	replace cantidad=1 if unidad_medida==2 & food=="Sal" & cantidad==1
	replace cantidad=120 if unidad_medida==2 & food=="Sal" & cantidad==12
	replace cantidad=500 if unidad_medida==2 & food=="Sal" & cantidad==5000	
	
	
//	Sardinas frescas/congeladas

	replace precio_b=precio_b*1000 if food=="Sardinas frescas/congeladas" & unidad_medida==2 & cantidad==3 & precio_b<1000		
	replace cantidad=3000 if unidad_medida==2 & food=="Sardinas frescas/congeladas" & cantidad==3
	replace precio_b=precio_b*1000 if food=="Sardinas frescas/congeladas" & unidad_medida==80 & cantidad==1 & precio_b<1000			
	
	
//	Tomates

	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==1 & cantidad==1 & precio_b<1000		
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==1 & cantidad==3 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Tomates" & cantidad==3
	replace cantidad=1 if unidad_medida==1 & food=="Tomates" & cantidad==5
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==1 & cantidad==10 & precio_b<1000		
	replace cantidad=1000 if unidad_medida==2 & food=="Tomates" & cantidad==1
	replace precio_b=precio_b*1000 if food=="Tomates" & unidad_medida==110 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Tomates" & unidad_medida==110 & cantidad==1 & precio_b>=100000		
	
	
//	Yuca

	drop if food=="Yuca" & unidad_medida==1 & cantidad==45	
	
	
//	Zanahorias

	replace precio_b=precio_b*1000 if food=="Zanahorias" & unidad_medida==1 & cantidad==2 & precio_b<1000		
	replace cantidad=1 if unidad_medida==1 & food=="Zanahorias" & cantidad==8
	replace cantidad=1 if unidad_medida==1 & food=="Zanahorias" & cantidad==10
	replace precio_b=precio_b*1000 if food=="Zanahorias" & unidad_medida==110 & cantidad==1 & precio_b<1000	
	replace unidad_medida=1 if food=="Zanahorias" & unidad_medida==110 & cantidad==1 & precio_b==90000		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


























		
