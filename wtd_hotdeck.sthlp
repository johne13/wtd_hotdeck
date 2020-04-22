{smcl}
{* *! version 0.01 16 Apr 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "wtd_hotdeck##syntax"}{...}
{viewerjumpto "Description" "wtd_hotdeck##description"}{...}
{viewerjumpto "Options" "wtd_hotdeck##options"}{...}
{viewerjumpto "Remarks" "wtd_hotdeck##remarks"}{...}
{viewerjumpto "Examples" "wtd_hotdeck##examples"}{...}
{title:Title}
{phang}
{bf:wtd_hotdeck} {hline 2} Hotdeck (or statistical match) imputation that selects donor rows in proportion to their
survey or sample weights

{marker syntax}{...}
{title:Syntax}
{p 4 17 2}
{cmdab:wtd_hotdeck}
varlist(min=1)
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt cells(varlist)}}  (optional) Categorical-style variables that define the cells{p_end}
{synopt:{opt weight(varname)}}  (optional) Survey- or sample-type weights{p_end}
{synopt:{opt seed(#)}}  (optional, default=0)  A positive integer will be used to set the seed, zero means no seed is set{p_end}
{synopt:{opt verbose(#)}}  (optional, default=0)  A non-zero value will cause intermediate variables to be retained{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
This is a fairly standard hotdeck program with the possibly interesting feature of allowing the use of frequency- or 
survey-style weights.  If provided, the donor rows are sampled in proportion to the weights, 
which may be either integers or floats.  If multiple variables are 
imputed to a row, then all values will be selected from the same donor row.

{pstd}
Note that donors and recipients are defined internally based on missing values in varlist.  Rows with no missing values
in varlist are defined as donors, and rows with any missing values are defined as recipients.  Also note that missing 
values are replaced or over-written by the hotdeck, so it may be helpful to explicitly store the
original values for later comparisons.

{pstd}
This program is offered for free and "as is", with no guarantees except "your money back for any reason".  It has mainly been tested
with Stata 12 (MacOS) and Stata 15 (Windows 10).  Since it is a essentially just a specialized sorting program, it
will likely work with any semi-recent version of Stata (or your money back, of course).

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt cells(varlist)}
Theses variables define the cells of the hotdeck.  The user is responsible for checking that each cell contains a
sufficient number of donors and no checking is done by this program.  The variables in "cells" are used internally for 
sorting and will generally be of the categorical type, but any variable type is allowed (e.g. if you have a float 
variable that only has five unique values, that should be fine).
{p_end}

{phang}
{opt weight(varname)}    
These may be of frequency- or survey-type and can be integers or floats.
{p_end}

{phang}
{opt seed(#)}
Set to a postive integer in order to ensure reproducible results.  The positive integer becomes the input for an 
internal "set seed" command.  If the seed is set to zero (the default value) or is not specified, then no seed is set internally and 
Stata will use the system value of seed, whatever that happens to be.
{p_end}

{phang}
{opt verbose(#)}    
If verbose is set to 1, a number of intermediate variables (beginning with "_") are retained at program termination.
This is mainly for debugging or curiosity.
{p_end}

{marker examples}{...}
{title:Brief example}

{pstd}Start with the NMIHS data, then randomly set 20% of childsex & birthwgt to missing{p_end}

{phang2}{cmd:. webuse nmihs}{p_end}
{phang2}{cmd:. keep finwgt marital age childsex birthwgt}{p_end}
{phang2}{cmd:. replace birthwgt = . if uniform() < 0.20}{p_end}
{phang2}{cmd:. replace childsex = . if birthwgt == .}{p_end}
{phang2}{cmd:. gen over25 = age > 25}{p_end}
{phang2}{cmd:. preserve}{p_end}

{pstd}Impute childsex & birthwgt using cells based on age & marital status{p_end}

{phang2}{cmd:. wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt)}{p_end}

{title:Continuing the example...}

{pstd}Note that wtd_hotdeck does not check that all of your cells have enough donors observations, so you should always check this
manually.  One simple way is to just tab the donor cells.{p_end}

{phang2}{cmd:. table marital over25 if ~missing(childsex,birthwgt)}{p_end}

{pstd}It can be interesting to check how much the weights matter.  If you try the short example below, you are likely to find
that the weights matter substantially, although there will be some random variation with each run (if no seed is set). {p_end}

{phang2}{cmd:. restore, preserve}{p_end}
{phang2}{cmd:. sum child birthwgt [w=finwgt]  // before hotdeck}{p_end}

{phang2}{cmd:. qui: wtd_hotdeck childsex birthwgt, cells(marital over25)}{p_end}
{phang2}{cmd:. sum child birthwgt [w=finwgt]  // after un-weighted hotdeck}{p_end}

{phang2}{cmd:. restore, preserve}{p_end}
{phang2}{cmd:. qui: wtd_hotdeck childsex birthwgt, cells(marital over25) weight(finwgt)}{p_end}
{phang2}{cmd:. sum child birthwgt [w=finwgt]  // after weighted hotdeck}{p_end}

{title:Author}

{pstd}John R Eiler{p_end}
{pstd}U.S. Dept of the Treasury{p_end}
{pstd}first.last at treasury.gov{p_end}

{title:Acknowledgements}

{pstd}
Rachel Costello, Portia DeFillippes
{p_end}

{title:Also see}

{pstd}
{cmdab: hotdeck, whotdeck, hotdeckvar} -- These are community-contributed commands that can be used for a hotdeck
imputation.  All three can be installed with "ssc install" and include excellent help files.  None of them allow sample 
weights as far as I can tell.
{p_end}

{pstd}
{cmdab: Stata's mi} -- Stata's mi command is very powerful and offers many alternative imputation approaches, but no option
to do a simple hotdeck, weighted or unweighted, to the best of my knowledge.
{p_end}

{pstd}
{cmdab: SAS's proc surveyimpute} -- It appears that SAS offers a weighted hotdeck via the command
"proc surveyimpute method=hotdeck(selection=weighted);".  I have not used this command and hence have not compared
results to wtd_hotdeck.
{p_end}

