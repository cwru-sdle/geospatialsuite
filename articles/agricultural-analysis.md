# Agricultural Applications with geospatialsuite

------------------------------------------------------------------------

## Agricultural Applications with geospatialsuite

This vignette demonstrates comprehensive agricultural analysis
capabilities including USDA CDL integration, crop monitoring, stress
detection, and yield assessment workflows.

### Enhanced NDVI Analysis for Agriculture

#### Time Series NDVI Monitoring

Use enhanced NDVI calculation for multi-temporal crop monitoring:

``` r
# Enhanced NDVI with quality filtering
ndvi_enhanced <- calculate_ndvi_enhanced(
  red_data = red_band,
  nir_data = nir_band,
  quality_filter = TRUE,
  temporal_smoothing = FALSE,  # Single date
  verbose = TRUE
)

# Visualize enhanced NDVI
create_ndvi_map(
  ndvi_data = ndvi_enhanced,
  title = "Enhanced NDVI with Quality Filtering",
  ndvi_classes = "none"
)

print("Enhanced NDVI Analysis:")
ndvi_values <- terra::values(ndvi_enhanced, mat = FALSE)
valid_ndvi <- ndvi_values[!is.na(ndvi_values)]
print(paste("Mean NDVI:", round(mean(valid_ndvi), 3)))
print(paste("NDVI range:", paste(round(range(valid_ndvi), 3), collapse = " - ")))
```

#### Multi-Index Crop Assessment

Calculate multiple vegetation indices for comprehensive crop assessment:

``` r
# Calculate multiple indices relevant to agriculture
agricultural_indices <- calculate_multiple_indices(
  red = red_band,
  nir = nir_band,
  indices = c("NDVI", "SAVI", "MSAVI", "DVI", "RVI"),
  output_stack = TRUE,
  verbose = TRUE
)

print("Agricultural Indices Calculated:")
print(names(agricultural_indices))

# Visualize key indices
if (terra::nlyr(agricultural_indices) >= 2) {
  # NDVI visualization
  create_spatial_map(
    spatial_data = agricultural_indices[[1]],
    title = "NDVI for Agricultural Assessment",
    color_scheme = "ndvi"
  )
  
  # SAVI visualization (soil-adjusted)
  if ("SAVI" %in% names(agricultural_indices)) {
    plot_raster_fast(
      agricultural_indices[["SAVI"]],
      title = "SAVI (Soil Adjusted Vegetation Index)",
      color_scheme = "viridis"
    )
  }
}
```

### Yield Prediction Support

#### Yield Potential Assessment

Assess yield potential using vegetation indices:

``` r
# Extract yield analysis if available
if (!is.null(crop_analysis$analysis_results$yield_analysis)) {
  yield_results <- crop_analysis$analysis_results$yield_analysis
  
  print("Yield Potential Analysis:")
  if (!"error" %in% names(yield_results)) {
    print(paste("Composite yield index:", round(yield_results$composite_yield_index, 3)))
    print(paste("Yield potential class:", yield_results$yield_potential_class))
    print(paste("Classification confidence:", round(yield_results$classification_confidence, 3)))
    
    print("Index contributions to yield assessment:")
    for (idx in names(yield_results$index_contributions)) {
      contrib <- yield_results$index_contributions[[idx]]
      print(paste("  ", idx, "- Normalized:", round(contrib$mean_normalized, 3),
                  "Raw mean:", round(contrib$raw_mean, 3)))
    }
  }
}

# Create yield potential map visualization
yield_potential_raster <- agricultural_indices[[1]]  # Use NDVI as proxy
terra::values(yield_potential_raster) <- ifelse(terra::values(yield_potential_raster) > 0.6, 3,
                                               ifelse(terra::values(yield_potential_raster) > 0.4, 2, 1))
names(yield_potential_raster) <- "Yield_Potential"

plot_raster_fast(
  yield_potential_raster,
  title = "Yield Potential Classification",
  color_scheme = "terrain"
)
```

#### Crop Performance Metrics

Calculate key performance indicators for agricultural monitoring:

``` r
# Calculate comprehensive vegetation statistics
if (inherits(agricultural_indices, "SpatRaster")) {
  veg_stats <- list()
  
  for (i in 1:terra::nlyr(agricultural_indices)) {
    index_name <- names(agricultural_indices)[i]
    values <- terra::values(agricultural_indices[[i]], mat = FALSE)
    valid_values <- values[!is.na(values)]
    
    if (length(valid_values) > 0) {
      veg_stats[[index_name]] <- list(
        mean = mean(valid_values),
        median = median(valid_values),
        sd = sd(valid_values),
        cv = sd(valid_values) / mean(valid_values),
        min = min(valid_values),
        max = max(valid_values),
        q25 = quantile(valid_values, 0.25),
        q75 = quantile(valid_values, 0.75)
      )
    }
  }
  
  print("Crop Performance Metrics:")
  for (index in names(veg_stats)) {
    stats <- veg_stats[[index]]
    print(paste(index, "- Mean:", round(stats$mean, 3), 
                "CV:", round(stats$cv, 3),
                "Range:", paste(round(c(stats$min, stats$max), 3), collapse = "-")))
  }
}
```

### Precision Agriculture Applications

#### Field-Level Analysis

Analyze individual fields or management zones:

``` r
# Create sample field boundaries
field_1 <- sf::st_polygon(list(matrix(c(
  -83.5, 40.0, -83.3, 40.0, -83.3, 40.2, -83.5, 40.2, -83.5, 40.0
), ncol = 2, byrow = TRUE)))

field_2 <- sf::st_polygon(list(matrix(c(
  -83.3, 40.0, -83.1, 40.0, -83.1, 40.2, -83.3, 40.2, -83.3, 40.0
), ncol = 2, byrow = TRUE)))

fields_sf <- sf::st_sf(
  field_id = c("Field_1", "Field_2"),
  crop_type = c("Corn", "Soybeans"),
  geometry = sf::st_sfc(field_1, field_2, crs = 4326)
)

# Extract vegetation statistics by field using spatial join
field_analysis <- universal_spatial_join(
  source_data = agricultural_indices,
  target_data = fields_sf,
  method = "zonal",
  summary_function = "mean",
  verbose = TRUE
)

print("Field-Level Analysis Results:")
if (inherits(field_analysis, "sf")) {
  print(sf::st_drop_geometry(field_analysis))
}
```

#### Variable Rate Application Support

Support precision agriculture through spatial variability analysis:

``` r
# Calculate coefficient of variation for management zones
if (inherits(agricultural_indices, "SpatRaster") && terra::nlyr(agricultural_indices) > 0) {
  # Use NDVI for variability analysis
  ndvi_layer <- agricultural_indices[[1]]
  
  # Calculate local variability using focal statistics
  local_cv <- terra::focal(ndvi_layer, w = matrix(1, 3, 3), 
                           fun = function(x) sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE))
  names(local_cv) <- "Local_CV"
  
  # Classify variability zones
  variability_zones <- terra::classify(local_cv, 
                                       matrix(c(0, 0.1, 1,     # Low variability
                                               0.1, 0.2, 2,    # Medium variability  
                                               0.2, 1, 3),     # High variability
                                              ncol = 3, byrow = TRUE))
  names(variability_zones) <- "Variability_Zones"
  
  # Visualize variability
  plot_raster_fast(
    local_cv,
    title = "Spatial Variability (Coefficient of Variation)",
    color_scheme = "plasma"
  )
  
  plot_raster_fast(
    variability_zones,
    title = "Management Zones (1=Low, 2=Medium, 3=High Variability)",
    color_scheme = "categorical"
  )
}
```

### Crop Health Monitoring

#### Disease and Stress Detection

Use vegetation indices to detect crop stress and disease:

``` r
# Create stress detection workflow
stress_indices <- c("NDVI", "SAVI", "DVI")

# Calculate stress thresholds based on crop type
corn_thresholds <- list(
  healthy = list(NDVI = c(0.6, 1.0), SAVI = c(0.4, 0.8)),
  stressed = list(NDVI = c(0.3, 0.6), SAVI = c(0.2, 0.4)),
  severely_stressed = list(NDVI = c(0.0, 0.3), SAVI = c(0.0, 0.2))
)

# Apply stress classification
if (inherits(agricultural_indices, "SpatRaster") && "NDVI" %in% names(agricultural_indices)) {
  ndvi_values <- terra::values(agricultural_indices[["NDVI"]], mat = FALSE)
  
  # Classify stress levels
  stress_classification <- ifelse(ndvi_values >= 0.6, "Healthy",
                                 ifelse(ndvi_values >= 0.3, "Moderate Stress", "Severe Stress"))
  
  # Create stress map
  stress_raster <- agricultural_indices[["NDVI"]]
  stress_numeric <- ifelse(ndvi_values >= 0.6, 3,
                          ifelse(ndvi_values >= 0.3, 2, 1))
  terra::values(stress_raster) <- stress_numeric
  names(stress_raster) <- "Stress_Level"
  
  plot_raster_fast(
    stress_raster,
    title = "Crop Stress Classification (1=Severe, 2=Moderate, 3=Healthy)",
    color_scheme = "terrain"
  )
  
  # Calculate stress statistics
  stress_table <- table(stress_classification)
  stress_percent <- round(prop.table(stress_table) * 100, 1)
  
  print("Crop Stress Distribution:")
  for (level in names(stress_table)) {
    print(paste(level, ":", stress_table[[level]], "pixels (", stress_percent[[level]], "%)"))
  }
}
```

#### Early Warning Systems

Create early warning systems for crop management:

``` r
# Define warning thresholds
warning_thresholds <- list(
  drought_stress = 0.4,    # NDVI below this indicates drought stress
  disease_risk = 0.3,      # NDVI below this indicates disease risk
  optimal_growth = 0.7     # NDVI above this indicates optimal conditions
)

# Generate alerts
if (exists("ndvi_values")) {
  alerts <- list()
  
  # Calculate percentages in each category
  drought_pixels <- sum(ndvi_values < warning_thresholds$drought_stress, na.rm = TRUE)
  disease_pixels <- sum(ndvi_values < warning_thresholds$disease_risk, na.rm = TRUE)
  optimal_pixels <- sum(ndvi_values > warning_thresholds$optimal_growth, na.rm = TRUE)
  total_pixels <- sum(!is.na(ndvi_values))
  
  alerts$drought_risk <- round((drought_pixels / total_pixels) * 100, 1)
  alerts$disease_risk <- round((disease_pixels / total_pixels) * 100, 1)
  alerts$optimal_conditions <- round((optimal_pixels / total_pixels) * 100, 1)
  
  print("Agricultural Alert System:")
  print(paste("Drought stress risk:", alerts$drought_risk, "% of field"))
  print(paste("Disease risk:", alerts$disease_risk, "% of field"))
  print(paste("Optimal conditions:", alerts$optimal_conditions, "% of field"))
  
  # Generate recommendations
  if (alerts$drought_risk > 20) {
    print("RECOMMENDATION: Consider irrigation scheduling")
  }
  if (alerts$disease_risk > 10) {
    print("RECOMMENDATION: Increase disease monitoring")
  }
  if (alerts$optimal_conditions > 70) {
    print("STATUS: Crop conditions are generally favorable")
  }
}
```

### Seasonal Crop Monitoring

#### Multi-Temporal Analysis

Track crop development throughout the growing season:

``` r
# Simulate time series data for growing season
growth_stages <- c("Planting", "V6", "V12", "R1", "R3", "R6")
ndvi_progression <- c(0.2, 0.4, 0.7, 0.8, 0.75, 0.6)

# Create time series visualization concept
seasonal_data <- data.frame(
  Stage = growth_stages,
  NDVI = ndvi_progression,
  DOY = c(120, 150, 180, 200, 220, 260)  # Day of year
)

print("Seasonal NDVI Progression:")
print(seasonal_data)

# Create conceptual growth curve
if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  
  growth_plot <- ggplot(seasonal_data, aes(x = DOY, y = NDVI)) +
    geom_line(color = "darkgreen", size = 1.2) +
    geom_point(color = "red", size = 3) +
    geom_text(aes(label = Stage), vjust = -0.5) +
    labs(title = "Typical Corn NDVI Progression",
         x = "Day of Year",
         y = "NDVI Value") +
    theme_minimal() +
    ylim(0, 1)
  
  print(growth_plot)
}
```

#### Harvest Timing Optimization

Use vegetation indices to optimize harvest timing:

``` r
# Define maturity indicators based on NDVI decline
maturity_thresholds <- list(
  corn = list(
    early_maturity = 0.7,     # NDVI starts declining
    harvest_ready = 0.5,      # Optimal harvest window
    post_harvest = 0.3        # Past optimal timing
  ),
  soybeans = list(
    early_maturity = 0.6,
    harvest_ready = 0.4,
    post_harvest = 0.25
  )
)

# Calculate harvest readiness
if (exists("ndvi_values")) {
  # Use corn thresholds for demonstration
  thresholds <- maturity_thresholds$corn
  
  harvest_assessment <- list(
    early_maturity = sum(ndvi_values <= thresholds$early_maturity & 
                        ndvi_values > thresholds$harvest_ready, na.rm = TRUE),
    harvest_ready = sum(ndvi_values <= thresholds$harvest_ready & 
                       ndvi_values > thresholds$post_harvest, na.rm = TRUE),
    post_optimal = sum(ndvi_values <= thresholds$post_harvest, na.rm = TRUE),
    still_growing = sum(ndvi_values > thresholds$early_maturity, na.rm = TRUE)
  )
  
  total_pixels <- sum(!is.na(ndvi_values))
  
  print("Harvest Timing Assessment:")
  for (stage in names(harvest_assessment)) {
    percentage <- round((harvest_assessment[[stage]] / total_pixels) * 100, 1)
    print(paste(stage, ":", harvest_assessment[[stage]], "pixels (", percentage, "%)"))
  }
}
```

### Water Management for Agriculture

#### Irrigation Needs Assessment

Use water indices to assess irrigation requirements:

``` r
# Calculate water-related indices
green_band <- red_band
terra::values(green_band) <- runif(2500, 0.1, 0.2)
names(green_band) <- "Green"

# Calculate NDWI for water stress detection
ndwi <- calculate_water_index(
  green = green_band,
  nir = nir_band,
  index_type = "NDWI",
  verbose = TRUE
)

# Irrigation needs based on NDWI
ndwi_values <- terra::values(ndwi, mat = FALSE)
valid_ndwi <- ndwi_values[!is.na(ndwi_values)]

if (length(valid_ndwi) > 0) {
  irrigation_zones <- ifelse(valid_ndwi < -0.3, "High Need",
                           ifelse(valid_ndwi < -0.1, "Moderate Need", "Adequate"))
  
  irrigation_table <- table(irrigation_zones)
  irrigation_percent <- round(prop.table(irrigation_table) * 100, 1)
  
  print("Irrigation Needs Assessment:")
  for (zone in names(irrigation_table)) {
    print(paste(zone, ":", irrigation_table[[zone]], "pixels (", irrigation_percent[[zone]], "%)"))
  }
  
  # Visualize irrigation zones
  irrigation_raster <- ndwi
  terra::values(irrigation_raster) <- as.numeric(as.factor(irrigation_zones))
  names(irrigation_raster) <- "Irrigation_Needs"
  
  plot_raster_fast(
    irrigation_raster,
    title = "Irrigation Needs Assessment (1=Adequate, 2=High, 3=Moderate)",
    color_scheme = "water"
  )
}
```

### Crop Rotation Analysis

#### Multi-Year Crop Tracking

Analyze crop rotation patterns using multi-temporal CDL data:

``` r
# Simulate multi-year CDL data
create_rotation_analysis <- function() {
  # Create sample rotation data
  rotation_data <- data.frame(
    year = rep(2021:2023, each = 4),
    field = rep(c("Field_A", "Field_B", "Field_C", "Field_D"), 3),
    crop = c(
      "Corn", "Soybeans", "Corn", "Wheat",      # 2021
      "Soybeans", "Corn", "Soybeans", "Corn",   # 2022
      "Corn", "Soybeans", "Corn", "Soybeans"   # 2023
    ),
    yield = runif(12, 80, 200)
  )
  
  return(rotation_data)
}

rotation_analysis <- create_rotation_analysis()
print("Crop Rotation Analysis:")
print(rotation_analysis)

# Analyze rotation patterns
rotation_patterns <- list()
fields <- unique(rotation_analysis$field)

for (field in fields) {
  field_data <- rotation_analysis[rotation_analysis$field == field, ]
  rotation_patterns[[field]] <- paste(field_data$crop, collapse = " Ã¢â€ â€™ ")
}

print("Rotation Patterns:")
for (field in names(rotation_patterns)) {
  print(paste(field, ":", rotation_patterns[[field]]))
}
```

#### Sustainable Agriculture Metrics

Calculate sustainability indicators:

``` r
# Calculate diversity index for crop rotation
calculate_crop_diversity <- function(rotation_data) {
  diversity_scores <- list()
  
  for (field in unique(rotation_data$field)) {
    field_crops <- rotation_data$crop[rotation_data$field == field]
    unique_crops <- length(unique(field_crops))
    total_years <- length(field_crops)
    
    # Simple diversity score (0-1, higher = more diverse)
    diversity_scores[[field]] <- unique_crops / total_years
  }
  
  return(diversity_scores)
}

diversity_scores <- calculate_crop_diversity(rotation_analysis)

print("Crop Diversity Scores (Higher = More Diverse):")
for (field in names(diversity_scores)) {
  print(paste(field, ":", round(diversity_scores[[field]], 2)))
}

# Sustainability recommendations
avg_diversity <- mean(unlist(diversity_scores))
print(paste("Average field diversity:", round(avg_diversity, 2)))

if (avg_diversity < 0.5) {
  print("RECOMMENDATION: Consider more diverse crop rotations")
} else if (avg_diversity > 0.8) {
  print("STATUS: Good crop diversity maintained")
}
```

### Integration with Farm Management

#### Data Export for Farm Software

Prepare analysis results for integration with farm management systems:

``` r
# Create farm-ready data export
create_farm_export <- function(analysis_results, field_boundaries) {
  # Compile key metrics for farm management
  farm_data <- list(
    summary_statistics = list(),
    recommendations = list(),
    alerts = list()
  )
  
  # Extract key metrics
  if (exists("veg_stats") && length(veg_stats) > 0) {
    farm_data$summary_statistics <- veg_stats
  }
  
  # Generate management recommendations
  if (exists("alerts")) {
    if (alerts$drought_risk > 20) {
      farm_data$recommendations <- c(farm_data$recommendations, 
                                   "Increase irrigation frequency")
    }
    if (alerts$disease_risk > 15) {
      farm_data$recommendations <- c(farm_data$recommendations,
                                   "Monitor for disease symptoms")
    }
  }
  
  return(farm_data)
}

# Export field-level results
if (exists("field_analysis") && inherits(field_analysis, "sf")) {
  field_summary <- sf::st_drop_geometry(field_analysis)
  
  # Add coordinates for GPS guidance
  field_centroids <- sf::st_centroid(field_analysis)
  field_coords <- sf::st_coordinates(field_centroids)
  field_summary$centroid_lon <- field_coords[, 1]
  field_summary$centroid_lat <- field_coords[, 2]
  
  print("Field Summary for Farm Management:")
  print(field_summary)
}
```

#### Economic Analysis Support

Calculate economic indicators from vegetation analysis:

``` r
# Estimate economic value based on vegetation health
calculate_economic_metrics <- function(ndvi_data, crop_prices) {
  if (!exists("ndvi_values")) return(NULL)
  
  # Simplified yield prediction based on NDVI
  # (In practice, would use crop-specific models)
  predicted_yield <- ifelse(ndvi_values > 0.7, "High",
                           ifelse(ndvi_values > 0.5, "Medium", "Low"))
  
  yield_table <- table(predicted_yield)
  
  # Economic projections (simplified)
  economic_zones <- list(
    high_yield = sum(predicted_yield == "High", na.rm = TRUE),
    medium_yield = sum(predicted_yield == "Medium", na.rm = TRUE), 
    low_yield = sum(predicted_yield == "Low", na.rm = TRUE)
  )
  
  return(economic_zones)
}

# Calculate economic zones
if (exists("ndvi_values")) {
  economic_analysis <- calculate_economic_metrics(ndvi_values, 
                                                  list(corn = 5.50, soybeans = 13.00))
  
  if (!is.null(economic_analysis)) {
    total_pixels <- sum(unlist(economic_analysis))
    
    print("Economic Potential Analysis:")
    for (zone in names(economic_analysis)) {
      pixels <- economic_analysis[[zone]]
      percentage <- round((pixels / total_pixels) * 100, 1)
      print(paste(zone, ":", pixels, "pixels (", percentage, "%)"))
    }
  }
}
```

### Quality Assurance and Validation

#### Data Quality Checks

Implement quality assurance for agricultural monitoring:

``` r
# Vegetation index quality assessment
quality_check <- function(vegetation_indices) {
  qc_results <- list()
  
  if (inherits(vegetation_indices, "SpatRaster")) {
    for (i in 1:terra::nlyr(vegetation_indices)) {
      index_name <- names(vegetation_indices)[i]
      values <- terra::values(vegetation_indices[[i]], mat = FALSE)
      
      qc_results[[index_name]] <- list(
        total_pixels = length(values),
        valid_pixels = sum(!is.na(values)),
        coverage_percent = round((sum(!is.na(values)) / length(values)) * 100, 1),
        value_range = range(values, na.rm = TRUE),
        outliers = sum(values < -1 | values > 1, na.rm = TRUE)  # For normalized indices
      )
    }
  }
  
  return(qc_results)
}

# Perform quality check
if (exists("agricultural_indices")) {
  qc_results <- quality_check(agricultural_indices)
  
  print("Data Quality Assessment:")
  for (index in names(qc_results)) {
    qc <- qc_results[[index]]
    print(paste(index, "- Coverage:", qc$coverage_percent, "%, Outliers:", qc$outliers))
  }
}
```

#### Field Validation Support

Support ground truth collection and validation:

``` r
# Create sampling points for field validation
create_validation_points <- function(field_boundary, n_points = 10) {
  # Generate random points within field boundary
  if (inherits(field_boundary, "sf")) {
    sample_points <- sf::st_sample(field_boundary, n_points)
    validation_sf <- sf::st_sf(
      point_id = paste0("VP_", 1:length(sample_points)),
      validation_type = "Ground_Truth",
      geometry = sample_points
    )
    return(validation_sf)
  }
  return(NULL)
}

# Create validation points for first field
if (exists("fields_sf")) {
  validation_points <- create_validation_points(fields_sf[1, ], n_points = 5)
  
  if (!is.null(validation_points)) {
    print("Validation Points Created:")
    print(sf::st_drop_geometry(validation_points))
    
    # Extract vegetation index values at validation points
    if (exists("agricultural_indices")) {
      validation_extracted <- universal_spatial_join(
        source_data = validation_points,
        target_data = agricultural_indices,
        method = "extract",
        verbose = FALSE
      )
      
      print("Extracted Values at Validation Points:")
      validation_summary <- sf::st_drop_geometry(validation_extracted)
      print(head(validation_summary))
    }
  }
}
```

### Advanced Agricultural Workflows

#### Complete Farm Analysis Pipeline

Demonstrate a complete agricultural analysis workflow:

``` r
# Complete agricultural analysis workflow
run_agricultural_workflow <- function(spectral_data, cdl_data = NULL, 
                                     region_boundary = NULL) {
  workflow_results <- list()
  
  # Step 1: Calculate vegetation indices
  message("Step 1: Calculating vegetation indices...")
  indices <- calculate_multiple_indices(
    spectral_data = spectral_data,
    indices = c("NDVI", "SAVI", "DVI"),
    output_stack = TRUE
  )
  workflow_results$vegetation_indices <- indices
  
  # Step 2: Crop classification (if CDL available)
  if (!is.null(cdl_data)) {
    message("Step 2: Analyzing crop distribution...")
    crop_mask <- create_crop_mask(cdl_data, "corn")
    workflow_results$crop_mask <- crop_mask
  }
  
  # Step 3: Stress assessment
  message("Step 3: Assessing crop stress...")
  if (inherits(indices, "SpatRaster") && "NDVI" %in% names(indices)) {
    ndvi_vals <- terra::values(indices[["NDVI"]], mat = FALSE)
    stress_percent <- sum(ndvi_vals < 0.5, na.rm = TRUE) / sum(!is.na(ndvi_vals)) * 100
    workflow_results$stress_assessment <- round(stress_percent, 1)
  }
  
  # Step 4: Generate recommendations
  message("Step 4: Generating management recommendations...")
  recommendations <- character()
  
  if (!is.null(workflow_results$stress_assessment)) {
    if (workflow_results$stress_assessment > 25) {
      recommendations <- c(recommendations, "High stress detected - investigate causes")
    }
    if (workflow_results$stress_assessment < 10) {
      recommendations <- c(recommendations, "Crop conditions appear favorable")
    }
  }
  
  workflow_results$recommendations <- recommendations
  
  return(workflow_results)
}

# Run the workflow
workflow_output <- run_agricultural_workflow(
  spectral_data = spectral_stack
)

print("Complete Agricultural Workflow Results:")
print(paste("Stress assessment:", workflow_output$stress_assessment, "% of area"))
print("Recommendations:")
for (rec in workflow_output$recommendations) {
  print(paste("-", rec))
}
```

### Summary and Best Practices

#### Key Agricultural Functions

geospatialsuite provides comprehensive agricultural analysis through:

1.  **CDL Integration**:
    [`get_comprehensive_cdl_codes()`](https://cwru-sdle.github.io/geospatialsuite/reference/get_comprehensive_cdl_codes.md),
    [`analyze_cdl_crops_dynamic()`](https://cwru-sdle.github.io/geospatialsuite/reference/analyze_cdl_crops_dynamic.md)
2.  **Crop Monitoring**:
    [`analyze_crop_vegetation()`](https://cwru-sdle.github.io/geospatialsuite/reference/analyze_crop_vegetation.md),
    [`calculate_ndvi_enhanced()`](https://cwru-sdle.github.io/geospatialsuite/reference/calculate_ndvi_enhanced.md)
3.  **Stress Detection**: Multi-index analysis with threshold
    classification
4.  **Water Management**:
    [`calculate_water_index()`](https://cwru-sdle.github.io/geospatialsuite/reference/calculate_water_index.md)
    for irrigation planning
5.  **Yield Assessment**: Composite index calculations and trend
    analysis

#### Best Practices for Agricultural Applications

``` r
# 1. Always validate your data
print("Data Validation Checklist:")
print("Check coordinate reference systems")
print("Verify date ranges match growing season")
print("Validate vegetation index ranges")
print("Confirm crop mask accuracy")

# 2. Use appropriate indices for your crop type
crop_index_recommendations <- list(
  corn = c("NDVI", "EVI2", "SAVI", "DVI"),
  soybeans = c("NDVI", "SAVI", "GNDVI", "DVI"),
  wheat = c("NDVI", "SAVI", "MSAVI"),
  general = c("NDVI", "SAVI", "DVI", "RVI")
)

print("Recommended indices by crop type:")
for (crop in names(crop_index_recommendations)) {
  indices <- crop_index_recommendations[[crop]]
  print(paste(crop, ":", paste(indices, collapse = ", ")))
}

# 3. Monitor throughout growing season
print("Seasonal Monitoring Schedule:")
print("- Planting: Establish baseline measurements")
print("- Early season: Monitor emergence and establishment") 
print("- Mid-season: Peak growth assessment and stress detection")
print("- Late season: Maturity evaluation and harvest timing")
print("- Post-harvest: Residue analysis and planning")
```

#### Integration with Precision Agriculture

``` r
# Precision agriculture workflow components
precision_ag_components <- list(
  data_collection = c("Satellite imagery", "UAV surveys", "Ground sensors"),
  analysis_methods = c("Vegetation indices", "Stress detection", "Yield mapping"),
  decision_support = c("Variable rate applications", "Irrigation scheduling", "Harvest timing"),
  validation = c("Ground truth sampling", "Yield monitoring", "Economic analysis")
)

print("Precision Agriculture Integration:")
for (component in names(precision_ag_components)) {
  print(paste(component, ":", paste(precision_ag_components[[component]], collapse = ", ")))
}
```

### Understanding analyze_crop_vegetation() Outputs

#### Output Structure Overview

The function returns three main components:

1.  **vegetation_indices**: Raster layers with calculated indices
2.  **analysis_results**: Detailed analysis (stress, growth, yield)
3.  **metadata**: Processing information

#### Interpreting Stress Analysis

Stress detection classifies pixels into three categories:

| Stress Level    | NDVI Range | Interpretation           |
|-----------------|------------|--------------------------|
| Healthy         | 0.6 - 1.0  | Normal vegetation growth |
| Moderate Stress | 0.4 - 0.6  | Some stress present      |
| Severe Stress   | 0.0 - 0.4  | Significant stress       |

``` r
result <- analyze_crop_vegetation(data, analysis_type = "stress")
stress <- result$analysis_results$stress_analysis$NDVI

# What percentage of my field needs attention?
cat(sprintf("%.1f%% of field shows stress\n",
            stress$moderate_stress_percentage + stress$severe_stress_percentage))
```

#### Understanding Composite Yield Index

The **composite yield index** is a 0-1 normalized score that combines
multiple vegetation indices:

**How it’s calculated:** 1. Multiple indices (NDVI, EVI, GNDVI, DVI,
RVI) are normalized to 0-1 2. Normalized values are averaged 3. Result
indicates relative yield potential

**Interpretation:** - **0.0-0.3**: Low yield potential - **0.3-0.6**:
Medium yield potential - **0.6-0.8**: High yield potential -
**0.8-1.0**: Very high yield potential

**Important caveats:** - This is a **relative** measure, not absolute
yield - Should be calibrated with actual yield data - Works best for
within-field comparisons - Correlation with actual yield varies by crop
and region

``` r
result <- analyze_crop_vegetation(data, crop_type = "corn", analysis_type = "yield")
yield <- result$analysis_results$yield_analysis

cat(sprintf("Yield Potential: %s\n", yield$yield_potential_class))
cat(sprintf("Composite Score: %.2f\n", yield$composite_yield_index))

# See which indices contributed
for (idx in names(yield$index_contributions)) {
  contrib <- yield$index_contributions[[idx]]
  cat(sprintf("  %s: %.3f\n", idx, contrib$mean_normalized))
}
```

#### Growth Stage Predictions

Growth stage is predicted from NDVI patterns:

| Crop | Stage        | NDVI Range |
|------|--------------|------------|
| Corn | Emergence    | \< 0.3     |
| Corn | Vegetative   | 0.3 - 0.6  |
| Corn | Reproductive | 0.6 - 0.8  |
| Corn | Maturity     | \> 0.8     |

``` r
result <- analyze_crop_vegetation(data, crop_type = "soybeans", analysis_type = "growth")
growth <- result$analysis_results$growth_analysis

cat(sprintf("Predicted stage: %s\n", growth$predicted_growth_stage))
cat(sprintf("Confidence: %.0f%%\n", growth$stage_confidence * 100))
```

### Summary

geospatialsuite’s agricultural applications provide:

#### **CDL Analysis Capabilities:**

- **Comprehensive crop codes** for all USDA CDL categories
- **Dynamic crop analysis** with area calculations
- **Flexible crop masking** and classification
- **Multi-year rotation analysis**
- **Crop diversity mapping**

#### **Precision Agriculture Tools:**

- **Crop-specific vegetation analysis** with stress detection
- **Enhanced NDVI** with agricultural processing
- **Multi-scale field analysis** (50m to 2km scales)
- **Management zone delineation**
- **Yield prediction support**

#### **Integrated Workflows:**

- **Environmental integration** (soil, weather, topography)
- **Water quality assessment** in agricultural context
- **Temporal growth monitoring**
- **Risk assessment** for pests and diseases
- **Comprehensive reporting** and visualization

#### **Key Advantages:**

1.  **Works with any agricultural region** - not limited to specific
    areas
2.  **Handles all crop types** - from row crops to specialty crops
3.  **Multi-scale analysis** - field to regional levels
4.  **Temporal integration** - supports time series analysis
5.  **Robust error handling** - reliable for operational use
6.  **Comprehensive documentation** - easy to implement

#### **Applications:**

- Precision agriculture and variable rate applications
- Crop yield prediction and forecasting
- Agricultural sustainability assessment
- Environmental impact monitoring
- Policy and regulatory compliance
- Research and development support

The agricultural tools in geospatialsuite provide everything needed for
professional agricultural analysis and precision farming applications!

### Acknowledgments

This work was developed by the geospatialsuite team with contributions
from: Olatunde D. Akanbi, Vibha Mandayam, Yinghui Wu, Jeffrey Yarus,
Erika I. Barcelos, and Roger H. French.
