set more off
set scheme s1mono

use wcgs, clear
* Table 2.1 Numerical Description of Systolic Blood Pressure
summarize sbp,detail

* Fig 2.1 Histogram of SBP data
graph7 sbp

* Fig 2.2 Histogram of SBP Data Using 15 Intervals
histogram sbp, bin(15) name(fig2_2, replace)

* Fig 2.3 Boxplot of SBP Data
summ sbp
graph box sbp, ///
	medtype(line) outergap(75) box(1, bfcolor(none) blcolor(black)) ///
	mark(1, mcolor(black)) plotregion(style(none)) alsize(75)  ///
	name(fig2_3, replace)

* Fig 2.4 Normal Q-Q Plot of the SBP Data
qnorm sbp, ///
	msize(medium) msymbol(circle) mcolor(black) legend(on ring(0)) ///
	plotregion(lcolor(none)) ytitle("Systolic Blood Pressure") ///
	legend(order(1 "Systolic Blood Pressure" 2 "Reference")) ///
	name(fig2_4, replace)

*Fig 2.5 Normal Q-Q Plot of Data From a Heavy-Tailed Distribution
* t-distribution with 1 d.f.
qnorm t1, ///
	msize(medium) mcolor(black) msymbol(circle) legend(on ring(0)) ///
	plotregion(lcolor(none)) ytitle("Heavy-Tailed Distn") ///
	legend(order(1 "Heavy-Tailed Distn" 2 "Reference")) ///
	name(fig2_5, replace)

*Fig 2.6 Normal Q-Q Plot of Data From a Light-Tailed Distribution
* Uniform distribution
qnorm uni, ///
	msize(medium) msymbol(circle) mcolor(black) legend(on ring(0)) ///
	plotregion(lcolor(none)) ytitle("Light-Tailed Distn") ///
	legend(order(1 "Light-Tailed Distn" 2 "Reference")) ///
	name(fig2_6, replace)

*Fig 2.7 Histograms of SBP and ln(SBP)
histogram sbp, ///
	bin(15) plotregion(style(none)) xtitle("Systolic Blood Pressure") ///
	name(sbp20, replace)
histogram lnsbp, ///
	bin(15) plotregion(style(none)) xtitle("Ln of Systolic Blood Pressure") ///
	name(lnsbp20, replace)
graph combine sbp20 lnsbp20, ysize(2.5) iscale(1.7) name(fig2_7, replace)

*Table 2.3
tabulate behpat

* Table 2.5
correlate sbp weight

*Fig 2.8 Scatterplot of SBP and Weight
twoway (scatter sbp weight, msize(tiny) mcolor(black)), ///
	plotregion(style(none)) ///
	ytitle("Systolic Blood Pressure") xtitle("Weight (lbs)") ///
	name(fig2_8, replace)

*Fig 2.9 Lowess Smooth of SBP vs Weight
lowess sbp weight, ///
	bwidth(0.25) msize(tiny) rlopts(lp(solid) clwid(medium)) ///
	note("  ") title("  ") plotregion(style(none)) ///
	ytitle("Systolic Blood Pressure") xtitle("Weight (lbs)") /// 
	name(fig2_9, replace)

*Table 2.6 Summary Data for SBP by Behavior Pattern
bysort behpat: summarize sbp

*Table 2.7 Descriptive Stats for SBP by Behavior Pattern
table behpat, contents(mean sbp sd sbp min sbp max sbp)

*Fig 2.10 Boxplots of SBP by Behavior Pattern
graph box sbp, ///
	medtype(line) over(behpat) ///
	box(1, bfcolor(none) blcolor(black) blwidth(medium)) ///
	mark(1, msize(medsmall) mcolor(black)) ///
	caption("Behavior Pattern", position(6)) ///
	ytitle("Systolic Blood Pressure") ///
	plotregion(style(none)) /// 
	name(fig2_10, replace)

*Table 2.8 Behavior Pattern by Weight Category
tabulate behpat wghtcat, column

*Table 2.9 Correlation Matrix for SBP, Age, Weight, and Height
correlate sbp age weight height

*Fig 2.11 Scatterplot Matrix of SBP, Age, Weight, and Height
graph matrix sbp age height weight, ///
	mcolor(black) msize(vsmall) ///
	name(fig2_11, replace)

*Table 2.10 CHD Events and Behavior Pattern by Weight Category
table chd69 behpat wghtcat, row col

*Figure 2.12 Scatterplot of SBP vs Weight by Behavior Pattern
twoway (scatter sbp weight, msymbol(circle) msize(small) mcolor(black)), ///
	by(behpat, note("  ")) name(fig2_12, replace)


