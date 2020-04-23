/*(************************************************************************************************************************************************* 
*------------------------------------------------------- 1.4: Dwelling characteristics -----------------------------------------------------------
*************************************************************************************************************************************************)*/

*** Type of flooring material
/* MATERIAL_PISO (s4q1) */
	*-- Label variable
	label var material_piso " 1. El material predominante del piso"
	 *-- Label values
		label def material_piso 1 "Mosaico, granito, vinil, ladrillo, ceramica, terracota, parquet y similares" ///
		 2 "Cemento" /// 
		 3 "Tierra" ///	
		 4 "Tablas"
		label value material_piso material_piso

*** Type of exterior wall material		 
/* MATERIAL_PARED_EXTERIOR (s4q2) */
	*-- Label variable
	label var material_pared_exterior "2. El material predominante de las paredes exteriores es:"
	*-- Label values
	label def material_pared_exterior 1 "Bloque, ladrillo frisado" 2 "Bloque ladrillo sin frisar" /// 
		 3 "Concreto" 4 "Madera aserrada" 5 "Bloque de plocloruro de vinilo" ///
		 6 "Adobe, tapia o bahareque frisado" 7 "Adobe, tapia o bahareque sin frisado" ///
		 8 "Otros (laminas de zinc, carton, tablas, troncos, piedra, paima, similares)"  
	label value material_pared_exterior material_pared_exterior


*** Type of roofing material
/* MATERIAL_TECHO (s4q3) */
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
* TIPO_VIVIENDA (s4q4): Tipo de Vivienda 
	*-- Label variable
	label var tipo_vivienda "Tipo de vivienda"
	*-- Label values
	label def tipo_vivienda_en 1 "Casa Quinta" ///
		2 "Casa" 3 "Apartamento en edificio" ///
		4 "Anexo en casaquinta" 5 "Vivienda rustica (rancho)" ///
		6 " Habitacion en vivienda o local de trabajo" ///
		7 "Rancho campesino"
	label val tipo_vivienda tipo_vivienda_en
	
*** Water supply
/* SUMINISTRO_AGUA (s4q5): Cuales han sido las principales fuentes de suministro de agua en esta vivienda? */	
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
/* FRECUENCIA_AGUA (s4q6): Con que frecuencia ha llegado el agua del acueducto a esta vivienda? */
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
/* SERVICIO_ELECTRICO : En los ultimos 3 meses, el servicio electrico ha sido suministrado por? */

		*-- Label variable
		label var serv_elect_red_pub "Ultimos 3 meses, el servicio electrico ha sido suministrado por? La red publica"
		*-- Label variable
		label var serv_elect_planta_priv "Ultimos 3 meses, el servicio electrico ha sido suministrado por? Planta electrica privada"
		*-- Label variable
		label var serv_elect_otro "Ultimos 3 meses, el servicio electrico ha sido suministrado por? Otra forma"
		*-- Label variable
		label def sino 1 "Si" 0 "No"
		label val serv_elect_red_pub sino
		label val serv_elect_planta_priv sino
		label val serv_elect_otro sino
		label val electricidad sino

*** Electric power interruptions
/* interrumpe_elect (s4q8): En esta vivienda el servicio electrico se interrumpe */
		*-- Label variable
		label var interrumpe_elect "En esta vivienda el servicio electrico se interrumpe"
		*-- Label values
		label def interrumpe_elect 1 "Diariamente por varias horas" 2 "Alguna vez a la semana por varias" 3 "Alguna vez al mes" 4 "Nunca se interrumpe" 
		label value interrumpe_elect interrumpe_elect
		tab interrumpe_elect

*** Type of toilet
/* TIPO_SANITARIO (s4q9): esta vivienda tiene */
		*-- Label variable
		label var tipo_sanitario_comp "Esta vivienda tiene el siguiente tipo de sanitario..."
		*-- Label values
		label def tipo_sanitario_en 1 "Poceta a cloaca/Pozo septico" ///
		2 "Poceta sin conexion" 3 "Excusado de hoyo o letrina" ///
		4 "No tiene poseta o excusado"
		label value tipo_sanitario_comp tipo_sanitario_comp_en

*** Number of rooms used exclusively to sleep
/* NDORMITORIOS (s5q1): ¿cuántos cuartos son utilizados exclusivamente para dormir por parte de las personas de este hogar? 
	VAR: ndormi= s5q1  //up to 9 */
		*-- Label variable
		label var ndormi "Cantidad de cuartos utilizados exclusivamente para dormir por las personas del hogar"
		
*** Bath with shower 
/* BANIO (s5q2): Su hogar tiene uso exclusivo de bano con ducha o regadera? */
		*-- Label variable
		label var banio_con_ducha "Baño con ducha"
		*-- Label values
		label def banio_con_ducha_en 1 "Yes" 0 "No"
		label val banio_con_ducha banio_con_ducha_en
		
*** Number of bathrooms with shower
/* NBANIOS (s5q3): cuantos banos con ducha o regadera?
clonevar nbanios = s5q3 if banio_con_ducha==1 */
		*-- Label variable
		label var nbanios "Cantidad de baños con ducha"
		
*** Housing tenure
/* TENENCIA_VIVIENDA (s5q7): régimen de  de la vivienda  */

*-- Label variable
label var tenencia_vivienda "Régimen de vivienda (esta encuesta)"
*-- Label values
label def tenencia_vivienda_en 1 "Propia pagada" 2 "Propia pagandose" ///
		3 "Alquilada" 4 "Alquilada parte de la vivienda" ///
		5 "Adjudicada pagandose Gran Mision Vivienda" /// 
		6 "Adjudicada Gran Mision Vivienda" ///
		7 "Cedida por razones de trabajo" ///
		8 "Prestada por familiar o amigo" ///
		9 "Tomada" ///
		10 "Otra"
label val 

*-- Label variable
label var tenencia_vivienda_comp "Régimen de vivienda (armonizada)"



/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/

	foreach i in auto heladera lavarropas computadora internet televisor ///
	radio calentador aire tv_cable microondas telefono_fijo {
	label def siyno 1 "Si" 0 "No"
	label val `i' siyno
	}
	
	
	/*
/*(************************************************************************************************************************************************* 
*--------------------------------------------------------- 1.5: Durables goods  --------------------------------------------------------
*************************************************************************************************************************************************)*/
global dur_ENCOVI auto ncarros anio_auto heladera lavarropas secadora computadora internet televisor radio calentador aire tv_cable microondas telefono_fijo

*** Dummy household owns cars
*  AUTO (s5q4): Dispone su hogar de carros de uso familiar que estan en funcionamiento?
		*-- Label variable
		*label var auto "Dispone su hogar de carros de uso familiar que estan en funcionamiento?"
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
