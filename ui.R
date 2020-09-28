library(leaflet)

bootstrapPage(
  
  tags$style(type="text/css", "html, body {width:100%;height:100%}"),
  
  # If not using custom CSS, set height of leafletOutput to a number instead of percent
  leafletOutput("map", width = "100%", height = "100%")
  
)