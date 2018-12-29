set more off

use fecfat, clear
* Table 7.1 Fecal Fat for Six Subjects
table subject pilltype, c(mean fecfat) row col

* Table 7.2 One-way ANOVA for the Fecal Fat Example
anova fecfat pilltype

* Table 7.3 Two-way ANOVA for the Fecal Fat Example
anova fecfat subject pilltype

* Table 7.4 SOF BMD and age at menopause with splines
use sof.dta, clear
gen meno_ov_52=meno_age>52
replace meno_ov_52=. if meno_age==.
mkspline visit_spl=visit, cubic nknots(3)
save sof2.dta, replace
regress totbmd i.meno_ov visit_spl* i.meno_ov#c.visit_spl*
predict pred_spl

sort meno_ov_52 visit

*Figure 7.1 BMD versus visit
#delimit;
twoway (connected pred_spl visit if meno_ov_52==0, msym(square) mcolor(black)) 
       (connected pred_spl  visit if meno_ov_52==1, msym(triangle) mcolor(black)), 
        legend(order(1 "Age at meno<52" 2 "Age at meno>52")) ytitle("Total BMD") xtitle("Visit") 
        title("Total BMD versus visit by age at menopause")
        subtitle("Spline fit only") 
		scheme(s1mono)
        name(bmd_vs_meno_spl, replace)
;
#delimit cr;

use gababies, clear

* Table 7.5 Summary Statistics for First- and Last-Born Babies
summ initwght lastwght delwght

* Table 7.6 Regression of Difference in Birthweight on Centered Initial Age
regress delwght cinitage if birthord==5

* Table 7.7 Repeated Measures Regression of Birthweight on Birth Order
* and Centered Initial Age
xtgee bweight i.birthord cinitage i.birthord#c.cinitage if birthord==1|birthord==5, i(momid)

* Table 7.8 Regression of Final Birthweight on Centered Initial Age, Adjusting
* for First Birthweight
regress lastwght cinitage initwght if birthord==5

* Fig 7.2 Plot of Birthweight Versus Birth Order
#delimit;
lowess bweight birthord, 
bwidth(0.4) title("  ") 
note("Lowess smoother, bandwidth 0.4 ", position(11)) 
	plotregion(style(none)) scheme(s1mono) 
	xtitle("Birth Order") ytitle("Birthweight (g)");

* Fig 7.3 Boxplots of Birthweight Versus Birth Order;
graph box bweight, 
	medtype(line) over(birthord) box(1, bfcolor(none) blcolor(black) lwidth(medium)) 
	mark(1, msize(medsmall) mcolor(black) msymbol(circle)) 
	caption("Birth Order", position(6)) 
	plotregion(style(none)) ytitle("Birthweight (g)")
	scheme(s1mono);
#delimit cr;

* Reshape data to wide format
* First drop indicator variables
reshape wide momage timesnc lowbrth bweight, i( momid ) j( birthord )

* Fig 7.4 Matrix Plot of Birthweights for Different Birth Orders
graph matrix bweight*

* Table 7.9 Correlation of Birthweights for Different Birth Orders;
corr bweight1 bweight2 bweight3 bweight4 bweight5

*Shortcut for above command;
corr bweight*

*Put data back in long format (required for xt commands);
reshape long

* Table 7.10 GEE Model With Robust Standard Errors
xtgee bweight birthord initage, i(momid) corr(exch) robust

* Table 7.11 GEE Model Without Robust Standard Errors
xtgee bweight birthord initage, i(momid) corr(exch) 

* Table 7.13 GEE Logistic Model
xtgee lowbrth birthord initage, i(momid) corr(exch) family(binomial) link(logit) robust ef

* Table 7.15 Random Effects Linear Regression Model for Birthweight
xtmixed bweight birthord initage || momid: , reml

use sof2.dta, clear
* Table 7.16 SOF analysis with splines 
xtgee totbmd i.meno_ov_52 visit_spl* i.meno_ov_52#c.visit_spl*, i(id) robust

* Table 7.17 SOF analysis with splines mixed model
xtmixed totbmd bmi visit_spl* || id: visit, cov(uns) reml

* Table 7.18 Between vs within information
bysort id: egen meanbmi=mean(bmi)
gen bmi_dev=bmi-meanbmi
xtmixed totbmd meanbmi bmi_dev visit_spl* || id: visit, cov(uns) reml

* Table 7.19 Low birthweight analysis
use gababies.dta, clear
rename lowbrth lowbirth
xtmelogit lowbirth birthord initage|| momid:, or

*Note:  Troponin data is proprietary so dataset is not given

* Table 7.25 Sample size
sampsi 1.7 1.4, sd1(0.5) power(0.8)
sampsi 1.546 1.4, sd1(0.5) n1(130)


