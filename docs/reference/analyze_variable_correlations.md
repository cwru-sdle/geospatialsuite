# Analyze correlations between multiple variables

Analyze correlations between multiple raster variables and create
correlation matrices and plots.

## Usage

``` r
analyze_variable_correlations(
  variable_list,
  output_folder = NULL,
  region_boundary = NULL,
  method = "pearson",
  create_plots = TRUE
)
```

## Arguments

- variable_list:

  Named list of raster variables

- output_folder:

  Output directory for results

- region_boundary:

  Optional region boundary

- method:

  Correlation method

- create_plots:

  Create correlation plots

## Value

List with correlation results

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require directory structures with multiple data files
# Analyze correlations between multiple variables
variables <- list(
  ndvi = "ndvi.tif",
  nitrogen = "soil_nitrogen.tif",
  elevation = "dem.tif",
  precipitation = "precip.tif"
)

correlation_results <- analyze_variable_correlations(
  variables,
  output_folder = "correlations/",
  region_boundary = "Ohio"
)
} # }
```
