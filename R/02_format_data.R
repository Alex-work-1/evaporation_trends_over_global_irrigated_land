#Step 2: Format ET Data ---

source("./source/main.R")


# --- Step 1: make function ---

format_data <- function(data_paths, name, value_column, PATH_SAVE) {
  # Converts NetCDF data to data table compatible format and saves them 
  # in the defined directory. 
  # Args:
  #  data_paths: path to the data files. (list)
  #  name: Name of NetCDF data column. (string)
  #  value_column: Desired name of data table data column. (string)
  #  PATH_SAVE: path where to save processed data. (string)
  # Returns:
  #  Void.
  
  
  # --- Step 2:Loop through each data path ---
  for (data_path in data_paths) {
    # --- Step 3: Load the data into RAM ---
    
    
    # Open the NetCDF file containing ET data
    data_nc <- nc_open(data_path)
    data <- ncvar_get(data_nc, name)
    
    # Assign dimension names to the data array for better readability
    dimnames(data)[[3]] <- data_nc$dim$time$vals   # Assign time dimension names
    dimnames(data)[[2]] <- data_nc$dim$lat$vals    # Assign latitude dimension names
    dimnames(data)[[1]] <- data_nc$dim$lon$vals    # Assign longitude dimension names
    nc_close(data_nc)
    
    # --- Step 4: Tidy Up the Data ---
    # Convert the evaporation data array into a tidy data.table format using reshape2
    data_t_tidy <- data.table(melt(
      data,
      varnames = c("lon", "lat", "Date"),
      # Define variable names
      value.name = value_column                   # Name the value column
    ))
    
    # --- Step 5: Format the Time Variable ---
    # Convert the time variable from numeric to Date format
    start_date <- as.Date("1970-01-01")
    #this is the predefined start date in all of nc files that we have in our server
    data_t_tidy[, Date := Date + start_date]  # Convert numeric date to Date format
    
    # --- Step 6: Save the Tidied Data ---
    # Get the file name without extension
    data_t_file_name <- get_file_name(data_path)
    
    # Save the tidy evaporation data to an RDS file for future use
    saveRDS(data_t_tidy, paste0(PATH_SAVE, paste0(data_t_file_name, ".rds")))
    
    
    # --- Step 7: Remove the old, not formatted data ---
    file.remove(data_path)
    
    # --- Step 8: Free the unused RAM space ---
    # call garbage collector to free unused RAM space
    gc()
  }
  
}

# --- Step 9: define ET variables ---

# Get the gleam data path
data_paths <- list.files(path = PATH_SAVE, 
                         full.names = TRUE, 
                         pattern = "gleam_e\\S+_cropped_")

# name of NetCDF variable
name <- "et"

# name of data table column
value_column <- "ET"

# --- Step 10: Call the function with ET parameters ---

format_data(data_paths, name, value_column, PATH_SAVE)





# --- Step 11: define precipitation variables ---

# Get the gleam data path
data_paths <- list.files(path = PATH_SAVE, 
                         full.names = TRUE, 
                         pattern = "mswx\\S+_cropped_")

# name of NetCDF variable
name <- "precipitation"

# name of data table column
value_column <- "Precipitation"

# --- Step 12: Call the function with precipitation parameters ---

format_data(data_paths, name, value_column, PATH_SAVE)




# --- Step 13: define PET variables ---

# Get the gleam data path
data_paths <- list.files(path = PATH_SAVE, 
                         full.names = TRUE, 
                         pattern = "gleam\\S+pet_mm\\S+_cropped_")

# name of NetCDF variable
name <- "pet"

# name of data table column
value_column <- "PET"

# --- Step 14: Call the function with precipitation parameters ---

format_data(data_paths, name, value_column, PATH_SAVE)



# --- Step 15: Clear RAM ---

# Clear session from all objects for memory optimization
rm(list = ls())