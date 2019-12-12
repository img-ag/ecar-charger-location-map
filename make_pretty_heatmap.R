library(leaflet)
library(leaflet.extras)

# import previously sourced data
charger_locations <- read.csv("charger_locations_2019-04-29.csv")

# make custom markers
charcharger_icon <- makeIcon(
  iconUrl = "https://image.flaticon.com/icons/svg/1706/1706178.svg",
  iconWidth = 38, iconHeight = 95,
  iconAnchorX = 22, iconAnchorY = 94,
  shadowWidth = 50, shadowHeight = 64,
  shadowAnchorX = 4, shadowAnchorY = 62
)

leaflet(quakes) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
  addWebGLHeatmap(lng=~long, lat=~lat, size = 60000)

# heatmap visualization
leaflet(data = charger_locations) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
  addWebGLHeatmap(lng=~Longitude, lat=~Latitude, size = 20000)

# marker visualization
leaflet(data = charger_locations) %>% addTiles() %>%
  addMarkers(~Longitude , ~Latitude, 
                              popup = ~as.character(LocationTitle), 
                               label = ~as.character(paste(Stadt, ": ",LocationTitle)),
                               icon = charcharger_icon)
