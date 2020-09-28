library(shiny)
library(leaflet)
library(sf)

function(input, output, session) {
  
  # Create the static map, which will be loaded once at startup and then cached
  output$map = renderLeaflet({
    bbox = as.vector(st_bbox(reg)) # Retrieve the extent of the Senegal
    leaflet() %>%
      addTiles(urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  # Add the  proportionnaIncremental changes to the map use should be performed in an observer
  observe({
    leafletProxy("map", data=reg) %>%
      addPolygons(color="black", weight=2, opacity=0.5, 
                  fillColor="blue", fillOpacity=0.05) %>% 
      addCircleMarkers(~lng, ~lat, radius=~nb_ong/10,
                       color="red", weight=1, opacity=0.5,
                       fillColor="red", fillOpacity=0.3)
  })

  # TODO Add a legend for proportionnal circles radius
}