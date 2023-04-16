

library(shiny)
library(leaflet)
library(osmdata)


ui <- fluidPage(
  titlePanel("Northern Lights and Star Chasing Guidance"),
  leafletOutput("map", height = "500px", width = "500px"),
  tags$iframe(src="https://stellarium-web.org/p/observations", width="75%", height="300")
)

server <- function(input, output) {
  
  output$map <- renderLeaflet({
    
    osmdata <- opq(bbox = "Cook County, MN") %>% 
      add_osm_feature(key = "tourism", value = c("camp_site", "viewpoint", "hotel")) %>% 
      osmdata_sf()           
    
    col_pal <- leaflet::colorFactor(palette = "viridis", 
                                    domain = c("camp_site", "viewpoint", "hotel"))  
    
    leaflet(data = filter(osmdata$osm_points, tourism %in% c("camp_site", "viewpoint", "hotel"))) %>%
      addTiles() %>%
      addCircleMarkers(
        color = ~col_pal(tourism), 
        opacity="0.8",
        weight="2",
        radius="2",
        label = ~name,
        labelOptions = labelOptions(
          textOnly = TRUE, 
          direction = "auto",
          fontSize = "26px", 
          fontColor = "black", 
          textShadow = "3px 3px white"
        )) %>%
      addLegend(      
        position = "bottomright",
        title = "Viewpoints, Camp Sites, and Hotels",
        colors = col_pal(c("camp_site", "viewpoint", "hotel")),
        labels = c("Camp Sites", "Lookout Viewpoints", "Hotels")
      )
    
  })
}

shinyApp(ui, server)

