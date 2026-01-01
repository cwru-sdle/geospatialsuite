# Select rasters for specific region with intelligent filtering

Intelligently select raster files that overlap with a specified region.

## Usage

``` r
select_rasters_for_region(input_folder, region_boundary, buffer_size = 0.1)
```

## Arguments

- input_folder:

  Directory containing raster files

- region_boundary:

  Region boundary or bounding box

- buffer_size:

  Buffer around region (in degrees)

## Value

Character vector of relevant file paths

## Examples

``` r
# \donttest{
# Select ASTER files for Michigan
michigan_files <- select_rasters_for_region("/aster/files", "Michigan")
#> Selecting rasters for specified region...
#> Selected 0 files out of 0 for the specified region

# Select with custom buffer
nevada_files <- select_rasters_for_region("/data", "Nevada", buffer_size = 0.2)
#> Selecting rasters for specified region...
#> Selected 0 files out of 0 for the specified region
# }
```
