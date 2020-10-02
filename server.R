library(shiny)
library(leaflet)
library(sf)
library(stringr)
library(classInt)
library(RColorBrewer)


function(input, output, session) {
  
  # Filter the ONG, LINKS and REGS in function of the chosen domain
  rv = reactive({
    if (input$domaine!="all") {
      ong = ong[str_detect(ong$dom, input$domaine), ]
      link = link[link$ong %in% ong$id, ]
    }
    aggByReg = aggregate(link$ong, by=list(link$reg), length)
    colnames(aggByReg) = c("id", "nb_ong")
    reg$nb_ong = aggByReg$nb_ong[match(reg$id, aggByReg$id)]
    reg = reg[!is.na(reg$nb_ong), ]
    return(list(ong=ong, reg=reg, link=link))
  })
  
  # Create the static map, which will be loaded once at startup and then cached
  output$map = renderLeaflet({
    bbox = as.vector(st_bbox(reg)) # Retrieve the extent of the Senegal
    leaflet(reg) %>%
      addTiles(urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  log(1.1, 1.1)
  log(10, 1.2)
  
  # On the static leaflet map previously created, map the data
  # Incremental changes to the map use should be performed in an observer
  observe({
    # Take static map and, every time input$ or dat() changes, clear polygons, markers
    # and legend. Add also senegalese external border with a thicker contour
    reg = rv()$reg
    map = leafletProxy("map", data=reg) %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearControls() %>%
      clearPopups() %>% 
      addPolylines(data=sen, color="black", weight=4)
    # If circles, add circles proportionnal to the nb of NGOs in each region
    if (input$maptype=="circles") {
      # Allow user to adjust circles size
      ciclesRadius = reg$nb_ong * input$a
      map %>%
        addPolygons(color="black", weight=2, opacity=0.5,
                    fillColor="blue", fillOpacity=0.05,
                    label=~lib) %>%
        addCircleMarkers(~lng, ~lat, layerId=~id, 
                         radius=ciclesRadius, color="red", weight=1, opacity=0.5,
                         fillColor="red", fillOpacity=0.3,
                         label=~lib)
      # Else, display a choropleth map, discretized with Jenks algorithm, + legend
    } else if (input$maptype=="density") {
      densities = reg$nb_ong / reg$area_km2 
      nclass = 5
      intervals = classIntervals(densities, nclass, style="jenks")
      classes = cut(densities, intervals$brks, include.lowest=TRUE)
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
    reg = rv()$reg
    reg = reg[reg$id==id, ]
    content = as.character(tagList(
      tags$h4("Nb d'ONG:", reg$nb_ong)))
    # TODO: Improve Popup presentation
    leafletProxy("map") %>% 
      addPopups(lng, lat, content, layerId=id)
  }
  
  # When a circleMaker is clicked, show a popup
  observe({
    event = input$map_marker_click
    if (is.null(event))
      return()
    isolate({
      showMarkersPopup(event$id, event$lat, event$lng)
    })
  })
  
}