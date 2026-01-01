# Analyze temporal changes in geospatial data

Analyze temporal changes in raster data including trend analysis, change
detection, and seasonal patterns. Works with any time series data.

## Usage

``` r
analyze_temporal_changes(
  data_list,
  dates = NULL,
  region_boundary = NULL,
  analysis_type = "trend",
  output_folder = NULL
)
```

## Arguments

- data_list:

  List of raster data for different time periods

- dates:

  Vector of dates corresponding to rasters

- region_boundary:

  Region boundary for analysis

- analysis_type:

  Type of temporal analysis: "trend", "change_detection", "seasonal",
  "statistics"

- output_folder:

  Output directory for results

## Value

Temporal analysis results

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Analyze NDVI trends over time
ndvi_trend <- analyze_temporal_changes(
  data_list = c("ndvi_2020.tif", "ndvi_2021.tif", "ndvi_2022.tif"),
  dates = c("2020", "2021", "2022"),
  region_boundary = "Iowa",
  analysis_type = "trend"
)

# Detect land cover changes
land_changes <- analyze_temporal_changes(
  data_list = land_cover_files,
  dates = land_cover_dates,
  analysis_type = "change_detection"
)
} # }
```
