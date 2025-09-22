# Description
# data prep - Xolani Sibande 2025
# Preliminaries -----------------------------------------------------------
# core
library(tidyverse)
library(readr)
library(readxl)
library(here)
library(lubridate)
library(xts)
library(broom)
library(glue)
library(scales)
library(kableExtra)
library(pins)
library(timetk)
library(uniqtag)
library(quantmod)
library(qs2)
library(sf)
library(stars)
library(terra)

# graphs
library(PNWColors)
library(patchwork)

# eda
library(psych)
library(DataExplorer)
library(skimr)

# econometrics
library(tseries)
library(strucchange)
library(vars)
library(urca)
library(mFilter)
library(car)

# Parallel processing
library(furrr)
library(parallel)
library(tictoc)

# Functions ---------------------------------------------------------------


#Temperature--------------------------------------
# load nc file
temp <- here("Data", "2mtemp.nc")
temp_rast <- terra::rast(temp)

#Load shape file -----
shape_file_path <- here("Data", "world-administrative-boundaries", "world-administrative-boundaries.shp")
shape_file <- st_read(dsn = shape_file_path)
shape_file_trans <- st_transform(shape_file, crs(temp_rast))

#Crop and mask data ----
temp_rast_cropped <- crop(temp_rast, shape_file_trans)
temp_rast_final <- mask(temp_rast_cropped, shape_file_trans)


writeRaster(temp_rast_final, here("Output", "cropped_masked_temp.tif"))

