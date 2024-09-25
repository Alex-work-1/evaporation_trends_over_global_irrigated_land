## packages
# generic
library(data.table)
library(plyr)
library(dplyr)
library(lubridate)
library(reshape2)
library(pRecipe)

# plotting
library(ggplot2)
library(ggpubr)

# geospatial
library(raster)
library(ncdf4)
library(sp)
library(sf)
library(stars)

## Paths
PATH_DATA <- 'data/raw/'
PATH_SAVE <- 'data/processed/'
PATH_RESULTS <- 'results/figures/'
PATH_GEO <- 'data/geo_data/'
## Datasets
EVAP_GLOBAL_DATASETS <- "gleam" # write now we are focusing on gleam data

## Constants
# Time
PERIOD_START <- as.Date("1980-01-01")
PERIOD_END <- as.Date("2019-12-31")

## Variable names
EVAP_NAME <- "evap"

EVAP_NAME_SHORT <- "e"
