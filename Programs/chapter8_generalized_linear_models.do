set more off

use "needle_sharing.dta", clear

*Table 8.1 Poisson regression
glm shared_syr i.homeless, family(poisson) link(log) eform

*Table 8.2 Poisson regression with robust SEs
glm shared_syr i.homeless, family(poisson) link(log) eform vce(robust)

*Table 8.3 Negative binomial regression
glm shared_syr i.homeless, family(nbinomial ml) link(log) eform

*Descriptive statistics showing overdispersion and extreme values
table homeless, c(mean shared_syr sd shared_syr)
tabulate shared_syr

*Table 8.4 Hurdle model
gen share0=shared_syr==0
logistic share0 i.homeless, level(97.5)
ztnb shared_syr i.homeless if shared_syr>0, irr level(97.5)

*Table 8.5 Zero inflated binomial
zinb shared_syr i.homeless, inflate(i.homeless) irr level(97.5)

clear all
use FITglm.dta, clear

*Generate four category variable from treatment and risk of falling variables,
*each of which is binary
rename trt01 trt
rename riskcat4 fall_risk
gen trt_fall=2*fall_risk+trt+1
label define trt_rsk 2 "ALN:Low risk"
label define trt_rsk 1 "PLB:Low risk", add
label define trt_rsk 4 "ALN:High risk", add
label define trt_rsk 3 "PLB:High risk", add
label values trt_fall trt_rsk

*Check results
table trt_fall trt
table trt_fall fall_risk

*Offset variable for analyses
gen logyears=ln(trialyrs)

*Table 8.6 Non-spine fractures, four level variable
glm numnosp ibn.trt_fall, family(poisson) offset(logyears) vce(robust) noconstant ef

*Table 8.7 Non-spine fractures, main effects and interaction
glm numnosp i.trt##i.fall_risk, family(poisson) offset(logyears) vce(robust) ef
margins r.trt@fall_risk

*Table 8.9 sample size calculation
display (invnormal(.975)+invnormal(.9))^2*30/((log(0.5)*0.5)^2*7.5)
