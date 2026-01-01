# Calculate spatial correlation between raster layers

Calculate spatial correlation between two raster layers using various
methods. Supports pixel-wise correlation and local correlation analysis.

## Usage

``` r
calculate_spatial_correlation(
  raster1,
  raster2,
  method = "pearson",
  local_correlation = FALSE,
  window_size = 3
)
```

## Arguments

- raster1:

  First raster layer

- raster2:

  Second raster layer

- method:

  Correlation method: "pearson", "spearman", "kendall"

- local_correlation:

  Calculate local correlation using moving window

- window_size:

  Window size for local correlation (in pixels)

## Value

Correlation coefficient or SpatRaster of local correlations

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Global correlation between NDVI and soil nitrogen
correlation <- calculate_spatial_correlation(ndvi_raster, nitrogen_raster)

# Local correlation with moving window
local_corr <- calculate_spatial_correlation(
  ndvi_raster, nitrogen_raster,
  local_correlation = TRUE,
  window_size = 5
)
} # }
```
