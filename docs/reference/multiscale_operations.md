# Multi-scale spatial operations

Handle multi-scale operations including up-scaling, down-scaling, and
pyramid operations for efficient processing.

## Usage

``` r
multiscale_operations(
  spatial_data,
  target_scales = c(1, 2, 4, 8),
  operation = "mean",
  pyramid = FALSE
)
```

## Arguments

- spatial_data:

  Input spatial data

- target_scales:

  Vector of scale factors

- operation:

  Operation to perform at each scale

- pyramid:

  Create image pyramid

## Value

List of results at different scales

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Create multi-scale analysis
scales <- multiscale_operations("data.tif", c(1, 2, 4, 8), "mean")
} # }
```
