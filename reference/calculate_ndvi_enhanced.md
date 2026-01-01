# Calculate NDVI with time series options

NDVI calculation specifically designed for time series analysis with
date matching, quality filtering, temporal smoothing, and multi-temporal
support. **Use this for time series analysis, use
calculate_vegetation_index() for single dates.**

## Usage

``` r
calculate_ndvi_enhanced(
  red_data,
  nir_data,
  clamp_range = c(-0.2, 1),
  match_by_date = FALSE,
  quality_filter = FALSE,
  temporal_smoothing = FALSE,
  verbose = FALSE,
  date_patterns = NULL
)
```

## Arguments

- red_data:

  Red band data (files, directory, or raster objects)

- nir_data:

  NIR band data (files, directory, or raster objects)

- clamp_range:

  Range to clamp NDVI values (default: c(-0.2, 1))

- match_by_date:

  Logical: match rasters by date using filenames

- quality_filter:

  Apply quality filtering (remove outliers)

- temporal_smoothing:

  Apply temporal smoothing for time series

- verbose:

  Print progress messages

- date_patterns:

  Custom date patterns for matching

## Value

SpatRaster with NDVI layers (single or multi-layer for time series)

## Details

### When to Use Enhanced vs Basic NDVI:

#### Use `calculate_ndvi_enhanced()` for:

- **Time series analysis**: Multiple dates, trend analysis

- **Quality control**: Remove outliers, temporal smoothing

- **Date matching**: Automatic pairing of red/NIR by date

- **Multi-temporal studies**: Seasonal analysis, change detection

#### Use `calculate_vegetation_index(index_type="NDVI")` for:

- **Single date analysis**: One-time calculation

- **Different indices**: Want to calculate EVI, SAVI, etc. too

- **Quick calculations**: Simple, fast NDVI

- **Mixed workflows**: Part of larger vegetation index analysis

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Time series NDVI with date matching
ndvi_series <- calculate_ndvi_enhanced(
  red_data = "/path/to/red/time_series/",
  nir_data = "/path/to/nir/time_series/",
  match_by_date = TRUE,
  quality_filter = TRUE,
  temporal_smoothing = TRUE
)

# Simple NDVI (single date with quality control)
ndvi_clean <- calculate_ndvi_enhanced(
  red_data = red_raster,
  nir_data = nir_raster,
  quality_filter = TRUE
)
} # }
```
