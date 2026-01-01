# Perform spatial interpolation for missing data

Perform spatial interpolation using reliable methods to fill missing
values in spatial datasets. Supports nearest neighbor, spline
interpolation, and multivariate imputation with comprehensive error
handling.

## Usage

``` r
spatial_interpolation_comprehensive(
  spatial_data,
  target_variables,
  method = "NN",
  target_grid = NULL,
  region_boundary = NULL,
  power = 2,
  max_distance = Inf,
  min_points = 3,
  max_points = 50,
  cross_validation = FALSE,
  cv_folds = 5,
  handle_outliers = "none",
  outlier_threshold = 3,
  coord_cols = c("lon", "lat"),
  mice_method = "pmm",
  mice_iterations = 10,
  output_format = "sf",
  output_file = NULL,
  verbose = FALSE
)
```

## Arguments

- spatial_data:

  Spatial data to interpolate. Can be:

  - sf object with point geometries

  - data.frame with coordinate columns

  - File path to spatial data (CSV, SHP, GeoJSON)

- target_variables:

  Character vector of variables to interpolate

- method:

  Interpolation method:

  - **"NN"**: Nearest neighbor (default)

  - **"simple"**: Simple distance weighting

  - **"spline"**: Thin plate spline interpolation

  - **"mice"**: Multivariate imputation (requires mice package)

  - **"auto"**: Automatically select best method based on data

- target_grid:

  Target grid for interpolation. Can be:

  - SpatRaster template for raster output

  - sf object with target locations

  - NULL for point-to-point interpolation only

- region_boundary:

  Optional region boundary for clipping results

- power:

  Power parameter for simple distance weighting (default: 2)

- max_distance:

  Maximum distance for interpolation (map units)

- min_points:

  Minimum number of points for interpolation

- max_points:

  Maximum number of points to use for each prediction

- cross_validation:

  Perform cross-validation for accuracy assessment

- cv_folds:

  Number of folds for cross-validation (default: 5)

- handle_outliers:

  Method for outlier handling: "none", "remove", "cap"

- outlier_threshold:

  Z-score threshold for outlier detection (default: 3)

- coord_cols:

  Coordinate column names for data.frame input

- mice_method:

  MICE method for multivariate imputation

- mice_iterations:

  Number of MICE iterations (default: 10)

- output_format:

  Output format: "sf", "raster", "both"

- output_file:

  Optional output file path

- verbose:

  Print detailed progress messages

## Value

Depending on output_format:

- "sf":

  sf object with interpolated values

- "raster":

  SpatRaster with interpolated surfaces

- "both":

  List containing both sf and raster results

Additional attributes include:

- interpolation_info: Method used, parameters, processing time

- cross_validation: CV results if performed

## Details

### Supported Interpolation Methods:

#### Distance-Based Methods:

- **NN** (Nearest Neighbor): Assigns nearest known value - Best for:
  Categorical data or when preserving exact values - Fast and creates
  Voronoi-like patterns - No assumptions about data distribution

- **Simple** (Simple distance weighting): Basic distance-based
  averaging - Best for: Quick estimates with minimal computation - Uses
  inverse distance weighting without external dependencies

#### Statistical Methods:

- **Spline**: Smooth surface interpolation using thin plate splines -
  Best for: Smooth, continuous phenomena - Creates smooth surfaces
  without sharp changes - Good for environmental data with gradual
  spatial variation

#### Multivariate Methods:

- **MICE**: Multivariate imputation by chained equations - Best for:
  Multiple correlated variables with missing values - Handles complex
  missing data patterns - Preserves relationships between variables -
  Requires mice package

### Input Data Support:

- sf objects with point geometries

- data.frame with coordinate columns

- File paths (CSV, shapefile, GeoJSON)

- Target grids for raster output

### Quality Control Features:

- Cross-validation for method comparison

- Outlier detection and handling

- Performance metrics calculation

- Robust error handling

## Method Selection Guide

- Dense, regular data:

  Simple distance weighting for good balance

- Sparse, irregular data:

  Nearest neighbor for stability

- Environmental data:

  Spline for smooth surfaces

- Categorical data:

  Nearest neighbor

- Multiple correlated variables:

  MICE for multivariate patterns

- Unknown data characteristics:

  Auto-selection based on data properties

## Performance Optimization

- For large datasets: Set max_points=50-100 for faster processing

- For high accuracy: Use cross_validation=TRUE to compare methods

- For memory efficiency: Process variables individually

- For smooth results: Use spline method

## See also

- [`universal_spatial_join`](https://cwru-sdle.github.io/geospatialsuite/reference/universal_spatial_join.md)
  for spatial data integration

- [`calculate_spatial_correlation`](https://cwru-sdle.github.io/geospatialsuite/reference/calculate_spatial_correlation.md)
  for spatial correlation analysis

- [`create_spatial_map`](https://cwru-sdle.github.io/geospatialsuite/reference/create_spatial_map.md)
  for visualization

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Basic nearest neighbor interpolation
soil_interpolated <- spatial_interpolation_comprehensive(
  spatial_data = "soil_samples.csv",
  target_variables = c("nitrogen", "phosphorus", "ph"),
  method = "NN",
  target_grid = study_area_grid,
  region_boundary = "Iowa"
)

# Simple distance weighting
temp_interp <- spatial_interpolation_comprehensive(
  spatial_data = weather_stations,
  target_variables = "temperature",
  method = "simple",
  power = 2,
  cross_validation = TRUE,
  verbose = TRUE
)

# Multivariate imputation for environmental data
env_imputed <- spatial_interpolation_comprehensive(
  spatial_data = env_monitoring,
  target_variables = c("temp", "humidity", "pressure", "wind_speed"),
  method = "mice",
  mice_iterations = 15,
  handle_outliers = "cap"
)

# Auto-method selection with comparison
best_interp <- spatial_interpolation_comprehensive(
  spatial_data = precipitation_data,
  target_variables = "annual_precip",
  method = "auto",
  cross_validation = TRUE,
  cv_folds = 10,
  target_grid = dem_template
)

# Access results and diagnostics
plot(best_interp)  # Plot interpolated surface
best_interp$cross_validation$rmse  # Cross-validation RMSE
best_interp$interpolation_info$method_selected  # Method chosen
} # }
```
