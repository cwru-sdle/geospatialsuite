## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6,
  warning = FALSE,
  message = FALSE,
  eval = TRUE
)

## ----installation, eval=FALSE-------------------------------------------------
# # Install from CRAN
# install.packages("geospatialsuite")

## ----load-library-------------------------------------------------------------
# Load the package
library(geospatialsuite)
library(terra)

## ----quick-start--------------------------------------------------------------
library(geospatialsuite)
library(terra)

# List available sample datasets
list_sample_datasets()

# Load sample raster data
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")

# Calculate NDVI
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")

# Visualize
plot(ndvi, main = "NDVI from Sample Data", col = terrain.colors(100))

## ----calculate-indices--------------------------------------------------------
# Load sample spectral bands
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")
blue <- load_sample_data("sample_blue.rds")

# Calculate NDVI
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
plot(ndvi, main = "NDVI")

# Calculate EVI (requires blue band)
evi <- calculate_vegetation_index(red = red, nir = nir, blue = blue, index_type = "EVI")
plot(evi, main = "EVI")

# Calculate multiple indices at once
indices <- calculate_multiple_indices(
  red = red,
  nir = nir,
  blue = blue,
  indices = c("NDVI", "EVI", "SAVI"),
  output_stack = TRUE
)

# Plot all indices
plot(indices)

## ----multiband-data-----------------------------------------------------------
# Load multi-band sample raster
multiband <- load_sample_data("sample_multiband.rds")

# Check band names
names(multiband)

# Auto-detect bands and calculate index
ndvi_auto <- calculate_vegetation_index(
  spectral_data = multiband,
  index_type = "NDVI",
  auto_detect_bands = TRUE
)

## ----spatial-operations-------------------------------------------------------
# Load sample vector data
points <- load_sample_data("sample_points.rds")
boundary <- load_sample_data("sample_boundary.rds")

# Calculate NDVI
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")

# Extract raster values to points
points_with_values <- universal_spatial_join(
  source_data = points,
  target_data = ndvi,
  method = "extract"
)

# Check result
head(points_with_values)

## ----visualization------------------------------------------------------------
# Load sample data
points <- load_sample_data("sample_points.rds")

# Quick map (auto-detects everything)
quick_map(points, variable = "ndvi", title = "NDVI at Sample Sites")

## ----list-datasets------------------------------------------------------------
# List all available datasets
datasets <- list_sample_datasets()
print(datasets[, c("filename", "type", "description")])

## ----load-single-tif, eval=FALSE----------------------------------------------
# # Use geospatialsuite's load_raster_data() function
# # It provides robust error handling and validation
# 
# # Load a single .tif file
# my_raster <- load_raster_data("path/to/your/ndvi.tif")
# 
# # Result is a list, extract the raster
# ndvi_raster <- my_raster[[1]]
# 
# # Now use with geospatialsuite functions
# # The raster is ready for analysis
# summary(ndvi_raster)

## ----load-multiple-tif, eval=FALSE--------------------------------------------
# # Load multiple Landsat bands with geospatialsuite
# # Handles validation automatically
# 
# landsat_files <- c(
#   "LC08_B4_red.tif",
#   "LC08_B5_nir.tif",
#   "LC08_B3_green.tif"
# )
# 
# # geospatialsuite loads them with error checking
# bands <- load_raster_data(landsat_files, verbose = TRUE)
# 
# # Extract individual bands
# red_band <- bands[[1]]
# nir_band <- bands[[2]]
# green_band <- bands[[3]]
# 
# # Calculate indices using geospatialsuite
# ndvi <- calculate_vegetation_index(
#   red = red_band,
#   nir = nir_band,
#   index_type = "NDVI"
# )
# 
# gndvi <- calculate_vegetation_index(
#   green = green_band,
#   nir = nir_band,
#   index_type = "GNDVI"
# )

## ----load-directory, eval=FALSE-----------------------------------------------
# # geospatialsuite can load all rasters from a directory
# # Perfect for batch processing
# 
# # Load all .tif files from Landsat directory
# all_bands <- load_raster_data(
#   "/path/to/landsat/imagery/",
#   pattern = "\\.(tif|tiff)$",
#   verbose = TRUE
# )
# 
# # geospatialsuite finds, loads, and validates all files
# # Returns a list of SpatRaster objects ready to use
# cat("Loaded", length(all_bands), "raster files\n")

## ----landsat-workflow, eval=FALSE---------------------------------------------
# # Complete workflow using geospatialsuite functions
# 
# library(geospatialsuite)
# 
# # 1. Load Landsat bands using geospatialsuite
# landsat_bands <- load_raster_data(
#   "landsat/LC08_L2SP_021033_20240715/",
#   pattern = "SR_B[2-5].TIF$",
#   verbose = TRUE
# )
# 
# # geospatialsuite loaded them with validation
# # Extract bands (scaled values 0-1 after Collection 2 scaling)
# blue <- landsat_bands[[1]]   # After scaling
# green <- landsat_bands[[2]]
# red <- landsat_bands[[3]]
# nir <- landsat_bands[[4]]
# 
# # 2. Calculate vegetation indices using geospatialsuite
# # The package has 60+ pre-programmed indices
# veg_indices <- calculate_multiple_indices(
#   red = red,
#   nir = nir,
#   blue = blue,
#   green = green,
#   indices = c("NDVI", "EVI", "SAVI", "GNDVI"),
#   output_stack = TRUE
# )
# 
# # 3. Visualize using geospatialsuite
# quick_map(veg_indices$NDVI, title = "Landsat 8 NDVI - July 15, 2024")

## ----load-shapefile, eval=FALSE-----------------------------------------------
# # Load shapefile with sf (standard approach)
# library(sf)
# field_boundaries <- sf::st_read("data/farm_fields.shp")
# 
# # Then use with geospatialsuite's spatial functions
# # Calculate NDVI first
# ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
# 
# # Extract NDVI to field boundaries using geospatialsuite
# fields_with_ndvi <- universal_spatial_join(
#   source_data = field_boundaries,
#   target_data = ndvi,
#   method = "extract"
# )
# 
# # geospatialsuite handles CRS mismatches automatically
# # Returns field boundaries with extracted NDVI statistics
# head(fields_with_ndvi)

## ----load-geopackage, eval=FALSE----------------------------------------------
# # Load GeoPackage (modern format, better than shapefile)
# farm_data <- sf::st_read("farm_management.gpkg", layer = "fields")
# sample_points <- sf::st_read("farm_management.gpkg", layer = "samples")
# 
# # Use geospatialsuite's spatial join
# samples_with_indices <- universal_spatial_join(
#   source_data = sample_points,
#   target_data = veg_indices,
#   method = "extract",
#   buffer_distance = 30  # 30m buffer
# )
# 
# # geospatialsuite extracted all indices in the stack
# # Each index becomes a column in the result
# names(samples_with_indices)

## ----multiband-auto, eval=FALSE-----------------------------------------------
# # geospatialsuite's auto-detection feature
# 
# # Load a stacked multi-band GeoTIFF
# multiband_raster <- load_raster_data("sentinel2_stack.tif")[[1]]
# 
# # Name the bands (Sentinel-2 example)
# names(multiband_raster) <- c("blue", "green", "red", "nir", "swir1")
# 
# # Use geospatialsuite's auto-detection
# # It finds the right bands automatically!
# indices <- calculate_multiple_indices(
#   spectral_data = multiband_raster,
#   indices = c("NDVI", "EVI", "MNDWI"),
#   auto_detect_bands = TRUE,  # This is geospatialsuite's feature!
#   output_stack = TRUE
# )
# 
# # No need to specify which band is which
# # geospatialsuite figured it out!

## ----complete-workflow, eval=FALSE--------------------------------------------
# # End-to-end agricultural monitoring with geospatialsuite
# 
# library(geospatialsuite)
# library(sf)
# 
# # 1. Load satellite imagery using geospatialsuite
# spectral_bands <- load_raster_data(
#   "/path/to/satellite/bands/",
#   pattern = "B[0-9].tif$",
#   verbose = TRUE
# )
# 
# # 2. Extract bands
# red <- spectral_bands[[3]]
# nir <- spectral_bands[[4]]
# green <- spectral_bands[[2]]
# 
# # 3. Calculate indices using geospatialsuite
# crop_health <- calculate_multiple_indices(
#   red = red,
#   nir = nir,
#   green = green,
#   indices = c("NDVI", "GNDVI", "SAVI"),
#   output_stack = TRUE
# )
# 
# # 4. Load field data
# fields <- sf::st_read("farm_data/fields.shp")
# 
# # 5. Extract to fields using geospatialsuite
# fields_analysis <- universal_spatial_join(
#   source_data = fields,
#   target_data = crop_health,
#   method = "extract"
# )
# 
# # 6. Visualize using geospatialsuite
# quick_map(fields_analysis,
#           variable = "NDVI",
#           title = "Field Health Assessment")
# 
# # geospatialsuite handled:
# # - Loading multiple files
# # - Calculating indices
# # - Spatial extraction with CRS handling
# # - Visualization

## ----list-indices-------------------------------------------------------------
# See all vegetation indices geospatialsuite provides
veg_indices <- list_vegetation_indices()
head(veg_indices[, c("Index", "Category", "Description")])

# See water indices
water_indices <- list_water_indices()
head(water_indices)

## ----help, eval=FALSE---------------------------------------------------------
# # Package documentation
# help(package = "geospatialsuite")
# 
# # Function help
# ?calculate_vegetation_index
# ?load_raster_data
# ?universal_spatial_join
# ?quick_map

## ----test-package-------------------------------------------------------------
# Test package installation
test_geospatialsuite_package_simple()

