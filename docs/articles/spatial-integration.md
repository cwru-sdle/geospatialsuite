# Spatial Data Integration

------------------------------------------------------------------------

## Introduction

Spatial data integration is essential for combining information from
different sources and scales. The geospatialsuite package provides the
[`universal_spatial_join()`](https://cwru-sdle.github.io/geospatialsuite/reference/universal_spatial_join.md)
function that handles all major spatial data combinations with automatic
method detection and robust error handling.

## Learning Objectives

By the end of this vignette, you will be able to:

- Integrate vector and raster datasets using universal spatial joins
- Extract raster values to point/polygon locations
- Calculate zonal statistics for regions
- Resample and align raster data
- Handle different coordinate systems automatically
- Perform multi-scale spatial operations

## Prerequisites

``` r
# Load required packages
library(geospatialsuite)
library(terra)
library(sf)

# Verify package functionality
test_function_availability()
#> $function_status
#> $function_status$calculate_vegetation_index
#> [1] TRUE
#> 
#> $function_status$calculate_ndvi_enhanced
#> [1] TRUE
#> 
#> $function_status$calculate_water_index
#> [1] TRUE
#> 
#> $function_status$calculate_multiple_indices
#> [1] TRUE
#> 
#> $function_status$create_spatial_map
#> [1] TRUE
#> 
#> $function_status$quick_map
#> [1] TRUE
#> 
#> $function_status$universal_spatial_join
#> [1] TRUE
#> 
#> $function_status$get_region_boundary
#> [1] TRUE
#> 
#> $function_status$load_raster_data
#> [1] TRUE
#> 
#> $function_status$process_vector_data
#> [1] TRUE
#> 
#> 
#> $summary
#> $summary$available
#> [1] 10
#> 
#> $summary$total
#> [1] 10
#> 
#> $summary$missing
#> character(0)
```

## Universal Spatial Join Overview

The
[`universal_spatial_join()`](https://cwru-sdle.github.io/geospatialsuite/reference/universal_spatial_join.md)
function automatically detects data types and selects the appropriate
spatial operation:

- **Vector - Raster**: Extract raster values to points/polygons
- **Raster - Vector**: Calculate zonal statistics
- **Raster - Raster**: Resample, align, or overlay
- **Vector - Vector**: Spatial intersection and overlay

## Basic Spatial Joins

### Vector to Raster Extraction (Most Common)

``` r
# Create sample point data (field sites)
field_sites <- data.frame(
  site_id = paste0("Site_", 1:20),
  lon = runif(20, -83.5, -83.0),
  lat = runif(20, 40.2, 40.7),
  crop_type = sample(c("corn", "soybeans", "wheat"), 20, replace = TRUE)
)

# Create sample raster data (satellite imagery)
satellite_raster <- rast(nrows = 50, ncols = 50, 
                        xmin = -83.5, xmax = -83.0, 
                        ymin = 40.2, ymax = 40.7)
values(satellite_raster) <- runif(2500, 0.2, 0.9)
names(satellite_raster) <- "ndvi"

# Extract raster values to points (automatic method detection)
extracted_results <- universal_spatial_join(
  source_data = field_sites,
  target_data = satellite_raster,
  method = "auto",  # Automatically detects "extract"
  verbose = TRUE
)

# View results - original data plus extracted values
head(extracted_results)
print(names(extracted_results))
```

### Extraction with Buffer

``` r
# Extract values with 100m buffer around each point
buffered_extraction <- universal_spatial_join(
  source_data = field_sites,
  target_data = satellite_raster,
  method = "extract",
  buffer_distance = 0.001,  # ~100m in degrees
  summary_function = "mean",
  verbose = TRUE
)

# Compare point vs buffered extraction
comparison_data <- data.frame(
  site_id = extracted_results$site_id,
  point_extraction = extracted_results$extracted_ndvi,
  buffer_extraction = buffered_extraction$extracted_ndvi
)

# Calculate differences
comparison_data$difference <- abs(comparison_data$point_extraction - 
                                comparison_data$buffer_extraction)
print(summary(comparison_data$difference))
```

## Zonal Statistics

### Raster to Vector Analysis

``` r
# Create sample polygon data (management zones)
management_zones <- data.frame(
  zone_id = 1:5,
  x_center = runif(5, -83.4, -83.1),
  y_center = runif(5, 40.3, 40.6),
  zone_type = sample(c("irrigated", "dryland"), 5, replace = TRUE)
)

# Convert to polygons with buffers
zones_sf <- st_as_sf(management_zones, 
                     coords = c("x_center", "y_center"), 
                     crs = 4326)
zones_polygons <- st_buffer(zones_sf, dist = 0.02)  # ~2km buffer

# Calculate zonal statistics
zonal_results <- universal_spatial_join(
  source_data = satellite_raster,  # Raster first for zonal
  target_data = zones_polygons,    # Polygons second
  method = "zonal",
  summary_function = "mean",
  verbose = TRUE
)

# View zonal statistics
head(zonal_results)
```

### Multiple Summary Functions

``` r
# Calculate multiple statistics for each zone
summary_functions <- c("mean", "median", "max", "min", "sd")

zonal_multi_stats <- list()
for (func in summary_functions) {
  result <- universal_spatial_join(
    source_data = satellite_raster,
    target_data = zones_polygons,
    method = "zonal",
    summary_function = func,
    verbose = FALSE
  )
  
  # Extract the new column
  stat_col <- names(result)[!names(result) %in% names(zones_polygons)]
  zonal_multi_stats[[func]] <- result[[stat_col[1]]]
}

# Combine into summary data frame
zone_summary <- data.frame(
  zone_id = zones_polygons$zone_id,
  zone_type = zones_polygons$zone_type,
  mean_ndvi = zonal_multi_stats$mean,
  median_ndvi = zonal_multi_stats$median,
  max_ndvi = zonal_multi_stats$max,
  min_ndvi = zonal_multi_stats$min,
  sd_ndvi = zonal_multi_stats$sd
)

print(zone_summary)
```

## Raster Operations

### Raster Resampling and Alignment

``` r
# Create rasters with different resolutions
high_res_raster <- rast(nrows = 100, ncols = 100, 
                       xmin = -83.5, xmax = -83.0, 
                       ymin = 40.2, ymax = 40.7)
values(high_res_raster) <- runif(10000, 0.3, 0.8)
names(high_res_raster) <- "detailed_ndvi"

low_res_raster <- rast(nrows = 20, ncols = 20, 
                      xmin = -83.5, xmax = -83.0, 
                      ymin = 40.2, ymax = 40.7)
values(low_res_raster) <- runif(400, 0.1, 0.6)
names(low_res_raster) <- "coarse_data"

# Resample high resolution to match low resolution
resampled_result <- universal_spatial_join(
  source_data = high_res_raster,
  target_data = low_res_raster,
  method = "resample",
  summary_function = "mean",
  verbose = TRUE
)

# Check resolution change
cat("Original resolution:", res(high_res_raster), "\n")
cat("Resampled resolution:", res(resampled_result), "\n")
```

### Scale Factor Operations

``` r
# Aggregate by scale factor (coarser resolution)
aggregated_raster <- universal_spatial_join(
  source_data = high_res_raster,
  target_data = NULL,  # No target needed for scaling
  method = "resample",
  scale_factor = 5,    # 5x coarser resolution
  summary_function = "mean",
  verbose = TRUE
)

# Disaggregate (finer resolution)
disaggregated_raster <- universal_spatial_join(
  source_data = low_res_raster,
  target_data = NULL,
  method = "resample",
  scale_factor = 0.5,  # 2x finer resolution
  verbose = TRUE
)

cat("Original low res:", res(low_res_raster), "\n")
cat("Disaggregated res:", res(disaggregated_raster), "\n")
```

## Vector to Vector Operations

### Spatial Overlay

``` r
# Create county boundaries (simplified)
counties <- data.frame(
  county = c("Franklin", "Delaware", "Union"),
  x_center = c(-83.0, -83.1, -83.3),
  y_center = c(40.0, 40.4, 40.2)
)

counties_sf <- st_as_sf(counties, coords = c("x_center", "y_center"), crs = 4326)
counties_polygons <- st_buffer(counties_sf, dist = 0.15)  # Large county-like areas

# Find which county each field site is in
sites_with_counties <- universal_spatial_join(
  source_data = field_sites,
  target_data = counties_polygons,
  method = "overlay",
  verbose = TRUE
)

# View results
head(sites_with_counties)
```

### Nearest Neighbor Analysis

``` r
# Find nearest weather station for each field site
weather_stations <- data.frame(
  station_id = paste0("WX_", 1:8),
  longitude = runif(8, -83.6, -82.9),
  latitude = runif(8, 40.1, 40.8),
  elevation = runif(8, 200, 400),
  avg_temp = runif(8, 10, 15)
)

nearest_results <- universal_spatial_join(
  source_data = field_sites,
  target_data = weather_stations,
  method = "nearest",
  verbose = TRUE
)

# Check distances to nearest stations
# The function automatically calculates spatial relationships
head(nearest_results)
```

## Advanced Integration Techniques

### Multi-Dataset Integration

``` r
# Integrate multiple datasets to field sites
raster_datasets <- list(
  elevation = rast(nrows = 30, ncols = 30, 
                  xmin = -83.5, xmax = -83.0, 
                  ymin = 40.2, ymax = 40.7),
  temperature = rast(nrows = 30, ncols = 30, 
                    xmin = -83.5, xmax = -83.0, 
                    ymin = 40.2, ymax = 40.7),
  precipitation = rast(nrows = 30, ncols = 30, 
                      xmin = -83.5, xmax = -83.0, 
                      ymin = 40.2, ymax = 40.7)
)

# Add random values
values(raster_datasets$elevation) <- runif(900, 200, 400)
values(raster_datasets$temperature) <- runif(900, 8, 18)
values(raster_datasets$precipitation) <- runif(900, 800, 1200)

# Extract all environmental variables to field sites
environmental_data <- field_sites
for (var_name in names(raster_datasets)) {
  extraction_result <- universal_spatial_join(
    source_data = environmental_data,
    target_data = raster_datasets[[var_name]],
    method = "extract",
    verbose = FALSE
  )
  
  # Add extracted values to main dataset
  new_col <- names(extraction_result)[!names(extraction_result) %in% names(environmental_data)]
  environmental_data[[var_name]] <- extraction_result[[new_col[1]]]
}

# View integrated dataset
head(environmental_data)
```

### Terrain Analysis Integration

``` r
# Create sample DEM
dem_raster <- rast(nrows = 60, ncols = 60, 
                  xmin = -83.5, xmax = -83.0, 
                  ymin = 40.2, ymax = 40.7)
values(dem_raster) <- runif(3600, 200, 500)
names(dem_raster) <- "elevation"

# Use the integrated terrain analysis function
terrain_results <- integrate_terrain_analysis(
  vector_data = field_sites,
  elevation_raster = dem_raster,
  terrain_vars = c("slope", "aspect", "TRI", "TPI"),
  extraction_method = "extract"
)

# View terrain-enhanced field sites
head(terrain_results)
```

## Coordinate Reference System Handling

### Automatic CRS Management

``` r
# Create data in different coordinate systems
utm_points <- data.frame(
  id = 1:10,
  x_utm = runif(10, 300000, 350000),  # UTM coordinates
  y_utm = runif(10, 4450000, 4480000)
)

# Convert to UTM Zone 17N
utm_sf <- st_as_sf(utm_points, coords = c("x_utm", "y_utm"), crs = 32617)

# Our raster is in WGS84 (EPSG:4326)
wgs84_raster <- satellite_raster

# Universal spatial join handles CRS conversion automatically
utm_extraction <- universal_spatial_join(
  source_data = utm_sf,
  target_data = wgs84_raster,
  method = "extract",
  verbose = TRUE  # Shows CRS conversion messages
)

# Check that extraction worked despite different CRS
head(utm_extraction)
```

### Manual CRS Specification

``` r
# Force specific output CRS
projected_result <- universal_spatial_join(
  source_data = field_sites,
  target_data = satellite_raster,
  method = "extract",
  crs_target = 32617,  # UTM Zone 17N
  verbose = TRUE
)

# Check output CRS
st_crs(projected_result)
```

## Handling Missing Data

### NA Strategy Options

``` r
# Create raster with some NA values
sparse_raster <- satellite_raster
values(sparse_raster)[sample(1:ncell(sparse_raster), 500)] <- NA
names(sparse_raster) <- "sparse_data"

# Different strategies for handling NAs
strategies <- c("remove", "nearest", "zero")

na_handling_results <- list()
for (strategy in strategies) {
  result <- universal_spatial_join(
    source_data = field_sites,
    target_data = sparse_raster,
    method = "extract",
    na_strategy = strategy,
    verbose = FALSE
  )
  
  extracted_col <- names(result)[grepl("extracted", names(result))]
  na_handling_results[[strategy]] <- result[[extracted_col[1]]]
}

# Compare different NA handling approaches
na_comparison <- data.frame(
  site_id = field_sites$site_id,
  remove_na = na_handling_results$remove,
  nearest_fill = na_handling_results$nearest,
  zero_fill = na_handling_results$zero
)

# Count NAs in each approach
sapply(na_comparison[-1], function(x) sum(is.na(x)))
```

## Advanced Spatial Operations

### Multi-Scale Analysis

``` r
# Create rasters at different scales
scales <- c(1, 2, 4, 8)  # Different aggregation levels
multi_scale_data <- list()

base_raster <- satellite_raster
for (scale in scales) {
  if (scale == 1) {
    multi_scale_data[[paste0("scale_", scale)]] <- base_raster
  } else {
    aggregated <- universal_spatial_join(
      source_data = base_raster,
      target_data = NULL,
      method = "resample",
      scale_factor = scale,
      summary_function = "mean"
    )
    multi_scale_data[[paste0("scale_", scale)]] <- aggregated
  }
}

# Extract values at different scales
multi_scale_extraction <- field_sites
for (scale_name in names(multi_scale_data)) {
  result <- universal_spatial_join(
    source_data = multi_scale_extraction,
    target_data = multi_scale_data[[scale_name]],
    method = "extract",
    verbose = FALSE
  )
  
  # Add to main dataset
  new_col <- names(result)[!names(result) %in% names(multi_scale_extraction)]
  multi_scale_extraction[[scale_name]] <- result[[new_col[1]]]
}

# Analyze scale effects
scale_columns <- names(multi_scale_extraction)[grepl("scale_", names(multi_scale_extraction))]
scale_analysis <- multi_scale_extraction[c("site_id", scale_columns)]
head(scale_analysis)
```

### Spatial Interpolation Integration

``` r
# Create sparse monitoring data
sparse_monitoring <- data.frame(
  monitor_id = 1:8,
  longitude = runif(8, -83.4, -83.1),
  latitude = runif(8, 40.3, 40.6),
  soil_ph = runif(8, 6.0, 7.5),
  organic_matter = runif(8, 2, 6)
)

# Some missing values
sparse_monitoring$soil_ph[c(2, 5)] <- NA
sparse_monitoring$organic_matter[c(3, 7)] <- NA

# Interpolate missing values
interpolated_data <- spatial_interpolation_comprehensive(
  spatial_data = sparse_monitoring,
  target_variables = c("soil_ph", "organic_matter"),
  method = "NN",  # Nearest neighbor
  verbose = TRUE
)

# Compare before and after interpolation
comparison <- data.frame(
  original_ph = sparse_monitoring$soil_ph,
  interpolated_ph = interpolated_data$soil_ph,
  original_om = sparse_monitoring$organic_matter,
  interpolated_om = interpolated_data$organic_matter
)

print(comparison)
```

## Working with Large Datasets

### Chunked Processing

``` r
# Simulate large point dataset
large_dataset <- data.frame(
  point_id = 1:5000,
  x = runif(5000, -83.5, -83.0),
  y = runif(5000, 40.2, 40.7),
  measurement = runif(5000, 0, 100)
)

# Process in chunks for memory efficiency
chunked_extraction <- universal_spatial_join(
  source_data = large_dataset,
  target_data = satellite_raster,
  method = "extract",
  chunk_size = 1000,  # Process 1000 points at a time
  verbose = TRUE
)

# Check processing efficiency
cat("Processed", nrow(chunked_extraction), "points successfully\n")
```

### Memory-Efficient Raster Operations

``` r
# Create multiple large rasters
raster_list <- list()
for (i in 1:3) {
  r <- rast(nrows = 200, ncols = 200, 
           xmin = -84, xmax = -82, ymin = 40, ymax = 42)
  values(r) <- runif(40000, 0, 1)
  names(r) <- paste0("band_", i)
  raster_list[[i]] <- r
}

# Efficiently combine rasters
combined_raster <- raster_to_raster_ops(
  raster1 = raster_list[[1]],
  raster2 = raster_list[[2]],
  operation = "add",
  handle_na = "ignore",
  verbose = TRUE
)

# Multi-raster operations
mean_composite <- universal_spatial_join(
  source_data = raster_list[[1]],
  target_data = raster_list[[2]],
  method = "resample",
  summary_function = "mean",
  verbose = TRUE
)
```

## Real-World Integration Examples

### Agricultural Field Analysis

``` r
# Simulate complete agricultural analysis workflow
farm_fields <- data.frame(
  field_id = paste0("Field_", LETTERS[1:15]),
  longitude = runif(15, -83.4, -83.1),
  latitude = runif(15, 40.3, 40.6),
  crop_type = sample(c("corn", "soybeans"), 15, replace = TRUE),
  planting_date = as.Date("2023-05-01") + sample(0:20, 15, replace = TRUE)
)

# Convert to polygons (field boundaries)
farm_sf <- st_as_sf(farm_fields, coords = c("longitude", "latitude"), crs = 4326)
field_polygons <- st_buffer(farm_sf, dist = 0.008)  # ~800m field size

# Environmental datasets
environmental_rasters <- list(
  ndvi = satellite_raster,
  elevation = dem_raster,
  soil_moisture = rast(nrows = 40, ncols = 40, 
                      xmin = -83.5, xmax = -83.0, 
                      ymin = 40.2, ymax = 40.7)
)
values(environmental_rasters$soil_moisture) <- runif(1600, 0.1, 0.4)

# Comprehensive field characterization
field_analysis <- farm_fields
for (env_var in names(environmental_rasters)) {
  # Calculate field averages using zonal statistics
  zonal_result <- universal_spatial_join(
    source_data = environmental_rasters[[env_var]],
    target_data = field_polygons,
    method = "zonal",
    summary_function = "mean",
    verbose = FALSE
  )
  
  # Extract the zonal statistic
  stat_col <- names(zonal_result)[grepl("zonal", names(zonal_result))]
  field_analysis[[paste0("avg_", env_var)]] <- zonal_result[[stat_col[1]]]
}

# View comprehensive field analysis
head(field_analysis)
```

### Watershed Analysis

``` r
# Create watershed polygons
watersheds <- data.frame(
  watershed_id = paste0("WS_", 1:6),
  outlet_lon = runif(6, -83.4, -83.1),
  outlet_lat = runif(6, 40.3, 40.6),
  area_km2 = runif(6, 10, 100)
)

watersheds_sf <- st_as_sf(watersheds, coords = c("outlet_lon", "outlet_lat"), crs = 4326)
# Create watershed polygons proportional to area
watersheds_polygons <- st_buffer(watersheds_sf, dist = sqrt(watersheds$area_km2) * 0.002)

# Calculate watershed statistics from multiple sources
watershed_stats <- watersheds
raster_sources <- list(
  mean_elevation = dem_raster,
  mean_ndvi = satellite_raster,
  vegetation_variability = satellite_raster  # Will calculate SD
)

summary_functions <- list(
  mean_elevation = "mean",
  mean_ndvi = "mean", 
  vegetation_variability = "sd"
)

for (var_name in names(raster_sources)) {
  result <- universal_spatial_join(
    source_data = raster_sources[[var_name]],
    target_data = watersheds_polygons,
    method = "zonal",
    summary_function = summary_functions[[var_name]],
    verbose = FALSE
  )
  
  stat_col <- names(result)[grepl("zonal", names(result))]
  watershed_stats[[var_name]] <- result[[stat_col[1]]]
}

print(watershed_stats)
```

## Error Handling and Troubleshooting

### Common Issues and Solutions

``` r
# Handle geometry mismatches gracefully
mismatched_raster <- rast(nrows = 25, ncols = 30,  # Different aspect ratio
                         xmin = -83.6, xmax = -82.9,  # Slightly different extent
                         ymin = 40.1, ymax = 40.8)
values(mismatched_raster) <- runif(750, 0, 1)

# Function automatically handles alignment
robust_extraction <- universal_spatial_join(
  source_data = field_sites,
  target_data = mismatched_raster,
  method = "extract",
  verbose = TRUE  # Shows alignment messages
)

# Handle empty results gracefully
empty_region <- data.frame(
  x = c(-90, -89),  # Far from our data
  y = c(35, 36)
)

empty_sf <- st_as_sf(empty_region, coords = c("x", "y"), crs = 4326)

# This will work but return NA values where appropriate
empty_result <- universal_spatial_join(
  source_data = empty_sf,
  target_data = satellite_raster,
  method = "extract",
  verbose = TRUE
)

print(empty_result)
```

### Performance Monitoring

``` r
# Monitor performance for different data sizes
data_sizes <- c(10, 50, 100, 500)
performance_results <- data.frame(
  n_points = data_sizes,
  processing_time = numeric(length(data_sizes))
)

for (i in seq_along(data_sizes)) {
  n <- data_sizes[i]
  test_points <- data.frame(
    id = 1:n,
    lon = runif(n, -83.4, -83.1),
    lat = runif(n, 40.3, 40.6)
  )
  
  start_time <- Sys.time()
  result <- universal_spatial_join(
    source_data = test_points,
    target_data = satellite_raster,
    method = "extract",
    verbose = FALSE
  )
  end_time <- Sys.time()
  
  performance_results$processing_time[i] <- as.numeric(end_time - start_time)
}

print(performance_results)
```

## Integration with Other Package Functions

### Combining with Vegetation Analysis

``` r
# Extract vegetation indices to management zones
vegetation_stack <- calculate_multiple_indices(
  red = satellite_raster * 0.7,  # Simulate red band
  nir = satellite_raster,
  indices = c("NDVI", "DVI", "RVI"),
  output_stack = TRUE
)

# Extract all vegetation indices to zones
vegetation_by_zone <- universal_spatial_join(
  source_data = zones_polygons,
  target_data = vegetation_stack,
  method = "extract",
  buffer_distance = 0,  # No buffer for polygon extraction
  summary_function = "mean",
  verbose = TRUE
)

# Analyze vegetation patterns by zone type
zone_veg_summary <- aggregate(
  vegetation_by_zone[grepl("extracted", names(vegetation_by_zone))],
  by = list(zone_type = vegetation_by_zone$zone_type),
  FUN = mean,
  na.rm = TRUE
)

print(zone_veg_summary)
```

### Integration with Water Quality

``` r
# Combine water indices with field water quality measurements
water_index_stack <- calculate_multiple_water_indices(
  green = satellite_raster * 0.8,  # Simulate green band
  nir = satellite_raster,
  swir1 = satellite_raster * 0.5,  # Simulate SWIR1
  indices = c("NDWI", "MNDWI", "NDMI"),
  output_stack = TRUE
)

# Extract to water quality monitoring sites
water_sites <- data.frame(
  site_id = paste0("WQ_", 1:12),
  longitude = runif(12, -83.4, -83.1),
  latitude = runif(12, 40.3, 40.6),
  measured_turbidity = runif(12, 5, 25),
  measured_chlorophyll = runif(12, 8, 35)
)

remote_vs_field <- universal_spatial_join(
  source_data = water_sites,
  target_data = water_index_stack,
  method = "extract",
  buffer_distance = 0.002,  # 200m buffer
  summary_function = "mean",
  verbose = TRUE
)

# Analyze relationships between remote sensing and field data
correlations <- cor(
  remote_vs_field[c("measured_turbidity", "measured_chlorophyll")],
  remote_vs_field[grepl("extracted", names(remote_vs_field))],
  use = "complete.obs"
)

print(correlations)
```

## Specialized Integration Functions

### Multi-Scale Operations

``` r
# Use the specialized multi-scale function
multi_scale_analysis <- multiscale_operations(
  spatial_data = satellite_raster,
  target_scales = c(1, 2, 4, 8),
  operation = "mean",
  pyramid = TRUE
)

# Extract at multiple scales to compare spatial patterns
scale_comparison <- field_sites
for (scale_name in names(multi_scale_analysis)) {
  result <- universal_spatial_join(
    source_data = scale_comparison,
    target_data = multi_scale_analysis[[scale_name]],
    method = "extract",
    verbose = FALSE
  )
  
  new_col <- names(result)[!names(result) %in% names(scale_comparison)]
  scale_comparison[[scale_name]] <- result[[new_col[1]]]
}

# Analyze scale effects
scale_vars <- names(scale_comparison)[grepl("scale_", names(scale_comparison))]
scale_effects <- scale_comparison[c("site_id", scale_vars)]
head(scale_effects)
```

### Raster Mathematical Operations

``` r
# Create two related rasters for mathematical operations
raster_a <- satellite_raster
raster_b <- rast(nrows = 50, ncols = 50, 
                xmin = -83.5, xmax = -83.0, 
                ymin = 40.2, ymax = 40.7)
values(raster_b) <- runif(2500, 0.1, 0.7)

# Mathematical operations between rasters
addition_result <- raster_to_raster_ops(
  raster1 = raster_a,
  raster2 = raster_b,
  operation = "add",
  align_method = "resample",
  verbose = TRUE
)

difference_result <- raster_to_raster_ops(
  raster1 = raster_a,
  raster2 = raster_b,
  operation = "subtract",
  handle_na = "ignore",
  verbose = TRUE
)

ratio_result <- raster_to_raster_ops(
  raster1 = raster_a,
  raster2 = raster_b,
  operation = "ratio",
  verbose = TRUE
)

# Extract mathematical results to points
math_results <- universal_spatial_join(
  source_data = field_sites,
  target_data = c(addition_result, difference_result, ratio_result),
  method = "extract",
  verbose = TRUE
)
```

## Visualization of Integration Results

### Mapping Integrated Data

``` r
# Create comprehensive visualization of integrated results
integrated_map <- create_spatial_map(
  spatial_data = environmental_data,
  fill_variable = "elevation",
  color_scheme = "terrain",
  title = "Field Sites with Environmental Data",
  point_size = 5
)

# Quick visualization of zonal results
zonal_map <- create_spatial_map(
  spatial_data = zonal_results,
  fill_variable = names(zonal_results)[grepl("zonal", names(zonal_results))][1],
  map_type = "polygons",
  color_scheme = "viridis",
  title = "Management Zones - Mean NDVI"
)
```

### Comparison Visualizations

``` r
# Compare extraction methods
comparison_data <- data.frame(
  site_id = field_sites$site_id,
  point_extraction = extracted_results$extracted_ndvi,
  buffer_extraction = buffered_extraction$extracted_ndvi,
  difference = abs(extracted_results$extracted_ndvi - buffered_extraction$extracted_ndvi)
)

# Plot comparison
plot(comparison_data$point_extraction, comparison_data$buffer_extraction,
     xlab = "Point Extraction", ylab = "Buffer Extraction",
     main = "Point vs Buffer Extraction Comparison")
abline(0, 1, col = "red", lty = 2)  # 1:1 line
```

## Best Practices

### Data Preparation

``` r
# Always validate inputs before processing
validate_spatial_data <- function(data) {
  if (inherits(data, "sf")) {
    # Check for valid geometries
    invalid_geoms <- !st_is_valid(data)
    if (any(invalid_geoms)) {
      warning(paste("Found", sum(invalid_geoms), "invalid geometries"))
      data <- st_make_valid(data)
    }
  }
  
  if (inherits(data, "SpatRaster")) {
    # Check for data coverage
    valid_cells <- sum(!is.na(values(data, mat = FALSE)))
    total_cells <- ncell(data)
    coverage <- (valid_cells / total_cells) * 100
    
    if (coverage < 10) {
      warning(paste("Low data coverage:", round(coverage, 1), "%"))
    }
  }
  
  return(data)
}

# Use validation in workflows
validated_sites <- validate_spatial_data(
  st_as_sf(field_sites, coords = c("lon", "lat"), crs = 4326)
)
validated_raster <- validate_spatial_data(satellite_raster)
```

### Method Selection Guidelines

``` r
# Guidelines for choosing spatial join methods
method_guide <- data.frame(
  Source_Type = c("Points", "Polygons", "Raster", "Raster", "Points"),
  Target_Type = c("Raster", "Raster", "Polygons", "Raster", "Points"),
  Recommended_Method = c("extract", "extract", "zonal", "resample", "nearest"),
  Use_Case = c("Sample at locations", "Area averages", "Regional stats", "Align data", "Find closest"),
  stringsAsFactors = FALSE
)

print(method_guide)
```

### Performance Optimization

``` r
# Optimize for different scenarios
optimization_tips <- list(
  large_datasets = "Use chunk_size parameter to control memory usage",
  different_crs = "Let the function handle CRS conversion automatically", 
  missing_data = "Choose appropriate na_strategy for your analysis needs",
  multiple_variables = "Process variables separately for better error handling",
  visualization = "Use quick_map() for fast preliminary visualization"
)

for (tip_name in names(optimization_tips)) {
  cat(tip_name, ":", optimization_tips[[tip_name]], "\n")
}
```

## Summary

This vignette demonstrated comprehensive spatial data integration using
geospatialsuite:

1.  **Universal Spatial Joins**: Automatic method detection for any data
    combination
2.  **Vector-Raster Integration**: Extracting values and calculating
    zonal statistics  
3.  **Raster Operations**: Resampling, alignment, and mathematical
    operations
4.  **Multi-Scale Analysis**: Working with data at different resolutions
5.  **Error Handling**: Robust processing with automatic CRS and
    geometry management
6.  **Real-World Applications**: Agricultural and environmental analysis
    examples

### Key Functions Used

- [`universal_spatial_join()`](https://cwru-sdle.github.io/geospatialsuite/reference/universal_spatial_join.md) -
  Core integration function with auto-detection
- [`raster_to_raster_ops()`](https://cwru-sdle.github.io/geospatialsuite/reference/raster_to_raster_ops.md) -
  Mathematical operations between rasters
- [`multiscale_operations()`](https://cwru-sdle.github.io/geospatialsuite/reference/multiscale_operations.md) -
  Multi-scale analysis capabilities
- [`spatial_interpolation_comprehensive()`](https://cwru-sdle.github.io/geospatialsuite/reference/spatial_interpolation_comprehensive.md) -
  Fill missing data spatially
- [`integrate_terrain_analysis()`](https://cwru-sdle.github.io/geospatialsuite/reference/integrate_terrain_analysis.md) -
  Specialized terrain integration

## Acknowledgments

This work was developed by the geospatialsuite team with contributions
from: Olatunde D. Akanbi, Erika I. Barcelos, and Roger H. French.
