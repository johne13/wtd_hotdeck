// wtd_hotdeck -- version 0.01

* to do:
   * some sort of report, especially about empty cells that result in no impute
   * option to specify impute flag???
   * compare results & speed to the other 2 hotdeck programs
   * use tempvars instead of creating and deleting underscore vars

capture program drop wtd_hotdeck

program wtd_hotdeck

    syntax varlist(min=1), [cells(varlist) weight(varname) seed(integer 0) verbose(integer 0)]
	
    di "varlist  `varlist'"
    di "cells    `cells'"
    di "weight   `weight'"
    di "verbose  `verbose'"

    if "`weight'" == "" {
        gen _weight = 1
        }
    else {
        gen _weight = `weight'
        }

    if "`cells'" == "" {
        gen _cells = 1
        local cells = "_cells"
        }

    if `seed' == 0	 {
        di "no seed was provided"
        } 
    else {
        set seed `seed'
        di "seed set to `seed'"
        }
	
    gen double _sort_order = runiform()

    // define _impute = 1 if any of the variables in varlist are missing
    // donors are the complement (rows with no missing variables)
    gen byte _impute = 0
    foreach var of varlist `varlist' {
        replace _impute = 1 if missing(`var')
        }
		
    // save recipient rows to file, keep donors
    preserve
    keep if _impute == 1
    tempfile recipients
    save `recipients', replace
    restore
    keep if _impute == 0

    // prep donor cells
    sort `cells' _sort_order, stable
    by `cells':  gen _wgt_sum = sum(_weight)
    by `cells':  gen _impute_wgt = _weight / _wgt_sum[_N]
    by `cells':  replace _impute_wgt = sum(_impute_wgt)
    // bring back recipient rows and sort entire data set    
    append using `recipients'
    replace _sort_order = _impute_wgt if _impute_wgt != .

    // set up new groups such that the first row of the group has
    // impute = 0, and all the other rows in the group have impute = 1
    gen _group_id = _impute == 0
	
    //create inverse, to allow descending, stable search
    gen _group_id_n = -_group_id
    gen _sort_order_n = -_sort_order
    sort `cells' _sort_order_n _group_id_n, stable
    replace _group_id = sum(_group_id)
	
    // replace missing values via a simple replace
    // note that impute is included for the almost impossible case of a
    // tie at one, in which case we want the impute=1 row at the top	
    sort `cells' _group_id _impute, stable

    foreach var in `varlist' {
        by `cells' _group_id: replace `var' = `var'[1] if _impute == 1 & missing(`var')
        }
        
    if `verbose' == 0 {
        // drop all the intermediate variables
    foreach v in _weight _cells _sort_order _impute _wgt_sum _impute_wgt _group_id _group_id_n _sort_order_n {
        capture drop `v'
        }
    }

end
