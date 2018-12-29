set more off


use hersdata, clear
xtile agedec = age, nq(10)
preserve
collapse age meanSBP=SBP, by(agedec)
save deciles, replace
restore
append using deciles
erase deciles.dta
twoway ///
* graph export sbpage.pdf, replace
use hersdata, clear

* regression with centered age
use wcgs, clear
cs chd69 arcus, or

* Table 3.6
clear
input hivp aids 
1 1
1 1
1 1
1 0
1 0
1 0
1 0
0 1 
0 1
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
0 0
end
label var aids "AIDS diag. in male [1=yes/0=no]"
label var hivp "female partner HIV positive"
cs hivp aids, or exact

* Table 3.7
use wcgs, clear
tabulate chd69 agec, col chi2

* Table 3.8
tabodds chd69 agec, or

* Tables 3.9 and 3.10
use whickam, clear
cs vstatus smoker [freq = nn], or
cs vstatus smoker [freq = nn], or by(agegrp)

* Table 3.11
clear 
set obs 160
gen Z = _n>80
gen X = (_n>45&_n<=80) | _n>115
gen Y = (_n>20&_n<=45) |  (_n>55&_n<=80) | (_n>105&_n<=115) | (_n>140)
tabulate Y X if Z==0
tabulate Y X if Z==1
cs Y X, or by(Z)

* Figure 3.2
use leuk, clear
stset time, f(cens)
sts graph, ///
	by(group) plot1opts(lp(solid)) plot2opts(lp(dash) lc(black)) ///
	ytitle("Proportion in Remission") xtitle("Weeks Since Randomization") ///
	title("") legend(order(1 "6-MP" 2 "Placebo") pos(2) ring(0)) ///
	name(Fig3_2, replace)
* graph export km2.pdf, replace

* Figure 3.3
sts graph, ///
	by(group) failure plot1opts(lp(solid)) plot2opts(lp(dash) lc(black)) ///
	ytitle("Proportion Relapsed") xtitle("Weeks Since Randomization") ///
	title("") legend(order(1 "6-MP" 2 "Placebo") pos(6) ring(0)) ///
	name(Fig3_3, replace)
* graph export km3.pdf, replace

* Table 3.15
sts test group

use hersdata, clear
reg SBP age
