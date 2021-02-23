/*===========================================================================
Purpose: import daily exchange rate data and produce montly exchange 
rates for 2019 and 2020

Country name:	Venezuela
Year:			2019 and 2020
Project:	
---------------------------------------------------------------------------
Authors:			Julieta Ladronis

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Exchange rates dataset


*--- Source: 1.	Banco Central de Venezuela (BCV), daily data 
(http://www.bcv.org.ve/estadisticas/tipo-de-cambio). 

*--- Note (1): Using 2.	Dólar Today (https://dolartoday.com/), daily data was very similar. 
*--- Note (2): We decide to use the official exchange rates to avoid some daily jumps 
in the exchange rates

=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
		
		* User 5: Britta
		global britta 1
			
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN\data_management\management\1. merging\exchange rates" 
				global dataout "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\input"
				
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
				global dataout "$rootpath\"
		}
		if $trini   {
				global rootpath ""
				global dataout "$rootpath\"
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN\data_management\management\1. merging\exchange rates"
				global dataout "$rootpath\"
		}
		
		if $britta   {
				global rootpath "F:\Working with Github\WB\VEN\data_management\management\1. merging\exchange rates"
				global dataout "$rootpath\"
		}
				
		
		
*********************************************************************************
*--- Import official data of exchange rates

*********************************************************************************
*--------------- 1T 2019		
*--------------- Set the dates of the exchange rate as a local 
/* These are the names of the excel spreadsheet which contain daily data for each trimester	
	local fechas_T1_2019 30092019 27092019 26092019 25092019 24092019 23092019 ///
	20092019 19092019 18092019 17092019 13092019 12092019 11092019 10092019 09092019 ///
	06092019 05092019 04092019 03092019 02092019 30082019 29082019 28082019 27082019 26082019 ///
	23082019 22082019 21082019 20082019 16082019 15082019 14082019 13082019 12082019 09082019 ///
	08082019 07082019 06082019 05082019 
	
	foreach k of local fechas_T1_2019 {
			  cap import excel using "$rootpath\2_1_2b19.xls", sheet(`k') cellrange(B9:G47) firstrow clear
		gen date="`k'"
		if `k'==30092019 {
		tempfile exch1
		save `exch1'
		}
		else {
			replace date="`k'"
			append using `exch1'
			save `exch1', replace
		}
	}


// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
	keep if Compra!=. 
	//Generate a code for each currency
	encode COD_moneda, gen(COD_moneda_e)

// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace force
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

	// Save as temporal file
	save `exch1', replace
	clear*/

*--------------- 2T 2019		
*--------------- Set the dates of the exchange rate as a local 
*These are the names of the excel spreadsheet which contain daily data for each trimester	
	local fechas_T2_2019 28062019 27062019 26062019 25062019 21062019 20062019 ///
	19062019 18062019 14062019 13062019 12062019 11062019 10062019 07062019 06062019 ///
	05062019 04062019 31052019 30052019 29052019 28052019 27052019 24052019 23052019 22052019 ///
	21052019 20052019 17052019 16052019 15052019 14052019 13052019 10052019 09052019 08052019 ///
	07052019 06052019 03052019 02052019 
	
	foreach k of local fechas_T2_2019 {
			  cap import excel using "$rootpath\2_1_2b19.xls", sheet(`k') cellrange(B9:G47) firstrow clear 
		gen date="`k'"		
		if `k'==28062019 {
		tempfile exch2
		save `exch2'
		}
		else {
			replace date="`k'"
			append using `exch2'
			save `exch2', replace
		}
	}


// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
	keep if Compra!=. 
	//Generate a code for each currency
	encode COD_moneda, gen(COD_moneda_e)

// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace force
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

	// Save as temporal file
	save `exch2', replace
	clear
	
	
*--------------- 3T 2019		
*--------------- Set the dates of the exchange rate as a local 
* These are the names of the excel spreadsheet which contain daily data for each trimester	
	local fechas_T3_2019 30092019 27092019 26092019 25092019 24092019 23092019 ///
	20092019 19092019 18092019 17092019 13092019 12092019 11092019 10092019 09092019 ///
	06092019 05092019 04092019 03092019 02092019 30082019 29082019 28082019 27082019 26082019 ///
	23082019 22082019 21082019 20082019 16082019 15082019 14082019 13082019 12082019 09082019 ///
	08082019 07082019 06082019 05082019 02082019 01082019 31072019 30072019 29072019 27072019 26072019 ///
	25072019 23072019 22072019 19072019 18072019 17072019 16072019 15072019 12072019 11072019 10072019 ///
	09072019 08072019 04072019 03072019 02072019 01072019
	foreach k of local fechas_T3_2019 {
			  cap import excel using "$rootpath\2_1_2c19.xls", sheet(`k') cellrange(B9:G47) firstrow clear
		gen date="`k'"
		if `k'==30092019 {
		tempfile exch3
		save `exch3'
		}
		else {
			replace date="`k'"
			append using `exch3'
			save `exch3', replace
		}
	}


// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
	keep if Compra!=. 
	//Generate a code for each currency
	encode COD_moneda, gen(COD_moneda_e)

// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace force
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

	// Save as temporal file
	save `exch3', replace
	clear

*--------------- 4T 2019		
*--------------- Set the dates of the exchange rate as a local 
* These are the names of the excel spreadsheet which contain daily data for each trimester	
	local fechas_T1 31102019 30102019 29102019 28102019 25102019 24102019 23102019 ///
	22102019 21102019 18102019 17102019 16102019 15102019 14102019 11102019 10102019 09102019 ///
	08102019 07102019 04102019 03102019 02102019 01102019 ///
	30122019 27122019 26122019 23122019 20122019 19122019 ///
	18122019 17122019 16122019 13122019 12122019 11122019 10122019 09122019 ///
	06122019 05122019 04122019 03122019 02122019 29112019 28112019 27112019 26112019 ///
	25112019 22112019 21112019 20112019 19112019 18112019 15112019 14112019 ///
	13112019 12112019 11112019 08112019 07112019 06112019 05112019 01112019
	
	foreach k of local fechas_T1 {
			  cap import excel using "$rootpath\2_1_2d19.xls", sheet(`k') cellrange(B9:G47) firstrow clear
		gen date="`k'"
		if `k'==31102019 {
		tempfile exch4
		save `exch4'
		}
		else {
			replace date="`k'"
			append using `exch4'
			save `exch4', replace
		}
	}


// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
	keep if Compra!=. 
	//Generate a code for each currency
	encode COD_moneda, gen(COD_moneda_e)

// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace force
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

	// Save as temporal file
	save `exch4', replace
	clear
	
*********************************************************************************
*--- Import official data of exchange rates
*--- Source: 
*********************************************************************************

*--------------- 1T 2020	
*--------------- Set the dates of the exchange rate as a local 
* These are the names of the excel spreadsheet which contain daily data for each trimester
	local fechas_T4 31032020 30032020 27032020 26032020 25032020 24032020 23032020 20032020 18032020 17032020 16032020 13032020 12032020 11032020 10032020 09032020 06032020 05032020 04032020 03032020 02032020 28022020 27022020 26022020 21022020 20022020 19022020	18022020 17022020 14022020 ///
	13022020 12022020 11022020 10022020 07022020 06022020 05022020 04022020 03022020 31012020 ///
	30012020 29012020 28012020 27012020	24012020 23012020 22012020 21012020	17012020 ///
	16012020 15012020 14012020 13012020 10012020 09012020 08012020 07012020 03012020 02012020	
foreach i of local fechas_T4 {
          cap import excel using "$rootpath\2_1_2a20.xls", sheet(`i') cellrange(B9:G47) firstrow clear	  
	gen date="`i'"
	if `i'==31032020 {
	tempfile exch5
	save `exch5'
	}
	else {
	    replace date="`i'"
		append using `exch5'
		save `exch5', replace
		}
}

// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
keep if Compra!=. 
//Generate a code for each currency
encode COD_moneda, gen(COD_moneda_e)

	// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace force
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

// Save as temporal file
	save `exch5', replace
	clear

*********************************************************************************
*--- Import official data of exchange rates
*--- Source: 
*********************************************************************************

*--------------- 2T 2020	
*--------------- Set the dates of the exchange rate as a local 
* These are the names of the excel spreadsheet which contain daily data for each trimester
	local fechas_T9 08042020 07042020 06042020 03042020 02042020 01042020	
foreach x of local fechas_T9 {
          cap import excel using "$rootpath\2_1_2b20.xls", sheet(`x') cellrange(B9:G47) firstrow clear	  
	gen date="`x'"
	if `x'==08042020 {
	tempfile exch6
	save `exch6'
	}
	else {
	    replace date="`x'"
		append using `exch6'
		save `exch6', replace
		}
}

// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
keep if Compra!=. 
//Generate a code for each currency
encode COD_moneda, gen(COD_moneda_e)

	// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace force
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date
	
********************************************************************************
*---  Append both databases
********************************************************************************
//append using `exch1', force
append using `exch2', force
append using `exch3', force
append using `exch4', force
append using `exch5', force

*********************************************************************************
*--- To select the currency units included in the survey
*********************************************************************************
// Pesos Colombianos: 11 COP 
// Euros 17 EUR
// Venezuela 29 PTR
// Dolar 35 USD

	keep if COD_moneda_e==11 | COD_moneda_e==17 | COD_moneda_e==29 | COD_moneda_e==35
	
	// Transform codes according to survey codes for currency
	// Pesos Colombianos: 11 COP ---> 4
	// Euros              17 EUR ---> 3
	// Venezuela          29 PTR ---> 
	// Dolar              35 USD ---> 2

	//replace COD_moneda_e=4 if COD_moneda_e==11 // Pesos colombianos
	//replace COD_moneda_e=3 if COD_moneda_e==17 // Euros
	//replace COD_moneda_e=2 if COD_moneda_e==35 // Dolar

	//rename COD_moneda_e moneda 
*********************************************************************************
*--- Save exchange rates dataset
*********************************************************************************
	 
	save "$dataout\exchenge_rate_sum_with2019T2", replace

*********************************************************************************
*--- Generate dataset to merge with prices
*********************************************************************************

    // Keep only relevant data
	collapse (mean) mean_moneda=Venta (median) median_moneda=Venta, by (month year COD_moneda)
	gen moneda=.
	replace moneda=2 if COD_moneda=="USD"
	replace moneda=3 if COD_moneda=="EUR"
	replace moneda=4 if COD_moneda=="COP"
	// Given that Petro is not relevant for our analysis we use this to generate the
	// exchange rate Bolivar-Bolivar
	replace moneda=1 if COD_moneda!="COP" & COD_moneda!="EUR" & COD_moneda!="USD"
	replace COD_moneda="BOL" if moneda==1
	replace mean_moneda=1 if moneda==1
	replace median_moneda=1 if moneda==1
	keep if moneda!=.	
	rename month mes
	
*********************************************************************************
*--- Save exchange rates dataset to merge with prices
*********************************************************************************
	
	save "$dataout\exchenge_rate_price_with2019T2", replace
	
	
	
	
	
