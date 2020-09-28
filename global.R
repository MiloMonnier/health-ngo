library(sf)

# Load the data: the health NGOs table, the 14 senegalese regions, and the senegalese 
ong = read.csv("data/ngos.csv")
reg = st_read("data/senegal_regions.gpkg", quiet=TRUE)
sen = st_read("data/senegal_contour.gpkg", quiet=TRUE)

# Compute the centroid of each region and retrieve coordinates.
# Conventionnaly, centroid should be computed in planar coordinates, in the EPSG:32628
# CRS here. However, EPSG:4326 still works, so we keep going and mute the warnings
centros = suppressWarnings(st_coordinates(st_centroid(reg)))
reg$lng = centros[,1]
reg$lat = centros[,2]

