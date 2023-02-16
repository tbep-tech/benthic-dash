library(tbeptools)
library(here)
library(dplyr)
library(filter)
library(sf)
library(leaflet)
library(readxl)

cols <- c('#CC3231', '#E9C318', '#2DC938')

# tbbi scores ---------------------------------------------------------------------------------

tbbiscr <- anlz_tbbiscr(benthicdata) %>%
  select(-TotalAbundance, -SpeciesRichness, -Salinity)

save(tbbiscr, file = here('data/tbbiscr.RData'))

# tb segments -------------------------------------------------------------

load(file = here('data/segmask.RData'))

segs <- tbsegshed %>%
  st_make_valid() %>%
  st_intersection(segmask) %>%
  st_simplify(dTolerance = 10, preserveTopology = TRUE)

save(segs, file = here('data/segs.RData'))

# median tbbi scores by segment -------------------------------------------

load(file = here('data/tbbiscr.RData'))

benmed <- tbbiscr %>%
  tbeptools::anlz_tbbimed() %>%
  mutate(
    outcome = case_when(
      TBBICat == 'Good' ~ cols[3],
      TBBICat == 'Fair' ~ cols[2],
      TBBICat == 'Poor' ~ cols[1]
    )
  )

save(benmed, file = here('data/benmed.RData'))

# benthic points all years as sf ------------------------------------------

# points
benpts <- tbbiscr %>%
  filter(ProgramName %in% c('Benthic Monitoring')) %>%
  filter(TBBICat != 'Empty Sample') %>%
  filter(AreaAbbr %in% c("HB", "OTB", "MTB", "LTB", "TCB", "MR", "BCB")) %>%
  mutate(
    outcome = case_when(
      TBBICat == 'Healthy' ~ cols[3],
      TBBICat == 'Intermediate' ~ cols[2],
      TBBICat == 'Degraded' ~ cols[1]
    )
  ) %>%
  sf::st_as_sf(coords = c('Longitude', 'Latitude'), crs = 4326)

save(benpts, file = here('data/benpts.RData'))

# parameter lookup --------------------------------------------------------

# parameter lookup
prmlkup <- sedimentdata %>%
  select(SedResultsType, Parameter) %>%
  unique() %>%
  filter(SedResultsType %in% c('Metals', 'Organics') | grepl('TC|TIC|TOC', Parameter)) %>%
  arrange(SedResultsType, Parameter)

save(prmlkup, file = here('data/prmlkup.RData'))

# benthic matrix ----------------------------------------------------------

fml <- 'Lato'

load(file = here('data/tbbiscr.RData'))

tbbimat <- tbeptools::show_tbbimatrix(tbbiscr, family = fml, txtsz = NULL)

save(tbbimat, file = here('data/tbbimat.RData'))

# special study table -----------------------------------------------------

spedat <- read_excel('T:/09_TECHNICAL_PROJECTS/BENTHIC_MONITORING/Special_Study_Sites/Benthic_Special_Projects.xlsx') %>%
  select(Year, `Short description` = Acronym, `Long description` = Segment)

save(spedat, file = here('data/spedat.RData'))

# PEL ratio summaries -----------------------------------------------------

pelsum <- anlz_sedimentpel(sedimentdata)

save(pelsum, file = here('data/pelsum.RData'))

