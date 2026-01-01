# Using analyze_crop_vegetation() in geospatialsuite

------------------------------------------------------------------------

## Complete Documentation: analyze_crop_vegetation() Output Structure

### Overview

The
[`analyze_crop_vegetation()`](https://cwru-sdle.github.io/geospatialsuite/reference/analyze_crop_vegetation.md)
function returns a nested list with three main components containing
comprehensive crop analysis results.

------------------------------------------------------------------------

### Output Structure

``` r
result <- analyze_crop_vegetation(
  spectral_data = your_data,
  crop_type = "corn",
  analysis_type = "comprehensive"
)

# Structure:
result$vegetation_indices      # SpatRaster with calculated indices
result$analysis_results        # Detailed analysis results
result$metadata                # Processing metadata
```

------------------------------------------------------------------------

### 1. vegetation_indices (SpatRaster)

**Type:** terra::SpatRaster object (multi-layer)

**Description:** A raster stack containing all calculated vegetation
indices for the specified crop type.

**Contents:**

- Each layer is a different vegetation index (NDVI, EVI, GNDVI, etc.)
- Values are the actual index calculations for each pixel
- Layer names correspond to the index abbreviations

**Example Access:**

``` r
# View all calculated indices
names(result$vegetation_indices)
# [1] "NDVI" "EVI" "GNDVI" "DVI" "RVI" "PRI"

# Extract a specific index
ndvi <- result$vegetation_indices[["NDVI"]]

# Plot an index
plot(result$vegetation_indices[["NDVI"]], main = "NDVI")

# Get values for analysis
ndvi_values <- terra::values(result$vegetation_indices[["NDVI"]])
```

------------------------------------------------------------------------

### 2. analysis_results (List)

**Type:** Named list with up to 5 components depending on
`analysis_type`

#### 2.1 stress_analysis (if analysis_type includes “stress” or “comprehensive”)

**Purpose:** Identifies vegetation stress based on index thresholds

**Structure:**

``` r
result$analysis_results$stress_analysis
```

**Contents for each index analyzed (e.g., NDVI, EVI, SIPI, GNDVI):**

| Field                        | Type    | Description                                  | Example   |
|------------------------------|---------|----------------------------------------------|-----------|
| `healthy_percentage`         | numeric | % of pixels classified as healthy vegetation | 65.3      |
| `moderate_stress_percentage` | numeric | % of pixels showing moderate stress          | 25.1      |
| `severe_stress_percentage`   | numeric | % of pixels showing severe stress            | 9.6       |
| `mean_value`                 | numeric | Mean index value across all pixels           | 0.72      |
| `median_value`               | numeric | Median index value                           | 0.74      |
| `std_dev`                    | numeric | Standard deviation of index values           | 0.15      |
| `thresholds_used`            | list    | The threshold values used for classification | See below |
| `total_pixels_analyzed`      | integer | Total number of valid pixels                 | 125000    |

**Threshold Structure:**

``` r
result$analysis_results$stress_analysis$NDVI$thresholds_used
# $healthy: c(0.6, 1.0)         # NDVI 0.6-1.0 = healthy
# $moderate_stress: c(0.4, 0.6) # NDVI 0.4-0.6 = moderate stress
# $severe_stress: c(0.0, 0.4)   # NDVI 0.0-0.4 = severe stress
```

**Interpretation:**

- **Healthy**: Vegetation is growing normally, adequate water/nutrients
- **Moderate Stress**: Some stress present, may indicate water deficit
  or nutrient issues
- **Severe Stress**: Significant stress, requires immediate attention

**Example Usage:**

``` r
# Access stress results for NDVI
ndvi_stress <- result$analysis_results$stress_analysis$NDVI

# What percentage of my field is healthy?
cat(sprintf("Healthy vegetation: %.1f%%\n", ndvi_stress$healthy_percentage))

# What's the average NDVI?
cat(sprintf("Mean NDVI: %.3f\n", ndvi_stress$mean_value))

# Check all indices analyzed
names(result$analysis_results$stress_analysis)
```

------------------------------------------------------------------------

#### 2.2 growth_analysis (if analysis_type includes “growth” or “comprehensive”)

**Purpose:** Estimates crop growth stage and provides growth statistics

**Structure:**

``` r
result$analysis_results$growth_analysis
```

**Contents:**

##### Index-specific statistics (for NDVI, EVI, GNDVI, DVI):

| Field                      | Type           | Description                             | Example                   |
|----------------------------|----------------|-----------------------------------------|---------------------------|
| `mean`                     | numeric        | Mean index value                        | 0.68                      |
| `median`                   | numeric        | Median index value                      | 0.70                      |
| `std_dev`                  | numeric        | Standard deviation                      | 0.12                      |
| `min`                      | numeric        | Minimum value                           | 0.15                      |
| `max`                      | numeric        | Maximum value                           | 0.92                      |
| `range`                    | numeric        | Max - Min                               | 0.77                      |
| `percentiles`              | numeric vector | 10th, 25th, 75th, 90th percentiles      | c(0.45, 0.58, 0.78, 0.85) |
| `coefficient_of_variation` | numeric        | std_dev / mean (measure of variability) | 0.18                      |
| `n_pixels`                 | integer        | Number of pixels analyzed               | 125000                    |

##### Growth stage prediction (overall):

| Field                    | Type      | Description                       | Example        |
|--------------------------|-----------|-----------------------------------|----------------|
| `predicted_growth_stage` | character | Predicted crop growth stage       | “reproductive” |
| `stage_confidence`       | numeric   | Confidence in prediction (0-1)    | 0.85           |
| `crop_type_used`         | character | Crop type used for classification | “corn”         |

**Growth Stage Classifications:**

**For Corn:**

- “emergence”: NDVI \< 0.3
- “vegetative”: NDVI 0.3-0.6
- “reproductive”: NDVI 0.6-0.8
- “maturity”: NDVI \> 0.8

**For Soybeans:**

- “emergence”: NDVI \< 0.4
- “vegetative”: NDVI 0.4-0.65
- “reproductive”: NDVI 0.65-0.8
- “maturity”: NDVI \> 0.8

**For Wheat:**

- “tillering”: NDVI \< 0.35
- “stem_elongation”: NDVI 0.35-0.7
- “grain_filling”: NDVI 0.7-0.8
- “maturity”: NDVI \> 0.8

**Example Usage:**

``` r
# What growth stage is the crop in?
growth <- result$analysis_results$growth_analysis
cat(sprintf("Growth stage: %s (confidence: %.2f)\n", 
            growth$predicted_growth_stage,
            growth$stage_confidence))

# Get detailed NDVI statistics
ndvi_stats <- growth$NDVI
cat(sprintf("NDVI range: %.3f - %.3f\n", ndvi_stats$min, ndvi_stats$max))
cat(sprintf("NDVI variability (CV): %.3f\n", ndvi_stats$coefficient_of_variation))
```

------------------------------------------------------------------------

#### 2.3 yield_analysis (if analysis_type includes “yield” or “comprehensive”)

**Purpose:** Estimates yield potential using multiple vegetation indices

**Structure:**

``` r
result$analysis_results$yield_analysis
```

**Contents:**

| Field                       | Type             | Description                            | Example                   |
|-----------------------------|------------------|----------------------------------------|---------------------------|
| `composite_yield_index`     | numeric          | Normalized yield potential score (0-1) | 0.72                      |
| `yield_potential_class`     | character        | Categorical yield potential            | “High”                    |
| `indices_used`              | character vector | Which indices contributed              | c(“NDVI”, “EVI”, “GNDVI”) |
| `n_indices_used`            | integer          | Number of indices used                 | 3                         |
| `index_contributions`       | list             | Individual index contributions         | See below                 |
| `crop_type`                 | character        | Crop type used                         | “corn”                    |
| `classification_confidence` | numeric          | Confidence in classification (0-1)     | 0.44                      |

**Index Contributions Structure:**

``` r
result$analysis_results$yield_analysis$index_contributions$NDVI
# $mean_normalized: 0.75    # Normalized contribution (0-1)
# $raw_mean: 0.68           # Raw mean NDVI value
# $raw_std: 0.12            # Raw standard deviation
```

**Composite Yield Index Calculation:**

1.  Each index (NDVI, EVI, GNDVI, DVI, RVI) is normalized to 0-1 scale
2.  Normalized values are averaged across all available indices
3.  Result is a single 0-1 score where:
    - 0.0 = Very low yield potential
    - 0.5 = Medium yield potential  
    - 1.0 = Maximum yield potential

**Yield Potential Classifications:**

**For Corn:**

- “Low”: composite_index \< 0.3
- “Medium”: composite_index 0.3-0.6
- “High”: composite_index 0.6-0.8
- “Very High”: composite_index \> 0.8

**For Soybeans:**

- “Low”: composite_index \< 0.35
- “Medium”: composite_index 0.35-0.65
- “High”: composite_index 0.65-0.85
- “Very High”: composite_index \> 0.85

**For Wheat:**

- “Low”: composite_index \< 0.3
- “Medium”: composite_index 0.3-0.6
- “High”: composite_index 0.6-0.8
- “Very High”: composite_index \> 0.8

**Interpretation:**

- **Composite Yield Index (0.0-1.0):** Higher values indicate better
  yield potential
- **Yield Potential Class:** Categorical assessment for easier
  interpretation
- **Index Contributions:** Shows which indices contributed and their
  individual scores
- **Classification Confidence:** Higher when composite_index is far from
  class boundaries (e.g., 0.2 or 0.9 are more confident than 0.5)

**Example Usage:**

``` r
# What's the yield potential?
yield <- result$analysis_results$yield_analysis
cat(sprintf("Yield Potential: %s (score: %.2f)\n", 
            yield$yield_potential_class,
            yield$composite_yield_index))

# Which indices contributed?
cat(sprintf("Based on %d indices: %s\n",
            yield$n_indices_used,
            paste(yield$indices_used, collapse = ", ")))

# Get individual index contributions
for (idx in names(yield$index_contributions)) {
  contrib <- yield$index_contributions[[idx]]
  cat(sprintf("%s: %.3f (raw: %.3f Ã‚Â± %.3f)\n",
              idx, 
              contrib$mean_normalized,
              contrib$raw_mean,
              contrib$raw_std))
}
```

------------------------------------------------------------------------

#### 2.4 summary_statistics

**Purpose:** Basic statistical summary for all calculated indices

**Structure:**

``` r
result$analysis_results$summary_statistics
```

**Contents for each index:**

| Field              | Type            | Description                             |
|--------------------|-----------------|-----------------------------------------|
| `mean`             | numeric         | Mean value across all pixels            |
| `median`           | numeric         | Median value                            |
| `std_dev`          | numeric         | Standard deviation                      |
| `min`              | numeric         | Minimum value                           |
| `max`              | numeric         | Maximum value                           |
| `count`            | integer         | Number of valid pixels                  |
| `na_count`         | integer         | Number of NA pixels                     |
| `range`            | numeric         | Max - Min                               |
| `cv`               | numeric         | Coefficient of variation (std_dev/mean) |
| `percentiles`      | numeric vector  | 5th, 25th, 75th, 95th percentiles       |
| `coverage_percent` | numeric         | % of total pixels with valid data       |
| `histogram`        | list (optional) | Histogram data if Ã¢â€°Â¥100 pixels     |

**Plus Overall Summary:**

``` r
result$analysis_results$summary_statistics$summary
# $total_indices_calculated: 6
# $indices_with_valid_data: c("NDVI", "EVI", "GNDVI", ...)
# $total_indices_requested: 6
# $success_rate: 100.0
```

**Example Usage:**

``` r
# Get statistics for all indices
stats <- result$analysis_results$summary_statistics

# NDVI statistics
ndvi_stats <- stats$NDVI
cat(sprintf("NDVI: %.3f Ã‚Â± %.3f (range: %.3f to %.3f)\n",
            ndvi_stats$mean,
            ndvi_stats$std_dev,
            ndvi_stats$min,
            ndvi_stats$max))

# Check data quality
cat(sprintf("Coverage: %.1f%% (%d pixels)\n",
            ndvi_stats$coverage_percent,
            ndvi_stats$count))
```

------------------------------------------------------------------------

#### 2.5 validation (if reference_data provided)

**Purpose:** Validates analysis against ground truth data

**Note:** This component only appears if you provide reference_data
parameter

**Structure:** TBD (depends on reference data format)

------------------------------------------------------------------------

### 3. metadata (List)

**Purpose:** Documents analysis parameters and processing information

**Structure:**

``` r
result$metadata
```

**Contents:**

| Field                | Type             | Description                     | Example                     |
|----------------------|------------------|---------------------------------|-----------------------------|
| `crop_type`          | character        | Crop type analyzed              | “corn”                      |
| `growth_stage`       | character        | Growth stage specified          | “mid”                       |
| `analysis_type`      | character        | Type of analysis performed      | “comprehensive”             |
| `indices_used`       | character vector | Indices calculated              | c(“NDVI”, “EVI”, …)         |
| `processing_date`    | POSIXct          | When analysis was performed     | 2025-11-03 10:30:45         |
| `input_bands`        | integer          | Number of input spectral bands  | 8                           |
| `spatial_resolution` | numeric vector   | Resolution (x, y) in map units  | c(10, 10)                   |
| `spatial_extent`     | numeric vector   | Extent (xmin, xmax, ymin, ymax) | c(-95.5, -95.0, 41.5, 42.0) |

**Example Usage:**

``` r
# Check what was analyzed
meta <- result$metadata
cat(sprintf("Analyzed %s at %s growth stage\n", 
            meta$crop_type, 
            meta$growth_stage))
cat(sprintf("Used %d indices: %s\n",
            length(meta$indices_used),
            paste(meta$indices_used, collapse = ", ")))
cat(sprintf("Processed on: %s\n", meta$processing_date))
```

------------------------------------------------------------------------

### Complete Example Workflow

``` r
library(geospatialsuite)
library(terra)

# Run comprehensive crop analysis
result <- analyze_crop_vegetation(
  spectral_data = "path/to/sentinel2_data.tif",
  crop_type = "corn",
  growth_stage = "mid",
  analysis_type = "comprehensive",
  verbose = TRUE
)

# ===== 1. Check what was calculated =====
cat("Indices calculated:\n")
print(names(result$vegetation_indices))

# ===== 2. Assess crop stress =====
stress <- result$analysis_results$stress_analysis$NDVI
cat(sprintf("\nStress Assessment:\n"))
cat(sprintf("  Healthy: %.1f%%\n", stress$healthy_percentage))
cat(sprintf("  Moderate stress: %.1f%%\n", stress$moderate_stress_percentage))
cat(sprintf("  Severe stress: %.1f%%\n", stress$severe_stress_percentage))

# ===== 3. Identify growth stage =====
growth <- result$analysis_results$growth_analysis
cat(sprintf("\nGrowth Stage: %s (%.0f%% confidence)\n",
            growth$predicted_growth_stage,
            growth$stage_confidence * 100))

# ===== 4. Estimate yield potential =====
yield <- result$analysis_results$yield_analysis
cat(sprintf("\nYield Potential: %s\n", yield$yield_potential_class))
cat(sprintf("Composite Yield Index: %.3f\n", yield$composite_yield_index))
cat(sprintf("Based on %d indices: %s\n",
            yield$n_indices_used,
            paste(yield$indices_used, collapse = ", ")))

# ===== 5. Visualize results =====
# Plot stress map
plot(result$vegetation_indices[["NDVI"]], 
     main = "NDVI - Stress Detection",
     col = terrain.colors(100))

# Create stress classification map
ndvi <- result$vegetation_indices[["NDVI"]]
stress_map <- classify(ndvi, 
                      matrix(c(-Inf, 0.4, 1,    # Severe stress
                              0.4, 0.6, 2,       # Moderate stress
                              0.6, Inf, 3),      # Healthy
                            ncol = 3, byrow = TRUE))
plot(stress_map, 
     main = "Crop Stress Classification",
     col = c("red", "yellow", "green"),
     legend = FALSE)
legend("topright", 
       legend = c("Severe Stress", "Moderate Stress", "Healthy"),
       fill = c("red", "yellow", "green"))

# ===== 6. Export results =====
# Save as geotiff
writeRaster(result$vegetation_indices, 
            "crop_indices.tif", 
            overwrite = TRUE)

# Save statistics as CSV
stats_df <- data.frame(
  Index = names(result$analysis_results$summary_statistics)[-length(names(result$analysis_results$summary_statistics))],
  Mean = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$mean),
  StdDev = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$std_dev),
  Min = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$min),
  Max = sapply(result$analysis_results$summary_statistics[1:(length(result$analysis_results$summary_statistics)-1)], function(x) x$max)
)
write.csv(stats_df, "crop_analysis_statistics.csv", row.names = FALSE)
```

------------------------------------------------------------------------

### Tips for Using Results

#### 1. Identifying Problem Areas

``` r
# Find pixels with severe stress
ndvi <- result$vegetation_indices[["NDVI"]]
severe_stress <- ndvi < 0.4
plot(severe_stress, main = "Severe Stress Areas")
```

#### 2. Comparing Multiple Fields

``` r
# Run analysis for multiple fields and compare
field1_result <- analyze_crop_vegetation(field1_data, crop_type = "corn")
field2_result <- analyze_crop_vegetation(field2_data, crop_type = "corn")

# Compare yield potential
cat(sprintf("Field 1 yield: %s (%.3f)\n", 
            field1_result$analysis_results$yield_analysis$yield_potential_class,
            field1_result$analysis_results$yield_analysis$composite_yield_index))
cat(sprintf("Field 2 yield: %s (%.3f)\n",
            field2_result$analysis_results$yield_analysis$yield_potential_class,
            field2_result$analysis_results$yield_analysis$composite_yield_index))
```

#### 3. Time Series Analysis

``` r
# Analyze the same field at different dates
early_season <- analyze_crop_vegetation(june_data, growth_stage = "early")
mid_season <- analyze_crop_vegetation(july_data, growth_stage = "mid")
late_season <- analyze_crop_vegetation(august_data, growth_stage = "late")

# Track NDVI progression
ndvi_progression <- c(
  early_season$analysis_results$growth_analysis$NDVI$mean,
  mid_season$analysis_results$growth_analysis$NDVI$mean,
  late_season$analysis_results$growth_analysis$NDVI$mean
)
plot(1:3, ndvi_progression, type = "b",
     xlab = "Time Period", ylab = "Mean NDVI",
     main = "NDVI Progression Through Season")
```

------------------------------------------------------------------------

### Validation Notes

**Important Caveats:**

1.  **Threshold-based**: Stress and yield classifications use
    literature-based thresholds that may need adjustment for your
    specific region/conditions
2.  **Composite Yield Index**: This is a vegetation-based proxy, not a
    direct yield prediction. Correlation with actual yield varies by
    crop, region, and year
3.  **Growth Stage**: Predictions are based on NDVI patterns and may not
    align perfectly with field observations
4.  **No guarantee**: These are analytical tools to support
    decision-making, not definitive assessments

**Recommended Validation:**

- Compare with ground truth data (yield monitors, field scouting)
- Calibrate thresholds for your specific conditions
- Use multiple years of data to establish local patterns
- Combine with other data sources (weather, soil, management)

------------------------------------------------------------------------

### Acknowledgments

This work was developed by the geospatialsuite team with contributions
from: Olatunde D. Akanbi, Vibha Mandayam, Yinghui Wu, Jeffrey Yarus,
Erika I. Barcelos, and Roger H. French.
