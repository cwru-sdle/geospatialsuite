# Get path to sample data file

Helper function to get the full path to a sample data file included with
geospatialsuite. This is useful when you want the file path rather than
loading the data directly.

## Usage

``` r
get_sample_data(filename)
```

## Arguments

- filename:

  Name of sample data file (e.g., "sample_red.rds")

## Value

Character string with full path to file

## Examples

``` r
# \donttest{
# Get path to sample raster
red_file <- get_sample_data("sample_red.rds")
nir_file <- get_sample_data("sample_nir.rds")

# Load manually with terra::rast() for PackedSpatRaster
red <- terra::rast(readRDS(red_file))
nir <- terra::rast(readRDS(nir_file))

# Or use load_sample_data() directly (recommended)
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")

# Calculate NDVI
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
# plot(ndvi)
# }
```
