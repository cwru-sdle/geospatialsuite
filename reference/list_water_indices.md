# Get comprehensive list of available water indices

Returns detailed information about all available water indices including
formulas, required bands, applications, and interpretation guidelines.

## Usage

``` r
list_water_indices(detailed = FALSE, application_filter = "all")
```

## Arguments

- detailed:

  Return detailed information including formulas and applications

- application_filter:

  Filter by application: "all", "water_detection",
  "moisture_monitoring", "drought_assessment"

## Value

Data frame with water index information

## Examples

``` r
# \donttest{
# All available water indices
water_indices <- list_water_indices()

# Detailed information with formulas
detailed_info <- list_water_indices(detailed = TRUE)

# Only water detection indices
water_detection <- list_water_indices(application_filter = "water_detection")
# }
```
