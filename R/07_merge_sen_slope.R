##
#Step 7: Merge layers for simplification and optimization
##


source("./source/main.R")



# --- Step 1: make functions ---


vector_merge <- function(layer_paths, save_dir, file_name,  
                         extension = ".shp"){
  # Merges list of vector layers together and saves the layer in the specified 
  # directory.
  # Args:
  #  layer_paths: path to the layers to merge (list of strings)
  #  save_dir: Directory of output result. (string)
  #  file_name: Name of the output file. (string)
  #  extension: Extension of the output file. (string)
  # Returns:
  #  Void.
  merged_layer <- st_read(layer_paths[1])
  
  for(layer_path in layer_paths[-1]){
    to_be_merged_layer <- st_read(layer_path)
    
    merged_layer <- rbind(merged_layer, to_be_merged_layer)
  }
  
  st_write(merged_layer, paste0(save_dir, file_name, extension))
  
}




raster_merge <- function(layer_paths, save_dir, file_name,  
                         extension = ".tif"){
  # Merges list of raster layers together and saves the layer in the specified 
  # directory.
  # Args:
  #  layer_paths: path to the layers to merge (list of strings)
  #  save_dir: Directory of output result. (string)
  #  file_name: Name of the output file. (string)
  #  extension: Extension of the output file. (string)
  # Returns:
  #  Void.
  merged_layer <- raster(layer_paths[1])
  
  for(layer_path in layer_paths[-1]){
    to_be_merged_layer <- raster(layer_path)
    
    merged_layer <- merge(merged_layer, to_be_merged_layer)
  }
  
  writeRaster(merged_layer, paste0(save_dir, file_name, extension), format="GTiff")
  
}


# --- Step 2: Make Oceania continent ---
# Define variables
# path to continents directory
continents_path <- "data/masks/continent-poly/"
# save directory
save_dir <- continents_path

# layer path list to merge
layer_paths <- list(paste0(continents_path, "Oceania.shp"), 
                    paste0(continents_path, "Australia.shp"))

# output file name
file_name <- "Oceania_merged"

# --- join Oceania and Australia ---
# call the function
vector_merge(layer_paths, save_dir, file_name)





# --- Step 3: Merge ET significant points and data layers

# define variables to ET points of significant change ---

# output directory save
save_dir <- paste0(PATH_SAVE, "merged_layers/")


# list of files to merge
layer_paths <- list.files(path = "data/processed/sen_slope/1980 - 2019/", 
                          full.names = TRUE, 
                          pattern = "sen_slope\\S+.shp") #select all files which contain _cropped_ and end with .rds


# output file name save
file_name <- "merged_ET_sen_slope"

# merge ET points of significant change ---
vector_merge(layer_paths, save_dir, file_name)




# update the list of ET change layers ---
layer_paths <- list.files(path = "data/processed/sen_slope/1980 - 2019/", 
                          full.names = TRUE, 
                          pattern = "sen_slope\\S+.tif") #select all files which contain _cropped_ and end with .rds



# merge ET change layers ---

raster_merge(layer_paths, save_dir, file_name)



# --- Step 3: Merge PET significant points and data layers

# define variables to PET points of significant change ---

# output directory save
save_dir <- paste0(PATH_SAVE, "merged_layers/")


# list of files to merge
layer_paths <- list.files(path = "data/processed/sen_slope_pet/1980 - 2019/", 
                          full.names = TRUE, 
                          pattern = "sen_slope_pet\\S+.shp") #select all files which contain _cropped_ and end with .rds


# output file name save
file_name <- "merged_PET_sen_slope"

# merge PET points of significant change ---
vector_merge(layer_paths, save_dir, file_name)




# update the list of PET change layers ---
layer_paths <- list.files(path = "data/processed/sen_slope_pet/1980 - 2019/", 
                          full.names = TRUE, 
                          pattern = "sen_slope_pet\\S+.tif") #select all files which contain _cropped_ and end with .rds



# merge PET change layers ---
raster_merge(layer_paths, save_dir, file_name)





# --- Step 4: Merge precipitation significant points and data layers

# define variables to precipitation points of significant change ---

# output directory save
save_dir <- paste0(PATH_SAVE, "merged_layers/")


# list of files to merge
layer_paths <- list.files(path = "data/processed/sen_slope_precip/1980 - 2019/", 
                          full.names = TRUE, 
                          pattern = "sen_slope_precip\\S+.shp") #select all files which contain _cropped_ and end with .rds


# output file name save
file_name <- "merged_precip_sen_slope"

# merge precipitation points of significant change ---
vector_merge(layer_paths, save_dir, file_name)




# update the list of precipitation change layers ---
layer_paths <- list.files(path = "data/processed/sen_slope_precip/1980 - 2019/", 
                          full.names = TRUE, 
                          pattern = "sen_slope_precip\\S+.tif") #select all files which contain _cropped_ and end with .rds



# merge precipitation change layers ---
raster_merge(layer_paths, save_dir, file_name)



# --- Step 5: Clear RAM ---


# Clear session from all objects for memory optimization
rm(list = ls())





