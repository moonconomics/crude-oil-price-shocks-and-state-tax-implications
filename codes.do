/*
Moon Oulatta, Ph.D. 
Assistant professor of economics
oulatta@niler.org
						
						Crude oil price shocks and state tax implications

Instructions: this do file provides a complete list of codes to replicate 
the key tables and Figures in this paper. Once you set the correct directory
from where you can access all the raw files, just execute the do file. 
*/
* Use STATA 16 or higher 

*Installing required packages:
ssc install ranktest
ssc install xtpmg, replace
ssc install ivreg2
ssc install xtivreg2
ssc install pnardl
ssc install estout 
net install st0373, from(http://www.stata-journal.com/software/sj15-1)

/*  					 I.   Main Data

Set the directory from where you will import all the raw excel files to 
compute the main-data set. You should set up the raw_data folder on your desktop 
and replace the address in line 29 with your own address. 
*/


cd "C:\Users\muuno\Desktop\Energy Economics\raw_data"



/* (i). Loading the state tax data and the fuel tax data

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. The units of the data are changed to the true numbers by multiplying
the data by $1,000,000. Some states suspended such as alaska suspended motor fueltax
tax in 2009, but the Federal Reserve Bank of Saint Louis made a mistake in their data 
and put a negative number in the data. We replace this number with 0. 
*/

import excel "state tax collection (total taxes).xlsx", sheet("Raw data") firstrow clear
sort states years
rename Statetaxestotalcollection tax
label var tax "State tax collection (total taxes)"
replace tax= (tax*1000000)
save tax_data.dta, replace 

import excel "Motor fuel taxes.xlsx", sheet("Data") firstrow clear
sort states years
label var fueltax "Motor fuel state taxes"
replace fueltax= (fueltax*1000000)
replace fueltax= 0 if fueltax<0
save fueltax_data.dta, replace 







/* (ii). Loading the crude petroleum export data

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format.  
*/

import excel "27 Mineral Fuel, Oil Etc.; Bitumin Subst; Mineral Wax.xlsx", sheet("Raw data") firstrow clear
sort states years
rename totalvalueus CRUDEXPORT
label var CRUDEXPORT "27 Mineral Fuel, Oil Etc.; Bitumin Subst; Mineral Wax"
drop country commodity
save export_data.dta, replace 


/* (iii). Loading the personal consumption expenditure data

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. The units of the data are changed to the true numbers by multiplying the data by $1,000,000. 
*/

import excel "Personal consumption expenditures.xlsx", sheet("Raw data") firstrow clear
sort states years
rename Personalconsumptionexpenditure cons
label var cons "Personal consumption expenditures"
replace cons= (cons*1000000)
save cons_data.dta, replace 


/* (iv). Loading the resident population data

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. The units of the data are changed to the true numbers by multiplying the data by $1,000
*/

import excel "Resident population.xlsx", sheet("Raw data") firstrow clear
sort states years
rename Residentpopulation population
label var population "Resident poulation by state"
replace population= (population*1000)
save pop_data.dta, replace 

/* (v). Loading the airport passenger traffic data
Importing the raw tax data and cleaning the raw data and transforming the data into STATA format.  
*/

import excel "U.S Airline Traffic By Airport.xlsx", sheet("Raw data") firstrow clear
sort states years
label var passengers "US air traffic by state, passengers"
save airtraffic_data.dta, replace 

/* (vi). Loading the consumer price index data

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. Here, we choose 1994 as the base year for all price indexes. 
*/

import excel "Consumer price index.xlsx", sheet("Annual") firstrow clear
sort states years
gen cpi94= CPIAUCSL if years==1994
by states: egen mean= mean( cpi94)
gen consumerpriceindex= (CPIAUCSL/ mean)*100
drop CPIAUCSL cpi94 mean
rename consumerpriceindex CPI
label var CPI "Consumer price index, base year 1994"
save CPI.dta, replace 


/* (vii). Loading the FHFA house price index

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. Here, we choose 1994 as the base year for all price indexes. 
*/

import excel "FHFA house price index.xlsx", sheet("state") firstrow clear
sort states years
drop if years<1994
keep states years HPI
gen HPI94= HPI if years==1994
sort states 
by states: egen mean= mean(HPI94)
gen HPINDEX= (HPI/ mean)*100
drop HPI94 mean HPI
label var HPINDEX "FHFA House Price Index, base year 1994"
save HPI.dta, replace 

/* (viii). Loading the gasoline price data 

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. Here, we choose 1994 as the base year for all price indexes. 
*/
import excel "gasoline_data.xlsx", sheet("Annual") firstrow clear
sort states years
gen gas94= GASREGW if years==1994
sort states
by states: egen mean= mean(gas94)
gen gaspriceindex= (GASREGW/ mean)*100
drop GASREGW gas94 mean
label var gaspriceindex "US regular gasoline price index, base year 1994"
save gasoline.dta, replace 

/* (ix). Loading the West Texas Crude Oil Cushing data  

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. Here, we choose 1994 as the base year for all price indexes. 
*/

import excel "West Texas Crude Cushing Prices.xlsx", sheet("Annual") firstrow clear
sort states years
gen WTI94= DCOILWTICO if years==1994
sort states 
by states: egen mean= mean(WTI94)
gen WTIpriceindex= (DCOILWTICO/ mean)*100
drop DCOILWTICO WTI94 mean
label var WTIpriceindex "WTI crude oil cushing price index, base year 1994"
save WTI.dta, replace 


/* (x). Loading the GDP data  

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. The units of the data are changed to the true numbers by multiplying the data by $1,000,000. 
*/
import excel "US GDP data.xlsx", sheet("Raw data") firstrow clear
rename CurrentdollarGrossDomesticPr gdp
replace gdp= (gdp*1000000)
label var gdp "US GDP in current dollars"
save gdp.dta, replace 



/* (xi). Loading the oil and gas extraction variable  

Importing the raw tax data and cleaning the raw data and transforming the data into STATA format. The units of the data are changed to the true numbers by multiplying the data by $1,000,000  
*/

import excel "Oil and gas extraction.xlsx", sheet("Raw_data") firstrow clear
replace oilandgasextraction= (oilandgasextraction*1000000)
label var oilandgasextraction "Oil and gas extraction contributions to GDP"
rename oilandgasextraction oilgas
save oilandgas.dta, replace 

/* (xii). Loading the returns variable  
Importing the raw tax data and cleaning the raw data and transforming the data into STATA format.  
*/
import excel "returns.xlsx", sheet("Dow Returns") firstrow clear
label var returns "Annual Dow Jones Induistrial Stock Returns (%)"
save returns.dta, replace 
********************************************************************************

* Merging all data to create one unique file (starting with the tax data)

use "tax_data.dta", clear

merge m:m years states using "airtraffic_data.dta"
drop _merge 

merge m:m years states using "cons_data.dta"
drop _merge 

merge m:m years states using "gdp.dta"
drop _merge 

merge m:m years states using "CPI.dta"
drop _merge 

merge m:m years states using "pop_data.dta"
drop _merge 

merge m:m years states using "WTI.dta"
drop _merge 

merge m:m years states using "returns.dta"
drop _merge 

merge m:m years states using "gasoline.dta"
drop _merge 

merge m:m years states using "HPI.dta"
drop _merge 

merge m:m years states using "export_data.dta"
drop _merge 

merge m:m years states using "oilandgas.dta"
drop _merge 

merge m:m years states using "fueltax_data.dta"
drop _merge 
*******************************************************************************


* Constructing all the key variables 

* Declare panel data
encode states, gen(cc)
xtset cc years

											
gen oilshare= (oilgas/gdp)*100
label var oilshare "oil and gas extraction percentage of GDP (%)"

gen taxpc=(tax/ population)
gen Tau= log(taxpc)
label var Tau "Log of state tax revenue per capita"

gen fueltaxpc=(fueltax/ population)
gen Tauf= log(fueltaxpc)
label var Tauf "Log of state fuel taxes per capita"


gen conspc=( cons/ population)
gen ci=log(conspc)
label var ci "Log of consumption expenditure per capita"

gen CRUDEXPORTPERCAPITA=(CRUDEXPORT/ population)
gen crudeExport=log( CRUDEXPORTPERCAPITA)
label var crudeExport "Log of crude petroleum and gas export per capita"

gen AIRPC=( passengers/ population)
gen airTraffic=log(AIRPC)
label var airTraffic "Log of air traffic passengers per capita"

gen PCPJ=( WTIpriceindex/ CPI)
gen pcpj=log(PCPJ)
label var pcpj "Log of the relative price of crude oil (CPI is deflator)"


gen PCPH=(WTIpriceindex /HPI)
gen pcph=log(PCPH)
label var pcph "Log of the relative price of crude oil (HPI is deflator)"


gen PGPJ= (gaspriceindex/ CPI)
gen pgpj= log(PGPJ)
label var pgpj "Log of the relative price of regular gasoline (CPI is deflator)"

gen pcpjq= (pcpj)^2
gen pcphq= (pcph)^2
gen pgpjq= (pgpj)^2

label var pcpjq "Quadratic term for pcpj"
label var pcphq "Quadratic term for pcph"
label var pgpjq "Quadratic term for pgpj"


gen dTau= (d.Tau)
label var dTau "Growth rate of Tau"

gen dTauf= (d.Tauf)
label var dTau "Growth rate of Tauf"

gen dci= (d.ci)
label var dci "Growth rate of ci"

gen dcrudeExport= (d.crudeExport)
label var dcrudeExport "Growth rate of crudeExport"

gen y=log(gdp/population)
label var y "Log of GDP per capita"
gen dy= (d.y) 
label var dy "Nominal GDP growth"

gen covid= 1 if years==2020 |years==2021 |years==2022 |years==2023
replace covid= 0 if covid==.
label var covid "Coronavirus pandemic"
gen gfc= 1 if years==2008 | years==2009 | years==2010
replace gfc = 0 if gfc==.
label var gfc "Global Financial Crisis Dummy Variable"


			* Weight of motor fuel tax revenue in the tax structure 

gen taxshare=(fueltax/ tax)*100					
tabstat taxshare, stat(mean)					




keep states years Tau Tauf dTauf ci crudeExport airTraffic pcpj pcph pgpj pcpjq pcphq pgpjq dTau dci dcrudeExport returns oilshare y dy cc covid gfc


save "main-data.dta", replace 


*******************************************************************************
			
* Panel Two Stage Least Estimator (Tables 1 and 9)


xtivreg2 Tau l2.Tau pcpj pcpjq   (ci= l3.ci air), r cluster(cc) first fe
estimates store iv1
xtivreg2 Tau l2.Tau pcph pcphq   (ci= l3.ci air), r cluster(cc) first fe
estimates store iv2
xtivreg2 Tau l3.Tau pgpj pgpjq   (ci= l3.ci air), r cluster(cc) first fe
estimates store iv3

xtivreg2 Tau l2.Tau pcpj pcpjq   (ci= l4.ci l4.returns), r cluster(cc) first fe
estimates store iv4
xtivreg2 Tau l2.Tau pcph pcphq   (ci= l4.ci l6.returns), r cluster(cc) first fe
estimates store iv5
xtivreg2 Tau l3.Tau pgpj pgpjq   (ci= l4.ci l6.returns), r cluster(cc) first fe
estimates store iv6

xtivreg2 Tau l2.Tau pcpj pcpjq   (ci= l3.ci d.crudeExport), r cluster(cc) first fe
estimates store iv7
* Equation used to estimate FIgure 2, See Figure 2.xlsx in raw folder. 


xtivreg2 Tau l2.Tau pcph pcphq   (ci= l3.ci d.crudeExport), r cluster(cc) first fe
estimates store iv8
xtivreg2 Tau l3.Tau pgpj pgpjq   (ci= L4.ci d.crudeExport), r cluster(cc) first fe
estimates store iv9


esttab iv1 iv2 iv3 iv4 iv5 iv6 iv7 iv8 iv9 using table1.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace


/* Additional robustness (Tables 14 and 16)
We conduct an additional robustness check by using the lags of air traffic and crude export as instruments, which relaxes the strict exogeneity condition. Additionally, we control for the 2008 Global Financial crisis and the coronavirus pandemic to ensure that the main empirical results are not purely driven by key historical macroeconomic shocks.
*/


xtivreg2 Tau l5.Tau pcpj pcpjq covid gfc   (ci= l5.ci l1.air covid gfc), r cluster(cc) first fe
estimates store ivr1
xtivreg2 Tau l5.Tau pcph pcphq covid gfc   (ci= l5.ci l1.air covid gfc), r cluster(cc) first fe
estimates store ivr2
xtivreg2 Tau l2.Tau pgpj pgpjq covid gfc   (ci= l3.ci l1.air covid gfc), r cluster(cc) first fe
estimates store ivr3


xtivreg2 Tau l2.Tau pcpj pcpjq covid gfc   (ci= l3.ci l2.d.crudeExport covid gfc), r cluster(cc) first fe
estimates store ivr4
xtivreg2 Tau l3.Tau pcph pcphq covid gfc   (ci= l3.ci l2.d.crudeExport covid gfc), r cluster(cc) first fe
estimates store ivr5
xtivreg2 Tau l2.Tau pgpj pgpjq covid gfc   (ci= l3.ci l2.d.crudeExport covid gfc), r cluster(cc) first fe
estimates store ivr6


xtivreg2 Tau l2.Tau pcpj pcpjq covid gfc   (ci= l3.ci l6.returns covid gfc), r cluster(cc) first fe
estimates store ivr7
xtivreg2 Tau l2.Tau pcph pcphq covid gfc   (ci= l3.ci l6.returns covid gfc), r cluster(cc) first fe
estimates store ivr8
xtivreg2 Tau l2.Tau pgpj pgpjq covid gfc   (ci= l3.ci l3.returns covid gfc), r cluster(cc) first fe
estimates store ivr9


esttab ivr1 ivr2 ivr3 ivr4 ivr5 ivr6 ivr7 ivr8 ivr9 using table2.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace







		* Panel Fixed Effects Threshold Regression Model (Table 2)
			
xthreg Tau, rx(l2.Tau crudeExport pcpj pcpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc) 
estimates store tres1
xthreg Tau , rx(l2.Tau crudeExport pcph pcphq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres2
xthreg Tau, rx(l2.Tau crudeExport pgpj pgpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres3

					
xthreg Tau l1.returns, rx(l2.Tau crudeExport pcpj pcpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres4
xthreg Tau l1.returns, rx(l2.Tau crudeExport pcph pcphq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres5
xthreg Tau l1.returns, rx(l2.Tau crudeExport pgpj pgpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres6

	
xthreg Tau, rx(l2.Tau l1.d.ci pcpj pcpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres7
* This equation is used to estimate Figure 2, See Figure 2.xlsx in the raw data folder. 
* Oil-dependent versus non-oil dependent states are also computed from this equation
drop _cat
gen oil= 1 if cc==2 | cc==18 | cc==31 | cc==34 | cc==36 |cc==43 | cc==50
replace oil= 0  if oil==.
label var oil " Categorical index for oil-dependent versus non-oil dependent"

xthreg Tau , rx(l2.Tau l1.d.ci pcph pcphq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres8

xthreg Tau, rx(l2.Tau l1.d.ci pgpj pgpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres9

esttab tres1 tres2 tres3 tres4 tres5 tres6 tres7 tres8 tres9 using table2.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace




* Additional Robustness, Panel Fixed Effects Threshold Regression Model (Table 10)
			
xthreg Tau covid gfc, rx(l2.Tau crudeExport pcpj pcpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc) 
estimates store tresr1
xthreg Tau covid gfc, rx(l2.Tau crudeExport pcph pcphq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr2
xthreg Tau covid gfc, rx(l2.Tau crudeExport pgpj pgpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr3
					
xthreg Tau l1.returns covid gfc, rx(l2.Tau crudeExport pcpj pcpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr4
xthreg Tau l1.returns covid gfc, rx(l2.Tau crudeExport pcph pcphq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr5
xthreg Tau l1.returns covid gfc, rx(l2.Tau crudeExport pgpj pgpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr6

	
xthreg Tau covid gfc, rx(l2.Tau l1.d.ci pcpj pcpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr7
xthreg Tau covid gfc, rx(l2.Tau l1.d.ci pcph pcphq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr8
xthreg Tau covid gfc, rx(l2.Tau l1.d.ci pgpj pgpjq) qx(oilshare) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tresr9



esttab tresr1 tresr2 tresr3 tresr4 tresr5 tresr6 tresr7 tresr8 tresr9 using table10.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace






* Additional Robustness, Panel Fixed Effects Threshold Regression Model (Table 11)

xthreg Tau covid gfc, rx(l2.Tau pcpj pcpjq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc) 
estimates store tres10
xthreg Tau covid gfc, rx(l2.Tau pcph pcphq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres11
xthreg Tau covid gfc, rx(l2.Tau pgpj pgpjq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres12		
	
xthreg Tau l1.returns covid gfc, rx(l2.Tau pcpj pcpjq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres13
xthreg Tau l1.returns covid gfc, rx(l2.Tau pcph pcphq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres14
xthreg Tau l1.returns covid gfc, rx(l2.Tau pgpj pgpjq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres15


xthreg Tau covid gfc, rx(l2.Tau l1.d.ci pcpj pcpjq) qx(crudeExport)thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres16
xthreg Tau covid gfc, rx(l2.Tau l1.d.ci pcph pcphq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres17
xthreg Tau covid gfc, rx(l2.Tau l1.d.ci pgpj pgpjq) qx(crudeExport) thnum(1) trim(0.01) grid(100) bs(100) vce(cluster cc)
estimates store tres18

esttab tres10 tres11 tres12 tres13 tres14 tres15 tres16 tres17 tres18 using table11.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace





* Motor Fuel Tax Regression (Motor fuel tax, Table 12)


xtivreg2 Tauf l2.Tauf pcpj pcpjq   (ci= l3.ci air), r cluster(cc) first fe
estimates store iv11
xtivreg2 Tauf l2.Tauf pcph pcphq   (ci= l5.ci air), r cluster(cc) first fe
estimates store iv21
xtivreg2 Tauf l2.Tauf pgpj pgpjq   (ci= l5.ci air), r cluster(cc) first fe
estimates store iv31



xtreg Tauf l2.Tauf pcpj pcpjq, r fe cluster(cc)
estimates store iv41
xtreg Tauf l2.Tauf pcph pcphq, r fe cluster(cc)
estimates store iv51
xtreg Tauf l2.Tauf pgpj pgpjq, r fe cluster(cc)
estimates store iv61


xtreg Tauf l2.Tauf pcpj pcpjq crudeExport, r fe cluster(cc)
estimates store iv71
xtreg Tauf l2.Tauf pcph pcphq crudeExport, r fe cluster(cc)
estimates store iv81
xtreg Tauf l2.Tauf pgpj pgpjq crudeExport, r fe cluster(cc)
estimates store iv91

esttab iv11 iv21 iv31 iv41 iv51 iv61 iv71 iv81 iv91 using table12.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace



* Robustness Check, Motor Fuel Tax Regression (Motor fuel tax, Table 13)


xtivreg2 Tauf l2.Tauf pcpj pcpjq  covid gfc (ci= l3.ci l1.air covid gfc), r cluster(cc) first fe
estimates store ivr11
xtivreg2 Tauf l2.Tauf pcph pcphq covid gfc   (ci= l3.ci l1.air covid gfc), r cluster(cc) first fe
estimates store ivr21
xtivreg2 Tauf l2.Tauf pgpj pgpjq covid gfc   (ci= l3.ci l1.air gfc covid), r cluster(cc) first fe
estimates store ivr31

xtreg Tauf l2.Tauf pcpj pcpjq covid gfc, r fe cluster(cc)
estimates store ivr41
xtreg Tauf l2.Tauf pcph pcphq covid gfc, r fe cluster(cc)
estimates store ivr51
xtreg Tauf l2.Tauf pgpj pgpjq covid gfc , r fe cluster(cc)
estimates store ivr61


xtreg Tauf l2.Tauf pcpj pcpjq crudeExport covid gfc, r fe cluster(cc)
estimates store ivr71
xtreg Tauf l2.Tauf pcph pcphq crudeExport covid gfc, r fe cluster(cc)
estimates store ivr81
xtreg Tauf l2.Tauf pgpj pgpjq crudeExport covid gfc, r fe cluster(cc)
estimates store ivr91

esttab ivr11 ivr21 ivr31 ivr41 ivr51 ivr61 ivr71 ivr81 ivr91 using table13.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace


				* Summary statistics table (Table 8) 
				
* Package required (estout)" 


program define xtsum2, eclass

syntax varlist

foreach var of local varlist {
    xtsum `var'

    tempname mat_`var'
    matrix mat_`var' = J(3, 5, .)
    matrix mat_`var'[1,1] = (`r(mean)', `r(sd)', `r(min)', `r(max)', `r(N)')
    matrix mat_`var'[2,1] = (., `r(sd_b)', `r(min_b)', `r(max_b)', `r(n)')
    matrix mat_`var'[3,1] = (., `r(sd_w)', `r(min_w)', `r(max_w)', `r(Tbar)')
    matrix colnames mat_`var'= Mean "Std. Dev." Min Max "N/s/T"
    matrix rownames mat_`var'= `var' " " " "

    local matall `matall' mat_`var'
    local obw `obw' overall between within
}

if `= wordcount("`varlist'")' > 1 {
    local matall = subinstr("`matall'", " ", " \ ",.)
    matrix allmat = (`matall')
    ereturn matrix mat_all = allmat
}
else ereturn matrix mat_all = mat_`varlist'
ereturn local obw = "`obw'"

end
xtsum2 Tau Tauf ci crudeExport airTraffic oilshare pcpj pcph pgpj returns y
esttab e(mat_all) using table3.tex, mlabels(none) labcol2(`e(obw)') varlabels(r2 " " r3 " ")  replace

				* Panel error correction term estimation  
/*
Here, we follow the Engle-granger approach to estimate the panel error correction 
model in Table 4. First, we estimate the long-run structural relationship between
state taxes and personal consumption expenditure. Then, we compute the error correction
term (e) by computing the residuals from the long-run relationship. We also test for 
asymmetric effects of oil prices in Table 3. Make sure to install pnardl in order to estimate the asymmetric panel error correction model. 
*/
xtreg Tau ci i.years, fe vce(cluster cc)
predict e, resid

  
* Unit Root Tests (Table 8)		
							
 xtunitroot fisher Tau, dfuller lags(1) trend demean
 xtunitroot fisher Tauf, dfuller lags(1) drift demean
 xtunitroot fisher ci, dfuller lags(1) trend demean
 xtunitroot fisher oilshare, dfuller lags(1) 
 xtunitroot fisher e, dfuller lags(1) trend demean
								
 dfuller pcpj if cc==1, lags(1) drift
 dfuller pcph if cc==1, lags(1) drift
 dfuller pgpj if cc==1, lags(1) drift
 dfuller returns if cc==1, lags(1) drift
 
 xtunitroot fisher crudeExport, dfuller lags(1) trend demean
 xtunitroot fisher air, dfuller lags(1) trend demean

 
									
				* Panel Error Correction Model (Table 4)
 
 xtreg dTau l4.dTau l1.d.pcpj l1.d.pcpjq l1.dci l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm1
 xtreg dTau l4.dTau l1.d.pcph l1.d.pcphq l1.dci l1.e covid gfc ,  fe vce(cluster cc)
 estimates store ecm2
 xtreg dTau l4.dTau l1.d.pgpj l1.d.pgpjq l1.dci l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm3
  
 xtreg dTau l2.dTau l1.d.pcpj l1.d.pcpjq l1.returns l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm4
 xtreg dTau l4.dTau l1.d.pcph l1.d.pcphq l2.returns l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm5
 xtreg dTau l2.dTau l1.d.pgpj l1.d.pgpjq l1.returns l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm6
 
 xtreg dTau l2.dTau l1.d.pcpj l1.d.pcpjq l1.dcrudeExport l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm7
 xtreg dTau l3.dTau l1.d.pcph l1.d.pcphq l1.dcrudeExport l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm8
 xtreg dTau l2.dTau l1.d.pgpj l1.d.pgpjq l1.dcrudeExport l1.e covid gfc,  fe vce(cluster cc)
 estimates store ecm9
 
esttab ecm1 ecm2 ecm3 ecm4 ecm5 ecm6 ecm7 ecm8 ecm9 using Table4.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace


			* Asymmetric Panel Error Correction Model (Table 3)
				
* Package required (xtpmg, pnardl)

pnardl d.Tau d.pcpj l1.d.ci, lr(l.Tau ci pcpj covid gfc) asymmetric(pcpj) replace
estimates store pn1
pnardl d.Tau d.pcpj l1.d.ci gfc covid, lr(l.Tau ci pcpj gfc covid) asymmetric(pcpj) replace mg
estimates store  pn2
pnardl d.Tau d.pcpj l1.d.ci gfc covid, lr(l.Tau ci pcpj gfc covid) asymmetric(pcpj) replace dfe cluster(cc)
estimates store pn3

 
esttab pn1 pn2 pn3 using table3.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace

* Figure (1)
preserve
collapse pcpj pcph pgpj, by(years)
tsset years
tsline pcpj pcph pgpj
restore
* Figure (4)
bayes, prior({y:pcpj}, uniform(-10000, 10000)): regress y pcpj 
bayesgraph histogram {y:pcpj}, normal density name(amb1)

bayes, prior({y:pcph}, uniform(-10000, 10000)):regress y pcph
bayesgraph histogram {y:pcph}, normal density name(amb2)

bayes, prior({y:pgpj}, uniform(-10000, 10000)):regress y pgpj
bayesgraph histogram {y:pgpj}, normal density name(amb3)

bayes, prior({dy:d.pcpj}, uniform(-10000, 10000)):regress dy d.pcpj
bayesgraph histogram {dy:d.pcpj}, normal density name(amb4)

bayes, prior({dy:d.pcph}, uniform(-10000, 10000)):regress dy d.pcph
bayesgraph histogram {dy:d.pcph}, normal density name(amb5)

bayes, prior({y:dpgpj}, uniform(-10000, 10000)):regress dy d.pgpj 
bayesgraph histogram {dy:d.pgpj}, normal density name(amb6)

graph combine amb1 amb2 amb3 amb4 amb5 amb6 , cols(2)

* Figure (5) 
twoway(scatter ci  pcph) (qfit ci pcph), name(pic1a)
twoway(scatter Tau  ci) (qfit Tau ci), name(pic1b)
twoway(scatter Tau  pcph) (qfit Tau pcph), name(pic1c)
twoway(scatter Tau  crudeExport) (lfit Tau crudeExport), name(pic1d)
graph combine pic1a pic1b pic1c pic1d




			* "Ambivalent oil effect" (Table 9)
xtreg y pcpj covid gfc if  oil==1, r cluster(cc) fe
estimates store  go1
xtreg dy d.pcpj covid gfc if  oil==1, r cluster(cc) fe
estimates store go2 
xtreg y pcpj covid gfc if  oil==0, r cluster(cc) fe
estimates store go3 
xtreg dy d.pcpj  covid gfc if  oil==0, r cluster(cc) fe
estimates store go4

esttab go1 go2 go3 go4 using table9.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace


*******************************************************************************
*******************************************************************************
******************************************************************************* 
 
 /*  					 II.   Global oil exporters

Here, we are replicating the main empirical framework for the top oil exporters
in the world. We will fix the missing tax observations and also address
the missing CPI observations for the United Arab Emirates.  
*/
*cd "C:\Users\muuno\Desktop\Energy Economics\raw_data"



/* (i). Loading the raw data for the top oil exporters and cleaning the 
raw data and transforming the data into STATA format. 
*/

cd "C:\Users\muuno\Desktop\Energy Economics\raw_data"
import excel "Top Exporters (final raw data).xlsx", sheet("Data") firstrow clear 
sort countries years 



			 * Constructing all the key variables 

encode countries, gen(cc)
xtset cc years

* Crude oil price index
													
gen  crudeLCU=(OfficialexchangerateLCUper* GlobalpriceofBrentCrude)
gen crude00= crudeLCU if years==2000
sort countries
by countries: egen mean= mean(crude00)
gen crudeindex= (crudeLCU/ mean)*100
drop mean
label var crudeindex "oil price index adjusted for exchange rate, base year, 2000"


* Replacing the missing CPI estimates for UAE with the GDP deflator

replace Consumerpriceindex2010100= GDPdeflatorbaseyearvariesb if Consumerpriceindex2010100==. & countries=="United Arab Emirates" & years<2007

gen CPI00= Consumerpriceindex2010100 if years==2000
sort countries
by countries: egen mean= mean(CPI00)
gen CPI= (Consumerpriceindex2010100/ mean)*100
label var CPI "oil price index adjusted for exchange rate, base year, 2000"


* Approximating the missing tax revenue data 
							
gen missingtaxdata=( GDPcurrentLCUNYGDPMKTPC* TotalRevenueExcludingGrants)
sort cc
by cc: replace Revenueexcludinggrantscurre= missingtaxdata if Revenueexcludinggrantscurre ==.

gen realoil=(crudeindex/CPI)
gen pcpj=log(realoil)
label var pcpj "Log of relative price of crude oil; CPI used as deflator"

gen pcpjq= (pcpj)^2
label var pcpjq "Quadratic term for pcpj"

gen worldGDP= log(GrossDomesticProductforWorld/PopulationTotalWorld)
label var worldGDP "Log of world GDP per capita"

gen Tau= log(Revenueexcludinggrantscurre/PopulationtotalSPPOPTOTL)
label var Tau "Log of total government revenue per capita"

gen ci= log(HouseholdsandNPISHsFinalcons /PopulationtotalSPPOPTOTL)
label var ci "Log of personal consumption expenditure per capita"

xtset cc years
gen dTau= (d.Tau)
label var dTau "Growth rate of Tau"

gen dci= (d.ci)
label var dci "Growth rate of ci"



* Key macroeconomic shocks 

gen covid= 1 if years==2020 |years==2021 |years==2022 |years==2023
replace covid= 0 if covid==.
label var covid "Coronavirus pandemic"
gen gfc= 1 if years==2008 | years==2009 | years==2010
replace gfc = 0 if gfc==.
label var gfc "Global Financial Crisis Dummy Variable"


keep years countries cc dci dTau ci Tau worldGDP pcpjq pcpj gfc covid 
xtset cc years 
save "top-exporters.dta", replace 


*******************************************************************************
* Engle Granger Cointegration approach: long-run regression 

xtreg Tau ci i.years, r cluster(cc)  fe

/* Note: The full set of time effects is largely insignificant, this worsens
the panel error correction estimates, therefore this study only controls for
key macroeconomic shocks such as the coronavirus pandemic and the 2008 Global 
Financial Crisis.  
*/

xtreg Tau ci covid gfc, r cluster(cc)  fe
predict e, resid


* Unit Root Test
 xtunitroot fisher Tau, dfuller lags(1)  demean drift 
 xtunitroot fisher ci, dfuller lags(3)  demean drift 
 xtunitroot fisher pcpj, dfuller lags(1)  demean drift
 dfuller worldGDP if cc==2, lags(2)  drift
 xtunitroot fisher e, dfuller lags(1)  demean drift
 
								* Table 5
* Package required (ranktest, ivreg2, xtivreg2):

				* (Panel 2SLS Model)
		
xtivreg2 Tau l3.Tau pcpj pcpjq covid gfc  (ci= l4.ci d.worldGDP covid gfc) , r cluster(cc) first fe
estimates store  export1

				* (Reduced-form panel fixed model)	
xtreg Tau l2.Tau pcpj pcpjq l1.d.worldGDP covid gfc, r cluster(cc)  fe
estimates store export2
			     * (Panel error correction model)	
xtreg dTau l3.d.Tau l1.d.pcpj l1.d.pcpjq l1.dci l1.e covid gfc, r cluster(cc) fe
estimates store export3



esttab export1 export2 export3 using table5.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace
 
********************************************************************************
*******************************************************************************
*******************************************************************************

/*  					II.   Global oil importers

Here, we are replicating the main empirical framework for the top oil importers.
*/

/* (i). Loading the main raw data for the top oil importers and cleaning the
raw data and transforming the data into STATA format. 
*/

cd "C:\Users\muuno\Desktop\Energy Economics\raw_data"

import excel "total government revenue (top importers).xlsx", sheet("Data") firstrow clear		
save revenue.dta, replace 

import excel "Top Importers (raw data).xlsx", sheet("Data") firstrow clear 
sort countries years 
merge m:m countries years using "revenue.dta"



* Constructing all the key variables 
encode countries, gen(cc)
xtset cc years

		

		
		
		
		
* Constructing the variables 
							
gen  crudeLCU=(OfficialexchangerateLCUper* GlobalpriceofBrentCrude)
gen crude1999= crudeLCU if years==1999
sort countries
by countries: egen mean= mean(crude1999)
gen crudeindex= (crudeLCU/ mean)*100
drop mean
label var crudeindex "oil price index adjusted for exchange rate, base year, 1999"


gen CPI1999= Consumerpriceindex2010100 if years==1999
sort countries
by countries: egen mean= mean(CPI1999)
gen CPI= (Consumerpriceindex2010100/ mean)*100
label var CPI "oil price index adjusted for exchange rate, base year, 2000"


gen realoil=(crudeindex/CPI)
gen pcpj=log(realoil)
label var pcpj "Log of relative price of crude oil; CPI used as deflator"

gen pcpjq= (pcpj)^2
label var pcpjq "Quadratic term for pcpj"

gen worldGDP= log(GrossDomesticProductforWorld/PopulationTotalWorld)
label var worldGDP "Log of world GDP per capita"

gen Tau= log(TaxrevenuecurrentLCUGCTA/PopulationtotalSPPOPTOTL)
label var Tau "Log of total tax revenue per capita"

gen TauG= log(Revenueexcludinggrantscurre/PopulationtotalSPPOPTOTL)
label var TauG "Log of total government revenue per capita"

gen ci= log(HouseholdsandNPISHsFinalcons /PopulationtotalSPPOPTOTL)
label var ci "Log of personal consumption expenditure per capita"

xtset cc years
gen dTau= (d.Tau)
label var dTau "Growth rate of Tau"

gen dci= (d.ci)
label var dci "Growth rate of ci"


* Key macroeconomic shocks 

gen covid= 1 if years==2020 |years==2021 |years==2022 |years==2023
replace covid= 0 if covid==.
label var covid "Coronavirus pandemic"
gen gfc= 1 if years==2008 | years==2009 | years==2010
replace gfc = 0 if gfc==.
label var gfc "Global Financial Crisis Dummy Variable"




keep years countries cc dci dTau ci Tau worldGDP pcpjq pcpj gfc covid TauG
xtset cc years 

save "top-importers.dta", replace 


*******************************************************************************
* Engle Granger Cointegration approach: long-run regression 

xtreg Tau ci i.years, r cluster(cc)  fe
/* Note: The full set of time effects is largely insignificant, this worsens
the panel error correction estimates, therefore this study only controls for
key macroeconomic shocks such as the coronavirus pandemic and the 2008 Global 
Financial Crisis.  
*/
xtreg Tau ci covid gfc, r cluster(cc)  fe
predict e, resid

* Unit Root Test
 xtunitroot fisher Tau, dfuller lags(1)  demean drift 
 xtunitroot fisher ci, dfuller lags(3)  demean drift 
 xtunitroot fisher pcpj, dfuller lags(1)  demean drift
 dfuller worldGDP if cc==2, lags(2)  drift
 xtunitroot fisher e, dfuller lags(1)  demean drift
 

* Package required (ranktest, ivreg2, xtivreg2):

						* (Panel 2SLS Model)
						
xtivreg2 TauG l3.TauG pcpj pcpjq covid gfc  (ci= l4.ci d.worldGDP covid gfc) , r cluster(cc) first fe
estimates store  import1
xtivreg2 Tau l3.Tau pcpj pcpjq covid gfc  (ci= l4.ci d.worldGDP covid gfc) , r cluster(cc) first fe
estimates store  import2

						* (Reduced-form panel fixed model)	
xtreg Tau l2.Tau pcpj pcpjq l1.d.worldGDP covid gfc, r cluster(cc)  fe
estimates store import3
						
						* (Panel error correction model)	
xtreg dTau l3.d.Tau l1.d.pcpj l1.d.pcpjq l1.dci l1.e covid gfc, r cluster(cc) fe
estimates store import4


esttab import1 import2 import3 import4 using table6.tex, star(* 0.10 ** 0.05 *** .01)  cells(b(fmt(3) star) ci(fmt(3) par))replace

* Thank you, please contact me if you have any questions: In Jesus anything is possible. 

 
 
 
