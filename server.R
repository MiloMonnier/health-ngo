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
  
  # On the static leaflet map previously created, add the data: regions, contour, circles
  # Incremental changes to the map use should be performed in an observer
  observe({
    leafletProxy("map", data=reg) %>%
      # Add the 14 senegalese regions
      addPolygons(color="black", weight=2, opacity=0.5, 
                  fillColor="blue", fillOpacity=0.05) %>% 
      # Add the senegalese border with a thicker contour above
      addPolygons(data=sen, color="black", weight=4, opacity=0.5, 
                  fillColor="blue", fillOpacity=0.05) %>% 
      # On each region centroid (lng-lat), add circles proportionnal to the number of NGOs
      addCircleMarkers(~lng, ~lat, radius=~nb_ong/10,
                       color="red", weight=1, opacity=0.5,
                       fillColor="red", fillOpacity=0.3)
  })

  # TODO Add a legend for proportionnal circles radius
}