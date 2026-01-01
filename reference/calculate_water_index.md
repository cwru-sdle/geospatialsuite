# Calculate water indices including both NDWI variants

Calculate various water indices including NDWI (McFeeters 1996), MNDWI
(Xu 2006), and NDMI (Gao 1996) for water body detection and moisture
content. Updated formulas based on latest research and satellite
missions (2024).

## Usage

``` r
calculate_water_index(
  green,
  nir,
  swir1 = NULL,
  index_type = "NDWI",
  clamp_range = NULL,
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

  SWIR1 band SpatRaster or file path (for MNDWI, NDMI)

- index_type:

  Index type: "NDWI", "MNDWI", "NDMI", "MSI", "NDII", "WI", "SRWI",
  "LSWI"

- clamp_range:

  Optional range to clamp output values

- mask_invalid:

  Mask invalid/extreme values

- verbose:

  Print progress messages

## Value

SpatRaster of water index

## Details

Available water indices with their specific applications:

### Primary Water Detection Indices:

- **NDWI** (McFeeters 1996): (Green - NIR) / (Green + NIR) - **Use**:
  Open water body detection, flood mapping - **Range**: Values from -1
  to 1, water bodies typically \> 0.3 - **Pros**: Simple, effective for
  clear water - **Cons**: Sensitive to built-up areas, can overestimate
  water

- **MNDWI** (Xu 2006): (Green - SWIR1) / (Green + SWIR1) - **Use**:
  Enhanced water detection, urban water bodies - **Range**: Values from
  -1 to 1, water bodies typically \> 0.5 - **Pros**: Better separation
  of water from built-up areas - **Cons**: Requires SWIR band, less
  effective with turbid water

### Vegetation Moisture Indices:

- **NDMI** (Gao 1996): (NIR - SWIR1) / (NIR + SWIR1) - **Use**:
  Vegetation water content, drought monitoring - **Range**: Values from
  -1 to 1, higher values = more water content - **Application**:
  Agriculture, forest fire risk assessment

- **MSI**: SWIR1 / NIR - Moisture Stress Index - **Use**: Plant water
  stress detection - **Range**: `[0, 5+]`, lower values = higher
  moisture

- **NDII**: (NIR - SWIR1) / (NIR + SWIR1) - Same as NDMI - **Use**:
  Alternative name for NDMI, vegetation moisture

### Specialized Water Indices:

- **WI**: NIR / SWIR1 - Water Index (simple ratio)

- **SRWI**: NIR / SWIR1 - Simple Ratio Water Index

- **LSWI**: (NIR - SWIR1) / (NIR + SWIR1) - Land Surface Water Index

### Band Requirements by Satellite:

- **Landsat 8/9**: Green=Band 3, NIR=Band 5, SWIR1=Band 6

- **Sentinel-2**: Green=Band 3, NIR=Band 8, SWIR1=Band 11

- **MODIS**: Green=Band 4, NIR=Band 2, SWIR1=Band 6

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require external data files not included with the package
# Original NDWI for water body detection
ndwi <- calculate_water_index(green_band, nir_band, index_type = "NDWI")

# Modified NDWI for enhanced water detection (requires SWIR1)
mndwi <- calculate_water_index(green_band, nir_band, swir1_band, index_type = "MNDWI")

# NDMI for vegetation moisture monitoring
ndmi <- calculate_water_index(green_band, nir_band, swir1_band, index_type = "NDMI")

# With quality control
water_index <- calculate_water_index(
  green = "green.tif",
  nir = "nir.tif",
  swir1 = "swir1.tif",
  index_type = "MNDWI",
  clamp_range = c(-1, 1),
  mask_invalid = TRUE,
  verbose = TRUE
)
} # }
```
