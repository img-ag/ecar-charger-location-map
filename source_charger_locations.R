require(ggmap)
require(RCurl)
require(dplyr)
require(stringr)

# import population data
cities <- read.csv("city_list_20171231.csv", sep = ";")

# source charger locations from openchargemap api
bin = getURL("https://api.openchargemap.io/v3/poi/?output=csv&countrycode=DE&maxresults=100000")
opencharge <- read.csv(textConnection(bin),
                        sep = ",")

opencharge.small <- select(opencharge, 
                           "UUID",
                           "LocationTitle",
                           "StateOrProvince",
                           "Postcode",
                           "Town",
                           "Latitude",
                           "Longitude",
                           "ConnectionType")


# quickly clean city names
names(opencharge.small)[names(opencharge.small) == "Town"] <-
  "Stadt"
names(cities)[names(cities) == "Plz"] <-
  "Postcode"
cities$Stadt <- str_remove_all(cities$Stadt, ", Landkreis")
cities$Stadt <- str_remove_all(cities$Stadt, ", Stadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", Stadtkreis")
cities$Stadt <- str_remove_all(cities$Stadt, ", Hansestadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", Freie und Hansestadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", St")
cities$Stadt <- str_remove_all(cities$Stadt, ", GKSt")
cities$Stadt <- str_remove_all(cities$Stadt, ", Landeshauptstadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", documenta-Stadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", Schloss-Stadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", Kreisstadt")
cities$Stadt <- str_remove_all(cities$Stadt, ", Krst.")

opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Landkreis")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Stadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Stadtkreis")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Hansestadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Freie und Hansestadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "St")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "GKSt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Landeshauptstadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "documenta-Stadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Schloss-Stadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Kreisstadt")
opencharge.small$Stadt <- str_remove_all(opencharge.small$Stadt, "Krst.")

# merge charger data with population data by
# either city
both <- merge( x = opencharge.small, y = cities, by = "Stadt", all.x = T)

# or postcode, if city value is missing
both1 <- subset(both, is.na(both$Plz)==F)
remaining1 <- subset(both, is.na(both$Plz)==T)
remaining1 <-  select(remaining1, 
                      "UUID",
                      "LocationTitle",
                      "StateOrProvince",
                      "Postcode",
                      "Stadt",
                      "Latitude",
                      "Longitude",
                      "ConnectionType")

both2 <- merge( x = remaining1, y = cities, by = "Postcode", all.x = T)

# remove rows with no valid area data
both2 <- subset(both2, is.na(both2$Fläche_km)==F)

# create final file
both_all <- union_all( x = both1, y = both2)

both_all$Stadt.y <- NULL
both_all$Stadt.x <- NULL

# calculate density of chargers per area and population
both_all$Fläche_km <- str_replace_all(both_all$Fläche_km, ",", ".")
both_all$ConnectionType <- str_replace_all(both_all$ConnectionType, ",", ".")
both_all$Stadt <- str_replace_all(both_all$Stadt, ",", ".")
both_all$StateOrProvince <- str_replace_all(both_all$StateOrProvince, ",", ".")
both_all$LocationTitle <- str_replace_all(both_all$LocationTitle, ",", ".")
both_all$ConnectionType <- str_remove_all(both_all$ConnectionType, ";")

# write final file
write.csv(both_all, "charger_locations_2019-04-29.csv", row.names = F)




