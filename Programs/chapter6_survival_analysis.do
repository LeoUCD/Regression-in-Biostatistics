set more off
clear all
set scheme s1mono

* Table 6.1
use "unos.dta", clear
gen day = px_stat_ - tx_date
replace day = 11 if day > 10
stset day, failure(death) 
sts list

* Data and code for Figures 6.1-6.3 and Table 6.2 are not available

* Table 6.3
use "unos.dta", clear
stset fu, failure(death)
stcox i.txty

* Table 6.4
use "pbc.dta", clear
stset years, failure(status)
stcox i.rx bilirubin

* Table 6.5
stcox i.rx bilirubin, nohr

* Table 6.6
stcox i.histol
testparm i(2/4).histol
lincom -3.histol + 4.histol, hr

* Table 6.7
quietly stcox i.histol
test -1*2.histol + 3.histol + 3*4.histol=0
contrast {histol -3 -1 1 3}, noeffects
contrast q(1).histol, noeffects

* Table 6.8
quietly stcox c.histol i.histol
testparm i.histol
contrast q(2/3).histol, noeffects

* Table 6.9
stcox age

* Table 6.10
gen age5 = age/5
stcox age5

* Table 6.11
stcox bilirubin

* Table 6.12
stcox bilirubin i.edema i.hepatom i.spiders

* Section 6.2.9
use "fit.dta", clear
* Overall treatment effect on fracture
stset fitpy, failure(newvfx) 
stcox i.treat
* Percent changes in BMD
tab treat, sum(bmd_pctchg)
reg bmd_pctchg i.treat
* Table 6.13
stcox i.treat i.smoking age bmd_diff bmd_base, strata(frac_base)

* Table 6.14
use "pbc.dta", clear
stset years, failure(status)
stcox i.rx##hepatom
lincom 1.rx + 1.rx#1.hepatom, hr

* Figure 6.4
use "unos.dta", clear
stset fu, failure(death) 
sts graph, by(txtype) ///
	ytitle(Probability of Survival) xtitle(Years of Follow Up) title(" ") ///
	plot1opts(lcolor(black) lpattern(solid)) ///
	plot2opts(lcolor(black) lpattern(dash)) ///
	legend(order(1 "Living" 2 "Cadaveric") ///
		region(lcolor(none) lpattern(blank)) position(6) ring(0)) ///
	name(fig6_4, replace)
	
* Figure 6.5
use "unos.dta", clear
stset fu, failure(death)
gen cisc=cold_isc-10.859gen chla=hla-3
gen cage = age - 11.6465sts graph, by(txtype) adjustfor(cage cisc chla) ///
	ytitle(Probability of Survival) xtitle(Year of Follow Up) title(" ") ///
	plot1opts(lcolor(black) lpattern(solid)) ///
	plot2opts(lcolor(black) lpattern(dash)) ///
	legend(order(1 "Living"  2 "Cadaveric") ///
		region(lcolor(none) lpattern(blank)) pos(6) ring(0)) ///
	name(fig6_5, replace)

* Figure 6.6
use "pbc.dta", clear
stset years, failure(status)stcox hepatom  bilirubin
stcurve, survival at( hepat=1 bilir=4.5 ) lcolor(black) ///
	ytitle(Predicted Survival Function) ///
	xtitle(Years Since Enrollment) xscale(range(0.00 10.0)) ///
	title(" ") name(fig6_6, replace)

* Table 6.16
use "actg019.dta", clear
stset days, failure(cens)
recode cd4 0/199=1 200/max=0, gen(strcd4)
stcox rx, strata(strcd4)
	
* Table 6.17
stcox i.rx##i.strcd4, strata(strcd4)
lincom 1.rx + 1.rx#1.strcd4, hr

* Figure 6.7
use "pbc.dta", clear
stset years, f(status)
gen agec=age-50sts graph, by(edema) adjustfor(agec) /// 
	ytitle((Age Adjusted) Probability of Survival) ///
	xtitle(Years Since Enrollment) title(" ") ///
	plot1opts(lcolor(black) lpattern(solid)) ///
	plot2opts(lcolor(black) lpattern(dash)) ///
	legend(order(1 "No Edema" 2 "Edema" ) ///
		region(lcolor(none) lpattern(blank)) position(6) ring(0)) ///
	name(fig6_7, replace)

* Table 6.18
mkspline age_sp = age, cubic displayknots
stcox age_sp1 age_sp2 age_sp3 age_sp4
* test for departure from linearity
test age_sp2 age_sp3 age_sp4
* test for overall effect
test age_sp1 age_sp2 age_sp3 age_sp4

* Figure 6.8
qui stcox age_sp1 age_sp2 age_sp3 age_sp4
predict spline, xb
recode age ///
	min/33.4=1 33.4/42.8=2 42.8/49.8=3 49.8/56.9=4 56.9/68.5=5 68.5/max=6 ///
	, gen(cat_age)
qui stcox i.cat_age
predict cut, xb
qui stcox age
predict linear, xb
replace spline = spline - 2.358604
replace linear = linear - 1.9947
replace cut = cut - 2.0416 + 0.225
twoway (line linear age, sort lpattern(solid)  lcolor(black)) ///
	(line spline age, sort lpattern(dash)  lcolor(black)) ///
	(line cut age, sort connect(stairstep) lpatter(longdash) lcolor(black)), ///
	ytitle(Relative Hazard Compared to Age 50) ///
	ylabel(-1.386 "0.25" -0.69 "0.5" 0 "1.0" 0.69 "2.0"  1.386 "4.0") ///
	xtitle(Age) legend( order(1 "Log-Linear fit" 2 "Cubic spline fit" ///
		3 "Categorical transformation")) name(fig6_8, replace)

* Figure 6.9stphplot, by(rx)  nolntime nonegative ///
	plot1opts(msize(zero) lcolor(black) lpattern(solid) connect(stairstep) ) ///
	plot2opts(msize(zero) lcolor(black) lpattern(dash) connect(stairstep) ) ///
	ytitle(Log Minus Log Survival) xtitle(Years Since Enrollment) xlabel(0(5)12) ///
	legend( label(1 "Placebo") label(2 "DPCA") ///
		region(lcolor(none) lpattern(blank)) position(6) ring(0) ) ///
	name(fig6_9, replace)

* Figure 6.10
stphplot, by(edema) nolntime nonegative ///
	plot1opts(msize(zero) lcolor(black) lpattern(solid) connect(stairstep) ) ///
	plot2opts(msize(zero) lcolor(black) lpattern(dash) connect(stairstep) ) ///
	ytitle(Log Minus Log Survival) xtitle(Years Since Enrollment) xlabel(0(5)12) ///
	legend( label(1 "No Edema") label(2 "Edema") ///
		region(lcolor(none) lpattern(blank)) position(6) ring(0) ) ///
	name(fig6_10, replace)

* Figure 6.11
stcox edema
estat phtest, plot(edema) bwidth(0.8) mcolor(black) msize(vsmall) ///
	lineopts(lcolor(black) lpattern(solid)) ///
	xtitle(Years Since Enrollment) ytitle(Log Hazard Ratio) ///
	title(" ") caption(" ") note(" ")  s xlabel(0(5)12) ///
	name(fig6_11, replace)

* Table 6.19
qui stcox rx edema
estat phtest, detail

* Table 6.20
use "mros.dta", clearstset months, failure(status)
sts list, at(1/10)

* Figure 6.21
stset years, failure(status==1)
stcrreg , compete(status==2)
predict cif_fracture, basecif
twoway ///
	(line cif_fracture _t if _t < 6.5, sort),  ///
	ytitle(Cumulative Probability of Fracture) ///
	xtitle(Years in Study) name(fig6_12, replace)
	
* Table 6.22
stcox i.bmd3 weight

* Table 6.23
stcrreg i.bmd3 weight, compete(status==2)

* Table 6.24
use "actg019.dta", clear
stset days, failure(cens)
stcox i.rx cd4, vce(bootstrap, bca reps(1000) nodots seed(881) )

* Table 6.25
stpower cox, failprob(.15) hratio(1.15) sd(4.5) r2(0.2025) 
display (invnormal(.975)+invnormal(0.8))^2/((log(1.15)*4.5)^2*0.15*(1-.2025))

* Table 6.26
stpower cox, n(312) failprob(.40) sd(1.5) r2(0.25) power(.8) hr
display exp(-(invnormal(.975)+invnormal(0.8))/(1.5*sqrt(125*(1-0.25))))



