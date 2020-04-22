// example for hotdeck help file

quietly{
webuse nmihs, clear
keep finwgt marital age childsex birthwgt
replace birthwgt = . if uniform() < 0.20
replace childsex = . if birthwgt == .
gen over25 = age > 25
preserve
}

discard  // to make sure wtd_hotdeck gets reloaded

foreach i of numlist 1/9 {
 
   quietly {
   
       restore, preserve
	   
	   if `i' == 1 {
		  local desc "no hotdeck           "
		  }
	   if `i' == 2 {
	      wtd_hotdeck childsex birthwgt, cells(marital over25)
		  local desc "cells, unwgtd        "
		  }
	   if `i' == 3 {
	      wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt)
		  local desc "cells, wgtd          "
		  }
	   if `i' == 4 {
	      wtd_hotdeck childsex birthwgt
		  local desc "no cells, unwgtd     "
		  }
	   if `i' == 5 {
	      wtd_hotdeck childsex birthwgt, weight(finwgt)
		  local desc "no cells, wgtd       "
		  }
	   if `i' == 6 {
	      wtd_hotdeck childsex, cells(marital over25) weight(finwgt)
	      wtd_hotdeck birthwgt, cells(marital over25) weight(finwgt)
		  local desc "cells, unwgtd, seq   "
		  }
	   if `i' == 7 {
	      wtd_hotdeck childsex, cells(marital over25) weight(finwgt)
	      wtd_hotdeck birthwgt, cells(marital over25) weight(finwgt)
		  local desc "cells, wgtd, seq     "
		  }
	   if `i' == 8 {
	      wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt) verbose(1)
		  local desc "cells, wgtd, seed    "
		  }	   
	   if `i' == 9 {
	      wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt) seed(12345)
		  local desc "cells, wgtd, verbose "
		  }
		  
	   sum childsex [w=finwgt]
	   local N1    : di %12.6f r(N)
	   local mean1 : di %12.6f r(mean)
	   sum birthwgt [w=finwgt]
	   local N2    : di %12.6f r(N)
	   local mean2 : di %12.6f r(mean)
	   corr childsex birthwgt
	   local corr  : di %12.6f r(rho)
       }
   di "`desc' " `N1' " " `mean1' " --- " `N2' " " `mean2' " --- " `corr'
   }	   
 
 webuse nmihs, clear
 sum childsex birthwgt [w=finwgt]
 
 
   
   