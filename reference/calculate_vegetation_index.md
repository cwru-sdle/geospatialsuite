# Calculate comprehensive vegetation indices

Calculate a wide range of vegetation indices from spectral bands with
automatic band detection, comprehensive error handling, and validation.
Supports 40+ different vegetation indices for various applications.
Accepts directories, file lists, and automatic CRS handling.

## Usage

``` r
calculate_vegetation_index(
  spectral_data = NULL,
  red = NULL,
  nir = NULL,
  blue = NULL,
  green = NULL,
  swir1 = NULL,
  swir2 = NULL,
  red_edge = NULL,
  coastal = NULL,
  nir2 = NULL,
  index_type = "NDVI",
  auto_detect_bands = FALSE,
  band_names = NULL,
  clamp_range = NULL,
  mask_invalid = TRUE,
  scale_factor = 1,
  auto_crs_fix = TRUE,
  region_boundary = NULL,
  verbose = FALSE
)
```

## Arguments

- spectral_data:

  Either individual bands (red, nir, etc.), a multi-band raster,
  directory path, or list of raster files

- red:

  Red band SpatRaster or file path

- nir:

  NIR band SpatRaster or file path

- blue:

  Optional blue band

- green:

  Optional green band

- swir1:

  Optional SWIR1 band

- swir2:

  Optional SWIR2 band

- red_edge:

  Optional Red Edge band

- coastal:

  Optional Coastal/Aerosol band

- nir2:

  Optional second NIR band

- index_type:

  Vegetation index to calculate (see list_vegetation_indices())

- auto_detect_bands:

  Automatically detect bands from multi-band raster

- band_names:

  Custom band names for multi-band input

- clamp_range:

  Range to clamp output values (optional)

- mask_invalid:

  Mask invalid/extreme values

- scale_factor:

  Scaling factor if needed (default: 1)

- auto_crs_fix:

  Automatically fix CRS mismatches between bands

- region_boundary:

  Optional boundary to crop and mask the result. Can be an sf object,
  file path to shapefile, or region name (if get_region_boundary() is
  available)

- verbose:

  Print progress messages

## Value

SpatRaster of vegetation index

## Details

### Input Format Support:

#### Single Calculation:

    # Individual band files
    ndvi <- calculate_vegetation_index(red = "red.tif", nir = "nir.tif", index_type = "NDVI")

    # Multi-band raster
    evi <- calculate_vegetation_index(spectral_data = "landsat.tif", index_type = "EVI",
                                     auto_detect_bands = TRUE)

#### Directory/Multiple Files:

    # Directory with band files
    savi <- calculate_vegetation_index(spectral_data = "/path/to/bands/",
                                      band_names = c("red", "nir"), index_type = "SAVI")

    # File list
    arvi <- calculate_vegetation_index(spectral_data = c("red.tif", "nir.tif", "blue.tif"),
                                      index_type = "ARVI")

### Enhanced vs Basic NDVI:

#### Basic `calculate_vegetation_index()`:

- Single time point calculation

- 40+ different indices

- Directory/file support

- Automatic CRS fixing

- **Use for**: Single-date analysis, comparing different indices

#### [`calculate_ndvi_enhanced()`](https://cwru-sdle.github.io/geospatialsuite/reference/calculate_ndvi_enhanced.md):

- Time series support

- Quality filtering

- Temporal smoothing

- Date matching between red/NIR

- **Use for**: Multi-temporal analysis, time series trends

\#' \## Band Naming Conventions:

The function supports case-insensitive band detection:

- **Generic names**: "red"/"RED"/"Red", "nir"/"NIR", "blue"/"BLUE",
  "green"/"GREEN"

- **Landsat 8/9**: B1-B7 (e.g., B4=Red, B5=NIR)

- **Sentinel-2**: B01-B12 (e.g., B04=Red, B08=NIR, B05=RedEdge)

- **MODIS**: band1-band7

#### Satellite-Specific Examples:

**Landsat 8/9:**

    # Bands automatically detected
    ndvi <- calculate_vegetation_index(
      spectral_data = "LC08_stack.tif",  # Has bands named B1-B7
      index_type = "NDVI",
      auto_detect_bands = TRUE
    )

**Sentinel-2:**

    # Red Edge indices need Sentinel-2
    ndre <- calculate_vegetation_index(
      spectral_data = sentinel_data,  # Has B01-B12
      index_type = "NDRE",
      auto_detect_bands = TRUE
    )

**Custom band names:**

    # Rename your bands first
    names(my_raster) <- c("red", "nir", "blue", "green")

    # Or specify explicitly
    ndvi <- calculate_vegetation_index(
      red = my_raster[[1]],
      nir = my_raster[[4]],
      index_type = "NDVI"
    )

For complete band naming documentation, see:
[`vignette("vegetation-indices", package = "geospatialsuite")`](https://cwru-sdle.github.io/geospatialsuite/articles/vegetation-indices.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require satellite imagery files (Landsat/Sentinel data etc.)
# Basic NDVI calculation
ndvi <- calculate_vegetation_index(red = red_band, nir = nir_band, index_type = "NDVI")

# Multi-band raster with auto-detection
evi <- calculate_vegetation_index(spectral_data = landsat_stack,
                                 index_type = "EVI", auto_detect_bands = TRUE)

# Directory with automatic band detection
savi <- calculate_vegetation_index(spectral_data = "/path/to/sentinel/bands/",
                                  index_type = "SAVI", auto_detect_bands = TRUE)

# Advanced index with custom parameters
pri <- calculate_vegetation_index(red = red_band, nir = nir_band, green = green_band,
                                 index_type = "PRI", clamp_range = c(-1, 1))

# Custom band names for multi-band data
ndvi <- calculate_vegetation_index(spectral_data = sentinel_data,
                                  band_names = c("B4", "B3", "B2", "B8"),
                                  index_type = "NDVI")

# With region boundary (auto CRS conversion and crop/mask)
ndvi_ohio <- calculate_vegetation_index(red = red_band, nir = nir_band,
                                       index_type = "NDVI",
                                       region_boundary = boundary_sf,
                                       verbose = TRUE)
} # }
```
