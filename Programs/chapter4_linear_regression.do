set more off

use hersdata, clear
margins physact
contrast {physact 0 0 -1 0 1}, effects

* Table 4.5
quietly regress glucose i.physact if diabetes == 0
contrast physact

* Table 4.6
regress glucose i.physact if diabetes==0
contrast physact, mcompare(bonferroni) nooverall effects

* Table 4.7
* Tests for linear trend
test -2*1.physact - 2.physact + 4.physact + 2*5.physact = 0
contrast {physact -2 -1 0 1 2}, noeffects
contrast q(1).physact, noeffects

* Table 4.9
regress glucose i.physact if diabetes==0
* Tests for linear trend
contrast {physact -2 -1 0 1 2}, noeffects
contrast q(1).physact, noeffects

* show that q. and p. behave differently
recode physact 2=3 3=4 4=5 5=7, gen(physact2)
regress glucose i.physact2 if diabetes == 0
contrast q(1).physact2, noeffects
contrast p(1).physact2, noeffects

* Table 4.11
quietly regress glucose i.physact if diabetes == 0
contrast q(2/4).physact, noeffects

* show that this works with more than 5 levels
reg glucose i.physact if diabetes==0
contrast q(2/5).physact, noeffects
reg glucose physact i.physact if diabetes==0
testparm i.physact
     name(fig4_2, replace) 
     
use hersdata, clear
* Store coefficient for BMI as estimate of overall effect
scalar overall = _b[BMI]
logistic exercise BMI age10 nonwhite smoking drinkany poorfair if diabetes == 0
* Second link: fully adjusted model for effect of exercise on glucose levels
	if diabetes == 0
* Store coefficient for BMI as estimate of direct effect, and calculate PE
scalar direct = _b[BMI]
scalar PE = round((overall-direct)/overall*100, 0.1)
scalar list PE
use hersdata, clear
regress LDL1 i.HT##i.statins
lincom 1.HT + 1.HT#1.statins

* Table 4.16
regress LDL1 i.HT##i.physact
testparm i.HT#i.physact
contrast HT#physact
gen BMIc = BMI - 28.57925

* must use Version 10 syntax for adjust command to work
xi: regress LDL i.statins*BMIc age nonwhite smoking drinkany
    name(fig4_3, replace)


* Table 4.19
set graphics off

* Table 4.20
gen agec = age - 67

    name(fig4_5, replace)
    

* Table 4.21
use hersdata, clear
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
recode BMI ///
xi: regress HDL i.catBMI age10 nonwhite smoking drinkany
qui adjust age10 nonwhite smoking drinkany, gen(fitted2)
twoway ///
	(line fitted BMI, sort lpattern(longdash)) ///
	(line fitted2 BMI, sort lpattern(solid)), ///
    legend(order(2 "Categorical transformation" 1 "Cubic spline fit")) ///


set seed 9896
sample 5
regress glucose diabetes BMI age drinkany
regress glucose diabetes BMI age drinkany, vce(robust)
regress glucose diabetes BMI age drinkany, vce(hc3)
restore
version 12
* outsheet using figure4_12.csv, comma replace

	ytitle("DFBETA") legend(order(1 "Simple Outlier" 2 "High Leverage Point" ///
		3 "Influential Point") rows(2)) name(fig4_13, replace)
gen id = _n
rename _dfbeta_1 DFBMI
rename _dfbeta_2 DFage10
rename _dfbeta_3 DFnonwhite
rename _dfbeta_4 DFsmoking
rename _dfbeta_5 DFdrinkany

* Table 4.23
regress LDL BMI age10 nonwhite smoking drinkany

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
sampsi_reg, alt(0.5) n1(`n_adj') s(power) sx(5.5) sd1(18.5) 

* Table 4.26
* sample size providing 90% power 
display (invnormal(.975) + invnormal(.9))^2 * 2028 * 0.0415528^2 / 0.5^2
* power in a new study with 200 participants
display 1 - normal(invnormal(0.975) - 0.5 / (sqrt(2028/200) * 0.0415528))
* minimum detectable effect in a new study with 100 participants
display (invnormal(.975) + invnormal(.8)) * sqrt(2028/100) * 0.0415528
