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
		6 "Room in a house or workplace" ///
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
		label var  electricidad "Last 3 months: had access to electricity"
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

 * Label from harmonization
 
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
		label var tipo_sanitario "Tipo sanitario (encuesta)"
		*-- Label values
		label def tipo_sanitario 1 "Poceta a cloaca" ///
		2 "Pozo septico" ///
		3 "Poceta sin conexion (tubo)" ///
		4 "Excusado de hoyo o letrina" ///
		5 "No tiene poceta o excusado" 
		label val tipo_sanitario tipo_sanitario
		
		*-- Label variable
		label var tipo_sanitario_comp "Tipo sanitario (armonizacion)"
		*-- Label values
		label def tipo_sanitario_comp_en 1 "Poceta a cloaca/Pozo septico" ///
		2 "Poceta sin conexion" ///
		3 "Excusado de hoyo o letrina" ///
		4 "No tiene poseta o excusado"
		label value tipo_sanitario_comp tipo_sanitario_comp_en

*** Number of rooms used exclusively to sleep
/* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
	VAR: ndormi= s5q1  //up to 9 */
 
 * Label from harmonization
		
*** Bath with shower 
/* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera?
VAR: banio_con_ducha = s5q2*/

 * Label from harmonization
		
*** Number of bathrooms with shower
/* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 */

 * Label from harmonization
		
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
		label var tenencia_vivienda "Regimen de tenencia de la vivienda (encuesta)"
		*-- Label variable
		label var tenencia_vivienda_comp "Regimen de tenencia de la vivienda (armonizada)"

		
		*** How much did you pay for rent or mortgage the last month?
		*-- Label variable
		* Label from harmonization
		
		*** In which currency did you make the payment?
		*-- Label variable
		* Label from harmonization
		
		*** In which month did you make the payment?
		*-- Label variable
		* Label from harmonization
	
		*** During the last year, have you had arrears in payments?
		*-- Label variable
		* Label from harmonization
		
		*** What consequences did the arrears in payments had?
		*-- Label variable
	    * Label from harmonization

		*** If you had to rent similar dwelling, how much did you think you should pay?
		*-- Label variable
	    * Label from harmonization

		*** In which currency ?
		*-- Label variable
	    * Label from harmonization

		*** What type of property title do you have?
		*-- Label variable
	    * Label from harmonization

*** What are the main sources of drinking water in your household?
		* Acueducto
		*-- Label variable
	    * Label from harmonization
		
		* Pila o estanque
		*-- Label variable
	    * Label from harmonization
		
		* Camión cisterna
		*-- Label variable
	    * Label from harmonization
		
		* Pozo con bomba
		*-- Label variable
	    * Label from harmonization
		
		* Pozo protegido
		*-- Label variable
	    * Label from harmonization
		
		* Aguas superficiales (manantial,río, lago, canal de irrigación)
		*-- Label variable
	    * Label from harmonization
		
		* Agua embotellada
		*-- Label variable
	    * Label from harmonization
		
		* Otros
		*-- Label variable
	    * Label from harmonization

		*** In your household, is the water treated to make it drinkable
	    * Label from harmonization
		
		*** How do you treat the water to make it more safe for drinking
	    * Label from harmonization
		
		*** Which type of fuel do you use for cooking?
		*-- Label variable
	    * Label from harmonization

*** Did you pay for the following utilities?
* Water
	    * Label from harmonization
		*-- Label values
		label def pagua 1 "Si" 0 "No"
		label val pagua pagua

* Electricity
	    * Label from harmonization
		*-- Label values
		label def pelect 1 "Si" 0 "No"
		label val pelect pelect
		
		* Gas
	    * Label from harmonization
		label def pgas 1 "Si" 0 "No"
		label val pgas pgas

		* Carbon, wood
	    * Label from harmonization
		label def pcarbon 1 "Si" 0 "No"
		label val pcarbon pcarbon
		
		* Paraffin
	    * Label from harmonization
		label def pparafina 1 "Si" 0 "No"
		label val pparafina pparafina 
		
		* Landline, internet and tv cable
	    * Label from harmonization
		label def ptelefono 1 "Si" 0 "No"
		label val ptelefono ptelefono
		
*** How much did you pay for the following utilities?		
		* Water
		*-- Label variable
		label var pagua_monto "Monto pagado por servicio de: Agua"
		
		* Electricity
		*-- Label variable
		label var pelect_monto "Monto pagado por servicio de: Electricidad y eliminacion de basura"
		
		* Gas
		*-- Label variable
		label var pgas_monto "Monto pagado por servicio de: Gas"
		
		* Carbon, wood
		*-- Label variable
		label var pcarbon_monto "Monto pagado por servicio de: Carbon,leña"
		
		* Paraffin
		*-- Label variable
		label var pparafina_monto "Monto pagado por servicio de: Vela, parafina (alumbrado)"
		
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_monto "Monto pagado por servicio de: Teléfono fijo, Internet y TV por cable"

*** In which currency did you pay for the following utilities?
		* Water
		*-- Label variable
		label var pagua_mon "Moneda en que pago: Agua"
		
		* Electricity
		*-- Label variable
		label var pelect_mon "Moneda en que pago: Electricidad y eliminacion de basura"
		
		* Gas
		*-- Label variable
		label var pgas_mon "Moneda en que pago: Gas"
		
		* Carbon, wood
		*-- Label variable
		label var pcarbon_mon "Moneda en que pago: Carbon,leña"
		
		* Paraffin
		*-- Label variable
		label var pparafina_mon "Moneda en que pago: Vela, parafina (alumbrado)"
		
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_mon "Moneda en que pago: Teléfono fijo, Internet y TV por cable"

*** In which month did you pay for the following utilities?
		* Water
		*-- Label variable
		label var pagagua_m "Mes en que pago: Agua"
		
		* Electricity
		*-- Label variable		
		label var pelect_m "Mes en que pago: Electricidad y eliminacion de basura"
		
		* Gas
		*-- Label variable		
		label var pgas_m "Mes en que pago: Gas"
		
		* Carbon, wood
		*-- Label variable
		label var pcarbon_m "Mes en que pago: Carbon,leña"
		
		* Paraffin
		*-- Label variable
		label var pparafina_m "Mes en que pago: Vela, parafina (alumbrado)"
		
		* Landline, internet and tv cable
		*-- Label variable
		label var ptelefono_m "Mes en que pago: Teléfono fijo, Internet y TV por cable"

*** In your household, have any home appliences damaged due to blackouts or voltage inestability?
		*-- Label variable
		*-- Label values
		label def danio_electrodom 1 "Si" 0 "No"
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


/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Dummy household owns cars
*  AUTO (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
		*-- Label variable
		label var auto "Dummy household owns cars"
		*-- Label values
		label def auto 1 "Yes" 0 "No"
		label val auto auto

*** Number of functioning cars in the household
* NCARROS (s5q4a) : ¿De cuantos carros dispone este hogar que esten en funcionamiento?
		*-- Label variable
		label var ncarros "Number of functioning cars in the household"

*** Year of the most recent car
		*-- Label variable
		label var anio_auto "Year of the most recent car"


*** Does the household have fridge?
* Heladera (s5q6__1): ¿Posee este hogar nevera?
		*-- Label variable
		label var heladera "Does the household have fridge?"
		*-- Label values
		label def heladera 1 "Yes" 0 "No"
		label val heladera heladera

*** Does the household have washing machine?
* Lavarropas (s5q6__2): ¿Posee este hogar lavadora?
		*-- Label variable
		label var lavarropas "Does the household have washing machine?"
		*-- Label values
		label def lavarropas 1 "Yes" 0 "No"
		label val lavarropas lavarropas

*** Does the household have dryer
* Secadora (s5q6__3): ¿Posee este hogar secadora? 
		*-- Label variable
		label var secadora "Does the household have dryer"
		*-- Label values
		label def secadora 1 "Yes" 0 "No"
		label val secadora secadora


*** Does the household have computer?
* Computadora (s5q6__4): ¿Posee este hogar computadora?
		*-- Label variable
		label var computadora "Does the household have computer?"
		*-- Label values
		label def computadora 1 "Yes" 0 "No"
		label val computadora computadora
		
*** Does the household have internet?
* Internet (s5q6__5): ¿Posee este hogar internet?
		*-- Label variable
		label var internet "Does the household have internet?"
		*-- Label values
		label def internet 1 "Yes" 0 "No"
		label val internet internet

*** Does the household have tv?
* Televisor (s5q6__6): ¿Posee este hogar televisor?
		*-- Label variable
		label var televisor "Does the household have tv?"
		*-- Label values
		label def televisor 1 "Yes" 0 "No"
		label val televisor televisor

*** Does the household have radio?
* Radio (s5q6__7): ¿Posee este hogar radio? 
		*-- Label variable
		label var radio "Does the household have radio?"
		*-- Label values
		label def radio 1 "Yes" 0 "No"
		label val radio radio

*** Does the household have heater?
* Calentador (s5q6__8): ¿Posee este hogar calentador? //NO COMPARABLE CON CALEFACCION FIJA
		*-- Label variable
		label var calentador "Does the household have heater?"
		*-- Label values
		label def calentador 1 "Yes" 0 "No"
		label val calentador calentador

*** Does the household have air conditioner?
* Aire acondicionado (s5q6__9): ¿Posee este hogar aire acondicionado?
		*-- Label variable
		label var aire "Does the household have air conditioner?"
		*-- Label values
		label def aire 1 "Yes" 0 "No"
		label val aire aire

*** Does the household have cable tv?
* TV por cable o satelital (s5q6__10): ¿Posee este hogar TV por cable?
		*-- Label variable
		label var tv_cable "Does the household have cable tv?"
		*-- Label values
		label def tv_cable 1 "Yes" 0 "No"
		label val tv_cable tv_cable

*** Does the household have microwave oven?
* Horno microonada (s5q6__11): ¿Posee este hogar horno microonda?
		*-- Label variable
		label var microondas "Does the household have microwave oven?"
		*-- Label values
		label def microondas 1 "Yes" 0 "No"
		label val microondas microondas

*** Does the household have landline telephone?
* Teléfono fijo (s5q6__12): telefono_fijo
		*-- Label variable
		label var telefono_fijo "Does the household have landline telephone?"
		*-- Label values
		label def telefono_fijo 1 "Yes" 0 "No"
		label val telefono_fijo telefono_fijo
		
/*(************************************************************************************************************************************************* 
*------------------------------------------------------ VII. EDUCATION / EDUCACIÓN -----------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Is the "member" answering by himself/herself?
		*-- Label variable
		label var contesta_ind "Is the 'member' answering by himself/herself?"
		*-- Label values
		label def contesta_ind 1 "Yes" 0 "No"
		label val contesta_ind contesta_ind
		
*** Who is answering instead of "member"?
		*-- Label variable
		label var contesta_ind "Who is answering instead of 'member'?"
		*-- Label values
		label def contesta_ind 1 "Head of the household" ///	
		02 "Spouse/partner"
		03 "Son/daughter"		
		04 "Stepson/stepdaughter"
		05 "Grandchild"	
		06 "Son/daugther/father/mother-in-law"
		07 "Father/mother"       
		08 "Sibling"
		09 "Brother/sister-in-law"     
		10 "Nephew/niece"
		11 "Other relative"    
		12 "Other: non relative"
		13 "House maid"
		label val contesta_ind contesta_ind

*** Have you ever attended any educational center? //for age +3
		*-- Label variable
		label var asistio_educ "Have you ever attended any educational center? (for age +3)"
		*-- Label values
		label def asistio_educ 1 "Yes" 0 "No"
		label val asistio_educ asistio_educ

*** Reasons for never attending
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
clonevar razon_noasis = s7q2 if s7q1==2 & (s7q2!=. & s7q2!=.a)
		*-- Label variable
		label var razon_noasis "Reasons for never attending"
		*-- Label values
		label def razon_noasis 1 "Too young" ///
		2 "The school is too far" ///
		3 "The school is closed"
		4 "Strikes/teachers absences"
		5 "Cost of school supplies"
		6 "Cost of school uniform"
		7 "Illness/disability"
		8 "Must work"
		9 "Insecurity when attending the educational center"
		10 "Discrimination"
		11 "Violence"
		14 "Duties in the household"
		15 "Attending school is not important"
		16 "Other. Mention it"
		label val razon_noasis razon_noasis

*** During the period 2019-2020 did you attend any educational center? //for age +3
		*-- Label variable
		label var asiste "During the period 2019-2020 did you attend any educational center? (for age +3)"
		*-- Label values
		label def asiste 1 "Yes" 0 "No"
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
		label var nivel_educ_act "During the period 2019-2020 did you attend any educational center? (for age +3)"
		*-- Label values
		label def nivel_educ_act 1 "None" ///		
        2 "Kindergarten"
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"	
		label val nivel_educ_act nivel_educ_act


*** Which grade are you currently attending
/* G_EDUC_ACT (s7q4a): ¿Cuál es el grado al que asiste? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
		*-- Label variable
		label var g_educ_act  "Which grade are you currently attending. For Regimen Actual: Primary and Media"

*** Regimen de estudios
* REGIMEN_ACT (s7q4b): El regimen de estudios es anual, semestral o trimestral?
		*-- Label variable
		label var regimen_act "Educational regimen (current): Annual, Biannual ot quarterly"
		*-- Label values
		label def regimen_act 1 "Annual" 2 "Biannual" 3 "Quarterly"
		label val regimen_act regimen_act

*** Which year are you currently attending	?	
/* A_EDUC_ACT (s7q4c): ¿Cuál es el ano al que asiste? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
		*-- Label variable
		label var a_educ_act "Which year are you currently attending?"

*** Which semester are you currently attending?
/* S_EDUC_ACT (s7q4d): ¿Cuál es el semestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
		*-- Label variable
		label var s_educ_act "Which semester are you currently attending?"


*** Which quarter are you currently attending?
/* T_EDUC_ACT (s7q4e): ¿Cuál esel trimestre al que asiste? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
		*-- Label variable
		label var t_educ_act "Which quarter are you currently attending?"

*** Type of educational center
/* TIPO_CENTRO_EDUC (s7q5): ¿el centro de educacion donde estudia es:
		1 = Privado
		2 = Publico
		.
		.a
*/

		*-- Label variable
		label var tipo_centro_educ "The educational center is: (this survey)"
		*-- Label values
		label def tipo_centro_educ 1 "Private" 2 "Public"
		label value tipo_centro_educ tipo_centro_educ
		
		*-- Label variable
		label var edu_pub "The educational center is:(harmonized)"
		*-- Label values
		label def edu_pub 0 "Private" 1 "Public"
		label value edu_pub edu_pub

*** During this school period, did you stop attending the educational center where you regularly study due to:
* Water failiures
		*-- Label variable
		label var fallas_agua "Have you ever stopped attending the educational center where you regularly study due to: water failiures"
		*-- Label values
		label def fallas_agua 0 "No" 1 "Yes"
		label value fallas_agua fallas_agua

* Electricity failures
		*-- Label variable
		label var fallas_elect "Have you ever stopped attending the educational center where you regularly study due to: electricity failiures"
		*-- Label values
		label def fallas_elect 0 "No" 1 "Yes"
		label value fallas_elect fallas_elect

* Teachers' strike
		*-- Label variable
		label var huelga_docente "Have you ever stopped attending the educational center where you regularly study due to: teachers' strike"
		*-- Label values
		*-- Label values
		label def huelga_docente 0 "No" 1 "Yes"
		label value huelga_docente huelga_docente

* Lack of means of transport
		*-- Label variable
		label var falta_transporte "Have you ever stopped attending the educational center where you regularly study due to: lack of means of transport"
		label def falta_transporte 0 "No" 1 "Yes"
		label value falta_transporte falta_transporte

* Lack of food in the household
		*-- Label variable
		label var falta_comida_hogar "Have you ever stopped attending the educational center where you regularly study due to: lack of food in the household"
		*-- Label values
		label def falta_comida_hogar 0 "No" 1 "Yes"
		label value falta_comida_hogar falta_comida_hogar

* Lack of food in the educational center
		*-- Label variable
		label var falta_comida_centro "Have you ever stopped attending the educational center where you regularly study due to: lack of food in the educational center"
		*-- Label values
		label def falta_comida_centro 0 "No" 1 "Yes"
		label value falta_comida_centro falta_comida_centro

* Teachers's non-attendance
		*-- Label variable
		label var inasis_docente "Have you ever stopped attending the educational center where you regularly study due to: teachers's non-attendance"
		*-- Label values
		label def inasis_docente 0 "No" 1 "Yes"
		label value inasis_docente inasis_docente

* Demonstrations or protests
		*-- Label variable
		label var protestas "Have you ever stopped attending the educational center where you regularly study due to: demonstrations or protests"
		*-- Label values
		label def protestas 0 "No" 1 "Yes"
		label value protestas protestas

* Never stopped attending 
		*-- Label variable
		label var nunca_deja_asistir "Have you ever stopped attending the educational center where you regularly study due to: never stopped attending "
		*-- Label values
		label def nunca_deja_asistir 0 "No" 1 "Yes"
		label value nunca_deja_asistir nunca_deja_asistir

*** The educational center where you attend has PAE's schools feeding program?
		*-- Label variable
		label var pae "The educational center where you attend has PAE's schools feeding program?"
		*-- Label values
		label def pae 0 "No" 1 "Yes"
		label value pae pae

*** In the educational center where you attend, PAE's schools feeding program is provided:
/* 		1.Every day
		2.Only few days
		3.Hardly ever
*/
		*-- Label variable
		label var pae_frecuencia "In the educational center where you attend, PAE's schools feeding program is provided:"
		*-- Label values
		label def pae_frecuencia 1 "Every day" ///
		2 "Only few days" ///
		3 "Hardly ever"
		label value pae_frecuencia pae_frecuencia

*** In the educational center where you attend, PAE's schools feeding program provides:
	* Breakfast
		*-- Label variable
		label var pae_desayuno "In the educational center where you attend, PAE's provides: breakfast"
		*-- Label values
		label def pae_desayuno 1 "Yes" 0 "No"
		label value pae_desayuno pae_desayuno

	* Lunch
		*-- Label variable
		label var pae_almuerzo "In the educational center where you attend, PAE's provides: lunch"
		*-- Label values
		label def pae_almuerzo 1 "Yes" 0 "No"
		label value pae_almuerzo pae_almuerzo

	* Snack in the morning (Merienda en la manana)
		*-- Label variable
		label var pae_meriman "In the educational center where you attend, PAE's provides: snack in the morning"
		*-- Label values
		label def pae_meriman 1 "Yes" 0 "No"
		label value pae_meriman pae_meriman

	* Snack in the afternoon (Merienda en la tarde)
		*-- Label variable
		label var pae_meritard "In the educational center where you attend, PAE's provides: snack in the afternoon"
		*-- Label values
		label def pae_meritard 1 "Yes" 0 "No"
		label value pae_meritard pae_meritard

	* Other
		*-- Label variable
		label var pae_otra "In the educational center where you attend, PAE's provides: other"
		*-- Label values
		label def pae_otra 1 "Yes" 0 "No"
		label value pae_otra pae_otra

*** During school year 2019-2020 did you pay for, obtain or receive donation of the following items?
	* Registration fee (Cuota de inscripción)
		*-- Label variable
		label var cuota_insc "During 2019-2020 did you pay for, obtain or receive donation of: registration fee"
		*-- Label values
		label def cuota_insc 1 "Yes" 0 "No"
		label value cuota_insc cuota_insc

	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
		label var compra_utiles "During 2019-2020 did you pay for, obtain or receive donation of: school supplies and books"
		*-- Label values
		*-- Label values
		label def compra_utiles 1 "Yes" 0 "No"
		label value compra_utiles compra_utiles

	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme "During 2019-2020 did you pay for, obtain or receive donation of: school uniforms and footwear"
		*-- Label values
		label def compra_uniforme 1 "Yes" 0 "No"
		label value compra_uniforme compra_uniforme

	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men "During 2019-2020 did you pay for, obtain or receive donation of: monthly fee"
		*-- Label values
		label def costo_men 1 "Yes" 0 "No"
		label value costo_men costo_men

	* Public transport or school bus(Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp "During 2019-2020 did you pay for, obtain or receive donation of: public transport or school bus"
		*-- Label values
		label def costo_transp 1 "Yes" 0 "No"
		label value costo_transp costo_transp

	* Other expenses
		*-- Label variable
		label var otros_gastos "During 2019-2020 did you pay for, obtain or receive donation of: other expenses"
		*-- Label values
		label def otros_gastos 1 "Yes"0 "No"
		label value otros_gastos otros_gastos

*** Amount paid for each item
	* Registration fee (Cuota de inscripción)
		*-- Label variable
		label var cuota_insc_monto "Amount: registration fee"

	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
		label var compra_utiles_monto "Amount: school supplies and books"

	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme_monto "Amount: school uniforms and footwear"

	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men_monto "Amount: monthly fee"

	* Public transport or school bus (Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp_monto "Amount: Public transport or school bus"

	* Other expenses
		*-- Label variable
		label var otros_gastos_monto "Amount: other expenses"

*** Currency unit 
* Registration fee (Cuota de inscripción)
	*-- Label variable
		label var cuota_insc_mon "Currency unit: registration fee"
	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
		label var compra_utiles_mon "Currency unit: school supplies and books"
	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme_mon "Currency unit: school uniforms and footwear"
	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men_mon "Currency unit: monthly fee"
	* Public transport or school bus (Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp_mon "Currency unit: public transport or school bus"
	* Other expenses
		*-- Label variable
		label var otros_gastos_mon "Currency unit: other expenses"

*** Month in which the item was paid
	* Registration fee (Cuota de inscripción)
		*-- Label variable
			label var cuota_insc_m "Month: registration fee"
	* School supplies and books (Compra de útiles y libros escolares)
		*-- Label variable
			label var compra_utiles_m "Month: school supplies and books"
	* School uniforms and footwear
		*-- Label variable
		label var compra_uniforme_m "Month: school uniforms and footwear"
	* Monthly fee (Costo de la mensualidad)
		*-- Label variable
		label var costo_men_m "Month: monthly fee"
	* Public transport or school bus (Uso de transporte público o escolar)
		*-- Label variable
		label var costo_transp_m "Month: public transport or school bus"
	* Other expenses
		*-- Label variable
		label var otros_gastos_m "Month: other expenses"

*** Educational attainment
/* NIVEL_EDUC_EN (s7q11): ¿Cual fue el ultimo nivel educativo en el que aprobo un grado, ano, semetre, trimestre?  
		1 = None (Ninguno)	
        2 = Preescolar
		3 = Regimen anterior: Basica (1-9)
		4 = Regimen anterior: Media (1-3)
		5 = Regimen actual: Primaria (1-6)		
		6 = Regimen actual: Media (1-6)
		7 = Tecnico (TSU)		
		8 = Universitario
		9 = Postgrado
		
		1 "None" ///		
        2 "Kindergarten" ///
		3 "Regimen anterior: Basica (1-9)" ///
		4 "Regimen anterior: Media (1-3)" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"	
*/
	*-- Label variable
	label var nivel_educ_en  "Education attained (this survey)"
	*-- Label values 
	label def nivel_educ_en 1 "None" ///		
        2 "Kindergarten" ///
		3 "Regimen anterior: Basica (1-9)" ///
		4 "Regimen anterior: Media (1-3)" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"
	label values nivel_educ_en nivel_educ_en	
	
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
	label var nivel_educ "Education attained (harmonized)"
	*-- Label values 	
	label def nivel_educ 1 "None" 2 "Kindergarten" 3 "Primary" 4 "Media" 5 "Tecnico (TSU)" 6 "University" 7 "Postgraduated"
	label value nivel_educ nivel_educ

*** Which was the last grade you completed?
/* G_EDUC (s7q11a): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Primaria: 1-6to
        Media: 1-6to
*/
	*-- Label variable
	label var g_educ "Last grade completed"
	
*** Cual era el regimen de estudios
* REGIMEN (s7q11ba): El regimen de estudios era anual, semestral o trimestral?
clonevar regimen = s7q11ba if s7q1==1 & (s7q11>=7 & s7q11<=9) & (s7q11ba!=. & s7q11ba!=.a)
	*-- Label variable
	label var regimen "Educational regimen (completed): Annual, Biannual ot quarterly"
	*-- Label values
	label def regimen 1 "Annual" 2 "Biannual" 3 "Quarterly"
	label val regimen regimen

*** Which was the last year you completed?
/** A_EDUC (s7q4b): ¿Cuál es el último año que aprobó? (variable definida para nivel educativo Primaria y Media)
        Tecnico: 1-3
        Universitario: 1-7
		Postgrado: 1-6
*/
	*-- Label variable
	label var a_educ "Last year completed"

*** Which was the last semester you completed?
/* S_EDUC (emhp27c): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-6 semestres
		Universitario: 1-14 semestres
		Postgrado: 1-12 semestres
*/
	*-- Label variable
	label var s_educ "Last semester completed"

*** Which was the last quarter you completed?
/* T_EDUC (emhp27d): ¿Cuál es el último semestre que aprobó? (variable definida para nivel educativo Tecnico, Universitario y Postgrado)
		Tecnico: 1-9 semestres
		Universitario: 1-21 semestres
		Postgrado: 1-18
*/
	*-- Label variable
	label var t_educ "Last quarter completed"

***  Literacy
*Alfabeto:	alfabeto (si no existe la pregunta sobre si la persona sabe leer y escribir, consideramos que un individuo esta alfabetizado si ha recibido al menos dos años de educacion formal)

	*-- Label variable
	label var alfabeto "Literate: received at least two years of formal education"
	*-- Label values
	label def alfabeto 1 "Yes" 0 "No"
	label val alfabeto alfabeto

/*
*** Obtuvo el titulo respectivo //missing in database
gen titulo = s7q11e==1 if s7q1==1 & (s7q11>=7 & s7q11<=9) 
*/

*** A que edad termini/dejo los estudios
	*-- Label variable
	label var edad_dejo_estudios "Age when completed/left studies"

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
		
		1 "Completed studies" ///
		2 "The school was too far" ///
		3 "The school closed" ///
		4 "Strikes/teachers absences" ///
		5 "Cost of school supplies" ///
		6 "Cost of school uniform" ///
		7 "Illness/disability" ///
		8 "Must work" ///
		9 "Do not wanted to continue studying" ///
		10 "Insecurity when attending the educational center" ///
		11 "Discrimination" ///
		12 "Violence" ///
		13 "Pregnancy/take care of children" ///
		14 "Duties in the household" ///
		15 "Attending school was not important" ///
		16 "Other. Mention it"

*/
	*-- Label variable
	label var razon_dejo_estudios "Main reason: left studies (this survey)"
	*-- Label values	
	label def razon_dejo_estudios 	1 "Completed studies" ///
		2 "The school was too far" ///
		3 "The school closed" ///
		4 "Strikes/teachers absences" ///
		5 "Cost of school supplies" ///
		6 "Cost of school uniform" ///
		7 "Illness/disability" ///
		8 "Must work" ///
		9 "Do not wanted to continue studying" ///
		10 "Insecurity when attending the educational center" ///
		11 "Discrimination" ///
		12 "Violence" ///
		13 "Pregnancy/take care of children" ///
		14 "Duties in the household" ///
		15 "Attending school was not important" ///
		16 "Other. Mention it"
	label val razon_dejo_estudios razon_dejo_estudios 
	

	*-- Label variable
	label var razon_dejo_est_comp "Main reason: left studies (harmonized)"
	*-- Label values	
	label def razon_dejo_est_comp 	1 "Completed studies" ///
		2 "The school was too far" ///
		3 "The school closed" ///
		4 "Strikes/teachers absences" ///
		5 "Cost of school supplies" ///
		6 "Cost of school uniform" ///
		7 "Illness/disability" ///
		8 "Must work" ///
		9 "Do not wanted to continue studying" ///
		10 "Insecurity when attending the educational center" ///
		11 "Discrimination or violence" ///
		12 "Pregnancy/take care of children" ///
		13 "Duties in the household" ///
		14 "Attending school was not important" ///
		15 "Other. Mention it"
	label val razon_dejo_est_comp razon_dejo_est_comp

/*(*********************************************************************************************************************************************** 
*---------------------------------------------------------- 10: Emigration ----------------------------------------------------------
***********************************************************************************************************************************************)*/	
*--------- Informant in this section
 /* Informante (s10q00): 00. Quién es el informante de esta sección?
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
		
		1 "Head of the household" ///	
		2 "Spouse/partner"
		3 "Son/daughter"		
		4 "Stepson/stepdaughter"
		5 "Grandchild"	
		6 "Son/daugther/father/mother-in-law"
		7 "Father/mother"       
		8 "Sibling"
		9 "Brother/sister-in-law"     
		10 "Nephew/niece"
		11 "Other relative"    
		12 "Other: non relative"
		13 "House maid"
 */
	
	*-- Label variable
	label var informant_emig "Informant: Emigration"
	*-- Label values	
	label def informant_emig  1 "Head of the household" 2 "Spouse/partner" 3 "Son/daughter/stepson/stepdaughter" ///
							  4 "Grandchild" 5 "Son/daugther/father/mother-in-law" 6 "Father/mother" 7 "Sibling" ///
							  8 "Brother/sister-in-law" 9 "Nephew/niece" 10 "Other relative" 11 "Other: non relative" ///
							  12 "House maid"
	label value informant_emig  informant_emig 


*--------- Emigrant from the household
 /* Emigrant(s10q1): 1. Duante los últimos 5 años, desde septiembre de 2014, 
	¿alguna persona que vive o vivió con usted en su hogar se fue a vivir a otro país?
         1 = Si
         2 = No
 */

	*-- Label variable
	label var hogar_emig "During last 5 years: any person who live/lived in the household left the country" 
	*-- Label values
	label def house_emig 1 "Yes" 2 "No"
	label value hogar_emig house_emig

*--------- Number of Emigrants from the household
 /* Number of Emigrants from the household(s10q2): 2. Cuántas personas?
 
 */

	*-- Label variable
	label var numero_emig "Number of Emigrants from the household"
	
*--------- Name of Emigrants from the household
 /* Name of Emigrants from the household(s10q2a): 2. Cuántas personas?
        
 */	
	
	*-- We will have 10 variables with names
	forval i = 0/9{
	label var nombre_emig_`i' "Name of Emigrants from the household"
	}

	
 *--------- Age of the emigrant
 /* Age of the emigrant(s10q3): 3. Cuántos años cumplidos tiene X?
        
 */
 	*-- We will have 10 variables with names	
	forval i = 1/10 {
		*-- Label variable
		label var edad_emig_`i' "Age of Emigrants"
		
	}
	
	
 *--------- Sex of the emigrant 
 /* Sex (s10q4): 4. El sexo de X es?
				01 Masculino
				02 Femenino
				
 */
 	*-- We will have 10 variables with names
	forval i = 1/10 {
		*-- Label variable
		label var sexo_emig_`i' "Sex of Emigrants"
		*-- Label values
		label def sexo_emig_`i' 1 "Male" 0 "Female"
		label value sexo_emig_`i' sexo_emig_`i'
		}
		
	
 /*
 *--------- Relationship of the emigrant with the head of the household
 Relationship (s10q5): 5. Cuál es el parentesco de X con el Jefe(a) del hogar?
        
 */ 
	*-- We will have 10 variables with names	
	forval i = 1/10 {
	*-- Label variable
	label var relemig_`i' "Emigrant's relationship with the head of the household"
	*-- Label values
	label def remig_`i' 1 "Head of the household" 2 "Spouse/partner" 3 "Son/daughter/stepson/stepdaughter" ///
							  4 "Grandchild" 5 "Son/daugther/father/mother-in-law" 6 "Father/mother" 7 "Sibling" ///
							  8 "Brother/sister-in-law" 9 "Nephew/niece" 10 "Other relative" 11 "Other: non relative" ///
							  12 "House maid"
	label value relemig_`i' remig_`i'
	}
	
	
 *--------- Year in which the emigrant left the household
 /* Year (s10q6a): 6a. En qué año se fue X ?
        
 */	
	*-- We will have 10 variables with names 
	forval i = 1/10 {
	*-- Label variable
	label var anoemig_`i' "Year of emigration"
	}
	
	
 *--------- Month in which the emigrant left the household
 /* Month (s10q6b): 6a. En qué mes se fue X ?
        
 */	
	*-- We will have 10 variables with names
	forval i = 1/10 {
	*-- Label variable
	label var mesemig_`i' "Month of emigration"
	*-- Label values
	label def mesemig_`i' 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" ///
	6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label val mesemig_`i' mesemig_`i'
	}


  *--------- Latest education level atained by the emigrant 
 /* Education level (s10q7): 7. Cuál fue el último nivel educativo en el que
							 X aprobó un grado, año, semestre o trimestre?  
			01 Ninguno
			02 Preescolar
			03 Régimen anterior: Básica (1-9)
			04 Régimen anterior: Media Diversificado y Profesional (1-3)
			05 Régimen actual: Primaria (1-6)
			06 Régimen actual: Media (1-6)
			07 Técnico (TSU)
			08 Universitario
			09 Postgrado

 */
 	
	*-- Given that the maximum number of emigrantes per household is 10 
	forval i = 1/10 {
	*-- Label variable
	label var leveledu_emig_`i' "Education level emigrant"
	*-- Label values
	label def leveledu_emig_`i' 1 "None" ///		
        2 "Kindergarten" ///
		3 "Regimen anterior: Basica (1-9)" ///
		4 "Regimen anterior: Media (1-3)" ///
		5 "Regimen actual: Primary(1-6)" ///
		6 "Regimen actual: Media (1-6)" ///
		7 "Tecnico (TSU)" ///		
		8 "University" ///
		9 "Postgraduated"
	label val leveledu_emig_`i' leveledu_emig_`i'
	}
	

 *--------- Latest education grade atained by the emigrant 
 /* Education level (s10q7a): 7a. Cuál fue el último GRADO aprobado por X?     
 */	
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var gradedu_emig_`i' "Education grade emigrant"
	
	}
	

 *--------- Education regime 
 /* Education regime (s10q7ba): 7ba. El régimen de estudio era anual, semestral o
							   trimestral?
								01 Anual
								02 Semestral
								03 Trimestral     
 */	
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var regedu_emig_`i' "Education regime: annual, biannual or quarterly"
	*-- Label values
	label def regedu_emig_`i' 1 "Annual" 2 "Biannual" 3 "Quarterly"
	label value regedu_emig_`i' regedu_emig_`i'
	}
	
 *--------- Latest year 
 /* Education regime (s10q7b): 7b. Cuál fue el último AÑO aprobado por X?    
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var anoedu_emig_`i' "Last year of education attained"
	*-- Cross check
	tab anoedu_emig_`i' hogar_emig
	}

  *--------- Latest semester
 /* Education regime (s10q7c): 7c. Cuál fue el último SEMESTRE aprobado por X?   
 */
 	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var semedu_emig_`i' "Last semester of education attained"
	}

  *--------- Country of residence of the emigrant
 /* Country (s10q8): 8. En cuál país vive actualmente X?   
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var paisemig_`i' "Country in which X lives"
	}

  *--------- Other country of residence 
 /* Other Country (s10q8_os): 8a. Otro país, especifique
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var opaisemig_`i' "Country in which X lives (Other)"
	}

  *--------- City of residence 
 /* City (s10q8b): 8b. Y en cuál ciudad ?
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var ciuemig_`i' "City in which X lives"
	}

   *--------- Emigrated alone or not
 /* Alone (s10q8c): 8c. X emigró solo/a ?	
					01 Si
					02 No
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var soloemig_`i' "Has X emigrated alone"
	*-- Label values
	label def soloemig_`i' 1 "Yes" 0 "No"
	label value soloemig_`i' soloemig_`i'
	}


  *--------- Emigrated with other people 
 /*  (s10q8d):8d. Con quién emigró X?				
				01 Padre/madre
				02 Hermano/a
				03 Conyuge/pareja
				04 Hijos/hijas
				05 Otro pariente
				06 No parientes
 */
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var conemig_`i' "Who emigrated with X"
	*-- Label values
	label def conemig_`i' 1 "Father/Mother" 2 "Brother/sister" 3 "Partner" 4 "Son/daughter" 5 "Other relative" 6 "Non relative"
	label value conemig_`i' conemig_`i'
	} 

  *--------- Reason for leaving the country
 /*  Reason (s10q9_os):9. Cuál fue el motivo por el cual X se fue				
						01 Fue a buscar/consiguió trabajo
						02 Cambió su lugar de trabajo
						03 Por razones de estudio
						04 Reagrupación familiar
						05 Se casó o unió
						06 Por motivos de salud
						07 Por violencia e inseguridad
						08 Por razones políticas
						09 Otro
						
						1 "Left looking for/got a job"
						2 "The location of the workplace changed"
						3 "Education/studies"
						4 "Family reunification"
						5 "Marriage/concubinage"
						6 "Health reasons"
						7 "Violence/insecurity"
						8 "Political reasons"
						9 "Other"
 */
  	*-- Given that the maximum number of emigrantes per household is 10 
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var razonemig_`i' "Why X emigrated"
	*-- Label values
	label def razonemig_`i' 1 "Left looking for/got a job" ///
						2 "The location of the workplace changed" ///
						3 "Education/studies" ///
						4 "Family reunification" ///
						5 "Marriage/concubinage" ///
						6 "Health reasons" ///
						7 "Violence/insecurity" ///
						8 "Political reasons" ///
						9 "Other"
	label val razonemig_`i' razonemig_`i'
	} 

  *--------- Occupation: Before leaving the country
 /*  Occupation before (s10q10):10. Cuál era la ocupación principal de X antes de emigrar?
			
					01 Director o gerente
					02 Profesional científico o intelectual
					03 Técnico o profesional de nivel medio
					04 Personal de apoyo administrativo
					05 Trabajador de los servicios o vendedor de comercios y mercados
					06 Agricultor o trabajador calificado agropecuario, forestal o pesquero
					07 Oficial, operario o artesano de artes mecánicas y otros oficios
					08 Operador de instalaciones fijas y máquinas y maquinarias
					09 Ocupaciones elementales
					10 Ocupaciones militares
					11 No se desempeñaba en alguna ocupación	
					
					 1 "Director or manager" 
					 2 "Scientific or intellectual professional" 
					 3 "Technician or mid-level professional" 
					 4 "Administrative support staff" 
                     5 "Service worker or seller of shops and markets" 
					 6 "Farmer or skilled agricultural, forestry or fishing worker" 
                     7 "Official, operator or craftsman of mechanical arts and other trades" 
					 8 "Operator of fixed installations and machines and machinery" ///
                     9 "Elementary occupations" 
					10 "Military occupations"
					11 "Without occupation"
 */    
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var ocupaemig_`i' "Which was X occupation before leaving"
	*-- Label values
	label def ocupaemig_`i' 1 "Director or manager" ///
					 2 "Scientific or intellectual professional" ///
					 3 "Technician or mid-level professional" ///
					 4 "Administrative support staff" ///
                     5 "Service worker or seller of shops and markets" /// 
					 6 "Farmer or skilled agricultural, forestry or fishing worker" /// 
                     7 "Official, operator or craftsman of mechanical arts and other trades" ///
					 8 "Operator of fixed installations and machines and machinery" ///
                     9 "Elementary occupations" ///
					10 "Military occupations" ///
					11 "Without occupation"
	label val ocupaemig_`i'	ocupaemig_`i'				
	} 

   *--------- Occupation: in the new country
 /*  Occupation now (s10q11): 11. Qué ocupación tiene X en el país donde vive ?
			
					01 Director o gerente
					02 Profesional científico o intelectual
					03 Técnico o profesional de nivel medio
					04 Personal de apoyo administrativo
					05 Trabajador de los servicios o vendedor de comercios y mercados
					06 Agricultor o trabajador calificado agropecuario, forestal o pesquero
					07 Oficial, operario o artesano de artes mecánicas y otros oficios
					08 Operador de instalaciones fijas y máquinas y maquinarias
					09 Ocupaciones elementales
					10 Ocupaciones militares
					11 No se desempeñaba en alguna ocupación			
 */    
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var ocupnemig_`i' "Which is X occupation now"
	*-- Label values
	label def ocupnemig_`i' 1 "Director or manager" ///
					 2 "Scientific or intellectual professional" ///
					 3 "Technician or mid-level professional" ///
					 4 "Administrative support staff" ///
                     5 "Service worker or seller of shops and markets" /// 
					 6 "Farmer or skilled agricultural, forestry or fishing worker" /// 
                     7 "Official, operator or craftsman of mechanical arts and other trades" ///
					 8 "Operator of fixed installations and machines and machinery" ///
                     9 "Elementary occupations" ///
					10 "Military occupations" ///
					11 "Without occupation"
	label val ocupnemig_`i' ocupnemig_`i'
	} 

 
    *--------- The emigrant moved back to the country
 /*  Moved back (s10q12): 12. X regresó a residenciarse nuevamente al país?
							1 Si
							0 No
		
 */    
	*-- We will have 10 variables with names
	forval i = 1/10{
	*-- Label variable
	label var volvioemig_`i' "Does X moved back to the country?"
	*-- Label values
	label def volvioemig_`i' 1 "Yes" 0 "No"
	label value volvioemig_`i' volvioemig_`i'
	} 


     *--------- Year: The emigrant moved back to the country
 /*  Year (s10q13a): 13a. En qué año regresó X?
		
 */    
	forval i = 1/10{
	*-- Label variable
	label var volvioanoemig_`i' "Year: X moved back to the country?"
	} 

      *--------- Month: The emigrant moved back to the country
 /*  Month (s10q13b): 13b. En qué mes regresó X?
		
 */ 
 	forval i = 1/10{
	*-- Label variable
	label var volviomesemig_`i' "Month: X moved back to the country?"
	} 

 
      *--------- Member of the household
 /*  Member (s10q14):14. En el presente X forma parte de este hogar?
						1 Si
						0 No
	
 */   
 	forval i = 1/10{
	*-- Label variable
	label var miememig_`i' "Is X a member of the household?"
	*-- Label values
	label def miememig_`i' 1 "Yes" 0 "No"
	label value miememig_`i' miememig_`i'
	} 

/*(************************************************************************************************************************************************ 
*---------------------------------------- XV: SHOCKS AFFECTING HOUSEHOLDS / EVENTOS QUE AFECTAN A LOS HOGARES -------------------------------------
************************************************************************************************************************************************)*/

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
	
	*-- Label variable
	label var informant_shock "Informant: shocks affecting households"
	*-- Label values	
	label def informant_shock  1 "Head of the household" 2 "Spouse/partner" 3 "Son/daughter/stepson/stepdaughter" ///
							  4 "Grandchild" 5 "Son/daugther/father/mother-in-law" 6 "Father/mother" 7 "Sibling" ///
							  8 "Brother/sister-in-law" 9 "Nephew/niece" 10 "Other relative" 11 "Other: non relative" ///
							  12 "House maid"
	label value informant_shock  informant_shock 


*--------- Events which affected the household
 /* Events(s15q1): 1. Cuáles de los siguientes eventos han afectado a
su hogar desde el año 2017 ?
         0 = No
         1 = Si
 */

	forval i = 1/21{
	*-- Label values 
	label def evento_`i' 0 "No" 1 "Yes"
	label value evento_`i' evento_`i'
	}
	
*-- Label variable
	*-- Label variable
	label var evento_1 "Since 2017, the household faced: dead or disability of an adult memeber which worked"
	label var evento_2 "Since 2017, the household faced: dead of a person which used to send remittances"
	label var evento_3 "Since 2017, the household faced: illness of the person with the most important household income"
	label var evento_4 "Since 2017, the household faced: loss of important contact"
	label var evento_5 "Since 2017, the household faced: the member with the most important household income lost his/her job"
	label var evento_6 "Since 2017, the household faced: Exit of family member which earned income due to divorce/separation"
	label var evento_7 "Since 2017, the household faced: Exit of family member which earned income due to marriage"
	label var evento_8 "Since 2017, the household faced: Emigration of a member of the household that earned income"
	label var evento_9 "Since 2017, the household faced: Non-agricultural business failure/closing of business or venture"
	label var evento_10 "Since 2017, the household faced: theft of crops, cash, livestock or other assets"
	label var evento_11 "Since 2017, the household faced: crop loss due to fire/drought/floods"
	label var evento_12 "Since 2017, the household faced: pest invasion that caused crop failure or loss of storage"
	label var evento_13 "Since 2017, the household faced: damaged/demolished home"
	label var evento_14 "Since 2017, the household faced: loss of property due to fire or flood"
	label var evento_15 "Since 2017, the household faced: loss of land"
	label var evento_16 "Since 2017, the household faced: dead of livestock due to disease"
	label var evento_17 "Since 2017, the household faced: higher cost of supplies"
	label var evento_18 "Since 2017, the household faced: lower prices of products"
	label var evento_19 "Since 2017, the household faced: higher prices of the main sources of food"
	label var evento_20 "Since 2017, the household faced: kidnapping/robbery/assault"
	label var evento_21 "Since 2017, the household faced: other"
	
	*-- Label variable
	label var evento_ot "Mention other shocks which affected your household"
	
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
	
	*-- Label variable
	*-- Label variable
	label var imp_evento_1 "Importance: dead or disability of an adult memeber which worked"
	label var imp_evento_2 "Importance: dead of a person which used to send remittances"
	label var imp_evento_3 "Importance: illness of the person with the most important household income"
	label var imp_evento_4 "Importance: loss of important contact"
	label var imp_evento_5 "Importance: the member with the most important household income lost his/her job"
	label var imp_evento_6 "Importance: exit of family member which earned income due to divorce/separation"
	label var imp_evento_7 "Importance: exit of family member which earned income due to marriage"
	label var imp_evento_8 "Importance: emigration of a member of the household that earned income"
	label var imp_evento_9 "Importance: non-agricultural business failure/closing of business or venture"
	label var imp_evento_10 "Importance: theft of crops, cash, livestock or other assets"
	label var imp_evento_11 "Importance: crop loss due to fire/drought/floods"
	label var imp_evento_12 "Importance: pest invasion that caused crop failure or loss of storage"
	label var imp_evento_13 "Importance: damaged/demolished home"
	label var imp_evento_14 "Importance: loss of property due to fire or flood"
	label var imp_evento_15 "Importance: loss of land"
	label var imp_evento_16 "Importance: dead of livestock due to disease"
	label var imp_evento_17 "Importance: higher cost of supplies"
	label var imp_evento_18 "Importance: lower prices of products"
	label var imp_evento_19 "Importance: higher prices of the main sources of food"
	label var imp_evento_20 "Importance: kidnapping/robbery/assault"
	label var imp_evento_21 "Importance: other"

 *--------- How many times have the shock occurred since 2017
 /* (s15q2a)2a. Cuántas veces ocurrió %rostertitle% desde 2017?
 */

	forval i = 1/21 {
		*-- Label variable
		label var veces_evento_`i' "How many times have the shock occurred since 2017"
		}
		
	
 /*
 *--------- Year of the event
 (s15q2b) 2b. En qué año ocurrió ?
        
 */ 

	forval i = 1/21 {
	*-- Label variable
	label var ano_evento_`i' "Year of the event"
	}
	

 *--------- How the houselhold coped with the shock
 /* (s15q2c): 2c. Cómo se las arregló su hogar con el choque más reciente?*/
 
local x 1 2 3 4 5 6 8 9 10 12 13 14 15 16 17 18 19 20 21 22 23 24
	foreach i of local x {
		forval k = 1/21 {
	label var reaccion_evento_`i'_`k' "Response to event"
	*-- Label values
	label def reaccion_evento_`i'_`k' 0 "Non code" 1 "Selling livestock" 2 "Selling land" 3 "Selling property" ///
	4 "Sending the children to live with friends" 5 "Stopped sending children to school" ///
	6 "Working in other income generating activities" ///
	8 "Received assiatnce from friends and relatives" 9 "Loans from friends and family" ///
	10 "Loans from financial institution" ///
	12 "Members of the household emigrated looking for a job" ///
	13 "Credit purchases" 14 "Delayed payment of obligations" ///
	15 "Sold the harvest in advance" 16 "Reduced the consumption of food" /// 
	17 "Reduced consumption of non-food item" 18 "Used savings" ///
	19 "Received assiatnce from a NGO" 20 "Advance payment from employer" ///
	21 "Received assiatence from the government" 22 "The insurance covered the costs" ///
	23 "Nothing" 24 "Other"
	label val reaccion_evento_`i'_`k' reaccion_evento_`i'_`k'
		}
	}
	
 *--------- Other responses to the event
 /* (s15q2d): 2d. Otro arreglo, especifique */	
	forval i = 1/21 {
	*-- Label variable
	label var reaccionot_evento`i' "Other responses to the event"
	}
	