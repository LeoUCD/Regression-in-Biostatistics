clear all

use nhanes3, clear

svyset sdppsu6 [pweight = wtpfqx6], strata(sdpstra6)

* Section 10.2
* unweighted proportion with diabetes
tab diabetes
* weighted proportion
svy: mean diabetes
* unweighted prevalence
dis .0739 * 1.685e+08
* weighted prevalence
svy: total diabetes

* Table 10.1.  Unweighted, Weighted, and Survey Logistic Models for Diabetes
* Model 1: Unweighted logistic model ignoring weights and clustering
logit diabetes age10 aframer mexamer othereth female, or nolog
* Model 2: Weighted logistic model still ignoring clustering
logit diabetes age10 aframer mexamer othereth female [pweight = wtpfqx6], or nolog
* Model 3: Survey model accounting for weights, stratification, and clustering
svy: logit diabetes age10 aframer mexamer othereth female, or nolog
estat effects, deff
* Section 12.5.3
estat gof, group(10)
