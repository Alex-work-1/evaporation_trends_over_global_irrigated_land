##
#Step 2: Converting cropped data to datatable format
##

# load libraries

library("terra")
library("data.table")

#Import cropped ET data 
gleam_rast <- rast("./data/processed/gleam-v3-8a_e_mm_croplands_198001_202112_025_monthly.nc")
gleam_dataframe <- terra::as.data.frame(gleam_rast, 
                                        na.rm = TRUE, 
                                        xy = TRUE, 
                                        time=TRUE)

# convert data to data table format
gleam_datatable <- as.data.table(gleam_dataframe)

# transform all date columns to rows
gleam_datatable <- as.data.table(
  melt(gleam_datatable, id.vars = c("x", "y"))
  )

# change the name of columns to the human readable format
setnames(gleam_datatable, 
         colnames(gleam_datatable), 
         c('Lon','Lat','Date','Evapotranspiration [mm]'))

# convert text date into date object
gleam_datatable[, Date := as.Date(Date, format = "%Y-%m-%d")]


# save the result
saveRDS(gleam_datatable, "data/processed/gleam_e_dt_1980_2021_monthly.rds")
