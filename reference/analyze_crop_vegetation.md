# Specialized crop vegetation analysis

Perform comprehensive vegetation analysis specifically designed for crop
monitoring including growth stage detection, stress identification, and
yield prediction support. Handles test scenarios properly with better
input validation.

## Usage

``` r
analyze_crop_vegetation(
  spectral_data,
  crop_type = "general",
  growth_stage = "unknown",
  analysis_type = "comprehensive",
  cdl_mask = NULL,
  reference_data = NULL,
  output_folder = NULL,
  verbose = FALSE
)
```

## Arguments

- spectral_data:

  Multi-band spectral data (file, directory, or SpatRaster)

- crop_type:

  Crop type for specialized analysis ("corn", "soybeans", "wheat",
  "general")

- growth_stage:

  Growth stage if known ("early", "mid", "late", "harvest")

- analysis_type:

  Type of analysis: "comprehensive", "stress", "growth", "yield"

- cdl_mask:

  Optional CDL mask for crop-specific analysis

- reference_data:

  Optional reference data for validation

- output_folder:

  Optional output folder for results

- verbose:

  Print detailed progress

## Value

List with comprehensive vegetation analysis results:

- `vegetation_indices`: SpatRaster with calculated indices

- `analysis_results`: Detailed analysis results by type

- `metadata`: Analysis metadata and parameters

## Details

### Crop-Specific Index Selection:

- **Corn**: NDVI, EVI, GNDVI, DVI, RVI, PRI

- **Soybeans**: NDVI, EVI, SAVI, GNDVI, PRI

- **Wheat**: NDVI, EVI, SAVI, DVI

- **General**: NDVI, EVI, SAVI, GNDVI, DVI, RVI

### Analysis Types:

- **comprehensive**: All analyses (stress, growth, yield)

- **stress**: Focus on stress detection indices

- **growth**: Growth stage analysis

- **yield**: Yield prediction support

### Output Structure:

The function returns a list with three main components:

#### 1. vegetation_indices (SpatRaster)

Multi-layer raster with calculated indices (NDVI, EVI, etc.)

#### 2. analysis_results (List)

**stress_analysis** (if requested):

- Percentage of pixels in each stress category

- Categories: healthy (NDVI 0.6-1.0), moderate stress (0.4-0.6), severe
  stress (0.0-0.4)

- Includes mean, median, std_dev, and thresholds used

**growth_analysis** (if requested):

- Predicted growth stage based on NDVI patterns

- Stage confidence (0-1 scale)

- Detailed statistics for each index

- Growth stages: emergence, vegetative, reproductive, maturity
  (crop-specific)

**yield_analysis** (if requested):

- **Composite Yield Index**: Normalized 0-1 score combining multiple
  indices

  - 0.0 = Very low yield potential

  - 0.5 = Medium yield potential

  - 1.0 = Maximum yield potential

- **Yield Potential Class**: Categorical (Low, Medium, High, Very High)

- **Index Contributions**: How each index contributed to composite score

- Calculation: Each index (NDVI, EVI, GNDVI, DVI, RVI) is normalized to
  0-1, then averaged to create composite score

**summary_statistics**:

- Basic stats (mean, std, min, max, percentiles) for all indices

- Coverage percentage and pixel counts

#### 3. metadata (List)

Processing information: crop_type, indices_used, processing_date,
spatial properties

### Example Interpretation:

    result <- analyze_crop_vegetation(data, crop_type = "corn")

    # Stress Assessment
    stress <- result$analysis_results$stress_analysis$NDVI
    cat(sprintf("Healthy: %.1f%%, Stressed: %.1f%%\n",
                stress$healthy_percentage,
                stress$severe_stress_percentage))

    # Growth Stage
    stage <- result$analysis_results$growth_analysis$predicted_growth_stage
    cat(sprintf("Growth stage: %s\n", stage))

    # Yield Potential
    yield <- result$analysis_results$yield_analysis
    cat(sprintf("Yield potential: %s (score: %.2f)\n",
                yield$yield_potential_class,
                yield$composite_yield_index))

### Important Notes:

- **Composite Yield Index** is a vegetation-based proxy, not a direct
  yield prediction

- Thresholds are based on literature and may need regional calibration

- Results should be validated with ground truth data

- For detailed output documentation, see package vignette

### Analysis Types:

- **comprehensive**: All analyses (stress, growth, yield)

- **stress**: Focus on stress detection indices

- **growth**: Growth stage analysis

- **yield**: Yield prediction support

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require actual spectral data
# Comprehensive corn analysis
corn_analysis <- analyze_crop_vegetation(
  spectral_data = sentinel_data,
  crop_type = "corn",
  analysis_type = "comprehensive",
  cdl_mask = corn_mask
)

# Access results
corn_analysis$vegetation_indices        # SpatRaster with indices
corn_analysis$analysis_results$stress_analysis  # Stress detection results
corn_analysis$metadata$indices_used     # Which indices were calculated

# Stress detection in soybeans
stress_analysis <- analyze_crop_vegetation(
  spectral_data = landsat_stack,
  crop_type = "soybeans",
  analysis_type = "stress",
  growth_stage = "mid"
)
} # }

# \donttest{
# Example with mock spectral data
# Create mock multi-band raster (simulating satellite data)
red_band <- terra::rast(nrows = 5, ncols = 5, crs = "EPSG:4326")
nir_band <- terra::rast(nrows = 5, ncols = 5, crs = "EPSG:4326")
terra::values(red_band) <- runif(25, 0.1, 0.3)   # Typical red values
terra::values(nir_band) <- runif(25, 0.4, 0.8)   # Typical NIR values
spectral_stack <- c(red_band, nir_band)
names(spectral_stack) <- c("red", "nir")

# Analyze with mock data
result <- analyze_crop_vegetation(spectral_stack, crop_type = "general")
print(names(result))  # Should show analysis components
#> [1] "vegetation_indices" "analysis_results"   "metadata"          
# }
```
