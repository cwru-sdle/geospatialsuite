# Get region boundary for any specified region

Universal function to get region boundaries for any geographic area
including US states, countries, CONUS, counties, or custom bounding
boxes with comprehensive error handling.

## Usage

``` r
get_region_boundary(region_def, verbose = FALSE)
```

## Arguments

- region_def:

  Region definition in various formats:

  - Character: "Ohio", "Nigeria", "CONUS"

  - Character with colon: "Ohio:Franklin" (state:county)

  - Numeric vector: c(xmin, ymin, xmax, ymax) bounding box

  - sf object: existing spatial object

- verbose:

  Print progress messages

## Value

sf object with boundary geometry

## Examples

``` r
# \donttest{
# US State with error handling
ohio_boundary <- get_region_boundary("Ohio")
#>   |                                                                              |                                                                      |   0%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   6%  |                                                                              |======                                                                |   8%  |                                                                              |=======                                                               |  10%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |============                                                          |  17%  |                                                                              |===============                                                       |  21%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  28%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  32%  |                                                                              |==========================                                            |  37%  |                                                                              |===========================                                           |  39%  |                                                                              |=============================                                         |  41%  |                                                                              |==============================                                        |  43%  |                                                                              |================================                                      |  46%  |                                                                              |===================================                                   |  50%  |                                                                              |======================================                                |  55%  |                                                                              |===========================================                           |  61%  |                                                                              |================================================                      |  69%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  78%  |                                                                              |========================================================              |  80%  |                                                                              |==========================================================            |  82%  |                                                                              |===========================================================           |  85%  |                                                                              |=================================================================     |  94%  |                                                                              |===================================================================   |  96%  |                                                                              |======================================================================| 100%

# Custom bounding box with validation
custom_area <- get_region_boundary(c(-84.5, 39.0, -82.0, 41.0))
# }
```
