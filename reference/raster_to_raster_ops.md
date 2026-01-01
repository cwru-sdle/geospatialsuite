# Raster to Raster Operations

Specialized function for mathematical and overlay operations between
rasters. Handles alignment, projection, and complex operations with
comprehensive error handling and performance optimization.

## Usage

``` r
raster_to_raster_ops(
  raster1,
  raster2,
  operation = "overlay",
  align_method = "resample",
  summary_function = "mean",
  handle_na = "propagate",
  mask_value = NA,
  output_file = NULL,
  verbose = FALSE
)
```

## Arguments

- raster1:

  First raster (SpatRaster or file path)

- raster2:

  Second raster (SpatRaster or file path)

- operation:

  Character. Mathematical operation:

  - **"add"**: Add rasters (raster1 + raster2)

  - **"subtract"**: Subtract rasters (raster1 - raster2)

  - **"multiply"**: Multiply rasters (raster1 \* raster2)

  - **"divide"**: Divide rasters (raster1 / raster2)

  - **"mask"**: Mask raster1 with raster2

  - **"overlay"**: Combine with summary function

  - **"difference"**: Absolute difference \|raster1 - raster2\|

  - **"ratio"**: Ratio raster1 / raster2 (with zero handling)

- align_method:

  Character. How to align mismatched rasters:

  - **"resample"**: Resample raster2 to match raster1 (default)

  - **"crop"**: Crop both to common extent

  - **"extend"**: Extend smaller raster to match larger

  - **"project"**: Reproject raster2 to raster1 CRS

- summary_function:

  Character. Function for overlay operation

- handle_na:

  Character. How to handle NA values:

  - **"propagate"**: NA + value = NA (default)

  - **"ignore"**: Skip NAs in calculations

  - **"zero"**: Treat NAs as zero

- mask_value:

  Numeric. Value to use for masking (default: NA)

- output_file:

  Character. Optional output file path

- verbose:

  Logical. Print processing details

## Value

SpatRaster with operation results

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Mathematical operations
sum_raster <- raster_to_raster_ops("ndvi.tif", "evi.tif", "add")
diff_raster <- raster_to_raster_ops("before.tif", "after.tif", "subtract")

# Masking operations
masked <- raster_to_raster_ops("data.tif", "mask.tif", "mask")

# Complex overlay with alignment
overlay <- raster_to_raster_ops(
  raster1 = "fine_res.tif",
  raster2 = "coarse_res.tif",
  operation = "overlay",
  align_method = "resample",
  summary_function = "mean",
  verbose = TRUE
)
} # }
```
