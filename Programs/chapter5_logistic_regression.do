set more off
clear all
set scheme s1mono

* Table 5.2
use wcgs, clear
logistic chd69 age, coef;

* Table 5.4. Logistic model for the relationship between CHD and arcus;

logistic chd69 arcus;

* Table 5.5. Logistic model for the relationship between CHD and age;

xi: logistic chd69 i.agec;

* Table 5.6. Logistic model for the relationship between CHD and several predictors;

logistic chd69 age chol sbp bmi smoke, coef;

use mira_hsv, clear

mkspline spl = mos, cubic nknots(3)
logistic hsv2 spl* i.agecat i.stihx newparts
list id mos hsv2 agecat stihx newparts if id==2 | id==54