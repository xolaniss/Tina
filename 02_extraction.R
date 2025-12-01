# Description

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
library(data.table)
library(tidytable)

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
library(qs2)

# Import ---------------------------------------------------------------
temp_rast <- terra::rast(here("Output", "cropped_masked_temp.tif"))

#Load shape file ---------
shape_file_path <- here("Data", "world-administrative-boundaries", "world-administrative-boundaries.shp")
shape_file <- st_read(dsn = shape_file_path)
shape_file_trans <- st_transform(shape_file, crs(temp_rast))

# temp extraction ----
temp_nc_extraction <- exactextractr::exact_extract(temp_rast, shape_file_trans)
temp_nc_extraction %>% glimpse()

temp_tbl <- 
  temp_nc_extraction %>% 
  bind_rows(.id = "id") %>% 
  tidytable::pivot_longer(cols = -c(id, coverage_fraction), names_to = "time", values_to = "t2m") %>%
  tidytable::separate(time, into = c("time", "seconds"), sep = "=") %>%
  tidytable::mutate(seconds = as.numeric(seconds)) %>%
  tidytable::mutate(date =  lubridate::as_datetime(seconds, "1970-01-01")) %>%
  tidytable::mutate(date = as.Date(date)) %>%
  tidytable::mutate(id = as.numeric(id)) %>%
  tidytable::mutate(t2m = t2m - 273.15)   # changing to Celsius


temp_tbl %>% tail() # check

# join with shape file ----
temp_names_tbl <- 
  shape_file_trans %>%
  tidytable::mutate(id = seq_len(nrow(.))) %>%
  tidytable::left_join(temp_tbl, by = "id") %>%
  tidytable::select(id, date, name, region, coverage_fraction, t2m) |> 
  as_tibble()

# Exporting to CSV ----
qd_save(temp_names_tbl, here("Output", "temp_names_tbl.qs2"))

# read in
temp_names_tbl <- qd_read(here("Output", "temp_names_tbl.qs2"))


## Create a new script to continue the analysis from here

# weighting and averaging ----
# temp_weighted_tbl <- 
  # temp_names_tbl |> 
  # drop_na() |>
  # mutate(weighted_t2m = coverage_fraction*t2m) |> 
  # group_by(date, name) |> 
  # summarise(mean_weighted_t2m = mean(weighted_t2m)) |> 
  # ungroup()



