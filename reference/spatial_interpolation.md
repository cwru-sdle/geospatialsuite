# Legacy spatial interpolation function (for backward compatibility)

Simplified version of spatial interpolation maintaining backward
compatibility. For new projects, use
spatial_interpolation_comprehensive() instead.

## Usage

``` r
spatial_interpolation(
  spatial_data,
  target_variables,
  method = "NN",
  power = 2,
  mice_method = "pmm"
)
```

## Arguments

- spatial_data:

  sf object with some missing values

- target_variables:

  Variables to interpolate

- method:

  Interpolation method: "NN", "simple", "mice"

- power:

  Power parameter for simple method (default: 2)

- mice_method:

  MICE method for multivariate imputation

## Value

sf object with interpolated values

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Simple interpolation (legacy interface)
interpolated_data <- spatial_interpolation(
  soil_data,
  target_variables = c("nitrogen", "carbon"),
  method = "NN"
)
} # }
```
