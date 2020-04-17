/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
*** Type of flooring material
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas
		 
 VAR: material_piso = s4q1 */
 
	* From Harmonization
	
*** Type of exterior wall material		 
/* MATERIAL_PARED_EXTERIOR (s4q2)
		 1 = Bloque, ladrillo frisado	
		 2 = Bloque ladrillo sin frisar  
		 3 = Concreto	
		 4 = Madera aserrada 
		 5 = Bloque de plocloruro de vinilo	
		 6 = Adobe, tapia o bahareque frisado
		 7 = Adobe, tapia o bahareque sin frisado
		 8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  

	VAR: material_pared_exterior = s4q2  */
	
	* From Harmonization

*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
		 
	VAR: material_techo = s4q3 	*/
	* From Harmonization
	
*** Type of dwelling
/* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
		
	VAR: tipo_vivienda = s4q4	
*/
	* From Harmonization

	
*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda?
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
		
		VAR: suministro_agua =  s4q5__1
*/
		*-- Label variable
		label var suministro_agua "Ultimos 3 meses: Cuales han sido las principales fuentes de suministro de agua en esta vivienda? (encuesta)"		
		
		*-- Label variable
		label var suministro_agua_comp "Ultimos 3 meses: Cuales han sido las principales fuentes de suministro de agua en esta vivienda? (armonizada)"		
		

*** Frequency of water supply
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
		
		VAR: frecuencia_agua = s4q6
*/
		*-- Label variable
		label var frecuencia_agua "Ultimos 3 meses: Con que frecuencia ha llegado el agua del acueducto a esta vivienda?"
	
*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/

		*-- Label variable
		label var  electricidad "Ultimos 3 meses: tuvo acceso a electricidad"
		*-- Label values
		label def elec 1 "Si" 0 "No"
		label val serv_elect_red_pub elec
		label val serv_elect_planta_priv elec
		label val serv_elect_otro elec
		label val electricidad elec
		
*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
	VAR: interrumpe_elect = s4q8		
*/
		*-- Label variable
		label var interrumpe_elect "Electric power interruptions"
		*-- Label values
		label def interrumpe_elect_en 1 "Daily for long hours" ///
		2 "Once a week for long hours" ///
		3 "Once a month" 4 "Never" 
		label value interrumpe_elect interrumpe_elect_en

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
		
	VAR: tipo_sanitario_comp
	
		1 "Poceta a cloaca/Pozo septico" 
		2 "Poceta sin conexion" 
		3 "Excusado de hoyo o letrina" 
		4 "No tiene poseta o excusado"
*/
		*-- Label variable
		label var tipo_sanitario "Type of toilet (this survey)"
		*-- Label values
		label def tipo_sanitario 1 "Toilet with flush (connected to public sewerage system)" ///
		2 "Toilet with flush (connected to cesspit)" ///
		3 "Toilet but not connected" ///
		4 "Toilet without flush" ///
		5 "Without toilet"
		label val tipo_sanitario tipo_sanitario
		
		*-- Label variable
		label var tipo_sanitario_comp "Type of toilet (harmonized)"
		*-- Label values
		label def tipo_sanitario_comp_en 1 "Toilet with flush (connected to public sewerage system of cesspit)" ///
		2 "Toilet but not connected" 3 "Toilet without flush" ///
		4 "Without toilet"
		label value tipo_sanitario_comp tipo_sanitario_comp_en

*** Number of rooms used exclusively to sleep
/* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
	VAR: ndormi= s5q1  //up to 9 */
 
		*-- Label variable
		label var ndormi "Number of rooms used exclusively to sleep"
		
*** Bath with shower 
/* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
VAR: banio_con_ducha = s5q2*/
		*-- Label variable
		label var banio_con_ducha "Bath with shower"
		*-- Label values
		label def banio_con_ducha_en 1 "Yes" 0 "No"
		label val banio_con_ducha banio_con_ducha_en
		
*** Number of bathrooms with shower
/* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 */
		*-- Label variable
		label var nbanios "Number of bathrooms with shower"
		
*** Housing tenure
/* TENENCIA_VIVIENDA (s5q7): régimen de  de la vivienda  
		1 = Propia pagada		
		2 = Propia pagandose
		3 = Alquilada
		4 = Alquilada parte de la vivienda
		5 = Adjudicada pagandose Gran Mision Vivienda
		6 = Adjudicada Gran Mision Vivienda
		7 = Cedida por razones de trabajo
		8 = Prestada por familiar o amigo
		9 = Tomada
		10 = Otra */
		
		*-- Label variable
		label var tenencia_vivienda "Housing tenure (this survey)"
		*-- Label values
		label def tenencia_vivienda_en 1 "Own housing (paid)" 2 "Own housing (paying)" ///
				3 "Rented housing" 4 "Rented part of the housing" ///
				5 "Awarded-Social housing: Gran Mision Vivienda (paying)" /// 
				6 "Awarded-Social housing: Gran Mision Vivienda"
				7 "Borrowed for work reasons"
				8 "Borrowed by relative or friend"
				9 "Taken over"
			   10 "Other"
		label val tenencia_vivienda tenencia_vivienda_en

		*-- Label variable
		label var tenencia_vivienda_comp "Housing tenure (harmonized)"
		*-- Label values
		label def tenencia_vivienda_comp 1 "Own housing (paid)" 2 "Own housing (paying)" ///
		3 "Rented housing" 4 "Borrowed" 5 "Taken over" 6 "Social housing: Government program" 7 "Other"
		label value tenencia_vivienda_comp tenencia_vivienda_comp

		*** How much did you pay for rent or mortgage the last month?
		*-- Label variable
		label var pago_alq_mutuo "How much did you pay for rent or mortgage the last month?"

		*** In which currency did you make the payment?
		*-- Label variable
		label var pago_alq_mutuo_mon "In which currency did you make the payment?"

		*** In which month did you make the payment?
		*-- Label variable
		label var pago_alq_mutuo_m "In which month did you make the payment?"
		*-- Label values
		label def month 1 "January" 2 "February" 3 "March" 4 "April" ///
		5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
		label val pago_alq_mutuo_m month
		
		*** During the last year, have you had arrears in payments?
		*-- Label variable
		label var atrasos_alq_mutuo "During the last year, have you had arrears in payments?"
		*-- Label values
		label def yesno 1 "Yes" 0 "No"
		label val atrasos_alq_mutuo yesno
		
		*** What consequences did the arrears in payments had?
		*-- Label variable
		label var implicancias_nopago "What consequences did the arrears in payments had?"
		*-- Label values
		label def implicancias_nopago 1 "Sold assets from the household to cancel debt" ///
							          2 "Asked your relatives for help" ///
									  3 "Sublease a room in the house" /// 
									  4 "Looked for a second job" ///
                                      5 "Other"
		label val implicancias_nopago implicancias_nopago
		
		*** If you had to rent similar dwelling, how much did you think you should pay?
		*-- Label variable
		label var renta_imp_en "If you had to rent similar dwelling, how much did you think you should pay?"
				
		*** In which currency ?
		*-- Label variable
		label var renta_imp_mon "In which currency?"

		*** What type of property title do you have?
		*-- Label variable
		label var titulo_propiedad "What type of property title do you have?"
		*-- Label values
		label def titulo_propiedad 1 "Título supletorio" 
                    2 "Ownership certificate" ///                 
					3 "Without certificate" ///
                    4 "Other"
		label val titulo_propiedad titulo_propiedad 

*** What are the main sources of drinking water in your household?
		* Acueducto
		*-- Label variable
		label var fagua_acueduc "Main sources of drinking water in your household? Pipeline"
		* Pila o estanque
		*-- Label variable
		label var fagua_estanq "Main sources of drinking water in your household? Pile or pond"
		* Camión cisterna
		*-- Label variable
		label var fagua_cisterna "Main sources of drinking water in your household? Water tanker truck"
		* Pozo con bomba
		*-- Label variable
		label var fagua_bomba "Main sources of drinking water in your household? Water pump"
		* Pozo protegido
		*-- Label variable
		label var fagua_pozo "Main sources of drinking water in your household?
		* Aguas superficiales (manantial,río, lago, canal de irrigación)
		*-- Label variable
		label var fagua_manantial "Main sources of drinking water in your household?
		* Agua embotellada
		*-- Label variable
		label var fagua_botella "Main sources of drinking water in your household? Bottled"
		* Otros
		*-- Label variable
		label var fagua_otro "Main sources of drinking water in your household? Other"

		*-- Label values
		label def aqua 0 "Other" 1 "First (1)" 2 "Second (2)" 3 "Third (3)" 
		label val fagua_acueduc aqua
		label val fagua_estanq aqua
		label val fagua_cisterna aqua
		label val fagua_bomba aqua
		label val fagua_pozo aqua
		label val fagua_manantial aqua
		label val fagua_botella aqua
		label val fagua_otro aqua

		*** In your household, is the water treated to make it drinkable
		*-- Label variable
		label var tratamiento_agua "In your household, is the water treated to make it drinkable"
		*-- Label values
		label val tratamiento_agua yesno
		
		*** How do you treat the water to make it more safe for drinking
		*-- Label variable
		label var tipo_tratamiento "How do you treat the water to make it more safe for drinking"
		label def tipo_tratamiento 1 "Boil the water" 2 "Add bleach" ///
						   3 "Use a filter for water" 4 "Boil and filter" ///
						   5 "Other"
	    label val tipo_tratamiento tipo_tratamiento
		
		*** Which type of fuel do you use for cooking?
		*-- Label variable
		label var comb_cocina "Which type of fuel do you use for cooking?"
		*-- Label values
		!label def comb_cocina 1 "Gas (direct)" 2 "Gas por bombona" 3 "Electricity" 4 "Wood" 5 "Other" 6 "Do not cook"
		label val comb_cocina comb_cocina

*** Did you pay for the following utilities?
* Water
		*-- Label variable
		label var pagua "Did you pay for the following utilities? Water"
		*-- Label values
		label val pagua yesno

* Electricity
		*-- Label variable
		label var pelect "Did you pay for the following utilities? Electricity"
		* Gas
		*-- Label variable
		label var pgas "Did you pay for the following utilities? Gas"
		* Carbon, wood
		*-- Label variable
		label var pcarbon "Did you pay for the following utilities? Carbon, wood"
		* Paraffin
		*-- Label variable
		label var pparafina "Did you pay for the following utilities? Paraffin"
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono "Did you pay for the following utilities? Landline, internet and tv cable"
		
		*-- Label values
		label val pelect yesno
		label val pgas yesno
		label val pcarbon yesno
		label val pparafina yesno
		label val ptelefono yesno

*** How much did you pay for the following utilities?
		*-- Label variable
		* Water
		label var pagua_monto "How much did you pay for the following utilities? Water"
		* Electricity
		*-- Label variable
		label var pelect_monto "How much did you pay for the following utilities? Electricity"
		* Gas
		*-- Label variable
		label var pgas_monto "How much did you pay for the following utilities? Gas"
		* Carbon, wood
		*-- Label variable
		label var pcarbon_monto "How much did you pay for the following utilities? Carbon, wood"
		* Paraffin
		*-- Label variable
		label var pparafina_monto "How much did you pay for the following utilities? Paraffin"
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_monto "How much did you pay for the following utilities? Landline, internet and tv cable"

*** In which currency did you pay for the following utilities?
		* Water
		*-- Label variable
		label var pagua_mon "In which currency did you pay for the following utilities? Water"
		* Electricity
		*-- Label variable
		label var pelect_mon "In which currency did you pay for the following utilities? Electricity"
		* Gas
		*-- Label variable
		label var pgas_mon"In which currency did you pay for the following utilities? Gas"
		* Carbon, wood
		*-- Label variable
		label var pcarbon_mon"In which currency did you pay for the following utilities? Carbon, wood"
		* Paraffin
		*-- Label variable
		label var pparafina_mon"In which currency did you pay for the following utilities? Paraffin"
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_mon "In which currency did you pay for the following utilities? Landline, internet and tv cable"

*** In which month did you pay for the following utilities?
		* Water
		*-- Label variable
		label var pagua_m "In which month did you pay for the following utilities? Water"
		*-- Label values
		label val pagua_m month 
		* Electricity
		*-- Label variable
		label var pelect_m "In which month did you pay for the following utilities? Electricity"
		*-- Label values
		label val pelect_m month
		* Gas
		*-- Label variable
		label var pgas_m "In which month did you pay for the following utilities? Gas"
		*-- Label values
		label val pgas month
		* Carbon, wood
		label var pcarbon_m "In which month did you pay for the following utilities? Carbon, wood"
		*-- Label values
		label val pcarbon_m month
		* Paraffin
		*-- Label variable
		label var pparafina_m "In which month did you pay for the following utilities? Paraffin"
		*-- Label values
		label val pparafina_m month
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_m "In which month did you pay for the following utilities? Landline, internet and tv cable"
		*-- Label values
		label val ptelefono_m month

*** In your household, have any home appliences damaged due to blackouts or voltage inestability?
		*-- Label variable
		label var danio_electrodom "In your household, have any home appliences damaged due to blackouts or voltage inestability?"
		*-- Label values
		label val danio_electrodom yesno


/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/
*** Type of flooring material
/* MATERIAL_PISO (s4q1)
		 1 = Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares
		 2 = Cemento   
		 3 = Tierra		
		 4 = Tablas
		 
 VAR: material_piso = s4q1
 *-- Label values
		label def material_piso 1 "Mosaic,granite,vynil, brick.." 2 "Cement" 3 "Ground floor" 4 "Boards" 5 "Other"
		label value material_piso material_piso

*/
	*-- Label variable
	label var material_piso " 1. El material predominante del piso"
	 *-- Label values
		label def material_piso 1 "Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares" ///
		 2 "Cemento" /// 
		 3 "Tierra" ///	
		 4 "Tablas"
		label value material_piso material_piso

*** Type of exterior wall material		 
/* MATERIAL_PARED_EXTERIOR (s4q2)
		 1 = Bloque, ladrillo frisado	
		 2 = Bloque ladrillo sin frisar  
		 3 = Concreto	
		 4 = Madera aserrada 
		 5 = Bloque de plocloruro de vinilo	
		 6 = Adobe, tapia o bahareque frisado
		 7 = Adobe, tapia o bahareque sin frisado
		 8 = Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)  

	VAR: material_pared_exterior = s4q2 
	
	*-- Label values
	label def material_pared_exterior 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete" 4 "" 5 "" 6 "" 7 "" 8 ""
	label value material_pared_exterior material_pared_exterior

		 */

	*-- Label variable
	label var material_pared_exterior "2. El material predominante de las paredes exteriores es:"
	*-- Label values
	label def material_pared_exterior 1 "Bloque, ladrillo frisado" 2 "Bloque ladrillo sin frisar" /// 
		 3 "Concreto" 4 "Madera aserrada" 5 "Bloque de plocloruro de vinilo" ///
		 6 "Adobe, tapia o bahareque frisado" 7 "Adobe, tapia o bahareque sin frisado" ///
		 8 "Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)"  
	label value material_pared_exterior material_pared_exterior


*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
		 
	VAR: material_techo = s4q3 */
	*-- Label variable
	label var material_techo "3. El material predominante del techo es"
	*-- Label values
	label def material_techo_en 1 "Platabanda (concreto o tablones)"	
		 2 "Tejas o similar"
		 3 "Lamina asfaltica"		
		 4 "Laminas metalicas (zinc, aluminio y similares)"    
		 5 "Materiales de desecho (tablon, tablas o similares, palma)"
	label val material_techo material_techo_en
	
*** Type of dwelling
/* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
		1 = Casa Quinta
		2 = Casa
		3 = Apartamento en edificio
		4 = Anexo en casaquinta
		5 = Vivienda rustica (rancho)
		6 = Habitacion en vivienda o local de trabajo
		7 = Rancho campesino
		
	VAR: tipo_vivienda = s4q4	
*/
	*-- Label variable
	label var tipo_vivienda "Type of dwelling"
	*-- Label values
	label def tipo_vivienda_en 1 "Detached house" ///
		2 "House" 3 "Apartament in building complex" ///
		4 "Annex in detached house" 5 "Vivienda rustica (rancho)" ///
		6 "Room in a house or in workplace" ///
		7 "Rancho campesino"
	label val tipo_vivienda tipo_vivienda_en
	
*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda?
		1 = Acueducto
		2 = Pila o estanque
		3 = Camion Cisterna
		4 = Pozo con bomba
		5 = Pozo protegido
		6 = Otros medios
		
		VAR: suministro_agua =  s4q5__1
*/
		
		*-- Label variable
		label var suministro_agua "5. Últimos 3 meses:principales fuentes de suministro de agua en esta vivienda:"

		*-- Label values
		label def suministro_agua 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Pozo con bomba" 5 "Pozo protegido" 6 "Otros medios"
		label value suministro_agua suministro_agua

		* Comparable across all years
		*-- Label variable
		label var suministro_agua_comp "5. Últimos 3 meses:principales fuentes de suministro de agua en esta vivienda:"
		*-- Label values
		label def suministro_agua_comp 1 "Acueducto" 2 "Pila o estanque" 3 "Camion Cisterna" 4 "Otros medios"
		label value suministro_agua_comp suministro_agua_comp

*** Frequency of water supply
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda?
        1 = Todos los dias
		2 = Algunos dias de la semana
		3 = Una vez por semana
		4 = Una vez cada 15 dias
		5 = Nunca
		
		VAR: frecuencia_agua = s4q6
*/
		*-- Label variable
		label var frecuencia_agua "6. Últimos 3 meses: frecuencia suministro agua por acueducto (tubería de calle)"
		*-- Label values
		label def frecuencia_agua 1 "Todos los dias" ///
		2 "Algunos dias de la semana" ///
		3 "Una vez por semana" ///
		4 "Una vez cada 15 dias" ///
		5 "Nunca" 
		label val frecuencia_agua frecuencia_agua


*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/

		*-- Label variable
		label var serv_elect_red_pub "Ultimos 3 meses, el servicio electrico ha sido suministrado por? La red publica"
		*-- Label variable
		label var serv_elect_planta_priv "Ultimos 3 meses, el servicio electrico ha sido suministrado por? Planta electrica privada"
		*-- Label variable
		label var serv_elect_otro "Ultimos 3 meses, el servicio electrico ha sido suministrado por? Otra forma"
		*-- Label variable
		label var electricidad "Ultimos 3 meses, el servicio electrico ha sido suministrado por? No tiene servicio electrico"
		*-- Label variable
		label def sino 1 "Si" 0 "No"
		label val serv_elect_red_pub sino
		label val serv_elect_planta_priv sino
		label val serv_elect_otro sino
		label val electricidad sino

*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe
			1 = Diariamente por varias horas
			2 = Alguna vez a la semana por varias horas
			3 = Alguna vez al mes
			4 = Nunca se interrumpe			
	VAR: interrumpe_elect = s4q8		
*/
		*-- Label variable
		label var interrumpe_elect "En esta vivienda el servicio electrico se interrumpe"
		*-- Label values
		label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
		label value interrumpe_elect interrumpe_elect
		tab interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene 
		1 = Poceta a cloaca
		2 = Pozo septico
		3 = Poceta sin conexion (tubo)
		4 = Excusado de hoyo o letrina
		5 = No tiene poceta o excusado
		99 = NS/NR
		
	VAR: tipo_sanitario_comp
	
		1 "Poceta a cloaca/Pozo septico" 
		2 "Poceta sin conexion" 
		3 "Excusado de hoyo o letrina" 
		4 "No tiene poseta o excusado"
*/
		*-- Label variable
		label var tipo_sanitario_comp "Type of toilet"
		*-- Label values
		label def tipo_sanitario_en 1 "Toilet with flush (connected to public sewerage system of cesspit)" ///
		2 "Toilet but not connected" 3 "Toilet without flush" ///
		4 "Without toilet"
		label value tipo_sanitario_comp tipo_sanitario_comp_en

*** Number of rooms used exclusively to sleep
/* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
	VAR: ndormi= s5q1  //up to 9 */
 
		*-- Label variable
		label var ndormi "Number of rooms used exclusively to sleep"
*** Bath with shower 
/* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
VAR: banio_con_ducha = s5q2*/
		*-- Label variable
		label var banio_con_ducha "Bath with shower"
		*-- Label values
		label def banio_con_ducha_en 1 "Yes" 0 "No"
		label val banio_con_ducha banio_con_ducha_en
		
*** Number of bathrooms with shower
/* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 */
		*-- Label variable
		label var nbanios "Number of bathrooms with shower"
		
*** Housing tenure
/* TENENCIA_VIVIENDA (s5q7): régimen de  de la vivienda  
		1 = Propia pagada		
		2 = Propia pagandose
		3 = Alquilada
		4 = Alquilada parte de la vivienda
		5 = Adjudicada pagandose Gran Mision Vivienda
		6 = Adjudicada Gran Mision Vivienda
		7 = Cedida por razones de trabajo
		8 = Prestada por familiar o amigo
		9 = Tomada
		10 = Otra
*/
clonevar tenencia_vivienda = s5q7 if (s5q7!=. & s5q7!=.a)
gen tenencia_vivienda_comp=1 if tenencia_vivienda==1
replace tenencia_vivienda_comp=2 if tenencia_vivienda==2
replace tenencia_vivienda_comp=3 if tenencia_vivienda==3 | tenencia_vivienda==4
replace tenencia_vivienda_comp=4 if tenencia_vivienda==8
replace tenencia_vivienda_comp=5 if tenencia_vivienda==9
replace tenencia_vivienda_comp=6 if tenencia_vivienda==5 | tenencia_vivienda==6
replace tenencia_vivienda_comp=7 if tenencia_vivienda==7 | tenencia_vivienda==10
label define tenencia_vivienda_comp 1 "Propia pagada" 2 "Propia pagandose" 3 "Alquilada" 4 "Prestada" 5 "Invadida" 6 "De algun programa de gobierno" 7 "Otra"
label value tenencia_vivienda_comp tenencia_vivienda_comp

*-- Label variable
label var tenencia_vivienda "Housing tenure (this survey)"
*-- Label values
label def tenencia_vivienda_en 1 "Propia pagada" 2 "Propia pagandose" ///
		3 "Alquilada" 4 "Alquilada parte de la vivienda" ///
		5 "Adjudicada pagandose Gran Mision Vivienda" /// 
		6 "Adjudicada Gran Mision Vivienda
		7 "Cedida por razones de trabajo
		8 "Prestada por familiar o amigo
		9 "Tomada
		10 "Otra
label val 

*-- Label variable
label var tenencia_vivienda_comp "Housing tenure (harmonized)"
*-- Label values
label def
label val 


*** How much did you pay for rent or mortgage the last month?
gen pago_alq_mutuo=s5q8a if s5q8a!=. & s5q8a!=.a

*** In which currency did you make the payment?
gen pago_alq_mutuo_mon=s5q8b if s5q8b!=. & s5q8b!=.a

*** In which month did you make the payment?
gen pago_alq_mutuo_m=s5q8c if s5q8c!=. & s5q8c!=.a

*** During the last year, have you had arrears in payments?
gen atrasos_alq_mutuo=(s5q9==1) if s5q9!=. & s5q9!=.a

*** What consequences did the arrears in payments had?
gen implicancias_nopago=s5q10 if s5q10!=. & s5q10!=.a

*** If you had to rent similar dwelling, how much did you think you should pay?
gen renta_imp_en=s5q11 if s5q11!=. & s5q11!=.a

*** In which currency ?
gen renta_imp_mon=s5q11a if s5q11a!=. & s5q11a!=.a

*** What type of property title do you have?
gen titulo_propiedad=s5q12 if s5q12!=. & s5q12!=.a

*** What are the main sources of drinking water in your household?
* Acueducto
gen fagua_acueduc=s5q13__1 if s5q13__1!=. & s5q13__1!=.a
* Pila o estanque
gen fagua_estanq=s5q13__2 if s5q13__2!=. & s5q13__2!=.a
* Camión cisterna
gen fagua_cisterna=s5q13__3 if s5q13__3!=. & s5q13__3!=.a
* Pozo con bomba
gen fagua_bomba=s5q13__4 if s5q13__4!=. & s5q13__4!=.a
* Pozo protegido
gen fagua_pozo=s5q13__5 if s5q13__5!=. & s5q13__5!=.a
* Aguas superficiales (manantial,río, lago, canal de irrigación)
gen fagua_manantial=s5q13__6 if s5q13__6!=. & s5q13__6!=.a
* Agua embotellada
gen fagua_botella=s5q13__7 if s5q13__7!=. & s5q13__7!=.a
* Otros
gen fagua_otro=s5q13__8 if s5q13__8!=. & s5q13__8!=.a

*** In your household, is the water treated to make it drinkable
gen tratamiento_agua=(s5q14==1) if s5q14!=. & s5q14!=.a

*** How do you treat the water to make it more safe for drinking
gen tipo_tratamiento=s5q15 if s5q15!=. & s5q15!=.a

*** Which type of fuel do you use for cooking?
gen comb_cocina=s5q16 if s5q16!=. & s5q16!=.a

*** Did you pay for the following utilities?
* Water
gen pagua=(s5q17__1==1) if s5q17__1!=. & s5q17__1!=.a 
* Electricity
gen pelect=(s5q17__2==1) if s5q17__2!=. & s5q17__2!=.a
* Gas
gen pgas=(s5q17__3==1) if s5q17__3!=. & s5q17__3!=.a
* Carbon, wood
gen pcarbon=(s5q17__4==1) if s5q17__4!=. & s5q17__4!=.a
* Paraffin
gen pparafina=(s5q17__5==1) if s5q17__5!=. & s5q17__5!=.a
* Landline, internet and tv cable
gen ptelefono=(s5q17__7==1) if s5q17__7!=. & s5q17__7!=.a

*** How much did you pay for the following utilities?
gen pagua_monto=s5q17a1 if s5q17a1!=. & s5q17a1!=.a 
* Electricity
gen pelect_monto=s5q17a2 if s5q17a2!=. & s5q17a2!=.a
* Gas
gen pgas_monto=s5q17a3 if s5q17a3!=. & s5q17a3!=.a
* Carbon, wood
gen pcarbon_monto=s5q17a4 if s5q17a4!=. & s5q17a4!=.a
* Paraffin
gen pparafina_monto=s5q17a5 if s5q17a5!=. & s5q17a5!=.a
* Landline, internet and tv cable
gen ptelefono_monto=s5q17a7 if s5q17a7!=. & s5q17a7!=.a

*** In which currency did you pay for the following utilities?
gen pagua_mon=s5q17b1 if s5q17b1!=. & s5q17b1!=.a 
* Electricity
gen pelect_mon=s5q17b2 if s5q17b2!=. & s5q17b2!=.a
* Gas
gen pgas_mon=s5q17b3 if s5q17b3!=. & s5q17b3!=.a
* Carbon, wood
gen pcarbon_mon=s5q17b4 if s5q17b4!=. & s5q17b4!=.a
* Paraffin
gen pparafina_mon=s5q17b5 if s5q17b5!=. & s5q17b5!=.a
* Landline, internet and tv cable
gen ptelefono_mon=s5q17b7 if s5q17b7!=. & s5q17b7!=.a

*** In which month did you pay for the following utilities?
gen pagua_m=s5q17c1 if s5q17c1!=. & s5q17c1!=.a 
* Electricity
gen pelect_m=s5q17c2 if s5q17c2!=. & s5q17c2!=.a
* Gas
gen pgas_m=s5q17c3 if s5q17c3!=. & s5q17c3!=.a
* Carbon, wood
gen pcarbon_m=s5q17c4 if s5q17c4!=. & s5q17c4!=.a
* Paraffin
gen pparafina_m=s5q17c5 if s5q17c5!=. & s5q17c5!=.a
* Landline, internet and tv cable
gen ptelefono_m=s5q17c7 if s5q17c7!=. & s5q17c7!=.a

*** In your household, have any home appliences damaged due to blackouts or voltage inestability?
gen danio_electrodom=(s5q20==1) if s5q20!=. & s5q20!=.a

foreach x in $dwell_ENCOVI {
replace `x'=. if relacion_en!=1
}

/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/
global dur_ENCOVI auto ncarros anio_auto heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas telefono_fijo

*** Dummy household owns cars
*  AUTO (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
		*-- Label variable
		label var auto "Dispone su hogar de carros de uso familiar que estan en funcionamiento?"
		*-- Label values
		label def auto 1 "Si" 0 "No"
		label val auto auto

*** Number of functioning cars in the household
* NCARROS (s5q4a) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
		*-- Label variable
		label var ncarros "¿De cuantos carros dispone este hogar que esten en funcionamiento?"

*** Year of the most recent car
		*-- Label variable
		label var anio_auto "Indique el año del modelo del carro. Si poseen más de 1, indique más reciente"


*** Does the household have fridge?
* Heladera (s5q6__1): ¿Posee este hogar nevera?
		*-- Label variable
		label var heladera "¿Posee este hogar nevera?"
		*-- Label values
		label def heladera 1 "Si" 0 "No"
		label val heladera heladera

*** Does the household have washing machine?
* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
		*-- Label variable
		label var lavarropas "¿Posee este hogar lavadora?"
		*-- Label values
		label def lavarropas 1 "Si" 0 "No"
		label val lavarropas lavarropas

*** Does the household have dryer
* Secadora (s5q6__3): ¿Posee este hogar secadora? 
		*-- Label variable
		label var secadora "¿Posee este hogar secadora?"
		*-- Label values
		label def secadora 1 "Si" 0 "No"
		label val secadora secadora


*** Does the household have computer?
* Computadora (s5q6__4): ¿Posee este hogar computadora?
		*-- Label variable
		label var computadora "¿Posee este hogar computadora?"
		*-- Label values
		label def computadora 1 "Si" 0 "No"
		label val computadora computadora
		
*** Does the household have internet?
* Internet (s5q6__5): ¿Posee este hogar internet?
		*-- Label variable
		label var internet "¿Posee este hogar internet?"
		*-- Label values
		label def internet 1 "Si" 0 "No"
		label val internet internet

*** Does the household have tv?
* Televisor (s5q6__6): ¿Posee este hogar televisor?
		*-- Label variable
		label var televisor "¿Posee este hogar televisor?"
		*-- Label values
		label def televisor 1 "Si" 0 "No"
		label val televisor televisor

*** Does the household have radio?
* Radio (s5q6__7): ¿Posee este hogar radio? 
		*-- Label variable
		label var radio "¿Posee este hogar radio?"
		*-- Label values
		label def radio 1 "Si" 0 "No"
		label val radio radio

*** Does the household have heater?
* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
		*-- Label variable
		label var calentador "¿Posee este hogar calentador?"
		*-- Label values
		label def calentador 1 "Si" 0 "No"
		label val calentador calentador

*** Does the household have air conditioner?
* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
		*-- Label variable
		label var aire "¿Posee este hogar aire acondicionado?"
		*-- Label values
		label def aire 1 "Si" 0 "No"
		label val aire aire

*** Does the household have cable tv?
* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
		*-- Label variable
		label var tv_cable "¿Posee este hogar TV por cable?"
		*-- Label values
		label def tv_cable 1 "Si" 0 "No"
		label val tv_cable tv_cable

*** Does the household have microwave oven?
* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
		*-- Label variable
		label var microondas "¿Posee este hogar horno microonda?"
		*-- Label values
		label def microondas 1 "Si" 0 "No"
		label val microondas microondas

*** Does the household have landline telephone?
* Teléfono fijo (s5q6__12): telefono_fijo
		*-- Label variable
		label var telefono_fijo "¿Posee este hogar telefono fijo?"
		*-- Label values
		label def telefono_fijo 1 "Si" 0 "No"
		label val telefono_fijo telefono_fijo

/*(************************************************************************************************************************************************* 
*------------------------------------------------------ VII. EDUCATION / EDUCACIÓN -----------------------------------------------------------
*************************************************************************************************************************************************)*/
global educ_ENCOVI contesta_ind_e quien_contesta_e asistio_educ razon_noasis asiste nivel_educ_act g_educ_act regimen_act a_educ_act s_educ_act t_educ_act edu_pub ///
fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
pae pae_frecuencia pae_desayuno pae_almuerzo pae_meriman pae_meritard pae_otra ///
cuota_insc compra_utiles compra_uniforme costo_men costo_transp otros_gastos ///
cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto ///
cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon ///
cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m ///
nivel_educ_en nivel_educ g_educ regimen a_educ s_educ t_educ alfabeto /*titulo*/ edad_dejo_estudios razon_dejo_est_comp

*** Is the "member" answering by himself/herself?
gen contesta_ind_e=s7q0 if (s7q0!=. & s7q0!=.a)
		*-- Label variable
		label var contesta_ind "Esta contestando por si mismo?"
		*-- Label values
		label def contesta_ind 1 "Si" 0 "No"
		label val contesta_ind contesta_ind
		
*** Who is answering instead of "member"?
gen quien_contesta_e=s7q00 if (s7q00!=. & s7q00!=.a)
		*-- Label variable
		label var quien_contesta_e "Quien esta contestando por X?"
		*-- Label values
		label def quien_contesta_e 1 "Jefe del Hogar" ///
		2 "Esposa(o) o Compañera(o)" ///
		3 "Hijo(a)" ///		
		4 "Hijastro(a)" ///
		5 "Nieto(a)" ///	
		6 "Yerno, nuera, suegro (a)" ///
		7 "Padre, madre" ///       
		8 "Hermano(a)" ///
		9 "Cunado(a)" ///         
		10 "Sobrino(a)" ///
		11 "Otro pariente" ///      
		12 "No pariente" ///
		13 "Servicio Domestico" 
		label val quien_contesta_e quien_contesta_e

*** Have you ever attended any educational center? //for age +3
		*-- Label variable
		label var asistio_educ "¿Alguna vez asistió a algún centro educativo como estudiante? (mayores de 3 anos)"
		*-- Label values
		label def asistio_educ 1 "Si" 0 "No"
		label val asistio_educ asistio_educ

*** Reasons for never attending: variable already has labels
/* RAZONES_NO_ASIS (s7q2): Cual fue la principal razon por la que nunca asistio?
		1 = Muy joven
		2 = Escuela distante
		3 = Escuela cerrada
		4 = Muchos paros/inasistencia de maestros
		5 = Costo de los útiles
		6 = Costo de los uniformes
		7 = Enfermedad/discapacidad
		8 = Debía trabajar
		9 = Inseguridad al asistir al centro educativo
		10 = Discriminación
		11 = Violencia
		14 = Obligaciones en el hogar
		15 = No lo considera importante
		16 = Otra, especifique
*/

*** During the period 2019-2020 did you attend any educational center? //for age +3
		*-- Label variable
		label var asiste "Entre 2019 y 2020: asistió a algún centro educativo como estudiante?(mayores de 3 anos)"
		*-- Label values
		label def asiste 1 "Si" 0 "No"
		label val asiste asiste

*** Which is the educational level you are currently attending?
/* NIVEL_EDUC_ACT (s7q4): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  
		1 = Ninguno		
        2 = Preescolar
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado	
*/
		*-- Label variable
		label var nivel_educ_act "¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?"
		*-- Label values
		label def nivel_educ_act 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Media" 5 "Tecnico (TSU)" 6 "Universitario" 7 "Postgrado"
		label value nivel_educ_act nivel_educ_act

*** Which grade are you currently attending
/* G_EDUC_ACT (s7q4a): ¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
		*-- Label variable
		label var g_educ_act "¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)"

*** Regimen de estudios
* REGIMEN_ACT (s7q4b): El regimen de estudios es anual, semestral o trimestral?
		*-- Label variable
		label var regimen_act "El regimen de estudios es anual, semestral o trimestral?"
		*-- Label values
		label def regimen_act 1 "Anual" 2 "Semestral" 3 "Trimestral"
		label value regimen_act regimen_act

*** Which year are you currently attending	?	
/* A_EDUC_ACT (s7q4c): ¿Cuál es el ano al que asiste? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
		*-- Label variable
		label var a_educ_act "¿Cuál es el ano al que asiste?"

*** Which semester are you currently attending?
/* S_EDUC_ACT (s7q4d): ¿Cuál es el semestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/

		*-- Label variable
		label var s_educ_act "¿Cuál es el semestre al que asiste?"


*** Which quarter are you currently attending?
/* T_EDUC_ACT (s7q4e): ¿Cuál esel trimestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
		*-- Label variable
		label var t_educ_act "¿Cuál es el trimestre al que asiste?"

*** Type of educational center
/* TIPO_CENTRO_EDUC (s7q5): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		.
		.a
*/
		*-- Label variable
		label var tipo_centro_educ "¿el centro de educacion donde estudia es:"
		*-- Label values
		label def tipo_centro_educ 1 "Privado" 2 "Publico"
		label value tipo_centro_educ tipo_centro_educ
		
		*-- Label variable
		label var edu_pub "¿el centro de educacion donde estudia es publico"
		*-- Label values
		label def edu_pub 0 "Privado" 1 "Publico"
		label value edu_pub edu_pub

		
*** During this school period, did you stop attending the educational center where you regularly study due to:
* Water failiures
		*-- Label variable
		label var fallas_agua "Alguna vez deja de asistir a clases por: Fallas de agua"
		*-- Label values
		label def fallas_agua 0 "No" 1 "Si"
		label value fallas_agua fallas_agua

* Electricity failures
		*-- Label variable
		label var fallas_elect "Alguna vez deja de asistir a clases por: Fallas de electricidad"
		*-- Label values
		label def fallas_elect 0 "No" 1 "Si"
		label value fallas_elect fallas_elect

* Huelga de personal docente
		*-- Label variable
		label var huelga_docente "Alguna vez deja de asistir a clases por: Huelga docente"
		*-- Label values
		label def huelga_docente 0 "No" 1 "Si"
		label value huelga_docente huelga_docente

* Falta transporte
		*-- Label variable
		label var falta_transporte "Alguna vez deja de asistir a clases por: Falta de trasnporte"
		*-- Label values
		label def falta_transporte 0 "No" 1 "Si"
		label value falta_transporte falta_transporte

* Falta de comida en el hogar
		*-- Label variable
		label var falta_comida_hogar "Alguna vez deja de asistir a clases por: Falta de comida en el hogar"
		*-- Label values
		label def falta_comida_hogar 0 "No" 1 "Si"
		label value falta_comida_hogar falta_comida_hogar

* Falta de comida en el centro educativo
		*-- Label variable
		label var falta_comida_centro "Alguna vez deja de asistir a clases por: Falta de comida en el centro educativo"
		*-- Label values
		label def falta_comida_centro 0 "No" 1 "Si"
		label value falta_comida_centro falta_comida_centro

* Inasistencia del personal docente
		*-- Label variable
		label var inasis_docente "Alguna vez deja de asistir a clases por: Inasistencia de los docentes"
		*-- Label values
		label def inasis_docente 0 "No" 1 "Si"
		label value inasis_docente inasis_docente

* Manifestaciones, movilizaciones o protestas
		*-- Label variable
		label var protestas "Alguna vez deja de asistir a clases por: Manifestaciones, movilizaciones o protestas"
		*-- Label values
		label def protestas 0 "No" 1 "Si"
		label value protestas protestas

* Nunca deje de asistir
		*-- Label variable
		label var nunca_deja_asistir "Alguna vez deja de asistir a clases por: nunca deja de asistir"
		*-- Label values
		label def nunca_deja_asistir 0 "No" 1 "Si"
		label value nunca_deja_asistir nunca_deja_asistir

*** El centro educativo al que asiste cuenta con el programa de alimentacion escolar PAE?
		*-- Label variable
		label var pae "El centro educativo al que asiste cuenta con el programa de alimentacion escolar PAE?"
		*-- Label values
		label def pae 0 "No" 1 "Si"
		label value pae pae
		
*** En el centro educativo al que asiste, el programa PAE funciona:
/* 		1.Todos los días
		2.Solo algunos días
		3.Casi nunca
*/
		*-- Label variable
		label var pae_frecuencia "En el centro educativo al que asiste, el programa PAE funciona:"
		*-- Label values
		label def pae_frecuencia 1 "Todos los días" ///
		2 "Solo algunos días" ///
		3 "Casi nunca"
		label value pae_frecuencia pae_frecuencia

*** En el centro educativo al que asiste, el programa pae ofrece:
* Desayuno
		*-- Label variable
		label var pae_desayuno "En el centro educativo PAE ofrece: desayuno"
		*-- Label values
		label def pae_desayuno 1 "Si" 0 "No"
		label value pae_desayuno pae_desayuno

* Almuerzo
		*-- Label variable
		label var pae_almuerzo "En el centro educativo PAE ofrece: almuerzo"
		*-- Label values
		label def pae_almuerzo 1 "Si" 0 "No"
		label value pae_almuerzo pae_almuerzo

* Merienda en la manana
		*-- Label variable
		label var pae_meriman "En el centro educativo PAE ofrece: merienda a la manana"
		*-- Label values
		label def pae_meriman 1 "Si" 0 "No"
		label value pae_meriman pae_meriman

* Merienda en la tarde
		*-- Label variable
		label var pae_meritard "En el centro educativo PAE ofrece: merienda a la tarde"
		*-- Label values
		label def pae_meritard 1 "Si" 0 "No"
		label value pae_meritard pae_meritard

* Otra
		*-- Label variable
		label var pae_otra "En el centro educativo PAE ofrece: otra"
		*-- Label values
		label def pae_otra 1 "Si" 0 "No"
		label value pae_otra pae_otra

*** Durante el periodo escolar 2019-2020 gasto, consiguio, recibio donancion en alguno de los siguientes conceptos?
* Cuota de inscripción
		*-- Label variable
		label var cuota_insc "Durante 2019-2020 gasto, consiguio, recibio donancion: cuota de inscripcion"
		*-- Label values
		label def cuota_insc 1 "Si" 0 "No"
		label value cuota_insc cuota_insc

* Compra de útiles y libros escolares
		*-- Label variable
		label var compra_utiles "Durante 2019-2020 gasto, consiguio, recibio donancion: útiles y libros escolares"
		*-- Label values
		label def compra_utiles 1 "Si" 0 "No"
		label value compra_utiles compra_utiles

* Compra de uniformes y calzados escolares
		*-- Label variable
		label var compra_uniforme "Durante 2019-2020 gasto, consiguio, recibio donancion: uniformes y calzados escolares"
		*-- Label values
		label def compra_uniforme 1 "Si" 0 "No"
		label value compra_uniforme compra_uniforme

* Costo de la mensualidad
		*-- Label variable
		label var costo_men "Durante 2019-2020 gasto, consiguio, recibio donancion: costo de la mensualidad"
		*-- Label values
		label def costo_men 1 "Si" 0 "No"
		label value costo_men costo_men

* Uso de transporte público o escolar
		*-- Label variable
		label var costo_transp "Durante 2019-2020 gasto, consiguio, recibio donancion: costo transporte público o escolar"
		*-- Label values
		label def costo_transp 1 "Si" 0 "No"
		label value costo_transp costo_transp

* Otros gastos
		*-- Label variable
		label var otros_gastos "Durante 2019-2020 gasto, consiguio, recibio donancion: otros gastos"
		*-- Label values
		label def otros_gastos 1 "Si" 0 "No"
		label value otros_gastos otros_gastos

*** Monto pagado
* Cuota de inscripción
		*-- Label variable
		label var cuota_insc_monto "Monto pagado: cuota de inscripción"

* Compra de útiles y libros escolares
		*-- Label variable
		label var compra_utiles_monto "Monto pagado: compra de útiles y libros escolares"

* Compra de uniformes y calzados escolares
		*-- Label variable
		label var compra_uniforme_monto "Monto pagado: compra de uniformes y calzados escolares"

* Costo de la mensualidad
		*-- Label variable
		label var costo_men_monto "Monto pagado: costo de la mensualidad"

* Uso de transporte público o escolar
		*-- Label variable
		label var costo_transp_monto "Monto pagado: uso de transporte público o escolar"

* Otros gastos
		*-- Label variable
		label var otros_gastos_monto "Monto pagado: otros gastos"


*** Moneda en que se realizo el pago
	* Cuota de inscripción
	*-- Label variable
		label var cuota_insc_mon "Moneda: cuota de inscripcion"
	* Compra de útiles y libros escolares
		*-- Label variable
		label var compra_utiles_mon "Moneda: compra de útiles y libros escolares"
	* Compra de uniformes y calzados escolares
		*-- Label variable
		label var compra_uniforme_mon "Moneda: compra de uniformes y calzados escolares"
	* Costo de la mensualidad
		*-- Label variable
		label var costo_men_mon "Moneda: costo de la mensualidad"
	* Uso de transporte público o escolar
		*-- Label variable
		label var costo_transp_mon "Moneda: uso de transporte público o escolar"
	* Otros gastos
		*-- Label variable
		label var otros_gastos_mon "Moneda: otros gastos"

*** Mes en que se realizo el pago
	* Cuota de inscripción
		*-- Label variable
			label var cuota_insc_m "Mes del pago: cuota de inscripcion"
	* Compra de útiles y libros escolares
		*-- Label variable
			label var compra_utiles_m "Mes del pago: compra de útiles y libros escolares"
	* Compra de uniformes y calzados escolares
		*-- Label variable
		label var compra_uniforme_m "Mes del pago: compra de uniformes y calzados escolares"
	* Costo de la mensualidad
		*-- Label variable
		label var costo_men_m "Mes del pago: costo de la mensualidad"
	* Uso de transporte público o escolar
		*-- Label variable
		label var costo_transp_m "Mes del pago: uso de transporte público o escolar"
	* Otros gastos
		*-- Label variable
		label var otros_gastos_m "Mes del pago: otros gastos"

*** Educational attainment
/* NIVEL_EDUC_EN (s7q11): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  
		1 = Ninguno		
        2 = Preescolar
		3 = Regimen anterior: Basica (1-9)
		4 = Regimen anterior: Media (1-3)
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado
*/
	*-- Label variable
	label var nivel_educ_en  "Último grado, año, semestre o trimestre y de cuál nivel educativo aprobado (encuesta)"

/* NIVEL_EDUC: Comparable across years
		1 = Ninguno		
        2 = Preescolar
		3 = Primaria		
		4 = Media
		5 = Tecnico (TSU)		
		6 = Universitario
		7 = Postgrado			
*/
	*-- Label variable
	label var nivel_educ  "Último grado, año, semestre o trimestre y de cuál nivel educativo aprobado (armonizada)"


*** Which was the last grade you completed?
/* G_EDUC (s7q11a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
	*-- Label variable
	label var g_educ "Ultimo grado que aprobo"
	
*** Cual era el regimen de estudios
* REGIMEN (s7q11ba): El regimen de estudios era anual, semestral o trimestral?

*** Which was the last year you completed?
/** A_EDUC (s7q4b): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
	*-- Label variable
	label var a_educ "Ultimo año que aprobo"

*** Which was the last semester you completed?
/* S_EDUC (emhp27c): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
	*-- Label variable
	label var s_educ "Ultimo semestre que aprobo"

*** Which was the last quarter you completed?
/* T_EDUC (emhp27d): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
	*-- Label variable
	label var t_educ "Ultimo trimestre que aprobo"

***  Literacy
*Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)
	*-- Label variable
	label var alfabeto "Alfabetizado: ha recibido al menos dos años de educacion formal"

/*
*** Obtuvo el titulo respectivo //missing in database
gen titulo = s7q11e==1 if s7q1==1 & (s7q11>=7 & s7q11<=9) 
*/

*** A que edad termini/dejo los estudios
	*-- Label variable
	label var edad_dejo_estudios "A que edad termino/dejo los estudios"

*** Cual fue la principal razon por la que dejo los estudios?
/* RAZONES_ABAN_ESTUDIOS
		1.Terminó los estudios
		2.Escuela distante
		3.Escuela cerrada
		4.Muchos paros/inasistencia de maestros
		5.Costo de los útiles
		6.Costo de los uniformes
		7.Enfermedad/discapacidad
		8.Debía trabajar
		9.No quiso seguir estudiando
		10.Inseguridad al asistir al centro educativo
		11.Discriminación
		12.Violencia
		13.Por embarazo/cuidar a los hijos
		14.Obligaciones en el hogar
		15.No lo considera importante
		16.Otra (Especifique)
*/
