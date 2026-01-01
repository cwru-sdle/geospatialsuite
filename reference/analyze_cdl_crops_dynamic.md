# Analyze CDL crops dynamically

Perform dynamic analysis of CDL crop data including area calculations,
classification, and masking for any crop combination. Now accepts file
paths directly.

## Usage

``` r
analyze_cdl_crops_dynamic(
  cdl_data,
  crop_selection,
  region_boundary = NULL,
  analysis_type = "classify",
  output_folder = NULL,
  year = NULL
)
```

## Arguments

- cdl_data:

  CDL raster data (file path, directory, or SpatRaster object)

- crop_selection:

  Crop selection (names, codes, or categories)

- region_boundary:

  Region boundary

- analysis_type:

  Type of analysis: "mask", "classify", "area"

- output_folder:

  Output directory

- year:

  Year for analysis (optional)

## Value

Analysis results depend on analysis_type:

- **"mask"**: SpatRaster with binary mask (1 = crop, 0 = other)

- **"classify"**: SpatRaster with binary classification

- **"area"**: List with detailed area analysis:

  - `crop_areas_ha`: Named list of areas by crop code (hectares)

  - `total_area_ha`: Total crop area (hectares)

  - `pixel_size_ha`: Individual pixel size (hectares)

  - `crop_codes`: CDL codes analyzed

  - `crop_name`: Crop name(s)

  - `region`: Region analyzed

  - `raster_info`: Technical raster information

  - `total_pixels`: Total number of pixels

  - `valid_pixels`: Number of valid (non-NA) pixels

## Details

### Usage Tips:

#### Area Analysis Results:

    # Access specific results
    result$total_area_ha          # Total area in hectares
    result$crop_areas_ha          # Area by crop code
    result$crop_areas_ha[["5"]]   # Soybean area (code 5)

#### Visualization:

    # For mask/classify results (SpatRaster):
    terra::plot(result)           # Plot the raster

    # For area results (list):
    print(result$total_area_ha)   # Print total area
    barplot(unlist(result$crop_areas_ha))  # Simple bar plot

## Examples

``` r
if (FALSE) { # \dontrun{
# These examples require actual CDL data files
# Analyze soybean area in Iowa - accepts file path directly
soybean_area <- analyze_cdl_crops_dynamic(
  "/path/to/cdl_2023.tif", "soybeans", "Iowa", "area"
)

# Access area results
soybean_area$total_area_ha                    # Total hectares
soybean_area$crop_areas_ha[["5"]]            # Soybean area (code 5)
soybean_area$total_area_ha * 2.47105         # Convert to acres

# Create grain classification
grain_classes <- analyze_cdl_crops_dynamic(
  cdl_data, "grains", "CONUS", "classify"
)
terra::plot(grain_classes)  # Plot the classification

# Works with directories too
results <- analyze_cdl_crops_dynamic(
  "/path/to/cdl/files/", "corn", "Ohio", "area"
)
} # }

# \donttest{
# Example with mock CDL data (this can run)
# Create sample CDL raster
mock_cdl <- terra::rast(nrows = 10, ncols = 10, xmin = 0, xmax = 10,
                       ymin = 0, ymax = 10, crs = "EPSG:4326")
terra::values(mock_cdl) <- sample(c(1, 5, 24), 100, replace = TRUE)  # corn, soy, wheat

# Analyze mock data
result <- analyze_cdl_crops_dynamic(mock_cdl, "corn", analysis_type = "mask")
#> Starting dynamic CDL crop analysis...
#> Analyzing 1 crop codes for corn
#> CDL analysis completed!
print(class(result))  # Should be SpatRaster
#> [1] "SpatRaster"
#> attr(,"package")
#> [1] "terra"
# }
```
