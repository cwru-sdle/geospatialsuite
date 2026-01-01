# Universal Spatial Join - Complete Implementation

Comprehensive spatial join system that handles ALL spatial data
combinations: Vector to Vector, Vector to Raster, Raster to Raster with
full documentation, error handling, and extensive examples. This
replaces all previous spatial join functions with a unified, robust
system.

## Usage

``` r
universal_spatial_join(
  source_data,
  target_data,
  method = "auto",
  scale_factor = NULL,
  summary_function = "mean",
  buffer_distance = NULL,
  temporal_tolerance = NULL,
  crs_target = NULL,
  na_strategy = "remove",
  chunk_size = 1e+06,
  parallel = FALSE,
  verbose = FALSE
)
```

## Arguments

- source_data:

  Source spatial data. Can be:

  - File path: "/path/to/data.tif" or "/path/to/data.shp"

  - Directory: "/path/to/spatial_files/" (processes all spatial files)

  - R object: SpatRaster, sf object, data.frame with coordinates

  - List: Multiple files, raster stack, or sf objects

- target_data:

  Target spatial data (same format options as source_data). Can be NULL
  for scaling operations with scale_factor.

- method:

  Spatial join method:

  - **"auto"**: Automatically detect best method (default)

  - **"extract"**: Extract raster values to vector features

  - **"overlay"**: Spatial intersection/overlay of vectors

  - **"resample"**: Resample raster to match target geometry

  - **"zonal"**: Calculate zonal statistics (raster â†’ vector)

  - **"nearest"**: Nearest neighbor spatial join

  - **"interpolate"**: Spatial interpolation (IDW, kriging)

  - **"temporal"**: Time-aware spatial join

- scale_factor:

  Numeric (\> 0 if provided). Scale factor for resolution changes:

  - `NULL`: Use target data resolution (default)

  - `> 1`: Coarser resolution (e.g., 2 = half resolution)

  - `< 1`: Finer resolution (e.g., 0.5 = double resolution)

  - Custom: Any positive number for specific scaling

- summary_function:

  Character. Function for aggregating overlapping values:

  - **"mean"**: Average values (default for continuous data)

  - **"median"**: Median values (robust to outliers)

  - **"max"**/**"min"**: Maximum/minimum values

  - **"sum"**: Sum values (useful for counts, areas)

  - **"sd"**: Standard deviation (measure variability)

  - **"mode"**/**"majority"**: Most frequent value (categorical data)

- buffer_distance:

  Numeric (\>= 0 if provided). Buffer distance in map units:

  - For point extraction: Buffer around points

  - For line extraction: Buffer along lines

  - For nearest neighbor: Search radius

  - Units: Same as source data CRS (meters, degrees, etc.)

- temporal_tolerance:

  Numeric (\>= 0 if provided). Time tolerance for temporal joins (in
  days):

  - Maximum time difference for matching observations

  - Only used with method = "temporal"

  - Example: 7 = match within 7 days

- crs_target:

  Character or numeric. Target coordinate reference system:

  - EPSG code: 4326, 3857, etc.

  - PROJ string: "+proj=utm +zone=33 +datum=WGS84"

  - NULL: Use source data CRS (default)

- na_strategy:

  Character. Strategy for handling NA values:

  - **"remove"**: Keep NAs as missing (default)

  - **"nearest"**: Replace with nearest neighbor value

  - **"interpolate"**: Spatial interpolation of NAs

  - **"zero"**: Replace NAs with zero

- chunk_size:

  Numeric (\> 0). Chunk size for processing large datasets:

  - Number of features/cells to process at once

  - Larger = faster but more memory

  - Smaller = slower but less memory

  - Default: 1,000,000

- parallel:

  Logical. Use parallel processing:

  - TRUE: Use multiple cores (faster for large data)

  - FALSE: Single core processing (default)

  - Requires 'parallel' package

- verbose:

  Logical. Print detailed progress messages:

  - TRUE: Show processing steps and diagnostics

  - FALSE: Silent processing (default)

## Value

Spatial data object with joined attributes. Return type depends on
operation:

- extract (vector â†’ raster):

  sf object with new columns containing extracted raster values.
  Original geometry preserved, new columns named "extracted\_" followed
  by the raster layer name

- zonal (raster â†’ vector):

  sf object with new columns containing zonal statistics. Original
  geometry preserved, new columns named "zonal\_" followed by the
  statistic name and raster layer name

- resample (raster â†’ raster):

  SpatRaster with resampled/processed data matching target resolution or
  scale factor

- overlay (vector â†’ vector):

  sf object with intersected/overlaid features combining attributes from
  both datasets

- nearest:

  sf object with attributes from nearest features joined

**Returned objects include 'spatial_join_info' attribute containing:**

- method: Join method used

- source_type, target_type: Data types processed

- processing_time: Time taken (if verbose=TRUE)

- timestamp: Processing timestamp

- summary_function: Aggregation function used

## Details

### Quick Start Guide:

Most common use case - extract raster values to point locations:

    result <- universal_spatial_join("my_points.csv", "my_raster.tif", method="extract")

### Supported Operations:

#### Data Type Combinations:

- **Vector â†’ Raster**: Extract raster values to points/polygons/lines

- **Raster â†’ Vector**: Calculate zonal statistics for polygons

- **Raster â†’ Raster**: Resample, overlay, mathematical operations

- **Vector â†’ Vector**: Spatial intersections, overlays, nearest
  neighbor

#### Input Format Support:

- **File paths**: ".tif", ".shp", ".gpkg", ".geojson", ".nc"

- **Directories**: Automatically processes all spatial files

- **R objects**: SpatRaster, sf, data.frame with coordinates

- **Lists**: Multiple files or raster stacks

#### Scaling Operations:

- **Up-scaling**: Aggregate to coarser resolution (scale_factor \> 1)

- **Down-scaling**: Interpolate to finer resolution (scale_factor \< 1)

- **Custom resolution**: Match target raster geometry

#### Error Handling:

- **Auto CRS reprojection**: Handles coordinate system mismatches

- **Geometry alignment**: Auto-crops, extends, or resamples as needed

- **NA handling**: Multiple strategies for missing data

- **Memory management**: Chunked processing for large datasets

#### Method Selection Guide:

- extract:

  Use when you have point/polygon locations and want to get values from
  a raster

- zonal:

  Use when you have polygons and want statistics from raster data within
  each polygon

- resample:

  Use when you need to change raster resolution or align two rasters

- overlay:

  Use when joining two vector datasets based on spatial relationships

- nearest:

  Use when you want to find the closest features between two vector
  datasets

- auto:

  Let the function choose - works well for standard extract/resample
  operations

## Common Error Solutions

- CRS Mismatch:

  "CRS mismatch detected" - Function automatically reprojects data, but
  manual CRS checking recommended for precision

- Memory Issues:

  "Large dataset processing" - Reduce chunk_size parameter (try 500000)
  or set parallel=FALSE

- No Spatial Overlap:

  "No spatial overlap found" - Check that source and target data cover
  the same geographic area

- File Not Found:

  "File does not exist" - Verify file paths and ensure files exist at
  specified locations

- Missing Bands:

  "Required bands not found" - For raster operations, ensure expected
  spectral bands are present

- Invalid Geometries:

  "Geometry errors" - Function attempts to fix automatically, but check
  input data quality

## Performance Tips

- For large datasets (\>1M cells): set chunk_size=500000 and
  parallel=TRUE

- Use method="resample" with scale_factor \> 1 to reduce data size
  before complex operations

- For time series analysis: consider temporal_tolerance to balance
  accuracy vs processing speed

- When processing multiple datasets: ensure consistent CRS to avoid
  reprojection overhead

- For point extraction: use smaller buffer_distance when possible to
  reduce processing time

## See also

- [`raster_to_raster_ops`](https://cwru-sdle.github.io/geospatialsuite/reference/raster_to_raster_ops.md)
  for specialized raster operations

- [`multiscale_operations`](https://cwru-sdle.github.io/geospatialsuite/reference/multiscale_operations.md)
  for multi-scale analysis

- [`process_vector_data`](https://cwru-sdle.github.io/geospatialsuite/reference/process_vector_data.md)
  for vector data preprocessing

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require satellite imagery files (Landsat/Sentinel data etc.)
# =================================================================
# MOST COMMON USE CASE: Extract raster values to CSV points
# =================================================================

# Your typical workflow: CSV file with coordinates + raster file
results <- universal_spatial_join(
  source_data = "my_field_sites.csv",    # CSV with lon, lat columns
  target_data = "satellite_image.tif",   # Any raster file
  method = "extract",                     # Extract raster values to points
  buffer_distance = 100,                  # 100m buffer around each point
  summary_function = "mean",              # Average within buffer
  verbose = TRUE                          # See what's happening
)

# Check results - original data + new columns with raster values
head(results)
#   site_id       lon       lat           geometry extracted_satellite_image
# 1       1 -83.12345  40.12345 POINT (-83.1 40.1)                   0.752
# 2       2 -83.23456  40.23456 POINT (-83.2 40.2)                   0.681
# 3       3 -83.34567  40.34567 POINT (-83.3 40.3)                   0.594

# Access the extracted values
results$extracted_satellite_image

# =================================================================
# ZONAL STATISTICS: Calculate statistics by polygon areas
# =================================================================

# Calculate average precipitation by watershed
watershed_precip <- universal_spatial_join(
  source_data = "precipitation_raster.tif",  # Raster data
  target_data = "watershed_boundaries.shp",  # Polygon boundaries
  method = "zonal",                           # Calculate zonal statistics
  summary_function = "mean",                  # Average precipitation per watershed
  verbose = TRUE
)

# Result: polygons with precipitation statistics
head(watershed_precip)
#   watershed_id                     geometry zonal_mean_precipitation_raster
# 1            1 POLYGON ((-84.2 40.1, ...))                             42.3
# 2            2 POLYGON ((-84.5 40.3, ...))                             38.7

# =================================================================
# RESAMPLE RASTER: Change resolution or align rasters
# =================================================================

# Aggregate 30m Landsat to 250m MODIS resolution
landsat_resampled <- universal_spatial_join(
  source_data = "landsat_30m.tif",      # High resolution input
  target_data = "modis_250m.tif",       # Target resolution template
  method = "resample",                   # Resample operation
  summary_function = "mean",             # Average when aggregating
  verbose = TRUE
)

# Check new resolution
terra::res(landsat_resampled)
# [1] 250 250

# Scale by factor instead of template
coarser_raster <- universal_spatial_join(
  source_data = "fine_resolution.tif",
  target_data = NULL,                    # No template needed
  method = "resample",
  scale_factor = 5,                      # 5x coarser resolution
  summary_function = "mean"
)

# =================================================================
# VECTOR OVERLAY: Join two vector datasets
# =================================================================

# Find which counties contain each field site
sites_with_counties <- universal_spatial_join(
  source_data = "field_sites.shp",      # Point data
  target_data = "county_boundaries.shp", # Polygon data
  method = "overlay",                     # Spatial intersection
  verbose = TRUE
)

# Result: points with county attributes added
head(sites_with_counties)
#   site_id           geometry county_name state_name
# 1       1 POINT (-83.1 40.1)    Franklin       Ohio
# 2       2 POINT (-83.2 40.2)    Delaware       Ohio

# =================================================================
# AUTO-DETECTION: Let function choose best method
# =================================================================

# Function automatically detects: points + raster = extract method
auto_result <- universal_spatial_join(
  source_data = my_points,               # Any point data
  target_data = my_raster,               # Any raster data
  method = "auto",                       # Automatically choose method
  verbose = TRUE                         # See what method was chosen
)
# Output: "Auto-detected method: extract for vector to raster"

# =================================================================
# ERROR HANDLING EXAMPLES
# =================================================================

# Function handles common issues automatically
robust_result <- universal_spatial_join(
  source_data = "points_wgs84.csv",     # WGS84 coordinate system
  target_data = "raster_utm.tif",       # UTM coordinate system
  method = "extract",
  na_strategy = "nearest",               # Handle missing values
  verbose = TRUE                         # See CRS handling messages
)
# Output: "CRS mismatch detected. Reprojecting to match raster CRS..."
} # }
```
