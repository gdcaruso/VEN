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
cap label def region_est1 1 "Central"  2 "Llanera" 3 "Occidental" 4 "Zuliana" ///
          5 "Andina" 6 "Nor-Oriental" 7 "Capital"
cap label value region_est1 region_est1

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

cap label var    nuevareg        "Geographical coverage of survey"

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

cap label var    relab_s         "Type of employment in the secondary occupation"
cap label define relab_s 		 1 "Employer" 2 "Salaried worker" 3 "Self-employed" 4 "Without salary" 5 "Unemployed"
cap label values relab_s relab_s

cap label var    relab_o         "Type of employment in the terciary occupation"
cap label define relab_o 		 1 "Employer" 2 "Salaried worker" 3 "Self-employed" 4 "Without salary" 5 "Unemployed"
cap label values relab_o relab_o

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
label var    inla_otro       "Other non-labor income (imputation for inla except retirement benefits & pensions)"
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
cap label var    lp_extrema	     "Official extreme poverty line"
cap label var    lp_moderada     "Official moderate poverty line"
label var pobre 				 "Poverty identifier"
label var pobre_extremo 		 "Extreme poverty identifier"
cap label var    ing_pob_ext     "Income used to estimate official extreme poverty"
cap label var    ing_pob_mod     "Income used to estimate official moderate poverty"
cap label var    ing_pob_mod_lp  "Official income / Poverty Line"
cap label var    p_reg	         "Adjustment factor for regional prices"
cap label var    ipc	         "CPI base month" 
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
