library(sf)

ong = read.csv("data/ong.csv")
reg = st_read("data/regions.geojson", quiet=TRUE)

# Compute the centroid in
centros = suppressWarnings(st_coordinates(st_centroid(reg)))
reg$lng = centros[,1]
reg$lat = centros[,2]

# plot(st_geometry(reg))
# plot(reg$geom_centro, add=T)
