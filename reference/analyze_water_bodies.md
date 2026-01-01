# Analyze water body characteristics using multiple indices

Comprehensive water body analysis using multiple water indices to
classify and characterize water features.

## Usage

``` r
analyze_water_bodies(
  green,
  nir,
  swir1 = NULL,
  region_boundary = NULL,
  water_threshold_ndwi = 0.3,
  water_threshold_mndwi = 0.5,
  output_folder = NULL,
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

- region_boundary:

  Optional region boundary for analysis

- water_threshold_ndwi:

  NDWI threshold for water detection (default: 0.3)

- water_threshold_mndwi:

  MNDWI threshold for water detection (default: 0.5)

- output_folder:

  Optional output directory

- verbose:

  Print progress messages

## Value

List with water analysis results

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Comprehensive water analysis
water_analysis <- analyze_water_bodies(
  green = "green.tif",
  nir = "nir.tif",
  swir1 = "swir1.tif",
  region_boundary = "study_area.shp",
  verbose = TRUE
)

# Access results
water_analysis$water_indices     # All calculated indices
water_analysis$water_mask        # Binary water mask
water_analysis$statistics        # Water body statistics
} # }
```
