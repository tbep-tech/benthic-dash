# benthic-dash

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15083034.svg)](https://doi.org/10.5281/zenodo.7647206)

Materials for the Tampa Bay benthic data dashboard.

## Annual udpate

1. Benthic and sediment data are provided to TBEP by EPC typically in December.  Note that the updated year will lag the current year. Update the files in [tbeptools](https://github.com/tbep-tech/tbeptools) with these data. 
    - `R/benthicdata.R`, run examples to update `R/benthicdata.RData` and update Roxygen with date of update (may need to change some column names in `R/read_formbenthic.R`)
    - `R/sedimentdata.R`, run examples to update `R/sedimentdata.RData` file and update Roxygen with file dims and date of update
    - Update dates in `R/anlz_tbbimed.R`, `R/show_tbbimatrix.R`, `R/anlz_sedimentaddtot.R`, `R/anlz_sedimentave.R`, `R/anlz_sedidmentpel.R`, `R/anlz_sedimentpelave.R`, `R/show_sedimentalratio.R`, `R/show_sedimentave.R`, `R/show_sedimentmap.R`, `R/show_sedimentpelave.R`, `R/show_sedimentpelmap.R`
    - Run `devtools::document()` to update documentation
    - Update dates in `vignettes/tbbi.Rmd`
    - Update date/version `DESCRIPTION` file
    - Commit and push changes to GitHub
1. Reinstall tbeptools locally and update `maxyr` in `R/dat_proc.R` and `maxyr` in `index.Rmd` in this repository
    - Source `R/dat_proc.R` to update datasets.  This should update all files in `data/` folder excluding `data/segmask.Rdata`.
    - Commit and push changes to GitHub
    - Log on to TBEP server and pull changes to benthic-dash repository
1. Update [state of the bay](https://github.com/tbep-tech/State-of-the-Bay) page to update the figure on the TBEP [data viz page](https://tbep.org/data-visualization) and the benthic document for [tbep.org/estuary/state-of-the-bay/](https://www.tbep.org/estuary/state-of-the-bay/)
    - Change maxyr and reprocess `figure/tbbireport.jpg` in `createfigs.R` 
    - Change year range and reprocess `figures/pel.png` in `createfigs.R`
    - `docs/tampa-bay-benthic-index.Rmd` change maxyr and reknit
    - Commit and push changes to GitHub
1. Update [CCMP](https://github.com/tbep-tech/ccmp) 
    - `docs/water/coc1.qmd` is the only one that needs updating.  Nothing needs to change, just re-render the website locally using `quarto publish gh-pages` or manually trigger the build on the repo page (otherwise, a commit needs to be pushed to trigger it).
