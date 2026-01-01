# Calculate multiple vegetation indices at once

Calculate multiple vegetation indices from the same spectral data in a
single operation. Efficient for comparative analysis and comprehensive
vegetation assessment. Supports directory input and automatic CRS
handling.

## Usage

``` r
calculate_multiple_indices(
  spectral_data = NULL,
  indices = c("NDVI", "EVI", "SAVI"),
  output_stack = TRUE,
  region_boundary = NULL,
  parallel = FALSE,
  verbose = FALSE,
  ...
)
```

## Arguments

- spectral_data:

  Multi-band raster, directory path, or individual bands

- indices:

  Vector of index names to calculate

- output_stack:

  Return as single multi-layer raster (TRUE) or list (FALSE)

- region_boundary:

  Optional region boundary for clipping

- parallel:

  Use parallel processing for multiple indices

- verbose:

  Print progress messages

- ...:

  Additional arguments passed to calculate_vegetation_index

## Value

SpatRaster stack or list of indices

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require satellite imagery files (Landsat/Sentinel data etc.)
# Calculate multiple basic indices from directory
multi_indices <- calculate_multiple_indices(
  spectral_data = "/path/to/sentinel/bands/",
  indices = c("NDVI", "EVI", "SAVI", "MSAVI"),
  auto_detect_bands = TRUE
)

# Comprehensive vegetation analysis from individual files
veg_analysis <- calculate_multiple_indices(
  red = red_band, nir = nir_band, blue = blue_band,
  indices = c("NDVI", "EVI", "ARVI", "GNDVI", "DVI"),
  output_stack = TRUE,
  region_boundary = "Iowa"
)

# Directory with custom band matching
stress_indices <- calculate_multiple_indices(
  spectral_data = "/path/to/bands/",
  indices = c("PRI", "SIPI", "NDRE"),
  band_names = c("red", "green", "nir", "red_edge"),
  output_stack = TRUE
)
} # }
```
