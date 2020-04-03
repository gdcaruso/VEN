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
	*-- Label variable
	label var material_piso "Type of flooring material"
	 *-- Label values
		label def material_piso 1 "Mosaic,granite,vynil, brick.." 2 "Cement" 3 "Ground floor" 4 "Boards" 5 "Other"
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

	VAR: material_pared_exterior = s4q2  */

	*-- Label variable
	label var material_pared_exterior "Type of exterior wall material"
	*-- Label values
	label def material_pared_exterior 1 "Frieze brick" 2 "Non frieze brick" 3 "Concrete" ///
	4 "Wood" 5 "Polyvinyl chloride block" 6 "Adobe, mud or frieze bahareque" 7 "Adobe, mud or non frieze bahareque" 8 "Other"
	label value material_pared_exterior material_pared_exterior

*** Type of roofing material
/* MATERIAL_TECHO (s4q3)
		 1 = Platabanda (concreto o tablones)		
		 2 = Tejas o similar  
		 3 = Lamina asfaltica		
		 4 = Laminas metalicas (zinc, aluminio y similares)    
		 5 = Materiales de desecho (tablon, tablas o similares, palma)
		 
	VAR: material_techo = s4q3 	*/
	*-- Label variable
	label var material_techo "Type of roofing material"
	*-- Label values
	label def material_techo_en 1 "Platabanda (concrete or planks)" ///		
		 2 "Roof tile or similar"  3 "Asphalt sheet" ///
		 4 "Metal sheets (zinc, aluminum and the like)" ///
		 5 "Waste materials (plank, boards or the like, palm)"
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
		label var suministro_agua "Last 3 months: Water supply (this survey)"		

		*-- Label values
		label var suministro_agua_en 1 "From pipeline" 2 "Pile or pond" ///
		3 "Distributed by water tanker truck"	4 "Connected to water pump"	5 "Connected but no water pump" ///
		6 "Other"
		*-- Label variable
		label var suministro_agua_comp "Last 3 months: Water supply (harmonized)"
		*-- Label values
		label def suministro_agua_comp_en 1 "From pipeline" 2 "Pile or pond" ///
		3 "Distributed by water tanker truck" 4 "Other"
		label value suministro_agua_comp suministro_agua_comp_en

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
		label var frecuencia_agua "Last 3 months: Frequency of water supply"
		*-- Label values
		label def frecuencia_agua_en 1 "Every day" 2 "Some days every week" ///
		3 "Once a week"	4 "Once every two weeks" ///
		5 "Never"
		label val frecuencia_agua frecuencia_agua_en

*** Electricity
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por?
            s4q7_1 = La red publica
			s4q7_2 = Planta electrica privada
			s4q7_3 = Otra forma
			s4q7_4 = No tiene servicio electrico
*/

		*-- Label variable
		label var serv_elect_red_pub "Last 3 months, electricity supply: public"
		*-- Label variable
		label var serv_elect_planta_priv "Last 3 months, electricity supply: private"
		*-- Label variable
		label var serv_elect_otro "Last 3 months, electricity supply: other"
		*-- Label variable
		label var  electricidad "Last 3 months, electricity supply: without electricity"
		label def elec 1 "Yes" 0 "No"
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
		3 "Once a months" 4 "Never" 
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
		label def implicancias_nopago 1 "Vendió activos del hogar para cancelar" ///
							          2 "Solicitó ayuda a familiares" ///
									  3 "Alquiló algún cuarto de la vivienda 
									  4 "Buscó un segundo trabajo para aumentar" ///
                                      5 "Otra"
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
//label var 
//gen serv_elect_red_pub=s4q7__1 if s4q7__1!=. & s4q7__1!=.a
*-- Label variable
//gen serv_elect_planta_priv=s4q7__2 if s4q7__2!=. & s4q7__2!=.a
*-- Label variable
//gen serv_elect_otro=s4q7__3 if s4q7__3!=. & s4q7__3!=.a
*-- Label variable
//gen electricidad= (s4q7__1==1 | s4q7__2==1 | s4q7__3==1)  if (s4q7__1!=. & s4q7__1!=.a & s4q7__2!=. & s4q7__2!=.a & s4q7__3!=. & s4q7__3!=.a)
* tab s4q7__4

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
		3 "Once a months" 4 "Never" 
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
		6 = Adjudicada Gran Mision Vivienda
		7 = Cedida por razones de trabajo
		8 = Prestada por familiar o amigo
		9 = Tomada
		10 = Otra
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
gen     auto = s5q4==1		if  s5q4!=. & s5q4!=.a
replace auto = .		if  relacion_en!=1 

*** Number of functioning cars in the household
* NCARROS (s5q4a) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
gen     ncarros = s5q4a if s5q4==1 & (s5q4a!=. & s5q4a!=.a)
replace ncarros = .		if  relacion_en!=1 

*** Year of the most recent car
gen anio_auto= s5q5 if s5q4==1 & (s5q5!=. & s5q5!=.a)
replace anio_auto = . if relacion_en==1

*** Does the household have fridge?
* Heladera (s5q6__1): ¿Posee este hogar nevera?
gen     heladera = s5q6__1==1 if (s5q6__1!=. & s5q6__1!=.a)
replace heladera = .		if  relacion_en!=1 

*** Does the household have washing machine?
* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
gen     lavarropas = s5q6__2==1 if (s5q6__2!=. & s5q6__2!=.a)
replace lavarropas = .		if  relacion_en!=1 

*** Does the household have dryer
* Secadora (s5q6__3): ¿Posee este hogar secadora? 
gen     secadora = s5q6__3==1 if (s5q6__3!=. & s5q6__3!=.a)
replace secadora = .		if  relacion_en!=1 

*** Does the household have computer?
* Computadora (s5q6__4): ¿Posee este hogar computadora?
gen computadora = s5q6__4==1 if (s5q6__4!=. & s5q6__4!=.a)
replace computadora = .		if  relacion_en!=1 

*** Does the household have internet?
* Internet (s5q6__5): ¿Posee este hogar internet?
gen     internet = s5q6__5==1 if (s5q6__5!=. & s5q6__5!=.a)
replace internet = .	if  relacion_en!=1 

*** Does the household have tv?
* Televisor (s5q6__6): ¿Posee este hogar televisor?
gen     televisor = s5q6__6==1 if (s5q6__6!=. & s5q6__6!=.a)
replace televisor = .	if  relacion_en!=1 

*** Does the household have radio?
* Radio (s5q6__7): ¿Posee este hogar radio? 
gen     radio = s5q6__7==1 if (s5q6__7!=. & s5q6__7!=.a)
replace radio = .		if  relacion_en!=1 

*** Does the household have heater?
* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
gen     calentador = s5q6__8==1 if (s5q6__8!=. & s5q6__8!=.a)
replace calentador = .		if  relacion_en!=1 

*** Does the household have air conditioner?
* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
gen     aire = s5q6__9==1 if (s5q6__9!=. & s5q6__9!=.a)
replace aire = .		    if  relacion_en!=1 

*** Does the household have cable tv?
* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
gen     tv_cable = s5q6__10==1 if (s5q6__10!=. & s5q6__10!=.a)
replace tv_cable = .		if  relacion_en!=1

*** Does the household have microwave oven?
* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
gen     microondas = s5q6__11==1 if (s5q6__11!=. & s5q6__11!=.a)
replace microondas = .		if  relacion_en!=1

*** Does the household have landline telephone?
* Teléfono fijo (s5q6__12): telefono_fijo
gen     telefono_fijo = s5q6__12==1 if (s5q6__12!=. & s5q6__12!=.a)
replace telefono_fijo = .		    if  relacion_en!=1 
