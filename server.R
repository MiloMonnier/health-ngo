library(shiny)
library(leaflet)
library(sf)

function(input, output, session) {
  
  dat = reactive({
    reg
  })
  # Create the static map, which will be loaded once at startup and then cached
  output$map = renderLeaflet({
    bbox = as.vector(st_bbox(dat())) # Retrieve the extent of the Senegal
    leaflet() %>%
      addTiles("//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  # On the static leaflet map previously created, add the data (circles or choropleth map)
  # Incremental changes to the map use should be performed in an observer
  observe({
    
    # Take back the static leaflet map and, every time input$ or dat() changes, clear polygons, markers, and legend 
    map = leafletProxy("map", data=dat()) %>% 
      clearShapes() %>% 
      clearMarkers() %>%
      clearControls()    # Clears legend
    # If circles chosen, add circles proportionnal to the number of NGOs on each region centroid (lng-lat)
    if (input$maptype=="circles") {
      map %>% 
        addPolygons(color="black", weight=2, opacity=0.5, fillColor="blue", fillOpacity=0.05) %>%
        addCircleMarkers(~lng, ~lat, radius=~nb_ong/10, color="red", weight=1, opacity=0.5, fillColor="red", fillOpacity=0.3)
      
      # Else, display a choropleth map
    } else if (input$maptype=="density") {
      # Set the color discretisation with Jenks algorithm
      var = dat()$dens_km
      nclass = 5
      intervals = classIntervals(var, nclass, style="jenks")
      classes = cut(var, intervals$brks, include.lowest=TRUE)
      colors = brewer.pal(nclass, "YlOrRd")
      col = colors[classes]
      # Add the Polygons and the Legend
      map %>%
        addPolygons(color="black", weight=2, opacity=0.3, fillColor=col, fillOpacity=0.5) %>%
        addLegend(position="bottomleft", colors=rev(colors), labels=rev(levels(classes)))
    }
    
    # Endly, add the senegalese external border with a thicker contour
    map %>%
      addPolygons(data=sen, color="black", weight=4, opacity=0.5, fillOpacity=0) 
  })
  
  # TODO Add a click event on senegalese regions
}