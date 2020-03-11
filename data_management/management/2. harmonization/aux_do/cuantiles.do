*===================================================================*
* cuantiles.do                                                      *
*===================================================================*

* ultima revision
* 10/1/2005
* 27/1/2006
* 6/4/2009

capture program drop cuantiles

program define cuantiles
  version 7.0
  syntax varlist(max=1) [if] [fweight], Ncuantiles(integer) Generate(namelist) [orden_aux(varlist)]
  tokenize `varlist'
  
  quietly {

    * cuantiles en, por ejemplo, d_ipcf
    local quanpers="`generate'"
    
    tempvar suma mipondera mivar
  
    local wt : word 2 of `exp'
    if "`wt'"=="" {
      local wt = 1
    }  

    gen `mivar'=.
    replace `mivar'=`1' `if' 
    * ojo con los missing!
    * no lo puedo hacer en la linea anterior porque la macro local if incluye la palabra "if"
    replace `mivar'=. if `1'==.

    sort `mivar' `orden_aux', stable
    
    gen `mipondera'=`wt'
    replace `mipondera'=0 if `mivar'==.     
    gen `suma'=sum(`mipondera')

    *ppquan = Personas Por Quantil
    *ppquan es el número de personas que debería tener cada quantil

    summ `mipondera', meanonly
    
    scalar ppquan = r(sum)/`ncuantiles'
    generate `quanpers'=.
    
    forvalues i=1(1)`ncuantiles' {
      display `i'
      replace `quanpers'=`i' if `suma'>(`i'-1)*ppquan & `suma'<=`i'*ppquan & `mivar'!=. 
    }
 
  }
  
  if `ncuantiles' <=375 { 
    tabulate `quanpers' [`weight'`exp'], summ(`1')
  }
end

