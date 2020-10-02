library(sf)
library(stringr)

# Load the data: the health NGOs table, the 14 senegalese regions, and the senegalese 
ong  = read.csv("data/ongs.csv", stringsAsFactors=FALSE)
link = read.csv("data/link.csv", stringsAsFactors=FALSE)
reg  = read_sf("data/regions_senegal.gpkg", stringsAsFactors=FALSE, quiet=TRUE)
sen  = read_sf("data/contour_senegal.gpkg", stringsAsFactors=FALSE, quiet=TRUE)

#  Unlist the different mission domaines of the NGOs
# keywords = str_split(ong$dom, ",") %>%
#   unlist() %>%
#   str_trim() %>%
#   unique() %>%
#   sort
