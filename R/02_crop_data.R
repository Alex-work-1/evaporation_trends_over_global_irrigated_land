##
#Step 2: Masking ET data to croplands
##
source("./source/main.R")

# List all files in the specified directory
evap_data_Full_name <- list.files(path = PATH_DATA, full.names = TRUE)

#Importing nc file
evap_data <- brick(evap_data_Full_name[2])

#Importing mask
mask <- shapefile("data/geo_data/mask.shp")

#cropping nc file  
evap_data_cropped <- pRecipe::crop_data(evap_data, mask)

#Save cropped evap data
pRecipe::saveNC(
  evap_data_cropped,
  paste0(PATH_SAVE, "gleam-v3-8a_e_mm_croplands_198001_20211_025_yearly.nc") ,
  name = "e",
  longname = "Actual Evapotranspiration",
  units = "mm"
)
