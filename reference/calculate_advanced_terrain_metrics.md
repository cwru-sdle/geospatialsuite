# Calculate advanced terrain metrics

Calculate advanced terrain metrics from DEM including curvature, wetness
index, and stream power index.

## Usage

``` r
calculate_advanced_terrain_metrics(
  elevation_raster,
  metrics = c("wetness_index", "curvature", "convergence"),
  region_boundary = NULL
)
```

## Arguments

- elevation_raster:

  Digital elevation model

- metrics:

  Vector of metrics to calculate

- region_boundary:

  Optional region boundary

## Value

List of terrain metric rasters

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Calculate advanced terrain metrics
terrain_metrics <- calculate_advanced_terrain_metrics(
  elevation_raster = "dem.tif",
  metrics = c("wetness_index", "curvature", "convergence"),
  region_boundary = "watershed.shp"
)
} # }
```
