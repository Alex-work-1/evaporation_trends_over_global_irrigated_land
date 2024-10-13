#Step 2: Format ET Data ---

source("./source/main.R")


# --- Step 1: Get the data paths ---

# Get the gleam data path
evap_data_paths <- list.files(path = PATH_SAVE, 
                              full.names = TRUE, 
                              pattern = "_cropped_")


# --- Step 2:Loop through each data path ---

for(evap_data_path in evap_data_paths){
  
  # --- Step 3: Load the data into RAM ---
  
  
  # Open the NetCDF file containing yearly ET data
  evap_data_nc <- nc_open(evap_data_path) 
  evap_data <- ncvar_get(evap_data_nc, "e") 
  
  # Assign dimension names to the data array for better readability
  dimnames(evap_data)[[3]] <- evap_data_nc$dim$time$vals   # Assign time dimension names
  dimnames(evap_data)[[2]] <- evap_data_nc$dim$lat$vals    # Assign latitude dimension names
  dimnames(evap_data)[[1]] <- evap_data_nc$dim$lon$vals    # Assign longitude dimension names
  nc_close(evap_data_nc)
  
  # --- Step 4: Tidy Up the Data ---
  # Convert the evaporation data array into a tidy data.table format using reshape2
  evap_data_tidy <- data.table(melt(
    evap_data,
    varnames = c("lon", "lat", "Date"),  # Define variable names
    value.name = "evap"                   # Name the value column
  ))
  
  # --- Step 5: Format the Time Variable ---
  # Convert the time variable from numeric to Date format
  start_date <- as.Date("1970-01-01")  
  #this is the predefined start date in all of nc files that we have in our server
  evap_data_tidy[, Date := Date + start_date]  # Convert numeric date to Date format
  
  # --- Step 6: Save the Tidied Data ---
  # Get the file name without extension
  evap_data_file_name <- get_file_name(evap_data_path)
  
  # Save the tidy evaporation data to an RDS file for future use
  saveRDS(evap_data_tidy, 
          paste0(PATH_SAVE, paste0(evap_data_file_name, ".rds"))
          )
  
  
  # --- Step 7: Remove the old, not formatted data ---
  file.remove(evap_data_path)
  
  # --- Step 8: Free the unused RAM space ---
  # call garbage collector to free unused RAM space
  gc()
}

