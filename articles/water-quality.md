# Water Quality Assessment

------------------------------------------------------------------------

## Introduction

The geospatialsuite package provides comprehensive tools for water
quality assessment using remote sensing data. This vignette demonstrates
water detection indices, quality parameter monitoring, and basic trend
analysis using the package’s reliable functions.

## Learning Objectives

By the end of this vignette, you will be able to:

- Calculate water detection indices (NDWI, MNDWI, NDMI)
- Analyze water quality parameters from field data
- Detect temporal changes in water conditions
- Create water quality visualizations
- Apply threshold-based classifications

## Prerequisites

``` r
# Load required packages
library(geospatialsuite)
library(terra)
library(sf)

# Check package functionality
test_package_minimal()
#> [1] TRUE
```

## Water Detection Indices

### Basic Water Index Calculation

The package includes multiple water indices for different applications:

``` r
# Load sample bands (Green, NIR, SWIR1)
green_band <- rast(nrows = 100, ncols = 100, 
                   xmin = -84, xmax = -83, ymin = 40, ymax = 41)
values(green_band) <- runif(10000, 0.2, 0.4)

nir_band <- rast(nrows = 100, ncols = 100, 
                 xmin = -84, xmax = -83, ymin = 40, ymax = 41)
values(nir_band) <- runif(10000, 0.4, 0.8)

swir1_band <- rast(nrows = 100, ncols = 100, 
                   xmin = -84, xmax = -83, ymin = 40, ymax = 41)
values(swir1_band) <- runif(10000, 0.1, 0.3)

# Calculate Original NDWI (McFeeters 1996) - Water body detection
ndwi <- calculate_water_index(
  green = green_band,
  nir = nir_band,
  index_type = "NDWI",
  verbose = TRUE
)

# Calculate Modified NDWI (Xu 2006) - Enhanced water detection
mndwi <- calculate_water_index(
  green = green_band,
  nir = nir_band,
  swir1 = swir1_band,
  index_type = "MNDWI",
  verbose = TRUE
)

# Calculate NDMI (Gao 1996) - Vegetation moisture content
ndmi <- calculate_water_index(
  green = green_band,
  nir = nir_band,
  swir1 = swir1_band,
  index_type = "NDMI",
  verbose = TRUE
)
```

### Available Water Indices

See all available water indices and their applications:

``` r
# List all available water indices
water_indices_info <- list_water_indices(detailed = TRUE)
print(water_indices_info)
#>   Index                Type Required_Bands Primary_Application
#> 1  NDWI     Water Detection     Green, NIR     water_detection
#> 2 MNDWI     Water Detection   Green, SWIR1     water_detection
#> 3  NDMI Vegetation Moisture     NIR, SWIR1 moisture_monitoring
#> 4   MSI     Moisture Stress     NIR, SWIR1  drought_assessment
#> 5  NDII Vegetation Moisture     NIR, SWIR1 moisture_monitoring
#> 6    WI       Water Content     NIR, SWIR1 moisture_monitoring
#> 7  SRWI       Water Content     NIR, SWIR1 moisture_monitoring
#> 8  LSWI       Surface Water     NIR, SWIR1     water_detection
#>                                                                           Description
#> 1 Normalized Difference Water Index (McFeeters 1996) - Original water detection index
#> 2 Modified NDWI (Xu 2006) - Enhanced water detection, reduces built-up area confusion
#> 3          Normalized Difference Moisture Index (Gao 1996) - Vegetation water content
#> 4        Moisture Stress Index - Plant water stress detection (lower = more moisture)
#> 5     Normalized Difference Infrared Index - Alternative name for vegetation moisture
#> 6                             Water Index - Simple ratio for water content assessment
#> 7                       Simple Ratio Water Index - Water content using NIR/SWIR ratio
#> 8                         Land Surface Water Index - Surface water content assessment
#>   Value_Range  Water_Threshold          Reference
#> 1     [-1, 1]            > 0.3   McFeeters (1996)
#> 2     [-1, 1]            > 0.5          Xu (2006)
#> 3     [-1, 1] N/A (vegetation)         Gao (1996)
#> 4    [0, 10+]            < 1.0            Various
#> 5     [-1, 1] N/A (vegetation) Hunt & Rock (1989)
#> 6    [0, 10+]            > 1.0            Various
#> 7    [0, 10+]            > 1.0            Various
#> 8     [-1, 1]            > 0.0 Xiao et al. (2002)
#>                             Formula
#> 1     (Green - NIR) / (Green + NIR)
#> 2 (Green - SWIR1) / (Green + SWIR1)
#> 3     (NIR - SWIR1) / (NIR + SWIR1)
#> 4                       SWIR1 / NIR
#> 5     (NIR - SWIR1) / (NIR + SWIR1)
#> 6                       NIR / SWIR1
#> 7                       NIR / SWIR1
#> 8     (NIR - SWIR1) / (NIR + SWIR1)
#>                                      Satellite_Bands
#> 1  Landsat: B3,B5 | Sentinel-2: B3,B8 | MODIS: B4,B2
#> 2 Landsat: B3,B6 | Sentinel-2: B3,B11 | MODIS: B4,B6
#> 3 Landsat: B5,B6 | Sentinel-2: B8,B11 | MODIS: B2,B6
#> 4 Landsat: B5,B6 | Sentinel-2: B8,B11 | MODIS: B2,B6
#> 5 Landsat: B5,B6 | Sentinel-2: B8,B11 | MODIS: B2,B6
#> 6 Landsat: B5,B6 | Sentinel-2: B8,B11 | MODIS: B2,B6
#> 7 Landsat: B5,B6 | Sentinel-2: B8,B11 | MODIS: B2,B6
#> 8 Landsat: B5,B6 | Sentinel-2: B8,B11 | MODIS: B2,B6
#>                                                                            Interpretation
#> 1       Water bodies: >0.3, Vegetation: <0, Built-up: 0-0.2. Sensitive to built-up areas.
#> 2       Water bodies: >0.5, Vegetation: <0, Built-up: <0.3. Better urban water detection.
#> 3        High moisture: >0.4, Moderate: 0.1-0.4, Low: <0.1. For vegetation water content.
#> 4     High moisture: <1.0, Moderate: 1.0-1.6, Stress: >1.6. Lower values = more moisture.
#> 5                  Same as NDMI. High values indicate higher vegetation moisture content.
#> 6 Higher values generally indicate higher water content. Threshold varies by application.
#> 7                                Similar to WI. Used for simple water content assessment.
#> 8  Higher values indicate more surface water. Used for wetland and irrigation monitoring.

# Get indices for specific applications
water_detection <- list_water_indices(application_filter = "water_detection")
moisture_monitoring <- list_water_indices(application_filter = "moisture_monitoring")
```

### Multiple Water Index Calculation

Calculate multiple indices simultaneously for comprehensive analysis:

``` r
# Calculate multiple water indices at once
water_analysis <- calculate_multiple_water_indices(
  green = green_band,
  nir = nir_band,
  swir1 = swir1_band,
  indices = c("NDWI", "MNDWI", "NDMI", "MSI"),
  output_stack = TRUE,
  verbose = TRUE
)

# Access individual indices
ndwi_layer <- water_analysis[["NDWI"]]
mndwi_layer <- water_analysis[["MNDWI"]]
```

## Water Body Analysis

### Comprehensive Water Body Characterization

``` r
# Perform complete water body analysis
water_body_analysis <- analyze_water_bodies(
  green = green_band,
  nir = nir_band,
  swir1 = swir1_band,
  water_threshold_ndwi = 0.3,
  water_threshold_mndwi = 0.5,
  verbose = TRUE
)

# Access results
water_indices <- water_body_analysis$water_indices
water_masks <- water_body_analysis$water_masks
statistics <- water_body_analysis$statistics

# Print water body statistics
print(statistics)
#> $ndwi_water
#> $ndwi_water$water_pixels
#> [1] 0
#> 
#> $ndwi_water$total_pixels
#> [1] 10000
#> 
#> $ndwi_water$water_percentage
#> [1] 0
#> 
#> $ndwi_water$pixel_area_m2
#> [1] 1e-04
#> 
#> $ndwi_water$estimated_water_area_m2
#> [1] 0
#> 
#> 
#> $mndwi_water
#> $mndwi_water$water_pixels
#> [1] 440
#> 
#> $mndwi_water$total_pixels
#> [1] 10000
#> 
#> $mndwi_water$water_percentage
#> [1] 4.4
#> 
#> $mndwi_water$pixel_area_m2
#> [1] 1e-04
#> 
#> $mndwi_water$estimated_water_area_m2
#> [1] 0.044
#> 
#> 
#> $consensus
#> $consensus$water_pixels
#> [1] 0
#> 
#> $consensus$total_pixels
#> [1] 10000
#> 
#> $consensus$water_percentage
#> [1] 0
#> 
#> $consensus$pixel_area_m2
#> [1] 1e-04
#> 
#> $consensus$estimated_water_area_m2
#> [1] 0
```

## Field Water Quality Data Analysis

### Loading and Processing Water Quality Data

``` r
# Create sample water quality monitoring data
sample_water_data <- data.frame(
  station_id = paste0("WQ_", 1:50),
  longitude = runif(50, -84, -83),
  latitude = runif(50, 40, 41),
  temperature = runif(50, 15, 25),
  ph = runif(50, 6.5, 8.5),
  dissolved_oxygen = runif(50, 5, 12),
  turbidity = runif(50, 2, 15),
  nitrate = runif(50, 0.5, 5.0),
  phosphorus = runif(50, 0.1, 2.0),
  sample_date = as.Date("2023-06-01") + sample(0:180, 50, replace = TRUE)
)

# Comprehensive water quality analysis
water_quality_results <- analyze_water_quality_comprehensive(
  water_data = sample_water_data,
  variable = "dissolved_oxygen",
  coord_cols = c("longitude", "latitude"),
  thresholds = list(
    Excellent = c(8, Inf),
    Good = c(6, 8),
    Fair = c(4, 6),
    Poor = c(0, 4)
  ),
  verbose = TRUE
)

# Access analysis results
quality_stats <- water_quality_results$statistics
spatial_patterns <- water_quality_results$spatial_analysis
temporal_trends <- water_quality_results$temporal_analysis
```

### Multi-Parameter Analysis

``` r
# Analyze multiple water quality parameters
parameters <- c("temperature", "ph", "dissolved_oxygen", "turbidity")

multi_param_results <- list()
for (param in parameters) {
  multi_param_results[[param]] <- analyze_water_quality_comprehensive(
    water_data = sample_water_data,
    variable = param,
    verbose = FALSE
  )
}

# Extract key statistics
param_summary <- sapply(parameters, function(p) {
  stats <- multi_param_results[[p]]$statistics$primary_variable
  c(mean = stats$mean, sd = stats$sd, min = stats$min, max = stats$max)
})

print(param_summary)
```

## Visualization

### Water Index Visualization

``` r
# Quick water index mapping
quick_map(ndwi, title = "NDWI - Water Detection")
quick_map(mndwi, title = "MNDWI - Enhanced Water Detection")

# Create water quality map with region boundary
water_map <- create_spatial_map(
  spatial_data = water_quality_results$water_data,
  fill_variable = "dissolved_oxygen",
  region_boundary = c(-84, 40, -83, 41),  # Custom bounding box
  color_scheme = "water",
  title = "Dissolved Oxygen Concentrations",
  point_size = 4
)
```

### Comparison Maps

``` r
# Compare different water indices
comparison_map <- create_comparison_map(
  data1 = ndwi,
  data2 = mndwi,
  comparison_type = "side_by_side",
  titles = c("NDWI (Original)", "MNDWI (Modified)"),
  color_scheme = "water"
)
```

## Threshold Analysis

### Water Quality Classification

``` r
# Apply water quality standards
quality_thresholds <- list(
  Excellent = c(9, Inf),
  Good = c(7, 9),
  Moderate = c(5, 7),
  Poor = c(3, 5),
  Very_Poor = c(0, 3)
)

# Classify water quality
classified_results <- analyze_water_quality_comprehensive(
  water_data = sample_water_data,
  variable = "dissolved_oxygen",
  thresholds = quality_thresholds,
  verbose = TRUE
)

# View classification results
threshold_stats <- classified_results$threshold_analysis$threshold_statistics
print(threshold_stats$category_percentages)
```

### Water Body Detection Thresholds

``` r
# Apply standard water detection thresholds
water_pixels_ndwi <- ndwi > 0.3   # Standard NDWI threshold
water_pixels_mndwi <- mndwi > 0.5  # Standard MNDWI threshold

# Combine for consensus water mask
consensus_water <- water_pixels_ndwi & water_pixels_mndwi
names(consensus_water) <- "consensus_water_mask"

# Visualize water detection
quick_map(consensus_water, title = "Consensus Water Detection")
```

## Temporal Analysis

### Time Series Water Quality Monitoring

``` r
# Create temporal water quality data
temporal_data <- data.frame(
  station_id = rep(paste0("WQ_", 1:10), each = 12),
  longitude = rep(runif(10, -84, -83), each = 12),
  latitude = rep(runif(10, 40, 41), each = 12),
  month = rep(1:12, 10),
  dissolved_oxygen = runif(120, 4, 12),
  temperature = runif(120, 5, 25),
  sample_date = rep(seq(as.Date("2023-01-01"), 
                       as.Date("2023-12-01"), by = "month"), 10)
)

# Analyze temporal patterns
temporal_results <- analyze_water_quality_comprehensive(
  water_data = temporal_data,
  variable = "dissolved_oxygen",
  date_column = "sample_date",
  station_id_col = "station_id",
  verbose = TRUE
)

# Check for temporal trends
if (!is.null(temporal_results$temporal_analysis$trend)) {
  trend_info <- temporal_results$temporal_analysis$trend
  cat("Temporal trend slope:", trend_info$slope, "\n")
  cat("Significance (p-value):", trend_info$p_value, "\n")
  cat("R-squared:", trend_info$r_squared, "\n")
}
```

## Real-World Applications

### Lake Water Quality Assessment

``` r
# Simulate lake monitoring scenario
lake_stations <- data.frame(
  station = paste0("Lake_", LETTERS[1:20]),
  lon = runif(20, -83.5, -83.0),
  lat = runif(20, 40.2, 40.7),
  depth_m = runif(20, 1, 15),
  temp_celsius = runif(20, 18, 24),
  ph = runif(20, 7.0, 8.5),
  do_mg_l = runif(20, 6, 11),
  chlorophyll_ug_l = runif(20, 5, 25),
  secchi_depth_m = runif(20, 1, 4)
)

# Comprehensive lake analysis
lake_analysis <- analyze_water_quality_comprehensive(
  water_data = lake_stations,
  variable = "do_mg_l",
  coord_cols = c("lon", "lat"),
  thresholds = list(
    Hypoxic = c(0, 2),
    Low = c(2, 5),
    Adequate = c(5, 8),
    High = c(8, Inf)
  )
)

# Analyze chlorophyll patterns
chlorophyll_analysis <- analyze_water_quality_comprehensive(
  water_data = lake_stations,
  variable = "chlorophyll_ug_l",
  thresholds = list(
    Oligotrophic = c(0, 4),
    Mesotrophic = c(4, 10),
    Eutrophic = c(10, Inf)
  )
)
```

### Stream Network Integration

``` r
# Analyze water quality along stream network
stream_monitoring <- data.frame(
  site_id = paste0("Stream_", 1:30),
  longitude = runif(30, -83.8, -83.2),
  latitude = runif(30, 40.1, 40.8),
  stream_order = sample(1:4, 30, replace = TRUE),
  flow_cms = runif(30, 0.1, 50),
  water_temp = runif(30, 12, 22),
  conductivity = runif(30, 200, 800),
  total_nitrogen = runif(30, 0.5, 8.0),
  total_phosphorus = runif(30, 0.05, 1.5)
)

# Analyze nutrient patterns
nitrogen_analysis <- analyze_water_quality_comprehensive(
  water_data = stream_monitoring,
  variable = "total_nitrogen",
  thresholds = list(
    Low = c(0, 2),
    Moderate = c(2, 5),
    High = c(5, Inf)
  ),
  verbose = TRUE
)

phosphorus_analysis <- analyze_water_quality_comprehensive(
  water_data = stream_monitoring,
  variable = "total_phosphorus",
  thresholds = list(
    Low = c(0, 0.3),
    Moderate = c(0.3, 0.8),
    High = c(0.8, Inf)
  )
)
```

## Error Handling and Troubleshooting

### Common Issues and Solutions

``` r
# Handle missing coordinate data
incomplete_data <- sample_water_data
incomplete_data$latitude[1:5] <- NA

# The function automatically handles missing coordinates
robust_results <- analyze_water_quality_comprehensive(
  water_data = incomplete_data,
  variable = "dissolved_oxygen",
  verbose = TRUE
)

# Handle different coordinate column names
alt_coord_data <- sample_water_data
names(alt_coord_data)[names(alt_coord_data) == "longitude"] <- "x"
names(alt_coord_data)[names(alt_coord_data) == "latitude"] <- "y"

# Function auto-detects coordinate columns
auto_detect_results <- analyze_water_quality_comprehensive(
  water_data = alt_coord_data,
  variable = "ph",
  verbose = TRUE
)
```

### Data Quality Checks

``` r
# Apply quality filters during analysis
filtered_analysis <- analyze_water_quality_comprehensive(
  water_data = sample_water_data,
  variable = "turbidity",
  quality_filters = list(
    valid_range = c(0, 100),  # Reasonable turbidity range
    remove_outliers = TRUE,
    remove_na = TRUE
  ),
  verbose = TRUE
)
```

## Integration with Other Package Functions

### Combining Water Indices with Vegetation Analysis

``` r
# Calculate both water and vegetation indices from the same data
# Assume we have a multi-band satellite image
red_band <- nir_band * 0.6  # Simulate red band

# Water detection
water_indices <- calculate_multiple_water_indices(
  green = green_band,
  nir = nir_band,
  swir1 = swir1_band,
  indices = c("NDWI", "MNDWI", "NDMI")
)

# Vegetation analysis
veg_indices <- calculate_multiple_indices(
  red = red_band,
  nir = nir_band,
  green = green_band,
  indices = c("NDVI", "GNDVI", "DVI"),
  output_stack = TRUE
)

# Create combined analysis
combined_stack <- c(water_indices, veg_indices)
names(combined_stack) <- c("NDWI", "MNDWI", "NDMI", "NDVI", "GNDVI", "DVI")
```

### Spatial Integration with Field Data

``` r
# Extract satellite-derived water indices to field monitoring points
extracted_values <- universal_spatial_join(
  source_data = sample_water_data,
  target_data = water_indices,
  method = "extract",
  buffer_distance = 100,  # 100m buffer around each point
  summary_function = "mean"
)

# Check correlations between field measurements and remote sensing
field_vs_remote <- data.frame(
  field_turbidity = extracted_values$turbidity,
  remote_ndwi = extracted_values$extracted_NDWI,
  remote_mndwi = extracted_values$extracted_MNDWI
)

# Calculate correlations
cor(field_vs_remote, use = "complete.obs")
```

## Best Practices

### Index Selection Guidelines

- **NDWI**: Use for general water body detection, especially clear water
- **MNDWI**: Better for urban areas and turbid water detection
- **NDMI**: Focus on vegetation moisture content and drought monitoring
- **MSI**: Detect plant water stress (lower values = higher moisture)

### Threshold Recommendations

``` r
# Standard water detection thresholds
standard_thresholds <- list(
  NDWI = list(water = 0.3, vegetation = 0.0),
  MNDWI = list(water = 0.5, built_up = 0.0),
  NDMI = list(high_moisture = 0.4, low_moisture = 0.1)
)

# Apply thresholds to create binary water masks
water_mask_ndwi <- ndwi > standard_thresholds$NDWI$water
water_mask_mndwi <- mndwi > standard_thresholds$MNDWI$water
```

### Quality Control

``` r
# Always mask invalid values and apply reasonable ranges
quality_controlled_ndwi <- calculate_water_index(
  green = green_band,
  nir = nir_band,
  index_type = "NDWI",
  clamp_range = c(-1, 1),
  mask_invalid = TRUE,
  verbose = TRUE
)

# Check data coverage
values_ndwi <- values(quality_controlled_ndwi, mat = FALSE)
coverage_percent <- (sum(!is.na(values_ndwi)) / length(values_ndwi)) * 100
cat("Data coverage:", round(coverage_percent, 1), "%\n")
```

## Summary

This vignette demonstrated:

1.  **Water Detection Indices**: NDWI, MNDWI, NDMI calculation and
    interpretation
2.  **Field Data Analysis**: Comprehensive water quality parameter
    assessment
3.  **Threshold Classification**: Application of water quality standards
4.  **Temporal Analysis**: Trend detection in water quality time series
5.  **Visualization**: Creating effective water quality maps
6.  **Integration**: Combining remote sensing and field data

### Key Functions Used

- [`calculate_water_index()`](https://cwru-sdle.github.io/geospatialsuite/reference/calculate_water_index.md) -
  Single water index calculation
- [`calculate_multiple_water_indices()`](https://cwru-sdle.github.io/geospatialsuite/reference/calculate_multiple_water_indices.md) -
  Multiple indices at once
- [`analyze_water_bodies()`](https://cwru-sdle.github.io/geospatialsuite/reference/analyze_water_bodies.md) -
  Comprehensive water body analysis
- [`analyze_water_quality_comprehensive()`](https://cwru-sdle.github.io/geospatialsuite/reference/analyze_water_quality_comprehensive.md) -
  Field data analysis
- [`list_water_indices()`](https://cwru-sdle.github.io/geospatialsuite/reference/list_water_indices.md) -
  Available indices information
- [`universal_spatial_join()`](https://cwru-sdle.github.io/geospatialsuite/reference/universal_spatial_join.md) -
  Spatial data integration
- [`create_spatial_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/create_spatial_map.md)
  and
  [`quick_map()`](https://cwru-sdle.github.io/geospatialsuite/reference/quick_map.md) -
  Visualization

## Acknowledgments

This work was developed by the geospatialsuite team with contributions
from: Olatunde D. Akanbi, Vibha Mandayam, Yinghui Wu, Jeffrey Yarus,
Erika I. Barcelos, and Roger H. French.
