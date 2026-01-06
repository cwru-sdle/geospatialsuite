# Select rasters for specific region with intelligent filtering

Intelligently select raster files that overlap with a specified region.
For ASTER files (GDEM and WBD), uses filename-based coordinate
extraction for fast filtering without loading full rasters.

## Usage

``` r
select_rasters_for_region(
  input_folder,
  region_boundary,
  overlap = TRUE,
  buffer_size = 0.1
)
```

## Arguments

- input_folder:

  Directory containing raster files

- region_boundary:

  Region boundary or bounding box

- overlap:

  Logical. If TRUE (default), checks for actual overlap with region. If
  FALSE, only includes tiles whose centroid falls within region. Only
  applies to ASTER files; non-ASTER files always use overlap detection.

- buffer_size:

  Buffer around region (in degrees)

## Value

Character vector of relevant file paths

## Examples

``` r
# \donttest{
# Select ASTER files for Michigan using overlap detection
michigan_files <- select_rasters_for_region("/aster/files", "Michigan")
#> Selecting rasters for specified region...
#> Selected 0 files out of 0 for the specified region

# Use centroid-based selection (faster, fewer tiles)
michigan_files_centroid <- select_rasters_for_region("/aster/files", "Michigan", 
                                                      overlap = FALSE)
#> Selecting rasters for specified region...
#> Selected 0 files out of 0 for the specified region

# Select with custom buffer
nevada_files <- select_rasters_for_region("/data", "Nevada", buffer_size = 0.2)
#> Selecting rasters for specified region...
#> Selected 0 files out of 0 for the specified region
# }
```
