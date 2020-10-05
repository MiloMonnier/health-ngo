library(shiny)
library(leaflet)
library(sf)
library(stringr)
library(classInt)
library(RColorBrewer)
library(dplyr)
library(DT)


function(input, output, session) {
  
  # Initialize the reactive values: everytime the user will change an input$,
  # this block will be run. Other blocks observe({...}) will get the updated data
  # through a rv()$... function.
  rv = reactive({
    # Filter the ONGs and LINKs working in input sectors
    if (!is.null(input$sectors)) {
      patterns = paste(input$sectors, collapse="|")
      ong = ong[str_detect(ong$dom, patterns), ]
      link = link[link$ong %in% ong$id, ]
    }
    # Join the number of ONGs per region
    aggOngByReg = aggregate(link$ong, by=list(link$reg), length)
    colnames(aggOngByReg) = c("id", "nb_ong")
    reg$nb_ong = aggOngByReg$nb_ong[match(reg$id, aggOngByReg$id)]
    reg = reg[!is.na(reg$nb_ong), ]
    # Join the regions codes to ONGs, alphabetically sorted, separeted by commas
    aggRegByOng = aggregate(link$reg, by=list(link$ong), FUN=function(x) paste(sort(x), collapse=", "))
    colnames(aggRegByOng) = c("id", "regions")
    ong$regions = aggRegByOng$regions[match(ong$id, aggRegByOng$id)]
    
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
  
  # On the static leaflet map previously created, map the data
  # Incremental changes to the map use should be performed in an observer
  observe({
    
    # Get back reactive values
    ong = rv()$ong
    link = rv()$link
    reg = rv()$reg
    
    # Take static map and, every time input$ or dat() changes, clear polygons, markers
    # and legend. Add also senegalese external border with a thicker contour
    map = leafletProxy("map", data=reg) %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearControls() %>%
      clearPopups() %>%
      addPolylines(data=sen, color="black", weight=4)
    
    # If 1 row of ONG table is clicked, highlight the regions where ONG is located
    if (!is.null(input$table_rows_selected)) {
      ongID = ong[input$table_rows_selected, "id"]
      regIDS = link[link$ong==ongID, "reg"]
      selectedReg = reg[reg$id %in% regIDS, ]
      map %>% 
        addPolygons(data=selectedReg, color="red", weight=2, opacity=0.5,
                  fillColor="red", fillOpacity=0.3)  %>%
        addLegend("bottomleft", colors="red", opacity=0.3,
                  labels="Régions d'intervention")
      
    # If circles, add circles proportionnal to the nb of NGOs in each region
    } else if (input$maptype=="circles") {
      label = paste(reg$lib, ":", reg$nb_ong)
      ciclesRadius = reg$nb_ong / 3 * input$size # Allow user to set circles size
      map %>%
        addPolygons(color="black", weight=2, opacity=0.5,
                    fillColor="blue", fillOpacity=0.05,
                    label=label) %>%
        addCircleMarkers(~lng, ~lat, layerId=~id, 
                         radius=ciclesRadius, color="red", weight=1, opacity=0.5,
                         fillColor="red", fillOpacity=0.3,
                         label=label)
    
    # Else, display a choropleth map, discretized with Jenks algorithm, + legend
    } else if (input$maptype=="density") {
      densities = reg$nb_ong / reg$area_km2
      # densities = round(reg$nb_ong / reg$area_km2, 3)
      nclass = 5
      intervals = classIntervals(densities, nclass, style="jenks")
      classes = cut(densities, intervals$brks, include.lowest=TRUE)
      colors = brewer.pal(nclass, "YlOrRd")
      col = colors[classes]
      label = paste(reg$lib, ":", densities, "/km²")
      map %>%
        addPolygons(layerId=~id,
                    color="black", weight=2, opacity=0.3,
                    fillColor=col, fillOpacity=0.5,
                    label=label) %>%
        addLegend("bottomleft", title="Nombre d'ONG/km²",
                  colors=rev(colors),  labels=rev(levels(classes)))
    }
  })
  
  
  # Show popup at given location when clicking on a marker 
  showMarkersPopup = function(id, lat, lng) {
    reg = rv()$reg
    reg = reg[reg$id==id, ]
    content = as.character(tagList(
      tags$h4("Nb d'ONG:", reg$nb_ong)))
    # TODO: Improve Popup presentation
    leafletProxy("map") %>% 
      clearPopups() %>%
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
  
  
  
  ## RIGHT: DATA EXPLORER ######################################################
  
  # Display the NGOs table and filter it according to input 
  output$table = DT::renderDataTable({
    ong = rv()$ong
    df = ong
    DT::datatable(df, selection='single', rownames=FALSE)
  })

}