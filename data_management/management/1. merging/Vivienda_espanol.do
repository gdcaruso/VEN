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
