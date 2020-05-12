*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- : Social Programs ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
global socialprog_ENCOVI  



*--------- Receive 'Mision' or social program
 /* (mmhp62):62. EN EL PRESENTE (2018),
 ¿… RECIBE O ES BENEFICIARIO DE ALGUNA MISIÓN O PROGRAMA SOCIAL?
 */
	*-- Check values
	tab mmhp62, mi
	destring mmhp62, replace
	*-- Standarization of missing values
	replace mmhp62=. if mmhp62==99
	*-- Label values
	label def mmhp62  1 "Si" 2 "No" 						  	
	label value mmhp62 mmhp62
	*-- Generate variable
	clonevar beneficiario= mmhp62
	*-- Label variable
	label var beneficiario "In 2017: do you receive a 'Mision' or social program"
	*-- Label values	
	label def beneficiario  1 "Yes" 2 "No" 						  	
	label value beneficiario beneficiario


*--------- Which type of 'Mision'
 /* 63. ¿PUEDE IDENTIFICAR CUÁL MISIÓN O PROGRAMA SOCIAL RECIBE ACTUALMENTE? 
 (selecciones hasta tres)
 
 Each person can chose three programs:
	 Variable 1: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 1
	(mmhp63m1)
	 Variable 2: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 2
	(mmhp63m2) 
	 Variable 3: ¿Puede identificar cuál misión o programa social recibe actualmente?: Misión 3
	(mmhp63m3)
	 
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
	replace mmhp63m`i'=. if mmhp63m`i'==99
	*-- Generate variable
	clonevar mision_`i' = mmhp63m`i' 
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
 /* 64. ¿SE HA SACADO USTED EL CARNET DE LA PATRIA?
				1. Sí
				2. No. Indique por qué no:  */

	*-- Check values
	tab mp64, mi
	*-- Standarization of missing values
	replace mp64=. if mp64==.
	*-- Generate variable
	clonevar carnet_patria = mp64
	*-- Label variable
	label var carnet_patria "Has at least one member of the houselhold obtained the 'Carnet Patria'"
	*-- Label values 
	label def carnet_patria 1 "Yes" 2 "No"
	label value carnet_patria carnet_patria

 *--------- 'Carnet patria' Not obtained: Reasons
	*-- Check values
	tab mp64pqn, mi
	*-- Standarization of missing values
	replace mp64pqn="." if mp64pqn=="98"
	replace mp64pqn="." if mp64pqn=="99"
	*-- Generate variable
	clonevar carnet_patria_no = mp64pqn
	*-- Label variable
	label var carnet_patria_no "Why not obtained the 'Carnet Patria'"
	
	
 *--------- 'Caja CLAP' (In kind-transfer)
 /* 65. ¿EN ESTE HOGAR HAN ADQUIRIDO LA BOLSA/CAJA DEL CLAP?*/
*-- Check values
	tab mp65, mi
	*-- Standarization of missing values
	replace mp65=. if mp65==99
	*-- Generate variable
	clonevar clap = mp65
	*-- Label variable
	label var clap "Has the houselhold received the 'CLAP'"
	*-- Label values 
	label def clap 1 "Yes" 2 "No"
	label value clap clap

		
*--------- 'Caja CLAP' (In kind-transfer): Frequency
 /* 61. ¿CON QUÉ FRECUENCIA LES LLEGA LA BOLSA/CAJA DEL CLAP? */ 

*-- Check values
	tab mp66, mi
	*-- Standarization of missing values
	replace mp66=. if mp66==99
	*-- Generate variable
	clonevar clap_cuando = mp66
	*-- Label variable
	label var clap_cuando "How often the houselhold received the 'CLAP'"
	*-- Label values 
	label def clap_cuando 1 "Cada mes" 2 "Cada 2 meses" ///
	3 "No hay periodicidad" 98 "NA"  
	label value clap_cuando clap_cuando
