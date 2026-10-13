# benthic-dash

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15083034.svg)](https://doi.org/10.5281/zenodo.7647206)

Materials for the Tampa Bay benthic data dashboard.

## How the dashboard runs

The dashboard is a flexdashboard document (`index.Rmd`) that uses `runtime: shiny_prerendered`. This affects how updates reach users.

* The page layout is rendered once to `index.html` (plus `index_files/`) and reused for every visitor. These files are created on the server and are not tracked by git.
* The `setup` chunk (`context='setup'`) runs once when an R process starts. It sources `R/funcs.R` and loads the files in `data/`. It also builds objects shared by the page and the server, such as the default TBBI and AMBI maps.
* The chunks with `context='server'` run once for each visitor. They hold the reactives, plot and map outputs, and the download handler.
* The plots on each page are only computed when a visitor first opens that page.

## Annual update

1. Benthic and sediment data are provided to TBEP by EPC typically in December.  Note that the updated year will lag the current year. Update the files in [tbeptools](https://github.com/tbep-tech/tbeptools) with these data. 
    - `R/benthicdata.R`, run examples to update `R/benthicdata.RData` and update Roxygen with date of update (may need to change some column names in `R/read_formbenthic.R`)
    - `R/sedimentdata.R`, run examples to update `R/sedimentdata.RData` file and update Roxygen with file dims and date of update
    - Update dates in `R/anlz_tbbimed.R`, `R/show_tbbimatrix.R`, `R/anlz_sedimentaddtot.R`, `R/anlz_sedimentave.R`, `R/anlz_sedidmentpel.R`, `R/anlz_sedimentpelave.R`, `R/show_sedimentalratio.R`, `R/show_sedimentave.R`, `R/show_sedimentmap.R`, `R/show_sedimentpelave.R`, `R/show_sedimentpelmap.R`
    - Run `devtools::document()` to update documentation
    - Update dates in `vignettes/tbbi.Rmd`
    - Update date/version `DESCRIPTION` file
    - Commit and push changes to GitHub
1. Reinstall tbeptools locally and update `maxyr` in `R/funcs.R` in this repository
    - Source `R/dat_proc.R` to update datasets.  This should update all files in `data/` folder excluding `data/segmask.Rdata`.
    - Commit and push changes to GitHub
    - Log on to TBEP server and pull changes to benthic-dash repository
    - Make sure running R processes pick up the new data. To restart the app right away, create or update a `restart.txt` file in the app directory on the server (e.g., `touch restart.txt`). No other files need to be deleted or rendered by hand. rmarkdown re-renders `index.html` on the next request if `index.Rmd`, `R/funcs.R`, the files in `data/` loaded by `index.Rmd`, the header files, or the files in `www/` (including `styles.css`) are newer than `index.html`. Pulling new files gives them a newer modified time, so this happens automatically.
    - Check the live dashboard. The year sliders should end at the new year and the matrices should include the new year.
1. Update [state of the bay](https://github.com/tbep-tech/State-of-the-Bay) page to update the figure on the TBEP [data viz page](https://tbep.org/data-visualization) and the benthic document for [tbep.org/estuary/state-of-the-bay/](https://www.tbep.org/estuary/state-of-the-bay/)
    - Change maxyr and reprocess `figure/tbbireport.jpg` in `createfigs.R` 
    - Change year range and reprocess `figures/pel.png` in `createfigs.R`
    - `docs/tampa-bay-benthic-index.Rmd` change maxyr and reknit
    - Commit and push changes to GitHub
1. Update [CCMP](https://github.com/tbep-tech/ccmp) 
    - `docs/water/coc1.qmd` is the only one that needs updating.  Nothing needs to change, just re-render the website locally using `quarto publish gh-pages` or manually trigger the build on the repo page (otherwise, a commit needs to be pushed to trigger it).

## Troubleshooting

* __The dashboard still shows old data.__ Update `restart.txt` as described above and reload the page. If that does not help, delete `index.html` and the `index_files/` folder on the server and update `restart.txt` again. This forces a fresh render on the next request.
* __The app fails to start with "Unable to write prerendered HTML file".__ The Shiny Server user needs write access to the app directory so it can create `index.html`. Fix the folder permissions, or render the page once on the server with `rmarkdown::render('index.Rmd')` from the app directory.
* __The first visit after an update is slow.__ This is expected. The first request renders `index.html`, which takes some time. Later visits reuse it.
* __A plot or map shows an error.__ Run the dashboard locally to see the full R error. In RStudio, open `index.Rmd` and click Run Document. From the command line, run `rmarkdown::run('index.Rmd')`. Outside RStudio this needs pandoc, which can be pointed to the copy that comes with RStudio by setting the `RSTUDIO_PANDOC` environment variable (e.g., `Sys.setenv(RSTUDIO_PANDOC = 'C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools')`).
* __Editing the dashboard.__ Code that loads data or creates objects needed by both the page and the server goes in `R/funcs.R` or the `setup` chunk. Reactives and `output$...` assignments go in a `context='server'` chunk. The page layout only contains the matching output placeholders (e.g., `plotly::plotlyOutput('benmat')`). Code placed in a regular chunk only runs when the page is rendered and is not available to the server.
