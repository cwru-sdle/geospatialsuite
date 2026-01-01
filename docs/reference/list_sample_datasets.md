# List available sample datasets

Display information about all sample datasets included with
geospatialsuite.

## Usage

``` r
list_sample_datasets(detailed = TRUE)
```

## Arguments

- detailed:

  Return detailed information? (default: TRUE)

## Value

Data frame with dataset information

## Examples

``` r
# \donttest{
# List all sample datasets
datasets <- list_sample_datasets()
print(datasets)
#>                 filename       type size_kb
#> 1         sample_red.rds SpatRaster       2
#> 2         sample_nir.rds SpatRaster       2
#> 3        sample_blue.rds SpatRaster       2
#> 4       sample_green.rds SpatRaster       2
#> 5       sample_swir1.rds SpatRaster       2
#> 6   sample_multiband.rds SpatRaster       8
#> 7      sample_points.rds         sf       3
#> 8    sample_boundary.rds         sf       2
#> 9 sample_coordinates.csv data.frame       1
#>                                          description
#> 1   Red band reflectance (10x10 pixels, Ohio region)
#> 2   NIR band reflectance (10x10 pixels, Ohio region)
#> 3  Blue band reflectance (10x10 pixels, Ohio region)
#> 4 Green band reflectance (10x10 pixels, Ohio region)
#> 5 SWIR1 band reflectance (10x10 pixels, Ohio region)
#> 6   Multi-band raster (Blue, Green, Red, NIR, SWIR1)
#> 7 Sample field locations (20 points with attributes)
#> 8                 Sample study area boundary polygon
#> 9    Sample coordinates with elevation and soil data
#>                                          use_case available
#> 1 Vegetation index calculation (NDVI, SAVI, etc.)      TRUE
#> 2 Vegetation index calculation (NDVI, SAVI, etc.)      TRUE
#> 3     Enhanced vegetation index (EVI) calculation      TRUE
#> 4           Water index calculation (NDWI, GNDVI)      TRUE
#> 5        Water and moisture indices (NDMI, MNDWI)      TRUE
#> 6    Auto band detection, multi-index calculation      TRUE
#> 7     Spatial join examples, extraction workflows      TRUE
#> 8    Region boundary examples, masking operations      TRUE
#> 9         Geocoding, spatial integration examples      TRUE
#>                                access_method
#> 1         load_sample_data('sample_red.rds')
#> 2         load_sample_data('sample_nir.rds')
#> 3        load_sample_data('sample_blue.rds')
#> 4       load_sample_data('sample_green.rds')
#> 5       load_sample_data('sample_swir1.rds')
#> 6   load_sample_data('sample_multiband.rds')
#> 7      load_sample_data('sample_points.rds')
#> 8    load_sample_data('sample_boundary.rds')
#> 9 load_sample_data('sample_coordinates.csv')

# Quick list
datasets_simple <- list_sample_datasets(detailed = FALSE)
# }
```
