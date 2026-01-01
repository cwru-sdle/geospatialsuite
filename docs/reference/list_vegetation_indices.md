# Get comprehensive list of available vegetation indices

Returns detailed information about all 40+ available vegetation indices
including formulas, required bands, applications, and references.

## Usage

``` r
list_vegetation_indices(
  category = "all",
  application = "all",
  detailed = FALSE
)
```

## Arguments

- category:

  Filter by category: "all", "basic", "enhanced", "specialized",
  "stress"

- application:

  Filter by application: "general", "agriculture", "forestry", "stress",
  "water"

- detailed:

  Return detailed information including formulas and references

## Value

Data frame with vegetation index information

## Examples

``` r
# \donttest{
# All available indices
all_indices <- list_vegetation_indices()

# Only stress detection indices
stress_indices <- list_vegetation_indices(category = "stress")

# Detailed information with formulas
detailed_info <- list_vegetation_indices(detailed = TRUE)

# Agricultural applications only
ag_indices <- list_vegetation_indices(application = "agriculture")
# }
```
