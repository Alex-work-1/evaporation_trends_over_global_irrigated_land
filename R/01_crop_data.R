##
#Step 1: Masking ET data to croplands
##
source("./source/main.R")



# --- Step 1: Load paths ---

# Get the gleam data path
evap_data_paths <- list.files(path = PATH_DATA, 
                             full.names = TRUE)


# Get the mask path
mask_paths <- list.files(path = PATH_MASK_HILDA_CATEGORY, full.names = TRUE)


# --- Step 2: Loop through different masks and evapotranspiration data files ---
for(evap_data_path in evap_data_paths){
  for(mask_path in mask_paths){
    
    
    # --- Step 3: Crop the data ---
    
    #Importing nc file
    evap_data <- brick(evap_data_path)
    
    
    
    #cropping nc file  
    evap_data_cropped <- pRecipe::crop_data(evap_data, 
                                            mask_path)
    
    
    # --- Step 4: save the result ---
    
    # Extract mask name
    mask_name <- get_file_name(mask_path)
    # Extract data file name
    data_file_name <- get_file_name(evap_data_path)
    
    
    #Save cropped evap data
    pRecipe::saveNC(
      evap_data_cropped,
      paste0(PATH_SAVE, paste0(data_file_name, "_cropped_", mask_name ,".nc")) ,
      name = "e",
      longname = "Actual Evapotranspiration",
      units = "mm"
    )
    
    
    # --- Step 5: Clear RAM memory for next operation ---
    
    # call garbage collector to free unused RAM space
    gc()
  }
}
