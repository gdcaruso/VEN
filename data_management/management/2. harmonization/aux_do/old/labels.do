
/*=========================================================================================================================================================================
								2: Preparacion de los datos / Data preparation: Etiquetado de Variables / Variable labeling
==========================================================================================================================================================================*/

/// Spanish ///
/*
label var    pais            "Pais"
label var    ano             "Ano de la encuesta"
label var    encuesta        "Nombre de la encuesta"
label var    id              "Identificacion unica del hogar"
label var    com             "Identificacion del componente"   
label var    pondera         "Factor de ponderacion"
label var    strata          "Variable de estratificacion"   
label var    psu	     	 "Unidad Primaria de Muestreo"

label var    relacion        "Relacion de parentesco con el jefe de hogar (armonizada)"
label def relacion 1 "Jefe" 2 "Cónyuge/Pareja" 3 "Hijo(a)/Hijastro(a)" 4 "Padre/Madre" ///		
		              5 "Hermano/Hermana" 6 "Nieto/Nieta" 7 "Otros familiares" 8 "Otros no familiares"
label values relacion relacion
label var    relacion_en    "Relacion de parentesco con el jefe de hogar (original encuesta)"

label var    hogarsec        "Miembro de un hogar secundario"
label define hogarsec 0 "No" 1 "Si"
label values hogarsec hogarsec

label var    hogar           "Indicador de hogar"
label var    miembros        "Numero de miembros del hogar principal"

label var    presec          "Hogares con miembros secundarios"
label define presec 0 "No" 1 "Si"
label values presec presec

label var    edad            "Edad"

label var    gedad1          "Grupos de edad: 2=[15,24], 3=[25,40], 4=[41,64]"
label define gedad1 1 "[0,14]" 2 "[15,24]" 3 "[25,40]" 4 "[41,64]" 5 "[65+]"
label values gedad1 gedad1

label var    hombre          "Sexo"
label define hombre 0 "Mujer" 1 "Hombre"
label values hombre hombre

label var    jefe            "Dummy de jefe de hogar"
label define jefe 0 "No Jefe" 1 "Jefe"
label values jefe jefe

label var    conyuge         "Dummy de conyuge del jefe de hogar"
label define conyuge 0 "No Conyuge" 1 "Conyuge"
label values conyuge conyuge

label var    hijo            "Dummy de hijo del jefe de hogar"
label define hijo 0 "No Hijo" 1 "Hijo"
label values hijo hijo

label var    nro_hijos       "Numero de hijos menores de 18 anos en el hogar principal"

label var    casado          "Dummy de estado civil: casado o unido"
label define casado 0 "No Casado" 1 "Casado"
label values casado casado

label var    soltero         "Dummy de estado civil: soltero"
label define soltero 0 "No Soltero" 1 "Soltero"
label values soltero soltero

label var    raza            "Raza"
label define raza 1 "Indigena" 2 "Afroamericano" 3 "Indigena y Afroamericano" 4 "Otro"
label values raza raza

*label var    raza_est	     "Variable original de raza de la encuesta (estandarizada)"	 

label var    lengua          "Lengua"
label define lengua 1 "Lengua Occidental" 4 "Lengua Indigena" 5 "Lengua Afroamericana" 6 "Otra lengua" 7 "Pregunta binaria"
label values lengua lengua 

*label var    lengua_est	     "Variable original de lengua de la encuesta (estandarizada)"

label var    propieta        "Es propietario de la vivienda que habita?"
label define propieta 0 "No Propietario" 1 "Propietario"
label values propieta propieta

label var    habita          "Numero de habitaciones de uso exclusivo del hogar"
label var    dormi           "Numero de dormitorios en la vivienda"

label var    precaria        "Vivienda ubicada en lugar precario"
label define precaria 0 "No Precario" 1 "Precario"
label values precaria precaria

label var    matpreca        "Son los materiales de construccion de la vivienda precarios?"
label define matpreca 0 "Materiales no Precarios" 1 "Materiales Precarios"
label values matpreca matpreca

label var    region_est1     "Region geografica desagregacion menor (estandarizada)" 
label var    region_est2     "Region geografica desagregacion intermedia (estandarizada)" 
label var    region_est3     "Region geografica desagregacion mayor (estandarizada)" 

label var    urbano          "Dummy de area de residencia"
label define urbano 0 "Rural" 1 "Urbano"
label values urbano urbano

label var    migrante        "Condicion migratoria"
label define migrante 0 "No migrante" 1 "Migrante"
label values migrante migrante

label var    migra_ext       "Dummy de migrante extranjero"
label define migra_ext 0 "No" 1 "Si"
label values migra_ext migra_ext

label var    migra_rur       "Dummy de migrante nacional rural"
label define migra_rur 0 "No" 1 "Si"

label values migra_rur migra_rur

label var    anios_residencia  "Anos de residencia"

label var    migra_rec       "Migrante reciente"
label define migra_rec 0 "No" 1 "Si"
label values migra_rec migra_rec

label var    nuevareg        "Cobertura geografica de la encuesta"

label var    agua            "Tiene instalacion de agua en la vivienda?"
label define agua 0 "No tiene" 1 "Tiene"
label values agua agua

label var    banio           "Tiene bano higienico en la vivienda?"
label define banio 0 "No tiene" 1 "Tiene"
label values banio banio

label var    cloacas         "Tiene bano conectado a cloacas?"
label define cloacas 0 "No tiene" 1 "Tiene"
label values cloacas cloacas

label var    elect           "Tiene electricidad en la vivienda?"
label define elect 0 "No tiene" 1 "Tiene"
label values elect elect

label var    telef           "Tiene telefono (fijo o celular) en la vivienda?"
label define telef 0 "No tiene" 1 "Tiene"
label values telef telef

label var    heladera        "Tiene heladera en la vivienda?"
label define heladera 0 "No tiene" 1 "Tiene"
label values heladera heladera

label var    lavarropas      "Tiene lavarropas en la vivienda?"
label define lavarropas 0 "No tiene" 1 "Tiene"
label values lavarropas lavarropas

label var    aire            "Tiene aire acondicionado en la vivienda?"
label define aire 0 "No tiene" 1 "Tiene"
label values aire aire

label var    calefaccion_fija "Tiene calefaccion fija en la vivienda?"
label define calefaccion_fija 0 "No tiene" 1 "Tiene"
label values calefaccion_fija calefaccion_fija

label var    telefono_fijo   "Tiene telefono fijo en la vivienda?"
label define telefono_fijo 0 "No tiene" 1 "Tiene"
label values telefono_fijo telefono_fijo

label var    celular         "Tiene telefono celular al menos un miembro del hogar?"
label define celular 0 "No tiene" 1 "Tiene"
label values celular celular

label var    celular_ind     "Tiene telefono celular (individual)"
label define celular_ind 0 "No tiene" 1 "Tiene"
label values celular_ind celular_ind

label var    televisor       "Tiene televisor en la vivienda?"
label define televisor 0 "No tiene" 1 "Tiene"
label values televisor televisor

label var    tv_cable        "Tiene TV por cable o satelital en la vivienda?"
label define tv_cable 0 "No tiene" 1 "Tiene"
label values tv_cable tv_cable

label var    video           "Tiene VCR o DVD en la vivienda?"
label define video 0 "No tiene" 1 "Tiene"
label values video video

label var    computadora     "Tiene computadora en la vivienda?"
label define computadora 0 "No tiene" 1 "Tiene"
label values computadora computadora

label var    internet_casa   "Tiene conexion de internet  en la vivienda?"
label define internet_casa 0 "No tiene" 1 "Tiene"
label values internet_casa internet_casa

label var    uso_internet    "Utiliza internet?"
label define uso_internet 0 "No utiliza" 1 "Utiliza"
label values uso_internet uso_internet

label var    auto            "Tiene automovil el hogar?"
label define auto 0 "No tiene" 1 "Tiene"
label values auto auto

label var    ant_auto        "Anos de antiguedad del automovil"
label var    auto_nuevo      "Dummy de automovil de menos de 5 anos: =1 menos de 5 anos"

label var    moto            "Tiene motocicleta el hogar?"
label define moto 0 "No tiene" 1 "Tiene"
label values moto moto

label var    bici            "Tiene bicicleta el hogar?"
label define bici 0 "No tiene" 1 "Tiene"
label values bici bici

label var    alfabeto        "Dummy de alfabetizacion"
label define alfabeto 0 "No Alfabetizado" 1 "Alfabetizado"
label values alfabeto alfabeto

label var    asiste          "Dummy de asistencia al sistema educativo"
label define asiste 0 "No asiste" 1 "Asiste"
label values asiste asiste

label var    edu_pub         "Dummy de tipo de establecimiento al que asiste"
label define edu_pub 0 "Establecimiento privado" 1 "Establecimiento Publico"
label values edu_pub edu_pub

label var    aedu	     "Anos de educacion aprobados"

label var    nivedu          "Grupos de anos de educacion"
label define nivedu 0 "[0,8]" 1 "[9,13]" 2 "[14+]" 
label values nivedu nivedu

label var    nivel           "Maximo nivel educativo alcanzado"
label define nivel 0 "Nunca Asistio" 1 "Primaria Incompleta" 2 "Primaria Completa" 3 "Secundaria Incompleta" 4 "Secundaria Completa" 5 "Superior Incompleta" 6 "Superior Completa"
label values nivel nivel

label var    prii            "Dummy de maximo nivel educativo alcanzado: =1 si primaria incompleta"
label var    pric            "Dummy de maximo nivel educativo alcanzado: =1 si primaria completa"
label var    seci            "Dummy de maximo nivel educativo alcanzado: =1 si secundaria incompleta"
label var    secc            "Dummy de maximo nivel educativo alcanzado: =1 si secundaria completa"
label var    supi            "Dummy de maximo nivel educativo alcanzado: =1 si superior incompleta"
label var    supc            "Dummy de maximo nivel educativo alcanzado: =1 si superior completa"
label var    exp             "Experiencia potencial"

label var    pea             "Dummy de condicion de actividad: economicamente activo"
label define pea 0 "Inactivo" 1 "Activo"
label values pea pea

label var    ocupado         "Dummy de condicion de actividad: ocupado"
label define ocupado 0 "No ocupado" 1 "Ocupado"
label values ocupado ocupado

label var    desocupa        "Dummy de condicion de actividad: desocupado"
label define desocupa 0 "No desocupado" 1 "Desocupado"
label values desocupa desocupa 

label var    durades          "Duracion del desempleo en meses"
label var    hstrt            "Horas trabajadas en todas las ocupaciones"
label var    hstrp            "Horas trabajadas en la ocupacion principal"

label var    deseamas        "Desea conseguir otro empleo o trabajar mas horas?"
label define deseamas 0 "No" 1 "Si"
label values deseamas deseamas

label var    antigue          "Antiguedad en la ocupacion principal"

label var    relab            "Relación laboral en la ocupación principal"
label define relab 1 "Empleador" 2 "Asalariado" 3 "Cuentapropista" 4 "Sin Salario" 5 "Desocupado"
label values relab relab

label var    relab_s          "Relación laboral en la ocupación secundaria"
label define relab_s 1 "Empleador" 2 "Asalariado" 3 "Cuentapropista" 4 "Sin Salario" 5 "Desocupado"
label values relab_s relab_s

label var    relab_o          "Relación laboral en la ocupación terciaria"
label define relab_o 1 "Empleador" 2 "Asalariado" 3 "Cuentapropista" 4 "Sin Salario" 5 "Desocupado"
label values relab_o relab_o

label var    asal             "Dummy de asalariado en la ocupación principal" 
label define asal 0 "No asalariado" 1 "Asalariado" 
label values asal asal

label var    empresa          "Tipo de empresa en la que trabaja"
label define empresa 1 "Grande" 2 "Chica" 3 "Pública"
label values empresa empresa

label var    grupo_lab        "Grupo laboral" 

label var    categ_lab         "Categoría laboral - Informalidad Productiva"
label define categ_lab 1 "No informal" 2 "Informal" 
label values categ_lab categ_lab

label var    sector1d            "Sector de actividad a 1 digito CIIU" 
label define sector1d 1 "Agricultura, Ganadería, Caza y Silvicultura" 2 "Pesca" 3 "Explotación de Minas y Canteras" 4 "Industrias Manufactureras" 5 "Suministro de Electricidad, Gas y Agua" 6 "Construcción" 7 "Comercio" 8 "Hoteles y Restaurantes" 9 "Transporte, Almacenamiento y Comunicaciones" 10 "Intermediación Financiera" 11 "Actividades Inmobiliarias, Empresariales y de Alquiler" 12 "Administración Pública y Defensa" 13 "Enseñanza" 14 "Servicios Sociales y de Salud" 15 "Otras Actividades de Servicios Comunitarios, Sociales y Personales" 16 "Hogares Privados con Servicio Doméstico" 17 "Organizaciones y Órganos Extraterritoriales" 
label values sector1d sector1d

label var    sector            "Sector de actividad - Clasificación propia"
label var    tarea             "Tarea que realiza en la ocupación principal"

label var    contrato          "Tiene contrato laboral firmado?"
label define contrato 0 "No tiene" 1 "Tiene"
label values contrato contrato

label var    ocuperma          "Es su ocupación permanente o temporaria?"
label define ocuperma 0 "Temporaria" 1 "Permanente"
label values ocuperma ocuperma

label var    djubila           "Tiene derecho a jubilación en su empleo?"
label define djubila 0 "No" 1 "Si"
label values djubila djubila

label var    dsegsale          "Tiene derecho a seguro de salud en su empleo?"
label define dsegsale 0 "No" 1 "Si"
label values dsegsale dsegsale

label var    aguinaldo        "Tiene derecho a recibir aguinaldo en su empleo?"
label define aguinaldo 0 "No" 1 "Si"
label values aguinaldo daguinaldo

label var    dvacaciones       "Tiene derecho a vacaciones pagas en su empleo?"
label define dvacaciones 0 "No" 1 "Si"
label values dvacaciones dvacaciones

label var    sindicato         "Se encuentra afiliado a sindicato?"
label define sindicato 0 "No" 1 "Si"
label values sindicato sindicato

label var    prog_empleo       "Se encuentra ocupado en un programa de empleo?"
label define prog_empleo 0 "No" 1 "Si"
label values prog_empleo prog_empleo

*label var    n_ocu_h           "Número de ocupados en el hogar"

/*label var    asistencia        "Recibe programa de asistencia social?"
label define asistencia 0 "No" 1 "Si"
label values asistencia asistencia*/

label var    dsegsal           "Tiene seguro de salud?"
label define dsegsal 0 "No" 1 "Si"
label values dsegsal dsegsal

label var    iasalp_m          "Ingreso asalariado en la ocupación principal - monetario"
label var    iasalp_nm         "Ingreso asalariado en la ocupación principal - no monetario"
label var    ictapp_m          "Ingreso por cuenta propia en la ocupación principal - monetario"
label var    ictapp_nm         "Ingreso por cuenta propia en la ocupación principal - no monetario"
label var    ipatrp_m          "Ingreso por patrón en la ocupación principal - monetario"
label var    ipatrp_nm         "Ingreso por patrón en la ocupación principal - no monetario"
label var    iolp_m            "Otros ingresos laborales en la ocupación principal - monetario"
label var    iolp_nm           "Otros ingresos laborales en la ocupación principal - no monetario"
label var    iasalnp_m         "Ingreso asalariado en la ocupación no principal - monetario"
label var    iasalnp_nm        "Ingreso asalariado en la ocupación no principal - no monetario"
label var    ictapnp_m         "Ingreso por cuenta propia en la ocupación no principal - monetario"
label var    ictapnp_nm        "Ingreso por cuenta propia en la ocupación no principal - no monetario"
label var    ipatrnp_m         "Ingreso por patrón en la ocupación no principal - monetario"
label var    ipatrnp_nm        "Ingreso por patrón en la ocupación no principal - no monetario"
label var    iolnp_m           "Otros ingresos laborales en la ocupación no principal - monetario"
label var    iolnp_nm          "Otros ingresos laborales en la ocupación no principal - no monetario"
label var    ijubi_m         "Ingreso monetario por jubilaciones y pensiones"
label var    ijubi_nm        "Ingreso no monetario por jubilaciones y pensiones"
*label var    ijubi_o	       "Ingreso por jubilaciones y pensiones (no identificado si contributiva o no)"
label var    icap_m              "Ingreso monetario del capital"
label var    icap_nm             "Ingreso no monetario del capital"
label var    icap             "Ingreso del capital"
label var    cct	       "Ingreso por programas de transferencias monetarias condicionadas"	 
label var    itrane_o_m	       "Ingreso por transferencias estatales no CCT - monetario"	
label var    itrane_o_nm         "Ingreso por transferencias estatales no CCT - no monetario"
label var    itrane_ns         "Ingreso por transferencias estatales no especificadas"
label var    rem               "Ingreso por remesas del exterior - monetario"
*label var    itranext_nm       "Ingreso por remesas del exterior - no monetario"
label var    itranp_o_m        "Ingreso por otras transferencias privadas del país - monetario"
label var    itranp_o_nm       "Ingreso por otras transferencias privadas del país - no monetario"
label var    itranp_ns         "Ingreso por transferencias privadas no especificadas"
label var    inla_otro         "Otros ingresos no laborales"
label var    ipatrp            "Ingreso por patrón en la ocupación principal - total"
label var    iasalp            "Ingreso asalariado en la ocupación principal - total"
label var    ictapp            "Ingreso por cuenta propia en la ocupación principal - total"
label var    iolp	       "Otros ingresos laborales en la ocupación principal - total"
label var    ip_m              "Ingreso en la ocupación principal - monetario"
label var    ip                "Ingreso en la ocupación principal"
label var    wage_m            "Ingreso horario en la ocupación principal - monetario"
label var    wage              "Ingreso horario en la ocupación principal" 
label var    ipatrnp	       "Ingreso por patrón en la ocupación no principal - total"	
label var    iasalnp           "Ingreso asalariado en la ocupación no principal - total"
label var    ictapnp           "Ingreso por cuenta propia en la ocupación no principal - total"
label var    iolnp             "Otros ingresos laborales en la ocupación principal - total"
label var    inp	       "Ingreso por trabajo en la actividad no principal"	 
label var    ipatr_m           "Ingreso por trabajo como patrón - monetario"
label var    ipatr             "Ingreso por trabajo como patrón"
label var    iasal_m           "Ingreso por trabajo como asalariado - monetario" 
label var    iasal             "Ingreso por trabajo como asalariado" 
label var    ictap_m           "Ingreso por trabajo como cuentapropista - monetario"
label var    ictap             "Ingreso por trabajo como cuentapropista"
label var    ila_m             "Ingreso laboral - monetario"
label var    ila               "Ingreso laboral total"
label var    ilaho_m           "Ingreso horario en todas las ocupaciones - monetario"
label var    ilaho             "Ingreso horario en todas las ocupaciones"
label var    perila            "Dummy de perceptor de ingresos laborales: =1 si percibe ingreso laboral"
label var    ijubi             "Ingreso por jubilaciones y pensiones"
label var    itranp_m          "Ingreso por transferencias privadas - monetario"
label var    itranp            "Ingreso por transferencias privadas"
label var    itrane_m          "Ingreso por transferencias estatales - monetario"
label var    itrane            "Ingreso por transferencias estatales"
label var    itran_m           "Ingreso por transferencias - monetario"
label var    itran             "Ingreso por transferencia"
label var    inla_m            "Ingreso no laboral total - monetario"
label var    inla              "Ingreso no laboral total"
label var    ii_m              "Ingreso individual total - monetario" 
label var    ii                "Ingreso individual total"
label var    perii             "Perceptor ingresos"
label var    n_perila_h        "Número de perceptores de ingreso laboral en el hogar"
label var    n_perii_h         "Número de perceptores de ingreso individual en el hogar"
label var    ilf_m             "Ingreso laboral total familiar - monetario"
label var    ilf               "Ingreso laboral total familiar"
label var    inlaf_m           "Ingreso no laboral total familiar - monetario"
label var    inlaf             "Ingreso no laboral total familiar"
label var    itf_m             "Ingreso total familiar - monetario"
label var    itf_sin_ri        "Ingreso total familiar sin renta imputada"
label var    renta_imp         "Renta imputada de la vivienda propia"
label var    itf               "Ingreso total familiar"
label var    cohi              "Indicador de respuesta de ingresos: =1 si coherente - individual"
label var    cohh              "Indicador de respuesta de ingresos: =1 si respuesta del hogar coherente"
label var    coh_oficial       "Indicador de respuesta de ingresos: =1 si respuesta del hogar coherente - para estimación oficial"
label var    ilpc_m            "Ingreso laboral per cápita - monetario" 
label var    ilpc              "Ingreso laboral per cápita" 
label var    inlpc_m           "Ingreso no laboral per cápita - monetario" 
label var    inlpc             "Ingreso no laboral per cápita"
label var    ipcf_sr           "Ingreso per cápita familiar sin renta implícita"
label var    ipcf_m            "Ingreso per cápita familiar - monetario" 
label var    ipcf              "Ingreso per cápita familiar" 
label var    iea               "Ingreso equivalente A" 
label var    ieb               "Ingreso equivalente B" 
label var    iec               "Ingreso equivalente C" 
label var    ied               "Ingreso equivalente D" 
label var    iee               "Ingreso equivalente E" 
label var    ilea_m            "Ingreso laboral equivalente - monetario" 
label var    lp_extrema	       "Línea de pobreza extrema  oficial"
label var    lp_moderada       "Línea de pobreza moderada oficial"
label var    ing_pob_ext       "Ingreso utilizado para estimar la pobreza extrema oficial"
label var    ing_pob_mod       "Ingreso utilizado para estimar la pobreza moderada oficial"
label var    ing_pob_mod_lp    "Ingreso oficial / LP"
label var    p_reg	       "Factor ajuste por precios regionales"
label var    ipc	       "IPC mes base" 
label var    pipcf	       "Percentiles ingreso per cápita familiar"
label var    dipcf	       "Deciles ingreso per cápita familiar"
label var    p_ing_ofi	       "Percentiles ingreso oficial para estimar pobreza"
label var    d_ing_ofi	       "Deciles ingreso oficial para estimar pobreza"
label var    piea	       "Percentiles ingreso equivalente A"
label var    qiea	       "Quintiles ingreso equivalente A"
label var    pondera_i	       "Ponderador para variables de ingreso"  
label var    ipc05	       "Índice de Precios al Consumidor Promedio de 2005"
label var    ipc11	       "Índice de Precios al Consumidor Promedio de 2011"
label var    ppp05	       "Factor de Ajuste de PPP 2005"
label var    ppp11	       "Factor de Ajuste de PPP 2011"
label var    ipcf_cpi05	       "Ingreso per cápita familiar en valores de 2005"
label var    ipcf_cpi11	       "Ingreso per cápita familiar en valores de 2011"
label var    ipcf_ppp05	       "Ingreso per cápita familiar en dólares de 2005"
label var    ipcf_ppp11	       "Ingreso per cápita familiar en dólares de 2011"
*/

/// English ///
label var    pais            "Country"
label var    ano             "Survey year"
label var    encuesta        "Household survey name"
label var    id              "Household unique identifier"
label var    com             "Identifier of household member"   
label var    pondera         "Weighting factor"
label var    strata          "Stratification variable"   
label var    psu	     	 "Primary sampling unit"

label var    relacion        "Relationship with head of household (harmonized)"
label def relacion 		 	 1 "Head" 2 "Spouse/Partner" 3 "Son/Daughter/Stepson/Stepdaughter" 4 "Mother/Father" ///		
							 5 "Brother/Sister" 6 "Granddaughter/Grandson" 7 "Other family" 8 "Other non-family"
label values relacion relacion
label var    relacion_en    "Relationship with head of household (original survey)"

label var    hogarsec        "Member of secondary household"
label define hogarsec 		 0 "No" 1 "Yes"
label values hogarsec hogarsec

label var    hogar           "Indicator of household "
label var    miembros        "Number of members in main household"

label var    presec          "Households with secondary household members"
label define presec 		 0 "No" 1 "Yes"
label values presec presec

label var    edad            "Age"

label var    gedad1          "Age groups: 2=[15,24], 3=[25,40], 4=[41,64]"
label define gedad1 		 1 "[0,14]" 2 "[15,24]" 3 "[25,40]" 4 "[41,64]" 5 "[65+]"
label values gedad1 gedad1

label var    hombre          "Gender"
label define hombre 		 0 "Female" 1 "Male"
label values hombre hombre

label var    jefe            "Dummy for head of household"
label define jefe 		 	 0 "Not head" 1 "Head"
label values jefe jefe

label var    conyuge         "Dummy for spouse of household head"
label define conyuge 		 0 "Not spouse" 1 "Spouse"
label values conyuge conyuge

label var    hijo            "Dummy for child of household head"
label define hijo 		 	 0 "Not son/daughter" 1 "Son/Daughter"
label values hijo hijo

label var    nro_hijos       "Number of children under 18 years old in the main household"

label var    casado          "Dummy for marital status: married or civil union"
label define casado 		 0 "Not married" 1 "Married"
label values casado casado

label var    soltero         "Dummy for marital status: single"
label define soltero 		 0 "Not single" 1 "Single"
label values soltero soltero

label var    raza            "Ethnicity"
label define raza 		 	 1 "Indigenous" 2 "Afro-American" 3 "Indigenous & Afro-American" 4 "Other"
label values raza raza

*label var    raza_est	     "Original ethnicity variable from survey (standardized)"	 

label var    lengua          "Native tongue"
label define lengua 		 1 "Occidental" 4 "Indigenous" 5 "Afro-American" 6 "Other langauge" 7 "Binary question"
label values lengua lengua 

*label var    lengua_est	 "Original language variable from survey (standardized)"

label var    propieta        "Owner of dwelling s/he lives in?"
label define propieta 		 0 "Not owner" 1 "Owner"
label values propieta propieta

label var    habita          "Number of rooms for exclusive use of the household"
label var    dormi           "Number of bedrooms in dwelling"

label var    precaria        "Dwelling located in hazardous/precarious location"
label define precaria 		 0 "Not hazardous" 1 "Hazardous"
label values precaria precaria

label var    matpreca        "Are the dwelling's construction materials of low-quality?"
label define matpreca 		 0 "Non-precarious materials" 1 "Precarious materials"
label values matpreca matpreca

label var    region_est1     "Geographic region lowest disaggregation (standardized)" 
label var    region_est2     "Geographic region intermediate disaggregation  (standardized)" 
label var    region_est3     "Geographic region highest disaggregation  (standardized)" 

label var    urbano          "Dummy for residence area"
label define urbano 		 0 "Rural" 1 "Urban"
label values urbano urbano

label var    migrante        "Dummy for migration status"
label define migrante 		 0 "Non migrant" 1 "Migrant"
label values migrante migrante

label var    migra_ext       "Dummy for foreign migrant"
label define migra_ext 		 0 "No" 1 "Yes"
label values migra_ext migra_ext

label var    migra_rur       "Dummy for national rural migrant"
label define migra_rur 		 0 "No" 1 "Yes"

label values migra_rur migra_rur

label var    anios_residencia  "Years of residency"

label var    migra_rec       "Dummy for recent migrant"
label define migra_rec 		 0 "No" 1 "Yes"
label values migra_rec migra_rec

label var    nuevareg        "Geographical coverage of survey"

label var    agua            "Does the dwelling have access to a water supply system?"
label define agua 			 0 "No" 1 "Yes"
label values agua agua

label var    banio           "Are there higienic toilet facilities in the dwelling?"
label define banio 			 0 "No" 1 "Yes"
label values banio banio

label var    cloacas         "Does the dwelling have toilet facilities linked to the sewer?"
label define cloacas 		 0 "No" 1 "Yes"
label values cloacas cloacas

label var    elect           "Does the dwelling have access to electricity?"
label define elect 			 0 "No" 1 "Yes"
label values elect elect

label var    telef           "Does the dwelling have a phone (landline or mobile)?"
label define telef 			 0 "No" 1 "Yes"
label values telef telef

label var    heladera        "Does the household have a fridge?"
label define heladera 		 0 "No" 1 "Yes"
label values heladera heladera

label var    lavarropas      "Does the household have a washing machine?"
label define lavarropas 	0 "No" 1 "Yes"
label values lavarropas lavarropas

label var    aire            "Does the household have air conditioner?"
label define aire 			 0 "No" 1 "Yes"
label values aire aire

label var    calefaccion_fija "Does the household have access to fixed heating?"
label define calefaccion_fija 0 "No" 1 "Yes"
label values calefaccion_fija calefaccion_fija

label var    telefono_fijo   "Does the household have a fixed phone?"
label define telefono_fijo 	 0 "No" 1 "Yes"
label values telefono_fijo telefono_fijo

label var    celular         "Does any member of the household have a mobile phone?"
label define celular 		 0 "No" 1 "Yes"
label values celular celular

label var    celular_ind     "Has mobile phone? (individual)"
label define celular_ind 	 0 "No" 1 "Yes"
label values celular_ind celular_ind

label var    televisor       "Does the household have a television?"
label define televisor 		 0 "No" 1 "Yes"
label values televisor televisor

label var    tv_cable        "Does the household have access to cable/satellite TV?"
label define tv_cable 		 0 "No" 1 "Yes"
label values tv_cable tv_cable

label var    video           "Does the household have a VCR or DVD?"
label define video 			 0 "No" 1 "Yes"
label values video video

label var    computadora     "Does the household have a computer?"
label define computadora 	 0 "No" 1 "Yes"
label values computadora computadora

label var    internet_casa   "Does the household have access to internet?"
label define internet_casa 	 0 "No" 1 "Yes"
label values internet_casa internet_casa

label var    uso_internet    "Do you use the internet?"
label define uso_internet 	 0 "No" 1 "Yes"
label values uso_internet uso_internet

label var    auto            "Does the household have a car?"
label define auto 		 	 0 "No" 1 "Yes"
label values auto auto

label var    ant_auto        "Antiquity of car, in years"
label var    auto_nuevo      "Dummy car less than 5 years old: =1 less than 5 years"

label var    moto            "Does the household have a motorcycle?"
label define moto 			  0 "No" 1 "Yes"
label values moto moto

label var    bici            "Does the household have a bicycle?"
label define bici 			  0 "No" 1 "Yes"
label values bici bici

label var    alfabeto        "Dummy for literacy"
label define alfabeto 		 0 "Illiterate" 1 "Literate"
label values alfabeto alfabeto

label var    asiste          "Dummy for attending education system"
label define asiste 		 0 "Does not attend" 1 "Attends"
label values asiste asiste

label var    edu_pub        "Dummy for type of education establishment attended"
label define edu_pub 		 0 "Private establishment" 1 "Public establishment"
label values edu_pub edu_pub

label var    aedu	     	 "Years of education completed"

label var    nivedu      	 "Groups by years of education"
label define nivedu 		 0 "[0,8]" 1 "[9,13]" 2 "[14+]" 
label values nivedu nivedu

label var    nivel           "Highest level of education attainment"
label define nivel 			 0 "Never attended" 1 "Incomplete Primary" 2 "Complete primary" 3 "Incomplete secondary" 4 "Complete secondary" 5 "Incomplete higher" 6 "Higher complete"
label values nivel nivel

label var    prii            "Dummy for educational attainment: =1 if primary incomplete"
label var    pric            "Dummy for educational attainment: =1 if primary complete"
label var    seci            "Dummy for educational attainment: =1 if secondary incomplete"
label var    secc            "Dummy for educational attainment: =1 if secondary complete"
label var    supi            "Dummy for educational attainment: =1 if higher complete"
label var    supc            "Dummy for educational attainment: =1 if higher complete"
label var    exp             "Potential experience"

label var    pea             "Dummy for activity status: economically active"
label define pea 			 0 "Inactive" 1 "Active"
label values pea pea

label var    ocupado         "Dummy for activity status: employed"
label define ocupado 		 0 "Not employed" 1 "Employed"
label values ocupado ocupado

label var    desocupa        "Dummy for activity status: unemployed"
label define desocupa 		 0 "Not unemployed" 1 "Unemployed"
label values desocupa desocupa 

label var    durades         "Duration of unemployement in months"
label var    hstrt           "Total hours worked in all employments"
label var    hstrp           "Hours worked in main occupation"

label var    deseamas        "Do you want to have another employment or work more hours?"
label define deseamas 		 0 "No" 1 "Yes"
label values deseamas deseamas

label var    antigue         "How long has the person been in the main occupation"

label var    relab           "Type of employment in the main occupation"
label define relab 			 1 "Employer" 2 "Salaried worker" 3 "Self-employed" 4 "Without salary" 5 "Unemployed"
label values relab relab

label var    relab_s         "Type of employment in the secondary occupation"
label define relab_s 		 1 "Employer" 2 "Salaried worker" 3 "Self-employed" 4 "Without salary" 5 "Unemployed"
label values relab_s relab_s

label var    relab_o         "Type of employment in the terciary occupation"
label define relab_o 		 1 "Employer" 2 "Salaried worker" 3 "Self-employed" 4 "Without salary" 5 "Unemployed"
label values relab_o relab_o

label var    asal            "Dummy for salaried worker in the main occupation" 
label define asal 			 0 "Not salaried worker" 1 "Salaried worker" 
label values asal asal

label var    empresa         "Type of company where she/he works"
label define empresa 		 1 "Big" 2 "Small" 3 "Public"
label values empresa empresa

label var    grupo_lab       "Labor group" 

label var    categ_lab       "Labor category - Informality"
label define categ_lab 		 1 "Not informal" 2 "Informal" 
label values categ_lab categ_lab

label var    sector1d        "Activity sector (1 digit CIIU)" 
label define sector1d 		 1 "Agriculture, Livestock, Hunting and Forestry" 2 "Fishing" 3 "Mining and Quarrying" 4 "Manufacturing Industries" 5 "Electricity, Gas and Water Supply" 6 "Construction" 7 "Commerce" 8 "Hotels and Restaurants" 9 "Transportation, Storage and Communications" 10 "Financial Intermediation" 11 "Real Estate, Business and Rental Activities" 12 "Public Administration and Defense" 13 "Teaching" 14 "Social and Health Services" 15 "Other Community Services Activities, Social and Personal" 16 "Private Households with Domestic Service" 17 "Extraterritorial Organizations and Organs" 
label values sector1d sector1d

label var    sector          "Activity sector - Own classification"
label var    tarea           "Task performed in the main occupation"

label var    contrato        "Has signed work contract?"
label define contrato 		 0 "Does not have" 1 "Has"
label values contrato contrato

label var    ocuperma        "Permanent or temporary occupation?"
label define ocuperma 		 0 "Temporary" 1 "Permanent"
label values ocuperma ocuperma

label var    djubila         "Right to receive employment-based retirement benefits?"
label define djubila 		 0 "No" 1 "Yes"
label values djubila djubila

label var    dsegsale        "Receives employment-based health insurance?"
label define dsegsale 		 0 "No" 1 "Yes"
label values dsegsale dsegsale

label var    aguinaldo       "Receives end-year bonus?"
label define aguinaldo 		 0 "No" 1 "Yes"
label values aguinaldo daguinaldo

label var    dvacaciones     "Right to paid vacations in your employment?"
label define dvacaciones 	 0 "No" 1 "Yes"
label values dvacaciones dvacaciones

label var    sindicato       "Member of an union?"
label define sindicato 		 0 "No" 1 "Yes"
label values sindicato sindicato

label var    prog_empleo     "Are you occupied in a labor program?"
label define prog_empleo 	 0 "No" 1 "Yes"
label values prog_empleo prog_empleo

*label var    n_ocu_h        "Number of employed people in the household"

/*label var    asistencia    "Recipient of benefits from any social assistance program?"
label define asistencia 	 0 "No" 1 "Yes"
label values asistencia asistencia*/

label var    dsegsal         "Do you have health insurance?"
label define dsegsal 		 0 "No" 1 "Yes"
label values dsegsal dsegsal

label var    iasalp_m        "Labor income from main occupation - monetary"
label var    iasalp_nm       "Labor income from main occupation - non-monetary"
label var    ictapp_m        "Self-employed income from main occupation - monetary"
label var    ictapp_nm       "Self-employed income from main occupation - non-monetary"
label var    ipatrp_m        "Employer income from main occupation - monetary"
label var    ipatrp_nm       "Employer income from main occupation - non-monetary"
label var    iolp_m          "Other labor income from main occupation - monetary"
label var    iolp_nm         "Other labor income from main occupation - non monetary"
label var    iasalnp_m       "Labor income from secondary occupation - monetary"
label var    iasalnp_nm      "Labor income from secondary occupation - non-monetary"
label var    ictapnp_m       "Self-employed income from secondary occupation - monetary"
label var    ictapnp_nm      "Self-employed income from secondary occupation - non-monetary"
label var    ipatrnp_m       "Employer income from secondary occupation - monetary"
label var    ipatrnp_nm      "Employer income from secondary occupation - non monetary"
label var    iolnp_m         "Other labor income from secondary occupation - monetary"
label var    iolnp_nm        "Other labor income from secondary occupation - non-monetary"
label var    ijubi_m         "Monetary income for retirement benefits and pensions"
label var    ijubi_nm        "Non monetary income for retirement benefits and pensions "
*label var   ijubi_o	     "Income for retirement benefits and pensions (not identified if contributive or not)"
label var    icap_m          "Monetary income from capital"
label var    icap_nm         "Non-monetary income from capital"
label var    icap            "Income from capital"
label var    cct	      	 "Income from conditional cash transfer programs"	 
label var    itrane_o_m	     "Income from public transfers other than CCTs - monetary"	
label var    itrane_o_nm     "Income from public transfers other than CCTs - non monetary"
label var    itrane_ns       "Income from unspecified public transfers"
label var    rem             "Income from remittances del exterior - monetary"
*label var   itranext_nm    "Income from remittances from abroad - non monetary"
label var    itranp_o_m      "Income from other private transfers in the country - monetary"
label var    itranp_o_nm     "Income from other private transfers in the country - non monetary"
label var    itranp_ns       "Income from non-specified private transfers"
label var    inla_otro       "Other non-labor income"
label var    ipatrp          "Employer income from main occupation - total"
label var    iasalp          "Salaried worker income from main occupation - total"
label var    ictapp          "Self-employed income from main occupation - total"
label var    iolp	      	 "Other labor income from main occupation - total"
label var    ip_m            "Income from main occupation - monetary"
label var    ip              "Income in main occupation"
label var    wage_m          "Hourly income from main occupation - monetary"
label var    wage            "Hourly wage in main occupation"
label var    ipatrnp	     "Employer income from secondary occupation - total"
label var    iasalnp         "Salaried worker income from secondary occupation - total"
label var    ictapnp         "Self-employed income from secondary occupation - total"
label var    iolnp           "Other labor income from main occupation - total"
label var    inp	         "Labor income from secondary occupation"
label var    ipatr_m         "Employer income - monetary"
label var    ipatr           "Employer income"
label var    iasal_m         "Salaried worker income in main occupation: Monetary"
label var    iasal           "Salaried worker income in main occupation"
label var    ictap_m         "Self-employed labor income - monetary"
label var    ictap           "Self-employed labor income"
label var    ila_m           "Labor income - monetary"
label var    ila             "Total labor income"
label var    ilaho_m         "Hourly income in all occupations - monetary"
label var    ilaho           "Hourly income in all occupations"
label var    perila          "Dummy for labor income earner: =1 if labor income earner"
label var    ijubi           "Income from retirement benefits and pensions"
label var    itranp_m        "Income from private transfers - monetary"
label var    itranp          "Income from private transfers"
label var    itrane_m        "Income from public transfers - monetary"
label var    itrane          "Income from public transfers"
label var    itran_m         "Income from transfers - monetary"
label var    itran           "Income from transfers"
label var    inla_m          "Total non-labor income - monetary"
label var    inla            "Total non-labor income"
label var    ii_m            "Total individual income - monetary"
label var    ii              "Total individual income"
label var    perii           "Income earner"
label var    n_perila_h      "Number of labor income earners in household"
label var    n_perii_h       "Number of labor income earners in household"
label var    ilf_m           "Total household labor income - monetary"
label var    ilf             "Total household labor income"
label var    inlaf_m         "Total household non-labor income - monetary"
label var    inlaf           "Total household non-labor income"
label var    itf_m           "Total household income - monetary"
label var    itf_sin_ri      "Total household income without imputed rent"
label var    renta_imp       "Imputed income for home owners"
label var    itf             "Household total income"
label var    cohi            "Indicators for income answers: =1 if answer is coherent (individual)"
label var    cohh            "Indicators for income answers: =1 if answer is coherent (household)"
label var    coh_oficial     "Indicators for income answers: =1 if answer is coherent (household) – for official estimate"
label var    ilpc_m          "Per capita labor income - monetary"
label var    ilpc            "Per capita labor income"
label var    inlpc_m         "Per capita non-labor income - monetary"
label var    inlpc           "Per capita non-labor income "
label var    ipcf_sr         "Per capita household income without implicit rent"
label var    ipcf_m          "Per capita household income - monetary"
label var    ipcf            "Per capita household income"
label var    iea             "Equivalized income A" 
label var    ieb             "Equivalized income B" 
label var    iec             "Equivalized income C" 
label var    ied             "Equivalized income D" 
label var    iee             "Equivalized income E" 
label var    ilea_m          "Equivalized labor income - monetary" 
label var    lp_extrema	     "Official extreme poverty line"
label var    lp_moderada     "Official moderate poverty line"
label var    ing_pob_ext     "Income used to estimate official extreme poverty"
label var    ing_pob_mod     "Income used to estimate official moderate poverty"
label var    ing_pob_mod_lp  "Official income / Poverty Line"
label var    p_reg	         "Adjustment factor for regional prices"
label var    ipc	         "CPI base month" 
cap label var    pipcf	         "Percentiles household per capita income"
cap label var    dipcf	         "Income deciles per capita household income"
cap label var    p_ing_ofi	     "Income percentiles to estimate official poverty"
cap label var    d_ing_ofi	     "Income deciles to estimate official poverty"
cap label var    piea	     	 "Percentiles equivalized income A"
cap label var    qiea	         "Quintiles equivalized income A"
cap label var    pondera_i	     "Weight for income variables"  
cap label var    ipc05	         "Average Consumer Price Index for 2005"
cap label var    ipc11	     	 "Average Consumer Price Index for 2011"
cap label var    ppp05	   	 	 "PPP conversion factor (2005)"
cap label var    ppp11	         "PPP conversion factor (2011)"
cap label var    ipcf_cpi05	     "Per capita household income (2005 values)"
cap label var    ipcf_cpi11	     "Per capita household income (2011 values)"
cap label var    ipcf_ppp05	     "Per capita household income (2005 dollars)"
cap label var    ipcf_ppp11	     "Per capita household income (2011 dollars)"
