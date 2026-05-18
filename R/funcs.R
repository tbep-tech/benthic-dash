cols <- c('#CC3231', '#E9C318', '#2DC938')
maxyr <- 2024

# Leaflet map pre-loaded with the same basemap tiles mapview uses by default.
# Avoids the overhead of initializing a full mapview object.
base_leaflet <- function() {
  leaflet::leaflet() %>%
    leaflet::addProviderTiles("CartoDB.Positron",   group = "CartoDB.Positron") %>%
    leaflet::addProviderTiles("CartoDB.DarkMatter", group = "CartoDB.DarkMatter") %>%
    leaflet::addProviderTiles("OpenStreetMap",      group = "OpenStreetMap") %>%
    leaflet::addProviderTiles("Esri.WorldImagery",  group = "Esri.WorldImagery") %>%
    leaflet::addProviderTiles("OpenTopoMap",        group = "OpenTopoMap") %>%
    leaflet::addLayersControl(
      baseGroups = c("CartoDB.Positron", "CartoDB.DarkMatter", "OpenStreetMap",
                     "Esri.WorldImagery", "OpenTopoMap"),
      options = leaflet::layersControlOptions(collapsed = TRUE)
    )
}

# Harmonize the Acronym column for special study site data (sedspedat, benspedat).
# Also drops rows with no matching project record.
fix_acronym <- function(dat) {
  dat |>
    dplyr::mutate(
      Acronym = regmatches(StationNumber, regexpr('([a-zA-Z]+)', StationNumber)),
      Acronym = ifelse(Acronym %in% c('PPf', 'PPs'), 'PP', Acronym),
      Acronym = dplyr::case_when(
        Acronym == 'CRB' & yr == 2003 ~ 'LBE',
        Acronym == 'CH'  ~ 'CH5',
        Acronym == 'FDE' ~ 'FD-E',
        Acronym == 'FDW' ~ 'FD-W',
        Acronym == 'CPB' ~ 'CBSS',
        Acronym %in% c('BCB', 'LTB', 'MTB', 'OTB') & yr == 2018 ~ 'MicPla',
        Acronym == 'HB' & StationNumber == '18HB07' ~ 'MicPla',
        Acronym == 'HB' & StationNumber %in% paste0('18HB0', 1:6) ~ 'OyRest',
        Acronym == 'MR' ~ 'MROyster',
        T ~ Acronym
      )
    ) |>
    dplyr::filter(!(yr == 2002 & Acronym == 'DHB')) |>
    dplyr::filter(!(yr == 2011 & Acronym %in% c('BC', 'MC')))
}

# Returns a renderUI for the sediment parameter selectInput.
# exclude: type values for which no parameter selector should appear.
param_selector_ui <- function(input, typsel_id, input_id, prmlkup,
                              exclude = 'PEL summary') {
  shiny::renderUI({
    typsel <- input[[typsel_id]]
    shiny::req(typsel, !typsel %in% exclude)
    tosel <- prmlkup |>
      dplyr::filter(SedResultsType == typsel) |>
      dplyr::pull(Parameter) |>
      sort() |>
      as.character()
    shiny::selectInput(input_id, 'Select parameter:', choices = tosel)
  })
}
