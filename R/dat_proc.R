library(tbeptools)
library(here)
library(sf)

# tbbi scores ---------------------------------------------------------------------------------

tbbiscr <- anlz_tbbiscr(benthicdata) %>%
  select(-TotalAbundance, -SpeciesRichness, -Salinity)

save(tbbiscr, file = here('data/tbbiscr.RData'))

# segment polygons ----------------------------------------------------------------------------

load(file = here('data/segmask.RData'))

segs <- tbsegshed %>%
  st_make_valid() %>%
  st_intersection(segmask) %>%
  st_simplify(dTolerance = 10, preserveTopology = TRUE)

save(segs, file = here('data/segs.RData'))
