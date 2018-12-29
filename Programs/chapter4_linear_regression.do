set more offset scheme s1mono* Section 4.1: Multiple Regression Exampleuse hersdata, clear* Table 4.1. Unadjusted Regression of Glucose on Exerciseregress glucose exercise if diabetes == 0* Table 4.2. Unadjusted Regression of Glucose on Exerciseregress glucose exercise age10 drinkany BMI if diabetes == 0
* Table 4.4: Regression of Glucose on Physical Activity
use hersdata, clearregress glucose i.physact if diabetes == 0lincom _cons + 2.physact
margins physactlincom 5.physact - 3.physact
contrast {physact 0 0 -1 0 1}, effects

* Table 4.5
quietly regress glucose i.physact if diabetes == 0testparm i.physact
contrast physact

* Table 4.6
regress glucose i.physact if diabetes==0
contrast physact, mcompare(bonferroni) nooverall effects

* Table 4.7regress glucose ibn.physact if diabetes == 0, noconstant
* Tests for linear trend
test -2*1.physact - 2.physact + 4.physact + 2*5.physact = 0
contrast {physact -2 -1 0 1 2}, noeffects
contrast q(1).physact, noeffects

* Table 4.9
regress glucose i.physact if diabetes==0
* Tests for linear trendtest -2.physact + 4.physact + 2*5.physact = 0
contrast {physact -2 -1 0 1 2}, noeffects
contrast q(1).physact, noeffects

* show that q. and p. behave differently
recode physact 2=3 3=4 4=5 5=7, gen(physact2)
regress glucose i.physact2 if diabetes == 0
contrast q(1).physact2, noeffects
contrast p(1).physact2, noeffects* Table 4.10quietly regress glucose physact i.physact if diabetes == 0testparm i.physact

* Table 4.11
quietly regress glucose i.physact if diabetes == 0
contrast q(2/4).physact, noeffects

* show that this works with more than 5 levels
reg glucose i.physact if diabetes==0
contrast q(2/5).physact, noeffects
reg glucose physact i.physact if diabetes==0
testparm i.physact* Figure 4.1use figure4_1, clearset graphics offgen x1 = (x2 > 4)gen y = 0.5 + x2gen y0 = y if x1 == 0gen y1 = y if x1 == 1gen x20 = x2 if x1 == 0gen x21 = x2 if x1 == 1twoway ///	(scatter y x1, msymbol(O) mlabel(x1)) ///	, ///	plotregion(style(none)) ///	yscale(range(0 10)) ylabel(0(2)10) ///	xscale(range(-0.25 1.25)) xlabel(0 1) ///	title("Unadjusted effect of E") ///	ytitle("y") ///	xtitle("E") ///	legend(off) ///	name(cp1, replace)	twoway ///	(scatter y x2, msymbol(i)) ///	(scatter y0 x20, msymbol(O) mlabel(x1)) ///	(scatter y1 x21, msymbol(O) mlabel(x1)) ///	(line y0 x20, sort clpat(shortdash)) ///	(line y1 x21, sort clpat(longdash)) ///	, ///	plotregion(style(none)) ///	yscale(range(0 10)) ylabel(0(2)10) ///	xscale(range(0 8)) xlabel(0(2)8) ///	title("Adjusted effect of E") ///	ytitle("y") ///	xtitle("C") ///	legend(order(4 5) label(4 "E = 0") label(5 "E = 1") pos(12) ring(0)) ///	name(cp2, replace)	replace y = x2 - 4 * x1replace y0 = y if x1 == 0replace y1 = y if x1 == 1twoway ///	(scatter y x1, msymbol(O) mlabel(x1)) ///	, ///	plotregion(style(none)) ///	yscale(range(0 6)) ylabel(0(2)6) ///	xscale(range(-0.25 1.25)) xlabel(0 1) ///	ytitle("y") ///	xtitle("E") ///	legend(off) ///	name(cp3, replace)	twoway  ///	(scatter y x2, msymbol(i)) ///	(scatter y0 x20, msymbol(O) mlabel(x1)) ///	(scatter y1 x21, msymbol(O) mlabel(x1)) ///	(line y0 x20, sort clpat(shortdash)) ///	(line y1 x21, sort clpat(longdash)) ///	, ///	plotregion(style(none)) ///	xscale(range(0 8)) xlabel(0(2)8) ///	yscale(range(0 6)) ylabel(0(2)6) ///	ytitle("y") ///	xtitle("C") ///	legend(off) ///	name(cp4, replace)	set graphics ongraph combine cp1 cp2 cp3 cp4, name(fig4_1, replace)* Table 4.12use hersdata, clearregress LDL BMIpredict overall, xbtab nonwhite, sum(BMI)regress LDL BMI age10 nonwhite smoking drinkany* Figure 4.2quietly adjust age10 smoking drinkany, by(BMI nonwhite) xb gen(fitted)gen whites = fitted if nonwhite == 0gen others = fitted if nonwhite == 1twoway ///	(line whites BMI, sort clpat(shortdash)) ///	(line others BMI, sort clpat(longdash)) ///	(line overall BMI, sort clpat(solid)) ///	, plotregion(style(none)) ///    ytitle("LDL Cholesterol (mg/dL)") ylabel(130(10)170) ///    xtitle("Body Mass Index (kg/m{superscript: 2})")  xlabel(10(10)60) ///    legend(label(1 "Whites") label(2 "Other Ethnicities") ///        	label(3 "Unadjusted") pos(12) ring(0)) ///
     name(fig4_2, replace) 
     * explore negative confounding by eliminating on variable at a timeregress LDL BMI nonwhite smoking drinkanyregress LDL BMI age10 smoking drinkanyregress LDL BMI age10 nonwhite drinkanyregress LDL BMI age10 nonwhite smoking* Table 4.13
use hersdata, clearregress glucose  BMI age10 nonwhite smoking drinkany poorfair if diabetes == 0
* Store coefficient for BMI as estimate of overall effect
scalar overall = _b[BMI]* First link: logistic model for BMI effect on exercise
logistic exercise BMI age10 nonwhite smoking drinkany poorfair if diabetes == 0
* Second link: fully adjusted model for effect of exercise on glucose levelsregress glucose  BMI age10 nonwhite smoking drinkany poorfair exercise ///
	if diabetes == 0
* Store coefficient for BMI as estimate of direct effect, and calculate PE
scalar direct = _b[BMI]
scalar PE = round((overall-direct)/overall*100, 0.1)
scalar list PE* Table 4.15
use hersdata, clear
regress LDL1 i.HT##i.statins
lincom 1.HT + 1.HT#1.statins

* Table 4.16
regress LDL1 i.HT##i.physact
testparm i.HT#i.physact
contrast HT#physact* Table 4.17 Interaction Model for BMI and Statin Use
gen BMIc = BMI - 28.57925regress LDL i.statins##c.BMIc age nonwhite smoking drinkanylincom BMIc + 1.statins#c.BMIc
* Figure 4.3
* must use Version 10 syntax for adjust command to work
xi: regress LDL i.statins*BMIc age nonwhite smoking drinkanyquietly adjust age nonwhite smoking drinkany, by(BMIc statins) xb gen(fitted)gen nostatia = fitted if statins == 0gen wistatia = fitted if statins == 1twoway ///        (line wistatia BMI, sort clpat(shortdash)) ///        (line nostatia BMI, sort clpat(longdash)) ///	, ///	plotregion(style(none)) ///	ytitle("LDL Cholesterol (mg/dl)") ylabel(120(10)170) ///    xtitle("Body Mass Index (kg/m{superscript: 2})") xlabel(10(10)60) ///    legend(label(1 "Statin Users") label(2 "Non-Users") pos(6) ring(0)) ///
    name(fig4_3, replace)
* Table 4.18gen LDLch = LDL1 - LDLgen LDLpctch = LDLch / LDL * 100egen meanLDL = mean(LDL)gen cLDL0 = LDL - meanLDLregress LDLch HT##c.cLDL0

* Table 4.19regress LDLpctch HT##c.cLDL0* Figure 4.4.use hersdata, clearregress LDL BMI age10 nonwhite smoking drinkany
set graphics offcprplot BMI, ///	rlopts(clpat(solid)) lsopts(bw(.5) clpat(longdash)) ///	plotregion(style(none)) msize(vtiny) ///	ytitle("LDL Cholesterol Component Plus Residual") ///    xtitle("Body Mass Index (kg/m{superscript: 2})") xlabel(20(10)60) ///    name(LDL, replace)	regress HDL BMI age10 nonwhite smoking drinkanycprplot BMI, ///	rlopts(clpat(solid)) ///	lsopts(bw(.5) clpat(longdash)) plotregion(style(none)) msize(vtiny) ///	ytitle("HDL Cholesterol Component Plus Residual") ///    xtitle("Body Mass Index (kg/m{superscript: 2})") xlabel(20(10)60) ///    name(HDL, replace)set graphics on	graph combine LDL HDL, cols(2) name(fig4_4, replace)

* Table 4.20use hersdata, clear
gen agec = age - 67gen BMIc = BMI - 28.58gen BMIc2 = BMIc ^ 2regress HDL BMIc BMIc2 agec nonwhite smoking drinkany
* Figure 4.5quietly regress HDL BMI BMIc2 agec nonwhite smoking drinkanycprplot BMI, ///	rlopts(clpat(solid)) lsopts(bw(.5) clpat(longdash)) ///	plotregion(style(none)) msize(vtiny) ///	ytitle("HDL Cholesterol Component Plus Residual") ///    xtitle("Body Mass Index (kg/m{superscript: 2})") xlabel(20(10)60) ///
    name(fig4_5, replace)
    * Figure 4.6use figure4_6, clearset graphics offgen y = x ^ 2line y x, ///	plotregion(style(none)) ///	title("Quadratic") ///	xscale(range(0 1)) xlabel(0 1) xtitle("") ///	yscale(range(0 1)) ylabel(0 1) ytitle("") ///	name(quadratic, replace)	replace y = ((x * .8) ^ 2 - (x * .8) ^ 3) * 27 / 4line y x, ///	plotregion(style(none)) ///	title("Polynomial") ///	xscale(range(0 1)) xlabel(0 1) xtitle("") ///	yscale(range(0 1)) ylabel(0 1) ytitle("") ///	name(polynomial, replace)	replace y = log((x) * (exp(5) - 1) + 1) / (log(1 * exp(5) - 1) * 1)line y x, ///	plotregion(style(none)) ///	title("Log") ///	xscale(range(0 1)) xlabel(0 1) xtitle("") ///	yscale(range(0 1)) ylabel(0 1) ytitle("") ///	name(log, replace)	replace y = sqrt(x)line y x, ///	plotregion(style(none)) ///	title("Square Root") ///	xscale(range(0 1)) xlabel(0 1) xtitle("") ///	yscale(range(0 1)) ylabel(0 1) ytitle("") ///	name(sqrt, replace)set graphics ongraph combine quadratic polynomial log sqrt, name(fig4_6, replace)

* Table 4.21
use hersdata, clearmkspline2 BMIsp = BMI, cubicregress HDL BMIsp1 BMIsp2 BMIsp3 BMIsp4 age10 nonwhite smoking drinkany
* test for departure from linearity
test BMIsp2 BMIsp3 BMIsp4
* test for overall effect of BMI
test BMIsp1 BMIsp2 BMIsp3 BMIsp4

* Figure 4.7
quietly regress HDL BMIsp1 BMIsp2 BMIsp3 BMIsp4 age10 nonwhite smoking drinkany
qui adjust age10 nonwhite smoking drinkany, gen(fitted)
* next line requires downloadable postrcspline package
adjustrcspline
* categorical fit 
recode BMI ///	min/18.4999 = 1 18.5/24.9999 = 2 25/29.9999 = 3 30/34.9999 = 4 ///	35/39.9999 = 5 40/max = 6, gen(catBMI)
xi: regress HDL i.catBMI age10 nonwhite smoking drinkany
qui adjust age10 nonwhite smoking drinkany, gen(fitted2)
twoway ///
	(line fitted BMI, sort lpattern(longdash)) ///
	(line fitted2 BMI, sort lpattern(solid)), ///	plotregion(style(none)) ///	ytitle("HDL Cholesterol (mg/dL)") ///    xtitle("Body Mass Index (kg/m{superscript: 2})")  xlabel(20(10)60) ///
    legend(order(2 "Categorical transformation" 1 "Cubic spline fit")) ///    name(fig4_7, replace)	
* ado-file eda.ado for Figures 4.8 and 4.9capture program drop edaprogram define eda	set graphics off	set scheme s1mono	quietly histogram `1', name(eda1, replace)	quietly graph box `1', name(eda2, replace)	quietly kdensity `1', ep normal name(eda3, replace)	quietly qnorm `1', name(eda4, replace)	set graphics on	set scheme s1mono	graph combine eda1 eda2 eda3 eda4	end* Figure 4.8use hersdata, clearregress LDL BMI age nonwhite smoking drinkanypredict resid, resideda resid* Figure 4.9gen logLDL = log(LDL)regress logLDL BMI age nonwhite smoking drinkanypredict logresid, resideda logresid
* Figure 4.10use hersdata, cleargen BMI2 = BMI ^ 2regress HDL BMI BMI2 age nonwhite smoking drinkanypredict resid, residgen residsq = resid ^ 2predict fitted, xbtab nonwhite, sum(resid)tab smoking, sum(resid)tab drinkany, sum(resid)set graphics offtwoway ///	(scatter resid BMI, sort msymbol(point) msize(vtiny)) ///	, ///	plotregion(style(none)) ///	xtitle("Body Mass Index (kg/m{superscript: 2})") ///	xlabel(20(10)60) ///	yline(0) ///	ytitle("") ///	title("Residuals Versus Predictor") ///	legend(off) ///	name(cv1, replace)twoway ///	(scatter resid fitted, sort msymbol(point) msize(vtiny))  ///	, ///	plotregion(style(none)) ///	yline(0) ///	title("Residuals Versus Fitted Values") ///	ytitle("") ///	legend(off) ///	name(cv2, replace)set graphics ongraph combine cv1 cv2, name(fig4_10, replace)* Figure 4.11. gen logHDL = log(HDL)regress logHDL BMI BMI2 age nonwhite smoking drinkanypredict logresid, residpredict lfitted, xbgen lresidsq = logresid ^ 2tab nonwhite, sum(logresid)tab smoking, sum(logresid)tab drinkany, sum(logresid)set graphics offtwoway ///	(scatter logresid BMI, sort msymbol(point) msize(vtiny)) ///	, ///	plotregion(style(none)) ///	xtitle("Body Mass Index (kg/m{superscript: 2})") ///	xlabel(20(10)60) ///	yline(0) ///	ytitle("") ///	title("Residuals Versus Predictor") ///	legend(off) ///	name(cv1, replace)twoway ///	(scatter logresid lfitted, sort msymbol(point) msize(vtiny)) ///	, ///	plotregion(style(none)) ///	yline(0) ///	title("Residuals Versus Fitted") ///	ytitle("") ///	legend(off) ///	name(cv2, replace)set graphics ongraph combine cv1 cv2, name(fig4_11, replace)* Table 4.22use hersdata, clearpreserve
set seed 9896
sample 5
regress glucose diabetes BMI age drinkany
regress glucose diabetes BMI age drinkany, vce(robust)
regress glucose diabetes BMI age drinkany, vce(hc3)
restore* Figure 4.12
version 12use figure4_12, clear
* outsheet using figure4_12.csv, comma replaceregress y2 x if x < 60dfbetarename _dfbeta_1 Simple_Outlierset graphics offtwoway ///	(scatter y2 x if _n ~= 12 & x < 60, msymbol(point) msize(medium)) ///	(scatter y2 x if _n == 12, msymbol(x) msize(huge)) ///	(lfit y2 x if x < 60, sort clpat(solid)) ///	(lfit y2 x if _n ~= 12 & x < 60, sort clpat(shortdash)) ///	, ///	plotregion(style(none)) ///	title("Simple Outlier") ///	ytitle("Y") ///	xtitle("") ///	legend(off) ///	name(outlier, replace)regress y1 x dfbetarename _dfbeta_1 High_Leverage_Pointtwoway ///	(scatter y1 x if x < 60, msymbol(point) msize(medium)) ///	(scatter y1 x if x >= 60, msymbol(x) msize(huge)) ///	(lfit y1 x, sort clpat(solid)) ///	(lfit y1 x if x < 60, sort clpat(shortdash)) ///	, ///	plotregion(style(none)) ///	title("High Leverage Point") ///	ytitle("Y") ///	xtitle("") ///	legend(off) ///	name(leverage, replace)regress y3 xdfbetarename _dfbeta_1 Influential_Pointtwoway ///	(scatter y3 x if x < 60, msymbol(point) msize(medium)) ///	(scatter y3 x if x >= 60, msymbol(x) msize(huge)) ///	(lfit y3 x, sort clpat(solid)) ///	(lfit y3 x if x < 60, sort clpat(shortdash)) ///	, ///	plotregion(style(none)) ///	ylabel(15(5)35) ///	title("Influential Point") ///	ytitle("Y") ///	xtitle("") ///	legend(order(3 4) label(3 "All Data Points") label(4 "Omitting X") ///	pos(12) ring(0)) ///	name(influence, replace)set graphics ongraph combine outlier leverage influence, name(fig4_12, replace)
* Figure 4.13graph box Simple_Outlier High_Leverage_Point Influential_Point, ///
	ytitle("DFBETA") legend(order(1 "Simple Outlier" 2 "High Leverage Point" ///
		3 "Influential Point") rows(2)) name(fig4_13, replace)* Figure 4.14use hersdata, clear
gen id = _nregress LDL BMI age10 nonwhite smoking drinkanydfbeta
rename _dfbeta_1 DFBMI
rename _dfbeta_2 DFage10
rename _dfbeta_3 DFnonwhite
rename _dfbeta_4 DFsmoking
rename _dfbeta_5 DFdrinkanygraph box DFBMI DFage10 DFnonwhite DFsmoking DFdrinkany, name(fig4_14, replace)

* Table 4.23
regress LDL BMI age10 nonwhite smoking drinkanyregress LDL BMI age10 nonwhite smoking drinkany ///	if DFnonwhite <= .2 & DFsmoking <= .2 & DFBMI <= .2

* Table 4.24
sampsi 0 40, sd1(38) alpha(0.05) power(0.8)
* approximate solution using Snedecor and Cochran adjustment 
display (invnormal(.975) + invnormal(.8))^2 * 38^2 / (40^2 * 0.5 * (1-0.5)) + 2

* Table 4.25
use hersdata, clear
regress SBP BMI age nonwhite smoking drinkany i.physact
regress BMI age nonwhite smoking drinkany i.physact
sum BMI
local n_adj = 485*(1-.33^2)
sampsi_reg, alt(0.5) n1(`n_adj') s(power) sx(5.5) sd1(18.5) dis 1 - normal(invnormal(0.975) - 0.5 * 5.5 * sqrt(485*(1-.33^2)) / 18.5)

* Table 4.26
* sample size providing 90% power 
display (invnormal(.975) + invnormal(.9))^2 * 2028 * 0.0415528^2 / 0.5^2
* power in a new study with 200 participants
display 1 - normal(invnormal(0.975) - 0.5 / (sqrt(2028/200) * 0.0415528))
* minimum detectable effect in a new study with 100 participants
display (invnormal(.975) + invnormal(.8)) * sqrt(2028/100) * 0.0415528
