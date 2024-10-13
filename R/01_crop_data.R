##
#Step 1: Masking ET data to croplands
##
source("./source/main.R")



# --- Step 1: Load paths ---

# Get the gleam data path
evap_data_path <- paste0(PATH_DATA, GLEAM_EVAP_YEARLY)


# Get the mask path
mask_paths <- list.files(path = PATH_MASK_HILDA_CATEGORY, full.names = TRUE)


# --- Step 2: Loop through different masks ---

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
  
  #Save cropped evap data
  pRecipe::saveNC(
    evap_data_cropped,
    paste0(PATH_SAVE, paste0("gleam_e_yearly_cropped_", mask_name ,".nc")) ,
    name = "e",
    longname = "Actual Evapotranspiration",
    units = "mm"
  )
  
  
  # --- Step 5: Clear RAM memory for next operation ---
  
  # call garbage collector to free unused RAM space
  gc()
}
