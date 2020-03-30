/*===========================================================================
Puropose: this scripts generates some summary statistics and evidence for
sampling dessision on COVID VEN survey
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		27 Mar, 2020
Modification Date:  
Output:			products.dta

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 3: Lautaro
		global lauta2   1
		

		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"

		}
		if $trini   {
				global rootpath ""
		}
		
		if $male   {
				global rootpath ""
		}

// set raw data path
global merged "$rootpath\data_management\output\merged"


********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off


/*==============================================================================
Employment Section
==============================================================================*/

// we have to identify low variance questions and missings of the labor section of encovi

use "$merged\individual.dta", replace

// condition to start labor module
keep if s6q5 > 9

tab s9q1, mi
/*
     1. ¿La |
     semana |
   pasada … |
 trabajó al |
  menos una |
      hora? |      Freq.     Percent        Cum.
------------+-----------------------------------
         Sí |      9,050       43.15       43.15
         No |     11,898       56.73       99.88
          . |         18        0.09       99.96
         .a |          8        0.04      100.00
------------+-----------------------------------
      Total |     20,974      100.00
  */


tab s9q2 if s9q1==2, mi
/*
LOW VARIANCE!

     2. ¿…le dedicó la semana pasada al |
                      menos una hora a? |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
Realizar una actividad que le proporcio |        228        1.92        1.92
Ayudar en las tierras o en el negocio d |        109        0.92        2.83
            No trabajó la semana pasada |     11,561       97.17      100.00
----------------------------------------+-----------------------------------
                                  Total |     11,898      100.00

*/

tab s9q3 if s9q1==2 & s9q2==3, mi

/*
LOW VARIANCE!
  3. ¿tiene |
      algún |
    empleo, |
  negocio o |
    realiza |
     alguna |
  actividad |
     por su |
    cuenta? |      Freq.     Percent        Cum.
------------+-----------------------------------
         Sí |        237        2.05        2.05
         No |     11,323       97.94       99.99
         .a |          1        0.01      100.00
------------+-----------------------------------
      Total |     11,561      100.00

*/

tab s9q4 if s9q3==1, mi
/*
(DEPENDS ON s9q3)
     4. ¿Cuál es la razón principal por |
        la que ... no trabajó la semana |
                                pasada? |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                         Estaba enfermo |         35       14.77       14.77
                             Vacaciones |         26       10.97       25.74
                                Permiso |         14        5.91       31.65
                   Conflictos laborales |          6        2.53       34.18
Reparación de equipo, maquinaria, vehíc |         12        5.06       39.24
                     No quiere trabajar |         17        7.17       46.41
   Falta de trabajo, clientes o pedidos |         87       36.71       83.12
      Nuevo empleo a empezar en 30 días |          5        2.11       85.23
                  Factores estacionales |          4        1.69       86.92
                                   Otro |         31       13.08      100.00
----------------------------------------+-----------------------------------
                                  Total |        237      100.00
*/


tab s9q5 if s9q3==1, mi

/*
(DEPENDS ON s9q3)
 5. Durante |
     semana |
     pasada |
       ¿... |
     recibe |
   sueldo o |
 ganancias? |      Freq.     Percent        Cum.
------------+-----------------------------------
         Sí |         87       36.71       36.71
         No |        150       63.29      100.00
------------+-----------------------------------
      Total |        237      100.00
*/



tab s9q6 if s9q3 == 2, mi

 /*
 6. Durante |
  últimas 4 |
   semanas, |
    hizo …. |
  algo para |
  encontrar |
 un trabajo |
remunerado? |      Freq.     Percent        Cum.
------------+-----------------------------------
         Sí |        308        2.72        2.72
         No |     11,015       97.28      100.00
------------+-----------------------------------
      Total |     11,323      100.00
*/


tab s9q7 if s9q6 == 2, mi

/*

Low variance!
    7. O …. |
  hizo algo |
       para |
 empezar un |
   negocio? |      Freq.     Percent        Cum.
------------+-----------------------------------
         Sí |         74        0.67        0.67
         No |     10,941       99.33      100.00
------------+-----------------------------------
      Total |     11,015      100.00
*/


tab s9q8 if s9q7 == 2, mi
/* can be collapsed with others
    8. Última vez que … |
         hizo algo para |
    conseguir trabajo o |
     establecer negocio |      Freq.     Percent        Cum.
------------------------+-----------------------------------
 En los últimos 2 meses |        191        1.75        1.75
En los últimos 12 meses |        115        1.05        2.80
     Hace más de un año |        588        5.37        8.17
No ha hecho diligencias |     10,047       91.83      100.00
------------------------+-----------------------------------
                  Total |     10,941      100.00
*/



tab s9q11 if s9q8!=.
/* OK
    11. ¿Por cuál de estos motivos … no |
     está buscando trabajo actualmente: |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
         Está cansado de buscar trabajo |        375        3.43        3.43
      No encuentra el trabajo apropiado |        654        5.98        9.40
     Cree que no va a encontrar trabajo |        340        3.11       12.51
   No sabe cómo ni dónde buscar trabajo |        245        2.24       14.75
Cree que por su edad no le darán trabaj |      1,864       17.04       31.79
Ningún trabajo se adapta a sus capacida |        222        2.03       33.82
      No tiene quién le cuide los niños |      1,037        9.48       43.30
          Está enfermo/motivos de salud |      1,455       13.30       56.59
              Otro motivo ? Especifique |      4,749       43.41      100.00
----------------------------------------+-----------------------------------
                                  Total |     10,941      100.00
*/


. tab s9q12 if s9q11!=., mi
//
//      12. Qué está haciendo actualmente? |
//  (sólo para aquellos que no trabajaron) |      Freq.     Percent        Cum.
// ----------------------------------------+-----------------------------------
//                              Estudiando |      3,492       31.92       31.92
//                              Entrenando |         65        0.59       32.51
// Actividades del hogar o responsabilidad |      4,328       39.56       72.07
// Trabajando en una parcela para uso fami |         81        0.74       72.81
//                   Jubilado o pensionado |      1,507       13.77       86.58
//               Enfermedad de largo plazo |        274        2.50       89.09
//                            Discapacidad |        489        4.47       93.56
//                      Trabajo voluntario |        118        1.08       94.63
//                         Trabajo caridad |         27        0.25       94.88
//        Actividades culturales o de ocio |        559        5.11       99.99
//                                      .a |          1        0.01      100.00
// ----------------------------------------+-----------------------------------
//                                   Total |     10,941      100.00


//VARIABLE AUXILIAR


gen empleo = 1 if  s9q1==1 | inlist(s9q2,1,2) | s9q3==1 | s9q5==1




tab s9q17 if emp==1, mi
//
//         17. |
//     ¿Además |
//  de trabajo |
//  principal, |
//     realizó |
//        otra |
//   actividad |
//  que generó |
//   ingresos? |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//          Sí |        442        4.59        4.59
//          No |      9,179       95.38       99.97
//          .a |          3        0.03      100.00
// ------------+-----------------------------------
//       Total |      9,624      100.00
//

sum s9q19__*

//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//     s9q19__1 |      4,947    .9446129    .2287574          0          1
//     s9q19__2 |      4,841    .0530882    .2242325          0          1
//     s9q19__3 |      4,835     .020062    .1402271          0          1
//     s9q19__4 |      4,833     .048831    .2155368          0          1
//     s9q19__5 |      4,901    .6151806    .4866022          0          1
// -------------+---------------------------------------------------------
//     s9q19__6 |      4,840    .0022727    .0476238          0          1
//     s9q19__7 |      4,830    .0031056     .055647          0          1
//     s9q19__8 |      4,840    .0295455    .1693471          0          1
//     s9q19__9 |      4,853    .0434783    .2039521          0          1
//    s9q19__10 |      4,846    .0410648    .1984606          0          1
// -------------+---------------------------------------------------------
//    s9q19__11 |      4,840    .0233471     .151019          0          1
//    s9q19__12 |      4,840    .0402893    .1966571          0          1



sum s9q20__*
//
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//     s9q20__1 |      4,938     .146213    .3533554          0          1
//     s9q20__2 |      4,926    .0578563    .2334952          0          1
//     s9q20__3 |      4,916     .034581    .1827345          0          1
//     s9q20__4 |      4,921    .0288559    .1674185          0          1
//     s9q20__5 |      4,911    .0071269    .0841279          0          1
// -------------+---------------------------------------------------------
//     s9q20__6 |      4,907    .0018341    .0427916          0          1



 sum s9q21__*
//
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//     s9q21__1 |      4,936    .0950162     .293267          0          1
//     s9q21__2 |      4,923     .015844    .1248845          0          1
//     s9q21__3 |      4,933    .0279749    .1649175          0          1
//     s9q21__4 |      4,924    .0008123     .028493          0          1
//     s9q21__5 |      4,930    .0008114    .0284757          0          1
// -------------+---------------------------------------------------------
//     s9q21__6 |      4,926    .0028421    .0532406          0          1
//     s9q21__7 |      4,925     .000203    .0142494          0          1
//     s9q21__8 |      4,921    .0004064    .0201578          0          1
//     s9q21__9 |      4,913    .0044779     .066774          0          1

sum s9q22__*

//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//     s9q22__1 |      4,926      .31892    .4661053          0          1
//     s9q22__2 |      4,898     .118824    .3236143          0          1
//     s9q22__3 |      4,891    .0181967    .1336758          0          1
//     s9q22__4 |      4,908    .0729421     .260068          0          1
//     s9q22__5 |      4,892    .0065413    .0806215          0          1
// -------------+---------------------------------------------------------
//     s9q22__6 |      4,902     .124439    .3301154          0          1
//     s9q22__7 |      4,878     .004305    .0654782          0          1


tab s9q23, mi
//    24. ¿Con |
// respecto al |
//  mes pasado |
//    … dinero |
//   por venta |
// productos/s |
//    ervicios |
//     negocio |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//          Sí |        185        0.88        0.88
//          No |        167        0.80        1.68
//           . |     20,622       98.32      100.00
// ------------+-----------------------------------
//       Total |     20,974      100.00
//

tab s9q24, mi

//  24. El mes |
//      pasado |
//     ¿retiró |
//           … |
//   productos |
// del negocio |
// o actividad |
//        para |
//     consumo |
//       hogar |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//          Sí |         73        0.35        0.35
//          No |        279        1.33        1.68
//           . |     20,622       98.32      100.00
// ------------+-----------------------------------
//       Total |     20,974      100.00

. tab s9q25, mi

// 25. Durante |
//  últimos 12 |
//       meses |
//    ¿recibió |
//           … |
// ganancias o |
//    utilidad |
//     negocio |
//      propio |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//          Sí |      1,641        7.82        7.82
//          No |      2,637       12.57       20.40
//           . |     16,694       79.59       99.99
//          .a |          2        0.01      100.00
// ------------+-----------------------------------
//       Total |     20,974      100.00



. tab s9q33

//      33. ¿Por cuál motivo… no ha hecho |
//        diligencias para trabajar horas |
//                           adicionales? |      Freq.     Percent        Cum.
// ---------------------------------------+-----------------------------------
//                Cree que no hay trabajo |        136        8.09        8.09
//         Está cansado de buscar trabajo |         70        4.16       12.25
//                 No sabe buscar trabajo |         17        1.01       13.27
//         No encuentra trabajo apropiado |        131        7.79       21.06
//       Está esperando trabajo o negocio |        111        6.60       27.66
//      Dificultad para tramitar permisos |         18        1.07       28.73
// No consigue créditos o financiamientos |         25        1.49       30.22
//                          Es estudiante |         95        5.65       35.87
//                     Se ocupa del hogar |        726       43.19       79.06
//              Enfermedad o discapacidad |        105        6.25       85.31
//                     Otra (Especifique) |        247       14.69      100.00
// ---------------------------------------+-----------------------------------
//                                  Total |      1,681      100.00

tab s9q36

// 36. Realiza |
//     aportes |
//  para algún |
//    fondo de |
//   pensiones |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//          Sí |        480        2.29        2.29
//          No |      9,138       43.57       45.86
//           . |     11,350       54.11       99.97
//          .a |          6        0.03      100.00
// ------------+-----------------------------------
//       Total |     20,974      100.00


 sum s9q37__* if s9q36==1

//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//     s9q37__1 |        480      .93125    .2532925          0          1
//     s9q37__2 |        480    .0520833    .2224269          0          1
//     s9q37__3 |        480    .0270833    .1624957          0          1
//     s9q37__4 |        480    .0041667    .0644823          0          1




. sum s9q28__*

//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//     s9q28__1 |     20,697    .0240131    .1530936          0          1
//     s9q28__2 |     20,816    .1789489    .3833187          0          1
//     s9q28__3 |     20,730    .0399421     .195828          0          1
//     s9q28__4 |     20,687    .0007734    .0278006          0          1
//     s9q28__5 |     20,677    .0026116    .0510383          0          1
// -------------+---------------------------------------------------------
//     s9q28__6 |     20,678    .0003869    .0196661          0          1
//     s9q28__7 |     20,726    .1459037    .3530182          0          1
//     s9q28__8 |     20,674    .0012576    .0354415          0          1
//     s9q28__9 |     20,695    .0304905    .1719367          0          1
//    s9q28__10 |     20,675    .0057074    .0753331          0          1
// -------------+---------------------------------------------------------
//    s9q28__11 |     20,643    .0610861    .2394939          0          1


sum s9q29a__*



//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//    s9q29a__1 |     20,895     .010146    .1002173          0          1
//    s9q29a__2 |     20,808    .0015379    .0391865          0          1
//    s9q29a__3 |     20,777    .0000963     .009811          0          1
//    s9q29a__4 |     20,775    .0464982    .2105665          0          1
//    s9q29a__5 |     20,750    .0026506     .051417          0          1
// -------------+---------------------------------------------------------
//    s9q29a__6 |     20,726    .0000965    .0098231          0          1
//    s9q29a__7 |     20,741    .0001446    .0120261          0          1
//    s9q29a__8 |     20,757    .0046731     .068202          0          1
//    s9q29a__9 |     20,736    .0002411    .0155268          0          1


