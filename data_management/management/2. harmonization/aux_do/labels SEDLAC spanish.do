
/*=========================================================================================================================================================================
								2: Preparacion de los datos / Data preparation: Etiquetado de Variables / Variable labeling
==========================================================================================================================================================================*/

/// Spanish ///

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
label def region_est1 1 "Central"  2 "Llanera" 3 "Occidental" 4 "Zuliana" ///
          5 "Andina" 6 "Nor-Oriental" 7 "Capital"
label value region_est1 region_est1
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

*label var    nuevareg        "Cobertura geografica de la encuesta"

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

*label var    relab_s          "Relación laboral en la ocupación secundaria"
*label define relab_s 1 "Empleador" 2 "Asalariado" 3 "Cuentapropista" 4 "Sin Salario" 5 "Desocupado"
*label values relab_s relab_s

*label var    relab_o          "Relación laboral en la ocupación terciaria"
*label define relab_o 1 "Empleador" 2 "Asalariado" 3 "Cuentapropista" 4 "Sin Salario" 5 "Desocupado"
*label values relab_o relab_o

label var    asal   "Dummy de asalariado en la ocupación principal" 
label define asal 0 "No asalariado" 1 "Asalariado" 
label values asal asal

label var    empresa 	"Tipo de empresa en la que trabaja"
label define empresa 1 	"Grande" 2 "Chica" 3 "Pública"
label values empresa empresa

label var    grupo_lab  "Grupo laboral" 

label var    categ_lab   "Categoría laboral - Informalidad Productiva"
label define categ_lab 1 "No informal" 2 "Informal" 
label values categ_lab categ_lab

label var    sector1d   "Sector de actividad a 1 digito CIIU" 
label define sector1d 1 "Agricultura, Ganadería, Caza y Silvicultura" 2 "Pesca" 3 "Explotación de Minas y Canteras" 4 "Industrias Manufactureras" 5 "Suministro de Electricidad, Gas y Agua" 6 "Construcción" 7 "Comercio" 8 "Hoteles y Restaurantes" 9 "Transporte, Almacenamiento y Comunicaciones" 10 "Intermediación Financiera" 11 "Actividades Inmobiliarias, Empresariales y de Alquiler" 12 "Administración Pública y Defensa" 13 "Enseñanza" 14 "Servicios Sociales y de Salud" 15 "Otras Actividades de Servicios Comunitarios, Sociales y Personales" 16 "Hogares Privados con Servicio Doméstico" 17 "Organizaciones y Órganos Extraterritoriales" 
label values sector1d sector1d

label var    sector    	"Sector de actividad - Clasificación propia"
label var    tarea      "Tarea que realiza en la ocupación principal"

label var    contrato   "Tiene contrato laboral firmado?"
label define contrato 0 "No tiene" 1 "Tiene"
label values contrato contrato

label var    ocuperma   "Es su ocupación permanente o temporaria?"
label define ocuperma 0 "Temporaria" 1 "Permanente"
label values ocuperma ocuperma

label var    djubila   "Tiene derecho a jubilación en su empleo?"
label define djubila 0 "No" 1 "Si"
label values djubila djubila

label var    dsegsale   "Tiene derecho a seguro de salud en su empleo?"
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
cap label var    ilea_m            "Ingreso laboral equivalente - monetario" 
cap label var    lp_extrema	       "Línea de pobreza extrema  oficial"
cap label var    lp_moderada       "Línea de pobreza moderada oficial"
cap label var    ing_pob_ext       "Ingreso utilizado para estimar la pobreza extrema oficial"
cap label var    ing_pob_mod       "Ingreso utilizado para estimar la pobreza moderada oficial"
cap label var    ing_pob_mod_lp    "Ingreso oficial / LP"
cap label var    p_reg	       "Factor ajuste por precios regionales"
cap label var    ipc	       "IPC mes base" 
cap label var    pipcf	       "Percentiles ingreso per cápita familiar"
cap label var    dipcf	       "Deciles ingreso per cápita familiar"
cap label var    p_ing_ofi	       "Percentiles ingreso oficial para estimar pobreza"
cap label var    d_ing_ofi	       "Deciles ingreso oficial para estimar pobreza"
cap label var    piea	       "Percentiles ingreso equivalente A"
cap label var    qiea	       "Quintiles ingreso equivalente A"
cap label var    pondera_i	       "Ponderador para variables de ingreso"  
cap label var    ipc05	       "Índice de Precios al Consumidor Promedio de 2005"
cap label var    ipc11	       "Índice de Precios al Consumidor Promedio de 2011"
cap label var    ppp05	       "Factor de Ajuste de PPP 2005"
cap label var    ppp11	       "Factor de Ajuste de PPP 2011"
cap label var    ipcf_cpi05	       "Ingreso per cápita familiar en valores de 2005"
cap label var    ipcf_cpi11	       "Ingreso per cápita familiar en valores de 2011"
cap label var    ipcf_ppp05	       "Ingreso per cápita familiar en dólares de 2005"
cap label var    ipcf_ppp11	       "Ingreso per cápita familiar en dólares de 2011"

