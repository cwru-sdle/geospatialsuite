# Create raster mosaic with intelligent file selection

Create mosaics from multiple raster files with various methods and
intelligent file selection based on region boundaries.

## Usage

``` r
create_raster_mosaic(
  input_data,
  method = "merge",
  region_boundary = NULL,
  output_file = NULL,
  parallel = FALSE
)
```

## Arguments

- input_data:

  Character vector of file paths, directory path, or list of rasters

- method:

  Mosaicing method: "merge", "mosaic", "mean", "max", "min"

- region_boundary:

  Optional region boundary for clipping

- output_file:

  Optional output file path

- parallel:

  Use parallel processing

## Value

SpatRaster object

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Basic mosaic
mosaic <- create_raster_mosaic("/path/to/rasters", method = "merge")

# Mosaic for specific region
ohio_mosaic <- create_raster_mosaic("/aster/files", "merge", "Ohio")

# Mean composite
mean_mosaic <- create_raster_mosaic(raster_list, method = "mean")
} # }
```
