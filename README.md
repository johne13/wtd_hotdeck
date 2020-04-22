## wtd_hotdeck
A hotdeck (statistical match) imputation that selects donors in proportion to sample weights.  Contents of the help file are below, or refer to the help file itself (wtd_hotdeck.sthlp)

## Quick start guide
Just copy the ado and sthlp files to you standard ado directory, or any working directory

## Files in this repository
<b>wtd_hotdeck.ado</b> -- the actual ado file

<b>wtd_hotdeck.sthlp</b> -- the help file, in Stata's SMCL format

<b>help_example.do</b> -- this is a similar to the example in the help file, but expanded to do some barebones testing of the ado file syntax and results

## The Stata help file:

wtd_hotdeck -- A hotdeck (or statistical match) imputation that selects donor rows in proportion to their survey or sample weights

Syntax
    wtd_hotdeck varlist(min=1) [, options]

    options               Description
    --------------------------------------------------------------------------------------------------------------------------
    Main
      cells(varlist)       (optional) Categorical-style variables that define the cells
      weight(varname)      (optional) Survey- or sample-type weights
      seed(#)              (optional, default=0) A positive integer will be used to set the seed, zero means no seed is set
      verbose(#)           (optional, default=0) A non-zero value will cause intermediate variables to be retained
    --------------------------------------------------------------------------------------------------------------------------

Description

    This is a fairly standard hotdeck program with the possibly interesting feature of allowing the use of frequency- or
    survey-style weights.  If provided, the donor rows are sampled in proportion to the weights, which may be either integers
    or floats.  If multiple variables are imputed to a row, then all values will be selected from the same donor row.

    Note that donors and recipients are defined internally based on missing values in varlist.  Rows with no missing values in
    varlist are defined as donors, and rows with any missing values are defined as recipients.  Also note that missing values
    are replaced or over-written by the hotdeck, so it may be helpful to explicitly store the original values for later
    comparisons.

    This program is offered for free and "as is", with no guarantees except "your money back for any reason".  It has mainly
    been tested with Stata 12 (MacOS) and Stata 15 (Windows 10).  Since it is a essentially just a specialized sorting
    program, it will likely work with any semi-recent version of Stata (or your money back, of course).

Options
   
    cells(varlist) Theses variables define the cells of the hotdeck.  The user is responsible for checking that each cell
        contains a sufficient number of donors and no checking is done by this program.  The variables in "cells" are used
        internally for sorting and will generally be of the categorical type, but any variable type is allowed (e.g. if you
        have a float variable that only has five unique values, that should be fine).

    weight(varname) These may be of frequency- or survey-type and can be integers or floats.

    seed(#) Set to a postive integer in order to ensure reproducible results.  The positive integer becomes the input for an
        internal "set seed" command.  If the seed is set to zero (the default value) or is not specified, then no seed is set
        internally and Stata will use the system value of seed, whatever that happens to be.

    verbose(#) If verbose is set to 1, a number of intermediate variables (beginning with "_") are retained at program
        termination.  This is mainly for debugging or curiosity.

Brief example

    Start with the NMIHS data, then randomly set 20% of childsex & birthwgt to missing

        . webuse nmihs
        . keep finwgt marital age childsex birthwgt
        . replace birthwgt = . if uniform() < 0.20
        . replace childsex = . if birthwgt == .
        . gen over25 = age > 25
        . preserve

    Impute childsex & birthwgt using cells based on age & marital status

        . wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt)

Continuing the example...

    Note that wtd_hotdeck does not check that all of your cells have enough donors observations, so you should always check
    this manually.  One simple way is to just tab the donor cells.

        . table marital over25 if ~missing(childsex,birthwgt)

    It can be interesting to check how much the weights matter.  If you try the short example below, you are likely to find
    that the weights matter substantially, although there will be some random variation with each run (if no seed is set).

        . restore, preserve
        . sum child birthwgt [w=finwgt] // before hotdeck

        . qui: wtd_hotdeck childsex birthwgt, cells(marital over25)
        . sum child birthwgt [w=finwgt] // after un-weighted hotdeck

        . restore, preserve
        . qui: wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt)
        . sum child birthwgt [w=finwgt] // after weighted hotdeck

Author

    John R Eiler
    U.S. Dept of the Treasury
    first.last at treasury.gov

Acknowledgements

    Rachel Costello, Portia DeFillippes

Also see

    hotdeck, whotdeck, hotdeckvar -- These are community-contributed commands that can be used for a hotdeck imputation.  All
    three can be installed with "ssc install" and include excellent help files.  None of them allow sample weights as far as I
    can tell.

    Stata's mi -- Stata's mi command is very powerful and offers many alternative imputation approaches, but no option to do a
    simple hotdeck, weighted or unweighted, to the best of my knowledge.

    SAS's proc surveyimpute -- It appears that SAS offers a weighted hotdeck via the command "proc surveyimpute
    method=hotdeck(selection=weighted);".  I have not used this command and hence have not compared results to wtd_hotdeck.



