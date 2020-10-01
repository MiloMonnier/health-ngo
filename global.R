library(sf)
library(classInt)
library(RColorBrewer)

# Load the data: the health NGOs table, the 14 senegalese regions, and the senegalese 
ngo = read.csv("data/ngos.csv", stringsAsFactors=FALSE)
reg = st_read("data/senegal_regions.gpkg", stringsAsFactors=FALSE, quiet=TRUE)
sen = st_read("data/senegal_contour.gpkg", stringsAsFactors=FALSE, quiet=TRUE)

# Compute the centroid of each region and retrieve coordinates.
# Conventionnaly, centroid should be computed in planar coordinates, in the EPSG:32628
# CRS here. However, EPSG:4326 still works, so we keep going and mute the warnings
centros = suppressWarnings(st_coordinates(st_centroid(reg)))
reg$lng = centros[,1]
reg$lat = centros[,2]

# Compute the density of NGOS per km2, and per 100000/hab
reg$area_km2 = st_area(st_transform(reg, 32628))/10^6
reg$area_km2 = as(reg$area_km2, "numeric") 
reg$dens_km = reg$nb_ong / reg$area_km2


# For a continuous gradient
# pal = colorNumeric("YlGnBu", dat()$dens_km)
# reg$color = pal(reg$dens_km)
# Source: https://rstudio.github.io/leaflet/legends.html




