# Load sample data directly

Convenience function to load sample data directly into R objects.
Automatically detects file type and uses appropriate loading function.
For .rds files containing SpatRaster objects, properly unpacks from
PackedSpatRaster format. For .csv files, uses read.csv().

## Usage

``` r
load_sample_data(filename, ...)
```

## Arguments

- filename:

  Name of sample data file

- ...:

  Additional arguments passed to loading function

## Value

Loaded data object (SpatRaster, sf, or data.frame)

## Examples

``` r
# \donttest{
# Load raster data (returns SpatRaster)
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")
blue <- load_sample_data("sample_blue.rds")

# Load vector data (returns sf object)
points <- load_sample_data("sample_points.rds")
boundary <- load_sample_data("sample_boundary.rds")

# Load CSV (returns data.frame)
coords <- load_sample_data("sample_coordinates.csv")

# Use loaded data
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
evi <- calculate_vegetation_index(red = red, nir = nir, blue = blue, index_type = "EVI")
# plot(ndvi, main = "NDVI")
# plot(evi, main = "EVI")
# }
```
