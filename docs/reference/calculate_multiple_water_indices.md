# Calculate multiple water indices at once

Calculate multiple water indices from the same spectral data in a single
operation. Efficient for comprehensive water and moisture analysis.

## Usage

``` r
calculate_multiple_water_indices(
  green,
  nir,
  swir1 = NULL,
  indices = c("NDWI", "MNDWI", "NDMI"),
  output_stack = TRUE,
  clamp_values = TRUE,
  mask_invalid = TRUE,
  verbose = FALSE
)
```

## Arguments

- green:

  Green band SpatRaster or file path

- nir:

  NIR band SpatRaster or file path

- swir1:

  SWIR1 band SpatRaster or file path

- indices:

  Vector of index names to calculate

- output_stack:

  Return as single multi-layer raster (TRUE) or list (FALSE)

- clamp_values:

  Apply reasonable value clamping

- mask_invalid:

  Mask invalid values

- verbose:

  Print progress messages

## Value

SpatRaster stack or list of water indices

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Calculate multiple water indices
water_indices <- calculate_multiple_water_indices(
  green = green_band,
  nir = nir_band,
  swir1 = swir1_band,
  indices = c("NDWI", "MNDWI", "NDMI", "MSI"),
  output_stack = TRUE,
  verbose = TRUE
)

# Access individual indices
ndwi <- water_indices[["NDWI"]]
mndwi <- water_indices[["MNDWI"]]
} # }
```
