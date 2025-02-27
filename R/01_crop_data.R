##
#Step 1: Masking ET data to croplands
##
source("./source/main.R")


# --- Step 1: make function ---

crop_nc_data <- function(data_paths, mask_paths, PATH_SAVE, name, long_name, units){
  # Crops NetCDF data by mask files and saves them in the defined directory. 
  # Args:
  #  data_paths: path to the data files. (list)
  #  mask_paths: path to the mask files. (list)
  #  PATH_SAVE: path where to save cropped data. (string)
  #  name: Name of NetCDF data column. (string)
  #  long_name: Long name of data. (string)
  #  units: Units of data. (string)
  # Returns:
  #  Void.
  
  
  # --- Step 2: Loop through different masks and evapotranspiration data files ---
  for(data_path in data_paths){
    for(mask_path in mask_paths){
      
      
      # --- Step 3: Crop the data ---
      
      #Importing nc file
      evap_data <- brick(data_path)
      
      
      
      #cropping nc file  
      evap_data_cropped <- pRecipe::crop_data(evap_data, 
                                              mask_path)
      
      
      # --- Step 4: save the result ---
      
      # Extract mask name
      mask_name <- get_file_name(mask_path)
      # Extract data file name
      data_file_name <- get_file_name(data_path)
      
      
      #Save cropped evap data
      pRecipe::saveNC(
        evap_data_cropped,
        paste0(PATH_SAVE, paste0(data_file_name, "_cropped_", mask_name ,".nc")) ,
        name = name,
        longname = long_name,
        units = units
      )
      
      
      # --- Step 5: Clear RAM memory for next operation ---
      
      # call garbage collector to free unused RAM space
      gc()
    }
  }
  
}

# --- Step 6: define ET variables ---

# Get the gleam data path
data_paths <- list.files(path = PATH_DATA, 
                              full.names = TRUE,
                              pattern = "gleam_e")


# Get the mask path
mask_paths <- list.files(path = PATH_MASK_HILDA_CATEGORY, full.names = TRUE)


name <- "et"
longname <- "Actual Evapotranspiration"
units <- "mm"

# --- Step 7: Call the function with ET parameters ---
crop_nc_data(data_paths, mask_paths, PATH_SAVE, name, longname, units)


# --- Step 8: define precipitation variables ---

# Get the data path
data_paths <- list.files(path = PATH_DATA, 
                              full.names = TRUE,
                              pattern = "mswx")


# Get the mask path
mask_paths <- list.files(path = PATH_MASK_HILDA_CATEGORY, full.names = TRUE)


name <- "precipitation"
longname <- "Precipitation"
units <- "mm"

# --- Step 9: Call the function with precipitation parameters ---
crop_nc_data(data_paths, mask_paths, PATH_SAVE, name, longname, units)




# --- Step 10: define precipitation variables ---

# Get the gleam data path
data_paths <- list.files(path = PATH_DATA, 
                              full.names = TRUE,
                              pattern = "gleam\\S+pet_mm")


# Get the mask path
mask_paths <- list.files(path = PATH_MASK_HILDA_CATEGORY, full.names = TRUE)


name <- "pet"
longname <- "Potential Evapotranspiration"
units <- "mm"

# --- Step 11: Call the function with precipitation parameters ---
crop_nc_data(data_paths, mask_paths, PATH_SAVE, name, longname, units)






# --- Step 12: Clear RAM ---

# Clear session from all objects for memory optimization
rm(list = ls())
