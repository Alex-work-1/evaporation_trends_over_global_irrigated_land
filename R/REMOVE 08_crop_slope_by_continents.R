##
#Step 8: Crop data layers by continents
##

source("./source/main.R")


# --- Step 1: define functions ---
crop_save_raster <- function(crop_raster_path, crop_by_path, save_file_path){
  crop_raster <- raster(crop_raster_path)
  crop_by <- st_read(crop_by_path)
  croped_raster <- raster::crop(crop_raster, crop_by)
  
  writeRaster(croped_raster,
              filename=paste0(save_file_path,
                              ".tif"),
              format="GTiff", overwrite=TRUE)
  }

crop_save_vector <- function(crop_vector_path, crop_by_path, save_file_path){
  crop_vector <- st_read(crop_vector_path)
  crop_by <- st_read(crop_by_path)
  croped_vector <- st_crop(crop_vector, st_bbox(crop_by, crs=4326))
  
  st_write(croped_vector, paste0(save_file_path, ".shp"))
  
}

# --- Step 1: define common variables ---

continents_path <- "data/masks/continent-poly/"
oceania_path <- paste0(continents_path, "Oceania_merged", ".shp")
input_dir <- paste0(PATH_SAVE, "merged_layers/")
save_dir <- "data/processed/cropped_by_continent/"



crop_name <- "merged_precip_sen_slope"
crop_by_path <- paste0(continents_path, "Africa.shp")
crop_raster_path <- paste0(input_dir,
                           crop_name,
                           ".tif")
save_file_path <- paste0(save_dir, "Africa_precip")

crop_save_raster(crop_raster_path, crop_by_path, save_file_path)

crop_vector_path <- paste0(input_dir,
                           crop_name,
                           ".shp")
crop_save_vector(crop_vector_path, crop_by_path, save_file_path)





# --- Step 5: Clear RAM ---


# Clear session from all objects for memory optimization
# rm(list = ls())



# 
# continent <- "Africa"
# 





#data/masks/continent-poly/    Africa.shp Asia.shp Europe.shp North America.shp Oceania_merged.shp South America.shp
#"data/processed/merged_layers/merged_ET_sen_slope.dbf"
# "data/layers/world_map.gpkg"


#st_layers("sac.gpkg")
#sac_test <- st_read("sac.gpkg",
# layer = "special_areas_conservation")


# # layer <- st_layers(system.file("gpkg/nc.gpkg", package = "sf"))$name[1]





# merged_precip_sen_slope.tif
# # Read in the Shapefile
# shapefile <- st_read("path/to/shapefile.shp")
# 
# # Read in the GeoTIFF
# raster_file <- raster("path/to/geotiff.tif")
# 
# # Perform spatial intersection (without bounding box)
# intersection <- st_intersection(shapefile, raster_file)
# 
# # Extract the cropped GeoTIFF
# cropped_raster <- extract(raster_file, intersection)
# 
# # Write the cropped GeoTIFF to a new file
# writeRaster(cropped_raster, "path/to/cropped_geotiff.tif", format="GTiff")

