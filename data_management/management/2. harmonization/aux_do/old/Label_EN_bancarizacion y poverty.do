 

label var razon_no_busca_o "Why aren't you currently looking for a job? (Other reasons)"

/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- XVI: BANKING / BANCARIZACIÓN ---------------------------------------------------------------
************************************************************************************************************************************************)*/
*** Section for individuals 15+
*** 
label var contesta_ind_b "Is the "member" answering by himself/herself?"

*** Who is answering instead of "member"?
label var quien_contesta_b "Who is answering instead of 'member'?"

*** Do you have in any bank the following?
		* Checking account
		label var cuenta_corr "Do you have in any bank the following? Checking account"
		* Savings account
		label var cuenta_aho "Do you have in any bank the following? Savings account"
		* Credit card
		label var tcredito "Do you have in any bank the following? Credit card"
		* Debit card
		label var tdebito "Do you have in any bank the following? Dedit card"
		* None
		label var no_banco "Do you have in any bank the following? None"

*** How often do you pay with cash ?
	label var efectivo_f "How often do you pay with cash?"
	label def efectivo_f_eng 1 "Usually" 2 "Sometimes" 3 "Hardly ever" 4 "Never"
	label val efectivo_f efectivo_f_eng
	
*** How often do you pay with credit card?
	label var tcredito_f "How often do you pay with credit card?"
	label def tcredito_f_eng 1 "Usually" 2 "Sometimes" 3 "Hardly ever" 4 "Never"
	label val tcredito_f tcredito_f_eng

*** How often do you pay with debit card?
	label var tdebito_f "How often do you pay with debit card?"
	label def tdebito_f_eng 1 "Usually" 2 "Sometimes" 3 "Hardly ever" 4 "Never"
	label val tdebito_f tdebito_f_eng

*** How often do you pay using online bank?
	label var bancao_f "How often do you pay using online bank?"
	label def bancao_f_eng 1 "Usually" 2 "Sometimes" 3 "Hardly ever" 4 "Never"
	label val bancao_f bancao_f_eng

*** How often do you use mobile payment?
	label var pagomovil_f "How often do you use mobile payment?"
	label def pagomovil_f_eng 1 "Usually" 2 "Sometimes" 3 "Hardly ever" 4 "Never"
	label val pagomovil_f pagomovil_f_eng

*** Reasons for not holding any bank account or card?
	label var razon_nobanco "Reasons for not holding any bank account or card?"
	
/*(************************************************************************************************************************************************ 
*------------------------------------------------------------- POVERTY ---------------------------------------------------------------
************************************************************************************************************************************************)*/
	*** International poverty line 1.9 USD	
	label var lp_19usd "International poverty line 1.9 USD"

	*** International poverty line 3.2 USD	
	label var lp_32usd "International poverty line 3.2 USD"

	*** International poverty line 5.5 USD	
	label var lp_55usd "International poverty line 5.5 USD"
	
	*** Poverty identifier
	label var pobre "Poverty identifier"
	
	*** Extreme poverty identifier
	label var pobre_extremo "Extreme poverty identifier"
