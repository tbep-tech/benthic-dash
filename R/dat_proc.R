library(tbeptools)
library(here)

# tbbi scores ---------------------------------------------------------------------------------

tbbiscr <- anlz_tbbiscr(benthicdata)

save(tbbiscr, file = here('data/tbbiscr.RData'))
