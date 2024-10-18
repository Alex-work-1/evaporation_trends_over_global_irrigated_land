## packages
# generic
library(data.table)
library(plyr)
library(dplyr)
library(lubridate)
library(reshape2)
library(pRecipe)
library(tools)
library(stringr)

# plotting
library(ggplot2)
library(ggpubr)

# geospatial
library(raster)
library(ncdf4)
library(sp)
library(sf)
library(stars)

## Folder Paths
PATH_DATA <- 'data/raw/'
PATH_SAVE <- 'data/processed/'
PATH_RESULTS <- 'results/figures/'
PATH_GEO <- 'data/geo_data/'
PATH_MASK <- 'data/masks/'
PATH_MASK_HILDA_CATEGORY <- 'data/masks/hilda_categories/'

## Data Files
GLEAM_EVAP_YEARLY <- "gleam_e_mm_land_198001_202112_025_yearly.nc"
GLEAM_EVAP_MONTHLY <- "gleam_e_mm_land_198001_202112_025_monthly.nc"

## Mask Files
HILDA_C1 <- "hilda_C1.gpkg"
HILDA_C2 <- "hilda_C2.gpkg"
HILDA_C3 <- "hilda_C3.gpkg"

## Datasets
EVAP_GLOBAL_DATASETS <- "gleam" 

## Constants
# Time
PERIOD_START <- as.Date("1980-01-01")
PERIOD_END <- as.Date("2019-12-31")

## Variable names
EVAP_NAME <- "evap"

EVAP_NAME_SHORT <- "e"




## Functions

get_file_name <- function(file_path, ext=TRUE){
  # Extracts file name from the file path with or without extension.
  # Args:
  #  file_path: path to the file. (string)
  #  ext: should it leave extension or not. (boolean)
  # Returns:
  #  File name string.
  
  # get name with extension
  name <- basename(file_path)
  
  # If true - remove extension
  if(ext){
    name <- file_path_sans_ext(name)
  }
  
  return(name)
}

