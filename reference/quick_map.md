# Quick map function - one-line mapping with auto-detection

Ultra-simple function for quick spatial mapping. Auto-detects data type
and creates appropriate map.

## Usage

``` r
quick_map(spatial_data, variable = NULL, title = NULL, ...)
```

## Arguments

- spatial_data:

  Any spatial data

- variable:

  Variable to visualize (optional, auto-detected)

- title:

  Map title (optional)

- ...:

  Additional arguments passed to create_spatial_map

## Value

Map object

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
quick_map("data.shp")
quick_map(my_raster)
quick_map(points_data, interactive = TRUE)
} # }
```
