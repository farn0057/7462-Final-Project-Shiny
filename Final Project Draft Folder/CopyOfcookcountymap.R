
library(tidyverse)
library(gt)
library(paletteer)
library(plotly)
library(flexdashboard)
library(tidycensus)
library(osmdata)
library(plotly)
library(ggplot2)
library(sf)
library(ggmap)
library(leaflet)
library(tigris)
library(viridis, quietly = TRUE)
library(leaflet.minicharts)



### Cooky County MN Lookout spots and Campsites/Hotels


osmdata <- opq(bbox = "Cook County, MN") %>%  #defining bbox for MN FOR OSMDATA
  add_osm_feature(key = "tourism", value = c("camp_site", "viewpoint", "hotel")) %>%  
  osmdata_sf()           
col_pal <- leaflet::colorFactor(palette = "viridis", #making a color palette  
                                domain = c("camp_site", "viewpoint", "hotel"))  #defining #different colors for values
#making leaflet
leaflet(data = filter(osmdata$osm_points, tourism %in% c("camp_site",  "viewpoint", "hotel"))) %>%
  addTiles() %>%
  addCircleMarkers(   #adding markers and defining options and labels
    color = ~col_pal(tourism), 
    opacity="0.8",
    weight="2",
    radius="2",
    label = ~name,
    labelOptions = labelOptions(textOnly = TRUE, direction = "auto")
  ) %>%
  addLegend(      #creating a legend
    position = "bottomright",
    title = "Cook County Lookout Viewpoints, Camp Sites, and Hotels",
    colors = col_pal(c("camp_site", "viewpoint", "hotel")),
    labels = c("Camp Sites", "Lookout Viewpoints", "Hotels")
  )

