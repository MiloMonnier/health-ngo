library(shiny)
library(leaflet)
library(sf)

function(input, output, session) {
  
  bb = as.vector(st_bbox(reg))
  
  # Create the map
  output$map = renderLeaflet({
    leaflet(reg) %>%
      addTiles(urlTemplate= "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      fitBounds(bb[1], bb[2], bb[3], bb[4]) %>%
      addPolygons(color="black", weight=2, opacity=0.5, 
                  fillColor="blue", fillOpacity=0.05) %>% 
      addCircleMarkers(~lng, ~lat, radius=~nb_ong/10,
                       color="red", weight=1, opacity=0.5,
                       fillColor="red", fillOpacity=0.3)
  })

}