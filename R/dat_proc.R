library(tbeptools)
library(here)
library(dplyr)
library(sf)
library(leaflet)
library(readxl)

cols <- c('#CC3231', '#E9C318', '#2DC938')
maxyr <- 2021

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
  anlz_sedimentaddtot(pelave = F) %>%
  select(SedResultsType, Parameter) %>%
  unique() %>%
  filter(SedResultsType %in% c('Metals', 'Organics') | grepl('TC|TIC|TOC', Parameter)) %>%
  arrange(SedResultsType, Parameter) %>%
  mutate(
    Parameter = factor(Parameter, levels = c("Aluminum", "Antimony", "Arsenic",
      "Cadmium", "Chromium", "Copper",
      "Iron", "Lead", "Manganese", "Mercury", "Nickel", "Selenium",
      "Silver", "Tin", "Zinc", "Total Chlordane",
      "Total DDT", "Total HMW PAH", "Total LMW PAH", "Total PAH", "Total PCB",
      "1-Methylnaphthalene", "2-Methylnaphthalene",
      "A BHC", "A Chlordane", "Acenaphthene", "Acenaphthylene", "Aldrin",
      "Anthracene", "B BHC", "Benzo(a)anthracene", "Benzo(a)pyrene",
      "Benzo(b)fluoranthene", "Benzo(g,h,i)perylene", "Benzo(k)fluoranthene",
      "Chrysene", "Coronene", "D BHC", "DDD", "DDE", "DDT", "Dibenzo(a,h)anthracene",
      "Dieldrin", "Endosulfan I", "Endosulfan II", "Endosulfan SO4",
      "Endrin", "Endrin Aldehyde", "Endrin Ketone", "Fluoranthene",
      "Fluorene", "G BHC", "G Chlordane", "Heptachlor", "Heptachlor Epoxide",
      "Indeno(1,2,3-c,d)pyrene", "Methoxychlor", "Mirex", "Naphthalene",
      "PCB 101", "PCB 1016", "PCB 105", "PCB 118", "PCB 1221", "PCB 1232",
      "PCB 1242", "PCB 1248", "PCB 1254", "PCB 1260", "PCB 1262", "PCB 1268",
      "PCB 128", "PCB 153", "PCB 170", "PCB 18", "PCB 180", "PCB 187",
      "PCB 195", "PCB 206", "PCB 28", "PCB 44", "PCB 52", "PCB 66",
      "PCB 8", "Phenanthrene", "Pyrene", "Retene",
      "TC(Solids)", "TIC(Solids)", "TOC(Solids)")
    )
  )

save(prmlkup, file = here('data/prmlkup.RData'))

# benthic matrix ----------------------------------------------------------

fml <- 'Lato'

load(file = here('data/tbbiscr.RData'))

tbbimat <- tbeptools::show_tbbimatrix(tbbiscr, family = fml, txtsz = NULL)

save(tbbimat, file = here('data/tbbimat.RData'))

# special study table -----------------------------------------------------

spedat <- read_excel('T:/09_TECHNICAL_PROJECTS/BENTHIC_MONITORING/Special_Study_Sites/Benthic_Special_Projects.xlsx') %>%
  mutate(
    Acronym = case_when(
      Acronym == 'Tires' ~ 'PTF',
      Acronym == 'Piney Point' ~ 'PP',
      T ~ Acronym
    ),
    Segment = case_when(
      Segment == 'April & September' ~ 'Piney Point sampling, spring and fall',
      T ~ Segment
    )
  ) %>%
  filter(!fordash %in% 'rm') %>%
  filter(Year <= maxyr) %>%
  select(Year, Description = Segment, Acronym)

# add 2019 mcbay sediment special study info
toadd <- tibble(
  Year = 2019,
  Description = 'McKay Bay',
  Acronym = 'MCB'
)

# combine
spedat <- bind_rows(spedat, toadd) %>%
  arrange(Year, Description)

save(spedat, file = here('data/spedat.RData'))

# special study data --------------------------------------------------------------------------

# these must be processed not using tbeptools function to compare with spedat
# see T:\09_TECHNICAL_PROJECTS\BENTHIC_MONITORING\Special_Study_Sites\Benthic_Special_Projects.xlsx for match of spedat not processed (prior to above) with sediment or benthic TBEP-Special data
# see T:\09_TECHNICAL_PROJECTS\BENTHIC_MONITORING\Special_Study_Sites\staid.csv for sediment data with station acronyms not matched to those in spedat after post-processing
# for all cases, file used for spedat is not altered except noting rows to remove that don't match
# linking key is the Acronym column in spedat, sedspedat, benspedat

sedspedat <- sedimentdata %>%
  filter(FundingProject == 'TBEP-Special') %>%
  mutate(
    Acronym = regmatches(StationNumber, regexpr('([a-zA-Z]+)', StationNumber)),
    Acronym = ifelse(Acronym %in% c('PPf', 'PPs'), 'PP', Acronym),
    Acronym = case_when(
      Acronym == 'CRB' & yr == 2003 ~ 'LBE',
      Acronym == 'CH' ~ 'CH5',
      Acronym == 'FDE' ~ 'FD-E',
      Acronym == 'FDW' ~ 'FD-W',
      Acronym == 'CPB' ~ 'CBSS',
      Acronym %in% c('BCB', 'LTB', 'MTB', 'OTB') & yr == 2018 ~ 'MicPla',
      Acronym == 'HB' & StationNumber == '18HB07' ~ 'MicPla',
      Acronym == 'HB' & StationNumber %in% c(paste0('18HB0', c(1:6))) ~ 'OyRest',
      Acronym == 'MR' ~ 'MROyster',
      T ~ Acronym
    ),
    AreaAbbr = case_when(
      AreaAbbr == 'MCB' ~ 'HB',
      T ~ AreaAbbr
    )
  ) %>%
  filter(!(yr == 2002 & Acronym == 'DHB')) %>% # no record of these sites
  filter(!(yr == 2011 & Acronym == 'BC')) %>% # no record of these sites
  filter(!(yr == 2011 & Acronym == 'MC')) # no record of these sites

# only used for the map, preprocessed above
load(file = here('data/benpts.RData'))

benspedat <- benpts %>%
  filter(FundingProject == 'TBEP-Special') %>%
  mutate(
    Acronym = regmatches(StationNumber, regexpr('([a-zA-Z]+)', StationNumber)),
    Acronym = ifelse(Acronym %in% c('PPf', 'PPs'), 'PP', Acronym),
    Acronym = case_when(
      Acronym == 'CRB' & yr == 2003 ~ 'LBE',
      Acronym == 'CH' ~ 'CH5',
      Acronym == 'FDE' ~ 'FD-E',
      Acronym == 'FDW' ~ 'FD-W',
      Acronym == 'CPB' ~ 'CBSS',
      Acronym %in% c('BCB', 'LTB', 'MTB', 'OTB') & yr == 2018 ~ 'MicPla',
      Acronym == 'HB' & StationNumber == '18HB07' ~ 'MicPla',
      Acronym == 'HB' & StationNumber %in% c(paste0('18HB0', c(1:6))) ~ 'OyRest',
      Acronym == 'MR' ~ 'MROyster',
      T ~ Acronym
    ),
    AreaAbbr = case_when(
      AreaAbbr == 'MCB' ~ 'HB',
      T ~ AreaAbbr
    )
  ) %>%
  filter(!(yr == 2002 & Acronym == 'DHB')) %>% # no record of these sites
  filter(!(yr == 2011 & Acronym == 'BC')) %>% # no record of these sites
  filter(!(yr == 2011 & Acronym == 'MC')) # no record of these sites

save(sedspedat, file = here('data/sedspedat.RData'))
save(benspedat, file = here('data/benspedat.RData'))

# PEL ratio summaries -----------------------------------------------------

pelsum <- anlz_sedimentpel(sedimentdata)

save(pelsum, file = here('data/pelsum.RData'))

