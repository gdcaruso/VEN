********************************************************************************
	* DROP VARIABLES 
********************************************************************************
use "$datapath/ENCOVI_2019_postpobreza.dta", replace
	***********************
	* FROM SURVEY
	***********************
	
*---- Geolocalization	
		global geoloc 			gps_struc_latitud gps_struc_longitud gps_struc_exactitud gps_struc_altitud gps_struc_tiempo ///
								gps_coord_latitud gps_coord_longitud gps_coord_exactitud gps_coord_altitud gps_coord_tiempo	
*---- Variables which identify individuals' names
	forval i=0/9 {
	drop nombre_emig_`i'
	}
	

*---- From Harmonization and cleaning (auxiliary)
	   
	   global harmoclean s9q25a_bolfeb s9q26a_bolfeb s9q27_bolfeb s9q28a_1_bolfeb s9q28a_2_bolfeb s9q28a_3_bolfeb s9q28a_4_bolfeb ijubi_mpe_bolfeb s9q29b_5_bolfeb 
	   
*---- Drop globales
		drop $geoloc $harmoclean
		
		
	***********************
	* FROM IMPUTATION
	***********************
	
*---- Auxiliary variables from imputation

*----Auxiliary variables to identify missing values 
	global	vars_aux			quintil perc_ilaenitf perc_inlaenitf perc_rentimpenitf ///
								perc_ijubi_meninla perc_icap_meninla perc_remeninla perc_itranp_o_meninla perc_itranp_nseninla ///
								perc_itrane_o_meninla perc_itrane_nseninla perc_inla_extraordeninla ///
								/*ocupado*/ edad9 recibe_ingresolab_mon_mes recibe_ingresolab_mon_ano recibe_ingresolab_mon report_inglabmon_nocuanto ///
								recibe_ingresolab_nomon report_inglabnomon_nocuanto ///
								cuantasinlarecibe recibe_ingresonolab_mes ///
								recibe_ingresonolab_ano recibe_ingresonolab ///
								inla_aux report_ingnolab_nocuanto recibe_ingresopenjub_mes recibe_ingresopenjub_ano ///
								recibe_ingresopenjub ila_dummy norta_sirecibeila ///
								ocup_norta_sirecibeila jubi_pens ijubpen_dummy jubi_norta_sirecibejubi ///
								aimputar_ila_mon aimputar_jubipen ocup_o_rtarecibenilamon jubi_o_rtarecibejubi ///
								jubpen ijubi_aux djubpen ijubpen_dummy bene ingresoslab_bene inlanojub inla_aux



*---- Dummy identifying missings for imputation
	global vars_ident			dila_m_miss1 djubpen_miss1 dbene_miss1 dinlanojub_miss1 ///
								dila_m_miss2 djubpen_miss2 dbene_miss2 dinlanojub_miss2 ///
								dila_m_miss3 djubpen_miss3 ///
								ila_m_out dila_m_out jubpen_out djubpen_out bene_out dbene_out ///
								dila_m_zero djubpen_zero dbene_zero dinlanojub_zero

*---- Variables tailored for these analisis

	global other             	edad2 afiliado_segsalud_comp total_hrtr asiste_o_dejoypq 

*---- Variables without missing (where missing was included as a category)
	global vars_mineq_sinmis 	edad_sinmis	edad2_sinmis agegroup_sinmis hombre_sinmis relacion_comp_sinmis miembros_sinmis estado_civil_sinmis region_est1_sinmis municipio_sinmis 	///
								tipo_vivienda_hh_sinmis propieta_hh_sinmis auto_hh_sinmis anio_auto_hh_sinmis heladera_hh_sinmis lavarropas_hh_sinmis computadora_hh_sinmis	internet_hh_sinmis televisor_hh_sinmis calentador_hh_sinmis aire_hh_sinmis tv_cable_hh_sinmis microondas_hh_sinmis ///
								afiliado_segsalud_comp_sinmis ///
								nivel_educ_sinmis ///
								tarea_sinmis sector_encuesta_sinmis categ_ocu_sinmis total_hrtr_sinmis ///
								c_sso_sinmis c_rpv_sinmis c_spf_sinmis c_aca_sinmis c_sps_sinmis c_otro_sinmis ///
								cuenta_corr_sinmis cuenta_aho_sinmis tcredito_sinmis tdebito_sinmis no_banco_sinmis ///
								aporte_pension_sinmis clap_sinmis ingsuf_comida_sinmis comida_trueque_sinmis 

*---- Dummy auxiliary for regressions 
	global dummy_vars           p_agegroup_sinmis1 p_agegroup_sinmis2 p_agegroup_sinmis3 p_agegroup_sinmis4 p_agegroup_sinmis5 p_agegroup_sinmis6 p_agegroup_sinmis7 p_agegroup_sinmis8 ///
								p_relacion_comp_sinmis1 p_relacion_comp_sinmis2 p_relacion_comp_sinmis3 p_relacion_comp_sinmis4 p_relacion_comp_sinmis5 p_relacion_comp_sinmis6 p_relacion_comp_sinmis7 p_relacion_comp_sinmis8 p_relacion_comp_sinmis9 p_relacion_comp_sinmis10 p_relacion_comp_sinmis11 p_relacion_comp_sinmis12 p_relacion_comp_sinmis13 ///
								p_estado_civil_sinmis1 p_estado_civil_sinmis2 p_estado_civil_sinmis3 p_estado_civil_sinmis4 p_estado_civil_sinmis5 p_estado_civil_sinmis6 p_region_est1_sinmis1 p_region_est1_sinmis2 p_region_est1_sinmis3 p_region_est1_sinmis4 p_region_est1_sinmis5 p_region_est1_sinmis6 p_region_est1_sinmis7 p_region_est1_sinmis8 p_region_est1_sinmis9 ///
								p_municipio_sinmis1 p_municipio_sinmis2 p_municipio_sinmis3 p_municipio_sinmis4 p_municipio_sinmis5 p_municipio_sinmis6 p_municipio_sinmis7 p_municipio_sinmis8 p_municipio_sinmis9 p_municipio_sinmis10 p_municipio_sinmis11 p_municipio_sinmis12 p_municipio_sinmis13 p_municipio_sinmis14 p_municipio_sinmis15 p_municipio_sinmis16 p_municipio_sinmis17 p_municipio_sinmis18 p_municipio_sinmis19 p_municipio_sinmis20 p_municipio_sinmis21 p_municipio_sinmis22 p_municipio_sinmis23 p_municipio_sinmis24 p_municipio_sinmis25 ///
								p_tipo_vivienda_hh_sinmis1 p_tipo_vivienda_hh_sinmis2 p_tipo_vivienda_hh_sinmis3 p_tipo_vivienda_hh_sinmis4 p_tipo_vivienda_hh_sinmis5 p_tipo_vivienda_hh_sinmis6 p_tipo_vivienda_hh_sinmis7 p_tipo_vivienda_hh_sinmis8 ///
								p_propieta_hh_sinmis1 p_propieta_hh_sinmis2 p_propieta_hh_sinmis3 ///
								p_auto_hh_sinmis1 p_auto_hh_sinmis2 p_auto_hh_sinmis3 p_heladera_hh_sinmis1 p_heladera_hh_sinmis2 p_heladera_hh_sinmis3 p_lavarropas_hh_sinmis1 p_lavarropas_hh_sinmis2 p_lavarropas_hh_sinmis3 p_computadora_hh_sinmis1 p_computadora_hh_sinmis2 p_computadora_hh_sinmis3 p_internet_hh_sinmis1 p_internet_hh_sinmis2 p_internet_hh_sinmis3 p_televisor_hh_sinmis1 p_televisor_hh_sinmis2 p_televisor_hh_sinmis3 p_calentador_hh_sinmis1 p_calentador_hh_sinmis2 p_calentador_hh_sinmis3 p_aire_hh_sinmis1 p_aire_hh_sinmis2 p_aire_hh_sinmis3 p_tv_cable_hh_sinmis1 p_tv_cable_hh_sinmis2 p_tv_cable_hh_sinmis3 p_microondas_hh_sinmis1 p_microondas_hh_sinmis2 p_microondas_hh_sinmis3 ///
								p_afiliado_segsalud_comp_sinmis1 p_afiliado_segsalud_comp_sinmis2 p_afiliado_segsalud_comp_sinmis3 p_afiliado_segsalud_comp_sinmis4 p_afiliado_segsalud_comp_sinmis5 p_afiliado_segsalud_comp_sinmis6 p_afiliado_segsalud_comp_sinmis7 ///
								p_nivel_educ_sinmis1 p_nivel_educ_sinmis2 p_nivel_educ_sinmis3 p_nivel_educ_sinmis4 p_nivel_educ_sinmis5 p_nivel_educ_sinmis6 p_nivel_educ_sinmis7 p_nivel_educ_sinmis8 ///
								p_tarea_sinmis1 p_tarea_sinmis2 p_tarea_sinmis3 p_tarea_sinmis4 p_tarea_sinmis5 p_tarea_sinmis6 p_tarea_sinmis7 p_tarea_sinmis8 p_tarea_sinmis9 p_tarea_sinmis10 p_tarea_sinmis11 p_sector_encuesta_sinmis1 p_sector_encuesta_sinmis2 p_sector_encuesta_sinmis3 p_sector_encuesta_sinmis4 p_sector_encuesta_sinmis5 p_sector_encuesta_sinmis6 p_sector_encuesta_sinmis7 p_sector_encuesta_sinmis8 p_sector_encuesta_sinmis9 p_sector_encuesta_sinmis10 p_sector_encuesta_sinmis11 p_categ_ocu_sinmis1 p_categ_ocu_sinmis2 p_categ_ocu_sinmis3 p_categ_ocu_sinmis4 p_categ_ocu_sinmis5 p_categ_ocu_sinmis6 p_categ_ocu_sinmis7 p_categ_ocu_sinmis8 p_c_sso_sinmis1 p_c_sso_sinmis2 p_c_sso_sinmis3 ///
								p_c_rpv_sinmis1 p_c_rpv_sinmis2 p_c_rpv_sinmis3 p_c_spf_sinmis1 p_c_spf_sinmis2 p_c_spf_sinmis3 p_c_aca_sinmis1 p_c_aca_sinmis2 p_c_aca_sinmis3 p_c_sps_sinmis1 p_c_sps_sinmis2 p_c_sps_sinmis3 p_c_otro_sinmis1 p_c_otro_sinmis2 p_c_otro_sinmis3 ///
								p_cuenta_corr_sinmis1 p_cuenta_corr_sinmis2 p_cuenta_corr_sinmis3 p_cuenta_aho_sinmis1 p_cuenta_aho_sinmis2 p_cuenta_aho_sinmis3 p_tcredito_sinmis1 p_tcredito_sinmis2 p_tcredito_sinmis3 p_tdebito_sinmis1 p_tdebito_sinmis2 p_tdebito_sinmis3 p_no_banco_sinmis1 p_no_banco_sinmis2 p_no_banco_sinmis3 ///
								p_aporte_pension_sinmis1 p_aporte_pension_sinmis2 p_aporte_pension_sinmis3 p_aporte_pension_sinmis4 p_aporte_pension_sinmis5 p_aporte_pension_sinmis6 ///
								p_clap_sinmis1 p_clap_sinmis2 p_clap_sinmis3 p_ingsuf_comida_sinmis1 p_ingsuf_comida_sinmis2 p_ingsuf_comida_sinmis3 p_comida_trueque_sinmis1 p_comida_trueque_sinmis2 p_comida_trueque_sinmis3

*---- Dummy to check inconsistences
	global checks 				ila_nuestro dummy_nocoincideila inla_nuestro dummy_nocoincideinla

*---- Drop globales	
drop $vars_aux $vars_ident $other $vars_mineq_sinmis $dummy_vars $checks						
********************************************************************************
	* KEEP VARIABLES 
********************************************************************************	
* To keep (but different from encovi 2019)
*---- From CEDLAS (auxiliary)
	   global cedlas relab 
*---- II. Interview Control / Control de la entrevista
		global control_ent entidad region_est1 municipio nombmun parroquia nombpar 
*----III Household determination / Determinacion de hogares
		global det_hogares npers_viv comparte_gasto_viv npers_gasto_sep npers_gasto_comp
*----1.1: Identification Variables / Variables de identificación
		global id_ENCOVI pais ano encuesta id com psu
*----1.2: Demographic variables  / Variables demográficas
		global demo_ENCOVI relacion_en relacion_comp hombre edad anio_naci mes_naci dia_naci pais_naci residencia resi_estado resi_municipio razon_cambio_resi razon_cambio_resi_o pert_2014 razon_incorp_hh razon_incorp_hh_o ///
	certificado_naci cedula razon_nocertificado razon_nocertificado_o estado_civil_en estado_civil hijos_nacidos_vivos hijos_vivos anio_ult_hijo mes_ult_hijo dia_ult_hijo
*----1.4: Dwelling characteristics / Caracteristicas de la vivienda
		global  dwell_ENCOVI material_piso material_pared_exterior material_techo tipo_vivienda suministro_agua suministro_agua_comp frecuencia_agua ///
							serv_elect_red_pub serv_elect_planta_priv serv_elect_otro electricidad interrumpe_elect tipo_sanitario tipo_sanitario_comp ndormi banio_con_ducha nbanios tenencia_vivienda ///
							pago_alq_mutuo pago_alq_mutuo_mon pago_alq_mutuo_m atrasos_alq_mutuo implicancias_nopago renta_imp_en renta_imp_mon titulo_propiedad ///
							fagua_acueduc fagua_estanq fagua_cisterna fagua_bomba fagua_pozo fagua_manantial fagua_botella fagua_otro tratamiento_agua tipo_tratamiento ///
							comb_cocina pagua pelect pgas pcarbon pparafina ptelefono pagua_monto pelect_monto pgas_monto pcarbon_monto pparafina_monto ptelefono_monto pagua_mon ///
							pelect_mon pgas_mon pcarbon_mon pparafina_mon ptelefono_mon pagua_m pelect_m pgas_m pcarbon_m pparafina_m ptelefono_m danio_electrodom tenencia_vivienda_comp
*----VII. EDUCATION / EDUCACIÓN 
		global educ_ENCOVI contesta_ind_e quien_contesta_e asistio_educ razon_noasis asiste nivel_educ_act g_educ_act regimen_act a_educ_act s_educ_act t_educ_act edu_pub ///
				fallas_agua fallas_elect huelga_docente falta_transporte falta_comida_hogar falta_comida_centro inasis_docente protesta nunca_deja_asistir ///
				pae pae_frecuencia pae_desayuno pae_almuerzo pae_meriman pae_meritard pae_otra ///
				cuota_insc compra_utiles compra_uniforme costo_men costo_transp otros_gastos ///
				cuota_insc_monto compra_utiles_monto compra_uniforme_monto costo_men_monto costo_transp_monto otros_gastos_monto ///
				cuota_insc_mon compra_utiles_mon compra_uniforme_mon costo_men_mon costo_transp_mon otros_gastos_mon ///
				cuota_insc_m compra_utiles_m compra_uniforme_m costo_men_m costo_transp_m otros_gastos_m ///
				nivel_educ_en nivel_educ g_educ regimen a_educ s_educ t_educ alfabeto /*titulo*/ edad_dejo_estudios razon_dejo_estudios razon_dejo_est_comp
*----VIII. HEALTH / SALUD 

		global health_ENCOVI enfermo enfermedad enfermedad_o visita razon_no_medico razon_no_medico_o medico_o_quien medico_o_quien_o lugar_consulta lugar_consulta_o pago_consulta cant_pago_consulta mone_pago_consulta ///
				mes_pago_consulta receto_remedio recibio_remedio donde_remedio donde_remedio_o pago_remedio mone_pago_remedio mes_pago_remedio pago_examen cant_pago_examen ///
				mone_pago_examen mes_pago_examen remedio_tresmeses cant_remedio_tresmeses mone_remedio_tresmeses mes_remedio_tresmeses seguro_salud ///
				afiliado_segsalud pagosegsalud quien_pagosegsalud cant_pagosegsalud mone_pagosegsalud mes_pagosegsalud

*----IX: LABOR / EMPLEO	
	global labor_ENCOVI ocupado trabajo_semana trabajo_semana_2 trabajo_independiente razon_no_trabajo razon_no_trabajo_o sueldo_semana busco_trabajo empezo_negocio cuando_buscotr ///
			dili_agencia dili_aviso dili_planilla dili_credito dili_tramite dili_compra dili_contacto ///
			como_busco_semana razon_no_busca razon_no_busca_o actividades_inactivos tarea sector_encuesta categ_ocu hstr_ppal trabajo_secundario hstr_todos /// 
			im_sueldo im_hsextra im_propina im_comision im_ticket im_guarderia im_beca im_hijos im_antiguedad im_transporte im_rendimiento im_otro im_petro ///
			im_sueldo_cant im_hsextra_cant im_propina_cant im_comision_cant im_ticket_cant im_guarderia_cant im_beca_cant im_hijos_cant im_antiguedad_cant im_transporte_cant im_rendimiento_cant im_otro_cant im_petro_cant ///
			im_sueldo_mone im_hsextra_mone im_propina_mone im_comision_mone im_ticket_mone im_guarderia_mone im_beca_mone im_hijos_mone im_antiguedad_mone im_transporte_mone im_rendimiento_mone im_otro_mone ///
			c_sso c_rpv c_spf c_aca c_sps c_otro c_sso_cant c_rpv_cant c_spf_cant c_aca_cant c_sps_cant c_otro_cant c_sso_mone c_rpv_mone c_spf_mone c_aca_mone c_sps_mone c_otro_mone ///
			inm_comida inm_productos inm_transporte inm_vehiculo inm_estaciona inm_telefono inm_servicios inm_guarderia inm_otro ///
			inm_comida_cant inm_productos_cant inm_transporte_cant inm_vehiculo_cant inm_estaciona_cant inm_telefono_cant inm_servicios_cant inm_guarderia_cant inm_otro_cant ///
			inm_comida_mone inm_productos_mone inm_transporte_mone inm_vehiculo_mone inm_estaciona_mone inm_telefono_mone inm_servicios_mone inm_guarderia_mone inm_otro_mone ///
			d_sso d_spf d_isr d_cah d_cpr d_rpv d_otro d_sso_cant d_spf_cant d_isr_cant d_cah_cant d_cpr_cant d_rpv_cant d_otro_cant d_sso_mone d_spf_mone d_isr_mone d_cah_mone d_cpr_mone d_rpv_mone d_otro_mone ///
			im_patron im_patron_cant im_patron_mone inm_patron inm_patron_cant inm_patron_mone im_indep im_indep_cant im_indep_mone i_indep_mes i_indep_mes_cant i_indep_mes_mone ///
			g_indep_mes_cant g_indep_mes_mone razon_menoshs razon_menoshs_o deseamashs buscamashs razon_nobusca razon_nobusca_o cambiotr razon_cambiotr razon_cambiotr_o ///
			aporta_pension pension_IVSS pension_publi pension_priv pension_otro pension_otro_o aporte_pension cant_aporta_pension mone_aporta_pension 

*----XVI: BANKING / BANCARIZACIÓN
		global bank_ENCOVI contesta_ind_b quien_contesta_b cuenta_corr cuenta_aho tcredito tdebito no_banco ///
		efectivo_f tcredito_f tdebito_f bancao_f pagomovil_f razon_nobanco

*----9: Otros ingresos y pensiones / Other income and pensions	
		global otherinc_ENCOVI inla_pens_soi	inla_pens_vss	inla_jubi_emp	inla_pens_dsa	inla_beca_pub	inla_beca_pri	inla_ayuda_pu	inla_ayuda_pr	inla_ayuda_fa	inla_asig_men	inla_otros	inla_petro ///
		inla_pens_soi_cant	inla_pens_vss_cant	inla_jubi_emp_cant	inla_pens_dsa_cant	inla_beca_pub_cant	inla_beca_pri_cant	inla_ayuda_pu_cant	inla_ayuda_pr_cant	inla_ayuda_fa_cant	inla_asig_men_cant	inla_otros_cant	inla_petro_cant ///
		inla_pens_soi_mone	inla_pens_vss_mone	inla_jubi_emp_mone	inla_pens_dsa_mone	inla_beca_pub_mone	inla_beca_pri_mone	inla_ayuda_pu_mone	inla_ayuda_pr_mone	inla_ayuda_fa_mone	inla_asig_men_mone	inla_otros_mone ///
		iext_sueldo	iext_ingnet	iext_indemn	iext_remesa	iext_penjub	iext_intdiv	iext_becaes	iext_extrao iext_alquil ///
		iext_sueldo_cant	iext_ingnet_cant	iext_indemn_cant	iext_remesa_cant	iext_penjub_cant	iext_intdiv_cant	iext_becaes_cant	iext_extrao_cant    iext_alquil_cant ///
		iext_sueldo_mone	iext_ingnet_mone	iext_indemn_mone	iext_remesa_mone	iext_penjub_mone	iext_intdiv_mone	iext_becaes_mone	iext_extrao_mone	iext_alquil_mone

*----10: Emigración / Emigration
		global emigra_ENCOVI informant_emig hogar_emig numero_emig nombre_emig_* edad_emig_* sexo_emig_* relemig_* anoemig_* mesemig_* leveledu_emig_* ///
				gradedu_emig_* regedu_emig_* anoedu_emig_* semedu_emig_* paisemig_* opaisemig_* ciuemig_* soloemig_* conemig_* razonemig_* ocupaemig_* ocupnemig_* ///
				volvioemig_* volvioanoemig_* volviomesemig_* miememig_*

*----XI: MORTALITY / MORTALIDAD
		global mortali_ENCOVI ctoshnosyud ctoshnosme hnohombre1 hnohombre2 hnohombre3 hnohombre4 hnohombre5 hnohombre6 hnohombre7 hnohombre8 hnohombre9 hnohombre10 ///
				hnohombre11 hnohombre12 hnohombre13 hnohombre14 hnohombre15 hnohombre16 hnohombre17 hnohombre18 hnohombre19 hnovivo1 hnovivo2 hnovivo3 hnovivo4 hnovivo5 ///
				hnovivo6 hnovivo7 hnovivo8 hnovivo9 hnovivo10 hnovivo11 hnovivo12 hnovivo13 hnovivo14 hnovivo15 hnovivo16 hnovivo17 hnovivo18 hnovivo19 hnoedad1 hnoedad2 ///
				hnoedad3 hnoedad4 hnoedad5 hnoedad6 hnoedad7 hnoedad8 hnoedad9 hnoedad10 hnoedad11 hnoedad12 hnoedad13 hnoedad14 hnoedad15 hnoedad16 hnoedad17 hnoedad18 ///
				hnoedad19 hnocontactoano1 hnocontactoano2 hnocontactoano3 hnocontactoano4 hnocontactoano5 hnocontactoano6 hnocontactoano7 hnocontactoano8 hnocontactoano9 ///
				hnocontactoano10 hnocontactoano11 hnocontactoano12 hnocontactoano13 hnocontactoano14 hnocontactoano15 hnocontactoano16 hnocontactoano17 hnocontactoano18 ///
				hnocontactoano19 hnocontactomes1 hnocontactomes2 hnocontactomes3 hnocontactomes4 hnocontactomes5 hnocontactomes6 hnocontactomes7 hnocontactomes8 hnocontactomes9 ///
				hnocontactomes10 hnocontactomes11 hnocontactomes12 hnocontactomes13 hnocontactomes14 hnocontactomes15 hnocontactomes16 hnocontactomes17 hnocontactomes18 ///
				hnocontactomes19 hnofallecioano1 hnofallecioano2 hnofallecioano3 hnofallecioano4 hnofallecioano5 hnofallecioano6 hnofallecioano7 hnofallecioano8 hnofallecioano9 ///
				hnofallecioano10 hnofallecioano11 hnofallecioano12 hnofallecioano13 hnofallecioano14 hnofallecioano15 hnofallecioano16 hnofallecioano17 hnofallecioano18 ///
				hnofallecioano19 hnofalleciomes1 hnofalleciomes2 hnofalleciomes3 hnofalleciomes4 hnofalleciomes5 hnofalleciomes6 hnofalleciomes7 hnofalleciomes8 hnofalleciomes9 ///
				hnofalleciomes10 hnofalleciomes11 hnofalleciomes12 hnofalleciomes13 hnofalleciomes14 hnofalleciomes15 hnofalleciomes16 hnofalleciomes17 hnofalleciomes18 hnofalleciomes19 ///
				hnoedadfallecio1 hnoedadfallecio2 hnoedadfallecio3 hnoedadfallecio4 hnoedadfallecio5 hnoedadfallecio6 hnoedadfallecio7 hnoedadfallecio8 hnoedadfallecio9 hnoedadfallecio10 ///
				hnoedadfallecio11 hnoedadfallecio12 hnoedadfallecio13 hnoedadfallecio14 hnoedadfallecio15 hnoedadfallecio16 hnoedadfallecio17 hnoedadfallecio18 hnoedadfallecio19
*----XII: FOOD CONSUMPTION / CONSUMO DE ALIMENTO 
		global foodcons_ENCOVI clap clap_cuando
		
*----XIII: FOOD SAFETY / SEGURIDAD ALIMENTARIA 
		global segalimentaria_ENCOVI ingsuf_comida preocucomida_norecursos faltacomida_norecursos nosaludable_norecursos pocovariado_norecursos salteacomida_norecursos comepoco_norecursos ///
				hambre_norecursos nocomedia_norecursos pocovariado_me18_norecursos salteacomida_me18_norecursos comepoco_me18_norecursos nocomedia_me18_norecursos comida_trueque

*----XV: SHOCKS AFFECTING HOUSEHOLDS / EVENTOS QUE AFECTAN A LOS HOGARES 
		global shocks_ENCOVI informant_shock evento_* evento_ot imp_evento_* veces_evento_* ano_evento_* ///
				reaccion_evento_* reaccionot_evento*
*----1.9: Income Variables 
		global ingreso_ENCOVI ingresoslab_mon_local ingresoslab_mon_afuera ingresoslab_mon ingresoslab_bene ijubi_m icap_m rem itranp_o_m itranp_ns itrane_o_m itrane_ns inla_extraord inla_otro

*----Más variables de ingreso CEDLAS 
		global from_cedlas pondera iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_nm /*ijubi_o*/ icap_nm cct itrane_o_nm itranp_o_nm ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi icap itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee pipcf dipcf /*d_ing_ofi p_ing_ofi*/ piea qiea ipc ipc11 ppp11 ipcf_cpi11 ipcf_ppp11 ///
				interview_month interview__id interview__key quest linea_pobreza linea_pobreza_extrema pobre pobre_extremo  // additional

*---- Keep 		
keep $cedlas $control_ent $det_hogares $id_ENCOVI $demo_ENCOVI $dwell_ENCOVI $dur_ENCOVI $educ_ENCOVI $health_ENCOVI $labor_ENCOVI $otherinc_ENCOVI $bank_ENCOVI $mortali_ENCOVI $emigra_ENCOVI $foodcons_ENCOVI $segalimentaria_ENCOVI $shocks_ENCOVI $ingreso_ENCOVI $from_cedlas

*---- Drop de las que teniamos dudas
drop quest informant_emig informant_shock centropo nombcp segmento peso_segmento combined_id tipo_muestra /*gps* */ id_str statut sector_urb 

compress

save "$datapath/varcleaned_ENCOVI_2019_postpobreza.dta", replace
