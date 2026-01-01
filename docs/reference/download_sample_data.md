# Download or access sample datasets for geospatialsuite

Access built-in sample datasets for learning and testing geospatialsuite
functionality. All datasets are in .rds format (CRAN-preferred) and
included with the package (~50-80KB total).

## Usage

``` r
download_sample_data(
  dataset = "all",
  dest_dir = tempdir(),
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- dataset:

  Name of dataset to download. See
  [`list_sample_datasets()`](https://cwru-sdle.github.io/geospatialsuite/reference/list_sample_datasets.md)
  for available options. Use "all" to list all datasets.

- dest_dir:

  Directory to save downloaded data (default: tempdir())

- overwrite:

  Overwrite existing files? (default: FALSE)

- verbose:

  Print download progress? (default: TRUE)

## Value

Character vector of file paths to sample data

## Details

### Built-in Sample Data (No Download Required)

The package includes small sample datasets in inst/extdata/ using .rds
format:

- **sample_red.rds**: Red band SpatRaster (10x10 pixels, Ohio region)

- **sample_nir.rds**: NIR band SpatRaster (10x10 pixels)

- **sample_blue.rds**: Blue band SpatRaster (10x10 pixels)

- **sample_green.rds**: Green band SpatRaster (10x10 pixels)

- **sample_swir1.rds**: SWIR1 band SpatRaster (10x10 pixels)

- **sample_multiband.rds**: Multi-band SpatRaster (5 layers stacked)

- **sample_points.rds**: Sample field locations (20 points, sf object)

- **sample_boundary.rds**: Sample study area polygon (sf object)

- **sample_coordinates.csv**: Sample coordinates with attributes

All .rds files contain native R objects (SpatRaster or sf) that load
instantly with readRDS() or the load_sample_data() helper function.

## Examples

``` r
# \donttest{
# List available datasets
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

# Get path to built-in sample data
red_file <- get_sample_data("sample_red.rds")
nir_file <- get_sample_data("sample_nir.rds")

# Load and use sample data
red <- load_sample_data("sample_red.rds")
nir <- load_sample_data("sample_nir.rds")
ndvi <- calculate_vegetation_index(red = red, nir = nir, index_type = "NDVI")
  # Plot (users can run this interactively)
  # plot(ndvi, main = "NDVI", col = terrain.colors(100))
# }
```
