set more off
set scheme s1mono

* Figure 9.1
set seed 9896
clear all
set obs 200
gen age = 40+40*uniform()
gen smoking = uniform()<1/(1+exp(-7.5+0.14*age))
replace smoking=0 if age>70
replace smoking=1 if age<50
gen risk = 0.7 + 0.005*(age-55) if smoking==1
replace risk = 0.55 + 0.03*(age-55) if smoking==0
gen dead = uniform()<risk
set scheme s1mono
gen y1 = -0.05
gen y0 = 0.05
twoway ///
	(line risk age if smoking==1, sort lpattern(solid) lw(medthick)) ///
	(line risk age if smoking==0, sort lpattern(longdash) lw(medthick)) ///
	(scatter y1 age if smoking==1, msymbol(d)) ///
	(scatter y0 age if smoking==0, msymbol(t)), ///
	legend(rows(1) order(1 "" 3 "Smokers" 2 "" 4 "Non-Smokers")) ///
	ytitle("Annual Mortality Risk (%)") ///
	yscale(range(-0.1 1.5)) ylabel(0(0.5)1.5) ///
	xtitle("Age") name(fig9_1, replace)

* Table 9.5
use phototherapy, clear
foreach x in male gest_age qual_TSB age_days {
	tab `x' phototherapy, col
	}
/* There are two typos in the numbers for the no-phototherapy group: there are
706, not 704, infants with 35 weeks gestational age, and 4,246, not 4,263, with
with 24 to <48h age at qualifying TSB measurement. To be fixed in next 
printing. */

* Table 9.6
use phototherapy, clear
logistic over_thresh i.phototherapy male ib40.gest_age##c.birth_wt ///
	ib4.qual_TSB ib2.age_days, cluster(hospital)
	 	
* Table 9.7
preserve
* Duplicate each observation, identifying the second as potential
expand 2, gen(potential)
* Assign the opposite exposure for the potential outcome
replace phototherapy = 1-phototherapy if potential==1
* Estimate the logistic model using only the actual outcomes
quietly logistic over_thresh i.phototherapy male i.gest_age##c.birth_wt ///
	i.qual_TSB i.age_days if potential==0, cluster(hospital)
* Obtain expected values for both actual and potential outcomes
predict Y, pr
* calculate EY by treatment
tab phototherapy, sum(Y)

* repeat using stored results
forvalues i = 0/1 {
	qui sum Y if phototherapy==`i'
	scalar EY`i' = r(mean)
	}
* marginal odds-ratio
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
* marginal risk-difference
scalar marginal_RD = EY1-EY0
scalar list marginal_OR marginal_RD
restore

* Table 9.8
use phototherapy, clear
quietly logistic over_thresh i.phototherapy male ib40.gest_age##c.birth_wt ///
	ib4.qual_TSB ib2.age_days, cluster(hospital)
margins phototherapy
scalar EY0 = el(r(b), 1, 1)
scalar EY1 = el(r(b), 1, 2)
* marginal odds-ratio
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
scalar list marginal_OR

* Table 9.9
margins, dydx(phototherapy) 
margins r.phototherapy

* Table 9.10
/*
capture program drop marginal_OR
program define marginal_OR, rclass
logistic over_thresh i.phototherapy male i.gest_age##c.birth_wt i.qual_TSB i.age_days
margins phototherapy
matrix b = r(b)
scalar EY0 = b[1, 1]
scalar EY1 = b[1, 2]
* marginal odds-ratio
return scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
end
bootstrap "marginal_OR" r(marginal_OR), reps(1000) cluster(hospital)
*/

* Table 9.11
use phototherapy, clear  
gen bwg = birth_wt*1000
capture drop bwsp*
mkspline bwsp = bwg, cubic 
capture drop prop_score
capture drop logit_ps	
qui logistic phototherapy i.qual_TSB##i.(gest_age age_days male) ///
 	i.gest_age##i.age_days i.(gest_age age_days male)##c.bwsp*
estat gof, group(10) table
predict prop_score
predict logit_ps, xb
xtile ps_quintile = prop_score, nq(5)
label variable ps_quintile "Propensity score quintile"
 
foreach x in male gest_age birth_wt qual_TSB age_days {
	di _newline as result "`x'"
	table phototherapy ps_quintile, c(mean `x') format(%9.2f) col
	}
/* Some of the numbers for male sex did not get updated, to be fixed in second
printing. */
 
 * Figure 9.2
twoway (kdensity logit_ps if phototherapy==1, area(1) lpattern(solid)) ///
	(kdensity logit_ps if phototherapy==0, area(1) lpattern(longdash)), ///
	ytitle("Density") xtitle("Logit Propensity Score") ///
	legend(order(1 "Treated" 2 "Untreated")) name(pscores, replace)
* graph export pscores.pdf, eeplace
  
* Table 9.12
table phototherapy ps_quintile, ///
	c(count over_thresh sum over_thresh mean over_thresh) col
 
* Table 9.13
logistic over_thresh i.phototherapy i.ps_quintile, cluster(hospital)
qui margins phototherapy
matrix b = r(b)
scalar EY0 = b[1, 1]
scalar EY1 = b[1, 2]
* Marginal odds-ratio
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
scalar list marginal_OR 
* Marginal risk difference
margins, dydx(phototherapy) 
margins r.phototherapy
 
* Table 9.14
capture drop lps_rcs*
gen lps100 = logit_ps*100
mkspline lps_rcs = lps100, cubic 
logistic over_thresh i.phototherapy lps_rcs*, cluster(hospital)
* check non-linearity of response to propensity score
testparm lps_rcs2-lps_rcs4
qui margins phototherapy
matrix b = r(b)
scalar EY0 = b[1, 1]
scalar EY1 = b[1, 2]
* Marginal odds-ratio
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
scalar list marginal_OR 
* Marginal risk difference
margins, dydx(phototherapy) 
margins r.phototherapy
 
* Table 9.15
gen iptw = phototherapy/prop_score + (1-phototherapy)/(1-prop_score)
sum iptw
recode iptw min/20=0 20/max=1, gen(big_weight)
tab phototherapy big_weight
logistic over_thresh i.phototherapy [pweight=iptw], cluster(hospital)
margins, dydx(phototherapy)
margins r.phototherapy
 
* Table 9.16 
cc over_thresh phototherapy, by(ps_quintile)
 
* checks for sensitivity to positivity violation.
recode logit_ps min/-3=-1 -3/1=0 1/max=1, gen(ppv)
label define ppv -1 "<-3" 0 "-3 to 1" 1 ">1"
label values ppv ppv
label variable ppv "Possible positivity violation"
tab phototherapy ppv, row
logistic over_thresh i.phototherapy lps_rcs* if ppv==0, cluster(hospital)
margins phototherapy
matrix b = r(b)
scalar EY0 = b[1, 1]
scalar EY1 = b[1, 2]
* Marginal odds-ratio
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
scalar list marginal_OR 
* Marginal risk difference
margins, dydx(phototherapy) 
margins r.phototherapy
 
* Table 9.17
capture drop lps100 lps_rcs*
gen lps100 = logit_ps*100
qui mkspline lps_rcs = lps100, cubic 
qui logistic over_thresh i.phototherapy lps_rcs*, cluster(hospital)
margins phototherapy, subpop(phototherapy)
matrix b = r(b)
scalar EY0 = b[1, 1]
scalar EY1 = b[1, 2]
* Marginal odds-ratio
display EY1/(1-EY1)*(1-EY0)/EY0
* Marginal risk difference
margins, dydx(phototherapy) subpop(phototherapy)
margins r.phototherapy, subpop(phototherapy)

* Table 9.18
set seed 9896
capture drop order
gen order = uniform()
sort order
psmatch2 phototherapy, out(over_thresh) pscore(prop_score) noreplace

* Table 9.19
gen smrw = phototherapy + (1-phototherapy)*prop_score/(1-prop_score)
gen big_smrw = smrw>20
tab big_smrw
sum smrw
logistic over_thresh i.phototherapy [pweight=smrw], cluster(hospital)
* Marginal risk difference
margins, dydx(phototherapy)
margins r.phototherapy 

* Table 9.20
use fitdata, clear
gen delta_bmd=cobmd-blbmd 
mkspline age_spl=age, cubic nknots(3)
gen treat = tx
qui summ blbmd
gen bmd_base = (blbmd/r(sd))
qui summ cobmd
gen bmd_post = (cobmd/r(sd))
gen bmdd = cobmd-blbmd
qui summ bmdd
gen bmd_diff = bmdd/r(sd)
gen frac_new = newvfx  
gen frac_base = blvfx 
gen ofrac_base = blnspfx 
* controlled direct effect estimate
quietly logistic frac_new i.treat bmd_diff bmd_base i.frac_base i.smoking age_spl* 
margins treat, at(bmd_diff==0)
margins, dydx(treat) at(bmd_diff==0)
margins r.treat, at(bmd_diff==0)
 
* Table 9.21
use hersdata, clear
set seed 9896
gen ldlch = LDL1-LDL
reg ldlch HT
predict res, resid
* unmeasured confounder associated with LDL change
gen U = res + 30*invnorm(uniform())
* percent compliance depends on U
gen HT_use =  normal(-4 + 6*HT - 0.02*U + 0.5*invnorm(uniform()))
tab HT, sum(HT_use)
reg ldlch HT
reg ldlch HT_use
ivregress 2sls ldlch (HT_use = HT)
estat endogenous
estat firststage
/* numbers don't match exactly -- I must not have set the seed in the example
in the book */

* Table 9.22
use phototherapy, clear
gen phototherapy2 = phototherapy
egen hosp_year = group(hospital year)
biprobit ///
	(over_thresh male i.gest_age##c.birth_wt i.qual_TSB i.age_days i.phototherapy) ///
	(phototherapy2 = i.hosp_year  male i.gest_age##c.birth_wt i.qual_TSB i.age_days), nolog 
margins, at(phototherapy = (0 1)) predict(pmarg1) 
scalar EY0 = el(r(b), 1, 1)
scalar EY1 = el(r(b), 1, 2)
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
scalar list marginal_OR
* marginal risk difference
margins, dydx(phototherapy) predict(pmarg1) 
margins r.phototherapy, predict(pmarg1)

* biprobit model omitting control variables
qui biprobit (over_thresh i.phototherapy) (phototherapy2 = i.hosp_year), cluster(hospital) nolog
margins, at(phototherapy = (0 1)) predict(pmarg1) 
scalar EY0 = el(r(b), 1, 1)
scalar EY1 = el(r(b), 1, 2)
scalar marginal_OR = EY1/(1-EY1)*(1-EY0)/EY0
scalar list marginal_OR 
* marginal risk-difference 
margins, dydx(phototherapy) predict(pmarg1) 
margins r.phototherapy, predict(pmarg1)
scalar marginal_RD = EY1-EY0
scalar list marginal_RD

* show that adding the IV to a model for phototherapy increases pseudo-R^2
qui logistic phototherapy male i.gest_age##c.birth_wt i.qual_TSB i.age_days
scalar psuedoR2_base = e(r2_p)
qui logistic phototherapy male i.gest_age##c.birth_wt i.qual_TSB i.age_days i.hosp_year
scalar psuedoR2_IV = e(r2_p)
scalar list psuedoR2_base psuedoR2_IV


