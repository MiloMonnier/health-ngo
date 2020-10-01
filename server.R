library(shiny)
library(leaflet)
library(sf)

test = reg

function(input, output, session) {
  
  dat = reactive({
    reg
  })
  
  # Create the static map, which will be loaded once at startup and then cached
  output$map = renderLeaflet({
    bbox = as.vector(st_bbox(reg)) # Retrieve the extent of the Senegal
    leaflet(reg) %>%
      addTiles(urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  
  # On the static leaflet map previously created, map the data
  # Incremental changes to the map use should be performed in an observer
  observe({
    # Take static map and, every time input$ or dat() changes, clear polygons, markers
    # and legend. Add also senegalese external border with a thicker contour
    map = leafletProxy("map", data=dat()) %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearControls() %>%
      addPolylines(data=sen, color="black", weight=4)
    # If circles chosen, add circles proportionnal to the number
    #of NGOs on each region centroid (lng-lat)
    if (input$maptype=="circles") {
      map %>%
        addPolygons(color="black", weight=2, opacity=0.5,
                    fillColor="blue", fillOpacity=0.05,
                    label=~lib) %>%
        addCircleMarkers(~lng, ~lat, 
                         layerId=~id, 
                         radius=~nb_ong/10, color="red", weight=1, opacity=0.5,
                         fillColor="red", fillOpacity=0.3,
                         label=~lib)
    # Else, display a choropleth map, discretized with Jenks algorithm, and corresponding legend
    } else if (input$maptype=="density") {
      var = dat()$dens_km
      nclass = 5
      intervals = classIntervals(var, nclass, style="jenks")
      classes = cut(var, intervals$brks, include.lowest=TRUE)
      colors = brewer.pal(nclass, "YlOrRd")
      col = colors[classes]
      map %>%
        addPolygons(layerId=~id,
                    color="black", weight=2, opacity=0.3,
                    fillColor=col, fillOpacity=0.5,
                    label=~lib) %>%
        addLegend("bottomleft", title="Nb d'ONG/km²",
                  colors=rev(colors),  labels=rev(levels(classes)))
    }
    
  })
  
  
  # Create functions to show popup at given location
  
  # For circlesMarkers
  showMarkersPopup = function(id, lat, lng) {
    selectedReg = reg[reg$id==id, ]
    content = as.character(tagList(tags$h4("markerPopup. Nb d'ONG:", selectedReg$nb_ong)))
    leafletProxy("map") %>% 
      addPopups(lng, lat, content, layerId=id)
  }
  
  # For polygons
  showPolygonsPopup = function(id, lat, lng) {
    selectedReg = reg[reg$id==id, ]
    content = as.character(tagList(tags$h4("polygonPopup:", selectedReg$lib)))
    leafletProxy("map") %>% 
      addPopups(lng, lat, content, layerId=id)
  }
  
  # When a circleMaker is clicked, show a popup
  observe({
    leafletProxy("map") %>% 
      clearPopups()
    event = input$map_marker_click
    if (is.null(event))
      return()
    isolate({
      showMarkersPopup(event$id, event$lat, event$lng)
    })
  })
  
  # When a region polygon is clicked, show a popup
  observe({
    leafletProxy("map") %>% 
      clearPopups()
    event = input$map_shape_click
    if (is.null(event))
      return()
    isolate({
      showPolygonsPopup(event$id, event$lat, event$lng)
    })
  })
  
  
}