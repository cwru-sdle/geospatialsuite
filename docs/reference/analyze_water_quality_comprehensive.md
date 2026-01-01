# Analyze water quality comprehensively with flexible data handling

Complete water quality analysis with flexible data input handling,
robust error checking, and comprehensive spatial integration. Supports
any water quality dataset format with automatic column detection and
standardized processing.

## Usage

``` r
analyze_water_quality_comprehensive(
  water_data,
  variable = NULL,
  region_boundary = NULL,
  river_network = NULL,
  output_folder = tempdir(),
  thresholds = NULL,
  coord_cols = NULL,
  date_column = NULL,
  station_id_col = NULL,
  quality_filters = list(),
  verbose = FALSE
)
```

## Arguments

- water_data:

  Water quality data in various formats:

  - File path (CSV, shapefile, GeoJSON)

  - data.frame with coordinates

  - sf object

  - List of datasets for multi-dataset analysis

- variable:

  Variable to analyze (auto-detected if NULL)

- region_boundary:

  Region boundary (optional)

- river_network:

  Optional river network data for context

- output_folder:

  Output directory (default: tempdir())

- thresholds:

  Named list of threshold values for classification (optional)

- coord_cols:

  Coordinate column names (auto-detected if NULL)

- date_column:

  Date/time column name (auto-detected if NULL)

- station_id_col:

  Station ID column name (auto-detected if NULL)

- quality_filters:

  Quality control filters to apply

- verbose:

  Print detailed progress messages

## Value

List with comprehensive water quality analysis results:

- `water_data`: Processed spatial data

- `statistics`: Summary statistics by variable and category

- `spatial_analysis`: Spatial pattern analysis

- `temporal_analysis`: Temporal trends (if date data available)

- `threshold_analysis`: Threshold exceedance analysis

- `output_files`: Paths to generated output files

- `metadata`: Analysis metadata and parameters

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Flexible data input - auto-detects columns
results <- analyze_water_quality_comprehensive("water_stations.csv")

# Specify parameters for custom data
results <- analyze_water_quality_comprehensive(
  water_data = my_data,
  variable = "nitrate_concentration",
  region_boundary = "Ohio",
  coord_cols = c("longitude", "latitude"),
  thresholds = list(
    Normal = c(0, 2),
    Elevated = c(2, 5),
    High = c(5, 10),
    Critical = c(10, Inf)
  )
)

# Multi-dataset analysis
results <- analyze_water_quality_comprehensive(
  water_data = list(
    surface = "surface_water.csv",
    groundwater = "groundwater.csv"
  ),
  variable = "total_nitrogen"
)
} # }
```
