use "hers nodm visit4 only.dta", clear

*Table 11.1 Complete case analysis
regress sbp glucose white bmi

*Singly impute glucose
*Note:  This is also Table 11.8
regress glucose bmi csmker white sbp diabetes
predict pred_gluc
gen imp_glucose=glucose
replace imp_glucose=pred_gluc if glucose==.

*Table 11.2 With imputed glucose
regress sbp imp_glucose white bmi

*Multiple imputation
capture mi unset
mi set wide
mi register imputed glucose
mi impute reg glucose bmi csmker white sbp diabetes, add(5) rseed(271828) force

*Table 11.3 with multiply imputed data
*Note:  results not quite the same since this uses a different seed
mi estimate: regress sbp glucose white bmi

*Longitudinal data
clear all
use "hers long base visit1 only saved.dta"
drop visit
rename nvisit visit

*Table 11.4  Complete case analysis (xtgee)
xtgee sbp visit bmi baseline_dm, i(pptid) corr(exch) robust

*Table 11.5 Complete case analsis (xtmixed)
*Note: reml added to get back to Ver 11 default
xtmixed sbp visit bmi baseline_dm || pptid:, reml

*Table 11.6 xtgee and xtmixed with MAR data
*Note: reml added to get back to Ver 11 default
xtgee sbp visit bmi baseline_dm if miss_mar==0, i(pptid) corr(exch) robust
xtmixed sbp visit bmi baseline_dm if miss_mar==0 || pptid:, reml

*Table 11.7 xtgee and xtmixed with NMAR data
*Note: reml added to get back to Ver 11 default
xtgee sbp visit bmi baseline_dm if miss_nmar==0, i(pptid) corr(exch) robust
xtmixed sbp visit bmi baseline_dm if miss_nmar==0 || pptid:, reml

*Table 11.8 - see above

clear all
use "hers nodm longitudinal.dta"
xtset pptid visit
summ
xtdes

*Centered BMI
egen bmi_avg=mean(bmi)
gen bmi_ctr=bmi-bmi_avg

*MCAR
gen sbp_mcar=sbp
set seed 2718 
gen rndmize1=uniform()
sort rndmize1
*"Drop" 75% of data
replace sbp_mcar=. if _n>_N/4
xtmixed sbp_mcar c.bmi_ctr white htnmeds htnmeds#c.bmi_ctr || pptid:

*To create CD-MCAR drop only those on meds
gen sbp_cdmcar=sbp
set seed 3141
gen rndmize2=uniform()
sort htnmeds rndmize2
*"Drop" 75%, only among those on meds
replace sbp_cdmcar=. if _n>_N/4

*Table 11.12 CD-MCAR analysis and margins
*Note: reml added to get back to Ver 11 default
xtmixed sbp_cdmcar c.bmi_ctr white htnmeds htnmeds#c.bmi_ctr || pptid:, reml
margins, at(bmi_ctr=0) at(bmi_ctr=1)
margins, at(bmi_ctr=0) at(bmi_ctr=1) noesample
