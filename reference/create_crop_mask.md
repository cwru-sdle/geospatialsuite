# Create crop mask from CDL data

Create binary or classified crop mask from USDA CDL data for specified
crops. Fixed to handle terra operations properly.

## Usage

``` r
create_crop_mask(
  cdl_data,
  crop_codes,
  region_boundary = NULL,
  mask_type = "binary"
)
```

## Arguments

- cdl_data:

  CDL raster data (file path or SpatRaster)

- crop_codes:

  Vector of CDL codes or crop names

- region_boundary:

  Optional region boundary for clipping

- mask_type:

  Type of mask: "binary" (1/0) or "preserve" (keep original codes)

## Value

SpatRaster with crop mask

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require actual CDL data files
# Create corn mask
corn_mask <- create_crop_mask("cdl_2023.tif", "corn", "Iowa")

# Create grain crops mask
grain_mask <- create_crop_mask(cdl_raster, "grains", mask_type = "preserve")
} # }

# \donttest{
# Example with mock data (this can run)
mock_cdl <- terra::rast(nrows = 5, ncols = 5, crs = "EPSG:4326")
terra::values(mock_cdl) <- c(1, 1, 5, 5, 24, 1, 5, 5, 24, 24,
                            1, 1, 5, 24, 24, 5, 5, 24, 24, 1,
                            1, 5, 5, 24, 1)  # corn, soy, wheat

# Create corn mask from mock data
corn_mask <- create_crop_mask(mock_cdl, "corn")
print(terra::values(corn_mask))  # Should show 1s and 0s
#>       crop_mask_binary
#>  [1,]                1
#>  [2,]                1
#>  [3,]                0
#>  [4,]                0
#>  [5,]                0
#>  [6,]                1
#>  [7,]                0
#>  [8,]                0
#>  [9,]                0
#> [10,]                0
#> [11,]                1
#> [12,]                1
#> [13,]                0
#> [14,]                0
#> [15,]                0
#> [16,]                0
#> [17,]                0
#> [18,]                0
#> [19,]                0
#> [20,]                1
#> [21,]                1
#> [22,]                0
#> [23,]                0
#> [24,]                0
#> [25,]                1
# }
```
