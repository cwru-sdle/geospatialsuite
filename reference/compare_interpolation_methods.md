# Compare interpolation methods

Compare multiple interpolation methods using cross-validation and return
performance metrics for method selection.

## Usage

``` r
compare_interpolation_methods(
  spatial_data,
  target_variable,
  methods = c("NN", "simple", "spline"),
  cv_folds = 5,
  verbose = TRUE
)
```

## Arguments

- spatial_data:

  Spatial data for interpolation

- target_variable:

  Variable to interpolate

- methods:

  Vector of methods to compare

- cv_folds:

  Number of cross-validation folds

- verbose:

  Print comparison results

## Value

Data frame with method comparison results

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Compare interpolation methods
method_comparison <- compare_interpolation_methods(
  soil_data,
  target_variable = "nitrogen",
  methods = c("NN", "simple", "spline"),
  cv_folds = 10
)

# View results
print(method_comparison)
# Best method
best_method <- method_comparison$method[which.min(method_comparison$rmse)]
} # }
```
