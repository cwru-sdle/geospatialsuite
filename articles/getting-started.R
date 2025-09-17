## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6,
  warning = FALSE,
  message = FALSE
)

## ----eval=FALSE---------------------------------------------------------------
# # Install from source
# # install.packages("geospatialsuite")
# 
# 
# # Load the package
# library(geospatialsuite)

## ----echo=FALSE---------------------------------------------------------------
# For vignette building - adjust as needed
library(terra)
library(sf)
library(ggplot2)
library(dplyr)

## ----eval=FALSE---------------------------------------------------------------
# # Core packages (required)
# library(terra)    # Raster operations and plotting
# library(sf)       # Vector operations
# library(ggplot2)  # Static mapping
# library(dplyr)    # Data manipulation
# 
# # Optional packages (for enhanced features)
# library(leaflet)      # Interactive mapping
# library(viridis)      # Enhanced color schemes
# library(RColorBrewer) # Additional color palettes

## ----eval=FALSE---------------------------------------------------------------
# # One-line mapping - auto-detects data type and creates appropriate map
# quick_map("mydata.shp")
# quick_map("satellite_image.tif")
# quick_map(my_spatial_data, interactive = TRUE)

## ----eval=FALSE---------------------------------------------------------------
# # US States
# ohio_boundary <- get_region_boundary("Ohio")
# california_boundary <- get_region_boundary("California")
# 
# # Countries
# nigeria_boundary <- get_region_boundary("Nigeria")
# brazil_boundary <- get_region_boundary("Brazil")
# 
# # Continental US
# conus_boundary <- get_region_boundary("CONUS")
# 
# # Custom bounding box
# custom_area <- get_region_boundary(c(-84.5, 39.0, -82.0, 41.0))
# 
# # State and county
# franklin_county <- get_region_boundary("Ohio:Franklin")

## ----eval=FALSE---------------------------------------------------------------
# # Basic NDVI calculation
# ndvi <- calculate_vegetation_index(
#   red = "red_band.tif",
#   nir = "nir_band.tif",
#   index_type = "NDVI"
# )
# 
# # Enhanced NDVI with quality filtering
# ndvi_enhanced <- calculate_ndvi_enhanced(
#   red_data = red_raster,
#   nir_data = nir_raster,
#   quality_filter = TRUE,
#   clamp_range = c(-0.2, 1)
# )
# 
# # Multiple vegetation indices
# vegetation_indices <- calculate_multiple_indices(
#   red = red_band,
#   nir = nir_band,
#   blue = blue_band,
#   indices = c("NDVI", "EVI", "SAVI", "GNDVI"),
#   output_stack = TRUE
# )

## ----eval=FALSE---------------------------------------------------------------
# # Water detection indices
# ndwi <- calculate_water_index(
#   green = green_band,
#   nir = nir_band,
#   index_type = "NDWI"
# )
# 
# # Enhanced water detection
# mndwi <- calculate_water_index(
#   green = green_band,
#   swir1 = swir1_band,
#   index_type = "MNDWI"
# )
# 
# # Comprehensive water analysis
# water_analysis <- analyze_water_bodies(
#   green = "green.tif",
#   nir = "nir.tif",
#   swir1 = "swir1.tif",
#   region_boundary = "Ohio"
# )

## ----eval=FALSE---------------------------------------------------------------
# # Get crop codes
# corn_codes <- get_comprehensive_cdl_codes("corn")
# grain_codes <- get_comprehensive_cdl_codes("grains")
# 
# # Create crop mask
# corn_mask <- create_crop_mask(
#   cdl_data = "cdl_2023.tif",
#   crop_codes = corn_codes,
#   region_boundary = "Iowa"
# )
# 
# # Analyze crop areas
# crop_analysis <- analyze_cdl_crops_dynamic(
#   cdl_data = "cdl_2023.tif",
#   crop_selection = "soybeans",
#   region_boundary = "Ohio",
#   analysis_type = "area"
# )
# 
# # Access results
# total_area_hectares <- crop_analysis$total_area_ha
# total_area_acres <- total_area_hectares * 2.47105

## ----eval=FALSE---------------------------------------------------------------
# # Extract raster values to points - most common use case
# field_data <- universal_spatial_join(
#   source_data = "field_sites.csv",      # CSV with coordinates
#   target_data = "satellite_image.tif",  # Any raster
#   method = "extract",
#   buffer_distance = 100,                # 100m buffer around points
#   summary_function = "mean"
# )
# 
# # Zonal statistics for polygons
# watershed_stats <- universal_spatial_join(
#   source_data = "precipitation.tif",    # Raster data
#   target_data = "watersheds.shp",       # Polygon boundaries
#   method = "zonal",
#   summary_function = "mean"
# )
# 
# # Resample raster to different resolution
# resampled <- universal_spatial_join(
#   source_data = "fine_resolution.tif",
#   target_data = "coarse_template.tif",
#   method = "resample"
# )

## ----eval=FALSE---------------------------------------------------------------
# # Simple raster plotting
# terra::plot(ndvi_raster, main = "NDVI Analysis",
#             col = colorRampPalette(c("brown", "yellow", "green"))(100))
# 
# # RGB composite
# plot_rgb_raster(
#   raster_data = satellite_data,
#   r = 4, g = 3, b = 2,           # False color composite
#   stretch = "hist",
#   title = "False Color Composite"
# )
# 
# # Custom NDVI visualization
# create_spatial_map(
#   spatial_data = ndvi_raster,
#   color_scheme = "ndvi",
#   region_boundary = "Ohio",
#   title = "Ohio NDVI Analysis"
# )

## ----eval=FALSE---------------------------------------------------------------
# # Interactive point map
# interactive_map <- create_interactive_map(
#   spatial_data = monitoring_stations,
#   fill_variable = "water_quality",
#   basemap = "terrain",
#   title = "Water Quality Monitoring"
# )
# 
# # Interactive with custom popup
# leaflet_map <- create_spatial_map(
#   spatial_data = crop_data,
#   fill_variable = "yield",
#   interactive = TRUE,
#   title = "Crop Yield Distribution"
# )

## ----eval=FALSE---------------------------------------------------------------
# # Automatic CRS fixing
# result <- calculate_vegetation_index(
#   red = red_band,
#   nir = nir_band,
#   auto_crs_fix = TRUE,  # Automatically handle CRS differences
#   verbose = TRUE        # See what's happening
# )

## ----eval=FALSE---------------------------------------------------------------
# # Handle missing values
# interpolated <- spatial_interpolation_comprehensive(
#   spatial_data = sparse_data,
#   target_variables = "temperature",
#   method = "NN",               # Nearest neighbor for gaps
#   na_strategy = "nearest"      # Strategy for NAs
# )

## ----eval=FALSE---------------------------------------------------------------
# # Process large datasets efficiently
# result <- universal_spatial_join(
#   source_data = large_points,
#   target_data = large_raster,
#   method = "extract",
#   chunk_size = 500000,    # Smaller chunks for memory
#   parallel = FALSE        # Disable parallel for stability
# )

## ----eval=FALSE---------------------------------------------------------------
# # Test package functionality
# test_results <- test_geospatialsuite_package_simple(verbose = TRUE)
# 
# # Quick diagnostic
# quick_diagnostic()
# 
# # Check function availability
# function_status <- test_function_availability(verbose = TRUE)

## ----eval=FALSE---------------------------------------------------------------
# # Load raster data
# rasters <- load_raster_data("/path/to/raster/files/")
# single_raster <- load_raster_data("satellite_image.tif")
# 
# # Load with region boundary
# ohio_rasters <- load_raster_data(
#   "/path/to/files/",
#   pattern = "\\.(tif|tiff)$"
# )
# 
# # Date extraction from filenames
# dates <- extract_dates_universal(
#   c("ndvi_2023-05-15.tif", "ndvi_2023-06-15.tif")
# )

## ----eval=FALSE---------------------------------------------------------------
# # Automatic CRS handling
# vegetation_indices <- calculate_multiple_indices(
#   spectral_data = "/path/to/bands/",   # Mixed CRS files
#   indices = c("NDVI", "EVI", "SAVI"),
#   auto_detect_bands = TRUE,
#   auto_crs_fix = TRUE,                 # Fix CRS mismatches
#   region_boundary = "Michigan"
# )

## ----eval=FALSE---------------------------------------------------------------
# # Package documentation
# help(package = "geospatialsuite")
# 
# # Function help
# ?calculate_vegetation_index
# ?universal_spatial_join
# ?quick_map
# 
# # List available vegetation indices
# list_vegetation_indices(detailed = TRUE)
# 
# # List available water indices
# list_water_indices(detailed = TRUE)
# 
# # Test package installation
# test_geospatialsuite_package_simple()

## ----eval=FALSE---------------------------------------------------------------
# # Complete example: Analyze crop vegetation in Ohio
# library(geospatialsuite)
# 
# # 1. Calculate vegetation indices
# vegetation <- calculate_multiple_indices(
#   red = "landsat_red.tif",
#   nir = "landsat_nir.tif",
#   blue = "landsat_blue.tif",
#   indices = c("NDVI", "EVI", "SAVI"),
#   region_boundary = "Ohio",
#   output_stack = TRUE
# )
# 
# # 2. Create crop mask
# crop_mask <- create_crop_mask(
#   cdl_data = "cdl_ohio_2023.tif",
#   crop_codes = get_comprehensive_cdl_codes("corn"),
#   region_boundary = "Ohio"
# )
# 
# # 3. Apply crop mask to vegetation data
# crop_vegetation <- terra::mask(vegetation, crop_mask)
# 
# # 4. Create visualization
# quick_map(crop_vegetation$NDVI, title = "Ohio Corn NDVI")
# 
# # 5. Calculate statistics
# crop_stats <- terra::global(crop_vegetation, "mean", na.rm = TRUE)
# print(crop_stats)
# 
# # 6. Save results
# terra::writeRaster(crop_vegetation, "ohio_corn_vegetation.tif")

