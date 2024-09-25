#Step 1: Load ET Data ---

source("./source/main.R")

# List all files in the specified directory
evap_data_Full_name <- list.files(path = PATH_DATA, full.names = TRUE)

# Open the NetCDF file containing yearly ET data
evap_data_nc <- nc_open(evap_data_Full_name[2]) 
evap_data <- ncvar_get(evap_data_nc, "e") 
# Assign dimension names to the data array for better readability
dimnames(evap_data)[[3]] <- evap_data_nc$dim$time$vals   # Assign time dimension names
dimnames(evap_data)[[2]] <- evap_data_nc$dim$lat$vals    # Assign latitude dimension names
dimnames(evap_data)[[1]] <- evap_data_nc$dim$lon$vals    # Assign longitude dimension names
nc_close(evap_data_nc)

# --- Step 2: Tidy Up the Data ---
# Convert the evaporation data array into a tidy data.table format using reshape2
evap_data_tidy <- data.table(melt(
  evap_data,
  varnames = c("lon", "lat", "time"),  # Define variable names
  value.name = "evap"                   # Name the value column
))

# --- Step 3: Format the Time Variable ---
# Convert the time variable from numeric to Date format
start_date <- as.Date("1970-01-01")  
#this is the predefined start time in all of nc files that we have in our server
evap_data_tidy[, time := time + start_date]  # Convert numeric time to Date
print(evap_data_tidy)
# --- Step 4: Save the Tidied Data ---
# Save the tidy evaporation data to an RDS file for future use
saveRDS(evap_data_tidy, paste0(PATH_DATA, "gleam_evap_198001_202101.rds"))