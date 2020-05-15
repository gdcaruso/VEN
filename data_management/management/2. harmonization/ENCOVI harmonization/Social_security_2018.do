/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- : Social Programs ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global socialprog_ENCOVI  beneficiario



*--------- Receive 'Mision' or social program
 /* (mmhp57):57. EN EL PRESENTE (2018),
 ¿… RECIBE O ES BENEFICIARIO DE ALGUNA MISIÓN O PROGRAMA SOCIAL?
 */
	*-- Check values
	tab mmhp57, mi
	*-- Standarization of missing values
	replace mmhp57=. if mmhp57==99
	*-- Generate variable
	clonevar beneficiario= mmhp57
	replace beneficiario= 0 if mmhp57==2
	*-- Label variable
	label var beneficiario "In 2018: do you receive a 'Mision' or social program"
	*-- Label values	
	label def beneficiario  1 "Yes" 0 "No" 						  	
	label value beneficiario beneficiario


*--------- Which type of 'Mision'
 /* 58. ¿PUEDE IDENTIFICAR CUÁL MISIÓN O PROGRAMA SOCIAL RECIBE ACTUALMENTE? 
 (selecciones hasta tres)
 
 Each person can chose three programs:
	 Variable 1: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 1
	(mmhp58m1)
	 Variable 2: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 2
	(mmhp58m2) 
	 Variable 3: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 3
	(mmhp58m3)
	 
	 Categories:
				1. Alimentación/Mercal
				2. Barrio Adentro
				3. Milagro
				4. Sonrisa
				5. Robinson
				6. Ribas
				7. Sucre
				8. Saber y Trabajo, Vuelvan Caras y/o Ché Guevara
				9. G. M. Vivienda y/o Barrio Tricolor
				10. Casa Bien Equipada
				11. Madres del Barrio
				12. Hijos de Venezuela
				13. Negra Hipólita
				14. Amor Mayor
				15. Identidad
				16. Otra
				98. NA
				99. NS/NR
 */

	forval i = 1/3{
	*-- Standarization of missing values
	replace mmhp58m`i'=. if mmhp58m`i'==99
	*-- Generate variable
	clonevar mision_`i' = mmhp58m`i' 
	*-- Label variable
	label var mision_`i' "Name of the social program: Mision `i'"
	*-- Label values 
	label def mision_`i' 1 "Alimentación/Mercal" 2 "Barrio Adentro" 3 "Milagro" ///
					     4 "Sonrisa" 5 "Robinson" 6 "Ribas" 7 "Sucre" ///
						 8 "Saber y Trabajo, Vuelvan Caras y/o Ché Guevara" ///
						 9 "G. M. Vivienda y/o Barrio Tricolor" 10 "Casa Bien Equipada" ///
						11 "Madres del Barrio" 12 "Hijos de Venezuela" 13 "Negra Hipólita" ///
						14 "Amor Mayor"	15 "Identidad" 16 "Otra" 98 "NA"
	label value mision_`i' mision_`i'
	*-- Check values
	tab mision_`i' beneficiario, mi 
	}


	
 *--------- 'Carnet patria' 
 /* 2018 and 2017 are not 100% comparable given that 2018 asked for any member 
 in the household and 2017 asked only the informant
 
	2018: 	59. ¿ALGÚN MIEMBRO DE ESTE HOGAR, 
				INCLUSIVE USTED, SE HA SACADO EL CARNET DE LA PATRIA? 
    2017: 	64. ¿SE HA SACADO USTED EL CARNET DE LA PATRIA?
				1. Sí
				2. No. Indique por qué no:*/

	*-- Check values
	tab mp59, mi
	*-- Standarization of missing values
	replace mp59=. if mp59==99
	*-- Generate variable
	clonevar carnet_patria = mp59
	replace carnet_patria = 0 if mp59==2
	*-- Label variable
	label var carnet_patria "Has at least one member of the houselhold obtained the 'Carnet Patria'"
	*-- Label values 
	label def carnet_patria 1 "Yes" 2 "No"
	label value carnet_patria carnet_patria
	
 *--------- 'Carnet patria' Not obtained: Reasons
	*-- Check values
	tab mp59pqn, mi
	*-- Standarization of missing values
	replace mp59pqn="." if mp59pqn=="98"
	replace mp59pqn="." if mp59pqn=="99"
	*-- Generate variable
	clonevar carnet_patria_no = mp59pqn
	*-- Label variable
	label var carnet_patria_no "Why not obtained the 'Carnet Patria'"
	
 *--------- 'Caja CLAP' (In kind-transfer)
 /* 60. ¿EN ESTE HOGAR HAN ADQUIRIDO LA BOLSA/CAJA DEL CLAP?*/
	*-- Check values
	tab mp60, mi
	*-- Standarization of missing values
	replace mp60=. if mp60==99
	*-- Generate variable
	clonevar clap = mp60
	replace clap = 0 if mp60==2
	*-- Label variable
	label var clap "Has at least one member of the houselhold received the 'CLAP'"
	*-- Label values 
	label def clap 1 "Yes" 0 "No"
	label value clap clap

*--------- 'Caja CLAP' (In kind-transfer): Frequency
 /* 61. ¿CON QUÉ FRECUENCIA LES LLEGA LA BOLSA/CAJA DEL CLAP? */ 
	*-- Check values
	tab mp61, mi
	*-- Standarization of missing values
	replace mp61=. if mp61==99
	*-- Generate variable
	clonevar clap_cuando = mp61
	*-- Label variable
	label var clap_cuando "How often the houselhold received the 'CLAP'"
	*-- Label values 
	label def clap_cuando 1 "Cada dos o tres semanas" 2 "Cada mes" ///
						  3 "Cada dos meses" 4 "No hay periodicidad" 
	label value clap_cuando clap_cuando
	
		
