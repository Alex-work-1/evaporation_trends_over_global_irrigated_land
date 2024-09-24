##
#Step 1: Masking ET data to croplands
##

# load libraries

library("sf")
library("raster")
library("pRecipe")

#Add working dir
# setwd("Desktop/evaporation_trend_over_global_irrigated_land")

#Defining path to raw files
path_to_netcdf_file <- "./data/raw/gleam_e_mm_land_198001_202112_025_yearly.nc"
path_to_mask_file <- "./data/mask/croplands/Croplands.shp"

#Importing nc files

gleam_netcdf <- brick(path_to_netcdf_file)

#cropping nc file  
gleam_netcdf_cropped <- pRecipe::crop_data(gleam_netcdf, path_to_mask_file)

# save the cropped data
pRecipe::saveNC(gleam_netcdf_cropped,
                "./data/processed/gleam-v3-8a_e_mm_croplands_198001_202112_025_monthly.nc",
                name = "e", 
                longname = "Actual Evapotranspiration", 
                units = "mm" )
